"""Supplied high walking/freefall entry cuts followed by native no-A transitions.

No initialized slide action, slide velocity, floor/cache, platform, or later actor
position is supplied. These are still conditional setup cuts, not clean routes.
"""
import argparse,json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_slide_handoff import roots,shell_root,rich_sample,advance,validate_positive
from ink_floorless_warp import NEUTRAL,reach_after_pillars
from ink_crawl_predecessors import pose,write,steer
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

def walking_root(capture):
    g,o=reach_after_pillars(capture)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):advance(g,NEUTRAL)
    edits=[];pose(g,[-1800,1280,-800],edits)
    for field,value in [('action',g.constant('ACT_WALKING')),('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[20,0,0]),('faceAngle',[0,0x4000,0])]:write(g,'gMarioState.'+field,value,edits)
    pad=steer(g,[-1000,-800],64);pad['buttons']=0
    advance(g,pad)
    after=rich_sample(g,o)
    assert after['action']==g.constant('ACT_WALKING') and after['floorY']==1280 and after['movement'][1]==1280
    return g,o,g.save_state(),dict(edits=edits,control=pad,after=after,events=frame_events(g))

def run(capture):
    g,o,base,_,_=roots(capture)
    sg,so,sbase,shell_prep=shell_root(capture)
    wg,wo,wbase,walk_prep=walking_root(capture)
    trials=[]
    for height in [1741,67277]:
        for kind in ['walking-z-up','walking-z-east','walking-z-neutral','walking-native-z-east','freefall-z-shell','freefall-neutral-shell','freefall-z-no-shell']:
            shell='shell' in kind and 'no-shell' not in kind
            q,obs,state=(wg,wo,wbase) if kind=='walking-native-z-east' else (sg,so,sbase) if shell else (g,o,base)
            q.load_state(state);edits=[]
            pose(q,[-1950,height,-939],edits)
            fields=[] if kind=='walking-native-z-east' else [('action',q.constant('ACT_WALKING' if kind.startswith('walking') else 'ACT_FREEFALL')),
                                ('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[20,-16 if kind.startswith('freefall') else 0,0]),('faceAngle',[0,0x4000,0])]
            for field,value in fields:
                write(q,'gMarioState.'+field,value,edits)
            if kind.startswith('walking'):
                for a,v in zip('XYZ',[-1989,height,-939]):write(q,'gObjectPool[49].oPos'+a,v,edits)
            elif shell:
                for a,v in zip('XYZ',[-1950,height-10,-939]):write(q,f'gObjectPool[{shell_prep["slot"]}].oPos'+a,v,edits)
            if 'neutral-shell' in kind:pad=NEUTRAL
            elif 'z-up' in kind:pad=dict(buttons=0x2000,stick=[0,64])
            elif 'z-east' in kind:pad=steer(q,[-1000,-939],64)
            else:pad=dict(buttons=0x2000,stick=[0,0])
            initial=rich_sample(q,obs);rows=[];events=[];controls=[];shells=[]
            for i in range(32):
                control=pad if i==0 else NEUTRAL
                advance(q,control);rows.append(rich_sample(q,obs));events.append(frame_events(q));controls.append(control)
                if shell:
                    slot=shell_prep['slot']
                    shells.append(dict(slot=slot,active=q.read(f'gObjectPool[{slot}].activeFlags'),action=q.read(f'gObjectPool[{slot}].oAction'),interactStatus=q.read(f'gObjectPool[{slot}].oInteractStatus'),isShell=q.read(f'gObjectPool[{slot}].behavior')==q.address('bhvKoopaShell'),ridden=obs.slot(q.read('gMarioState.riddenObj')),position=[q.read(f'gObjectPool[{slot}].oPos'+a) for a in 'XYZ']))
                if rows[-1]['area']!=1:break
            arrival=next((r for r in rows if r['area']==2),None)
            useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
            t=dict(recipe=dict(name=kind,height=height,firstInput=pad),edits=edits,initial=initial,controls=controls,samples=rows,events=events,shellSamples=shells,
                   topCapture=any(r['floorOwner']==r['platform']==61 and r['used']==64 for r in rows),usefulArrival=useful,firstGap=rows[0]['display'][1]-rows[0]['movement'][1])
            validate_positive(t);trials.append(t)
    return dict(schema=1,scope=__doc__,scriptSha256=digest(__file__),dependenciesSha256={'ink_slide_handoff.py':digest(Path(__file__).with_name('ink_slide_handoff.py'))},baselineSha256=digest(capture),shellPreparation=shell_prep,walkingPreparation=walk_prep,trials=trials)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps([dict(name=t['recipe'],gap=t['firstGap'],first=t['samples'][0]['actionName'],actionEntries=[e.get('action') for e in t['events'][0] if e['type']=='FLT_EXECUTE_ACTION'],capture=t['topCapture'],useful=t['usefulArrival']) for t in r['trials']],indent=2))
