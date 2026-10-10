$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-menu-hookup-20261009'
$archive = 'C:/Users/pmcga/dev/hollowtide/docs/design/menu-hookup-2026-10-09'
if (-not (Test-Path -LiteralPath "$archive/.gdignore")) { throw 'Expected installed archive missing' }
foreach ($name in @('menu_check','quit_title','quit_pause','town_loop_check','music_check')) {
    Copy-Item -LiteralPath "$taskRoot/live_$name.log" -Destination "$archive/logs/live_$name.log"
}
Copy-Item -LiteralPath "$taskRoot/installation.json" -Destination "$archive/installation.json"
Copy-Item -LiteralPath "$taskRoot/review/menu-checks.json" -Destination "$archive/review/menu-checks.json"
Get-ChildItem -LiteralPath "$taskRoot/review" -Filter '*.png' -File | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path "$archive/review" $_.Name) }
Copy-Item -LiteralPath "$taskRoot/audit.py" -Destination "$archive/reproduction/audit.py"
Copy-Item -LiteralPath "$taskRoot/finalize.ps1" -Destination "$archive/reproduction/finalize.ps1"
Write-Output 'Archived live native verification, previews and preservation manifest.'
