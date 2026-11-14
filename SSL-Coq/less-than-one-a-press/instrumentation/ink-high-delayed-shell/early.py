"""One matched phase97 mount control: native recovery while the top is live."""
import argparse,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,roots,trial,digest
def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    g,o,s,slot,prep=roots(a.capture,(97,));r=dict(phase=97,height=25000,mode='late-z-pulse',boxPhase=130);t=trial(g,o,s,slot,r,True)
    q,qo,qs,qslot,qprep=roots(a.capture,(97,));assert qprep==prep;assert t==trial(q,qo,qs,qslot,r,True)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),helperSha256=digest(ROOT/'instrumentation/ink-high-delayed-shell/search.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),shellPreparation=prep,trial=t,freshBoundaries=len(t['samples']))
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',r,'highSlide',len(t['highSlideExecutions']),'capture',t['capture'],'useful',t['useful'],'fresh',result['freshBoundaries']);print('CHANGES',t['actionChanges'])
    for i in range(30,35):
        s=t['samples'][i];print(i+1,{k:s[k] for k in ['movement','display','actionName','floorY','floorOwner','platform','topTimer','topActive']})
if __name__=='__main__':main()
