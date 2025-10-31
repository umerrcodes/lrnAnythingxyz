## Learn Anything (iOS, SwiftUI) — Project Plan, Rules, and Approach

### High-level goals
- Sign in (optional)
- Type a topic
- Article is generated
- Can listen to the article

For the first milestone, we will build:
- A fake sign-in screen that pretends to sign in
- A content screen with a heading and a search bar

This lets us prove the navigation and state flow early without backend complexity.

### Guiding rules to follow
- Keep features modular: group related screens, logic, and assets together by feature (Authentication, Content, Shared). Why: Makes the code easy to navigate and evolve as features grow.

- Unidirectional data flow: Views read state from view models; view models update state; services do the work. Why: Clear ownership reduces bugs and makes testing straightforward.

- Single source of truth for app-wide state: one app-level state indicating whether the user is signed in. Why: Prevents conflicting state across screens and simplifies navigation logic.

- Protocol-driven services (e.g., ArticleService, AudioService): define interfaces; start with mock implementations. Why: Enables easy swapping of mocks/real implementations and simplifies tests.

- Avoid global singletons except system frameworks (e.g., speech synthesizer within a wrapper). Why: Reduces hidden dependencies and improves testability.

- Accessibility by default: dynamic type, VoiceOver labels, and controls large enough to tap. Why: Ensures the “listen to article” feature and the app are usable by everyone.

- Prepare for localization (strings and voice). Why: The content is language-driven; planning now avoids costly refactors later.
- Small, frequent commits with meaningful messages. Why: Easier to review and revert if needed.

### Project structure (folders and why)
- `App/`
  - App entry and app-wide state (e.g., whether a user is signed in).
  - Why: Centralizes lifecycle and high-level decisions (e.g., which screen to show on launch).

- `Features/Authentication/`
  - `Views/` for sign-in screens
  - `ViewModels/` for sign-in state and actions
  - `Services/` (optional later) for real auth
  - Why: Keeps all sign-in concerns contained and swappable (fake now, real later).

- `Features/Content/`
  - `Views/` for the content screen with heading and search bar
  - `ViewModels/` for search query state and triggering article generation
  - `Models/` for article entities (title, body, etc.)
  - Why: Encapsulates the core “learn anything” experience and its state.

- `Shared/Components/`
  - Reusable UI elements (buttons, inputs, headers)
  - Why: Avoids repetition and ensures visual consistency.

- `Shared/Services/`
  - `ArticleService/` for generating an article (mock first)
  - `AudioService/` for text-to-speech (TTS) playback
  - Why: Abstracts platform details and logic away from views; easy to test and swap implementations.

- `Shared/Models/`
  - Cross-feature types such as `Article`
  - Why: Single definition prevents duplication across features.

- `Resources/`
  - `Assets.xcassets`, `Strings` for localization
  - Why: Keeps design tokens and copy centralized.

- `Tests/`
  - Unit tests for view models and services; UI tests for basic flows
  - Why: Gives confidence we don’t break sign-in/navigation/content while iterating.

Note: You can evolve to use SwiftData for persistence later (e.g., saving reading history). For now, focus on in-memory state to keep the first milestone simple.

### Navigation approach (and why)
- Use a single app entry point that decides which screen to show based on a boolean “isSignedIn”. Why: Straightforward logic that mirrors the product requirements (sign-in is optional/fake initially).
- Prefer a simple navigation stack for phones. Why: It matches common iOS UX and is easier to reason about than split views for the initial scope.
- Route to Content after fake sign-in; allow returning to sign-in during testing via a debug toggle. Why: Simplifies iteration while keeping the flow obvious.

### State management approach (and why)
- Have an app-wide state object that holds “isSignedIn”. Why: The sign-in state affects which root screen is visible.
- Each feature has its own view model managing its screen state (e.g., `searchQuery`, `isLoading`, `article`). Why: Keeps state close to where it’s used and keeps responsibilities separate.
- Views bind to view model properties; actions call view model methods, which call services. Why: Maintains unidirectional flow and keeps Views declarative and light.

