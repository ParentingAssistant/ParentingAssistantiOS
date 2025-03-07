import SwiftUI

struct ChoresView: View {
    @StateObject private var taskService = TaskService.shared
    @State private var showingAddTask = false
    @State private var selectedCategory: TaskCategory = .other
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: category == selectedCategory
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Tasks List
                LazyVStack(spacing: 16) {
                    ForEach(taskService.tasks.filter {
                        selectedCategory == .other ? true : $0.category == selectedCategory
                    }) { task in
                        TaskRow(task: task) { task in
                            taskService.toggleTask(task)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Household Chores")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(category: selectedCategory)
        }
    }
}

struct CategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: category.color) : Color(.systemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: (Task) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: { onToggle(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? Color(hex: task.category.color) : .gray)
            }
            
            // Task Details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                
                if let description = task.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let assignedTo = task.assignedTo {
                    Text("Assigned to: \(assignedTo)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Category Icon
            Image(systemName: task.category.icon)
                .foregroundColor(Color(hex: task.category.color))
                .font(.title3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskService = TaskService.shared
    @State private var title = ""
    @State private var description = ""
    @State private var assignedTo = ""
    @State private var category: TaskCategory
    
    init(category: TaskCategory) {
        _category = State(initialValue: category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description)
                    TextField("Assign to (optional)", text: $assignedTo)
                    
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let task = Task(
                            title: title,
                            description: description.isEmpty ? nil : description,
                            assignedTo: assignedTo.isEmpty ? nil : assignedTo,
                            category: category
                        )
                        taskService.addTask(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ChoresView()
    }
} 