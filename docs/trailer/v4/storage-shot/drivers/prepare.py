from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
protected={}
for folder in ['scripts','scenes','data','dialogue','tools/trailer']:
    for p in (R/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc':protected[p.relative_to(R).as_posix()]=sha(p)
for p in (R/'docs/trailer/v3').iterdir():
    if p.is_file():protected[p.relative_to(R).as_posix()]=sha(p)
for p in (R/'docs/pitch/feedback-post-2026-10-12').glob('*.gif'):protected[p.relative_to(R).as_posix()]=sha(p)
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
source=(R/'tools/trailer/record_pitch_v3.gd').read_text(encoding='utf-8');(W/'original-record_pitch_v3.gd').write_text(source,encoding='utf-8')
v4=source.replace('record_pitch_v3.gd','record_pitch_v4.gd').replace('cut_pitch_v3.py','a future cut_pitch_v4.py').replace('docs/trailer/v3/raw.avi','docs/trailer/v4/raw.avi').replace('user://pitch_capture.save','user://pitch_capture_v4.save')
v4=v4.replace('extends SceneTree\n','extends SceneTree\n## V4 (Codex,2026-10-14): current indoor Storage shot, derived from Claude\'s preserved V3.\n## --storage-only records only the exact shared Storage segment. Full eight-shot branch is not yet re-recorded.\n',1)
v4=v4.replace('var _seg_start := 0','var _seg_start := 0\nvar _checks: Array = []\nvar _markers: Array = []\nvar _review := ""',1)
v4=v4.replace('\t_base = Engine.get_process_frames()','\t_base = Engine.get_process_frames()\n\tTeamState.save_path = SAVE\n\t_review = OS.get_environment("HT_CAPTURE_REVIEW")\n\tif _review == "": _review = ProjectSettings.globalize_path("user://pitch_v4_review")\n\tDirAccess.make_dir_recursive_absolute(_review)\n\tif "--storage-only" in OS.get_cmdline_user_args():\n\t\tvar good := await _storage_shot()\n\t\tawait _finish_capture(good)\n\t\treturn',1)
v4=v4.replace('\tTeamState.save_path = TeamState.SAVE_PATH','\t# Keep every shot on this recorder\'s private save path.',1)
start=v4.index('\t# 6. The Storage:');end=v4.index('\t# 7. Growth at the shrine:',start)
v4=v4[:start]+'\t# 6. Current Storage room: entry, counter, deposit/withdraw and exit.\n\tif not await _storage_shot():\n\t\tawait _finish_capture(false)\n\t\treturn\n\n'+v4[end:]
old='\tprint("RECORDED %d frames" % _now())\n\tquit()'
assert old in v4;v4=v4.replace(old,'\tawait _finish_capture(true)',1)
v4+='\n\n'+(W/'storage-segment.gdpart').read_text(encoding='utf-8')
out=W/'prepared/tools/trailer/record_pitch_v4.gd';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(v4,encoding='utf-8')
assert not (R/'tools/trailer/record_pitch_v4.gd').exists()
print('Prepared V4 recorder; protected',len(protected),'current sources, V3 root files and four GIFs.')