### Data and services (and why)
- ArticleService
  - Start with a mock service that returns a canned article for any topic. Why: Lets you build UI/flow without waiting on a backend or LLM.
  - Later, replace the mock with a real implementation that calls your server or an on-device model. Why: Clean separation makes the upgrade low-risk.

- AudioService (Text-to-Speech)
  - Wrap the system speech synthesizer behind a simple interface with start/pause/stop. Why: Views shouldn’t know OS details; easier to test and mock.
  - Plan for voice selection and rate; default to sensible settings. Why: Improves accessibility and UX.

- Authentication (fake first)
  - Provide a simple method that marks the user as signed in. Why: Unblocks navigation work now; can be replaced with real auth later.

### Accessibility and UX (and why)
- Ensure controls (sign-in button, search field) are large and labeled. Why: Improves touch accuracy and VoiceOver support.
- Use consistent typography and spacing. Why: Improves readability of generated articles and reduces cognitive load.
- Keep feedback immediate (loading indicators, disabled states). Why: Users should understand what’s happening.

### Implementation milestones (step-by-step with why)
1) Bootstrap app settings
   - Confirm target iOS version and SwiftUI lifecycle are set. Why: Prevents avoidable runtime surprises and uses modern APIs.

2) Create folder structure listed above
   - Add `App`, `Features/Authentication`, `Features/Content`, `Shared/Components`, `Shared/Services`, `Shared/Models`, `Resources`, `Tests`. Why: Sets a scalable foundation before any feature code arrives.

3) Add app-wide state for sign-in
   - Define a single place to track `isSignedIn`. Why: Navigation root depends on it; avoids duplicating this flag.

4) Build the fake Sign-In screen
   - Show a simple screen with an action to “Sign in”. Why: Unblocks flow testing immediately without backend work.
   - On action, flip `isSignedIn` to true. Why: Drives the navigation to the content screen.

5) Build the Content screen (heading + search bar)
   - Display a prominent app heading and a search field. Why: Matches the core value proposition and gives a focal point.
   - Hold the query in screen state; validate it’s non-empty. Why: Keeps UX predictable and prepares for article generation.

6) Wire navigation from Sign-In to Content
   - Root view decides between Sign-In and Content using `isSignedIn`. Why: Simple, explicit control flow.

7) Integrate a mock ArticleService behind the search button
   - When the user taps search, call the mock service to “generate” an article and show a placeholder success state. Why: Validates end-to-end flow before backend.

8) Prepare AudioService for TTS
   - Add a play/pause control (can be disabled initially) and connect to the service later. Why: Surfaces the listening concept early and shapes the UI.

9) Add basic tests
   - Unit test sign-in state changes and search triggering. Why: Locks in behavior and reduces regressions while you iterate.

10) Polish pass
   - Accessibility labels, dynamic type sizing, and basic error states. Why: Improves usability and resilience.

### How SwiftUI differs from React Native (mental model mapping)
- Language and runtime
  - SwiftUI uses Swift and Apple’s UI framework directly; React Native uses JavaScript/TypeScript with a bridge to native views. Why: In SwiftUI you have direct platform APIs without the overhead of a JS bridge.

- UI primitives
  - SwiftUI uses declarative `View`s composed with modifiers; RN uses components with props/styles. Why: Conceptually similar, but modifiers are a primary composition tool in SwiftUI.

- Layout
  - SwiftUI stacks (VStack/HStack/ZStack) and container views replace Flexbox; alignment and spacing are set via modifiers. Why: Different syntax, same goal—predictable layout.

- State
  - SwiftUI uses property wrappers (`@State`, `@ObservedObject`, `@StateObject`, environment) and observable models; RN uses `useState/useReducer` and context. Why: Both are unidirectional; names differ but patterns are familiar.

