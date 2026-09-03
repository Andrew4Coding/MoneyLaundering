//
//  MoneySource.swift
//  Money Laundering
//

import Foundation

enum MoneySource: String, Codable, CaseIterable, Identifiable {
    case grab
    case gopay
    case bca
    case bni
    case ovo
    case qris

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .grab: "Grab"
        case .gopay: "GoPay"
        case .bca: "BCA"
        case .bni: "BNI"
        case .ovo: "OVO"
        case .qris: "QRIS"
        }
    }

    /// Asset catalog image name, or `nil` for sources drawn with an SF Symbol instead.
    var imageName: String? {
        switch self {
        case .grab: "grab"
        case .gopay: "gopay"
        case .bca: "bca"
        case .bni: "bni"
        case .ovo, .qris: nil
        }
    }

    /// SF Symbol fallback used when the source has no logo in the asset catalog.
    var symbolName: String {
        switch self {
        case .qris: "qrcode"
        default: "creditcard.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .grab: "00B14F"
        case .gopay: "00AED6"
        case .bca: "0066AE"
        case .bni: "F37021"
        case .ovo: "4C3494"
        case .qris: "1E4C9A"
        }
    }

    /// Which transaction types this source can be used with. Grab is spend-only and QRIS is
    /// receive-only; everything else works both ways.
    var scope: CategoryScope {
        switch self {
        case .grab: .expense
        case .qris: .income
        case .gopay, .bca, .bni, .ovo: .both
        }
    }

    static func available(for type: TransactionType) -> [MoneySource] {
        allCases.filter { $0.scope.allows(type) }
    }
}
