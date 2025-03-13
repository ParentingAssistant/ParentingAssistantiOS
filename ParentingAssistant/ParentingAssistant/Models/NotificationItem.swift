import SwiftUI

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let category: NotificationCategory
    var isRead: Bool
    let actionData: [String: Any]?
    
    var iconName: String {
        switch category {
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
    
    var iconColor: Color {
        switch category {
        case .mealPlan:
            return .blue
        case .bedtime:
            return .purple
        case .activity:
            return .green
        case .reminder:
            return .orange
        case .health:
            return .pink
        case .general:
            return .gray
        }
    }
} 