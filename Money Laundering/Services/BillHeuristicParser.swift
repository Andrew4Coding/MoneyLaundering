//
//  BillHeuristicParser.swift
//  Money Laundering
//

import Foundation
import OSLog

/// Regex-based parser that extracts line items and charges straight from OCR text, with no LLM.
/// Handles both layouts thermal printers use:
///  - inline:  `2  Nasi Goreng          25.000`
///  - split:   every item name first, then a separate block with every amount.
enum BillHeuristicParser {
    private enum Charge {
        case subtotal, total, tax, service, discount, none
    }

    private static let taxKeywords = ["tax", "ppn", "pb1", "pbjt", "pajak"]
    private static let serviceKeywords = ["service", "svc", "layanan", "sc "]
    private static let discountKeywords = ["disc", "diskon", "voucher", "promo", "potongan"]
    private static let subtotalKeywords = ["subtotal", "sub total"]
    private static let totalKeywords = ["total", "grand total", "balance due", "amount due", "bayar", "tagihan"]

    private static let junkKeywords = [
        "print by", "served by", "print :", "print:", "guests", "guest :", "cek kembali",
        "sebelum", "melakukan", "pembayaran", "pesanan anda", "npwp", "no.", "struk",
        "terima kasih", "thank", "www", "http", ".com", "cashier", "kasir", "operator",
        "tbl", "table", "meja", "gopay", "ovo", "dana", "qris", "shopeepay", "cash",
        "tunai", "kembali", "change", "customer", "member", "poin", "point",
    ]

    static func parse(text: String) -> ParsedBill {
        let rawLines = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let lines = rawLines.filter { !isJunk($0) }

        let inlineItems = parseInline(lines)
        let split = parseSplit(lines)

        // Prefer whichever layout produced more items; inline wins ties.
        let useSplit = split.items.count > inlineItems.count
        let items = useSplit ? split.items : inlineItems

        var charges = useSplit ? split.charges : parseInlineCharges(lines)
        // Fill any charge the chosen layout missed from the other pass.
        let other = useSplit ? parseInlineCharges(lines) : split.charges
        if charges.tax == 0 { charges.tax = other.tax }
        if charges.service == 0 { charges.service = other.service }
        if charges.discount == 0 { charges.discount = other.discount }

        AppLog.billScan.debug(
            "Heuristic: \(lines.count) usable line(s), inline \(inlineItems.count) item(s), split \(split.items.count) item(s), using \(useSplit ? "split" : "inline")"
        )

        return ParsedBill(
            merchant: merchant(from: lines),
            items: items,
            tax: charges.tax,
            service: charges.service,
            discount: charges.discount,
            rawText: text
        )
    }

    // MARK: - Inline layout

    private static func parseInline(_ lines: [String]) -> [ParsedBill.Item] {
        var items: [ParsedBill.Item] = []
        for line in lines {
            guard classifyCharge(line) == .none,
                  let amount = trailingAmount(in: line), amount >= 100 else { continue }
            let (name, quantity) = nameAndQuantity(from: stripTrailingAmount(line))
            guard isPlausibleName(name) else { continue }
            items.append(item(name: name, quantity: quantity, amount: amount))
        }
        return items
    }

    private static func parseInlineCharges(_ lines: [String]) -> (tax: Decimal, service: Decimal, discount: Decimal) {
        var tax: Decimal = 0, service: Decimal = 0, discount: Decimal = 0
        for line in lines {
            guard let amount = trailingAmount(in: line), amount > 0 else { continue }
            switch classifyCharge(line) {
            case .tax: tax += amount
            case .service: service += amount
            case .discount: discount += amount
            default: break
            }
        }
        return (tax, service, discount)
    }

    // MARK: - Split layout

    private static func parseSplit(_ lines: [String]) -> (items: [ParsedBill.Item], charges: (tax: Decimal, service: Decimal, discount: Decimal)) {
        // Label lines (no trailing amount) in order, then amount-only lines in order.
        var labels: [String] = []
        var amounts: [Decimal] = []
        for line in lines {
            if let value = amountOnly(line) {
                amounts.append(value)
            } else if trailingAmount(in: line) == nil, hasLetters(line) {
                labels.append(line)
            }
        }

        guard labels.count >= 2, amounts.count >= 2 else {
            return ([], (0, 0, 0))
        }

        var items: [ParsedBill.Item] = []
        var tax: Decimal = 0, service: Decimal = 0, discount: Decimal = 0

        // Align from the end: a receipt reliably finishes with its charges and grand total, and
        // the item block sits directly above them. Anything left over at the top (store name,
        // table number, cashier) simply falls outside the zip and is ignored.
        for (label, amount) in zip(labels.reversed(), amounts.reversed()) {
            switch classifyCharge(label) {
            case .tax: tax += amount
            case .service: service += amount
            case .discount: discount += amount
            case .subtotal, .total:
                break
            case .none:
                let (name, quantity) = nameAndQuantity(from: label)
                guard isPlausibleName(name) else { continue }
                items.append(item(name: name, quantity: quantity, amount: amount))
            }
        }
        return (Array(items.reversed()), (tax, service, discount))
    }

