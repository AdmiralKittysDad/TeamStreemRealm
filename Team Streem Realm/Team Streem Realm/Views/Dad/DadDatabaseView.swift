import SwiftUI

struct DadDatabaseView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var selectedTable = 0

    var body: some View {
        VStack(spacing: 0) {
            // Table selector
            tableSelector

            // Content
            TabView(selection: $selectedTable) {
                zonesTable.tag(0)
                structuresTable.tag(1)
                sessionsTable.tag(2)
                materialsTable.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }

    // MARK: - Table Selector
    private var tableSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tableTab("Zones", count: airtable.zones.count, index: 0)
                tableTab("Structures", count: airtable.structures.count, index: 1)
                tableTab("Sessions", count: airtable.sessions.count, index: 2)
                tableTab("Materials", count: airtable.materials.count, index: 3)
            }
            .padding()
        }
        .background(Color.mcCardBg)
    }

    private func tableTab(_ title: String, count: Int, index: Int) -> some View {
        Button {
            selectedTable = index
            HapticManager.shared.selection()
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text("\(count)")
                    .font(.caption)
            }
            .foregroundColor(selectedTable == index ? .white : .mcStone)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selectedTable == index ? Color.mcDiamond : Color.mcDeepslate)
            .cornerRadius(6)
        }
    }

    // MARK: - Zones Table
    private var zonesTable: some View {
        List {
            ForEach(airtable.zones.sorted(by: { ($0.zoneNumber ?? 0) < ($1.zoneNumber ?? 0) })) { zone in
                ZoneRowView(zone: zone)
                    .listRowBackground(Color.mcCardBg)
            }
        }
        .listStyle(.plain)
        .background(Color.mcBackground)
        .modifier(HideListBackgroundModifier())
    }

    // MARK: - Structures Table
    private var structuresTable: some View {
        List {
            ForEach(airtable.structures) { structure in
                StructureRowView(structure: structure)
                    .listRowBackground(Color.mcCardBg)
            }
        }
        .listStyle(.plain)
        .background(Color.mcBackground)
        .modifier(HideListBackgroundModifier())
    }

    // MARK: - Sessions Table
    private var sessionsTable: some View {
        List {
            ForEach(airtable.sessions) { session in
                SessionRowView(session: session)
                    .listRowBackground(Color.mcCardBg)
            }
        }
        .listStyle(.plain)
        .background(Color.mcBackground)
        .modifier(HideListBackgroundModifier())
    }

    // MARK: - Materials Table
    private var materialsTable: some View {
        List {
            ForEach(airtable.materials.sorted(by: { $0.materialName < $1.materialName })) { material in
                MaterialRowView(material: material)
                    .listRowBackground(Color.mcCardBg)
            }
        }
        .listStyle(.plain)
        .background(Color.mcBackground)
        .modifier(HideListBackgroundModifier())
    }
}

// MARK: - Zone Row
struct ZoneRowView: View {
    let zone: Zone
    @StateObject private var airtable = AirtableService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(zone.emoji)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(zone.displayName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Zone \(zone.zoneNumber ?? 0) • \(zone.status.rawValue)")
                        .font(.caption)
                        .foregroundColor(.mcStone)
                }

                Spacer()

                // Visibility indicator
                Image(systemName: zone.isVisibleToKids ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(zone.isVisibleToKids ? .mcEmerald : .mcStone)
            }

            // Stats row
            HStack(spacing: 16) {
                statItem("Blocks", value: "\(zone.blocksPlacedRollup ?? 0)/\(zone.blocksPlannedRollup ?? 0)")
                statItem("Layers", value: "\(zone.layerProgressCount ?? 0)/\(zone.totalLayers ?? 0)")
                statItem("Progress", value: "\(Int(zone.progress * 100))%")
            }

            ProgressView(value: zone.progress)
                .progressViewStyle(MinecraftProgressStyle(color: zone.themeColor, height: 8))
        }
        .padding(.vertical, 8)
    }

    private func statItem(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.mcStone)
            Text(value)
                .font(.caption)
                .foregroundColor(.mcDiamond)
        }
    }
}

// MARK: - Structure Row
struct StructureRowView: View {
    let structure: Structure

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(structure.icon)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(structure.displayName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(structure.structureType.rawValue)
                        .font(.caption)
                        .foregroundColor(structure.themeColor)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(Int(structure.progress * 100))%")
                        .font(.headline)
                        .foregroundColor(.mcDiamond)
                    Text("\(structure.blocksPlacedRollup ?? 0)/\(structure.blocksPlanned ?? 0)")
                        .font(.caption)
                        .foregroundColor(.mcStone)
                }
            }

            if let description = structure.whatWeTellTheKids {
                Text("Kids: \(description)")
                    .font(.caption)
                    .foregroundColor(.mcPrismarine)
                    .italic()
            }

            ProgressView(value: structure.progress)
                .progressViewStyle(MinecraftProgressStyle(color: structure.themeColor, height: 6))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Session Row
struct SessionRowView: View {
    let session: BuildSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.mood.emoji)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(session.formattedDate)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(session.mood.shortName)
                        .font(.caption)
                        .foregroundColor(session.mood.color)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(session.blocksPlacedThisSession ?? 0) blocks")
                        .font(.subheadline)
                        .foregroundColor(.mcDiamond)
                    Text(session.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.mcGold)
                }
            }

            if let notes = session.notesDisplay {
                Text("💬 \(notes)")
                    .font(.caption)
                    .foregroundColor(.mcPrismarine)
            }

            HStack {
                Image(systemName: session.isVisibleToKids ? "eye.fill" : "eye.slash.fill")
                    .font(.caption)
                    .foregroundColor(session.isVisibleToKids ? .mcEmerald : .mcStone)

                Text(session.isVisibleToKids ? "Visible to kids" : "Hidden from kids")
                    .font(.caption2)
                    .foregroundColor(.mcStone)

                Spacer()

                if let bpm = session.blocksPerMinute {
                    Text("\(String(format: "%.1f", bpm)) b/min")
                        .font(.caption)
                        .foregroundColor(.mcAmethyst)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Material Row
struct MaterialRowView: View {
    let material: Material

    var body: some View {
        HStack(spacing: 12) {
            // Block image
            BlockImageView(imageName: material.imageName, size: 44, emoji: material.emoji)

            VStack(alignment: .leading, spacing: 4) {
                Text(material.materialName)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                HStack {
                    Text(material.rarity.name)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(material.rarity.color)
                        .cornerRadius(4)

                    if let category = material.category {
                        Text(category)
                            .font(.caption2)
                            .foregroundColor(.mcPrismarine)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.mcPrismarine.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(material.progress * 100))%")
                    .font(.headline)
                    .foregroundColor(material.rarity.color)

                Text("\(material.qtyPlaced)/\(material.qtyPlanned)")
                    .font(.caption)
                    .foregroundColor(.mcStone)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    DadDatabaseView()
}
