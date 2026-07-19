//
//  CustomCategoryEditorView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

/// Sheet for creating a custom category with an emoji logo, name, description, and scope.
struct CustomCategoryEditorView: View {
    @Bindable var viewModel: AddTransactionViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Icon") {
                    HStack {
                        Text(viewModel.newCategoryEmoji.isEmpty ? "🙂" : viewModel.newCategoryEmoji)
                            .font(.system(size: 40))
                        TextField("Type an emoji", text: $viewModel.newCategoryEmoji)
                            .font(.title3)
                            .onChange(of: viewModel.newCategoryEmoji) { _, newValue in
                                if let last = newValue.last {
                                    viewModel.newCategoryEmoji = String(last)
                                }
                            }
                    }
                }

                Section("Details") {
                    TextField("Name", text: $viewModel.newCategoryName)
                    TextField("Description", text: $viewModel.newCategoryDescription)
                }

                Section("Applies to") {
                    checkboxRow(title: "Expense", isOn: expenseEnabled) { setExpense($0) }
                    checkboxRow(title: "Income", isOn: incomeEnabled) { setIncome($0) }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.createCustomCategory(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isCustomCategoryValid)
                }
            }
        }
    }

    private var expenseEnabled: Bool {
        viewModel.newCategoryScope == .expense || viewModel.newCategoryScope == .both
    }

    private var incomeEnabled: Bool {
        viewModel.newCategoryScope == .income || viewModel.newCategoryScope == .both
    }

    private func setExpense(_ isOn: Bool) {
        updateScope(expense: isOn, income: incomeEnabled)
    }

    private func setIncome(_ isOn: Bool) {
        updateScope(expense: expenseEnabled, income: isOn)
    }

    /// Keeps at least one scope checked — unchecking the last one is a no-op rather than
    /// leaving the category applicable to nothing.
    private func updateScope(expense: Bool, income: Bool) {
        switch (expense, income) {
        case (true, true): viewModel.newCategoryScope = .both
        case (true, false): viewModel.newCategoryScope = .expense
        case (false, true): viewModel.newCategoryScope = .income
        case (false, false): break
        }
    }

    private func checkboxRow(title: String, isOn: Bool, action: @escaping (Bool) -> Void) -> some View {
        Button {
            action(!isOn)
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isOn ? Color.accentColor : .secondary)
                    .font(.title3)
            }
        }
        .buttonStyle(.plain)
    }
}
