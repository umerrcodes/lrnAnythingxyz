//
//  lrnAnythingApp.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct lrnAnythingApp: App {
    init() {
        // Force HTTP/2/1.1 by disabling HTTP/3 (QUIC) at runtime for Simulator stability
        setenv("CFNETWORK_HTTP3_ENABLE", "0", 1)
    }
    @StateObject private var appState = AppState()
    @StateObject private var appEnvironment: AppEnvironment = {
        // WARNING: For prototype use only. Do not ship keys in apps.
        let article = OpenAIArticleService(apiKey: "OPENAI_KEY_REMOVED")
        let tts = OpenAITTSService(apiKey: "OPENAI_KEY_REMOVED")
        let storage = AudioStorage()
        let manager = AudioManager()
        let recent = RecentArticlesStore()
        return AppEnvironment(articleService: article, audioService: tts, audioStorage: storage, audioManager: manager, recentStore: recent)
    }()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isSignedIn {
                    ContentView(articleService: appEnvironment.articleService)
                } else {
                    SignIn()
                }
            }
            .environmentObject(appState)
            .environmentObject(appEnvironment)
            .environmentObject(appEnvironment.recentStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
