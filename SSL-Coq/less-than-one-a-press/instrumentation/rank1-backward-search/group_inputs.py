"""Lossless symbolic groups at real controller cuts, not whole-game state merging.

The selected straight-line bodies come from generated US/JP Clight. Branches
become if-then-else expressions; original input bits remain symbolic. This uses
the exploratory engine's storage/arithmetic interpretation, not a Coq proof.
"""
import argparse
from collections import Counter, defaultdict
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path

from clight import ROOT, Term, outer_items, seq, walk
from engine import Engine, Scope, MEM, STATE, Unsupported, read, write, word, z

CTRL, PAD = 0x05000000, 0x06000000


@dataclass
class SymbolicState:
    memory: object
    temps: dict


class Merged:
    """Compose a bounded statement once, retaining both arms as exact ITEs.

    Substituting its output expressions in a goal gives that goal's preimage.
    No concrete state or representative controller record is selected.
    """
    def __init__(self, engine, function):
        self.engine, self.scope = engine, Scope(engine, function)

    def expression(self, expression, state, location=False):
        value = (self.engine.location if location else self.engine.eval)(expression, self.scope)
        pairs = [(MEM, state.memory)] + [(self.scope.temps[k], v) for k, v in state.temps.items()]
        return z.simplify(z.substitute(value, *pairs))

    def run(self, statement, state):
        tag, a = statement.tag, statement.args
        if tag == 'Sskip': return state
        if tag == 'Ssequence': return self.run(a[1], self.run(a[0], state))
        if tag == 'Sset':
            temps = dict(state.temps)
            temps[a[0].tag] = self.expression(a[1], state)
            return SymbolicState(state.memory, temps)
        if tag == 'Sassign':
            ty = self.engine.typeof(a[0])
            size, _ = self.scope.function.unit.size(ty)
            value = self.engine.cast(self.expression(a[1], state), self.engine.typeof(a[1]), ty)
            location = self.expression(a[0], state, location=True)
            return SymbolicState(z.simplify(write(state.memory, location, value, size)), state.temps)
        if tag == 'Sifthenelse':
            from engine import truth
            condition = truth(self.expression(a[0], state))
            yes, no = self.run(a[1], state), self.run(a[2], state)
            temps = {k: z.simplify(z.If(condition, yes.temps.get(k, self.scope.temps[k]),
                                      no.temps.get(k, self.scope.temps[k])))
                     for k in yes.temps.keys() | no.temps.keys()}
            return SymbolicState(z.simplify(z.If(condition, yes.memory, no.memory)), temps)
        # Calls, loops and nonlocal exits cannot silently inherit a frame.
        raise Unsupported('Merged input slice does not support ' + tag)


def field(unit, tag, name): return unit.layout(tag)[2][name]


def put(memory, address, value, size):
    if isinstance(value, int): value = word(value)
    if z.is_bv(value) and value.size() < 32: value = z.ZeroExt(32-value.size(), value)
    return write(memory, word(address), value, size)


def observed(memory, address, size):
    return z.simplify(read(memory, word(address), size), expand_select_ite=True)


def check(engine, predicate, expected, name, directory):
    result, _, reason = engine.solve(predicate)
    if result != expected: raise RuntimeError(f'{name}: expected {expected}, got {result}: {reason}')
    solver = z.Solver(); solver.add(predicate)
    (directory / (name + '.smt2')).write_text(solver.to_smt2(), encoding='utf-8')
    return result


def controller_cut(function):
    # The actual cuts used by InkControllerSource.ics_edge_stage/down_stage.
    iteration = outer_items(function.body)[2].args[1]
    assert iteration.tag == 'Sloop'
    present = outer_items(iteration.args[0])[-1]
    assert present.tag == 'Sifthenelse'
    pieces = outer_items(present.args[1])
    return seq(pieces[2:4])


