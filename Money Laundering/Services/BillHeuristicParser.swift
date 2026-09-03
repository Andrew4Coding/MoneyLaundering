//
//  BillHeuristicParser.swift
//  Money Laundering
//

import Foundation

/// Regex-based parser that extracts line items and charges straight from OCR text, with no LLM.
/// This is the primary parser — the on-device model is only tried when this finds nothing.
enum BillHeuristicParser {
    private static let skipKeywords = [
        "subtotal", "sub total", "total", "grand total", "tax", "ppn", "pb1", "pajak",
        "service", "svc", "layanan", "discount", "diskon", "voucher", "promo",
        "cash", "tunai", "kembali", "change", "rounding", "pembulatan", "npwp",
        "cashier", "kasir", "table", "meja", "bill", "invoice", "struk", "terima kasih",
        "thank", "qty", "quantity", "item", "www", "http", "@",
    ]
    private static let taxKeywords = ["tax", "ppn", "pb1", "pajak"]
    private static let serviceKeywords = ["service", "svc", "layanan"]
    private static let discountKeywords = ["discount", "diskon", "voucher", "promo"]

    static func parse(text: String) -> ParsedBill {
        let lines = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var items: [ParsedBill.Item] = []
        var tax: Decimal = 0
        var service: Decimal = 0
        var discount: Decimal = 0
        var merchant = lines.first ?? ""

        for line in lines {
            let lower = line.lowercased()
            guard let amount = trailingAmount(in: line), amount > 0 else { continue }

            if taxKeywords.contains(where: lower.contains) {
                tax += amount
                continue
            }
            if serviceKeywords.contains(where: lower.contains) {
                service += amount
                continue
            }
            if discountKeywords.contains(where: lower.contains) {
                discount += amount
                continue
            }
            if skipKeywords.contains(where: lower.contains) {
                continue
            }

            let (name, quantity) = nameAndQuantity(from: line)
            guard !name.isEmpty, name.count > 1 else { continue }

            items.append(
                ParsedBill.Item(
                    name: name,
                    quantity: quantity,
                    unitPrice: quantity > 0 ? amount / Decimal(quantity) : amount,
                    lineTotal: amount
                )
            )
        }

        if merchant.rangeOfCharacter(from: .decimalDigits) != nil { merchant = "" }

        return ParsedBill(
            merchant: merchant,
            items: items,
            tax: tax,
            service: service,
            discount: discount,
            rawText: text
        )
    }

    /// The last money-looking token on a line, e.g. `25.000` or `25,000` or `25000`.
    private static func trailingAmount(in line: String) -> Decimal? {
        guard let match = line.range(
            of: #"(\d{1,3}(?:[.,]\d{3})+|\d{3,})\s*$"#,
            options: .regularExpression
        ) else { return nil }
        return CurrencyFormatter.parse(String(line[match]))
    }

    /// Strips a leading quantity marker (`2x`, `2 x`, `2 @`) and the trailing amount from a line.
    private static func nameAndQuantity(from line: String) -> (name: String, quantity: Int) {
        var working = line

        if let amountRange = working.range(
            of: #"(\d{1,3}(?:[.,]\d{3})+|\d{3,})\s*$"#,
            options: .regularExpression
        ) {
            working = String(working[..<amountRange.lowerBound])
        }

        var quantity = 1
        if let qtyRange = working.range(
            of: #"^\s*(\d{1,3})\s*[x@×]\s*"#,
            options: .regularExpression
        ) {
            let digits = working[qtyRange].filter(\.isNumber)
            quantity = max(1, Int(digits) ?? 1)
            working = String(working[qtyRange.upperBound...])
        }

        let name = working
            .trimmingCharacters(in: CharacterSet(charactersIn: " .-–—•*x×@:"))
            .trimmingCharacters(in: .whitespaces)
        return (name, quantity)
    }
}
