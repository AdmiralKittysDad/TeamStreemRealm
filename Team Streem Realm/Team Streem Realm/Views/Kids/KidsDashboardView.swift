import SwiftUI

struct KidsDashboardView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var selectedTab = 0
    @State private var showConfetti = false
    @State private var headerScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Epic animated ocean background
            AnimatedGradientBackground()
            BubbleBackground()

            VStack(spacing: 0) {
                // Epic Header with logo animation
                epicHeader

                // Tab Content
                TabView(selection: $selectedTab) {
                    // Dashboard Tab - The HYPE zone
                    dashboardContent
                        .tag(0)

                    // Zones Tab
                    KidsZonesView()
                        .tag(1)

                    // Build Log Tab
                    KidsSessionsView()
                        .tag(2)

                    // Materials Tab
                    KidsMaterialsView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom Tab Bar
                epicTabBar
            }

            // Confetti overlay
            ConfettiView(isActive: $showConfetti)
        }
        .preferredColorScheme(.dark)
        .task {
            await airtable.loadKidsData()
        }
        .refreshable {
            HapticManager.shared.refresh()
            await airtable.loadKidsData()
        }
    }

    // MARK: - Epic Header
    private var epicHeader: some View {
        HStack(spacing: 16) {
            // Animated logo
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("⚔️")
                        .font(.system(size: 28))
                        .scaleEffect(headerScale)

                    Text("TEAM STREEM")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.mcDiamond, .mcEmerald],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                Text("REALM")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcGold)
                    .tracking(6)
            }

            Spacer()

            // Refresh button with loading state
            if airtable.isLoading {
                ProgressView()
                    .tint(.mcDiamond)
                    .scaleEffect(1.2)
            } else {
                Button {
                    Task {
                        HapticManager.shared.refresh()
                        await airtable.loadKidsData()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.mcDiamond, .mcPrismarine],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .mcDiamond.opacity(0.5), radius: 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.mcBedrock, Color.mcBedrock.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                headerScale = 1.1
            }
        }
    }

    // MARK: - Dashboard Content
    private var dashboardContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Epic Progress Ring - THE MAIN EVENT
                epicProgressSection

                // Active Zone Spotlight
                activeZoneSpotlight

                // Stats Dashboard
                statsDashboard

                // Recent Activity
                recentActivitySection

                // Fun Facts
                funFactsSection

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    // MARK: - Epic Progress Section
    private var epicProgressSection: some View {
        VStack(spacing: 20) {
            // Title with sparkles
            HStack {
                Text("✨")
                Text("MEGA BUILD PROGRESS")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.mcGold)
                    .tracking(2)
                Text("✨")
            }

            // The big ring!
            EpicProgressRing(
                progress: airtable.overallProgress,
                size: 200,
                lineWidth: 24,
                primaryColor: .mcEmerald,
                secondaryColor: .mcDiamond
            )
            .onTapGesture {
                // Easter egg - tap for confetti!
                if airtable.overallProgress > 0 {
                    showConfetti = true
                    HapticManager.shared.achievementUnlocked()
                }
            }

            // Block counters
            HStack(spacing: 16) {
                AnimatedBlockCounter(
                    value: airtable.totalBlocksPlaced,
                    label: "Placed",
                    color: .mcDiamond,
                    icon: "cube.fill"
                )

                AnimatedBlockCounter(
                    value: airtable.totalBlocksPlanned - airtable.totalBlocksPlaced,
                    label: "To Go",
                    color: .mcGold,
                    icon: "cube"
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.mcCardBg.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.mcDiamond.opacity(0.5), .mcEmerald.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .mcDiamond.opacity(0.2), radius: 20)
    }

    // MARK: - Active Zone Spotlight
    private var activeZoneSpotlight: some View {
        Group {
            if let zone = airtable.activeZone {
                VStack(spacing: 16) {
                    // Pulsing "NOW BUILDING" badge
                    HStack {
                        Circle()
                            .fill(Color.mcRedstone)
                            .frame(width: 12, height: 12)
                            .pulsingGlow(color: .mcRedstone, intensity: 0.8)

                        Text("NOW BUILDING")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.mcRedstone)
                            .tracking(2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.mcRedstone.opacity(0.2))
                    )

                    // Zone card
                    Zone3DCard(zone: zone) {
                        selectedTab = 1 // Go to zones tab
                        HapticManager.shared.impact(.medium)
                    }
                }
            } else {
                // Coming soon card
                VStack(spacing: 16) {
                    Text("🔮")
                        .font(.system(size: 50))

                    Text("COMING SOON")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.mcAmethyst)

                    Text("Dad is planning the next epic build zone...")
                        .font(.system(size: 14))
                        .foregroundColor(.mcStone)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.mcCardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.mcAmethyst.opacity(0.3), lineWidth: 2)
                        )
                )
            }
        }
    }

    // MARK: - Stats Dashboard
    private var statsDashboard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 BUILD STATS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcGold)
                    .tracking(1)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCardEnhanced(
                    icon: "🗺️",
                    value: "\(airtable.completedZonesCount)",
                    total: "\(airtable.zones.count)",
                    label: "Zones Complete",
                    color: .mcEmerald,
                    progress: airtable.zones.isEmpty ? 0 : Double(airtable.completedZonesCount) / Double(airtable.zones.count)
                )

                StatCardEnhanced(
                    icon: "⏱️",
                    value: airtable.formattedBuildTime,
                    total: nil,
                    label: "Build Time",
                    color: .mcGold,
                    progress: nil
                )

                StatCardEnhanced(
                    icon: "📅",
                    value: "\(airtable.sessions.count)",
                    total: nil,
                    label: "Sessions",
                    color: .mcDiamond,
                    progress: nil
                )

                StatCardEnhanced(
                    icon: "🧱",
                    value: "\(airtable.materials.count)",
                    total: nil,
                    label: "Block Types",
                    color: .mcAmethyst,
                    progress: nil
                )
            }
        }
    }

    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📝 RECENT ACTIVITY")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcPrismarine)
                    .tracking(1)
                Spacer()

                Button {
                    selectedTab = 2
                    HapticManager.shared.selection()
                } label: {
                    Text("See All →")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.mcDiamond)
                }
            }

            if let session = airtable.recentSession {
                SessionTimelineCard(session: session, isLatest: true)
            } else {
                EmptyStateView(
                    icon: "🏗️",
                    title: "No Sessions Yet",
                    message: "Dad hasn't logged any build sessions yet. Check back soon!"
                )
            }
        }
    }

    // MARK: - Fun Facts Section
    private var funFactsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💡 DID YOU KNOW?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcGold)
                    .tracking(1)
                Spacer()
            }

            FunFactCard(facts: funFacts)
        }
    }

    private var funFacts: [String] {
        [
            "Ocean Monuments are one of the rarest structures in Minecraft! 🌊",
            "Prismarine blocks actually change color over time - watch closely! ✨",
            "Sea Lanterns emit the brightest light possible in Minecraft! 💡",
            "Elder Guardians are like mini-bosses that guard Ocean Monuments! 👁️",
            "It takes a LOT of patience to build underwater - Dad is a pro! 💪",
            "Sponges can only be found in Ocean Monuments! 🧽",
            "Guardians shoot lasers from their eyes - pew pew! 👀",
            "The Conduit gives you underwater superpowers! 🦸"
        ]
    }

    // MARK: - Epic Tab Bar
    private var epicTabBar: some View {
        HStack(spacing: 0) {
            TabBarButtonEnhanced(
                icon: "house.fill",
                label: "Home",
                isSelected: selectedTab == 0,
                color: .mcDiamond
            ) {
                selectedTab = 0
                HapticManager.shared.selection()
            }

            TabBarButtonEnhanced(
                icon: "map.fill",
                label: "Zones",
                isSelected: selectedTab == 1,
                color: .mcEmerald
            ) {
                selectedTab = 1
                HapticManager.shared.selection()
            }

            TabBarButtonEnhanced(
                icon: "clock.fill",
                label: "Sessions",
                isSelected: selectedTab == 2,
                color: .mcGold
            ) {
                selectedTab = 2
                HapticManager.shared.selection()
            }

            TabBarButtonEnhanced(
                icon: "cube.fill",
                label: "Blocks",
                isSelected: selectedTab == 3,
                color: .mcAmethyst
            ) {
                selectedTab = 3
                HapticManager.shared.selection()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            Rectangle()
                .fill(Color.mcBedrock)
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
        )
    }
}

