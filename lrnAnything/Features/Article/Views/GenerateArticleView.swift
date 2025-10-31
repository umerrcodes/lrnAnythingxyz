//
//  GenerateArticleView.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import SwiftUI

struct GenerateArticleView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    let topic: String
    let articleService: any ArticleService

    @State private var article: Article?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let article = article {
                ArticleView(
                    article: article,
                    audioService: appEnvironment.audioService,
                    audioStorage: appEnvironment.audioStorage,
                    audioManager: appEnvironment.audioManager
                )
            } else if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Generating article for \"\(topic)\"…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                    Button("Retry") { triggerGeneration() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle(topic.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: topic) { triggerGeneration() }
    }

    private func triggerGeneration() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let result = try await articleService.generateArticle(topic: topic, style: .storyMan)
                await MainActor.run {
                    appEnvironment.recentStore.add(result)
                    self.article = result
                    self.isLoading = false
                }
            } catch {
                #if DEBUG
                print("Article generation failed:", error.localizedDescription)
                #endif
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack { GenerateArticleView(topic: "Quantum", articleService: MockArticleService()) }
}
#endif


