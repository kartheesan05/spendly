import SwiftUI

enum Theme {
    static func color(for category: String) -> Color {
        switch category {
        case "Food & Drinks": return Color(red: 1.0, green: 0.42, blue: 0.21)
        case "Travel": return Color(red: 0.25, green: 0.60, blue: 1.0)
        case "Entertainment": return Color(red: 0.69, green: 0.45, blue: 1.0)
        case "Shopping": return Color(red: 1.0, green: 0.35, blue: 0.60)
        case "Services": return Color(red: 0.30, green: 0.85, blue: 0.55)
        default: return Color(red: 0.55, green: 0.58, blue: 0.64)
        }
    }

    static func icon(for category: String) -> String {
        switch category {
        case "Food & Drinks": return "fork.knife"
        case "Travel": return "tram.fill"
        case "Entertainment": return "film.fill"
        case "Shopping": return "bag.fill"
        case "Services": return "wrench.and.screwdriver.fill"
        default: return "tag.fill"
        }
    }

    static func paymentIcon(for method: String) -> String {
        switch method {
        case "UPI": return "qrcode"
        case "Cash": return "banknote.fill"
        case "Card": return "creditcard.fill"
        default: return "creditcard.fill"
        }
    }
}

enum Money {
    static func format(_ amount: Double, compact: Bool = false) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "INR"
        f.locale = Locale(identifier: "en_IN")
        f.maximumFractionDigits = compact ? 0 : 0
        f.maximumFractionDigits = amount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        if compact && abs(amount) >= 1000 {
            f.numberStyle = .currency
            f.maximumFractionDigits = 1
            return f.string(from: NSNumber(value: amount)) ?? "₹0"
        }
        return f.string(from: NSNumber(value: amount)) ?? "₹0"
    }
}
