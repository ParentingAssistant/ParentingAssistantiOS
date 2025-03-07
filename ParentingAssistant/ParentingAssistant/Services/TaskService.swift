import SwiftUI

@MainActor
class TaskService: ObservableObject {
    static let shared = TaskService()
    
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {
        // Initialize with sample tasks
        tasks = [
            Task(title: "Make the bed", category: .bedroom),
            Task(title: "Empty dishwasher", category: .kitchen),
            Task(title: "Do homework", category: .homework),
            Task(title: "Feed pets", category: .other),
            Task(title: "Clean bathroom", category: .bathroom)
        ]
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        // TODO: Sync with backend
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            // TODO: Sync with backend
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        // TODO: Sync with backend
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            // TODO: Sync with backend
        }
    }
} 