#!/bin/bash

# This script downloads the Noto Color Emoji SVG assets from the official Google Fonts repository
# and prepares them for use in the Xcode project.

REPO_URL="https://github.com/googlefonts/noto-emoji.git"
TEMP_DIR="temp_noto_emoji_svgs"
DEST_DIR="svgs"
ASSET_CATALOG_DIR="EmojiTapper/EmojiTapperMobile/Assets.xcassets"

# Emojis to include (filename without extension)
CLASSIC_EMOJIS=(
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

PENGUIN_BALL_EMOJIS=(
    "emoji_u1f427" # 🐧
    "emoji_u1f436" # 🐶
    "emoji_u1f431" # 🐱
    "emoji_u1f42d" # 🐭
    "emoji_u1f439" # 🐹
    "emoji_u1f430" # 🐰
    "emoji_u1f98a" # 🦊
    "emoji_u1f43b" # 🐻
    "emoji_u1f43c" # 🐼
    "emoji_u1f428" # 🐨
    "emoji_u1f42f" # 🐯
    "emoji_u1f981" # 🦁
    "emoji_u1f42e" # 🐮
    "emoji_u1f437" # 🐷
    "emoji_u1f438" # 🐸
    "emoji_u1f412" # 🐵
    "emoji_u1f648" # 🙈
    "emoji_u1f649" # 🙉
    "emoji_u1f64a" # 🙊
    "emoji_u1f414" # 🐔
    "emoji_u1f426" # 🐦
    "emoji_u1f424" # 🐤
    "emoji_u1f423" # 🐣
    "emoji_u1f425" # 🐥
    "emoji_u1f986" # 🦆
    "emoji_u1f985" # 🦅
    "emoji_u1f989" # 🦉
    "emoji_u1f987" # 🦇
    "emoji_u1f43a" # 🐺
    "emoji_u1f417" # 🐗
    "emoji_u1f434" # 🐴
    "emoji_u1f984" # 🦄
    "emoji_u1f41d" # 🐝
    "emoji_u1f41b" # 🐛
    "emoji_u1f98b" # 🦋
    "emoji_u1f40c" # 🐌
    "emoji_u1f41e" # 🐞
    "emoji_u1f41c" # 🐜
    "emoji_u1f99f" # 🦟
    "emoji_u1f997" # 🦗
    "emoji_u1f577" # 🕷
    "emoji_u1f982" # 🦂
    "emoji_u1f422" # 🐢
    "emoji_u1f40d" # 🐍
    "emoji_u1f98e" # 🦎
    "emoji_u1f996" # 🦖
    "emoji_u1f995" # 🦕
    "emoji_u1f419" # 🐙
    "emoji_u1f991" # 🦑
    "emoji_u1f990" # 🦐
    "emoji_u1f99e" # 🦞
    "emoji_u1f980" # 🦀
    "emoji_u1f421" # 🐡
    "emoji_u1f41f" # 🐠
    "emoji_u1f420" # 🐟
    "emoji_u1f42c" # 🐬
    "emoji_u1f433" # 🐳
    "emoji_u1f40b" # 🐋
    "emoji_u1f988" # 🦈
    "emoji_u1f40a" # 🐊
    "emoji_u1f405" # 🐅
    "emoji_u1f406" # 🐆
    "emoji_u1f993" # 🦓
    "emoji_u1f98d" # 🦍
    "emoji_u1f9a7" # 🦧
    "emoji_u1f418" # 🐘
    "emoji_u1f99b" # 🦛
    "emoji_u1f98f" # 🦏
    "emoji_u1f42a" # 🐪
    "emoji_u1f42b" # 🐫
    "emoji_u1f992" # 🦒
    "emoji_u1f998" # 🦘
    "emoji_u1f403" # 🐃
    "emoji_u1f402" # 🐂
    "emoji_u1f404" # 🐄
    "emoji_u1f40e" # 🐎
    "emoji_u1f416" # 🐖
    "emoji_u1f411" # 🐏
    "emoji_u1f411" # 🐑
    "emoji_u1f999" # 🦙
    "emoji_u1f410" # 🐐
    "emoji_u1f98c" # 🦌
    "emoji_u1f415" # 🐕
    "emoji_u1f429" # 🐩
    "emoji_u1f9ae" # 🦮
    "emoji_u1f415_200d_1f9ba" # 🐕‍🦺
    "emoji_u1f408" # 🐈
    "emoji_u1f408_200d_2b1b" # 🐈‍⬛
    "emoji_u1f413" # 🐓
    "emoji_u1f983" # 🦃
    "emoji_u1f99a" # 🦚
    "emoji_u1f99c" # 🦜
    "emoji_u1f9a2" # 🦢
    "emoji_u1f9a9" # 🦩
    "emoji_u1f54a" # 🕊
    "emoji_u1f407" # 🐇
    "emoji_u1f99d" # 🦝
    "emoji_u1f9a8" # 🦨
    "emoji_u1f9a5" # 🦡
    "emoji_u1f9a6" # 🦦
    "emoji_u1f9ab" # 🦫
    "emoji_u1f43f" # 🐿
    "emoji_u1f994" # 🦔
    "emoji_u1f9a1" # 🦡
    "emoji_u1f435" # 🐵
    "emoji_u1f40f" # 🐏
)

ALL_EMOJIS=("${CLASSIC_EMOJIS[@]}" "${PENGUIN_BALL_EMOJIS[@]}")

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
for emoji_name in "${ALL_EMOJIS[@]}"; do
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
