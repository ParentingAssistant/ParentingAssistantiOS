import Foundation
import FirebaseFirestore
import UserNotifications

enum NotificationCategory: String, Codable {
    case mealPlan = "meal_plan"
    case bedtime = "bedtime"
    case activity = "activity"
    case reminder = "reminder"
    case health = "health"
    case general = "general"
}

enum NotificationAction: String {
    case viewMealPlan = "view_meal_plan"
    case viewActivity = "view_activity"
    case viewBedtime = "view_bedtime"
    case viewHealth = "view_health"
    case dismiss = "dismiss"
}

@MainActor
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [NotificationItem] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private override init() {
        super.init()
        setupNotificationHandling()
    }
    
    func setupNotificationHandling() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
                Task { @MainActor in
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
        
        // Configure notification categories and actions
        let mealPlanAction = UNNotificationAction(
            identifier: NotificationAction.viewMealPlan.rawValue,
            title: "View Meal Plan",
            options: .foreground
        )
        
        let activityAction = UNNotificationAction(
            identifier: NotificationAction.viewActivity.rawValue,
            title: "View Activity",
            options: .foreground
        )
        
        let bedtimeAction = UNNotificationAction(
            identifier: NotificationAction.viewBedtime.rawValue,
            title: "View Bedtime",
            options: .foreground
        )
        
        let healthAction = UNNotificationAction(
            identifier: NotificationAction.viewHealth.rawValue,
            title: "View Health",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: NotificationAction.dismiss.rawValue,
            title: "Dismiss",
            options: .destructive
        )
        
        let mealPlanCategory = UNNotificationCategory(
            identifier: NotificationCategory.mealPlan.rawValue,
            actions: [mealPlanAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let activityCategory = UNNotificationCategory(
            identifier: NotificationCategory.activity.rawValue,
            actions: [activityAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let bedtimeCategory = UNNotificationCategory(
            identifier: NotificationCategory.bedtime.rawValue,
            actions: [bedtimeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let healthCategory = UNNotificationCategory(
            identifier: NotificationCategory.health.rawValue,
            actions: [healthAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            mealPlanCategory,
            activityCategory,
            bedtimeCategory,
            healthCategory
        ])
        
        // Set the delegate
        UNUserNotificationCenter.current().delegate = self
    }
    
    func startListening() {
        Task { @MainActor in
            guard let userId = AuthenticationService.shared.currentUser?.id, !userId.isEmpty else {
                self.isLoading = false
                self.error = "No user logged in"
                return
            }
            
            self.isLoading = true
            self.error = nil
            
            listener = db.collection("users")
                .document(userId)
                .collection("notifications")
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    Task { @MainActor in
                        if let error = error {
                            print("Error listening to notifications: \(error.localizedDescription)")
                            self.error = error.localizedDescription
                            self.isLoading = false
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            self.notifications = []
                            self.updateUnreadCount()
                            self.isLoading = false
                            return
                        }
                        
                        self.notifications = documents.compactMap { document -> NotificationItem? in
                            let data = document.data()
                            guard let id = data["id"] as? String,
                                  let title = data["title"] as? String,
                                  let message = data["message"] as? String,
                                  let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                                  let category = data["category"] as? String,
                                  let isRead = data["isRead"] as? Bool else {
                                return nil
                            }
                            
                            return NotificationItem(
                                id: id,
                                title: title,
                                message: message,
                                timestamp: timestamp,
                                category: NotificationCategory(rawValue: category) ?? .general,
                                isRead: isRead,
                                actionData: data["actionData"] as? [String: Any]
                            )
                        }
                        
                        self.updateUnreadCount()
                        self.isLoading = false
                    }
                }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func markAsRead(_ notificationId: String) {
        Task { @MainActor in
            guard let userId = AuthenticationService.shared.currentUser?.id, !userId.isEmpty else {
                self.error = "No user logged in"
                return
            }
            
            db.collection("users")
                .document(userId)
                .collection("notifications")
                .document(notificationId)
                .updateData(["isRead": true]) { error in
                    if let error = error {
                        print("Error marking notification as read: \(error.localizedDescription)")
                        Task { @MainActor in
                            self.error = error.localizedDescription
                        }
                    }
                }
        }
    }
    
    func markAllAsRead() {
        Task { @MainActor in
            guard let userId = AuthenticationService.shared.currentUser?.id, !userId.isEmpty else {
                self.error = "No user logged in"
                return
            }
            
            let batch = db.batch()
            notifications.forEach { notification in
                if !notification.isRead {
                    let ref = db.collection("users")
                        .document(userId)
                        .collection("notifications")
                        .document(notification.id)
                    batch.updateData(["isRead": true], forDocument: ref)
                }
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error marking all notifications as read: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    func handleNotificationAction(_ action: NotificationAction, for notification: NotificationItem) {
        switch action {
        case .viewMealPlan:
            // Navigate to meal plan
            break
        case .viewActivity:
            // Navigate to activity
            break
        case .viewBedtime:
            // Navigate to bedtime
            break
        case .viewHealth:
            // Navigate to health
            break
        case .dismiss:
            markAsRead(notification.id)
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action = NotificationAction(rawValue: response.actionIdentifier) ?? .dismiss
        
        Task { @MainActor in
            if let notificationId = response.notification.request.content.userInfo["notificationId"] as? String,
               let notification = notifications.first(where: { $0.id == notificationId }) {
                handleNotificationAction(action, for: notification)
            }
            
            completionHandler()
        }
    }
} 