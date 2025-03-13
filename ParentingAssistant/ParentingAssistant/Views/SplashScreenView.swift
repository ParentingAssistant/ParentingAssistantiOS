import SwiftUI

struct SplashScreenView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var isLoading = true
    @State private var showHome = false
    @State private var currentFact: String = ""
    
    private let funFacts = [
        "Did you know? Babies can recognize their mother's voice from birth!",
        "A child's brain develops the fastest during the first 3 years of life.",
        "Reading to your child for just 20 minutes a day can significantly improve their language skills.",
        "Children learn best through play and exploration.",
        "The average 4-year-old asks about 400 questions per day!",
        "Babies can distinguish between all sounds of all languages until about 6 months old.",
        "Children who eat dinner with their families regularly perform better in school.",
        "Playing with blocks can help develop mathematical thinking in young children.",
        "Babies can start learning sign language as early as 6 months old.",
        "Children who get enough sleep are better at problem-solving and memory tasks."
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Logo
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.accentColor)
                
                // App Name
                Text("Parenting Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Fun Fact
                Text(currentFact)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Loading Indicator with fixed height
                ZStack {
                    Color.clear
                        .frame(height: 40) // Fixed height for the loading area
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            }
        }
        .onAppear {
            selectRandomFact()
            checkAuthentication()
        }
        .fullScreenCover(isPresented: $showHome) {
            HomeView()
                .transition(.opacity)
                .animation(.easeIn(duration: 0.3), value: showHome)
        }
    }
    
    private func selectRandomFact() {
        currentFact = funFacts.randomElement() ?? funFacts[0]
    }
    
    private func checkAuthentication() {
        // Run configuration checks in parallel
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ConfigurationManager.shared.testKeyRetrieval()
            group.leave()
        }
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try ConfigurationManager.shared.validateKeys()
            } catch {
                print("Configuration error: \(error.localizedDescription)")
            }
            group.leave()
        }
        
        // Wait for user data to be loaded
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // The AuthenticationService will automatically load user data
            // through its auth state listener
            if authService.currentUser != nil {
                print("User data loaded successfully")
            } else {
                print("No user data available")
            }
            group.leave()
        }
        
        // Navigate to Home after all checks are complete
        group.notify(queue: .main) {
            isLoading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showHome = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
} 