$ErrorActionPreference = 'Stop'
$taskRoot = 'D:/dev/hollowtide-hall-door-20261010'
$liveRoot = 'C:/Users/pmcga/dev/hollowtide'
$pending = Get-Content -LiteralPath "$taskRoot/pending-install.json" -Raw | ConvertFrom-Json
foreach ($item in $pending) {
    $target = Join-Path $liveRoot $item.path
    if ($null -eq $item.before) {
        if (Test-Path -LiteralPath $target) { throw "Concurrent new file: $target" }
    } elseif ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower() -ne $item.before) { throw "Concurrent edit: $target" }
}
$archive = Join-Path $liveRoot 'docs/world/hall-door-2026-10-10'
if (Test-Path -LiteralPath $archive) { throw 'Archive exists; preserve it' }
Copy-Item -LiteralPath "$taskRoot/archive" -Destination $archive -Recurse
foreach ($item in $pending) {
    $target = Join-Path $liveRoot $item.path
    if ($null -ne $item.before -and (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower() -ne $item.before) { throw "Changed before write: $target" }
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($target)) | Out-Null
    [System.IO.File]::WriteAllBytes($target,[System.IO.File]::ReadAllBytes($item.source))
}
Write-Output 'Installed coherent Hall, bounded ground/menu changes, launch scene and preserved originals.'
