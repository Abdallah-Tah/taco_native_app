import SwiftUI

// MARK: - ViewModel

@MainActor
final class EnginesViewModel: ObservableObject {
    @Published var engines: EnginesStatus?
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        error = nil
        do {
            engines = try await APIClient.shared.fetch(.enginesStatus)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - View

struct EnginesView: View {
    @StateObject private var vm = EnginesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let e = vm.engines {
                        EngineRow(name: "BTC 15m",  engine: e.btc15m)
                        EngineRow(name: "ETH 15m",  engine: e.eth15m)
                        EngineRow(name: "SOL 15m",  engine: e.sol15m)
                        EngineRow(name: "XRP 15m",  engine: e.xrp15m)
                        EngineRow(name: "Coinbase", engine: e.coinbase)
                    }
                    if let error = vm.error {
                        ErrorBanner(message: error) { Task { await vm.load() } }
                    }
                }
                .padding(16)
            }
            .background(Color.tacoBg)
            .navigationTitle("Engines")
            .refreshable { await vm.load() }
            .onAppear { Task { await vm.load() } }
        }
    }
}

struct EngineRow: View {
    let name: String
    let engine: Engine

    var statusColor: Color {
        guard engine.running else { return .tacoRed }
        return engine.mode == "live" ? .tacoGreen : .tacoAmber
    }

    var statusLabel: String {
        guard engine.running else { return "DOWN" }
        return engine.mode.uppercased()
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle().fill(statusColor).frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.subheadline.weight(.medium)).foregroundColor(.white)
                Text(engine.pid.map { "pid \($0)" } ?? "no pid")
                    .font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            Text(statusLabel)
                .font(.caption.bold())
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.tacoSurface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5)))
    }
}
