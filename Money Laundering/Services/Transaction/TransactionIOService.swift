//
//  TransactionIOService.swift
//  Money Laundering
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
