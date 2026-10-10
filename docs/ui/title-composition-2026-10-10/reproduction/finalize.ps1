$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-title-composition-20261010'
$archive = 'C:/Users/pmcga/dev/hollowtide/docs/ui/title-composition-2026-10-10'
if (-not (Test-Path -LiteralPath "$archive/README.md")) { throw 'Missing installed handoff' }
foreach ($folder in @('logs','review','reproduction')) {
    Copy-Item -Path "$taskRoot/archive/$folder/*" -Destination "$archive/$folder" -Recurse -Force
}
Copy-Item -LiteralPath "$taskRoot/archive/installation.json" -Destination "$archive/installation.json"
Copy-Item -LiteralPath "$taskRoot/archive/README.md" -Destination "$archive/README.md"
Write-Output 'Archived installed title checks, previews and preservation audit.'
