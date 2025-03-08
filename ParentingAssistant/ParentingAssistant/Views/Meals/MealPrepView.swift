import SwiftUI

struct MealPrepView: View {
    @State private var selectedDay = Date()
    @State private var showingRecipeDetail = false
    @State private var selectedRecipe: Recipe?
    @State private var showingAddGroceryItem = false
    @State private var showingVoiceAssistant = false
    @State private var selectedMealType = "All"
    
    let mealTypes = ["All", "Breakfast", "Lunch", "Dinner", "Snacks"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date Selector
                DatePicker(
                    "Select Week",
                    selection: $selectedDay,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Meal Type Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(mealTypes, id: \.self) { type in
                            MealTypeButton(
                                title: type,
                                isSelected: type == selectedMealType
                            ) {
                                withAnimation {
                                    selectedMealType = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Weekly Meal Plan
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Weekly Meal Plan")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingVoiceAssistant = true }) {
                            Image(systemName: "mic.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(weeklyMeals) { day in
                        if selectedMealType == "All" || day.mealType == selectedMealType {
                            DayMealCard(day: day) { recipe in
                                selectedRecipe = recipe
                                showingRecipeDetail = true
                            }
                        }
                    }
                }
                
                // Grocery List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Grocery List")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingAddGroceryItem = true }) {
                            Label("Add Item", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ForEach(groceryCategories) { category in
                        GroceryCategoryCard(category: category)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Meal Prep")
        .sheet(isPresented: $showingRecipeDetail) {
            if let recipe = selectedRecipe {
                RecipeDetailView(recipe: recipe)
            }
        }
        .sheet(isPresented: $showingAddGroceryItem) {
            AddGroceryItemView()
        }
        .sheet(isPresented: $showingVoiceAssistant) {
            VoiceAssistantView()
        }
    }
    
    let weeklyMeals = [
        DayMeal(
            date: "Monday",
            mealType: "Breakfast",
            recipes: [
                Recipe(
                    title: "Rainbow Pancakes",
                    description: "Colorful, fluffy pancakes with fruit toppings",
                    prepTime: "20 mins",
                    difficulty: "Easy",
                    ingredients: ["Flour", "Eggs", "Milk", "Food coloring"],
                    imageSystemName: "fork.knife.circle.fill"
                )
            ]
        ),
        DayMeal(
            date: "Monday",
            mealType: "Lunch",
            recipes: [
                Recipe(
                    title: "Bento Box",
                    description: "Fun-shaped sandwiches with veggie sides",
                    prepTime: "15 mins",
                    difficulty: "Easy",
                    ingredients: ["Bread", "Turkey", "Cheese", "Vegetables"],
                    imageSystemName: "takeoutbag.and.cup.and.straw.fill"
                )
            ]
        ),
        DayMeal(
            date: "Monday",
            mealType: "Dinner",
            recipes: [
                Recipe(
                    title: "Mini Pizza Station",
                    description: "Create your own personal pizzas",
                    prepTime: "30 mins",
                    difficulty: "Medium",
                    ingredients: ["Pizza dough", "Sauce", "Cheese", "Toppings"],
                    imageSystemName: "circle.grid.2x2.fill"
                )
            ]
        )
    ]
    
    let groceryCategories = [
        GroceryCategory(
            name: "Produce",
            items: [
                GroceryItem(name: "Bananas", quantity: "1 bunch", isChecked: false),
                GroceryItem(name: "Carrots", quantity: "1 lb", isChecked: true),
                GroceryItem(name: "Spinach", quantity: "2 bags", isChecked: false)
            ]
        ),
        GroceryCategory(
            name: "Dairy",
            items: [
                GroceryItem(name: "Milk", quantity: "1 gallon", isChecked: false),
                GroceryItem(name: "Cheese", quantity: "8 oz", isChecked: false),
                GroceryItem(name: "Yogurt", quantity: "6 pack", isChecked: true)
            ]
        )
    ]
}

struct MealTypeButton: View {
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

struct DayMeal: Identifiable {
    let id = UUID()
    let date: String
    let mealType: String
    let recipes: [Recipe]
}

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let prepTime: String
    let difficulty: String
    let ingredients: [String]
    let imageSystemName: String
}

struct DayMealCard: View {
    let day: DayMeal
    let onRecipeSelect: (Recipe) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day.date)
                    .font(.headline)
                Spacer()
                Text(day.mealType)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            ForEach(day.recipes) { recipe in
                Button(action: { onRecipeSelect(recipe) }) {
                    RecipeRow(recipe: recipe)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: recipe.imageSystemName)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                HStack {
                    Label(recipe.prepTime, systemImage: "clock")
                    Spacer()
                    Label(recipe.difficulty, systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct GroceryCategory: Identifiable {
    let id = UUID()
    let name: String
    let items: [GroceryItem]
}

struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: String
    var isChecked: Bool
}

struct GroceryCategoryCard: View {
    let category: GroceryCategory
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() }}) {
                HStack {
                    Text(category.name)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            
            if isExpanded {
                ForEach(category.items) { item in
                    GroceryItemRow(item: item)
                }
            }
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    @State private var isChecked: Bool
    
    init(item: GroceryItem) {
        self.item = item
        _isChecked = State(initialValue: item.isChecked)
    }
    
    var body: some View {
        HStack {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .gray)
            }
            
            Text(item.name)
                .font(.subheadline)
            
            Spacer()
            
            Text(item.quantity)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recipe Image
                    Image(systemName: recipe.imageSystemName)
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.blue.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Recipe Info
                        Text(recipe.description)
                            .font(.body)
                        
                        // Stats
                        HStack {
                            StatCard(title: "Prep Time", value: recipe.prepTime)
                            StatCard(title: "Difficulty", value: recipe.difficulty)
                        }
                        
                        // Ingredients
                        Text("Ingredients")
                            .font(.headline)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Label(ingredient, systemImage: "circle.fill")
                                .font(.subheadline)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(recipe.title)
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

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddGroceryItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Grocery Item Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Item")
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

struct VoiceAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Voice Assistant")
                    .font(.headline)
                Text("Ask me about recipes or cooking instructions!")
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

struct MealPrepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealPrepView()
        }
    }
} 
