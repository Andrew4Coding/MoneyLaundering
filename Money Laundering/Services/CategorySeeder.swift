//
//  CategorySeeder.swift
//  Money Laundering
//

import Foundation
import SwiftData

enum CategorySeeder {
    /// Seeds the default category set once. Idempotent — safe to call on every launch.
    static func seedIfNeeded(context: ModelContext) {
        var descriptor = FetchDescriptor<TransactionCategory>(predicate: #Predicate { $0.isDefault == true })
        descriptor.fetchLimit = 1

        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        for definition in defaultDefinitions {
            let category = TransactionCategory(
                name: definition.name,
                iconType: .system,
                iconValue: definition.symbolName,
                colorHex: definition.colorHex,
                categoryDescription: definition.description,
                appliesTo: definition.scope,
                isDefault: true
            )
            context.insert(category)
        }

        try? context.save()
    }

    private struct Definition {
        let name: String
        let symbolName: String
        let colorHex: String
        let description: String
        let scope: CategoryScope
    }

    private static let defaultDefinitions: [Definition] = [
        Definition(name: "Food", symbolName: "fork.knife", colorHex: "FF9500", description: "Meals, groceries, and snacks", scope: .expense),
        Definition(name: "Transport", symbolName: "car.fill", colorHex: "34C759", description: "Fuel, rides, and public transit", scope: .expense),
        Definition(name: "Shopping", symbolName: "bag.fill", colorHex: "FF2D55", description: "Clothes, gadgets, and other purchases", scope: .expense),
        Definition(name: "Bills", symbolName: "doc.text.fill", colorHex: "5856D6", description: "Utilities, subscriptions, and rent", scope: .expense),
        Definition(name: "Entertainment", symbolName: "gamecontroller.fill", colorHex: "AF52DE", description: "Movies, games, and fun", scope: .expense),
        Definition(name: "Health", symbolName: "cross.case.fill", colorHex: "FF3B30", description: "Medicine and healthcare", scope: .expense),
        Definition(name: "Salary", symbolName: "banknote.fill", colorHex: "30D158", description: "Monthly salary and wages", scope: .income),
        Definition(name: "Gift", symbolName: "gift.fill", colorHex: "FFD60A", description: "Gifts and bonuses received", scope: .income),
        Definition(name: "Other", symbolName: "questionmark.circle.fill", colorHex: "8E8E93", description: "Anything that doesn't fit elsewhere", scope: .both),
    ]
}
