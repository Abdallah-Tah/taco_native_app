import SwiftUI

extension Color {
    static let tacoGreen   = Color(hex: "#34d399")
    static let tacoRed     = Color(hex: "#f87171")
    static let tacoBlue    = Color(hex: "#60a5fa")
    static let tacoPurple  = Color(hex: "#a78bfa")
    static let tacoAmber   = Color(hex: "#f59e0b")
    static let tacoSurface = Color(hex: "#161b27")
    static let tacoBg      = Color(hex: "#0f1117")
    static let tacoBorder  = Color(hex: "#1e2436")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
