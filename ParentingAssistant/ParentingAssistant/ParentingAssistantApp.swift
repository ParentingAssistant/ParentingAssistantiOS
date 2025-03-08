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
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
    }
}
