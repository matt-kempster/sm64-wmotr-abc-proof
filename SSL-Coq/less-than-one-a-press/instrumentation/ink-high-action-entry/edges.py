"""Pad-edge binary32 refinement of high-Y native shell cancellation.

Targets the loaded static floor vertices [-2149,-1945] x [-1125,-921]
and signed-integer truncation edges; not a global position enumeration.
"""
import argparse,json,struct,time,sys
from pathlib import Path
from collections import Counter
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,Guard,shell_root,one,digest

def f32(x):return struct.unpack('<f',struct.pack('<f',x))[0]
def adjacent(x,d):
    bits=struct.unpack('<I',struct.pack('<f',x))[0]
    bits+=d if x>=0 else -d
    return struct.unpack('<f',struct.pack('<I',bits))[0]
def values(anchors):
    return sorted(set(v for a in anchors for v in [adjacent(a,-1),a,adjacent(a,1),a-.75,a-.5,a-.25,a+.25,a+.5,a+.75]))

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    g,o,base,prep=shell_root(a.capture);g=Guard(g)
    xs=values([-2150,-2149,-1946,-1945]);zs=values([-1126,-1125,-922,-921])
    positions=set((x,z) for x in xs for z in range(-1127,-918))
    positions.update((x,z) for z in zs for x in range(-2151,-1942))
    positions.update((x,z) for x in xs for z in zs)
    rows=[];captured=[];counts=Counter();retained=[];start=time.time()
    for y in [25000,67277]:
      for x,z in sorted(positions):
        r=dict(name=f'shell-edge-{x}-{y}-{z}',pos=[x,y,z]);t=one(g,o,base,prep['slot'],r)
        before,after=t['samples'];key=(before['floorY'],after['floorY'],after['action'],after['used'],after['platform']);counts[str(key)]+=1
        if before['floorY']==768:
            rows.append(dict(recipe=r,samples=t['samples'],capture=t['capture']))
        if t['capture']:
            ft=one(g,o,base,prep['slot'],r,True);captured.append(ft);print('CAPTURE',r,ft['useful'],flush=True)
      print('HEIGHT',y,'elapsed',time.time()-start,'captures',len(captured),flush=True)
    for x,z in [(-2148,-1124),(-1946,-1124),(-1946,-922),(-2148,-922),
                (adjacent(-1946,-1),-939),(adjacent(-1946,1),-939),
                (-1950,adjacent(-922,-1)),(-1950,adjacent(-922,1)),
                (adjacent(-2149,-1),-939),(adjacent(-2149,1),-939),
                (-1950,adjacent(-1125,-1)),(-1950,adjacent(-1125,1))]:
      retained.append(one(g,o,base,prep['slot'],dict(name=f'edge-full-{x}-{z}',pos=[x,25000,z]),True))
    q,qo,qbase,qprep=shell_root(a.capture);q=Guard(q);assert prep==qprep
    for t in retained+captured:assert one(q,qo,qbase,qprep['slot'],t['recipe'],True)==t
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),trialScriptSha256=digest(ROOT/'instrumentation/ink-high-action-entry/search.py'),prefixSha256=digest(a.capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),shellPreparation=prep,menu=dict(xBoundaryValues=xs,zBoundaryValues=zs,alongEdgeX=[-2151,-1943,1],alongEdgeZ=[-1127,-919,1],heights=[25000,67277],deduplicatedXZCount=len(positions)),candidateCount=2*len(positions),outcomeCounts=dict(counts),lowPadScreens=rows,trials=retained+captured,captureCount=len(captured),usefulCount=sum(t['useful'] for t in captured),verifiedFreshTrials=len(retained)+len(captured),verifiedFreshBoundaries=sum(len(t['samples']) for t in retained+captured),elapsed=time.time()-start)
    with open(a.output,'x') as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps({k:result[k] for k in ['candidateCount','captureCount','usefulCount','verifiedFreshTrials','verifiedFreshBoundaries','elapsed']},indent=2))
    print(json.dumps(counts,indent=2))

if __name__=='__main__':main()
