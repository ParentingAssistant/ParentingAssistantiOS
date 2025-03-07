import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showingEditProfile = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(authService.currentUser?.fullName ?? "User")
                                .font(.headline)
                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showingEditProfile = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("Preferences") {
                    NavigationLink("Dietary Restrictions") {
                        Text("Dietary Restrictions View")
                    }
                    
                    NavigationLink("Cuisine Types") {
                        Text("Cuisine Types View")
                    }
                    
                    NavigationLink("Cooking Difficulty") {
                        Text("Cooking Difficulty View")
                    }
                    
                    NavigationLink("Serving Size") {
                        Text("Serving Size View")
                    }
                }
                
                Section("Notifications") {
                    Toggle("Weekly Meal Plan", isOn: .constant(true))
                    Toggle("Meal Reminders", isOn: .constant(true))
                }
                
                Section {
                    Button(role: .destructive, action: { showingSignOutAlert = true }) {
                        HStack {
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "arrow.right.square")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    ProfileView()
} 