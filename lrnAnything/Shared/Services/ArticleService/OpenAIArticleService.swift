import Foundation

final class OpenAIArticleService: ArticleService {
    private let apiKey: String
    private let model: String

    private let curiousGeorgePrompt = """
    You are an article generator. A user will mention a topic, and you will generate a 400-word article.

    You will not engage in any introductory commentary and will dive straight into the article. Make your article sound story-like so that the information flows well but don't make it too emotional. It is as if you are a professor trying to cover a topic to a student and wanting to make sure your coverage is interesting so that the student keeps track of the flow of information, but you also don't want to lose the substance. Don't try to go too broad; try to go deep instead.

    When a topic is provided, translate it into a curious question that you want to explore. Focus on creating an article that flows well and provides an informative session to the user. Assume that the user is not familiar with the topic at all, so use easy-to-understand language whenever appropriate. Make the article read like it is being read aloud. Here is the topic the user requests:
    """

    private let storyManPrompt = """
    You are an expert writer who crafts engaging 400-word articles on any given topic. Your articles are informative, well-structured, and designed to captivate readers from start to finish. Always begin with a true short historical story that sets the scene.

    When writing, you should avoid any preliminary remarks and immediately delve into the subject matter. Use a narrative style that is both accessible and compelling, ensuring that complex ideas are explained in simple terms without losing depth. Aim to provide a thorough exploration of the topic, focusing on depth rather than breadth.

    If a topic is provided, reframe it as an intriguing question to investigate. Your goal is to educate the reader as if they have no prior knowledge of the subject while keeping them engaged with a flowing, conversational tone. Here is the topic the user requests:
    """

    init(apiKey: String, model: String = "gpt-4o-mini") {
        self.apiKey = apiKey
        self.model = model
    }

    func generateArticle(topic: String, style: ArticleStyle) async throws -> Article {
        #if DEBUG
        print("🚀 Starting article generation")
        print("📝 Topic: \(topic)")
        print("🎨 Style: \(style)")
        print("🤖 Model: \(model)")
        print("🔑 API Key: \(String(apiKey.prefix(15)))...")
        #endif
        
        let systemPrompt: String = {
            switch style {
            case .curiousGeorge: return curiousGeorgePrompt
            case .storyMan: return storyManPrompt
            }
        }()

        let userPrompt = topic

        let requestBody = ChatCompletionsRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            temperature: 0.7
        )

        // Attempt Chat Completions first
        let chatURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        do {
            #if DEBUG
            print("📡 Sending request to Chat Completions API...")
            #endif
            
            let responseData = try await Self.sendJSONRequest(url: chatURL, apiKey: apiKey, payload: requestBody)
            
            #if DEBUG
            print("✅ Received response, parsing...")
            #endif
            
            let content = try Self.parseContent(from: responseData)
            let title = topic.capitalized
            let summary = "Generated article on \(topic)."
            let body = content
            
            #if DEBUG
            print("✅ Article generated successfully!")
            print("📄 Content length: \(body.count) characters")
            #endif
            
            return Article(topic: topic, title: title, summary: summary, body: body)
        } catch {
            #if DEBUG
            print("❌ Chat Completions failed: \(error.localizedDescription)")
            print("🔄 Trying Responses API as fallback...")
            #endif
            
            // Fallback: try Responses API
            let responsesURL = URL(string: "https://api.openai.com/v1/responses")!
            let responsesReq = ResponsesRequest(
                model: model,
                input: [
                    .init(role: "system", content: [.init(type: "input_text", text: systemPrompt)]),
                    .init(role: "user", content: [.init(type: "input_text", text: userPrompt)])
                ]
            )
            
            do {
                let responseData = try await Self.sendJSONRequest(url: responsesURL, apiKey: apiKey, payload: responsesReq)
                let content = try Self.parseResponsesContent(from: responseData)
                let title = topic.capitalized
                let summary = "Generated article on \(topic)."
                let body = content
                
                #if DEBUG
                print("✅ Responses API succeeded!")
                #endif
                
                return Article(topic: topic, title: title, summary: summary, body: body)
            } catch let responsesError {
                #if DEBUG
                print("❌ Both APIs failed!")
                print("Chat error: \(error.localizedDescription)")
                print("Responses error: \(responsesError.localizedDescription)")
                #endif
                
                // Throw the more informative error
                throw error
            }
        }
    }
    
    // Test connection to OpenAI
    func testConnection() async throws -> String {
        let testURL = URL(string: "https://api.openai.com/v1/models")!
        var request = URLRequest(url: testURL)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if http.statusCode == 200 {
            return "✅ Connection successful! API is working."
        } else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAI", code: http.statusCode, 
                         userInfo: [NSLocalizedDescriptionKey: "Status \(http.statusCode): \(errorText)"])
        }
    }
}

// MARK: - DTOs

private struct ChatMessage: Codable {
    let role: String
    let content: String?
}

// MARK: - Parsing helpers

