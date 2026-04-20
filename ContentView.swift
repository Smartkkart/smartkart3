import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            ProductComparisonView()
                .tabItem { Label("Compare", systemImage: "barcode.viewfinder") }
                .tag(AppTab.compare)

            ShoppingListView()
                .tabItem { Label("List", systemImage: "list.bullet.rectangle") }
                .tag(AppTab.list)

            MealPlannerView()
                .tabItem { Label("Meals", systemImage: "fork.knife") }
                .tag(AppTab.meals)

            BudgetView()
                .tabItem { Label("Budget", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(AppTab.budget)
        }
        .tint(AppTheme.primary)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard
                    statsGrid
                    quickActions
                    recommendedDeals
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("SmartCart")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Shop smarter every week")
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("Compare stores, plan meals, and stay inside budget with live-style savings guidance.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    appState.selectedTab = .compare
                } label: {
                    Label("Scan Product", systemImage: "barcode.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    appState.selectedTab = .meals
                } label: {
                    Label("Meal Plan", systemImage: "fork.knife")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .cardStyle()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.primary.opacity(0.22), AppTheme.secondary.opacity(0.16)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            StatCard(
                title: "Saved This Week",
                value: appState.savedThisWeek.currencyString,
                detail: "Across \(appState.shoppingListGroups.count) stores",
                color: AppTheme.primary,
                systemImage: "dollarsign.circle.fill"
            )
            StatCard(
                title: "Budget Left",
                value: max(appState.remainingBudget, 0).currencyString,
                detail: "\(Int(appState.budgetProgress * 100))% used",
                color: AppTheme.secondary,
                systemImage: "wallet.pass.fill"
            )
            StatCard(
                title: "Best Store Today",
                value: appState.bestStore.name,
                detail: "Avg basket \(appState.bestStore.priceIndex.currencyString)",
                color: AppTheme.deal,
                systemImage: "building.2.crop.circle"
            )
            StatCard(
                title: "Planned Meals",
                value: "\(appState.mealPlan.count)",
                detail: "Cheapest week: \(appState.cheapestMealPlanTotal.currencyString)",
                color: .orange,
                systemImage: "calendar"
            )
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shortcuts")
                .font(.headline)

            ForEach(HomeShortcut.allCases) { shortcut in
                Button {
                    appState.selectedTab = shortcut.tab
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: shortcut.icon)
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(shortcut.color.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(shortcut.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(shortcut.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)
            }
        }
    }
    private var recommendedDeals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Deals")
                .font(.headline)

            ForEach(appState.topDeals) { deal in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deal.productName)
                            .font(.headline)
                        Text("\(deal.storeName) • \(deal.distanceText)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(deal.price.currencyString)
                            .font(.headline)
                        Text("Save \(deal.savings.currencyString)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primary)
                    }
                }
                .cardStyle()
            }
        }
    }
}

