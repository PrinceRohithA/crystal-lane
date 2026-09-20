#!/usr/bin/env bash
# Pull the approved CC0 packs into assets/. Safe to re-run.
# Packs: Kenney 1-Bit, MELLE crystals, Kenney Shape Characters, Kenney UI Pack.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${TMPDIR:-/tmp}/crystal-lane-cc0-$$"
mkdir -p "$WORK"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

download() {
  local url="$1" dest="$2"
  echo "GET $url"
  curl -L --fail --retry 4 --retry-delay 2 -o "$dest" "$url"
}

echo "Downloading CC0 packs into $WORK"

download "https://kenney.nl/media/pages/assets/1-bit-pack/aa867a1f37-1677578516/kenney_1-bit-pack.zip" \
  "$WORK/kenney_1-bit-pack.zip"
download "https://kenney.nl/media/pages/assets/shape-characters/c016420b08-1698339465/kenney_shape-characters.zip" \
  "$WORK/kenney_shape-characters.zip"
download "https://kenney.nl/media/pages/assets/ui-pack/f651646eab-1718203990/kenney_ui-pack.zip" \
  "$WORK/kenney_ui-pack.zip"
download "https://opengameart.org/sites/default/files/crystal%20blue.png" "$WORK/crystal_blue.png"
download "https://opengameart.org/sites/default/files/crystal%20red.png" "$WORK/crystal_red.png"

mkdir -p "$WORK/1bit" "$WORK/shapes" "$WORK/ui"
unzip -q -o "$WORK/kenney_1-bit-pack.zip" -d "$WORK/1bit"
unzip -q -o "$WORK/kenney_shape-characters.zip" -d "$WORK/shapes"
unzip -q -o "$WORK/kenney_ui-pack.zip" -d "$WORK/ui"

ENV="$ROOT/assets/env"
CRY="$ROOT/assets/crystals"
UNI="$ROOT/assets/units"
UIP="$ROOT/assets/ui"
LIC="$ROOT/assets/licenses"
mkdir -p "$ENV" "$CRY" "$UNI" "$UIP" "$LIC"

cp "$WORK/1bit/Tilesheet/colored-transparent_packed.png" "$ENV/kenney_1bit_colored_packed.png"
cp "$WORK/1bit/Tilesheet/monochrome-transparent_packed.png" "$ENV/kenney_1bit_monochrome_packed.png"
cp "$WORK/1bit/Tilesheet.txt" "$ENV/Tilesheet.txt"
cp "$WORK/1bit/License.txt" "$LIC/kenney_1-bit-pack_License.txt"

cp "$WORK/crystal_blue.png" "$CRY/crystal_blue.png"
cp "$WORK/crystal_red.png" "$CRY/crystal_red.png"

SRC="$WORK/shapes/PNG/Default"
for color in blue red; do
  for shape in square rhombus circle squircle; do
    cp "$SRC/${color}_body_${shape}.png" "$UNI/${color}_body_${shape}.png"
  done
  for hand in closed rock open peace point thumb; do
    cp "$SRC/${color}_hand_${hand}.png" "$UNI/${color}_hand_${hand}.png"
  done
done
for face in a b c d e f g h i j k l; do
  cp "$SRC/face_${face}.png" "$UNI/face_${face}.png"
done
cp "$SRC/shadow.png" "$UNI/shadow.png"
cp "$SRC/tile_coin.png" "$UNI/tile_coin.png"
cp "$WORK/shapes/License.txt" "$LIC/kenney_shape-characters_License.txt"

UI_PNG="$WORK/ui/PNG"
for color in Blue Green Yellow Red Grey; do
  lc="$(echo "$color" | tr 'A-Z' 'a-z')"
  cp "$UI_PNG/$color/Default/button_rectangle_depth_gloss.png" "$UIP/${lc}_button_gloss.png"
  cp "$UI_PNG/$color/Default/button_rectangle_depth_flat.png" "$UIP/${lc}_button_flat.png"
  cp "$UI_PNG/$color/Default/button_rectangle_depth_gradient.png" "$UIP/${lc}_button_gradient.png"
  cp "$UI_PNG/$color/Default/slide_horizontal_color.png" "$UIP/${lc}_bar.png"
  cp "$UI_PNG/$color/Default/slide_horizontal_grey.png" "$UIP/${lc}_bar_under.png"
  cp "$UI_PNG/$color/Default/slide_horizontal_color_section_wide.png" "$UIP/${lc}_bar_fill.png"
  cp "$UI_PNG/$color/Default/button_round_depth_gloss.png" "$UIP/${lc}_round.png"
done
cp "$UI_PNG/Yellow/Default/star.png" "$UIP/star_gold.png"
cp "$UI_PNG/Extra/Default/input_rectangle.png" "$UIP/panel.png"
cp "$UI_PNG/Extra/Default/input_outline_rectangle.png" "$UIP/panel_outline.png"
cp "$WORK/ui/Font/Kenney Future Narrow.ttf" "$UIP/KenneyFutureNarrow.ttf"
cp "$WORK/ui/Font/Kenney Future.ttf" "$UIP/KenneyFuture.ttf"
cp "$WORK/ui/License.txt" "$LIC/kenney_ui-pack_License.txt"

echo "Updated $ROOT/assets (CC0 Kenney + MELLE only)."
echo "See assets/ATTRIBUTION.md"
