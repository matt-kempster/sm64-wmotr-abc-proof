"""Controller-grounded runtime refinement of the actual final-call preimage.

The generated final caller is reversed, including its four-unit/owner decision.
Earlier gameplay is an unanswered runtime relation indexed by a complete input
history, not an assumed frame or a manufactured emulator snapshot. Each new
model is replayed from initialization; its reached call occurrence supplies the
observations that refine that same model. Other histories remain unanswered.

This is an experimental candidate loop, NOT exhaustive arbitrary-prestate
classification or a verified Clight/retail refinement. A fixed reachable prefix
is an explicit search branch. No answer on it excludes other prefixes.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import time

from clight import ROOT
from engine import Engine, MEM, OBJECT, FLOOR, TOP, read, word, z
from search import HEIGHT, bits, number, conjunction

ROM_SHA256 = '9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317'
FINAL_PC = 0x802c7f88
MARIO_RETAIL = 0x80346038
BUTTON_MASK = 0x7f3f  # Actual pad buttons, with A and the two unused bits clear.


def digest(data):
    return hashlib.sha256(data).hexdigest()


def json_bytes(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode()


def save(path, value):
    path.write_text(json.dumps(value, indent=2)+'\n', encoding='utf-8')


def slot_pointer(slot):
    if slot == -1:
        return 0
    if not 0 <= slot < 240:
        raise ValueError('Object is outside the observed pool')
    if slot == 61:
        return TOP
    if slot == 67:
        return OBJECT
    return 0x02200000+slot*0x1000


class FinalCallPreimage:
    """Expose one actual find_floor occurrence, without existentially hiding it."""
    def __init__(self, version='jp'):
        self.engine = e = Engine(version)
        self.query = [z.BitVec('reached.query.'+axis, 32) for axis in 'xyz']
        self.height = z.BitVec('reached.height', 32)
        self.floor = z.BitVec('reached.floor', 32)
        self.owner = z.BitVec('reached.owner', 32)
        self.output = z.BitVec('retention.output', 32)
        self.fields = self.query+[self.height, self.floor, self.owner]
        self.occurrences = []
        fn = e.function('platform_displacement', 'update_mario_platform')
        layout = fn.unit
        if layout.layout('_Object')[2]['_platform'] != 532 or layout.layout('_Surface')[2]['_object'] != 44:
            raise ValueError('Generated layouts changed')

        def expose(name, ident, args, after, retval, scope):
            if name != 'find_floor':
                raise ValueError('Unexpected unresolved final-caller function '+name)
            self.occurrences.append(dict(caller=fn.name, callee=name, source=fn.digest, path=ident))
            # These equalities expose the required observations. They do not
            # claim that any runtime history supplies the proposed values.
            return z.And(*[z.fpToIEEEBV(a) == q for a, q in zip(args[:3], self.query)],
                z.fpToIEEEBV(retval) == self.height,
                read(after, args[3]) == self.floor,
                z.Implies(self.floor != 0, read(after, self.floor+word(44)) == self.owner),
                read(after, word(e.global_address('_gMarioObject'))) == word(OBJECT))

        e.call_constraints = expose
        goal = z.And(read(MEM, word(e.global_address('_gMarioPlatform'))) == self.output,
                     read(MEM, word(OBJECT+532)) == self.output)
        scope, paths = e.start(fn, goal)
        # Keep the call-taking branch. A null-Mario early return is not an
        # observation of the selected floor call and cannot satisfy this cut.
        self.relation = z.And(conjunction([p for p in paths if p.calls]),
            read(MEM, word(e.global_address('_gMarioObject'))) == word(OBJECT))
        self.target = z.And(self.relation, self.output == word(TOP),
                           self.query[0] == word(bits(-2200)),
                           self.query[2] == word(bits(-1024)), self.height == word(HEIGHT))
        if len(self.occurrences) != 1:
            raise ValueError('Expected exactly one source floor call')

    def facts(self, values):
        if len(values) != len(self.fields):
            raise ValueError('Incomplete occurrence projection')
        return z.And(*[var == word(value) for var, value in zip(self.fields, values)])

    def validate_return(self, values, observed_output):
        # Check that the actual source suffix both permits the measured result
        # and rules out a different result for these observed call values.
        s = z.Solver(); s.set(timeout=15000)
        s.add(self.relation, self.facts(values))
        s.push(); s.add(self.output == word(observed_output)); yes = s.check(); s.pop()
        s.push(); s.add(self.output != word(observed_output)); no = s.check(); s.pop()
        if yes != z.sat or no != z.unsat:
            raise ValueError(f'Generated suffix / emulator mismatch or incomplete check: {yes}/{no}')
        return dict(matchingReturn=str(yes), differentReturn=str(no))


class CandidateLoop:
    def __init__(self, updates, allowed=None, timeout_ms=15000, *, prefix=(), context=None):
        self.cut = FinalCallPreimage()
        self.prefix = [list(row) for row in prefix]
        self.context_id = digest(json_bytes(context or {'scope':'unit-test-only'}))
        self.inputs = [[z.BitVec(f'input.{i}.{name}', n) for name, n in
                        (('buttons', 16), ('x', 8), ('y', 8))] for i in range(updates)]
        self.solver = z.Solver(); self.solver.set(timeout=timeout_ms)
        self.solver.add(self.cut.target)
        for frame in self.inputs:
            self.solver.add(frame[0] & z.BitVecVal((~BUTTON_MASK) & 65535, 16) == 0)
            if allowed is not None:
                self.solver.add(z.Or(*[self.match_frame(frame, row) for row in allowed]))
        self.refinements = []
        self.pending = []

    def history(self, rows):
        first = len(self.prefix)+1
        return self.prefix+[[first+i, *row] for i, row in enumerate(rows)]+[[first+len(rows), 0, 0, 0]]

    def identity(self, rows):
        return dict(contextSHA256=self.context_id, controllerSHA256=digest(json_bytes(self.history(rows))))

    @staticmethod
    def match_frame(frame, row):
        return z.And(*[v == z.BitVecVal(x % (1 << v.size()), v.size()) for v, x in zip(frame, row)])

    def key(self, rows):
        if len(rows) != len(self.inputs) or any(len(r) != 3 for r in rows):
            raise ValueError('Input horizon mismatch')
        return z.And(*[self.match_frame(frame, row) for frame, row in zip(self.inputs, rows)])

    def propose(self, preferred=None):
        self.solver.push()
        # Pending cases are only skipped for scheduling this batch. They are
        # never added to the learned exclusions or counted as rejected.
        for rows in self.pending:
            self.solver.add(z.Not(self.key(rows)))
        if preferred is not None:
            self.solver.push(); self.solver.add(self.key(preferred))
            status = self.solver.check()
            model = self.solver.model() if status == z.sat else None
            self.solver.pop()
            if status != z.sat:
                status = self.solver.check()
                model = self.solver.model() if status == z.sat else None
        else:
            # Prioritize unpaused trials for this first fixed-poll adapter.
            # This is not an exclusion: if that priority set has no model,
            # query the full domain again, and retain pending paused cases.
            self.solver.push()
            self.solver.add(*[(frame[0] & 0x1000) == 0 for frame in self.inputs])
            status = self.solver.check()
            model = self.solver.model() if status == z.sat else None
            self.solver.pop()
            if status != z.sat:
                status = self.solver.check()
                model = self.solver.model() if status == z.sat else None
        self.solver.pop()
        if model is None:
            return str(status), None
        def signed(v):
            n = model.eval(v, model_completion=True).as_long()
            return n-256 if n >= 128 else n
        rows = [[model.eval(frame[0], model_completion=True).as_long(), signed(frame[1]), signed(frame[2])]
                for frame in self.inputs]
        proposal = dict(inputs=rows,
            requiredCall=dict(queryBits=[model.eval(v, model_completion=True).as_long() for v in self.cut.query],
                heightBits=model.eval(self.cut.height, model_completion=True).as_long(),
                owner=model.eval(self.cut.owner, model_completion=True).as_long()),
            meaning='Proposed inputs and required call values; not yet executed or reachable.')
        return 'sat', proposal

    def consume(self, rows, values, output, evidence):
        if any(evidence.get(key) != value for key, value in self.identity(rows).items()):
            raise ValueError('Reply belongs to a different controller history or search context')
        if evidence.get('callPath') != self.cut.occurrences[0]:
            raise ValueError('Reply belongs to a different source call occurrence')
        checks = self.cut.validate_return(values, output)
        # Feed facts into the *same* target query, guarded by this complete
        # suffix. The runner binds this instance to one fixed prefix/config.
        fact = z.Implies(self.key(rows), self.cut.facts(values))
        self.solver.add(fact)
        self.solver.push(); self.solver.add(self.key(rows)); status = self.solver.check(); self.solver.pop()
        expected = (output == TOP and values[0] == bits(-2200)
                    and values[2] == bits(-1024) and values[3] == HEIGHT)
        if status not in (z.sat, z.unsat) or (status == z.sat) != expected:
            raise ValueError('Runtime feedback did not classify its own target correctly')
        result = dict(status='checkpoint-witness' if expected else 'rejected-exact-history',
            afterFeedback=str(status), sourceSuffix=checks, evidence=evidence)
        self.refinements.append(result)
        return result


def read_baseline(path):
    rows = [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines()]
    if [r['poll'] for r in rows] != list(range(1, len(rows)+1)):
        raise ValueError('Baseline controller polls are not consecutive')
    if any(r['buttons'] & ~BUTTON_MASK for r in rows):
        raise ValueError('Baseline contains A or unused button bits')
    return rows


def windows_to_wsl(path):
    path = str(Path(path).resolve()).replace('\\', '/')
    if re.match(r'^[A-Za-z]:/', path):
        return '/mnt/'+path[0].lower()+path[2:]
    return path


def host_path(path):
    if os.name == 'nt' and re.match(r'^/mnt/[a-z]/', path):
        return Path(path[5].upper()+':/'+path[7:])
    return Path(path)


def run_emulator(rom, schedule, first, updates, work, timeout):
    script = ROOT/'instrumentation/rank1-reachable-search/capture.sh'
    args = ['bash', windows_to_wsl(script), windows_to_wsl(rom), windows_to_wsl(schedule)]
    env = dict(os.environ, RANK1_SEARCH_FIRST=str(first), RANK1_SEARCH_END=str(first+updates))
    if os.name == 'nt':
        command = 'cd '+shlex.quote(windows_to_wsl(ROOT))+' && '+shlex.join([
            'env', f'RANK1_SEARCH_FIRST={first}', f'RANK1_SEARCH_END={first+updates}', *args])
        args = ['wsl.exe', '-d', 'Ubuntu-24.04', '--', 'bash', '-lc', command]
    began = time.perf_counter()
    try:
        result = subprocess.run(args, capture_output=True, text=True, encoding='utf-8',
                                errors='replace', env=env, timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        # No state/result claim is made from an unfinished capture.
        raise ValueError('Emulator capture timed out; candidate remains pending') from exc
    (work/'runner.log').write_text(result.stdout+'\n'+result.stderr, encoding='utf-8')
    outputs = re.findall(r'^Output: (.+)$', result.stdout, re.M)
    if result.returncode or len(outputs) != 1:
        raise ValueError('Emulator capture failed; inspect runner.log')
    return host_path(outputs[0].strip())/'raw.log', time.perf_counter()-began


def load_receipt(log, schedule, baseline, first, updates):
    spec = importlib.util.spec_from_file_location('rank1_exact_observer', ROOT/'instrumentation/rank1-reachable-search/check.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    raw = log.read_bytes(); data = module.parse(raw.decode('utf-8', errors='replace'))
    validated = module.validate(data)
    inputs = data['WAFEL_PILOT']
    actual = [[r['poll'], r['buttons'], *r['stick']] for r in inputs]
    if actual != schedule:
        raise ValueError('Emulator did not execute the proposed complete controller history')
    # Compare the complete observed prefix, not just XYZ or a user-supplied label.
    if inputs[:first-1] != baseline[:first-1]:
        raise ValueError('Replayed prefix differs from the authenticated baseline')
    receipt = validated['receipt']
    if receipt['firstPoll'] != first or receipt['endPollExclusive'] != first+updates:
        raise ValueError('Observer window mismatch')
    stages = {(s['poll'], s['stage']):s for s in data['R1_SEARCH']}
    finals = [q for q in data['R1_SEARCH_QUERY'] if q['returnPC'] == FINAL_PC]
    if [q['poll'] for q in finals] != list(range(first, first+updates)):
        raise ValueError('This candidate did not complete one observed retention check per input poll')
    occurrences = []
    for ordinal, q in enumerate(finals, 1):
        s = stages[(q['poll'], 'final-query-return')]
        tail = stages[(q['poll'], 'final-platform-return')]
        if (q.get('entryPC') != 0x80381900 or q.get('entrySP') != q.get('returnSP')
            or q.get('outputAddress') != q.get('entrySP', 0)+60
            or any(q.get(k) != MARIO_RETAIL for k in ('entryObject', 'returnObject', 'stateObject'))
            or s['area'] != 1 or tail['area'] != 1):
            raise ValueError('Reached call/receiver/stack boundary is outside this adapter')
        if tail['platform'] != tail['objectPlatform']:
            raise ValueError('Retention outputs disagree')
        # Surface identity is only relocated after actual pool membership has
        # been checked. No live floor list is supplied to the emulator.
        floor = FLOOR+s['floorIndex']*48 if q['floor'] else 0
        if q['floor'] and s['floorIndex'] < 0:
            raise ValueError('Invalid returned floor')
        values = [*q['arguments'], q['height'], floor, slot_pointer(s['owner'])]
        occurrences.append(dict(ordinal=ordinal, poll=q['poll'], timer=q['timer'],
            queryBits=q['arguments'], heightBits=q['height'], floor=q['floor'],
            ownerSlot=s['owner'], platformSlot=tail['platform'],
            topTimer=tail['topTimer'], topBehavior=tail['topBehavior'],
            values=values, output=slot_pointer(tail['platform'])))
    return dict(captureSHA256=digest(raw), controllerSHA256=digest(json_bytes(schedule)),
                checks=validated, occurrences=occurrences)


def run(args):
    if args.updates < 1 or args.candidate_budget < 1 or args.first_poll < 350:
        raise ValueError('Positive bounds and a normally initialized Area-1 prefix are required')
    if digest(args.rom.read_bytes()) != ROM_SHA256:
        raise ValueError('The supplied ROM is not the authenticated JP ROM')
    baseline = read_baseline(args.prefix)
    first, n = args.first_poll, args.updates
    if len(baseline) < first+n:
        raise ValueError('Baseline must cover the requested window and trailing observation poll')
    args.output.mkdir(parents=True, exist_ok=False)
    prefix = [[r['poll'], r['buttons'], *r['stick']] for r in baseline[:first-1]]
    context = dict(version='jp', romSHA256=ROM_SHA256, firstPoll=first, updates=n,
        prefixSHA256=digest(json_bytes(prefix)), baselineSHA256=digest(args.prefix.read_bytes()),
        inputDomain='All 13 physical non-A buttons and both signed 8-bit axes at every suffix poll.',
        proposalPriority='Try no Start presses first; Start is not removed from the input domain.',
        horizonDomain='One completed Area-1 retention check per suffix poll; other timings remain pending.',
        earlierHistories='All prefixes other than this controller-reached prefix remain open.')
    loop = CandidateLoop(n, prefix=prefix, context=context)
    report = dict(status='running', context=context, candidates=[], completedExhaustiveUpdates=0,
        scope='Runtime-refined input branch of the generated final-call preimage, not unrestricted source-horizon classification.',
        globalExclusion=False, wholeInkInstallationWitness=False)
    save(args.output/'context.json', context)
    save(args.output/'report.json', report)
    began = time.perf_counter()
    preferred = [[0, 0, 0] for _ in range(n)]
    for iteration in range(args.candidate_budget):
        work = args.output/f'candidate-{iteration:03d}'; work.mkdir()
        status, proposal = loop.propose(preferred if iteration == 0 else None)
        if proposal is None:
            report['status'] = 'solver-'+status
            break
        proposal['contextSHA256'] = digest(json_bytes(context))
        rows = proposal['inputs']
        # One extra neutral poll is needed for the emulator testshot shutdown.
        schedule = loop.history(rows)
        proposal['controllerSHA256'] = digest(json_bytes(schedule))
        save(work/'proposal.json', proposal)
        (work/'proposed.smt2').write_text(loop.solver.to_smt2(), encoding='utf-8')
        schedule_file = work/'controller.inputs'
        schedule_file.write_text(''.join(' '.join(map(str, row))+'\n' for row in schedule), encoding='utf-8')
        print(f'Candidate {iteration}: source target proposed; replaying {n} updates from its complete controller history.', flush=True)
        item = dict(iteration=iteration, controllerSHA256=proposal['controllerSHA256'],
                    proposedCall=proposal['requiredCall'])
        try:
            # Exact-history cache reuse still revalidates the raw controller
            # log, prefix, ABI pairs and every reached checkpoint. A previous
            # summary verdict alone cannot answer the call.
            log = None
            if getattr(args, 'replay_cache', None):
                cache = json.loads((args.replay_cache/'report.json').read_text(encoding='utf-8'))
                for old in cache.get('candidates', []):
                    if old.get('controllerSHA256') == proposal['controllerSHA256'] and old.get('replayLog'):
                        log = Path(old['replayLog']); break
            reused = log is not None
            if reused:
                seconds = 0.0
            else:
                log, seconds = run_emulator(args.rom, schedule_file, first, n, work, args.emulator_timeout)
            item.update(replayLog=str(log), emulatorSeconds=seconds, exactHistoryCacheRevalidated=reused)
            reply = load_receipt(log, schedule, baseline, first, n)
            save(work/'reply.json', reply)
            # Use every intermediate occurrence to check the actual source
            # decision, not just a target-height arithmetic reimplementation.
            checks = [loop.cut.validate_return(o['values'], o['output']) for o in reply['occurrences']]
            last = reply['occurrences'][-1]
            evidence = dict(contextSHA256=proposal['contextSHA256'], controllerSHA256=reply['controllerSHA256'],
                captureSHA256=reply['captureSHA256'], ordinal=n, poll=last['poll'],
                callPath=loop.cut.occurrences[0], sourceHashes=loop.cut.engine.functions)
            outcome = loop.consume(rows, last['values'], last['output'], evidence)
            # Save and re-query the exact model after consuming the reply.
            loop.solver.push(); loop.solver.add(loop.key(rows))
            (work/'refined.smt2').write_text(loop.solver.to_smt2(), encoding='utf-8')
            loop.solver.pop()
            item.update(outcome, emulatorSeconds=seconds, exactHistoryCacheRevalidated=reused, validatedUpdates=n,
                        matchedFloorCallReplies=len(checks), actualFinal=last,
                        replayLog=str(log), sourceSuffixChecks=checks)
            print(f"Candidate {iteration}: {outcome['status']}; {len(checks)} reached floor calls checked; target {outcome['afterFeedback']} after feedback.", flush=True)
            if outcome['status'] == 'checkpoint-witness':
                report['status'] = 'checkpoint-witness-needs-warp-and-lifetime-validation'
        except (ValueError, AssertionError) as error:
            item.update(status='pending-runtime-validation', reason=str(error))
            loop.pending.append(rows)
            print(f'Candidate {iteration}: pending ({error}).', flush=True)
        report['candidates'].append(item)
        save(args.output/'report.json', report)
        if report['status'].startswith('checkpoint-witness'):
            break
    if report['status'] == 'running':
        report['status'] = 'candidate-budget-reached-unsearched-histories-remain'
    report.update(seconds=time.perf_counter()-began,
        rejectedExactHistories=sum(c['status'] == 'rejected-exact-history' for c in report['candidates']),
        matchedFloorCallReplies=sum(c.get('matchedFloorCallReplies', 0) for c in report['candidates']),
        pendingCandidates=len(loop.pending), generatedSource=loop.cut.engine.functions,
        implementationHashes={name:digest(Path(__file__).with_name(name).read_bytes()) for name in
            ('candidate_feedback.py', 'engine.py', 'clight.py')},
        observerSHA256=digest((ROOT/'instrumentation/rank1-reachable-search/probe.c').read_bytes()),
        remaining='Untested suffixes, unmatched runtime cases, all other prefixes and arbitrary symbolic prestates remain open. No timing extrapolation for exhaustive longer horizons.')
    save(args.output/'report.json', report)
    return report


def add_arguments(p):
    p.add_argument('--prefix', type=Path, required=True, help='Authenticated baseline inputs.jsonl; only earlier controller inputs are reused.')
    p.add_argument('--rom', type=Path, required=True)
    p.add_argument('--first-poll', type=int, default=2651)
    p.add_argument('--candidate-budget', type=int, default=3)
    p.add_argument('--emulator-timeout', type=float, default=240)
    p.add_argument('--replay-cache', type=Path, help='Optional previous report directory; only raw logs for identical complete input schedules are reused and fully rechecked.')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    add_arguments(p)
    p.add_argument('--updates', type=int, default=30)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    result = run(args)
    print(json.dumps({key:result[key] for key in ('status', 'rejectedExactHistories', 'matchedFloorCallReplies', 'pendingCandidates')}, indent=2))
    # The bridge completing does not mean exhaustive search completed.
    raise SystemExit(2)


if __name__ == '__main__':
    main()
