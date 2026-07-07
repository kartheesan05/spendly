import SwiftUI

struct TransactionsView: View {
    @Environment(DashboardViewModel.self) private var vm
    @State private var query = ""
    @State private var filterCategory: String?

    var filtered: [Spend] {
        let byPeriod = vm.filteredSpends
        let byCategory = filterCategory.map { cat in
            byPeriod.filter { $0.category == cat }
        } ?? byPeriod
        guard !query.isEmpty else { return byCategory }
        return byCategory.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var grouped: [(date: Date, items: [Spend])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: filtered, by: { cal.startOfDay(for: $0.date) })
        return groups.keys.sorted(by: >).map { ($0, groups[$0]!.sorted(by: { $0.amount > $1.amount })) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !vm.categorySlices.isEmpty {
                    categoryChips
                }
                if grouped.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray").font(.system(size: 36)).foregroundStyle(.secondary)
                        Text("No transactions").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 80)
                } else {
                    ForEach(grouped, id: \.date) { group in
                        sectionHeader(for: group.date, count: group.items.count)
                        VStack(spacing: 10) {
                            ForEach(group.items) { spend in
                                row(for: spend)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 40)
        }
        .background(MeshGradientBackground())
        .safeAreaPadding(.top, 8)
        .task { if vm.spends.isEmpty { await vm.load() } }
        .refreshable { await vm.refresh() }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.categorySlices) { slice in
                    let isOn = filterCategory == slice.category
                    Button {
                        withAnimation(.snappy) { filterCategory = isOn ? nil : slice.category }
                    } label: {
                        HStack(spacing: 6) {
                            Circle().fill(Theme.barDim).frame(width: 8, height: 8)
                            Text(slice.category).font(.caption.weight(.semibold))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .foregroundStyle(.primary)
                        .background {
                            if isOn { Capsule().fill(Theme.softFillStrong) }
                        }
                        .glassCell(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionHeader(for date: Date, count: Int) -> some View {
        HStack {
            Text(date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)))
                .font(.subheadline.weight(.bold))
            Spacer()
            Text("\(count) • \(Money.format(grouped.first(where: { $0.date == date })?.items.reduce(0) { $0 + $1.amount } ?? 0, compact: true))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
    }

    private func row(for spend: Spend) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.softFill).frame(width: 42, height: 42)
                Image(systemName: Theme.icon(for: spend.category))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(spend.name).font(.subheadline.weight(.semibold)).lineLimit(1)
                HStack(spacing: 6) {
                    Image(systemName: Theme.paymentIcon(for: spend.paymentMethod)).font(.caption2)
                    Text(spend.category).font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Money.format(spend.amount))
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .padding(14)
        .glassCell(cornerRadius: 18)
    }
}
