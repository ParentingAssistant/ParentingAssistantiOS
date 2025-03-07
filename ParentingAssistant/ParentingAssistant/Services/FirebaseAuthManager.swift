import Foundation
import FirebaseAuth
import FirebaseFirestore

enum FirebaseError: Error {
    case authError(String)
    case firestoreError(String)
}

class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    private init() {
        print("FirebaseAuthManager initialized")
    }
    
    // MARK: - Authentication Methods
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("Attempting to sign in with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                print("Sign in failed: No result")
                completion(.failure(FirebaseError.authError("No result")))
                return
            }
            
            print("Successfully signed in user: \(result.user.uid)")
            completion(.success(result))
        }
    }
    
    func createUser(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("Attempting to create user with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("User creation failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                print("User creation failed: No result")
                completion(.failure(FirebaseError.authError("No result")))
                return
            }
            
            print("Successfully created user: \(result.user.uid)")
            completion(.success(result))
        }
    }
    
    func resetPassword(forEmail email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Attempting to reset password for email: \(email)")
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Password reset failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("Password reset email sent successfully")
            completion(.success(()))
        }
    }
    
    func signOut() throws {
        print("Attempting to sign out")
        try Auth.auth().signOut()
        print("Successfully signed out")
    }
    
    // MARK: - Firestore Methods
    
    func createUserDocument(userId: String, userData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        print("Creating user document for ID: \(userId)")
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Failed to create user document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("Successfully created user document")
            completion(.success(()))
        }
    }
    
    func fetchUserDocument(userId: String, completion: @escaping (Result<[String: Any]?, Error>) -> Void) {
        print("Fetching user document for ID: \(userId)")
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Failed to fetch user document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                print("Successfully fetched user document")
                completion(.success(document.data()))
            } else {
                print("No user document found")
                completion(.success(nil))
            }
        }
    }
    
    func updateUserDocument(userId: String, userData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        print("Updating user document for ID: \(userId)")
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(userData) { error in
            if let error = error {
                print("Failed to update user document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("Successfully updated user document")
            completion(.success(()))
        }
    }
} 