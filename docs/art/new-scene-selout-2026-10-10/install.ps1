$ErrorActionPreference='Stop'
$liveProject='C:/Users/pmcga/dev/hollowtide'
$taskRoot='D:/dev/hollowtide-new-scene-selout-20261010'
$archiveTarget=Join-Path $liveProject 'docs/art/new-scene-selout-2026-10-10'
$pending=Get-Content -LiteralPath (Join-Path $taskRoot 'pending-install.json') -Raw | ConvertFrom-Json
foreach($item in $pending) {
 $target=Join-Path $liveProject $item.path
 $actual=if(Test-Path -LiteralPath $target){(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower()}else{$null}
 if($actual -ne $item.before){throw "Concurrent file changed: $($item.path)"}
 $candidate=Join-Path (Join-Path $taskRoot 'candidate') $item.path
 if((Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash.ToLower() -ne $item.after){throw "Candidate changed: $($item.path)"}
}
if(Test-Path -LiteralPath $archiveTarget){throw 'Versioned archive already exists; do not overwrite.'}
New-Item -ItemType Directory -Path $archiveTarget | Out-Null
# Copy only exact archive children; no wildcard operations against the live project.
foreach($child in Get-ChildItem -LiteralPath (Join-Path $taskRoot 'archive')) {
 Copy-Item -LiteralPath $child.FullName -Destination $archiveTarget -Recurse
}
foreach($item in $pending) {
 $target=Join-Path $liveProject $item.path
 $actual=if(Test-Path -LiteralPath $target){(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower()}else{$null}
 if($actual -ne $item.before){throw "Concurrent file changed before writing: $($item.path)"}
 New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
 Copy-Item -LiteralPath (Join-Path (Join-Path $taskRoot 'candidate') $item.path) -Destination $target
}
Write-Output "Installed $($pending.Count) guarded files and archived originals/native proof."
