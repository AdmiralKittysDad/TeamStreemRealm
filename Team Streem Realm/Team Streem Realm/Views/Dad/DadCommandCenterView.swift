import SwiftUI

struct DadCommandCenterView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var showingLogSession = false
    @State private var showingZoneEditor: Zone?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Actions
                quickActionsSection

                // Active Zone Control
                activeZoneControl

                // Zone Visibility Manager
                zoneVisibilitySection

                // Recent Session Quick Stats
                recentSessionSection
            }
            .padding()
        }
        .sheet(isPresented: $showingLogSession) {
            LogSessionSheet()
        }
        .sheet(item: $showingZoneEditor) { zone in
            ZoneEditorSheet(zone: zone)
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ QUICK ACTIONS")
                .font(.headline)
                .foregroundColor(.mcGold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Log Session",
                    color: .mcEmerald
                ) {
                    showingLogSession = true
                }

                QuickActionButton(
                    icon: "arrow.clockwise.circle.fill",
                    title: "Refresh Data",
                    color: .mcDiamond
                ) {
                    Task {
                        await airtable.loadAllData()
                    }
                }

                QuickActionButton(
                    icon: "bell.badge.fill",
                    title: "Notify Kids",
                    color: .mcAmethyst
                ) {
                    // TODO: Send push notification
                    HapticManager.shared.notification(.success)
                }

                QuickActionButton(
                    icon: "camera.fill",
                    title: "Add Photo",
                    color: .mcGold
                ) {
                    // TODO: Add photo to session
                }
            }
        }
        .minecraftCard()
    }

    // MARK: - Active Zone Control
    private var activeZoneControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 ACTIVE ZONE")
                    .font(.headline)
                    .foregroundColor(.mcGold)
                Spacer()

                if let zone = airtable.activeZone {
                    Button("Edit") {
                        showingZoneEditor = zone
                    }
                    .font(.caption)
                    .foregroundColor(.mcDiamond)
                }
            }

            if let zone = airtable.activeZone {
                VStack(spacing: 12) {
                    HStack {
                        Text(zone.emoji)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(zone.displayName)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Zone \(zone.zoneNumber ?? 0) • \(Int(zone.progress * 100))% complete")
                                .font(.caption)
                                .foregroundColor(.mcStone)
                        }
                        Spacer()
                    }

                    ProgressView(value: zone.progress)
                        .progressViewStyle(MinecraftProgressStyle(color: zone.themeColor, height: 16))

                    // Zone controls
                    HStack(spacing: 12) {
                        Button {
                            Task {
                                try? await airtable.setZoneStatus(zoneId: zone.id, status: .complete)
                                HapticManager.shared.zoneComplete()
                            }
                        } label: {
                            Label("Complete", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.mcEmerald)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.mcDeepslate)
                                .cornerRadius(6)
                        }

                        Button {
                            showingZoneEditor = zone
                        } label: {
                            Label("Edit Teaser", systemImage: "text.bubble.fill")
                                .font(.caption)
                                .foregroundColor(.mcAmethyst)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.mcDeepslate)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .background(Color.mcOceanDeep)
                .cornerRadius(8)
            } else {
                Text("No active zone. Set one below!")
                    .font(.subheadline)
                    .foregroundColor(.mcStone)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.mcDeepslate)
                    .cornerRadius(8)
            }
        }
        .minecraftCard()
    }

    // MARK: - Zone Visibility
    private var zoneVisibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👁️ ZONE VISIBILITY")
                .font(.headline)
                .foregroundColor(.mcGold)

            ForEach(airtable.zones.sorted(by: { ($0.zoneNumber ?? 0) < ($1.zoneNumber ?? 0) })) { zone in
                HStack {
                    Text(zone.emoji)
                    Text("Zone \(zone.zoneNumber ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Spacer()

                    // Status picker
                    Menu {
                        Button("🔒 Locked") {
                            Task {
                                try? await airtable.setZoneStatus(zoneId: zone.id, status: .locked)
                            }
                        }
                        Button("🔨 Building") {
                            Task {
                                try? await airtable.setZoneStatus(zoneId: zone.id, status: .building)
                            }
                        }
                        Button("✅ Complete") {
                            Task {
                                try? await airtable.setZoneStatus(zoneId: zone.id, status: .complete)
                            }
                        }
                    } label: {
                        Text(zone.status.displayText)
                            .font(.caption)
                            .foregroundColor(statusColor(zone.status))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.mcDeepslate)
                            .cornerRadius(4)
                    }

                    // Visibility toggle
                    Toggle("", isOn: Binding(
                        get: { zone.isVisibleToKids },
                        set: { _ in
                            Task {
                                try? await airtable.toggleZoneVisibility(zoneId: zone.id)
                            }
                        }
                    ))
                    .labelsHidden()
                    .tint(.mcEmerald)
                }
                .padding(.vertical, 8)

                if zone.id != airtable.zones.last?.id {
                    Divider()
                        .background(Color.mcStone.opacity(0.2))
                }
            }
        }
        .minecraftCard()
    }

    private func statusColor(_ status: ZoneStatus) -> Color {
        switch status {
        case .locked: return .mcStone
        case .building: return .mcRedstone
        case .complete: return .mcEmerald
        }
    }

    // MARK: - Recent Session
    private var recentSessionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📝 RECENT SESSION")
                    .font(.headline)
                    .foregroundColor(.mcGold)
                Spacer()
                Button("Log New") {
                    showingLogSession = true
                }
                .font(.caption)
                .foregroundColor(.mcDiamond)
            }

            if let session = airtable.recentSession {
                HStack(spacing: 16) {
                    VStack {
                        Text("\(session.blocksPlacedThisSession ?? 0)")
                            .font(.title2.bold())
                            .foregroundColor(.mcDiamond)
                        Text("blocks")
                            .font(.caption2)
                            .foregroundColor(.mcStone)
                    }

                    VStack {
                        Text(session.formattedDuration)
                            .font(.title2.bold())
                            .foregroundColor(.mcGold)
                        Text("duration")
                            .font(.caption2)
                            .foregroundColor(.mcStone)
                    }

                    VStack {
                        Text(session.mood.emoji)
                            .font(.title2)
                        Text(session.mood.shortName)
                            .font(.caption2)
                            .foregroundColor(.mcStone)
                    }

                    Spacer()

                    Text(session.formattedDate)
                        .font(.caption)
                        .foregroundColor(.mcStone)
                }
            } else {
                Text("No sessions logged yet")
                    .font(.subheadline)
                    .foregroundColor(.mcStone)
            }
        }
        .minecraftCard()
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.mcDeepslate)
            .cornerRadius(8)
        }
    }
}

