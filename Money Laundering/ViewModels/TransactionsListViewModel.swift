//
//  TransactionsListViewModel.swift
//  Money Laundering
//

import Foundation
import Observation

@Observable
final class TransactionsListViewModel {
    var searchText: String = ""
    var selectedPeriod: PeriodOption = .all
    var customRange: ClosedRange<Date>?

    /// Applies date-range filtering and text search over the full, live-updating array
    /// supplied by the view's `@Query`. In-memory filtering is deliberately simple here —
    /// see plan notes on why dynamic `#Predicate` composition isn't worth it at this scale.
    func filtered(_ transactions: [Transaction]) -> [Transaction] {
        let range = DateRangeProvider.range(for: selectedPeriod, customRange: customRange)

        return transactions.filter { transaction in
            matchesDateRange(transaction, range: range) && matchesSearch(transaction)
        }
    }

    private func matchesDateRange(_ transaction: Transaction, range: ClosedRange<Date>?) -> Bool {
        guard let range else { return true }
        return range.contains(transaction.date)
    }

    private func matchesSearch(_ transaction: Transaction) -> Bool {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return true }
        return transaction.title.localizedStandardContains(searchText)
            || transaction.transactionDescription.localizedStandardContains(searchText)
            || (transaction.category?.name.localizedStandardContains(searchText) ?? false)
    }
}
