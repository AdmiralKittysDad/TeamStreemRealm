import SwiftUI

struct KidsMaterialsView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var selectedCategory: String? = nil
    @State private var sortOrder: SortOrder = .rarity
    @State private var searchText = ""
    @State private var appearAnimation = false

    enum SortOrder: String, CaseIterable {
        case rarity = "Rarity"
        case name = "Name"
        case progress = "Progress"
        case quantity = "Quantity"

        var icon: String {
            switch self {
            case .rarity: return "star.fill"
            case .name: return "textformat"
            case .progress: return "chart.bar.fill"
            case .quantity: return "number"
            }
        }
    }

    var categories: [String] {
        let cats = Set(airtable.materials.compactMap { $0.category })
        return cats.sorted()
    }

    var filteredMaterials: [Material] {
        var materials = airtable.materials

        // Filter by category
        if let category = selectedCategory {
            materials = materials.filter { $0.category == category }
        }

        // Filter by search
        if !searchText.isEmpty {
            materials = materials.filter {
                $0.materialName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortOrder {
        case .rarity:
            return materials.sorted { rarityValue($0.rarity) > rarityValue($1.rarity) }
        case .name:
            return materials.sorted { $0.materialName < $1.materialName }
        case .progress:
            return materials.sorted { $0.progress > $1.progress }
        case .quantity:
            return materials.sorted { $0.qtyPlanned > $1.qtyPlanned }
        }
    }

    private func rarityValue(_ rarity: BlockRarity) -> Int {
        switch rarity {
        case .legendary: return 5
        case .epic: return 4
        case .rare: return 3
        case .uncommon: return 2
        case .common: return 1
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Epic Header
                headerSection

                // Stats Overview
                statsOverview

                // Category Filter
                categoryFilter

                // Sort Controls
                sortControls

                // Materials Grid - The Encyclopedia!
                materialsGrid
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("📚")
                            .font(.system(size: 32))

                        Text("BLOCK ENCYCLOPEDIA")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.mcAmethyst, .mcDiamond],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    Text("Discover all the cool blocks in the build!")
                        .font(.system(size: 13))
                        .foregroundColor(.mcStone)
                }

                Spacer()
            }

            // Rarity Legend
            rarityLegend
        }
    }

    private var rarityLegend: some View {
        HStack(spacing: 6) {
            ForEach([BlockRarity.legendary, .epic, .rare, .uncommon, .common], id: \.self) { rarity in
                HStack(spacing: 4) {
                    Circle()
                        .fill(rarity.color)
                        .frame(width: 8, height: 8)
                    Text(rarity.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.mcStone)
                }
            }
        }
    }

    // MARK: - Stats Overview
    private var statsOverview: some View {
        HStack(spacing: 12) {
            // Total blocks
            VStack(spacing: 4) {
                Text("\(airtable.materials.count)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.mcDiamond)
                Text("Block Types")
                    .font(.system(size: 11))
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcCardBg)
            )

            // Legendary count
            let legendaryCount = airtable.materials.filter { $0.rarity == .legendary }.count
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("⭐")
                    Text("\(legendaryCount)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.mcGold)
                }
                Text("Legendary")
                    .font(.system(size: 11))
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcGold.opacity(0.15))
            )

            // Completed count
            let completedCount = airtable.materials.filter { $0.isComplete }.count
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("✅")
                    Text("\(completedCount)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.mcEmerald)
                }
                Text("Complete")
                    .font(.system(size: 11))
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mcEmerald.opacity(0.15))
            )
        }
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FILTER BY CATEGORY")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.mcStone)
                .tracking(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryChip(
                        title: "All",
                        icon: "square.grid.2x2",
                        isSelected: selectedCategory == nil,
                        color: .mcDiamond
                    ) {
                        selectedCategory = nil
                        HapticManager.shared.selection()
                    }

                    ForEach(categories, id: \.self) { category in
                        CategoryChip(
                            title: category,
                            icon: categoryIcon(for: category),
                            isSelected: selectedCategory == category,
                            color: categoryColor(for: category)
                        ) {
                            selectedCategory = category
                            HapticManager.shared.selection()
                        }
                    }
                }
            }
        }
    }

    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case let c where c.contains("prismarine"): return "water.waves"
        case let c where c.contains("light"): return "lightbulb.fill"
        case let c where c.contains("blackstone"): return "square.fill"
        case let c where c.contains("obsidian"): return "hexagon.fill"
        case let c where c.contains("ice"): return "snowflake"
        case let c where c.contains("stone"): return "mountain.2.fill"
        case let c where c.contains("glass"): return "square.dashed"
        case let c where c.contains("metal"): return "shield.fill"
        case let c where c.contains("nether"): return "flame.fill"
        case let c where c.contains("wood"): return "tree.fill"
        default: return "cube.fill"
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case let c where c.contains("prismarine"): return .mcPrismarine
        case let c where c.contains("light"): return .mcGold
        case let c where c.contains("blackstone"): return .mcDeepslate
        case let c where c.contains("obsidian"): return .mcAmethyst
        case let c where c.contains("ice"): return .mcDiamond
        case let c where c.contains("nether"): return .mcRedstone
        default: return .mcStone
        }
    }

    // MARK: - Sort Controls
    private var sortControls: some View {
        HStack(spacing: 8) {
            Text("SORT BY")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.mcStone)
                .tracking(1)

            ForEach(SortOrder.allCases, id: \.self) { order in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        sortOrder = order
                    }
                    HapticManager.shared.selection()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: order.icon)
                            .font(.system(size: 10))
                        Text(order.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(sortOrder == order ? .white : .mcStone)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(sortOrder == order ? Color.mcDiamond : Color.mcCardBg)
                    )
                }
            }

            Spacer()
        }
    }

    // MARK: - Materials Grid
    @ViewBuilder
    private var materialsGrid: some View {
        if filteredMaterials.isEmpty {
            EmptyStateView(
                icon: "🔍",
                title: "No Blocks Found",
                message: "Try a different category or search term"
            )
            .padding(.top, 40)
        } else {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(filteredMaterials.enumerated()), id: \.element.id) { index, material in
                    MaterialEncyclopediaCard(material: material)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.7)
                            .delay(Double(index % 10) * 0.05),
                            value: appearAnimation
                        )
                }
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .mcStone)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.mcCardBg)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? color : Color.mcStone.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    KidsMaterialsView()
}
