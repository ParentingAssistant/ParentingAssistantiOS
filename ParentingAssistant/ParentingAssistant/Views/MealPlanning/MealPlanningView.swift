import SwiftUI
import FirebaseFirestore

struct MealPlanningView: View {
    @StateObject private var mealService = MealPlanningService.shared
    @State private var selectedDate = Date()
    @State private var showingMealDetail = false
    @State private var selectedMeal: Meal?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                DateSelectorView(selectedDate: $selectedDate)
                
                if mealService.isLoading {
                    loadingView
                } else if mealService.meals.isEmpty {
                    EmptyStateView()
                } else {
                    MealsListView(
                        meals: mealService.meals,
                        selectedMeal: $selectedMeal,
                        showingMealDetail: $showingMealDetail
                    )
                }
                
                GenerateButton(
                    isGenerating: mealService.isGenerating,
                    action: {
                        Task {
                            await mealService.generateNewPlan(for: selectedDate)
                        }
                    }
                )
            }
            .padding(.vertical)
        }
        .navigationTitle("Meal Plan")
        .sheet(isPresented: $showingMealDetail) {
            if let meal = selectedMeal {
                MealDetailView(meal: meal)
            }
        }
        .onAppear {
            Task {
                await mealService.loadMeals(for: selectedDate)
            }
        }
        .onChange(of: selectedDate) { _, newDate in
            Task {
                await mealService.loadMeals(for: newDate)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
            Text("Loading meals...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Supporting Views
private struct DateSelectorView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker("Select Date",
                  selection: $selectedDate,
                  displayedComponents: [.date])
        .datePickerStyle(.graphical)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No meals planned for this date")
                .font(.headline)
            Text("Generate a new plan to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct MealsListView: View {
    let meals: [Meal]
    @Binding var selectedMeal: Meal?
    @Binding var showingMealDetail: Bool
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { type in
                let mealsForType = meals.filter { $0.type == type }
                MealTypeSection(
                    type: type,
                    meals: mealsForType,
                    selectedMeal: $selectedMeal,
                    showingMealDetail: $showingMealDetail
                )
            }
        }
    }
}

private struct MealTypeSection: View {
    let type: MealType
    let meals: [Meal]
    @Binding var selectedMeal: Meal?
    @Binding var showingMealDetail: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            if meals.isEmpty {
                Text("No \(type.rawValue.lowercased()) planned")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                mealsList
            }
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Image(systemName: type.icon)
                .foregroundStyle(Color(hex: type.color))
            Text(type.rawValue)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
    }
    
    private var mealsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(meals) { meal in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meal.name)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text("\(meal.ingredients.count) ingredients")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 160, height: 100)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedMeal = meal
                        showingMealDetail = true
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct GenerateButton: View {
    let isGenerating: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "wand.and.stars")
                    Text("Generate New Plan")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isGenerating ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .disabled(isGenerating)
        .padding(.horizontal)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview Provider
#Preview {
    NavigationView {
        MealPlanningView()
    }
}
