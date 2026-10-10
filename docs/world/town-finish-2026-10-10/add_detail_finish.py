from pathlib import Path
W=Path(__file__).parent
base=Path('C:/Users/pmcga/dev/hollowtide/scripts/arena/creature_finish.gdshader').read_text()
base=base.replace('// Hollowtide Sprite Forge finish at the arena\'s native pixel grid.','// Purposeful building finish: the creature silhouette/cluster pass, plus interior ink.\n// Source artwork stays untouched. Decorative buildings keep their quieter treatment.')
extra='''
	// Ink the dark side of high-contrast material boundaries: root ribs, stone joints,
	// window mullions and arch trim. Weak moss/texture variation stays coloured.
	if (c.a > 0.5) {
		float lum = luma(c.rgb);
		float light_neighbour = max(max(luma(n.rgb), luma(s.rgb)), max(luma(e.rgb), luma(w.rgb)));
		float boundary = smoothstep(0.12, 0.23, light_neighbour-lum) * (1.0-smoothstep(0.36, 0.48, lum));
		float dark_joint = 1.0-smoothstep(0.13, 0.25, lum);
		c.rgb = mix(c.rgb, outline.rgb, max(boundary, dark_joint));
	}
'''
base=base.replace('\tCOLOR = c * tint;',extra+'\tCOLOR = c * tint;')
(W/'candidate/scripts/town/building_detail_finish.gdshader').write_text(base)
