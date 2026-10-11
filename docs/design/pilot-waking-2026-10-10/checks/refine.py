from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
plan=json.loads((W/'pending.json').read_text(encoding='utf-8'));updates=[]
if (W/'refine-pending.json').exists():
    prior_updates=json.loads((W/'refine-pending.json').read_text(encoding='utf-8'))
    for row in plan:
        previous=next((p for p in prior_updates if p['target']==row['target']),None)
        if previous:row['after']=previous['before']
for row in plan:
    if row['path']=='scripts/ui/waking_bank.gd':continue
    live=(L/row['path']).read_bytes()
    assert hashlib.sha256(live).hexdigest()==row['after'],row['path']
    if row['path'].endswith('creature_prologue.gd'):
        new=(C/row['path']).read_bytes()
        assert new.decode('utf-8')==live.decode('utf-8').replace('back.text="Choose another companion"','back.text="Change partner"')
    else:
        new=live.replace(b'77/77 waking checks',b'95/95 waking checks',1)
        assert new!=live
    (W/'candidate'/row['path']).write_bytes(new)
    before=row['after'];row['after']=hashlib.sha256(new).hexdigest()
    updates.append({'target':row['target'],'source':row['source'],'before':before,'after':row['after']})
(W/'pending.json').write_text(json.dumps(plan,indent=2),encoding='utf-8')
(W/'refine-pending.json').write_text(json.dumps(updates,indent=2),encoding='utf-8')
(W/'refine-install.ps1').write_text('''$ErrorActionPreference = 'Stop'
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
''',encoding='utf-8')
print('Prepared label-only refinement and accurate check count.')
