import SwiftUI

struct BedtimeStoryView: View {
    @StateObject private var storyService = StoryGenerationService.shared
    @State private var childName = ""
    @State private var selectedTheme: StoryTheme = .fairyTale
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Child Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Child's Name")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter child's name", text: $childName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isNameFieldFocused)
                }
                .padding(.horizontal)
                
                // Theme Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a Theme")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(StoryTheme.allCases, id: \.self) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isSelected: theme == selectedTheme
                                )
                                .onTapGesture {
                                    selectedTheme = theme
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Generate Button
                Button(action: {
                    isNameFieldFocused = false
                    Task {
                        await storyService.generateStory(
                            childName: childName.isEmpty ? "Little One" : childName,
                            theme: selectedTheme
                        )
                    }
                }) {
                    HStack {
                        if storyService.isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "wand.and.stars")
                            Text("Generate Story")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .disabled(storyService.isGenerating)
                .padding(.horizontal)
                
                // Generated Story
                if let story = storyService.generatedStory {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Story")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(story)
                            .font(.body)
                            .lineSpacing(8)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                }
                
                if let error = storyService.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Bedtime Story")
        .background(Color(.systemGroupedBackground))
    }
}

struct ThemeCard: View {
    let theme: StoryTheme
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: theme.icon)
                .font(.title)
                .foregroundColor(isSelected ? .white : .blue)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Text(theme.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(width: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationView {
        BedtimeStoryView()
    }
} 