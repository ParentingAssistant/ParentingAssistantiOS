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
            var apiKey = try ConfigurationManager.shared.openAIKey
            print("   ✅ API key retrieved successfully")
            print("   🔑 API Key (first 10 chars): \(apiKey.prefix(10))...")
            
            if apiKey.isEmpty || apiKey.hasPrefix("your_") {
                print("   ⚠️ ERROR: API key appears to be a placeholder or empty")
                throw OpenAIError.invalidKey
            }
            
            // Prepare the request
            print("   📝 Preparing request...")
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Debug: Print the auth header (redacted)
            let authHeaderValue = "Bearer \(apiKey)"
            print("   🔒 Authorization Header: Bearer \(apiKey.prefix(5))...\(apiKey.suffix(5))")
            request.setValue(authHeaderValue, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Debug: Double-check the authorization header
            if let actualAuthHeader = request.value(forHTTPHeaderField: "Authorization") {
                let redactedHeader = "Bearer \(actualAuthHeader.dropFirst(7).prefix(5))...\(actualAuthHeader.dropFirst(7).suffix(5))"
                print("   ✅ Verified Authorization Header: \(redactedHeader)")
                
                if !actualAuthHeader.contains(apiKey) {
                    print("   ❌ ERROR: Authorization header doesn't contain the correct API key!")
                }
            }
            
            // Prepare the request body
            let requestBody: [String: Any] = [
                "model": "gpt-3.5-turbo",
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
                    
                    // Check for invalid key error
                    if let error = errorJson["error"] as? [String: Any],
                       let code = error["code"] as? String, code == "invalid_api_key",
                       let message = error["message"] as? String {
                        print("   🔍 Invalid API key error. Message: \(message)")
                    }
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
                metadata: ["model": "gpt-3.5-turbo"]
            )
            
            // Try to store the response, but don't fail if this doesn't work
            do {
                try await promptService.addResponse(to: prompt.id ?? UUID().uuidString, content: content)
                print("   ✅ Response stored successfully in Firebase")
            } catch {
                // Just log the error but continue with the response
                print("   ⚠️ Warning: Could not store response in Firebase: \(error.localizedDescription)")
                print("   ℹ️ This is okay for testing - continuing with response")
            }
            
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
    case invalidKey
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .noContent:
            return "No content in OpenAI API response"
        case .invalidKey:
            return "Invalid API key"
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