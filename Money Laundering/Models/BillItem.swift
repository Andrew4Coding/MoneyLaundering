//
//  BillItem.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import Foundation
import SwiftData
import AppIntents

@Model
final class BillItem {
    var name: String = ""
    var quantity: Int = 1
    var unitPrice: Decimal = 0
    var lineTotal: Decimal = 0
    var isSelected: Bool = false
    var sortIndex: Int = 0

    var bill: Bill?

    init(
        name: String = "",
        quantity: Int = 1,
        unitPrice: Decimal = 0,
        lineTotal: Decimal = 0,
        isSelected: Bool = false,
        sortIndex: Int = 0
    ) {
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.lineTotal = lineTotal
        self.isSelected = isSelected
        self.sortIndex = sortIndex
    }
}
