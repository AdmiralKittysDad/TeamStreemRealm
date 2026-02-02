import Foundation
import SwiftUI

// MARK: - Zone Model
struct Zone: Identifiable, Codable {
    let id: String
    var zoneDisplay: String?
    var zoneProd: String?
    var zoneNumber: Int?
    var yStart: Int?
    var yEnd: Int?
    var totalLayers: Int?
    var layerProgressCount: Int?
    var blocksPlannedRollup: Int?
    var blocksPlacedRollup: Int?
    var blocksRemaining: Int?
    var progressFromAPI: Double?
    var hoursRollup: Double?

    // UI Control (defaults - can be enhanced with Airtable fields later)
    var isVisibleToKids: Bool = true
    var status: ZoneStatus = .building
    var teaserMessage: String?

    var displayName: String {
        // Clean up the display name (remove "Zone X:" prefix for cleaner UI)
        if let display = zoneDisplay {
            if display.contains(":") {
                return String(display.split(separator: ":").last ?? Substring(display)).trimmingCharacters(in: .whitespaces)
            }
            return display
        }
        return "Zone \(zoneNumber ?? 0)"
    }

    var fullDisplayName: String {
        zoneDisplay ?? "Zone \(zoneNumber ?? 0)"
    }

    var progress: Double {
        // Use API progress if available, otherwise calculate
        if let p = progressFromAPI {
            return p
        }
        guard let planned = blocksPlannedRollup, planned > 0,
              let placed = blocksPlacedRollup else { return 0 }
        return Double(placed) / Double(planned)
    }

    var layerProgress: Double {
        guard let total = totalLayers, total > 0,
              let complete = layerProgressCount else { return 0 }
        return Double(complete) / Double(total)
    }

    var isLocked: Bool {
        !isVisibleToKids || status == .locked
    }

    // Zone colors based on zone number - using theme colors
    var themeColor: Color {
        switch zoneNumber {
        case 1: return .mcPrismarine
        case 2: return .mcDiamond
        case 3: return .mcEmerald
        case 4: return .mcAmethyst
        case 5: return .mcGold
        default: return .mcStone
        }
    }

    var gradientColors: [Color] {
        switch zoneNumber {
        case 1: return [.mcPrismarine, .mcOceanDeep]
        case 2: return [.mcDiamond, .mcLapis]
        case 3: return [.mcEmerald, .mcDarkGreen]
        case 4: return [.mcAmethyst, Color(hex: "4a1a6b")]
        case 5: return [.mcGold, .mcCopper]
        default: return [.mcStone, .mcDeepslate]
        }
    }

    var emoji: String {
        switch zoneNumber {
        case 1: return "🌊"
        case 2: return "✨"
        case 3: return "🏝️"
        case 4: return "🗼"
        case 5: return "💎"
        default: return "🧱"
        }
    }

    var funDescription: String {
        switch zoneNumber {
        case 1: return "Deep beneath the waves..."
        case 2: return "Where light meets darkness!"
        case 3: return "Breaking the surface!"
        case 4: return "Reaching for the sky!"
        case 5: return "The crown jewel awaits!"
        default: return "Mystery zone!"
        }
    }
}

enum ZoneStatus: String, Codable {
    case locked = "locked"
    case building = "building"
    case complete = "complete"

    var displayText: String {
        switch self {
        case .locked: return "🔒 Mystery"
        case .building: return "⚒️ BUILDING"
        case .complete: return "✅ COMPLETE"
        }
    }

    var color: Color {
        switch self {
        case .locked: return .mcStone
        case .building: return .mcRedstone
        case .complete: return .mcEmerald
        }
    }
}

// MARK: - Airtable Mapping
extension Zone {
    init(from record: AirtableRecord) {
        self.id = record.id
        self.zoneDisplay = record.fields["Zone_Display"] as? String
        self.zoneProd = record.fields["Zone_Prod"] as? String
        self.zoneNumber = record.fields["Zone_Number"] as? Int
        self.yStart = record.fields["Y_Start_Prod"] as? Int
        self.yEnd = record.fields["Y_End_Prod"] as? Int
        self.totalLayers = record.fields["Total_Layers"] as? Int
        self.layerProgressCount = record.fields["Layer_Progress"] as? Int
        self.blocksPlannedRollup = record.fields["Blocks_Planned_Rollup"] as? Int
        self.blocksPlacedRollup = record.fields["Blocks_Placed_Rollup"] as? Int
        self.blocksRemaining = record.fields["Blocks_Remaining"] as? Int
        self.progressFromAPI = record.fields["Progress"] as? Double
        self.hoursRollup = record.fields["Hours_Rollup"] as? Double
        self.teaserMessage = record.fields["Teaser_Message"] as? String

        // Handle visibility - check both bool and int formats
        if let visible = record.fields["Is_Visible_To_Kids"] as? Bool {
            self.isVisibleToKids = visible
        } else if let visibleInt = record.fields["Is_Visible_To_Kids"] as? Int {
            self.isVisibleToKids = visibleInt == 1
        } else {
            self.isVisibleToKids = true // Default visible
        }

        // Determine status
        if let statusStr = record.fields["Status"] as? String,
           let parsedStatus = ZoneStatus(rawValue: statusStr) {
            self.status = parsedStatus
        } else {
            // Infer status from progress
            let prog = self.progress
            if prog >= 1.0 {
                self.status = .complete
            } else if prog > 0 || self.zoneNumber == 1 {
                self.status = .building
            } else {
                self.status = .locked
            }
        }
    }

    func toAirtableFields() -> [String: Any] {
        var fields: [String: Any] = [:]
        if let display = zoneDisplay { fields["Zone_Display"] = display }
        if let number = zoneNumber { fields["Zone_Number"] = number }
        if let layers = layerProgressCount { fields["Layer_Progress"] = layers }
        fields["Is_Visible_To_Kids"] = isVisibleToKids
        fields["Status"] = status.rawValue
        if let teaser = teaserMessage { fields["Teaser_Message"] = teaser }
        return fields
    }
}
