import SwiftUI
import LocalAuthentication

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var currentUser: User?
    
    static let shared = AuthenticationService()
    
    private init() {}
    
    struct User {
        let id: String
        let email: String
        let fullName: String
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implement actual login API call
        // For now, simulate successful login
        currentUser = User(id: UUID().uuidString, email: email, fullName: "Test User")
        isAuthenticated = true
    }
    
    func signUp(fullName: String, email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implement actual signup API call
        // For now, simulate successful signup
        currentUser = User(id: UUID().uuidString, email: email, fullName: fullName)
        isAuthenticated = true
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implement actual password reset API call
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Biometric Authentication
    
    func canUseBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        let reason = "Log in to your account"
        
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            throw error
        }
    }
    
    // MARK: - Password Strength
    
    enum PasswordStrength {
        case weak
        case medium
        case strong
        
        var color: Color {
            switch self {
            case .weak: return .red
            case .medium: return .orange
            case .strong: return .green
            }
        }
        
        var description: String {
            switch self {
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }
    }
    
    func checkPasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        // Length check
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        
        // Character variety checks
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumbers = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChars = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        if hasUppercase && hasLowercase { score += 1 }
        if hasNumbers { score += 1 }
        if hasSpecialChars { score += 1 }
        
        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
} 