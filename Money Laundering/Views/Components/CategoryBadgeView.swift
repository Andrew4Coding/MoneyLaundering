//
//  CategoryBadgeView.swift
//  Money Laundering
//

import SwiftUI

/// Renders a category's logo. Every category shares one fixed colour — they are told apart by
/// symbol and name, not by colour.
struct CategoryBadgeView: View {
    let category: TransactionCategory?
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.categoryColor.opacity(0.18))

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
                    .foregroundStyle(AppTheme.categoryColor)
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

#Preview {
    HStack(spacing: 16) {
        CategoryBadgeView(category: TransactionCategory(name: "Food", iconType: .system, iconValue: "fork.knife", isDefault: true))
        CategoryBadgeView(category: TransactionCategory(name: "Salary", iconType: .system, iconValue: "banknote.fill", isDefault: true))
        CategoryBadgeView(category: nil)
    }
    .padding()
}
