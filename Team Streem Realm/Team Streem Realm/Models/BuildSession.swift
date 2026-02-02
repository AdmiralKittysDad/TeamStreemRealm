import Foundation
import SwiftUI

// MARK: - Build Session Model
struct BuildSession: Identifiable, Codable {
    let id: String
    var sessionDate: Date?
    var startTime: Date?
    var endTime: Date?
    var durationMinutes: Int?
    var blocksPlacedThisSession: Int?
    var mood: BuildMood
    var notesDisplay: String?
    var notesInternal: String?
    var photoURL: URL?
    var isVisibleToKids: Bool
    var zoneIds: [String]?
    var structureIds: [String]?

    var formattedDate: String {
        guard let date = sessionDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        guard let minutes = durationMinutes else { return "--" }
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }

    var blocksPerMinute: Double? {
        guard let blocks = blocksPlacedThisSession,
              let minutes = durationMinutes,
              minutes > 0 else { return nil }
        return Double(blocks) / Double(minutes)
    }
}

enum BuildMood: String, Codable, CaseIterable {
    case masterBuilder = "🏆 Master Builder"
    case onFire = "🔥 On Fire"
    case brickByBrick = "🧱 Brick by Brick"
    case creeperProblems = "😤 Creeper Problems"
    case minedOut = "😴 Mined Out"

    var emoji: String {
        switch self {
        case .masterBuilder: return "🏆"
        case .onFire: return "🔥"
        case .brickByBrick: return "🧱"
        case .creeperProblems: return "😤"
        case .minedOut: return "😴"
        }
    }

    var shortName: String {
        switch self {
        case .masterBuilder: return "Master Builder"
        case .onFire: return "On Fire"
        case .brickByBrick: return "Brick by Brick"
        case .creeperProblems: return "Creeper Problems"
        case .minedOut: return "Mined Out"
        }
    }

    var color: Color {
        switch self {
        case .masterBuilder: return Color("Gold")
        case .onFire: return Color("Redstone")
        case .brickByBrick: return Color("Stone")
        case .creeperProblems: return Color("Emerald")
        case .minedOut: return Color("Lapis")
        }
    }
}

// MARK: - Airtable Mapping
extension BuildSession {
    init(from record: AirtableRecord) {
        self.id = record.id

        // Parse date
        if let dateStr = record.fields["Session_Date"] as? String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            self.sessionDate = formatter.date(from: dateStr)
        }

        // Duration can come from formula or input field
        if let duration = record.fields["Duration_Minutes"] as? Int {
            self.durationMinutes = duration
        } else if let duration = record.fields["Duration_Input_Minutes"] as? Int {
            self.durationMinutes = duration
        }
        self.blocksPlacedThisSession = record.fields["Blocks_Placed_This_Session"] as? Int
        self.notesDisplay = record.fields["Notes_Display"] as? String
        self.notesInternal = record.fields["Notes_Prod"] as? String  // Correct field name

        // Is_Visible_To_Kids is a checkbox (bool), not int
        if let visible = record.fields["Is_Visible_To_Kids"] as? Bool {
            self.isVisibleToKids = visible
        } else if let visibleInt = record.fields["Is_Visible_To_Kids"] as? Int {
            self.isVisibleToKids = visibleInt == 1
        } else {
            self.isVisibleToKids = true
        }

        self.zoneIds = record.fields["Zone_Worked"] as? [String]
        self.structureIds = record.fields["Structures_Worked"] as? [String]

        // Parse photo
        if let photos = record.fields["Photo"] as? [[String: Any]],
           let firstPhoto = photos.first,
           let thumbnails = firstPhoto["thumbnails"] as? [String: Any],
           let large = thumbnails["large"] as? [String: Any],
           let urlStr = large["url"] as? String {
            self.photoURL = URL(string: urlStr)
        }

        // Parse mood
        if let moodStr = record.fields["Mood"] as? String,
           let mood = BuildMood(rawValue: moodStr) {
            self.mood = mood
        } else {
            self.mood = .brickByBrick
        }
    }

    func toAirtableFields() -> [String: Any] {
        var fields: [String: Any] = [:]

        if let date = sessionDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            fields["Session_Date"] = formatter.string(from: date)
        }

        // Use Duration_Input_Minutes (writable) instead of Duration_Minutes (formula)
        if let duration = durationMinutes { fields["Duration_Input_Minutes"] = duration }
        if let blocks = blocksPlacedThisSession { fields["Blocks_Placed_This_Session"] = blocks }
        fields["Mood"] = mood.rawValue
        if let notes = notesDisplay { fields["Notes_Display"] = notes }
        if let internal_ = notesInternal { fields["Notes_Prod"] = internal_ }
        fields["Is_Visible_To_Kids"] = isVisibleToKids  // Checkbox expects bool
        if let zones = zoneIds, !zones.isEmpty { fields["Zone_Worked"] = zones }
        if let structures = structureIds, !structures.isEmpty { fields["Structures_Worked"] = structures }

        return fields
    }
}

// MARK: - New Session Helper
extension BuildSession {
    static func new() -> BuildSession {
        BuildSession(
            id: UUID().uuidString,
            sessionDate: Date(),
            startTime: nil,
            endTime: nil,
            durationMinutes: nil,
            blocksPlacedThisSession: nil,
            mood: .brickByBrick,
            notesDisplay: nil,
            notesInternal: nil,
            photoURL: nil,
            isVisibleToKids: true,
            zoneIds: nil,
            structureIds: nil
        )
    }
}
