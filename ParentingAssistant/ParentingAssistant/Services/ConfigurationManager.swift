import Foundation
import Security

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
        
        // Get the project directory (where your source code is)
        let projectDirectory = "/Users/ahmedm/Developer/ParentingAssistant/ParentingAssistant"
        print("   Project directory: \(projectDirectory)")
        
        // Try to find the config file in the project directory
        let configPath = (projectDirectory as NSString).appendingPathComponent("Config.xcconfig")
        print("   Looking for config file at: \(configPath)")
        
        if fileManager.fileExists(atPath: configPath) {
            return configPath
        }
        
        // If not found, try the parent directory
        let parentPath = (projectDirectory as NSString).deletingLastPathComponent
        let parentConfigPath = (parentPath as NSString).appendingPathComponent("Config.xcconfig")
        print("   Looking for config file at: \(parentConfigPath)")
        
        if fileManager.fileExists(atPath: parentConfigPath) {
            return parentConfigPath
        }
        
        return nil
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
            
            // Try to read from .xcconfig file
            print("   Checking .xcconfig file...")
            if let configPath = getConfigFilePath() {
                print("   ✅ Found config file")
                do {
                    let contents = try String(contentsOfFile: configPath, encoding: .utf8)
                    print("\n   Config file contents:")
                    print("   -------------------")
                    print(contents)
                    print("   -------------------")
                    
                    let lines = contents.components(separatedBy: .newlines)
                    for line in lines {
                        if line.hasPrefix("OPENAI_API_KEY") {
                            let components = line.components(separatedBy: "=")
                            if components.count == 2 {
                                let key = components[1].trimmingCharacters(in: .whitespaces)
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
            print("   ❌ Key not found in .xcconfig file")
            
            // If not found, try environment variables
            print("   Checking environment variables...")
            if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                print("   ✅ Found key in environment variables")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
                return key
            }
            
            // Try Info.plist as last resort
            print("   Checking Info.plist...")
            if let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String {
                print("   ✅ Found key in Info.plist")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "openai_api_key")
                return key
            }
            
            print("   ❌ Key not found in any location")
            print("   Available Info.plist keys: \(Bundle.main.infoDictionary?.keys.joined(separator: ", ") ?? "none")")
            print("   Environment variables: \(ProcessInfo.processInfo.environment.keys.joined(separator: ", "))")
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
                    print("\n   Config file contents:")
                    print("   -------------------")
                    print(contents)
                    print("   -------------------")
                    
                    let lines = contents.components(separatedBy: .newlines)
                    for line in lines {
                        if line.hasPrefix("FIREBASE_API_KEY") {
                            let components = line.components(separatedBy: "=")
                            if components.count == 2 {
                                let key = components[1].trimmingCharacters(in: .whitespaces)
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
            if let key = ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] {
                print("   ✅ Found key in environment variables")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
                return key
            }
            
            // Try Info.plist as last resort
            print("   Checking Info.plist...")
            if let key = Bundle.main.infoDictionary?["FIREBASE_API_KEY"] as? String {
                print("   ✅ Found key in Info.plist")
                // Store in Keychain for future use
                try? storeKeyInKeychain(key: key, keyIdentifier: "firebase_api_key")
                return key
            }
            
            print("   ❌ Key not found in any location")
            print("   Available Info.plist keys: \(Bundle.main.infoDictionary?.keys.joined(separator: ", ") ?? "none")")
            print("   Environment variables: \(ProcessInfo.processInfo.environment.keys.joined(separator: ", "))")
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
            print("Failed to list directory contents: \(error)")
        }
        
        // Print config file contents
        printConfigFileContents()
        
        // Test OpenAI key retrieval
        do {
            let key = try openAIKey
            print("\n✅ Successfully retrieved OpenAI key: \(key.prefix(8))...")
        } catch {
            print("\n❌ Failed to retrieve OpenAI key: \(error)")
        }
        
        // Test Firebase key retrieval
        do {
            let key = try firebaseKey
            print("\n✅ Successfully retrieved Firebase key: \(key.prefix(8))...")
        } catch {
            print("\n❌ Failed to retrieve Firebase key: \(error)")
        }
    }
} 
