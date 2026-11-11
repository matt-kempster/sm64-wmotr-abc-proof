"""Fresh detailed controls for the fixed airborne-entry crawl investigation."""
import argparse
import json
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_air_entry_to_crawl import (ROOT,root_state,advance,policy_pad,state,
                                  assess,CRAWL,AIR,Z,sha)


def run(output):
    full_path=ROOT/"build/wafel-pilot/ink-air-to-crawl-final.json"
    full=json.loads(full_path.read_text(encoding="utf-8"))
    witnesses={}
    for name in ["first","longestInterior"]:
        g,o,_,setup=root_state()
        rows=[]
        for expected in full["selected"][name]["records"]:
            got=advance(g,o,expected["input"])
            assert got==expected
            rows.append(got)
        witnesses[name]=dict(records=rows,source="Selected full-policy witness")
    g,o,_,setup=root_state()
    rows=[]
    recipe=dict(mode="b-z",delay=0,direction=0,magnitude=16,brakeGroundFrames=0)
    for k in range(21):
        rows.append(advance(g,o,policy_pad(g,recipe,k,0)))
    witnesses["immediateDive"]=dict(records=rows,recipe=recipe)
    g,o,_,setup=root_state()
    rows=[]
    # A positive action-detection control: let the same Mario fall out and
    # land naturally, settle to idle, crouch, and then move with Z held.
    idle=g.constant("ACT_IDLE")
    crouch=g.constant("ACT_CROUCHING")
    stage="settle"
    for k in range(70):
        s=state(g,o)
        if stage=="settle" and s["action"]==idle:stage="crouch"
        if stage=="crouch" and s["action"]==crouch:stage="crawl"
        pad=dict(buttons=0 if stage=="settle" else Z,
                 stick=[0,32] if stage=="crawl" else [0,0])
        rows.append(advance(g,o,pad))
        if (rows[-1]["state"]["action"]==CRAWL and
                any(e["action"]==CRAWL for e in rows[-1]["entries"])):break
    witnesses["roofCrawlControl"]=dict(records=rows,stageReached=stage)
    validations={}
    for name,w in witnesses.items():
        g,o,_,again_setup=root_state()
        assert again_setup==setup
        for expected in w["records"]:assert advance(g,o,expected["input"])==expected
        validations[name]=dict(passed=True,comparedFrames=len(w["records"])+1)
    report=dict(schema=1,scope="Same supplied airborne entry, controller inputs only thereafter",
        setup=setup,witnesses=witnesses,validations=validations,actionNames=g.mario_action_names(),
        scriptSha256=sha(__file__),fullPolicyReceiptSha256=sha(full_path),
        dependencies={n:sha(Path(__file__).with_name(n)) for n in
          ["ink_air_entry_to_crawl.py","ink_crawl_edge_entry.py","ink_top_entry_witnesses.py"]})
    with output.open("x",encoding="utf-8") as f:
        json.dump(report,f,indent=2);f.write("\n")
    print(json.dumps(dict(saved=str(output),validations=validations,
        roofControlFinal=witnesses["roofCrawlControl"]["records"][-1]["state"])),flush=True)


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("output",type=Path)
    run(p.parse_args().output)
