import Combine
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

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var searchText = ""
    @Published var selectedProductID: UUID? = DemoData.products.first?.id
    @Published var selectedDiet: DietStyle = .cheap
    @Published var mealsPerWeek = 5
    @Published private(set) var weeklyBudget: Double = 650
    @Published private(set) var spent: Double = 401
    @Published private(set) var savedThisWeek: Double = 143
    @Published private(set) var shoppingItems: [ShoppingListItem] = DemoData.shoppingItems

    let products = DemoData.products
    let stores = DemoData.stores
    let deals = DemoData.deals
    let mealPlan = DemoData.meals
    let spendingByDay = DemoData.spending

    var filteredProducts: [Product] {
        guard !searchText.isEmpty else { return products }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var selectedProduct: Product? {
        let fallbackID = filteredProducts.first?.id
        let currentID = selectedProductID ?? fallbackID
        return products.first(where: { $0.id == currentID })
    }

    var sortedDealsForSelectedProduct: [StoreDeal] {
        guard let selectedProduct else { return [] }
        return deals
            .filter { $0.productID == selectedProduct.id }
            .sorted { $0.price < $1.price }
    }

    var cheapestDeal: StoreDeal? {
        sortedDealsForSelectedProduct.first
    }

    var topDeals: [StoreDeal] {
        Array(
            deals
                .sorted { $0.savings > $1.savings }
                .prefix(3)
        )
    }

    var selectedProductHistory: [PriceHistoryPoint] {
        guard let selectedProduct else { return [] }
        return DemoData.priceHistory[selectedProduct.id] ?? []
    }

    var selectedProductTrendText: String {
        guard
            let first = selectedProductHistory.first?.price,
            let last = selectedProductHistory.last?.price
        else {
            return "0 kr"
        }

        return (first - last).currencyString
    }

    var shoppingListGroups: [StoreGroup] {
        let grouped = Dictionary(grouping: shoppingItems, by: \.store)
        return grouped
            .map { StoreGroup(store: $0.key, items: $0.value) }
            .sorted { $0.total < $1.total }
    }

    var totalListCost: Double {
        shoppingItems.reduce(0) { $0 + $1.totalPrice }
    }

    var optimizedSavings: Double {
        shoppingItems.reduce(0) { $0 + $1.potentialSavings }
    }

    var remainingBudget: Double {
        weeklyBudget - spent
    }

    var budgetProgress: Double {
        min(max(spent / weeklyBudget, 0), 1)
    }

    var budgetAlert: String {
        if budgetProgress > 0.9 {
            return "Warning: you're close to exceeding this week's budget."
        } else if budgetProgress > 0.7 {
            return "On track, but switching stores could save another \(optimizedSavings.currencyString)."
        } else {
            return "You are under budget and saving well this week."
        }
    }

    var bestStore: Store {
        stores.min(by: { $0.priceIndex < $1.priceIndex }) ?? stores[0]
    }

    var dailyBudgetTarget: Double {
        weeklyBudget / 7
    }

    var budgetTips: [String] {
        [
            "Buy oat milk at Willys today and save 6 kr.",
            "Swap two ICA items to Willys and save \(optimizedSavings.currencyString).",
            "Use the cheap meal plan mode to keep dinners below 50 kr."
        ]
    }

    var filteredMealPlan: [MealPlanEntry] {
        Array(
            mealPlan
                .filter { selectedDiet == .cheap ? true : $0.diet == selectedDiet || $0.cost <= 50 }
                .prefix(mealsPerWeek)
        )
    }

    var mealPlannerIngredients: [String] {
        let ingredients = filteredMealPlan.flatMap(\.ingredients)
        return Array(Set(ingredients)).sorted()
    }

    var cheapestMealPlanTotal: Double {
        filteredMealPlan.reduce(0) { $0 + $1.cost }
    }

    func addSelectedProductToShoppingList() {
        guard
            let product = selectedProduct,
            let bestDeal = cheapestDeal,
            let store = stores.first(where: { $0.name == bestDeal.storeName })
        else {
            return
        }

        let item = ShoppingListItem(
            id: UUID(),
            product: product,
            quantity: 1,
            store: store,
            unitPrice: bestDeal.price,
            cheaperAlternativePrice: nil
        )
        shoppingItems.append(item)
    }

    func optimizeShoppingRoute() {
        shoppingItems = shoppingItems.map { item in
            guard let bestDeal = deals
                .filter({ $0.productID == item.product.id })
                .min(by: { $0.price < $1.price })
            else {
                return item
            }

            let targetStore = stores.first(where: { $0.name == bestDeal.storeName }) ?? item.store
            return ShoppingListItem(
                id: item.id,
                product: item.product,
                quantity: item.quantity,
                store: targetStore,
                unitPrice: bestDeal.price,
                cheaperAlternativePrice: nil
            )
        }
    }
}
