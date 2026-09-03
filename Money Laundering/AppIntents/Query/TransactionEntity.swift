//
//  TransactionEntity.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import AppIntents
import SwiftData
import Foundation

struct TransactionEntity: AppEntity {
    var id: String
    var title: String
    var amount: Decimal
    var date: Date
    var typeName: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Transaction" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(typeName) · \(CurrencyFormatter.rupiah(amount))"
        )
    }

    static var defaultQuery = TransactionEntityQuery()

    init(_ tx: Transaction) {
        self.id = tx.persistentModelID.storeIdentifier ?? UUID().uuidString
        self.title = tx.title
        self.amount = tx.amount
        self.date = tx.date
        self.typeName = tx.type.rawValue
    }
}

struct TransactionEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [TransactionEntity] {
        let context = Persistance.container.mainContext
        return try context.fetch(FetchDescriptor<Transaction>())
            .map(TransactionEntity.init)
            .filter { identifiers.contains($0.id) }
    }
}
