import SwiftUI
import Charts

struct DailyTrendChart: View {
    let data: [DaySpend]

    private var peak: DaySpend? {
        data.max(by: { $0.amount < $1.amount })
    }

    var body: some View {
        if data.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "chart.bar.fill").font(.title2).foregroundStyle(.secondary)
                Text("No trend data").font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
        } else {
            Chart(data) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Spend", day.amount)
                )
                .foregroundStyle(
                    peak?.id == day.id
                        ? Color(red: 1.0, green: 0.42, blue: 0.21)
                        : Color.white.opacity(0.5)
                )
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .font(.caption2)
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel().font(.caption2).foregroundStyle(.secondary)
                }
            }
            .frame(height: 160)
            .chartYScale(domain: .automatic(includesZero: true))
        }
    }
}
