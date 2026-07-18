//
//  RootTabView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

/// 2-tab shell (Home, Transactions). The "Add" action is exposed as a bottom-bar toolbar
/// button inside each tab's navigation stack so the system manages its placement alongside
/// the tab bar. Stats lives inside Home rather than as a separate tab.
struct RootTabView: View {
    @State private var isPresentingAdd = false
    @State private var selection = 0
    @State private var previousSelection = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.6, blue: 0.3),
                    Color(red: 1.0, green: 0.85, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
