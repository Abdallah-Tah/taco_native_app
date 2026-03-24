import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    if let report = vm.report {
                        CapitalCardView(report: report)
                        StatsRowView(report: report)
                    }
                    if let engines = vm.engines {
                        EngineStatusCard(engines: engines)
                    }
                    if let summary = vm.summary {
                        RecentTradesCard(trades: summary.recentTrades)
                    }
                    if let error = vm.error {
                        ErrorBanner(message: error) { Task { await vm.load() } }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.tacoBg)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .refreshable { await vm.load() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .onAppear { vm.startAutoRefresh() }
            .onDisappear { vm.stopAutoRefresh() }
        }
    }
}

// MARK: - Capital card

struct CapitalCardView: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current capital")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            Text(report.currentCapital, format: .currency(code: "USD"))
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 24) {
                StatCell(label: "Free cash", value: report.freeCash, color: .tacoBlue)
                StatCell(label: "Open value", value: report.openValue, color: .tacoPurple)
                StatCell(label: "15m PnL", value: report.combined15mPnl, color: report.combined15mPnl >= 0 ? .tacoGreen : .tacoRed, signed: true)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1a2540"))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tacoBorder, lineWidth: 0.5))
        )
    }
}

struct StatCell: View {
    let label: String
    let value: Double
    let color: Color
    var signed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(signed ? (value >= 0 ? "+" : "") + String(format: "$%.0f", value) : String(format: "$%.0f", value))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - Stats row

struct StatsRowView: View {
    let report: Report

    var body: some View {
        HStack(spacing: 10) {
            StatCard(label: "Win rate", value: "\(Int(report.sevenDayWinRate * 100))%", sub: "7-day", color: .tacoGreen)
            StatCard(label: "Streak", value: "\(report.streak > 0 ? "🔥" : "") \(abs(report.streak))W", sub: "wins", color: .tacoAmber)
            StatCard(label: "Regime", value: report.regime.uppercased(), sub: "market", color: .tacoBlue)
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let sub: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 10)).foregroundStyle(.secondary).textCase(.uppercase).tracking(0.5)
            Text(value).font(.system(size: 18, weight: .medium)).foregroundColor(color)
            Text(sub).font(.system(size: 10)).foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.tacoSurface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5)))
    }
}

// MARK: - Recent trades

struct RecentTradesCard: View {
    let trades: [Trade]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent trades").font(.caption).foregroundStyle(.secondary).textCase(.uppercase).tracking(1)
            VStack(spacing: 0) {
                ForEach(trades.prefix(5)) { trade in
                    TradeRow(trade: trade)
                    if trade.id != trades.prefix(5).last?.id {
                        Divider().background(Color.tacoBorder)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.tacoSurface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5)))
        }
    }
}

struct TradeRow: View {
    let trade: Trade

    var body: some View {
        HStack {
            Circle()
                .fill(symbolColor)
                .frame(width: 28, height: 28)
                .overlay(Text(String(trade.symbol.prefix(1))).font(.caption.bold()).foregroundColor(.white))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(trade.symbol) \(trade.side)").font(.subheadline.weight(.medium)).foregroundColor(.white)
                Text(trade.timestamp, style: .relative).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            if let pnl = trade.pnl {
                Text((pnl >= 0 ? "+" : "") + String(format: "$%.0f", pnl))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(pnl >= 0 ? .tacoGreen : .tacoRed)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var symbolColor: Color {
        switch trade.symbol.prefix(3) {
        case "BTC": return .tacoAmber
        case "ETH": return .tacoBlue
        case "SOL": return .tacoPurple
        case "XRP": return .tacoGreen
        default: return .tacoSurface
        }
    }
}

// MARK: - Error banner

struct ErrorBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle").foregroundColor(.tacoRed)
            Text(message).font(.caption).foregroundStyle(.secondary)
            Spacer()
            Button("Retry", action: retry).font(.caption.bold()).foregroundColor(.tacoBlue)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.tacoSurface).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tacoRed.opacity(0.3), lineWidth: 0.5)))
    }
}
