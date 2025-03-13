import Foundation
import FirebaseFirestore

class PromptService: ObservableObject {
    static let shared = PromptService()
    private let db = Firestore.firestore()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private init() {}
    
    // MARK: - Prompt Management
    
    func createPrompt(category: Prompt.PromptCategory, content: String) async throws -> Prompt {
        let prompt = Prompt(
            category: category,
            content: content,
            createdAt: Date(),
            updatedAt: Date(),
            responses: []
        )
        
        let docRef = try db.collection("prompts").addDocument(from: prompt)
        var savedPrompt = prompt
        savedPrompt.id = docRef.documentID
        return savedPrompt
    }
    
    func getPrompt(id: String) async throws -> Prompt {
        let docRef = db.collection("prompts").document(id)
        let document = try await docRef.getDocument()
        return try document.data(as: Prompt.self)
    }
    
    func getPromptsByCategory(_ category: Prompt.PromptCategory) async throws -> [Prompt] {
        let snapshot = try await db.collection("prompts")
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Prompt.self) }
    }
    
    // MARK: - Response Management
    
    func addResponse(to promptId: String, content: String, metadata: [String: String]? = nil) async throws {
        let response = PromptResponse(promptId: promptId, content: content, metadata: metadata)
        
        try await db.collection("prompts").document(promptId).updateData([
            "responses": FieldValue.arrayUnion([response.dictionary]),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    func getResponses(for promptId: String) async throws -> [PromptResponse] {
        let prompt = try await getPrompt(id: promptId)
        return prompt.responses
    }
    
    // MARK: - Caching
    
    func cachePrompt(_ prompt: Prompt) async throws {
        let cacheKey = "prompt_\(prompt.id ?? UUID().uuidString)"
        let encoder = JSONEncoder()
        let data = try encoder.encode(prompt)
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
    
    func getCachedPrompt(id: String) -> Prompt? {
        let cacheKey = "prompt_\(id)"
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(Prompt.self, from: data)
    }
    
    // MARK: - Template Prompts
    
    static let mealPlanningPrompt = """
    Create a healthy meal plan for a family with the following requirements:
    - Include breakfast, lunch, dinner, and snacks
    - Consider nutritional balance
    - Include preparation time estimates
    - List required ingredients
    - Provide simple cooking instructions
    """
    
    static let bedtimeStoryPrompt = """
    Create a short, engaging bedtime story suitable for children aged 5-10 years old.
    The story should:
    - Have a clear moral or lesson
    - Include positive messages
    - Be age-appropriate
    - Be engaging and easy to follow
    - Be suitable for reading aloud
    """
    
    static let activitySuggestionPrompt = """
    Suggest age-appropriate activities for children that:
    - Promote learning and development
    - Are engaging and fun
    - Can be done indoors or outdoors
    - Require minimal special equipment
    - Include safety considerations
    """
    
    static let emotionalSupportPrompt = """
    Provide guidance for handling a child's emotional situation:
    - Identify the emotional state
    - Suggest appropriate responses
    - Include calming techniques
    - Offer age-appropriate explanations
    - Provide follow-up activities
    """
    
    static let healthAdvicePrompt = """
    Provide health advice for a child's situation:
    - Identify potential concerns
    - Suggest appropriate actions
    - Include preventive measures
    - List warning signs to watch for
    - Recommend when to seek professional help
    """
    
    static let routinePlanningPrompt = """
    Create a daily routine that:
    - Balances activities and rest
    - Includes time for meals
    - Incorporates learning activities
    - Allows for physical activity
    - Maintains consistent sleep schedule
    """
} 
