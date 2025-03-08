import SwiftUI

struct WorkLifeBalanceView: View {
    @State private var isFocusModeActive = false
    @State private var selectedTimeBlock = 30
    @State private var showingFocusSettings = false
    @State private var selectedCategory = "All"
    
    let timeBlocks = [15, 30, 45, 60]
    let categories = ["All", "Home", "Work", "Kids"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Focus Mode Section
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Focus Mode")
                                .font(.headline)
                            Text("Minimize distractions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isFocusModeActive)
                            .tint(.blue)
                    }
                    
                    if isFocusModeActive {
                        HStack {
                            ForEach(timeBlocks, id: \.self) { minutes in
                                TimeBlockButton(
                                    minutes: minutes,
                                    isSelected: minutes == selectedTimeBlock
                                ) {
                                    selectedTimeBlock = minutes
                                }
                            }
                        }
                        
                        Button(action: { showingFocusSettings = true }) {
                            Text("Customize Focus Settings")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Task Delegation Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Suggested Tasks to Delegate")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                DelegationCategoryPill(
                                    title: category,
                                    isSelected: category == selectedCategory
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ForEach(delegationSuggestions) { suggestion in
                        if selectedCategory == "All" || suggestion.category == selectedCategory {
                            DelegationCard(suggestion: suggestion)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Self-Care Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Self-Care Recommendations")
                        .font(.headline)
                    
                    ForEach(selfCareActivities) { activity in
                        SelfCareCard(activity: activity)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Work-Life Balance")
        .sheet(isPresented: $showingFocusSettings) {
            FocusSettingsView()
        }
    }
    
    let delegationSuggestions = [
        DelegationSuggestion(
            title: "Grocery Shopping",
            description: "Use a delivery service for weekly groceries",
            category: "Home",
            service: "Instacart",
            estimatedTime: "2 hours saved"
        ),
        DelegationSuggestion(
            title: "House Cleaning",
            description: "Book a weekly cleaning service",
            category: "Home",
            service: "TaskRabbit",
            estimatedTime: "4 hours saved"
        ),
        DelegationSuggestion(
            title: "Kids' Transportation",
            description: "Set up a carpool with other parents",
            category: "Kids",
            service: "Local Network",
            estimatedTime: "1 hour daily"
        ),
        DelegationSuggestion(
            title: "Email Management",
            description: "Use an AI assistant for email triage",
            category: "Work",
            service: "AI Assistant",
            estimatedTime: "1 hour daily"
        )
    ]
    
    let selfCareActivities = [
        SelfCareActivity(
            title: "Morning Meditation",
            description: "Start your day with 10 minutes of mindfulness",
            duration: "10 mins",
            benefit: "Reduced stress, improved focus",
            type: .mindfulness
        ),
        SelfCareActivity(
            title: "Lunch Break Walk",
            description: "Take a refreshing walk during lunch",
            duration: "20 mins",
            benefit: "Physical activity, mental clarity",
            type: .physical
        ),
        SelfCareActivity(
            title: "Evening Reading",
            description: "Wind down with a book before bed",
            duration: "15 mins",
            benefit: "Better sleep, relaxation",
            type: .relaxation
        )
    ]
}

struct TimeBlockButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(minutes)m")
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct DelegationCategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct DelegationSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let service: String
    let estimatedTime: String
}

struct DelegationCard: View {
    let suggestion: DelegationSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(suggestion.title)
                    .font(.headline)
                Spacer()
                Text(suggestion.category)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(suggestion.service, systemImage: "link")
                Spacer()
                Label(suggestion.estimatedTime, systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SelfCareActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let benefit: String
    let type: ActivityType
    
    enum ActivityType {
        case mindfulness
        case physical
        case relaxation
        
        var color: Color {
            switch self {
            case .mindfulness: return .blue
            case .physical: return .green
            case .relaxation: return .purple
            }
        }
        
        var icon: String {
            switch self {
            case .mindfulness: return "brain.head.profile"
            case .physical: return "figure.walk"
            case .relaxation: return "leaf"
            }
        }
    }
}

struct SelfCareCard: View {
    let activity: SelfCareActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: activity.type.icon)
                    .foregroundColor(activity.type.color)
                Text(activity.title)
                    .font(.headline)
                Spacer()
                Text(activity.duration)
                    .font(.caption)
                    .padding(6)
                    .background(activity.type.color.opacity(0.1))
                    .foregroundColor(activity.type.color)
                    .cornerRadius(8)
            }
            
            Text(activity.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(activity.benefit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FocusSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Focus Settings Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Focus Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkLifeBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkLifeBalanceView()
        }
    }
} 