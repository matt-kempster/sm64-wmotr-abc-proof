"""Direct supplied-start tests of crawling off the spinning top and re-entry.

Every trial starts from an explicitly supplied exterior or upper-surface
pose/action/velocity. Supported-crawl trials must then complete one native
update with CRAWLING, the native 100-unit hitbox, top-owned floor and platform.
Only controller inputs are written after that preparation. The top, floor
cache, platform pointer, collision mesh, box, timer and RNG are never edited.
This is a local mechanism test, with no controller-produced approach claim.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys
import time

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).resolve().parent))
from replay import create_game, Observer, load_capture, set_input
from ink_crawl_top_entry import top_snapshot, upper_floor, observation
from ink_crawl_predecessors import f32

CRAWL=0x04008448
NEUTRAL=dict(buttons=0,stick=[0,0])
PHASES=[60,76,92,108,120,124,128,129,130,140,148]
PATTERNS=["uphill","neutral","outward","tangent-left","tangent-right","out-then-in"]
ALLOWED={f"gControllerPads[0].{name}" for name in ("button","stick_x","stick_y")}


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


class TrialGame:
    def __init__(self):
        self.game=create_game()
        self.setup=False
        self.ledger=[]
        self.total_updates=0
        self.write_counts=Counter()

    def __getattr__(self,name):
        return getattr(self.game,name)

    def write(self,path,value):
        if path not in ALLOWED:
            assert self.setup,"Non-controller write after setup"
            assert path in {"gMarioState.pos","gMarioObject.oPosX","gMarioObject.oPosY",
                "gMarioObject.oPosZ","gMarioObject.header.gfx.pos",
                "gMarioState.action","gMarioState.actionState","gMarioState.actionTimer",
                "gMarioState.forwardVel","gMarioState.vel","gMarioState.faceAngle"},path
            self.ledger.append(dict(path=path,before=self.read(path),after=value))
        self.write_counts[path]+=1
        self.game.write(path,value)

    def advance_pad(self,pad):
        assert not self.setup
        assert not pad["buttons"]&0x8000
        set_input(self,pad)
        self.game.advance()
        self.total_updates+=1
        assert not self.read("gMarioState.input")&0x82


def controller(g,yaw,buttons=0x2000,magnitude=64):
    camera=g.read("gMarioState.area.camera.yaw")
    angle=(yaw-camera)*math.tau/65536
    return dict(buttons=buttons,stick=[round(math.sin(angle)*magnitude),
                                    round(-math.cos(angle)*magnitude)])


def seed_pose(g,recipe):
    g.ledger=[]
    g.setup=True
    pos=recipe["pos"]
    yaw=recipe["yaw"]&0xffff
    angle=yaw*math.tau/65536
    g.write("gMarioState.pos",pos)
    for axis,value in zip("XYZ",pos):
        g.write("gMarioObject.oPos"+axis,value)
    g.write("gMarioObject.header.gfx.pos",pos)
    g.write("gMarioState.action",recipe["action"])
    g.write("gMarioState.actionState",0)
    g.write("gMarioState.actionTimer",0)
    g.write("gMarioState.forwardVel",recipe["speed"])
    g.write("gMarioState.vel",[f32(math.sin(angle)*recipe["speed"]),
                             recipe.get("verticalSpeed",0),
                             f32(math.cos(angle)*recipe["speed"])])
    g.write("gMarioState.faceAngle",[0,yaw if yaw<32768 else yaw-65536,0])
    g.setup=False
    return list(g.ledger)


def point_class(top,pos):
    if top is None or not top["faces"]:
        return None
    upper=upper_floor(top["faces"],pos[0],pos[2])
    if upper is None:
        return dict(inside=False,deep=False,upper=None,underside=top["underside"])
    depth=upper-pos[1]
    inside=pos[1]>top["underside"]+0.01 and depth>0.01
    return dict(inside=inside,deep=inside and upper-int(pos[1])>78,
                upper=upper,underside=top["underside"],depth=depth)


def snapshot(g,o,top=None):
    r=observation(g,o)
    top=top_snapshot(g) if top is None else top
    r.update(geometry=point_class(top,r["position"]),
             hitboxHeight=g.read("gMarioObject.hitboxHeight"),
             forward=g.read("gMarioState.forwardVel"),
             velocity=g.read("gMarioState.vel"),
             faceAngle=g.read("gMarioState.faceAngle"),
             topLive=top is not None)
    return r


def events(g,top):
    result=[]
    for event in g.frame_log():
        if event["type"]=="FLT_EXECUTE_ACTION":
            r={k:v for k,v in event.items() if k!="reason"}
            r["geometry"]=point_class(top,r["pos"])
            result.append(r)
    return result


def advance_record(g,o,pad):
    g.advance_pad(pad)
    top=top_snapshot(g)
    return dict(state=snapshot(g,o,top),entries=events(g,top))


def is_supported_crawl(s):
    return (s["action"]==CRAWL and s["floorOwner"]==61 and s["platform"]==61
            and s["hitboxHeight"]==100 and abs(s["position"][1]-s["floorY"])<0.05)


def make_contexts(g,rows):
    o=Observer(g)
    for pad in rows[:2548]:
        g.advance_pad(pad)
    states={}
    contexts={}
    for _ in range(155):
        if g.read("gObjectPool[61].oAction")==1:
            phase=g.read("gObjectPool[61].oTimer")
            if phase in PHASES:
                states[phase]=g.save_state()
                contexts[phase]=top_snapshot(g)
        g.advance_pad(NEUTRAL)
    assert len(states)==len(PHASES)
    return o,states,contexts


def recipes(top,phase,mode):
    faces=[f for f in top["faces"] if f["normal"]["y"]>0.01]
    for fi,face in enumerate(faces):
        base=[v for v in face["vertices"] if v[1]==top["underside"]]
        apex=max(face["vertices"],key=lambda v:v[1])
        assert len(base)==2
        normal=face["normal"]
        uphill=round(math.atan2(-normal["x"],-normal["z"])*65536/math.tau)&0xffff
        fractions=[0.05,0.25,0.5,0.75,0.95]
        insets=[1,8,32] if mode=="crawl" else [8,128,256]
        for along in fractions:
            edge=[base[0][j]*(1-along)+base[1][j]*along for j in range(3)]
            for inset in insets:
                t=inset/512
                x=f32(edge[0]*(1-t)+apex[0]*t)
                z=f32(edge[2]*(1-t)+apex[2]*t)
                y=upper_floor(top["faces"],x,z)
                if y is None:
                    continue
                if mode=="crawl":
                    for speed in [0,4,16]:
                        yield dict(phase=phase,face=fi,along=along,inset=inset,
                                   pos=[x,y,z],yaw=uphill,speed=speed,action=CRAWL)
                else:
                    for height in [1,80]:
                        for yaw_offset in [0,0x4000,0x8000,0xc000]:
                            for speed in [0,32,64]:
                                yield dict(phase=phase,face=fi,along=along,inset=inset,
                                    pos=[x,f32(y+height),z],yaw=(uphill+yaw_offset)&0xffff,
                                    speed=speed,verticalSpeed=-16,action=0x0100088c,
                                    heightAboveFace=height)


def direction(g,pattern,k):
    # Use the current position relative to the live cap center. This gives
    # actual inputs for turning at an edge, without moving Mario directly.
    p=g.read("gMarioState.pos")
    center=[g.read("gObjectPool[61].oPos"+a) for a in "XZ"]
    inward=round(math.atan2(center[0]-p[0],center[1]-p[2])*65536/math.tau)&0xffff
    if pattern=="neutral":
        return dict(buttons=0x2000,stick=[0,0])
    offset={"uphill":0,"outward":0x8000,"tangent-left":0x4000,
            "tangent-right":0xc000,"out-then-in":0x8000 if k<3 else 0}[pattern]
    return controller(g,(inward+offset)&0xffff)


def assess(records,initial):
    ever_lost=False
    lost_while_crawling=False
    result=dict(lostTop=False,lostWhileCrawling=False,regainedTop=False,
                insideCrawl=False,deepCrawl=False,deepAfterLoss=False,
                endInsideCrawl=False,insideOtherAction=False,deepOtherAction=False,
                endDeepOtherAction=False)
    marks=[]
    for k,r in enumerate(records,1):
        s=r["state"]
        if not s["topLive"]:
            break
        # Action entries precede the completed update. Only an earlier
        # completed boundary can establish prior loss for these entries.
        for e in r["entries"]:
            geom=e["geometry"]
            if geom and geom["inside"]:
                if e["action"]==CRAWL:
                    result["insideCrawl"]=True
                    if geom["deep"]:
                        result["deepCrawl"]=True
                        result["deepAfterLoss"] |= ever_lost
                        marks.append(dict(update=k,event="deep-crawl-action-entry",
                                          priorLoss=ever_lost,priorCrawlLoss=lost_while_crawling))
                else:
                    result["insideOtherAction"]=True
                    if geom["deep"]:
                        result["deepOtherAction"]=True
                        marks.append(dict(update=k,event="deep-other-action-entry",
                                          action=e["action"]))
        if s["floorOwner"]!=61:
            ever_lost=True
            result["lostTop"]=True
            if s["action"]==CRAWL:
                lost_while_crawling=True
                result["lostWhileCrawling"]=True
                marks.append(dict(update=k,event="upper-floor-lost-while-crawling"))
        elif ever_lost:
            result["regainedTop"]=True
        geom=s["geometry"]
        if geom and geom["inside"] and s["action"]==CRAWL:
            result["endInsideCrawl"]=True
            if geom["deep"]:
                result["deepCrawl"]=True
                result["deepAfterLoss"] |= ever_lost
                marks.append(dict(update=k,event="deep-crawl-boundary"))
        elif geom and geom["deep"]:
            result["deepOtherAction"]=True
            result["endDeepOtherAction"]=True
            marks.append(dict(update=k,event="deep-other-action-boundary",action=s["action"]))
    result["finalAction"]=records[-1]["state"]["action"] if records else initial["action"]
    return result,marks


def run_suffix(g,o,mode,pattern,horizon):
    pads=[]
    records=[]
    for k in range(horizon):
        if g.read("gMarioState.area.camera").is_null():
            break
        if (g.read("gObjectPool[61].behavior")!=g.address("bhvPyramidTop")
                or not g.read("gObjectPool[61].activeFlags")):
            break
        if mode=="crawl":
            pad=direction(g,pattern,k)
        else:
            # Native freefall/dive continuation from the supplied exterior
            # start. B is pressed only for the dive pattern; A is always off.
            pad=controller(g,g.read("gMarioState.faceAngle")[1],
                           0x4000 if pattern=="dive" and k==0 else 0)
        pads.append(pad)
        records.append(advance_record(g,o,pad))
        if records[-1]["state"]["area"]!=1:
            break
    return pads,records


def replay(capture,selected,mode):
    g=TrialGame()
    assert g.constant("ACT_CRAWLING")==CRAWL
    assert g.constant("ACT_FREEFALL")==0x0100088c
    rows=load_capture(capture)
    o=Observer(g)
    for pad in rows[:2548]:
        g.advance_pad(pad)
    phase=selected["recipe"]["phase"]
    while not (g.read("gObjectPool[61].oAction")==1 and g.read("gObjectPool[61].oTimer")==phase):
        g.advance_pad(NEUTRAL)
    ledger=seed_pose(g,selected["recipe"])
    assert ledger==selected["edits"]
    if mode=="crawl":
        got=advance_record(g,o,selected["primeInput"])
        assert got==selected["prime"]
        assert is_supported_crawl(got["state"])
    for pad,expected in zip(selected["inputs"],selected["records"]):
        got=advance_record(g,o,pad)
        assert got==expected
    return dict(passed=True,compared=len(selected["records"])+(mode=="crawl"),
                initialSetup=ledger,postSetupWrites="controller fields only")


def run(output,mode,limit=None):
    capture=ROOT/"build/wafel-pilot/capture.bKv95w/inputs.jsonl"
    rows=load_capture(capture)
    g=TrialGame()
    o,states,contexts=make_contexts(g,rows)
    summaries=[]
    rejected=Counter()
    counts=Counter()
    selected={}
    preparation=[]
    start=time.monotonic()
    phases=PHASES if mode=="crawl" else [108,120,128,129,130,140]
    for phase in phases:
        for seed_index,recipe in enumerate(recipes(contexts[phase],phase,mode)):
            if limit is not None and counts["initialSeeds"]>=limit:
                break
            g.load_state(states[phase])
            edits=seed_pose(g,recipe)
            counts["initialSeeds"]+=1
            initial=snapshot(g,o)
            if initial["geometry"] and initial["geometry"]["inside"]:
                raise AssertionError("Supplied start already inside cap")
            prime_pad=None
            prime=None
            if mode=="crawl":
                prime_pad=controller(g,recipe["yaw"])
                prime=advance_record(g,o,prime_pad)
                if not is_supported_crawl(prime["state"]):
                    rejected[hex(prime["state"]["action"])]+=1
                    continue
                initial=prime["state"]
                counts["nativeSupportedCrawlSeeds"]+=1
            prepared=g.save_state()
            patterns=PATTERNS if mode=="crawl" else ["fall","dive"]
            for pattern in patterns:
                g.load_state(prepared)
                pads,records=run_suffix(g,o,mode,pattern,24)
                outcome,marks=assess(records,initial)
                counts["trials"]+=1
                counts["suffixUpdates"]+=len(records)
                for key,value in outcome.items():
                    if isinstance(value,bool):
                        counts[key]+=value
                summary=dict(recipe=recipe,pattern=pattern,updates=len(records),**outcome)
                summaries.append(summary)
                categories=[]
                for key in ["lostWhileCrawling","regainedTop","deepAfterLoss","deepCrawl",
                            "endInsideCrawl","insideOtherAction","deepOtherAction",
                            "endDeepOtherAction"]:
                    if outcome[key]:
                        categories.append(key)
                if outcome["lostTop"]:
                    categories.append("lostTop")
                if not selected:
                    categories.append("first")
                for category in categories:
                    if category not in selected:
                        selected[category]=dict(recipe=recipe,pattern=pattern,
                            edits=edits,initial=initial,primeInput=prime_pad,prime=prime,
                            inputs=pads,records=records,outcome=outcome,marks=marks)
        print(json.dumps(dict(phase=phase,counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
        if limit is not None and counts["initialSeeds"]>=limit:
            break
    validations={}
    for category,witness in selected.items():
        validations[category]=replay(capture,witness,mode)
    report=dict(schema=1,mode=mode,scope="Supplied upper-surface/exterior local test; entry reachability remains open",
                preEntrySetup="Accepted debug level select before gameplay",
                phases=phases,counts=dict(counts),rejectedPrimeActions=dict(rejected),
                scriptSha256=sha(__file__),
                dependencies={name:sha(Path(__file__).with_name(name)) for name in
                    ["replay.py","ink_crawl_top_entry.py","ink_crawl_predecessors.py"]},
                runtimeSha256=sha(ROOT/"build/wafel-pilot/sm64_jp.dll"),
                captureSha256=sha(capture),aInputs=0,writeCounts=dict(g.write_counts),
                elapsedSeconds=time.monotonic()-start,topContexts=contexts,
                actionNames=g.mario_action_names(),
                summaries=summaries,selected=selected,validations=validations)
    with output.open("x",encoding="utf-8") as f:
        json.dump(report,f,indent=2,allow_nan=False)
        f.write("\n")
    print(json.dumps(dict(saved=str(output),counts=dict(counts))),flush=True)


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output",type=Path)
    parser.add_argument("--mode",choices=["crawl","air"],default="crawl")
    parser.add_argument("--limit",type=int)
    args=parser.parse_args()
    if args.output.exists():
        raise FileExistsError(args.output)
    run(args.output,args.mode,args.limit)

