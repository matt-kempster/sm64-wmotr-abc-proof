"""Search predecessors of the selected Ink installation checkpoints.

Run from any directory. Generates a JSON receipt, SMT queries and a DOT graph.
There are no emulator/Wafel state writes or controller trials in this search.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from clight import ROOT, Term, outer_items, seq, walk
from engine import Engine, Scope, Path as Branch, MEM, STATE, OBJECT, FLOOR, TOP, word, float_bits, finite, read, load_float, z

HEIGHT = 1156733869
LOWER, UPPER = HEIGHT - 32768 + 1, HEIGHT + 32768 - 1


def bits(value): return struct.unpack('>I',struct.pack('>f',value))[0]
def number(value): return struct.unpack('>f',struct.pack('>I',value))[0]
def band(value): return z.And(z.UGE(value,word(LOWER)),z.ULE(value,word(UPPER)))
def conjunction(paths): return z.Or(*[p.condition for p in paths])


def checked(engine, formula, entry, expected, label, output):
    result,model,reason=engine.solve(formula,entry)
    solver=z.Solver();solver.add(formula,*entry)
    (output/(label+'.smt2')).write_text(solver.to_smt2(),encoding='utf-8')
    if result != expected:
        raise RuntimeError(label+': expected '+expected+', got '+result+' '+str(reason))
    return dict(result=result,meaning='No solution in this extracted storage/arithmetic model.' if result=='unsat'
                else 'Consistent local constraints; this is not a controller-reachable state.')


def describe(engine,scope,paths,output,label,required_call=None):
    result=[]
    for i,p in enumerate(paths):
        if required_call and not any(required_call in c for c in p.calls):
            verdict='outside-selected-call-branch';reason='This path does not execute the selected retry call.'
        else:
            answer,_,reason=engine.solve(p.condition,engine.entry(scope))
            verdict={'sat':'unresolved-call-obligations' if p.calls else 'consistent-local-predecessor',
                     'unsat':'contradiction-in-extracted-slice','unknown':'unknown'}[answer]
        result.append(dict(branch=i,status=verdict,decisions=list(p.decisions),
                           unexpandedCalls=[engine.calls[c] for c in p.calls],reason=reason))
    return dict(branches=result,scope='Actual generated body or named cut, ordinary separated storage; interpreter is not formally verified.')


def source_calls(fn):
    return [dict(function=n.args[1].args[0].tag.removeprefix('_'),path=list(path))
            for path,n in walk(fn.body) if n.tag=='Scall' and n.args[1].tag=='Evar']


def final_capture(version,output):
    e=Engine(version)
    fn=e.function('platform_displacement','update_mario_platform')
    def target(name,ident,args,after,retval,scope):
        if name!='find_floor': return z.BoolVal(True)
        # Desired callee outcome, not a contract that the live lists supply it.
        return z.And(z.fpEQ(args[0],float_bits(bits(-2200))),z.fpEQ(args[2],float_bits(bits(-1024))),
                     z.fpEQ(retval,float_bits(HEIGHT)),read(after,args[3])==word(FLOOR),
                     read(after,word(FLOOR+44))==word(TOP),
                     read(after,word(e.global_address('_gMarioObject')))==word(OBJECT))
    e.call_constraints=target
    goal=z.And(read(MEM,word(e.global_address('_gMarioPlatform')))==word(TOP),
               read(MEM,word(OBJECT+532))==word(TOP))
    scope,paths=e.start(fn,goal)
    pre=conjunction(paths);entry=e.entry(scope); y=read(MEM,word(OBJECT+164))
    tests={}
    tests['outside-band']=checked(e,z.And(pre,z.Not(band(y))),entry,'unsat',version+'-final-outside-band',output)
    # Check the entire binary32 domain, not just the two endpoints. Obtain
    # both the subtraction argument and comparison from the generated body.
    abs_call=next(n for _,n in walk(fn.body) if n.tag=='Scall' and n.args[1].args[0].tag=='_absf')
    near_test=next(n.args[0] for _,n in walk(fn.body) if n.tag=='Sifthenelse'
                   and n.args[0].tag=='Ebinop' and n.args[0].args[0].tag=='Olt')
    from clight import items
    from engine import truth
    caller=Scope(e,fn);absolute=Scope(e,e.function('object_helpers','absf'))
    predicate=truth(e.eval(near_test,caller))
    predicate=z.substitute(predicate,(caller.temps[abs_call.args[0].args[0].tag],absolute.result))
    math_paths=e.wp(absolute.function.body,[Branch(predicate)],absolute)
    formula=conjunction(e.substitute(math_paths,(absolute.temps['_x'],e.eval(items(abs_call.args[2])[0],caller))))
    all_y=z.BitVec('every_binary32_Y',32)
    formula=z.substitute(formula,(caller.temps['_marioY'],z.fpBVToFP(all_y,z.Float32())),
                         (caller.temps['_floorHeight'],float_bits(HEIGHT)))
    tests['all-binary32-distance-band']=checked(e,z.Xor(formula,band(all_y)),[],
            'unsat',version+'-distance-band-equivalence',output)
    for label,value,want in [('lower',LOWER,'sat'),('upper',UPPER,'sat'),
                             ('below',LOWER-1,'unsat'),('above',UPPER+1,'unsat'),
                             ('exact',HEIGHT,'sat'),('raw-768',bits(768),'unsat')]:
        tests[label]=checked(e,z.And(pre,y==word(value)),entry,want,version+'-final-'+label,output)
    result=describe(e,scope,paths,output,'final')
    result.update(heightBits=HEIGHT,queryXZ=[-2200,-1024],acceptedRawYBits=[LOWER,UPPER],
                  acceptedRawY=[number(LOWER),number(UPPER)],checks=tests,
                  missing='Actual find_floor execution must supply the requested top/height and returned-memory conditions; no list or call frame is granted.')
    return result,e.functions


def copy_and_snap(version,output):
    results={};functions={}
    for name,unit,target_addresses,incoming in [
        ('copy_mario_state_to_object','object_list_processor',[OBJECT+164],STATE+64),
        ('stop_and_set_height_to_floor','mario_step',[STATE+64,OBJECT+36],STATE+112)]:
        e=Engine(version);fn=e.function(unit,name)
        # Point target makes the exact overwrite relation easy to read. A second
        # query propagates the entire accepted interval, not a finite sample.
        goal=z.And(*[read(MEM,word(a))==word(HEIGHT) for a in target_addresses])
        scope,paths=e.start(fn,goal);pre=conjunction(paths);entry=e.entry(scope)
        assert not e.calls
        required=read(MEM,word(incoming))==word(HEIGHT)
        checks={'exact-equivalence':checked(e,z.Xor(pre,required),entry,'unsat',version+'-'+name+'-exact',output),
                'nonempty':checked(e,pre,entry,'sat',version+'-'+name+'-nonempty',output)}
        interval_goal=z.And(*[band(read(MEM,word(a))) for a in target_addresses])
        scope2,paths2=e.start(fn,interval_goal)
        checks['interval-equivalence']=checked(e,z.Xor(conjunction(paths2),band(read(MEM,word(incoming)))),
                e.entry(scope2),'unsat',version+'-'+name+'-interval',output)
        if name=='stop_and_set_height_to_floor':
            checks['old-low-positions-allowed']=checked(e,z.And(pre,
                read(MEM,word(STATE+64))==word(bits(768)),read(MEM,word(OBJECT+36))==word(bits(768))),
                entry,'sat',version+'-snap-old-low',output)
            checks['old-high-display-insufficient']=checked(e,z.And(pre,
                read(MEM,word(STATE+112))==word(bits(768)),read(MEM,word(OBJECT+36))==word(HEIGHT)),
                entry,'unsat',version+'-snap-low-floor',output)
        result=describe(e,scope,paths,output,name)
        result.update(checks=checks,predecessor=('Incoming State Y is in the same required band.' if incoming==STATE+64
              else 'Cached floorHeight at this call is in the required band. The old State/display Y need not be high.'),
              missing='This is a local call. Intervening calls and scheduler intervals are not silently connected or framed.')
        results[name]=result;functions.update(e.functions)
    return results,functions


def retry_arguments(version,output):
    e=Engine(version);fn=e.function('mario','update_mario_geometry_inputs')
    parts=outer_items(fn.body)
    # The same first four outer statements used by InkBackwardSource: two
    # wall calls, the first floor call/height store, then the retry choice.
    body=seq(parts[:4])
    floor_sites=[(p,n) for p,n in walk(body) if n.tag=='Scall' and n.args[1].args[0].tag=='_find_floor']
    assert len(floor_sites)==2
    # WP's branch path uses .then/.else rather than numeric child indices.
    constraints={}
    def target(name,ident,args,after,retval,scope):
        if name!='find_floor': return z.BoolVal(True)
        is_retry='.then' in ident
        if is_retry:
            constraints['retry_id']=ident
            return z.And(*[z.fpEQ(v,float_bits(b)) for v,b in zip(args[:3],[bits(-2200),HEIGHT,bits(-1024)])],
                         z.fpEQ(retval,float_bits(HEIGHT)),read(after,args[3])==word(FLOOR))
        constraints['first_id']=ident
        # This fixes the requested low query, not the outcome or pre-call
        # display. The real caller's retry guard must require a null result.
        return z.And(*[z.fpEQ(v,float_bits(b)) for v,b in zip(args[:3],[bits(-2200),bits(768),bits(-1024)])],
                     read(after,word(STATE+136))==word(OBJECT))
    e.call_constraints=target
    scope,paths=e.start(fn,read(MEM,word(STATE+112))==word(HEIGHT),body)
    selected=[p for p in paths if constraints['retry_id'] in p.calls]
    assert len(selected)==1
    pre=selected[0].condition;entry=e.entry(scope)
    after_first=z.Array('after@'+constraints['first_id'],MEM.domain(),MEM.range())
    # Earlier substitutions do not alter this explicit AFTER-first-call memory.
    checks={
      'has-local-candidate':checked(e,pre,entry,'sat',version+'-retry-candidate',output),
      'first-result-must-miss':checked(e,z.And(pre,read(after_first,word(STATE+104))!=word(0)),entry,
                                    'unsat',version+'-retry-first-nonnull',output),
      'display-at-copy-must-be-high':checked(e,z.And(pre,read(after_first,word(OBJECT+36))!=word(HEIGHT)),entry,
                                          'unsat',version+'-retry-low-display',output),
      'pre-call-low-display-remains-open':checked(e,z.And(pre,read(MEM,word(OBJECT+36))==word(bits(768))),entry,
                                                'sat',version+'-retry-pre-call-low',output)}
    result=describe(e,scope,paths,output,'retry',required_call=constraints['retry_id'])
    result.update(checks=checks,sourceCut='First four outer statements of update_mario_geometry_inputs',
       predecessor='At the copy after the first query: floor is null and displayed vector is (-2200,1938.8648681640625,-1024).',
       missing='Both wall calls and both floor calls retain independent before/after memory. The low pre-call display SAT case is an unresolved callee effect, not a discovered display writer. Later geometry and interaction calls are outside this cut.')
    return result,e.functions


def disappeared(version,output):
    e=Engine(version);fn=e.function('mario_actions_cutscene','act_disappeared')
    # The same named ordinary Mario receiver at this cut is a scope condition,
    # not a claim that the unexpanded animation or warp call preserves it.
    e.call_constraints=lambda name,ident,args,after,retval,scope: read(after,word(STATE+136))==word(OBJECT)
    scope,paths=e.start(fn,z.And(band(read(MEM,word(STATE+64))),band(read(MEM,word(OBJECT+36)))))
    result=describe(e,scope,paths,output,'disappeared')
    result['missing']='set_mario_animation and, on its reached branch, level_trigger_warp are unexpanded. The named ordinary Mario receiver is required at each returned-memory cut. Full action-call entry does not inherit the snap predecessor without the real call effects.'
    return result,e.functions


def run(version,output):
    output.mkdir(parents=True,exist_ok=True)
    capture,functions=final_capture(version,output)
    print(version+': final owner preimage checked',flush=True)
    copy,more=copy_and_snap(version,output);functions.update(more)
    print(version+': copy and floor-snap preimages checked',flush=True)
    retry,more=retry_arguments(version,output);functions.update(more)
    action,more=disappeared(version,output);functions.update(more)
    print(version+': retry and action call frontiers recorded',flush=True)
    e=Engine(version)
    schedule={}
    for unit,name in [('object_list_processor','update_objects'),('object_list_processor','bhv_mario_update'),
                      ('mario','execute_mario_action'),('interaction','interact_warp')]:
        fn=e.function(unit,name);schedule[name]=source_calls(fn)
    functions.update(e.functions)
    hashes={file:hashlib.sha256((ROOT/file).read_text(encoding='utf-8').encode()).hexdigest()
            for file in {f['file'] for f in functions.values()}}
    return dict(version=version,finalCapture=capture,localPredecessors=copy,retryArguments=retry,
                disappeared=action,actualCallInventory=schedule,generatedFunctions=functions,
                generatedUnitHashes=hashes)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',type=Path,default=ROOT/'build/rank1-backward-search/checked')
    args=p.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    report=dict(status='Bounded predecessor engine and solver checks; no new Coq theorem or clean gameplay witness.',
        direction='Target conditions first; Ssequence is processed last statement first. No earlier replay seeds or forward controller sampling.',
        storageScope='Canonical disjoint State/Object/Surface/global/local regions using generated field layouts; valid ordinary receivers. Allocation, undefined behavior, arbitrary pointer aliasing and call resolution are not a proved CompCert simulation.',
        inputs='The closed copy/snap/final-check slices do not read controller buttons. Their predecessors do not choose B versus Z. The earlier physical-input and action history is an explicit frontier.',
        solver=z.get_version_string(),versions={v:run(v,args.output) for v in ('us','jp')})
    report['implementationHashes']={n:hashlib.sha256(Path(__file__).with_name(n).read_text(encoding='utf-8').encode()).hexdigest()
                                    for n in ('clight.py','engine.py','search.py')}
    report['queryHashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(args.output.glob('*.smt2'))}
    (args.output/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    (args.output/'predecessors.dot').write_text('''digraph InkPredecessors {
  rankdir=RL;
  owner [label="Target: remember useful top"];
  query [label="Final raw Y in strict 4-unit band\nLive floor result OPEN"];
  copy [label="Actual State-to-Object copy\nIncoming State Y in same band"];
  snap [label="Actual floor snap + display copy\nIncoming cached floorHeight in band"];
  retry [label="Selected retry query at checked height\nNull first result + high display at copy"];
  producer [label="Earlier walls, live floors, display producer\nController reachability OPEN"];
  owner -> query;
  query -> copy [style=dashed,label="intervening callbacks OPEN"];
  copy -> snap [style=dashed,label="action tail and timing OPEN"];
  snap -> retry [style=dashed,label="geometry/interactions/call effects OPEN"];
  retry -> producer [style=dashed,label="no memory frame granted"];
}
''',encoding='utf-8')
    for v,r in report['versions'].items():
        counts={}
        for branch in r['finalCapture']['branches']:counts[branch['status']]=counts.get(branch['status'],0)+1
        print(v,counts,'raw Y band:',r['finalCapture']['acceptedRawY'])
    print('PASS: backward slice checks; open calls and joins remain unresolved.')


if __name__=='__main__': main()
