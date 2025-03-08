import SwiftUI

struct HouseholdChoresView: View {
    @State private var selectedDay = Date()
    @State private var showingAddChore = false
    @State private var showingVoiceReminders = false
    @State private var showingCleaningTip = false
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Today", "Upcoming", "Completed"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date Selector
                DatePicker(
                    "Select Date",
                    selection: $selectedDay,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.self) { filter in
                            FilterButton(
                                title: filter,
                                isSelected: filter == selectedFilter
                            ) {
                                withAnimation {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Chores List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Daily Chores")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingVoiceReminders = true }) {
                            Image(systemName: "mic.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(choresList) { chore in
                        ChoreCard(chore: chore)
                    }
                }
                
                // Cleaning Tips
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Cleaning Tips")
                            .font(.headline)
                        Spacer()
                        Button("See All") {
                            showingCleaningTip = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    ForEach(cleaningTips.prefix(2)) { tip in
                        CleaningTipCard(tip: tip)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Add Chore Button
                Button(action: { showingAddChore = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Chore")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Household Chores")
        .sheet(isPresented: $showingAddChore) {
            AddChoreView()
        }
        .sheet(isPresented: $showingVoiceReminders) {
            VoiceRemindersView()
        }
        .sheet(isPresented: $showingCleaningTip) {
            CleaningTipsView()
        }
    }
    
    let choresList = [
        Chore(
            title: "Make Beds",
            assignedTo: "Kids",
            dueTime: "Morning",
            isCompleted: false,
            points: 5,
            icon: "bed.double.fill"
        ),
        Chore(
            title: "Empty Dishwasher",
            assignedTo: "Parent",
            dueTime: "After Breakfast",
            isCompleted: true,
            points: 10,
            icon: "dishwasher.fill"
        ),
        Chore(
            title: "Vacuum Living Room",
            assignedTo: "Teen",
            dueTime: "Afternoon",
            isCompleted: false,
            points: 15,
            icon: "vacuum.fill"
        ),
        Chore(
            title: "Take Out Trash",
            assignedTo: "Dad",
            dueTime: "Evening",
            isCompleted: false,
            points: 5,
            icon: "trash.fill"
        )
    ]
    
    let cleaningTips = [
        CleaningTip(
            title: "Quick Kitchen Clean",
            description: "Wipe counters while cooking to prevent buildup",
            duration: "2 mins",
            category: "Kitchen"
        ),
        CleaningTip(
            title: "Efficient Laundry",
            description: "Sort clothes by color while putting them in hamper",
            duration: "1 min",
            category: "Laundry"
        ),
        CleaningTip(
            title: "Bathroom Shine",
            description: "Spray shower walls after use to prevent soap scum",
            duration: "30 secs",
            category: "Bathroom"
        )
    ]
}

struct FilterButton: View {
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

struct Chore: Identifiable {
    let id = UUID()
    let title: String
    let assignedTo: String
    let dueTime: String
    var isCompleted: Bool
    let points: Int
    let icon: String
}

struct ChoreCard: View {
    let chore: Chore
    @State private var isCompleted: Bool
    
    init(chore: Chore) {
        self.chore = chore
        _isCompleted = State(initialValue: chore.isCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: chore.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.title)
                    .font(.headline)
                HStack {
                    Label(chore.assignedTo, systemImage: "person.fill")
                    Spacer()
                    Label(chore.dueTime, systemImage: "clock.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("\(chore.points)pts")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Button(action: { isCompleted.toggle() }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CleaningTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let category: String
}

struct CleaningTipCard: View {
    let tip: CleaningTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tip.title)
                    .font(.headline)
                Spacer()
                Text(tip.category)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Label(tip.duration, systemImage: "clock")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddChoreView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Chore Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Chore")
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

struct VoiceRemindersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Voice Reminders")
                    .font(.headline)
                Text("Set reminders for chores using voice commands")
                    .foregroundColor(.secondary)
                
                Button(action: {}) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
                .padding()
            }
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

struct CleaningTipsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("All Cleaning Tips")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Cleaning Tips")
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

struct HouseholdChoresView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HouseholdChoresView()
        }
    }
} 