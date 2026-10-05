from pathlib import Path
from PIL import Image,ImageFilter
import numpy as np,json,hashlib,shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"historic-frontage-2026-10-04"
DEST=P/"assets/sprites/world/historic_frontage_2026_10_04"
assert not DEST.exists(), "Version folder already exists; inspect before rerun"
assert (P/"scripts/historic_street.gd").read_bytes()==(D/"before/scripts/historic_street.gd").read_bytes(), "Concurrent script change; stop"
DEST.mkdir()
audit=[]
for source,name in [("repair_workshop_v2","repair_workshop"),("rear_rowhomes_v2","rear_rowhomes"),("workshop_keeper","workshop_keeper")]:
 im=Image.open(D/(source+"-original.png")).convert("RGBA")
 bounds=im.getbbox();crop=im.crop(bounds)
 out=Image.new("RGBA",(crop.width+24,crop.height+24))
 out.paste(crop,(12,12))
 assert np.unique(np.array(out)[:,:,3]).tolist()==[0,255]
 target=DEST/(name+".png");out.save(target)
 assert np.array_equal(np.array(out)[12:12+crop.height,12:12+crop.width],np.array(crop))
 audit.append({"source":source+"-original.png","runtime":target.relative_to(P).as_posix(),"source_bounds":bounds,"runtime_size":out.size,"visible_size":crop.size,"padding":12,"opaque_pixels_preserved":True,"semi_transparent_pixels":0})
original=Image.open(P/"assets/sprites/world/historic_street_2026_10_03/street_pavers.png").convert("RGBA")
street=np.array(original); pavers=np.array(Image.open(W/"historic-riverfront-review/historic_pavers_tile_source.png").convert("RGBA"))
shape=(896,768);yy,xx=np.mgrid[:896,:768]
def stroke(points,half):
 best=np.full(shape,1e9)
 for a,b in zip(points,points[1:]):
  vx,vy=b[0]-a[0],b[1]-a[1];t=np.clip(((xx-a[0])*vx+(yy-a[1])*vy)/max(vx*vx+vy*vy,.001),0,1)
  best=np.minimum(best,(xx-a[0]-t*vx)**2+(yy-a[1]-t*vy)**2)
 return best<half*half
