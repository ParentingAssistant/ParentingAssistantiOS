import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        List {
            // Profile Header
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authService.currentUser?.fullName ?? "Parent")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(authService.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Preferences Section
            Section("Preferences") {
                NavigationLink {
                    Text("Dietary Restrictions")
                } label: {
                    Label("Dietary Restrictions", systemImage: "leaf.fill")
                }
                
                NavigationLink {
                    Text("Cuisine Types")
                } label: {
                    Label("Cuisine Types", systemImage: "fork.knife")
                }
                
                NavigationLink {
                    Text("Cooking Difficulty")
                } label: {
                    Label("Cooking Difficulty", systemImage: "chart.bar.fill")
                }
                
                NavigationLink {
                    Text("Serving Size")
                } label: {
                    Label("Serving Size", systemImage: "person.2.fill")
                }
            }
            
            // Notifications Section
            Section("Notifications") {
                Toggle("Weekly Meal Plan", isOn: .constant(authService.currentUser?.preferences.mealPreferences.weeklyPlanEnabled ?? false))
                Toggle("Meal Reminders", isOn: .constant(authService.currentUser?.preferences.notificationsEnabled ?? true))
            }
            
            // Account Section
            Section("Account") {
                Button {
                    showingEditProfile = true
                } label: {
                    Label("Edit Profile", systemImage: "pencil")
                }
                
                Button {
                    showingLogoutAlert = true
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Profile")
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                try? authService.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Button("Save Changes") {
                        // TODO: Implement profile update
                        showingAlert = true
                        alertMessage = "Profile updated successfully"
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
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
                fullName = authService.currentUser?.fullName ?? ""
                email = authService.currentUser?.email ?? ""
            }
            .alert("Profile Update", isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
} 