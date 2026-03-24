import SwiftUI

// MARK: - ViewModel

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        error = nil
        do {
            transactions = try await APIClient.shared.fetch(.transactions)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - View

struct TransactionsView: View {
    @StateObject private var vm = TransactionsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(vm.transactions) { tx in
                        TransactionRow(tx: tx)
                        Divider().background(Color.tacoBorder).padding(.leading, 56)
                    }
                    if let error = vm.error {
                        ErrorBanner(message: error) { Task { await vm.load() } }.padding(16)
                    }
                }
                .background(Color.tacoSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tacoBorder, lineWidth: 0.5))
                .padding(16)
            }
            .background(Color.tacoBg)
            .navigationTitle("Transactions")
            .refreshable { await vm.load() }
            .onAppear { Task { await vm.load() } }
        }
    }
}

struct TransactionRow: View {
    let tx: Transaction

    var iconName: String {
        switch tx.type {
        case "fill":     return "arrow.left.arrow.right.circle.fill"
        case "redeem":   return "gift.circle.fill"
        case "resolved": return "checkmark.circle.fill"
        case "error":    return "exclamationmark.circle.fill"
        default:         return "circle.fill"
        }
    }

    var iconColor: Color {
        switch tx.type {
        case "fill":     return .tacoBlue
        case "redeem":   return .tacoPurple
        case "resolved": return .tacoGreen
        case "error":    return .tacoRed
        default:         return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.note ?? tx.type.capitalized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Text(tx.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let amount = tx.amount {
                Text(String(format: "$%.2f", amount))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(tx.type == "error" ? .tacoRed : .white)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
