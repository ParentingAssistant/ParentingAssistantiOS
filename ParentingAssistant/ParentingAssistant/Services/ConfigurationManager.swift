import Foundation
import Security

enum ConfigurationError: Error {
    case missingKey
    case invalidKey
    case keychainError
    case configFileNotFound
    
    var localizedDescription: String {
        switch self {
        case .missingKey:
            return "API key not found in configuration"
        case .invalidKey:
            return "API key is empty or invalid"
        case .keychainError:
            return "Failed to access or store key in Keychain"
        case .configFileNotFound:
            return "Config.plist file not found in bundle"
        }
    }
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    // MARK: - API Keys
    
    var openAIKey: String {
        get throws {
            print("🔑 Attempting to retrieve OpenAI API key...")
            
            // First try to get from Keychain
            print("   Checking Keychain...")
            if let key = try? getKeyFromKeychain(key: "openai_api_key") {
                print("   ✅ Found key in Keychain")
                return key
            }
            print("   ❌ Key not found in Keychain")
            
            // If not in Keychain, try to get from Config.plist
            print("   Checking Config.plist...")
            guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let config = NSDictionary(contentsOfFile: configPath) as? [String: Any] else {
                print("   ❌ Config.plist not found or invalid")
                throw ConfigurationError.configFileNotFound
            }
            
            if let key = config["OpenAIKey"] as? String {
                print("   ✅ Found key in Config.plist")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
                return key
            }
            
            print("   ❌ Key not found in Config.plist")
            print("   Available keys in Config.plist: \(config.keys.joined(separator: ", "))")
            throw ConfigurationError.missingKey
        }
    }
    
    var firebaseKey: String {
        get throws {
            print("🔑 Attempting to retrieve Firebase API key...")
            
            // First try to get from Keychain
            print("   Checking Keychain...")
            if let key = try? getKeyFromKeychain(key: "firebase_api_key") {
                print("   ✅ Found key in Keychain")
                return key
            }
            print("   ❌ Key not found in Keychain")
            
            // If not in Keychain, try to get from Config.plist
            print("   Checking Config.plist...")
            guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let config = NSDictionary(contentsOfFile: configPath) as? [String: Any] else {
                print("   ❌ Config.plist not found or invalid")
                throw ConfigurationError.configFileNotFound
            }
            
            if let key = config["FIREBASE_API_KEY"] as? String {
                print("   ✅ Found key in Config.plist")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
                return key
            }
            
            print("   ❌ Key not found in Config.plist")
            print("   Available keys in Config.plist: \(config.keys.joined(separator: ", "))")
            throw ConfigurationError.missingKey
        }
    }
    
    // MARK: - Keychain Operations
    
    private func storeKeyInKeychain(key: String, keyIdentifier: String) throws {
        print("   💾 Attempting to store key in Keychain...")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("   ✅ Successfully stored key in Keychain")
        } else {
            print("   ❌ Failed to store key in Keychain. Status: \(status)")
            throw ConfigurationError.keychainError
        }
    }
    
    private func getKeyFromKeychain(key: String) throws -> String? {
        print("   🔍 Attempting to retrieve key from Keychain...")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data,
               let key = String(data: data, encoding: .utf8) {
                print("   ✅ Successfully retrieved key from Keychain")
                return key
            }
        }
        
        print("   ❌ Failed to retrieve key from Keychain. Status: \(status)")
        return nil
    }
    
    // MARK: - Validation
    
    func validateKeys() throws {
        print("🔍 Validating API keys...")
        
        // Validate OpenAI Key
        print("   Checking OpenAI key...")
        let openAIKey = try self.openAIKey
        guard !openAIKey.isEmpty else {
            print("   ❌ OpenAI key is empty")
            throw ConfigurationError.invalidKey
        }
        print("   ✅ OpenAI key is valid")
        
        // Validate Firebase Key
        print("   Checking Firebase key...")
        let firebaseKey = try self.firebaseKey
        guard !firebaseKey.isEmpty else {
            print("   ❌ Firebase key is empty")
            throw ConfigurationError.invalidKey
        }
        print("   ✅ Firebase key is valid")
    }
} 
