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

    private let container = Persistance.container

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
