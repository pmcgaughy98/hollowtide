from pathlib import Path
import hashlib,shutil,os,subprocess,re,json
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=W/'import-project'
folder=Path('assets/sprites/world/rising_water_2026_10_14');(P/folder).mkdir(parents=True,exist_ok=True)
template=(S/'assets/sprites/ui/item/parcel.png.import').read_text(encoding='utf-8')
old=re.search(r'path="([^"]+)"',template).group(1)
for name in ['ripples.png','shoreline.png']:
    path='res://'+(folder/name).as_posix();ctex='res://.godot/imported/'+name+'-'+hashlib.md5(path.encode()).hexdigest()+'.ctex'
    text=template.replace(old,ctex).replace('res://assets/sprites/ui/item/parcel.png',path)
    text=re.sub(r'^uid=.*\n','',text,flags=re.MULTILINE)
    shutil.copy2(W/'art'/name,P/folder/name)
    (P/folder/(name+'.import')).write_text(text,encoding='utf-8')
(P/'project.godot').write_text('config_version=5\n[application]\nconfig/name="RisingWaterImportFixture"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',encoding='utf-8')
env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=str(W/'import-profile')
with (W/'import-art.log').open('w',encoding='utf-8') as f:
    result=subprocess.run(['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path',str(P),'--editor','--import'],stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW,timeout=60)
text=(W/'import-art.log').read_text(encoding='utf-8');assert result.returncode==0 and 'SCRIPT ERROR' not in text,text[-2000:]
files=[]
for name in ['ripples.png','shoreline.png']:
    rel=(folder/(name+'.import')).as_posix();meta=(P/rel).read_text(encoding='utf-8');ctex=re.search(r'path="res://([^"]+)"',meta).group(1)
    for item in [rel,ctex,ctex.replace('.ctex','.md5')]:
        dest=S/item;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/item,dest);files.append(item)
(W/'imported-files.json').write_text(json.dumps(files,indent=2),encoding='utf-8')
print('Both atlas textures imported natively with existing lossless/no-mipmap parameters and staged.')
