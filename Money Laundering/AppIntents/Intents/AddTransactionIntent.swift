//
//  AddTransactionIntent.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import Foundation
import AppIntents
import SwiftData

struct AddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Transaction"
    static var description = IntentDescription("Records a new income or expense.")
    static var openAppWhenRun = false

    @Parameter(title: "Amount") var amount: Double
    @Parameter(title: "Title") var name: String
    @Parameter(title: "Type", default: TransactionType.expense) var type: TransactionType
    @Parameter(title: "Source", default: MoneySource.bca) var source: MoneySource
    @Parameter(title: "Category") var category: CategoryEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$type) of \(\.$amount) for \(\.$name)") {
            \.$source
            \.$category
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = Persistance.container.mainContext

        let all = try context.fetch(FetchDescriptor<TransactionCategory>())
        let matchedCategory = all.first {
            $0.name.localizedCaseInsensitiveCompare(category.name) == .orderedSame
        }

        let tx = Transaction(
            type: type,
            title: name,
            amount: Decimal(amount),
            source: source,
            date: .now,
            category: matchedCategory
        )
        context.insert(tx)
        try context.save()

        return .result(dialog: "Added \(CurrencyFormatter.rupiah(Decimal(amount))) — \(name).")
    }
}