private struct ProductComparisonView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchHeader
                    selectedProductCard
                    priceComparisonCard
                    priceHistoryCard
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Price Scanner")
        }
    }

    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Search products or barcode", text: $appState.searchText)
                .textFieldStyle(.roundedBorder)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(appState.filteredProducts) { product in
                        Button {
                            appState.selectedProductID = product.id
                        } label: {
                            Text(product.name)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(appState.selectedProduct?.id == product.id ? AppTheme.primary : .white)
                                )
                                .foregroundStyle(appState.selectedProduct?.id == product.id ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .cardStyle()
    }

    private var selectedProductCard: some View {
        Group {
            if let product = appState.selectedProduct {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(AppTheme.secondary.opacity(0.12))
                                .frame(width: 86, height: 86)
                            Image(systemName: product.icon)
                                .font(.system(size: 34))
                                .foregroundStyle(AppTheme.secondary)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.name)
                                .font(.title3.weight(.bold))
                            Text(product.category)
                                .foregroundStyle(.secondary)
                            Text("Cheapest nearby: \(appState.cheapestDeal?.storeName ?? "-")")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.primary)
                        }
                    }

                    Button {
                        appState.addSelectedProductToShoppingList()
                    } label: {
                        Label("Add Cheapest Option To List", systemImage: "cart.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .cardStyle()
            }
        }
    }

    private var priceComparisonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearby Price Comparison")
                .font(.headline)

            ForEach(appState.sortedDealsForSelectedProduct) { deal in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(deal == appState.cheapestDeal ? AppTheme.primary : AppTheme.secondary.opacity(0.24))
                                .frame(width: 10, height: 10)
                            Text(deal.storeName)
                                .font(.headline)
                        }
                        Text("\(deal.distanceText) away • \(deal.deliveryLabel)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(deal.price.currencyString)
                            .font(.headline)
                        Text(deal.priceDifferenceText)
                            .font(.caption)
                            .foregroundStyle(deal == appState.cheapestDeal ? AppTheme.primary : .secondary)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white)
                )
            }
        }
        .cardStyle()
    }

    private var priceHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price History")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(appState.selectedProductHistory) { point in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(point.isToday ? AppTheme.primary : AppTheme.secondary.opacity(0.22))
                            .frame(width: 28, height: CGFloat(90 + (point.price * 2.2)))
                        Text(point.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Text("Tip: prices are down \(appState.selectedProductTrendText) compared with last week.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}

private struct ShoppingListView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summary
                    optimizeButton
                    groupedItems
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Shopping List")
        }
    }

    private var summary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Estimated Total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(appState.totalListCost.currencyString)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("Optimized route saves \(appState.optimizedSavings.currencyString)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primary)
            }
            Spacer()
        }
        .cardStyle()
    }

    private var optimizeButton: some View {
        Button {
            appState.optimizeShoppingRoute()
        } label: {
            Label("Optimize Shopping", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var groupedItems: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(appState.shoppingListGroups) { group in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(group.store.name)
                            .font(.headline)
                        Spacer()
                        Text(group.total.currencyString)
                            .font(.headline)
                    }

                    ForEach(group.items) { item in
                        HStack(spacing: 12) {
                            Image(systemName: item.product.icon)
                                .foregroundStyle(AppTheme.secondary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.product.name)
                                Text("Qty \(item.quantity) • \(item.product.category)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if item.hasCheaperAlternative {
                                Text("Alt -\(item.potentialSavings.currencyString)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.deal)
                            }
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}

private struct MealPlannerView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    plannerControls
                    weeklyMeals
                    recipeBasket
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Meal Planner")
        }
    }

    private var plannerControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly setup")
                .font(.headline)

            Picker("Diet", selection: $appState.selectedDiet) {
                ForEach(DietStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Stepper("Meals per week: \(appState.mealsPerWeek)", value: $appState.mealsPerWeek, in: 3...7)

            HStack {
                Text("Budget mode")
                Spacer()
                Text(appState.selectedDiet.tip)
                    .foregroundStyle(AppTheme.primary)
            }
            .font(.subheadline)
        }
        .cardStyle()
    }

    private var weeklyMeals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            ForEach(appState.filteredMealPlan) { meal in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meal.day)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.secondary)
                        Text(meal.title)
                            .font(.headline)
                        Text(meal.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(meal.cost.currencyString)
                            .font(.headline)
                        Text(meal.tagline)
                            .font(.caption)
                            .foregroundStyle(meal.cost <= 50 ? AppTheme.primary : .secondary)
                    }
                }
                .cardStyle()
            }
        }
    }

    private var recipeBasket: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Auto-generated Grocery Basket")
                .font(.headline)
            Text("Best combined store total: \(appState.cheapestMealPlanTotal.currencyString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(appState.mealPlannerIngredients, id: \.self) { ingredient in
                Label(ingredient, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.primary)
            }
        }
        .cardStyle()
    }
}

private struct BudgetView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    budgetSummary
                    spendingChart
                    savingsTips
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Budget")
        }
    }

    private var budgetSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Budget")
                .font(.headline)
            Text(appState.weeklyBudget.currencyString)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            ProgressView(value: appState.budgetProgress)
                .tint(appState.budgetProgress > 0.85 ? .red : AppTheme.primary)
            Text(appState.budgetAlert)
                .font(.subheadline)
                .foregroundStyle(appState.budgetProgress > 0.85 ? .red : AppTheme.primary)
        }
        .cardStyle()
    }

    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(appState.spendingByDay) { point in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(point.amount > appState.dailyBudgetTarget ? AppTheme.deal : AppTheme.primary.opacity(0.7))
                            .frame(width: 28, height: CGFloat(40 + point.amount))
                        Text(point.day)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
    }

    private var savingsTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Savings Tips")
                .font(.headline)

            ForEach(appState.budgetTips, id: \.self) { tip in
                Label(tip, systemImage: "lightbulb.fill")
                    .foregroundStyle(.primary)
            }
        }
        .cardStyle()
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let detail: String
    let color: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private enum HomeShortcut: CaseIterable, Identifiable {
    case compare
    case list
    case meals

    var id: String { title }

    var title: String {
        switch self {
        case .compare: "Scan and Compare"
        case .list: "Smart Shopping List"
        case .meals: "Budget Meal Planner"
        }
    }

    var subtitle: String {
        switch self {
        case .compare: "Find the cheapest store for each product"
        case .list: "Group items by store and optimize the route"
        case .meals: "Generate weekly meals under your budget"
        }
    }

    var icon: String {
        switch self {
        case .compare: "barcode.viewfinder"
        case .list: "cart.fill"
        case .meals: "fork.knife.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .compare: AppTheme.secondary
        case .list: AppTheme.primary
        case .meals: AppTheme.deal
        }
    }

    var tab: AppTab {
        switch self {
        case .compare: .compare
        case .list: .list
        case .meals: .meals
        }
    }
}

private enum AppTheme {
    static let primary = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let secondary = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let background = Color(red: 0.96, green: 0.97, blue: 0.98)
    static let deal = Color(red: 0.97, green: 0.79, blue: 0.22)
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.primary.opacity(configuration.isPressed ? 0.82 : 1))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(configuration.isPressed ? 0.82 : 1))
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
            )
    }
}
