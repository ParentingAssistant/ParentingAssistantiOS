import Foundation
import Security
import FirebaseCrashlytics
import FirebaseAnalytics

enum ConfigurationError: Error {
    case missingKey
    case invalidKey
    case keychainError
    
    var localizedDescription: String {
        switch self {
        case .missingKey:
            return "API key not found in configuration"
        case .invalidKey:
            return "API key is empty or invalid"
        case .keychainError:
            return "Failed to access or store key in Keychain"
        }
    }
    
    var analyticsEventName: String {
        switch self {
        case .missingKey: return "config_error_missing_key"
        case .invalidKey: return "config_error_invalid_key"
        case .keychainError: return "config_error_keychain"
        }
    }
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {
        print("🔑 Initializing ConfigurationManager...")
        // Run test key retrieval on initialization
        testKeyRetrieval()
    }
    
    // MARK: - API Keys
    
    private func getConfigFilePath() -> String? {
        let fileManager = FileManager.default
        
        // Try to find the config file in the current directory
        let currentPath = fileManager.currentDirectoryPath
        let configPath = (currentPath as NSString).appendingPathComponent("Config.xcconfig")
        print("   Looking for config file at: \(configPath)")
        
        if fileManager.fileExists(atPath: configPath) {
            return configPath
        }
        
        // If not found, try the parent directory
        let parentPath = (currentPath as NSString).deletingLastPathComponent
        let parentConfigPath = (parentPath as NSString).appendingPathComponent("Config.xcconfig")
        print("   Looking for config file at: \(parentConfigPath)")
        
        if fileManager.fileExists(atPath: parentConfigPath) {
            return parentConfigPath
        }
        
        // Try to find in the bundle
        if let bundlePath = Bundle.main.path(forResource: "Config", ofType: "xcconfig") {
            print("   Found config file in bundle at: \(bundlePath)")
            return bundlePath
        }
        
        return nil
    }
    
    private func logError(_ error: Error, context: String) {
        print("❌ Error in \(context): \(error.localizedDescription)")
        
        // Log to Crashlytics
        Crashlytics.crashlytics().record(error: error, userInfo: ["context": context])
        
        // Log to Analytics
        if let configError = error as? ConfigurationError {
            Analytics.logEvent(configError.analyticsEventName, parameters: [
                "context": context,
                "error_description": error.localizedDescription
            ])
        } else {
            Analytics.logEvent("config_error_unknown", parameters: [
                "context": context,
                "error_description": error.localizedDescription
            ])
        }
    }
    
    private func logSuccess(_ message: String, context: String) {
        print("✅ \(message)")
        Analytics.logEvent("config_success", parameters: [
            "context": context,
            "message": message
        ])
    }
    
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
            
            // For development only, try to read from .xcconfig file
            #if DEBUG
            print("   Checking .xcconfig file (DEBUG only)...")
            if let configPath = getConfigFilePath() {
                print("   ✅ Found config file")
                do {
                    let contents = try String(contentsOfFile: configPath, encoding: .utf8)
                    // Print a limited portion of the contents for security
                    print("   Config file found with \(contents.count) characters")
                    
                    let lines = contents.components(separatedBy: .newlines)
                    for line in lines {
                        if line.hasPrefix("OPENAI_API_KEY") {
                            let components = line.components(separatedBy: "=")
                            if components.count >= 2 {
                                // Join all components after the first one in case the key itself contains = characters
                                let key = components[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
                                print("   ✅ Found key in .xcconfig file")
                                // Store in Keychain for future use
                                try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
                                return key
                            }
                        }
                    }
                } catch {
                    print("   ❌ Failed to read config file: \(error)")
                }
            }
            #endif
            
            // Try environment variables (for development)
            #if DEBUG
            print("   Checking environment variables (DEBUG only)...")
            if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                print("   ✅ Found key in environment variables")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
                return key
            }
            #endif
            
            // Try Info.plist as last resort
            print("   Checking Info.plist...")
            if let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String,
               !key.isEmpty,
               !key.hasPrefix("$(") {
                print("   ✅ Found key in Info.plist")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
                return key
            }
            
            print("   ❌ Key not found in any location")
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
            
