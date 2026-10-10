from pathlib import Path
from PIL import Image,ImageSequence,ImageDraw
import urllib.request,json,collections,sys
W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
R=C/'assets/sprites/menu/village_actors_2026_10_09'
manifest=json.loads((W/'frame-preparation.json').read_text()) if (W/'frame-preparation.json').exists() else {}
for form in sys.argv[1:]:
    receipt=json.loads((W/(form+'-result.json')).read_text())
    assert receipt['status']=='succeeded'
    raw=W/(form+'-raw.gif')
    urllib.request.urlretrieve(receipt['result']['output_urls'][0],raw)
    gif=Image.open(raw)
    frames=[];details=[]
    for index,frame in enumerate(ImageSequence.Iterator(gif)):
        im=frame.convert('RGBA')
        assert im.size==(80,80),(form,index,im.size)
        # Clear only exterior neutral white matte; preserve white body pixels.
        pix=im.load();seen=set();todo=collections.deque()
        def allowed(x,y):
            r,g,b,a=pix[x,y]
            return a<128 or (min(r,g,b)>=248 and max(r,g,b)-min(r,g,b)<=5)
        for x in range(80):
            for y in [0,79]:
                if allowed(x,y):todo.append((x,y));seen.add((x,y))
        for y in range(80):
            for x in [0,79]:
                if allowed(x,y):todo.append((x,y));seen.add((x,y))
        removed=0
        while todo:
            x,y=todo.popleft()
            if pix[x,y][3]>0:removed+=1
            pix[x,y]=(*pix[x,y][:3],0)
            for dx,dy in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(1,-1),(-1,1),(1,1)]:
                q=(x+dx,y+dy)
                if 0<=q[0]<80 and 0<=q[1]<80 and q not in seen and allowed(*q):seen.add(q);todo.append(q)
        box=im.getchannel('A').getbbox()
        assert box and min(box[:2])>1 and max(box[2:])<79,(form,index,'clipped',box)
        dst=R/form/f'frame_{index:02d}.png';dst.parent.mkdir(parents=True,exist_ok=True);im.save(dst)
        frames.append(im)
        details.append({'index':index,'used':list(box),'exterior_matte_pixels':removed,'raw_duration_ms':frame.info.get('duration',0)})
    assert len(frames)>=4,(form,'Insufficient frames')
    atlas=Image.new('RGBA',(80*len(frames),80))
    for i,im in enumerate(frames):atlas.alpha_composite(im,(i*80,0))
    atlas.save(W/(form+'-atlas.png'))
    cols=4;rows=(len(frames)+cols-1)//cols
    board=Image.new('RGB',(cols*168,rows*184),(52,61,52));draw=ImageDraw.Draw(board)
    for i,im in enumerate(frames):
        at=((i%cols)*168,(i//cols)*184)
        board.paste(im.resize((160,160),Image.Resampling.NEAREST),(at[0]+4,at[1]+3),im.resize((160,160),Image.Resampling.NEAREST))
        draw.text((at[0]+4,at[1]+166),str(i),fill=(250,224,174))
    board.save(W/(form+'-frame-review.png'))
    alpha=frames[0].getchannel('A').getbbox()
    manifest[form]={'frame_count':len(frames),'canvas':[80,80],'anchor':[40,alpha[3]],'frames':details,'source_task':receipt['task_id']}
(W/'frame-preparation.json').write_text(json.dumps(manifest,indent=2))
(R/'animations.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps({form:{'frames':m['frame_count'],'anchor':m['anchor']} for form,m in manifest.items()}))
