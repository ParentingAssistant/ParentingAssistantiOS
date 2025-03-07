import Foundation
import FirebaseCore

class FirebaseConfig {
    static func configure() {
        print("Configuring Firebase...")
        FirebaseApp.configure()
        print("Firebase configured successfully")
        
        // Print Firebase configuration details
        if let options = FirebaseApp.app()?.options {
            print("Firebase Project ID: \(options.projectID ?? "nil")")
            print("Firebase Bundle ID: \(options.bundleID)")
            print("Firebase Database URL: \(options.databaseURL ?? "nil")")
            print("Firebase Storage Bucket: \(options.storageBucket ?? "nil")")
        }
    }
} 
