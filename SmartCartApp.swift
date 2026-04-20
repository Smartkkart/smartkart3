import SwiftUI

@main
struct SmartCartApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// Global app state — shared across all screens
class AppState: ObservableObject {
    @Published var savedThisWeek: Double = 143
    @Published var weeklyBudget: Double = 750
    @Published var spent: Double = 438
    @Published var shoppingItems: [ShoppingItem] = ShoppingItem.samples
    @Published var selectedTab: Int = 0

    var budgetRemaining: Double { weeklyBudget - spent }
    var budgetPercent: Double { spent / weeklyBudget }
}
