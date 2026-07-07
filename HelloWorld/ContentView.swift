import SwiftUI

struct ContentView: View {
    @State private var vm = DashboardViewModel()
    @State private var tab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $tab) {
            Tab("Dashboard", systemImage: "chart.pie.fill", value: AppTab.dashboard) {
                DashboardView()
            }
            Tab("Insights", systemImage: "sparkles", value: AppTab.insights) {
                InsightsView()
            }
            Tab("Transactions", systemImage: "list.bullet.rectangle.portrait", value: AppTab.transactions) {
                TransactionsView()
            }
        }
        .environment(vm)
        .tint(.white)
    }
}

enum AppTab: String, Hashable {
    case dashboard, insights, transactions
}

#Preview {
    ContentView()
}
