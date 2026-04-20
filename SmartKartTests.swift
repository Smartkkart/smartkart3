import Testing
@testable import SmartKart

struct SmartKartTests {
    @MainActor
    @Test func optimizeShoppingRouteLowersOrPreservesCost() async throws {
        let appState = AppState()
        let initialTotal = appState.totalListCost

        appState.optimizeShoppingRoute()

        #expect(appState.totalListCost <= initialTotal)
    }

    @MainActor
    @Test func selectedCheapMealPlanHonorsMealCount() async throws {
        let appState = AppState()
        appState.mealsPerWeek = 4
        appState.selectedDiet = .cheap

        #expect(appState.filteredMealPlan.count == 4)
        #expect(appState.cheapestMealPlanTotal > 0)
    }
}
