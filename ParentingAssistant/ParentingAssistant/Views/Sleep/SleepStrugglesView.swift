import SwiftUI

struct SleepStrugglesView: View {
    @State private var selectedChild = "Child 1"
    @State private var isPlayingSound = false
    @State private var selectedSoundType = "Lullaby"
    @State private var selectedTimeRange = "Week"
    @State private var volume: Double = 0.5
    
    let children = ["Child 1", "Child 2", "Child 3"]
    let soundTypes = ["Lullaby", "White Noise", "Nature Sounds"]
    let timeRanges = ["Week", "Month", "3 Months"]
    
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
                
                // Sleep Analytics
                VStack(spacing: 16) {
                    HStack {
                        Text("Sleep Analytics")
                            .font(.headline)
                        Spacer()
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(timeRanges, id: \.self) { range in
                                Text(range).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Sleep Stats
                    HStack(spacing: 20) {
                        SleepStatCard(
                            title: "Average Sleep",
                            value: "8h 30m",
                            trend: "+30m",
                            isPositive: true
                        )
                        SleepStatCard(
                            title: "Sleep Quality",
                            value: "85%",
                            trend: "+5%",
                            isPositive: true
                        )
                    }
                    
                    // Sleep Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sleep Pattern")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        SleepChart()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Sound Controls
                VStack(spacing: 16) {
                    HStack {
                        Text("Sleep Sounds")
                            .font(.headline)
                        Spacer()
                        Picker("Sound Type", selection: $selectedSoundType) {
                            ForEach(soundTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Button(action: { isPlayingSound.toggle() }) {
                        HStack {
                            Image(systemName: isPlayingSound ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title)
                            Text(isPlayingSound ? "Pause" : "Play")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Volume Slider
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "speaker.fill")
                            Slider(value: $volume)
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Sleep Training Tips
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sleep Training Program")
                        .font(.headline)
                    
                    ForEach(sleepTips) { tip in
                        SleepTipCard(tip: tip)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Sleep Support")
    }
    
    let sleepTips = [
        SleepTip(
            title: "Consistent Bedtime",
            description: "Maintain the same sleep schedule, even on weekends",
            phase: "Week 1",
            duration: "7 days"
        ),
        SleepTip(
            title: "Bedtime Routine",
            description: "Create a calming routine: bath, story, quiet time",
            phase: "Week 2",
            duration: "14 days"
        ),
        SleepTip(
            title: "Self-Soothing",
            description: "Help your child learn to fall asleep independently",
            phase: "Week 3",
            duration: "21 days"
        )
    ]
}

struct SleepStatCard: View {
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                Text(trend)
            }
            .font(.caption)
            .foregroundColor(isPositive ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SleepChart: View {
    var body: some View {
        // Placeholder for actual chart implementation
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.3))
                            .frame(height: CGFloat(50 + (index * 10)))
                        
                        Text("D\(index + 1)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
            
            // Time indicators
            HStack {
                Text("8PM")
                Spacer()
                Text("8AM")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
}

struct SleepTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let phase: String
    let duration: String
}

struct SleepTipCard: View {
    let tip: SleepTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tip.title)
                        .font(.headline)
                    Text(tip.phase)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(tip.duration)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SleepStrugglesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SleepStrugglesView()
        }
    }
} 