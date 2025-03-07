import SwiftUI

struct MealPlanningView: View {
    @StateObject private var mealService = MealPlanningService.shared
    @State private var selectedDate = Date()
    @State private var showingMealDetail = false
    @State private var selectedMeal: Meal?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date Selector
                DatePicker("Select Date",
                          selection: $selectedDate,
                          displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Meals List
                LazyVStack(spacing: 16) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        VStack(alignment: .leading, spacing: 12) {
                            // Section Header
                            HStack {
                                Image(systemName: mealType.icon)
                                    .foregroundColor(Color(hex: mealType.color))
                                Text(mealType.rawValue)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)
                            
                            // Meal Cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(mealService.meals.filter { $0.type == mealType }) { meal in
                                        MealCard(meal: meal)
                                            .onTapGesture {
                                                selectedMeal = meal
                                                showingMealDetail = true
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // Generate New Plan Button
                Button(action: { Task { await mealService.generateNewPlan() } }) {
                    HStack {
                        if mealService.isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "wand.and.stars")
                            Text("Generate New Plan")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .disabled(mealService.isGenerating)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .navigationTitle("Meal Plan")
        .sheet(isPresented: $showingMealDetail) {
            if let meal = selectedMeal {
                MealDetailView(meal: meal)
            }
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NavigationView {
        MealPlanningView()
    }
} 