//
//  Bill.swift
//  Money Laundering
//

import Foundation
import SwiftData

enum BillScanStatus: String, Codable {
    case manual
    case scanning
    case scanned
    case failed
}

/// A scanned or manually-entered receipt: the photo, its line items, and the shared charges
/// (tax, service, discount). A `Bill` is standalone — it is never turned into a `Transaction`.
/// The user ticks the items they personally paid for and `totals` splits the shared charges
/// proportionally.
@Model
final class Bill {
    var title: String = ""
    var merchant: String = ""
    var date: Date = Date.now
    var createdAt: Date = Date.now

    @Attribute(.externalStorage)
    var imageData: Data?

    /// Raw OCR text kept for reference and re-parsing.
    var rawText: String = ""

    var taxAmount: Decimal = 0
    var serviceAmount: Decimal = 0
    var discountAmount: Decimal = 0

    var scanStatusRaw: String = BillScanStatus.manual.rawValue

    @Relationship(deleteRule: .cascade, inverse: \BillItem.bill)
    var items: [BillItem]? = []

    init(
        title: String = "",
        merchant: String = "",
        date: Date = .now,
        imageData: Data? = nil,
        rawText: String = "",
        taxAmount: Decimal = 0,
        serviceAmount: Decimal = 0,
        discountAmount: Decimal = 0,
        scanStatus: BillScanStatus = .manual,
        createdAt: Date = .now
    ) {
        self.title = title
        self.merchant = merchant
        self.date = date
        self.imageData = imageData
        self.rawText = rawText
        self.taxAmount = taxAmount
        self.serviceAmount = serviceAmount
        self.discountAmount = discountAmount
        scanStatusRaw = scanStatus.rawValue
        self.createdAt = createdAt
    }

    var scanStatus: BillScanStatus {
        get { BillScanStatus(rawValue: scanStatusRaw) ?? .manual }
        set { scanStatusRaw = newValue.rawValue }
    }

    var sortedItems: [BillItem] {
        (items ?? []).sorted { $0.sortIndex < $1.sortIndex }
    }

    var displayTitle: String {
        if !merchant.isEmpty {
            return merchant
        }
        if !title.isEmpty {
            return title
        }
        return "Bill"
    }

    var itemsSubtotal: Decimal {
        (items ?? []).reduce(Decimal(0)) { $0 + $1.lineTotal }
    }

    /// Full bill amount if every item is counted.
    var grandTotal: Decimal {
        itemsSubtotal + taxAmount + serviceAmount - discountAmount
    }

    /// The user's share, based on which items are ticked, with tax/service/discount split
    /// proportionally to the selected subtotal.
    var totals: BillTotals {
        BillMath.totals(
            lineItems: (items ?? []).map { ($0.lineTotal, $0.isSelected) },
            tax: taxAmount,
            service: serviceAmount,
            discount: discountAmount
        )
    }
}
