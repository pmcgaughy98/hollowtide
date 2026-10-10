$ErrorActionPreference = 'Stop'
$crewWork = 'D:/dev/hollowtide-crew-dungeon-selout-20261010'
$crewLive = 'C:/Users/pmcga/dev/hollowtide'
$crewArchive = "$crewLive/docs/art/crew-dungeon-selout-2026-10-10"
$crewManifest = Get-Content -Raw -LiteralPath "$crewWork/pending-install.json" | ConvertFrom-Json
foreach ($crewFile in $crewManifest) {
    $crewTarget = Join-Path $crewLive $crewFile.path
    if ($null -eq $crewFile.expected) { if (Test-Path -LiteralPath $crewTarget) { throw "New target now exists: $crewTarget" } }
    else { if ((Get-FileHash -LiteralPath $crewTarget -Algorithm SHA256).Hash.ToLower() -ne $crewFile.expected) { throw "Live changed: $crewTarget" } }
}
if (Test-Path -LiteralPath $crewArchive) { throw 'Versioned archive already exists.' }
New-Item -ItemType Directory -Path $crewArchive | Out-Null
Get-ChildItem -LiteralPath "$crewWork/archive" -Recurse -File | ForEach-Object {
    $crewRelative = $_.FullName.Substring((Resolve-Path -LiteralPath "$crewWork/archive").Path.Length + 1)
    $crewDestination = Join-Path $crewArchive $crewRelative
    New-Item -ItemType Directory -Path (Split-Path -Parent $crewDestination) -Force | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $crewDestination
}
foreach ($crewFile in $crewManifest) {
    $crewTarget = Join-Path $crewLive $crewFile.path
    New-Item -ItemType Directory -Path (Split-Path -Parent $crewTarget) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path "$crewWork/candidate" $crewFile.path) -Destination $crewTarget
    if ((Get-FileHash -LiteralPath $crewTarget -Algorithm SHA256).Hash.ToLower() -ne $crewFile.candidate) { throw "Copy mismatch: $crewTarget" }
}
Write-Output "Installed $($crewManifest.Count) guarded files; originals and native review archived first."
