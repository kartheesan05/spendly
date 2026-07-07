import SwiftUI

struct CategoryBreakdownView: View {
    let slices: [CategorySlice]
    let total: Double
    @Binding var selected: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(slices) { slice in
                Button {
                    selected = (selected == slice.category) ? nil : slice.category
                } label: {
                    row(for: slice)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func row(for slice: CategorySlice) -> some View {
        let color = Theme.color(for: slice.category)
        let isOn = selected == slice.category
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.22)).frame(width: 34, height: 34)
                Image(systemName: Theme.icon(for: slice.category))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(slice.category)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(Money.format(slice.amount))
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                    Text(String(format: "%.0f%%", slice.percentage))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 42, alignment: .trailing)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(color.opacity(0.16)).frame(height: 6)
                        Capsule().fill(color).frame(width: geo.size.width * CGFloat(slice.percentage / 100), height: 6)
                    }
                }
                .frame(height: 6)
            }
            .opacity(selected == nil || isOn ? 1 : 0.4)
            .animation(.snappy(duration: 0.3), value: selected)
        }
        .padding(.vertical, 4)
    }
}
