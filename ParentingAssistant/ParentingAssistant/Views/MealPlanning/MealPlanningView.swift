import SwiftUI

struct MealPlanningView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    @State private var showingPreferences = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar View
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            
            // Meals List
            List {
                Section("Breakfast") {
                    ForEach(0..<2) { _ in
                        MealRow(mealType: .breakfast)
                    }
                }
                
                Section("Lunch") {
                    ForEach(0..<2) { _ in
                        MealRow(mealType: .lunch)
                    }
                }
                
                Section("Dinner") {
                    ForEach(0..<2) { _ in
                        MealRow(mealType: .dinner)
                    }
                }
                
                Section("Snacks") {
                    ForEach(0..<2) { _ in
                        MealRow(mealType: .snack)
                    }
                }
            }
        }
        .navigationTitle("Meal Planning")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Label("Add Meal", systemImage: "plus")
                    }
                    
                    Button {
                        showingPreferences = true
                    } label: {
                        Label("Preferences", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddMeal) {
            AddMealView()
        }
        .sheet(isPresented: $showingPreferences) {
            MealPreferencesView()
        }
    }
}

struct MealRow: View {
    let mealType: MealType
    @State private var showingDetails = false
    
    var body: some View {
        Button {
            showingDetails = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sample Meal")
                        .font(.headline)
                    Text("Calories: 500 • Prep: 30 min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingDetails) {
            MealDetailView()
        }
    }
}

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }
}

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mealName = ""
    @State private var calories = ""
    @State private var prepTime = ""
    @State private var selectedType: MealType = .breakfast
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Meal Name", text: $mealName)
                    
                    Picker("Meal Type", selection: $selectedType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Prep Time (minutes)", text: $prepTime)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Add Meal") {
                        // TODO: Implement meal addition
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MealDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sample Meal")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("500 calories", systemImage: "flame.fill")
                            Spacer()
                            Label("30 min prep", systemImage: "clock.fill")
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Ingredients") {
                    ForEach(0..<5) { _ in
                        Text("• Ingredient")
                    }
                }
                
                Section("Instructions") {
                    ForEach(0..<3) { index in
                        Text("\(index + 1). Step description")
                    }
                }
            }
            .navigationTitle("Meal Details")
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

struct MealPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dietary Restrictions") {
                    ForEach(["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free"], id: \.self) { restriction in
                        Toggle(restriction, isOn: .constant(false))
                    }
                }
                
                Section("Cuisine Types") {
                    ForEach(["Italian", "Mexican", "Chinese", "Indian", "Mediterranean"], id: \.self) { cuisine in
                        Toggle(cuisine, isOn: .constant(false))
                    }
                }
                
                Section("Cooking Difficulty") {
                    Picker("Difficulty", selection: .constant(CookingDifficulty.easy)) {
                        ForEach(CookingDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue.capitalized)
                                .tag(difficulty)
                        }
                    }
                }
                
                Section("Serving Size") {
                    Stepper("Serves \(authService.currentUser?.preferences.mealPreferences.servingSize ?? 4)", value: .constant(4), in: 1...8)
                }
            }
            .navigationTitle("Meal Preferences")
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

#Preview {
    NavigationStack {
        MealPlanningView()
    }
} 