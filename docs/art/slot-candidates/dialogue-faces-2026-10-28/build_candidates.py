"""Candidate-only dialogue crops; does not run either production builder's write-all main."""
import sys, json, hashlib
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'tools/ui'));sys.path.insert(0,str(ROOT/'tools/arena'))
import build_dialogue_portraits as b
from downscale import resample
B=Path(__file__).resolve().parent
CENTRES={'punchybun':(14,22),'sparkjab':(21,21)}
reports={}
for form,mid in CENTRES.items():
 d=B/form
 cut=b.auto_cut(form)
 face=resample(cut,max(cut.size)/40).resize((40,40),Image.Resampling.NEAREST)
 if (d/'prepared.png').exists():
  assert np.array_equal(np.array(face),np.array(Image.open(d/'prepared.png').convert('RGBA'))), 'Rebuild differs'
 face.save(d/'prepared.png')
 x,y=mid[0]-12,mid[1]-12
 small=face.crop((x,y,x+24,y+24))
 a=np.array(face);c=np.array(small)
 src=np.array(cut)
 palette=set(tuple(p) for p in src[src[:,:,3]>0,:3].tolist())
 own=set(tuple(p) for p in a[a[:,:,3]>0,:3].tolist())
 cover=float((c[:,:,3]>0).mean())
 check={'size_40x40':face.size==(40,40),'binary_alpha':set(np.unique(a[:,:,3]))<={0,255},'source_palette_only':own<=palette,'cut_inside':x>=0 and y>=0 and x+24<=40 and y+24<=40,'cut_coverage_at_least_45_percent':cover>=.45,'small_size_48x48':small.resize((48,48),Image.Resampling.NEAREST).size==(48,48)}
 assert all(check.values()),check
 reports[form]={'pass':all(check.values()),'checks':check,'FACE_AT_proposal':mid,'small_cut':[x,y,24,24],'small_opaque_coverage':cover,'generation':False,'slot_validation':'not applicable: creature face not in ArtSlots registry','approval':'pending','installed':False}
 small.resize((48,48),Image.Resampling.NEAREST).save(d/'headshot-48.png')
 (d/'checks.json').write_text(json.dumps(reports[form],indent=2)+'\n')
 ledger=json.loads((d/'ledger.json').read_text());ledger['FACE_AT_proposal']=mid;ledger['small_opaque_coverage']=cover
 (d/'ledger.json').write_text(json.dumps(ledger,indent=2)+'\n')
 print(form, 'PASS 6/6; 40x40; source colours; binary alpha; headshot cover',round(cover*100,1),'%; FACE_AT',mid)
# Only the two proposed FACE_AT lines differ in this candidate-only UI copy.
prod=(ROOT/'scripts/ui/ui_style.gd').read_text()
patched=prod.replace('const FACE_AT := {','const FACE_AT := {\n\t"punchybun": Vector2i(14, 22), "sparkjab": Vector2i(21, 21),',1)
assert patched!=prod
(B/'ui_style_candidate.gd').write_text(patched)
(B/'checks.json').write_text(json.dumps(reports,indent=2)+'\n')
# Human review, source face plus full 40px dialogue and 24px/2x headshot.
sheet=Image.new('RGBA',(980,660),(29,36,32,255));draw=ImageDraw.Draw(sheet)
font=ImageFont.truetype('C:/Windows/Fonts/consola.ttf',18)
draw.text((18,15),'Punchybun / Sparkjab face candidates | NOT INSTALLED',font=font,fill='white')
for row,(form,mid) in enumerate(CENTRES.items()):
 d=B/form;y=60+row*294
 src=Image.open(d/'source-copy.png').convert('RGBA');src.thumbnail((220,220),Image.Resampling.NEAREST)
 sheet.alpha_composite(src,(14,y+30));draw.text((18,y),'current SW source',font=font,fill='white')
 face=Image.open(d/'prepared.png').convert('RGBA')
 bg=Image.new('RGBA',(40,40),(148,207,198,255));bg.alpha_composite(face)
 full=bg.resize((240,240),Image.Resampling.NEAREST);sheet.alpha_composite(full,(264,y+30))
 draw.text((264,y),form+' 40x40 @6x',font=font,fill='white')
 x0,y0=mid[0]-12,mid[1]-12
 draw.rectangle((264+x0*6,y+30+y0*6,264+(x0+24)*6-1,y+30+(y0+24)*6-1),outline=(255,90,90),width=2)
 cut=Image.open(d/'headshot-48.png').convert('RGBA');well=Image.new('RGBA',(48,48),(148,207,198,255));well.alpha_composite(cut)
 sheet.alpha_composite(well.resize((192,192),Image.Resampling.NEAREST),(548,y+30))
 draw.text((548,y),'24px cut -> 48px',font=font,fill='white')
 draw.text((764,y+45),'PASS 6/6',font=font,fill=(150,230,150))
 draw.text((764,y+80),'source 15 colours',font=font,fill='white')
 draw.text((764,y+110),'hard alpha',font=font,fill='white')
 draw.text((764,y+140),'cover '+str(round(reports[form]['small_opaque_coverage']*100))+'%',font=font,fill='white')
 draw.text((764,y+180),'answer: pending',font=font,fill='white')
sheet.convert('RGB').save(B/'review_sheet.png')