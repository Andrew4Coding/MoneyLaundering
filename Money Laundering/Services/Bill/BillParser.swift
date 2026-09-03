//
//  BillParser.swift
//  Money Laundering
//

import Foundation
import FoundationModels

/// Structured result of parsing a bill's OCR text.
struct ParsedBill {
    struct Item {
        var name: String
        var quantity: Int
        var unitPrice: Decimal
        var lineTotal: Decimal
    }

    var merchant: String
    var items: [Item]
    var tax: Decimal
    var service: Decimal
    var discount: Decimal
    var rawText: String
}

/// Turns raw receipt OCR text into structured line items and charges using Apple Intelligence's
/// on-device model with guided generation.
enum BillParser {
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    @Generable
    struct LLMBill {
        @Guide(description: "The store or restaurant name. Empty string if not found.")
        var merchant: String
        @Guide(description: "Every purchased line item. Exclude subtotal, total, tax and service rows.")
        var items: [LLMItem]
        @Guide(description: "Total tax amount such as PB1 or PPN, as a plain number. 0 if none.")
        var tax: Double
        @Guide(description: "Total service charge as a plain number. 0 if none.")
        var serviceCharge: Double
        @Guide(description: "Total discount as a positive plain number. 0 if none.")
        var discount: Double
    }

    @Generable
    struct LLMItem {
        var name: String
        @Guide(description: "Quantity purchased, at least 1.")
        var quantity: Int
        @Guide(description: "Price for a single unit, as a plain number.")
        var unitPrice: Double
        @Guide(description: "Total price for this line, as a plain number.")
        var lineTotal: Double
    }

    static func parse(text: String) async throws -> ParsedBill {
        let session = LanguageModelSession(instructions: """
        You extract structured data from the raw OCR text of a receipt. Amounts are Indonesian \
        Rupiah and use '.' as a thousands separator, so "25.000" means 25000 and there are no \
        decimal places. Never include currency symbols or separators in numbers. Use 0 or an \
        empty string when a value is missing. Only list real purchased items — never subtotal, \
        total, tax, rounding or service-charge rows.
        """)

        let bill = try await session.respond(to: text, generating: LLMBill.self).content

        return ParsedBill(
            merchant: bill.merchant.trimmingCharacters(in: .whitespacesAndNewlines),
            items: bill.items.map { item in
                ParsedBill.Item(
                    name: item.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    quantity: max(1, item.quantity),
                    unitPrice: Decimal(max(0, item.unitPrice)),
                    lineTotal: Decimal(max(0, item.lineTotal))
                )
            },
            tax: Decimal(max(0, bill.tax)),
            service: Decimal(max(0, bill.serviceCharge)),
            discount: Decimal(max(0, bill.discount)),
            rawText: text
        )
    }
}
