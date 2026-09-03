//
//  AppTheme.swift
//  Money Laundering
//

import SwiftUI

enum AppTheme {
    /// The single accent colour used app-wide, replacing the previous orange tint.
    static let accent = Color(hex: "0A84FF")

    /// Every category renders in this one colour — categories are distinguished by their
    /// symbol and name, not by per-category colours.
    static let categoryColor = Color(hex: "0A84FF")
}

extension Color {
    /// Creates a color from a hex string like "FF9500" or "#FF9500".
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
