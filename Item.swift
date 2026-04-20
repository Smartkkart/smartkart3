import Foundation

enum AppTab: Int, Hashable {
    case home
    case compare
    case list
    case meals
    case budget
}

enum DietStyle: String, CaseIterable, Identifiable {
    case cheap
    case healthy
    case vegetarian
    case gym

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cheap: "Cheap"
        case .healthy: "Healthy"
        case .vegetarian: "Veg"
        case .gym: "Gym"
        }
    }

    var tip: String {
        switch self {
        case .cheap: "Cook for less than 50 kr"
        case .healthy: "Balance fiber and lean protein"
        case .vegetarian: "Lower cost with plant proteins"
        case .gym: "Higher protein, efficient prep"
        }
    }
}

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String
    let icon: String
}

struct Store: Identifiable, Hashable {
    let id: UUID
    let name: String
    let priceIndex: Double
}

struct StoreDeal: Identifiable, Hashable {
    let id: UUID
    let productID: UUID
    let productName: String
    let storeName: String
    let price: Double
    let normalPrice: Double
    let distanceInKilometers: Double
    let isOnline: Bool

    var savings: Double {
        max(normalPrice - price, 0)
    }

    var distanceText: String {
        String(format: "%.1f km", distanceInKilometers)
    }

    var deliveryLabel: String {
        isOnline ? "online delivery" : "in store"
    }

    var priceDifferenceText: String {
        savings > 0 ? "Save \(savings.currencyString)" : "Best current price"
    }
}

struct ShoppingListItem: Identifiable, Hashable {
    let id: UUID
    let product: Product
    var quantity: Int
    let store: Store
    let unitPrice: Double
    let cheaperAlternativePrice: Double?

    var totalPrice: Double {
        Double(quantity) * unitPrice
    }

    var potentialSavings: Double {
        guard let cheaperAlternativePrice else { return 0 }
        return max(unitPrice - cheaperAlternativePrice, 0) * Double(quantity)
    }

    var hasCheaperAlternative: Bool {
        potentialSavings > 0
    }
}

struct StoreGroup: Identifiable {
    let id = UUID()
    let store: Store
    let items: [ShoppingListItem]

    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
}

struct MealPlanEntry: Identifiable, Hashable {
    let id: UUID
    let day: String
    let title: String
    let description: String
    let cost: Double
    let diet: DietStyle
    let ingredients: [String]

    var tagline: String {
        cost <= 50 ? "Under 50 kr" : "Premium option"
    }
}

struct PriceHistoryPoint: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let price: Double
    let isToday: Bool
}

struct SpendingPoint: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let amount: Double
}

