from pathlib import Path
import hashlib,json,re,shutil,subprocess,sys,os
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=W/'texture-project'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text())
P.mkdir(exist_ok=True);(P/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Muskin texture import"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
for rel,h in owned.items():
 assert sha(L/rel)==sha(W/'originals'/rel),rel+' concurrently changed'
 d=P/rel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'prepared'/rel,d);shutil.copy2(L/(rel+'.import'),P/(rel+'.import'))
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(P),'--headless','--editor','--import']
env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=str(W/'import-local-profile')
r=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW);log=r.stdout+r.stderr;(W/'import.log').write_text(log);(W/'import-command.json').write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':r.returncode},indent=2));assert r.returncode==0 and 'ERROR:' not in log,log
cache=[]
for rel,h in owned.items():
 assert sha(L/rel)==sha(W/'originals'/rel),rel
 text=(L/(rel+'.import')).read_text();ctex=re.search(r'^path="res://([^\"]+)"',text,re.M).group(1)
 assert ctex.startswith('.godot/imported/') and (P/ctex).is_file()
 assert (P/(rel+'.import')).read_text()==text,'Import metadata changed'
 shutil.copy2(W/'prepared'/rel,L/rel)
 for c in (Path(ctex),Path(ctex).with_suffix('.md5')):
  assert (P/c).is_file();shutil.copy2(P/c,L/c);cache.append(c.as_posix())
(W/'cache-installed.json').write_text(json.dumps(cache,indent=2));print('Installed three guarded PNGs and their exact imported cache pairs; import metadata unchanged.')
