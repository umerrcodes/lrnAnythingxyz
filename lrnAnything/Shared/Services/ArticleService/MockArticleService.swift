//
//  MockArticleService.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import Foundation

struct MockArticleService: ArticleService {
    func generateArticle(topic: String, style: ArticleStyle) async throws -> Article {
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4s
        let title = "\(topic.capitalized): A Short Exploration"
        let summary = "A brief overview of \(topic)."
        let body = "This is a mock article for \(topic). Replace with real OpenAI output.\n\nIt demonstrates the end-to-end flow (search → generate → navigate)."
        return Article(topic: topic, title: title, summary: summary, body: body)
    }
}


