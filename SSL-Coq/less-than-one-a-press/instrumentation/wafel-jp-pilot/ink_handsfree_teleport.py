"""Focused JP hands-free teleport/actor diagnostics and clean Bob-omb search.

Every non-controller gameplay write belongs to an explicit local setup ledger.
Actor identity is tracked by original slot, behavior, active flags and owner;
address reuse alone is never counted as survival. No complete Ink route claim.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from replay import create_game, Observer, load_capture
from ink_box_delivery import accepted_prefix, advance, steer
from ink_crawl_predecessors import pose, write

NEUTRAL=dict(buttons=0,stick=[0,0])
BEHAVIORS=('bhvBobomb','bhvJumpingBox','bhvBreakableBoxSmall','bhvKoopaShell','bhvFadingWarp')

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def actor(g,slot):
    q=f'gObjectPool[{slot}].';behavior=g.read(q+'behavior')
    name=next((b for b in BEHAVIORS if behavior==g.address(b)),'other')
    r=dict(slot=slot,behavior=name,owner=g.read(q+'header.gfx.activeAreaIndex'),
           xyz=[g.read(q+'oPos'+a)for a in 'XYZ'],
           velocity=[g.read(q+'oVel'+a)for a in 'XYZ'])
    for f in ('activeFlags','oAction','oTimer','oHeldState','oIntangibleTimer',
              'oInteractStatus','oInteractionSubtype','oInteractType','oForwardVel',
              'hitboxRadius','hitboxHeight','hitboxDownOffset'):
        r[f]=g.read(q+f)
    r['scale']=g.read(q+'header.gfx.scale')
    if name=='bhvBobomb':r.update(fuse=g.read(q+'oBobombFuseTimer'),lit=g.read(q+'oBobombFuseLit'))
    return r

def snap(g,o,slots):
    return dict(timer=g.read('gGlobalTimer'),area=g.read('gCurrAreaIndex'),
       action=g.read('gMarioState.action'),arg=g.read('gMarioState.actionArg'),actionState=g.read('gMarioState.actionState'),
       actionTimer=g.read('gMarioState.actionTimer'),input=g.read('gMarioState.input'),
       movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a)for a in 'XYZ'],
       display=g.read('gMarioObject.header.gfx.pos'),velocity=g.read('gMarioState.vel'),
       forward=g.read('gMarioState.forwardVel'),face=g.read('gMarioState.faceAngle'),
       held=o.slot(g.read('gMarioState.heldObj')),used=o.slot(g.read('gMarioState.usedObj')),
       floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),
       platform=o.slot(g.read('gMarioPlatform')),hitboxHeight=g.read('gMarioObject.hitboxHeight'),
       marioInteract=g.read('gMarioObject.oInteractStatus'),actors=[actor(g,s)for s in slots])

def inventory(g):
    rows=[]
    for slot in range(240):
        q=f'gObjectPool[{slot}].'
        if g.read(q+'activeFlags') and (g.read(q+'oInteractType')&2 or
              any(g.read(q+'behavior')==g.address(b)for b in BEHAVIORS)):
            rows.append(actor(g,slot))
    return rows

def clean_bobomb_idle_seed(capture):
    """Fresh controller-only seed: accepted prefix350 + canonical 197 updates.

    Returns Game, Observer, reproducible record. No gameplay memory edits.
    """
    rows=load_capture(capture);g=create_game();o=Observer(g)
    accepted_prefix(g,o,rows,350);controls=[];samples=[];done=False;pressed=False;firstheld=None
    for k in range(197):
        p=g.read('gMarioState.pos');done|=math.hypot(p[0]-1750,p[2]-7050)<60
        a=actor(g,39);target=(a['xyz'][0],a['xyz'][2]) if done else (1750,7050)
        distance=math.hypot(p[0]-a['xyz'][0],p[2]-a['xyz'][2])
        press=done and not pressed and distance<140 and g.read('gMarioState.forwardVel')>=29
        if press:pressed=True
        if firstheld is not None:target=(1120,5800)
        pad=steer(g,target,0x4000 if press else 0x2000 if pressed else 0)
        controls.append(pad);advance(g,pad);r=snap(g,o,[39]);samples.append(r)
        if firstheld is None and r['held']==39:firstheld=k+1
    assert samples[-1]['held']==39 and samples[-1]['action']==0x0c400201
    assert samples[-1]['actors'][0]['fuse']==89
    return g,o,dict(prefixLength=350,controls=controls,samples=samples,gameplayEdits=[])

def prepare_orphan(capture, side='east', teleport_updates=75, translate_actor=True):
    """Fresh native teleport with an explicit position-only local setup.

    Translation moves M/C/D and (optionally) actor39 XYZ by the same vector.
    All action, held-state, fuse, scale, collision and timing fields are inherited.
    This helper does NOT supply a clean journey to the teleporter.
    """
    g,o,seed=clean_bobomb_idle_seed(capture)
    point={'east':[6930,0,-4871],'west':[-5943,0,-4903]}[side]
    before=snap(g,o,[39]);relative=[a-b for a,b in zip(before['actors'][0]['xyz'],before['movement'])]
    edits=[];pose(g,point,edits)
    if translate_actor:
        for axis,p,delta in zip('XYZ',point,relative):write(g,f'gObjectPool[39].oPos{axis}',p+delta,edits)
    initial=snap(g,o,[39]);samples=[]
    for k in range(teleport_updates):advance(g,NEUTRAL);samples.append(snap(g,o,[39]))
    if teleport_updates>=75:
        assert samples[42]['held']==-1 and samples[-1]['actors'][0]['oHeldState']==1
        assert samples[-1]['actors'][0]['behavior']=='bhvBobomb'
    return g,o,dict(seed=seed,side=side,setupEdits=edits,before=before,initial=initial,
                   controls=[NEUTRAL.copy()for _ in samples],samples=samples)

def return_via_teleporter(g,o, distance=300, threshold=60):
    """Controller-only return from west to east, no additional setup writes."""
    controls=[];samples=[];stage='depart'
    for k in range(180):
        p=g.read('gMarioState.pos');action=g.read('gMarioState.action')
        if stage=='depart' and math.hypot(p[0]+5943+distance,p[2]+4903)<60:stage='settle'
        if stage=='settle' and action==0x0c400201:stage='return'
        if stage=='return' and math.hypot(p[0]+5943,p[2]+4903)<threshold:stage='wait'
        target=(-5943-distance,-4903) if stage=='depart' else (-5943,-4903)
        pad=steer(g,target,0) if stage in ('depart','return')else NEUTRAL.copy()
        controls.append(pad);advance(g,pad);r=snap(g,o,[39]);r['stage']=stage;samples.append(r)
        if p[0]>6000 and action==0x0c400201:break
    return dict(controls=controls,samples=samples,gameplayEdits=[])

def depart_and_settle(g,o,target):
    controls=[];samples=[];settle=False
    for k in range(90):
        p=g.read('gMarioState.pos');settle|=math.hypot(p[0]-target[0],p[2]-target[1])<60
        pad=NEUTRAL.copy()if settle else steer(g,target,0)
        controls.append(pad);advance(g,pad);samples.append(snap(g,o,[39]))
        if settle and samples[-1]['action']==0x0c400201:break
    return dict(controls=controls,samples=samples,gameplayEdits=[])

def fixed_controls(g,o,controls):
    samples=[];names=g.mario_action_names()
    for pad in controls:
        advance(g,pad);r=snap(g,o,[39])
        r['entries']=[names.get(e['action'],hex(e['action']))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION']
        samples.append(r)
    return dict(controls=controls,samples=samples,gameplayEdits=[])

def prepare_bloated_orphan(capture):
    """Explicit stronger diagnostic: native bloat, supplied idle eligibility.

    The second setup translates M/C/D+actor XYZ and supplies ACT_IDLE. It does
    not supply scale, fuse, actor held-state or Mario's held pointer. Therefore
    it does not prove native hands-free acquisition of a bloated Bob-omb.
    """
    g,o,first=prepare_orphan(capture);back=return_via_teleporter(g,o)
    departure=depart_and_settle(g,o,(6930,-5171))
    controls=[dict(buttons=0x4000 if k in (1,20)else 0,stick=[0,0])for k in range(1,26)]
    bloat=fixed_controls(g,o,controls);s=bloat['samples'][-1]
    assert s['held']==39 and s['actors'][0]['scale'][0]>1.79
    relative=[a-b for a,b in zip(s['actors'][0]['xyz'],s['movement'])]
    edits=[];point=[6930,0,-4871];pose(g,point,edits)
    for axis,p,delta in zip('XYZ',point,relative):write(g,f'gObjectPool[39].oPos{axis}',p+delta,edits)
    write(g,'gMarioState.action',0x0c400201,edits)
    initial=snap(g,o,[39]);teleport=fixed_controls(g,o,[NEUTRAL.copy()for _ in range(75)])
    assert teleport['samples'][0]['action']==0x1336
    assert teleport['samples'][-1]['held']==-1
    assert teleport['samples'][-1]['actors'][0]['oHeldState']==1
    return g,o,dict(firstTeleport=first,firstReturn=back,departure=departure,nativeBloat=bloat,
        setupEdits=edits,initial=initial,teleport=teleport)

def run(capture,clean_inputs):
    rows=load_capture(capture);g=create_game();o=Observer(g)
    accepted_prefix(g,o,rows,350);stock=inventory(g);initial=snap(g,o,[47,49])
    states=g.save_state();bobs=[r['slot']for r in stock if r['behavior']=='bhvBobomb']
    search=[];seeds=[];names=g.mario_action_names()
    for slot in bobs:
      for waypoint in [(1750,7050),(2250,6900),(3800,6500)]:
       for radius in [100,140,200]:
        g.load_state(states);controls=[];samples=[];events=[];done=False;pressed=False;last=None;firstheld=None;hf=None
        for k in range(240):
            p=g.read('gMarioState.pos');done|=math.hypot(p[0]-waypoint[0],p[2]-waypoint[1])<60
            a=actor(g,slot);target=(a['xyz'][0],a['xyz'][2]) if done else waypoint
            distance=math.hypot(p[0]-a['xyz'][0],p[2]-a['xyz'][2])
            press=done and not pressed and distance<radius and g.read('gMarioState.forwardVel')>=29
            if press:pressed=True
            if firstheld is not None:target=(1120,5800)
            pad=steer(g,target,0x4000 if press else 0x2000 if pressed else 0)
            controls.append(pad);advance(g,pad);r=snap(g,o,[slot]);samples.append(r)
            acts=[names.get(e['action'],hex(e['action']))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION']
            if firstheld is None and r['held']==slot:firstheld=k+1
            if hf is None and 'ACT_DIVE_PICKING_UP'in acts and r['held']==slot and r['action']in [0x008c0453,0x00840452,0x0100088c]:hf=k+1
            key=(r['action'],r['held'],r['actors'][0]['activeFlags'],r['actors'][0]['behavior'])
            if key!=last:events.append(dict(update=k+1,entries=acts,sample=r));last=key
            if firstheld is not None and r['held']==slot and r['action']==0x0c400201:
                seeds.append(dict(label=f'bob{slot}-idle-{waypoint[0]}-{waypoint[1]}-r{radius}',slot=slot,state=g.save_state(),controls=controls.copy(),initial=r))
                break
        search.append(dict(slot=slot,waypoint=waypoint,radius=radius,controls=controls,
          firstHeld=firstheld,firstHandsfree=hf,events=events,samples=samples,
          gameplayEdits=[]))
    clean=[json.loads(l)for l in clean_inputs.read_text().splitlines()if l.strip()]
    boxgame=create_game();bo=Observer(boxgame)
    for pad in clean[:514]:advance(boxgame,pad)
    assert boxgame.read('gMarioState.action')==0x0c400201 and bo.slot(boxgame.read('gMarioState.heldObj'))==47
    seeds.insert(0,dict(label='clean-box47-idle',slot=47,state=boxgame.save_state(),controls=clean[:514],initial=snap(boxgame,bo,[47])))
    local=[]
    for seed in seeds[:5]:
      for side,point in [('east',[6930,0,-4871]),('west',[-5943,0,-4903])]:
       for leave in ['neutral','crawl']:
        # Each fresh Game loads only a complete state produced by the named prefix.
        game=boxgame if seed['slot']==47 else g;obs=bo if seed['slot']==47 else o
        game.load_state(seed['state']);edits=[];pose(game,point,edits)
        before=snap(game,obs,[seed['slot']]);samples=[];controls=[];events=[];last=None
        for k in range(140):
            action=game.read('gMarioState.action')
            pad=NEUTRAL.copy()
            if leave=='crawl':pad=dict(buttons=0x2000,stick=[0,64])
            controls.append(pad);advance(game,pad);r=snap(game,obs,[seed['slot']]);samples.append(r)
            key=(r['action'],r['held'],r['actors'][0]['activeFlags'],r['actors'][0]['behavior'])
            if key!=last:events.append(dict(update=k+1,sample=r));last=key
        local.append(dict(seed=seed['label'],slot=seed['slot'],side=side,leave=leave,
          seedControls=seed['controls'],seedInitial=seed['initial'],setupEdits=edits,
          before=before,controls=controls,samples=samples,events=events))
    return dict(schema=1,scope=__doc__,baselineSha256=sha(capture),cleanInputsSha256=sha(clean_inputs),
       runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),scriptSha256=sha(__file__),
       stock=stock,initial=initial,cleanBobombSearch=search,localTeleports=local,
       summary=dict(bobombPolicies=len(search),bobombPickups=sum(t['firstHeld']is not None for t in search),
          bobombHandsfree=sum(t['firstHandsfree']is not None for t in search),idleHeldBobombSeeds=len(seeds)-1,
          localTeleports=len(local)))

def study(capture,clean_inputs):
    """Selected fresh-replayed witnesses, with every setup cut in its ledger."""
    g,o,first=prepare_orphan(capture);back=return_via_teleporter(g,o);base=g.save_state()
    regrab=fixed_controls(g,o,[dict(buttons=0x4000 if k==1 else 0,stick=[0,0])for k in range(1,36)])
    assert regrab['samples'][5]['held']==39
    assert regrab['samples'][17]['held']==-1 and regrab['samples'][17]['actors'][0]['oHeldState']==0
    assert regrab['samples'][24]['actors'][0]['activeFlags']==0
    g.load_state(base);release_controls=[]
    for k in range(35):
        action=g.read('gMarioState.action')
        pad=dict(buttons=0x4000 if k==0 else 0x2000,
                 stick=[0,64]if action in(0x0c008220,0x0c008223,0x04008448)else[0,0])
        release_controls.append(pad);advance(g,pad)
    g.load_state(base);release_crawl=fixed_controls(g,o,release_controls)
    assert release_crawl['samples'][17]['actors'][0]['oHeldState']==0
    assert release_crawl['samples'][24]['actors'][0]['activeFlags']==0
    assert not any(s['action']==0x04008448 for s in release_crawl['samples'][:25])
    bloat=[]
    for second in range(17,24):
        g.load_state(base)
        trial=fixed_controls(g,o,[dict(buttons=0x4000 if k in (1,second)else 0,stick=[0,0])for k in range(1,31)])
        trial['secondB']=second;bloat.append(trial)
    bg,bo,big=prepare_bloated_orphan(capture);bigback=return_via_teleporter(bg,bo)
    push=fixed_controls(bg,bo,[NEUTRAL.copy()for _ in range(4)])
    previous=bigback['samples'][-1]['movement']
    for sample in push['samples']:
        point=sample['movement']
        displacement=math.hypot(point[0]-previous[0],point[2]-previous[2])
        assert abs(displacement-49)<0.001 and sample['held']==-1
        assert sample['velocity']==[0,0,0] and sample['forward']==0
        assert sample['actors'][0]['behavior']=='bhvBobomb' and sample['actors'][0]['oHeldState']==1
        previous=point
    # Fresh instances reproduce the complete chosen state projections.
    g2,o2,first2=prepare_orphan(capture);back2=return_via_teleporter(g2,o2)
    regrab2=fixed_controls(g2,o2,regrab['controls'])
    assert first==first2 and back==back2 and regrab==regrab2
    g2,o2,_=prepare_orphan(capture);return_via_teleporter(g2,o2)
    assert fixed_controls(g2,o2,release_controls)==release_crawl
    bg2,bo2,big2=prepare_bloated_orphan(capture);bigback2=return_via_teleporter(bg2,bo2)
    push2=fixed_controls(bg2,bo2,push['controls'])
    assert big==big2 and bigback==bigback2 and push==push2
    clean=[json.loads(l)for l in clean_inputs.read_text().splitlines()if l.strip()]
    box=create_game();ob=Observer(box)
    for pad in clean[:514]:advance(box,pad)
    boxbefore=snap(box,ob,[47]);edits=[];pose(box,[6930,0,-4871],edits)
    boxcontrols=[NEUTRAL.copy()for _ in range(75)]+[dict(buttons=0x4000 if k==0 else 0,stick=[0,0])for k in range(35)]
    boxsamples=[]
    for pad in boxcontrols:advance(box,pad);boxsamples.append(snap(box,ob,[47]))
    return dict(schema=2,scope=__doc__,baselineSha256=sha(capture),cleanInputsSha256=sha(clean_inputs),
      runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),scriptSha256=sha(__file__),
      normalTeleport=first,normalReturn=back,regrabRelease=regrab,releaseCrawl=release_crawl,bloatSecondPressSweep=bloat,
      bloatedTeleport=big,bloatedReturn=bigback,bloatedNeutralPush=push,
      jumpingBoxControl=dict(prefixLength=514,before=boxbefore,setupEdits=edits,controls=boxcontrols,samples=boxsamples),
      validation=dict(freshNormalTeleportReturnRegrabEqual=True,freshBloatedTeleportReturnPushEqual=True,
        scope='Exact equality of recorded projections, not whole-memory or original-ROM equivalence'),
      summary=dict(cleanBobombSeedBranchInputs=len(first['seed']['controls']),nativeReturnInputs=len(back['controls']),
        regrabUpdate=6,releaseUpdate=18,deactivatedUpdate=25,bloatSecondPresses=[18,19,20],
        nativeBloatMaxScale=big['nativeBloat']['samples'][-1]['actors'][0]['scale'][0],
        bloatedOrphanRadius=bigback['samples'][-1]['actors'][0]['hitboxRadius'],
        ordinaryPointer=-1,boxRegrabObserved=any(s['held']==47 for s in boxsamples[75:])))

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('clean_inputs',type=Path);p.add_argument('output',type=Path);p.add_argument('--study',action='store_true')
    a=p.parse_args();r=study(a.capture,a.clean_inputs)if a.study else run(a.capture,a.clean_inputs)
    with a.output.open('x',encoding='utf-8')as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(r['summary'],indent=2))
    for t in r.get('localTeleports',[]):
        print(t['seed'],t['side'],t['leave'],[(e['update'],hex(e['sample']['action']),e['sample']['held'])for e in t['events']])

if __name__=='__main__':main()
