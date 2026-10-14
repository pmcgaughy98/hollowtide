from pathlib import Path
import re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
t=(R/'tools/trailer/cut_pitch_v3.py').read_text(encoding='utf-8')
(W/'original-cut_pitch_v3.py').write_text(t,encoding='utf-8')
t=t.replace('import re\n','import re\nimport os\nimport json\n',1)
t=t.replace('ROOT = Path(__file__).resolve().parents[2]','ROOT = Path(os.environ.get("HT_PITCH_ROOT", Path(__file__).resolve().parents[2]))',1)
t=t.replace('OUT = ROOT / "docs" / "trailer" / "v3"','OUT = Path(os.environ.get("HT_PITCH_OUT", ROOT / "docs" / "trailer" / "v4" / "full"))',1)
t=t.replace('RAW = OUT / "raw.avi"','RAW = Path(os.environ.get("HT_PITCH_RAW", OUT / "raw.avi"))',1)
t=t.replace('SEGS = OUT / "segments.txt"','SEGS = Path(os.environ.get("HT_PITCH_MARKERS", OUT / "shot-markers.json"))\nCOMMANDS = []\nEDIT = []\n_PROBES = {}',1)
a=t.index('SHOTS = [');b=t.index('\n\n\ndef run',a)
t=t[:a]+'''SHOTS = [
    ("cold", "01_storm_open", 1.6, 2),
    ("card", "river", 0, 1),
    ("clip", "mark:flood_partner", 0.15, 1),
    ("clip", "03_ruin_rises", 0.6, 1),
    ("clip", "seg:title_continue", 1.0, 2),
    ("card", "mail", 0, 1),
    ("clip", "mark:mail_early", 0.2, 3),
    ("clip", "seg:mail_call", 24.0, 2),
    ("clip", "mark:board_parcel", 0.4, 2),
    ("card", "turn", 0, 1),
    ("clip", "mark:water_rows_1", 0.2, 2),
    ("clip", "mark:water_rows_2", 0.2, 2),
    ("clip", "v2hollow", 28.3, 2),
    ("card", "home", 0, 1),
    ("clip", "seg:faint", 0.8, 1),
    ("clip", "mark:faint_information", 0.2, 2),
    ("clip", "mark:storage_shelves", 0.1, 2),
    ("clip", "mark:storage_deposit", 0.1, 1),
    ("clip", "mark:storage_withdraw", 0.1, 1),
    ("card", "grow", 0, 1),
    ("clip", "seg:growth", 0.5, 3),
    ("card", "below", 0, 1),
    ("clip", "seg:standoff", 1.0, 2),
    ("clip", "mark:standoff_starward", 0.3, 3),
    ("clip", "mark:stone_rises", 0.0, 1),
    ("end", "end", 0, 3),
]'''+t[b:]
a=t.index('def run(args):');b=t.index('\n\n# The game draws',a)
t=t[:a]+'''def run(args):
    COMMANDS.append(args)
    WORK.mkdir(parents=True,exist_ok=True)
    (OUT / "edit-commands.json").write_text(json.dumps(COMMANDS,indent=2),encoding="utf-8")
    subprocess.run(args, check=True, capture_output=True)

def metadata():
    return json.loads(SEGS.read_text(encoding="utf-8"))

def segments():
    return {s["name"]:(s["first"],s["last"]) for s in metadata()["segments"]}

def source(name: str, start: float, length: float = 0):
    if name.startswith("seg:"):
        a,b=segments()[name[4:]]
        at=a/FPS+start
        assert at+length <= b/FPS+0.001,(name,start,length,(b-a)/FPS)
        return RAW,at
    if name.startswith("mark:"):
        frame=next(m["frame"] for m in metadata()["markers"] if m["name"]==name[5:])
        a,b=next((a,b) for a,b in segments().values() if a<=frame<b)
        at=frame/FPS+start
        assert at+length<=b/FPS+0.001,(name,at,length,b/FPS)
        return RAW,at
    path=V2_HOLLOW if name=="v2hollow" else VIDS/f"{name}.mp4"
    assert path.is_file(),path
    return path,start
'''+t[b:]
t=t.replace('path, at = source(name, start)','path, at = source(name, start, length)\n    EDIT.append({"name":name,"path":str(path),"source_start_seconds":at,"length_seconds":length,"keep_audio":keep_audio})',1)
t=t.replace('"-c:v", "libx264",','"-c:v", "libx264", "-threads", "4",')
t=t.replace('"-preset", "slow"','"-preset", "medium"')
t=t.replace('hollowtide_pitch_v3','hollowtide_pitch_v4')
t=t.replace('    print(f"wrote {final}', '    (OUT / "edit-timeline.json").write_text(json.dumps({"planned_seconds":total,"fps":FPS,"bars":sum(b for *_,b in SHOTS),"shots":SHOTS,"resolved_clips":EDIT},indent=2),encoding="utf-8")\n    print(f"wrote {final}',1)
t=t.replace('def main():\n', 'def main():\n    assert not (OUT / "hollowtide_pitch_v4.mp4").exists() and not (OUT / "hollowtide_pitch_v4_share.mp4").exists(), "Choose a fresh output folder; preserve the previous edit."\n',1)
t=t.replace('        length = bars * BAR','        print(f"SHOT {i+1}/{len(SHOTS)} {name}",flush=True)\n        length = bars * BAR',1)
t=t.replace('subprocess.run(args, check=True, capture_output=True)','subprocess.run(args, check=True, capture_output=True, timeout=180)',1)
head='''"""V4 pitch edit, Codex2026-10-14, derived from Claude's preserved V3 cutter.
Reads the measured V4 segment/shot markers, not V3 timings. Nine current engine segments,
with archival storm/ruin/V2 combat cutaways; exact inputs/edits recorded beside the outputs.
Same proposed cards, bar-line edit, fonts, existing title painting and hollow_flute music.
Use HT_PITCH_ROOT/OUT/RAW/MARKERS for an isolated work output; defaults target docs/trailer/v4/full.
"""'''
t=re.sub(r'^""".*?"""',lambda m:head,t,count=1,flags=re.S)
t=t.replace('    ("clip", "seg:title_continue", 1.0, 2),','    ("clip", "seg:title_continue", 0.0, 1),\n    ("clip", "seg:title_continue", 4.4, 1),',1)
out=W/'prepared/tools/trailer/cut_pitch_v4.py';out.write_text(t,encoding='utf-8')
print('Prepared27-shot V4 edit with measured segment/marker bounds, preserved V3 fonts/cards/music and exact command ledger; Continue transition trimmed around its black fade.')
