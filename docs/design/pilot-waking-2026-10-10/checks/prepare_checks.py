from pathlib import Path
import shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
shutil.copy2(Path('D:/dev/hollowtide-wilds-selout-20261010/run.py'),W/'run.py')
s=(L/'tools/debug/soul_prologue_check.gd').read_text().replace('res://docs/design/soul-prologue-2026-10-10/',str(W).replace('\\','/')+'/review/soul/')
s=s.replace('\tquit()','''\tfor n in root.get_children():n.queue_free()
\tload("res://scripts/audio/music.gd")._inst=null
\tfor k in 12:await process_frame
\tquit(0 if ok_hand and ok_wake else 1)''')
(W/'soul_check.gd').write_text(s)
s=(L/'tools/debug/town_loop_check.gd').read_text()
s=s.replace('var presses := 0','var presses := 0\n\tvar loop_ok := true')
s=s.replace('\tif _scene() != "hub_town.tscn":','\tloop_ok = _scene() == "hub_town.tscn" and TeamState.data.get("party",[]) == [[0,0],[1,0]]\n\tif _scene() != "hub_town.tscn":')
s=s.replace('\t# 3. Things to carry home','\tloop_ok = loop_ok and _scene() == "dungeon.tscn" and dg.return_to_town\n\t# 3. Things to carry home')
s=s.replace('\t# 4. The next run','\tloop_ok = loop_ok and _scene() == "hub_town.tscn" and TeamState.data.get("bag",{}).get("lamp_oil",0) == 2\n\t# 4. The next run')
s=s.replace('\t# 5. A faint','\tloop_ok = loop_ok and dg.bag.get("lamp_oil",0) == 2 and dg.taught.has(key) and dg.iq.get(dg.party[1][0],0) == 7\n\t# 5. A faint')
s=s.replace('\tquit()','''\tloop_ok = loop_ok and _scene() == "hub_town.tscn" and TeamState.data.get("bag",{}).is_empty()
\tfor n in root.get_children():n.queue_free()
\tload("res://scripts/audio/music.gd")._inst=null
\tawait _frames(12)
\tprint("TOWN LOOP ","PASS" if loop_ok else "FAIL")
\tquit(0 if loop_ok else 1)''')
(W/'town_loop_check.gd').write_text(s)
print('Prepared current Claude checks with isolated output, cleanup and loop assertions.')
