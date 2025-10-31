//
//  ContentViewModel.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    @Published var article: Article?

    private let articleService: any ArticleService

    init(articleService: any ArticleService) {
        self.articleService = articleService
    }

    func search(topic: String, style: ArticleStyle = .storyMan) async {
        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        do {
            let result = try await articleService.generateArticle(topic: trimmed, style: style)
            self.article = result
        } catch {
            self.errorMessage = "Failed to generate article. Please try again."
        }
        isSearching = false
    }
}


