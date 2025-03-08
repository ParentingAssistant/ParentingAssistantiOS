import SwiftUI

struct HealthTrackingView: View {
    @State private var selectedChild = "Child 1"
    @State private var selectedTab = "Growth"
    @State private var showingAddRecord = false
    
    let children = ["Child 1", "Child 2", "Child 3"]
    let tabs = ["Growth", "Vaccines", "Checkups", "Activities"]
    
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
                
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(tabs, id: \.self) { tab in
                            TabButton(
                                title: tab,
                                isSelected: selectedTab == tab
                            ) {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Content based on selected tab
                switch selectedTab {
                case "Growth":
                    GrowthSection()
                case "Vaccines":
                    VaccineSection()
                case "Checkups":
                    CheckupSection()
                case "Activities":
                    ActivitySection()
                default:
                    EmptyView()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Health & Growth")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddRecord = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            AddHealthRecordView(selectedTab: selectedTab)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct GrowthSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Height & Weight Chart Placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    Text("Growth Chart")
                        .foregroundColor(.secondary)
                )
            
            // Recent Measurements
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Measurements")
                    .font(.headline)
                
                ForEach(["Height: 105 cm (March 15)", "Weight: 18 kg (March 15)"], id: \.self) { measurement in
                    HStack {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(.blue)
                        Text(measurement)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

struct VaccineSection: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(["MMR Vaccine", "DTaP Vaccine", "Flu Shot"], id: \.self) { vaccine in
                VaccineCard(
                    name: vaccine,
                    date: "March 20, 2024",
                    status: vaccine == "Flu Shot" ? "Due" : "Completed"
                )
            }
        }
        .padding(.horizontal)
    }
}

struct VaccineCard: View {
    let name: String
    let date: String
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: status == "Completed" ? "checkmark.circle.fill" : "clock.fill")
                .foregroundColor(status == "Completed" ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .padding(6)
                .background(status == "Completed" ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                .foregroundColor(status == "Completed" ? .green : .orange)
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CheckupSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Upcoming Appointments
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming Appointments")
                    .font(.headline)
                
                ForEach(["Annual Checkup - Apr 15", "Dental Visit - May 1"], id: \.self) { appointment in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(appointment)
                        Spacer()
                        Button("Reschedule") {
                            // Reschedule action
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            // Past Visits
            VStack(alignment: .leading, spacing: 12) {
                Text("Past Visits")
                    .font(.headline)
                
                ForEach(["Regular Checkup - Feb 1", "Eye Exam - Jan 15"], id: \.self) { visit in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(visit)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct ActivitySection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Activity Stats
            HStack {
                ActivityStatCard(title: "Steps", value: "5,234", icon: "figure.walk")
                ActivityStatCard(title: "Active Time", value: "45 min", icon: "flame.fill")
            }
            
            // Recent Activities
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Activities")
                    .font(.headline)
                
                ForEach(["Swimming - 30 min", "Park Play - 45 min", "Cycling - 20 min"], id: \.self) { activity in
                    HStack {
                        Image(systemName: "figure.run")
                            .foregroundColor(.blue)
                        Text(activity)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct ActivityStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddHealthRecordView: View {
    let selectedTab: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Placeholder for add record form
                Text("Add new \(selectedTab.lowercased()) record")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Record")
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

struct HealthTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthTrackingView()
        }
    }
} 