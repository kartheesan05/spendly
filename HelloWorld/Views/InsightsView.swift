import SwiftUI
import Charts

struct InsightsView: View {
    @Environment(DashboardViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                weekdayCard
                paymentCard
                topSpendsCard
                summaryCard
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 40)
        }
        .background(MeshGradientBackground())
        .safeAreaPadding(.top, 8)
        .task { if vm.spends.isEmpty { await vm.load() } }
        .refreshable { await vm.refresh() }
    }

    private var weekdayCard: some View {
        GlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Spending by weekday", systemImage: "calendar.badge.clock")
                        .font(.headline)
                    Spacer()
                    if let peak = vm.weekdayPeak {
                        Text(peak.label)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Capsule().fill(Theme.softFillStrong))
                            .foregroundStyle(.primary)
                    }
                }
                Chart(vm.weekdaySpend, id: \.index) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Spend", item.amount)
                    )
                    .foregroundStyle(
                        vm.weekdayPeak?.label == item.label
                            ? Color(red: 0.30, green: 0.85, blue: 0.55)
                            : Theme.barDim
                    )
                    .cornerRadius(5)
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Theme.gridLine)
                        AxisValueLabel().font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .frame(height: 170)
            }
        }
    }

    private var paymentCard: some View {
        GlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Label("Payment methods", systemImage: "creditcard.fill")
                    .font(.headline)
                ForEach(vm.paymentSlices) { slice in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Theme.softFill).frame(width: 40, height: 40)
                            Image(systemName: Theme.paymentIcon(for: slice.method))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(slice.method).font(.subheadline.weight(.semibold))
                            Text("\(slice.count) transactions").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(Money.format(slice.amount))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var topSpendsCard: some View {
        GlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Label("Top 5 spends", systemImage: "ranking.number")
                    .font(.headline)
                ForEach(Array(vm.topSpends.enumerated()), id: \.element.id) { index, spend in
                    HStack(spacing: 14) {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        ZStack {
                            Circle().fill(Theme.softFill).frame(width: 38, height: 38)
                            Image(systemName: Theme.icon(for: spend.category))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(spend.name).font(.subheadline.weight(.semibold)).lineLimit(1)
                            Text(spend.date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(Money.format(spend.amount))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    if index < vm.topSpends.count - 1 {
                        Divider().overlay(Theme.gridLine)
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        GlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Label("At a glance", systemImage: "sparkles")
                    .font(.headline)
                summaryRow("Average per transaction", value: Money.format(vm.averagePerTransaction))
                summaryRow("Daily average", value: Money.format(vm.dailyAverage))
                summaryRow("Total transactions", value: "\(vm.transactionCount)")
                summaryRow("Active days", value: "\(vm.spanDays)")
                summaryRow("Categories", value: "\(vm.categorySlices.count)")
                if let big = vm.biggestSpend {
                    summaryRow("Biggest spend", value: "\(big.name) (\(Money.format(big.amount)))")
                }
                if let top = vm.topCategory {
                    summaryRow("Top category", value: "\(top.category) (\(String(format: "%.0f%%", top.percentage)))")
                }
            }
        }
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.7)
        }
    }
}
