"""Bounded stock-SSL1 pair/triple search with explicit frozen-clone grants.

Primary starts supply an AIR action, position and velocity, never a ground
action. Diagnostic ground-action starts are separately tagged. Actor types,
radii, tangibility and statuses are inherited; no status resets occur during
continuations. Every useful full result gets removal ablations from the same
saved native prefix. No actor or Mario delivery history is claimed.
"""
import argparse,json,sys,time,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import roots as shared_roots,place_actor,actor_snapshot,pose,write,advance,NEUTRAL,rich_sample,frame_events,digest

FAMILIES={
 'shell_box':['shell','box'], 'goomba_box':['goomba','box'],
 'goomba_shell':['goomba','shell'], 'goomba_shell_box':['goomba','shell','box'],
 'two_goombas_box':['goomba','goomba2','box'], 'two_goombas_shell':['goomba','goomba2','shell'],
 'goomba_flyguy_shell':['goomba','flyguy','shell'], 'flyguy_shell_box':['flyguy','shell','box'],
 'klepto_shell_box':['klepto','shell','box'], 'bigbox_shell_box':['bigbox','shell','box'],
 'bobomb_shell_box':['bobomb','shell','box'], 'smallbox_shell_box':['smallbox','shell','box'],
 'goomba_bobomb_shell':['goomba','bobomb','shell'], 'goomba_smallbox_shell':['goomba','smallbox','shell'],
 'buddy_shell_box':['buddy','shell','box'], 'buddy_box':['buddy','box'],
 'buddy_shell':['buddy','shell'], 'goomba_box_buddy':['goomba','box','buddy'],
 'two_bobombs_box':['bobomb','bobomb2','box']}
GEOMETRIES=['east','west','north','south','deep-bounce','side-enemy','above-enemy','opposing-centers']
ENEMIES={'goomba','goomba2','flyguy','klepto'}

class Guard:
    def __init__(self,g):self.g=g;self.setup=False
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        if not self.setup:assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        self.g.write(p,v)

def roots(capture):
    g,o,b,inv,prep=shared_roots(capture);g=Guard(g)
    def choose(behavior,index=0):
        a=[a for a in inv if a['behavior']==behavior and a['intangible']==0 and a['radius']>0]
        assert len(a)>index,(behavior,index)
        return a[index]
    catalog={name:choose(behavior,index) for name,behavior,index in [
      ('goomba','bhvGoomba',0),('goomba2','bhvGoomba',1),('flyguy','bhvFlyGuy',0),
      ('klepto','bhvKlepto',0),('shell','bhvKoopaShell',0),('box','bhvJumpingBox',0),
      ('bobomb','bhvBobomb',0),('bobomb2','bhvBobomb',1),('smallbox','bhvBreakableBoxSmall',0),
      ('bigbox','bhvBreakableBox',0),('buddy','bhvBobombBuddyOpensCannon',0)]}
    return g,o,b,inv,catalog,prep

def actor_spec(r,name,catalog):
    originalActors=FAMILIES.get(r['family'],r['actors'])
    geom=r['geometry'];direction={'east':(1,0),'west':(-1,0),'north':(0,1),'south':(0,-1)}.get(geom,(1,0));dx,dz=direction;y=r['height'];x,z=-1950,-939
    if name in ENEMIES or name=='bigbox':
        off=-70 if geom=='deep-bounce' else 0 if geom=='side-enemy' else 80 if geom=='above-enemy' else -10
        xyz=[x+(60 if name in ['goomba2','flyguy'] and 'goomba' in originalActors else 0),y+off,z]
    else:
        sign=-1
        if geom=='opposing-centers' and name in ['box','bobomb2','buddy']:sign=1
        xyz=[x+sign*39*dx,y-10 if name=='shell' else y,z+sign*39*dz]
    mode='native'
    if r['flavor']=='clone':
        targets=[n for n in originalActors if n in ENEMIES]
        if not targets:targets=['bigbox'] if 'bigbox' in originalActors else ['shell'] if 'shell' in originalActors else []
        if name in targets:mode='carry_clone'
    if name in r.get('positions',{}):xyz=r['positions'][name]
    return dict(name=name,slot=catalog[name]['slot'],xyz=xyz,mode=mode)

def sample(g,o):
    return dict(movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],display=g.read('gMarioObject.header.gfx.pos'),velocity=g.read('gMarioState.vel'),action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),area=g.read('gCurrAreaIndex'),warpOp=g.read('sDelayedWarpOp'),countdown=g.read('sDelayedWarpTimer'),collisions=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]')) for i in range(g.read('gMarioObject.numCollidedObjs'))])

