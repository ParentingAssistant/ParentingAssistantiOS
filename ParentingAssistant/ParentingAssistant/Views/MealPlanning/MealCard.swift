import SwiftUI

struct MealCard: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image or Placeholder
            ZStack {
                if let imageURL = meal.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 200, height: 150)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(meal.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(meal.calories) cal", systemImage: "flame.fill")
                    Spacer()
                    Label("\(meal.prepTime) min", systemImage: "clock.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 