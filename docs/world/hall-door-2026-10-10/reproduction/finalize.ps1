$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-hall-door-20261010'
$archive = 'C:/Users/pmcga/dev/hollowtide/docs/world/hall-door-2026-10-10'
if (-not (Test-Path -LiteralPath "$archive/README.md")) { throw 'Missing installed handoff' }
foreach ($folder in @('logs','review','reproduction')) {
    Copy-Item -Path "$taskRoot/archive/$folder/*" -Destination "$archive/$folder" -Recurse -Force
}
Copy-Item -LiteralPath "$taskRoot/archive/installation.json" -Destination "$archive/installation.json"
Write-Output 'Archived installed native checks and preservation audit.'
