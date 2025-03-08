import SwiftUI

struct FamilySchedulerView: View {
    @State private var selectedDate = Date()
    @State private var selectedTab = "Calendar"
    @State private var showingAddEvent = false
    @State private var showingAddTask = false
    @State private var showingAddExpense = false
    
    let tabs = ["Calendar", "Tasks", "Budget"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date selector
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Tab Selector
                HStack(spacing: 16) {
                    ForEach(tabs, id: \.self) { tab in
                        SchedulerTabButton(
                            title: tab,
                            isSelected: selectedTab == tab
                        ) {
                            withAnimation {
                                selectedTab = tab
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Content based on selected tab
                switch selectedTab {
                case "Calendar":
                    CalendarSection(showingAddEvent: $showingAddEvent)
                case "Tasks":
                    TasksSection(showingAddTask: $showingAddTask)
                case "Budget":
                    BudgetSection(showingAddExpense: $showingAddExpense)
                default:
                    EmptyView()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Family Scheduler")
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
        .sheet(isPresented: $showingAddTask) {
            FamilyTaskFormView()
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
    }
}

struct SchedulerTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct CalendarSection: View {
    @Binding var showingAddEvent: Bool
    let upcomingEvents = [
        Event(title: "Soccer Practice", date: "Today, 4:00 PM", category: "Sports", participants: ["John", "Emma"]),
        Event(title: "Parent-Teacher Meeting", date: "Tomorrow, 2:30 PM", category: "School", participants: ["Parents"]),
        Event(title: "Family Movie Night", date: "Saturday, 7:00 PM", category: "Family", participants: ["All"])
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Upcoming Events")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddEvent = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            ForEach(upcomingEvents) { event in
                EventCard(event: event)
            }
        }
    }
}

struct TasksSection: View {
    @Binding var showingAddTask: Bool
    @State private var tasks = [
        FamilyTask(title: "Pack school lunches", priority: "High", dueDate: "Today", assignedTo: "Mom"),
        FamilyTask(title: "Pick up dry cleaning", priority: "Medium", dueDate: "Tomorrow", assignedTo: "Dad"),
        FamilyTask(title: "Schedule dentist appointments", priority: "Low", dueDate: "This week", assignedTo: "Mom")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Family Tasks")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            ForEach(tasks) { task in
                TaskCard(task: task)
            }
        }
    }
}

struct BudgetSection: View {
    @Binding var showingAddExpense: Bool
    let expenses = [
        Expense(category: "Groceries", amount: 150.0, date: "Today"),
        Expense(category: "Activities", amount: 75.0, date: "Yesterday"),
        Expense(category: "School", amount: 45.0, date: "Mar 15")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Budget Overview
            VStack(spacing: 12) {
                Text("March Budget")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    BudgetStatCard(title: "Spent", amount: "$850", color: .blue)
                    BudgetStatCard(title: "Remaining", amount: "$650", color: .green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Recent Expenses
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recent Expenses")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                ForEach(expenses) { expense in
                    ExpenseCard(expense: expense)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let category: String
    let participants: [String]
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.category)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(event.date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                Text(event.participants.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct FamilyTask: Identifiable {
    let id = UUID()
    let title: String
    let priority: String
    let dueDate: String
    let assignedTo: String
}

struct TaskCard: View {
    let task: FamilyTask
    
    var priorityColor: Color {
        switch task.priority {
        case "High": return .red
        case "Medium": return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(priorityColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                
                HStack {
                    Label(task.dueDate, systemImage: "calendar")
                    Spacer()
                    Label(task.assignedTo, systemImage: "person.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct Expense: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let date: String
}

struct ExpenseCard: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.headline)
                Text(expense.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", expense.amount))")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BudgetStatCard: View {
    let title: String
    let amount: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(amount)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Event Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Event")
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

struct FamilyTaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Family Task Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Task")
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

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Expense Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Expense")
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

struct FamilySchedulerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FamilySchedulerView()
        }
    }
} 