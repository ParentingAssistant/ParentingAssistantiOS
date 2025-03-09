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
            // 1. Generate meal plan with OpenAI
            print("🤖 Calling OpenAI API to generate meal plan...")
            let prompt = """
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
            """
            
            // TODO: Replace with actual OpenAI API call
            print("⚠️ Using mock OpenAI response for now")
            let mockResponse = """
            {
              "meals": [
                {
                  "type": "breakfast",
                  "name": "Greek Yogurt Power Bowl",
                  "ingredients": ["1 cup Greek yogurt", "1/2 cup mixed berries", "1/4 cup granola", "1 tbsp honey", "1 tbsp chia seeds"],
                  "instructions": "1. Add yogurt to bowl\\n2. Top with berries\\n3. Sprinkle granola and chia seeds\\n4. Drizzle with honey",
                  "nutrition_info": "Calories: 350, Protein: 20g, Carbs: 45g, Fat: 12g, Fiber: 6g"
                },
                {
                  "type": "snack",
                  "name": "Apple and Almond Energy Bites",
                  "ingredients": ["1 medium apple", "2 tbsp almond butter", "1 tbsp rolled oats"],
                  "instructions": "1. Slice apple into wedges\\n2. Spread almond butter\\n3. Sprinkle with oats",
                  "nutrition_info": "Calories: 200, Protein: 6g, Carbs: 25g, Fat: 10g, Fiber: 4g"
                },
                {
                  "type": "lunch",
                  "name": "Rainbow Quinoa Buddha Bowl",
                  "ingredients": ["1 cup cooked quinoa", "1 cup roasted chickpeas", "1 cup mixed vegetables", "1/2 avocado", "2 tbsp tahini dressing"],
                  "instructions": "1. Place quinoa as base\\n2. Arrange vegetables and chickpeas\\n3. Add sliced avocado\\n4. Drizzle with dressing",
                  "nutrition_info": "Calories: 450, Protein: 15g, Carbs: 55g, Fat: 20g, Fiber: 12g"
                },
                {
                  "type": "snack",
                  "name": "Trail Mix Power Pack",
                  "ingredients": ["1/4 cup mixed nuts", "2 tbsp dried cranberries", "1 tbsp dark chocolate chips"],
                  "instructions": "Mix all ingredients in a small container",
                  "nutrition_info": "Calories: 180, Protein: 5g, Carbs: 15g, Fat: 12g, Fiber: 3g"
                },
                {
                  "type": "dinner",
                  "name": "Herb-Crusted Baked Salmon with Roasted Vegetables",
                  "ingredients": ["6 oz salmon fillet", "2 cups mixed vegetables", "2 tbsp olive oil", "1 tbsp herbs de provence", "1 lemon"],
                  "instructions": "1. Preheat oven to 400°F\\n2. Season salmon with herbs\\n3. Toss vegetables with oil\\n4. Bake for 20 minutes\\n5. Serve with lemon wedges",
                  "nutrition_info": "Calories: 420, Protein: 35g, Carbs: 25g, Fat: 22g, Fiber: 6g"
                }
              ]
            }
            """
            
            // 2. Parse the response
            print("🔄 Parsing OpenAI response...")
            let meals = try parseMealsFromAIResponse(mockResponse)
            print("✅ Successfully parsed \(meals.count) meals from response")
            
            // 3. Save to Firestore
            print("💾 Saving meals to Firestore...")
            for meal in meals {
                do {
                    let docRef = db.collection("meals").document()
                    var mealData = try Firestore.Encoder().encode(meal)
                    // Add the date field
                    mealData["date"] = Timestamp(date: date)
                    try await docRef.setData(mealData)
                    print("✅ Successfully saved meal: \(meal.name)")
                    print("   Document ID: \(docRef.documentID)")
                    print("   Data: \(mealData)")
                } catch {
                    print("❌ Failed to save meal \(meal.name): \(error.localizedDescription)")
                    throw error
                }
            }
            
            // 4. Reload meals
            print("🔄 Reloading meals after generation...")
            await loadMeals(for: date)
            
        } catch {
            print("❌ Error generating meal plan: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
        
        isGenerating = false
    }
    
    private func parseMealsFromAIResponse(_ response: String) throws -> [Meal] {
        print("🔍 Parsing AI response: \(response)")
        // TODO: Implement actual parsing logic
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let mealsArray = json["meals"] as? [[String: Any]] else {
            print("❌ Failed to parse JSON response")
            throw NSError(domain: "MealPlanningService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid AI response format"])
        }
        
        return mealsArray.compactMap { mealDict in
            guard let name = mealDict["name"] as? String,
                  let typeStr = mealDict["type"] as? String,
                  let type = MealType(rawValue: typeStr.capitalized),
                  let ingredients = mealDict["ingredients"] as? [String],
                  let instructions = mealDict["instructions"] as? String,
                  let nutritionInfo = mealDict["nutrition_info"] as? String else {
                print("❌ Failed to parse meal dictionary: \(mealDict)")
                return nil
            }
            
            print("✅ Successfully parsed meal: \(name)")
            return Meal(
                id: UUID().uuidString,
                name: name,
                type: type,
                ingredients: ingredients,
                instructions: instructions,
                nutritionInfo: nutritionInfo
            )
        }
    }
} 
