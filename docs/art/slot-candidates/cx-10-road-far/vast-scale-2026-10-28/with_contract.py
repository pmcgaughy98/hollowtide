from pathlib import Path
import sys,runpy
sys.dont_write_bytecode=True
R=Path(__file__).parent;ROOT=R.parents[4];sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load()
name=sys.argv.pop(1);runpy.run_path(str(ROOT/'tools/art'/name),run_name='__main__')
