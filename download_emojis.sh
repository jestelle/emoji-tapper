#!/bin/bash

# This script downloads the Noto Color Emoji SVG assets from the official Google Fonts repository
# and prepares them for use in the Xcode project.

REPO_URL="https://github.com/googlefonts/noto-emoji.git"
TEMP_DIR="temp_noto_emoji_svgs"
DEST_DIR="svgs"
ASSET_CATALOG_DIR="EmojiTapper/EmojiTapperMobile/Assets.xcassets"

# Emojis to include (filename without extension)
EMOJIS_TO_INCLUDE=(
    "emoji_u1f600" # 😀
    "emoji_u1f60a" # 😊
    "emoji_u1f602" # 😂
    "emoji_u1f970" # 🥰
    "emoji_u1f60e" # 😎
    "emoji_u1f914" # 🤔
    "emoji_u1f62e" # 😮
    "emoji_u1f60b" # 😋
    "emoji_u1f642" # 🙂
    "emoji_u1f606" # 😆
    "emoji_u1f60d" # 😍
    "emoji_u1f917" # 🤗
    "emoji_u1f634" # 😴
    "emoji_u1f92f" # 🤯
    "emoji_u1f607" # 😇
    "emoji_u1f480" # 💀
    "emoji_u23f3"  # ⏳
    "emoji_u1f352" # 🍒
)

# 1. Clean up previous assets
echo "Cleaning up previous assets..."
rm -rf "$DEST_DIR"
# Find all .imageset directories in the asset catalog and remove them
find "$ASSET_CATALOG_DIR" -type d -name "*.imageset" -exec rm -r {} +

# 2. Clone the repository into a temporary directory
echo "Cloning Noto Emoji repository..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR"

# 3. Create the destination directories if they don't exist
mkdir -p "$DEST_DIR"
mkdir -p "$ASSET_CATALOG_DIR"

# 4. Copy the specified SVG files and create imagesets
echo "Copying specified SVG files and creating imagesets..."
for emoji_name in "${EMOJIS_TO_INCLUDE[@]}"; do
  svg_file="$TEMP_DIR/svg/${emoji_name}.svg"
  if [ -f "$svg_file" ]; then
    # Copy to the svgs directory
    cp "$svg_file" "$DEST_DIR"/

    # Create imageset in the asset catalog
    filename=$(basename "$svg_file")
    imageset_name="${filename%.*}.imageset"
    imageset_path="$ASSET_CATALOG_DIR/$imageset_name"
    mkdir -p "$imageset_path"

    # Copy the svg file to the imageset
    cp "$svg_file" "$imageset_path"/

    # Create Contents.json
    cat > "$imageset_path/Contents.json" << EOL
{
  "images" : [
    {
      "filename" : "$filename",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}
EOL
  else
    echo "Warning: SVG for ${emoji_name} not found in repository."
  fi
done

# 5. Clean up the temporary directory
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done! Specified SVGs are in the '$DEST_DIR' directory and added to the asset catalog."
