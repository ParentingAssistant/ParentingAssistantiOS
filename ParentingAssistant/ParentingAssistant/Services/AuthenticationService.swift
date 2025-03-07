import SwiftUI
import LocalAuthentication
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var currentUser: User?

    private let authManager = FirebaseAuthManager.shared
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task {
                print("Auth state changed - User: \(user?.uid ?? "nil")")
                if let userId = user?.uid {
                    print("User is authenticated with ID: \(userId)")
                    await self?.fetchUserData(userId: userId)
                    self?.isAuthenticated = true
                    print("isAuthenticated set to true")
                } else {
                    print("No user found, setting isAuthenticated to false")
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }

    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await authManager.signIn(withEmail: email, password: password)
            // No need to manually fetch user data or set isAuthenticated
            // The auth state listener will handle it
        } catch {
            throw error
        }
    }

    func signUp(fullName: String, email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await authManager.createUser(withEmail: email, password: password)

            let userData: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Date(),
                "lastLoginAt": Date(),
                "dietaryRestrictions": [],
                "cuisineTypes": [],
                "cookingDifficulty": CookingDifficulty.easy.rawValue,
                "servingSize": 4,
                "weeklyPlanEnabled": false,
                "notificationsEnabled": true
            ]

            try await authManager.createUserDocument(userId: result.user.uid, userData: userData)
            // No need to manually fetch user data or set isAuthenticated
            // The auth state listener will handle it
        } catch {
            throw error
        }
    }

    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }

        try await authManager.resetPassword(forEmail: email)
    }

    func signOut() throws {
        try authManager.signOut()
        // No need to manually set currentUser or isAuthenticated
        // The auth state listener will handle it
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

        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    private func fetchUserData(userId: String) async {
        do {
            print("Fetching user data for ID: \(userId)")
            guard let data = try await authManager.fetchUserDocument(userId: userId) else {
                print("No user data found in Firestore, attempting to recreate document")
                await recreateUserDocument(userId: userId)
                return
            }
            
            print("Successfully fetched user data: \(data)")
            
            // Create UserPreferences
            let mealPreferences = User.MealPreferences(
                cuisineTypes: data["cuisineTypes"] as? [String] ?? [],
                difficultyLevel: CookingDifficulty(rawValue: data["cookingDifficulty"] as? String ?? "") ?? .easy,
                servingSize: data["servingSize"] as? Int ?? 4,
                weeklyPlanEnabled: data["weeklyPlanEnabled"] as? Bool ?? false
            )
            
            let preferences = User.UserPreferences(
                dietaryRestrictions: data["dietaryRestrictions"] as? [String] ?? [],
                mealPreferences: mealPreferences,
                notificationsEnabled: data["notificationsEnabled"] as? Bool ?? true,
                reminderTime: (data["reminderTime"] as? Timestamp)?.dateValue()
            )
            
            self.currentUser = User(
                id: userId,
                email: data["email"] as? String ?? "",
                fullName: data["fullName"] as? String ?? "",
                children: nil, // We'll handle children separately
                preferences: preferences,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                lastLoginAt: (data["lastLoginAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            print("Updated currentUser with fetched data")
        } catch {
            print("Error fetching user data: \(error)")
        }
    }

    private func recreateUserDocument(userId: String) async {
        guard let user = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "fullName": user.displayName ?? "",
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "lastLoginAt": Timestamp(date: Date()),
            "dietaryRestrictions": [],
            "cuisineTypes": [],
            "cookingDifficulty": CookingDifficulty.easy.rawValue,
            "servingSize": 4,
            "weeklyPlanEnabled": false,
            "notificationsEnabled": true
        ]
        
        do {
            try await authManager.createUserDocument(userId: userId, userData: userData)
            await fetchUserData(userId: userId)
        } catch {
            print("Error recreating user document: \(error)")
        }
    }
}

extension Notification.Name {
    static let AuthStateDidChange = Notification.Name("AuthStateDidChange")
}
