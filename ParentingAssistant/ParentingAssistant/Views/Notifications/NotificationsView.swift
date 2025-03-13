import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationService = NotificationService.shared
    @State private var selectedCategory: NotificationCategory?
    @State private var showingFilters = false
    
    private var filteredNotifications: [NotificationItem] {
        guard let category = selectedCategory else {
            return notificationService.notifications
        }
        return notificationService.notifications.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if notificationService.isLoading {
                    ProgressView()
                } else if filteredNotifications.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Notifications")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("You're all caught up!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(filteredNotifications) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    notificationService.markAsRead(notification.id)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            selectedCategory = nil
                        } label: {
                            Label("All", systemImage: "bell.fill")
                        }
                        
                        ForEach(NotificationCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(category.displayName, systemImage: category.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        notificationService.markAllAsRead()
                    } label: {
                        Text("Mark All Read")
                    }
                    .disabled(filteredNotifications.isEmpty)
                }
            }
        }
        .onAppear {
            notificationService.startListening()
        }
        .onDisappear {
            notificationService.stopListening()
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: notification.iconName)
                    .foregroundColor(notification.iconColor)
                    .font(.title3)
                
                Text(notification.title)
                    .font(.headline)
                
                Spacer()
                
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.7 : 1.0)
    }
}

extension NotificationCategory: CaseIterable {
    static var allCases: [NotificationCategory] = [
        .mealPlan,
        .bedtime,
        .activity,
        .reminder,
        .health,
        .general
    ]
    
    var displayName: String {
        switch self {
        case .mealPlan:
            return "Meal Plans"
        case .bedtime:
            return "Bedtime"
        case .activity:
            return "Activities"
        case .reminder:
            return "Reminders"
        case .health:
            return "Health"
        case .general:
            return "General"
        }
    }
    
    var iconName: String {
        switch self {
        case .mealPlan:
            return "fork.knife"
        case .bedtime:
            return "moon.stars.fill"
        case .activity:
            return "figure.2.and.child.holdinghands"
        case .reminder:
            return "bell.fill"
        case .health:
            return "heart.text.square.fill"
        case .general:
            return "bell.fill"
        }
    }
}

#Preview {
    NotificationsView()
} 