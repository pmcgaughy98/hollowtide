from pathlib import Path
import hashlib, json, re, shutil
from PIL import Image, ImageDraw

W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
E=L/'docs/ui/recruit-portraits-2026-10-26'
baseline=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    assert sha(L/rel)==baseline[rel], f'Concurrent documentation changed: {rel}'
assert not E.exists(), 'Evidence already exists; do not replace originals'
sheet=Image.new('RGB',(1152,472),'#242b25')
d=ImageDraw.Draw(sheet)
for row,mode in enumerate(('team-','fallback-team-')):
    for col,form in enumerate(('skimlet','ozbender','valvekin')):
        im=Image.open(W/'native'/(mode+form+'.png')).convert('RGB')
        sheet.paste(im.resize((384,216),Image.Resampling.NEAREST),(col*384,row*236+20))
        d.text((col*384+4,row*236+4),('Normal: ' if row==0 else 'Fallback: ')+form,fill='white')
sheet.save(W/'native-contact.png')
E.mkdir(parents=True)
for name in ('originals','prepared','native'):
    shutil.copytree(W/name,E/name,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.json','.log','.png','.md'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_recruit_portraits.md'
assert not handoff.exists()
shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: task 2 and current queue reconciliation

Task 2 COMPLETE/INSTALLED as fallback art: Skimlet, Ozbender and Valvekin each have a 48px arena portrait, cropped from current southwest stills through build_portraits.py, with three reproducible HEAD entries. The default crop missed Ozbender's face and Valvekin's mantle; corrected crops inspected by Codex, Preston approval pending. Native 32/32, clean runtime: imported RGBA exact, existing dialogue-first Team/dungeon headshots preserved, and new portraits selected exactly when the dialogue face is unavailable in a private-process fixture. Existing face_crop_check 5/5 across 49 faces. All 48 other builder outputs exact; 3483 protected files exact before documentation, only the builder changed among existing production files. Claude's dirty source work preserved. No new generation, paid call, real save, game-rule change or commit. Evidence: [portrait review and checks](../ui/recruit-portraits-2026-10-26/README.md). [Handoff](CODEX_HANDOFF_2026-10-26_recruit_portraits.md).

Source issues for Claude: task 2's empty-box diagnosis predates the current dialogue-first UI; these files are fallbacks, with the existing dialogue portraits retained. Section 9 item 18 swaps ART-03/ART-10 descriptions relative to section 5. Headless import still reports the previously recorded Dialogue Manager theme_values.gd:51 Nil-to-int editor errors; import exits 0 and final native pixels/runtime checks pass independently. The first fixture failed 10/19 because it expected obsolete portrait priority; archived, corrected final fixture 32/32, no game-source workaround.

New work confirmed in sections 5-9 through October 24; their repeated rows refine earlier items. Next slice: original task 3 / latest pass 6 C2, title Options/How to play/Quit bounds and ui_fit's three title failures. Settings task 4/C1 still needs current inspection and checking. Canvaswing task 1 remains complete. LV-27 flood dialogue choices were taken by Claude; skip them. Other factory/pass tasks remain pending, and proposed wording retains its specified flags.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md'
raw=queue.read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n'
queue.write_bytes(raw+result.replace('\r\n','\n').encode('utf-8').replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md'
raw=collab.read_bytes();head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: recruit portrait fallbacks and updated queue (October 26, 2026)

Task 2 COMPLETE/INSTALLED: 48px Skimlet/Ozbender/Valvekin arena portraits from existing southwest stills, with three HEAD crop entries. Native 32/32 and existing face_crop_check 5/5 across 49 faces; all 48 other builder outputs exact, 3483 protected files exact before docs. The task's old empty-box diagnosis is superseded by Claude's dialogue-first UI: current dialogue crops stay normal, new PNGs are checked fallbacks. Preston crop approval pending. Originals, native normal/fallback screenshots, exact pixels and hashes: [portrait evidence](ui/recruit-portraits-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_recruit_portraits.md). No new generation, paid calls, game code/rules, real save or commit. Headless import retains the editor-only Dialogue Manager theme_values.gd:51 Nil-to-int errors; native runtime log is clean. The task file's factory/pass 2-6 additions through October 24 were read; next slice is original task 3 / latest pass 6 C2 title panel bounds and ui_fit's three title failures. Other Claude changes preserved, LV-27 stays Claude's, proposed words retain their flags.

'''
collab.write_bytes(head+sep+entry.encode('utf-8').replace(b'\n',nl)+rest)
allowed={'tools/arena/build_portraits.py','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'}
changed=[p for p,h in baseline.items() if not (L/p).is_file() or sha(L/p)!=h]
assert set(changed)==allowed,changed
for p,h in json.loads((W/'installed-files.json').read_text(encoding='utf-8')).items():
    assert sha(L/p)==h,p
assert queue.read_bytes().startswith((W/'originals/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes())
original=(W/'originals/docs/AI_COLLABORATION.md').read_bytes()
assert collab.read_bytes().endswith(original.partition(b'\n')[2])
missing=[]
(E/'publication.json').write_text('{}',encoding='utf-8')
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        if not (p.parent/target).exists(): missing.append((str(p),target))
assert not missing,missing
receipt={'protected_before':len(baseline),'protected_unchanged_after_docs':len(baseline)-len(changed),'existing_baseline_changes':changed,'original_queue_preserved_as_prefix':True,'original_collaboration_body_preserved_as_suffix':True,'evidence':str(E),'handoff':str(handoff),'native':'32/32','face_crop':'5/5','local_links_resolve':True}
(W/'publication.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
shutil.copy2(W/'publication.json',E/'publication.json')
print(json.dumps(receipt,indent=2))
