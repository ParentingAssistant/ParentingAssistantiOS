import SwiftUI

struct MealDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let meal: Meal
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image
                    if let imageURL = meal.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Type
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(Color(hex: meal.type.color))
                                .fontWeight(.semibold)
                            
                            Text(meal.title)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        // Quick Info
                        HStack(spacing: 16) {
                            Label("\(meal.calories) cal", systemImage: "flame.fill")
                            Label("\(meal.prepTime) min", systemImage: "clock.fill")
                            Label("\(meal.servings) servings", systemImage: "person.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        // Description
                        Text(meal.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Dietary Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(meal.dietaryTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.headline)
                            
                            ForEach(meal.ingredients, id: \.self) { ingredient in
                                Label(ingredient, systemImage: "circle.fill")
                                    .font(.subheadline)
                            }
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                            
                            ForEach(Array(meal.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1).")
                                        .fontWeight(.semibold)
                                    Text(instruction)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                }
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

#Preview {
    MealDetailView(meal: Meal(
        id: "1",
        title: "Overnight Oats with Berries",
        description: "Healthy and delicious breakfast with fresh berries and honey",
        imageURL: nil,
        type: .breakfast,
        calories: 350,
        prepTime: 10,
        servings: 1,
        ingredients: ["Oats", "Milk", "Berries", "Honey"],
        instructions: ["Mix oats and milk", "Add berries and honey", "Refrigerate overnight"],
        dietaryTags: ["Vegetarian", "High Fiber"]
    ))
} 