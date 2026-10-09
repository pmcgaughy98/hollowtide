"""Reproduce the three Listener forms' palette integration in a separate candidate.

Uses preserved originals and each approved take's exact colors. Never writes to
the source or live project. The original base art, poses, alpha and size stay fixed.
The existing normalizer and named-only arena builder are used without modification.
"""
import argparse,importlib.util,json,shutil,subprocess,sys
from pathlib import Path
import numpy as np
from PIL import Image

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--project',type=Path,required=True,help='Project containing current pipeline tools')
    ap.add_argument('--originals',type=Path,required=True,help='Preserved project-relative originals root')
    ap.add_argument('--output',type=Path,required=True,help='New isolated output directory')
    args=ap.parse_args();project=args.project.resolve();source=args.originals.resolve();out=args.output.resolve()
    if out.exists():ap.error('Output must be a new directory; inspect existing candidates before replacing them.')
    if out==project or out==source:ap.error('Output must differ from both input roots')
    forms=['listener','caller','warden'];doc=Path('docs/creatures/arena-starters-2026-10-07')
    out.mkdir(parents=True)
    for name in ['normalize_arena_palette.py','build_small.py','downscale.py']:
        dest=out/'tools/arena'/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(project/'tools/arena'/name,dest)
    spec=importlib.util.spec_from_file_location('norm',out/'tools/arena/normalize_arena_palette.py')
    norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
    audit={}
    for form in forms:
        base=np.array(Image.open(source/doc/'forms'/f'{form}_arena_front_take1.png').convert('RGBA'))
        palette,outline,target=norm.base_rules(base);records=[]
        files=[Path(f'assets/sprites/arena/{form}/{f}.png') for f in 's se e ne n nw w sw'.split()]
        files += [doc/'walk'/f'{form}_{f}_sheet.png' for f in 's se e ne n'.split()]
        for rel in files:
            a=np.array(Image.open(source/rel).convert('RGBA'));b=a.copy()
            walk=rel.name.endswith('_sheet.png');size=a.shape[0]//2 if walk else a.shape[0]
            for i in range(8 if walk else 1):
                y=i//4*size if walk else 0;x=i%4*size if walk else 0
                fr=a[y:y+size,x:x+size];fixed,params=norm.normalize(fr,palette,outline,target)
                assert np.array_equal(fixed[...,3],fr[...,3]),str(rel)
                b[y:y+size,x:x+size]=fixed
                records.append({'path':rel.as_posix(),'frame':i,'parameters':params})
            dest=out/rel;dest.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(b).save(dest)
        audit[form]=records
    subprocess.run([sys.executable,str(out/'tools/arena/build_small.py'),*forms],cwd=out,check=True)
    (out/'listener-palette-audit.json').write_text(json.dumps(audit,indent=2))

if __name__=='__main__':main()
