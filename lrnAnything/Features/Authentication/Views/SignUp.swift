//
//  SignUp.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import SwiftUI

struct SignUp: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.gray.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 40)

                    VStack(alignment: .leading, spacing: 20) {
                        Image(systemName: "circle.hexagongrid")
                            .font(.system(size: 28, weight: .semibold))

                        Text("Get Started")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Create an account to continue")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button(action: { appState.isSignedIn = true }) {
                            HStack { Image(systemName: "applelogo"); Text("Continue with Apple").fontWeight(.semibold); Spacer() }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        Button(action: { appState.isSignedIn = true }) {
                            HStack { Image(systemName: "g.circle"); Text("Continue with Google").fontWeight(.semibold); Spacer() }
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

                        Button(action: { appState.isSignedIn = true }) {
                            HStack { Image(systemName: "envelope"); Text("Continue with Email").fontWeight(.semibold); Spacer() }
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
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SignUp()
        .environmentObject(AppState())
}
#endif


