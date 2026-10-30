#!/bin/bash
# Pass 9 dungeon lane: run one probe script windowed (1152x648), fixed 30 fps, with its own APPDATA under the session
# scratchpad, so Preston's user folder is never touched. Output goes to <scratch>/runs/<tag>.txt.
# usage: run_win.sh <tag> <res:// script> <wall timeout s> [args after --...]
S="C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad/p9d"
tag="$1"; scr="$2"; to="$3"; shift 3
A="$S/appdata/$tag"
rm -rf "$A"; mkdir -p "$A" "$S/runs"
cd /c/Users/pmcga/dev/hollowtide
APPDATA="$A" XDG_DATA_HOME="$A" timeout "$to" "C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" \
	--path C:/Users/pmcga/dev/hollowtide --fixed-fps 30 --max-fps 30 --resolution 1152x648 --script "$scr" -- "$@" > "$S/runs/$tag.txt" 2>&1
echo "EXIT $? $tag"
