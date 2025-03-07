import SwiftUI

@MainActor
class MealPlanningService: ObservableObject {
    static let shared = MealPlanningService()
    
    @Published var meals: [Meal] = []
    @Published var isGenerating = false
    @Published var error: String?
    
    private init() {
        // Initialize with sample data
        meals = [
            Meal(id: "1", 
                 title: "Overnight Oats with Berries",
                 description: "Healthy and delicious breakfast with fresh berries and honey",
                 imageURL: nil,
                 type: .breakfast,
                 calories: 350,
                 prepTime: 10,
                 servings: 1,
                 ingredients: ["Oats", "Milk", "Berries", "Honey"],
                 instructions: ["Mix oats and milk", "Add berries and honey", "Refrigerate overnight"],
                 dietaryTags: ["Vegetarian", "High Fiber"]),
            Meal(id: "2",
                 title: "Grilled Chicken Salad",
                 description: "Fresh garden salad with grilled chicken breast",
                 imageURL: nil,
                 type: .lunch,
                 calories: 450,
                 prepTime: 20,
                 servings: 1,
                 ingredients: ["Chicken breast", "Mixed greens", "Tomatoes", "Olive oil"],
                 instructions: ["Grill chicken", "Mix salad", "Add dressing"],
                 dietaryTags: ["High Protein", "Low Carb"])
        ]
    }
    
    func generateNewPlan() async {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            // TODO: Implement AI-powered meal plan generation
            // For now, just simulate a delay
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            
            // Update meals with new plan
            // This is where you would integrate with your AI service
            print("Generated new meal plan")
        } catch {
            self.error = error.localizedDescription
        }
    }
} 