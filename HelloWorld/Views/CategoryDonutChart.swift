import SwiftUI
import Charts

struct CategoryDonutChart: View {
    let slices: [CategorySlice]
    let total: Double
    @Binding var selected: String?

    var body: some View {
        ZStack {
            if slices.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No spends in this period")
                        .foregroundStyle(.secondary)
                }
                .frame(height: 240)
            } else {
                Chart(slices) { slice in
                    SectorMark(
                        angle: .value("Amount", slice.amount),
                        innerRadius: .ratio(0.64),
                        angularInset: 2.2
                    )
                    .foregroundStyle(Theme.color(for: slice.category))
                    .opacity(isSelected(slice) ? 1.0 : dimmedOpacity)
                    .offset(offset(for: slice))
                }
                .chartLegend(.hidden)
                .frame(height: 240)
                .animation(.snappy(duration: 0.35), value: selected)

                VStack(spacing: 2) {
                    if let selected, let slice = slices.first(where: { $0.category == selected }) {
                        Text(slice.category.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.color(for: selected))
                            .tracking(0.5)
                        Text(Money.format(slice.amount))
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                        Text(String(format: "%.0f%% of total", slice.percentage))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("TOTAL")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text(Money.format(total))
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                        Text("\(slices.reduce(0) { $0 + $1.count }) spends")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .allowsHitTesting(false)
                .animation(.snappy(duration: 0.35), value: selected)
            }
        }
    }

    private func isSelected(_ slice: CategorySlice) -> Bool {
        selected == nil || selected == slice.category
    }

    private var dimmedOpacity: Double {
        selected == nil ? 0.95 : 0.28
    }

    private func offset(for slice: CategorySlice) -> CGSize {
        guard selected == slice.category, total > 0 else { return .zero }
        let cumulative = slices.reduce(0.0) { acc, s -> Double in
            s.category == slice.category ? acc : acc + s.amount
        }
        let frac = (cumulative + slice.amount / 2) / total
        let angle = frac * 2 * .pi - .pi / 2
        let dist: CGFloat = 10
        return CGSize(width: cos(angle) * dist, height: sin(angle) * dist)
    }
}
