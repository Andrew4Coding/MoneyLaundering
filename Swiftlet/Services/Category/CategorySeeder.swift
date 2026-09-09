//
//  CategorySeeder.swift
//  Swiftlet
//

import Foundation
import SwiftData

enum CategorySeeder {
    static func seedIfNeeded(context: ModelContext) {
        mergeDuplicates(context: context)

        let existingNames = Set(
            ((try? context.fetch(FetchDescriptor<TransactionCategory>())) ?? [])
                .map { $0.name.lowercased() }
        )

        let startIndex = (((try? context.fetch(FetchDescriptor<TransactionCategory>())) ?? [])
            .map(\.sortIndex).max() ?? -1) + 1

        var didInsert = false
        for (offset, definition) in defaultDefinitions.enumerated()
            where !existingNames.contains(definition.name.lowercased())
        {
            let category = TransactionCategory(
                name: definition.name,
                iconType: .system,
                iconValue: definition.symbolName,
                appliesTo: definition.scope,
                isDefault: true,
                sortIndex: startIndex + offset
            )
            context.insert(category)
            didInsert = true
        }

        if didInsert {
            try? context.save()
        }
    }

    private static func mergeDuplicates(context: ModelContext) {
        guard let allCategories = try? context.fetch(FetchDescriptor<TransactionCategory>()) else { return }

        let groups = Dictionary(grouping: allCategories) { $0.name.lowercased() }

        var didDelete = false
        for group in groups.values where group.count > 1 {
            let sorted = group.sorted { $0.createdAt < $1.createdAt }
            guard let keeper = sorted.first else { continue }

            for duplicate in sorted.dropFirst() {
                for transaction in duplicate.transactions ?? [] {
                    transaction.category = keeper
                }
                context.delete(duplicate)
                didDelete = true
            }
        }

        if didDelete {
            try? context.save()
        }
    }

    private struct Definition {
        let name: String
        let symbolName: String
        let scope: CategoryScope
    }

    private static let defaultDefinitions: [Definition] = [
        Definition(name: "Food", symbolName: "fork.knife", scope: .expense),
        Definition(name: "Transport", symbolName: "car.fill", scope: .expense),
        Definition(name: "Shopping", symbolName: "bag.fill", scope: .expense),
        Definition(name: "Bills", symbolName: "doc.text.fill", scope: .expense),
        Definition(name: "Entertainment", symbolName: "gamecontroller.fill", scope: .expense),
        Definition(name: "Health", symbolName: "cross.case.fill", scope: .expense),
        Definition(name: "Salary", symbolName: "banknote.fill", scope: .income),
        Definition(name: "Reimburse", symbolName: "arrow.uturn.backward.circle.fill", scope: .income),
        Definition(name: "Gift", symbolName: "gift.fill", scope: .income),
        Definition(name: "Other", symbolName: "questionmark.circle.fill", scope: .both),
    ]
}
