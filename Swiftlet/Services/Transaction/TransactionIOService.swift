//
//  TransactionIOService.swift
//  Swiftlet
//

import Foundation
import SwiftData

/// Serializes transactions to/from CSV or JSON, independent of CloudKit sync, so the user can
/// back up or move data between accounts manually.
enum TransactionIOService {
    struct Record: Codable {
        var type: String
        var title: String
        var amount: String
        var source: String
        var date: Date
        var description: String
        var category: String?
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func export(_ transactions: [Transaction], format: TransactionExportFormat) -> Data {
        let records = transactions.map { transaction in
            Record(
                type: transaction.type.rawValue,
                title: transaction.title,
                amount: NSDecimalNumber(decimal: transaction.amount).stringValue,
                source: transaction.source.rawValue,
                date: transaction.date,
                description: transaction.transactionDescription,
                category: transaction.category?.name
            )
        }

        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            return (try? encoder.encode(records)) ?? Data()
        case .csv:
            return encodeCSV(records)
        }
    }

    // MARK: - Import

    struct ImportResult {
        var imported: Int
        var skipped: Int
    }

    enum ImportError: LocalizedError {
        case unreadableFile
        case invalidFormat

        var errorDescription: String? {
            switch self {
            case .unreadableFile: "The file couldn't be read."
            case .invalidFormat: "This file isn't a valid Swiftlet JSON export."
            }
        }
    }

    @MainActor
    static func importJSON(_ data: Data, into context: ModelContext) throws -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let records = try? decoder.decode([Record].self, from: data) else {
            throw ImportError.invalidFormat
        }

        let existing = (try? context.fetch(FetchDescriptor<Transaction>())) ?? []
        var imported = 0
        var skipped = 0

        for record in records {
            guard
                let type = TransactionType(rawValue: record.type),
                let source = MoneySource(rawValue: record.source),
                let amount = Decimal(string: record.amount)
            else {
                skipped += 1
                continue
            }

            let isDuplicate = existing.contains { transaction in
                guard transaction.title == record.title else { return false }
                guard transaction.amount == amount else { return false }
                guard transaction.date == record.date else { return false }
                guard transaction.type == type else { return false }
                guard transaction.source == source else { return false }
                return transaction.transactionDescription == record.description
            }
            if isDuplicate {
                skipped += 1
                continue
            }

            let category = resolveCategory(named: record.category, in: context)

            let transaction = Transaction(
                type: type,
                title: record.title,
                amount: amount,
                source: source,
                date: record.date,
                description: record.description,
                category: category
            )
            context.insert(transaction)
            imported += 1
        }

        try context.save()
        return ImportResult(imported: imported, skipped: skipped)
    }

    @MainActor
    private static func resolveCategory(named name: String?, in context: ModelContext) -> TransactionCategory? {
        guard let name, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        if let match = TransactionCategory.matching(name, in: context) {
            return match
        }
        let created = TransactionCategory(name: name)
        context.insert(created)
        return created
    }

    // MARK: - CSV

    private static let csvHeader = ["type", "title", "amount", "source", "date", "description", "category"]

    private static func encodeCSV(_ records: [Record]) -> Data {
        var lines = [csvHeader.joined(separator: ",")]
        for record in records {
            let fields = [
                record.type,
                record.title,
                record.amount,
                record.source,
                isoFormatter.string(from: record.date),
                record.description,
                record.category ?? "",
            ]
            lines.append(fields.map { escapeCSVField($0) }.joined(separator: ","))
        }
        return lines.joined(separator: "\n").data(using: .utf8) ?? Data()
    }

    private static func escapeCSVField(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else { return field }
        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
