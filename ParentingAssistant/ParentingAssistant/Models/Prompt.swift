import Foundation
import FirebaseFirestore

struct Prompt: Codable, Identifiable {
    var id: String?
    let category: PromptCategory
    let content: String
    let createdAt: Date
    let updatedAt: Date
    var responses: [PromptResponse]
    
    enum PromptCategory: String, Codable {
        case mealPlanning = "meal_planning"
        case bedtimeStory = "bedtime_story"
        case activitySuggestion = "activity_suggestion"
        case emotionalSupport = "emotional_support"
        case healthAdvice = "health_advice"
        case routinePlanning = "routine_planning"
        case other = "other"
    }
    
    var dictionary: [String: Any] {
        return [
            "category": category.rawValue,
            "content": content,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "responses": responses.map { $0.dictionary }
        ]
    }
}

struct PromptResponse: Codable, Identifiable {
    var id: String?
    let promptId: String
    let content: String
    let createdAt: Date
    let metadata: [String: String]?
    
    init(promptId: String, content: String, metadata: [String: String]? = nil) {
        self.promptId = promptId
        self.content = content
        self.createdAt = Date()
        self.metadata = metadata
    }
    
    var dictionary: [String: Any] {
        return [
            "promptId": promptId,
            "content": content,
            "createdAt": createdAt,
            "metadata": metadata ?? [:]
        ]
    }
} 
