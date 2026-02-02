import Foundation
import SwiftUI
import Combine

// MARK: - Claude Configuration
struct ClaudeConfig {
    static var apiKey: String {
        // API key should be set at runtime for security
        UserDefaults.standard.string(forKey: "claude_api_key") ?? ""
    }
    static let baseURL = "https://api.anthropic.com/v1/messages"
    static let model = "claude-sonnet-4-20250514"
    static let maxTokens = 4096
}

// MARK: - Claude Message Types
struct ClaudeMessage: Codable, Identifiable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date

    enum MessageRole: String, Codable {
        case user
        case assistant
    }

    init(role: MessageRole, content: String) {
        self.id = UUID().uuidString
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

// MARK: - Claude API Request/Response
private struct ClaudeAPIRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [APIMessage]
    let tools: [ClaudeTool]?

    struct APIMessage: Codable {
        let role: String
        let content: String
    }
}

private struct ClaudeAPIResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let stop_reason: String?

    struct ContentBlock: Codable {
        let type: String
        let text: String?
        let id: String?
        let name: String?
        let input: [String: AnyCodable]?
    }
}

// MARK: - Claude Tools (Function Calling)
struct ClaudeTool: Codable {
    let name: String
    let description: String
    let input_schema: InputSchema

    struct InputSchema: Codable {
        let type: String
        let properties: [String: Property]
        let required: [String]
    }

    struct Property: Codable {
        let type: String
        let description: String
        let enum_values: [String]?

        enum CodingKeys: String, CodingKey {
            case type, description
            case enum_values = "enum"
        }
    }
}

// MARK: - Claude Service
@MainActor
class ClaudeService: ObservableObject {
    static let shared = ClaudeService()

    @Published var messages: [ClaudeMessage] = []
    @Published var isProcessing = false
    @Published var lastError: String?

    private let airtable = AirtableService.shared

    // System prompt for the AI assistant
    private let systemPrompt = """
    You are the TEAM STREEM REALM Build Assistant - a helpful AI that manages Dad's epic Minecraft mega-build project!

    Your personality:
    - Enthusiastic about Minecraft and the build project
    - Supportive and encouraging
    - Uses appropriate Minecraft terminology and occasional emojis
    - Keeps responses concise but informative

    You have access to the Airtable database through these tools:
    - log_session: Record a new build session with blocks placed, duration, mood, and notes
    - update_zone: Change zone status, visibility, or teaser message
    - get_stats: Retrieve current project statistics
    - toggle_visibility: Show/hide zones or structures from the kids

    Current project context (refreshed each message):
    - Total zones: {zone_count}
    - Zones complete: {complete_count}
    - Total blocks placed: {blocks_placed}
    - Total blocks planned: {blocks_planned}
    - Overall progress: {progress}%

    When the user wants to log a session, ask for:
    1. How many blocks were placed
    2. How long they built (minutes)
    3. Which zone(s) they worked on
    4. Their mood (Master Builder 🏆, On Fire 🔥, Brick by Brick 🧱, Creeper Problems 😤, Mined Out 😴)
    5. Any notes for the kids (optional)

    Always confirm actions before executing them.
    """

