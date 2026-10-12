# The long headless checks, one after another, each logged (Claude, 2026-10-12). Run from the project folder:
#   & .\tools\debug\run_long_checks.ps1
# The pilot chain plays the whole pilot on autopilot (ten minutes or more); the town loop clears a dungeon first.
$godot = "C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"
$out = "docs\design\faint-2026-10-12"
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($check in @("town_loop_check", "pilot_chain_check")) {
    Write-Host "== $check started $(Get-Date -Format HH:mm:ss)"
    & $godot --headless --path . --script "res://tools/debug/$check.gd" 2>$null | Out-File -Encoding utf8 "$out\$check.log"
    Write-Host "== $check exit $LASTEXITCODE at $(Get-Date -Format HH:mm:ss)"
    Select-String -Path "$out\$check.log" -Pattern "-> ok|-> FAIL|FAILED|all ok|^After|^Then|^Second|WRONG|SCRIPT ERROR|Faints" | ForEach-Object { $_.Line }
}
Write-Host "== done"
