from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
paths=['assets/audio/music/monster_house.mp3','scripts/dungeon/boss_intro.gd','assets/audio/music/pond_garden.mp3','docs/audio/sources.md']
names=['00_garden.png','01b_notice.png','01_walk_in.png','02_voice.png','03_shadow_in_pond.png','04_burst.png','06_getting_up_dazed.png','07_shadow_on_ground.png','08_slam.png','09b_wipe.png','09_warden_talks.png','10_fight.png','README.md','warden_entrance.mp4']
paths+=['docs/design/boss-intro-2026-10-10/'+n for n in names]
accepted={r:{'sha256':hashlib.sha256((L/r).read_bytes()).hexdigest(),'reason':'Claude concurrent Warden pond-garden scene/music refresh; current source/docs inspected, retained without writes.'} for r in paths}
(W/'accepted-post-preinstall.json').write_text(json.dumps(accepted,indent=2))
audio=accepted['assets/audio/music/monster_house.mp3']['sha256']
p=W/'audit.py';s=p.read_text();s=s.replace("asset_exceptions={'assets/audio/_440hz_originals/retuned.txt':",f"asset_exceptions={{'assets/audio/music/monster_house.mp3':'{audio}','assets/audio/_440hz_originals/retuned.txt':");p.write_text(s)
p=W/'README.md';s=p.read_text();s+='\n\nInstalled verification: 27 entrance checks, town reachability/all 12 services and paired Hall-door checks pass in the live game. The actual entry exercised Claude\'s current dungeon. Inspected and retained concurrent Warden introduction/pond-garden captures and music refresh, including Monster House\'s newly replaced track; exact hash exceptions are restricted to these files and its audio retuning record. Creature and world source art is unchanged. No natural dungeon clear is claimed.\n';p.write_text(s)
print('Recorded inspected, bounded concurrent files; no live writes.')
