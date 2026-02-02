import Foundation
import SwiftUI

// MARK: - Structure Model
struct Structure: Identifiable, Codable {
    let id: String
    var structureDisplay: String?
    var structureProd: String?
    var structureType: StructureType
    var blocksPlanned: Int?
    var blocksPlacedRollup: Int?
    var blocksRemaining: Int?
    var progressFromAPI: Double?
    var estimatedHours: Double?
    var hoursRollup: Double?
    var forecastHoursRemaining: Double?
    var whatWeTellTheKids: String?
    var whatReallyHappens: String?
    var isVisibleToKids: Bool
    var zoneIds: [String]?

    var displayName: String {
        structureDisplay ?? "Secret Build"
    }

    var progress: Double {
        if let p = progressFromAPI {
            return p
        }
        guard let planned = blocksPlanned, planned > 0,
              let placed = blocksPlacedRollup else { return 0 }
        return Double(placed) / Double(planned)
    }

    var blocksRemainingCount: Int {
        if let remaining = blocksRemaining {
            return remaining
        }
        let planned = blocksPlanned ?? 0
        let placed = blocksPlacedRollup ?? 0
        return max(0, planned - placed)
    }

    var icon: String {
        structureType.icon
    }

    var themeColor: Color {
        structureType.color
    }

    var kidsDescription: String {
        whatWeTellTheKids ?? "Something awesome is being built here!"
    }
}

enum StructureType: String, Codable, CaseIterable {
    case platform = "Platform"
    case tower = "Tower"
    case chamber = "Chamber"
    case system = "System"
    case bridge = "Bridge"
    case monument = "Monument"
    case other = "Other"

    var icon: String {
        switch self {
        case .platform: return "🏗️"
        case .tower: return "🗼"
        case .chamber: return "🏛️"
        case .system: return "⚙️"
        case .bridge: return "🌉"
        case .monument: return "🗿"
        case .other: return "🧱"
        }
    }

    var color: Color {
        switch self {
        case .platform: return .mcEmerald
        case .tower: return .mcAmethyst
        case .chamber: return .mcDiamond
        case .system: return .mcRedstone
        case .bridge: return .mcGold
        case .monument: return .mcPrismarine
        case .other: return .mcStone
        }
    }
}

// MARK: - Airtable Mapping
extension Structure {
    init(from record: AirtableRecord) {
        self.id = record.id
        self.structureDisplay = record.fields["Structure_Display"] as? String
        self.structureProd = record.fields["Structure_Prod"] as? String
        self.blocksPlanned = record.fields["Blocks_Planned"] as? Int
        self.blocksPlacedRollup = record.fields["Blocks_Placed_Rollup"] as? Int
        self.blocksRemaining = record.fields["Blocks_Remaining"] as? Int
        self.progressFromAPI = record.fields["Progress"] as? Double
        self.estimatedHours = record.fields["Estimated_Hours"] as? Double
        self.hoursRollup = record.fields["Hours_Rollup"] as? Double
        self.forecastHoursRemaining = record.fields["Forecast_Hours_Remaining"] as? Double
        self.whatWeTellTheKids = record.fields["What_We_Tell_The_Kids"] as? String
        self.whatReallyHappens = record.fields["What_Really_Happens"] as? String
        self.zoneIds = record.fields["Zone"] as? [String]

        // Handle visibility - check both bool and int formats
        if let visible = record.fields["Is_Visible_To_Kids"] as? Bool {
            self.isVisibleToKids = visible
        } else if let visibleInt = record.fields["Is_Visible_To_Kids"] as? Int {
            self.isVisibleToKids = visibleInt == 1
        } else {
            self.isVisibleToKids = true
        }

        if let typeStr = record.fields["Structure_Type"] as? String,
           let type = StructureType(rawValue: typeStr) {
            self.structureType = type
        } else {
            self.structureType = .other
        }
    }

    func toAirtableFields() -> [String: Any] {
        var fields: [String: Any] = [:]
        if let display = structureDisplay { fields["Structure_Display"] = display }
        if let planned = blocksPlanned { fields["Blocks_Planned"] = planned }
        fields["Structure_Type"] = structureType.rawValue
        if let kids = whatWeTellTheKids { fields["What_We_Tell_The_Kids"] = kids }
        if let real = whatReallyHappens { fields["What_Really_Happens"] = real }
        fields["Is_Visible_To_Kids"] = isVisibleToKids
        return fields
    }
}
