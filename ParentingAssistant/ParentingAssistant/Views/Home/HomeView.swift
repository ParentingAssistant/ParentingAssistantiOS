import SwiftUI

struct HomeView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var selectedTab = 0
    @State private var hasNotifications = true
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Top Navigation
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text(authService.currentUser?.fullName ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            
                            Button(action: { /* Handle notifications */ }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    if hasNotifications {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 2, y: -2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Daily Overview Section
                        VStack(spacing: 16) {
                            Text("Today's Overview")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DailyOverviewCard(
                                icon: "fork.knife",
                                title: "Dinner",
                                description: "Chicken and vegetable stir fry",
                                time: "6:30 PM"
                            )
                            
                            DailyOverviewCard(
                                icon: "gift",
                                title: "Activity",
                                description: "Make a birthday card for uncle Tim",
                                time: "2:00 PM"
                            )
                            
                            DailyOverviewCard(
                                icon: "bell",
                                title: "Reminder",
                                description: "Don't forget to pack lunch for tomorrow",
                                time: "Evening"
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                        .padding(.horizontal)
                        
                        // Feature Grid Section
                        VStack(spacing: 16) {
                            Text("What would you like to do?")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ],
                                spacing: 16
                            ) {
                                FeatureGridItem(
                                    icon: "fork.knife",
                                    title: "Meal Plans",
                                    color: .blue,
                                    destination: AnyView(MealPlanningView())
                                )
                                
                                FeatureGridItem(
                                    icon: "book.fill",
                                    title: "Bedtime Stories",
                                    color: .purple,
                                    destination: AnyView(BedtimeStoryView())
                                )
                                
                                FeatureGridItem(
                                    icon: "checklist.checked",
                                    title: "Kids' Routines",
                                    color: .mint,
                                    destination: AnyView(KidsRoutinesView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "house.fill",
                                    title: "Household Chores",
                                    color: .brown,
                                    destination: AnyView(HouseholdChoresView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "figure.2.and.child.holdinghands",
                                    title: "Kids' Activities",
                                    color: .green,
                                    destination: AnyView(KidsActivitiesView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "cart.fill",
                                    title: "Running Errands",
                                    color: .red,
                                    destination: AnyView(RunningErrandsView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "heart.text.square.fill",
                                    title: "Emotional Support",
                                    color: .pink,
                                    destination: AnyView(EmotionalNeedsView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "chart.bar.fill",
                                    title: "Health & Growth",
                                    color: .teal,
                                    destination: AnyView(HealthTrackingView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "calendar.badge.clock",
                                    title: "Family Scheduler",
                                    color: .indigo,
                                    destination: AnyView(FamilySchedulerView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "figure.mind.and.body",
                                    title: "Work-Life Balance",
                                    color: .cyan,
                                    destination: AnyView(WorkLifeBalanceView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "moon.stars.fill",
                                    title: "Sleep Support",
                                    color: .purple,
                                    destination: AnyView(SleepStrugglesView()),
                                    isBeta: true
                                )
                                
                                FeatureGridItem(
                                    icon: "airplane.circle.fill",
                                    title: "Travel Prep",
                                    color: .orange,
                                    destination: AnyView(TravelPrepView()),
                                    isBeta: true
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGroupedBackground))
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            NavigationStack {
                MarketplaceView()
            }
            .tabItem {
                Label("Shop", systemImage: "cart.fill")
            }
            .tag(2)
            
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

struct DailyOverviewCard: View {
    let icon: String
    let title: String
    let description: String
    let time: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct FeatureGridItem: View {
    let icon: String
    let title: String
    let color: Color
    let destination: AnyView
    var isBeta: Bool = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(color)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                if isBeta {
                    Text("BETA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(4)
                        .padding(8)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}

struct HomeView2_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 
