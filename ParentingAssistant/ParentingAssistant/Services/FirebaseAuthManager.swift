import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    private init() {
        print("FirebaseAuthManager initialized")
    }
    
    // MARK: - Authentication Methods
    
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult {
        print("Attempting to sign in with email: \(email)")
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        print("Successfully signed in user: \(result.user.uid)")
        return result
    }
    
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        print("Attempting to create user with email: \(email)")
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        print("Successfully created user: \(result.user.uid)")
        return result
    }
    
    func resetPassword(forEmail email: String) async throws {
        print("Attempting to reset password for email: \(email)")
        try await Auth.auth().sendPasswordReset(withEmail: email)
        print("Password reset email sent successfully")
    }
    
    func signOut() throws {
        print("Attempting to sign out")
        try Auth.auth().signOut()
        print("Successfully signed out")
    }
    
    // MARK: - Firestore Methods
    
    func createUserDocument(userId: String, userData: [String: Any]) async throws {
        print("Creating user document for ID: \(userId)")
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).setData(userData)
        print("Successfully created user document")
    }
    
    func fetchUserDocument(userId: String) async throws -> [String: Any]? {
        print("Fetching user document for ID: \(userId)")
        let db = Firestore.firestore()
        let document = try await db.collection("users").document(userId).getDocument()
        if document.exists {
            print("Successfully fetched user document")
            return document.data()
        } else {
            print("No user document found")
            return nil
        }
    }
    
    func updateUserDocument(userId: String, userData: [String: Any]) async throws {
        print("Updating user document for ID: \(userId)")
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).updateData(userData)
        print("Successfully updated user document")
    }
} 