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

    private let iconColumns = [GridItem(.adaptive(minimum: 44), spacing: 12)]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $viewModel.newCategoryName)
                }

                Section {
                    iconPreviewRow
                    iconGrid
                } header: {
                    Text("Icon")
                } footer: {
                    if viewModel.isUsingAutomaticIcon, viewModel.isAppleIntelligenceIconAvailable {
                        Text("Chosen automatically by Apple Intelligence from the name. Tap an icon to pick one yourself.")
                    } else if viewModel.isUsingAutomaticIcon {
                        Text("Chosen automatically from the name. Tap an icon to pick one yourself.")
                    }
                }

                Section("Applies to") {
                    checkboxRow(title: "Expense", isOn: expenseEnabled) { setExpense($0) }
                    checkboxRow(title: "Income", isOn: incomeEnabled) { setIncome($0) }
                }
            }
            .onChange(of: viewModel.newCategoryName) { viewModel.requestIconSuggestion() }
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

    private var iconPreviewRow: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.resolvedCategorySymbol)
                .font(.title3)
                .foregroundStyle(AppTheme.categoryColor)
                .frame(width: 32, height: 32)
                .background(AppTheme.categoryColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))

            Text(viewModel.isUsingAutomaticIcon ? "Automatic" : "Custom")
                .foregroundStyle(.secondary)
            Spacer()

            if viewModel.isSuggestingCategoryIcon {
                ProgressView()
            } else if !viewModel.isUsingAutomaticIcon {
                Button("Auto") {
                    viewModel.manuallyPickedSymbol = nil
                    viewModel.requestIconSuggestion()
                }
                .font(.footnote.weight(.semibold))
            }
        }
    }

    private var iconGrid: some View {
        LazyVGrid(columns: iconColumns, spacing: 12) {
            ForEach(CategoryIconIntelligence.iconOptions, id: \.self) { symbol in
                let isSelected = !viewModel.isUsingAutomaticIcon && viewModel.resolvedCategorySymbol == symbol
                Button {
                    viewModel.manuallyPickedSymbol = symbol
                } label: {
                    Image(systemName: symbol)
                        .font(.body)
                        .foregroundStyle(isSelected ? Color.white : AppTheme.categoryColor)
                        .frame(width: 44, height: 44)
                        .background(
                            isSelected ? AppTheme.categoryColor : AppTheme.categoryColor.opacity(0.14),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
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
