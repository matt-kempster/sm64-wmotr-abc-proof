# Tiny concrete backward-validation pilot

2 October 2026. **The smallest real Wafel check passes:** one target-derived
predecessor matches, a deliberately wrong predecessor is rejected, and two
edges replay continuously without an intermediate patch or restore. The
original 1 October package passed 13 code tests; the local runtime fixes now
pass 15. No emulator or runtime was installed. This validates the small
backward-testing loop on an ordinary freefall segment, not a full-state
inverse, new Ink witness, Coq result, route exclusion or estimate change.

## What is reused

`instrumentation/wafel-jp-pilot/branch.py` already restores a full Wafel saved
context and advances concrete game updates with explicit controller writes.
`replay.py` supplies the pinned JP runtime loader, controller prefix and
bit-exact position/action/support observations. The original emulator poll
comparison has its own documented +1 global-timer offset; it is not silently
reused as a Wafel frame number.

`instrumentation/rank1-backward-search/candidate_feedback.py` proposes whole
forward controller histories and feeds measured floor-call values into a
generated-source query. It does not reconstruct arbitrary preceding frames.
The [Reverse Scattershot note](rank1-reverse-scattershot.md) describes the
missing literal loop: propose a predecessor, execute the actual forward edge,
and retain a compatible suffix. The new pilot implements that small loop,
without the symbolic engine or ordinary forward input branching.

## The exact small problem

The real adapter deliberately starts with **ordinary descending ACT_FREEFALL
in SSL Area 1**, on the existing JP runtime. It tries two neutral-input updates.
It does not start at Pedro, installed Ink, a supplied warp, or a whole no-A
route. Choose a reached prefix ending at a suitable pre-input boundary.

Only two state fields are inverse-mapped: `gMarioState.pos[1]` and
`gMarioState.vel[1]`. Candidate generation receives the target observation,
never the recorded predecessor values. For the ordinary freefall hypothesis:

1. Guess previous vertical velocity by reversing the ordinary gravity minus-4
   step, then consider nearby binary32 words
2. Guess previous height by reversing four rounded additions of previous
   velocity divided by four, then consider nearby binary32 words
3. Restore the full N-1 context, overwrite both mapped fields, explicitly write
   all three controller-pad fields, advance once, and compare the target
4. For an accepted N-1 candidate, inverse-map its two fields to N-2, restore
   that frame's full context, patch and check the next edge
5. Finally restore N-2 and patch **once**. Run both inputs continuously, checking
   the intermediate and final projections. Never restore or patch at N-1

The arithmetic hypothesis is grounded in the committed generated JP AST:
`generated/jp_mario_step.v`, `f_perform_air_step` (four quarter steps, then
gravity) and the ordinary branch of `f_apply_gravity` (subtract 4, clamp at
-75); `generated/jp_mario_actions_airborne.v`, `f_act_freefall` calls the common
air step. Collisions, wind, alternate gravity paths and other effects are
**not assumed away by acceptance**: the full runtime executes them, and only
an actual matching output can accept a proposal. These formulas merely propose
candidates; they are not a hand-written replacement for the game relation.

The default radius is two neighboring binary32 words per field, giving at most
25 proposals per inverse step. It deliberately excludes terminal speed, the
apex and nonfinite values. This is not an exhaustive inverse of rounding,
collisions or the game update. A failed budget says only that no tested chain
matched. Increasing the radius does not supply exhaustive coverage.

## State, equality and evidence limits

