import SwiftUI

// MARK: - Minecraft Color Palette
extension Color {
    // Primary Minecraft colors
    static let mcDarkGreen = Color(hex: "2d5a27")
    static let mcGrass = Color(hex: "567d46")
    static let mcDirt = Color(hex: "866043")
    static let mcStone = Color(hex: "7f7f7f")
    static let mcDeepslate = Color(hex: "4d4d4d")
    static let mcBedrock = Color(hex: "333333")

    // Block colors
    static let mcDiamond = Color(hex: "4aedd9")
    static let mcEmerald = Color(hex: "17dd62")
    static let mcGold = Color(hex: "fcdb5a")
    static let mcRedstone = Color(hex: "ff0000")
    static let mcLapis = Color(hex: "345ec3")
    static let mcAmethyst = Color(hex: "9a5cc6")
    static let mcPrismarine = Color(hex: "63c5b5")
    static let mcCopper = Color(hex: "c06b4f")

    // Ocean colors
    static let mcOceanDeep = Color(hex: "0a2c4a")
    static let mcOceanMid = Color(hex: "1a4d6e")
    static let mcOceanLight = Color(hex: "3a8dbe")
    static let mcSeaFoam = Color(hex: "5eb8a0")

    // UI colors
    static let mcBackground = Color(hex: "1a1a2e")
    static let mcCardBg = Color(hex: "252542")
    static let mcAccent = Color(hex: "4aedd9")

    // Helper for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Minecraft Styling
struct MinecraftCardStyle: ViewModifier {
    var color: Color = .mcCardBg

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color)
            .cornerRadius(4) // Pixel-like corners
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.mcStone.opacity(0.5), lineWidth: 2)
            )
    }
}

struct MinecraftButtonStyle: ButtonStyle {
    var color: Color = .mcGrass

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    color.opacity(configuration.isPressed ? 0.7 : 1.0)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                }
            )
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MinecraftProgressStyle: ProgressViewStyle {
    var color: Color = .mcEmerald
    var backgroundColor: Color = .mcDeepslate
    var height: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(backgroundColor)
                    .frame(height: height)

                // Progress
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0), height: height)
                    .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)

                // Pixel overlay
                HStack(spacing: 2) {
                    ForEach(0..<Int(geometry.size.width / 8), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 1)
                    }
                }
                .frame(height: height)
            }
        }
        .frame(height: height)
    }
}

// MARK: - View Extensions
extension View {
    func minecraftCard(color: Color = .mcCardBg) -> some View {
        self.modifier(MinecraftCardStyle(color: color))
    }

    func pixelBorder(color: Color = .mcStone, width: CGFloat = 2) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color, lineWidth: width)
        )
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .mcOceanDeep,
                .mcOceanMid,
                .mcBackground
            ]),
            startPoint: animate ? .topLeading : .bottomLeading,
            endPoint: animate ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Floating Bubbles Effect
struct FloatingBubble: View {
    let size: CGFloat
    let duration: Double
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    yOffset = -50
                    opacity = 0.1
                }
            }
    }
}

struct BubbleBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<15, id: \.self) { index in
                FloatingBubble(
                    size: CGFloat.random(in: 4...12),
                    duration: Double.random(in: 3...6)
                )
                .position(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: CGFloat.random(in: 0...geometry.size.height)
                )
            }
        }
    }
}

// MARK: - Pulsing Glow Effect
struct PulsingGlow: ViewModifier {
    var color: Color
    var intensity: CGFloat
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isAnimating ? intensity : intensity * 0.5), radius: isAnimating ? 15 : 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func pulsingGlow(color: Color = .mcDiamond, intensity: CGFloat = 0.6) -> some View {
        self.modifier(PulsingGlow(color: color, intensity: intensity))
    }
}

// MARK: - Block Image View (Local Assets with Emoji Fallback)
struct BlockImageView: View {
    let imageName: String  // Local asset name
    let size: CGFloat
    var emoji: String = "🧱"  // Fallback emoji
    var showGlow: Bool = false

    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.none) // Keeps pixelated look for Minecraft blocks
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback to emoji if image not found
                emojiPlaceholder
            }
        }
        .frame(width: size, height: size)
        .background(Color.mcDeepslate)
        .cornerRadius(4)
        .if(showGlow) { view in
            view.pulsingGlow(color: .mcDiamond, intensity: 0.4)
        }
    }

    private var emojiPlaceholder: some View {
        ZStack {
            Color.mcDeepslate
            Text(emoji)
                .font(.system(size: size * 0.5))
        }
    }
}

