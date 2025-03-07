import SwiftUI

struct PasswordStrengthView: View {
    let password: String
    
    private var strength: PasswordStrength {
        if password.isEmpty {
            return .empty
        } else if password.count < 8 {
            return .weak
        } else if password.count < 12 {
            return .medium
        } else {
            return .strong
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Password Strength: \(strength.title)")
                .font(.caption)
                .foregroundColor(strength.color)
            
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < strength.bars ? strength.color : Color.gray.opacity(0.3))
                            .frame(width: (geometry.size.width - 4) / 3)
                    }
                }
            }
            .frame(height: 4)
        }
    }
}

private enum PasswordStrength {
    case empty
    case weak
    case medium
    case strong
    
    var title: String {
        switch self {
        case .empty: return "Empty"
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
    
    var color: Color {
        switch self {
        case .empty: return .gray
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
    
    var bars: Int {
        switch self {
        case .empty: return 0
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PasswordStrengthView(password: "")
        PasswordStrengthView(password: "123")
        PasswordStrengthView(password: "12345678")
        PasswordStrengthView(password: "123456789012")
    }
    .padding()
} 