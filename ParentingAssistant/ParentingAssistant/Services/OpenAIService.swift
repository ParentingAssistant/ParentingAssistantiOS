import Foundation

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    private let promptService = PromptService.shared
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private init() {}
    
    func generateResponse(for prompt: Prompt) async throws -> PromptResponse {
        print("🤖 Starting OpenAI API request...")
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Get API key
            print("   🔑 Getting API key...")
            let apiKey = try ConfigurationManager.shared.openAIKey
            print("   ✅ API key retrieved successfully")
            
            // Prepare the request
            print("   📝 Preparing request...")
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Prepare the request body
            let requestBody: [String: Any] = [
                "model": "gpt-4",
                "messages": [
                    ["role": "system", "content": "You are a helpful parenting assistant."],
                    ["role": "user", "content": prompt.content]
                ],
                "temperature": 0.7,
                "max_tokens": 1000
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("   ✅ Request body prepared")
            
            // Make the request
            print("   🌐 Making API request...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("   ❌ Invalid response type")
                throw OpenAIError.invalidResponse
            }
            
            print("   📥 Received response with status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("   ❌ API Error: \(errorJson)")
                }
                throw OpenAIError.invalidResponse
            }
            
            // Parse the response
            print("   🔄 Parsing response...")
            let decoder = JSONDecoder()
            let result = try decoder.decode(OpenAIResponse.self, from: data)
            
            guard let content = result.choices.first?.message.content else {
                print("   ❌ No content in response")
                throw OpenAIError.noContent
            }
            
            print("   ✅ Successfully parsed response")
            
            // Create and store the response
            let promptResponse = PromptResponse(
                promptId: prompt.id ?? UUID().uuidString,
                content: content,
                metadata: ["model": "gpt-4"]
            )
            
            try await promptService.addResponse(to: prompt.id ?? UUID().uuidString, content: content)
            print("   ✅ Response stored successfully")
            
            return promptResponse
            
        } catch {
            print("   ❌ Error during OpenAI API call: \(error.localizedDescription)")
            self.error = error
            throw error
        }
    }
}

// MARK: - Supporting Types

enum OpenAIError: Error {
    case invalidResponse
    case noContent
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .noContent:
            return "No content in OpenAI API response"
        }
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
} 