"""Read-only consistency audit for the bounded 973-unit producer experiments.

Run after reproducing the named raw reports in build/wafel-pilot. This checks
Python syntax, provenance hashes, retained result data, no-A bits and patch
ledgers. It does not initialize Wafel, advance gameplay or redo a fresh replay.
Paths are resolved from this script, so the caller need not change directory.
"""
import ast, hashlib, json
from pathlib import Path


def main():
    root=Path(__file__).resolve().parents[2]
    P=root/'instrumentation/wafel-jp-pilot';B=root/'build/wafel-pilot';N=root/'docs/notes'
    read=lambda p:json.loads(p.read_text())
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    cp=read(N/'ink-crawl-predecessors-receipt.json');sh=read(N/'ink-shell-producer-receipt.json');cl=read(N/'ink-clean-approach-receipt.json');ap=read(N/'ink-alternate-push-receipt.json')
    cr=read(B/'ink-crawl-predecessors-20261111-expanded.json');br=read(B/'ink-crawl-continuation-beam-20261111.json');sr=read(B/'ink-shell-producer-20261111.json');lr=read(B/'ink-clean-approach-20261111.json');ar=read(B/'ink-alternate-push-minimal-20261111.json')
    for name,r in [('ink_crawl_predecessors.py',cp),('ink_crawl_continuation_beam.py',br),('ink_shell_producer.py',sh),('ink_clean_approach_search.py',cl),('ink_alternate_push.py',ap)]:
     ast.parse((P/name).read_text());assert sha(P/name)==r['scriptSha256']
    for r,name in [(cp,'ink-crawl-predecessors-20261111-expanded.json'),(sh,'ink-shell-producer-20261111.json'),(cl,'ink-clean-approach-20261111.json')]:assert r['rawReportSha256']==sha(B/name)
    assert cp['continuationBeamRawSha256']==sha(B/'ink-crawl-continuation-beam-20261111.json')
    for r in [cp,sh,cl,ap,cr,br,sr,lr,ar]:
     assert r['runtimeSha256']==sha(B/'sm64_jp.dll') and r['baselineSha256']==sha(B/'capture.bKv95w/inputs.jsonl')
    assert cp['continuationBeam']==br and ap==ar
    assert br['sourceReceiptSha256']==cp['rawReportSha256'] and br['predecessorScriptSha256']==cp['scriptSha256']
    print('PASS source syntax, five script hashes, raw hashes, DLL/capture hashes, beam/raw and alternate/raw equality')
    for key in ['schema','scope','baselineSha256','runtimeSha256','scriptSha256','contexts','staticInventory','entryControls','inverseProposal','inverseTopTrials','bestRoofWitnesses','summary']:assert cp[key]==cr[key]
    keys=['phase','seed','target','crawlUpdates','topCrawlUpdates','maxCrawlY','reachedHighCrawl','updates']
    assert cp['roofSweep']['rows']==[[r[k] for k in keys]+[r['actionCounts'],r['final']['movement'],r['final']['action'],r['final']['topTimer'],r['final']['floorOwner']] for r in cr['roofTrials']]
    assert (len(cr['entryControls']),len(cr['inverseTopTrials']),len(cr['roofTrials']))==(12,32,936)
    assert sum(r['updates'] for r in cr['roofTrials'])==cp['roofSweep']['totalUpdates']==64344
    assert (sum(r['crawlUpdates']>0 for r in cr['roofTrials']),sum(r['topCrawlUpdates']>0 for r in cr['roofTrials']),sum(r['reachedHighCrawl'] for r in cr['roofTrials']))==(130,10,0)
    roof=cr['bestRoofWitnesses'][0];v=roof['freshBootValidation']
    assert v['passed'] and v['intermediateEdits']==0 and roof['edits']==v['initialEdits']
    assert len(roof['controls'])==v['continuousUpdates']==84 and len(roof['checkpoints'])==v['comparedCheckpoints']==41
    assert len(br['depthResults'])==52 and br['width']==16 and br['horizon']==52
    assert sum(r['testedThisDepth'] for r in br['depthResults'])==br['summary']['testedContinuations']==13889
    assert br['summary']['reachedHighCrawlCandidates']==0 and br['summary']['stoppingReason']=='horizon'
    assert all(x['topSupportedCandidates']==0 for x in br['depthResults'] if x['storedTopTimer']>=82)
    for t in br['trails']:
     v=t['freshBootValidation'];assert v['passed'] and v['intermediateEdits']==0 and v['initialEdits']==br['initialEdits']
     assert len(t['controls'])==v['continuousUpdates']==83
     assert len(t['snapshots'])==len(t['branchControls'])==v['comparedBranchCheckpoints']==52
     assert t['controls']==br['prefixControls']+t['branchControls']
     assert max([br['start']['movement'][1]]+[s['movement'][1] for s in t['snapshots']])==t['peakY']==br['summary']['maximumCrawlY']
    print('PASS crawl compact rows/counts, beam depth counts, and fresh-replay record consistency')
    src=P/'ink_shell_producer.py';tree=ast.parse(src.read_text());ns=dict(hashlib=hashlib,json=json,Path=Path,__file__=str(src))
    functions=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in ['digest','compact']]
    exec(compile(ast.Module(body=functions,type_ignores=[]),str(src),'exec'),ns)
    assert ns['compact'](sr,B/'ink-shell-producer-20261111.json')==sh
    assert [x['capturesTop'] for x in sr['ablations']]==[True,True,False]
    assert len(sr['coasts'])==2 and all(len(x['samples'])==120 for x in sr['coasts'])
    release=sr['suppliedApproachRelease'];assert release['shellReleasedAfterUpdates']==31 and len(release['samples'])==100
    assert next(i+1 for i,x in enumerate(release['samples']) if x['shell'] is not None)==31
    screen=sr['cleanApproachScreen'];assert len(screen['trials'])==8 and screen['testedUpdates']==sum(len(x['inputs']) for x in screen['trials'])==4800
    assert all(x['boxAction']==2 and not x['activeShells'] for x in screen['trials'])
    mount=sr['mountThenZ']['samples'];assert len(mount)==12 and any(x['ridden']==126 for x in mount) and not mount[-1]['shell']['isShell']
    assert len(lr['trials'])==len(cl['trials'])==90 and lr['freshBootBestPhase130Matches'] is True
    for a,b in zip(lr['trials'],cl['trials']):assert {k:v for k,v in a.items() if k!='inputs'}==b
    for k,v in lr.items():
     if k!='trials':assert cl[k]==v
    assert next(t for t in lr['trials'] if t['policy']==lr['bestPolicy'])['inputs']==cl['bestInputs']
    assert all(not t['marioPrerequisite'] and t['topSupportedSamples']==0 for t in lr['trials'])
    assert len(ar['trials'])==5
    for t in ar['trials']:
     success=not t['name'].endswith('xz-only');assert [t[k] for k in ['handoff','topCapture','outsideElevator']]==[success]*3
     if success:
      assert t['after']['movement']==t['after']['collision']==[-1882.,768.,-939.] and t['after']['display']==[-1882.,1741.,-939.]
      assert t['nextUpdate']['floorOwner']==t['nextUpdate']['platform']==61 and t['nextUpdate']['used']==64
      assert t['arrival']['area']==2 and t['arrival']['movement']==[365.5927734375,5500.,-1096.8026123046875]
    print('PASS shell compact reconstruction and component counts; 90 clean-policy records; five alternate-actor outcomes')
    counts=[0,0]
    def scan(x):
     if isinstance(x,dict):
      if isinstance(x.get('buttons'),int):assert not x['buttons']&0x8000;counts[0]+=1
      if isinstance(x.get('input'),int):assert not x['input']&0x82;counts[1]+=1
      for y in x.values():scan(y)
     elif isinstance(x,list):
      for y in x:scan(y)
    for r in [cr,br,sr,lr,ar]:scan(r)
    prefix=[json.loads(line) for line in (B/'capture.bKv95w/inputs.jsonl').read_text().splitlines() if line.strip()]
    assert all(not row['buttons']&0x8000 for row in prefix[:2548])
    position={'gMarioState.pos','gMarioObject.oPosX','gMarioObject.oPosY','gMarioObject.oPosZ','gMarioObject.header.gfx.pos'}
    mario=position|{'gMarioState.action','gMarioState.actionState','gMarioState.actionTimer','gMarioState.forwardVel','gMarioState.vel','gMarioState.faceAngle'}
    paths=lambda e:{x['path'] for x in e}
    assert paths(roof['edits'])==position and paths(br['initialEdits'])==position
    assert all(paths(t['edits'])<=mario for t in cr['entryControls'])
    assert all(paths(t['edits'])<=mario|{'gMarioPlatform'} for t in cr['inverseTopTrials'])
    assert paths(sr['fixturePrefixEdits'])=={'gObjectPool[32].oAction'}
    for t in sr['ablations']:
     allowed=mario|{'gObjectPool[126].oPos'+a for a in 'XYZ'}
     if t['mode']=='old-zero-velocities':allowed|={'gObjectPool[126].'+x for x in ['oForwardVel','oVelX','oVelY','oVelZ']}
     assert paths(t['edits'])<=allowed
    assert paths(release['edits'])<=mario and paths(sr['mountThenZ']['edits'])<=mario and screen['nonControllerEdits']==[]
    for t in ar['trials']:
     assert paths(t['edits'])<=mario|{'gObjectPool[%d].oPos%s'%(t['slot'],a) for a in 'XYZ'}
     if 'minimal-mario' in t['name']:assert paths(t['edits'])==position|{'gMarioState.action'}|{'gObjectPool[%d].oPos%s'%(t['slot'],a) for a in 'XYZ'}
    assert lr['suppliedGameplayWrites']==[] and lr['prefixAFrames']==0
    tree=ast.parse((P/'ink_clean_approach_search.py').read_text())
    assert not any(isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute) and n.func.attr=='write' and isinstance(n.func.value,ast.Name) and n.func.value.id in ['g','fresh'] for n in ast.walk(tree))
    print('PASS no-A:',counts[0],'retained button records;',counts[1],'sampled Mario-input fields; 2548-row baseline prefix')
    print('PASS documented patch scopes; clean approach has no gameplay write call; roof/beam witnesses contain only initial synchronized-position writes')
    print('LIMIT: read-only audit, no native rerun. Fresh-replay assertions match recorded results and source, but shell/alternate trials have no independent fresh-boot replay claim. Shell raw omits scriptSha256; its compact receipt records the current matching source hash.')


if __name__ == "__main__":
    main()
