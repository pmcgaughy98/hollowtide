from pathlib import Path
import shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"coalcrest-refinement-2026-10-04"
for v in ["front","back"]:shutil.copy2(D/(v+"-draft-enlarged.png"),D/(v+"-draft-before-alignment.png"))
p=W/"refine_coalcrest_pixels.py";s=p.read_text()
s=s.replace('points=[(71,106),(64,119),(52,126),(40,130),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79)]','points=[(64,121),(52,130),(40,132),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79)]')
s=s.replace('widths=[23,18,13,10,8,6,5,4.5,4,3.5,3.5]','widths=[20,14,9,7.5,6,5,4.5,4,3.5,3.5]')
s=s.replace('signed=(xs-64)*-.73+(ys-119)*.68','signed=(xs-61)*-.76+(ys-126)*.65')
# Fine native toe/ankle rendering replaces the initial coarse left-foot reconstruction.
a=s.index(' # Left visible foot:');b=s.index(' # Right foot:',a)
s=s[:a]+''' # Left foot keeps the authored ankle angle, with fine claws and less square edges.
 a[128:143,57:78]=0
 paint_poly(a,[(61,128),(67,128),(68,132),(68,134),(72,135),(75,138),(74,140),(72,139),(70,137),(68,138),(68,140),(66,141),(64,140),(64,138),(62,137),(61,140),(59,140),(59,136),(60,133)],(10,2,0))
 paint_poly(a,[(61,128),(66,128),(66,132),(67,134),(70,135),(72,137),(70,136),(67,136),(66,137),(65,139),(64,137),(61,136),(60,138),(60,135)],M)
 paint_poly(a,[(61,129),(63,129),(63,132),(65,134),(65,135),(63,134),(61,133)],B)
 paint_poly(a,[(65,129),(66,130),(66,133),(65,134)],S)
 paint_poly(a,[(60,136),(61,136),(60,139)],(96,62,46))
 paint_poly(a,[(65,138),(66,138),(66,140),(65,140)],(96,62,46))
 paint_poly(a,[(72,137),(73,138),(73,139)],(96,62,46))
''' +s[b:]
a=s.index(' # Far hind foot emerges');b=s.index(' return m',a)
s=s[:a]+''' # Far hind foot is side-on and partly hidden behind the tail.
 a[126:137,69:91]=0
 paint_poly(a,[(72,126),(77,126),(77,129),(79,131),(84,131),(89,133),(89,135),(87,135),(84,133),(82,133),(84,135),(82,136),(80,134),(77,134),(74,133),(72,131)],(9,1,1))
 paint_poly(a,[(73,126),(76,126),(76,129),(78,131),(80,132),(83,132),(86,133),(87,134),(85,133),(82,132),(81,133),(78,133),(75,132),(73,130)],M)
 paint_poly(a,[(74,127),(75,127),(75,130),(77,131),(76,132),(74,131)],(96,62,46))
 paint_poly(a,[(82,132),(84,133),(84,134),(82,133)],B)
 paint_poly(a,[(87,133),(88,134),(88,134)],(96,62,46))
''' +s[b:]
p.write_text(s)
p=W/"verify_install_coalcrest_refinement.py";s=p.read_text().replace('protected[:103,45:130]=True','protected[:103,51:130]=True').replace('(a[102:122,57:65,1]>115))','(a[102:122,57:65,1]>115)&(a[102:122,57:65,3]>0))')
s=s.replace('probes +=[(132,75),(133,106)]','probes +=[(131,75),(133,106)]')
p.write_text(s)
