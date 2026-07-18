//
//  HomeSummaryCard.swift
//  Money Laundering
//

import SwiftUI

/// Balance ("money left") card plus income/expense side-by-side totals for the selected period.
struct HomeSummaryCard: View {
    let balance: Decimal
    let totalIncome: Decimal
    let totalExpense: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Money Left")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.rupiah(balance))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
                    .monospacedDigit()
            }

            HStack(spacing: 12) {
                statTile(title: "Income", amount: totalIncome, systemImage: "arrow.down.circle.fill", tint: .green)
                statTile(title: "Expense", amount: totalExpense, systemImage: "arrow.up.circle.fill", tint: .red)
            }
        }
        .padding(20)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 20))
    }

    private func statTile(title: String, amount: Decimal, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.rupiah(amount))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeSummaryCard(balance: 4_955_000, totalIncome: 5_000_000, totalExpense: 45_000)
        .padding()
}
