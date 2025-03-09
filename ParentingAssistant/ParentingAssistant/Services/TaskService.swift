import SwiftUI

class ChoreService: ObservableObject {
    static let shared = ChoreService()
    
    @Published var chores: [ChoreTask] = []
    
    private init() {
        // Initialize with sample chores
        chores = [
            ChoreTask(title: "Make the bed", category: .bedroom),
            ChoreTask(title: "Empty dishwasher", category: .kitchen),
            ChoreTask(title: "Do homework", category: .homework),
            ChoreTask(title: "Feed pets", category: .other),
            ChoreTask(title: "Clean bathroom", category: .bathroom)
        ]
    }
    
    func addChore(_ chore: ChoreTask) {
        chores.append(chore)
    }
    
    func toggleChore(_ chore: ChoreTask) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted.toggle()
        }
    }
    
    func deleteChore(_ chore: ChoreTask) {
        chores.removeAll { $0.id == chore.id }
    }
    
    func updateChore(_ chore: ChoreTask) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index] = chore
        }
    }
} 