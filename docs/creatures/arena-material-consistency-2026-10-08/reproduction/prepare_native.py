"""Prepare hidden owned Godot checks, preserving existing native captures first."""
from pathlib import Path
W=Path(__file__).resolve().parent
template=(W.parent/'arena-vitrecrag-consistency-2026-10-07/launch_vitrecrag_check.ps1').read_text(encoding='utf8')
checks={
 'oxbowarchon':('arena_backline_check.gd','arena-oxbowarchon-2026-10-08',['backline_rail_telegraph.png','backline_rail.png','backline_recoil.png','backline_stage1_bar.png','backline_vent_blast.png','backline_match.png']),
 'starward':('arena_protector_check.gd','arena-starward-2026-10-08',['line_stage1.png','line_stage2.png','line_stage3.png','star_guard.png','counter_jab.png','starshield_forming.png','starshield_snap.png','star_field.png','match_3v3.png']),
 'slagglass':('arena_vitrecrag_check.gd','arena-vitrecrag-2026-10-07',['line_stage1.png','line_stage2.png','line_stage3.png','glass_1.80s.png','glass_2.30s.png','glass_2.70s.png','glass_3.10s.png','match.png'])}
for name,(script,doc,captures) in checks.items():
    code=template.replace("$taskReviewRoot = Split-Path -Parent $MyInvocation.MyCommand.Path", "$taskReviewRoot = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'native-"+name+"'\nNew-Item -ItemType Directory -Path $taskReviewRoot -Force | Out-Null")
    code=code.replace("docs\\creatures\\arena-vitrecrag-2026-10-07",'docs\\creatures\\'+doc)
    start=code.index('$taskExpected = ');end=code.index('\n',start)
    code=code[:start]+"$taskExpected = @("+','.join("'"+s+"'" for s in captures)+")"+code[end:]
    code=code.replace('arena_vitrecrag_check.gd',script)
    code=code.replace('WaitForExit(15000)','WaitForExit(55000)')
    code=code.replace('$taskFinished = $taskProcess.WaitForExit(55000)', '$taskOwnedHandle = $taskProcess.Handle\n$taskFinished = $taskProcess.WaitForExit(55000)',1)
    code=code.replace("$taskTimeout = -not $taskFinished", "if ($Mode -eq 'runtime' -and -not $taskFinished) { $taskFinished = $taskProcess.WaitForExit(55000) }\nif ($Mode -eq 'runtime' -and -not $taskFinished) { $taskFinished = $taskProcess.WaitForExit(20000) }\n$taskTimeout = -not $taskFinished")
    (W/('launch_'+name+'_check.ps1')).write_text(code,encoding='utf8')
