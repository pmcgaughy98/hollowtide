from pathlib import Path
import hashlib,json,re,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
P=L/'docs/design/pilot-waking-2026-10-10'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
old=(W/'originals/scripts/creature_prologue.gd').read_text(encoding='utf-8')
new=(C/'scripts/creature_prologue.gd').read_text(encoding='utf-8')
def method(s,name):return re.search(r'^func '+name+r'\(.*?(?=^func |\Z)',s,re.S|re.M).group(0)
for name in ['actor','set_form','label','button','choose','previous','advance','_unhandled_input']:
    assert method(old,name)==method(new,name),name+' changed outside presentation scope'
assert '\u2022 '+ '"+NAMES[i]' in new
assert sha(L/'scripts/creature_prologue.gd')==baseline['scripts/creature_prologue.gd'],'Concurrent prologue edit, inspect before installing'
assert not (L/'scripts/ui/waking_bank.gd').exists(),'Concurrent helper exists'
assert 'WAKING 77/77 PASS' in (W/'waking_check.log').read_text(encoding='utf-8')
assert 'RESULT: the soul prologue works' in (W/'soul_check.log').read_text(encoding='utf-8')
assert 'TOWN LOOP PASS' in (W/'town_loop_check.log').read_text(encoding='utf-8')
paths=['scripts/ui/waking_bank.gd','scripts/creature_prologue.gd','docs/AI_COLLABORATION.md']
for r in paths[:2]:
    q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,q)
prior=(L/'docs/AI_COLLABORATION.md').read_bytes()
(W/'latest-ai-before.md').write_bytes(prior)
note='''## Codex: pilot waking scene, handoff job 12 (October 10, 2026)

Implemented the approved pilot outline's first three beats in the waking presentation. A broken, river-wet clay bank with loose letters faces the newly risen, lit Hollow and its stone approach. The scene uses existing dungeon clay/stone materials, native 384x216 pixels and nearest 3x presentation, gentle water glints and frozen Reduce Motion. Creature actors clear the heading and retain their installed finish. Dialogue now names the riverbank collapse, a little retained human memory, a Wayline trainee gathering loose mail and the quiet call, then the no-solo-route rule and both characters' need for each other before Highbank. New dialogue and the distant architecture are proposals; Preston's outline approval is not approval of final lines or staging.

Partner choices, soul-selected identity, pixel frames/portraits, input/focus, town transition and team/state methods are retained. Native review: 77/77 waking checks across all six pairings, actual mouse/keyboard and Back; current soul handoff works; current town_loop_check passes the actual scene changes, clear/state carryover and faint/bag loss. Originals, previews, source scope and final live verification: [pilot waking handoff](design/pilot-waking-2026-10-10/README.md). No generated art, original PNG, creature palette/shader, title art, rules, save/state, settings or commit edits. Preserve the seven-form refinements, Oxbowarchon jade, Sparkwick correction, Skimlet correction, Gruntle portrait clipping and Claude's concurrent work. Claude still owns the Guildmaster/town introduction and remaining pilot systems.

'''
header=b'# Working Together on Hollowtide\r\n\r\n' if prior.startswith(b'# Working Together on Hollowtide\r\n\r\n') else b'# Working Together on Hollowtide\n\n'
assert prior.startswith(header)
q=W/'candidate/docs/AI_COLLABORATION.md';q.parent.mkdir(parents=True,exist_ok=True)
q.write_bytes(header+note.encode('utf-8')+prior[len(header):])
plan=[]
for r in paths:
    src=W/'candidate'/r;dst=L/r
    plan.append({'path':r,'before':sha(dst) if dst.exists() else None,'after':sha(src),'source':str(src),'target':str(dst),'archive':str(P/'originals'/r)})
(W/'pending.json').write_text(json.dumps(plan,indent=2),encoding='utf-8')
script='''$ErrorActionPreference = 'Stop'
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
'''
(W/'install.ps1').write_text(script,encoding='utf-8')
print('Prepared guarded 3-file install; 8 state/control methods exact; prior AI body retained.')