extension OpenAIArticleService {
    private static func sendJSONRequest<T: Encodable>(url: URL, apiKey: String, payload: T) async throws -> Data {
        let data = try JSONEncoder().encode(payload)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120  // Increased to 2 minutes
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = data

        #if DEBUG
        print("📤 Request URL: \(url.absoluteString)")
        print("📦 Request size: \(data.count) bytes")
        #endif

        // Retry logic with exponential backoff
        var lastError: Error = NSError(domain: "OpenAI", code: -1)
        let maxRetries = 3
        
        for attempt in 0..<maxRetries {
            do {
                #if DEBUG
                if attempt > 0 {
                    print("🔄 Retry attempt \(attempt + 1)/\(maxRetries)")
                }
                #endif
                
                let (responseData, response) = try await URLSession.shared.data(for: request)
                
                guard let http = response as? HTTPURLResponse else {
                    throw NSError(domain: "OpenAI", code: -1, 
                                userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
                }
                
                #if DEBUG
                print("📥 Response status: \(http.statusCode)")
                print("📦 Response size: \(responseData.count) bytes")
                #endif
                
                if !(200..<300).contains(http.statusCode) {
                    let errorText = String(data: responseData, encoding: .utf8) ?? "<no body>"
                    
                    #if DEBUG
                    print("❌ HTTP Error \(http.statusCode):")
                    print(errorText.prefix(500))
                    #endif
                    
                    // For rate limits (429), wait and retry
                    if http.statusCode == 429 && attempt < maxRetries - 1 {
                        let backoff = Double(attempt + 1) * 2.0 // 2s, 4s, 6s
                        #if DEBUG
                        print("⏳ Rate limited, waiting \(backoff)s before retry...")
                        #endif
                        try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                        continue
                    }
                    
                    throw NSError(domain: "OpenAI", code: http.statusCode, 
                                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(errorText)"])
                }
                
                return responseData
            } catch let error as URLError {
                lastError = error
                
                #if DEBUG
                print("❌ Network error: \(error.localizedDescription)")
                print("   Code: \(error.code.rawValue)")
                #endif
                
                // Retry on timeout or connection lost
                if (error.code == .timedOut || error.code == .networkConnectionLost) && attempt < maxRetries - 1 {
                    let backoff = Double(attempt + 1) * 1.5
                    #if DEBUG
                    print("⏳ Network issue, retrying in \(backoff)s...")
                    #endif
                    try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                    continue
                }
                break
            } catch {
                lastError = error
                #if DEBUG
                print("❌ Unexpected error: \(error.localizedDescription)")
                #endif
                break
            }
        }
        
        throw lastError
    }

    private static func parseContent(from data: Data) throws -> String {
        // Log raw response for debugging
        #if DEBUG
        if let rawString = String(data: data, encoding: .utf8) {
            print("🔍 Raw API Response (first 500 chars):")
            print(rawString.prefix(500))
        }
        #endif
        
        // Try strict decode first
        do {
            let completion = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)
            
            #if DEBUG
            print("✅ Successfully decoded ChatCompletionsResponse")
            print("   Choices count: \(completion.choices.count)")
            #endif
            
            if let content = completion.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty {
                return content
            }
        } catch {
            #if DEBUG
            print("⚠️ Strict decode failed: \(error.localizedDescription)")
            #endif
        }
        
        // Try permissive dictionary parsing
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            #if DEBUG
            print("🔍 Parsed JSON keys: \(obj.keys.joined(separator: ", "))")
            #endif
            
            if let choices = obj["choices"] as? [Any],
               let first = choices.first as? [String: Any] {
                if let message = first["message"] as? [String: Any], 
                   let content = message["content"] as? String, !content.isEmpty {
                    return content
                }
                if let content = first["text"] as? String, !content.isEmpty {
                    return content
                }
            }
            
            // Check for API errors
            if let err = obj["error"] as? [String: Any] {
                let msg = err["message"] as? String ?? "Unknown error"
                let type = err["type"] as? String ?? "unknown"
                throw NSError(domain: "OpenAI", code: -3, 
                             userInfo: [NSLocalizedDescriptionKey: "API Error (\(type)): \(msg)"])
            }
        }
        
        let sample = String(data: data.prefix(500), encoding: .utf8) ?? "<non-utf8>"
        throw NSError(domain: "OpenAI", code: -2, 
                     userInfo: [NSLocalizedDescriptionKey: "Cannot parse response. Sample: \(sample)"])
    }

    private static func parseResponsesContent(from data: Data) throws -> String {
        #if DEBUG
        if let rawString = String(data: data, encoding: .utf8) {
            print("🔍 Responses API Response (first 500 chars):")
            print(rawString.prefix(500))
        }
        #endif
        
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let text = obj["output_text"] as? String, !text.isEmpty { 
                return text 
            }
            if let out = obj["output"] as? [[String: Any]], let first = out.first,
               let contentArr = first["content"] as? [[String: Any]],
               let text = contentArr.first?["text"] as? String, !text.isEmpty { 
                return text 
            }
            if let err = obj["error"] as? [String: Any], let msg = err["message"] as? String { 
                throw NSError(domain: "OpenAI", code: -4, 
                             userInfo: [NSLocalizedDescriptionKey: "Responses API Error: \(msg)"]) 
            }
        }
        
        // Fallback to chat shape
        return try parseContent(from: data)
    }
}

// MARK: - Responses DTOs

private struct ResponsesRequest: Codable {
    let model: String
    let input: [ResponsesMessage]
}

private struct ResponsesMessage: Codable {
    let role: String
    let content: [ResponsesText]
}

private struct ResponsesText: Codable {
    let type: String
    let text: String
}

private struct ChatCompletionsRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double?
}

private struct ChatCompletionsResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String?
        }
        let index: Int?
        let message: Message
    }
    let choices: [Choice]
}