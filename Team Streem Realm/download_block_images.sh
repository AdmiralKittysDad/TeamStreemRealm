#!/bin/bash
# Download Minecraft block images and create Xcode asset catalog structure
# Run this script from the Team Streem Realm folder

ASSETS_DIR="Team Streem Realm/Assets.xcassets/Blocks"
BASE_URL="https://mc.nerothe.com/img/1.21.4"

# Create assets directory if it doesn't exist
mkdir -p "$ASSETS_DIR"

# Function to create an imageset
create_imageset() {
    local source_name=$1
    local asset_name=$2

    local imageset_dir="$ASSETS_DIR/${asset_name}.imageset"
    mkdir -p "$imageset_dir"

    # Download the image
    echo "Downloading $source_name -> $asset_name..."
    curl -s -o "$imageset_dir/${asset_name}.png" "$BASE_URL/$source_name"

    # Create Contents.json
    cat > "$imageset_dir/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "${asset_name}.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : false,
    "template-rendering-intent" : "original"
  }
}
EOF
}

echo "🧱 Downloading Minecraft block images..."
echo "================================================"

# Prismarine blocks
create_imageset "prismarine.png" "block_prismarine"
create_imageset "dark_prismarine.png" "block_dark_prismarine"
create_imageset "prismarine_bricks.png" "block_prismarine_bricks"

# Lighting blocks
create_imageset "sea_lantern.png" "block_sea_lantern"
create_imageset "lantern.png" "block_lantern"
create_imageset "end_rod.png" "block_end_rod"
create_imageset "soul_lantern.png" "block_soul_lantern"
create_imageset "glowstone.png" "block_glowstone"
create_imageset "shroomlight.png" "block_shroomlight"

# Blackstone family
create_imageset "blackstone.png" "block_blackstone"
create_imageset "polished_blackstone.png" "block_polished_blackstone"
create_imageset "polished_blackstone_bricks.png" "block_polished_blackstone_bricks"
create_imageset "chiseled_polished_blackstone.png" "block_chiseled_polished_blackstone"
create_imageset "gilded_blackstone.png" "block_gilded_blackstone"

# Obsidian
create_imageset "crying_obsidian.png" "block_crying_obsidian"
create_imageset "obsidian.png" "block_obsidian"

# Ice blocks
create_imageset "blue_ice.png" "block_blue_ice"
create_imageset "packed_ice.png" "block_packed_ice"
create_imageset "ice.png" "block_ice"

# Special blocks
create_imageset "lodestone_top.png" "block_lodestone"
create_imageset "beacon.png" "block_beacon"
create_imageset "conduit.png" "block_conduit"

# Stone variants
create_imageset "smooth_stone.png" "block_smooth_stone"
create_imageset "stone.png" "block_stone"
create_imageset "stone_bricks.png" "block_stone_bricks"
create_imageset "deepslate.png" "block_deepslate"
create_imageset "deepslate_bricks.png" "block_deepslate_bricks"

# Glass
create_imageset "glass.png" "block_glass"
create_imageset "tinted_glass.png" "block_tinted_glass"

# Metal blocks
create_imageset "iron_block.png" "block_iron"
create_imageset "gold_block.png" "block_gold"
create_imageset "diamond_block.png" "block_diamond"
create_imageset "netherite_block.png" "block_netherite"
create_imageset "copper_block.png" "block_copper"

# Decorative
create_imageset "chain.png" "block_chain"

# Nether blocks
create_imageset "magma_block.png" "block_magma"
create_imageset "soul_sand.png" "block_soul_sand"
create_imageset "soul_soil.png" "block_soul_soil"
create_imageset "nether_bricks.png" "block_nether_bricks"
create_imageset "red_nether_bricks.png" "block_red_nether_bricks"
create_imageset "basalt_side.png" "block_basalt"
create_imageset "polished_basalt_side.png" "block_polished_basalt"

# Amethyst
create_imageset "amethyst_block.png" "block_amethyst"
create_imageset "budding_amethyst.png" "block_budding_amethyst"

# Coral
create_imageset "brain_coral_block.png" "block_brain_coral"
create_imageset "tube_coral_block.png" "block_tube_coral"
create_imageset "fire_coral_block.png" "block_fire_coral"

# Terracotta
create_imageset "terracotta.png" "block_terracotta"
create_imageset "cyan_glazed_terracotta.png" "block_cyan_glazed_terracotta"

# Wood planks
create_imageset "oak_planks.png" "block_oak_planks"
create_imageset "dark_oak_planks.png" "block_dark_oak_planks"
create_imageset "spruce_planks.png" "block_spruce_planks"
create_imageset "warped_planks.png" "block_warped_planks"
create_imageset "crimson_planks.png" "block_crimson_planks"

# End blocks
create_imageset "end_stone.png" "block_end_stone"
create_imageset "end_stone_bricks.png" "block_end_stone_bricks"
create_imageset "purpur_block.png" "block_purpur"
create_imageset "purpur_pillar.png" "block_purpur_pillar"

echo ""
echo "================================================"
echo "✅ Done! Downloaded $(ls -1 "$ASSETS_DIR" | grep -c imageset) block images."
echo ""
echo "📱 Now open Xcode and the images should appear in Assets.xcassets/Blocks"
echo "   You may need to close and reopen the project for Xcode to detect them."
