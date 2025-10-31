//
//  AudioManager.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation
import AVFoundation

@MainActor
final class AudioManager: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0
    @Published var totalDuration: Double = 0 // estimated or actual total duration for UI

    private let player: AVQueuePlayer
    private var timeObserver: Any?

    init() {
        self.player = AVQueuePlayer()
        configureAudioSession()
        addObservers()
    }

    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }

    func replaceQueue(with urls: [URL]) {
        let items = urls.map { AVPlayerItem(url: $0) }
        player.removeAllItems()
        for item in items { player.insert(item, after: nil) }
        updateDuration(from: items.first)
    }

    func addTrack(_ url: URL) {
        let item = AVPlayerItem(url: url)
        player.insert(item, after: nil)
    }

    func play() {
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 1_000)
        player.seek(to: time)
    }

    // MARK: - Private

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("AudioSession error:", error.localizedDescription)
            #endif
        }
    }

    private func addObservers() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 4), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let item = self.player.currentItem, self.duration <= 0 {
                self.updateDuration(from: item)
            }
        }
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if self.player.items().isEmpty { self.isPlaying = false }
        }
    }

    private func updateDuration(from item: AVPlayerItem?) {
        guard let duration = item?.asset.duration, duration.isNumeric else { return }
        self.duration = CMTimeGetSeconds(duration)
    }
}

private extension CMTime {
    var isNumeric: Bool { isValid && flags.contains(.valid) && !seconds.isNaN && seconds.isFinite }
}


