#!/bin/bash
# Pass 9 live audit: one probe phase, windowed (1152x648 default), fixed 30 fps, its own APPDATA under %TEMP%\p9a.
# usage: run9.sh <phase> <save file or ""> <wall timeout s> [extra args...]
# Never the player's own user folder: APPDATA points at a fresh scratch folder for every run.
S="C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad/p9"
ph="$1"; sv="$2"; to="$3"; shift 3
tag="$ph$(echo "$@" | tr -d ' -')"
A="C:/Users/pmcga/AppData/Local/Temp/p9a/$tag"
rm -rf "$A"; mkdir -p "$A"
O="$S/runs/$tag"
rm -rf "$O"; mkdir -p "$O"
cd /c/Users/pmcga/dev/hollowtide
args=(--phase "$ph" --out "$O")
[ -n "$sv" ] && args+=(--save "$sv")
t0=$(date +%s%3N)
APPDATA="$A" timeout "$to" "C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --path C:/Users/pmcga/dev/hollowtide --fixed-fps 30 --max-fps 30 --audio-driver Dummy --resolution 1152x648 --script "$S/audit9_probe.gd" -- "${args[@]}" "$@" > "$S/runs/out_$tag.txt" 2>&1
rc=$?
t1=$(date +%s%3N)
echo "EXIT $rc $tag wall_ms $((t1 - t0))" | tee -a "$S/runs/exits.txt"
