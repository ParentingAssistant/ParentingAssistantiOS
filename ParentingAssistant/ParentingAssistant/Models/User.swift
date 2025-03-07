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
