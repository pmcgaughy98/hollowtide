from pathlib import Path
import os,subprocess,json,sys
W=Path(__file__).parent;stage=sys.argv[1];assert stage in ['candidate','live'];env=os.environ.copy();env['APPDATA']=str(W/(stage+'-profile'));env['LOCALAPPDATA']=env['APPDATA'];env['HT_WALK_STAGE']=stage
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'native_check.gd')]
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW);t=p.stdout+p.stderr
(W/('native-'+stage+'.log')).write_text(t,encoding='utf-8');(W/('native-'+stage+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'stage':stage,'exit':p.returncode},indent=2),encoding='utf-8');print(t[-7000:]);assert p.returncode==0 and 'CANVASWING WALK: 64/64' in t and not any(x in t for x in ['SCRIPT ERROR','FAIL'])
