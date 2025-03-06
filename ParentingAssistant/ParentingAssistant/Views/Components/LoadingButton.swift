import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            ZStack {
                // Button Text
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                
                // Loading Indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.1)
                }
            }
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
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingButton(title: "Sign In", isLoading: false) {
            // Action
        }
        LoadingButton(title: "Loading...", isLoading: true) {
            // Action
        }
    }
    .padding()
} 