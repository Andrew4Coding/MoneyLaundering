//
//  CategoryBadgeView.swift
//  Money Laundering
//

import SwiftUI

/// Renders a category's "logo" — an SF Symbol for default categories, an emoji for custom ones.
struct CategoryBadgeView: View {
    let category: TransactionCategory?
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: category?.colorHex ?? "8E8E93").opacity(0.18))

            content
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var content: some View {
        if let category {
            switch category.iconType {
            case .system:
                Image(systemName: category.iconValue)
                    .font(.system(size: size * 0.42, weight: .medium))
                    .foregroundStyle(Color(hex: category.colorHex))
            case .emoji:
                Text(category.iconValue)
                    .font(.system(size: size * 0.5))
            }
        } else {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
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

#Preview {
    HStack(spacing: 16) {
        CategoryBadgeView(category: TransactionCategory(name: "Food", iconType: .system, iconValue: "fork.knife", colorHex: "FF9500", isDefault: true))
        CategoryBadgeView(category: TransactionCategory(name: "Gaming", iconType: .emoji, iconValue: "🎮", colorHex: "5856D6"))
        CategoryBadgeView(category: nil)
    }
    .padding()
}
