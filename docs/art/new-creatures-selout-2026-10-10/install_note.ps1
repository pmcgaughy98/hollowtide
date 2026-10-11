$ErrorActionPreference='Stop'
$taskRoot='D:/dev/hollowtide-wilds-selout-20261010'
$item=Get-Content -LiteralPath "$taskRoot/note-update.json" -Raw | ConvertFrom-Json
$target=Join-Path 'C:/Users/pmcga/dev/hollowtide' $item.path
$source=Join-Path "$taskRoot/candidate" $item.path
if((Get-FileHash -LiteralPath $target).Hash.ToLower() -ne $item.before){throw 'Concurrent collaboration note changed.'}
if((Get-FileHash -LiteralPath $source).Hash.ToLower() -ne $item.after){throw 'Staged note changed.'}
Copy-Item -LiteralPath $source -Destination $target
Write-Output 'Saved final verification note; earlier collaboration body retained.'
