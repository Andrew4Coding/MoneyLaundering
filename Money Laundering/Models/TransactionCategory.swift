//
//  TransactionCategory.swift
//  Money Laundering
//

import Foundation
import SwiftData

enum CategoryIconType: String, Codable {
    case system
    case emoji
}

enum CategoryScope: String, Codable, CaseIterable, Identifiable {
    case expense
    case income
    case both

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .expense: "Expense"
        case .income: "Income"
        case .both: "Both"
        }
    }

    func allows(_ type: TransactionType) -> Bool {
        switch self {
        case .expense: type == .expense
        case .income: type == .income
        case .both: true
        }
    }
}

/// Named `TransactionCategory` (not `Category`) to avoid colliding with `ObjectiveC.Category`,
/// a typealias to `OpaquePointer` auto-imported via Foundation — using `Category` here silently
/// resolves to that opaque C type instead of this model.
@Model
final class TransactionCategory {
    var name: String = ""
    var iconTypeRaw: String = CategoryIconType.system.rawValue
    var iconValue: String = "questionmark.circle"
    var colorHex: String = "8E8E93"
    var categoryDescription: String = ""
    var appliesToRaw: String = CategoryScope.both.rawValue
    var isDefault: Bool = false
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]? = []

    var iconType: CategoryIconType {
        get { CategoryIconType(rawValue: iconTypeRaw) ?? .system }
        set { iconTypeRaw = newValue.rawValue }
    }

    var appliesTo: CategoryScope {
        get { CategoryScope(rawValue: appliesToRaw) ?? .both }
        set { appliesToRaw = newValue.rawValue }
    }

    init(
        name: String,
        iconType: CategoryIconType,
        iconValue: String,
        colorHex: String,
        categoryDescription: String = "",
        appliesTo: CategoryScope = .both,
        isDefault: Bool = false,
        createdAt: Date = .now
    ) {
        self.name = name
        self.iconTypeRaw = iconType.rawValue
        self.iconValue = iconValue
        self.colorHex = colorHex
        self.categoryDescription = categoryDescription
        self.appliesToRaw = appliesTo.rawValue
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
}
