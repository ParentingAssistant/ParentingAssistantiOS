import Foundation

enum CookingDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Simple recipes with basic ingredients and steps"
        case .medium: return "Moderate complexity with some advanced techniques"
        case .hard: return "Complex recipes requiring advanced cooking skills"
        }
    }
} 