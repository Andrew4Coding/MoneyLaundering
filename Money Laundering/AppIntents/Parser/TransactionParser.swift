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
    @Guide(description: "Transaction type, either 'expense' or 'income'")
    var type: String

    @Guide(description: "Amount in whole rupiah. Expand shorthand: 20k→20000, 1.5jt/1.5 juta→1500000, 20 ribu→20000, 3jt/3juta/3mil->3000000")
    var amount: Double

    @Guide(description: "A short human-readable name for the transaction, at most 5 words, e.g. \"Lunch at Padang\", \"Grab to office\", \"Monthly electricity bill\". Derive it from the phrase. If nothing specific is mentioned, leave empty.")
    var name: String

    @Guide(description: "Merchant or short note if mentioned, else empty")
    var note: String
}

enum TransactionParser {
    static func parse(_ text: String) async throws -> ParsedTransaction {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw NeedsFallback()
        }

        let session = LanguageModelSession(instructions: """
        You extract a single transaction from a short phrase for a personal
        finance app. Currency is Indonesian rupiah. Give the transaction a
        short, natural name. The category is chosen separately, so do not
        infer one here.
        """)
        return try await session.respond(
            to: "Extract the transaction from: \"\(text)\"",
            generating: ParsedTransaction.self
        ).content
    }

    struct NeedsFallback: Error {}
}
