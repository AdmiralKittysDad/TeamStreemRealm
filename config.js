// ============================================
// MEGA BUILD TRACKER - Configuration
// ============================================

const CONFIG = {
  // Airtable Configuration
  AIRTABLE_API_KEY: 'patmH6KZTNDCGNbhX.7fcdbf3b4042c83f98eed229566b5735279e6e33db0473ba7a98eadd8283a667',
  AIRTABLE_BASE_ID: 'appmul5QQ7fC0RlfB',

  // Table Names
  TABLES: {
    PROJECTS: 'Projects',
    ZONES: 'Zones',
    STRUCTURES: 'Structures',
    BUILD_SESSIONS: 'Build_Sessions',
    MATERIALS: 'Materials'
  },

  // Refresh interval (in milliseconds) - 30 seconds
  REFRESH_INTERVAL: 30 * 1000,

  // Fun facts to cycle through
  FUN_FACTS: [
    "Every block placed brings you closer to something epic!",
    "Master builders always plan before they build!",
    "The biggest builds start with a single block!",
    "Teamwork makes the dream work!",
    "Even the Ender Dragon started as an egg!",
    "Great builders never give up!",
    "Your world, your rules, your adventure!",
    "Legends are built one block at a time!",
    "The best treasures are the ones we build together!",
    "Keep calm and mine on!",
    "Every expert was once a beginner!",
    "Building is believing!"
  ],

  // Mood emojis mapping
  MOOD_EMOJIS: {
    '🏆 Master Builder': '🏆',
    '😤 Creeper Problems': '😤',
    '🧱 Brick by Brick': '🧱',
    '🔥 On Fire': '🔥',
    '😴 Mined Out': '😴'
  },

  // Structure type icons
  STRUCTURE_ICONS: {
    'Platform': '🏗️',
    'Tower': '🗼',
    'Chamber': '🏛️',
    'System': '⚙️',
    'Other': '🧱'
  },

  // Block data with images, descriptions, and trivia
  BLOCK_DATA: {
    'default': {
      image: 'https://minecraft.wiki/images/Block.gif',
      emoji: '🧱',
      description: 'A mysterious block waiting to be discovered!',
      trivia: 'Every block in Minecraft has a story to tell.',
      rarity: 'common'
    },
    'Prismarine': {
      image: 'https://minecraft.wiki/images/Prismarine_JE2_BE2.png',
      emoji: '🟦',
      description: 'A beautiful aquatic stone that shifts colors over time. Found deep within Ocean Monuments guarded by fearsome Guardians.',
      trivia: 'Prismarine is one of the only blocks in Minecraft that changes color! It cycles through shades of green, blue, and purple.',
      rarity: 'uncommon'
    },
    'Dark Prismarine': {
      image: 'https://minecraft.wiki/images/Dark_Prismarine_JE2_BE2.png',
      emoji: '🟩',
      description: 'A darker, more refined variant of prismarine with a deep teal color. Crafted using ink sacs from squids.',
      trivia: 'Dark Prismarine requires squid ink to craft, making it a combination of ocean treasures!',
      rarity: 'uncommon'
    },
    'Prismarine Bricks': {
      image: 'https://minecraft.wiki/images/Prismarine_Bricks_JE2_BE2.png',
      emoji: '🧱',
      description: 'Refined prismarine blocks arranged in a beautiful brick pattern. Perfect for detailed underwater builds.',
      trivia: 'Unlike regular prismarine, prismarine bricks do NOT change color - they stay a consistent teal.',
      rarity: 'uncommon'
    },
    'Sea Lanterns': {
      image: 'https://minecraft.wiki/images/Sea_Lantern_JE1.gif',
      emoji: '💡',
      description: 'Luminous blocks that glow with the light of the deep ocean. They emit a light level of 15 - the brightest possible!',
      trivia: 'Sea Lanterns pulse with light! Watch closely and you\'ll see them gently flicker like underwater stars.',
      rarity: 'rare'
    },
    'Blackstone': {
      image: 'https://minecraft.wiki/images/Blackstone_JE1_BE1.png',
      emoji: '⬛',
      description: 'A dark volcanic stone from the Nether. Harder than cobblestone and perfect for spooky builds.',
      trivia: 'Blackstone was added in the Nether Update and can be used as a substitute for cobblestone in many recipes!',
      rarity: 'common'
    },
    'Polished Blackstone': {
      image: 'https://minecraft.wiki/images/Polished_Blackstone_JE1_BE1.png',
      emoji: '◼️',
      description: 'Smooth, refined blackstone with a sleek appearance. Popular for modern Nether-themed builds.',
      trivia: 'Polished Blackstone can be used to craft stone tools, just like regular cobblestone!',
      rarity: 'common'
    },
    'Crying Obsidian': {
      image: 'https://minecraft.wiki/images/Crying_Obsidian_JE1_BE1.gif',
      emoji: '💜',
      description: 'Ancient obsidian that weeps purple tears. Used to craft Respawn Anchors for setting spawn points in the Nether!',
      trivia: 'Crying Obsidian was one of the first blocks ever shown in Minecraft but wasn\'t added until 11 years later!',
      rarity: 'rare'
    },
    'Gilded Blackstone': {
      image: 'https://minecraft.wiki/images/Gilded_Blackstone_JE1_BE1.png',
      emoji: '✨',
      description: 'Blackstone with veins of precious gold running through it. Found in Bastion Remnants.',
      trivia: 'Mining Gilded Blackstone has a 10% chance to drop gold nuggets instead of the block itself!',
      rarity: 'epic'
    },
    'Glass': {
      image: 'https://minecraft.wiki/images/Glass_JE4_BE2.png',
      emoji: '🪟',
      description: 'Transparent blocks made by smelting sand. Essential for windows and see-through structures.',
      trivia: 'Glass doesn\'t drop itself when broken without Silk Touch - it just shatters into nothing!',
      rarity: 'common'
    },
    'Tinted Glass': {
      image: 'https://minecraft.wiki/images/Tinted_Glass_JE1_BE1.png',
      emoji: '🕶️',
      description: 'Special glass that blocks light while still being see-through. Crafted with amethyst shards!',
      trivia: 'Tinted Glass is perfect for building mob farms because it blocks light but lets you watch the action!',
      rarity: 'uncommon'
    },
    'Sea Lanterns': {
      image: 'https://minecraft.wiki/images/Sea_Lantern_JE1.gif',
      emoji: '🌟',
      description: 'Luminous blocks harvested from Ocean Monuments. They glow with an enchanting underwater light.',
      trivia: 'Sea Lanterns emit light level 15 - as bright as glowstone, but with a cooler blue glow!',
      rarity: 'rare'
    },
    'Smooth Stone': {
      image: 'https://minecraft.wiki/images/Smooth_Stone_JE2_BE2.png',
      emoji: '🪨',
      description: 'Extra-refined stone with a clean, flat surface. Made by smelting regular stone.',
      trivia: 'Smooth Stone requires double-smelting: first cobblestone to stone, then stone to smooth stone!',
      rarity: 'common'
    },
    'Blue Ice': {
      image: 'https://minecraft.wiki/images/Blue_Ice_JE2_BE1.png',
      emoji: '🧊',
      description: 'The slipperiest block in all of Minecraft! Found in icebergs and perfect for super-fast boat highways.',
      trivia: 'Blue Ice is 2.5x more slippery than regular ice, and boats can travel at over 70 blocks per second on it!',
      rarity: 'rare'
    },
    'Lodestone': {
      image: 'https://minecraft.wiki/images/Lodestone_JE1_BE1.png',
      emoji: '🧭',
      description: 'A magical block that can link to compasses. Point your compass to any location in any dimension!',
      trivia: 'Lodestones are made with a Netherite Ingot - making them one of the most expensive functional blocks!',
      rarity: 'legendary'
    },
    'Beacons': {
      image: 'https://minecraft.wiki/images/Beacon_JE6_BE3.gif',
      emoji: '📡',
      description: 'Powerful blocks that shoot beams of light into the sky and grant special powers to nearby players!',
      trivia: 'Beacon beams can be seen from 256 blocks away and can shine through bedrock in the Nether!',
      rarity: 'legendary'
    },
    'Iron Blocks': {
      image: 'https://minecraft.wiki/images/Block_of_Iron_JE4_BE3.png',
      emoji: '⬜',
      description: 'Solid blocks of compressed iron ingots. Essential for building beacon pyramids and iron golems.',
      trivia: 'Four iron blocks arranged in a T-shape with a carved pumpkin on top creates an Iron Golem!',
      rarity: 'uncommon'
    },
    'Conduit': {
      image: 'https://minecraft.wiki/images/Conduit_%28active%29.gif',
      emoji: '🔮',
      description: 'A mysterious artifact that grants underwater breathing, night vision, and attacks hostile mobs!',
      trivia: 'A fully powered Conduit requires 42 prismarine blocks and can affect players up to 96 blocks away!',
      rarity: 'legendary'
    },
    'Magma Blocks': {
      image: 'https://minecraft.wiki/images/Magma_Block_JE2_BE2.gif',
      emoji: '🔥',
      description: 'Hot volcanic blocks that damage anything standing on them. Creates bubble columns that pull things down!',
      trivia: 'Magma blocks create a whirlpool effect in water - great for traps or underwater elevators going DOWN!',
      rarity: 'uncommon'
    },
    'Soul Sand': {
      image: 'https://minecraft.wiki/images/Soul_Sand_JE2_BE2.png',
      emoji: '💀',
      description: 'Spooky sand from the Nether that slows movement. Creates bubble columns that push things UP in water!',
      trivia: 'If you look closely, you can see ghostly faces trapped in Soul Sand!',
      rarity: 'common'
    },
    'Lanterns': {
      image: 'https://minecraft.wiki/images/Lantern_JE1.gif',
      emoji: '🏮',
      description: 'Decorative light sources that can hang from ceilings or sit on floors. Slightly brighter than torches!',
      trivia: 'Lanterns emit light level 15 - one of the brightest light sources in the game!',
      rarity: 'common'
    },
    'End Rods': {
      image: 'https://minecraft.wiki/images/End_Rod_JE1.png',
      emoji: '🕯️',
      description: 'Elegant light sources from the End dimension. They emit gentle white particles!',
      trivia: 'End Rods are crafted from a Blaze Rod and a Popped Chorus Fruit - a combination of Nether and End materials!',
      rarity: 'rare'
    },
    'Chain': {
      image: 'https://minecraft.wiki/images/Chain_JE1_BE1.png',
      emoji: '⛓️',
      description: 'Metal chains perfect for hanging lanterns or creating industrial decorations.',
      trivia: 'Chains can be placed horizontally as well as vertically - great for drawbridges!',
      rarity: 'common'
    },
    'Ladders': {
      image: 'https://minecraft.wiki/images/Ladder_JE4.png',
      emoji: '🪜',
      description: 'Wooden climbing tools that stick to walls. Essential for vertical navigation!',
      trivia: 'You can hold the sneak key while on a ladder to stop in place - perfect for building!',
      rarity: 'common'
    },
    'Chests': {
      image: 'https://minecraft.wiki/images/Chest_Opening_and_Closing.gif',
      emoji: '📦',
      description: 'Storage blocks that hold 27 stacks of items. The backbone of any good base!',
      trivia: 'Two chests next to each other create a double chest with 54 slots of storage!',
      rarity: 'common'
    },
    'Kelp': {
      image: 'https://minecraft.wiki/images/Kelp.png',
      emoji: '🌿',
      description: 'Underwater plants that grow from the ocean floor. Can be eaten or used as fuel when dried!',
      trivia: 'Dried kelp blocks are one of the most efficient fuel sources in the game!',
      rarity: 'common'
    },
    'Coral Blocks': {
      image: 'https://minecraft.wiki/images/Tube_Coral_Block_JE2_BE2.png',
      emoji: '🪸',
      description: 'Colorful living blocks from warm ocean biomes. Come in 5 beautiful varieties!',
      trivia: 'Coral blocks will turn gray and die if not placed next to water within 4 blocks!',
      rarity: 'uncommon'
    },
    'Coral Fans': {
      image: 'https://minecraft.wiki/images/Fire_Coral_Fan_JE2_BE2.png',
      emoji: '🌊',
      description: 'Decorative coral pieces that can be placed on blocks. Add life to any underwater build!',
      trivia: 'Like coral blocks, coral fans need water nearby or they\'ll turn into dead coral fans!',
      rarity: 'uncommon'
    },
    'Jack-o-Lanterns': {
      image: 'https://minecraft.wiki/images/Jack_o%27Lantern_JE4.png',
      emoji: '🎃',
      description: 'Carved pumpkins with a torch inside. They provide light AND look spooky!',
      trivia: 'Jack o\'Lanterns can be placed underwater and still glow - unlike torches!',
      rarity: 'common'
    },
    'Polished Blackstone Stairs': {
      image: 'https://minecraft.wiki/images/Polished_Blackstone_Stairs_JE1_BE1.png',
      emoji: '📐',
      description: 'Sleek stairs made from polished blackstone. Perfect for Nether-themed stairways!',
      trivia: 'Stairs only use 6 blocks to craft but give you 4 stairs - that\'s more efficient than slabs!',
      rarity: 'common'
    },
    'Cyan Stained Glass': {
      image: 'https://minecraft.wiki/images/Cyan_Stained_Glass_JE3_BE3.png',
      emoji: '🔷',
      description: 'Beautiful cyan-colored glass. Perfect for underwater or ocean-themed windows!',
      trivia: 'Stained glass can be used to change the color of beacon beams!',
      rarity: 'common'
    },
    'Magenta Stained Glass': {
      image: 'https://minecraft.wiki/images/Magenta_Stained_Glass_JE3_BE3.png',
      emoji: '🔶',
      description: 'Vibrant magenta-colored glass. Great for adding pops of color to builds!',
      trivia: 'All 16 colors of stained glass can be combined for amazing stained glass window designs!',
      rarity: 'common'
    }
  }
};
