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
    @Published var error: String?

    private let authManager = FirebaseAuthManager.shared
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private init() {
        print("AuthenticationService initialized")
        setupAuthStateListener()
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    private func setupAuthStateListener() {
        print("Setting up auth state listener...")
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("Auth state changed - User: \(user?.uid ?? "nil")")
            self?.isAuthenticated = user != nil
            if let user = user {
                print("User authenticated, fetching user data...")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.fetchUserData(userId: user.uid)
                }
            } else {
                print("User signed out")
                self?.currentUser = nil
            }
        }
    }

    func login(email: String, password: String) {
        print("Login attempt for email: \(email)")
        isLoading = true
        
        authManager.signIn(withEmail: email, password: password) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let authResult):
                print("Login successful, fetching user data...")
                self.fetchUserData(userId: authResult.user.uid)
            case .failure(let error):
                print("Login failed with error: \(error.localizedDescription)")
                self.error = error.localizedDescription
            }
        }
    }

    func signUp(fullName: String, email: String, password: String) {
        print("Sign up attempt for email: \(email)")
        isLoading = true
        
        authManager.createUser(withEmail: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let authResult):
                print("User created successfully, creating user document...")
                
                let userData: [String: Any] = [
                    "id": authResult.user.uid,
                    "fullName": fullName,
                    "email": email,
                    "createdAt": Timestamp(date: Date()),
                    "lastLoginAt": Timestamp(date: Date()),
                    "dietaryRestrictions": [],
                    "cuisineTypes": [],
                    "cookingDifficulty": CookingDifficulty.easy.rawValue,
                    "servingSize": 4,
                    "weeklyPlanEnabled": false,
                    "notificationsEnabled": true
                ]
                
                self.authManager.createUserDocument(userId: authResult.user.uid, userData: userData) { [weak self] result in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    switch result {
                    case .success:
                        print("User document created successfully")
                        self.fetchUserData(userId: authResult.user.uid)
                    case .failure(let error):
                        print("Failed to create user document: \(error.localizedDescription)")
                        self.error = error.localizedDescription
                    }
                }
                
            case .failure(let error):
                self.isLoading = false
                print("Sign up failed with error: \(error.localizedDescription)")
                self.error = error.localizedDescription
            }
        }
    }

    func resetPassword(email: String) {
        print("Password reset attempt for email: \(email)")
        isLoading = true
        
        authManager.resetPassword(forEmail: email) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success:
                print("Password reset email sent successfully")
            case .failure(let error):
                print("Password reset failed with error: \(error.localizedDescription)")
                self.error = error.localizedDescription
            }
        }
    }

    func signOut() throws {
        print("Sign out attempt")
        isLoading = true
        defer { isLoading = false }

        do {
            try authManager.signOut()
            print("Sign out successful")
            currentUser = nil
        } catch {
            print("Sign out failed with error: \(error.localizedDescription)")
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Biometric Authentication

    func canUseBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "unknown error")")
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your account"
            )
            print("Biometric authentication \(success ? "successful" : "failed")")
            return success
        } catch {
            print("Biometric authentication error: \(error.localizedDescription)")
            return false
        }
    }

    private func fetchUserData(userId: String) {
        print("Fetching user data for ID: \(userId)")
        authManager.fetchUserDocument(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userData):
                if let userData = userData {
                    print("User data fetched successfully: \(userData)")
                    DispatchQueue.main.async {
                        self.currentUser = User(
                            id: userData["id"] as? String ?? "",
                            email: userData["email"] as? String ?? "",
                            fullName: userData["fullName"] as? String ?? "",
                            children: nil, // We'll handle children separately
                            preferences: User.UserPreferences(
                                dietaryRestrictions: userData["dietaryRestrictions"] as? [String] ?? [],
                                mealPreferences: User.MealPreferences(
                                    cuisineTypes: userData["cuisineTypes"] as? [String] ?? [],
                                    difficultyLevel: CookingDifficulty(rawValue: userData["cookingDifficulty"] as? String ?? "") ?? .easy,
                                    servingSize: userData["servingSize"] as? Int ?? 4,
                                    weeklyPlanEnabled: userData["weeklyPlanEnabled"] as? Bool ?? false
                                ),
                                notificationsEnabled: userData["notificationsEnabled"] as? Bool ?? true,
                                reminderTime: (userData["reminderTime"] as? Timestamp)?.dateValue()
                            ),
                            createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            lastLoginAt: (userData["lastLoginAt"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        print("Current user updated: \(self.currentUser?.fullName ?? "nil")")
                    }
                } else {
                    print("No user data found, attempting to recreate user document...")
                    self.recreateUserDocument(userId: userId)
                }
            case .failure(let error):
                print("Error fetching user data: \(error.localizedDescription)")
                self.error = error.localizedDescription
            }
        }
    }

    private func recreateUserDocument(userId: String) {
        print("Recreating user document for ID: \(userId)")
        guard let user = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        
        let userData: [String: Any] = [
            "id": userId,
            "fullName": user.displayName ?? "New User",
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
        
        authManager.createUserDocument(userId: userId, userData: userData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                print("User document recreated successfully")
                self.fetchUserData(userId: userId)
            case .failure(let error):
                print("Error recreating user document: \(error.localizedDescription)")
                self.error = error.localizedDescription
            }
        }
    }

    // MARK: - Profile Management
    
    func updateProfile(fullName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Updating profile for user: \(currentUser?.id ?? "unknown")")
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "AuthenticationService", code: -1, 
                              userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }
        
        let userData: [String: Any] = [
            "fullName": fullName,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        authManager.updateUserDocument(userId: userId, userData: userData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("Profile updated successfully")
                
                // Create new user instance with updated name
                if let currentUser = self.currentUser {
                    self.currentUser = User(
                        id: userId,
                        email: currentUser.email,
                        fullName: fullName,
                        children: currentUser.children,
                        preferences: currentUser.preferences,
                        createdAt: currentUser.createdAt,
                        lastLoginAt: currentUser.lastLoginAt
                    )
                }
                completion(.success(()))
                
            case .failure(let error):
                print("Failed to update profile: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

extension Notification.Name {
    static let AuthStateDidChange = Notification.Name("AuthStateDidChange")
}