Full contexts come from Wafel `Game.save_state()` and `load_state()`. The
[verified v0.8.5 implementation](https://github.com/branpk/wafel/blob/1fa9a8320f7e56090234895f13d94f33c68977c1/wafel_api/src/game.rs)
copies the managed DLL's data segments and frame counter; the API's rerecord
counter increases on load rather than being restored. This is not an
emulator or whole-process snapshot. The
[Python SaveState API](https://github.com/branpk/wafel/blob/1fa9a8320f7e56090234895f13d94f33c68977c1/wafel_python/src/game.rs)
does not expose snapshot bytes or content equality. Object equality of its
opaque handles must not be used as a memory-equality check.

Accordingly, acceptance is named **accepted-projection**. The compared
projection includes all original pilot observer fields, all nine position
words, all three velocity words, forward velocity, level, Mario flags and
action argument, RNG, controller down/pressed history and pad values. Floats
are compared as binary32 words, not with a tolerance. The report enumerates
the exact field names. Full object state, exact floor-surface identity, heap
contents and numerous other values remain outside the comparison.

This projection is justified only for this bounded observation question:
"did this concrete execution produce these named endpoint values?" It is
**not** a proved suffix-preserving equivalence or an exact full-state inverse.
The two-frame replay executes the suffix itself, so hidden intermediate state
is carried continuously. A test deliberately makes two individually matching
edges incompatible through omitted hidden state; the continuous replay rejects
that splice. Hidden differences that do not affect this tested suffix can still
remain. Longer continuations require their own concrete replay or a stronger
equivalence argument.

The prior full contexts supply the unmodified complement of the two patched
fields. This is explicit conditional state search, not inversion of all game
memory. Arbitrary patched predecessors are not claimed to be controller-reachable.
The short recorded forward trace is the test oracle and complement-context
provider, not a source of copied inverse values. A regression test replaces
the recorded old y/velocity with deliberately wrong values and still recovers
the target-derived candidate.

Each trial records its full-context restore, patch before/after words and
mapping name, exact input and advance boundary, and differing fields. A Wafel
advance must increase `Game.frame()` and the global timer by one. Boundary f
means after f Wafel advances, before setting the next controller sample; the
input written there produces f+1. The initial prefix endpoint for poll P is
frame P-1. Retail timer offsets are used only for prefix comparison.

Each trial restores its caller's full gameplay context after acceptance,
rejection, partial write or advance failure. The pilot as a whole returns to
its reached prefix endpoint, not power-on. Operational errors are not counted
as rejected candidates.
A failed restore poisons the validator and aborts reuse. Restoration readback
checks the frame and named projection; it cannot independently prove all DLL
bytes restored. An unpatched two-update replay is an additional real-runtime
control when the optional Wafel pilot is run.

## Run the checks without Wafel or an emulator

From the repository root, Python 3.9 or newer:

```sh
python3 -m unittest discover \
  -s SSL-Coq/less-than-one-a-press/instrumentation/wafel-jp-pilot \
  -p 'test_backward_validation.py' -v
```

Fifteen tests pass in this implementation: accepted edge, exact one-bit rejection,
two-edge continuous replay, independence from recorded inverse fields,
hidden-context splice rejection, partial-write/advance restoration, restore
failure handling, exact boundaries, missing-versus-null projection keys,
mapping scope, a noninteger binary32 inverse requiring a neighboring proposal,
Wafel API read/write wiring, an explicit invalid-height control with saved
mismatches, and refusal to count backend errors as that control's rejection. The
deterministic backend is a test fixture, not a game model, emulator receipt or
evidence that the Wafel pilot passes. No Coq files changed or proof builds ran.

## Checked local runtime

Dot's ZIP was inspected and `git apply --check` passed at its exact base,
`940aec2a14b5a4cea3c5bf607b66aa4089b48157`, on
`codex/ssl-pyramid-item-proof`. The unrelated modified root `CLAUDE.md` and
untracked root `build/` were preserved. No push, site edit or deployment was
performed during the runtime-check batch, as requested. The user subsequently
authorized committing and pushing this checked pilot on the existing branch;
site changes remain outside this batch.

The installed runtime is **Python 3.9.13, Windows x64, Wafel 0.8.5**, with
the existing authenticated JP DLL. Its SHA256 is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The private baseline capture is `build/wafel-pilot/capture.bKv95w/inputs.jsonl`,
SHA256 `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The Ubuntu-24.04 emulator and Ubuntu Coq/CompCert environments are separate;
this check loads the Windows DLL with the installed Windows Python.

The first direct invocation found one adapter issue: the embeddable Python's
isolated path did not include the script directory, so the sibling module
could not import. The fix adds that directory explicitly. The real two-edge
run then passed. A second small addition runs a deliberately wrong height
control and records its differences, distinguishing rejection from errors.
The inverse mapper and validator from Dot's package remain unchanged.

Starting at capture poll **1170**, the prefix uses 1,169 advances and zero
held-A samples. Before the endpoint, 821 Area-1 observations match the retail
capture; the endpoint itself also matches, at the established +1 timer offset.
Mario is in ordinary descending `ACT_FREEFALL`, SSL Area 1, at
`(1722.2869873046875, 872, -2872.21337890625)` with vertical speed -16.
Two neutral updates provide the target and complementary saved contexts.
They are an oracle, not a forward controller search.

| Boundary | Wafel frame | Global timer | Movement Y | Vertical speed |
| --- | ---: | ---: | ---: | ---: |
| N-2 / reached prefix | 1169 | 1170 | 872 | -16 |
| N-1 / intermediate | 1170 | 1171 | 856 | -20 |
| N / target | 1171 | 1172 | 836 | -24 |

The target-derived central proposal, `freefall-ulp-v+0-y+0`, is accepted for
both inverse steps. At N-1 it proposes Y=856 and speed -20 using the target
Y=836 and speed -24. At N-2 it proposes Y=872 and speed -16 from the accepted
intermediate. These happen to equal the recorded oracle values, but the
mapper does not read the recorded predecessor fields. The patch ledger
therefore shows identical before/after words for the accepted proposals;
this is recovery of the known segment, not discovery of a new pose.

The explicit invalid proposal instead uses Y=920, speed -20 at frame 1170.
After one neutral advance, movement, collision and display Y are **900**, not
the target's **836**. Their expected/actual binary32 words are
`1146159104` / `1147207680`; those are the three recorded mismatches. It is
**rejected**, rather than returning an operational error.

The final chain's ledger is exactly: restore frame 1169, patch its two fields,
advance with neutral input, advance with neutral input. Both sampled
checkpoints match. No intermediate restore or patch occurs. The unpatched
save/restore/replay control also passes, and the pilot restores its reached
starting context after the checks.

The 31 named fields are `action`, `actionArg`, `actionTimer`, `area`,
`buttonDown`, `buttonPressed`, `collision`, `display`, `flags`, `floorHeight`,
`floorNull`, `floorOwner`, `forwardVel`, `input`, `level`, `marioSlot`, `pad`,
`pillars`, `platform`, `rng`, `timer`, `topAction`, `topActive`, `topSlot`,
`topTimer`, `vx`, `vy`, `vz`, `x`, `y`, `z`. Vectors are compared element by
element and floats by their exact binary32 words. Everything else comes from
the saved full context and is not independently compared.

## Commands and saved evidence

From `SSL-Coq/less-than-one-a-press`, the game check command was:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/backward_wafel.py build/wafel-pilot/capture.bKv95w/inputs.jsonl --first-poll 1170 --radius 2 --output build/concrete-backward-pilot/20261002-runtime/runtime-final.json
```

A parent Python `subprocess.run(..., timeout=120, capture_output=True)` imposes
the 120-second limit and saves the command, duration, exit code, stdout and
stderr. The final invocation exits 0 in **3.02 seconds**, including the
1,169-update prefix and all pilot controls; this is not an exhaustive-search
price or a per-update benchmark. Radius two allows at most 25 proposals per
inverse step; the first proposal succeeds at each edge. This batch stops at
the two-edge pilot.
The final code tests use:

```powershell
& './build/wafel-pilot/python/python.exe' -m unittest discover -s instrumentation/wafel-jp-pilot -p test_backward_validation.py -v
```

Evidence stays in ignored `build/concrete-backward-pilot/20261002-runtime/`:
`runtime-final.json` holds exact inputs, patch words, frame boundaries and
differences; `runtime-final-command.json` holds the command and resource limit;
`runtime-final.stdout.txt` and `runtime-final.stderr.txt` hold execution logs;
`tests-validated.txt` holds the 15 passing code tests; `runtime-version.txt`
holds the inspected versions. Earlier initial-run reports are retained there.
The original ZIP files and patch are retained separately under
`build/concrete-backward-pilot/20261002-dot-handoff/`.

Changed files are the three new Python modules (`backward_validation.py`,
`backward_wafel.py`, `test_backward_validation.py`), their existing Wafel
README, this new note, `rank1-reverse-scattershot.md`, `no-a-route-atlas.md`
and `checklist.md`. No existing symbolic-search, Coq or site files changed.

This completes the requested small runtime checks. Exact full-memory equality
would still require a supported comparator or a proved sufficient projection.
An Ink predecessor, a broader inverse move catalog, and allowed gameplay
reachability are separate work; none is claimed here.
