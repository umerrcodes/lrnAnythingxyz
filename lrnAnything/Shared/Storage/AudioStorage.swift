//
//  AudioStorage.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation
import AVFoundation

final class AudioStorage {
    private let fileManager: FileManager
    private let indexFileName = "audio_index.json"

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    // MARK: Paths

    private func documentsDirectory() throws -> URL {
        try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    private func articleDirectory(articleId: UUID) throws -> URL {
        let dir = try documentsDirectory().appendingPathComponent("Articles/\(articleId.uuidString)", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func indexURL() throws -> URL {
        try documentsDirectory().appendingPathComponent(indexFileName)
    }

    // MARK: Index

    func loadIndex() -> AudioIndex {
        do {
            let url = try indexURL()
            guard fileManager.fileExists(atPath: url.path) else { return AudioIndex() }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(AudioIndex.self, from: data)
        } catch {
            return AudioIndex()
        }
    }

    func saveIndex(_ index: AudioIndex) {
        do {
            let url = try indexURL()
            let data = try JSONEncoder().encode(index)
            try data.write(to: url)
        } catch {
            #if DEBUG
            print("Failed to save audio index:", error.localizedDescription)
            #endif
        }
    }

    // MARK: Audio files

    func saveAudio(articleId: UUID, topic: String, audioData: Data, chunkIndex: Int) throws -> URL {
        let dir = try articleDirectory(articleId: articleId)
        let fileName = "chunk_\(chunkIndex).mp3"
        let url = dir.appendingPathComponent(fileName)
        try audioData.write(to: url)

        var index = loadIndex()
        var record = index.records[articleId] ?? AudioRecord(articleId: articleId, topic: topic, createdAt: Date(), tracks: [])
        if record.tracks.contains(where: { $0.chunkIndex == chunkIndex }) == false {
            let duration = AVURLAsset(url: url).duration.seconds
            record.tracks.append(AudioTrack(fileName: fileName, chunkIndex: chunkIndex, durationSeconds: duration.isFinite ? duration : nil))
            record.tracks.sort { $0.chunkIndex < $1.chunkIndex }
            index.records[articleId] = record
            saveIndex(index)
        }

        return url
    }

    func trackURLs(for articleId: UUID) -> [URL] {
        let index = loadIndex()
        guard let record = index.records[articleId] else { return [] }
        do {
            let dir = try articleDirectory(articleId: articleId)
            return record.tracks.map { dir.appendingPathComponent($0.fileName) }
        } catch {
            return []
        }
    }

    func totalDuration(for articleId: UUID) -> Double {
        let index = loadIndex()
        guard let record = index.records[articleId] else { return 0 }
        return record.tracks.compactMap { $0.durationSeconds }.reduce(0, +)
    }
}


