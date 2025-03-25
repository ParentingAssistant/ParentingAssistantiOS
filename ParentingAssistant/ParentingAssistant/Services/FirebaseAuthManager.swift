import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore

enum FirebaseError: Error {
    case authError(String)
    case firestoreError(String)
    case googleSignInError(String)
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
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        print("Attempting to sign in with Google")
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(FirebaseError.googleSignInError("No client ID found")))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            if let error = error {
                print("Google Sign-In failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google Sign-In failed: Missing user or token")
                completion(.failure(FirebaseError.googleSignInError("Missing user or token")))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in with Google failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let authResult = authResult else {
                    print("Firebase sign in with Google failed: No result")
                    completion(.failure(FirebaseError.authError("No result")))
                    return
                }
                
                // Create or update user document
                if let displayName = user.profile?.name, let email = user.profile?.email {
                    let userData: [String: Any] = [
                        "id": authResult.user.uid,
                        "fullName": displayName,
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
                    
                    self?.createOrUpdateUserDocument(userId: authResult.user.uid, userData: userData)
                }
                
                print("Successfully signed in with Google: \(authResult.user.uid)")
                completion(.success(authResult))
            }
        }
    }
    
    private func createOrUpdateUserDocument(userId: String, userData: [String: Any]) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                // Update last login time for existing user
                db.collection("users").document(userId).updateData([
                    "lastLoginAt": Timestamp(date: Date())
                ])
            } else {
                // Create new user document
                db.collection("users").document(userId).setData(userData)
            }
        }
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