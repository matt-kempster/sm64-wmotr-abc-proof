"""Read-only source-mesh map for selecting a bounded controller route menu."""
import math,re,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import search as s

def mesh():
 text=(s.ROOT/'../../../reference-sm64-decomp/levels/ssl/areas/1/collision.inc.c').read_text()
 vs=[tuple(map(int,m))for m in re.findall(r'COL_VERTEX\((-?\d+),\s*(-?\d+),\s*(-?\d+)\)',text)]
 tris=[];typ=None
 for line in text.splitlines():
  m=re.search(r'COL_TRI_INIT\((\w+)',line)
  if m:typ=m[1]
  m=re.search(r'COL_TRI(?:_SPECIAL)?\((\d+),\s*(\d+),\s*(\d+)',line)
  if m:
   v=[vs[int(i)]for i in m.groups()];u=[v[1][i]-v[0][i]for i in range(3)];w=[v[2][i]-v[1][i]for i in range(3)]
   n=[u[1]*w[2]-u[2]*w[1],u[2]*w[0]-u[0]*w[2],u[0]*w[1]-u[1]*w[0]]
   if n[1]>0:tris.append((typ,v,n))
 return tris

def floor(tris,x,z):
 found=[]
 for typ,v,n in tris:
  if any((b[2]-a[2])*(x-a[0])-(b[0]-a[0])*(z-a[2])<0 for a,b in zip(v,v[1:]+v[:1])):continue
  y=v[0][1]-(n[0]*(x-v[0][0])+n[2]*(z-v[0][2]))/n[1];found.append((y,typ))
 return max(found,default=(-11000,'MISS'))
if __name__=='__main__':
 t=mesh();print('X=-7000..7000 step500; Z north to south')
 for z in range(-6000,7001,500):
  vals=[floor(t,x,z)for x in range(-7000,7001,500)]
  print(str(z).rjust(5),''.join(' 'if typ=='MISS'else'Q'if'QUICKSAND'in typ else'^'if y>500 else'.'for y,typ in vals))
