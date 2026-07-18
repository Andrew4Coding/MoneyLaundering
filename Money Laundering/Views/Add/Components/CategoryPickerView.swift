//
//  CategoryPickerView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

/// Horizontal scrolling grid of category chips, filtered to the current transaction type,
/// plus a trailing "New" chip that opens the custom category editor.
struct CategoryPickerView: View {
    let categories: [TransactionCategory]
    @Binding var selection: TransactionCategory?
    let onCreateNew: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 76), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.persistentModelID) { category in
                Button {
                    selection = category
                } label: {
                    VStack(spacing: 6) {
                        CategoryBadgeView(category: category, size: 48)
                            .overlay(
                                Circle()
                                    .strokeBorder(selection?.id == category.id ? Color.accentColor : .clear, lineWidth: 2)
                            )
                        Text(category.name)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }

            Button(action: onCreateNew) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 48, height: 48)
                    Text("New")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
