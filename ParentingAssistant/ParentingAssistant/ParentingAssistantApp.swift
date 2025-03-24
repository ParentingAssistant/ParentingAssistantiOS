//
//  ParentingAssistantApp.swift
//  ParentingAssistant
//
//  Created by Ahmed Khaled Mohamed on 06.03.25.
//

import SwiftUI
import FirebaseCore

@main
struct ParentingAssistantApp: App {
    @StateObject private var authService = AuthenticationService.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light)
                .environmentObject(authService)
        }
    }
}
