import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 12) {
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Join our parenting community")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Sign Up Form
            VStack(spacing: 20) {
                // Full Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    TextField("Enter your full name", text: $fullName)
                        .textContentType(.name)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    TextField("Enter your email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    SecureField("Create a password", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    // Password Strength Indicator
                    PasswordStrengthView(password: password)
                        .padding(.top, 4)
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Error Message
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            // Sign Up Button
            LoadingButton(
                title: "Create Account",
                isLoading: authService.isLoading
            ) {
                validateAndSignUp()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Terms and Conditions
            Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .imageScale(.large)
                }
            }
        }
    }
    
    private func validateAndSignUp() {
        // Reset error state
        showError = false
        errorMessage = ""
        
        // Validate full name
        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError = true
            errorMessage = "Please enter your full name"
            return
        }
        
        // Validate email
        guard isValidEmail(email) else {
            showError = true
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Validate password
        guard password.count >= 8 else {
            showError = true
            errorMessage = "Password must be at least 8 characters long"
            return
        }
        
        // Validate password confirmation
        guard password == confirmPassword else {
            showError = true
            errorMessage = "Passwords do not match"
            return
        }
        
        authService.signUp(fullName: fullName, email: email, password: password)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
} 