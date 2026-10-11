from pathlib import Path
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p=C/'scripts/creature_prologue.gd';s=p.read_text(encoding='utf-8')
lines=s.splitlines(keepends=True)
for i,line in enumerate(lines):
    if 'if i==(hero if phase==0 else partner):b.text=' in line:
        lines[i]='\t\t\tif i==(hero if phase==0 else partner):b.text="\u2022 "+NAMES[i]\n'
p.write_text(''.join(lines),encoding='utf-8')
print('Restored original UTF-8 choice marker.')
