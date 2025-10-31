//
//  SignIn.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import SwiftUI

struct SignIn: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle background
                LinearGradient(colors: [.gray.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 40)

                    // Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Logo placeholder
                        Image(systemName: "circle.hexagongrid")
                            .font(.system(size: 28, weight: .semibold))

                        Text("Get Started")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Learn Anything helps you read, write at your highest level")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Apple button (primary)
                        Button(action: { appState.isSignedIn = true }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        // Google button (secondary, light)
                        Button(action: { appState.isSignedIn = true }) {
                            HStack {
                                Image(systemName: "g.circle")
                                Text("Continue with Google")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                            )
                        }

                        // Email button (muted)
                        Button(action: { appState.isSignedIn = true }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Continue with Email")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        HStack(spacing: 4) {
                            Text("By continuing, you agree to")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text("Terms of Use")
                                .font(.footnote)
                                .underline()
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 24)

                    Spacer()

                    // Link to sign up (optional – behaves the same for now)
                    NavigationLink("Create an account") { SignUp() }
                        .padding(.bottom, 24)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SignIn()
        .environmentObject(AppState())
}
#endif


