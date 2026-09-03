//
//  TransactionType.swift
//  Money Laundering
//

import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
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
}
