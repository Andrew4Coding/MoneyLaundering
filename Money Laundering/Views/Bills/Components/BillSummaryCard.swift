//
//  BillSummaryCard.swift
//  Money Laundering
//

import SwiftUI

/// Shows the user's computed share of a bill for the currently ticked items.
struct BillSummaryCard: View {
    let totals: BillTotals

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Share")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if totals.hasSelection {
                line("Items", totals.selectedSubtotal)
                if totals.taxShare > 0 {
                    line("Tax (\(percentText))", totals.taxShare)
                }
                if totals.serviceShare > 0 {
                    line("Service (\(percentText))", totals.serviceShare)
                }
                if totals.discountShare > 0 {
                    line("Discount", -totals.discountShare)
                }
                Divider()
                HStack {
                    Text("Your total")
                        .font(.headline)
                    Spacer()
                    Text(CurrencyFormatter.rupiah(totals.grandTotal))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .monospacedDigit()
                }
            } else {
                Text("Tick the items you paid for to see your total.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private var percentText: String {
        "\(Int((totals.fraction * 100).rounded()))%"
    }

    private func line(_ label: String, _ amount: Decimal) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(CurrencyFormatter.rupiah(amount))
                .font(.subheadline)
                .monospacedDigit()
        }
    }
}

#Preview {
    BillSummaryCard(totals: BillMath.totals(
        lineItems: [(50_000, true), (30_000, false), (20_000, true)],
        tax: 10_000, service: 5_000, discount: 0
    ))
    .padding()
}
