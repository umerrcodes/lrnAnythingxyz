//
//  AudioIndex.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

struct AudioTrack: Codable, Equatable {
    let fileName: String
    let chunkIndex: Int
    let durationSeconds: Double?
}

struct AudioRecord: Codable, Equatable {
    let articleId: UUID
    let topic: String
    let createdAt: Date
    var tracks: [AudioTrack]
}

struct AudioIndex: Codable {
    var records: [UUID: AudioRecord]

    init(records: [UUID: AudioRecord] = [:]) {
        self.records = records
    }
}


