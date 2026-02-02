import Foundation
import SwiftUI

// MARK: - Material Model
struct Material: Identifiable, Codable {
    let id: String
    var materialName: String
    var category: String?
    var qtyPlanned: Int
    var qtyRemaining: Int
    var progressFromAPI: Double?
    var notes: String?

    var progress: Double {
        if let p = progressFromAPI {
            return p
        }
        guard qtyPlanned > 0 else { return 0 }
        return Double(qtyPlanned - qtyRemaining) / Double(qtyPlanned)
    }

    var qtyPlaced: Int {
        max(0, qtyPlanned - qtyRemaining)
    }

    var isComplete: Bool {
        qtyPlaced >= qtyPlanned
    }

    // Block data from embedded database
    var blockData: BlockData {
        BlockData.data[materialName] ?? BlockData.defaultBlock
    }

    // Local asset image name (embedded in app bundle)
    var imageName: String {
        blockData.localImageName
    }

    var emoji: String {
        blockData.emoji
    }

    var description: String {
        blockData.description
    }

    var trivia: String {
        blockData.trivia
    }

    var rarity: BlockRarity {
        blockData.rarity
    }
}

enum BlockRarity: String, Codable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var color: Color {
        switch self {
        case .common: return .mcStone
        case .uncommon: return .mcEmerald
        case .rare: return .mcDiamond
        case .epic: return .mcAmethyst
        case .legendary: return .mcGold
        }
    }

    var name: String {
        rawValue.capitalized
    }
}

// MARK: - Block Data (Static Info)
// All images are embedded locally in Assets.xcassets/Blocks/
struct BlockData {
    let localImageName: String  // Asset catalog image name
    let emoji: String
    let description: String
    let trivia: String
    let rarity: BlockRarity

    static let defaultBlock = BlockData(
        localImageName: "block_stone",
        emoji: "🧱",
        description: "A mysterious block waiting to be discovered!",
        trivia: "Every block in Minecraft has a story to tell.",
        rarity: .common
    )

