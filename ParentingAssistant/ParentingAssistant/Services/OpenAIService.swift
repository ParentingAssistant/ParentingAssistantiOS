import Foundation

enum OpenAIError: Error {
    case invalidResponse
    case apiError(String)
    case decodingError
}

class OpenAIService {
    static let shared = OpenAIService()
    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String {
        // In production, this should be stored in KeyChain or environment variables
        // For now, we'll use a property list
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["OpenAIKey"] as? String else {
            fatalError("OpenAI API key not found in Config.plist")
        }
        return key
    }
    
    private init() {}
    
    func generateStory(
        prompt: String,
        ageGroup: String,
        theme: String,
        completion: @escaping (Result<String, OpenAIError>) -> Void
    ) {
        let storyPrompt = """
        Create a bedtime story for a \(ageGroup) child with the theme: \(theme).
        Story requirements:
        - Age-appropriate language and content
        - Engaging characters and plot
        - Educational or moral message
        - Length: about 5-7 paragraphs
        - End with a gentle, sleep-inducing conclusion
        
        Additional context: \(prompt)
        """
        
        let parameters: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                ["role": "system", "content": "You are a skilled children's storyteller who creates engaging, age-appropriate bedtime stories."],
                ["role": "user", "content": storyPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(.apiError("Failed to encode request")))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.apiError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let content = result.choices.first?.message.content {
                    completion(.success(content))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
} 