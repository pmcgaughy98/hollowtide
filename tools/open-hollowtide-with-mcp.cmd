@echo off
setlocal
set "PATH=C:\Users\pmcga\Documents\Codex\2026-09-24\wh\godot-mcp-install\uv-x86_64-pc-windows-msvc;%PATH%"
set "GODOT_AI_DISABLE_TELEMETRY=true"
start "" "C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" --editor --path "%~dp0.."
endlocal
