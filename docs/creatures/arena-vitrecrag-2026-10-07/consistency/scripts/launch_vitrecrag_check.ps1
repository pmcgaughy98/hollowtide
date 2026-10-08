<#
Run one requested arena check in a hidden, owned Godot process. This is a review helper,
not game code. Import is bounded to 55 seconds; runtime to 125 seconds, using waits
of at most 55 seconds so the calling agent can communicate during execution.
Before runtime, preserve all existing user://arena_captures files in this unique run folder.
Usage: powershell -NoProfile -File launch_vitrecrag_check.ps1 -Mode import
       powershell -NoProfile -File launch_vitrecrag_check.ps1 -Mode runtime
Nothing is deleted except terminating this helper's own child if it exceeds its deadline.
#>
param([Parameter(Mandatory=$true)][ValidateSet('import','runtime')][string]$Mode)
$ErrorActionPreference = 'Stop'
$taskProject = 'C:\Users\pmcga\dev\hollowtide'
$taskEngine = 'C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe'
$taskReviewRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$taskStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$taskTag = [Guid]::NewGuid().ToString('N').Substring(0,8)
$taskRun = Join-Path $taskReviewRoot ('runs\' + $Mode + '_' + $taskStamp + '_' + $taskTag)
New-Item -ItemType Directory -Path $taskRun -Force | Out-Null
$taskCaptureRoot = Join-Path $taskProject 'docs\creatures\arena-vitrecrag-2026-10-07'
$taskStdout = Join-Path $taskRun 'stdout.log'
$taskStderr = Join-Path $taskRun 'stderr.log'
$taskExpected = @('line_stage1.png','line_stage2.png','line_stage3.png','glass_1.80s.png','glass_2.30s.png','glass_2.70s.png','glass_3.10s.png','match.png')
function Get-CaptureManifest([string]$Root) {
    $taskRows = @()
    if (Test-Path -LiteralPath $Root) {
        foreach ($taskFile in Get-ChildItem -LiteralPath $Root -File -Filter *.png) {
            $taskRelative = $taskFile.FullName.Substring($Root.Length).TrimStart([char]92,[char]47)
            $taskRows += [ordered]@{relative=$taskRelative;length=$taskFile.Length;sha256=(Get-FileHash -LiteralPath $taskFile.FullName -Algorithm SHA256).Hash.ToLower();lastWriteUtc=$taskFile.LastWriteTimeUtc.ToString('o')}
        }
    }
    return $taskRows
}
$taskBefore = @(Get-CaptureManifest $taskCaptureRoot)
$taskBefore | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $taskRun 'captures-before.json') -Encoding utf8
if ($Mode -eq 'runtime') {
    $taskBackup = Join-Path $taskRun 'captures-originals'
    New-Item -ItemType Directory -Path $taskBackup -Force | Out-Null
    foreach ($taskRow in $taskBefore) {
        $taskSource = Join-Path $taskCaptureRoot $taskRow.relative
        $taskDestination = Join-Path $taskBackup $taskRow.relative
        New-Item -ItemType Directory -Path (Split-Path -Parent $taskDestination) -Force | Out-Null
        Copy-Item -LiteralPath $taskSource -Destination $taskDestination
        if ((Get-FileHash -LiteralPath $taskDestination -Algorithm SHA256).Hash.ToLower() -ne $taskRow.sha256) { throw 'Existing capture backup hash mismatch; launch aborted.' }
    }
}
if ($Mode -eq 'import') { $taskArguments = '--headless --path "' + $taskProject + '" --import' }
else { $taskArguments = '--path "' + $taskProject + '" --fixed-fps 30 --script res://tools/debug/arena_vitrecrag_check.gd' }
$taskStartedUtc = [DateTime]::UtcNow.ToString('o')
$taskProcess = Start-Process -FilePath $taskEngine -ArgumentList $taskArguments -WorkingDirectory $taskProject -WindowStyle Hidden -RedirectStandardOutput $taskStdout -RedirectStandardError $taskStderr -PassThru
$taskFinished = $taskProcess.WaitForExit(55000)
if ($Mode -eq 'runtime' -and -not $taskFinished) { $taskFinished = $taskProcess.WaitForExit(55000) }
if ($Mode -eq 'runtime' -and -not $taskFinished) { $taskFinished = $taskProcess.WaitForExit(15000) }
$taskTimeout = -not $taskFinished
if ($taskTimeout) {
    if (-not $taskProcess.HasExited) { $taskProcess.Kill() }
    $taskProcess.WaitForExit()
}
$taskProcess.Refresh()
$taskExit = $taskProcess.ExitCode
$taskOut = if (Test-Path -LiteralPath $taskStdout) { Get-Content -LiteralPath $taskStdout -Raw } else { '' }
$taskErr = if (Test-Path -LiteralPath $taskStderr) { Get-Content -LiteralPath $taskStderr -Raw } else { '' }
$taskAllLines = (($taskOut + "`n" + $taskErr) -split "`r?`n")
$taskScriptErrors = @($taskAllLines | Where-Object { $_ -match 'SCRIPT ERROR:|Parse Error:|Could not load script|Failed to load script' })
$taskGeneralErrors = @($taskAllLines | Where-Object { $_ -match '(^|\s)ERROR:' -and $_ -notmatch 'SCRIPT ERROR:' })
$taskWarnings = @($taskAllLines | Where-Object { $_ -match 'WARNING:' })
$taskAfter = @(Get-CaptureManifest $taskCaptureRoot)
$taskAfter | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $taskRun 'captures-after.json') -Encoding utf8
$taskCopied = @()
if ($Mode -eq 'runtime') {
    $taskResults = Join-Path $taskRun 'stills'
    New-Item -ItemType Directory -Path $taskResults -Force | Out-Null
    foreach ($taskName in $taskExpected) {
        $taskSource = Join-Path $taskCaptureRoot $taskName
        if (Test-Path -LiteralPath $taskSource) {
            Copy-Item -LiteralPath $taskSource -Destination (Join-Path $taskResults $taskName)
            $taskCopied += $taskName
        }
    }
}
$taskReceipt = [ordered]@{mode=$Mode;project=$taskProject;engine=$taskEngine;arguments=$taskArguments;pid=$taskProcess.Id;startedUtc=$taskStartedUtc;completedUtc=[DateTime]::UtcNow.ToString('o');timeout=$taskTimeout;exitCode=$taskExit;stdout=$taskStdout;stderr=$taskStderr;scriptErrors=$taskScriptErrors;generalErrors=$taskGeneralErrors;warnings=$taskWarnings;captureRoot=$taskCaptureRoot;expectedCaptureNames=$taskExpected;copiedCaptureNames=$taskCopied;capturesBefore=$taskBefore;capturesAfter=$taskAfter;runtimeCaptureFreshnessRequiresReview=$true;gameWasNotRunByPreparation=$false}
$taskReceipt | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $taskRun 'receipt.json') -Encoding utf8
$taskReceipt | ConvertTo-Json -Depth 20
if ($taskTimeout) { exit 124 }
if ($taskExit -ne 0) { exit $taskExit }
if ($taskScriptErrors.Count -gt 0) { exit 3 }