enum DemoData {
    static let products: [Product] = [
        Product(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Oat Milk", category: "Dairy Alternative", icon: "drop.fill"),
        Product(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Chicken Breast", category: "Protein", icon: "takeoutbag.and.cup.and.straw.fill"),
        Product(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Pasta", category: "Pantry", icon: "fork.knife"),
        Product(id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, name: "Greek Yogurt", category: "Breakfast", icon: "cup.and.saucer.fill")
    ]

    static let stores: [Store] = [
        Store(id: UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!, name: "ICA Maxi", priceIndex: 248),
        Store(id: UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!, name: "Willys", priceIndex: 231),
        Store(id: UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc")!, name: "Coop Online", priceIndex: 257)
    ]

    static let deals: [StoreDeal] = [
        StoreDeal(id: UUID(), productID: products[0].id, productName: products[0].name, storeName: "Willys", price: 21, normalPrice: 27, distanceInKilometers: 1.8, isOnline: false),
        StoreDeal(id: UUID(), productID: products[0].id, productName: products[0].name, storeName: "ICA Maxi", price: 23, normalPrice: 27, distanceInKilometers: 2.2, isOnline: false),
        StoreDeal(id: UUID(), productID: products[0].id, productName: products[0].name, storeName: "Coop Online", price: 26, normalPrice: 29, distanceInKilometers: 0.0, isOnline: true),
        StoreDeal(id: UUID(), productID: products[1].id, productName: products[1].name, storeName: "ICA Maxi", price: 79, normalPrice: 92, distanceInKilometers: 2.2, isOnline: false),
        StoreDeal(id: UUID(), productID: products[1].id, productName: products[1].name, storeName: "Willys", price: 75, normalPrice: 88, distanceInKilometers: 1.8, isOnline: false),
        StoreDeal(id: UUID(), productID: products[1].id, productName: products[1].name, storeName: "Coop Online", price: 82, normalPrice: 91, distanceInKilometers: 0.0, isOnline: true),
        StoreDeal(id: UUID(), productID: products[2].id, productName: products[2].name, storeName: "Willys", price: 18, normalPrice: 24, distanceInKilometers: 1.8, isOnline: false),
        StoreDeal(id: UUID(), productID: products[2].id, productName: products[2].name, storeName: "ICA Maxi", price: 19, normalPrice: 24, distanceInKilometers: 2.2, isOnline: false),
        StoreDeal(id: UUID(), productID: products[2].id, productName: products[2].name, storeName: "Coop Online", price: 23, normalPrice: 25, distanceInKilometers: 0.0, isOnline: true),
        StoreDeal(id: UUID(), productID: products[3].id, productName: products[3].name, storeName: "ICA Maxi", price: 31, normalPrice: 39, distanceInKilometers: 2.2, isOnline: false),
        StoreDeal(id: UUID(), productID: products[3].id, productName: products[3].name, storeName: "Willys", price: 29, normalPrice: 38, distanceInKilometers: 1.8, isOnline: false),
        StoreDeal(id: UUID(), productID: products[3].id, productName: products[3].name, storeName: "Coop Online", price: 34, normalPrice: 39, distanceInKilometers: 0.0, isOnline: true)
    ]

    static let shoppingItems: [ShoppingListItem] = [
        ShoppingListItem(id: UUID(), product: products[0], quantity: 2, store: stores[1], unitPrice: 21, cheaperAlternativePrice: nil),
        ShoppingListItem(id: UUID(), product: products[1], quantity: 1, store: stores[1], unitPrice: 75, cheaperAlternativePrice: nil),
        ShoppingListItem(id: UUID(), product: products[2], quantity: 3, store: stores[0], unitPrice: 19, cheaperAlternativePrice: 18),
        ShoppingListItem(id: UUID(), product: products[3], quantity: 2, store: stores[0], unitPrice: 31, cheaperAlternativePrice: 29)
    ]

    static let meals: [MealPlanEntry] = [
        MealPlanEntry(id: UUID(), day: "Mon", title: "Creamy Oat Pasta", description: "Pantry pasta with oat milk sauce and herbs.", cost: 44, diet: .cheap, ingredients: ["Pasta", "Oat Milk", "Garlic", "Spinach"]),
        MealPlanEntry(id: UUID(), day: "Tue", title: "Chicken Rice Bowl", description: "Lean chicken with vegetables and jasmine rice.", cost: 52, diet: .gym, ingredients: ["Chicken Breast", "Rice", "Broccoli", "Soy Sauce"]),
        MealPlanEntry(id: UUID(), day: "Wed", title: "Vegetarian Protein Wrap", description: "Bean wrap with yogurt dressing.", cost: 39, diet: .vegetarian, ingredients: ["Greek Yogurt", "Beans", "Wraps", "Tomato"]),
        MealPlanEntry(id: UUID(), day: "Thu", title: "Healthy Yogurt Breakfast", description: "Greek yogurt with oats and berries.", cost: 36, diet: .healthy, ingredients: ["Greek Yogurt", "Oats", "Berries"]),
        MealPlanEntry(id: UUID(), day: "Fri", title: "Budget Chicken Pasta", description: "Chicken pasta prep for two dinners.", cost: 49, diet: .cheap, ingredients: ["Chicken Breast", "Pasta", "Tomato Sauce"]),
        MealPlanEntry(id: UUID(), day: "Sat", title: "High Protein Bowl", description: "Chicken, yogurt sauce, roasted vegetables.", cost: 58, diet: .gym, ingredients: ["Chicken Breast", "Greek Yogurt", "Peppers"]),
        MealPlanEntry(id: UUID(), day: "Sun", title: "Vegetarian Pasta Bake", description: "A low-cost tray bake with pantry staples.", cost: 47, diet: .vegetarian, ingredients: ["Pasta", "Cheese", "Tomato Sauce"])
    ]

    static let priceHistory: [UUID: [PriceHistoryPoint]] = [
        products[0].id: [
            PriceHistoryPoint(label: "Mon", price: 27, isToday: false),
            PriceHistoryPoint(label: "Tue", price: 26, isToday: false),
            PriceHistoryPoint(label: "Wed", price: 24, isToday: false),
            PriceHistoryPoint(label: "Thu", price: 23, isToday: false),
            PriceHistoryPoint(label: "Fri", price: 21, isToday: true)
        ],
        products[1].id: [
            PriceHistoryPoint(label: "Mon", price: 89, isToday: false),
            PriceHistoryPoint(label: "Tue", price: 84, isToday: false),
            PriceHistoryPoint(label: "Wed", price: 82, isToday: false),
            PriceHistoryPoint(label: "Thu", price: 79, isToday: false),
            PriceHistoryPoint(label: "Fri", price: 75, isToday: true)
        ],
        products[2].id: [
            PriceHistoryPoint(label: "Mon", price: 24, isToday: false),
            PriceHistoryPoint(label: "Tue", price: 22, isToday: false),
            PriceHistoryPoint(label: "Wed", price: 21, isToday: false),
            PriceHistoryPoint(label: "Thu", price: 19, isToday: false),
            PriceHistoryPoint(label: "Fri", price: 18, isToday: true)
        ],
        products[3].id: [
            PriceHistoryPoint(label: "Mon", price: 38, isToday: false),
            PriceHistoryPoint(label: "Tue", price: 36, isToday: false),
            PriceHistoryPoint(label: "Wed", price: 34, isToday: false),
            PriceHistoryPoint(label: "Thu", price: 31, isToday: false),
            PriceHistoryPoint(label: "Fri", price: 29, isToday: true)
        ]
    ]

    static let spending: [SpendingPoint] = [
        SpendingPoint(day: "Mon", amount: 42),
        SpendingPoint(day: "Tue", amount: 78),
        SpendingPoint(day: "Wed", amount: 34),
        SpendingPoint(day: "Thu", amount: 61),
        SpendingPoint(day: "Fri", amount: 57),
        SpendingPoint(day: "Sat", amount: 83),
        SpendingPoint(day: "Sun", amount: 46)
    ]
}

extension Double {
    var currencyString: String {
        String(format: "%.0f kr", self)
    }
}
