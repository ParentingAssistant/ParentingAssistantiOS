import SwiftUI

struct BedtimeStoryView: View {
    @StateObject private var storyService = StoryService.shared
    @State private var selectedChild = "Child 1"
    @State private var selectedTheme = "Adventure"
    @State private var customPrompt = ""
    @State private var generatedStory = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingSavedStories = false
    @State private var showingThemeInfo = false
    @State private var selectedThemeInfo: ThemeInfo?
    
    let children = ["Child 1", "Child 2", "Child 3"]
    let themes: [ThemeInfo] = [
        ThemeInfo(name: "Adventure", description: "Exciting journeys and discoveries", icon: "map"),
        ThemeInfo(name: "Fantasy", description: "Magic and wonder", icon: "wand.and.stars"),
        ThemeInfo(name: "Animals", description: "Stories about furry friends", icon: "pawprint"),
        ThemeInfo(name: "Space", description: "Cosmic exploration", icon: "star.fill"),
        ThemeInfo(name: "Ocean", description: "Underwater adventures", icon: "water.waves"),
        ThemeInfo(name: "Nature", description: "Outdoor discoveries", icon: "leaf"),
        ThemeInfo(name: "Friendship", description: "Tales of companionship", icon: "heart"),
        ThemeInfo(name: "Magic", description: "Enchanting stories", icon: "sparkles")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Child Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Child")
                        .font(.headline)
                    Picker("Select Child", selection: $selectedChild) {
                        ForEach(children, id: \.self) { child in
                            Text(child).tag(child)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                // Theme Selector
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Story Theme")
                            .font(.headline)
                        Spacer()
                        Button("Saved Stories") {
                            showingSavedStories = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themes, id: \.name) { theme in
                                ThemeButton(
                                    title: theme.name,
                                    icon: theme.icon,
                                    isSelected: theme.name == selectedTheme
                                ) {
                                    selectedTheme = theme.name
                                    selectedThemeInfo = theme
                                    showingThemeInfo = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Custom Prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Details (Optional)")
                        .font(.headline)
                    TextEditor(text: $customPrompt)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Generate Button
                Button(action: generateStory) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isGenerating ? "Creating Story..." : "Generate Story")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isGenerating)
                .padding(.horizontal)
                
                // Generated Story
                if !generatedStory.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Story")
                            .font(.headline)
                        
                        Text(generatedStory)
                            .font(.body)
                            .lineSpacing(8)
                        
                        // Story Controls
                        HStack {
                            Button(action: {
                                if storyService.isReading {
                                    storyService.stopReading()
                                } else {
                                    storyService.readStory(generatedStory) {}
                                }
                            }) {
                                Label(
                                    storyService.isReading ? "Stop Reading" : "Read Aloud",
                                    systemImage: storyService.isReading ? "stop.fill" : "speaker.wave.2.fill"
                                )
                            }
                            Spacer()
                            Button(action: saveCurrentStory) {
                                Label("Save", systemImage: "bookmark.fill")
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Bedtime Stories")
        .sheet(isPresented: $showingSavedStories) {
            SavedStoriesView()
        }
        .alert("Theme Info", isPresented: $showingThemeInfo, presenting: selectedThemeInfo) { _ in
            Button("OK", role: .cancel) {}
        } message: { theme in
            Text(theme.description)
        }
        .alert("Error", isPresented: $showingError, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error)
        }
    }
    
    private func generateStory() {
        isGenerating = true
        errorMessage = nil
        
        let ageGroup = storyService.getAgeGroup(for: selectedChild)
        
        OpenAIService.shared.generateStory(
            prompt: customPrompt,
            ageGroup: ageGroup,
            theme: selectedTheme
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                
                switch result {
                case .success(let story):
                    generatedStory = story
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func saveCurrentStory() {
        let story = Story(
            title: storyService.generateStoryTitle(theme: selectedTheme, childName: selectedChild),
            content: generatedStory,
            theme: selectedTheme,
            childName: selectedChild,
            ageGroup: storyService.getAgeGroup(for: selectedChild)
        )
        storyService.saveStory(story)
    }
}

struct ThemeInfo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
}

struct ThemeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .foregroundColor(isSelected ? .white : .blue)
            .cornerRadius(12)
        }
    }
}

struct BedtimeStoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BedtimeStoryView()
        }
    }
} 