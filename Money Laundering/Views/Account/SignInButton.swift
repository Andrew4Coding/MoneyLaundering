//
//  SignInButton.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 08/09/26.
//

import AuthenticationServices
import Foundation
import SwiftUI

struct SignInButton: View {
    @Environment(AuthenticationService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case let .success(authorization):
                authService.handleAuthorization(authorization)
            case let .failure(error):
                print("Sign in with Apple failed: \(error.localizedDescription)")
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
