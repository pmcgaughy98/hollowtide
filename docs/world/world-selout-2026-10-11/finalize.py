from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/world/world-selout-2026-10-11'
installed=json.loads((P/'installed-hashes.json').read_text())
assert all(hashlib.sha256((L/rel).read_bytes()).hexdigest()==digest for rel,digest in installed.items()),'Inspect concurrent installed source edit'
before=json.loads((W/'before-hashes.json').read_text());owned=['scripts/town/highbank_painter.gd','scripts/town/hub_town.gd']
audit={rel:{'before':digest,'after':hashlib.sha256((L/rel).read_bytes()).hexdigest()} for rel,digest in before.items() if rel not in owned}
changed=[rel for rel,row in audit.items() if row['before']!=row['after']]
assert not changed,'Inspect concurrent protected changes: '+str(changed)
for rel in owned:
    original=(W/'originals'/rel).read_bytes();live=(L/rel).read_bytes()
    if rel.endswith('highbank_painter.gd'):
        restored=live.replace(b'\treturn preload("res://scripts/town/world_finish.gd").paint(Detail.river(img))',b'\treturn Detail.river(img)')
    else:
        line=b'\tpreload("res://scripts/town/world_finish.gd").apply(map)\r\n'
        if b'\r\n' not in original:line=line.replace(b'\r\n',b'\n')
        restored=live.replace(line,b'')
    assert restored==original,rel+' changed outside presentation hook'
for name in ['verify','live-verify','hub_town_check','town_walk_check','hall_door_check','dungeons_check']:
    t=(W/(name+'.log')).read_text(encoding='utf-8')
    assert not any(x in t for x in ['SCRIPT ERROR','ERROR:','FAIL','WRONG','Leaked']),name
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.png','.gd','.py','.log','.json','.diff','.md']:shutil.copy2(p,P/p.name)
(P/'protected-audit.json').write_text(json.dumps({'protected_checked':len(audit),'changed':changed,'owned_source_minus_hooks':'byte-exact originals','files':audit},indent=2),encoding='utf-8')
dst=L/'docs/team/CODEX_START_HERE_2026-10-11.md';assert not dst.exists(),'Inspect an existing next-chat handoff first'
shutil.copy2(W/dst.name,dst)
note='''## Codex: Highbank world sel-out and fresh-chat handoff (October 11, 2026)

Preston requested world sel-out, then a new-chat context handoff to save usage. Installed connected road borders, cliff lips/faces and switchback treads using shared material-colored one-pixel rims plus bounded0.55 masked internal ink. Quiet walking interiors, all13 existing landmarks with approach/shadow margins, river/water/glints and grid remain exact. One return hook in highbank_painter, one material hook in hub_town, new world_finish helper; no PNG/generation, creature/palette, layout, story/rule/save, shared shader or settings changes. Native21/21 staging and live;7753 rim pixels and26520 selected GPU detail pixels, zero outside masks. All12 services, routes, actual Hollow entry, two Hall doors, walking and current dungeon5/5 checks pass. Owned originals byte-exact outside hooks; protected hashes unchanged. [Evidence, originals and exact diff](world/world-selout-2026-10-11/README.md). No commit.

**New chat should read [CODEX_START_HERE_2026-10-11.md](team/CODEX_START_HERE_2026-10-11.md) first**, then current instructions/latest Claude handoff. Preserve Claude's new Dialogue Manager flood talk and Warden staging, rebuilt Hall art and all original creature assets/refinements. Clarification for earlier top notes: the Growth Shrine exterior and evolution presentation were already completed October10; the pending job4 is its richer condition/move information screen, subject to inspecting the latest live work. Do not regenerate the exterior or install its older staging scripts. Codex is out of the two shared world files.

'''
path=L/'docs/AI_COLLABORATION.md';body=path.read_bytes();newline='\r\n' if b'\r\n' in body else '\n';marker=(newline*2).encode();pos=body.index(marker)+len(marker);encoded=note.replace('\n',newline).encode()
assert note.splitlines()[0].encode() not in body
path.write_bytes(body[:pos]+encoded+body[pos:]);assert path.read_bytes().replace(encoded,b'',1)==body
print(f'Live checks clean; {len(audit)} protected hashes exact. Fresh-chat handoff saved: {dst}')
