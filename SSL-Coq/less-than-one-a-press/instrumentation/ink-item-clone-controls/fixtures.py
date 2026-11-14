"""Shared actual stock-actor fixture; placement/freeze grants are explicit.

No type, radius, height, tangibility, status or velocity is manufactured.
carry_clone mirrors the non-HOLDABLE held-state helper's three field effects;
it does not construct a fake pickup, release, allocation lineage or delivery.
"""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_slide_handoff import shell_root,advance,rich_sample
from ink_floorless_warp import NEUTRAL
from ink_crawl_predecessors import pose,write,f32
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

BEHAVIORS=['bhvGoomba','bhvPokey','bhvPokeyBodyPart','bhvFlyGuy','bhvKlepto',
 'bhvBobomb','bhvJumpingBox','bhvBreakableBoxSmall','bhvBreakableBox','bhvToxBox',
 'bhvTweester','bhvKoopaShell','bhvSmallPiranhaFlame','bhvFlyguyFlame','bhvExplosion',
 'bhvNormalCap','bhvWingCap','bhvTree','bhvExclamationBox','bhvStar','bhvYellowCoin',
 'bhvRedCoin','bhvBobombBuddy','bhvBobombBuddyOpensCannon','bhvFireSpitter',
 'bhvWarp','bhvFadingWarp','bhvSpinAirborneWarp','bhvPyramidTop','bhvPoleGrabbing',
 'bhvHiddenRedCoinStar','bhvHiddenStar','bhvCoinInsideBoo','bhvCoinFormation',
 'bhvCoinFormationSpawn','bhvCannonClosed','bhvBulletBill','bhvPiranhaPlant']

def slot_of(g,ptr):
    if ptr.is_null():return -1
    return next((i for i in range(240) if ptr==g.address(f'gObjectPool[{i}]')),-2)

def actor_snapshot(g,slot):
    p=f'gObjectPool[{slot}].'
    behavior=g.read(p+'behavior')
    name=next((n for n in BEHAVIORS if behavior==g.address(n)),'unmapped')
    fields={k:g.read(p+k) for k in ['oFlags','oHeldState','oAction','oTimer','oIntangibleTimer','oInteractType','oInteractionSubtype','oInteractStatus','oVelX','oVelY','oVelZ','oForwardVel','activeFlags','hitboxRadius','hitboxHeight','hitboxDownOffset','hurtboxRadius','hurtboxHeight','bhvStackIndex','oBhvParams','oBhvParams2ndByte']}
    fields.update(slot=slot,behavior=name,position=[g.read(p+'oPos'+a) for a in 'XYZ'],scale=g.read(p+'header.gfx.scale'),parentSlot=slot_of(g,g.read(p+'parentObj')),commandAtCarryStart=g.read(p+'curBhvCommand')==g.address('bhvCarrySomething5'),commandAtCarryBreak=g.read(p+'curBhvCommand')==g.address('bhvCarrySomething5[1]'))
    return fields

def inventory(g):
    rows=[]
    for i in range(240):
        if not g.read(f'gObjectPool[{i}].activeFlags'):continue
        a=actor_snapshot(g,i)
        a.update(interactionType=a['oInteractType'],subtype=a['oInteractionSubtype'],radius=a['hitboxRadius'],height=a['hitboxHeight'],downOffset=a['hitboxDownOffset'],flags=a['oFlags'],active=a['activeFlags'],intangible=a['oIntangibleTimer'],holdable=bool(a['oFlags']&0x400),automaticXZ=bool(a['oFlags']&2),automaticY=bool(a['oFlags']&4))
        rows.append(a)
    return rows

def roots(capture):
    """Return game, observer, saved before130 state, live inventory, prep ledger."""
    g,o,base,prep=shell_root(capture)
    assert g.read('gObjectPool[61].oTimer')==130
    return g,o,base,inventory(g),prep

def place_actor(g,slot,xyz,ledger,mode='native'):
    """Caller enables its setup write guard. No subsequent freeze writes occur."""
    assert mode in ['native','carry_clone','forced_frozen']
    p=f'gObjectPool[{slot}].';before=actor_snapshot(g,slot)
    if mode=='carry_clone':assert not(before['oFlags']&0x400), 'HOLDABLE native release does not install carry script'
    for a,v in zip('XYZ',xyz):write(g,p+'oPos'+a,v,ledger)
    if mode!='native':
        ledger.append(dict(path=p+'parentObj',beforeSlot=before['parentSlot'],afterSymbol='gMarioObject',mode=mode))
        g.write(p+'parentObj',g.read('gMarioObject'))
        ledger.append(dict(path=p+'curBhvCommand',before='inherited '+before['behavior']+' continuation',afterSymbol='bhvCarrySomething5',mode=mode))
        g.write(p+'curBhvCommand',g.address('bhvCarrySomething5'))
        write(g,p+'bhvStackIndex',0,ledger)
    return dict(mode=mode,before=before,after=actor_snapshot(g,slot))
