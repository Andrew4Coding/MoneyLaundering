//
//  BillEditorViewModel.swift
//  Money Laundering
//

import Foundation
import Observation
import OSLog
import SwiftData

/// One editable bill-item row. Amounts are held as digit strings so the text fields stay simple.
struct DraftBillItem: Identifiable {
    var id = UUID()
    var name: String = ""
    var quantity: Int = 1
    var amountText: String = ""
    var isSelected: Bool = false

    var amount: Decimal {
        CurrencyFormatter.parse(amountText) ?? 0
    }
}

@Observable
@MainActor
final class BillEditorViewModel {
    enum ScanState: Equatable {
        case idle
        case scanning
        case done
        case failed(String)
    }

    var title: String = ""
    var merchant: String = ""
    var date: Date = .now
    var imageData: Data?

    var items: [DraftBillItem] = []
    var taxText: String = ""
    var serviceText: String = ""
    var discountText: String = ""

    var scanState: ScanState = .idle
    /// True when the last successful scan came from the regex heuristic rather than the model.
    var usedHeuristicScan = false

    private(set) var editingBill: Bill?
    private var rawText: String = ""

    var isEditing: Bool {
        editingBill != nil
    }

    init() {}

    init(editing bill: Bill) {
        editingBill = bill
        title = bill.title
        merchant = bill.merchant
        date = bill.date
        imageData = bill.imageData
        rawText = bill.rawText
        taxText = CurrencyFormatter.plainAmount(bill.taxAmount)
        serviceText = CurrencyFormatter.plainAmount(bill.serviceAmount)
        discountText = CurrencyFormatter.plainAmount(bill.discountAmount)
        items = bill.sortedItems.map { item in
            DraftBillItem(
                name: item.name,
                quantity: item.quantity,
                amountText: CurrencyFormatter.plainAmount(item.lineTotal),
                isSelected: item.isSelected
            )
        }
    }

    var tax: Decimal {
        CurrencyFormatter.parse(taxText) ?? 0
    }

    var service: Decimal {
        CurrencyFormatter.parse(serviceText) ?? 0
    }

    var discount: Decimal {
        CurrencyFormatter.parse(discountText) ?? 0
    }

    var canScan: Bool {
        imageData != nil
    }

    var totals: BillTotals {
        BillMath.totals(
            lineItems: items.map { ($0.amount, $0.isSelected) },
            tax: tax,
            service: service,
            discount: discount
        )
    }

    var isValid: Bool {
        imageData != nil || !items.isEmpty || !merchant.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func addItem() {
        items.append(DraftBillItem())
    }

    func removeItems(at offsets: IndexSet) {
        items = items.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map(\.element)
    }

    /// OCRs the current photo and fills in items/charges. Only overwrites fields the user
    /// hasn't already filled.
    func runScan() async {
        guard let imageData else { return }
        scanState = .scanning

        switch await BillScanner.scan(imageData: imageData) {
        case let .failure(message):
            AppLog.billScan.error("Bill scan needs a rescan: \(message, privacy: .public)")
            scanState = .failed(message)
        case let .success(parsed, usedAI):
            if parsed.items.isEmpty {
                AppLog.billScan.notice("Bill scan produced no items; user must add them or rescan")
            }
            usedHeuristicScan = !usedAI
            rawText = parsed.rawText
            if merchant.trimmingCharacters(in: .whitespaces).isEmpty {
                merchant = parsed.merchant
            }
            if !parsed.items.isEmpty {
                items = parsed.items.enumerated().map { _, item in
                    DraftBillItem(
                        name: item.name,
                        quantity: item.quantity,
                        amountText: CurrencyFormatter.plainAmount(item.lineTotal),
                        isSelected: false
                    )
                }
            }
            if taxText.isEmpty {
                taxText = CurrencyFormatter.plainAmount(parsed.tax)
            }
            if serviceText.isEmpty {
                serviceText = CurrencyFormatter.plainAmount(parsed.service)
            }
            if discountText.isEmpty {
                discountText = CurrencyFormatter.plainAmount(parsed.discount)
            }
            scanState = .done
        }
    }

    @discardableResult
    func save(context: ModelContext) -> Bool {
        guard isValid else { return false }

        let bill = editingBill ?? Bill()
        bill.title = title.trimmingCharacters(in: .whitespaces)
        bill.merchant = merchant.trimmingCharacters(in: .whitespaces)
        bill.date = date
        bill.imageData = imageData
        bill.rawText = rawText
        bill.taxAmount = tax
        bill.serviceAmount = service
        bill.discountAmount = discount

        switch scanState {
        case .done:
            bill.scanStatus = .scanned
        case .failed:
            if bill.scanStatus != .scanned {
                bill.scanStatus = .failed
            }
        case .idle, .scanning:
            if editingBill == nil {
                bill.scanStatus = .manual
            }
        }

        if editingBill == nil {
            context.insert(bill)
        }

        for existing in bill.items ?? [] {
            context.delete(existing)
        }

        let rebuilt = items.enumerated().map { index, draft -> BillItem in
            let quantity = max(1, draft.quantity)
            let item = BillItem(
                name: draft.name.trimmingCharacters(in: .whitespaces),
                quantity: quantity,
                unitPrice: BillMath.rounded(draft.amount / Decimal(quantity)),
                lineTotal: draft.amount,
                isSelected: draft.isSelected,
                sortIndex: index
            )
            item.bill = bill
            context.insert(item)
            return item
        }
        bill.items = rebuilt

        try? context.save()
        return true
    }
}
