import SwiftUI

struct EmotionalNeedsView: View {
    @State private var selectedMood: Mood = .neutral
    @State private var selectedChild = "Child 1"
    @State private var moodIntensity: Double = 0.5
    @State private var showingExerciseDetail = false
    @State private var selectedExercise: EmotionalExercise?
    
    let children = ["Child 1", "Child 2", "Child 3"]
    
    enum Mood: String, CaseIterable {
        case veryHappy = "Very Happy"
        case happy = "Happy"
        case neutral = "Neutral"
        case sad = "Sad"
        case angry = "Angry"
        
        var emoji: String {
            switch self {
            case .veryHappy: return "😄"
            case .happy: return "🙂"
            case .neutral: return "😐"
            case .sad: return "😢"
            case .angry: return "😠"
            }
        }
        
        var color: Color {
            switch self {
            case .veryHappy: return .green
            case .happy: return .mint
            case .neutral: return .blue
            case .sad: return .indigo
            case .angry: return .red
            }
        }
    }
    
    let exercises: [EmotionalExercise] = [
        EmotionalExercise(
            title: "Breathing Butterfly",
            description: "A calming breathing exercise",
            category: .relaxation,
            duration: "5 mins",
            ageRange: "4+ years"
        ),
        EmotionalExercise(
            title: "Feelings Journal",
            description: "Express emotions through drawing",
            category: .expression,
            duration: "15 mins",
            ageRange: "5+ years"
        ),
        EmotionalExercise(
            title: "Empathy Stories",
            description: "Interactive stories about understanding others",
            category: .empathy,
            duration: "10 mins",
            ageRange: "6+ years"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Child Selector
                Picker("Select Child", selection: $selectedChild) {
                    ForEach(children, id: \.self) { child in
                        Text(child).tag(child)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Mood Tracker
                VStack(spacing: 16) {
                    Text("How are they feeling?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: mood == selectedMood
                            ) {
                                withAnimation {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text("Intensity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $moodIntensity)
                            .tint(selectedMood.color)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Coaching Tips
                VStack(alignment: .leading, spacing: 16) {
                    Text("Coaching Tips")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(coachingTips, id: \.self) { tip in
                        TipCard(tip: tip)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Emotional Exercises
                VStack(alignment: .leading, spacing: 16) {
                    Text("Social-Emotional Exercises")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(exercises) { exercise in
                        ExerciseCard(exercise: exercise)
                            .onTapGesture {
                                selectedExercise = exercise
                                showingExerciseDetail = true
                            }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Emotional Support")
        .sheet(isPresented: $showingExerciseDetail) {
            if let exercise = selectedExercise {
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
    
    let coachingTips = [
        "Listen actively without judgment",
        "Validate their feelings before problem-solving",
        "Use 'I' statements to model emotional expression",
        "Create a safe space for emotional discussions"
    ]
}

struct MoodButton: View {
    let mood: EmotionalNeedsView.Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                Text(mood.rawValue)
                    .font(.caption)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(isSelected ? mood.color.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? mood.color : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct TipCard: View {
    let tip: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(tip)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmotionalExercise: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: Category
    let duration: String
    let ageRange: String
    
    enum Category: String {
        case relaxation = "Relaxation"
        case expression = "Expression"
        case empathy = "Empathy"
        
        var color: Color {
            switch self {
            case .relaxation: return .blue
            case .expression: return .purple
            case .empathy: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .relaxation: return "wind"
            case .expression: return "pencil.and.paper"
            case .empathy: return "heart.fill"
            }
        }
    }
}

struct ExerciseCard: View {
    let exercise: EmotionalExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: exercise.category.icon)
                    .font(.title2)
                    .foregroundColor(exercise.category.color)
                Text(exercise.title)
                    .font(.headline)
                Spacer()
                Text(exercise.category.rawValue)
                    .font(.caption)
                    .padding(6)
                    .background(exercise.category.color.opacity(0.1))
                    .foregroundColor(exercise.category.color)
                    .cornerRadius(8)
            }
            
            Text(exercise.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(exercise.duration, systemImage: "clock.fill")
                Spacer()
                Label(exercise.ageRange, systemImage: "person.2.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: EmotionalExercise
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(exercise.description)
                        .font(.body)
                    
                    Text("Instructions coming soon...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle(exercise.title)
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

struct EmotionalNeedsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmotionalNeedsView()
        }
    }
} 