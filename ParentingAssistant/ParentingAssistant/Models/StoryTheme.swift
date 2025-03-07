import Foundation

enum StoryTheme: String, Codable, CaseIterable {
    case fairyTale = "Fairy Tale"
    case adventure = "Adventure"
    case fantasy = "Fantasy"
    case space = "Space Journey"
    case animals = "Animal Friends"
    case nature = "Nature"
    case superheroes = "Superheroes"
    case science = "Science"
    
    var icon: String {
        switch self {
        case .fairyTale: return "wand.and.stars"
        case .adventure: return "map.fill"
        case .fantasy: return "sparkles"
        case .space: return "moon.stars.fill"
        case .animals: return "pawprint.fill"
        case .nature: return "leaf.fill"
        case .superheroes: return "bolt.fill"
        case .science: return "atom"
        }
    }
    
    var description: String {
        switch self {
        case .fairyTale: return "Magical stories with princes, princesses, and enchanted creatures"
        case .adventure: return "Exciting journeys and thrilling discoveries"
        case .fantasy: return "Mystical worlds with dragons and magical powers"
        case .space: return "Cosmic adventures among the stars"
        case .animals: return "Fun tales with friendly animal characters"
        case .nature: return "Stories about the wonders of the natural world"
        case .superheroes: return "Epic tales of heroes with amazing powers"
        case .science: return "Fun and educational stories about science"
        }
    }
    
    var emoji: String {
        switch self {
        case .fairyTale: return "🏰"
        case .adventure: return "🗺️"
        case .fantasy: return "🦄"
        case .space: return "🚀"
        case .animals: return "🐾"
        case .nature: return "🌲"
        case .superheroes: return "🦸‍♂️"
        case .science: return "��"
        }
    }
} 