//
//  ArticleService.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import Foundation

enum ArticleStyle: String {
    case curiousGeorge
    case storyMan
}

protocol ArticleService {
    func generateArticle(topic: String, style: ArticleStyle) async throws -> Article
}


