"""Stage a bounded Clinkerhide south-walk curl cleanup for review, never edit live art.

The generated tail curl protrudes above/right of the crest in frames1/2/3 and
above/left in frames5/6/7. Explicit source-canvas row spans remove only the
curved protrusions and their narrow join. Frames0/4, actual crest peaks, all
body/feet and other directions stay literal. This is an audited alpha/support
exception, not a palette-only claim. The cell grid is fixed at144x144 (576x288
sheet). Originals are retained and every removed pixel has local/sheet coords.

--source is the preserved original south sheet; --input can be a palette-fixed
copy with identical alpha. Outputs go only to a chosen review folder, alongside
masks, overlays, a same-palette before/after and source/final game3x contact.
"""
from pathlib import Path
import argparse,hashlib,json,sys
import numpy as np
from PIL import Image,ImageDraw
PROJECT_PATH='docs/creatures/arena-starters-2026-10-07/walk/clinkerhide_s_sheet.png'
# Inclusive (y,x_start,x_end). Source crest peak positions are outside these spans.
SPANS={
1:[(24,79,83),(25,77,84),(26,83,85),(27,84,86),(28,84,86),(29,84,86),(30,84,86),(31,83,86),(32,82,86),(33,84,85),(34,84,85),(35,84,84),(36,84,84)],
2:[(20,80,84),(21,79,85),(22,84,86),(23,85,86),(24,86,87),(25,86,87),(26,86,87),(27,86,87),(28,84,87),(29,82,87),(30,80,87),(31,82,86),(32,84,85)],
3:[(20,78,79),(21,78,80),(22,80,81),(23,81,82),(24,82,83),(25,82,83),(26,82,83),(27,81,83),(28,79,83),(29,80,82),(30,81,81)],
5:[(25,66,69),(26,64,70),(27,64,67),(28,63,65),(29,62,64),(30,62,64),(31,62,64),(32,62,66),(33,62,66),(34,62,64),(35,62,64),(36,62,64),(37,62,64),(38,62,64),(39,62,64)],
6:[(23,63,68),(24,62,64),(25,61,63),(26,60,62),(27,60,61),(28,59,61),(29,59,61),(30,59,61),(31,59,62),(32,59,63),(33,59,64),(34,60,64),(35,60,63),(36,61,62)],
7:[(25,64,68),(26,62,69),(27,61,64),(28,60,62),(29,60,62),(30,60,63),(31,60,65),(32,61,66),(33,62,64),(34,63,63)],
}
W=Path(__file__).resolve().parent.parent
ap=argparse.ArgumentParser();ap.add_argument('--source',type=Path,required=True);ap.add_argument('--input',type=Path);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--project',type=Path,default=Path('C:/Users/pmcga/dev/hollowtide'))
args=ap.parse_args();src=args.source;inp=args.input or src;O=args.output;O.mkdir(parents=True,exist_ok=True)
original=np.array(Image.open(src).convert('RGBA'));a=np.array(Image.open(inp).convert('RGBA'))
assert a.shape==original.shape==(288,576,4),'Expected exactly576x288 south sheet with144px cells'
assert np.array_equal(a[...,3],original[...,3]),'Input geometry differs from preserved original'
mask=np.zeros(a.shape[:2],bool);pixels=[];cw=144
for i,rows in SPANS.items():
 for y,x0,x1 in rows:
  for x in range(x0,x1+1):
   sx=x+(i%4)*cw;sy=y+(i//4)*cw
   if original[sy,sx,3]==0:continue
   assert not mask[sy,sx]
   mask[sy,sx]=True;pixels.append({'project_path':PROJECT_PATH,'frame':i,'xy':[x,y],'sheet_xy':[sx,sy],'original_rgba':original[sy,sx].tolist(),'input_rgba':a[sy,sx].tolist(),'after_rgba':[0,0,0,0]})
b=a.copy();b[mask]=0
assert np.array_equal(b[~mask],a[~mask]),'Unaudited pixel change'
for i in range(8):
 sy=(i//4)*cw;sx=(i%4)*cw;old=a[sy:sy+cw,sx:sx+cw];new=b[sy:sy+cw,sx:sx+cw]
 oy=np.nonzero(old[...,3]>0)[0];ny=np.nonzero(new[...,3]>0)[0]
 assert int(oy.max())==int(ny.max()),'Foot row changed'
 if i in (0,4):assert np.array_equal(old,new),'Control frame changed'
Image.fromarray(b).save(O/'clinkerhide_s_sheet_curl_removed_PROPOSAL.png')
ma=np.zeros_like(a);ma[mask]=[255,40,40,255];Image.fromarray(ma).save(O/'curl_removal_mask.png')
def checker(shape):
 yy,xx=np.mgrid[:shape[0],:shape[1]];v=((xx//8+yy//8)%2)*9+32;return np.repeat(v[...,None],3,axis=2).astype(np.uint8)
over=Image.fromarray(checker(a.shape[:2]));over.paste(Image.fromarray(original),(0,0),Image.fromarray(original));rgb=np.array(over);rgb[mask]=[255,40,40];Image.fromarray(rgb).resize((1152,576),Image.Resampling.NEAREST).save(O/'original_curl_mask_overlay2x.png')
sys.path.insert(0,str(args.project/'tools/arena'));from downscale import shrink
for label,top in [('source_original_then_final',original),('palette_input_then_same_palette_repair',a)]:
 contact=Image.new('RGB',(8*156,2*164),(22,34,28));dr=ImageDraw.Draw(contact)
 for row,aa in enumerate([top,b]):
  dr.text((6,row*164+2),'original source' if row==0 and label.startswith('source_') else 'palette input' if row==0 else 'curl removed PROPOSAL',fill='white')
  for i in range(8):
   sx=(i%4)*cw;sy=(i//4)*cw;fr=Image.fromarray(aa[sy:sy+cw,sx:sx+cw]);sm=shrink(fr,3);large=sm.resize((144,144),Image.Resampling.NEAREST)
   dr.text((i*156+5,row*164+16),f'f{i}',fill='white');contact.paste(large,(i*156+5,row*164+20),large)
 contact.save(O/(label+'_game3x.png'))
record={'status':'PROPOSAL ONLY; no live or candidate asset changed','project_path':PROJECT_PATH,'source_path':str(src),'input_path':str(inp),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'input_sha256':hashlib.sha256(inp.read_bytes()).hexdigest(),'output_sha256':hashlib.sha256((O/'clinkerhide_s_sheet_curl_removed_PROPOSAL.png').read_bytes()).hexdigest(),'sheet_canvas':[576,288],'cell_canvas':[144,144],'frames_changed':[1,2,3,5,6,7],'control_frames_exact':[0,4],'foot_rows_exact':True,'all_unmasked_rgba_exact':True,'geometry_exception':'Removal of documented generated external thin curled tail above crest; alpha/support changes only at audited coordinates. No intended head/body redraw.','removed_pixels_total':len(pixels),'removed_by_frame':{str(i):sum(p['frame']==i for p in pixels) for i in range(8)},'row_spans_inclusive':{str(i):v for i,v in SPANS.items()},'pixels':pixels,'repairs':[{'path':PROJECT_PATH,'sheet_pixels_xy':[p['sheet_xy'] for p in pixels],'frames_changed':[1,2,3,5,6,7],'reason':'Documented generated thin external curl above crest; bounded alpha-removal exception','removed_pixels_total':len(pixels)}],'geometry_repairs':[{'path':PROJECT_PATH,'frame':p['frame'],'xy':p['xy'],'sheet_xy':p['sheet_xy'],'before_alpha':p['original_rgba'][3],'after_alpha':0} for p in pixels]}
(O/'curl-removal-proposal.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({k:record[k] for k in ('status','frames_changed','control_frames_exact','foot_rows_exact','all_unmasked_rgba_exact','removed_pixels_total','removed_by_frame')},indent=2))
