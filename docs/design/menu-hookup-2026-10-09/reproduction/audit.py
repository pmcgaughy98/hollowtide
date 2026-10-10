from pathlib import Path
import hashlib,json
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text())
owned={item['path'] for item in pending}
protected=json.loads((W/'preinstall-protected.json').read_text())
changed=[]
for r,h in protected.items():
    if r in owned: continue
    actual=sha(L/r) if (L/r).exists() else None
    if actual!=h: changed.append({'path':r,'preinstall':h,'now':actual})
assert not changed,('Protected files changed after installation; inspect concurrency',changed)
for item in pending: assert sha(L/item['path'])==item['after'],'Installed source changed: '+item['path']
for name in ['menu_check','quit_title','quit_pause','town_loop_check','music_check']:
    log=(W/('live_'+name+'.log')).read_text()
    errors=[line for line in log.splitlines() if ('ERROR:' in line or 'Parse Error' in line or 'Failed loading' in line) and 'Failed to read the root certificate store' not in line]
    assert not errors,(name,errors)
assert 'CHECKS 44 FAILURES 0' in (W/'live_menu_check.log').read_text()
music=(W/'live_music_check.log').read_text()
for expected in ['town at home: highbank','by the Hall: wayline_hall','at the ferry landing: ferry_landing','B1F: hollow','B1F, lantern low: deep_hollow','a Monster House springs: monster_house','a rest floor: rest_floor','the boss floor, its scene: boss_scene','the boss fight: guardian','jingle victory','jingle recruit','jingle evolution','jingle fainted']: assert expected in music,expected
result={'runtime_files':pending,'protected_files_checked':len(protected)-len(owned.intersection(protected)),'protected_changes_after_install':changed,'concurrent_changes_preserved':json.loads((W/'concurrent-before-install.json').read_text()),'live_native_checks':44,'failures':[],'quit_title':'native click confirmation exits 0','quit_pause':'native click confirmation exits 0','town_loop':'real scenes, forced clear/faint, record retained','music':'existing routes/jingles, actual title/town playback checks','scope':'menu only; no disk saves, map/rules/audio/creature asset rewrite','engine':'Godot 4.7.2 native compatibility; isolated APPDATA','known_diagnostic':'Pre-existing Windows root certificate store message only'}
(W/'installation.json').write_text(json.dumps(result,indent=2))
print('Installed menu verified:',result['live_native_checks'],'native checks;',result['protected_files_checked'],'protected source files exact.')
