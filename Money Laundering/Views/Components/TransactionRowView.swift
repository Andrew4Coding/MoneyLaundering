//
//  TransactionRowView.swift
//  Money Laundering
//

import SwiftUI

/// Shared row: category logo, source badge, title, date, and signed amount.
struct TransactionRowView: View {
    let transaction: Transaction

    private var amountColor: Color {
        transaction.type == .income ? .green : .primary
    }

    private var signedAmountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)\(CurrencyFormatter.rupiah(transaction.amount))"
    }

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadgeView(category: transaction.category, size: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    SourceBadgeView(source: transaction.source)
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(signedAmountText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(amountColor)
                .monospacedDigit()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(transaction.title), \(transaction.category?.name ?? "Uncategorized"), \(transaction.source.displayName), \(CurrencyFormatter.rupiah(transaction.amount)), \(transaction.type.displayName)"
        )
    }
}

#Preview {
    let category = TransactionCategory(name: "Food", iconType: .system, iconValue: "fork.knife", colorHex: "FF9500", isDefault: true)
    List {
        TransactionRowView(transaction: Transaction(type: .expense, title: "Lunch", amount: 45000, source: .grab, date: .now, description: "", category: category))
        TransactionRowView(transaction: Transaction(type: .income, title: "July Salary", amount: 5_000_000, source: .bca, date: .now, description: "", category: category))
    }
}
