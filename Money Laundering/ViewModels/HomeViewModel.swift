//
//  HomeViewModel.swift
//  Money Laundering
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    var selectedPeriod: PeriodOption = .thisMonth
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

    func recentTransactions(from transactions: [Transaction], limit: Int = 5) -> [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(limit))
    }
}
