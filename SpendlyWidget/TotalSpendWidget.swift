import WidgetKit
import SwiftUI

struct TotalSpendEntry: TimelineEntry {
    let date: Date
    let total: Double
    let transactionCount: Int
    let monthLabel: String
}

struct TotalSpendProvider: TimelineProvider {
    func placeholder(in context: Context) -> TotalSpendEntry {
        TotalSpendEntry(date: .now, total: 0, transactionCount: 0, monthLabel: currentMonthLabel())
    }

    func getSnapshot(in context: Context, completion: @escaping (TotalSpendEntry) -> Void) {
        Task {
            let entry = await fetchEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TotalSpendEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            let nextUpdate = Date().addingTimeInterval(30 * 60)
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    private func fetchEntry() async -> TotalSpendEntry {
        let service = NotionService()
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: .now)) ?? .now

        do {
            let spends = try await service.fetchSpends()
            let monthSpends = spends.filter { $0.date >= startOfMonth }
            let total = monthSpends.reduce(0) { $0 + $1.amount }
            return TotalSpendEntry(
                date: .now,
                total: total,
                transactionCount: monthSpends.count,
                monthLabel: currentMonthLabel()
            )
        } catch {
            return TotalSpendEntry(
                date: .now,
                total: 0,
                transactionCount: 0,
                monthLabel: currentMonthLabel()
            )
        }
    }

    private func currentMonthLabel() -> String {
        Date().formatted(.dateTime.month(.wide).year())
    }
}

struct TotalSpendWidget: Widget {
    let kind: String = "TotalSpendWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TotalSpendProvider()) { entry in
            TotalSpendWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.06, blue: 0.08),
                            Color(red: 0.03, green: 0.03, blue: 0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("This Month")
        .description("Shows your total spend for the current month.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TotalSpendWidgetView: View {
    let entry: TotalSpendEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .font(.subheadline)
                Text(entry.monthLabel)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
            }
            .foregroundStyle(.secondary)

            Text(Money.format(entry.total))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text("\(entry.transactionCount) spends")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
