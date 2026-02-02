import SwiftUI

struct KidsSessionsView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var selectedSession: BuildSession?
    @State private var appearAnimation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Epic Header
                headerSection

                // Stats Overview - The exciting numbers!
                statsOverview

                // Sessions Timeline - The adventure log!
                if airtable.sessions.isEmpty {
                    emptyState
                } else {
                    sessionsTimeline
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailSheet(session: session)
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
                Text("📜")
                    .font(.system(size: 32))

                Text("BUILD LOG")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mcGold, .mcCopper],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()

                if !airtable.sessions.isEmpty {
                    Text("\(airtable.sessions.count) sessions")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.mcStone)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.mcCardBg)
                        )
                }
            }

            HStack {
                Text("Dad's building adventures, logged!")
                    .font(.system(size: 14))
                    .foregroundColor(.mcStone)
                Spacer()
            }
        }
    }

    // MARK: - Stats Overview
    private var statsOverview: some View {
        VStack(spacing: 16) {
            // Top row - Big hero numbers
            HStack(spacing: 16) {
                // Total Build Time
                VStack(spacing: 8) {
                    Text("⏱️")
                        .font(.system(size: 36))

                    Text(airtable.formattedBuildTime)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.mcGold)

                    Text("Total Build Time")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.mcStone)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.mcGold.opacity(0.2), Color.mcCardBg],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )

                // Total Blocks
                VStack(spacing: 8) {
                    Text("🧱")
                        .font(.system(size: 36))

                    Text("\(airtable.totalBlocksPlaced.formatted)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.mcDiamond)

                    Text("Blocks Placed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.mcStone)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.mcDiamond.opacity(0.2), Color.mcCardBg],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
            }

            // Bottom row - Fun stats
            HStack(spacing: 12) {
                MiniStatCard(
                    icon: "📊",
                    value: averageBlocksPerSession,
                    label: "Avg Blocks",
                    color: .mcEmerald
                )

                MiniStatCard(
                    icon: "⚡",
                    value: averageBlocksPerMinute,
                    label: "Blocks/Min",
                    color: .mcRedstone
                )

                MiniStatCard(
                    icon: "🏆",
                    value: bestSessionBlocks,
                    label: "Best Session",
                    color: .mcAmethyst
                )
            }
        }
    }

    private var averageBlocksPerSession: String {
        guard !airtable.sessions.isEmpty else { return "0" }
        let total = airtable.sessions.reduce(0) { $0 + ($1.blocksPlacedThisSession ?? 0) }
        return "\(total / airtable.sessions.count)"
    }

    private var averageBlocksPerMinute: String {
        guard airtable.totalBuildMinutes > 0 else { return "0" }
        let bpm = Double(airtable.totalBlocksPlaced) / Double(airtable.totalBuildMinutes)
        return String(format: "%.1f", bpm)
    }

    private var bestSessionBlocks: String {
        let best = airtable.sessions.map { $0.blocksPlacedThisSession ?? 0 }.max() ?? 0
        return "\(best)"
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🔨")
                .font(.system(size: 80))

            Text("No Adventures Yet!")
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)

            Text("Dad hasn't logged any building sessions yet.\nThe epic saga will begin soon!")
                .font(.system(size: 15))
                .foregroundColor(.mcStone)
                .multilineTextAlignment(.center)

            // Animated dots
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.mcDiamond)
                        .frame(width: 8, height: 8)
                        .opacity(appearAnimation ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: appearAnimation
                        )
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.mcCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.mcStone.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Sessions Timeline
    private var sessionsTimeline: some View {
        VStack(spacing: 0) {
            HStack {
                Text("📖 BUILD ADVENTURES")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcPrismarine)
                    .tracking(1)
                Spacer()
            }
            .padding(.bottom, 16)

            ForEach(Array(airtable.sessions.enumerated()), id: \.element.id) { index, session in
                SessionTimelineCard(session: session, isLatest: index == 0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(x: appearAnimation ? 0 : 50)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: appearAnimation
                    )
                    .onTapGesture {
                        HapticManager.shared.impact(.light)
                        selectedSession = session
                    }
                    .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Mini Stat Card
struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 20))

            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.mcStone)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mcCardBg)
        )
    }
}

