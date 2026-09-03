//
//  TransactionType.swift
//  Money Laundering
//

import AppIntents
import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable, AppEnum {
    case expense
    case income

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .expense: "Expense"
        case .income: "Income"
        }
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Transaction Type"
    }

    static var caseDisplayRepresentations: [TransactionType: DisplayRepresentation] {
        [.expense: "Expense", .income: "Income"]
    }
}

