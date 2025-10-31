//
//  AppEnvironment.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import Foundation

final class AppEnvironment: ObservableObject {
    let articleService: any ArticleService
    let audioService: AudioService
    let audioStorage: AudioStorage
    let audioManager: AudioManager
    let recentStore: RecentArticlesStore

    init(articleService: any ArticleService, audioService: AudioService, audioStorage: AudioStorage, audioManager: AudioManager, recentStore: RecentArticlesStore) {
        self.articleService = articleService
        self.audioService = audioService
        self.audioStorage = audioStorage
        self.audioManager = audioManager
        self.recentStore = recentStore
    }
}
