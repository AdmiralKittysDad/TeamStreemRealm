import SwiftUI

struct KidsZonesView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var selectedZone: Zone?
    @State private var appearAnimation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Epic Header
                headerSection

                // Zone Progress Overview
                zoneProgressOverview

                // Zone Cards - The good stuff!
                zonesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .sheet(item: $selectedZone) { zone in
            ZoneDetailSheet(zone: zone)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🗺️")
                    .font(.system(size: 32))

                Text("BUILD ZONES")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mcGold, .mcCopper],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()
            }

            HStack {
                Text("Explore Dad's epic underwater kingdom!")
                    .font(.system(size: 14))
                    .foregroundColor(.mcStone)
                Spacer()
            }
        }
    }

    // MARK: - Zone Progress Overview
    private var zoneProgressOverview: some View {
        HStack(spacing: 16) {
            // Completed zones
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("✅")
                    Text("\(airtable.completedZonesCount)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.mcEmerald)
                }
                Text("Complete")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcEmerald.opacity(0.15))
            )

            // In Progress
            let buildingCount = airtable.zones.filter { $0.status == .building }.count
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("🔨")
                    Text("\(buildingCount)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.mcRedstone)
                }
                Text("Building")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcRedstone.opacity(0.15))
            )

            // Locked/Mystery
            let lockedCount = airtable.zones.filter { $0.status == .locked }.count
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("🔒")
                    Text("\(lockedCount)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.mcAmethyst)
                }
                Text("Mystery")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcAmethyst.opacity(0.15))
            )
        }
    }

    // MARK: - Zones Section
    private var zonesSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(airtable.zones.sorted(by: { ($0.zoneNumber ?? 0) < ($1.zoneNumber ?? 0) }).enumerated()), id: \.element.id) { index, zone in
                Zone3DCard(zone: zone) {
                    if !zone.isLocked {
                        selectedZone = zone
                    } else {
                        HapticManager.shared.notification(.warning)
                    }
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 30)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                    .delay(Double(index) * 0.1),
                    value: appearAnimation
                )
            }

            // Coming Soon Teaser
            if airtable.zones.count < 5 {
                comingSoonCard
            }
        }
    }

    // MARK: - Coming Soon Card
    private var comingSoonCard: some View {
        VStack(spacing: 12) {
            Text("❓")
                .font(.system(size: 50))
                .opacity(0.5)

            Text("MORE ZONES COMING")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.mcStone)

            Text("Dad is planning something amazing...")
                .font(.system(size: 14))
                .foregroundColor(.mcStone.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                )
                .foregroundColor(.mcStone.opacity(0.3))
        )
    }
}

// MARK: - Zone Detail Sheet
struct ZoneDetailSheet: View {
    let zone: Zone
    @Environment(\.dismiss) private var dismiss
    @StateObject private var airtable = AirtableService.shared
    @State private var showConfetti = false

    var structures: [Structure] {
        airtable.structures.filter { structure in
            structure.zoneIds?.contains(zone.id) ?? false
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: zone.gradientColors + [Color.mcBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Zone hero
                        zoneHero

                        // Progress ring
                        progressRingSection

                        // Stats grid
                        statsSection

                        // Structures in this zone
                        if !structures.isEmpty {
                            structuresSection
                        }

                        // Fun description
                        funDescriptionSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

                // Confetti overlay
                ConfettiView(isActive: $showConfetti)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Zone \(zone.zoneNumber ?? 0)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var zoneHero: some View {
        VStack(spacing: 16) {
            // Big emoji
            Text(zone.emoji)
                .font(.system(size: 100))
                .shadow(color: zone.themeColor.opacity(0.5), radius: 20)
                .onTapGesture {
                    if zone.status == .complete {
                        showConfetti = true
                        HapticManager.shared.zoneComplete()
                    }
                }

            // Zone name
            Text(zone.displayName)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Status badge
            HStack(spacing: 8) {
                Circle()
                    .fill(zone.status.color)
                    .frame(width: 10, height: 10)

                Text(zone.status.displayText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(zone.status.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(zone.status.color.opacity(0.2))
            )

            // Fun description
            Text(zone.funDescription)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .italic()
        }
        .padding(.top, 20)
    }

    private var progressRingSection: some View {
        VStack(spacing: 16) {
            EpicProgressRing(
                progress: zone.progress,
                size: 160,
                lineWidth: 18,
                primaryColor: zone.themeColor,
                secondaryColor: zone.gradientColors.last ?? .mcDiamond
            )

            if zone.status == .complete {
                Text("🎉 ZONE COMPLETE! 🎉")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.mcGold)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.mcCardBg.opacity(0.8))
        )
    }

    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCardEnhanced(
                icon: "🧱",
                value: zone.blocksPlacedRollup?.formatted ?? "0",
                total: zone.blocksPlannedRollup?.formatted,
                label: "Blocks",
                color: .mcDiamond,
                progress: zone.progress
            )

            if let complete = zone.layerProgressCount, let total = zone.totalLayers {
                StatCardEnhanced(
                    icon: "📚",
                    value: "\(complete)",
                    total: "\(total)",
                    label: "Layers",
                    color: .mcEmerald,
                    progress: zone.layerProgress
                )
            }

            if let yStart = zone.yStart, let yEnd = zone.yEnd {
                StatCardEnhanced(
                    icon: "📏",
                    value: "Y\(yStart)-\(yEnd)",
                    total: nil,
                    label: "Height Range",
                    color: .mcGold,
                    progress: nil
                )
            }

            StatCardEnhanced(
                icon: "🏗️",
                value: "\(structures.count)",
                total: nil,
                label: "Structures",
                color: .mcAmethyst,
                progress: nil
            )
        }
    }

    private var structuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏗️ STRUCTURES IN THIS ZONE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcGold)
                    .tracking(1)
                Spacer()
            }

            ForEach(structures) { structure in
                StructureCard(structure: structure)
            }
        }
    }

    private var funDescriptionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📖 ABOUT THIS ZONE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcPrismarine)
                    .tracking(1)
                Spacer()
            }

            if let prodDesc = zone.zoneProd {
                Text(prodDesc)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Blocks remaining
            if zone.status != .complete {
                let remaining = (zone.blocksPlannedRollup ?? 0) - (zone.blocksPlacedRollup ?? 0)
                HStack {
                    Text("⏳")
                    Text("\(remaining.formatted) blocks remaining")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.mcGold)
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
        )
    }
}

// MARK: - Structure Card
struct StructureCard: View {
    let structure: Structure

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(structure.themeColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Text(structure.icon)
                    .font(.system(size: 24))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(structure.displayName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                if let desc = structure.whatWeTellTheKids {
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundColor(.mcStone)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Progress
            VStack(spacing: 4) {
                Text("\(Int(structure.progress * 100))%")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(structure.themeColor)

                // Mini progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.mcDeepslate)
                        .frame(width: 40, height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(structure.themeColor)
                        .frame(width: 40 * structure.progress, height: 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mcCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(structure.themeColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    KidsZonesView()
}
