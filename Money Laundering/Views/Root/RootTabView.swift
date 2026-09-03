//
//  RootTabView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

/// 2-tab shell (Home, Transactions). The "Add" action is exposed as a bottom-bar toolbar
/// button inside each tab's navigation stack so the system manages its placement alongside
/// the tab bar. Stats lives inside Home rather than as a separate tab.
struct RootTabView: View {
    @State private var isPresentingAdd = false
    @State private var selection = 0
    @State private var previousSelection = 0

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(isPresentingAdd: $isPresentingAdd)
            }

            Tab("Transactions", systemImage: "list.bullet", value: 1) {
                TransactionsListView(isPresentingAdd: $isPresentingAdd)
            }

            Tab("Account", systemImage: "person.crop.circle", value: 2) {
                AccountView()
            }

            Tab("Plus", systemImage: "plus", value: 3, role: .search) {
                Color.clear
            }
        }
        .onChange(of: selection) { _, newValue in
            guard newValue == 3 else {
                previousSelection = newValue
                return
            }
            isPresentingAdd = true
            selection = previousSelection
        }
        .sheet(isPresented: $isPresentingAdd) {
            AddTransactionView()
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
