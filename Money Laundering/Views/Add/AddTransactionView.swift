//
//  AddTransactionView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TransactionCategory.name) private var allCategories: [TransactionCategory]

    @State private var viewModel: AddTransactionViewModel

    init(transaction: Transaction? = nil) {
        if let transaction {
            _viewModel = State(initialValue: AddTransactionViewModel(editing: transaction))
        } else {
            _viewModel = State(initialValue: AddTransactionViewModel())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $viewModel.type) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.type) { _, _ in
                        if let selected = viewModel.selectedCategory, !selected.appliesTo.allows(viewModel.type) {
                            viewModel.selectedCategory = nil
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section("Amount") {
                    TextField("Rp 0", text: $viewModel.amountText)
                        .keyboardType(.numberPad)
                        .font(.title2.weight(.semibold))
                }

                Section("Category") {
                    CategoryPickerView(
                        categories: viewModel.availableCategories(from: allCategories),
                        selection: $viewModel.selectedCategory,
                        onCreateNew: { viewModel.isPresentingCustomCategoryEditor = true }
                    )
                    .padding(.vertical, 4)
                }

                Section("Details") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Description", text: $viewModel.descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Source") {
                    MoneySourcePickerView(selection: $viewModel.source)
                }

                Section("Date") {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Transaction" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save(context: modelContext) {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: $viewModel.isPresentingCustomCategoryEditor) {
                CustomCategoryEditorView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
