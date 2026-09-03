//
//  Money_LaunderingApp.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 01/07/26.
//

import SwiftData
import SwiftUI

@main
struct Money_LaunderingApp: App {
    @State private var authService = AuthenticationService()

    let container: ModelContainer = {
        let schema = Schema([Transaction.self, TransactionCategory.self])
        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.andrew4coding.moneylaundering.Money-Laundering")
        )
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        CategorySeeder.seedIfNeeded(context: container.mainContext)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                switch authService.state {
                case .signedIn:
                    RootTabView()
                case .signedOut:
                    SignInView()
                }
            }
            .tint(AppTheme.accent)
            .environment(authService)
        }
        .modelContainer(container)
    }
}
