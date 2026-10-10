from pathlib import Path
import json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');r='docs/AI_COLLABORATION.md'
b=(L/r).read_bytes();c=(W/'candidate'/r).read_bytes()
start=c.index(b'## Codex: Mouth of the Hollow entrance finish')
end=c.index(b'\n## ',start+10)
assert c[start:end].rstrip() in b,'Entrance entry changed or missing; inspect before accepting'
a=json.loads((W/'accepted-post-preinstall.json').read_text());a[r]={'sha256':hashlib.sha256(b).hexdigest(),'reason':'Grok prepended the antagonist/boss handoff; exact installed Mouth entry verified retained, all current note bytes preserved.'}
(W/'accepted-post-preinstall.json').write_text(json.dumps(a,indent=2))
p=W/'archive/concurrent-notes/AI_COLLABORATION-post-install.md';p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
print('Verified Mouth entry retained under concurrent Grok note.')