    // Available tools for function calling
    private let tools: [ClaudeTool] = [
        ClaudeTool(
            name: "log_session",
            description: "Log a new build session to the database",
            input_schema: ClaudeTool.InputSchema(
                type: "object",
                properties: [
                    "blocks_placed": ClaudeTool.Property(type: "integer", description: "Number of blocks placed this session", enum_values: nil),
                    "duration_minutes": ClaudeTool.Property(type: "integer", description: "Duration of the session in minutes", enum_values: nil),
                    "mood": ClaudeTool.Property(type: "string", description: "Builder's mood", enum_values: ["🏆 Master Builder", "🔥 On Fire", "🧱 Brick by Brick", "😤 Creeper Problems", "😴 Mined Out"]),
                    "notes": ClaudeTool.Property(type: "string", description: "Notes to share with the kids (optional)", enum_values: nil),
                    "zone_ids": ClaudeTool.Property(type: "string", description: "Comma-separated zone IDs worked on", enum_values: nil)
                ],
                required: ["blocks_placed", "duration_minutes", "mood"]
            )
        ),
        ClaudeTool(
            name: "update_zone",
            description: "Update a zone's status, visibility, or teaser message",
            input_schema: ClaudeTool.InputSchema(
                type: "object",
                properties: [
                    "zone_id": ClaudeTool.Property(type: "string", description: "The zone record ID", enum_values: nil),
                    "status": ClaudeTool.Property(type: "string", description: "New status (optional)", enum_values: ["locked", "building", "complete"]),
                    "is_visible": ClaudeTool.Property(type: "boolean", description: "Whether kids can see this zone (optional)", enum_values: nil),
                    "teaser_message": ClaudeTool.Property(type: "string", description: "Mystery teaser for locked zones (optional)", enum_values: nil)
                ],
                required: ["zone_id"]
            )
        ),
        ClaudeTool(
            name: "get_stats",
            description: "Get current project statistics",
            input_schema: ClaudeTool.InputSchema(
                type: "object",
                properties: [:],
                required: []
            )
        ),
        ClaudeTool(
            name: "toggle_visibility",
            description: "Toggle visibility of a zone or structure for the kids",
            input_schema: ClaudeTool.InputSchema(
                type: "object",
                properties: [
                    "type": ClaudeTool.Property(type: "string", description: "Type of item", enum_values: ["zone", "structure"]),
                    "id": ClaudeTool.Property(type: "string", description: "Record ID", enum_values: nil)
                ],
                required: ["type", "id"]
            )
        )
    ]

    private init() {
        // Load conversation history from UserDefaults
        loadMessages()
    }

    // MARK: - Build Context
    private func buildContext() -> String {
        return systemPrompt
            .replacingOccurrences(of: "{zone_count}", with: "\(airtable.zones.count)")
            .replacingOccurrences(of: "{complete_count}", with: "\(airtable.completedZonesCount)")
            .replacingOccurrences(of: "{blocks_placed}", with: "\(airtable.totalBlocksPlaced)")
            .replacingOccurrences(of: "{blocks_planned}", with: "\(airtable.totalBlocksPlanned)")
            .replacingOccurrences(of: "{progress}", with: String(format: "%.1f", airtable.overallProgress * 100))
    }

