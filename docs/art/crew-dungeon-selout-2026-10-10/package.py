from pathlib import Path
import json,shutil,hashlib,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');A=W/'archive'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert 'SEL-OUT: 22 checks, 0 failures' in (W/'selout_check.log').read_text()
assert 'DUNGEONS: all ok' in (W/'dungeons_check.log').read_text()
for log in ['selout_check.log','dungeons_check.log','after_capture.log']:
 assert 'SCRIPT ERROR' not in (W/log).read_text()
owned=[]
for p in (W/'candidate').rglob('*'):
 if not p.is_file():continue
 r=p.relative_to(W/'candidate').as_posix();o=W/'originals'/r
 expected=sha(o) if o.exists() else None
 assert (L/r).exists()==(expected is not None),(r,'new target exists')
 if expected:assert sha(L/r)==expected,(r,'concurrent edit requires rebase')
 owned.append({'path':r,'expected':expected,'candidate':sha(p)})
 # Retain the exact scoped diff, alongside unchanged concurrent code snapshots.
 if o.exists():
  q=A/'diffs'/(r+'.diff');q.parent.mkdir(parents=True,exist_ok=True)
  q.write_text(''.join(difflib.unified_diff(o.read_text(encoding='utf-8').splitlines(True),p.read_text(encoding='utf-8').splitlines(True),fromfile='current-live/'+r,tofile='finish/'+r)),encoding='utf-8')
note='''## Codex: rival crew and both dungeon scenery sel-out (October 10, 2026)

Preston requested Mirekit/Whinet and dungeon 1/2, explicitly including scenery. Added bounded internal contour ink through the existing Hollowtide Sprite finish for the two installed stage 1 sets and their dialogue portraits. Shared map finish is masked to exposed wall faces/edges and stairs; walking surfaces remain original. Preserved Claude's concurrent Rootbank Warren name/new meadow-and-hills ValleyPainter, crew dialogue/expressions/moves and second-boss Warden pond; no roster/stat/controller/terrain-source changes.

22 native checks pass: 544 textures, alpha/silhouette/bright pale highlights exact; 33 other forms and town detail preset byte-exact; all unmasked pixels exact across riverbank/valley/ruin/bank; actual dungeon/crew portraits/emotion marks/closing/Warden scene. Current Claude dungeons_check all ok, including Rot Spit/Drain Bite and town dispatch choice. No source PNG edits, generation, settings edit or commit. Preserve seven-form/Oxbowarchon jade, Sparkwick correction and all original backups. [Native previews, scope, originals and audit](art/crew-dungeon-selout-2026-10-10/README.md). Implemented and reviewed; Preston's visual approval and natural dungeon clear not claimed.


'''
old=(L/'docs/AI_COLLABORATION.md').read_bytes();text=old.decode('utf-8');anchor='# Working Together on Hollowtide\n\n';normalized=text.replace('\r\n','\n');assert normalized.startswith(anchor)
# Keep every existing byte after its original header (including concurrent notes).
header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n\r\n') else anchor.encode()
p=W/'candidate/docs/AI_COLLABORATION.md';p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(header+note.replace('\n','\r\n' if b'\r\n' in header else '\n').encode()+old[len(header):])
q=W/'originals/docs/AI_COLLABORATION.md';q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(old)
owned.append({'path':'docs/AI_COLLABORATION.md','expected':sha(q),'candidate':sha(p)})
for folder in ['candidate','originals','initial-originals','review','concurrent-code']:
 shutil.copytree(W/folder,A/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.py','.gd','.json','.log','.md'] and p.name!='pending-install.json':shutil.copy2(p,A/p.name)
(W/'pending-install.json').write_text(json.dumps(owned,indent=2))
(A/'installed-files.json').write_text(json.dumps(owned,indent=2))
print('Packaged',len(owned),'exact guarded installation files and native review evidence.')
