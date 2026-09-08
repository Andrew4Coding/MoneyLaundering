//
//  AddTransactionIntent.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import AppIntents
import Foundation
import SwiftData

struct AddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Transaction"
    static var description = IntentDescription("Records a new income or expense.")
    static var openAppWhenRun = false

    @Parameter(title: "Amount") var amount: Double
    @Parameter(title: "Title") var name: String
    @Parameter(title: "Type", default: TransactionType.expense) var type: TransactionType
    @Parameter(title: "Source", default: MoneySource.bca) var source: MoneySource
    @Parameter(title: "Category", requestValueDialog: "Which category? Leave blank to auto-detect")
    var category: CategoryEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$type) of \(\.$amount) for \(\.$name)") {
            \.$source
            \.$category
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = Persistance.container.mainContext
        let all = try context.fetch(FetchDescriptor<TransactionCategory>(sortBy: [SortDescriptor(\.name)]))

        let resolvedCategory = await resolveCategory(from: all, context: context)

        let tx = Transaction(
            type: type,
            title: name,
            amount: Decimal(amount),
            source: source,
            date: .now,
            category: resolvedCategory
        )
        context.insert(tx)
        try context.save()

        let suffix = resolvedCategory.map { " in \($0.name)" } ?? ""
        return .result(dialog: "Added \(CurrencyFormatter.rupiah(Decimal(amount))) — \(name)\(suffix).")
    }

    /// Uses the picked category, otherwise asks the on-device model to classify by title, falling back to "Other".
    @MainActor
    private func resolveCategory(
        from all: [TransactionCategory],
        context _: ModelContext
    ) async -> TransactionCategory? {
        if let category {
            return all.first { $0.name.localizedCaseInsensitiveCompare(category.name) == .orderedSame }
        }

        let eligible = all.filter { $0.appliesTo.allows(type) }
        if let guess = await CategoryClassifier.classify(
            title: name,
            type: type,
            among: eligible.map(\.name)
        ) {
            return eligible.first { $0.name == guess }
        }

        return all.first { $0.name.caseInsensitiveCompare("Other") == .orderedSame }
    }
}
