import Foundation

// MARK: - System

struct SystemStatus: Codable {
    let host: String
    let uptime: String
    let cpuTempC: Double
    let memoryUsedMb: Double
    let diskUsedPercent: Double
    let openclawRunning: Bool
    let lastUpdated: String
}

// MARK: - Report

struct Report: Codable {
    let currentCapital: Double
    let freeCash: Double
    let openValue: Double
    let goalProgress: Double
    let btcRealizedPnl: Double
    let ethRealizedPnl: Double
    let combined15mPnl: Double
    let sevenDayWinRate: Double
    let streak: Int
    let regime: String
}

// MARK: - Engines

struct EnginesStatus: Codable {
    let btc15m: Engine
    let eth15m: Engine
    let sol15m: Engine
    let xrp15m: Engine
    let coinbase: Engine
}

struct Engine: Codable {
    let running: Bool
    let mode: String  // "live" | "dry"
    let pid: Int?
}

// MARK: - Dashboard

struct DashboardSummary: Codable {
    let openPnl: Double
    let todayPnl: Double
    let allTimePnl: Double
    let positions: [Position]
    let recentTrades: [Trade]
}

struct Position: Codable, Identifiable {
    let id: UUID
    let symbol: String
    let size: Double
    let entryPrice: Double
    let currentPrice: Double
    let unrealizedPnl: Double
}

struct Trade: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let symbol: String
    let side: String      // "buy" | "sell"
    let amount: Double
    let pnl: Double?
    let status: String    // "filled" | "resolved" | "error"
}

// MARK: - Transactions

struct Transaction: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let type: String     // "fill" | "redeem" | "resolved" | "error"
    let symbol: String?
    let amount: Double?
    let note: String?
}

// MARK: - Redeems

struct Redeem: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let title: String
    let value: Double
    let status: String   // "success" | "pending" | "failed"
}
