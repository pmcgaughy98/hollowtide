from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'package'
for folder in ['review','review-packaged']:
    result=json.loads((W/folder/'native-checks.json').read_text(encoding='utf-8'));assert result['passed']==result['total']==8
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert not changed,changed
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.gd','.json','.md','.txt','.log','.png']:shutil.copy2(p,P/p.name)
generation={'provider':'built-in image_gen.imagegen','calls':2,'exact_model_version':None,'original_outputs_preserved':True,'items':[
 {'output':'generation/shell.png','original_tool_path':'C:/Users/pmcga/.codex/generated_images/01a12b4b-7982-7b32-b405-2a584762f412/exec-284e9fab-93ef-472d-881b-fe60d0e95cae.png','prompt':'shell-prompt.txt','edit_target':'shell-guide-3x.png','style_references':['references/hall-low.png','references/hall-chamber.png'],'used_regions':'native-preparation.json shell_parts; floor and accidental side openings not used'},
 {'output':'generation/props.png','original_tool_path':'C:/Users/pmcga/.codex/generated_images/01a12b4b-7982-7b32-b405-2a584762f412/exec-adb767f2-0dff-4630-9a60-19d5d17e5f73.png','prompt':'props-prompt.txt','edit_target':'props-guide.png','style_references':['references/hall-low.png','generation/shell.png'],'transparent_background_requested':True,'native_preparation':'source alpha >=224, uniform nearest fit, two-pixel margins, shared material rim'}]}
(P/'generation-ledger.json').write_text(json.dumps(generation,indent=2),encoding='utf-8')
evidence='docs/world/storage-art-proposal-2026-10-14/README.md'
summary='Task 3 ART COMPLETE/STAGED: a proposed 17x13-tile (408x312) Storage interior matching the Hall: exact native Hall limestone floor, rooted timber, brass, two back-wall cabinets, central counter, low stock crates/basket and wall lamps; no keeper or mail parcel stock. Six separate native props, shell, mask, assembled art, placements/depths and a standalone Godot preview delivered for Claude. Shared CPU rim preserves alpha/interiors; native preview8/8 and packaged preview8/8; all unselected floor pixels exact, all108 illustrative walkable tiles connected and three-tile aisle/threshold clear. All539 protected existing game sources/current-finish files exact. No live room, collision, door, Storage panel/data or game hook installed: these stay Claude\'s. Two built-in imagegen calls; original outputs, exact prompts, Hall references, nearest/alpha preparation and receipts: '+evidence+'. No external paid generator, commit, other proposal or training edit. Tasks1-3 deliverables complete; task4 dialogue-frame corner is next, then task5 AI inventory refresh. Claude room integration remains pending.'
plans={}
for rel in ['docs/team/CODEX_TASKS_2026-10-14.md','docs/team/CODEX_START_HERE_2026-10-14.md','docs/AI_COLLABORATION.md']:
    p=R/rel;old=p.read_bytes();text=old.decode('utf-8-sig').replace('\r\n','\n')
    if 'CODEX_TASKS_' in rel:
        assert "3. **The Storage room's art.**" in text
        text=text.replace("3. **The Storage room's art.**","3. **ART COMPLETE/STAGED: The Storage room's art.**",1)
        text+='\n\nCodex, October 14: '+summary+'\n'
    elif 'CODEX_START_HERE_' in rel:
        start=text.index('## Current status\n\n')+len('## Current status\n\n');end=text.index('\n\n## Read before work',start)
        text=text[:start]+summary+text[end:]
        text=text.replace("the Storage room's art, the dialogue frame's left corner", "the Storage room's art (staged), the dialogue frame's left corner",1)
    else:
        assert '# Working Together on Hollowtide\n' in text
        text=text.replace('# Working Together on Hollowtide\n','# Working Together on Hollowtide\n\n## Codex: Storage room art staged for Claude (October 14, 2026)\n\n'+summary+'\n',1)
    backup=P/'originals-docs'/p.name;backup.parent.mkdir(exist_ok=True);backup.write_bytes(old)
    diff=''.join(difflib.unified_diff(old.decode('utf-8-sig').replace('\r\n','\n').splitlines(True),text.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
    (P/(p.name+'.diff')).write_text(diff,encoding='utf-8',newline='\n')
    plans[rel]=(old,(text.replace('\n','\r\n') if b'\r\n' in old else text).encode('utf-8'))
handoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_storage_art.md';assert not handoff.exists()
dest=R/'docs/world/storage-art-proposal-2026-10-14';assert not dest.exists()
for rel,(old,new) in plans.items():assert (R/rel).read_bytes()==old
for rel,(_,new) in plans.items():(R/rel).write_bytes(new)
handoff.write_text('# Storage room art, Codex to Claude, October 14\n\n'+summary+'\n\nOpen the standalone staging/project.godot under that evidence folder for the art preview. See its README and placements.json. The actual room/door/panel hook, layout, solids and final depths are yours; source code and current Storage remain unchanged. Keep parcel refusal and the existing 166,64 panel origin. The counter uses a proposed five-tile body with top overhang, so confirm contact and foot sorting in game. No keeper. All sources are proposals pending Preston\'s visual review. No chat message was sent.\n',encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='manifest.json'}
(P/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
shutil.copytree(P,dest)
for rel,sha in manifest.items():assert hashlib.sha256((dest/rel).read_bytes()).hexdigest()==sha
for rel,(_,new) in plans.items():assert (R/rel).read_bytes()==new
for rel,sha in protected.items():assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==sha,rel
print('Saved and verified',len(manifest),'proposal files and standalone preview. Three status docs and Claude handoff updated; all539 protected game files exact.')
