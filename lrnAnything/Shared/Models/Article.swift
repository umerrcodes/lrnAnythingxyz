//
//  Article.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import Foundation

struct Article: Identifiable, Hashable, Codable {
    let id: UUID
    let topic: String
    let title: String
    let summary: String
    let body: String
    let createdAt: Date

    init(id: UUID = UUID(), topic: String, title: String, summary: String, body: String, createdAt: Date = Date()) {
        self.id = id
        self.topic = topic
        self.title = title
        self.summary = summary
        self.body = body
        self.createdAt = createdAt
    }
}


