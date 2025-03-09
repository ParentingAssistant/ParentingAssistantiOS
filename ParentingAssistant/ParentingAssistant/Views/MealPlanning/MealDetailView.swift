import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ingredientsSection
                    instructionsSection
                    nutritionSection
                }
                .padding()
            }
            .navigationTitle(meal.name)
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
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)
            ForEach(meal.ingredients, id: \.self) { ingredient in
                Text("• \(ingredient)")
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.headline)
            Text(meal.instructions)
        }
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nutrition Information")
                .font(.headline)
            Text(meal.nutritionInfo)
        }
    }
} 