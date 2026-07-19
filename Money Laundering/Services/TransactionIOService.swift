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

    /// Inserts a `Transaction` for each parsed record. Categories are matched by name
    /// (case-insensitive) against what already exists — mirroring `CategorySeeder`'s
    /// dedupe convention — and created on the fly if no match is found, so an import never
    /// silently drops a category label.
    @discardableResult
    static func importTransactions(from data: Data, format: TransactionExportFormat, context: ModelContext) throws -> Int {
        let records: [Record]
        switch format {
        case .json:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            records = try decoder.decode([Record].self, from: data)
        case .csv:
            records = try decodeCSV(data)
        }

        let existingCategories = try context.fetch(FetchDescriptor<TransactionCategory>())
        var categoriesByName = Dictionary(
            existingCategories.map { ($0.name.lowercased(), $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var importedCount = 0
        for record in records {
            guard let type = TransactionType(rawValue: record.type),
                  let source = MoneySource(rawValue: record.source),
                  let amount = Decimal(string: record.amount) else { continue }

            var category: TransactionCategory?
            if let name = record.category, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                let key = name.lowercased()
                if let existing = categoriesByName[key] {
                    category = existing
                } else {
                    let created = TransactionCategory(
                        name: name,
                        iconType: .system,
                        iconValue: "questionmark.circle",
                        colorHex: "8E8E93",
                        appliesTo: .both,
                        isDefault: false
                    )
                    context.insert(created)
                    categoriesByName[key] = created
                    category = created
                }
            }

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
            importedCount += 1
        }

        try context.save()
        return importedCount
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
                record.category ?? ""
            ]
            lines.append(fields.map(escapeCSVField).joined(separator: ","))
        }
        return lines.joined(separator: "\n").data(using: .utf8) ?? Data()
    }

    private static func decodeCSV(_ data: Data) throws -> [Record] {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        var lines = text.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        guard !lines.isEmpty else { return [] }
        lines.removeFirst()

        return lines.compactMap { line in
            let fields = parseCSVLine(line)
            guard fields.count >= 6, let date = isoFormatter.date(from: fields[4]) else { return nil }
            return Record(
                type: fields[0],
                title: fields[1],
                amount: fields[2],
                source: fields[3],
                date: date,
                description: fields[5],
                category: (fields.count > 6 && !fields[6].isEmpty) ? fields[6] : nil
            )
        }
    }

    private static func escapeCSVField(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else { return field }
        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var insideQuotes = false

        var iterator = line.makeIterator()
        while let char = iterator.next() {
            switch char {
            case "\"":
                insideQuotes.toggle()
            case "," where !insideQuotes:
                fields.append(current)
                current = ""
            default:
                current.append(char)
            }
        }
        fields.append(current)
        return fields
    }
}
