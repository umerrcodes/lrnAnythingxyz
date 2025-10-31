//
//  AudioService.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

enum TTSVoice: String {
    case alloy
}

protocol AudioService {
    func synthesizeSpeech(text: String, voice: TTSVoice) async throws -> Data
}