    // MARK: - Classification

    private static func classifyCharge(_ line: String) -> Charge {
        let lower = line.lowercased()
        // Summary rows first so "Total Disc." counts as a total, not another discount.
        if subtotalKeywords.contains(where: lower.contains) { return .subtotal }
        if totalKeywords.contains(where: lower.contains) { return .total }
        if discountKeywords.contains(where: lower.contains) { return .discount }
        if taxKeywords.contains(where: lower.contains) { return .tax }
        if serviceKeywords.contains(where: lower.contains) { return .service }
        return .none
    }

    private static func isJunk(_ line: String) -> Bool {
        let lower = line.lowercased()
        if junkKeywords.contains(where: lower.contains) { return true }
        if line.range(of: #"\d{1,2}:\d{2}"#, options: .regularExpression) != nil { return true }
        if line.range(
            of: #"(?i)\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b"#,
            options: .regularExpression
        ) != nil { return true }
        // Phone numbers, e.g. "0813 14830545" or "081314830545".
        if line.range(of: #"0\d{2,3}[\s-]?\d{6,}"#, options: .regularExpression) != nil { return true }
        return false
    }

    /// A line that is nothing but a money value (optionally "Rp"), worth at least 100.
    private static func amountOnly(_ line: String) -> Decimal? {
        let trimmed = line
            .replacingOccurrences(of: "Rp", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        guard trimmed.range(of: #"^-?[\d.,]+$"#, options: .regularExpression) != nil else { return nil }
        guard let value = CurrencyFormatter.parse(trimmed), value >= 100 else { return nil }
        return value
    }

    private static func isPlausibleName(_ name: String) -> Bool {
        name.unicodeScalars.filter(CharacterSet.letters.contains).count >= 2
    }

    private static func hasLetters(_ line: String) -> Bool {
        line.rangeOfCharacter(from: .letters) != nil
    }

    // MARK: - Line pieces

    private static let amountPattern = #"(\d{1,3}(?:[.,]\d{3})+|\d{4,})\s*$"#

    private static func trailingAmount(in line: String) -> Decimal? {
        guard let match = line.range(of: amountPattern, options: .regularExpression) else { return nil }
        return CurrencyFormatter.parse(String(line[match]))
    }

    private static func stripTrailingAmount(_ line: String) -> String {
        guard let match = line.range(of: amountPattern, options: .regularExpression) else { return line }
        return String(line[..<match.lowerBound])
    }

    /// Splits a leading quantity marker (`2x`, `2 @`, or just `2 `) off the item name.
    private static func nameAndQuantity(from line: String) -> (name: String, quantity: Int) {
        var working = line.trimmingCharacters(in: CharacterSet(charactersIn: " .-–—•*:;?/\\"))
        var quantity = 1

        if let range = working.range(
            of: #"^\s*(\d{1,3})\s*(?:[x@×]\s*|\s)"#,
            options: .regularExpression
        ) {
            let digits = working[range].filter(\.isNumber)
            if let qty = Int(digits), qty >= 1, qty <= 999 {
                quantity = qty
                working = String(working[range.upperBound...])
            }
        }

        let name = working
            .trimmingCharacters(in: CharacterSet(charactersIn: " .-–—•*x×@:;?"))
            .trimmingCharacters(in: .whitespaces)
        return (name, quantity)
    }

    private static func item(name: String, quantity: Int, amount: Decimal) -> ParsedBill.Item {
        ParsedBill.Item(
            name: name,
            quantity: quantity,
            unitPrice: quantity > 0 ? amount / Decimal(quantity) : amount,
            lineTotal: amount
        )
    }

    private static func merchant(from lines: [String]) -> String {
        for line in lines.prefix(5)
            where line.rangeOfCharacter(from: .decimalDigits) == nil
            && classifyCharge(line) == .none
            && line.unicodeScalars.filter(CharacterSet.letters.contains).count >= 3 {
            return line
        }
        return ""
    }
}
