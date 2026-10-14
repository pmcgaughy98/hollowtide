from pathlib import Path
import shutil
W=Path(__file__).parent;p=W/'prepared/tools/trailer/record_pitch_v4.gd'
if not (W/'take1/recorded-script.gd').exists():shutil.copy2(p,W/'take1/recorded-script.gd')
t=p.read_text(encoding='utf-8')
t=t.replace('await _read(low, 30 * 48, 45)','await _read(low, 30 * 90, 45)',1)
t=t.replace('if talk == null or talk.is_empty():\n\t\t\tsince = 0','if talk == null or talk.is_empty():\n\t\t\tif not host.cutscene: return\n\t\t\tsince = 0',1)
t=t.replace('\twhile is_instance_valid(bd) and _scene() == "dungeon.tscn" and guard < 30 * 75:', '\tvar held := 0\n\tvar starward_marked := false\n\tvar stone_marked := false\n\twhile is_instance_valid(bd) and _scene() == "dungeon.tscn" and guard < 30 * 150:',1)
old='\t\tif not talk.is_empty() and guard % 55 == 0:\n\t\t\tbd.act_talk()'
new='''		if not talk.is_empty():
			if String(talk[0][0]) == "Starward" and not starward_marked:
				starward_marked=true
				_mark("standoff_starward");await _still("full_standoff_starward")
			if bool(UI._line.get("done",false)):
				held+=1
				if held>=45:
					bd.act_talk();held=0
			else: held=0
		else: held=0
		if bd.intro.has("stone") and not stone_marked:
			stone_marked=true
			_mark("stone_rises");await _still("full_stone_rises")'''
assert old in t;t=t.replace(old,new,1)
p.write_text(t,encoding='utf-8')
print('Capture waits for completed mail call and readable Warden pages; adds Starward/stone edit markers. Gameplay unchanged.')