- Navigation
  - SwiftUI’s `NavigationStack`/`NavigationSplitView` vs RN navigators. Why: Native navigation feels more integrated and uses type-safe routes.

- Packages
  - Swift Package Manager vs npm/yarn. Why: SPM integrates with Xcode and manages native dependencies directly.

- Hot reload/preview
  - SwiftUI Previews provide live previews in Xcode; RN offers Fast Refresh. Why: Both accelerate UI iteration, but previews run inside Xcode.

- Platform APIs
  - SwiftUI has direct access to iOS frameworks (e.g., speech, haptics). RN needs native modules or third-party libraries. Why: Fewer layers to cross in SwiftUI.

### What to do next (right now)
- Create the folders listed in Project structure.
- Add an app-wide state holder with an `isSignedIn` boolean.
- Build a simple fake Sign-In screen that toggles `isSignedIn` to true when tapped.
- Build a Content screen with a heading and a search bar that stores a non-empty query.
- Wire the root view to show Sign-In when `isSignedIn` is false and Content when true.
- Add a mock ArticleService that returns a static article for any query when the search button is tapped.
- Add an AudioService interface and a disabled play/pause control to the Content screen to signal listening is coming.

Following this plan ensures you have a working, testable flow quickly and a clean architecture ready for real auth, real article generation, and text-to-speech.


### Milestone 2 — Topic → Article generation (OpenAI) with navigation

Goal: When the user types a topic and taps Search, generate an article using OpenAI and navigate to a new page that displays the article.

High-level approach
- Keep UI simple: search happens in the Content screen, results render in a dedicated Article screen.
- Use a service layer to call OpenAI, with a mock fallback for development and offline work.
- Maintain unidirectional flow: View → ViewModel → Service → ViewModel → View.

What to build (files and why)
1) Shared data model
   - File: `Shared/Models/Article.swift`
   - Content: An `Article` type with fields like `id`, `topic`, `title`, `summary`, `body`, `createdAt`.
   - Why: One canonical structure to pass between service, view models, and views.

2) Article service protocol
   - File: `Shared/Servicesv/ArticleService/ArticleService.swift`
   - Content: A protocol with a single method like `generateArticle(for topic) → Article` (async/throws).
   - Why: Decouples the UI from OpenAI specifics; makes it easy to swap in a mock or a different provider.

3) OpenAI-backed implementation
   - File: `Shared/Services/ArticleService/OpenAIArticleService.swift`
   - Content: A concrete type that calls OpenAI’s text generation endpoint (chat or responses API) and maps the response into `Article`.
   - Why: Real implementation hidden behind the protocol maintains testability and avoids vendor lock across the UI layer.

4) Mock implementation
   - File: `Shared/Services/ArticleService/MockArticleService.swift`
   - Content: Return a static `Article` after a short delay.
   - Why: Instant local development, no cost, no network, and predictable tests.

5) Content feature view model
   - File: `Features/Content/ViewModels/ContentViewModel.swift`
   - Content: Holds `searchQuery`, `isSearching`, optional `errorMessage`. On search: validate input (non-empty, ≤ 20 chars), call the service, then route to the Article screen with the result.
   - Why: Keeps logic out of the view; prepares for future validation and analytics.

6) Article screen
   - File: `Features/Article/Views/ArticleView.swift`
   - Content: Displays the `Article` (title, summary, body) in a scrollable layout and leaves space for a future “Listen” control.
   - Why: Dedicated space to read without the search UI clutter.

7) Navigation
   - Update: Wrap the content experience in a `NavigationStack` (either at the app root or inside the Content feature) and push to `ArticleView` after a successful generation.
   - Why: Keeps routing declarative and testable; mirrors the mental model (search → read).

