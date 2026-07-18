//
//  Transaction.swift
//  Money Laundering
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var typeRaw: String = TransactionType.expense.rawValue
    var title: String = ""
    var amount: Decimal = 0
    var sourceRaw: String = MoneySource.bca.rawValue
    var date: Date = Date.now
    var transactionDescription: String = ""
    var createdAt: Date = Date.now

    var category: TransactionCategory?

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var source: MoneySource {
        get { MoneySource(rawValue: sourceRaw) ?? .bca }
        set { sourceRaw = newValue.rawValue }
    }

    init(
        type: TransactionType,
        title: String,
        amount: Decimal,
        source: MoneySource,
        date: Date,
        description: String = "",
        category: TransactionCategory?,
        createdAt: Date = .now
    ) {
        self.typeRaw = type.rawValue
        self.title = title
        self.amount = amount
        self.sourceRaw = source.rawValue
        self.date = date
        self.transactionDescription = description
        self.category = category
        self.createdAt = createdAt
    }
}
