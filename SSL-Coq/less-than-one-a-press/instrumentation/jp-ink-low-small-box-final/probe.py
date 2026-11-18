"""Build the existing JP remote-shell/release probe and observe the stock small box."""
import argparse
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile


here = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("recipe", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
case = json.loads(args.recipe.read_bytes())
swapped = case["name"] == "swapped-bobs"
with tempfile.TemporaryDirectory() as tmp:
    recipe_path = args.recipe
    if swapped:
        assert [cut["phase"] for cut in case["cuts"]] == [128, 130]
        last = case["cuts"][1]["edits"]
        assert [e["path"] for e in last] == [f"gObjectPool[39].oPos{a}" for a in "XYZ"]
        recipe_path = Path(tmp) / "first-cut.json"
        recipe_path.write_text(json.dumps({**case, "cuts": case["cuts"][:1]}))
    subprocess.run([sys.executable, str(here.parent / "jp-ink-shell-three-releases/generate.py"),
                    str(recipe_path), str(args.output)], check=True)
source = args.output.read_text()
if swapped:
    # Exactly the three disclosed writes to the ordinary Bob, before update 130.
    marker = " if(sc_bridge>=0&&(unsigned)sc_bridge<sizeof(case_pads)"
    assert source.count(marker) == 1
    lines = []
    for i, edit in enumerate(last):
        bits = struct.unpack(">I", struct.pack(">f", edit["after"]))[0]
        address = 0x8033c118 + 39 * 0x260 + 0xa0 + 4*i
        lines.append(f'  sw32(0x{address:08x}u,0x{bits:08x}u,{json.dumps(edit["path"])});')
    source = source.replace(marker, " if(sc_bridge==4){\n" + "\n".join(lines) + "\n }\n" + marker)
    original = "SC_PUSH=A_OBJECT_POOL+39*OBJECT_SIZE"
    assert source.count(original) == 1
    source = source.replace(original, original.replace("39*", "40*"))
box_observer = "static void pp_box(void){uint32_t b=A_OBJECT_POOL+49*OBJECT_SIZE;"
assert source.count(box_observer) == 1
# The observer already logs the complete ordinary actor hitbox, status, and movement.
source = source.replace(box_observer, box_observer.replace("49*", "39*" if swapped else "23*"))
source = source.replace("PP_BOX,bridge", "SB_BOX,bridge")
# The JP function with the floor call returning to 0x8024d550 saves the
# actor argument at sp+0x44. Its epilogue runs after both accepted X/Z stores.
old = "if(pc==FD_QUERY){fd_query_caller="
observer = r'''if(pc==0x8024d3d8u || pc==0x8024d57cu){
  if(fd_live() && r){
   uint32_t actor=pc==0x8024d3d8u ? (uint32_t)r[5] : R32(sp+0x44);
   fprintf(stderr,"SB_SHOVE,bridge=%d,pc=%08x,actor=%08x,behavior=%08x,type=%u,radius=%.9g,actorXYZ=(%.9g,%.9g,%.9g),M=(%.9g,%.9g,%.9g)\n",
     sc_bridge,pc,actor,R32(actor+0x20c),R32(actor+0x130),rfloat(actor+0x1f8),
     rfloat(actor+O_POS_X),rfloat(actor+O_POS_Y),rfloat(actor+O_POS_Z),
     rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z));
  }
 }else '''
assert source.count(old) == 1
source = source.replace(old, observer + old)
old = "pcs[]={SC_CAMERA,"
assert source.count(old) == 1
source = source.replace(old, "pcs[]={0x8024d3d8u,0x8024d57cu,SC_CAMERA,")
args.output.write_bytes(source.encode())