    static let data: [String: BlockData] = [
        // === PRISMARINE BLOCKS ===
        "Prismarine": BlockData(
            localImageName: "block_prismarine",
            emoji: "🟦",
            description: "A beautiful aquatic stone that shifts colors over time. Found deep within Ocean Monuments guarded by fearsome Guardians.",
            trivia: "Prismarine is one of the only blocks in Minecraft that changes color! It cycles through shades of green, blue, and purple.",
            rarity: .uncommon
        ),
        "Dark Prismarine": BlockData(
            localImageName: "block_dark_prismarine",
            emoji: "🟩",
            description: "A darker, more refined variant of prismarine with a deep teal color. Crafted using ink sacs from squids.",
            trivia: "Dark Prismarine requires squid ink to craft, making it a combination of ocean treasures!",
            rarity: .uncommon
        ),
        "Prismarine Bricks": BlockData(
            localImageName: "block_prismarine_bricks",
            emoji: "🧱",
            description: "Refined prismarine blocks arranged in a beautiful brick pattern. Perfect for detailed underwater builds.",
            trivia: "Unlike regular prismarine, prismarine bricks do NOT change color - they stay a consistent teal.",
            rarity: .uncommon
        ),

        // === LIGHTING BLOCKS ===
        "Sea Lanterns": BlockData(
            localImageName: "block_sea_lantern",
            emoji: "💡",
            description: "Luminous blocks that glow with the light of the deep ocean. They emit a light level of 15 - the brightest possible!",
            trivia: "Sea Lanterns pulse with light! Watch closely and you'll see them gently flicker like underwater stars.",
            rarity: .rare
        ),
        "Lanterns": BlockData(
            localImageName: "block_lantern",
            emoji: "🏮",
            description: "Decorative light sources that can hang from ceilings or sit on floors. Slightly brighter than torches!",
            trivia: "Lanterns emit light level 15 - one of the brightest light sources in the game!",
            rarity: .common
        ),
        "End Rods": BlockData(
            localImageName: "block_end_rod",
            emoji: "🕯️",
            description: "Elegant light sources from the End dimension. They emit gentle white particles!",
            trivia: "End Rods are crafted from a Blaze Rod and a Popped Chorus Fruit - a combination of Nether and End materials!",
            rarity: .rare
        ),
        "Soul Lantern": BlockData(
            localImageName: "block_soul_lantern",
            emoji: "🔵",
            description: "A haunting blue lantern that casts an eerie glow. Perfect for spooky builds!",
            trivia: "Soul Lanterns emit a lower light level (10) than regular lanterns, but their blue glow is unique!",
            rarity: .uncommon
        ),
        "Glowstone": BlockData(
            localImageName: "block_glowstone",
            emoji: "⭐",
            description: "A bright, glowing block from the Nether. Made from glowstone dust dropped by witches or found in the Nether.",
            trivia: "Glowstone is one of the few blocks that can transmit redstone signals through it!",
            rarity: .uncommon
        ),
        "Shroomlight": BlockData(
            localImageName: "block_shroomlight",
            emoji: "🍄",
            description: "A luminous block found on huge fungi in the Nether. It provides bright light with a warm, organic feel.",
            trivia: "Shroomlights are brighter than glowstone and don't shatter into dust when broken!",
            rarity: .uncommon
        ),

        // === BLACKSTONE FAMILY ===
        "Blackstone": BlockData(
            localImageName: "block_blackstone",
            emoji: "⬛",
            description: "A dark volcanic stone from the Nether. Harder than cobblestone and perfect for spooky builds.",
            trivia: "Blackstone was added in the Nether Update and can be used as a substitute for cobblestone in many recipes!",
            rarity: .common
        ),
        "Polished Blackstone": BlockData(
            localImageName: "block_polished_blackstone",
            emoji: "◼️",
            description: "Smooth, refined blackstone with a sleek appearance. Popular for modern Nether-themed builds.",
            trivia: "Polished Blackstone can be used to craft stone tools, just like regular cobblestone!",
            rarity: .common
        ),
        "Polished Blackstone Bricks": BlockData(
            localImageName: "block_polished_blackstone_bricks",
            emoji: "🔲",
            description: "Elegant bricks crafted from polished blackstone. Creates a distinguished, dark aesthetic.",
            trivia: "These bricks can be cracked in a furnace to create a weathered, ancient look!",
            rarity: .common
        ),
        "Chiseled Polished Blackstone": BlockData(
            localImageName: "block_chiseled_polished_blackstone",
            emoji: "🔳",
            description: "Ornate blackstone with a carved pattern. Features a mysterious skull-like design.",
            trivia: "The chiseled pattern looks like a Piglin face - fitting for the Nether!",
            rarity: .uncommon
        ),
        "Gilded Blackstone": BlockData(
            localImageName: "block_gilded_blackstone",
            emoji: "✨",
            description: "Blackstone with veins of precious gold running through it. Found in Bastion Remnants.",
            trivia: "Mining Gilded Blackstone has a 10% chance to drop gold nuggets instead of the block itself!",
            rarity: .epic
        ),

        // === OBSIDIAN VARIANTS ===
        "Crying Obsidian": BlockData(
            localImageName: "block_crying_obsidian",
            emoji: "💜",
            description: "Ancient obsidian that weeps purple tears. Used to craft Respawn Anchors for setting spawn points in the Nether!",
            trivia: "Crying Obsidian was one of the first blocks ever shown in Minecraft but wasn't added until 11 years later!",
            rarity: .rare
        ),
        "Obsidian": BlockData(
            localImageName: "block_obsidian",
            emoji: "🟪",
            description: "One of the hardest blocks in the game, formed when water meets lava. Used to build Nether portals.",
            trivia: "It takes 9.4 seconds to mine obsidian with a diamond pickaxe - the longest mining time in vanilla Minecraft!",
            rarity: .uncommon
        ),

        // === ICE BLOCKS ===
        "Blue Ice": BlockData(
            localImageName: "block_blue_ice",
            emoji: "🧊",
            description: "The slipperiest block in all of Minecraft! Found in icebergs and perfect for super-fast boat highways.",
            trivia: "Blue Ice is 2.5x more slippery than regular ice, and boats can travel at over 70 blocks per second on it!",
            rarity: .rare
        ),
        "Packed Ice": BlockData(
            localImageName: "block_packed_ice",
            emoji: "❄️",
            description: "Solid ice that doesn't melt near light sources. Great for permanent ice structures.",
            trivia: "Packed Ice doesn't melt and doesn't create water when broken - unlike regular ice!",
            rarity: .uncommon
        ),
        "Ice": BlockData(
            localImageName: "block_ice",
            emoji: "🌨️",
            description: "Frozen water that melts near light. Slippery surface makes movement faster!",
            trivia: "Regular ice melts if the light level is above 11 or if it's near a heat source.",
            rarity: .common
        ),

        // === SPECIAL BLOCKS ===
        "Lodestone": BlockData(
            localImageName: "block_lodestone",
            emoji: "🧭",
            description: "A magical block that can link to compasses. Point your compass to any location in any dimension!",
            trivia: "Lodestones are made with a Netherite Ingot - making them one of the most expensive functional blocks!",
            rarity: .legendary
        ),
        "Beacons": BlockData(
            localImageName: "block_beacon",
            emoji: "📡",
            description: "Powerful blocks that shoot beams of light into the sky and grant special powers to nearby players!",
            trivia: "Beacon beams can be seen from 256 blocks away and can shine through bedrock in the Nether!",
            rarity: .legendary
        ),
        "Conduit": BlockData(
            localImageName: "block_conduit",
            emoji: "🔮",
            description: "A mysterious artifact that grants underwater breathing, night vision, and attacks hostile mobs!",
            trivia: "A fully powered Conduit requires 42 prismarine blocks and can affect players up to 96 blocks away!",
            rarity: .legendary
        ),

        // === STONE VARIANTS ===
        "Smooth Stone": BlockData(
            localImageName: "block_smooth_stone",
            emoji: "🪨",
            description: "Extra-refined stone with a clean, flat surface. Made by smelting regular stone.",
            trivia: "Smooth Stone requires double-smelting: first cobblestone to stone, then stone to smooth stone!",
            rarity: .common
        ),
        "Stone": BlockData(
            localImageName: "block_stone",
            emoji: "⬜",
            description: "The most common block underground. Turns into cobblestone when mined.",
            trivia: "Stone makes up about 65% of the underground in Minecraft!",
            rarity: .common
        ),
        "Stone Bricks": BlockData(
            localImageName: "block_stone_bricks",
            emoji: "🧱",
            description: "Refined stone arranged in a brick pattern. Classic building material for castles and temples.",
            trivia: "Stone Bricks are found naturally in Strongholds - structures that house End Portals!",
            rarity: .common
        ),
        "Deepslate": BlockData(
            localImageName: "block_deepslate",
            emoji: "🌑",
            description: "A dark, dense stone found deep underground. Harder to mine than regular stone.",
            trivia: "Deepslate generates below Y level 8 and replaces stone in the deepest parts of the world!",
            rarity: .common
        ),
        "Deepslate Bricks": BlockData(
            localImageName: "block_deepslate_bricks",
            emoji: "🔘",
            description: "Dark, elegant bricks crafted from deepslate. Perfect for modern dungeon aesthetics.",
            trivia: "Deepslate bricks have a unique, industrial look that's popular in modern builds!",
            rarity: .common
        ),

        // === GLASS ===
        "Glass": BlockData(
            localImageName: "block_glass",
            emoji: "🪟",
            description: "Transparent blocks made by smelting sand. Essential for windows and see-through structures.",
            trivia: "Glass doesn't drop itself when broken without Silk Touch - it just shatters into nothing!",
            rarity: .common
        ),
        "Tinted Glass": BlockData(
            localImageName: "block_tinted_glass",
            emoji: "🕶️",
            description: "Mysterious dark glass that blocks light but you can still see through it!",
            trivia: "Tinted Glass drops itself when broken, unlike regular glass!",
            rarity: .uncommon
        ),

        // === METAL BLOCKS ===
        "Iron Blocks": BlockData(
            localImageName: "block_iron",
            emoji: "⬜",
            description: "Solid blocks of compressed iron ingots. Essential for building beacon pyramids and iron golems.",
            trivia: "Four iron blocks arranged in a T-shape with a carved pumpkin on top creates an Iron Golem!",
            rarity: .uncommon
        ),
        "Gold Block": BlockData(
            localImageName: "block_gold",
            emoji: "🟨",
            description: "Shiny blocks of pure gold. Used for beacon pyramids and impressing your friends!",
            trivia: "Gold blocks are the only metal blocks that Piglins will admire!",
            rarity: .rare
        ),
        "Diamond Block": BlockData(
            localImageName: "block_diamond",
            emoji: "💎",
            description: "The ultimate flex - a solid block of diamonds. Incredibly rare and valuable.",
            trivia: "A single diamond block requires 9 diamonds, which can take hours to find!",
            rarity: .epic
        ),
        "Netherite Block": BlockData(
            localImageName: "block_netherite",
            emoji: "🖤",
            description: "The rarest and most powerful block in the game. Immune to fire and explosions!",
            trivia: "One Netherite block requires 9 Netherite ingots - that's 36 Ancient Debris!",
            rarity: .legendary
        ),
        "Copper Block": BlockData(
            localImageName: "block_copper",
            emoji: "🟧",
            description: "A shiny orange metal block that oxidizes over time, turning green!",
            trivia: "Copper blocks go through 4 stages of oxidation unless you wax them with honeycomb!",
            rarity: .common
        ),

        // === DECORATIVE ===
        "Chain": BlockData(
            localImageName: "block_chain",
            emoji: "⛓️",
            description: "Metal chains perfect for hanging lanterns or creating industrial decorations.",
            trivia: "Chains can be placed horizontally as well as vertically - great for drawbridges!",
            rarity: .common
        ),

        // === NETHER BLOCKS ===
        "Magma Blocks": BlockData(
            localImageName: "block_magma",
            emoji: "🔥",
            description: "Hot volcanic blocks that damage anything standing on them. Creates bubble columns that pull things down!",
            trivia: "Magma blocks create a whirlpool effect in water - great for traps or underwater elevators going DOWN!",
            rarity: .uncommon
        ),
        "Soul Sand": BlockData(
            localImageName: "block_soul_sand",
            emoji: "💀",
            description: "Spooky sand from the Nether that slows movement. Creates bubble columns that push things UP in water!",
            trivia: "If you look closely, you can see ghostly faces trapped in Soul Sand!",
            rarity: .common
        ),
        "Soul Soil": BlockData(
            localImageName: "block_soul_soil",
            emoji: "👻",
            description: "Similar to Soul Sand but doesn't slow movement. Fire burns blue on it!",
            trivia: "Soul Fire on Soul Soil deals more damage than regular fire!",
            rarity: .common
        ),
        "Nether Bricks": BlockData(
            localImageName: "block_nether_bricks",
            emoji: "🟤",
            description: "Dark red bricks found in Nether Fortresses. Heat-resistant and blast-proof.",
            trivia: "Nether Bricks are immune to Ghast fireballs - that's why Fortresses are made of them!",
            rarity: .common
        ),
        "Red Nether Bricks": BlockData(
            localImageName: "block_red_nether_bricks",
            emoji: "🔴",
            description: "A darker, more sinister variant of Nether Bricks. Crafted with Nether Wart.",
            trivia: "Red Nether Bricks don't generate naturally - you have to craft them!",
            rarity: .uncommon
        ),
        "Basalt": BlockData(
            localImageName: "block_basalt",
            emoji: "🌋",
            description: "A volcanic rock from the Nether. Can be polished for a sleeker look.",
            trivia: "Basalt forms naturally when lava flows over Soul Soil next to Blue Ice!",
            rarity: .common
        ),
        "Polished Basalt": BlockData(
            localImageName: "block_polished_basalt",
            emoji: "🔵",
            description: "Smooth, refined basalt with a clean cylindrical appearance.",
            trivia: "The top of Polished Basalt looks like a target or bullseye!",
            rarity: .common
        ),

        // === AMETHYST ===
        "Amethyst Block": BlockData(
            localImageName: "block_amethyst",
            emoji: "💜",
            description: "A beautiful purple crystal block that chimes when walked on or hit!",
            trivia: "Amethyst blocks make a unique, musical chiming sound - great for instruments!",
            rarity: .rare
        ),
        "Budding Amethyst": BlockData(
            localImageName: "block_budding_amethyst",
            emoji: "🔮",
            description: "The only block that grows Amethyst Clusters. Cannot be obtained even with Silk Touch!",
            trivia: "Budding Amethyst is completely unobtainable in Survival - it breaks into nothing!",
            rarity: .legendary
        ),

        // === CORAL BLOCKS ===
        "Brain Coral Block": BlockData(
            localImageName: "block_brain_coral",
            emoji: "🧠",
            description: "A pink coral block with a brain-like pattern. Dies if not in water!",
            trivia: "Coral blocks will turn into dead coral if they're not touching water within 4 blocks.",
            rarity: .uncommon
        ),
        "Tube Coral Block": BlockData(
            localImageName: "block_tube_coral",
            emoji: "🔵",
            description: "A vibrant blue coral block. Found in warm ocean biomes.",
            trivia: "Tube coral is one of the 5 coral types added in the Update Aquatic!",
            rarity: .uncommon
        ),
        "Fire Coral Block": BlockData(
            localImageName: "block_fire_coral",
            emoji: "🔴",
            description: "A bright red coral block that adds fiery color to underwater builds.",
            trivia: "Despite its name, Fire Coral has nothing to do with actual fire!",
            rarity: .uncommon
        ),

        // === TERRACOTTA ===
        "Terracotta": BlockData(
            localImageName: "block_terracotta",
            emoji: "🟫",
            description: "Hardened clay that can be dyed into 16 different colors. Found in badlands.",
            trivia: "Terracotta is blast resistant - almost as strong as cobblestone!",
            rarity: .common
        ),
        "Glazed Terracotta": BlockData(
            localImageName: "block_cyan_glazed_terracotta",
            emoji: "🎨",
            description: "Beautifully patterned ceramic blocks. Each color has a unique design!",
            trivia: "Glazed Terracotta patterns can be rotated to create complex designs!",
            rarity: .uncommon
        ),

        // === WOOD TYPES ===
        "Oak Planks": BlockData(
            localImageName: "block_oak_planks",
            emoji: "🪵",
            description: "The classic Minecraft building block. Warm, versatile, and easy to find.",
            trivia: "Oak trees were the only tree type in Minecraft until 2011!",
            rarity: .common
        ),
        "Dark Oak Planks": BlockData(
            localImageName: "block_dark_oak_planks",
            emoji: "🟤",
            description: "Rich, dark brown planks from Dark Oak trees. Found only in Dark Forest biomes.",
            trivia: "Dark Oak trees only grow from 2x2 saplings planted together!",
            rarity: .common
        ),
        "Spruce Planks": BlockData(
            localImageName: "block_spruce_planks",
            emoji: "🌲",
            description: "Darker planks from Spruce trees. Perfect for cozy cabin builds.",
            trivia: "Spruce trees can grow into giant trees if planted in a 2x2 pattern!",
            rarity: .common
        ),
        "Warped Planks": BlockData(
            localImageName: "block_warped_planks",
            emoji: "🩵",
            description: "Teal-colored planks from the Warped Forest. Fire-resistant Nether wood!",
            trivia: "Warped wood is completely fireproof - it won't burn in lava!",
            rarity: .uncommon
        ),
        "Crimson Planks": BlockData(
            localImageName: "block_crimson_planks",
            emoji: "❤️",
            description: "Red-tinted planks from the Crimson Forest. Also fire-resistant!",
            trivia: "Crimson Forests are the only place where Hoglins spawn naturally!",
            rarity: .uncommon
        ),

        // === END BLOCKS ===
        "End Stone": BlockData(
            localImageName: "block_end_stone",
            emoji: "🟡",
            description: "The pale yellow stone that makes up The End dimension.",
            trivia: "End Stone is extremely blast resistant - great for Wither fights!",
            rarity: .uncommon
        ),
        "End Stone Bricks": BlockData(
            localImageName: "block_end_stone_bricks",
            emoji: "🔶",
            description: "Refined End Stone with a brick pattern. Elegant and durable.",
            trivia: "End Stone Bricks are one of the most blast-resistant craftable blocks!",
            rarity: .uncommon
        ),
        "Purpur Block": BlockData(
            localImageName: "block_purpur",
            emoji: "🟣",
            description: "Purple blocks found in End Cities. Made from Chorus Fruit!",
            trivia: "Purpur is named after the Latin word for purple!",
            rarity: .rare
        ),
        "Purpur Pillar": BlockData(
            localImageName: "block_purpur_pillar",
            emoji: "🏛️",
            description: "Decorative purple pillars from The End. Directional placement!",
            trivia: "Purpur Pillars can be oriented in different directions like logs!",
            rarity: .rare
        )
    ]
}

// MARK: - Airtable Mapping
extension Material {
    init(from record: AirtableRecord) {
        self.id = record.id
        self.materialName = record.fields["Material_Name"] as? String ?? "Unknown"
        self.category = record.fields["Category"] as? String
        self.qtyPlanned = record.fields["Qty_Planned"] as? Int ?? 0
        self.qtyRemaining = record.fields["Qty_Remaining"] as? Int ?? 0
        self.progressFromAPI = record.fields["Progress"] as? Double
        self.notes = record.fields["Notes"] as? String
    }

    func toAirtableFields() -> [String: Any] {
        var fields: [String: Any] = [:]
        fields["Material_Name"] = materialName
        if let cat = category { fields["Category"] = cat }
        fields["Qty_Planned"] = qtyPlanned
        if let n = notes { fields["Notes"] = n }
        return fields
    }
}