// MARK: - Enhanced Stat Card
struct StatCardEnhanced: View {
    let icon: String
    let value: String
    var total: String?
    let label: String
    let color: Color
    var progress: Double?

    @State private var appear = false

    var body: some View {
        VStack(spacing: 10) {
            Text(icon)
                .font(.system(size: 28))
                .scaleEffect(appear ? 1 : 0.5)

            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(color)

                if let total = total {
                    Text("/\(total)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.mcStone)
                }
            }

            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.mcStone)
                .textCase(.uppercase)

            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mcDeepslate)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Enhanced Tab Bar Button
struct TabBarButtonEnhanced: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 44, height: 44)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? color : .mcStone)
                }

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? color : .mcStone)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Fun Fact Card
struct FunFactCard: View {
    let facts: [String]
    @State private var currentIndex = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        VStack(spacing: 12) {
            Text(facts[currentIndex])
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(opacity)
                .animation(.easeInOut(duration: 0.3), value: opacity)

            // Dots indicator
            HStack(spacing: 6) {
                ForEach(0..<min(facts.count, 5), id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex % 5 ? Color.mcGold : Color.mcStone.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.mcGold.opacity(0.15), Color.mcCardBg],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mcGold.opacity(0.3), lineWidth: 1)
                )
        )
        .onTapGesture {
            cycleFact()
        }
        .onAppear {
            startAutoRotate()
        }
    }

    private func cycleFact() {
        withAnimation {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex = (currentIndex + 1) % facts.count
            withAnimation {
                opacity = 1
            }
        }
        HapticManager.shared.selection()
    }

    private func startAutoRotate() {
        Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
            cycleFact()
        }
    }
}

// MARK: - Preview
#Preview {
    KidsDashboardView()
}
