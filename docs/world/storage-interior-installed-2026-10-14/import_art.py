from pathlib import Path
import hashlib,shutil,os,subprocess,re,json
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=W/'import-project'
folder=Path('assets/sprites/world/storage_interior_2026_10_14');P.mkdir(exist_ok=True)
template=(S/'assets/sprites/ui/item/parcel.png.import').read_text(encoding='utf-8');old=re.search(r'path="([^"]+)"',template).group(1)
names=[p.relative_to(W/'prepared'/folder).as_posix() for p in (W/'prepared'/folder).rglob('*.png')]
for name in names:
    path='res://'+(folder/name).as_posix();ctex='res://.godot/imported/'+Path(name).name+'-'+hashlib.md5(path.encode()).hexdigest()+'.ctex'
    text=template.replace(old,ctex).replace('res://assets/sprites/ui/item/parcel.png',path);text=re.sub(r'^uid=.*\n','',text,flags=re.M)
    dst=P/folder/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'prepared'/folder/name,dst);Path(str(dst)+'.import').write_text(text,encoding='utf-8')
(P/'project.godot').write_text('config_version=5\n[application]\nconfig/name="StorageArtImportFixture"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',encoding='utf-8')
env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=str(W/'import-profile')
with (W/'import-art.log').open('w',encoding='utf-8') as f:
    result=subprocess.run(['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path',str(P),'--editor','--import'],stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW,timeout=60)
log=(W/'import-art.log').read_text(encoding='utf-8');assert result.returncode==0 and 'SCRIPT ERROR' not in log,log[-2000:]
files=[]
for name in names:
    rel=(folder/(name+'.import')).as_posix();meta=(P/rel).read_text(encoding='utf-8');ctex=re.search(r'path="res://([^"]+)"',meta).group(1)
    for item in [rel,ctex,ctex.replace('.ctex','.md5')]:
        dst=S/item;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/item,dst);files.append(item)
(W/'imported-files.json').write_text(json.dumps(files,indent=2),encoding='utf-8')
print('Imported',len(names),'unchanged native room PNGs at lossless/no-mipmap settings.')
