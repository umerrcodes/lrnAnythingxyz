//
//  RecentArticlesStore.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

final class RecentArticlesStore: ObservableObject {
    @Published private(set) var recentArticles: [Article] = []

    private let key = "recentArticles"
    private let maxCount: Int = 10
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func add(_ article: Article) {
        // Deduplicate by id
        recentArticles.removeAll { $0.id == article.id }
        recentArticles.insert(article, at: 0)
        if recentArticles.count > maxCount {
            recentArticles = Array(recentArticles.prefix(maxCount))
        }
        save()
    }

    func load() {
        guard let data = defaults.data(forKey: key) else { return }
        if let decoded = try? JSONDecoder().decode([Article].self, from: data) {
            self.recentArticles = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(recentArticles) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        recentArticles.removeAll()
        defaults.removeObject(forKey: key)
    }
}


