# Mario attempts to deliver the Bob-omb himself

**These controller-only tests do not deliver the Bob-omb to Ink.** They are a
different question from the successful supplied preplacement test: that test
placed the actors with setup writes, rather than making Mario carry or throw
them there. Its compatibility result is preserved and is not a delivery witness.

This package begins with the actual no-A Bob-omb acquisition and enlarged
regrab preserved in [the earlier transport study](../../../docs/notes/ink-bobomb-regrab-transport.md).
All subsequent branches also use controller input only. The only non-controller
write is the project's accepted pre-entry `gDebugLevelSelect=1`; there are no
Mario, actor, held/used pointer, HOLP, hitbox, profile, fuse, action, timing or RNG
edits. A wrapper rejects every later write except the three controller fields.
Whole-state restoration only chooses an already controller-reached branch.

The working compatibility recipe's Bob origin is
`(-2080.06005859375,1809.2066650390625,-1230.322021484375)`.
It is the target for this finite transport menu, not a claim that every useful
handoff requires this exact point. No frozen-shell, Crazy Box or top-phase
fixture is imported into these gameplay histories.

## Actual transport

The first 616 controls of the earlier 938-input witness actually reach an
enlarged, held Bob39 at radius91 and fuse158. Mario is then
`(4620.95068359375,25.48348617553711,4450.9541015625)` in `PICKING_UP`;
the actor is `(4645.24853515625,85.48348999023438,4547.95703125)`.

`search.py` tries eight direct/south/west waypoint policies with per-cycle
turn caps1024/4096. `refine.py` tries sixteen direct/perimeter policies with
larger turn caps8192/16384 and two B phases. Held Mario faces away from desired
travel so the enlarged held body's contact pushes him in that direction.
After an actual drop he aims at the actual actor and pulses B for recovery.
All native terrain, enemy interactions, automatic drops, fuse growth and
deletion remain active. Horizons are850/1200 extension updates, but all tested
actors expire before the horizon.

The combined menu contains24 policy rows,14 distinct realized controller
suffixes, and2,544 branch updates. Its closest live/free actor lies4,056.014254
XYZ units from the target. That distance is a measured finite result, not an
unreachability radius. Maximum held Mario Y is396.5442810058594; maximum live
Bob Y is456.5442810058594. The largest held fuse is475, again not a lifetime
bound. The best policy makes16 further regrabs; another makes18.

The closest predecessor is preserved as the complete905-input
`closest-inputs.jsonl`. It uses no A. At completed897, Mario still holds Bob
at `(817.6715698242188,-45.853660583496094,836.99169921875)`, on floor type19.
At898, he crosses to moving quicksand type45, enters `QUICKSAND_DEATH`, and
loses the held reference. Bob is then still live/free at
`(850.7859497070312,-42.439029693603516,875.0999145507812)` with radius91,
fuse440 and patrol action/timer0. The actor expires at905. Thus this branch
fails terrain traversal before reaching a suitable release position or height.

A southern branch exposes a second concrete failure. At797 Mario still holds
Bob near `(2443.57,201.72,5092.19)`. Update798 enters `BUTT_SLIDE` and drops the
actor on the slope; recovery fails and it expires at805. The large-turn menu
loses its first recovery and expires by635. These are bounded action/terrain
failures, not proof that every route or steering schedule fails.

The top remains in action0 and every sampled pillar count is zero. There is
no spinning-top phase130, warp or Area2 arrival in these transport branches.
Increasing action0's timer is not the spinning sequence's timer.

## Actual drops and a genuine throw

`release.py` recreates seven small release controls twice from entry. The
neutral enlarged-donor continuation credits the earlier donor lifecycle; the
B/Z comparisons and earlier normal throw distinguish the available controls.

| Native start and input | First release | Bob origin after the update | Size and outcome |
|---|---|---|---|
| Enlarged pickup after616; neutral |628| (4558.10791015625,23.010007858276367,4253.400390625) | Radius91, fuse170, automatic drop |
| Same; B or Z on627 or628 |628| Same actor origin | Radius91, automatic drop; no throw |
| Earlier pickup after597; B on609 |615| (4589.56640625,147.4859619140625,4529.181640625) | Radius65, fuse157, actual native throw |
| Earlier pickup after597; Z on609 |609| (4607.4951171875,35.526939392089844,4555.734375) | Radius65, fuse151, actual native drop |

Input numbers count completed controller updates from the accepted entry
history. B at628 changes Mario's later action/movement that update, but does
not change the enlarged actor's release origin. The full snapshots and native
action-entry events are retained, rather than inferring a throw from the final
held pointer alone.

The source explains this local restriction. `bobomb_held_loop`
(`src/game/behaviors/bobomb.inc.c:182`) sets `INT_STATUS_MARIO_DROP_OBJECT` when
the fuse is expired. `act_hold_idle`
(`src/game/mario_actions_stationary.c:438`) checks that status before the
B/Z cancellation helper. Ordinary `PICKING_UP` completes its animation before
selecting `HOLD_IDLE` (`mario_actions_object.c:175`). Consequently B does not
turn this particular enlarged regrab cycle into an arbitrarily timed throw.
The earlier unexpired pickup can select actual `THROWING`; its timer7 invokes
`mario_throw_held_object` (`mario_actions_object.c:248`). The successful native
throw starts at HOLP height, while a drop uses Mario's movement Y
(`interaction.c:295,316`); post-release actor behavior can then adjust its
position. These source statements do not exclude another history or a
different action/flag arrangement.

In particular, the actual low native donor release is not the supplied
radius91 profile transplanted into the earlier Ink test. This package performs
no such transplant. Neither a real low throw nor repeated low regrabs solve
high target delivery.

## Reproduction and limits

From `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/bob/search.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/bob/refine.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/bob/release.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/bob/audit.py
```

All archive replays pass; selected full histories are additionally replayed
from fresh entry. Each advancement asserts A is absent both from the pad and
Mario's interpreted pressed/down flags. The read-only audit recomputes summary
counts and verifies the complete closest-input file against the archive.
`terrain.py` is a source-mesh planning aid with ordinary host arithmetic;
it is not a JP query emulator or a proof of a traversable path.

Evidence is pinned Wafel0.8.5/Python3.9.13. No original-ROM replay of these
new input extensions has run and no Coq theorem is added. Starting proof
checkout was `0605d842cedb55151e70952d56064553c4970f60`; applicable source pin
is `9921382a68bb0c865e5e45eb594d9c64db59b1af`, local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. JP runtime SHA-256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The original input-file SHA-256 is
`5fbabbad20efe0353072ac401279b81cc696415dd87621d905755b8dcf3e641b`;
the complete new905-input predecessor is
`72cfae1ed76e785214969fdc08d5039b922d109890db69644004eb72265338f5`.

The next useful test is an actual safe-ground regrab route to the south
entrance/roof approach, with recovery timing adapted before the slope causes
automatic sliding. A separate alternative is an actual history that preserves
the needed HOLP and reaches a throw-capable action with the enlarged actor.
Neither is supplied here. Joining either actor delivery with Mario's shell
entry and the top's active phase remains open.
