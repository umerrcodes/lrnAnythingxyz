//
//  ArticleAudioViewModel.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

@MainActor
final class ArticleAudioViewModel: ObservableObject {
    @Published var isGenerating: Bool = false
    @Published var errorMessage: String?
    @Published var progress: Double = 0 // 0...1
    @Published var firstTrackReady: Bool = false

    private let audioService: AudioService
    private let audioStorage: AudioStorage
    private let audioManager: AudioManager

    init(audioService: AudioService, audioStorage: AudioStorage, audioManager: AudioManager) {
        self.audioService = audioService
        self.audioStorage = audioStorage
        self.audioManager = audioManager
    }

    func playIfCached(article: Article) {
        let urls = audioStorage.trackURLs(for: article.id)
        guard !urls.isEmpty else { return }
        audioManager.replaceQueue(with: urls)
        audioManager.totalDuration = audioStorage.totalDuration(for: article.id)
        firstTrackReady = true
    }

    func generateIfNeeded(article: Article, voice: TTSVoice = .alloy) async {
        if isGenerating { return }
        // If cached, nothing to do
        if !audioStorage.trackURLs(for: article.id).isEmpty { return }

        isGenerating = true
        errorMessage = nil
        progress = 0
        firstTrackReady = false

        audioManager.totalDuration = estimateDuration(for: article.body)

        let chunks = makeChunks(from: article.body)
        let total = max(chunks.count, 1)

        for (idx, chunk) in chunks.enumerated() {
            do {
                let data = try await audioService.synthesizeSpeech(text: chunk, voice: voice)
                let url = try audioStorage.saveAudio(articleId: article.id, topic: article.topic, audioData: data, chunkIndex: idx)
                if idx == 0 {
                    audioManager.replaceQueue(with: [url]) // do not auto-play
                    firstTrackReady = true
                } else {
                    audioManager.addTrack(url)
                }
                // Update actual total duration as we learn it
                let actual = audioStorage.totalDuration(for: article.id)
                if actual > 0 { audioManager.totalDuration = actual }
                progress = Double(idx + 1) / Double(total)
            } catch {
                errorMessage = error.localizedDescription
                break
            }
        }

        isGenerating = false
    }

    func play() {
        audioManager.play()
    }
    func pause() {
        audioManager.pause()
    }

    // Splits by paragraphs then enforces max length (~800 chars) pieces while cutting at whitespace.
    private func makeChunks(from text: String, maxChars: Int = 800) -> [String] {
        if text.count <= maxChars { return [text] }
        var chunks: [String] = []
        var buffer = ""
        for paragraph in text.components(separatedBy: "\n\n") {
            if buffer.count + paragraph.count + 2 <= maxChars {
                buffer += (buffer.isEmpty ? "" : "\n\n") + paragraph
            } else {
                if !buffer.isEmpty { chunks.append(buffer); buffer = "" }
                if paragraph.count <= maxChars {
                    buffer = paragraph
                } else {
                    // hard wrap long paragraph at whitespace
                    var start = paragraph.startIndex
                    while start < paragraph.endIndex {
                        let end = paragraph.index(start, offsetBy: maxChars, limitedBy: paragraph.endIndex) ?? paragraph.endIndex
                        var slice = paragraph[start..<end]
                        if end < paragraph.endIndex, let lastSpace = paragraph[start..<end].lastIndex(of: " ") {
                            slice = paragraph[start..<lastSpace]
                            start = paragraph.index(after: lastSpace)
                        } else {
                            start = end
                        }
                        chunks.append(String(slice))
                    }
                }
            }
        }
        if !buffer.isEmpty { chunks.append(buffer) }
        return chunks
    }

    private func estimateDuration(for text: String) -> Double {
        // Rough estimate: ~160 wpm ≈ 2.67 words/sec → 0.375s/word
        let words = text.split { $0.isWhitespace || $0.isNewline }.count
        return Double(words) * 0.375
    }
}


