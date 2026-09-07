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
            background

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

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    AppTheme.accent.mix(with: Color(.systemBackground), by: 0.82),
                    AppTheme.accent.mix(with: Color(.systemBackground), by: 0.62),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(AppTheme.accent.opacity(0.18))
                .frame(width: 260)
                .blur(radius: 50)
                .offset(x: floatPhase ? -120 : -150, y: floatPhase ? -220 : -180)

            Circle()
                .fill(Color(hex: "5AC8FA").opacity(0.28))
                .frame(width: 320)
                .blur(radius: 70)
                .offset(x: floatPhase ? 140 : 110, y: floatPhase ? 260 : 300)
        }
        .ignoresSafeArea()
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
                Text("Track every rupiah in, out, and where it went.")
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
                request.requestedScopes = [.fullName]
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
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationService())
}
