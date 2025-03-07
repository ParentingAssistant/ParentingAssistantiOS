import SwiftUI

struct MarketplaceView: View {
    @State private var selectedCategory: ProductCategory = .all
    @State private var searchText = ""
    
    enum ProductCategory: String, CaseIterable {
        case all = "All"
        case mealPlanning = "Meal Planning"
        case education = "Education"
        case toys = "Toys"
        case clothing = "Clothing"
        case services = "Services"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .mealPlanning: return "fork.knife"
            case .education: return "book.fill"
            case .toys: return "gift.fill"
            case .clothing: return "tshirt.fill"
            case .services: return "person.2.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            CategoryPill(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: category == selectedCategory
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                
                // Products Grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(0..<10) { _ in
                            ProductCard()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Marketplace")
            .searchable(text: $searchText, prompt: "Search products and services")
        }
    }
}

struct ProductCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Product Name")
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$99.99")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
} 