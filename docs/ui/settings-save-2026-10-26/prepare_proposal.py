from pathlib import Path
import difflib,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
p=L/'scripts/ui/ui_style.gd';old=p.read_text(encoding='utf-8')
needle='\t\t\tDirAccess.rename_absolute(main, main + ".bak")   # replaces the older .bak\n\t\terr = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), main)'
replacement='\t\t\terr = DirAccess.copy_absolute(main, main + ".bak")   # keep the final readable until replacement\n\t\tif err == OK:\n\t\t\terr = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), main)'
assert old.count(needle)==1
new=old.replace(needle,replacement)
folder=W/'proposal';folder.mkdir(exist_ok=True)
(folder/'ui_style.gd').write_text(new,encoding='utf-8')
# Stop at the exact point after backing up and before replacing, by returning a controlled error in this private variant.
rename='\t\t\terr = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), main)'
assert new.count(rename)==1
(folder/'ui_style_interrupted.gd').write_text(new.replace(rename,'\t\t\terr = ERR_BUSY   # private interruption fixture, after the backup copy'),encoding='utf-8')
(folder/'shared-pause-save.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/scripts/ui/ui_style.gd',tofile='b/scripts/ui/ui_style.gd')),encoding='utf-8')
(folder/'source.json').write_text(json.dumps({'source':'scripts/ui/ui_style.gd','source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'status':'PROPOSED ONLY; Claude pass7 owns live file; not installed'},indent=2),encoding='utf-8')
print('Prepared a three-line shared-helper proposal; live shared source untouched.')
