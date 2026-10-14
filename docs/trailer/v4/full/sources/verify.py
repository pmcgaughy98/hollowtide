from pathlib import Path
import subprocess,json,hashlib,re,sys,math
from PIL import Image,ImageDraw
W=Path(__file__).parent;D=W/(sys.argv[1] if len(sys.argv)>1 else 'delivery');T=W/'take3';Q=D/'qa';Q.mkdir(exist_ok=True)
commands=[]
def run(args):
    commands.append(args)
    p=subprocess.run(args,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180)
    assert p.returncode==0,(args,p.stderr[-2000:])
    return p
def probe(path):
    return json.loads(run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(path)]).stdout)
def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
meta=json.loads((T/'shot-markers.json').read_text());assert len(meta['segments'])==9
assert len(meta['checks'])==26 and all(c['passed'] for c in meta['checks'])
log=(T/'record.log').read_text(encoding='utf-8');assert 'CAPTURE TOTAL: 26/26' in log
assert not re.search(r'SCRIPT ERROR|ERROR:|WARNING:|FAIL',log)
recorded=int(re.search(r'RECORDED (\d+) frames',log)[1])
probes={};measure={}
for path in [T/'raw.avi',D/'hollowtide_pitch_v4.mp4',D/'hollowtide_pitch_v4_share.mp4']:
    data=probe(path);probes[path.name]=data
    video=next(s for s in data['streams'] if s['codec_type']=='video')
    aud=next(s for s in data['streams'] if s['codec_type']=='audio')
    assert video['avg_frame_rate']=='30/1';assert int(video['nb_read_frames'])>0
    if path.suffix=='.avi':assert int(video['nb_read_frames'])==recorded+1
    else:
        assert (video['width'],video['height'])==(1920,1080)
        assert video['codec_name']=='h264' and aud['codec_name']=='aac'
    measure[path.name]={'seconds':float(data['format']['duration']),'frames':int(video['nb_read_frames']),'width':video['width'],'height':video['height'],'fps':video['avg_frame_rate'],'video_codec':video['codec_name'],'audio_codec':aud['codec_name'],'bytes':path.stat().st_size,'sha256':sha(path)}
    print('PROBED',path.name,measure[path.name],flush=True)
for name in ['hollowtide_pitch_v4.mp4','hollowtide_pitch_v4_share.mp4']:
    p=run(['ffmpeg','-v','error','-i',str(D/name),'-f','null','-'])
    assert not p.stderr.strip(),p.stderr
    (Q/(name+'.decode.log')).write_text('Full audio/video decode completed without errors.\n',encoding='utf-8')
audio=run(['ffmpeg','-hide_banner','-i',str(D/'hollowtide_pitch_v4.mp4'),'-vn','-af','volumedetect','-f','null','-']).stderr
(Q/'audio-volumedetect.log').write_text(audio,encoding='utf-8')
peak=float(re.search(r'max_volume: ([\-\d.]+) dB',audio)[1]);mean=float(re.search(r'mean_volume: ([\-\d.]+) dB',audio)[1])
assert -60<mean<-5 and peak<0,(mean,peak)
black=run(['ffmpeg','-hide_banner','-i',str(D/'hollowtide_pitch_v4.mp4'),'-an','-vf','blackdetect=d=0.25:pix_th=0.05','-f','null','-']).stderr
(Q/'blackdetect.log').write_text(black,encoding='utf-8')
black_ranges=[{'start':float(a),'end':float(b),'duration':float(c)} for a,b,c in re.findall(r'black_start:([\d.]+) black_end:([\d.]+) black_duration:([\d.]+)',black)]
assert all(b['start']>=measure['hollowtide_pitch_v4.mp4']['seconds']-1.25 for b in black_ranges),black_ranges
timeline=json.loads((D/'edit-timeline.json').read_text());shots=timeline['shots'];at=0;bounds=[]
for i,(kind,name,_,bars) in enumerate(shots):
    p=D/'_work'/f'shot{i:02d}.mp4';v=next(s for s in probe(p)['streams'] if s['codec_type']=='video');dur=int(v['nb_read_frames'])/30
    bounds.append({'shot':i+1,'name':name,'kind':kind,'start':at,'duration':dur});at+=dur
assert abs(at-measure['hollowtide_pitch_v4.mp4']['frames']/30)<0.12
for where,offset in [('start',0.15),('middle',None),('end',-0.15)]:
    for group in range(math.ceil(len(bounds)/13)):
        chosen=bounds[group*13:(group+1)*13];sheet=Image.new('RGB',(1920,5*390),(16,21,17));draw=ImageDraw.Draw(sheet)
        for j,b in enumerate(chosen):
            t=b['start']+(b['duration']/2 if offset is None else offset if offset>=0 else b['duration']+offset)
            out=Q/f"shot{b['shot']:02d}_{where}.jpg"
            run(['ffmpeg','-v','error','-ss',f'{t:.4f}','-i',str(D/'hollowtide_pitch_v4.mp4'),'-frames:v','1','-vf','scale=640:360','-q:v','2',str(out)])
            x=(j%3)*640;y=(j//3)*390;sheet.paste(Image.open(out),(x,y));draw.text((x+8,y+365),f"{b['shot']:02d} {b['name']} | {t:.2f}s",fill='white')
        sheet.save(Q/f'contact-{where}-{group+1}.jpg',quality=95)
native=sorted(T.glob('*.png'));sheet=Image.new('RGB',(1920,((len(native)+2)//3)*390),(16,21,17));draw=ImageDraw.Draw(sheet)
for i,p in enumerate(native):
    x=i%3*640;y=i//3*390;sheet.paste(Image.open(p).resize((640,360)),(x,y));draw.text((x+8,y+365),p.stem,fill='white')
sheet.save(Q/'native-stills.jpg',quality=95)
result={'take':'take3','capture_checks':26,'segments':9,'raw_recorded_counter':recorded,'media':measure,'audio_mean_db':mean,'audio_sample_peak_db':peak,'blackdetect_ranges':black_ranges,'decode_full_and_share':'passed','actual_shot_boundaries':bounds,'planned_seconds':timeline['planned_seconds'],'visual_review':'pending human/agent inspection of start/middle/end contacts and native stills'}
(D/'verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
(D/'media-probes.json').write_text(json.dumps(probes,indent=2),encoding='utf-8')
(D/'verification-commands.json').write_text(json.dumps(commands,indent=2),encoding='utf-8')
print('VERIFIED',json.dumps(result),flush=True)
