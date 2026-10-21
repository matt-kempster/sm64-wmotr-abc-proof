# Rank 10A: upstream post-bounce execution transfer

Comparison baseline: [SSL PR #3 at `a1ff8b162e1d9816ac2b102e395047349358ed81`](https://github.com/tra38/sm64-wmotr-abc-proof/commit/a1ff8b162e1d9816ac2b102e395047349358ed81)
and [upstream `3f12cca74fb86c3a6619600994103757c6d9e94c`](https://github.com/matt-kempster/sm64-wmotr-abc-proof/commit/3f12cca74fb86c3a6619600994103757c6d9e94c) (21 October 2026).

The upstream result supports a stronger **local execution boundary** for SSL.
It does not turn the 51-state ordinary certificate or 31-state hard-rebound
certificate into a complete flight proof. Its WMotR-specific theorem cannot
be instantiated unchanged on SSL's selected linked programs and elevator
memories. The new work proves the portable local code directly in SSL.

## Generated code and transitions

The generated function-definition text is identical between upstream and
SSL US for `act_slide_kick`, `update_air_without_turn`, `perform_air_step`,
`perform_air_quarter_step`, `apply_gravity`, `apply_vertical_wind`, and
`set_mario_action_airborne`. This is a source comparison, not a proof that
their complete environments are interchangeable: upstream canonicalizes
anonymous composite atoms, and the linked programs differ.

`skp_us_jp_shared_code` checks actual Coq equality of SSL's US/JP
`act_slide_kick`, `update_air_without_turn`, `perform_air_step`, and
`apply_gravity` functions. The quarter-step definitions differ at their
anonymous `Surface.normal` tags (`__769` versus `__732`). More materially,
JP's vertical-wind helper has an additional `play_sound` call on the active
wind path. The ordinary slide-kick initializer case is already checked for
both versions by the existing launch proof; equality of that case does not
assert equality of the complete initializer functions.

| Case | Generated behavior | Consequence for SSL's model |
|---|---|---|
| State 0, timer 0 | Initial sound and animation calls | These calls need their own execution/footprint reasoning when composing a launch. |
| Every state | Increment and narrow the timer to 16 bits, then test updated timer > 30 and `posY - floorHeight > 500` | Arithmetic is modulo 65536. At 65535 the next timer is zero, so the late test is false. |
| Timeout accepted | Request FREEFALL (`16779404`), argument 2; return setter result | The model's `sk_accept` marks this boundary; `sk_next` alone does not execute the setter. |
| AIR_STEP_NONE (0), state nonzero | Skip pre-bounce angle work and return FALSE | The complete remaining handler suffix preserves memory. |
| Landed (1), state 0 and post-gravity velocity < 0 | Set velocity to `-velocity / 2`, state to 1, timer to 0, then landing sound | The bounce uses the velocity after gravity. |
| Landed, state nonzero (or bounce test false) | Request SLIDE_KICK_SLIDE (`8389722`), argument 0, then landing sound | No second bounce. The existing model marks the episode inactive; it does not execute this whole continuation. |
| Hit wall (2) | Zero positive vertical velocity, set particles, request BACKWARD_AIR_KB (`16910512`) | Not represented by the simple vertical sample recurrence. |
| Lava wall (6) | Call `lava_boost_on_wall` | Separate execution and reachability case. |

The air step attempts four movement quarters, then applies gravity (apart
from its special FLYING exclusion), vertical wind, and display refresh.
Gravity for slide kick is binary32 subtraction by 2, followed by an actual
comparison against -75 and a conditional store. A ceiling can zero velocity
during the quarters; subsequent slide-kick gravity then yields -2. Wind,
walls, different floors, early landings, and ceiling cuts must not be
silently modeled as four uninterrupted additions.

## Why the upstream theorem is not a drop-in lemma

Upstream's [`FfClass.sk_ok`][up-ff] now checks every outcome through `ff_okE ent_bs`,
and [`AirMove.sk_pre`][up-air] no longer requires state zero. [`SkRun.sk_kfinal`][up-run] obtains
the result from the actual symbolic walk `SkW.skcheck12`; `KbRow.sk1_row` and
`HeightFrame.Hsk1` are removed. This closes the handler's post-bounce row
inside that proof's existing premises, not every premise of the enclosing
game theorem.

The strengthened [`AirMatch.vel_exc` / `vel_ex`][up-vel] accepts a constant -75 only
with the clamp path fact, or the subtraction result with the no-clamp fact.
`aclass_air_ex` yields exact gravity velocity. Replacing that equality by
`-75 <= velocity' <= gravity(velocity)` would admit impossible updates and
invalidate the post-bounce signed-energy argument. SSL reuses this proof
requirement, not a weaker numerical bound.

The upstream execution theorem requires all of the following:

- `linked12 lp`: the exact upstream 22-unit link chain, despite its historical
  name. SSL instead selects a repaired US program or an official cleaned JP
  link from its 38-unit construction. Symbol/body/layout transport has to be
  proved; a matching handler text is insufficient.
- Its symbolic memory environment (`env_ok`, `MMg`, region and path facts),
  old-block injection and pointer-closure conditions, and actual completed
  handler call. Readable fields alone do not establish these conditions.
- `floor_data`, a fresh entry floor, and the WMotR floor/pole/cannon predicates.
  These do not describe SSL's moving elevator mesh or live query lists.
- `budget_ok`, including `posY + credit <= 2424 + 372`. Since the credit is
  nonnegative, its height consequence is `posY <= 2796`. SSL's normal sample
  starts at Y=4000, so this budget cannot be assumed for that sample.
- The existing DMA, square-root, audio and camera specifications. Their
  footprint claims do not follow just from selecting an SSL linked program.

Thus no upstream theorem or open world assumption is imported as an SSL
axiom. A future larger transfer can reuse the symbolic executor and exact
velocity recognizer after retargeting their program, floor, memory, and
summary premises. That is substantially more than deleting a state-zero
conjunct.

## The smaller bridge

[`Area2SlideKickGravityCore.v`](../../proofs/Area2SlideKickGravityCore.v)
constructs the generic execution with explicit action/velocity layouts.
[`Area2SlideKickPostBounce.v`](../../proofs/Area2SlideKickPostBounce.v)
instantiates those layouts for the selected programs and adds:

- `skp_selected_gravity_resolves`: the actual `apply_gravity` body resolves in
  each SSL selected program, including US viewport repair.
- `skp_exact_gravity_call`: a complete generated `apply_gravity` call, with
  exact binary32 subtraction/clamp behavior for any input float and any
  action state. Premises are a readable SLIDE_KICK action at Mario offset 12,
  readable velocity at 76, and writable `Mfloat32` access at 76. The argument
  is `Vptr mario Ptrofs.zero`; an arbitrary nonzero structure base would need
  offset transport. These field premises do not identify a controller-reached
  Mario block. Function entry, branch decisions and the one or two stores
  are constructed. Loads from other blocks or ranges disjoint from Mario's
  bytes `[76,80)` are preserved. There is no assumed output velocity, inert
  callback, WMotR height budget, or incoming state-zero premise.
- `skp_post_bounce_call_matches_model`: when `sk_sample_exact s` and
  `sk_bounced s` hold and memory contains a nonzero action state, that real
  helper execution preserves that state and produces exactly
  `sk_float8 (sk_velocity8 (sk_next s))`. The existing ordinary and hard
  sample certificates supply the arithmetic premise. Position, support,
  timer and the origin of the nonzero state still require a live projection.
  This is a helper-call theorem: it does not assert that the handler reaches
  that call when `sk_accept s` is true (the last hard-rebound sample).
- `skp_post_bounce_no_collision_suffix`: the actual remainder of
  `act_slide_kick` after an AIR_STEP_NONE result, from a readable nonzero
  state, returns zero with unchanged memory. It assumes neither a harmless
  callback nor a final memory frame: the branch performs no call or store.

The call theorems construct executions from the stated memory fields. They
are not an upstream-style classification theorem taking an arbitrary completed
whole-handler call as input. Using them for a universal exclusion requires
composition or transport to that actual run, with the necessary determinism
and memory-frame reasoning.

`SlideKickPostBounceBoundary` is consumed by
`current_rank10a_ground_pound_moving_geometry_boundary` in `MainTheorem.v`.
This strengthens the local facts supplied there. It does not discharge the
whole-run impossibility theorem's route or refinement premises.

## Remaining obligations

These two real execution pieces are not yet a single `act_slide_kick`
invocation proved to implement all of `sk_next`. The missing composition
must establish the actual timer gate, horizontal update, quarter-step loop,
collision results, gravity-call entry, vertical wind, graphics copy, and
handler return from one consistent memory history. In particular, prove
live base selection and the ten-unit descent at the right phase, headroom,
no interfering wall/wind/action effects, valid pointers and writable cells,
and the state/timer/position projection. Handle landing, ceiling and wall
alternatives rather than assuming every result is AIR_STEP_NONE. A stale
post-landing floor height must not be treated as the next dispatch's fresh
query result without a refresh proof.

Then preserve these premises across successive frames and connect them to
the existing launch initialization. Finally, derive the needed launch or
hard-fall predecessor from a clean no-A controller history. The 37.5 hard
rebound remains a conditional setup; the initializer overwrites inherited
vertical velocity with 12. Freefall-to-ground-pound continuation and a useful
sideways departure from the cage also remain open. Rank 10A is not closed,
and its subjective 2–5% counterexample estimate is unchanged.

## Supplied validation (Coq 8.18.0)

The targeted build of both new proof modules passed with Coq 8.18.0 and
CompCert 3.15 through `pipeline/build.sh`. The generic gravity-call assumption
audit reports six existing Coq/CompCert foundations and no project-local
axioms. The combined selected-program boundary assumption audit reports seven
existing foundations, including proof irrelevance, and no project-local axioms.
The final serial SSL discipline audit, `20261021-151648-1oc7w6z1`, passed:
681 registered sources, the `MainTheorem` dependency build, proof-hole and
link checks, all six requested assumption queries, and dependency integration
(509 of 603 proof modules in the main import closure, 94 standalone, zero
problems). The integrated Rank 10A boundary uses seven allowed foundations;
the conditional impossibility theorem uses six. This successful incremental
run followed a resource-killed parallel build and a two-hour cold serial
build timeout; neither failed attempt was counted as a passed audit.
Mechanical checks do not discharge the remaining execution and reachability
premises above. To rebuild the new boundary and repeat its focused checks:

```sh
bash pipeline/build.sh check-rank10a-post-bounce
```

The comparison and proof are pinned to the two commits above. No generated
source was edited.

[up-ff]: https://github.com/matt-kempster/sm64-wmotr-abc-proof/blob/3f12cca74fb86c3a6619600994103757c6d9e94c/proofs/WMotRRequiresA/FfClass.v
[up-air]: https://github.com/matt-kempster/sm64-wmotr-abc-proof/blob/3f12cca74fb86c3a6619600994103757c6d9e94c/proofs/WMotRRequiresA/AirMove.v
[up-run]: https://github.com/matt-kempster/sm64-wmotr-abc-proof/blob/3f12cca74fb86c3a6619600994103757c6d9e94c/proofs/WMotRRequiresA/SkRun.v
[up-vel]: https://github.com/matt-kempster/sm64-wmotr-abc-proof/blob/3f12cca74fb86c3a6619600994103757c6d9e94c/proofs/WMotRRequiresA/AirMatch.v

## Local application and validation (Coq 8.16.1)

The supplied two-commit patch was applied to the working tree of
`codex/ssl-pyramid-item-proof` on 21 October 2026, preserving unrelated
changes. The proof sources are unchanged from the supplied patch. Windows
Git initially wrote CRLF endings in the patched Bash checker; the first
audit, `20261021-134443-qjyu9zg1`, failed that link check despite a
successful proof build and six assumption queries. Restoring LF endings
and adding a path-specific Git line-ending attribute repairs application
without changing the proof statements or pipeline limits.

The fresh serial audit `20261021-135002-8exmu8bz` passes its dependency build,
proof-hole scan, link hygiene, all six requested assumption queries and
integration checks with Coq 8.16.1, CompCert 3.15 and the
`sm64-item-proof` switch. Limits remain 600 seconds for the build,
240 seconds per assumption query and 6,815,744 KB of virtual memory.
The [local validation record](rank10a-post-bounce-local-validation.json)
retains exact source hashes and check results, separately from the supplied
Coq 8.18 evidence. These are local helper-call and suffix results; whole
flight and clean controller reachability remain open.

The verified patch, LF repair and report updates are recorded in the
containing commit, with unrelated working-tree edits excluded. Because the
full audit included those preserved edits, the exact staged MainTheorem was
also checked independently through the pipeline. Its Rank 10A boundary and
conditional impossibility theorem retain seven and six allowed foundations.
The local validation record distinguishes the original working-tree audit
from this selective-commit check.
