import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var shouldShowLogin = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                // First Page
                VStack(spacing: 24) {
                    Image("family_ai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 40)
                        .transition(.opacity)
                    
                    Text("Simplify Parenting with AI")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    Text("Reduce your mental load – let AI help you manage daily parenting tasks.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .tag(0)
                
                // Second Page
                VStack(spacing: 24) {
                    Image("meal_bedtime")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 40)
                        .transition(.opacity)
                    
                    Text("Smart Meal Planning & Bedtime Stories")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    Text("From meal plans to personalized stories, get customized help every day.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .tag(1)
                
                // Third Page
                VStack(spacing: 24) {
                    Image("get_started")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 40)
                        .transition(.opacity)
                    
                    Text("Ready to Transform Your Parenting Journey?")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    Text("Join thousands of parents making daily tasks easier with AI assistance.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    
                    Button(action: {
                        withAnimation {
                            shouldShowLogin = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .navigationDestination(isPresented: $shouldShowLogin) {
                LoginView()
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

// Preview provider for SwiftUI canvas
#Preview {
    OnboardingView()
} 
