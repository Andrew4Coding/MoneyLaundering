//
//  TransactionParser.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 08/09/26.
//

import Foundation
import FoundationModels

@Generable
struct ParsedTransaction {
    @Guide(description: "Amount in whole rupiah. Expand shorthand: 20k→20000, 1.5jt/1.5 juta→1500000, 20 ribu→20000")
    var amount: Double

    @Guide(description: "Spending category",
           .anyOf(["food", "transport", "groceries", "bills",
                   "entertainment", "shopping", "health", "other"]))
    var category: String

    @Guide(description: "Merchant or short note if mentioned, else empty")
    var note: String

    @Guide(description: "When the expense happened, ISO 8601 (e.g. 2026-09-08T14:00:00). Resolve relative words like \"yesterday\", \"2pm\" against the current date. Empty if not mentioned.")
    var occurredAt: String

    var date: Date? {
        guard !occurredAt.isEmpty else { return nil }
        if let dt = try? Date(occurredAt, strategy: .iso8601.time(includingFractionalSeconds: false)) {
            return dt
        }
        return try? Date(occurredAt, strategy: .iso8601.year().month().day())
    }
}

enum TransactionParser {
    static func parse(_ text: String) async throws -> ParsedTransaction {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw NeedsFallback()
        }
        let today = Date.now.formatted(.iso8601.year().month().day())
        let session = LanguageModelSession(instructions: """
        You extract a single expense from a short phrase for a personal
        finance app. Currency is Indonesian rupiah. If no category is
        clearly implied, use "other". Today is \(today); resolve any
        relative date/time against it.
        """)
        return try await session.respond(
            to: "Extract the transaction from: \"\(text)\"",
            generating: ParsedTransaction.self
        ).content
    }

    struct NeedsFallback: Error {}
}
