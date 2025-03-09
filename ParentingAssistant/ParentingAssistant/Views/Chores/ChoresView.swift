import SwiftUI

// Import the AddChoreView
@_spi(AddChoreView) import ParentingAssistant

struct ChoresView: View {
    @StateObject private var choreService = ChoreService.shared
    @State private var showingAddChore = false
    @State private var selectedCategory: ChoreCategory = .other

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ChoreCategory.allCases, id: \.self) { category in
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
                
                // Chores List
                LazyVStack(spacing: 16) {
                    ForEach(choreService.chores.filter {
                        selectedCategory == .other ? true : $0.category == selectedCategory
                    }) { chore in
                        ChoreRow(chore: chore) { chore in
                            choreService.toggleChore(chore)
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
                Button {
                    showingAddChore = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAddChore) {
            AddChoreView(category: selectedCategory)
        }
    }
}

struct CategoryButton: View {
    let category: ChoreCategory
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

struct ChoreRow: View {
    let chore: ChoreTask
    let onToggle: (ChoreTask) -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: { onToggle(chore) }) {
                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(chore.isCompleted ? Color(hex: chore.category.color) : .gray)
            }
            
            // Chore Details
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.title)
                    .font(.headline)
                    .strikethrough(chore.isCompleted)
                
                if let description = chore.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let assignedTo = chore.assignedTo {
                    Text("Assigned to: \(assignedTo)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Category Icon
            Image(systemName: chore.category.icon)
                .foregroundColor(Color(hex: chore.category.color))
                .font(.title3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        ChoresView()
    }
} 
