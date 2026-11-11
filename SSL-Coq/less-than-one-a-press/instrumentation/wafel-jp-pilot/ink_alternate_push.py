"""Supplied XYZ alternatives to the shell; no actor spawn or velocity edit.

This is a local handoff diagnostic, not controller delivery of the actor or
Mario. Existing actors retain their native behavior, motion and pool history.
"""
import argparse, hashlib, json, sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, set_input, NEUTRAL
from ink_timer130_crawl import snapshot, frame_events, CRAWLING


def run(capture):
    g,o=reach_after_pillars(capture)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==130):
        set_input(g,NEUTRAL);g.advance()
    state=g.save_state(); trials=[]
    cases=[('jumping-box',49,'bhvJumpingBox',[-1989,1741,-939],False),
           ('bobomb',39,'bhvBobomb',[-1979,1741,-939],False),
           ('jumping-box-minimal-mario',49,'bhvJumpingBox',[-1989,1741,-939],True),
           ('bobomb-minimal-mario',39,'bhvBobomb',[-1979,1741,-939],True),
           ('jumping-box-xz-only',49,'bhvJumpingBox',[-1989,None,-939],False)]
    for name,slot,behavior,actor_xyz,minimal in cases:
        g.load_state(state); edits=[]
        def write(path,value):
            edits.append(dict(path=path,before=g.read(path),after=value));g.write(path,value)
        mario_fields=[('pos',[-1950,1741,-939]),('action',CRAWLING)]
        if not minimal:mario_fields += [('actionState',0),('actionTimer',0),('forwardVel',5),('vel',[4,0,0]),('faceAngle',[0,0x4000,0])]
        for field,value in mario_fields:
            write('gMarioState.'+field,value)
        for axis,value in zip('XYZ',[-1950,1741,-939]):write('gMarioObject.oPos'+axis,value)
        write('gMarioObject.header.gfx.pos',[-1950,1741,-939])
        q='gObjectPool[%d].'%slot
        assert g.read(q+'behavior')==g.address(behavior) and g.read(q+'activeFlags')
        actor_before={f:g.read(q+f) for f in ['oPosX','oPosY','oPosZ','oAction','oForwardVel','oVelX','oVelY','oVelZ','hitboxRadius','hitboxHeight','hitboxDownOffset']}
        for axis,value in zip('XYZ',actor_xyz):
            if value is not None:write(q+'oPos'+axis,value)
        before=snapshot(g,o); pad=dict(buttons=0x2000,stick=[0,64]);set_input(g,pad);g.advance()
        assert not g.read('gMarioState.input')&0x82
        after=snapshot(g,o); events=frame_events(g); continuation=[]
        for _ in range(28):
            set_input(g,NEUTRAL);g.advance();assert not g.read('gMarioState.input')&0x82
            r=snapshot(g,o);continuation.append(r)
            if r['area']==2:break
        handoff=after['movement']==[-1882.,768.,-939.] and after['collision']==after['movement'] and after['display']==[-1882.,1741.,-939.] and after['action']==CRAWLING
        first=continuation[0]
        captured=first['action']==0x1300 and first['floorOwner']==61 and first['platform']==61 and first['used']==64
        arrival=next((r for r in continuation if r['area']==2),None)
        outside=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
        assert (handoff,captured,outside)==((False,False,False) if name.endswith('xz-only') else (True,True,True))
        trials.append(dict(name=name,slot=slot,behavior=behavior,actorBefore=actor_before,edits=edits,before=before,controller=pad,after=after,events=events,nextUpdate=first,arrival=arrival,continuationUpdates=len(continuation),handoff=handoff,topCapture=captured,outsideElevator=outside))
    return dict(schema=1,scope='Supplied high crawling Mario and actor coordinates; no clean actor delivery',baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),trials=trials)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps([{k:t[k] for k in ['name','handoff','topCapture','outsideElevator']} for t in r['trials']]))
