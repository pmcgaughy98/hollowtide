$ErrorActionPreference='Stop'
$taskRoot='D:/dev/hollowtide-new-scene-selout-20261010'
$liveProject='C:/Users/pmcga/dev/hollowtide'
$items=Get-Content -LiteralPath "$taskRoot/border-fix.json" -Raw | ConvertFrom-Json
foreach($item in $items) {
 $target=Join-Path $liveProject $item.path
 if((Get-FileHash -LiteralPath $target).Hash.ToLower() -ne $item.before){throw "Concurrent change $($item.path)"}
 if((Get-FileHash -LiteralPath (Join-Path "$taskRoot/candidate" $item.path)).Hash.ToLower() -ne $item.after){throw "Candidate changed $($item.path)"}
}
foreach($item in $items) {
 $target=Join-Path $liveProject $item.path
 if((Get-FileHash -LiteralPath $target).Hash.ToLower() -ne $item.before){throw "Concurrent change before write $($item.path)"}
 Copy-Item -LiteralPath (Join-Path "$taskRoot/candidate" $item.path) -Destination $target
}
Write-Output 'Installed guarded portrait-window clipping and updated handoff note.'
