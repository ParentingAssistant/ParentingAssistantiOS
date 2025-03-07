import SwiftUI
import MapKit

struct RunningErrandsView: View {
    @State private var newItem = ""
    @State private var shoppingList: [ShoppingItem] = []
    @State private var showingDeliveryComparison = false
    @State private var showingAppointmentScheduler = false
    @State private var selectedTab = 0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Shopping List Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Shopping List")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        TextField("Add item", text: $newItem)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                    
                    ForEach(shoppingList) { item in
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)
                            Text(item.name)
                            Spacer()
                            Button(action: { toggleItem(item) }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Delivery Services Section
                Button(action: { showingDeliveryComparison = true }) {
                    HStack {
                        Image(systemName: "car.fill")
                        Text("Compare Delivery Services")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                
                // Appointments Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Upcoming Appointments")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Button(action: { showingAppointmentScheduler = true }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Schedule New Appointment")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    // Placeholder for appointments list
                    ForEach(0..<2) { _ in
                        AppointmentCard()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Route Planning Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Route Planning")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Map(coordinateRegion: $region)
                        .frame(height: 200)
                        .cornerRadius(16)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .padding()
        }
        .navigationTitle("Running Errands")
        .sheet(isPresented: $showingDeliveryComparison) {
            DeliveryComparisonView()
        }
        .sheet(isPresented: $showingAppointmentScheduler) {
            AppointmentSchedulerView()
        }
    }
    
    private func addItem() {
        guard !newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        shoppingList.append(ShoppingItem(name: newItem))
        newItem = ""
    }
    
    private func toggleItem(_ item: ShoppingItem) {
        if let index = shoppingList.firstIndex(where: { $0.id == item.id }) {
            shoppingList[index].isCompleted.toggle()
        }
    }
}

struct ShoppingItem: Identifiable {
    let id = UUID()
    let name: String
    var isCompleted = false
}

struct AppointmentCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Doctor's Appointment")
                .font(.headline)
            Text("Tomorrow at 2:00 PM")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DeliveryComparisonView: View {
    var body: some View {
        NavigationView {
            Text("Delivery Comparison")
                .navigationTitle("Compare Services")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AppointmentSchedulerView: View {
    var body: some View {
        NavigationView {
            Text("Schedule Appointment")
                .navigationTitle("New Appointment")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RunningErrandsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RunningErrandsView()
        }
    }
} 