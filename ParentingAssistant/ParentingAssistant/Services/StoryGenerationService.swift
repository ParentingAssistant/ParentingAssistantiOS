import SwiftUI
import Foundation

@MainActor
class StoryGenerationService: ObservableObject {
    static let shared = StoryGenerationService()
    
    @Published var isGenerating = false
    @Published var generatedStory: String?
    @Published var error: String?
    
    private init() {}
    
    func generateStory(childName: String, theme: StoryTheme) {
        isGenerating = true
        generatedStory = nil
        error = nil
        
        // Simulate a delay for story generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            // Generate a simple placeholder story based on the theme
            let story = """
            Once upon a time, there was a wonderful child named \(childName). 
            
            \(self.getThemeIntro(theme: theme, childName: childName))
            
            And so, \(childName)'s amazing adventure came to an end, but the memories would last forever.
            
            The End 🌟
            """
            
            self.generatedStory = story
            self.isGenerating = false
        }
    }
    
    private func getThemeIntro(theme: StoryTheme, childName: String) -> String {
        switch theme {
        case .fairyTale:
            return "One magical day, \(childName) discovered a hidden castle in the clouds, where friendly fairies welcomed them with sparkling fairy dust and warm smiles."
        case .adventure:
            return "With a trusty backpack and a map in hand, \(childName) set out on an exciting journey through mysterious caves and ancient ruins."
        case .fantasy:
            return "While exploring the enchanted forest, \(childName) befriended a young dragon who could change colors like a rainbow."
        case .space:
            return "Aboard their shiny spaceship, \(childName) zoomed past twinkling stars and colorful planets, making friends with friendly aliens along the way."
        case .animals:
            return "Deep in the friendly forest, \(childName) met a group of talking animals who loved to play games and share delicious forest treats."
        case .nature:
            return "During a walk in the enchanted garden, \(childName) discovered that they could talk to flowers and trees, learning their fascinating secrets."
        case .superheroes:
            return "\(childName) woke up one morning to discover they had amazing superpowers! They could fly through the clouds and help people in need."
        case .science:
            return "In their magical laboratory, \(childName) conducted wonderful experiments that made rainbow bubbles and glowing potions."
        }
    }
} 