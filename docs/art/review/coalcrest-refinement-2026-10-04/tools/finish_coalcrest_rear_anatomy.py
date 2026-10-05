from pathlib import Path
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
p=W/"refine_coalcrest_pixels.py";s=p.read_text()
a=s.index(' # The anomalous amber');b=s.index(' # Far hind foot',a)
s=s[:a]+''' # Repaint and tuck in the old emitter-shaped silhouette as a slim, shaded far leg.
 m=polygon([(55,102),(65,100),(66,112),(65,125),(55,126),(55,116)])
 bounds=[61,61,60,60,60,60,59,59,59,59,58,58,58,57,57,57,56,56,56]
 for y,left in enumerate(bounds,104):
  for x in range(55,65):
   if not m[y,x]:continue
   if x<left:a[y,x]=0
   elif a[y,x,3]>0:
    a[y,x,:3]=(37,27,25) if x==left else (M if x<=left+1 else B)
''' +s[b:]
s=s.replace('a[126:137,69:91]=0','a[127:140,65:91]=0')
s=s.replace('foot_region[126:137,69:91]=True','foot_region[127:140,65:91]=True')
p.write_text(s)
