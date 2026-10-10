$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-sparkwick-20261010'
$liveRoot = 'C:/Users/pmcga/dev/hollowtide'
$archiveTarget = Join-Path $liveRoot 'docs/creatures/sparkwick-material-consistency-2026-10-10'
$manifest = Get-Content -LiteralPath (Join-Path $taskRoot 'pending-install.json') -Raw | ConvertFrom-Json
foreach ($item in $manifest) {
    $target = Join-Path $liveRoot $item.path
    if ($null -eq $item.before) { if (Test-Path -LiteralPath $target) { throw "New target exists: $target" } }
    else { if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower() -ne $item.before) { throw "Concurrent edit: $target" } }
    if ((Get-FileHash -LiteralPath $item.source -Algorithm SHA256).Hash.ToLower() -ne $item.after) { throw "Candidate changed: $target" }
}
if (Test-Path -LiteralPath $archiveTarget) { throw 'Archive exists; preserve it.' }
Copy-Item -LiteralPath (Join-Path $taskRoot 'archive') -Destination $archiveTarget -Recurse
foreach ($item in $manifest) {
    $target = Join-Path $liveRoot $item.path
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    [System.IO.File]::WriteAllBytes($target, [System.IO.File]::ReadAllBytes($item.source))
}
Write-Output 'Installed Sparkwick-only presentation palette; originals archived first.'
