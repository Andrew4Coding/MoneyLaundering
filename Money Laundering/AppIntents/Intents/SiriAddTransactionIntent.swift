//
//  SiriAddTransactionIntent.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 08/09/26.
//

import AppIntents
import Foundation
import SwiftData

struct SiriAddTransactionIntent: AppIntent {
    static let title: LocalizedStringResource = "Quick Add Transaction"
    static let description = IntentDescription("Add an expense from a spoken phrase like \u{201C}20k for lunch\u{201D}.")
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = true

    @Parameter(title: "What did you spend?", requestValueDialog: "What did you spend?")
    var rawPhrase: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = Persistance.container.mainContext
        let parsed = try await parse(rawPhrase)

        guard parsed.amount > 0 else {
            throw $rawPhrase.needsValueError("How much did you spend, and what for?")
        }

        let money = Decimal(parsed.amount)
        let category = TransactionCategory.matching(canonicalCategoryName(parsed.category), in: context)
        let categoryLabel = category?.name ?? "Uncategorized"
        let title = parsed.note.isEmpty ? categoryLabel : parsed.note

        try await requestConfirmation(
            dialog: "Add \(CurrencyFormatter.rupiah(money)) for \(categoryLabel)?"
        )

        let tx = Transaction(
            type: .expense,
            title: title,
            amount: money,
            source: .bca,
            date: parsed.date ?? .now,
            category: category
        )
        context.insert(tx)
        try context.save()

        return .result(dialog: "Added \(CurrencyFormatter.rupiah(money)) for \(categoryLabel).")
    }

    private func parse(_ text: String) async throws -> ParsedTransaction {
        do {
            return try await TransactionParser.parse(text)
        } catch is TransactionParser.NeedsFallback {
            return Self.fallbackParse(text)
        }
    }

    private func canonicalCategoryName(_ token: String) -> String {
        switch token.lowercased() {
        case "groceries": return "Food"
        default: return token
        }
    }

    /// Deterministic parser used when the on-device model is unavailable.
    static func fallbackParse(_ text: String) -> ParsedTransaction {
        let lower = text.lowercased()
        var amount: Double = 0

        if let match = lower.firstMatch(of: /([0-9][0-9.,]*)\s*(k|rb|ribu|jt|juta|m)?/) {
            let digits = Double(match.1.replacing(",", with: "").replacing(".", with: "")) ?? 0
            switch match.2?.lowercased() {
            case "k", "rb", "ribu": amount = digits * 1000
            case "jt", "juta", "m": amount = digits * 1_000_000
            default: amount = digits
            }
        }

        let keywords: [String: String] = [
            "lunch": "food", "dinner": "food", "makan": "food", "coffee": "food", "kopi": "food",
            "grab": "transport", "gojek": "transport", "bensin": "transport", "transport": "transport",
            "groceries": "groceries", "belanja": "shopping",
            "bill": "bills", "listrik": "bills",
        ]
        let category = keywords.first { lower.contains($0.key) }?.value ?? "other"
        return ParsedTransaction(amount: amount, category: category, note: "", occurredAt: "")
    }
}
