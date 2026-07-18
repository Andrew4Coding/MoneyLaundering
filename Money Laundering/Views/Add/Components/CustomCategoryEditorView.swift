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
                    Picker("Applies to", selection: $viewModel.newCategoryScope) {
                        ForEach(CategoryScope.allCases) { scope in
                            Text(scope.displayName).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
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
}
