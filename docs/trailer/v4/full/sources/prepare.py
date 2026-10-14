from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
protected={}
for folder in ['scripts','scenes','data','dialogue','tools/trailer']:
    for p in (R/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc':protected[p.relative_to(R).as_posix()]=sha(p)
for folder in ['docs/trailer/v3','docs/trailer/v4/storage-shot','docs/pitch/feedback-post-2026-10-12']:
    for p in (R/folder).iterdir():
        if p.is_file():protected[p.relative_to(R).as_posix()]=sha(p)
for rel in ['docs/design/videos-2026-10-11/01_storm_open.mp4','docs/design/videos-2026-10-11/03_ruin_rises.mp4','docs/design/videos-2026-10-11/07_warden_entrance.mp4','docs/trailer/v2/hollow.avi','assets/audio/music/hollow_flute.mp3']:
    protected[rel]=sha(R/rel)
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
source=(R/'tools/trailer/record_pitch_v4.gd').read_text(encoding='utf-8')
(W/'original-record_pitch_v4.gd').write_text(source,encoding='utf-8')
t=source.replace('Full eight-shot branch is not yet re-recorded.','Full mode also captures a fresh flood conversation and validates each main segment.')
t=t.replace('for tools/trailer/a future cut_pitch_v4.py. Nothing here changes the','for tools/trailer/cut_pitch_v4.py. Nothing here changes the')
t=t.replace('var _checks: Array = []','var _segments: Array = []\nvar _checks: Array = []',1)
t=t.replace('\t_seg_start = _now()','\t_seg_start = _now()\n\t_mark("segment_"+name)',1)
t=t.replace('func _end() -> void:\n','func _end() -> void:\n\t_segments.append({"name":_seg_name,"first":_seg_start,"last":_now()})\n',1)
old='\tif UI.line_done(line):'
assert old in t;t=t.replace(old,'\tif UI.line_done(line) or (UI._line.get("text", "") == line and bool(UI._line.get("done", false))):',1)
old='\t\t\t\tif host.has_method("act_talk"):'
new='\t\t\t\tif not UI.line_done(line):\n\t\t\t\t\tUI.finish_line()   # the next page, as a player presses E\n\t\t\t\telif host.has_method("act_talk"):'
assert old in t;t=t.replace(old,new,1)
t=t.replace('\t# 1. The title with Continue, into Highbank.','\tif not await _flood_shot():\n\t\tawait _finish_capture(false)\n\t\treturn\n\t# 1. The title with Continue, into Highbank.',1)
t=t.replace('\tawait _frames(70)\n\ttitle._on_continue()','\tawait _frames(70)\n\tawait _still("full_title")\n\t_checked("title ready for Continue",not ("_boot_done" in title) or title.get("_boot_done"))\n\ttitle._on_continue()',1)
t=t.replace('\tawait _frames(100)\n\t_end()','\t_checked("Continue enters real Highbank",_scene()=="hub_town.tscn")\n\tawait _frames(100)\n\t_end()',1)
t=t.replace('\tawait _read(low, 30 * 55, 45)','\tawait _read(low, 30 * 7, 45)\n\t_mark("mail_early");await _still("full_mail")\n\tawait _read(low, 30 * 48, 45)\n\t_checked("mail call completes",not low.cutscene and low.talk.is_empty())',1)
t=t.replace('\tif posted.size() >= 2:','\t_checked("board has requests",posted.size()>=2)\n\tif posted.size() >= 2:',1)
t=t.replace('\tawait _frames(70)\n\ttown.act_board_move(1)','\t_checked("taking a delivery puts a Parcel in bag",int(TeamState.data["bag"].get("parcel",0))==1)\n\t_mark("board_parcel");await _still("full_board_parcel")\n\tawait _frames(70)\n\ttown.act_board_move(1)',1)
t=t.replace('\tvar dir := Vector2i(1, 0)','\tvar rows_seen := 0\n\tvar dir := Vector2i(1, 0)',1)
t=t.replace('\t\tawait _frames(12)\n\tawait _frames(30)','\t\tawait _frames(12)\n\t\tif dg.water_rows>rows_seen:\n\t\t\trows_seen=dg.water_rows\n\t\t\t_mark("water_rows_%d"%rows_seen);await _still("full_water_%d"%rows_seen)\n\t_checked("current water reaches at least two painted rows",rows_seen>=2 and _scene()=="dungeon.tscn")\n\tawait _frames(30)',1)
t=t.replace('\tvar fs: Node = current_scene','\t_checked("leader loss reaches actual defeat scene",_scene()=="faint_screen.tscn")\n\tvar fs: Node = current_scene',1)
t=t.replace('\tawait _frames(30 * 6)\n\t_end()','\t_mark("faint_information");await _still("full_defeat")\n\tawait _frames(30 * 6)\n\t_end()',1)
t=t.replace('\tawait _frames(20)\n\n\t# 6. Current Storage room','\t_checked("defeat returns team to town",_scene()=="hub_town.tscn")\n\tawait _frames(20)\n\n\t# 6. Current Storage room',1)
t=t.replace('\tawait _frames(90)\n\t_end()','\t_checked("shrine grows Kithflare to Sparkwick",not town2.evolving_now and TeamState.data["party"][0]==[0,1])\n\t_mark("growth_result");await _still("full_growth_result")\n\tawait _frames(90)\n\t_end()',1)
t=t.replace('\tawait _frames(60)   # the stone carried home: Highbank\'s first frames','\t_checked("Warden stand-off returns to town",_scene()=="hub_town.tscn")\n\t_checked("stand-off carries shrine stone home",TeamState.data.get("story",{}).get("stone","")=="carried")\n\t_mark("standoff_return");await _still("full_standoff_return")\n\tawait _frames(60)   # the stone carried home: Highbank\'s first frames',1)
t=t.replace('func _finish_capture(good: bool) -> void:\n','func _finish_capture(good: bool) -> void:\n\tgood = good and _checks.all(func(c: Dictionary) -> bool:return bool(c["passed"]))\n',1)
t=t.replace('"checks":_checks,"markers":_markers','"checks":_checks,"segments":_segments,"markers":_markers',1)
t=t.replace('\tTeamState.erase_save()\n\tprint("RECORDED','\tvar flood=load("res://dialogue/flood_bank.dialogue")\n\tflood.lines={}   # release capture-only evaluated expressions after all scenes are gone\n\tTeamState.erase_save()\n\tprint("CAPTURE TOTAL: %d/%d"%[_checks.filter(func(c):return c["passed"]).size(),_checks.size()])\n\tprint("RECORDED',1)
t+='\n\n'+(W/'flood.gdpart').read_text(encoding='utf-8')
out=W/'prepared/tools/trailer/record_pitch_v4.gd';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(t,encoding='utf-8')
assert t.count('func _storage_shot()')==1 and t.count('func _flood_shot()')==1
print('Prepared full recorder with fresh flood shot and main-segment checks;',len(protected),'protected files.')