Service integration (OpenAI) — how to wire it up
- API choice: Either use OpenAI Chat Completions or the newer Responses API. Pick a small, cost-efficient model for draft content (e.g., a lightweight GPT-4-class or equivalent). Keep the model name configurable.
- HTTP details: Build a standard POST request with `Authorization: Bearer <key>` and `Content-Type: application/json`. Include a system prompt (below) and a user message containing the topic. Parse the returned text and map it into the `Article` fields.
- Timeouts/retries: Set a reasonable timeout (e.g., 20–30s) and a single retry for transient errors. Surface readable error messages to the user (e.g., “Please try again”).
- Rate limiting: Add a minimal debounce or disable the search button while a request is in flight.

System prompt (use as the service’s system message)
"You are an expert educator creating a clear, structured, and engaging article about a single topic that a user provides. Write in concise, plain English suitable for a motivated beginner. Output should use short paragraphs and lists where helpful. Structure the article as: 1) Title (concise) 2) Overview (3–5 sentences) 3) Key Concepts (bulleted list with 4–8 items, each one-liner) 4) Step-by-Step (numbered list, 5–10 steps) 5) Practical Examples (2–3 compact examples) 6) Common Pitfalls (bulleted list) 7) Next Steps and Further Reading (links or keywords). Keep to roughly 700–900 words. Avoid fluff. Prefer active voice and specific wording. Make it friendly for text-to-speech: short sentences, minimal nested lists, and no long tables."

Security and configuration of the API key
- Best practice: Do not ship the OpenAI key in the app. Use your own backend as a proxy that holds the key and enforces quotas.
- Prototype-only option (use for local/dev, never ship): Add a `Config/Secrets.xcconfig` excluded from git with a `OPENAI_API_KEY` setting, wire it to Info.plist via build settings, and read it at runtime. Understand this is not secure and should not be used in production.

Dependency injection (where to put the service)
- Create an app-wide environment container (e.g., `App/AppEnvironment.swift`) that holds `articleService` and inject it using `.environment(…)` or `.environmentObject` at the root.
- Why: Centralized, swappable dependencies without scattering constructors across views.

Step-by-step implementation guide
1) Create `Article.swift` in `Shared/Models/` with the fields listed above.
   - Why: Establishes the data contract that all layers will share.

2) Create `ArticleService.swift` in `Shared/Services/ArticleService/` defining the service protocol.
   - Why: UI depends only on the protocol; real/mocks are interchangeable.

3) Create `MockArticleService.swift` returning a static `Article` (topic is echoed in title/body).
   - Why: Unblocks UI and navigation while the real API is being wired.

4) Create `OpenAIArticleService.swift` in `Shared/Services/ArticleService/` and implement the network call:
   - Build the request with model, messages (system + user), and a sensible max tokens.
   - Read the API key using your chosen approach (proxy server recommended; local xcconfig only for prototype).
   - Parse and map the response into an `Article`.
   - Why: Encapsulates vendor-specific details.

5) Add an environment container `AppEnvironment` in `App/` and initialize it in `lrnAnythingApp.swift` with either mock or OpenAI service.
   - Why: One place to switch implementations (mock in Debug, real in Release).

6) Create `ContentViewModel.swift` in `Features/Content/ViewModels/`:
   - Holds `searchQuery`, `isSearching`, `errorMessage`.
   - Exposes a `search()` method that validates the query and calls `articleService`.
   - On success, provide the resulting `Article` to the navigation layer (e.g., via a binding or a path push).
   - Why: Keeps the view simple and predictable.

7) Update `ContentView` to use the view model and perform navigation:
   - Disable the button while `isSearching` or when `searchQuery` is empty.
   - After success, navigate to `ArticleView` with the generated `Article`.
   - Why: Clear action-feedback loop for the user.

8) Create `ArticleView.swift` under `Features/Article/Views/` to render the article with a scroll view and semantic headings.
   - Reserve space for a future “Listen” button.
   - Why: Keeps reading focused and prepares for TTS.