            // Try to read from .xcconfig file
            print("   Checking .xcconfig file...")
            if let configPath = getConfigFilePath() {
                print("   ✅ Found config file")
                do {
                    let contents = try String(contentsOfFile: configPath, encoding: .utf8)
                    // Print a limited portion of the contents for security
                    print("   Config file found with \(contents.count) characters")
                    
                    let lines = contents.components(separatedBy: .newlines)
                    for line in lines {
                        // Check for either FIREBASE_API_KEY or FIREBASE_KEY
                        if line.hasPrefix("FIREBASE_KEY") || line.hasPrefix("FIREBASE_API_KEY") {
                            let components = line.components(separatedBy: "=")
                            if components.count >= 2 {
                                // Join all components after the first one in case the key itself contains = characters
                                let key = components[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
                                print("   ✅ Found key in .xcconfig file")
                                // Store in Keychain for future use
                                try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
                                return key
                            }
                        }
                    }
                } catch {
                    print("   ❌ Failed to read config file: \(error)")
                }
            }
            print("   ❌ Key not found in .xcconfig file")
            
            // If not found, try environment variables
            print("   Checking environment variables...")
            // Check both environment variable names
            if let key = ProcessInfo.processInfo.environment["FIREBASE_KEY"] ?? ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] {
                print("   ✅ Found key in environment variables")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
                return key
            }
            
            // Try Info.plist as last resort
            print("   Checking Info.plist...")
            if let key = Bundle.main.infoDictionary?["FIREBASE_API_KEY"] as? String,
               !key.isEmpty,
               !key.hasPrefix("$(") {
                print("   ✅ Found key in Info.plist")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
                return key
            }
            
            print("   ❌ Key not found in any location")
            throw ConfigurationError.missingKey
        }
    }
    
    // MARK: - Keychain Operations
    
    private func storeKeyInKeychain(key: String, keyIdentifier: String) throws {
        print("   💾 Attempting to store key in Keychain...")
        
        // First try to delete any existing key
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Then store the new key
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
        do {
            let openAIKey = try self.openAIKey
            guard !openAIKey.isEmpty else {
                let error = ConfigurationError.invalidKey
                logError(error, context: "openai_key_validation")
                throw error
            }
            logSuccess("OpenAI key is valid", context: "openai_key_validation")
        } catch {
            logError(error, context: "openai_key_validation")
            throw error
        }
        
        // Validate Firebase Key
        print("   Checking Firebase key...")
        do {
            let firebaseKey = try self.firebaseKey
            guard !firebaseKey.isEmpty else {
                let error = ConfigurationError.invalidKey
                logError(error, context: "firebase_key_validation")
                throw error
            }
            logSuccess("Firebase key is valid", context: "firebase_key_validation")
        } catch {
            logError(error, context: "firebase_key_validation")
            throw error
        }
    }
    
    // MARK: - Testing
    
    func printConfigFileContents() {
        print("\n📄 Printing Config.xcconfig contents...")
        
        if let configPath = getConfigFilePath() {
            print("✅ Found config file")
            do {
                let contents = try String(contentsOfFile: configPath, encoding: .utf8)
                print("\nFile contents:")
                print("-------------------")
                print(contents)
                print("-------------------")
            } catch {
                print("❌ Failed to read config file: \(error)")
            }
        } else {
            print("❌ Config file not found")
        }
    }
    
    func testKeyRetrieval() {
        print("\n🔍 Testing API Key Retrieval...")
        
        // Print current directory for debugging
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        print("Current directory: \(currentPath)")
        
        // List files in current directory
        do {
            let files = try fileManager.contentsOfDirectory(atPath: currentPath)
            print("Files in directory:")
            files.forEach { print("   - \($0)") }
        } catch {
            logError(error, context: "directory_listing")
        }
        
        // Print config file contents
        printConfigFileContents()
        
        // Test OpenAI key retrieval
        do {
            let key = try openAIKey
            logSuccess("Successfully retrieved OpenAI key", context: "key_retrieval_test")
        } catch {
            logError(error, context: "openai_key_retrieval_test")
        }
        
        // Test Firebase key retrieval
        do {
            let key = try firebaseKey
            logSuccess("Successfully retrieved Firebase key", context: "key_retrieval_test")
        } catch {
            logError(error, context: "firebase_key_retrieval_test")
        }
    }
} 
