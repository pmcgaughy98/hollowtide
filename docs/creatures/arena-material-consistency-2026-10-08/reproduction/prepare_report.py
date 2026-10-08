"""Prepare a separate reporter for current per-form sizes and an explicit jade override.

The earlier report_consistency.py behavior is preserved. This derived reporter reads
the current builder's SCALE constants without executing it and verifies its resample
pipeline byte for byte. A CLI palette-reference override is explicit in the evidence.
"""
from pathlib import Path
W=Path(__file__).resolve().parent
C=W/'source-audit/candidate-project'
code=(C/'tools/arena/report_consistency.py').read_text(encoding='utf8')
code=code.replace("parser.add_argument('--forms',", "parser.add_argument('--palette-reference',type=Path,help='Explicit JSON mapping of form to preserved corrected-palette reference')\n    parser.add_argument('--forms',")
code=code.replace('basepal={}; bases=[]', "overrides=json.loads(args.palette_reference.read_text(encoding='utf8')) if args.palette_reference else {}\n    basepal={}; bases=[]")
code=code.replace("basepal[n]={tuple(c) for c in a[:,:,:3][a[:,:,3]>0]}", "palette_image=np.array(Image.open(args.palette_reference.parent/overrides[n]).convert('RGBA')) if n in overrides else a\n        basepal[n]={tuple(c) for c in palette_image[:,:,:3][palette_image[:,:,3]>0]}")
code=code.replace("from downscale import shrink", "from downscale import shrink,resample\n    import ast\n    builder=ast.parse((project/'tools/arena/build_small.py').read_text(encoding='utf8'))\n    scales=next(ast.literal_eval(node.value) for node in builder.body if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='SCALE' for t in node.targets))\n    def small_of(im,n):\n        scale=scales.get(n,1.0)\n        return shrink(im,3) if scale==1.0 else resample(im,3.0/scale)")
code=code.replace("im=shrink(Image.open(project/f'assets/sprites/arena/{n}/{src}.png').convert('RGBA'),3)", "im=small_of(Image.open(project/f'assets/sprites/arena/{n}/{src}.png').convert('RGBA'),n)")
code=code.replace('im=shrink(im,3)','im=small_of(im,n)')
code=code.replace("summary['game_pngs_exact_existing_pipeline']", "summary['palette_reference_overrides']=overrides\n    summary['palette_reference_sha256']=sha(args.palette_reference) if args.palette_reference else None\n    summary['game_pngs_exact_existing_pipeline']",1)
code=code.replace('own_base','selected_reference').replace('own-base','selected-reference')
code=code.replace('Structural/palette checks passed.','Structural/palette checks passed using explicit selected references and current per-form scale.')
dest=W/'candidate-tools/report_arena_materials.py';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(code,encoding='utf8')
(W/'palette-reference/references.json').parent.mkdir(parents=True,exist_ok=True)
(W/'palette-reference/references.json').write_text('{"oxbowarchon":"oxbowarchon-dark-jade.png"}\n',encoding='utf8')
