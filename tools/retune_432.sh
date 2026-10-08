#!/usr/bin/env bash
# Retune the music from A=440 to A=432 Hz (Preston, 2026-10-06), keeping each track's speed.
# 432/440 = 0.981818: about a third of a semitone lower. Originals are kept in
# docs/audio/music-440-originals-2026-10-06/; running this again starts from those
# originals, so it never lowers a track twice.
#   bash tools/retune_432.sh
set -e
cd "$(dirname "$0")/.."
SRC=docs/audio/music-440-originals-2026-10-06
mkdir -p "$SRC"
for f in assets/audio/music/*.mp3 assets/audio/music/*.wav; do
  name=$(basename "$f")
  [ -f "$SRC/$name" ] || cp "$f" "$SRC/$name"
  case "$name" in
    *.mp3) ffmpeg -v error -y -i "$SRC/$name" -af "rubberband=pitch=0.981818:pitchq=quality" -b:a 192k "$f" ;;
    *.wav) ffmpeg -v error -y -i "$SRC/$name" -af "rubberband=pitch=0.981818:pitchq=quality" "$f" ;;
  esac
  echo "retuned $name"
done
