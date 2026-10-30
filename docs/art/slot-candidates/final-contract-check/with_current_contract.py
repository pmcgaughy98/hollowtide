import sys,runpy
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
reg.SLOTS_JSON=Path(__file__).with_name('slots.json')
reg.load() # The normal freshness guard stays active.
tool=sys.argv[1]
assert tool in ('prepare_slot.py','validate_slot.py','review_sheet.py')
sys.argv=[str(ROOT/'tools/art'/tool)]+sys.argv[2:]
runpy.run_path(sys.argv[0],run_name='__main__')
