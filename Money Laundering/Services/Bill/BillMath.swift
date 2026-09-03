//
//  BillMath.swift
//  Money Laundering
//

import Foundation

/// The user's computed share of a bill.
struct BillTotals: Equatable {
    var selectedSubtotal: Decimal
    var taxShare: Decimal
    var serviceShare: Decimal
    var discountShare: Decimal
    var grandTotal: Decimal
    /// Selected subtotal as a fraction of the full item subtotal (0...1).
    var fraction: Double
    var hasSelection: Bool
}

/// Splits a bill's shared charges (tax, service, discount) across the items the user ticked,
/// proportionally to their share of the item subtotal.
enum BillMath {
    static func totals(
        lineItems: [(amount: Decimal, selected: Bool)],
        tax: Decimal,
        service: Decimal,
        discount: Decimal
    ) -> BillTotals {
        let fullSubtotal = lineItems.reduce(Decimal(0)) { $0 + $1.amount }
        let selectedSubtotal = lineItems.filter(\.selected).reduce(Decimal(0)) { $0 + $1.amount }

        guard fullSubtotal > 0, selectedSubtotal > 0 else {
            return BillTotals(
                selectedSubtotal: 0,
                taxShare: 0,
                serviceShare: 0,
                discountShare: 0,
                grandTotal: 0,
                fraction: 0,
                hasSelection: false
            )
        }

        let ratio = selectedSubtotal / fullSubtotal
        let taxShare = rounded(tax * ratio)
        let serviceShare = rounded(service * ratio)
        let discountShare = rounded(discount * ratio)

        return BillTotals(
            selectedSubtotal: selectedSubtotal,
            taxShare: taxShare,
            serviceShare: serviceShare,
            discountShare: discountShare,
            grandTotal: selectedSubtotal + taxShare + serviceShare - discountShare,
            fraction: (ratio as NSDecimalNumber).doubleValue,
            hasSelection: true
        )
    }

    /// Rounds to whole Rupiah.
    static func rounded(_ value: Decimal) -> Decimal {
        var input = value
        var result = Decimal()
        NSDecimalRound(&result, &input, 0, .plain)
        return result
    }
}