9) Add basic tests:
   - Service: Given a topic, mock returns deterministic `Article`.
   - ViewModel: `search()` disables input, calls service, handles success/error, and re-enables input.
   - Why: Prevent regressions while iterating on prompts and UI.

10) Prompt iteration checklist:
   - Validate section headings are present and consistent.
   - Tune length/temperature as needed for clarity and cost.
   - Add light post-processing (e.g., trimming whitespace) if needed.
   - Why: Stabilizes user experience across topics.

Rollout tips
- Start with the mock by default; add a simple toggle (Debug only) to switch to OpenAI.
- Log timing and failure reasons (Debug only) to guide retries/backoff.
- Keep the system prompt versioned in the service so changes are traceable.

### Milestone 3 — Audio generation (OpenAI TTS), local cache, and player

Goal: Convert generated article text to speech as MP3, save locally, and play immediately as chunks arrive (play chunk 1 while chunk 2+ are generating). Provide play/pause/seek UI and basic persistence.

High-level approach
- Chunk article text into ~800-character pieces (paragraph-aware), TTS each chunk, and queue audio items in `AVQueuePlayer` as soon as they finish.
- Save MP3s under Documents so subsequent plays are instant and offline.
- Maintain a lightweight JSON index for audio tracks per article.

What to build (files and why)
1) `Shared/Services/AudioService/AudioService.swift`
   - Protocol: `synthesizeSpeech(text:voice) → Data` (async/throws).
   - Why: Swappable TTS backends (OpenAI or mock) without touching UI.

2) `Shared/Services/AudioService/OpenAITTSService.swift`
   - Implementation calling `POST https://api.openai.com/v1/audio/speech` with `{ model: "tts-1" | "gpt-4o-mini-tts", input, voice: "alloy", format: "mp3" }`.
   - Why: Returns raw MP3 bytes, independent of playback.

3) `Shared/Storage/AudioStorage.swift` and `Shared/Models/AudioIndex.swift`
   - Layout: `Documents/Articles/<articleId>/chunk_<index>.mp3` and `audio_index.json`.
   - API: `saveAudio(articleId:topic:audioData:chunkIndex:) -> URL`, `trackURLs(for:) -> [URL]`.
   - Why: Reliable on-disk cache and lookup without a database.

4) `Shared/Managers/AudioManager.swift`
   - Wrap `AVQueuePlayer` with `play()`, `pause()`, `seek(to:)`, `replaceQueue(with:)`, `addTrack(_:)`.
   - Publishes `isPlaying`, `currentTime`, `duration` for UI binding.
   - Why: Central, testable playback control.

5) `Features/Article/ViewModels/ArticleAudioViewModel.swift`
   - Orchestrates chunking → TTS → save → enqueue. Starts playback once chunk 1 is saved; appends subsequent chunks.
   - Publishes `isGenerating`, `progress`, and `errorMessage`.
   - Why: Keeps complexity out of the views.

6) `Features/Audio/Views/AudioPlayerView.swift`
   - Play/Pause + Slider UI bound to `AudioManager`.
   - Why: Reusable player control for any screen.

7) Integrate into article flow
   - `Features/Article/Views/ArticleView.swift`: on appear, play cached audio if available; if none, auto-generate and start playback. Show progress and controls.
   - `Features/Article/Views/GenerateArticleView.swift`: unchanged logic; after article generation, navigates to `ArticleView`.
   - Why: Users hear audio quickly without an extra tap and can scrub reliably.

OpenAI details (TTS)
- Endpoint: `POST /v1/audio/speech` with Bearer key.
- Models: `gpt-4o-mini-tts` (preferred) or `tts-1`.
- Voices: `alloy` to start; make configurable later.
- Errors: 401/404/429/etc. → show readable error and allow Retry. Use chunking to avoid very long inputs.

Persistence decisions (and why)
- MP3s in Documents/Articles: predictable paths, easy cleanup.
- JSON index: small structure that maps article → tracks; faster than scanning directories.
- Recent articles via `@AppStorage` (optional enhancement): keep a small list of recent article metadata for quick access.

