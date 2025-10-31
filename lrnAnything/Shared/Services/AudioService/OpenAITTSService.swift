//
//  OpenAITTSService.swift
//  lrnAnything
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

final class OpenAITTSService: AudioService {
    private let apiKey: String
    private let model: String
    private let session: URLSession

    init(apiKey: String, model: String = "tts-1", session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    func synthesizeSpeech(text: String, voice: TTSVoice) async throws -> Data {
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "model": model,
            "input": text,
            "voice": voice.rawValue,
            "format": "mp3"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            #if DEBUG
            print("OpenAI TTS error", http.statusCode, body)
            #endif
            throw NSError(domain: "OpenAI.TTS", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: body])
        }
        return data
    }
}


