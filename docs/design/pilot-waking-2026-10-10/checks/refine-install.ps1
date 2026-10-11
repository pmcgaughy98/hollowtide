$ErrorActionPreference = 'Stop'
$plan = Get-Content -LiteralPath 'D:/dev/hollowtide-pilot-waking-20261010/refine-pending.json' -Raw | ConvertFrom-Json
foreach ($row in $plan) {
    if ((Get-FileHash -LiteralPath $row.source -Algorithm SHA256).Hash.ToLower() -ne $row.after) { throw 'Candidate changed' }
    if ((Get-FileHash -LiteralPath $row.target -Algorithm SHA256).Hash.ToLower() -ne $row.before) { throw 'Concurrent edit' }
}
foreach ($row in $plan) {
    if ((Get-FileHash -LiteralPath $row.target -Algorithm SHA256).Hash.ToLower() -ne $row.before) { throw 'Concurrent pre-write edit' }
    Copy-Item -LiteralPath $row.source -Destination $row.target
    if ((Get-FileHash -LiteralPath $row.target -Algorithm SHA256).Hash.ToLower() -ne $row.after) { throw 'Install mismatch' }
}
Write-Output 'Refined Back label and handoff count; original backups preserved.'
