import Foundation

struct Story: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let theme: String
    let childName: String
    let createdAt: Date
    let ageGroup: String
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        theme: String,
        childName: String,
        ageGroup: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.theme = theme
        self.childName = childName
        self.ageGroup = ageGroup
        self.createdAt = createdAt
    }
} 