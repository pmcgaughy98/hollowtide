import sys,runpy,json
from pathlib import Path
sys.dont_write_bytecode=True
R=Path(__file__).parent;ROOT=R.parents[3]
sys.path.insert(0,str(ROOT/"tools/art"))
import slot_registry as reg
reg.SLOTS_JSON=R/"slots.json"
meta=json.loads((R/"contract-source.json").read_text(encoding="utf-8"));source=R/meta["folder"]
reg.SLOT_DIR=source/"slots";reg.LOADER=source/"art_slots.gd"
reg.load()
tool=sys.argv[1]
assert tool in ("prepare_slot.py","validate_slot.py","review_sheet.py")
sys.argv=[str(ROOT/"tools/art"/tool)]+sys.argv[2:]
runpy.run_path(sys.argv[0],run_name="__main__")