def button_analysis(version, directory):
    e = Engine(version)
    sampling = e.function('game_init', 'read_controller_inputs')
    fn = e.function('mario', 'update_mario_button_inputs')
    sf = lambda name: STATE + field(fn.unit, '_MarioState', name)
    cf = lambda name: CTRL + field(fn.unit, '_Controller', name)
    before = z.Array('button_initial_memory', MEM.domain(), MEM.range())
    now, previous = z.BitVecs('sample_now sample_previous', 16)
    initial_flags = z.BitVec('initial_Mario_input', 16)
    since_a, since_b, squish = z.BitVecs('since_A since_B squish', 8)
    memory = before
    for address, value, size in [(cf('_controllerData'), PAD, 4), (PAD, now, 2),
            (cf('_buttonDown'), previous, 2), (sf('_controller'), CTRL, 4),
            (sf('_input'), initial_flags, 2), (sf('_framesSinceA'), since_a, 1),
            (sf('_framesSinceB'), since_b, 1), (sf('_squishTimer'), squish, 1)]:
        memory = put(memory, address, value, size)
    sampling_merge = Merged(e, sampling)
    sampled = sampling_merge.run(controller_cut(sampling), SymbolicState(memory, {'_controller': word(CTRL)}))
    pressed = observed(sampled.memory, cf('_buttonPressed'), 2)
    down = observed(sampled.memory, cf('_buttonDown'), 2)
    checks = {'actual-edge-and-down': check(e, z.Or(pressed != (now & (now ^ previous)), down != now),
                    'unsat', version+'-group-actual-controller-edge', directory)}
    transform = Merged(e, fn)
    after = transform.run(fn.body, SymbolicState(sampled.memory, {'_m': word(STATE)}))
    outputs = [observed(after.memory, sf(name), size)
               for name, size in [('_input', 2), ('_framesSinceA', 1), ('_framesSinceB', 1)]]
    checks['original-held-and-edge-bits-retained'] = check(e,
        z.Or(observed(after.memory, cf('_buttonDown'), 2) != now,
             observed(after.memory, cf('_buttonPressed'), 2) != pressed),
        'unsat', version+'-group-button-memory-retained', directory)
    writes = {n.args[0].args[1].tag for _, n in walk(fn.body) if n.tag == 'Sassign'}
    assert writes == {'_input', '_framesSinceA', '_framesSinceB'}
    # The signature is derived from the actual helper's output at zero flags.
    # All other state, including counters and prior held bits, stays symbolic.
    signature = z.simplify(z.substitute(outputs[0], (initial_flags, z.BitVecVal(0, 16))))
    other = z.BitVec('sample_alternative', 16)
    signature_other = z.substitute(signature, (now, other))
    output_other = [z.substitute(v, (now, other)) for v in outputs]
    # Keep the project's already-held-A case. Its real derived new-press bit
    # must stay zero; a released A cannot be pressed again in the next step.
    legal = lambda v: z.And((v & z.BitVecVal(0x00c0,16))==0,
        (z.substitute(pressed,(now,v)) & z.BitVecVal(0x8000,16))==0)
    checks['previous-ABZ-suffice-for-signature'] = check(e,
        z.And(legal(now), signature != z.substitute(signature,(previous,previous & z.BitVecVal(0xe000,16)))),
        'unsat',version+'-group-button-prior-signature',directory)
    checks['all-nonzero-squish-values-agree'] = check(e,
        z.And(legal(now),squish!=0,signature!=z.substitute(signature,(squish,z.BitVecVal(1,8)))),
        'unsat',version+'-group-button-squish-signature',directory)
    checks['same-signature-same-helper-writes'] = check(e,
        z.And(legal(now), legal(other), signature == signature_other,
              z.Or(*[a != b for a, b in zip(outputs, output_other)])),
        'unsat', version+'-group-button-congruence', directory)
    # Contrast against the old branch-expanding preimage implementation.
    desired = z.BitVec('desired_button_flags', 16)
    scope, paths = e.start(fn, read(MEM, word(sf('_input')), 2) == desired)
    reference = z.Or(*[p.condition for p in paths])
    reference = z.simplify(z.substitute(reference, (MEM, sampled.memory), (scope.temps['_m'], word(STATE))))
    checks['merged-matches-backward-preimage'] = check(e,
        z.And(legal(now), z.Xor(reference, outputs[0] == desired)),
        'unsat', version+'-group-button-preimage-equivalence', directory)
    # Explicit enumeration is only of one sample's finite alphabet, not histories.
    profiles = []
    off_a_masks=[mask for mask in range(65536) if not mask & 0x80c0]
    for old_a in (0,0x8000):
      for old_b in (0, 0x4000):
        for old_z in (0, 0x2000):
            for squished in (False, True):
                expression = z.simplify(z.substitute(signature,
                    (previous, z.BitVecVal(old_a | old_b | old_z, 16)),
                    (squish, z.BitVecVal(int(squished), 8))))
                groups = Counter()
                masks=off_a_masks if not old_a else [mask+a for mask in off_a_masks for a in (0,0x8000)]
                for mask in masks:
                    key = z.simplify(z.substitute(expression, (now, z.BitVecVal(mask, 16)))).as_long()
                    groups[key] += 1
                assert sum(groups.values()) == (16384 if old_a else 8192)
                profiles.append(dict(previousA=bool(old_a),previousB=bool(old_b), previousZ=bool(old_z),
                    squished=squished, groups=[dict(signature=k, members=n) for k,n in sorted(groups.items())]))
    # Same helper result now does not justify dropping the held-B distinction.
    def sig(current, prior):
        value = z.simplify(z.substitute(signature, (now, z.BitVecVal(current,16)),
            (previous,z.BitVecVal(prior,16)), (squish,z.BitVecVal(0,8))))
        if not z.is_bv_value(value):
            candidate = e.solve(z.BoolVal(True))[1].eval(value, model_completion=True)
            check(e, value != candidate, 'unsat', version+f'-group-concrete-{current}-{prior}', directory)
            value = candidate
        return value.as_long()
    counterexample = dict(previousB=True, firstSamples=[0, 0x4000], nextSample=0x4000,
        firstSignatures=[sig(0,0x4000),sig(0x4000,0x4000)],
        nextSignatures=[sig(0x4000,0),sig(0x4000,0x4000)])
    assert len(set(counterexample['firstSignatures'])) == 1
    assert len(set(counterexample['nextSignatures'])) == 2
    (directory/(version+'-button-signature.smt.txt')).write_text(signature.sexpr()+'\n',encoding='utf-8')
    return dict(checks=checks,profiles=profiles,writeFields=sorted(writes),
        heldButtonCounterexample=counterexample,
        meaning='Groups have the same writes in this helper for the same other state. Original held bits remain in memory and in the group; these are not interchangeable whole-game states.'), e.functions


