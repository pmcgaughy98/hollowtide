$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-town-finish-20261010'
$archiveTarget = 'C:/Users/pmcga/dev/hollowtide/docs/world/town-finish-2026-10-10'
if (-not (Test-Path -LiteralPath (Join-Path $archiveTarget 'README.md'))) { throw 'Expected archive missing.' }
foreach ($name in @('README.md','installation.json','audit.py','live_check.py','live_finish_check.gd','live_finish_check.log','live_hub_town_check.gd','live_hub_town_check.log','live_hall_door_check.gd','live_hall_door_check.log','install.ps1','finalize.ps1')) {
    Copy-Item -LiteralPath (Join-Path $taskRoot $name) -Destination (Join-Path $archiveTarget $name) -Force
}
Copy-Item -LiteralPath (Join-Path $taskRoot 'review') -Destination $archiveTarget -Recurse -Force
Write-Output 'Final native captures and preservation audit archived.'
