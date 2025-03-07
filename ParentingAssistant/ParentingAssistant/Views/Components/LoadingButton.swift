import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    init(title: String, isLoading: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
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

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LoadingButton(
                title: "Sign In",
                isLoading: false,
                action: { print("Button tapped") }
            )
            LoadingButton(
                title: "Loading...",
                isLoading: true,
                action: { print("Button tapped") }
            )
        }
        .padding()
    }
} 