#!/bin/bash
# Pass 9 dungeon lane: one live-play probe phase (the pass 9 audit's audit9_probe.gd, which extends
# tools/debug/live_play_probe.gd), windowed 1152x648, its own APPDATA under the session scratchpad, as the audit's
# run9.sh did. Luminance logging is on unless --nolum is passed. Output: <scratch>/runs/<tag>/ (log.txt, lum.tsv, shots/).
# usage: run_probe.sh <tag> <phase> <save file or ""> <wall timeout s> [extra probe args...]
S="C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad/p9d"
PROBE="C:/Users/pmcga/dev/hollowtide/docs/team/sweep-2026-10-20/pass9-audit/method/audit9_probe.gd"
tag="$1"; ph="$2"; sv="$3"; to="$4"; shift 4
A="$S/appdata/$tag"
O="$S/runs/$tag"
rm -rf "$A" "$O"; mkdir -p "$A" "$O"
cd /c/Users/pmcga/dev/hollowtide
args=(--phase "$ph" --out "$O")
[ -n "$sv" ] && args+=(--save "$sv")
APPDATA="$A" XDG_DATA_HOME="$A" timeout "$to" "C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" \
	--path C:/Users/pmcga/dev/hollowtide --fixed-fps 30 --max-fps 30 --audio-driver Dummy --resolution 1152x648 \
	--script "$PROBE" -- "${args[@]}" "$@" > "$S/runs/out_$tag.txt" 2>&1
echo "EXIT $? $tag"
