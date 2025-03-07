import Foundation

struct Meal: Identifiable {
    let id: String
    let title: String
    let description: String
    let imageURL: String?
    let type: MealType
    let calories: Int
    let prepTime: Int // in minutes
    let servings: Int
    let ingredients: [String]
    let instructions: [String]
    let dietaryTags: [String]
    
    init(id: String,
         title: String,
         description: String,
         imageURL: String?,
         type: MealType,
         calories: Int,
         prepTime: Int,
         servings: Int,
         ingredients: [String],
         instructions: [String],
         dietaryTags: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.type = type
        self.calories = calories
        self.prepTime = prepTime
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
        self.dietaryTags = dietaryTags
    }
}

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.and.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }
    
    var color: String {
        switch self {
        case .breakfast: return "FFB347" // Orange
        case .lunch: return "98FB98" // Light Green
        case .dinner: return "87CEEB" // Sky Blue
        case .snack: return "DDA0DD" // Light Purple
        }
    }
} 