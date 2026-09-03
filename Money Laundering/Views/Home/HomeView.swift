//
//  HomeView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @State private var viewModel = HomeViewModel()

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

                    CategoryBreakdownChart(slices: viewModel.categoryBreakdown(from: allTransactions))

                    StatsSectionView(transactions: allTransactions, selectedPeriod: $viewModel.selectedPeriod)

                    RecentTransactionsSection(transactions: viewModel.recentTransactions(from: allTransactions))
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
