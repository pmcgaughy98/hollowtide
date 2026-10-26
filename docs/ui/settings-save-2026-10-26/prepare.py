from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'))
base={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(base,indent=2),encoding='utf-8')
for rel in ('scripts/main_menu.gd','scripts/ui/ui_style.gd','scripts/ui/game_pause_menu.gd','tools/debug/rebind_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
raw=(L/'scripts/main_menu.gd').read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n'
edits=[
('var config := ConfigFile.new()\n\tconfig.set_value("audio", "master", _master_volume)', 'var config := ConfigFile.new()\n\tconfig.load(PREFERENCES)   # keep keys this menu does not edit\n\tconfig.set_value("audio", "master", _master_volume)'),
('var error := config.save(PREFERENCES)\n\tif error == OK:\n\t\t_settings_dirty = false', 'var error := config.save(PREFERENCES + ".tmp")\n\tif error == OK:\n\t\terror = DirAccess.rename_absolute(ProjectSettings.globalize_path(PREFERENCES + ".tmp"), ProjectSettings.globalize_path(PREFERENCES))\n\tif error == OK:\n\t\t_settings_dirty = false\n\t\tUI.reload_prefs()\n\t\t_options_status.text = "Changes are saved automatically."')]
for old,new in edits:
    a=old.encode().replace(b'\n',nl);b=new.encode().replace(b'\n',nl);assert raw.count(a)==1,old;raw=raw.replace(a,b)
dest=W/'prepared/scripts/main_menu.gd';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(raw)
print('Preserved',len(base),'current files; prepared a main_menu-only save fix.')
