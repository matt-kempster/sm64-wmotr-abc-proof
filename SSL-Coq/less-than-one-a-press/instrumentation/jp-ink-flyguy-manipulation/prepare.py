"""Prepare a fresh original-JP comparison from a real A-off input history."""
import argparse,gzip,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/ink-buddy-replacement-delivery'))
from search import Guard,create_game,Observer,advance
from replay import bits

FIELDS=[('oPosX',True),('oPosY',True),('oPosZ',True),('oVelX',True),('oVelY',True),('oVelZ',True),('oForwardVel',True),
 ('oMoveAnglePitch',False),('oMoveAngleYaw',False),('oMoveAngleRoll',False),('oFaceAnglePitch',False),('oFaceAngleYaw',False),('oFaceAngleRoll',False),
 ('oFlyGuyIdleTimer',False),('oFlyGuyOscTimer',False),('oFlyGuyLungeYDecel',True),('oFlyGuyLungeTargetPitch',False),('oFlyGuyTargetRoll',False),('oFlyGuyScaleVel',True),
 ('oAction',False),('oSubAction',False),('oTimer',False),('oDistanceToMario',True),('oHomeX',True),('oHomeY',True),('oHomeZ',True),('oInteractionSubtype',False),('oInteractStatus',False),
 ('header.gfx.scale[0]',True),('header.gfx.scale[1]',True),('header.gfx.scale[2]',True)]

def main():
    p=argparse.ArgumentParser();p.add_argument('inputs',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
    controls=[json.loads(x)for x in a.inputs.read_text().splitlines()]
    controls=[dict(buttons=r['buttons'],stick=r['stick'])for r in controls]
    assert all(not r['buttons']&0x8000 for r in controls)
    a.out.mkdir(parents=True,exist_ok=False)
    (a.out/'inputs.jsonl').write_bytes((''.join(json.dumps(r,separators=(',',':'))+'\n'for r in controls)).encode())
    (a.out/'controller.inputs').write_bytes((''.join('%d %d %d %d\n'%(i+1,r['buttons'],*r['stick'])for i,r in enumerate(controls))).encode())
    game=Guard(create_game());o=Observer(game);rows=[]
    for i,pad in enumerate(controls):
        observation=o.snapshot()
        if 'positions'in observation:
            words=[]
            for field,flt in FIELDS:
                value=game.read('gObjectPool[45].'+field)
                words.append(bits(value)if flt else value&0xffffffff)
            rows.append(dict(poll=i+1,observation=observation,used=o.slot(game.read('gMarioState.usedObj')),
                held=o.slot(game.read('gMarioState.heldObj')),flyActive=game.read('gObjectPool[45].activeFlags'),flyWords=words))
        advance(game,pad)
    (a.out/'wafel-trace.json.gz').write_bytes(gzip.compress((json.dumps(rows,separators=(',',':'))+'\n').encode(),mtime=0))
    (a.out/'fields.json').write_bytes((json.dumps(FIELDS,indent=2)+'\n').encode())
    print('Prepared',len(controls),'A-off inputs,',len(rows),'observations',a.out)

if __name__=='__main__':main()
