"""Measure concrete full-game advances; never classify symbolic predecessors.

Restore only a state reached through the captured controller prefix. Every
sampled field in the checked windows must match the existing retail-emulator
capture at the established +1 global-timer observation offset. Timing repeats
are the same inputs, not independent searches or additional gameplay coverage.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import statistics
import sys
import time

sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import create_game, load_capture, Observer, set_input, RUNTIME


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_match(actual, expected):
    if 'positions' not in expected:
        raise ValueError('The timed interval must remain in the captured Area-1 scene.')
    if actual['timer'] != expected['timer'] + 1:
        raise ValueError('The established poll-to-update timer offset changed.')
    differences = {
        key: [value, actual.get(key)] for key, value in expected.items()
        if key not in ('poll', 'timer', 'buttons', 'stick')
        and actual.get(key) != value
    }
    if differences:
        raise ValueError('Retail capture mismatch: ' + json.dumps(differences))


def timing_summary(values):
    return {'min': min(values), 'median': statistics.median(values),
            'max': max(values), 'samples': values}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--first-poll', type=int, default=2540)
    parser.add_argument('--lengths', type=int, nargs='+', default=[30, 90, 150])
    parser.add_argument('--repeats', type=int, default=5)
    args = parser.parse_args()
    rows = load_capture(args.capture)
    if args.repeats < 1 or not args.lengths or min(args.lengths) < 1:
        parser.error('Positive horizons and repeat count required.')
    if args.first_poll < 2 or args.first_poll + max(args.lengths) > len(rows):
        parser.error('Need a complete controller prefix and final observation row.')
    if [row['poll'] for row in rows] != list(range(1, len(rows) + 1)):
        raise ValueError('Non-contiguous input capture.')
    if any(row['buttons'] & 0x8000 for row in rows):
        raise ValueError('This benchmark uses the existing A-released replay only.')

    game = create_game()  # Authenticates the JP DLL; grants only accepted startup.
    observer = Observer(game)
    prefix_checked = 0
    start = time.perf_counter()
    for row in rows[:args.first_poll - 1]:
        if 'positions' in row:
            require_match(observer.snapshot(), row)
            prefix_checked += 1
        set_input(game, row)
        game.advance()
    prefix_seconds = time.perf_counter() - start
    saved = game.save_state()
    initial = observer.snapshot()
    require_match(initial, rows[args.first_poll - 1])
    results = []
    for length in args.lengths:
        policy = rows[args.first_poll - 1:args.first_poll - 1 + length]
        for mode in ('advance-only', 'checked-trace'):
            restore_times, run_times, totals = [], [], []
            reference_trace = None
            events = Counter()
            action_event_frames = 0
            for repeat in range(args.repeats):
                begin = time.perf_counter()
                game.load_state(saved)
                restore_seconds = time.perf_counter() - begin
                if observer.snapshot() != initial:
                    raise ValueError('Restored observer state differs from the reached state.')
                trace = []
                counts = Counter()
                frames = 0
                begin = time.perf_counter()
                for i, row in enumerate(policy):
                    set_input(game, row)
                    game.advance()
                    if mode == 'checked-trace':
                        snapshot = observer.snapshot()
                        require_match(snapshot, rows[args.first_poll + i])
                        trace.append(snapshot)
                        kinds = [event['type'] for event in game.frame_log()]
                        counts.update(kinds)
                        frames += 'FLT_EXECUTE_ACTION' in kinds
                run_seconds = time.perf_counter() - begin
                # Final checks are outside both measured intervals.
                final = observer.snapshot()
                require_match(final, rows[args.first_poll - 1 + length])
                if final['timer'] - initial['timer'] != length:
                    raise ValueError('An advance did not correspond to one global-timer increment.')
                if mode == 'checked-trace':
                    trace_hash = hashlib.sha256(json.dumps(trace, sort_keys=True).encode()).hexdigest()
                    if reference_trace is not None and trace_hash != reference_trace:
                        raise ValueError('Repeated observation trace is not deterministic.')
                    reference_trace = trace_hash
                    if repeat and (events != counts or action_event_frames != frames):
                        raise ValueError('Repeated action-event trace differs.')
                    events, action_event_frames = counts, frames
                restore_times.append(restore_seconds)
                run_times.append(run_seconds)
                totals.append(restore_seconds + run_seconds)
            results.append({
                'mode': mode, 'advances': length, 'nominalGameSeconds': length / 30,
                'repeats': args.repeats, 'restoreSeconds': timing_summary(restore_times),
                'runSeconds': timing_summary(run_times),
                'restorePlusRunSeconds': timing_summary(totals),
                'medianAdvancesPerSecond': length / statistics.median(run_times),
                'checkedSnapshotsPerRepeat': length if mode == 'checked-trace' else 0,
                'checkedTraceSha256': reference_trace,
                'frameLogEventCountsPerRepeat': dict(events),
                'framesWithMarioActionEventsPerRepeat': action_event_frames,
                'finalSnapshot': final,
            })
    report = {
        'schema': 1, 'recordedUtc': datetime.now(timezone.utc).isoformat(),
        'verdict': 'concrete-replay-benchmark-passed',
        'scope': 'One reached JP replay; repeated nested horizons. No predecessor enumeration, new route search, or impossibility result.',
        'wafelRelease': '0.8.5', 'python': platform.python_version(),
        'librarySha256': digest(RUNTIME / 'sm64_jp.dll'),
        'captureSha256': digest(args.capture), 'scriptSha256': digest(Path(__file__)),
        'adapterSha256': digest(Path(__file__).with_name('replay.py')),
        'firstPoll': args.first_poll, 'prefixAdvances': args.first_poll - 1,
        'prefixComparedArea1Snapshots': prefix_checked, 'prefixSeconds': prefix_seconds,
        'aHeldFrames': 0, 'timerOffset': 1, 'initialSnapshot': initial,
        'totalTimedAdvances': 2 * args.repeats * sum(args.lengths),
        'uniqueComparedSuffixSnapshots': max(args.lengths),
        'results': results,
        'notMeasured': ['symbolic predecessors', 'number of required search branches',
                        'exact within-update warp/retention checkpoints', 'US runtime'],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({key: report[key] for key in
                      ('verdict', 'firstPoll', 'totalTimedAdvances', 'uniqueComparedSuffixSnapshots')}))
    for row in results:
        print(json.dumps({key: row[key] for key in
                          ('mode', 'advances', 'medianAdvancesPerSecond',
                           'framesWithMarioActionEventsPerRepeat')}))


if __name__ == '__main__':
    main()
