import Foundation
import Combine

// MARK: - Airtable Configuration
struct AirtableConfig {
    static let baseId = "appmul5QQ7fC0RlfB"
    static let apiKey = "patmH6KZTNDCGNbhX.7fcdbf3b4042c83f98eed229566b5735279e6e33db0473ba7a98eadd8283a667"
    static let baseURL = "https://api.airtable.com/v0"

    // Table names
    static let zonesTable = "Zones"
    static let structuresTable = "Structures"
    static let materialsTable = "Materials"
    static let sessionsTable = "Build_Sessions"
    static let zoneMaterialsTable = "Zone_Materials"
    static let structureMaterialsTable = "Structure_Materials"
    static let projectTable = "Project"
}

// MARK: - Zone Local State (for fields not yet in Airtable)
struct ZoneLocalState: Codable {
    var isVisibleToKids: Bool
    var status: String
    var teaserMessage: String?
}

// MARK: - Airtable Error
enum AirtableError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case unauthorized
    case notFound
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        case .unauthorized:
            return "Unauthorized - check API key"
        case .notFound:
            return "Record not found"
        case .rateLimited:
            return "Rate limited - please wait"
        }
    }
}

// MARK: - Airtable Service
@MainActor
class AirtableService: ObservableObject {
    static let shared = AirtableService()

    // Published data for SwiftUI binding
    @Published var zones: [Zone] = []
    @Published var structures: [Structure] = []
    @Published var materials: [Material] = []
    @Published var sessions: [BuildSession] = []
    @Published var isLoading = false
    @Published var lastError: AirtableError?

