//
//  CategoryPickerListView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

struct CategoryPickerListView: View {
    let categories: [TransactionCategory]
    @Binding var selection: TransactionCategory?
    let onCreateNew: () -> Void
    let onEdit: (TransactionCategory) -> Void
    let onDelete: (TransactionCategory) -> Void
    let onTogglePin: (TransactionCategory) -> Void

    @Environment(\.dismiss) private var dismiss

    private var pinnedCategories: [TransactionCategory] {
        categories.filter(\.isPinned)
    }

    private var unpinnedCategories: [TransactionCategory] {
        categories.filter { !$0.isPinned }
    }

    var body: some View {
        List {
            if !pinnedCategories.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedCategories, id: \.persistentModelID) { category in
                        row(for: category)
                    }
                }
            }

            Section("All Categories") {
                ForEach(unpinnedCategories, id: \.persistentModelID) { category in
                    row(for: category)
                }
            }
        }
        .navigationTitle("Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCreateNew) {
                    Label("New Category", systemImage: "plus")
                }
            }
        }
    }

    private func row(for category: TransactionCategory) -> some View {
        Button {
            selection = category
            dismiss()
        } label: {
            HStack(spacing: 12) {
                CategoryBadgeView(category: category, size: 36)
                Text(category.name)
                    .foregroundStyle(.primary)
                Spacer()
                if selection?.persistentModelID == category.persistentModelID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .font(.body.weight(.semibold))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(category)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                onEdit(category)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading) {
            Button {
                onTogglePin(category)
            } label: {
                Label(category.isPinned ? "Unpin" : "Pin", systemImage: category.isPinned ? "pin.slash" : "pin")
            }
            .tint(AppTheme.accent)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryPickerListView(
            categories: [
                TransactionCategory(name: "Food", iconType: .system, iconValue: "fork.knife", isDefault: true, isPinned: true),
                TransactionCategory(name: "Transport", iconType: .system, iconValue: "car.fill", isDefault: true),
            ],
            selection: .constant(nil),
            onCreateNew: {},
            onEdit: { _ in },
            onDelete: { _ in },
            onTogglePin: { _ in }
        )
    }
}
