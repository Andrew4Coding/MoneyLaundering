//
//  HomeView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @State private var viewModel = HomeViewModel()
    @Binding var isPresentingAdd: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach([PeriodOption.today, .thisWeek, .thisMonth, .all]) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    HomeSummaryCard(
                        balance: viewModel.balance(from: allTransactions),
                        totalIncome: viewModel.totalIncome(from: allTransactions),
                        totalExpense: viewModel.totalExpense(from: allTransactions)
                    )

                    StatsSectionView(transactions: allTransactions, selectedPeriod: $viewModel.selectedPeriod)

                    RecentTransactionsSection(transactions: viewModel.recentTransactions(from: allTransactions))
                }
                .padding()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarSpacer(.flexible, placement: .bottomBar)

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isPresentingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("Add Transaction")
                }
            }
        }
    }
}

#Preview {
    HomeView(isPresentingAdd: .constant(false))
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
