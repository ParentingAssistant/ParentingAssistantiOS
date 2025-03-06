import SwiftUI

struct PasswordStrengthView: View {
    let password: String
    @StateObject private var authService = AuthenticationService.shared
    
    private var strength: AuthenticationService.PasswordStrength {
        authService.checkPasswordStrength(password)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Strength bars
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(getBarColor(for: index))
                        .frame(height: 4)
                }
            }
            
            // Strength description
            Text(strength.description)
                .font(.caption)
                .foregroundColor(strength.color)
        }
    }
    
    private func getBarColor(for index: Int) -> Color {
        switch (strength, index) {
        case (.weak, 0):
            return .red
        case (.medium, 0), (.medium, 1):
            return .orange
        case (.strong, _):
            return .green
        default:
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PasswordStrengthView(password: "weak")
        PasswordStrengthView(password: "Medium123")
        PasswordStrengthView(password: "StrongP@ssw0rd!")
    }
    .padding()
} 