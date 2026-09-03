//
//  CategorySeeder.swift
//  Money Laundering
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

        var didInsert = false
        for definition in defaultDefinitions where !existingNames.contains(definition.name.lowercased()) {
            let category = TransactionCategory(
                name: definition.name,
                iconType: .system,
                iconValue: definition.symbolName,
                categoryDescription: definition.description,
                appliesTo: definition.scope,
                isDefault: true
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
        let description: String
        let scope: CategoryScope
    }

    private static let defaultDefinitions: [Definition] = [
        Definition(name: "Food", symbolName: "fork.knife", description: "Meals, groceries, and snacks", scope: .expense),
        Definition(name: "Transport", symbolName: "car.fill", description: "Fuel, rides, and public transit", scope: .expense),
        Definition(name: "Shopping", symbolName: "bag.fill", description: "Clothes, gadgets, and other purchases", scope: .expense),
        Definition(name: "Bills", symbolName: "doc.text.fill", description: "Utilities, subscriptions, and rent", scope: .expense),
        Definition(name: "Entertainment", symbolName: "gamecontroller.fill", description: "Movies, games, and fun", scope: .expense),
        Definition(name: "Health", symbolName: "cross.case.fill", description: "Medicine and healthcare", scope: .expense),
        Definition(name: "Salary", symbolName: "banknote.fill", description: "Monthly salary and wages", scope: .income),
        Definition(name: "Reimburse", symbolName: "arrow.uturn.backward.circle.fill", description: "Money paid back to you for expenses you covered", scope: .income),
        Definition(name: "Gift", symbolName: "gift.fill", description: "Gifts and bonuses received", scope: .income),
        Definition(name: "Other", symbolName: "questionmark.circle.fill", description: "Anything that doesn't fit elsewhere", scope: .both),
    ]
}
