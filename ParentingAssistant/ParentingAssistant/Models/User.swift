import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    var children: [Child]?
    var preferences: UserPreferences
    let createdAt: Date
    var lastLoginAt: Date
    
    struct Child: Codable, Identifiable {
        let id: String
        var name: String
        var age: Int
        var favoriteThemes: [StoryTheme]
    }
    
    struct UserPreferences: Codable {
        var dietaryRestrictions: [String]
        var mealPreferences: MealPreferences
        var notificationsEnabled: Bool
        var reminderTime: Date?
    }
    
    struct MealPreferences: Codable {
        var cuisineTypes: [String]
        var difficultyLevel: CookingDifficulty
        var servingSize: Int
        var weeklyPlanEnabled: Bool
    }
}

// MARK: - Story Theme
enum StoryTheme: String, Codable, CaseIterable {
    case adventure
    case fantasy
    case animals
    case space
    case nature
    case superheroes
    case fairytales
    case science
    
    var displayName: String {
        switch self {
        case .adventure: return "Adventure"
        case .fantasy: return "Fantasy"
        case .animals: return "Animals"
        case .space: return "Space"
        case .nature: return "Nature"
        case .superheroes: return "Superheroes"
        case .fairytales: return "Fairy Tales"
        case .science: return "Science"
        }
    }
    
    var emoji: String {
        switch self {
        case .adventure: return "🗺️"
        case .fantasy: return "🦄"
        case .animals: return "🐾"
        case .space: return "🚀"
        case .nature: return "🌲"
        case .superheroes: return "🦸‍♂️"
        case .fairytales: return "🏰"
        case .science: return "��"
        }
    }
} 