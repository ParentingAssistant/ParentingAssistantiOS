import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    
    enum SearchCategory: String, CaseIterable {
        case all = "All"
        case meals = "Meals"
        case stories = "Stories"
        case chores = "Chores"
        case routines = "Routines"
        case marketplace = "Products"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .meals: return "fork.knife"
            case .stories: return "book.fill"
            case .chores: return "house.fill"
            case .routines: return "clock.fill"
            case .marketplace: return "cart.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SearchCategory.allCases, id: \.self) { category in
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
                
                // Search Results
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Placeholder content
                        ForEach(0..<10) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .frame(height: 100)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search for meals, stories, chores...")
        }
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
} 