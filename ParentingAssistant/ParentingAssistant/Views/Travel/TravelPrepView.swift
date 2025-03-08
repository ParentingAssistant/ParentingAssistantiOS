import SwiftUI

struct TravelPrepView: View {
    @State private var selectedTrip = "Beach Vacation"
    @State private var showingTripForm = false
    @State private var showingItineraryPlanner = false
    @State private var selectedCategory = "All"
    @State private var weather = "Sunny, 75°F"
    @State private var location = "Miami, FL"
    @State private var tripDuration = "7 days"
    
    let categories = ["All", "Essentials", "Clothes", "Activities", "Health"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Trip Details Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedTrip)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("\(location) • \(tripDuration)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showingTripForm = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Weather Info
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                        Text(weather)
                            .font(.subheadline)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Packing List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Packing List")
                            .font(.headline)
                        Spacer()
                        Menu("Filter") {
                            ForEach(categories, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category)
                                }
                            }
                        }
                    }
                    
                    ForEach(packingItems.filter {
                        selectedCategory == "All" || $0.category == selectedCategory
                    }) { item in
                        PackingItemRow(item: item)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Itinerary Planning
                VStack(spacing: 16) {
                    HStack {
                        Text("Travel Itinerary")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingItineraryPlanner = true }) {
                            Label("Plan", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ForEach(itineraryItems) { item in
                        ItineraryItemCard(item: item)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Emergency Tips
                VStack(alignment: .leading, spacing: 16) {
                    Text("Emergency Preparation")
                        .font(.headline)
                    
                    ForEach(emergencyTips) { tip in
                        EmergencyTipCard(tip: tip)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Travel Prep")
        .sheet(isPresented: $showingTripForm) {
            TripDetailsForm()
        }
        .sheet(isPresented: $showingItineraryPlanner) {
            ItineraryPlannerView()
        }
    }
    
    let packingItems = [
        PackingItem(
            title: "Travel Documents",
            category: "Essentials",
            quantity: 1,
            isChecked: false,
            note: "Passports, IDs, insurance cards"
        ),
        PackingItem(
            title: "First Aid Kit",
            category: "Health",
            quantity: 1,
            isChecked: false,
            note: "Include any prescription medications"
        ),
        PackingItem(
            title: "Swimsuits",
            category: "Clothes",
            quantity: 2,
            isChecked: false,
            note: "Per person"
        ),
        PackingItem(
            title: "Beach Toys",
            category: "Activities",
            quantity: 1,
            isChecked: false,
            note: "Buckets, shovels, floaties"
        )
    ]
    
    let itineraryItems = [
        ItineraryItem(
            day: "Day 1",
            activities: [
                "10:00 AM - Beach arrival",
                "1:00 PM - Lunch at seaside café",
                "4:00 PM - Pool time"
            ],
            type: "Beach Day"
        ),
        ItineraryItem(
            day: "Day 2",
            activities: [
                "9:00 AM - Aquarium visit",
                "12:30 PM - Picnic lunch",
                "2:00 PM - Marine show"
            ],
            type: "Attraction"
        )
    ]
    
    let emergencyTips = [
        EmergencyTip(
            title: "Local Emergency Contacts",
            description: "Save local emergency numbers and nearest hospital address",
            icon: "phone.fill"
        ),
        EmergencyTip(
            title: "Weather Alerts",
            description: "Enable notifications for severe weather warnings",
            icon: "cloud.bolt.fill"
        ),
        EmergencyTip(
            title: "Meeting Point",
            description: "Establish a family meeting point in case of separation",
            icon: "map.fill"
        )
    ]
}

struct PackingItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let quantity: Int
    var isChecked: Bool
    let note: String
}

struct PackingItemRow: View {
    let item: PackingItem
    @State private var isChecked: Bool
    
    init(item: PackingItem) {
        self.item = item
        _isChecked = State(initialValue: item.isChecked)
    }
    
    var body: some View {
        HStack {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("x\(item.quantity)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ItineraryItem: Identifiable {
    let id = UUID()
    let day: String
    let activities: [String]
    let type: String
}

struct ItineraryItemCard: View {
    let item: ItineraryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.day)
                    .font(.headline)
                Spacer()
                Text(item.type)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            ForEach(item.activities, id: \.self) { activity in
                Text(activity)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmergencyTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct EmergencyTipCard: View {
    let tip: EmergencyTip
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: tip.icon)
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TripDetailsForm: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Trip Details Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Trip Details")
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

struct ItineraryPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Itinerary Planner Form")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Plan Itinerary")
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

struct TravelPrepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TravelPrepView()
        }
    }
} 