import SwiftUI

// MARK: - ViewModel

@MainActor
final class SystemViewModel: ObservableObject {
    @Published var status: SystemStatus?
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        error = nil
        do {
            status = try await APIClient.shared.fetch(.system)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - View

struct SystemView: View {
    @StateObject private var vm = SystemViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    if let s = vm.status {
                        // Health overview
                        HStack(spacing: 10) {
                            HealthCard(
                                label: "CPU Temp",
                                value: String(format: "%.1f°C", s.cpuTempC),
                                color: s.cpuTempC > 70 ? .tacoRed : s.cpuTempC > 55 ? .tacoAmber : .tacoGreen
                            )
                            HealthCard(
                                label: "Memory",
                                value: String(format: "%.0f MB", s.memoryUsedMb),
                                color: .tacoBlue
                            )
                            HealthCard(
                                label: "Disk",
                                value: String(format: "%.0f%%", s.diskUsedPercent),
                                color: s.diskUsedPercent > 85 ? .tacoRed : .tacoGreen
                            )
                        }

                        // Details card
                        VStack(spacing: 0) {
                            DetailRow(label: "Host", value: s.host)
                            Divider().background(Color.tacoBorder)
                            DetailRow(label: "Uptime", value: s.uptime)
                            Divider().background(Color.tacoBorder)
                            DetailRow(label: "Openclaw", value: s.openclawRunning ? "Running ✓" : "Stopped ✗", valueColor: s.openclawRunning ? .tacoGreen : .tacoRed)
                            Divider().background(Color.tacoBorder)
                            DetailRow(label: "Last updated", value: s.lastUpdated)
                        }
                        .background(Color.tacoSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5))
                    }

                    if let error = vm.error {
                        ErrorBanner(message: error) { Task { await vm.load() } }
                    }
                }
                .padding(16)
            }
            .background(Color.tacoBg)
            .navigationTitle("System")
            .refreshable { await vm.load() }
            .onAppear { Task { await vm.load() } }
        }
    }
}

struct HealthCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 10)).foregroundStyle(.secondary).textCase(.uppercase).tracking(0.5)
            Text(value).font(.system(size: 18, weight: .medium)).foregroundColor(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.tacoSurface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5)))
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.medium)).foregroundColor(valueColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }
}