    // Computed stats for dashboard
    @Published var totalBlocksPlaced: Int = 0
    @Published var totalBlocksPlanned: Int = 0
    @Published var totalBuildMinutes: Int = 0

    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - URL Builder
    private func buildURL(table: String, recordId: String? = nil, queryParams: [String: String]? = nil) -> URL? {
        var urlString = "\(AirtableConfig.baseURL)/\(AirtableConfig.baseId)/\(table)"

        if let recordId = recordId {
            urlString += "/\(recordId)"
        }

        guard var components = URLComponents(string: urlString) else { return nil }

        if let params = queryParams {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        return components.url
    }

    // MARK: - Request Builder
    private func buildRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(AirtableConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    // MARK: - Generic Fetch
    private func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let request = buildRequest(url: url)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AirtableError.networkError(NSError(domain: "Invalid response", code: 0))
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw AirtableError.decodingError(error)
                }
            case 401:
                throw AirtableError.unauthorized
            case 404:
                throw AirtableError.notFound
            case 429:
                throw AirtableError.rateLimited
            default:
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw AirtableError.apiError(message)
                }
                throw AirtableError.apiError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as AirtableError {
            throw error
        } catch {
            throw AirtableError.networkError(error)
        }
    }

    // MARK: - Fetch All Records (with pagination)
    private func fetchAllRecords(from table: String, filter: String? = nil, sort: [(field: String, direction: String)]? = nil) async throws -> [AirtableRecord] {
        var allRecords: [AirtableRecord] = []
        var offset: String? = nil

        repeat {
            var params: [String: String] = [:]

            if let filter = filter {
                params["filterByFormula"] = filter
            }

            if let sort = sort {
                for (index, item) in sort.enumerated() {
                    params["sort[\(index)][field]"] = item.field
                    params["sort[\(index)][direction]"] = item.direction
                }
            }

            if let offset = offset {
                params["offset"] = offset
            }

            guard let url = buildURL(table: table, queryParams: params.isEmpty ? nil : params) else {
                throw AirtableError.invalidURL
            }

            let response: AirtableResponse = try await fetch(AirtableResponse.self, from: url)
            allRecords.append(contentsOf: response.records)
            offset = response.offset

        } while offset != nil

        return allRecords
    }

    // MARK: - Load All Data (Kids View - filtered)
    func loadKidsData() async {
        isLoading = true
        lastError = nil

        do {
            // Fetch all data - filtering happens client-side based on Is_Visible_To_Kids
            // (These fields may not exist in Airtable yet, so we load everything)
            async let zonesTask = fetchAllRecords(
                from: AirtableConfig.zonesTable,
                sort: [(field: "Zone_Number", direction: "asc")]
            )

            async let structuresTask = fetchAllRecords(
                from: AirtableConfig.structuresTable
            )

            async let sessionsTask = fetchAllRecords(
                from: AirtableConfig.sessionsTable,
                sort: [(field: "Session_Date", direction: "desc")]
            )

            async let materialsTask = fetchAllRecords(
                from: AirtableConfig.materialsTable
            )

            let (zonesRecords, structuresRecords, sessionsRecords, materialsRecords) = try await (
                zonesTask, structuresTask, sessionsTask, materialsTask
            )

            // Convert to models
            self.zones = zonesRecords.map { Zone(from: $0) }
            self.structures = structuresRecords.map { Structure(from: $0) }
            self.sessions = Array(sessionsRecords.map { BuildSession(from: $0) }.prefix(10)) // Last 10 sessions
            self.materials = materialsRecords.map { Material(from: $0) }

            // Apply locally saved zone states (for fields not in Airtable yet)
            applyLocalZoneStates()

            // Calculate stats
            calculateStats()

        } catch let error as AirtableError {
            self.lastError = error
            print("❌ Airtable error: \(error.localizedDescription)")
        } catch {
            self.lastError = .networkError(error)
            print("❌ Network error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Load All Data (Dad View - unfiltered)
    func loadAllData() async {
        isLoading = true
        lastError = nil

        do {
            async let zonesTask = fetchAllRecords(
                from: AirtableConfig.zonesTable,
                sort: [(field: "Zone_Number", direction: "asc")]
            )

            async let structuresTask = fetchAllRecords(
                from: AirtableConfig.structuresTable
            )

            async let sessionsTask = fetchAllRecords(
                from: AirtableConfig.sessionsTable,
                sort: [(field: "Session_Date", direction: "desc")]
            )

            async let materialsTask = fetchAllRecords(
                from: AirtableConfig.materialsTable
            )

            let (zonesRecords, structuresRecords, sessionsRecords, materialsRecords) = try await (
                zonesTask, structuresTask, sessionsTask, materialsTask
            )

            self.zones = zonesRecords.map { Zone(from: $0) }
            self.structures = structuresRecords.map { Structure(from: $0) }
            self.sessions = sessionsRecords.map { BuildSession(from: $0) }
            self.materials = materialsRecords.map { Material(from: $0) }

            // Apply locally saved zone states (for fields not in Airtable yet)
            applyLocalZoneStates()

            calculateStats()

        } catch let error as AirtableError {
            self.lastError = error
            print("❌ Airtable error: \(error.localizedDescription)")
        } catch {
            self.lastError = .networkError(error)
            print("❌ Network error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Calculate Stats
    private func calculateStats() {
        totalBlocksPlaced = zones.reduce(0) { $0 + ($1.blocksPlacedRollup ?? 0) }
        totalBlocksPlanned = zones.reduce(0) { $0 + ($1.blocksPlannedRollup ?? 0) }
        totalBuildMinutes = sessions.reduce(0) { $0 + ($1.durationMinutes ?? 0) }
    }

    // MARK: - CRUD Operations (Dad App)

    // Create Session
    func createSession(_ session: BuildSession) async throws -> BuildSession {
        guard let url = buildURL(table: AirtableConfig.sessionsTable) else {
            throw AirtableError.invalidURL
        }

        let createRequest = AirtableCreateRequest(fields: session.toAirtableFields())
        let body = try JSONEncoder().encode(createRequest)

        let request = buildRequest(url: url, method: "POST", body: body)

        let (data, response) = try await self.session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AirtableError.apiError("Invalid response")
        }

        // Log response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📝 Create session response (\(httpResponse.statusCode)): \(responseString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                print("❌ Create session error: \(message)")
                throw AirtableError.apiError(message)
            }
            throw AirtableError.apiError("Failed to create session (HTTP \(httpResponse.statusCode))")
        }

        let decoder = JSONDecoder()
        let record = try decoder.decode(AirtableRecord.self, from: data)
        let newSession = BuildSession(from: record)

        // Update local data
        self.sessions.insert(newSession, at: 0)
        calculateStats()

        return newSession
    }

    // Update Zone
    func updateZone(_ zone: Zone) async throws {
        guard let url = buildURL(table: AirtableConfig.zonesTable, recordId: zone.id) else {
            throw AirtableError.invalidURL
        }

        let updateRequest = AirtableCreateRequest(fields: zone.toAirtableFields())
        let body = try JSONEncoder().encode(updateRequest)

        let request = buildRequest(url: url, method: "PATCH", body: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AirtableError.apiError("Invalid response")
        }

        // Handle field errors - store locally if Airtable rejects the field
        if httpResponse.statusCode == 422 {
            // Fields don't exist in Airtable - save locally instead
            print("⚠️ Airtable fields missing - saving zone state locally")
            saveZoneStateLocally(zone)
            // Update local data anyway
            if let index = zones.firstIndex(where: { $0.id == zone.id }) {
                zones[index] = zone
            }
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                print("❌ Airtable error: \(message)")
                // If it's an unknown field error, save locally
                if message.contains("Unknown field") {
                    print("⚠️ Saving zone state locally due to missing Airtable fields")
                    saveZoneStateLocally(zone)
                    if let index = zones.firstIndex(where: { $0.id == zone.id }) {
                        zones[index] = zone
                    }
                    return
                }
                throw AirtableError.apiError(message)
            }
            throw AirtableError.apiError("Failed to update zone (HTTP \(httpResponse.statusCode))")
        }

        // Update local data
        if let index = zones.firstIndex(where: { $0.id == zone.id }) {
            zones[index] = zone
        }
    }

    // MARK: - Local Storage Fallback
    private let localStorageKey = "ZoneLocalState"

    private func saveZoneStateLocally(_ zone: Zone) {
        var savedStates = loadLocalZoneStates()
        savedStates[zone.id] = ZoneLocalState(
            isVisibleToKids: zone.isVisibleToKids,
            status: zone.status.rawValue,
            teaserMessage: zone.teaserMessage
        )
        if let data = try? JSONEncoder().encode(savedStates) {
            UserDefaults.standard.set(data, forKey: localStorageKey)
        }
    }

    private func loadLocalZoneStates() -> [String: ZoneLocalState] {
        guard let data = UserDefaults.standard.data(forKey: localStorageKey),
              let states = try? JSONDecoder().decode([String: ZoneLocalState].self, from: data) else {
            return [:]
        }
        return states
    }

    func applyLocalZoneStates() {
        let localStates = loadLocalZoneStates()
        for (index, zone) in zones.enumerated() {
            if let localState = localStates[zone.id] {
                zones[index].isVisibleToKids = localState.isVisibleToKids
                if let status = ZoneStatus(rawValue: localState.status) {
                    zones[index].status = status
                }
                zones[index].teaserMessage = localState.teaserMessage
            }
        }
    }

    // Update Structure
    func updateStructure(_ structure: Structure) async throws {
        guard let url = buildURL(table: AirtableConfig.structuresTable, recordId: structure.id) else {
            throw AirtableError.invalidURL
        }

        let updateRequest = AirtableCreateRequest(fields: structure.toAirtableFields())
        let body = try JSONEncoder().encode(updateRequest)

        var request = buildRequest(url: url, method: "PATCH", body: body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AirtableError.apiError("Failed to update structure")
        }

        if let index = structures.firstIndex(where: { $0.id == structure.id }) {
            structures[index] = structure
        }
    }

    // Toggle Zone Visibility
    func toggleZoneVisibility(zoneId: String) async throws {
        guard var zone = zones.first(where: { $0.id == zoneId }) else {
            throw AirtableError.notFound
        }

        zone.isVisibleToKids.toggle()
        try await updateZone(zone)
    }

    // Set Zone Status
    func setZoneStatus(zoneId: String, status: ZoneStatus) async throws {
        guard var zone = zones.first(where: { $0.id == zoneId }) else {
            throw AirtableError.notFound
        }

        zone.status = status
        try await updateZone(zone)
    }

    // Update Teaser Message
    func updateTeaserMessage(zoneId: String, message: String?) async throws {
        guard var zone = zones.first(where: { $0.id == zoneId }) else {
            throw AirtableError.notFound
        }

        zone.teaserMessage = message
        try await updateZone(zone)
    }
}

// MARK: - Quick Stats Helper
extension AirtableService {
    var overallProgress: Double {
        guard totalBlocksPlanned > 0 else { return 0 }
        return Double(totalBlocksPlaced) / Double(totalBlocksPlanned)
    }

    var formattedBuildTime: String {
        let hours = totalBuildMinutes / 60
        let minutes = totalBuildMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var activeZone: Zone? {
        zones.first { $0.status == .building }
    }

    var completedZonesCount: Int {
        zones.filter { $0.status == .complete }.count
    }

    var recentSession: BuildSession? {
        sessions.first
    }
}
