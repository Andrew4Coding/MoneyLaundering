//
//  TransactionsListViewModel.swift
//  Money Laundering
//

import Foundation
import Observation
import SwiftData

@Observable
final class TransactionsListViewModel {
    var searchText: String = ""
    var selectedPeriod: PeriodOption = .all
    var customRange: ClosedRange<Date>?

    var isPresentingExporter = false
    var exportDocument: TransactionDocument?
    var exportFormat: TransactionExportFormat = .csv

    var statusMessage: String?
    var isPresentingStatusAlert = false

    func startExport(format: TransactionExportFormat, transactions: [Transaction]) {
        exportFormat = format
        exportDocument = TransactionDocument(data: TransactionIOService.export(transactions, format: format))
        isPresentingExporter = true
    }

    func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            statusMessage = "Exported to \(url.lastPathComponent)."
        case .failure(let error):
            statusMessage = "Export failed: \(error.localizedDescription)"
        }
        isPresentingStatusAlert = true
    }

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
