//
//  SignInView.swift
//  Money Laundering
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Environment(AuthenticationService.self) private var authService

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.6, blue: 0.3),
                    Color(red: 1.0, green: 0.85, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                    Text("Money Laundering")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("Sign in to sync your transactions across devices with iCloud.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        authService.handleAuthorization(authorization)
                    case .failure(let error):
                        print("Sign in with Apple failed: \(error.localizedDescription)")
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationService())
}
