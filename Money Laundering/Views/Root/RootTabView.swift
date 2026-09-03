//
//  RootTabView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

/// Tab shell (Home, Transactions, Bills, Account). The center "search" slot is a scan button
/// that opens the new-bill editor. Adding a plain transaction lives on the Transactions tab.
struct RootTabView: View {
    @State private var isPresentingScanBill = false
    @State private var selection = 0
    @State private var previousSelection = 0

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

            Tab("Scan Bill", systemImage: "doc.viewfinder", value: 4, role: .search) {
                Color.clear
            }
        }
        .onChange(of: selection) { _, newValue in
            guard newValue == 4 else {
                previousSelection = newValue
                return
            }
            isPresentingScanBill = true
            selection = previousSelection
        }
        .sheet(isPresented: $isPresentingScanBill) {
            BillEditorView()
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Transaction.self, TransactionCategory.self, Bill.self, BillItem.self], inMemory: true)
}
