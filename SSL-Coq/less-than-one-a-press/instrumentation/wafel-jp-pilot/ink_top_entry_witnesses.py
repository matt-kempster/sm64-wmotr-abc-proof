"""Retain native meshes and fresh replays for direct top-entry witnesses.

The supplied setup is explicit. There are no post-setup gameplay writes.
Computed penetration labels are separate from native positions and action logs.
"""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))

from ink_crawl_edge_entry import (ROOT, TrialGame, Observer, load_capture,
    make_contexts, recipes, seed_pose, snapshot, advance_record, controller,
    NEUTRAL, top_snapshot, sha, is_supported_crawl)


def rich_state(g,o):
    top=top_snapshot(g)
    return dict(native=snapshot(g,o,top),topMesh=top,
                collision=[g.read("gMarioObject.oPos"+a) for a in "XYZ"])


def rich_advance(g,o,pad):
    before=rich_state(g,o)
    record=advance_record(g,o,pad)
    return dict(before=before,input=pad,after=rich_state(g,o),
                actionEntries=record["entries"],
                executedTopTimer=before["native"]["topTimer"])


def setup_fresh(recipe):
    g=TrialGame()
    o=Observer(g)
    rows=load_capture(ROOT/"build/wafel-pilot/capture.bKv95w/inputs.jsonl")
    for pad in rows[:2548]:
        g.advance_pad(pad)
    while not (g.read("gObjectPool[61].oAction")==1 and
               g.read("gObjectPool[61].oTimer")==recipe["phase"]):
        g.advance_pad(NEUTRAL)
    edits=seed_pose(g,recipe)
    return g,o,edits


def trace(recipe,pads,prime_pad=None):
    g,o,edits=setup_fresh(recipe)
    initial=rich_state(g,o)
    assert not initial["native"]["geometry"]["inside"]
    prime=rich_advance(g,o,prime_pad) if prime_pad is not None else None
    if prime is not None:
        assert is_supported_crawl(prime["after"]["native"])
    rows=[]
    for pad in pads:
        rows.append(rich_advance(g,o,pad))
    return dict(recipe=recipe,suppliedEdits=edits,initial=initial,prime=prime,updates=rows)


def run(output,edge_batch):
    capture=ROOT/"build/wafel-pilot/capture.bKv95w/inputs.jsonl"
    g=TrialGame()
    o,states,contexts=make_contexts(g,load_capture(capture))
    direct=[]
    best=None
    tested=0
    for phase in [108,120,128,129,130,140]:
        for recipe in recipes(contexts[phase],phase,"air"):
            g.load_state(states[phase])
            seed_pose(g,recipe)
            assert not snapshot(g,o)["geometry"]["inside"]
            pad=controller(g,recipe["yaw"],0)
            result=advance_record(g,o,pad)
            tested+=1
            entries=[e for e in result["entries"] if e["geometry"] and e["geometry"]["deep"]]
            geom=result["state"]["geometry"]
            if entries and geom and geom["deep"]:
                row=dict(recipe=recipe,input=pad,result=result)
                direct.append(row)
                pos=result["state"]["position"]
                # Prefer the recorded handoff's phase and nearby altitude.
                score=abs(phase-130)*1000+abs(pos[1]-1741)+0.1*(abs(pos[0]+1950)+abs(pos[2]+939))
                if best is None or score<best[0]:
                    best=(score,row)
    print(json.dumps(dict(oneUpdateStarts=tested,directDeepEntries=len(direct))),flush=True)
    witnesses={}
    crawl=json.loads(edge_batch.read_text())
    for category in ["lostWhileCrawling","endDeepOtherAction"]:
        w=crawl["selected"][category]
        witnesses["edge_"+category]=trace(w["recipe"],w["inputs"],w["primeInput"])
    if best:
        selected=best[1]
        for pattern in ["keep-falling","press-Z","steer-inward-Z"]:
            recipe=selected["recipe"]
            g,o,edits=setup_fresh(recipe)
            pads=[selected["input"]]
            g.advance_pad(pads[0])
            for k in range(23):
                if not g.read("gObjectPool[61].activeFlags"):
                    break
                yaw=recipe["yaw"]
                if pattern=="steer-inward-Z":
                    import math
                    p=g.read("gMarioState.pos")
                    yaw=round(math.atan2(g.read("gObjectPool[61].oPosX")-p[0],
                        g.read("gObjectPool[61].oPosZ")-p[2])*65536/math.tau)&0xffff
                pad=controller(g,yaw,0 if pattern=="keep-falling" else 0x2000)
                pads.append(pad)
                g.advance_pad(pad)
            witnesses["direct_face_"+pattern]=trace(recipe,pads)
    validations={}
    for name,w in witnesses.items():
        again=trace(w["recipe"],[r["input"] for r in w["updates"]],
                    w["prime"]["input"] if w["prime"] else None)
        assert again==w,name
        validations[name]=dict(passed=True,comparedUpdates=len(w["updates"])+bool(w["prime"]))
    report=dict(schema=1,scope="Supplied exterior starts; local native events, not a reached route",
        oneUpdateStarts=tested,directDeepEntryCount=len(direct),
        directDeepEntries=direct,witnesses=witnesses,validations=validations,
        actionNames=g.mario_action_names(),aInputs=0,
        postSetupWrites="controller fields only; complete native states restored between trials",
        captureSha256=sha(capture),runtimeSha256=sha(ROOT/"build/wafel-pilot/sm64_jp.dll"),
        scriptSha256=sha(__file__),edgeBatchSha256=sha(edge_batch),
        dependencies={n:sha(Path(__file__).with_name(n)) for n in
          ["ink_crawl_edge_entry.py","ink_crawl_top_entry.py","replay.py","ink_crawl_predecessors.py"]})
    with output.open("x",encoding="utf-8") as f:
        json.dump(report,f,indent=2,allow_nan=False)
        f.write("\n")
    print(json.dumps(dict(saved=str(output),validations=validations)),flush=True)


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output",type=Path)
    parser.add_argument("--edge-batch",type=Path,
                        default=ROOT/"build/wafel-pilot/ink-crawl-edge-full.json")
    args=parser.parse_args()
    run(args.output,args.edge_batch)
