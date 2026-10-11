from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');r='docs/AI_COLLABORATION.md'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text());record=next(d for d in pending if d['path']==r)
assert sha(L/r)==record['after']
raw=(L/r).read_bytes();s=raw.decode().replace('\r\n','\n')
s=s.replace('across 1,323 new textures','across 1,329 new textures',1)
s=s.replace('Native town materials, dialogue clipping/dismissal, Team presentation and dungeon art presentation pass; existing field-menu check passes. The two-dungeon check reports missing new-wild stat lookups, so it is not claimed clean.','Native town materials, dialogue clipping/dismissal and the real three-new-creature Team/dungeon actors pass; existing field-menu and two-dungeon checks pass cleanly after Claude supplied the concurrent kit lookup fix.',1)
a=s.index('Claude/Grok gameplay follow-up:');b=s.index('\n\n',a)
s=s[:a]+"During review the new wilds lacked Arena.KITS lookups; Claude added them concurrently. His arena source was retained untouched. Final native checks now use real Skimlet/Ozbender/Valvekin town and dungeon teams and the current two-dungeon check without errors. Earlier art-only fixture trials are superseded by those real-team checks. Six townsfolk currently have rotations/town stills and newly added dialogue portraits; this pass supplies their finish, not NPC story/service placement. Job12 waking remains pending from the handoff."+s[b:]
backup=W/'initial-note'/r;backup.parent.mkdir(parents=True,exist_ok=True);backup.write_bytes(raw)
q=W/'candidate'/r;q.write_bytes(s.replace('\n','\r\n').encode() if b'\r\n' in raw else s.encode())
update={'path':r,'before':record['after'],'after':sha(q)}
record['after']=update['after'];(W/'pending-install.json').write_text(json.dumps(pending,indent=2));(W/'note-update.json').write_text(json.dumps(update,indent=2))
print('Updated final handoff note to the successful real-team checks and preserved Claude kit fix.')
