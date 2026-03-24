import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }

            EnginesView()
                .tabItem { Label("Engines", systemImage: "cpu") }

            TransactionsView()
                .tabItem { Label("Transactions", systemImage: "arrow.left.arrow.right") }

            RedeemsView()
                .tabItem { Label("Redeems", systemImage: "gift.fill") }

            SystemView()
                .tabItem { Label("System", systemImage: "server.rack") }
        }
        .tint(.indigo)
    }
}
