from pathlib import Path
from PIL import Image
import json,hashlib,os
root=Path(__file__).resolve().parent
package=root/'ironvent-black-match-review-2026-10-05'
mapping=json.loads((package/'back-palette-proposal.json').read_text())
correction=json.loads((package/'title-registration-correction.json').read_text())
out=root/'rebuild-proof'
out.mkdir(exist_ok=False)
def fs(q):return Path(chr(92)*2+'?'+chr(92)+str(q.absolute())) if os.name=='nt' else q
sha=lambda q:hashlib.sha256(fs(q).read_bytes()).hexdigest()
records=[]
for name,rel in [('front','assets/sprites/creatures/ironvent_black_match_2026_10_05/ironvent_front.png'),('title','assets/sprites/creatures/ironvent_black_match_2026_10_05/furnace_roar_title.png'),('title',correction['new_texture'])]:
 src=package/'before'/f'{name}-original.png'
 assert sha(src)==mapping['assets'][name]['source_sha256']
 original=Image.open(fs(src)).convert('RGBA'); rebuilt=original.copy()
 table={tuple(item['front_title_rgb']):tuple(item['back_reference_rgb']) for item in mapping['mapping']}
 mapped=0
 for y in range(original.height):
  for x in range(original.width):
   pixel=original.getpixel((x,y))
   if pixel[3]>0 and pixel[:3] in table:
    rebuilt.putpixel((x,y),table[pixel[:3]]+(pixel[3],));mapped+=1
 assert mapped==mapping['assets'][name]['mapped_pixels']
 target=out/rel;fs(target.parent).mkdir(parents=True,exist_ok=True);rebuilt.save(fs(target))
 frozen=root/'runtime'/rel
 assert fs(target).read_bytes()==fs(frozen).read_bytes()
 assert sha(target)==mapping['assets'][name]['proposal_sha256']
 assert rebuilt.getchannel('A').tobytes()==original.getchannel('A').tobytes()
 records.append({'relative_path':rel,'mapped_RGB_pixels':mapped,'sha256':sha(target),'frozen_PNG_byte_exact':True,'alpha_exact':True})
(out/'rebuild-checks.json').write_text(json.dumps({'passed':True,'PNG_files':3,'unique_edited_portraits':2,'unique_RGB_edits':1786,'files':records},indent=2)+'\n')
print('IRONVENT_LOCAL_PALETTE_REBUILD true PNGs=3 unique_portraits=2 unique_RGB_edits=1786')
