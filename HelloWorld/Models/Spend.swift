import Foundation

struct Spend: Identifiable, Hashable {
    let id: String
    let name: String
    let amount: Double
    let category: String
    let paymentMethod: String
    let date: Date

    static let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()
}

struct CategorySlice: Identifiable, Hashable {
    let category: String
    let amount: Double
    let count: Int
    var percentage: Double = 0
    var id: String { category }
}

struct PaymentSlice: Identifiable, Hashable {
    let method: String
    let amount: Double
    let count: Int
    var id: String { method }
}

struct DaySpend: Identifiable, Hashable {
    let date: Date
    let amount: Double
    let count: Int
    var id: Double { date.timeIntervalSince1970 }
}
