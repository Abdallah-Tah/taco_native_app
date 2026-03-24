import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var report: Report?
    @Published var summary: DashboardSummary?
    @Published var engines: EnginesStatus?
    @Published var isLoading = false
    @Published var error: String?

    private var refreshTask: Task<Void, Never>?
    private let interval: TimeInterval

    init(interval: TimeInterval = AppSettings.shared.refreshInterval) {
        self.interval = interval
    }

    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await load()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
    }

    func load() async {
        isLoading = true
        error = nil
        async let reportResult: Report = APIClient.shared.fetch(.report)
        async let summaryResult: DashboardSummary = APIClient.shared.fetch(.dashboardSummary)
        async let enginesResult: EnginesStatus = APIClient.shared.fetch(.enginesStatus)

        do {
            let (r, s, e) = try await (reportResult, summaryResult, enginesResult)
            report = r
            summary = s
            engines = e
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
