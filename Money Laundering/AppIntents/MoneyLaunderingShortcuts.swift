//
//  MoneyLaunderingShortcuts.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import AppIntents
import Foundation

struct MoneyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTransactionIntent(),
            phrases: [
                "Add a transaction in \(.applicationName)",
                "Log an expense in \(.applicationName)",
            ],
            shortTitle: "Add Transaction",
            systemImageName: "plus.circle"
        )

        AppShortcut(
            intent: SiriAddTransactionIntent(),
            phrases: [
                "Quick add expense in \(.applicationName)",
                "Quick add a transaction in \(.applicationName)",
                "Log a quick expense in \(.applicationName)",
            ],
            shortTitle: "Quick Add",
            systemImageName: "bolt.fill"
        )

        AppShortcut(
            intent: TodayTransactionsIntent(),
            phrases: [
                "Show today's transactions in \(.applicationName)",
                "What did I spend today in \(.applicationName)",
            ],
            shortTitle: "Today's Transactions",
            systemImageName: "calendar"
        )
    }
}
