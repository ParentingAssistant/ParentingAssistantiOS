import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 12) {
                Text("Reset Password")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Enter your email to receive reset instructions")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
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
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Error/Success Message
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            if showSuccess {
                Text("Reset instructions sent to your email")
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            // Reset Button
            LoadingButton(
                title: "Send Reset Link",
                isLoading: authService.isLoading
            ) {
                validateAndSendResetEmail()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
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
    
    private func validateAndSendResetEmail() {
        // Reset states
        showError = false
        showSuccess = false
        errorMessage = ""
        
        // Validate email
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError = true
            errorMessage = "Please enter your email address"
            return
        }
        
        guard isValidEmail(email) else {
            showError = true
            errorMessage = "Please enter a valid email address"
            return
        }
        
        authService.resetPassword(email: email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ForgotPasswordView()
        }
    }
} 