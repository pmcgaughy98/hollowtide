"""Preserve current seven-form source art, references and runtime pipeline for review."""
from pathlib import Path
import shutil, importlib.util
from PIL import Image, ImageDraw

P=Path('C:/Users/pmcga/dev/hollowtide')
W=Path(__file__).resolve().parent
forms=['slagglass','preostmar','oathfen','oxbowarchon','punchybun','sparkjab','starward']
old=Path(__file__).parent.parent/'arena-vitrecrag-consistency-2026-10-07/source-audit/audit_originals.py'
code=old.read_text(encoding='utf8')
code=code.replace("arena-vitrecrag-consistency-2026-10-07/source-audit",W.name+'/source-audit')
code=code.replace("FORMS=['fusern','slagglass','vitrecrag']",'FORMS='+repr(forms))
code=code.replace("OLD_FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw','cinderhide','clinkerhide','ironvent']", "OLD_FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw','cinderhide','clinkerhide','ironvent','fusern','vitrecrag']")
code=code.replace("protected=[]", "protected=[{'path':'project.godot','sha256':sha(P/'project.godot'),'bytes':(P/'project.godot').stat().st_size}]")
audit=W/'source-audit'; audit.mkdir(parents=True,exist_ok=True)
(audit/'audit_originals.py').write_text(code,encoding='utf8')
exec(compile(code,str(audit/'audit_originals.py'),'exec'),{})
candidate=W/'candidate-project'
for item in (audit/'originals').rglob('*.png'):
    dest=candidate/item.relative_to(audit/'originals'); dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(item,dest)
for name in ['build_small.py','downscale.py','normalize_arena_palette.py','report_consistency.py']:
    dest=candidate/'tools/arena'/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/'tools/arena'/name,dest)
refs=[('original Oxbow','assets/sprites/creatures/oxbowarchon.png'),('signature','assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail/style_matched/titlecard.png')]
refs += [(n,'docs/creatures/arena-starters-2026-10-07/forms/'+n+'.png') for n in forms]
sheet=Image.new('RGB',(900,900),(40,47,51));d=ImageDraw.Draw(sheet)
for idx,(label,rel) in enumerate(refs):
    im=Image.open(P/rel).convert('RGBA'); im.thumbnail((275,270),Image.Resampling.NEAREST)
    x=(idx%3)*300;y=(idx//3)*300;d.text((x+8,y+5),label,fill='white');sheet.paste(im,(x+(300-im.width)//2,y+26),im)
    dest=W/'references'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/rel,dest)
sheet.save(W/'references.png')