def trial(g,o,base,catalog,r,full=False):
    g.load_state(base);g.setup=True;edits=[];pose(g,[-1950,r['height'],-939],edits)
    action=r['action'];speed=r['speed'];vy=r['vy']
    for k,v in [('action',g.constant(action)),('forwardVel',speed),('vel',[speed,vy,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    if r['kind']=='supplied-ground-control':
        for k,v in [('actionState',0),('actionTimer',0),('slideVelX',speed),('slideVelZ',0),('slideYaw',16384)]:write(g,'gMarioState.'+k,v,edits)
    actorEdits=[];setups=[]
    for name in r['actors']:
        s=actor_spec(r,name,catalog);setup=place_actor(g,s['slot'],s['xyz'],actorEdits,s['mode']);setups.append(dict(spec=s,setup=setup))
    g.setup=False;initial=rich_sample(g,o) if full else None;rows=[];events=[];actors=[];pads=[];firstEvents=[];highGround=[]
    targets={g.constant(n) for n in ['ACT_CRAWLING','ACT_CROUCH_SLIDE','ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE']}
    for i in range(40 if full else 4):
        pad=dict(buttons=r['buttons'],stick=r.get('stick',[0,0])) if i==0 else NEUTRAL;advance(g,pad);s=rich_sample(g,o) if full else sample(g,o);rows.append(s);es=frame_events(g)
        if i==0:firstEvents=es
        for e in es:
            if e['type']=='FLT_EXECUTE_ACTION' and e['action'] in targets and e['pos'][1]>20000:highGround.append(dict(update=i+1,event=e))
        if full:
            events.append(es);pads.append(pad);actors.append([actor_snapshot(g,catalog[n]['slot']) for n in r['actors']])
        elif i==0:actors.append([dict(name=n,slot=catalog[n]['slot'],position=[g.read(f'gObjectPool[{catalog[n]["slot"]}].oPos'+a) for a in 'XYZ'],status=g.read(f'gObjectPool[{catalog[n]["slot"]}].oInteractStatus'),active=g.read(f'gObjectPool[{catalog[n]["slot"]}].activeFlags')) for n in r['actors']])
        if s['area']!=1:break
    capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows);arrival=next((s for s in rows if s['area']==2),None);useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return dict(recipe=r,initial=initial,marioEdits=edits if full else None,actorEdits=actorEdits if full else None,actorSetups=setups if full else None,controls=pads,samples=rows,events=events,firstEvents=firstEvents,actors=actors,highGroundExecutions=highGround,capture=capture,useful=useful)

def recipes():
    for family,names in FAMILIES.items():
      flavors=['native','clone'] if any(n in ENEMIES or n in ['bigbox','shell'] for n in names) else ['native']
      for height in [25000,67277]:
       for flavor in flavors:
        for geom in GEOMETRIES:
         for buttons in [0,0x2000]:
            yield dict(kind='air-entry',family=family,actors=names,height=height,flavor=flavor,geometry=geom,buttons=buttons,action='ACT_FREEFALL',speed=20,vy=-16)
    for family in ['goomba_box','goomba_shell_box']:
      for height in [25000,67277]:
       for flavor in ['native','clone']:
        for geom in GEOMETRIES:
         for action,speed,vy in [('ACT_FREEFALL',20,16),('ACT_DIVE',64,-16)]:
            yield dict(kind='air-entry',family=family,actors=FAMILIES[family],height=height,flavor=flavor,geometry=geom,buttons=0,action=action,speed=speed,vy=vy)
    for height in [25000,67277]:
      for family,names,action,speed,flavor in [
        ('box_only',['box'],'ACT_CRAWLING',0,'native'),('box_only',['box'],'ACT_BUTT_SLIDE',20,'native'),
        ('shell_box',['shell','box'],'ACT_BUTT_SLIDE',20,'native'),
        ('goomba_shell_box',['goomba','shell','box'],'ACT_BUTT_SLIDE',64,'clone'),
        ('buddy_shell_box',['buddy','shell','box'],'ACT_BUTT_SLIDE',20,'native')]:
        yield dict(kind='supplied-ground-control',family=family,actors=names,height=height,flavor=flavor,geometry='east',buttons=0x2000 if action=='ACT_CRAWLING' else 0,stick=[0,64] if action=='ACT_CRAWLING' else [0,0],action=action,speed=speed,vy=0)

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();g,o,base,inv,catalog,prep=roots(a.capture);start=time.time();screens=[];positives=[]
    for r in recipes():
        t=trial(g,o,base,catalog,r);screens.append(t)
        if t['capture']:positives.append(r);print('CAPTURE',r,flush=True)
    selected=positives+[t['recipe'] for t in screens if t['recipe']['kind']=='supplied-ground-control']
    for t in screens:
        r=t['recipe']
        if r['kind']=='air-entry' and r['action']=='ACT_FREEFALL' and r['vy']==-16 and r['geometry']=='east' and r['buttons']==0x2000 and r['flavor']=='clone' and r['family'] in ['goomba_box','goomba_shell_box','two_goombas_box','flyguy_shell_box','klepto_shell_box','goomba_box_buddy']:selected.append(r)
        if r['kind']=='air-entry' and r['height']==25000 and r['geometry']=='opposing-centers' and r['buttons']==0 and r['family']=='two_bobombs_box':selected.append(r)
        if r['kind']=='air-entry' and r['family'] in ['shell_box','buddy_shell_box'] and r['geometry']=='east' and r['flavor']=='native' and r['buttons']==0x2000:selected.append(r)
    q,qo,qbase,qinv,qcat,qprep=roots(a.capture);assert prep==qprep and inv==qinv and catalog==qcat;trials=[];seen=set();ablations=[]
    def checked(r):
        key=json.dumps(r,sort_keys=True)
        if key in seen:return next(t for t in trials if json.dumps(t['recipe'],sort_keys=True)==key)
        seen.add(key);t=trial(g,o,base,catalog,r,True);assert t==trial(q,qo,qbase,qcat,r,True);trials.append(t);return t
    selected=list({json.dumps(r,sort_keys=True):r for r in selected}.values())
    for r in selected:
        t=checked(r)
        if t['capture'] or t['useful']:
            for name in r['actors']:
                rr=dict(r,actors=[n for n in r['actors'] if n!=name],removedActor=name);tt=checked(rr);ablations.append(dict(original=r,removed=name,recipe=rr,capture=tt['capture'],useful=tt['useful']))
    # Prefix-removal comparisons for the main frozen triple show each handler's
    # actual contribution, independently of whether a handoff is useful.
    for height in [25000,67277]:
      rr=dict(kind='air-entry',family='goomba_shell_box',actors=['goomba','shell','box'],height=height,flavor='clone',geometry='east',buttons=0,action='ACT_FREEFALL',speed=20,vy=-16)
      for names in [[],['goomba'],['goomba','shell'],['goomba','shell','box']]:checked(dict(rr,actors=names,prefixAblation=True))
    for family,flavor,geom,namesets in [
      ('two_goombas_box','clone','east',[['goomba'],['goomba2'],['goomba','goomba2'],['goomba','goomba2','box']]),
      ('two_bobombs_box','native','opposing-centers',[['bobomb'],['bobomb2'],['box'],['bobomb','bobomb2'],['bobomb','bobomb2','box']])]:
      for names in namesets:checked(dict(kind='air-entry',family=family,actors=names,height=25000,flavor=flavor,geometry=geom,buttons=0,action='ACT_FREEFALL',speed=20,vy=-16,sameTypeComparison=True))
    counts={kind:dict(recipes=sum(t['recipe']['kind']==kind for t in screens),highGroundRecipes=sum(t['recipe']['kind']==kind and bool(t['highGroundExecutions']) for t in screens),captureRecipes=sum(t['recipe']['kind']==kind and t['capture'] for t in screens)) for kind in ['air-entry','supplied-ground-control']}
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),fixtureSha256=digest(ROOT/'instrumentation/ink-item-clone-controls/fixtures.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),shellPreparation=prep,inventory=inv,catalog=catalog,menu=dict(families=FAMILIES,geometries=GEOMETRIES,heights=[25000,67277],firstInputs=[0,0x2000],screenUpdates=4,fullMaxUpdates=40),counts=counts,screens=screens,trials=trials,ablations=ablations,freshBoundaries=sum(len(t['samples']) for t in trials),fullUsefulAir=sum(t['useful'] and t['recipe']['kind']=='air-entry' for t in trials),fullUsefulSuppliedGround=sum(t['useful'] and t['recipe']['kind']=='supplied-ground-control' for t in trials),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'full',len(trials),'fresh',result['freshBoundaries'],'usefulAir',result['fullUsefulAir'],'usefulGround',result['fullUsefulSuppliedGround'],flush=True)

if __name__=='__main__':main()
