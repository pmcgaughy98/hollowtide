#!/bin/bash
# Pass 9 rooms lane: one probe phase, windowed 1152x648, fixed 30 fps, its own APPDATA under %TEMP%\p9r (never Preston's).
# usage: run.sh <phase> <save file or ""> <wall timeout s> <tag> [extra args...]
S="C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad/p9rooms"
ph="$1"; sv="$2"; to="$3"; tag="$4"; shift 4
A="C:/Users/pmcga/AppData/Local/Temp/p9r/$tag"
rm -rf "$A"; mkdir -p "$A"
O="$S/runs/$tag"
rm -rf "$O"; mkdir -p "$O/shots"
cd /c/Users/pmcga/dev/hollowtide
args=(--phase "$ph" --out "$O/")
[ -n "$sv" ] && args+=(--save "$sv")
t0=$(date +%s%3N)
APPDATA="$A" timeout "$to" "C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --path C:/Users/pmcga/dev/hollowtide --fixed-fps 30 --max-fps 30 --audio-driver Dummy --resolution 1152x648 --script "${PROBE:-$S/rooms9_probe.gd}" -- "${args[@]}" "$@" > "$S/runs/out_$tag.txt" 2>&1
rc=$?
t1=$(date +%s%3N)
echo "EXIT $rc $tag wall_ms $((t1 - t0))" | tee -a "$S/runs/exits.txt"
