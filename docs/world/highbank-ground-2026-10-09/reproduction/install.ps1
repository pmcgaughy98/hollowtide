$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-highbank-ground-20261009'
$liveRoot = 'C:/Users/pmcga/dev/hollowtide'
$pending = Get-Content -LiteralPath "$taskRoot/pending-install.json" -Raw | ConvertFrom-Json
foreach ($item in $pending) {
    $target = Join-Path $liveRoot $item.path
    if ($null -eq $item.before) {
        if (Test-Path -LiteralPath $target) { throw "Concurrent new file: $target" }
    } elseif ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower() -ne $item.before) {
        throw "Concurrent file edit: $target"
    }
}
$archive = Join-Path $liveRoot 'docs/world/highbank-ground-2026-10-09'
if (Test-Path -LiteralPath $archive) { throw 'Archive already exists; do not overwrite it' }
Copy-Item -LiteralPath "$taskRoot/archive" -Destination $archive -Recurse
foreach ($item in $pending) {
    $target = Join-Path $liveRoot $item.path
    if ($null -ne $item.before -and (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower() -ne $item.before) {
        throw "File changed immediately before write: $target"
    }
    [System.IO.File]::WriteAllBytes($target, [System.IO.File]::ReadAllBytes($item.source))
}
Write-Output 'Installed reviewed Highbank ground painter and preserved original controller/notes.'
