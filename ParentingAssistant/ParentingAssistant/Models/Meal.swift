import Foundation
import FirebaseFirestore

struct Meal: Codable, Identifiable {
    let id: String
    let name: String
    let type: MealType
    let ingredients: [String]
    let instructions: String
    let nutritionInfo: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case ingredients
        case instructions
        case nutritionInfo = "nutrition_info"
    }
}

enum MealType: String, Codable, CaseIterable {
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
