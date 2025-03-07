import SwiftUI

struct KidsActivitiesView: View {
    @State private var showingPlaydateCoordinator = false
    @State private var showingAIChatbot = false
    @State private var selectedCategory: ActivityCategory = .all
    
    enum ActivityCategory: String, CaseIterable {
        case all = "All"
        case playtime = "Playtime"
        case educational = "Educational"
        case outdoor = "Outdoor"
        case creative = "Creative"
        case games = "Games"
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .playtime: return .orange
            case .educational: return .green
            case .outdoor: return .purple
            case .creative: return .pink
            case .games: return .indigo
            }
        }
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2.fill"
            case .playtime: return "figure.play"
            case .educational: return "book.fill"
            case .outdoor: return "sun.max.fill"
            case .creative: return "paintbrush.fill"
            case .games: return "gamecontroller.fill"
            }
        }
    }
    
    let activities: [Activity] = [
        Activity(title: "Treasure Hunt", category: .playtime, description: "Set up an exciting indoor treasure hunt", duration: "30 mins", ageRange: "4-8 years"),
        Activity(title: "Science Experiment", category: .educational, description: "Simple and safe chemistry experiments", duration: "45 mins", ageRange: "6-12 years"),
        Activity(title: "Nature Walk", category: .outdoor, description: "Explore and collect leaves", duration: "1 hour", ageRange: "All ages"),
        Activity(title: "Art Project", category: .creative, description: "Paint with unusual materials", duration: "45 mins", ageRange: "3+ years"),
        Activity(title: "Memory Game", category: .games, description: "Fun card matching game", duration: "20 mins", ageRange: "5+ years")
    ]
    
    var filteredActivities: [Activity] {
        selectedCategory == .all ? activities : activities.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ActivityCategory.allCases, id: \.self) { category in
                            ActivityCategoryButton(
                                title: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: category == selectedCategory
                            ) {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Quick Actions
                HStack(spacing: 16) {
                    Button(action: { showingPlaydateCoordinator = true }) {
                        QuickActionButton(
                            title: "Coordinate Playdate",
                            icon: "calendar.badge.plus",
                            color: .purple
                        )
                    }
                    
                    Button(action: { showingAIChatbot = true }) {
                        QuickActionButton(
                            title: "Chat with AI",
                            icon: "bubble.left.fill",
                            color: .blue
                        )
                    }
                }
                .padding(.horizontal)
                
                // Activities Grid
                LazyVGrid(
                    columns: [GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(filteredActivities) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Kids' Activities")
        .sheet(isPresented: $showingPlaydateCoordinator) {
            PlaydateCoordinatorView()
        }
        .sheet(isPresented: $showingAIChatbot) {
            KidsChatbotView()
        }
    }
}

struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let category: KidsActivitiesView.ActivityCategory
    let description: String
    let duration: String
    let ageRange: String
}

struct ActivityCategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(isSelected ? color : color.opacity(0.1))
            .foregroundColor(isSelected ? .white : color)
            .cornerRadius(12)
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: activity.category.icon)
                    .font(.title2)
                    .foregroundColor(activity.category.color)
                Text(activity.title)
                    .font(.headline)
                Spacer()
                Text(activity.category.rawValue)
                    .font(.caption)
                    .padding(6)
                    .background(activity.category.color.opacity(0.1))
                    .foregroundColor(activity.category.color)
                    .cornerRadius(8)
            }
            
            Text(activity.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(activity.duration, systemImage: "clock.fill")
                Spacer()
                Label(activity.ageRange, systemImage: "person.2.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PlaydateCoordinatorView: View {
    var body: some View {
        NavigationView {
            Text("Playdate Coordinator")
                .navigationTitle("Schedule Playdate")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct KidsChatbotView: View {
    var body: some View {
        NavigationView {
            Text("AI Chatbot")
                .navigationTitle("Chat with AI Friend")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct KidsActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KidsActivitiesView()
        }
    }
} 