import SwiftUI

struct SavedStoriesView: View {
    @StateObject private var storyService = StoryService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStory: Story?
    @State private var showingStoryDetail = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(storyService.savedStories.sorted(by: { $0.createdAt > $1.createdAt })) { story in
                    SavedStoryRow(story: story)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedStory = story
                            showingStoryDetail = true
                        }
                }
                .onDelete { indexSet in
                    let stories = storyService.savedStories.sorted(by: { $0.createdAt > $1.createdAt })
                    indexSet.forEach { index in
                        storyService.deleteStory(stories[index])
                    }
                }
            }
            .navigationTitle("Saved Stories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingStoryDetail, content: {
                if let story = selectedStory {
                    SavedStoryDetailView(story: story)
                }
            })
        }
    }
}

struct SavedStoryRow: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(story.title)
                .font(.headline)
            
            HStack {
                Label(story.childName, systemImage: "person")
                Spacer()
                Label(story.theme, systemImage: "tag")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text(story.createdAt, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SavedStoryDetailView: View {
    let story: Story
    @StateObject private var storyService = StoryService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Story metadata
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(story.childName, systemImage: "person")
                            Spacer()
                            Label(story.theme, systemImage: "tag")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text(story.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Story content
                    Text(story.content)
                        .font(.body)
                        .lineSpacing(8)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // Read controls
                    HStack {
                        Button(action: {
                            if storyService.isReading {
                                storyService.stopReading()
                            } else {
                                storyService.readStory(story.content) {}
                            }
                        }) {
                            Label(
                                storyService.isReading ? "Stop Reading" : "Read Aloud",
                                systemImage: storyService.isReading ? "stop.fill" : "play.fill"
                            )
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle(story.title)
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