"""Read-only geometry and controller-only approach study for the moving SSL top.

The accepted pre-entry debug level select is the only non-controller
initialization. Every trial restores a complete state reached with inputs.
No position, action, surface, timer, actor or platform field is written.
Geometry calculations are observations of native meshes, not game updates.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import create_game, Observer, load_capture, set_input
from ink_box_delivery import steer, snap as delivery_snap
from ink_crawl_predecessors import f32

CRAWL = 0x04008448
NEUTRAL = dict(buttons=0, stick=[0, 0])
ALLOWED_WRITES = {f"gControllerPads[0].{f}" for f in ("button", "stick_x", "stick_y")}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


class InputOnly:
    def __init__(self):
        self.game = create_game()
        self.write_counts = Counter()
        self.updates = 0

    def __getattr__(self, name):
        return getattr(self.game, name)

    def write(self, path, value):
        if path not in ALLOWED_WRITES:
            raise AssertionError("Gameplay write forbidden: " + path)
        self.write_counts[path] += 1
        return self.game.write(path, value)

    def advance_pad(self, pad):
        assert not pad["buttons"] & 0x8000
        set_input(self, pad)
        self.game.advance()
        self.updates += 1
        assert not self.read("gMarioState.input") & 0x82


def mesh(g, owner):
    result = []
    for i in range(g.read("gNumStaticSurfaces"), g.read("gSurfacesAllocated")):
        p = f"sSurfacePool[{i}]."
        if g.read(p + "object") == owner:
            result.append(dict(index=i,
                vertices=[g.read(p + "vertex%d" % j) for j in (1, 2, 3)],
                normal=g.read(p + "normal"), offset=g.read(p + "originOffset")))
    return result


def floor_height(face, x, z):
    n = face["normal"]
    return f32(-f32(f32(f32(n["x"] * x) + f32(n["z"] * z)) + face["offset"]) / n["y"])


def contains(face, x, z):
    v = face["vertices"]
    edges = [(a[2]-z)*(b[0]-a[0]) - (a[0]-x)*(b[2]-a[2])
             for a, b in zip(v, v[1:]+v[:1])]
    return min(edges) >= -1e-6


def upper_floor(faces, x, z):
    # Uses native integer vertices and native binary32 plane data.
    x, z = int(x), int(z)
    hits = [floor_height(f, x, z) for f in faces
            if f["normal"]["y"] > 0.01 and contains(f, x, z)]
    return max(hits) if hits else None


def top_snapshot(g):
    live = (g.read("gObjectPool[61].behavior") == g.address("bhvPyramidTop")
            and g.read("gObjectPool[61].activeFlags") != 0)
    if not live:
        return None
    faces = mesh(g, g.address("gObjectPool[61]"))
    return dict(timer=g.read("gObjectPool[61].oTimer"),
                action=g.read("gObjectPool[61].oAction"),
                center=[g.read("gObjectPool[61].oPos"+a) for a in "XYZ"],
                angle=g.read("gObjectPool[61].oFaceAngleYaw"),
                angularVelocity=g.read("gObjectPool[61].oAngleVelYaw"),
                velocity=[g.read("gObjectPool[61].oVel"+a) for a in "XZ"],
                faces=faces,
                underside=min((v[1] for f in faces for v in f["vertices"]), default=None))


def cross(a, b, p):
    return (b[0]-a[0])*(p[1]-a[1]) - (b[1]-a[1])*(p[0]-a[0])


def clip_polygon(poly, boundary):
    # Counterclockwise convex clipping in X/Z, using double arithmetic.
    for a, b in zip(boundary, boundary[1:]+boundary[:1]):
        output = []
        if not poly:
            break
        prev = poly[-1]
        prev_side = cross(a, b, prev)
        for curr in poly:
            curr_side = cross(a, b, curr)
            if (curr_side >= 0) != (prev_side >= 0):
                fraction = prev_side / (prev_side-curr_side)
                output.append([prev[0]+fraction*(curr[0]-prev[0]),
                               prev[1]+fraction*(curr[1]-prev[1])])
            if curr_side >= 0:
                output.append(curr)
            prev, prev_side = curr, curr_side
        poly = output
    return poly


def projected_base(top):
    vertices = {(v[0], v[2]) for f in top["faces"] for v in f["vertices"]
                if v[1] == top["underside"]}
    cx = sum(x for x, z in vertices)/len(vertices)
    cz = sum(z for x, z in vertices)/len(vertices)
    return sorted(vertices, key=lambda p: math.atan2(p[1]-cz, p[0]-cx))


def geometry_study(g, rows):
    for row in rows[:2548]:
        g.advance_pad(row)
    static = []
    for i, s in enumerate(g.surfaces()[:g.read("gNumStaticSurfaces")]):
        if s.normal[1] > 0.01:
            static.append(dict(index=i, vertices=s.vertices,
                               normal=dict(zip("xyz", s.normal)),
                               offset=g.read(f"sSurfacePool[{i}].originOffset")))
    frames = []
    for k in range(153):
        g.advance_pad(NEUTRAL)
        top = top_snapshot(g)
        if top is not None and top["faces"]:
            top["completedInput"] = 2549+k
            frames.append(top)
    overlap = []
    for top in frames:
        boundary = projected_base(top)
        maximum = None
        face_index = None
        for face in static:
            v = face["vertices"]
            polygon = clip_polygon([[a[0], a[2]] for a in v], boundary)
            if polygon:
                n = face["normal"]
                height = max(-(n["x"]*x+n["z"]*z+face["offset"])/n["y"]
                             for x, z in polygon)
                if maximum is None or height > maximum:
                    maximum, face_index = height, face["index"]
        overlap.append(dict(storedTimer=top["timer"], action=top["action"],
                            underside=top["underside"], maxStaticSupportY=maximum,
                            face=face_index,
                            clearance=top["underside"]-maximum))
    # Sample the actual yaw-displacement formula on the native previous faces.
    rises = []
    outside = 0
    for prev, curr in zip(frames, frames[1:]):
        if curr["action"] != 1:
            continue
        angle = curr["angularVelocity"] & 0xffff
        sine = g.read(f"gSineTable[{angle >> 4}]")
        cosine = g.read(f"gSineTable[{((angle + 0x4000) & 0xffff) >> 4}]")
        cx, _, cz = curr["center"]
        for face in prev["faces"]:
            if face["normal"]["y"] <= 0.01:
                continue
            a, b, c = face["vertices"]
            for u in range(17):
                for v in range(17-u):
                    x = (a[0]*(16-u-v)+b[0]*u+c[0]*v)/16
                    z = (a[2]*(16-u-v)+b[2]*u+c[2]*v)/16
                    y = upper_floor(prev["faces"], x, z)
                    if y is None:
                        continue
                    dx = f32(f32(x+curr["velocity"][0])-cx)
                    dz = f32(f32(z+curr["velocity"][1])-cz)
                    nx = f32(cx+f32(f32(cosine*dx)+f32(sine*dz)))
                    nz = f32(cz+f32(f32(-sine*dx)+f32(cosine*dz)))
                    height = upper_floor(curr["faces"], nx, nz)
                    if height is None:
                        outside += 1
                        continue
                    rises.append(dict(phase=curr["timer"]-1, old=[x,y,z],
                                      rotated=[nx,y,nz], newFloorY=height,
                                      rise=height-y))
    by_phase=[]
    for phase in sorted({r["phase"] for r in rises}):
        phase_rows=[r for r in rises if r["phase"]==phase]
        by_phase.append(dict(phase=phase,points=len(phase_rows),
                             maximum=max(phase_rows,key=lambda r:r["rise"])))
    return dict(frames=frames, staticOverlap=overlap, sampler=dict(
        scope="153 barycentric points per upper triangle per transition; algebraic yaw formula with native trig values, not native platform-call replay",
        retainedPoints=len(rises), outsidePoints=outside,
        maxRise=max(rises,key=lambda r:r["rise"]),
        minRise=min(rises,key=lambda r:r["rise"]),
        above78=sum(r["rise"]>78 for r in rises),
        belowSurface=sum(r["rise"]>0 for r in rises),byPhase=by_phase))


def observation(g, o):
    read = g.read
    return dict(timer=read("gGlobalTimer"), area=read("gCurrAreaIndex"),
                level=read("gCurrLevelNum"), position=read("gMarioState.pos"),
                action=read("gMarioState.action"), floorY=read("gMarioState.floorHeight"),
                floorOwner=o.slot(read("gMarioState.floor?.object")),
                platform=o.slot(read("gMarioPlatform")),
                topAction=read("gObjectPool[61].oAction"),
                topTimer=read("gObjectPool[61].oTimer"),
                pillars=read("gObjectPool[61].oPyramidTopPillarsTouched"),
                display=(read("gMarioObject.header.gfx.pos")
                         if o.slot(read("gMarioObject")) >= 0 else None),
                ceilingY=read("gMarioState.ceilHeight"))


def classify(g, before, after):
    if after["level"] != 8 or after["area"] != 1:
        return []
    if not (g.read("gObjectPool[61].behavior") == g.address("bhvPyramidTop")
            and g.read("gObjectPool[61].activeFlags")):
        return []
    if math.hypot(after["position"][0]+2048,after["position"][2]+1024)>1700:
        return []
    top = top_snapshot(g)
    if top["underside"] is None:
        return []
    findings = []
    points = [("boundary", after["action"], after["position"])]
    points += [("action-entry", e["action"], e["pos"]) for e in g.frame_log()
               if e["type"] == "FLT_EXECUTE_ACTION"]
    for point, action, pos in points:
        upper = upper_floor(top["faces"],pos[0],pos[2])
        if upper is None:
            continue
        feet_inside = top["underside"] < pos[1] < upper
        body_overlap = pos[1] <= top["underside"] < pos[1]+100
        if action == CRAWL and (feet_inside or body_overlap):
            findings.append(dict(point=point, pos=pos, upper=upper,
                                 underside=top["underside"], feetInside=feet_inside,
                                 bodyOverlap=body_overlap, priorAction=before["action"],
                                 depth=upper-pos[1], after=after,
                                 top=top))
    return findings


def clean_search(g, rows, raw):
    o = Observer(g)
    seeds = {}
    for n,pad in enumerate(rows[:2548],1):
        g.advance_pad(pad)
        if n in {2390,2420,2460,2500,2520,2548}:
            seeds[n] = g.save_state()
    branches = []
    summaries = []
    findings = []
    # Freshly replay the already archived clean delivery histories and retain
    # native near-top states. No checkpoint is constructed from coordinates.
    for index, trial in enumerate(raw["trials"]):
        seed=trial["policy"]["seed"]
        g.load_state(seeds[seed])
        start=delivery_snap(g,o,0)
        assert start == trial["samples"][0]
        controls=[]
        before=observation(g,o)
        near=[]
        for n,pad in enumerate(trial["inputs"],1):
            g.advance_pad(pad)
            controls.append(dict(buttons=pad["buttons"],stick=pad["stick"]))
            after=observation(g,o)
            got=classify(g,before,after)
            for item in got:
                findings.append(dict(kind="archived-clean",trial=index,update=n,**item))
            pos=after["position"]
            if (after["area"]==1 and after["level"]==8 and pos[1]>=1200
                    and not g.read("gMarioState.area.camera").is_null()
                    and math.hypot(pos[0]+2048,pos[2]+1024)<1300):
                near.append((n,after))
                if n%8==0 and len(branches)<32:
                    branches.append(dict(trial=index,seed=seed,controls=controls.copy(),
                        state=g.save_state(),start=after))
            before=after
        assert delivery_snap(g,o,len(trial["inputs"])) == trial["samples"][-1]
        summaries.append(dict(trial=index,policy=trial["policy"],updates=len(controls),
                              nearTop=len(near),
                              spinningNearTop=sum(r["topAction"]==1 for _,r in near)))
    trials=[]
    best=[]
    # Z braking, Z steering and a delayed Z start at controller-reached
    # approaches. The intent is crawl entry and sustained contact with the cap.
    targets=[None,(-2048,-1024),(-1950,-939),(-2559,-1535),(-2500,-600)]
    for branch_index,branch in enumerate(branches):
        for delay in (0,8,24):
            for target in targets:
                g.load_state(branch["state"])
                before=observation(g,o)
                sequence=[]
                samples=[]
                hits=[]
                for k in range(160):
                    if g.read("gMarioState.area.camera").is_null():
                        break
                    buttons=0x2000 if k>=delay else 0
                    if target is None:
                        pad=dict(buttons=buttons,stick=[0,0])
                    else:
                        pad=steer(g,target,buttons)
                        pad["stick"]=[round(v*64/127) for v in pad["stick"]]
                    g.advance_pad(pad)
                    sequence.append(pad)
                    after=observation(g,o)
                    samples.append(after)
                    hits.extend(classify(g,before,after))
                    before=after
                    if after["area"]!=1 or after["level"]!=8:
                        break
                crawls=[s for s in samples if s["action"]==CRAWL]
                row=dict(branch=branch_index,delay=delay,target=target,updates=len(sequence),
                         crawlFrames=len(crawls),spinningCrawlFrames=sum(
                         s["topAction"]==1 for s in crawls),
                         maxCrawlY=max((s["position"][1] for s in crawls),default=None),
                         feetInside=sum(h["feetInside"] for h in hits),
                         spinningFeetInside=sum(h["feetInside"] and h["after"]["topAction"]==1 for h in hits))
                trials.append(row)
                if crawls and len(best)<6:
                    best.append(dict(summary=row,seed=branch["seed"],
                        prefix=branch["controls"],inputs=sequence,samples=samples,
                        initial=branch["start"],hits=hits))
                for item in hits:
                    if len(findings)<100:
                        findings.append(dict(kind="new-clean",branch=branch_index,
                                             delay=delay,target=target,**item))
        print(json.dumps(dict(progress="branch",completed=branch_index+1,
                              total=len(branches),trials=len(trials))),flush=True)
    # Validate selected complete histories from a fresh game, including their
    # accepted prefix. Comparisons cover every recorded continuation boundary.
    replays=[]
    for selected in best:
        fresh=InputOnly()
        fo=Observer(fresh)
        for pad in rows[:selected["seed"]]+selected["prefix"]:
            fresh.advance_pad(pad)
        assert observation(fresh,fo)==selected["initial"]
        for pad,expected in zip(selected["inputs"],selected["samples"]):
            fresh.advance_pad(pad)
            assert observation(fresh,fo)==expected
        replays.append(dict(seed=selected["seed"],compared=len(selected["samples"])+1,
                            inputCount=selected["seed"]+len(selected["prefix"])+len(selected["inputs"]),
                            writeCounts=dict(fresh.write_counts),passed=True))
    return dict(archived=summaries, branchCount=len(branches),
                branches=[{k:v for k,v in b.items() if k!="state"} for b in branches],
                trials=trials,findings=findings,selected=best,freshReplays=replays)


def four_pillar_approaches(g, rows):
    o=Observer(g)
    for pad in rows[:2548]:
        g.advance_pad(pad)
    assert g.read("gObjectPool[61].oPyramidTopPillarsTouched")==4
    initial=observation(g,o)
    state=g.save_state()
    policies=[]
    for dive in range(0,25,2):
        for offset in (-160,-80,0,80,160):
            for target in ((-2048,-1024),(-2559,-1535),(-2500,-600)):
                policies.append(dict(dive=dive,boxAimOffset=offset,target=target))
    summaries=[]
    candidates=[]
    for index,policy in enumerate(policies):
        g.load_state(state)
        controls=[]
        samples=[]
        findings=[]
        pickup=None
        near=[]
        previous=initial
        for k in range(165):
            if g.read("gMarioState.area.camera").is_null():
                break
            pos=g.read("gMarioState.pos")
            held=o.slot(g.read("gMarioState.heldObj"))
            if held==49 and pickup is None:
                pickup=k
            aiming=(policy["target"] if pickup is not None else
                    (-5200+policy["boxAimOffset"],1700))
            buttons=0
            if pickup is None:
                close=math.hypot(pos[0]+5200,pos[2]-1700)<220
                if k==policy["dive"] or (close and k%6==0):
                    buttons=0x4000
            else:
                # Once the automatic bounce ends, try to settle into crawl.
                if held!=49:
                    buttons=0x2000
            pad=steer(g,aiming,buttons)
            g.advance_pad(pad)
            controls.append(pad)
            after=observation(g,o)
            after["held"]=o.slot(g.read("gMarioState.heldObj"))
            samples.append(after)
            if after["area"]!=1 or after["level"]!=8:
                break
            assert after["pillars"]==4
            if after["topAction"]!=1 and after["topTimer"]<10 and k>10:
                break
            hits=classify(g,previous,after)
            findings.extend(hits)
            if math.hypot(after["position"][0]+2048,after["position"][2]+1024)<1400:
                near.append(after)
            previous=after
        crawl=[s for s in samples if s["action"]==CRAWL]
        live=[s for s in samples if s["topAction"]==1]
        closest=min(live,key=lambda s:math.hypot(s["position"][0]+2048,s["position"][2]+1024),default=None)
        row=dict(index=index,policy=policy,updates=len(controls),pickupAfterUpdates=pickup,
                 minPyramidDistance=None if closest is None else math.hypot(closest["position"][0]+2048,closest["position"][2]+1024),
                 closest=closest,crawlFrames=len(crawl),
                 maxCrawlY=max((s["position"][1] for s in crawl),default=None),
                 nearTopFrames=len(near),
                 nearTopMaxY=max((s["position"][1] for s in near),default=None),
                 feetInside=sum(h["feetInside"] for h in findings))
        summaries.append(row)
        candidates.append(dict(summary=row,inputs=controls,samples=samples,findings=findings))
    selected=[]
    ranking=[lambda t:t["summary"]["pickupAfterUpdates"] if t["summary"]["pickupAfterUpdates"] is not None else 9999,
             lambda t:t["summary"]["minPyramidDistance"] if t["summary"]["minPyramidDistance"] is not None else 99999,
             lambda t:-(t["summary"]["nearTopMaxY"] or -99999),
             lambda t:-(t["summary"]["maxCrawlY"] or -99999)]
    for key in ranking:
        trial=min(candidates,key=key)
        if trial["summary"]["index"] not in [t["summary"]["index"] for t in selected]:
            selected.append(trial)
    replays=[]
    for trial in selected:
        fresh=InputOnly()
        fo=Observer(fresh)
        for pad in rows[:2548]:
            fresh.advance_pad(pad)
        assert observation(fresh,fo)==initial
        for pad,expected in zip(trial["inputs"],trial["samples"]):
            fresh.advance_pad(pad)
            actual=observation(fresh,fo)
            actual["held"]=fo.slot(fresh.read("gMarioState.heldObj"))
            assert actual==expected
        replays.append(dict(trial=trial["summary"]["index"],compared=len(trial["samples"])+1,
                            passed=True,writeCounts=dict(fresh.write_counts)))
    return dict(scope="Four pillars already credited in every search seed; original western box can provide approach height, with no requirement to preserve it",
                initial=initial,trials=summaries,selected=selected,freshReplays=replays)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output",type=Path)
    parser.add_argument("--mode",choices=["geometry","clean","four-pillar"],required=True)
    args=parser.parse_args()
    if args.output.exists():
        raise FileExistsError(args.output)
    capture=ROOT/"build/wafel-pilot/capture.bKv95w/inputs.jsonl"
    rows=load_capture(capture)
    game=InputOnly()
    start=time.monotonic()
    if args.mode=="geometry":
        result=geometry_study(game,rows)
    elif args.mode=="clean":
        raw=json.loads((ROOT/"build/wafel-pilot/ink-box-delivery-20261111-final.json").read_text())
        result=clean_search(game,rows,raw)
    else:
        result=four_pillar_approaches(game,rows)
    report=dict(schema=1,mode=args.mode,
                preEntrySetup="Accepted create_game gDebugLevelSelect=1 before gameplay",
                gameplaySetupWrites=[],aInputs=0,
                scriptSha256=sha(__file__),runtimeSha256=sha(ROOT/"build/wafel-pilot/sm64_jp.dll"),
                captureSha256=sha(capture),writeCounts=dict(game.write_counts),
                updates=game.updates,elapsedSeconds=time.monotonic()-start,result=result)
    args.output.write_text(json.dumps(report,indent=2,allow_nan=False)+"\n")
    print(json.dumps(dict(saved=str(args.output),updates=game.updates,
                          seconds=report["elapsedSeconds"])),flush=True)


if __name__=="__main__":
    main()

