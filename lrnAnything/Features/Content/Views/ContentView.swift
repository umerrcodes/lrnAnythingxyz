//
//  ContentView.swift
//  lrnAnything
//
//  Created by Umercantcode on 31/10/2025.
//

import SwiftUI
 
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @EnvironmentObject private var recentStore: RecentArticlesStore
    let articleService: any ArticleService
    @State private var searchQuery: String = ""
    @State private var pendingTopic: String?
    @State private var selectedArticle: Article?
    private let queryLimit: Int = 20
    
    init(articleService: any ArticleService) {
        self.articleService = articleService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
            Image(systemName: "infinity")
                .font(.system(size: 46, weight: .regular))
                .padding(.top, 74)

            Text("Learn Anything")
                .font(.title)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    TextField("Search a topic here", text: $searchQuery)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .foregroundStyle(.white)
                        

                    Button("Search") {
                        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        pendingTopic = trimmed
                        // Clear the field once we navigate away
                        searchQuery = ""
                    }
                    .font(.body.weight(.semibold))
                    .padding(.vertical, 2)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                    .disabled(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(10)
                .background(
                    Capsule()
                        .fill(Color.black)
                )

                Text("search limited to 20 characters")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)

            // Recent articles chips
            if !recentStore.recentArticles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(recentStore.recentArticles) { article in
                                Button(action: { selectedArticle = article }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock")
                                        Text(article.topic.capitalized)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()
            }
            .navigationDestination(item: $pendingTopic) { topic in
                GenerateArticleView(topic: topic, articleService: articleService)
            }
            .navigationDestination(item: $selectedArticle) { article in
                ArticleView(
                    article: article,
                    audioService: appEnvironment.audioService,
                    audioStorage: appEnvironment.audioStorage,
                    audioManager: appEnvironment.audioManager
                )
            }
            .onChange(of: searchQuery) { newValue in
                if newValue.count > queryLimit {
                    searchQuery = String(newValue.prefix(queryLimit))
                }
            }
        }
    }
}

#Preview {
    ContentView(articleService: MockArticleService())
        .environmentObject(AppState())
}
