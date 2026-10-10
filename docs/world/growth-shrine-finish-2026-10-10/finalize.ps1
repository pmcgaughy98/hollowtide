$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-shrine-finish-20261010'
$archiveTarget = 'C:/Users/pmcga/dev/hollowtide/docs/world/growth-shrine-finish-2026-10-10'
if (-not (Test-Path -LiteralPath (Join-Path $archiveTarget 'README.md'))) { throw 'Expected archive missing.' }
foreach ($name in @('README.md','installation.json','audit.py','live_check.py','live_shrine_check.gd','live_shrine_check.log','live_import.log','live_evolution_check.gd','live_evolution_check.log','live_hub_town_check.gd','live_hub_town_check.log','live_hall_door_check.gd','live_hall_door_check.log','install.ps1','finalize.ps1')) {
    Copy-Item -LiteralPath (Join-Path $taskRoot $name) -Destination (Join-Path $archiveTarget $name) -Force
}
Copy-Item -LiteralPath (Join-Path $taskRoot 'review') -Destination $archiveTarget -Recurse -Force
Copy-Item -LiteralPath (Join-Path $taskRoot 'concurrent') -Destination $archiveTarget -Recurse -Force
Write-Output 'Growth Shrine native previews, source provenance and preservation audit archived.'
