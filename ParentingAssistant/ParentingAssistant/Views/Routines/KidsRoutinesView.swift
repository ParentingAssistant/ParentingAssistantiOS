import SwiftUI

struct KidsRoutinesView: View {
    @State private var selectedChild = "Child 1"
    @State private var selectedRoutine = "Morning"
    @State private var showingAddTask = false
    
    let children = ["Child 1", "Child 2", "Child 3"]
    let routineTypes = ["Morning", "After School", "Bedtime"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Child Selector
                Picker("Select Child", selection: $selectedChild) {
                    ForEach(children, id: \.self) { child in
                        Text(child).tag(child)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Routine Type Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(routineTypes, id: \.self) { routine in
                            RoutineTypeButton(
                                title: routine,
                                isSelected: routine == selectedRoutine
                            ) {
                                withAnimation {
                                    selectedRoutine = routine
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Progress Summary
                HStack(spacing: 20) {
                    ProgressCard(title: "Daily Streak", value: "5 days", icon: "flame.fill", color: .orange)
                    ProgressCard(title: "Stars Earned", value: "12 ⭐️", icon: "star.fill", color: .yellow)
                }
                .padding(.horizontal)
                
                // Tasks List
                VStack(spacing: 16) {
                    ForEach(routineTasks) { task in
                        RoutineTaskCard(task: task)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Kids' Routines")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddRoutineTaskView()
        }
    }
    
    let routineTasks = [
        RoutineTask(
            title: "Brush Teeth",
            icon: "tooth.fill",
            isCompleted: true,
            stars: 2,
            timeOfDay: "Morning",
            duration: "2 mins"
        ),
        RoutineTask(
            title: "Make Bed",
            icon: "bed.double.fill",
            isCompleted: true,
            stars: 2,
            timeOfDay: "Morning",
            duration: "5 mins"
        ),
        RoutineTask(
            title: "Get Dressed",
            icon: "tshirt.fill",
            isCompleted: false,
            stars: 2,
            timeOfDay: "Morning",
            duration: "10 mins"
        ),
        RoutineTask(
            title: "Pack Backpack",
            icon: "backpack.fill",
            isCompleted: false,
            stars: 3,
            timeOfDay: "Morning",
            duration: "5 mins"
        )
    ]
}

struct RoutineTask: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var isCompleted: Bool
    let stars: Int
    let timeOfDay: String
    let duration: String
}

struct RoutineTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RoutineTaskCard: View {
    let task: RoutineTask
    @State private var isCompleted: Bool
    
    init(task: RoutineTask) {
        self.task = task
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Task Icon
            Image(systemName: task.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            // Task Details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                HStack {
                    Text(task.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("\(task.stars) stars")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            // Completion Button
            Button(action: { isCompleted.toggle() }) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .frame(width: 30, height: 30)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AddRoutineTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedTimeOfDay = "Morning"
    @State private var duration = "5"
    @State private var stars = 2
    
    let timeOptions = ["Morning", "After School", "Bedtime"]
    let iconOptions = [
        "tooth.fill",
        "bed.double.fill",
        "tshirt.fill",
        "backpack.fill",
        "book.fill",
        "pencil.fill",
        "shower.fill",
        "moon.stars.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $taskTitle)
                    
                    Picker("Time of Day", selection: $selectedTimeOfDay) {
                        ForEach(timeOptions, id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    
                    HStack {
                        Text("Duration (mins)")
                        TextField("5", text: $duration)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text("Icon & Rewards")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(iconOptions, id: \.self) { icon in
                                IconSelectionButton(
                                    icon: icon,
                                    isSelected: icon == selectedIcon,
                                    action: { selectedIcon = icon }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Stepper("Stars: \(stars)", value: $stars, in: 1...5)
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
                    Button("Save") {
                        // Save task logic here
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}

struct KidsRoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KidsRoutinesView()
        }
    }
} 