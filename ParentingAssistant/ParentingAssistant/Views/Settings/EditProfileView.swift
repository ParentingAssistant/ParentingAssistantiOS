import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessMessage = false
    @State private var error = ""
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $fullName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(true) // Email cannot be changed
                }
                
                Section {
                    Button(action: saveChanges) {
                        HStack {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Save Changes")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isLoading || !isValid)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let user = authService.currentUser {
                    fullName = user.fullName
                    email = user.email
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveChanges() {
        isLoading = true
        authService.updateProfile(fullName: fullName) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    alertMessage = "Profile updated successfully"
                    showAlert = true
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
} 