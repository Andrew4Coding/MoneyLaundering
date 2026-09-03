//
//  CustomCategoryEditorView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

struct CustomCategoryEditorView: View {
    @Bindable var viewModel: AddTransactionViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $viewModel.newCategoryName)
                    TextField("Description", text: $viewModel.newCategoryDescription)
                }

                Section {
                    iconRow
                } footer: {
                    if viewModel.isAppleIntelligenceIconAvailable {
                        Text("Chosen automatically by Apple Intelligence from the name and description.")
                    }
                }

                Section("Applies to") {
                    checkboxRow(title: "Expense", isOn: expenseEnabled) { setExpense($0) }
                    checkboxRow(title: "Income", isOn: incomeEnabled) { setIncome($0) }
                }
            }
            .onChange(of: viewModel.newCategoryName) { viewModel.requestIconSuggestion() }
            .onChange(of: viewModel.newCategoryDescription) { viewModel.requestIconSuggestion() }
            .onChange(of: viewModel.newCategoryScope) { viewModel.requestIconSuggestion() }
            .navigationTitle(viewModel.isEditingCategory ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditingCategory ? "Save" : "Add") {
                        viewModel.saveCustomCategory(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isCustomCategoryValid)
                }
            }
        }
    }

    private var iconRow: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.resolvedCategorySymbol)
                .font(.title3)
                .foregroundStyle(AppTheme.categoryColor)
                .frame(width: 32, height: 32)
                .background(AppTheme.categoryColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))

            Text("Icon")
            Spacer()

            if viewModel.isSuggestingCategoryIcon {
                ProgressView()
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
