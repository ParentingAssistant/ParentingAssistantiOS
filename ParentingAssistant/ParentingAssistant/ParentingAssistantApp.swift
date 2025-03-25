//
//  ParentingAssistantApp.swift
//  ParentingAssistant
//
//  Created by Ahmed Khaled Mohamed on 06.03.25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct ParentingAssistantApp: App {
    @StateObject private var authService = AuthenticationService.shared
    
    init() {
        FirebaseApp.configure()
        
        // Configure Google Sign-In
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light)
                .environmentObject(authService)
                .onOpenURL { url in
                    if GIDSignIn.sharedInstance.handle(url) {
                        print("Google Sign-In URL handled successfully")
                    } else {
                        print("Failed to handle Google Sign-In URL")
                    }
                }
        }
    }
}
