//
//  AccountView.swift
//  Money Laundering
//

import AuthenticationServices
import SwiftUI

struct AccountView: View {
    @Environment(AuthenticationService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            List {
                switch authService.state {
                case let .signedIn(userID, displayName):
                    Section("Signed in with Apple") {
                        if let displayName, !displayName.isEmpty {
                            LabeledContent("Name", value: displayName)
                        } else {
                            LabeledContent("Apple ID", value: maskedIdentifier(userID))
                        }
                    }
                case .localOnly:
                    Section {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            if case let .success(authorization) = result {
                                authService.handleAuthorization(authorization)
                            }
                        }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    } header: {
                        Text("Using without an account")
                    } footer: {
                        Text("Sign in with Apple to attach a name to this device. Your existing data stays exactly where it is.")
                    }
                case .signedOut:
                    EmptyView()
                }

                Section {
                    Label("Synced privately via iCloud", systemImage: "icloud.fill")
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Your transactions are stored in your private CloudKit database and sync automatically across your devices.")
                }

                Section {
                    Button(signOutTitle, role: .destructive) {
                        authService.signOut()
                    }
                }
            }
            .navigationTitle("Account")
        }
    }

    private var signOutTitle: String {
        if case .localOnly = authService.state {
            return "Reset & Return to Sign In"
        }
        return "Sign Out"
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