Step-by-step to implement (done in code)
1) Add `AudioService` protocol and `OpenAITTSService`.
2) Add `AudioStorage` and `AudioIndex` JSON model.
3) Add `AudioManager` (`AVQueuePlayer`) with published state.
4) Add `ArticleAudioViewModel` for chunking, generation, and queueing.
5) Add `AudioPlayerView` and integrate into `ArticleView` with progress and retry.
6) Update `AppEnvironment` to hold `audioService`, `audioStorage`, and `audioManager`; initialize in `lrnAnythingApp.swift`.
7) Auto-generate audio on `ArticleView` if no cached tracks; otherwise play cached immediately.

Test checklist
- Generate article, confirm playback starts after first chunk while later chunks append.
- Scrub and pause/resume work; leaving and returning to article uses cached audio instantly.
- Turn off network after first chunk and verify playback continues with downloaded parts.
- Delete app and reinstall: no leftover files; index is rebuilt as you generate again.

### Mile stone 4 recent article + audio
Recent/saved articles: stored locally, not in Firebase.
JSON-encoded into UserDefaults via AppStorage.
ArticleManager.swiftLines 22-29
    @Published var recentArticles: [GeneratedArticle] = []    @Published var savedArticles: [GeneratedArticle] = []    @AppStorage("recentArticles") private var recentArticlesData: Data = Data()    @AppStorage("savedArticles") private var savedArticlesData: Data = Data()
ArticleManager.swiftLines 34-50
    private func loadArticles() {        if let recent = try? JSONDecoder().decode([GeneratedArticle].self, from: recentArticlesData) {            recentArticles = recent        }        if let saved = try? JSONDecoder().decode([GeneratedArticle].self, from: savedArticlesData) {            savedArticles = saved        }    }    private func saveArticles() {        if let encodedRecent = try? JSONEncoder().encode(recentArticles) {            recentArticlesData = encodedRecent        }        if let encodedSaved = try? JSONEncoder().encode(savedArticles) {            savedArticlesData = encodedSaved        }    }
Audio files: saved as MP3 in the app’s Documents folder with a small JSON index; not in Firebase.
AudioManager.swiftLines 35-41
}
    private let fileManager = FileManager.default    private let metadataFileName = "audioMetadata.json"    private var metadataURL: URL {        return try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)            .appendingPathComponent(metadataFileName)    }
AudioManager.swiftLines 176-190
func saveAudio(for article: GeneratedArticle, with audioData: Data, chunkIndex: Int) throws -> URL {    let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)    let audioFileName = "\(article.id)_\(UUID().uuidString)_\(chunkIndex).mp3"    let audioUrl = documentsDirectory.appendingPathComponent(audioFileName)    try audioData.write(to: audioUrl)    ...    return audioUrl}
AudioManager.swiftLines 192-216
func getAudioURLs(for articleId: String) -> [URL] {    guard let metadata = audioMetadata[articleId] else { return [] }    let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)    var validUrls: [URL] = []    ...    return validUrls}
TTS returns MP3 bytes already; we don’t convert formats locally.
PromptEngine.swiftLines 37-56
}
func synthesizeSpeech(text: String) async throws -> Data { /* POST /v1/audio/speech */ return data }
What to use for “temporary async storage” (when you don’t need long-term persistence):
In-memory (fast, ephemeral): properties on your ViewModels/Managers; @Published, @State, NSCache for evictable objects.
URLCache: built-in HTTP response cache for network requests.
File-based temporary:
Caches directory: survives app restarts, iOS may purge; good for large re-downloadable files (audio/images).
tmp directory: truly temporary; iOS may delete at any time.
Long-term/persistent:
Documents directory (what we use for MP3s) keeps files until you delete.
UserDefaults/@AppStorage for small key-value blobs (we store recent/saved lists here).
Core Data/SwiftData if data grows or needs queries/relations.