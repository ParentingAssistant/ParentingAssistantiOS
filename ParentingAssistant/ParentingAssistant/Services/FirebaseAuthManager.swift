import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func resetPassword(forEmail email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Firestore Methods
    
    func createUserDocument(userId: String, userData: [String: Any]) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).setData(userData)
    }
    
    func fetchUserDocument(userId: String) async throws -> [String: Any]? {
        let db = Firestore.firestore()
        let document = try await db.collection("users").document(userId).getDocument()
        return document.exists ? document.data() : nil
    }
    
    func updateUserDocument(userId: String, userData: [String: Any]) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).updateData(userData)
    }
} 