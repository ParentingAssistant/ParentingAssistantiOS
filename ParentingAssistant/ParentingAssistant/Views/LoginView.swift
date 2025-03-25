import SwiftUI
import LocalAuthentication
import UIKit

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var canUseBiometrics = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 12) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Sign in to continue")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Login Form
            VStack(spacing: 20) {
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
                    
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
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
            
            // Login Button
            LoadingButton(
                title: "Login",
                isLoading: authService.isLoading
            ) {
                validateAndLogin()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Or Divider
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("OR")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding(.horizontal, 8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            
            // Google Sign-In Button
            GoogleSignInButton {
                signInWithGoogle()
            }
            .padding(.horizontal, 24)
            
            // Biometric Login
            if canUseBiometrics {
                Button(action: {
                    authenticateWithBiometrics()
                }) {
                    HStack {
                        Image(systemName: LAContext().biometryType == .faceID ? "faceid" : "touchid")
                        Text("Login with Biometrics")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top, 8)
            }
            
            // Forgot Password
            Button(action: {
                showForgotPassword = true
            }) {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
            
            Spacer()
            
            // Sign Up Link
            VStack(spacing: 8) {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 30)
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
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
        .navigationDestination(isPresented: $showForgotPassword) {
            Text("Forgot Password") // TODO: Create ForgotPasswordView
        }
        .onAppear {
            let context = LAContext()
            var error: NSError?
            canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        }
    }
    
    private func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Failed to get root view controller")
            return
        }
        
        authService.signInWithGoogle(presenting: rootViewController)
    }
    
    private func validateAndLogin() {
        // Reset error state
        showError = false
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
        
        // Validate password
        guard !password.isEmpty else {
            showError = true
            errorMessage = "Please enter your password"
            return
        }
        
        authService.login(email: email, password: password)
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showError = true
            errorMessage = error?.localizedDescription ?? "Biometric authentication not available"
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access your account"
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.authService.login(email: "", password: "")
                } else if let error = error {
                    self.showError = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
        }
    }
}
