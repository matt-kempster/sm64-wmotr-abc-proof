"""Controller-only continuations of the recorded supplied airborne cap entry.

One declared exterior Mario setup is inherited from the verified entry.
The entry's first input is fixed. All branching starts AFTER that native
entry frame, with no further writes except controller-pad fields.
Finite policies and a bounded beam are experiments, not exhaustive proofs.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys
import time

sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_crawl_edge_entry import (ROOT, CRAWL, snapshot, top_snapshot, events,
                                 controller, sha)
from ink_top_entry_witnesses import setup_fresh

SOURCE=ROOT/"build/wafel-pilot/ink-top-entry-witnesses-v2.json"
Z=0x2000
B=0x4000
AIR=0x800
BUTTON_MODES=["land-z","z-hold","z-pulse","b-z","bz-z","b-land-z","b-repeat-z"]
DIRECTIONS=list(range(0,65536,4096))+["inward","outward","left","right","uphill"]


def state(g,o,top=None):
    s=snapshot(g,o,top)
    s.update(actionState=g.read("gMarioState.actionState"),
             actionTimer=g.read("gMarioState.actionTimer"),
             actionArg=g.read("gMarioState.actionArg"),
             input=g.read("gMarioState.input"),
             buttons=g.read("gMarioState.controller.buttonDown"),
             buttonsPressed=g.read("gMarioState.controller.buttonPressed"),
             animation=g.read("gMarioObject.header.gfx.animInfo.animID"),
             animationFrame=g.read("gMarioObject.header.gfx.animInfo.animFrame"),
             collision=[g.read("gMarioObject.oPos"+a) for a in "XYZ"],
             floorNormal=g.read("gMarioState.floor.normal"),
             floorType=g.read("gMarioState.floor.type"))
    return s


def advance(g,o,pad):
    before_timer=g.read("gGlobalTimer")
    before_top=g.read("gObjectPool[61].oTimer")
    g.advance_pad(pad)
    assert g.read("gGlobalTimer")==before_timer+1
    top=top_snapshot(g)
    return dict(executedTopTimer=before_top,input=pad,
                state=state(g,o,top),entries=events(g,top))


def root_state():
    ref=json.loads(SOURCE.read_text(encoding="utf-8"))["witnesses"]["direct_face_keep-falling"]
    g,o,edits=setup_fresh(ref["recipe"])
    before=snapshot(g,o)
    assert not before["geometry"]["inside"]
    g.advance_pad(ref["updates"][0]["input"])
    assert snapshot(g,o)==ref["updates"][0]["after"]["native"]
    initial=state(g,o)
    assert initial["geometry"]["deep"] and initial["action"]==g.constant("ACT_FREEFALL")
    return g,o,g.save_state(),dict(recipe=ref["recipe"],edits=edits,
             suppliedExterior=before,entryInput=ref["updates"][0]["input"],
             entryState=initial)


def yaw_for(g,direction):
    if isinstance(direction,int):
        return direction
    p=g.read("gMarioState.pos")
    yaw=round(math.atan2(g.read("gObjectPool[61].oPosX")-p[0],
                        g.read("gObjectPool[61].oPosZ")-p[2])*65536/math.tau)&0xffff
    if direction=="uphill":
        n=g.read("gMarioState.floor.normal")
        if n["x"] or n["z"]:
            yaw=round(math.atan2(-n["x"],-n["z"])*65536/math.tau)&0xffff
        return yaw
    return (yaw+dict(inward=0,outward=32768,left=16384,right=49152)[direction])&0xffff


def policy_pad(g,recipe,k,ground_age):
    action=g.read("gMarioState.action")
    ground=not action&AIR
    mode=recipe["mode"]
    delay=recipe["delay"]
    buttons=0
    if mode=="land-z":
        buttons=Z if ground else 0
    elif mode=="z-hold":
        buttons=Z if k>=delay else 0
    elif mode=="z-pulse":
        buttons=Z if k==delay or ground else 0
    elif mode in ("b-z","bz-z","b-land-z"):
        if k==delay:
            buttons=B|(Z if mode=="bz-z" else 0)
        elif k>delay:
            buttons=Z if mode!="b-land-z" or ground else 0
    elif mode=="b-repeat-z":
        buttons=B if k in [delay,delay+2,delay+4,delay+6] else Z if k>delay else 0
    magnitude=recipe["magnitude"]
    if ground and ground_age<=recipe["brakeGroundFrames"]:
        magnitude=0
    return controller(g,yaw_for(g,recipe["direction"]),buttons,magnitude)


def assess(records,constants):
    result=dict(crawl=False,startCrawl=False,crouch=False,crawlInside=False,
                crawlDeep=False,crawlInsideBeforeBelow=False,topLanding=False,
                firstCrawl=None,firstStartCrawl=None,firstBelow=None,
                firstOutside=None,lastInside=1,interiorFrames=1)
    below=False
    actions=set()
    for frame,r in enumerate(records,2):
        s=r["state"]; geom=s["geometry"]
        acts=[e["action"] for e in r["entries"]]+[s["action"]]
        actions.update(acts)
        if CRAWL in acts:
            result["crawl"]=True
            if result["firstCrawl"] is None:result["firstCrawl"]=frame
        if constants["ACT_START_CRAWLING"] in acts:
            result["startCrawl"]=True
            if result["firstStartCrawl"] is None:result["firstStartCrawl"]=frame
        result["crouch"] |= any(a in [constants["ACT_CROUCHING"],constants["ACT_START_CROUCHING"]] for a in acts)
        result["topLanding"] |= s["platform"]==61 and not s["action"]&AIR
        # Action entries precede the completed boundary's exit classification.
        samples=[(e["action"],e["geometry"]) for e in r["entries"]]+[(s["action"],geom)]
        for action,q in samples:
            if q and q["inside"] and action==CRAWL:
                result["crawlInside"]=True
                result["crawlDeep"] |= q["deep"]
                result["crawlInsideBeforeBelow"] |= not below
        if geom and geom["inside"]:
            result["lastInside"]=frame
            result["interiorFrames"]+=1
        elif result["firstOutside"] is None:
            result["firstOutside"]=frame
        if geom and geom["underside"] is not None and s["position"][1]<geom["underside"]-0.01:
            below=True
            if result["firstBelow"] is None:result["firstBelow"]=frame
    result["actions"]=sorted(actions)
    return result


def policy_recipes():
    for mode in BUTTON_MODES:
        delays=[0] if mode=="land-z" else range(8)
        for delay in delays:
            for direction in DIRECTIONS:
                for magnitude in [16,32,64]:
                    for brake in [0,3]:
                        yield dict(mode=mode,delay=delay,direction=direction,
                                   magnitude=magnitude,brakeGroundFrames=brake)


def save_witness(selected,key,recipe,records,outcome):
    if key not in selected:
        selected[key]=dict(recipe=recipe,records=records,outcome=outcome)


def policies(g,o,root,constants,selected,limit):
    summaries=[]; counts=Counter(); actions=Counter(); start=time.monotonic()
    best_inside=0
    for index,recipe in enumerate(policy_recipes()):
        if limit is not None and index>=limit:break
        g.load_state(root)
        records=[]; ground_age=0
        for k in range(21):
            ground_age=ground_age+1 if not g.read("gMarioState.action")&AIR else 0
            pad=policy_pad(g,recipe,k,ground_age)
            records.append(advance(g,o,pad))
            if not records[-1]["state"]["topLive"]:break
        result=assess(records,constants)
        counts["policies"]+=1; counts["updates"]+=len(records)
        for key,value in result.items():
            if isinstance(value,bool):counts[key]+=value
        for action in result["actions"]:actions[action]+=1
        summaries.append(dict(recipe=recipe,**result))
        if not selected:save_witness(selected,"first",recipe,records,result)
        for key in ["crawlInside","crawlDeep","startCrawl","crouch","topLanding","crawl"]:
            if result[key]:save_witness(selected,key,recipe,records,result)
        if result["interiorFrames"]>best_inside:
            best_inside=result["interiorFrames"]
            selected["longestInterior"]=dict(recipe=recipe,records=records,outcome=result)
        if (index+1)%500==0:
            print(json.dumps(dict(policies=index+1,counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
    return dict(counts=dict(counts),actionPolicyCounts=dict(actions),summaries=summaries)


def beam_menu():
    sticks=[(0,0)]
    for magnitude in [16,32,64]:
        for yaw in range(0,65536,8192):
            sticks.append((round(math.sin(yaw*math.tau/65536)*magnitude),
                           round(math.cos(yaw*math.tau/65536)*magnitude)))
    return [dict(buttons=b,stick=list(s)) for b in [0,Z,B,B|Z] for s in sticks]


def rank(s,constants):
    stages={CRAWL:9,"ACT_START_CRAWLING":8,"ACT_CROUCHING":7,
            "ACT_START_CROUCHING":6,"ACT_FREEFALL_LAND_STOP":5,
            "ACT_FREEFALL_LAND":4,"ACT_GROUND_POUND_LAND":4,
            "ACT_DIVE_SLIDE":3,"ACT_STOMACH_SLIDE_STOP":4}
    progress=max((v for k,v in stages.items() if s["action"]==(k if isinstance(k,int) else constants[k])),default=0)
    geom=s["geometry"] or {}
    inside=geom.get("inside",False)
    above=s["position"][1]>(geom.get("underside") or 1e9)
    return (inside and progress>=6,above,progress,inside,s["platform"]==61,
            -abs(s["forward"]),s["position"][1])


def state_key(s):
    # A finite search key, NOT an assertion of whole-state equivalence.
    return json.dumps(s,sort_keys=True,separators=(",",":"))


def beam(g,o,root,constants,selected,width):
    frontier=[dict(saved=root,records=[])]
    menu=beam_menu(); layers=[]; total=0; start=time.monotonic()
    for depth in range(1,22):
        candidates={}; pruned_below=0
        for parent in frontier:
            for pad in menu:
                g.load_state(parent["saved"])
                r=advance(g,o,pad); total+=1
                s=r["state"]
                chain=parent["records"]+[r]
                result=None
                acts=[e["action"] for e in r["entries"]]+[s["action"]]
                interesting=any(a in [CRAWL,constants["ACT_START_CRAWLING"],constants["ACT_CROUCHING"],constants["ACT_START_CROUCHING"]] for a in acts)
                if interesting or s["platform"]==61:
                    result=assess(chain,constants)
                    for key in ["crawlInside","crawlDeep","startCrawl","crouch","topLanding","crawl"]:
                        if result[key]:save_witness(selected,"beam_"+key,dict(beam=True,depth=depth),chain,result)
                geom=s["geometry"]
                if not s["topLive"] or (geom and s["position"][1]<geom["underside"]-0.01):
                    pruned_below+=1
                    continue
                key=state_key(s)
                if key not in candidates:
                    candidates[key]=dict(parent=parent,pad=pad,record=r,score=rank(s,constants))
        ordered=sorted(candidates.values(),key=lambda x:x["score"],reverse=True)
        # Preserve action/timer/button diversity before filling the beam.
        kept=[]; buckets=Counter()
        for c in ordered:
            s=c["record"]["state"]
            bucket=(s["action"],s["actionState"],s["actionTimer"],s["buttons"],s["platform"])
            if buckets[bucket]>=max(2,width//12):continue
            kept.append(c);buckets[bucket]+=1
            if len(kept)>=width:break
        if len(kept)<width:
            seen={id(c) for c in kept}
            kept.extend(c for c in ordered if id(c) not in seen)
            kept=kept[:width]
        next_frontier=[]
        for c in kept:
            g.load_state(c["parent"]["saved"])
            actual=advance(g,o,c["pad"])
            assert actual==c["record"]
            next_frontier.append(dict(saved=g.save_state(),records=c["parent"]["records"]+[actual]))
        layers.append(dict(depth=depth,expanded=len(frontier)*len(menu),uniqueObservedStates=len(candidates),
                           retained=len(next_frontier),prunedBelowOrInactive=pruned_below))
        print(json.dumps(dict(beam=layers[-1],total=total,seconds=time.monotonic()-start)),flush=True)
        frontier=next_frontier
        if not frontier:break
    if frontier:
        records=frontier[0]["records"]
        selected["beamFinal"]=dict(recipe=dict(beam=True),records=records,outcome=assess(records,constants))
    return dict(width=width,menu=menu,layers=layers,expandedUpdates=total,
                limits="Finite pad menu, observed-state key, beam ranking/diversity pruning and below-underside cutoff; not exhaustive")


def verify(witness,reference):
    g,o,_,setup=root_state()
    assert setup==reference
    for r in witness["records"]:
        assert advance(g,o,r["input"])==r
    return dict(passed=True,comparedFrames=len(witness["records"])+1)


def run(output,limit,width):
    g,o,root,setup=root_state()
    names=["ACT_CRAWLING","ACT_START_CRAWLING","ACT_CROUCHING","ACT_START_CROUCHING",
           "ACT_FREEFALL_LAND_STOP","ACT_FREEFALL_LAND","ACT_GROUND_POUND_LAND",
           "ACT_DIVE_SLIDE","ACT_STOMACH_SLIDE_STOP"]
    constants={n:g.constant(n) for n in names}
    selected={}
    batch=policies(g,o,root,constants,selected,limit)
    search=beam(g,o,root,constants,selected,width) if width else None
    validations={name:verify(w,setup) for name,w in selected.items()}
    report=dict(schema=1,scope="Fixed successful airborne entry; initial exterior setup supplied; controller-only continuation",
        setup=setup,policies=batch,beam=search,selected=selected,validations=validations,
        aInputs=0,postSetupWrites="Controller fields only",actionNames=g.mario_action_names(),
        sourceReceiptSha256=sha(SOURCE),scriptSha256=sha(__file__),
        runtimeSha256=sha(ROOT/"build/wafel-pilot/sm64_jp.dll"),
        dependencies={n:sha(Path(__file__).with_name(n)) for n in
          ["ink_top_entry_witnesses.py","ink_crawl_edge_entry.py","ink_crawl_top_entry.py","replay.py"]})
    with output.open("x",encoding="utf-8") as f:
        json.dump(report,f,indent=2,allow_nan=False);f.write("\n")
    print(json.dumps(dict(saved=str(output),counts=batch["counts"],validations=validations)),flush=True)


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("output",type=Path)
    p.add_argument("--limit",type=int)
    p.add_argument("--beam-width",type=int,default=96)
    args=p.parse_args()
    run(args.output,args.limit,args.beam_width)
