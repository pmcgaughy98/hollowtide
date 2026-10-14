from pathlib import Path
import hashlib,json,subprocess,html
from PIL import Image,ImageDraw
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=R/'docs/trailer/v4/full';O=W/'delivery';O.mkdir(exist_ok=True)
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
protected={}
for folder in ['scripts','scenes','data','dialogue','tools/trailer','docs/trailer/v4/full','docs/trailer/v4/storage-shot','docs/trailer/v3','docs/pitch/feedback-post-2026-10-12']:
    for p in (R/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc':protected[p.relative_to(R).as_posix()]=sha(p)
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
meta=json.loads((S/'shot-markers.json').read_text());markers={m['name']:m['frame'] for m in meta['markers']};segments={s['name']:(s['first'],s['last']) for s in meta['segments']}
clips=[
 ('mail_call','The mail call','Routes and crew portraits in the Sorting Floor.',markers['mail_early'],196,'mail_call'),
 ('water_rises','The rising water','The painted shoreline rises while all three creatures stay visible.',markers['water_rows_1'],240,'water'),
 ('carried_home','Carried home','The partner reacts, then the defeat screen names what was lost and kept.',segments['faint'][0]+30,240,'faint'),
 ('standoff','The stand-off','Starward steps in, and the Quietwater Warden answers.',markers['standoff_starward']+9,240,'standoff'),
 ('storage','Keeping supplies','Inside Storage: one Reedberry put in, then taken out.',markers['storage_shelves'],240,'storage'),
]
commands=[];results=[]
def run(args):
    commands.append(args);(O/'commands.json').write_text(json.dumps(commands,indent=2),encoding='utf-8')
    p=subprocess.run(args,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180)
    assert p.returncode==0,(args,p.stderr[-2500:]);return p
for name,title,caption,first,count,seg in clips:
    assert not (O/(name+'.gif')).exists();a,b=segments[seg];assert a<=first and first+count<=b
    out=O/(name+'.gif');mp4=O/(name+'.mp4');seconds=count/30
    filt='fps=15,scale=768:432:flags=neighbor,split[s0][s1];[s0]palettegen=stats_mode=full[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3'
    run(['ffmpeg','-v','error','-ss',f'{first/30:.9f}','-t',f'{seconds:.9f}','-i',str(S/'raw.avi'),'-an','-filter_complex',filt,'-loop','0',str(out)])
    run(['ffmpeg','-v','error','-ss',f'{first/30:.9f}','-t',f'{seconds:.9f}','-i',str(S/'raw.avi'),'-vf','fps=15,scale=768:432:flags=neighbor,setsar=1','-c:v','libx264','-threads','4','-crf','20','-pix_fmt','yuv420p','-an','-movflags','+faststart',str(mp4)])
    with Image.open(out) as im:
        assert im.size==(768,432) and im.n_frames==count//2 and im.info.get('loop')==0
        duration=0;sheet=Image.new('RGB',(1536,2*460),(16,21,17));draw=ImageDraw.Draw(sheet)
        for n in range(im.n_frames):im.seek(n);duration+=im.info['duration']
        for j,n in enumerate([0,count//6,count//3,count//2-1]):
            im.seek(n);x=j%2*768;y=j//2*460;sheet.paste(im.convert('RGB'),(x,y));draw.text((x+8,y+438),f'{title}: frame {n+1}/{im.n_frames}',fill='white')
        sheet.save(O/(name+'-review.jpg'),quality=95)
        im.seek(count//4);im.convert('RGB').save(O/(name+'-poster.jpg'),quality=93)
    probe=json.loads(run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(mp4)]).stdout)
    video=probe['streams'][0];assert video['codec_name']=='h264' and video['avg_frame_rate']=='15/1' and int(video['nb_read_frames'])==count//2
    dec=run(['ffmpeg','-v','error','-i',str(mp4),'-f','null','-']);assert not dec.stderr.strip()
    assert out.stat().st_size<8*1024*1024
    result={'id':name,'title':title,'caption':caption,'source_segment':seg,'source_first_frame':first,'source_last_exclusive':first+count,'source_seconds':seconds,'fps':15,'width':768,'height':432,'frames':count//2,'gif_seconds':duration/1000,'mp4_seconds':float(probe['format']['duration']),'gif_bytes':out.stat().st_size,'mp4_bytes':mp4.stat().st_size,'gif_sha256':sha(out),'mp4_sha256':sha(mp4),'audio':'silent previews; GIF cannot carry audio','review':'pending'}
    results.append(result);print(name,json.dumps(result),flush=True)
(O/'clips.json').write_text(json.dumps({'source_raw':'../../trailer/v4/full/raw.avi','source_raw_sha256':sha(S/'raw.avi'),'source_capture_checks':'26/26; existing completed V4 take3, not rerun','source_fps':30,'clips':results},indent=2),encoding='utf-8')
cards=[]
for c in results:
    name=c['id'];cards.append(f'''<article><h2>{html.escape(c['title'])}</h2><video controls muted loop playsinline preload="metadata" poster="{name}-poster.jpg" aria-label="{html.escape(c['title'])}"><source src="{name}.mp4" type="video/mp4"><a href="{name}.gif">Open GIF</a></video><p>{html.escape(c['caption'])}</p><p class="meta">{c['frames']} frames · {c['gif_seconds']:.2f}s GIF · {c['gif_bytes']/1000000:.2f} MB · 768 × 432</p><p><a href="{name}.gif" download>Download GIF</a> <a href="{name}.mp4" download>Download silent MP4</a></p></article>''')
page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Hollowtide · Current feedback clips</title><style>body{margin:0;background:#101511;color:#f4e8d2;font:17px/1.5 system-ui,sans-serif}main{max-width:1260px;margin:auto;padding:32px 24px}h1{font-size:clamp(28px,4vw,44px);line-height:1.15;margin-bottom:16px}h2{font-size:23px;margin:0 0 14px}header{max-width:900px;margin-bottom:30px}.kicker,.meta{color:#c2b8a4}.kicker{letter-spacing:.12em;text-transform:uppercase;font-size:13px}a{color:#f1d08b;text-underline-offset:4px}a:focus-visible,button:focus-visible,video:focus-visible{outline:3px solid #f1d08b;outline-offset:4px}button{font:inherit;padding:9px 16px;background:#27382c;color:#f4e8d2;border:1px solid #beA06c;border-radius:6px;cursor:pointer}article{background:#1b261e;border:1px solid #647053;border-radius:10px;padding:20px;min-width:0}section{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,500px),1fr));gap:22px}video{width:100%;aspect-ratio:16/9;display:block;background:#080b09;border-radius:4px}article a{display:inline-block;margin-right:18px}.meta{font-size:14px}footer{margin-top:32px;border-top:1px solid #647053;padding-top:20px}p{max-width:75ch}</style><main><header><p class="kicker">Hollowtide · October 14, 2026</p><h1>Five moments from the current slice</h1><p>Mail routes, a rising river, coming home and a place to keep supplies. Play or pause each clip, then download the GIF or smaller silent MP4.</p><p>These are staged recordings of the game. The prototype contains AI-generated art, music, sound effects and narrative, plus AI-assisted code and preparation. No new content was generated for these clips. <a href="../ai-asset-inventory.md">Asset inventory</a></p><button id="pause" type="button">Pause all clips</button></header><section>'''+''.join(cards)+'''</section><footer><p><a href="../../trailer/v4/full/hollowtide_pitch_v4_share.mp4">Full 99.7-second pitch with audio</a> · <a href="README.md">Sources and verification</a></p><p>Silent previews. No automatic playback. Original October 12 GIFs remain preserved. This page is a local review copy; nothing has been posted.</p></footer></main><script>document.getElementById('pause').addEventListener('click',()=>document.querySelectorAll('video').forEach(v=>v.pause()));</script></html>'''
(O/'index.html').write_text(page,encoding='utf-8')
print('BUILT',O,flush=True)
