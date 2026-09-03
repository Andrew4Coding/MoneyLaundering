//
//  CategoryBreakdownChart.swift
//  Money Laundering
//

import SwiftUI
import SwiftData
import Charts

/// Donut chart breaking down expenses by category for the currently selected Home period,
/// with a legend showing each category's percentage share.
struct CategoryBreakdownChart: View {
    let slices: [CategorySlice]

    private static let palette: [Color] = [
        .blue, .green, .orange, .purple, .pink, .teal, .red, .indigo, .brown, .mint
    ]

    private func color(for index: Int) -> Color {
        Self.palette[index % Self.palette.count]
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if slices.isEmpty {
                EmptyStateView(
                    systemImage: "chart.pie",
                    title: "No Spending Yet",
                    message: "Add some expenses to see how your spending breaks down."
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            } else {
                Chart(Array(slices.enumerated()), id: \.element.id) { index, slice in
                    SectorMark(
                        angle: .value("Amount", slice.fraction),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .cornerRadius(4)
                    .foregroundStyle(color(for: index))
                }
                .frame(height: 200)

                VStack(spacing: 8) {
                    ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(color(for: index))
                                .frame(width: 10, height: 10)
                            Text(slice.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            Spacer()
                            Text(slice.fraction, format: .percent.precision(.fractionLength(0)))
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    CategoryBreakdownChart(slices: [
        CategorySlice(name: "Food", amount: 120_000, fraction: 0.6, icon: nil),
        CategorySlice(name: "Transport", amount: 80_000, fraction: 0.4, icon: nil)
    ])
    .padding()
}