    // MARK: - Send Message
    func sendMessage(_ text: String) async {
        guard !ClaudeConfig.apiKey.isEmpty else {
            lastError = "Claude API key not configured. Go to Settings to add your key."
            return
        }

        // Add user message
        let userMessage = ClaudeMessage(role: .user, content: text)
        messages.append(userMessage)
        saveMessages()

        isProcessing = true
        lastError = nil

        do {
            // Build API request
            let apiMessages = messages.suffix(20).map { msg in // Keep last 20 for context
                ClaudeAPIRequest.APIMessage(role: msg.role.rawValue, content: msg.content)
            }

            let request = ClaudeAPIRequest(
                model: ClaudeConfig.model,
                max_tokens: ClaudeConfig.maxTokens,
                system: buildContext(),
                messages: Array(apiMessages),
                tools: tools
            )

            // Make API call
            guard let url = URL(string: ClaudeConfig.baseURL) else {
                throw NSError(domain: "Invalid URL", code: 0)
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue(ClaudeConfig.apiKey, forHTTPHeaderField: "x-api-key")
            urlRequest.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(request)

            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "Invalid response", code: 0)
            }

            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw NSError(domain: message, code: httpResponse.statusCode)
                }
                throw NSError(domain: "API Error", code: httpResponse.statusCode)
            }

            let apiResponse = try JSONDecoder().decode(ClaudeAPIResponse.self, from: data)

            // Process response
            var responseText = ""
            for block in apiResponse.content {
                if block.type == "text", let text = block.text {
                    responseText += text
                } else if block.type == "tool_use", let toolName = block.name, let input = block.input {
                    // Handle tool calls
                    let toolResult = await handleToolCall(name: toolName, input: input)
                    responseText += "\n\n\(toolResult)"
                }
            }

            // Add assistant message
            let assistantMessage = ClaudeMessage(role: .assistant, content: responseText)
            messages.append(assistantMessage)
            saveMessages()

        } catch {
            lastError = error.localizedDescription
            print("❌ Claude API error: \(error)")
        }

        isProcessing = false
    }

    // MARK: - Handle Tool Calls
    private func handleToolCall(name: String, input: [String: AnyCodable]) async -> String {
        switch name {
        case "log_session":
            return await logSession(input)
        case "update_zone":
            return await updateZone(input)
        case "get_stats":
            return getStats()
        case "toggle_visibility":
            return await toggleVisibility(input)
        default:
            return "Unknown tool: \(name)"
        }
    }

    private func logSession(_ input: [String: AnyCodable]) async -> String {
        let blocksPlaced = input["blocks_placed"]?.value as? Int ?? 0
        let duration = input["duration_minutes"]?.value as? Int ?? 0
        let moodStr = input["mood"]?.value as? String ?? "🧱 Brick by Brick"
        let notes = input["notes"]?.value as? String
        let zoneIdsStr = input["zone_ids"]?.value as? String

        let mood = BuildMood(rawValue: moodStr) ?? .brickByBrick

        var session = BuildSession.new()
        session.blocksPlacedThisSession = blocksPlaced
        session.durationMinutes = duration
        session.mood = mood
        session.notesDisplay = notes
        session.isVisibleToKids = true

        if let zonesStr = zoneIdsStr {
            session.zoneIds = zonesStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        do {
            let created = try await airtable.createSession(session)
            return "✅ **Session Logged!**\n- Blocks: \(blocksPlaced)\n- Duration: \(duration) minutes\n- Mood: \(mood.emoji) \(mood.shortName)\n\nThe kids will see this update! 🎉"
        } catch {
            return "❌ Failed to log session: \(error.localizedDescription)"
        }
    }

    private func updateZone(_ input: [String: AnyCodable]) async -> String {
        guard let zoneId = input["zone_id"]?.value as? String else {
            return "❌ Zone ID is required"
        }

        do {
            if let statusStr = input["status"]?.value as? String,
               let status = ZoneStatus(rawValue: statusStr) {
                try await airtable.setZoneStatus(zoneId: zoneId, status: status)
            }

            if let isVisible = input["is_visible"]?.value as? Bool {
                if var zone = airtable.zones.first(where: { $0.id == zoneId }) {
                    zone.isVisibleToKids = isVisible
                    try await airtable.updateZone(zone)
                }
            }

            if let teaser = input["teaser_message"]?.value as? String {
                try await airtable.updateTeaserMessage(zoneId: zoneId, message: teaser)
            }

            return "✅ Zone updated successfully!"
        } catch {
            return "❌ Failed to update zone: \(error.localizedDescription)"
        }
    }

    private func getStats() -> String {
        let progress = String(format: "%.1f", airtable.overallProgress * 100)
        return """
        📊 **Project Stats**

        **Zones:** \(airtable.completedZonesCount)/\(airtable.zones.count) complete
        **Blocks:** \(airtable.totalBlocksPlaced.formatted()) / \(airtable.totalBlocksPlanned.formatted())
        **Progress:** \(progress)%
        **Build Time:** \(airtable.formattedBuildTime)

        **Recent Sessions:** \(airtable.sessions.prefix(3).count)
        """
    }

    private func toggleVisibility(_ input: [String: AnyCodable]) async -> String {
        guard let type = input["type"]?.value as? String,
              let id = input["id"]?.value as? String else {
            return "❌ Type and ID are required"
        }

        do {
            if type == "zone" {
                try await airtable.toggleZoneVisibility(zoneId: id)
                return "✅ Zone visibility toggled!"
            } else {
                return "❌ Structure visibility toggle not implemented yet"
            }
        } catch {
            return "❌ Failed to toggle visibility: \(error.localizedDescription)"
        }
    }

    // MARK: - Message Persistence
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "claude_messages")
        }
    }

    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "claude_messages"),
           let decoded = try? JSONDecoder().decode([ClaudeMessage].self, from: data) {
            messages = decoded
        }
    }

    func clearHistory() {
        messages = []
        saveMessages()
    }
}

// MARK: - API Key Management
extension ClaudeService {
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "claude_api_key")
    }

    var hasAPIKey: Bool {
        !ClaudeConfig.apiKey.isEmpty
    }
}
