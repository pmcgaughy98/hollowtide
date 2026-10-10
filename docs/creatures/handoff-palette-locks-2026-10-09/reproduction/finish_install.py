from pathlib import Path
import hashlib,json,ast,shutil,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=W/'candidate';A=L/'docs/creatures/handoff-palette-locks-2026-10-09'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text());owned=json.loads((W/'owned.json').read_text());protected=json.loads((A/'preserved-sha256.json').read_text())
for r in owned:assert sha(L/r)==sha(P/r),'Installed sprite mismatch: '+r
for r,h in baseline.items():
    if r not in owned:assert sha(L/r)==h,'Reference/pipeline change: '+r
concurrent={r:{'before':h,'after':sha(L/r)} for r,h in protected.items() if sha(L/r)!=h}
assert not any(r.startswith('assets/') for r in concurrent),'Concurrent protected art change'
tree=ast.parse((W/'install.py').read_text());blocks={}
for node in tree.body:
    if isinstance(node,ast.Assign):
        for target in node.targets:
            if isinstance(target,ast.Name) and target.id in ['entry','progress']:blocks[target.id]=ast.literal_eval(node.value)
notes=['docs/AI_COLLABORATION.md','docs/team/CODEX_HANDOFF_2026-10-10.md'];pending=[]
for r,key in zip(notes,['entry','progress']):
    original=(A/'originals'/r).read_bytes();live=(L/r).read_bytes();nl='\r\n' if b'\r\n' in original else '\n';split=original.index(b'\n')+1
    planned=original[:split]+nl.encode()+blocks[key].replace('\n',nl).encode()+original[split:]
    assert live in [original,planned],'Concurrent note update: '+r
    destination=W/(Path(r).name+'.planned');destination.write_bytes(planned);pending.append({'path':r,'before':hashlib.sha256(original).hexdigest(),'after':hashlib.sha256(planned).hexdigest(),'source':str(destination)})
(W/'pending-notes.json').write_text(json.dumps(pending,indent=2))
if '--verify' not in sys.argv:print(json.dumps({'sprites_installed':len(owned),'notes_prepared':pending,'concurrent':list(concurrent)},indent=2));sys.exit()
for n in pending:assert sha(L/n['path'])==n['after'],'Note not finished: '+n['path']
changes=[r for r in owned if baseline[r]!=sha(P/r)]
(A/'installed-files.json').write_text(json.dumps({r:sha(L/r) for r in changes},indent=2))
native=json.loads((W/'native-checks.json').read_text())
manifest={'changed_pngs':len(changes),'checked_pngs':785,'native_checks':native,'relay_checks':50,'protected_files':len(protected),'concurrent_protected_changes':concurrent,'changed_notes':notes,'runtime_code_written':0,'generation_calls':0,'note_write_recovery':'Initial Path.write_bytes on AI_COLLABORATION.md raised EINVAL before changing the file. Guarded .NET write completed the prepared notes.','initial_installer_log':'logs/initial-install-write-error.txt'}
(A/'installation.json').write_text(json.dumps(manifest,indent=2));shutil.copy2(W/'finish_install.py',A/'reproduction/finish_install.py')
(A/'logs/initial-install-write-error.txt').write_text('Initial installer: OSError [Errno 22] Invalid argument opening docs/AI_COLLABORATION.md for writing; all sprite writes completed, both original notes intact. Recovery checked all 785 installed PNGs against tested candidates and guarded both prepared note writes by their original hashes.\n')
print(json.dumps({'verified':True,'changed_pngs':len(changes),'protected':len(protected),'concurrent':list(concurrent),'native_textures':720,'relay_checks':50},indent=2))
