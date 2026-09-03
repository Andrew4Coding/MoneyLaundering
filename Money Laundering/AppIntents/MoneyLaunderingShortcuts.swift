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
    }
}
