import SwiftUI

extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

extension Theme {
    static let meshTop = Color.adaptive(
        light: Color(red: 0.96, green: 0.96, blue: 0.98),
        dark: Color(red: 0.06, green: 0.06, blue: 0.08)
    )
    static let meshBottom = Color.adaptive(
        light: Color(red: 0.86, green: 0.87, blue: 0.92),
        dark: Color(red: 0.03, green: 0.03, blue: 0.05)
    )
    static let softFill = Color.adaptive(
        light: Color.black.opacity(0.06),
        dark: Color.white.opacity(0.12)
    )
    static let softFillStrong = Color.adaptive(
        light: Color.black.opacity(0.10),
        dark: Color.white.opacity(0.18)
    )
    static let gridLine = Color.adaptive(
        light: Color.black.opacity(0.08),
        dark: Color.white.opacity(0.08)
    )
    static let barDim = Color.adaptive(
        light: Color.black.opacity(0.30),
        dark: Color.white.opacity(0.50)
    )
    static let overlayScrim = Color.adaptive(
        light: Color.black.opacity(0.15),
        dark: Color.black.opacity(0.25)
    )
}

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
        f.maximumFractionDigits = amount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        if compact {
            f.maximumFractionDigits = 0
        }
        return f.string(from: NSNumber(value: amount)) ?? "₹0"
    }
}
