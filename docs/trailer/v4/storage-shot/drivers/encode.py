from pathlib import Path
import subprocess,json,re,hashlib
from PIL import Image,ImageDraw
W=Path(__file__).parent;V=W/'review';OUT=W/'delivery';OUT.mkdir(exist_ok=True)
log=(V/'record.log').read_text(encoding='utf-8',errors='replace')
assert 'STORAGE SHOT: 12/12' in log and 'Done recording movie' in log and 'ERROR:' not in log
meta=json.loads((V/'shot-markers.json').read_text(encoding='utf-8'));assert len(meta['checks'])==12 and all(c['passed'] for c in meta['checks'])
markers={m['name']:m['frame'] for m in meta['markers']}
segment=re.search(r'^SEG storage (\d+) (\d+)$',log,re.M);assert segment
start,end=map(int,segment.groups());raw=V/'raw.avi';commands=[]
def run(args):
    commands.append(args)
    return subprocess.run(args,check=True,capture_output=True,text=True,encoding='utf-8',errors='replace')
def probe(path):return json.loads(run(['ffprobe','-v','error','-count_frames','-show_entries','format=duration,size:stream=codec_name,codec_type,width,height,r_frame_rate,nb_read_frames','-of','json',str(path)]).stdout)
raw_info=probe(raw);video=[s for s in raw_info['streams'] if s['codec_type']=='video'][0]
assert (video['width'],video['height'],video['r_frame_rate'])==(1152,648,'30/1')
movie_frames=int(video['nb_read_frames']);assert movie_frames==int(re.search(r'RECORDED (\d+) frames',log).group(1))+1
mp4=OUT/'storage_room.mp4';gif=OUT/'storage_room.gif'
run(['ffmpeg','-v','error','-y','-i',str(raw),'-vf',f'trim=start_frame={start}:end_frame={end},setpts=PTS-STARTPTS', '-af',f'atrim=start={start/30:.9f}:end={end/30:.9f},asetpts=PTS-STARTPTS','-c:v','libx264','-preset','medium','-crf','18','-pix_fmt','yuv420p','-c:a','aac','-b:a','160k','-movflags','+faststart',str(mp4)])
gif_start=markers['storage_shelves'];gif_end=markers['storage_withdraw']+60
filt=f'[0:v]trim=start_frame={gif_start}:end_frame={gif_end},setpts=PTS-STARTPTS,fps=15,scale=768:432:flags=neighbor,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3'
run(['ffmpeg','-v','error','-y','-i',str(raw),'-filter_complex',filt,'-an','-loop','0',str(gif)])
info=probe(mp4);v=[s for s in info['streams'] if s['codec_type']=='video'][0]
assert int(v['nb_read_frames'])==end-start and v['width']==1152 and v['height']==648 and v['r_frame_rate']=='30/1'
im=Image.open(gif);duration=0
for n in range(im.n_frames):im.seek(n);duration+=im.info.get('duration',0)
assert im.size==(768,432) and im.n_frames>100
audio=run(['ffmpeg','-hide_banner','-i',str(mp4),'-vn','-af','volumedetect','-f','null','-']).stderr
assert 'max_volume: -inf' not in audio and 'max_volume:' in audio
(OUT/'audio-measurement.txt').write_text(audio,encoding='utf-8')
samples=[]
for name in ['storage_interior','storage_shelves','storage_deposit','storage_withdraw','storage_return']:
    frame=markers[name]+15;dest=OUT/(name+'.png')
    run(['ffmpeg','-v','error','-y','-i',str(raw),'-vf',rf'select=eq(n\,{frame})','-frames:v','1',str(dest)])
    samples.append((name,frame,dest))
sheet=Image.new('RGB',(1152,3*350),(22,29,25));draw=ImageDraw.Draw(sheet)
for n,(name,frame,p) in enumerate(samples):
    tile=Image.open(p).convert('RGB').resize((576,324),Image.Resampling.NEAREST)
    x=(n%2)*576;y=(n//2)*350
    sheet.paste(tile,(x,y+24));draw.text((x+8,y+6),f'{name} / raw frame {frame}',fill=(244,232,210))
sheet.save(OUT/'contact-sheet.png')
receipt={'source':'live Godot Movie Maker, scripted scene setup, no generative video','mode':'storage-only','native_checks':12,'raw':raw_info,'raw_frame_offset_note':'Recorder process count is one frame below total movie frames, as measured. Cuts use literal logged frame indices; review samples are taken from those raw indices.','mp4':info,'segment_frames':[start,end],'gif':{'size':list(im.size),'frames':im.n_frames,'duration_seconds':duration/1000,'raw_frame_range':[gif_start,gif_end],'fps':15,'palette_colors_max':128,'resize':'nearest; main MP4 remains native resolution'},'audio_peak_db':re.search(r'max_volume: ([^\r\n]+)',audio).group(1),'sample_frames':{name:frame for name,frame,p in samples},'full_eight_segment_branch_recorded':False,'full_script_parse_checked':True}
(OUT/'verification.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
(OUT/'edit-commands.json').write_text(json.dumps(commands,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in receipt.items() if k not in ['raw','mp4']},indent=2))
