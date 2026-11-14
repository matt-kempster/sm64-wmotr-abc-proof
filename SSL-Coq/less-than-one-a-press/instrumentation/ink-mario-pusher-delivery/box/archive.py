"""Archive the controller-produced Crazy Box predecessor study."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];DECOMP=ROOT.parents[2]/'reference-sm64-decomp'
def rec(p,label):return dict(path=label,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 files=['.gitattributes','check.py','archive.py','README.md','results.json.gz']
 inputs=['docs/notes/ink-box-delivery-receipt.json','instrumentation/ink-high-item-nudge/prefix.jsonl.gz','instrumentation/wafel-jp-pilot/ink_box_delivery.py','instrumentation/wafel-jp-pilot/replay.py']
 source=['src/game/behaviors/jumping_box.inc.c','src/game/mario_actions_airborne.c','src/game/mario_actions_moving.c','src/game/mario_actions_stationary.c','src/game/interaction.c']
 out=dict(schema=1,files=[rec(HERE/n,n)for n in files],inputs=[rec(ROOT/n,n)for n in inputs],source=[rec(DECOMP/n,n)for n in source]);data=(json.dumps(out,indent=2)+'\n').encode();p=HERE/'verification.json'
 if a.verify:assert p.read_bytes()==data
 else:p.write_bytes(data)
 print('PASS archive',len(files),'local files,',len(inputs),'inputs,',len(source),'source files')
if __name__=='__main__':main()
