$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-selout-scroll-20261010'
$archiveTarget = 'C:/Users/pmcga/dev/hollowtide/docs/world/selout-scroll-2026-10-10'
if (-not (Test-Path -LiteralPath (Join-Path $archiveTarget 'README.md'))) { throw 'Expected archive missing.' }
foreach ($name in @('README.md','installation.json','audit.py','live_check.py','live_selout_check.gd','live_selout_check.log','live_scroll_check.gd','live_scroll_check.log','live_shrine_check.gd','live_shrine_check.log','live_import.log','live_evolution_check.gd','live_evolution_check.log','live_hub_town_check.gd','live_hub_town_check.log','live_hall_door_check.gd','live_hall_door_check.log','install.ps1','finalize.ps1')) {
    Copy-Item -LiteralPath (Join-Path $taskRoot $name) -Destination (Join-Path $archiveTarget $name) -Force
}
Copy-Item -LiteralPath (Join-Path $taskRoot 'review') -Destination $archiveTarget -Recurse -Force
Copy-Item -LiteralPath (Join-Path $taskRoot 'concurrent') -Destination $archiveTarget -Recurse -Force
Copy-Item -LiteralPath (Join-Path $taskRoot 'accepted-post-preinstall.json') -Destination $archiveTarget -Force
Copy-Item -LiteralPath (Join-Path $taskRoot 'retain_concurrent.py') -Destination $archiveTarget -Force
Write-Output 'Shared sel-out / Scroll Keeper native previews, logs and preservation audit archived.'
