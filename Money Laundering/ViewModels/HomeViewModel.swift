//
//  HomeViewModel.swift
//  Money Laundering
//

import Foundation
import Observation

struct CategorySlice: Identifiable {
    var name: String
    var amount: Decimal
    var fraction: Double
    var icon: TransactionCategory?

    var id: String {
        name
    }
}

@Observable
final class HomeViewModel {
    var selectedPeriod: PeriodOption = .today
    var customRange: ClosedRange<Date>?

    private func periodTransactions(from transactions: [Transaction]) -> [Transaction] {
        guard let range = DateRangeProvider.range(for: selectedPeriod, customRange: customRange) else {
            return transactions
        }
        return transactions.filter { range.contains($0.date) }
    }

    func totalIncome(from transactions: [Transaction]) -> Decimal {
        periodTransactions(from: transactions)
            .filter { $0.type == .income }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    func totalExpense(from transactions: [Transaction]) -> Decimal {
        periodTransactions(from: transactions)
            .filter { $0.type == .expense }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    /// "Money left" — income minus expense for the currently selected period only.
    func balance(from transactions: [Transaction]) -> Decimal {
        totalIncome(from: transactions) - totalExpense(from: transactions)
    }

    /// Expense totals grouped by category for the selected period, largest first, with each
    /// slice's share of total spending.
    func categoryBreakdown(from transactions: [Transaction]) -> [CategorySlice] {
        let expenses = periodTransactions(from: transactions).filter { $0.type == .expense }
        let total = expenses.reduce(Decimal(0)) { $0 + $1.amount }
        guard total > 0 else { return [] }

        let grouped = Dictionary(grouping: expenses) { $0.category?.name ?? "Uncategorized" }
        return grouped.map { name, items in
            let amount = items.reduce(Decimal(0)) { $0 + $1.amount }
            return CategorySlice(
                name: name,
                amount: amount,
                fraction: (amount as NSDecimalNumber).doubleValue / (total as NSDecimalNumber).doubleValue,
                icon: items.first?.category
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    func recentTransactions(from transactions: [Transaction], limit: Int = 5) -> [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(limit))
    }
}
