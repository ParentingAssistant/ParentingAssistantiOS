import Foundation

struct Task: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    var isCompleted: Bool
    var dueDate: Date?
    var assignedTo: String?
    var category: TaskCategory
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String? = nil,
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         assignedTo: String? = nil,
         category: TaskCategory,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.assignedTo = assignedTo
        self.category = category
        self.createdAt = createdAt
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case cleaning = "Cleaning"
    case laundry = "Laundry"
    case kitchen = "Kitchen"
    case homework = "Homework"
    case bedroom = "Bedroom"
    case bathroom = "Bathroom"
    case outdoor = "Outdoor"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .cleaning: return "spray.and.sparkles"
        case .laundry: return "washer"
        case .kitchen: return "fork.knife"
        case .homework: return "book"
        case .bedroom: return "bed.double"
        case .bathroom: return "shower"
        case .outdoor: return "leaf"
        case .other: return "checklist"
        }
    }
    
    var color: String {
        switch self {
        case .cleaning: return "32ADE6" // Blue
        case .laundry: return "9747FF" // Purple
        case .kitchen: return "FF9500" // Orange
        case .homework: return "32D74B" // Green
        case .bedroom: return "FF375F" // Red
        case .bathroom: return "00C7BE" // Teal
        case .outdoor: return "34C759" // Green
        case .other: return "8E8E93" // Gray
        }
    }
} 