from pathlib import Path
from collections import defaultdict
import csv, hashlib, json, re

ROOT=Path('C:/Users/pmcga/dev/hollowtide')
WORK=Path(__file__).parent
DOC=WORK/'ai-asset-inventory.md'
if not DOC.exists(): DOC=ROOT/'docs/pitch/ai-asset-inventory.md'
ARCHIVE=WORK if WORK.name=='ai-asset-inventory-2026-10-11' else WORK/'ai-asset-inventory-2026-10-11'
ARCHIVE.mkdir(exist_ok=True)
census=json.loads((WORK/'census.json').read_text(encoding='utf-8'))

def classify(group):
    if group.startswith('assets/sprites/arena/'):
        return 'creature art','AI-generated, subsequently edited','Retro Diffusion; older reference-model provenance may need reconciliation'
    if group.startswith('assets/sprites/creatures'):
        return 'creature art','AI-generated / unknown legacy per-file trace','Opal and Retro Diffusion records; not a per-file provider assertion'
    if group.startswith('assets/sprites/ui/dialogue'):
        return 'portraits','AI-generated source, subsequently edited','Source creature crops; Retro Diffusion image_edit for expression variants'
    if group.startswith(('assets/sprites/ui/frame','assets/sprites/ui/essence','assets/sprites/ui/item')):
        return 'UI','AI-assisted and edited','Claude Python/Pillow pixel grids and drawing recipes'
    if group.startswith('assets/fonts'):
        return 'fonts','Hand-made / third-party authored, recorded conventional source','Local OFL notices; original font-editor tool not established'
    if group.startswith('assets/third_party'):
        return 'third-party terrain','Hand-made / third-party authored per local attribution','ARoachIFoundOnMyPillow; CC0 source record'
    if group.startswith('assets/tilesets/dungeon_tiles_2026_10_10'):
        return 'dungeon terrain','AI-assisted and edited','Codex native pixel recipes / Godot'
    if group.startswith('assets/audio/_440hz_originals'):
        return 'audio backups','Mixed AI-generated and AI-assisted source audio; not asserted shipped','Preserved original tuning; see current-family inventory'
    if group=='assets/audio/music':
        return 'music','AI-generated, subsequently edited','Suno / ElevenLabs; some remixes; Monster House currently unused'
    if group.startswith('assets/audio/sfx/'):
        family=group.split('/')[3]
        if family in {'ui','root_rampart','stormlantern','undertow'}:
            return 'sound','AI-assisted synthesis; verify retained backup variants','Claude Python/NumPy; see build_*_sounds.py and make_* recipes'
        if family in {'dungeon','arena','story'}:
            return 'sound','Mixed AI-generated and AI-assisted synthesis','ElevenLabs takes and Claude synthesis; current replacements distinguished in inventory'
        return 'sound','AI-generated, subsequently edited; backups may be synthesized','ElevenLabs takes; tools/build_*_sounds.py source mappings'
    if group.startswith('assets/sprites/world/'):
        family=group.split('/')[3]
        if family.startswith(('route1','hometown','courtyard','historic','world_linework','world_approaches','courier_hall','area_transitions')):
            return 'retained world art','Mixed AI-generated and AI-assisted edits; per-file trace needed','Retro Diffusion / native code; retained older-scene art, not pilot reachability proof'
        return 'town/room art','AI-generated bitmaps with AI-assisted code composition/finish','Built-in imagegen; see named archive/consumer; per-file legacy variants need reconciliation'
    if group.startswith(('assets/backgrounds/arena','assets/backgrounds/signature_stages')):
        return 'battle/arena scenery','AI-generated','Retro Diffusion map/environment workflows; older individual receipts may differ'
    if group.startswith('assets/sprites/effects'):
        return 'effects','Mixed AI-generated and AI-assisted; unknown old Forge provider mapping','Retro Diffusion VFX / earlier Forge output / native code; reconcile per-file if retained'
    if group.startswith('assets/sprites/menu'):
        return 'title art','AI-generated and edited; verify older variant sources','Retro Diffusion; village records / old courier title archives'
    if group.startswith('assets/sprites/player'):
        return 'retained human avatar','AI-generated animation; initial JPEG source tool unknown','Retro Diffusion walks; original Male.jpg/Female.jpg provenance unresolved'
    if group.startswith('assets/tilesets/route1_rd'):
        return 'retained terrain','AI-generated, subsequently edited','Retro Diffusion; route1-rd-first-pass archive'
    return 'legacy/unmatched','Unknown or AI-assisted legacy recipe; do not assert hand-made','Requires source match or exclusion from final release'

groups=defaultdict(list)
for filename in census['asset_files']:
    p=Path(filename)
    key='/'.join(p.parts[:4]) if len(p.parts)>4 else p.parent.as_posix()
    groups[key].append(filename)
rows=[]
for group,files in sorted(groups.items()):
    category,classification,tools=classify(group)
    consumers=sorted({r['source'] for r in census['references'] if r['target'].startswith('res://'+group+'/')})
    rows.append({'group':group,'media_resource_files':len(files),'category':category,'classification':classification,'recorded_tools':tools,'literal_reference_consumers':'; '.join(consumers),'scope':'repository census, not exported or reachable-content assertion'})
with (ARCHIVE/'asset-groups.csv').open('w',encoding='utf-8',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
(ARCHIVE/'source-references.json').write_text(json.dumps({'scope':census['scope'],'references':census['references']},indent=2),encoding='utf-8')

# Validate document links as if installed under docs/pitch. Planned companions are checked in WORK.
missing=[]; checked=[]
for raw in re.findall(r'\]\(([^)]+)\)',DOC.read_text(encoding='utf-8')):
    if raw.startswith(('https://','http://')): continue
    dest=(ROOT/'docs/pitch'/raw).resolve()
    if raw.startswith('ai-asset-inventory-2026-10-11/'):
        dest=ARCHIVE/raw.split('/',1)[1]
    if not dest.exists(): missing.append(raw)
    checked.append(raw)
if missing: raise SystemExit('Missing local evidence links: '+json.dumps(missing))
result={'repository_media_resource_files':len(census['asset_files']),'group_count':len(rows),'count_sum':sum(r['media_resource_files'] for r in rows),'literal_res_references':len(census['references']),'local_document_links_checked':len(checked),'missing_local_links':missing,'scope':'static provenance/document review only; no exported build, gameplay test or license clearance claimed'}
assert result['count_sum']==result['repository_media_resource_files']
(ARCHIVE/'validation.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result,indent=2))
