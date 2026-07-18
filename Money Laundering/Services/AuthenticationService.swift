//
//  AuthenticationService.swift
//  Money Laundering
//

import AuthenticationServices
import Foundation
import Observation

/// Gates app access behind Sign in with Apple. Only the Apple user identifier and display
/// name are persisted locally (UserDefaults) — actual data sync is handled separately by
/// SwiftData's private CloudKit database, which is tied to the device's iCloud account.
@Observable
final class AuthenticationService: NSObject {
    enum State: Equatable {
        case signedOut
        case signedIn(userID: String, displayName: String?)
    }

    private static let userIDKey = "appleUserIdentifier"
    private static let displayNameKey = "appleDisplayName"

    private(set) var state: State

    override init() {
        if let userID = UserDefaults.standard.string(forKey: Self.userIDKey) {
            state = .signedIn(userID: userID, displayName: UserDefaults.standard.string(forKey: Self.displayNameKey))
        } else {
            state = .signedOut
        }
        super.init()

        if case .signedIn(let userID, _) = state {
            refreshCredentialState(for: userID)
        }
    }

    /// Apple can revoke a credential (e.g. user removes the app's Apple ID access from
    /// Settings) without the app being notified directly, so re-check on launch.
    private func refreshCredentialState(for userID: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { [weak self] credentialState, _ in
            guard credentialState == .revoked else { return }
            DispatchQueue.main.async {
                self?.signOut()
            }
        }
    }

    func handleAuthorization(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        let userID = credential.user
        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        // Apple only supplies fullName on the very first authorization for a given user;
        // fall back to whatever was previously stored on subsequent sign-ins.
        let displayName = fullName.isEmpty ? UserDefaults.standard.string(forKey: Self.displayNameKey) : fullName

        UserDefaults.standard.set(userID, forKey: Self.userIDKey)
        if let displayName {
            UserDefaults.standard.set(displayName, forKey: Self.displayNameKey)
        }

        state = .signedIn(userID: userID, displayName: displayName)
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: Self.userIDKey)
        UserDefaults.standard.removeObject(forKey: Self.displayNameKey)
        state = .signedOut
    }
}
