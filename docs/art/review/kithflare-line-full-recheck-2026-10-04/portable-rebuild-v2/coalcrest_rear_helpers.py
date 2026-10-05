import numpy as np
from coalcrest_curve_helpers import smooth

def geometry(points,widths):
 path=smooth(points,widths)
 arc=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 tangent=np.gradient(path[:,:2],axis=0);tangent/=np.maximum(np.linalg.norm(tangent,axis=1)[:,None],.001)
 normal=np.column_stack([-tangent[:,1],tangent[:,0]])
 y,x=np.mgrid[:160,:160];diff=np.stack([x,y],-1)[:,:,None,:]-path[None,None,:,:2]
 dist=(diff*diff).sum(3);near=dist.argmin(2)
 shape=dist.min(2)<=(path[near,2]/2)**2
 u=(diff*np.array(normal)[None,None]).sum(3)[y,x,near]/np.maximum(path[near,2]/2,.001)
 return shape,path,arc,near,u,normal
