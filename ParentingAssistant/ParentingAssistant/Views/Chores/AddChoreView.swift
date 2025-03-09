import SwiftUI

struct AddChoreView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var choreService = ChoreService.shared
    @State private var title = ""
    @State private var description = ""
    @State private var assignedTo = ""
    @State private var category: ChoreCategory

    init(category: ChoreCategory) {
        _category = State(initialValue: category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chore Details")) {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description)
                    TextField("Assign to (optional)", text: $assignedTo)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ChoreCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let chore = ChoreTask(
                            title: title,
                            description: description.isEmpty ? nil : description,
                            assignedTo: assignedTo.isEmpty ? nil : assignedTo,
                            category: category
                        )
                        choreService.addChore(chore)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 