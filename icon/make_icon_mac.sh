#!/usr/bin/env bash

BASE_ICON="icon_base.png" # Base icon is 1024x1024
ICONSET_FOLDER="icon.iconset"

mkdir -p "$ICONSET_FOLDER"

sizes=(
  "16 icon_16x16.png"
  "32 icon_16x16@2x.png"
  "32 icon_32x32.png"
  "64 icon_32x32@2x.png"
  "128 icon_128x128.png"
  "256 icon_128x128@2x.png"
  "256 icon_256x256.png"
  "512 icon_256x256@2x.png"
  "512 icon_512x512.png"
)

for entry in "${sizes[@]}"; do
  size=$(echo $entry | cut -d' ' -f1)
  file=$(echo $entry | cut -d' ' -f2)

  sips -z $size $size "$BASE_ICON" --out "$ICONSET_FOLDER/$file" >/dev/null
done

cp "$BASE_ICON" "$ICONSET_FOLDER/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_FOLDER"

rm -r "$ICONSET_FOLDER"
