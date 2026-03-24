import SwiftUI

// MARK: - ViewModel

@MainActor
final class RedeemsViewModel: ObservableObject {
    @Published var redeems: [Redeem] = []
    @Published var isLoading = false
    @Published var error: String?

    var totalToday: Double {
        let calendar = Calendar.current
        return redeems
            .filter { calendar.isDateInToday($0.timestamp) && $0.status == "success" }
            .reduce(0) { $0 + $1.value }
    }

    var totalThisWeek: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return redeems
            .filter { $0.timestamp >= weekAgo && $0.status == "success" }
            .reduce(0) { $0 + $1.value }
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            redeems = try await APIClient.shared.fetch(.redeems)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - View

struct RedeemsView: View {
    @StateObject private var vm = RedeemsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    // Totals summary
                    HStack(spacing: 10) {
                        SummaryCard(label: "Today", value: vm.totalToday, color: .tacoGreen)
                        SummaryCard(label: "This week", value: vm.totalThisWeek, color: .tacoPurple)
                    }
                    .padding(.horizontal, 16)

                    // Redeem list
                    VStack(spacing: 0) {
                        ForEach(vm.redeems) { redeem in
                            RedeemRow(redeem: redeem)
                            if redeem.id != vm.redeems.last?.id {
                                Divider().background(Color.tacoBorder).padding(.leading, 56)
                            }
                        }
                    }
                    .background(Color.tacoSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5))
                    .padding(.horizontal, 16)

                    if let error = vm.error {
                        ErrorBanner(message: error) { Task { await vm.load() } }.padding(.horizontal, 16)
                    }
                }
                .padding(.top, 8)
            }
            .background(Color.tacoBg)
            .navigationTitle("Redeems")
            .refreshable { await vm.load() }
            .onAppear { Task { await vm.load() } }
        }
    }
}

struct SummaryCard: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundStyle(.secondary).textCase(.uppercase).tracking(0.5)
            Text(value, format: .currency(code: "USD"))
                .font(.title2.weight(.medium))
                .foregroundColor(color)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.tacoSurface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5)))
    }
}

struct RedeemRow: View {
    let redeem: Redeem

    var statusColor: Color {
        switch redeem.status {
        case "success": return .tacoGreen
        case "pending": return .tacoAmber
        default:        return .tacoRed
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gift.circle.fill")
                .foregroundColor(.tacoPurple)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(redeem.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Text(redeem.timestamp, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(redeem.value, format: .currency(code: "USD"))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Text(redeem.status.capitalized)
                    .font(.caption2.bold())
                    .foregroundColor(statusColor)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