// MARK: - Conditional Modifier
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Number Formatter
extension Int {
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Haptic Feedback
class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // Custom patterns for special events
    func blockPlaced() {
        impact(.light)
    }

    func achievementUnlocked() {
        notification(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.heavy)
        }
    }

    func zoneComplete() {
        notification(.success)
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                self.impact(.heavy)
            }
        }
    }

    func refresh() {
        impact(.soft)
    }
}

// MARK: - iOS 15 Compatibility for List Background
struct HideListBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content.onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

// MARK: - Epic Progress Ring (Like a boss health bar!)
struct EpicProgressRing: View {
    let progress: Double
    let size: CGFloat
    var lineWidth: CGFloat = 20
    var primaryColor: Color = .mcEmerald
    var secondaryColor: Color = .mcDiamond
    var showParticles: Bool = true

    @State private var animatedProgress: Double = 0
    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background ring with subtle glow
            Circle()
                .stroke(Color.mcDeepslate.opacity(0.5), lineWidth: lineWidth)

            // Progress ring with gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [primaryColor, secondaryColor, primaryColor]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: primaryColor.opacity(0.5), radius: 10)

            // Inner glow ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    primaryColor.opacity(0.3),
                    style: StrokeStyle(lineWidth: lineWidth + 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 4)

            // Sparkle particles around ring
            if showParticles && animatedProgress > 0 {
                ForEach(0..<8, id: \.self) { i in
                    SparkleParticle(
                        color: i % 2 == 0 ? primaryColor : secondaryColor,
                        delay: Double(i) * 0.15
                    )
                    .offset(x: 0, y: -size / 2 + lineWidth / 2)
                    .rotationEffect(.degrees(Double(i) * 45 + rotation))
                }
            }

            // Center content
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.25, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(pulseScale)

                Text("COMPLETE")
                    .font(.system(size: size * 0.08, weight: .bold))
                    .foregroundColor(.mcStone)
                    .tracking(2)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animatedProgress = progress
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

struct SparkleParticle: View {
    let color: Color
    let delay: Double
    @State private var opacity: Double = 0.3
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = 1.0
                    scale = 1.2
                }
            }
    }
}

// MARK: - Animated Block Counter
struct AnimatedBlockCounter: View {
    let value: Int
    let label: String
    var color: Color = .mcDiamond
    var icon: String = "cube.fill"

    @State private var displayValue: Int = 0
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            // Icon with bounce
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.5)
                    .repeatCount(3),
                    value: isAnimating
                )

            // Animated number
            Text("\(displayValue.formatted)")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.mcStone)
                .kerning(1)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mcCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: color.opacity(0.2), radius: 10)
        .onAppear {
            animateValue()
        }
        .onChange(of: value) { _ in
            animateValue()
        }
    }

    private func animateValue() {
        isAnimating = true

        // Animate counting up
        let steps = 30
        let duration = 1.0
        let stepDuration = duration / Double(steps)
        let increment = value / steps

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                if i == steps - 1 {
                    displayValue = value
                } else {
                    displayValue = min(increment * (i + 1), value)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
}

// MARK: - Confetti Explosion
struct ConfettiView: View {
    @Binding var isActive: Bool
    var colors: [Color] = [.mcDiamond, .mcEmerald, .mcGold, .mcAmethyst, .mcRedstone]

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiPiece(particle: particle)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                spawnConfetti()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isActive = false
                    particles.removeAll()
                }
            }
        }
    }

    private func spawnConfetti() {
        for _ in 0..<50 {
            particles.append(ConfettiParticle(
                color: colors.randomElement() ?? .mcDiamond,
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -400 ... -200),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0)
            ))
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let rotation: Double
    let scale: CGFloat
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: 10 * particle.scale, height: 10 * particle.scale)
            .offset(x: particle.x, y: particle.y + yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 3)) {
                    yOffset = 800
                    rotation = particle.rotation + 720
                    opacity = 0
                }
            }
    }
}

