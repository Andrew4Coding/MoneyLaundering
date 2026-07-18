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

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grab: "Grab"
        case .gopay: "GoPay"
        case .bca: "BCA"
        case .bni: "BNI"
        }
    }

    /// Asset catalog image name for each source's logo.
    var imageName: String {
        switch self {
        case .grab: "grab"
        case .gopay: "gopay"
        case .bca: "bca"
        case .bni: "bni"
        }
    }

    var colorHex: String {
        switch self {
        case .grab: "00B14F"
        case .gopay: "00AED6"
        case .bca: "0066AE"
        case .bni: "F37021"
        }
    }
}
