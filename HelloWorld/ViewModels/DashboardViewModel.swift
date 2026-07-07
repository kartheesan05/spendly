import Foundation
import SwiftUI

@Observable
final class DashboardViewModel {
    enum Period: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
        var id: String { rawValue }
    }

    var spends: [Spend] = []
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?
    var period: Period = .month
    var selectedCategory: String?

    private let service: NotionService

    init(service: NotionService = NotionService()) {
        self.service = service
    }

    // MARK: - Loading

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            spends = try await service.fetchSpends()
            lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await load()
    }

    // MARK: - Filtering

    private var now: Date { Date() }

    var filteredSpends: [Spend] {
        let cal = Calendar.current
        switch period {
        case .week:
            let cutoff = cal.date(byAdding: .day, value: -7, to: now) ?? now
            return spends.filter { $0.date >= cutoff }
        case .month:
            let cutoff = cal.date(byAdding: .day, value: -30, to: now) ?? now
            return spends.filter { $0.date >= cutoff }
        case .all:
            return spends
        }
    }

    // MARK: - Totals

    var total: Double {
        filteredSpends.reduce(0) { $0 + $1.amount }
    }

    var transactionCount: Int {
        filteredSpends.count
    }

    var averagePerTransaction: Double {
        guard transactionCount > 0 else { return 0 }
        return total / Double(transactionCount)
    }

    var previousTotal: Double {
        let cal = Calendar.current
        let days: Int
        switch period {
        case .week: days = 7
        case .month: days = 30
        case .all: return 0
        }
        let currentStart = cal.date(byAdding: .day, value: -days, to: now) ?? now
        let prevStart = cal.date(byAdding: .day, value: -days * 2, to: now) ?? now
        return spends
            .filter { $0.date >= prevStart && $0.date < currentStart }
            .reduce(0) { $0 + $1.amount }
    }

    var deltaPercent: Double? {
        guard period != .all, previousTotal > 0 else { return nil }
        return (total - previousTotal) / previousTotal * 100
    }

    // MARK: - Category

    var categorySlices: [CategorySlice] {
        let grouped = Dictionary(grouping: filteredSpends, by: { $0.category })
        let total = self.total
        return grouped
            .map { (cat, items) in
                let sum = items.reduce(0) { $0 + $1.amount }
                return CategorySlice(
                    category: cat,
                    amount: sum,
                    count: items.count
                )
            }
            .sorted { $0.amount > $1.amount }
            .map { slice in
                var s = slice
                s.percentage = total > 0 ? slice.amount / total * 100 : 0
                return s
            }
    }

    var topCategory: CategorySlice? {
        categorySlices.first
    }

    var biggestSpend: Spend? {
        filteredSpends.max(by: { $0.amount < $1.amount })
    }

    var smallestSpend: Spend? {
        filteredSpends.min(by: { $0.amount < $1.amount })
    }

    // MARK: - Payment

    var paymentSlices: [PaymentSlice] {
        let grouped = Dictionary(grouping: filteredSpends, by: { $0.paymentMethod })
        return grouped
            .map { (method, items) in
                PaymentSlice(
                    method: method,
                    amount: items.reduce(0) { $0 + $1.amount },
                    count: items.count
                )
            }
            .sorted { $0.amount > $1.amount }
    }

    // MARK: - Trend

    var dailyTrend: [DaySpend] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filteredSpends, by: { cal.startOfDay(for: $0.date) })
        return grouped
            .map { (day, items) in
                DaySpend(
                    date: day,
                    amount: items.reduce(0) { $0 + $1.amount },
                    count: items.count
                )
            }
            .sorted { $0.date < $1.date }
    }

    var dailyAverage: Double {
        guard !filteredSpends.isEmpty else { return 0 }
        let cal = Calendar.current
        guard let oldest = filteredSpends.map({ $0.date }).min(),
              let days = cal.dateComponents([.day], from: cal.startOfDay(for: oldest), to: cal.startOfDay(for: now)).day
        else { return 0 }
        let span = max(days, 1)
        return total / Double(span)
    }

    var spanDays: Int {
        let cal = Calendar.current
        guard let oldest = filteredSpends.map({ $0.date }).min() else { return 0 }
        return (cal.dateComponents([.day], from: cal.startOfDay(for: oldest), to: cal.startOfDay(for: now)).day ?? 0) + 1
    }

    // MARK: - Weekday pattern

    var weekdaySpend: [(index: Int, label: String, amount: Double)] {
        let symbols = Calendar.current.shortWeekdaySymbols
        let grouped = Dictionary(grouping: filteredSpends, by: { Calendar.current.component(.weekday, from: $0.date) - 1 })
        return (0..<7).map { idx in
            let items = grouped[idx] ?? []
            return (idx, symbols[idx], items.reduce(0) { $0 + $1.amount })
        }
    }

    var topSpends: [Spend] {
        Array(filteredSpends.sorted(by: { $0.amount > $1.amount }).prefix(5))
    }

    var weekdayPeak: (label: String, amount: Double)? {
        let peak = weekdaySpend.max(by: { $0.amount < $1.amount })
        guard let peak, peak.amount > 0 else { return nil }
        return (peak.label, peak.amount)
    }
}
