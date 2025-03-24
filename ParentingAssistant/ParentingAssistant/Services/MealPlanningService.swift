import SwiftUI
import FirebaseFirestore

@MainActor
class MealPlanningService: ObservableObject {
    static let shared = MealPlanningService()
    
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func loadMeals(for date: Date) async {
        print("🔍 Loading meals for date: \(date)")
        isLoading = true
        error = nil
        
        do {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
            
            print("📅 Date components:")
            print("   - Input date: \(date)")
            print("   - Start of day: \(startOfDay)")
            print("   - End of day: \(endOfDay)")
            
            // Debug the query
            print("🔍 Query parameters:")
            print("   Collection: meals")
            print("   Start timestamp: \(Timestamp(date: startOfDay))")
            print("   End timestamp: \(Timestamp(date: endOfDay))")
            
            let query = db.collection("meals")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                .whereField("date", isLessThanOrEqualTo: Timestamp(date: endOfDay))
            
            print("📝 Query path: \(query)")
            
            let snapshot = try await query.getDocuments()
            
            print("📦 Found \(snapshot.documents.count) meals in Firestore")
            if snapshot.documents.isEmpty {
                print("⚠️ No documents found. Checking all meals in collection...")
                let allMeals = try await db.collection("meals").getDocuments()
                print("📊 Total meals in collection: \(allMeals.documents.count)")
                for doc in allMeals.documents {
                    print("   Document ID: \(doc.documentID)")
                    print("   Data: \(doc.data())")
                }
            }
            
            meals = snapshot.documents.compactMap { document in
                do {
                    let meal = try document.data(as: Meal.self)
                    print("✅ Successfully parsed meal: \(meal.name)")
                    return meal
                } catch {
                    print("❌ Failed to parse meal from document: \(error.localizedDescription)")
                    print("   Document ID: \(document.documentID)")
                    print("   Document data: \(document.data())")
                    return nil
                }
            }
            print("📊 Final meals count after parsing: \(meals.count)")
        } catch {
            print("❌ Error loading meals: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func generateNewPlan(for date: Date) async {
        print("🎲 Starting meal plan generation for date: \(date)")
        isGenerating = true
        error = nil
        
        do {
            // 1. Create a prompt for meal planning
            print("🤖 Creating meal planning prompt...")
            let promptContent = """
            Generate a healthy meal plan for one day including:
            - Breakfast (healthy and energizing)
            - Morning Snack (light and nutritious)
            - Lunch (balanced and filling)
            - Afternoon Snack (sustaining energy)
            - Dinner (nutritious and satisfying)
            
            For each meal include:
            - Creative name
            - List of ingredients with quantities
            - Simple step-by-step instructions
            - Complete nutrition info (calories, protein, carbs, fats, fiber)
            
            Make meals practical, healthy, and family-friendly.
            
            IMPORTANT: Format your response as a JSON object with the following structure:
            {
                "meals": [
                    {
                        "name": "Meal Name",
                        "type": "Breakfast|Lunch|Dinner|Snack",
                        "ingredients": ["ingredient 1", "ingredient 2", ...],
                        "instructions": "Step-by-step instructions",
                        "nutrition_info": "Nutrition information"
                    },
                    ...
                ]
            }
            """
            
            let prompt = try await PromptService.shared.createPrompt(
                category: .mealPlanning,
                content: promptContent
            )
            
            // 2. Generate response using OpenAI
            print("🤖 Generating meal plan with OpenAI...")
            let response = try await OpenAIService.shared.generateResponse(for: prompt)
            
            // 3. Parse the response into meals
            print("🔄 Parsing OpenAI response...")
            let meals = try parseMealsFromAIResponse(response.content)
            print("✅ Successfully parsed \(meals.count) meals from response")
            
            // 4. Save to Firestore
            print("💾 Saving meals to Firestore...")
            var savedMeals: [Meal] = []
            var firestoreError: Error? = nil
            
            for meal in meals {
                do {
                    let docRef = db.collection("meals").document()
                    var mealData = try Firestore.Encoder().encode(meal)
                    // Add the date field
                    mealData["date"] = Timestamp(date: date)
                    try await docRef.setData(mealData)
                    print("✅ Successfully saved meal: \(meal.name)")
                    print("   Document ID: \(docRef.documentID)")
                    savedMeals.append(meal)
                } catch {
                    print("❌ Failed to save meal \(meal.name): \(error.localizedDescription)")
                    firestoreError = error
                    // Continue with the next meal instead of throwing
                }
            }
            
            // If we couldn't save any meals but have generated meals, still show them to the user
            if savedMeals.isEmpty && !meals.isEmpty {
                print("⚠️ Warning: Could not save meals to Firestore, but will display generated meals")
                self.meals = meals
                
                if let error = firestoreError {
                    print("ℹ️ Firestore error: \(error.localizedDescription)")
                    // Set a milder error message
                    self.error = "Generated meal plan successfully, but couldn't save it to your account."
                }
            } else {
                // 5. Reload meals (only if we successfully saved some)
                print("🔄 Reloading meals after generation...")
                await loadMeals(for: date)
            }
            
        } catch {
            print("❌ Error generating meal plan: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
        
        isGenerating = false
    }
    
    private func parseMealsFromAIResponse(_ response: String) throws -> [Meal] {
        print("🔍 Parsing AI response: \(response)")
        
        // Try to find JSON content between triple backticks if present
        let jsonString: String
        if let jsonMatch = response.range(of: "```json\n(.*?)\n```", options: [.regularExpression]) {
            jsonString = String(response[jsonMatch])
                .replacingOccurrences(of: "```json\n", with: "")
                .replacingOccurrences(of: "\n```", with: "")
        } else {
            jsonString = response
        }
        
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let mealsArray = json["meals"] as? [[String: Any]] else {
            print("❌ Failed to parse JSON response")
            throw NSError(domain: "MealPlanningService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid AI response format"])
        }
        
        return mealsArray.compactMap { mealDict in
            // Extract name
            guard let name = mealDict["name"] as? String else {
                print("❌ Failed to parse meal: missing or invalid name")
                return nil
            }
            
            // Extract type and convert to MealType
            guard let typeStr = mealDict["type"] as? String else {
                print("❌ Failed to parse meal '\(name)': missing or invalid type")
                return nil
            }
            
            // Handle different meal type formats
            let mealType: MealType
            let normalizedType = typeStr.capitalized
            
            // Map meal types to our enum cases
            if normalizedType.contains("Breakfast") {
                mealType = .breakfast
            } else if normalizedType.contains("Lunch") {
                mealType = .lunch
            } else if normalizedType.contains("Dinner") {
                mealType = .dinner
            } else if normalizedType.contains("Snack") || normalizedType.contains("Morning") || normalizedType.contains("Afternoon") {
                mealType = .snack
            } else if let type = MealType(rawValue: normalizedType) {
                // Try direct mapping as fallback
                mealType = type
            } else {
                print("❌ Failed to parse meal '\(name)': unrecognized meal type '\(typeStr)'")
                return nil
            }
            
            // Extract ingredients, handling different array types
            let ingredients: [String]
            if let stringArray = mealDict["ingredients"] as? [String] {
                // Already in the right format
                ingredients = stringArray
            } else if let nsArray = mealDict["ingredients"] as? NSArray {
                // Handle NSArray by converting each element to String
                ingredients = nsArray.compactMap { $0 as? String }
            } else {
                print("❌ Failed to parse meal '\(name)': missing or invalid ingredients")
                return nil
            }
            
            // Extract instructions and nutrition info
            guard let instructions = mealDict["instructions"] as? String,
                  let nutritionInfo = mealDict["nutrition_info"] as? String else {
                print("❌ Failed to parse meal '\(name)': missing instructions or nutrition info")
                return nil
            }
            
            print("✅ Successfully parsed meal: \(name) (Type: \(mealType.rawValue))")
            return Meal(
                id: UUID().uuidString,
                name: name,
                type: mealType,
                ingredients: ingredients,
                instructions: instructions,
                nutritionInfo: nutritionInfo
            )
        }
    }
} 