// MARK: - Log Session Sheet
struct LogSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var airtable = AirtableService.shared

    @State private var blocksPlaced = ""
    @State private var duration = ""
    @State private var selectedMood: BuildMood = .brickByBrick
    @State private var notes = ""
    @State private var selectedZones: Set<String> = []
    @State private var isLogging = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.mcBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Blocks placed
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🧱 Blocks Placed")
                                .font(.headline)
                                .foregroundColor(.mcGold)
                            TextField("e.g. 500", text: $blocksPlaced)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        // Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⏱️ Duration (minutes)")
                                .font(.headline)
                                .foregroundColor(.mcGold)
                            TextField("e.g. 90", text: $duration)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        // Mood picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("😊 Mood")
                                .font(.headline)
                                .foregroundColor(.mcGold)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(BuildMood.allCases, id: \.self) { mood in
                                    Button {
                                        selectedMood = mood
                                    } label: {
                                        HStack {
                                            Text(mood.emoji)
                                            Text(mood.shortName)
                                                .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedMood == mood ? mood.color : Color.mcDeepslate)
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }

                        // Zone selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🗺️ Zones Worked On")
                                .font(.headline)
                                .foregroundColor(.mcGold)

                            ForEach(airtable.zones) { zone in
                                Button {
                                    if selectedZones.contains(zone.id) {
                                        selectedZones.remove(zone.id)
                                    } else {
                                        selectedZones.insert(zone.id)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: selectedZones.contains(zone.id) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedZones.contains(zone.id) ? .mcEmerald : .mcStone)
                                        Text(zone.emoji)
                                        Text(zone.displayName)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💬 Notes for Kids (optional)")
                                .font(.headline)
                                .foregroundColor(.mcGold)
                            TextField("What should we tell them?", text: $notes)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Log Build Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.mcStone)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        logSession()
                    }
                    .foregroundColor(.mcDiamond)
                    .disabled(blocksPlaced.isEmpty || duration.isEmpty || isLogging)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func logSession() {
        guard let blocks = Int(blocksPlaced), let mins = Int(duration) else { return }

        isLogging = true

        var session = BuildSession.new()
        session.blocksPlacedThisSession = blocks
        session.durationMinutes = mins
        session.mood = selectedMood
        session.notesDisplay = notes.isEmpty ? nil : notes
        session.zoneIds = Array(selectedZones)
        session.isVisibleToKids = true

        Task {
            do {
                _ = try await airtable.createSession(session)
                HapticManager.shared.notification(.success)
                dismiss()
            } catch {
                HapticManager.shared.notification(.error)
            }
            isLogging = false
        }
    }
}

// MARK: - Zone Editor Sheet
struct ZoneEditorSheet: View {
    let zone: Zone
    @Environment(\.dismiss) private var dismiss
    @StateObject private var airtable = AirtableService.shared

    @State private var teaserMessage: String = ""
    @State private var isVisible: Bool = true
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.mcBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Zone header
                    HStack {
                        Text(zone.emoji)
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(zone.displayName)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Zone \(zone.zoneNumber ?? 0)")
                                .font(.caption)
                                .foregroundColor(.mcStone)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.mcCardBg)
                    .cornerRadius(8)

                    // Teaser message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🔮 Teaser Message")
                            .font(.headline)
                            .foregroundColor(.mcGold)
                        Text("This message shows when the zone is locked")
                            .font(.caption)
                            .foregroundColor(.mcStone)
                        TextField("e.g. Something epic is coming...", text: $teaserMessage)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Visibility toggle
                    Toggle(isOn: $isVisible) {
                        VStack(alignment: .leading) {
                            Text("Visible to Kids")
                                .font(.headline)
                                .foregroundColor(.mcGold)
                            Text("Toggle to show/hide this zone")
                                .font(.caption)
                                .foregroundColor(.mcStone)
                        }
                    }
                    .tint(.mcEmerald)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Zone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.mcStone)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(.mcDiamond)
                    .disabled(isSaving)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            teaserMessage = zone.teaserMessage ?? ""
            isVisible = zone.isVisibleToKids
        }
    }

    private func saveChanges() {
        isSaving = true

        Task {
            var updatedZone = zone
            updatedZone.teaserMessage = teaserMessage.isEmpty ? nil : teaserMessage
            updatedZone.isVisibleToKids = isVisible

            do {
                try await airtable.updateZone(updatedZone)
                HapticManager.shared.notification(.success)
                dismiss()
            } catch {
                HapticManager.shared.notification(.error)
            }
            isSaving = false
        }
    }
}

// MARK: - Preview
#Preview {
    DadCommandCenterView()
}
