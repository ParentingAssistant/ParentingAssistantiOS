import SwiftUI

struct HomeView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Grid View
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome Section
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text(authService.currentUser?.fullName ?? "Parent")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Features Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            NavigationLink(destination: MealPlanningView()) {
                                FeatureCard(
                                    icon: "fork.knife",
                                    title: "Meal Planning",
                                    subtitle: "Plan your family meals"
                                )
                            }
                            
                            NavigationLink(destination: Text("Bedtime Stories")) {
                                FeatureCard(
                                    icon: "book.fill",
                                    title: "Bedtime Stories",
                                    subtitle: "Read stories to your kids"
                                )
                            }
                            
                            NavigationLink(destination: Text("Household Chores")) {
                                FeatureCard(
                                    icon: "house.fill",
                                    title: "Household Chores",
                                    subtitle: "Manage family tasks"
                                )
                            }
                            
                            NavigationLink(destination: Text("Kids' Routines")) {
                                FeatureCard(
                                    icon: "clock.fill",
                                    title: "Kids' Routines",
                                    subtitle: "Track daily schedules"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Meal Planning Tab
            NavigationStack {
                MealPlanningView()
            }
            .tabItem {
                Label("Meals", systemImage: "fork.knife")
            }
            .tag(1)
            
            // Stories Tab
            NavigationStack {
                Text("Bedtime Stories")
                    .navigationTitle("Stories")
            }
            .tabItem {
                Label("Stories", systemImage: "book.fill")
            }
            .tag(2)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
} 