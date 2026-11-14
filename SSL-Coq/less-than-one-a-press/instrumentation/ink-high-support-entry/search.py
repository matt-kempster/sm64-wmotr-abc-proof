"""Small native high-air and yaw-only support comparisons, not route claims.

Initial pose/action/velocity and optional actor XYZ are supplied once. No
floor, ceiling, platform, top state or subsequent gameplay field is written.
"""
import json, math, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write,f32
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

class Guard:
    def __init__(self,g):self.game=g;self.setup=False
    def __getattr__(self,k):return getattr(self.game,k)
    def write(self,p,v):
        assert self.setup or p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        self.game.write(p,v)

def roots(capture):
    g,o=reach_after_pillars(capture);g=Guard(g);states={}
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==131):
        if g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer') in (128,130):states[g.read('gObjectPool[61].oTimer')]=g.save_state()
        advance(g,NEUTRAL)
    return g,o,states

def top(g):
    return {k:g.read('gObjectPool[61].'+k) for k in ['oPosX','oPosY','oPosZ','oFaceAnglePitch','oFaceAngleYaw','oFaceAngleRoll','oAngleVelPitch','oAngleVelYaw','oAngleVelRoll','oVelX','oVelY','oVelZ']}

def trial(g,o,states,r,full=False):
    g.load_state(states[r['phase']]);g.setup=True;edits=[]
    pose(g,r['pos'],edits)
    angle=r['yaw']*math.tau/65536;s=r['speed']
    for p,v in [('action',g.constant(r['action'])),('actionState',0),('actionTimer',0),
                ('forwardVel',s),('vel',[f32(s*math.sin(angle)),r['vy'],f32(s*math.cos(angle))]),
                ('faceAngle',[0,r['yaw'] if r['yaw']<32768 else r['yaw']-65536,0])]:write(g,'gMarioState.'+p,v,edits)
    if r['action']=='ACT_BUTT_SLIDE':
        for p,v in [('slideVelX',s),('slideVelZ',0),('slideYaw',16384)]:write(g,'gMarioState.'+p,v,edits)
    if r['box']:
        for a,v in zip('XYZ',[-1989,r['pos'][1],-939]):write(g,'gObjectPool[49].oPos'+a,v,edits)
    g.setup=False
    initial=rich_sample(g,o);rows=[];events=[];tops=[];pads=[]
    for i in range(33 if full else 6):
        pad=r['pad'] if i==0 else NEUTRAL
        advance(g,pad);pads.append(pad);rows.append(rich_sample(g,o));events.append(frame_events(g));tops.append(top(g))
        if rows[-1]['area']!=1:break
    arrival=next((s for s in rows if s['area']==2),None)
    useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows)
    return dict(recipe=r,edits=edits,initial=initial,controls=pads,samples=rows,events=events,topFields=tops,
                warpTopCapture=capture,usefulArea2=useful)

def recipes():
    for y in [21777,21778,25000,32767,67277,67536]:
      for vy in [-16,16,64]:
       for label,pad in [('neutral',NEUTRAL),('B',dict(buttons=0x4000,stick=[0,0])),('Z',dict(buttons=0x2000,stick=[0,0]))]:
        yield dict(name=f'air-y{y}-vy{vy}-{label}',kind='high-air',phase=130,pos=[-1950,y,-939],yaw=16384,speed=20,vy=vy,action='ACT_FREEFALL',box=True,pad=pad)
      yield dict(name=f'air-y{y}-no-box',kind='high-air',phase=130,pos=[-1950,y,-939],yaw=16384,speed=20,vy=-16,action='ACT_FREEFALL',box=False,pad=NEUTRAL)
    for yaw in [0,16384,32768,49152]:
      for speed in [20,262145,524289]:
        yield dict(name=f'yaw-landing-{yaw}-v{speed}',kind='yaw-support',phase=128,pos=[-1930,1837.8726806640625,-880],yaw=yaw,speed=speed,vy=-16,action='ACT_FREEFALL',box=False,pad=NEUTRAL)
    for y in [25000,67277]:
        yield dict(name=f'supplied-slide-control-y{y}',kind='positive-control',phase=130,pos=[-1950,y,-939],yaw=16384,speed=20,vy=0,action='ACT_BUTT_SLIDE',box=True,pad=NEUTRAL)

def main():
    capture=Path(sys.argv[1]);out=Path(sys.argv[2]);g,o,states=roots(capture)
    rows=[trial(g,o,states,r) for r in recipes()]
    selected=[t['recipe'] for t in rows if t['recipe']['kind']!='high-air' or t['recipe']['name'] in
       ['air-y21777-vy-16-neutral','air-y21778-vy-16-neutral','air-y25000-vy16-neutral','air-y25000-vy64-B','air-y25000-vy-16-Z','air-y32767-vy-16-neutral','air-y67277-vy-16-neutral','air-y67536-vy16-neutral']]
    q,qo,qs=roots(capture);full=[]
    for r in selected:
        t=trial(g,o,states,r,True);assert t==trial(q,qo,qs,r,True),r['name'];full.append(t)
    for t in full:
        if t['recipe']['kind']=='positive-control':assert t['usefulArea2'] and t['warpTopCapture']
    ground={g.constant(s) for s in ['ACT_CRAWLING','ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_CROUCH_SLIDE','ACT_DIVE_SLIDE']}
    summary=[]
    for t in rows:
        summary.append(dict(name=t['recipe']['name'],kind=t['recipe']['kind'],firstAction=t['samples'][0]['actionName'],firstM=t['samples'][0]['movement'],firstFloor=t['samples'][0]['floorY'],firstCeil=t['samples'][0]['ceilingY'],firstTopSurfaces=t['samples'][0]['topSurfaceCount'],groundActionSeen=any(s['action'] in ground for s in t['samples']),supportSeen=any(s['platform']==61 for s in t['samples']),capture=t['warpTopCapture']))
    sources=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='651c180e594e45c6825f9c4800da11f4afef0773',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(capture),sourceSha256={p:digest(sources/p) for p in ['src/game/mario_step.c','src/game/mario_actions_airborne.c','src/game/platform_displacement.c','src/game/behaviors/pyramid_top.inc.c']},screenTrials=rows,summary=summary,retained=full,counts=dict(screenTrials=len(rows),screenBoundaries=sum(len(t['samples']) for t in rows),freshTrials=len(full),freshBoundaries=sum(len(t['samples']) for t in full)))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps(dict(counts=result['counts'],summary=summary),indent=2))

if __name__=='__main__':main()
