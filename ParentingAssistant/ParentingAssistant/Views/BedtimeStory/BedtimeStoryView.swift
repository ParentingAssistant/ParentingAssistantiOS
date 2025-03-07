import SwiftUI

struct BedtimeStoryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: StoryCategory = .all
    @State private var showingFilters = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search stories...", text: $searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            
            // Category Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(StoryCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Stories Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(0..<10) { _ in
                        StoryCard()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Bedtime Stories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            StoryFiltersView()
        }
    }
}

struct CategoryButton: View {
    let category: StoryCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct StoryCard: View {
    @State private var showingDetails = false
    
    var body: some View {
        Button {
            showingDetails = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Story Image
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    )
                    .cornerRadius(12)
                
                // Story Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Story Title")
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("5-10 min read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
        }
        .sheet(isPresented: $showingDetails) {
            StoryDetailView()
        }
    }
}

enum StoryCategory: String, CaseIterable {
    case all = "All"
    case adventure = "Adventure"
    case fantasy = "Fantasy"
    case animals = "Animals"
    case bedtime = "Bedtime"
    case educational = "Educational"
}

struct StoryFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAgeRange = 0
    @State private var selectedDuration = 0
    @State private var includeEducational = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Age Range") {
                    Picker("Age Range", selection: $selectedAgeRange) {
                        Text("2-4 years").tag(0)
                        Text("5-7 years").tag(1)
                        Text("8-10 years").tag(2)
                    }
                }
                
                Section("Duration") {
                    Picker("Duration", selection: $selectedDuration) {
                        Text("5-10 minutes").tag(0)
                        Text("10-15 minutes").tag(1)
                        Text("15+ minutes").tag(2)
                    }
                }
                
                Section {
                    Toggle("Include Educational Content", isOn: $includeEducational)
                }
            }
            .navigationTitle("Filters")
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

struct StoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                // Story Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Story Title")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Once upon a time...")
                            .font(.body)
                        
                        // Sample story content
                        ForEach(0..<5) { _ in
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                                .font(.body)
                        }
                    }
                    .padding()
                }
                
                // Navigation Controls
                HStack {
                    Button {
                        if currentPage > 0 {
                            currentPage -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .disabled(currentPage == 0)
                    
                    Spacer()
                    
                    Text("Page \(currentPage + 1) of 5")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button {
                        if currentPage < 4 {
                            currentPage += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                    .disabled(currentPage == 4)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 2)
            }
            .navigationTitle("Story")
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
        BedtimeStoryView()
    }
} 