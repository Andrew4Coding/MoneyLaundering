//
//  MoneyLaunderingShortcuts.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import Foundation
import AppIntents

struct MoneyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTransactionIntent(),
            phrases: [
                "Add a transaction in \(.applicationName)",
                "Log an expense in \(.applicationName)"
            ],
            shortTitle: "Add Transaction",
            systemImageName: "plus.circle"
        )
        
        AppShortcut(
            intent: TodayTransactionsIntent(),
            phrases: [
                "Show today's transactions in \(.applicationName)",
                "What did I spend today in \(.applicationName)"
            ],
            shortTitle: "Today's Transactions",
            systemImageName: "calendar"
        )
    }
}