// MARK: - Zone Card with 3D Effect
struct Zone3DCard: View {
    let zone: Zone
    var isExpanded: Bool = false
    let onTap: () -> Void

    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: zone.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Shimmer effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: shimmerOffset)
                .mask(RoundedRectangle(cornerRadius: 20))

            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(zone.emoji)
                        .font(.system(size: 40))

                    Spacer()

                    if zone.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("\(Int(zone.progress * 100))%")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                    }
                }

                if zone.isLocked {
                    Text("??? MYSTERY ZONE ???")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))

                    if let teaser = zone.teaserMessage {
                        Text(teaser)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                    } else {
                        Text("Something awesome awaits...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                    }
                } else {
                    Text(zone.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.3))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.9))
                                .frame(width: geo.size.width * zone.progress)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Label("\(zone.blocksPlacedRollup ?? 0)", systemImage: "cube.fill")
                        Spacer()
                        if let layers = zone.layerProgressCount, let total = zone.totalLayers {
                            Label("Layer \(layers)/\(total)", systemImage: "square.stack.3d.up")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)
        }
        .frame(height: zone.isLocked ? 140 : 170)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 2 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .shadow(color: zone.themeColor.opacity(0.4), radius: isPressed ? 5 : 15, y: isPressed ? 2 : 8)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                HapticManager.shared.impact(.medium)
                onTap()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
}

// MARK: - Material Encyclopedia Card
struct MaterialEncyclopediaCard: View {
    let material: Material
    @State private var isFlipped = false
    @State private var showingDetail = false

    var body: some View {
        ZStack {
            // Back of card (trivia)
            VStack(spacing: 12) {
                Text("📖 FUN FACT")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mcGold)

                Text(material.trivia)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Text("Tap to flip back")
                    .font(.caption)
                    .foregroundColor(.mcStone)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.mcCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(material.rarity.color.opacity(0.5), lineWidth: 2)
                    )
            )
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1 : 0)

            // Front of card
            VStack(spacing: 8) {
                // Block image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.mcDeepslate)
                        .frame(width: 70, height: 70)

                    Text(material.emoji)
                        .font(.system(size: 40))
                }
                .shadow(color: material.rarity.color.opacity(0.3), radius: 5)

                Text(material.materialName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Rarity badge
                Text(material.rarity.name.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(material.rarity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(material.rarity.color.opacity(0.2))
                    )

                // Progress mini bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mcDeepslate)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(material.rarity.color)
                            .frame(width: geo.size.width * material.progress)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 8)

                Text("\(material.qtyPlaced)/\(material.qtyPlanned)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.mcStone)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.mcCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(material.rarity.color.opacity(0.3), lineWidth: 2)
                    )
            )
            .opacity(isFlipped ? 0 : 1)
        }
        .frame(height: 200)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
            HapticManager.shared.selection()
        }
    }
}

// MARK: - Build Session Timeline Card
struct SessionTimelineCard: View {
    let session: BuildSession
    let isLatest: Bool

    @State private var appear = false

    var body: some View {
        HStack(spacing: 16) {
            // Timeline dot and line
            VStack(spacing: 0) {
                Circle()
                    .fill(isLatest ? Color.mcRedstone : session.mood.color)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .scaleEffect(appear ? 1 : 0)

                Rectangle()
                    .fill(Color.mcStone.opacity(0.3))
                    .frame(width: 2)
            }

            // Session card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(session.formattedDate)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    if isLatest {
                        Text("LATEST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.mcRedstone)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.mcRedstone.opacity(0.2))
                            )
                    }

                    Text(session.mood.emoji)
                        .font(.title3)
                }

                HStack(spacing: 20) {
                    // Blocks
                    HStack(spacing: 4) {
                        Image(systemName: "cube.fill")
                            .foregroundColor(.mcDiamond)
                        Text("\(session.blocksPlacedThisSession ?? 0)")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }

                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.mcEmerald)
                        Text(session.formattedDuration)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }

                    Spacer()
                }
                .font(.system(size: 14))

                if let notes = session.notesDisplay, !notes.isEmpty {
                    Text("💬 \"\(notes)\"")
                        .font(.system(size: 13))
                        .foregroundColor(.mcGold)
                        .italic()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isLatest ? Color.mcRedstone.opacity(0.5) : Color.mcStone.opacity(0.2),
                                lineWidth: isLatest ? 2 : 1
                            )
                    )
            )
            .offset(x: appear ? 0 : 50)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Streak Fire Badge
struct StreakBadge: View {
    let streakDays: Int
    @State private var flameScale: CGFloat = 1.0
    @State private var flameOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            // Animated fire
            Text("🔥")
                .font(.system(size: 28))
                .scaleEffect(flameScale)
                .offset(y: flameOffset)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakDays)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.mcGold)

                Text("DAY STREAK")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.mcStone)
                    .tracking(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.mcRedstone.opacity(0.3), Color.mcGold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.mcGold.opacity(0.5), lineWidth: 2)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                flameScale = 1.15
                flameOffset = -2
            }
        }
    }
}

// MARK: - Loading Skeleton
struct SkeletonView: View {
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.mcDeepslate)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset)
            )
            .mask(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 400
                }
            }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 60))

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.mcStone)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
