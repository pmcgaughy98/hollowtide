from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/courier-hall-review")
original=Image.open(D/"courier-hall-native.png").convert("RGBA")
a=np.array(original);edit=Image.open(D/"rd-wide-board-output.png").convert("RGBA")
out=a.copy();small=np.array(Image.open(D/"board-edit-mask.png").convert("L"))>127
mask=np.zeros(a.shape[:2],bool);mask[20:68,20:116]=small
# Use the existing unlettered sage wall behind the board; discard the service's added wall posts and white margin.
for y,x in np.argwhere(mask):out[y,x]=a[y,111+(x-34)%16]
board=edit.crop((22,15,74,33))
out[31:49,42:94]=np.array(board)
final=Image.fromarray(out);final.save(D/"courier-hall-wide-board-finished.png")
audit={"dimensions":final.size,"changed_pixels":int(np.any(out!=a,axis=2).sum()),"changed_outside_board_mask":int(np.any(out!=a,axis=2)[~mask].sum()),"generated_board_crop":[22,15,52,18],"board_placement":[42,31],"wall_material_source":"Original sage plaster x111..126 at the same row; native repetition","rejected_delivery_parts":"Generated white margin and extra wall posts outside the noticeboard","single_wide_board":True,"sha256":hashlib.sha256((D/"courier-hall-wide-board-finished.png").read_bytes()).hexdigest()}
assert audit["changed_outside_board_mask"]==0
(D/"board-finished-audit.json").write_text(json.dumps(audit,indent=2))
target=P/"assets/sprites/world/courier_hall_2026_10_03/courier_hall_native.png"
assert target.read_bytes()==(D/"courier-hall-wide-board-native.png").read_bytes()
shutil.copy2(D/"courier-hall-wide-board-finished.png",target)
final.resize((768,768),Image.Resampling.NEAREST).save(D/"hall-final-art-detail.png")
print(json.dumps(audit))