added=stroke([(128,480),(128,244),(656,244),(656,480)],14)
added|=stroke([(384,400),(384,480)],22)
for x in [356,404]:added|=stroke([(x,222),(x,244)],12)
# Join curbs continuously to existing paving. Reuse the original native material.
combined=added|(street[:,:,3]>0)
inner=np.array(Image.fromarray(combined.astype("uint8")*255).filter(ImageFilter.MinFilter(5)))>0
curb=combined&~inner
# A narrow band repairs old curbs only at the new junctions; other old pixels remain exact.
edit=added|(np.array(Image.fromarray(added.astype("uint8")*255).filter(ImageFilter.MaxFilter(5)))>0)&(street[:,:,3]>0)
street[edit]=pavers[yy[edit]%48,xx[edit]%48];street[edit,3]=255
street[curb&edit,:3]=(91,80,64)
Image.fromarray(street).save(DEST/"street_pavers.png")
audit.append({"runtime":(DEST/"street_pavers.png").relative_to(P).as_posix(),"original_paving_unchanged_outside_new_paths_and_2px_junction_band":bool(np.array_equal(street[~edit],np.array(original)[~edit])),"new_path_pixels":int(edit.sum()),"material_source":"historic-riverfront-review/historic_pavers_tile_source.png","lanes":{"rear_y":244,"sides_x":[128,656],"rear_half_width":14}})
s=(P/"scripts/historic_street.gd").read_text()
s=s.replace('const STREET = preload("res://assets/sprites/world/historic_street_2026_10_03/street_pavers.png")','const STREET = preload("res://assets/sprites/world/historic_frontage_2026_10_04/street_pavers.png")\nconst WORKSHOP = preload("res://assets/sprites/world/historic_frontage_2026_10_04/repair_workshop.png")\nconst ROWHOMES = preload("res://assets/sprites/world/historic_frontage_2026_10_04/rear_rowhomes.png")\nconst KEEPER = preload("res://assets/sprites/world/historic_frontage_2026_10_04/workshop_keeper.png")')
s=s.replace('"ledger":Vector2(224,428)}','"ledger":Vector2(224,428),"keeper":Vector2(424,438),"homes":Vector2(356,244),"workshop":Vector2(384,428)}')
anchor='\t_solid("LedgerFootprint",Rect2(160,326,128,74))'
assert s.count(anchor)==1
s=s.replace(anchor,anchor+'''
	# Infill stays behind grounded entrance lanes; the keeper is courier-sized.
	_prop("OccupiedRepairWorkshop",WORKSHOP,Vector2(384,400),0.75)
	_solid("WorkshopFootprint",Rect2(332,326,104,74))
	_prop("UpperFloorRowhomes",ROWHOMES,Vector2(384,224),0.85)
	_solid("RowhomeFootprint",Rect2(307,159,154,65))
	var keeper:=_prop("WorkshopKeeper",KEEPER,Vector2(424,426),0.5)
	_solid("KeeperFeet",Rect2(-4,-4,8,4),keeper)
'''.rstrip())
s=s.replace('\t\t"ledger":return "E  Read public street ledger"','\t\t"ledger":return "E  Read public street ledger"\n\t\t"keeper":return "E  Talk to workshop keeper"\n\t\t"homes":return "E  Read residential doorstep notice"\n\t\t"workshop":return "E  Look at repair workshop"')
s=s.replace('\t\t"ledger":visit_ledger()','\t\t"ledger":visit_ledger()\n\t\t"keeper":visit_keeper()\n\t\t"homes":visit_homes()\n\t\t"workshop":visit_workshop()')
anchor='func visit_board() -> void:'
assert s.count(anchor)==1
s=s.replace(anchor,'''# Prototype resident text uses the existing dialogue panel and local activity.
func visit_keeper() -> void:
	var text := "WORKSHOP KEEPER\\nThese buildings get new fittings without losing their old doorways. If a parcel label and a lintel disagree, the public ledger across the street has today's address."
	if lintel_checked and ledger_checked and not handoff_verified:
		text = "WORKSHOP KEEPER\\nYou have both versions now. Take the current street address to the courier at the riverfront branch; the older lintel can stay where it is."
	elif handoff_verified:
		text = "WORKSHOP KEEPER\\nThe shop route is marked eighteen now. A new fitting is useful, but you do not have to tear out the old stone to keep the street working."
	_route.call("_show_message",text)

func visit_homes() -> void:
	_route.call("_show_message","RESIDENTIAL DOORSTEP\\nA small notice asks delivery runners to knock at each ground-floor door. The separate upstairs curtains and repaired thresholds show that the old row is still lived in.")

func visit_workshop() -> void:
	_route.call("_show_message","REPAIR WORKSHOP\\nTools hang in the display windows beneath a worn awning. The keeper is outside, within speaking distance of the doorway.")

'''+anchor)
(P/"scripts/historic_street.gd").write_text(s,encoding="utf-8",newline="\n")
(D/"native-preparation.json").write_text(json.dumps(audit,indent=2))
runtime=["scripts/historic_street.gd"]+[x.relative_to(P).as_posix() for x in DEST.glob("*.png")]
(D/"installation.json").write_text(json.dumps({"runtime":runtime,"new_dialogue":"Prototype proposal, not approved canon","map_size":[768,896],"new_landmarks":{"workshop":[384,400],"rowhomes":[384,224],"keeper":[424,426]},"original_address_activity_methods_preserved":True,"source_art_preserved":True},indent=2))
print(json.dumps({"installed":runtime,"sprites_native_pixels_preserved":True,"new_path_pixels":int(edit.sum())}))
