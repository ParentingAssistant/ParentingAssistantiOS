import Foundation
import AVFoundation

extension Notification.Name {
    static let speechSynthesizerDidFinishUtterance = Notification.Name("speechSynthesizerDidFinishUtterance")
}

class StoryService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = StoryService()
    private let synthesizer = AVSpeechSynthesizer()
    private let defaults = UserDefaults.standard
    private let storiesKey = "saved_stories"
    private var completionHandler: (() -> Void)?
    
    @Published var savedStories: [Story] = []
    @Published var isReading = false
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        loadStories()
    }
    
    func saveStory(_ story: Story) {
        savedStories.append(story)
        saveStoriesToDefaults()
    }
    
    func deleteStory(_ story: Story) {
        savedStories.removeAll { $0.id == story.id }
        saveStoriesToDefaults()
    }
    
    func readStory(_ content: String, completion: @escaping () -> Void) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: content)
        utterance.rate = 0.5 // Slower pace for bedtime stories
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for clarity
        utterance.volume = 1.0
        
        // Use a soothing voice if available
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        completionHandler = completion
        isReading = true
        synthesizer.speak(utterance)
    }
    
    func stopReading() {
        synthesizer.stopSpeaking(at: .immediate)
        isReading = false
        completionHandler = nil
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isReading = false
            self?.completionHandler?()
            self?.completionHandler = nil
            NotificationCenter.default.post(name: .speechSynthesizerDidFinishUtterance, object: nil)
        }
    }
    
    private func loadStories() {
        if let data = defaults.data(forKey: storiesKey),
           let stories = try? JSONDecoder().decode([Story].self, from: data) {
            savedStories = stories
        }
    }
    
    private func saveStoriesToDefaults() {
        if let data = try? JSONEncoder().encode(savedStories) {
            defaults.set(data, forKey: storiesKey)
        }
    }
    
    // Helper function to determine appropriate age group
    func getAgeGroup(for childName: String) -> String {
        // In a real app, this would fetch from a user profile
        // For now, return a default age group
        return "4-8 years"
    }
    
    // Helper function to generate story title
    func generateStoryTitle(theme: String, childName: String) -> String {
        let titles = [
            "\(childName)'s \(theme) Adventure",
            "The Magical \(theme) Journey",
            "A \(theme) Tale for \(childName)",
            "\(childName) Discovers \(theme)",
            "The \(theme) Dream"
        ]
        return titles.randomElement() ?? "\(childName)'s Story"
    }
} 