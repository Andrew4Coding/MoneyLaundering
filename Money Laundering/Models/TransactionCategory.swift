//
//  TransactionCategory.swift
//  Money Laundering
//

import Foundation
import SwiftData

enum CategoryIconType: String, Codable {
    case system
}

enum CategoryScope: String, Codable, CaseIterable, Identifiable {
    case expense
    case income
    case both

    var id: String {
        rawValue
    }

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
@Model
final class TransactionCategory {
    var name: String = ""
    var iconTypeRaw: String = CategoryIconType.system.rawValue
    var iconValue: String = "questionmark.circle"
    var appliesToRaw: String = CategoryScope.both.rawValue
    var isDefault: Bool = false
    var isPinned: Bool = false
    var sortIndex: Int = 0
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
        appliesTo: CategoryScope = .both,
        isDefault: Bool = false,
        isPinned: Bool = false,
        sortIndex: Int = 0,
        createdAt: Date = .now
    ) {
        self.name = name
        iconTypeRaw = iconType.rawValue
        self.iconValue = iconValue
        appliesToRaw = appliesTo.rawValue
        self.isDefault = isDefault
        self.isPinned = isPinned
        self.sortIndex = sortIndex
        self.createdAt = createdAt
    }

    /// Lightweight category identified by name only (icon/scope left at defaults).
    convenience init(name: String) {
        self.init(name: name, iconType: .system, iconValue: "questionmark.circle")
    }
}

extension TransactionCategory {
    @MainActor
    static func matching(_ name: String, in context: ModelContext) -> TransactionCategory? {
        let all = (try? context.fetch(FetchDescriptor<TransactionCategory>())) ?? []
        return all.first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
            ?? all.first { $0.name.localizedCaseInsensitiveContains(name) || name.localizedCaseInsensitiveContains($0.name) }
            ?? all.first { $0.name.caseInsensitiveCompare("Other") == .orderedSame }
    }
}
