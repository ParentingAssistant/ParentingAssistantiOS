import SwiftUI

struct MealCard: View {
    let meal: Meal
    
    var body: some View {
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
    }
} 