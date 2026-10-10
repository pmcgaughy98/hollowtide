$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-storage-finish-20261010'
$archiveTarget = 'C:/Users/pmcga/dev/hollowtide/docs/world/storage-finish-2026-10-10'
if (-not (Test-Path -LiteralPath (Join-Path $archiveTarget 'README.md'))) { throw 'Expected archive missing.' }
foreach ($name in @('README.md','installation.json','archive-verification.json','inspect_concurrent.py','audit.py','live_check.py','live_storage_check.gd','live_storage_check.log','live_storage_check_initial.log','live_import.log','live_hub_town_check.gd','live_hub_town_check.log','live_hall_door_check.gd','live_hall_door_check.log','install.ps1','finalize.ps1')) {
    Copy-Item -LiteralPath (Join-Path $taskRoot $name) -Destination (Join-Path $archiveTarget $name) -Force
}
Copy-Item -LiteralPath (Join-Path $taskRoot 'review') -Destination $archiveTarget -Recurse -Force
Write-Output 'Final Storage previews, provenance and preservation audit archived.'
