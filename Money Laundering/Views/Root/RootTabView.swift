//
//  RootTabView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

private struct SharedReceipt: Identifiable {
    let id = UUID()
    let imageData: Data
}

/// Tab shell (Home, Transactions, Bills, Account). The center "search" slot adds a plain
struct RootTabView: View {
    @Binding var pendingReceiptImageData: Data?

    @State private var isPresentingScanBill = false
    @State private var isPresentingAddTransaction = false
    @State private var sharedReceipt: SharedReceipt?
    @State private var selection = 0
    @State private var previousSelection = 0

    private var isBillsContext: Bool { selection == 2 }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView()
            }

            Tab("Transactions", systemImage: "list.bullet", value: 1) {
                TransactionsListView()
            }

            Tab("Bills", systemImage: "doc.text.image", value: 2) {
                BillsListView()
            }

            Tab("Account", systemImage: "person.crop.circle", value: 3) {
                AccountView()
            }

            Tab(
                isBillsContext ? "Scan Bill" : "Add Transaction",
                systemImage: isBillsContext ? "doc.viewfinder" : "plus",
                value: 4,
                role: .search
            ) {
                Color.clear
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            guard newValue == 4 else {
                previousSelection = newValue
                return
            }
            if oldValue == 2 {
                isPresentingScanBill = true
            } else {
                isPresentingAddTransaction = true
            }
            selection = previousSelection
        }
        .onChange(of: pendingReceiptImageData) { _, newValue in
            presentSharedTransactionIfNeeded(newValue)
        }
        .task {
            presentSharedTransactionIfNeeded(pendingReceiptImageData)
        }
        .sheet(isPresented: $isPresentingScanBill) {
            BillEditorView()
        }
        .sheet(isPresented: $isPresentingAddTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $isPresentingSharedTransaction) {
            AddTransactionView(receiptImageData: sharedReceiptImageData)
        }
    }

    private func presentSharedTransactionIfNeeded(_ data: Data?) {
        guard let data else { return }
        sharedReceiptImageData = data
        pendingReceiptImageData = nil
        isPresentingSharedTransaction = true
    }
}

#Preview {
    RootTabView(pendingReceiptImageData: .constant(nil))
        .modelContainer(for: [Transaction.self, TransactionCategory.self, Bill.self, BillItem.self], inMemory: true)
}
