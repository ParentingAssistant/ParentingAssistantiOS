import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                HomeView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    RootView()
} 