// MARK: - Session Detail Sheet
struct SessionDetailSheet: View {
    let session: BuildSession
    @Environment(\.dismiss) private var dismiss
    @StateObject private var airtable = AirtableService.shared
    @State private var showConfetti = false

    var sessionZones: [Zone] {
        guard let ids = session.zoneIds else { return [] }
        return airtable.zones.filter { ids.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [session.mood.color.opacity(0.3), Color.mcBackground],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero section
                        heroSection

                        // Stats grid
                        statsGrid

                        // Photo
                        if let photoURL = session.photoURL {
                            photoSection(url: photoURL)
                        }

                        // Notes
                        if let notes = session.notesDisplay, !notes.isEmpty {
                            notesSection(notes: notes)
                        }

                        // Zones worked on
                        if !sessionZones.isEmpty {
                            zonesWorkedSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

                // Confetti
                ConfettiView(isActive: $showConfetti)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(session.formattedDate)
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

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Big mood emoji
            Text(session.mood.emoji)
                .font(.system(size: 100))
                .shadow(color: session.mood.color.opacity(0.5), radius: 20)
                .onTapGesture {
                    showConfetti = true
                    HapticManager.shared.achievementUnlocked()
                }

            // Mood name
            Text(session.mood.shortName)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(session.mood.color)

            // Mood badge
            Text(moodDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }

    private var moodDescription: String {
        switch session.mood {
        case .masterBuilder: return "Dad was ON FIRE this session! 🔥"
        case .onFire: return "Great progress was made!"
        case .brickByBrick: return "Steady building, block by block."
        case .creeperProblems: return "Some challenges, but Dad pushed through!"
        case .minedOut: return "A short but productive session."
        }
    }

    private var statsGrid: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 SESSION STATS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcGold)
                    .tracking(1)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SessionStatBox(
                    icon: "🧱",
                    value: "\(session.blocksPlacedThisSession ?? 0)",
                    label: "Blocks Placed",
                    color: .mcDiamond
                )

                SessionStatBox(
                    icon: "⏱️",
                    value: session.formattedDuration,
                    label: "Build Time",
                    color: .mcGold
                )

                if let bpm = session.blocksPerMinute {
                    SessionStatBox(
                        icon: "⚡",
                        value: String(format: "%.1f", bpm),
                        label: "Blocks/Min",
                        color: .mcRedstone
                    )
                }

                SessionStatBox(
                    icon: session.mood.emoji,
                    value: session.mood.shortName,
                    label: "Mood",
                    color: session.mood.color
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
        )
    }

    private func photoSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📸 SESSION PHOTO")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcAmethyst)
                    .tracking(1)
                Spacer()
            }

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                case .failure:
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Failed to load photo")
                    }
                    .foregroundColor(.mcStone)
                    .frame(height: 150)
                case .empty:
                    SkeletonView()
                        .frame(height: 200)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
        )
    }

    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💬 DAD SAYS...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcPrismarine)
                    .tracking(1)
                Spacer()
            }

            Text("\"\(notes)\"")
                .font(.system(size: 16, weight: .medium))
                .italic()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
        )
    }

    private var zonesWorkedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🗺️ ZONES WORKED ON")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcEmerald)
                    .tracking(1)
                Spacer()
            }

            ForEach(sessionZones) { zone in
                HStack(spacing: 12) {
                    Text(zone.emoji)
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(zone.displayName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)

                        Text("Zone \(zone.zoneNumber ?? 0)")
                            .font(.system(size: 12))
                            .foregroundColor(zone.themeColor)
                    }

                    Spacer()

                    // Mini progress
                    VStack(spacing: 4) {
                        Text("\(Int(zone.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(zone.themeColor)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.mcDeepslate)
                                .frame(width: 50, height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(zone.themeColor)
                                .frame(width: 50 * zone.progress, height: 4)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(zone.themeColor.opacity(0.15))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
        )
    }
}

// MARK: - Session Stat Box
struct SessionStatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 28))

            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.mcStone)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Preview
#Preview {
    KidsSessionsView()
}
