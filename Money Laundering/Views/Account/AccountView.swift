//
//  AccountView.swift
//  Money Laundering
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthenticationService.self) private var authService

    var body: some View {
        NavigationStack {
            List {
                if case .signedIn(_, let displayName) = authService.state {
                    Section("Signed in with Apple") {
                        LabeledContent("Name", value: displayName ?? "Apple ID user")
                    }
                }

                Section {
                    Label("Synced privately via iCloud", systemImage: "icloud.fill")
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Your transactions are stored in your private CloudKit database and sync automatically across your devices.")
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        authService.signOut()
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthenticationService())
}
