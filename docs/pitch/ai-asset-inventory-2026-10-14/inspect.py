from pathlib import Path
import json,hashlib,subprocess,re
from PIL import Image
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
FACES={'grubbit':['surprised','happy'],'stillwade':['worried','determined'],'wickglow':['mischievous','happy'],'muskin':['surprised','worried'],'slipjaw':['angry','determined'],'rinsepaw':['happy','sad']}
facts={'date':'2026-10-14','scope':'targeted October12-14 refresh, not a new full census or export audit','expressions':[],'gifs':[],'videos':[],'normal_portraits_unchanged':{},'proposal_only':{},'source_scan':{}}
evidence={}
def record(p):
    assert p.is_file(),p
    evidence[p.relative_to(R).as_posix()]=sha(p)
for form,faces in FACES.items():
    normal=R/f'assets/sprites/ui/dialogue/{form}.png'
    prepared=R/f'docs/ui/crew-portraits-2026-10-11/prepared/assets/sprites/ui/dialogue/{form}.png'
    if not prepared.exists():
        matches=list((R/'docs/ui/crew-portraits-2026-10-11/prepared').rglob(form+'.png'))
        assert len(matches)==1,matches
        prepared=matches[0]
    assert sha(normal)==sha(prepared),form
    facts['normal_portraits_unchanged'][form]=True
    record(normal);record(prepared)
    for face in faces:
        p=R/f'assets/sprites/ui/dialogue/{form}_{face}.png';im=Image.open(p)
        assert im.size==(40,40)
        raw=R/f'docs/ui/crew-expressions-2026-10-12/{form}_{face}_edit.png'
        record(p);record(raw)
        facts['expressions'].append({'form':form,'face':face,'path':p.relative_to(R).as_posix(),'size':list(im.size),'raw':raw.relative_to(R).as_posix()})
for name in ['mail_call','water_rises','carried_home','standoff']:
    p=R/f'docs/pitch/feedback-post-2026-10-12/{name}.gif';im=Image.open(p)
    duration=0
    for k in range(im.n_frames):im.seek(k);duration+=im.info.get('duration',0)
    facts['gifs'].append({'path':p.relative_to(R).as_posix(),'size':list(im.size),'frames':im.n_frames,'duration_seconds':duration/1000,'sha256':sha(p)})
    record(p)
for name in ['hollowtide_pitch_v3.mp4','hollowtide_pitch_v3_share.mp4']:
    p=R/'docs/trailer/v3'/name
    result=subprocess.run(['ffprobe','-v','error','-show_entries','format=duration:stream=codec_name,codec_type,width,height,r_frame_rate','-of','json',str(p)],check=True,capture_output=True,text=True)
    facts['videos'].append({'path':p.relative_to(R).as_posix(),'probe':json.loads(result.stdout),'sha256':sha(p)})
    record(p)
for form in ['ballastak','switchhold']:
    matches=[str(p.relative_to(R)) for p in (R/'assets').rglob('*') if form in p.name.lower()]
    refs=[]
    for folder in ['scripts','scenes','data','dialogue']:
        for p in (R/folder).rglob('*'):
            if p.suffix in ['.gd','.tscn','.tres','.json','.dialogue'] and re.search(r'res://[^\s\"\']*(?:ballastak|switchhold)',p.read_text(encoding='utf-8',errors='replace'),re.I):refs.append(p.relative_to(R).as_posix())
    assert not matches and not refs
    facts['proposal_only'][form]={'matching_asset_paths':matches,'literal_resource_consumers':refs,'limits':'Name/path scan only; dated design records explicitly mark proposal. Names in roster/rules do not establish installed creature art.'}
scan=[];patterns=re.compile(r'HTTPRequest|HTTPClient|https?://|api_key|generate_content',re.I)
for folder in ['scripts','scenes','dialogue','data']:
    for p in (R/folder).rglob('*'):
        if p.suffix in ['.gd','.tscn','.tres','.json','.dialogue']:
            for n,line in enumerate(p.read_text(encoding='utf-8',errors='replace').splitlines(),1):
                if patterns.search(line):scan.append({'path':p.relative_to(R).as_posix(),'line':n,'text':line.strip()})
facts['source_scan']={'patterns':patterns.pattern,'directories':['scripts','scenes','dialogue','data'],'matches':scan,'limits':'Static marker scan only, not a network trace, plugin audit, reachability proof or export audit.'}
for name in ['docs/pitch/feedback-post-2026-10-12.md','tools/trailer/record_pitch_v3.gd','tools/trailer/cut_pitch_v3.py','docs/trailer/v3/segments.txt','tools/ui/rd_crew_expressions.py','tools/debug/rd_creature.py','scripts/town/guild_crew.gd','scripts/ui/ui_style.gd','docs/design/sprite-generator-skillup-2026-10-13.md','docs/design/new-creature-ballastak-2026-10-13/README.md','docs/design/new-creature-ballastak-2026-10-13/switchhold/README.md','docs/design/new-creature-ballastak-2026-10-13/parts_kit/README.md','docs/art/spritecook-assets.json','docs/world/storage-art-proposal-2026-10-14/generation-ledger.json','docs/world/storage-art-proposal-2026-10-14/README.md','docs/ui/parcel-icon-2026-10-14/README.md','docs/design/rising-water-finish-2026-10-14/README.md','docs/design/dialogue-corner-2026-10-14/README.md','project.godot']:
    record(R/name)
facts['main_scene']='scenes/creature_opening.tscn';assert 'run/main_scene="res://'+facts['main_scene']+'"' in (R/'project.godot').read_text(encoding='utf-8')
facts['export_presets_present']=(R/'export_presets.cfg').exists()
(W/'facts.json').write_text(json.dumps(facts,indent=2),encoding='utf-8')
(W/'evidence-sha256.json').write_text(json.dumps(evidence,indent=2),encoding='utf-8')
print(json.dumps(facts,indent=2))
