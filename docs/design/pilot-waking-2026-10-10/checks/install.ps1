$ErrorActionPreference = 'Stop'
$plan = Get-Content -LiteralPath 'D:/dev/hollowtide-pilot-waking-20261010/pending.json' -Raw | ConvertFrom-Json
foreach ($row in $plan) {
    if ((Get-FileHash -LiteralPath $row.source -Algorithm SHA256).Hash.ToLower() -ne $row.after) { throw "Candidate changed: $($row.path)" }
    if ($null -ne $row.before) {
        if ((Get-FileHash -LiteralPath $row.target -Algorithm SHA256).Hash.ToLower() -ne $row.before) { throw "Concurrent edit: $($row.path)" }
    } elseif (Test-Path -LiteralPath $row.target) { throw "Concurrent new file: $($row.path)" }
    if (Test-Path -LiteralPath $row.archive) { throw "Original backup already exists: $($row.path)" }
}
foreach ($row in $plan) {
    if ($null -ne $row.before) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $row.archive) -Force | Out-Null
        Copy-Item -LiteralPath $row.target -Destination $row.archive
        if ((Get-FileHash -LiteralPath $row.archive -Algorithm SHA256).Hash.ToLower() -ne $row.before) { throw 'Backup mismatch' }
    }
    if ($null -ne $row.before -and (Get-FileHash -LiteralPath $row.target -Algorithm SHA256).Hash.ToLower() -ne $row.before) { throw "Concurrent pre-write edit: $($row.path)" }
    Copy-Item -LiteralPath $row.source -Destination $row.target
    if ((Get-FileHash -LiteralPath $row.target -Algorithm SHA256).Hash.ToLower() -ne $row.after) { throw 'Install mismatch' }
    Write-Output "Installed $($row.path)"
}
