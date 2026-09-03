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
                if case .signedIn(let userID, let displayName) = authService.state {
                    Section("Signed in with Apple") {
                        if let displayName, !displayName.isEmpty {
                            LabeledContent("Name", value: displayName)
                        }
                        LabeledContent("Apple ID", value: maskedIdentifier(userID))
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

    /// Apple's opaque user identifier is long and sensitive; show only a recognizable prefix.
    private func maskedIdentifier(_ userID: String) -> String {
        let prefix = userID.split(separator: ".").first.map(String.init) ?? String(userID.prefix(6))
        return "\(prefix)…"
    }
}

#Preview {
    AccountView()
        .environment(AuthenticationService())
}
