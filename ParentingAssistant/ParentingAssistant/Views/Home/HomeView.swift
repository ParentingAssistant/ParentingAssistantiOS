import SwiftUI

struct HomeView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
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
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            NavigationLink(destination: MealPrepView()) {
                                FeatureCard(
                                    icon: "fork.knife",
                                    title: "Meal Prep",
                                    subtitle: "Plan meals & groceries"
                                )
                            }
                            
                            NavigationLink(destination: BedtimeStoryView()) {
                                FeatureCard(
                                    icon: "book.fill",
                                    title: "Bedtime Stories",
                                    subtitle: "Read stories to your kids"
                                )
                            }
                            
                            NavigationLink(destination: ChoresView()) {
                                FeatureCard(
                                    icon: "house.fill",
                                    title: "Household Chores",
                                    subtitle: "Manage family tasks"
                                )
                            }
                            
                            NavigationLink(destination: KidsActivitiesView()) {
                                FeatureCard(
                                    icon: "figure.2.and.child.holdinghands",
                                    title: "Kids' Activities",
                                    subtitle: "Fun & educational activities"
                                )
                            }
                            
                            NavigationLink(destination: RunningErrandsView()) {
                                FeatureCard(
                                    icon: "cart.fill",
                                    title: "Running Errands",
                                    subtitle: "Smart shopping & scheduling"
                                )
                            }
                            
                            NavigationLink(destination: EmotionalNeedsView()) {
                                FeatureCard(
                                    icon: "heart.text.square.fill",
                                    title: "Emotional Support",
                                    subtitle: "Help kids manage emotions"
                                )
                            }
                            
                            NavigationLink(destination: HealthTrackingView()) {
                                FeatureCard(
                                    icon: "chart.bar.fill",
                                    title: "Health & Growth",
                                    subtitle: "Track development & health"
                                )
                            }
                            
                            NavigationLink(destination: FamilySchedulerView()) {
                                FeatureCard(
                                    icon: "calendar.badge.clock",
                                    title: "Family Scheduler",
                                    subtitle: "Organize events & tasks"
                                )
                            }
                            
                            NavigationLink(destination: WorkLifeBalanceView()) {
                                FeatureCard(
                                    icon: "figure.mind.and.body",
                                    title: "Work-Life Balance",
                                    subtitle: "Focus & self-care tools"
                                )
                            }
                            
                            NavigationLink(destination: SleepStrugglesView()) {
                                FeatureCard(
                                    icon: "moon.stars.fill",
                                    title: "Sleep Support",
                                    subtitle: "Track & improve sleep"
                                )
                            }
                            
                            NavigationLink(destination: TravelPrepView()) {
                                FeatureCard(
                                    icon: "airplane.circle.fill",
                                    title: "Travel Prep",
                                    subtitle: "Plan trips & outings"
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
            
            // Search Tab
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            // Marketplace Tab
            NavigationStack {
                MarketplaceView()
            }
            .tabItem {
                Label("Shop", systemImage: "cart.fill")
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
                    .lineLimit(2)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 