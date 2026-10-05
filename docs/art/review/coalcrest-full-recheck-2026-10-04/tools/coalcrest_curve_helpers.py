import numpy as np
def smooth(points,widths):
 p=np.array(points,float);w=np.array(widths,float);result=[]
 for i in range(len(p)-1):
  a=p[max(i-1,0)];b=p[i];c=p[i+1];d=p[min(i+2,len(p)-1)]
  for t in np.linspace(0,1,16,endpoint=False):
   q=.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)
   result.append([q[0],q[1],w[i]*(1-t)+w[i+1]*t])
 result.append([*p[-1],w[-1]])
 return np.array(result)

def shape_and_texture(material,points,widths,srcpoints,srcwidths,roi):
 path=smooth(points,widths);src=smooth(srcpoints,srcwidths)
 ta=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 sa=np.cumsum(np.r_[0,np.linalg.norm(np.diff(src[:,:2],axis=0),axis=1)])
 # Preserve native spacing through the root, then repeat the authored scale bands.
 arc=ta%(2*sa[-1]);arc=np.where(arc>sa[-1],2*sa[-1]-arc,arc)
 ids=np.searchsorted(sa,arc).clip(0,len(src)-1)
 tangent=np.gradient(path[:,:2],axis=0);tangent/=np.maximum(np.linalg.norm(tangent,axis=1)[:,None],.001)
 normal=np.column_stack([-tangent[:,1],tangent[:,0]])
 st=np.gradient(src[:,:2],axis=0);st/=np.maximum(np.linalg.norm(st,axis=1)[:,None],.001)
 sn=np.column_stack([-st[:,1],st[:,0]])
 y,x=np.mgrid[:160,:160];diff=np.stack([x,y],axis=-1)[:,:,None,:]-path[None,None,:,:2]
 dist=(diff*diff).sum(axis=3);near=dist.argmin(axis=2);shape=dist.min(axis=2)<=(path[near,2]/2)**2
 sample=np.zeros((160,160),bool);sample[roi[1]:roi[3],roi[0]:roi[2]]=True
 sample&=(material[:,:,3]>0)&(material[:,:,0]>60)&(material[:,:,0]>=material[:,:,1])&(material[:,:,1]>=material[:,:,2])
 sy,sx=np.nonzero(sample);out=np.zeros_like(material)
 for y,x in np.argwhere(shape):
  i=near[y,x];j=ids[i];u=np.dot(np.array([x,y])-path[i,:2],normal[i])/max(path[i,2]/2,.001)
  desired=src[j,:2]+sn[j]*u*max(src[j,2]/2-1,.5);rx,ry=np.rint(desired).astype(int)
  if not(0<=rx<160 and 0<=ry<160 and sample[ry,rx]):
   k=((sx-desired[0])**2+(sy-desired[1])**2).argmin();rx,ry=sx[k],sy[k]
  out[y,x]=material[ry,rx];out[y,x,3]=255
 return shape,out