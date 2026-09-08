//
//  SignInView.swift
//  Money Laundering
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Environment(AuthenticationService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme

    @State private var animateIn = false
    @State private var floatPhase = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 24)

                header
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 24)

                Spacer(minLength: 24)

                signInButton
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 16)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                animateIn = true
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                floatPhase = true
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 20) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .rotationEffect(.degrees(floatPhase ? 2 : -2))

            VStack(spacing: 10) {
                Text("Money Laundering")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                Text("Track every money in, out, and where it went swiftly")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }

    private var signInButton: some View {
        VStack(spacing: 12) {
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
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppTheme.accent.opacity(0.25), radius: 16, y: 8)

            Button("Continue without an account") {
                authService.continueWithoutAccount()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationService())
}
