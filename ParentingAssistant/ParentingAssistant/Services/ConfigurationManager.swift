import Foundation
import Security

enum ConfigurationError: Error {
    case missingKey
    case invalidKey
    case keychainError
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    // MARK: - API Keys
    
    var openAIKey: String {
        get throws {
            // First try to get from Keychain
            if let key = try? getKeyFromKeychain(key: "openai_api_key") {
                return key
            }
            
            // If not in Keychain, try to get from Config
            guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
                throw ConfigurationError.missingKey
            }
            
            // Store in Keychain for future use
            try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
            
            return key
        }
    }
    
    var firebaseKey: String {
        get throws {
            // First try to get from Keychain
            if let key = try? getKeyFromKeychain(key: "firebase_api_key") {
                return key
            }
            
            // If not in Keychain, try to get from Config
            guard let key = Bundle.main.object(forInfoDictionaryKey: "FIREBASE_API_KEY") as? String else {
                throw ConfigurationError.missingKey
            }
            
            // Store in Keychain for future use
            try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
            
            return key
        }
    }
    
    // MARK: - Keychain Operations
    
    private func storeKeyInKeychain(key: String, keyIdentifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw ConfigurationError.keychainError
        }
    }
    
    private func getKeyFromKeychain(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    // MARK: - Validation
    
    func validateKeys() throws {
        // Validate OpenAI Key
        let openAIKey = try self.openAIKey
        guard !openAIKey.isEmpty else {
            throw ConfigurationError.invalidKey
        }
        
        // Validate Firebase Key
        let firebaseKey = try self.firebaseKey
        guard !firebaseKey.isEmpty else {
            throw ConfigurationError.invalidKey
        }
    }
} 
