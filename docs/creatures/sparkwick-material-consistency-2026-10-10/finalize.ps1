$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-sparkwick-20261010'
$archiveSource = Join-Path $taskRoot 'archive'
$archiveTarget = 'C:/Users/pmcga/dev/hollowtide/docs/creatures/sparkwick-material-consistency-2026-10-10'
Copy-Item -LiteralPath (Join-Path $taskRoot 'review') -Destination $archiveSource -Recurse -Force
foreach ($item in Get-ChildItem -LiteralPath $taskRoot -File) {
    if ($item.Extension -in '.md','.gd','.py','.ps1','.json','.log') {
        Copy-Item -LiteralPath $item.FullName -Destination (Join-Path $archiveSource $item.Name) -Force
    }
}
foreach ($item in Get-ChildItem -LiteralPath $archiveSource) {
    Copy-Item -LiteralPath $item.FullName -Destination $archiveTarget -Recurse -Force
}
Write-Output 'Published installed native evidence and exact asset preservation audit.'
