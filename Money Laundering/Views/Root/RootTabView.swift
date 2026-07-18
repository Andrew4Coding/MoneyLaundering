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

            TabView {
                Tab("Home", systemImage: "house.fill") {
                    HomeView(isPresentingAdd: $isPresentingAdd)
                }

                Tab("Transactions", systemImage: "list.bullet") {
                    TransactionsListView(isPresentingAdd: $isPresentingAdd)
                }

                Tab("Account", systemImage: "person.crop.circle") {
                    AccountView()
                }
            }
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
