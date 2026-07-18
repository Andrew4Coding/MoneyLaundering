//
//  AddTransactionViewModel.swift
//  Money Laundering
//

import Foundation
import SwiftData
import Observation

@Observable
final class AddTransactionViewModel {
    var type: TransactionType = .expense
    var title: String = ""
    var amountText: String = ""
    var source: MoneySource = .bca
    var date: Date = .now
    var descriptionText: String = ""
    var selectedCategory: TransactionCategory?

    var isPresentingCustomCategoryEditor = false
    var newCategoryEmoji: String = ""
    var newCategoryName: String = ""
    var newCategoryDescription: String = ""
    var newCategoryScope: CategoryScope = .expense

    var errorMessage: String?

    /// Non-nil when this view model is editing an existing transaction rather than creating a new one.
    private(set) var editingTransaction: Transaction?

    var isEditing: Bool { editingTransaction != nil }

    init() {}

    init(editing transaction: Transaction) {
        editingTransaction = transaction
        type = transaction.type
        title = transaction.title
        amountText = NSDecimalNumber(decimal: transaction.amount).stringValue
        source = transaction.source
        date = transaction.date
        descriptionText = transaction.transactionDescription
        selectedCategory = transaction.category
    }

    /// Categories applicable to the currently selected transaction type.
    func availableCategories(from allCategories: [TransactionCategory]) -> [TransactionCategory] {
        allCategories
            .filter { $0.appliesTo.allows(type) }
            .sorted { $0.name < $1.name }
    }

    var parsedAmount: Decimal? {
        CurrencyFormatter.parse(amountText)
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && (parsedAmount ?? 0) > 0
            && selectedCategory != nil
    }

    var isCustomCategoryValid: Bool {
        !newCategoryEmoji.trimmingCharacters(in: .whitespaces).isEmpty
            && !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    @discardableResult
    func save(context: ModelContext) -> Bool {
        guard let amount = parsedAmount, isValid else {
            errorMessage = "Please fill in a title, a valid amount, and choose a category."
            return false
        }

        if let editingTransaction {
            editingTransaction.type = type
            editingTransaction.title = title.trimmingCharacters(in: .whitespaces)
            editingTransaction.amount = amount
            editingTransaction.source = source
            editingTransaction.date = date
            editingTransaction.transactionDescription = descriptionText.trimmingCharacters(in: .whitespaces)
            editingTransaction.category = selectedCategory
        } else {
            let transaction = Transaction(
                type: type,
                title: title.trimmingCharacters(in: .whitespaces),
                amount: amount,
                source: source,
                date: date,
                description: descriptionText.trimmingCharacters(in: .whitespaces),
                category: selectedCategory
            )
            context.insert(transaction)
        }
        try? context.save()
        return true
    }

    @discardableResult
    func createCustomCategory(context: ModelContext) -> TransactionCategory? {
        guard isCustomCategoryValid else { return nil }

        let category = TransactionCategory(
            name: newCategoryName.trimmingCharacters(in: .whitespaces),
            iconType: .emoji,
            iconValue: newCategoryEmoji.trimmingCharacters(in: .whitespaces),
            colorHex: "8E8E93",
            categoryDescription: newCategoryDescription.trimmingCharacters(in: .whitespaces),
            appliesTo: newCategoryScope,
            isDefault: false
        )
        context.insert(category)
        try? context.save()

        selectedCategory = category
        newCategoryEmoji = ""
        newCategoryName = ""
        newCategoryDescription = ""
        newCategoryScope = .expense
        isPresentingCustomCategoryEditor = false

        return category
    }
}
