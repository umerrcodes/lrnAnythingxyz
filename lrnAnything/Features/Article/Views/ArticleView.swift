//
//  ArticleView.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import SwiftUI

struct ArticleView: View {
    let article: Article
    @ObservedObject private var audioManager: AudioManager
    private let audioStorage: AudioStorage
    @StateObject private var audioVM: ArticleAudioViewModel

    init(article: Article, audioService: AudioService, audioStorage: AudioStorage, audioManager: AudioManager) {
        self.article = article
        self.audioStorage = audioStorage
        _audioManager = ObservedObject(wrappedValue: audioManager)
        _audioVM = StateObject(wrappedValue: ArticleAudioViewModel(
            audioService: audioService,
            audioStorage: audioStorage,
            audioManager: audioManager
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.title)
                    .fontWeight(.bold)

                if !article.summary.isEmpty {
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Audio controls
                VStack(alignment: .leading, spacing: 12) {
                    Text("Listen")
                        .font(.headline)

                    // Top listen line with total time and play icon
                    HStack {
                        if audioVM.firstTrackReady { // Play button
                            Button(action: { audioManager.isPlaying ? audioManager.pause() : audioManager.play() }) { // Play/Pause button action
                                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                            }
                            .buttonStyle(.bordered) // Play/Pause button style
                        } else {
                            ProgressView()
                        }

                        Text("Listen to this article") // Listen to this article text
                            .font(.subheadline)
                        Spacer()
                        Text(timeString(max(audioManager.totalDuration, audioManager.duration))) // Total time  
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3))
                    )

                    if audioVM.firstTrackReady {
                        AudioPlayerView(manager: audioManager)
                    }

                    if let error = audioVM.errorMessage { Text(error).foregroundStyle(.red) }
                }
                .padding(.vertical)

                Text(article.body)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(article.topic.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            audioVM.playIfCached(article: article)
            let existing = audioStorage.trackURLs(for: article.id)
            if existing.isEmpty {
                await audioVM.generateIfNeeded(article: article)
            }
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

#if DEBUG
#Preview {
    ArticleView(article: Article(topic: "Quantum", title: "Quantum", summary: "Summary", body: "Body"), audioService: OpenAITTSService(apiKey: "mock"), audioStorage: AudioStorage(), audioManager: AudioManager())
}
#endif