def stick_analysis(version, directory):
    e = Engine(version)
    fn = e.function('game_init', 'adjust_analog_stick')
    parts = outer_items(fn.body)
    first_call = next(i for i,p in enumerate(parts) if any(n.tag == 'Scall' for _,n in walk(p)))
    assert first_call == 6  # Reset X/Y, then the four raw-axis tests.
    body = seq(parts[:first_call])
    cf = lambda name: CTRL + field(fn.unit, '_Controller', name)
    x, y = z.BitVecs('raw_X raw_Y', 8)
    memory = z.Array('stick_initial_memory', MEM.domain(), MEM.range())
    memory = put(memory, cf('_rawStickX'), z.SignExt(24,x), 2)
    memory = put(memory, cf('_rawStickY'), z.SignExt(24,y), 2)
    transform = Merged(e,fn)
    after = transform.run(body, SymbolicState(memory, {'_controller':word(CTRL)}))
    out_x, out_y = [observed(after.memory,cf(k),4) for k in ('_stickX','_stickY')]
    checks = {}
    alternate = z.BitVec('other_raw_axis',8)
    checks['axis-independence'] = check(e,z.Or(out_x != z.substitute(out_x,(y,alternate)),
        out_y != z.substitute(out_y,(x,alternate))), 'unsat',version+'-group-stick-independent',directory)
    checks['raw-axes-retained'] = check(e,
        z.Or(observed(after.memory,cf('_rawStickX'),2) != z.SignExt(8,x),
             observed(after.memory,cf('_rawStickY'),2) != z.SignExt(8,y)),
        'unsat',version+'-group-raw-stick-retained',directory)
    targets = z.BitVecs('target_X_bits target_Y_bits',32)
    goal = z.And(read(MEM,word(cf('_stickX')))==targets[0],read(MEM,word(cf('_stickY')))==targets[1])
    scope, paths = e.start(fn,goal,body)
    reference = z.simplify(z.substitute(z.Or(*[p.condition for p in paths]),
        (MEM,memory),(scope.temps['_controller'],word(CTRL))))
    checks['merged-matches-backward-preimage'] = check(e,
        z.Xor(reference,z.And(out_x==targets[0],out_y==targets[1])),
        'unsat',version+'-group-stick-preimage-equivalence',directory)
    scope2, guard_paths = e.start(fn,z.BoolVal(True),body)
    regions=[]
    for p in guard_paths:
        guard = z.simplify(z.substitute(p.condition,(MEM,memory),(scope2.temps['_controller'],word(CTRL))))
        result,_,reason=e.solve(guard)
        if result=='unknown': raise RuntimeError('Unresolved stick region: '+str(reason))
        if result=='sat': regions.append(dict(decisions=list(p.decisions),formula=guard.sexpr()))
    axis_groups={}
    for name,variable,expression in [('X',x,out_x),('Y',y,out_y)]:
        # Independence was checked symbolically above. Fix the other axis only
        # for this one-axis finite count, never in the retained predecessor set.
        expression=z.simplify(z.substitute(expression,((y if name=='X' else x),z.BitVecVal(0,8))))
        groups=defaultdict(list)
        for raw in range(-128,128):
            value=z.simplify(z.substitute(expression,(variable,z.BitVecVal(raw,8)))).as_long()
            groups[value].append(raw)
        axis_groups[name]=dict(groupCount=len(groups),memberSizes=dict(Counter(map(len,groups.values()))),
                               neutralMembers=groups[0])
    assert len(regions)==9 and axis_groups['X']==axis_groups['Y']
    assert axis_groups['X']['groupCount']==242 and axis_groups['X']['neutralMembers']==list(range(-7,8))
    unexpanded_call=next(n for _,n in walk(parts[first_call]) if n.tag=='Scall')
    try: transform.run(unexpanded_call,SymbolicState(memory,{'_controller':word(CTRL)}))
    except Unsupported: checks['unexpanded-call-rejected']='passed'
    else: raise AssertionError('Unknown call silently accepted')
    return dict(checks=checks,rawPairs=65536,symbolicRegions=regions,axisGroups=axis_groups,
        distinctAdjustedPairs=242**2,neutralPairMembers=15**2,
        boundary='Before the sqrtf call, with raw axes retained. The nine regions contain exact raw variables; they are not nine representative joystick directions.'), e.functions


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,default=ROOT/'build/rank1-backward-search/grouping')
    args=parser.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    report=dict(status='Checked local symbolic grouping; no complete-frame or 150-update coverage.',
                solver=z.get_version_string(),
                inputDomain='One ordinary Player-1 sample, no newly pressed A and two reserved button bits zero; previous bits retained. Already-held A may remain held or be released. Earlier history is not granted. Stick axes are signed-byte encodings. Other state stays symbolic at the named separated-storage cuts.',
                grouping='Exact conditional expressions and member predicates; never one representative for a whole-game state.',
                versions={})
    for version in ('us','jp'):
        print(version+': checking actual button sampling and helper groups',flush=True)
        buttons,functions=button_analysis(version,args.output)
        print(version+': checking stick-prefix groups',flush=True)
        sticks,more=stick_analysis(version,args.output);functions.update(more)
        report['versions'][version]=dict(buttons=buttons,sticks=sticks,generatedFunctions=functions)
    assert report['versions']['us']['buttons']['profiles']==report['versions']['jp']['buttons']['profiles']
    assert report['versions']['us']['sticks']['axisGroups']==report['versions']['jp']['sticks']['axisGroups']
    report['implementationHashes']={name:hashlib.sha256(Path(__file__).with_name(name).read_text(encoding='utf-8').encode()).hexdigest()
        for name in ('clight.py','engine.py','group_inputs.py')}
    (args.output/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('PASS: local grouping and backward-preimage checks; retained inputs and later consumers remain live.',flush=True)


if __name__=='__main__': main()
