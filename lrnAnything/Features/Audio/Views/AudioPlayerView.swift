//
//  AudioPlayerView.swift
//  lrnAnything
//
//  Created by Assistant & Umercantcode on 31/10/2025.
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var manager: AudioManager

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) { // Play/Pause button and slider
                Button(action: { manager.isPlaying ? manager.pause() : manager.play() }) { // Play/Pause button action
                    Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered) // Play/Pause button style

                // Slider for scrubbing
                Slider(value: Binding(
                    get: { manager.currentTime },
                    set: { manager.seek(to: $0) }
                ), in: 0...(max(max(manager.totalDuration, manager.duration), 0.1)), step: 0.1)
            }

            HStack { // Current time and total time
                Text(timeString(manager.currentTime))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(timeString(max(manager.totalDuration, manager.duration))) // Total time
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private func timeString(_ seconds: Double) -> String {
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}


