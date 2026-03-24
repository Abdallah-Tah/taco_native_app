import Foundation

enum APIEndpoint {
    case system
    case report
    case enginesStatus
    case dashboardSummary
    case transactions
    case redeems

    var path: String {
        switch self {
        case .system:           return "/api/system"
        case .report:           return "/api/report"
        case .enginesStatus:    return "/api/engines/status"
        case .dashboardSummary: return "/api/dashboard/summary"
        case .transactions:     return "/api/transactions"
        case .redeems:          return "/api/redeems"
        }
    }
}
