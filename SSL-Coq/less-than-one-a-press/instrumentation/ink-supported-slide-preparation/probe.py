"""Inspect selected adaptive preparations without repeating the search."""
import ast,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import roots,run_one
capture=Path(sys.argv[1]);g,o,states,meshes=roots(capture)
selected=[ast.literal_eval(line[5:]) for line in Path(sys.argv[2]).read_text().splitlines() if line.startswith('BEST ')][-4:]
trials=[]
for b in selected:
    t=run_one(g,o,states[b['recipe']['phase']],b['recipe'],b['box'],True);trials.append(t)
    print('RECIPE',b)
    for s,e in zip(t['samples'][:4],t['events'][:4]):
        print(json.dumps(s))
        print('ACTIONS',json.dumps([i for i in e if i['type'] in ['FLT_EXECUTE_ACTION','FLT_BEGIN_MOVEMENT_STEP']]))
Path(sys.argv[3]).write_text(json.dumps(trials,indent=2)+'\n')
