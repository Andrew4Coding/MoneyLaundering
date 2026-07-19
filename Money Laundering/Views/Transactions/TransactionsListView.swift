//
//  TransactionsListView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionsListViewModel()
    @Binding var isPresentingAdd: Bool

    private var filteredTransactions: [Transaction] {
        viewModel.filtered(allTransactions)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TransactionFilterBar(selectedPeriod: $viewModel.selectedPeriod, customRange: $viewModel.customRange)
                    .padding(.vertical, 8)

                List {
                    ForEach(filteredTransactions, id: \.persistentModelID) { transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: transaction)
                        } label: {
                            TransactionRowView(transaction: transaction)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .overlay {
                    if filteredTransactions.isEmpty {
                        EmptyStateView(
                            systemImage: "tray",
                            title: "No Transactions",
                            message: "Try a different date range or search term."
                        )
                    }
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: $viewModel.searchText, prompt: "Search title, description, or category")
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredTransactions[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    TransactionsListView(isPresentingAdd: .constant(false))
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
