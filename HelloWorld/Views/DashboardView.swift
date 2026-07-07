import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var vm
    @State private var selectedCategory: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                periodPicker
                heroCard
                donutCard
                insightsGrid
                trendCard
                biggestSpendCard
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 40)
        }
        .background(MeshGradientBackground())
        .overlay(alignment: .top) { loadingOverlay }
        .safeAreaPadding(.top, 8)
        .task { if vm.spends.isEmpty { await vm.load() } }
        .refreshable { await vm.refresh() }
    }

    // MARK: Period picker

    private var periodPicker: some View {
        HStack(spacing: 8) {
            ForEach(DashboardViewModel.Period.allCases) { period in
                Button {
                    withAnimation(.snappy) {
                        vm.period = period
                        selectedCategory = nil
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(vm.period == period ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if vm.period == period {
                                Capsule().fill(Theme.softFillStrong)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .glassCell(cornerRadius: 18)
    }

    // MARK: Hero total

    private var heroCard: some View {
        GlassCard(cornerRadius: 28, padding: 24) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Total spent")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let updated = vm.lastUpdated {
                        Label(updated.formatted(.dateTime.hour().minute().second()), systemImage: "clock")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(Money.format(vm.total))
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: vm.total)
                HStack(spacing: 14) {
                    statLabel("\(vm.transactionCount)", "spends")
                    Divider().frame(height: 28)
                    statLabel(Money.format(vm.averagePerTransaction, compact: true), "avg / spend")
                    if let delta = vm.deltaPercent {
                        Divider().frame(height: 28)
                        Label(String(format: "%+.0f%%", delta), systemImage: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(delta >= 0 ? .primary : .secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func statLabel(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                        .font(.system(.headline, design: .rounded).weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Donut + breakdown

    private var donutCard: some View {
        GlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label("Where it goes", systemImage: "chart.pie.fill")
                        .font(.headline)
                    Spacer()
                    if selectedCategory != nil {
                        Button("Clear") { withAnimation { selectedCategory = nil } }
                            .font(.caption.weight(.semibold))
                    }
                }
                CategoryDonutChart(slices: vm.categorySlices, total: vm.total, selected: $selectedCategory)
                CategoryBreakdownView(slices: vm.categorySlices, total: vm.total, selected: $selectedCategory)
            }
        }
    }

    // MARK: Insights grid

    private var insightsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            StatTile(title: "Transactions", value: "\(vm.transactionCount)", systemImage: "receipt")
            StatTile(title: "Daily average", value: Money.format(vm.dailyAverage, compact: true), systemImage: "calendar")
            StatTile(title: "Avg / spend", value: Money.format(vm.averagePerTransaction, compact: true), systemImage: "divide")
            StatTile(
                title: "Top category",
                value: vm.topCategory?.category ?? "—",
                systemImage: "crown.fill"
            )
        }
    }

    // MARK: Trend

    private var trendCard: some View {
        GlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Spending trend", systemImage: "chart.xyaxis.line")
                        .font(.headline)
                    Spacer()
                    Text("\(vm.spanDays) day span")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DailyTrendChart(data: vm.dailyTrend)
            }
        }
    }

    // MARK: Biggest spend

    @ViewBuilder
    private var biggestSpendCard: some View {
        if let biggest = vm.biggestSpend {
            GlassCard(cornerRadius: 26, padding: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Biggest spend", systemImage: "flame.fill")
                        .font(.headline)
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Theme.softFill).frame(width: 46, height: 46)
                            Image(systemName: Theme.icon(for: biggest.category))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(biggest.name)
                                .font(.system(size: 18, weight: .bold))
                            Text(biggest.date.formatted(.dateTime.day().month(.abbreviated).year()))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(Money.format(biggest.amount))
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                    }
                }
            }
        }
    }

    // MARK: Loading

    @ViewBuilder
    private var loadingOverlay: some View {
        if vm.isLoading && vm.spends.isEmpty {
            ZStack {
                Theme.overlayScrim.ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView().scaleEffect(1.3).tint(.primary)
                    Text("Loading your spends…")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(28)
                .glassCell(cornerRadius: 20)
            }
        } else if let error = vm.errorMessage, vm.spends.isEmpty {
            ZStack {
                Theme.overlayScrim.ignoresSafeArea()
                VStack(spacing: 14) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Couldn't load").font(.headline)
                    Text(error).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("Try again") { Task { await vm.load() } }
                        .buttonStyle(.borderedProminent)
                }
                .padding(28)
                .glassCell(cornerRadius: 20)
            }
        }
    }
}
