# Can we deliver the pink Bob-omb Buddy?

14 November 2026. **No controller-reachable method of moving SSL Area 1's
Buddy to the Ink setup has been established. Ordinary contact does not push
or pick him up. However, he is not intrinsically immovable: if a glitched
pickup really acquires him, the game's normal drop and throw routines can
relocate him.** That pickup is the unresolved step.

The selected three-actor handoff therefore remains conditional. Its Buddy
placement was supplied. These findings neither deliver that actor nor
invalidate the useful handoff after the supplied placements.

## What the different proposals establish

| Proposal | Result | Evidence and limit |
| --- | --- | --- |
| Walk into, punch or normally pick up the native Buddy | Does not relocate or grab him | TEXT/NPC interaction pushes Mario, not Buddy; finite approach controls leave Buddy at `(-5990,0,-3871)` |
| Push him with a Goomba, including an ordinary transport clone | Named stock-list proposal fails | Buddy is GENACTOR; PUSHABLE Goomba is not paired against him by the ordinary object collision pass |
| Hit him with a Bob-omb or small box | No target movement from the named attack helper | The helper changes interaction status, not target position/velocity; Buddy does not interpret it as knockback |
| Talk to Buddy during a small-box pickup to replace the remembered object | Blocked by the actual action guards | Pickup actions are in the OBJECT action group; they fail native NPC dialog readiness |
| Supply the missing pickup reference, then use Z or B | Native release relocates Buddy | Conditional experiment; no direct Buddy coordinate, held-state, behavior or HOLP edits |
| Relocate a terrain mesh or alter his support | Physics could matter, but no delivery history found | Idle calls real wall/floor/gravity physics; global terrain and object-lifetime invariants remain unproved |

HOLDABLE is an internal flag, not permission to pick an actor up normally.
For Buddy it means the generic pickup helper preserves his native behavior
and sets his held state. He does not turn into the frozen carry-script clone
used in the Goomba controls. His raw collision position does not follow the
hand while held. On release, however, the generic position stores still run:

- **Drop:** `(HOLP.x, Mario movement Y, HOLP.z)`.
- **Throw:** `(HOLP.x + 32 sin(yaw), HOLP.y, HOLP.z + 32 cos(yaw))`.

His own physics resumes/continues at the resulting position. There is no
Buddy throw handler that gives him the black Bob-omb's projectile velocity.
HOLP here is the stored held-object position; neither the drawn model nor
Mario's stored graphics position is being substituted for raw actor XYZ.

## The closest tested capture predecessor

The controlled test starts from the native Area-1 prefix, supplies Mario at
`(5900,51,3380)` beside the real small box, and presses B. Mario starts the
small-box pickup normally. During that animation, **one supplied write
changes `usedObj` from the small box to Buddy**. The native pickup then
acquires Buddy. Subsequent Z-drop or B-throw moves him thousands of units
without a direct write to Buddy's position. The comparison without that
pointer write picks up the small box and leaves Buddy at spawn.

**Both releases and the comparison pass on the original Japanese ROM.**
The three runs each preserve 2,327 pre-cut observations and 148 post-cut
observations. The Z-drop deposits Buddy at
`(5884.97021484375,51,3394.096435546875)`; the B-throw first records
`(5888.63916015625,160.45884704589844,3362.268798828125)`, then settles at
the same X/Z and Y51. The separate Wafel batch passes 3,323 fresh matched
boundaries, including ordinary player contacts and conditional releases.
These counts describe finite tests, not all possible controller histories.

This isolates the exact missing condition. It is not a clone route and does
not exploit a naturally reused slot. No reviewed in-area constructor spawns
a fresh Buddy into the remembered donor slot. Distance hiding keeps the
existing slot, and normal area reload resets Mario's pending pickup state.
The `PERSISTENT_RESPAWN` flag does not provide an in-area distance respawner.

The next useful experiment is a specific legal object-slot or pointer
history that makes a reached grab consume the native Buddy. Repeating drops
from an already supplied held pointer will not solve that problem. An
alternative is a concrete movable terrain mesh that can actually reach his
spawn location and alter his support; none is established here.

## Evidence and proof boundaries

The [source audit](ink-buddy-movement-source.md) records the exact actor,
pair tests, physics, pointer writers, action guards and pinned source
revision. The [runtime record](ink-buddy-movement-runtime.md) records every
setup edit, controller input and fresh replay check. The
[Coq record](ink-buddy-movement-proof.md) specifies the generated-code
theorems and their explicit assumptions. The original-JP replay receipt is
in [the ROM harness](../../instrumentation/jp-ink-buddy-movement/README.md).

A full “Buddy never moves in any allowed history” proof is still absent.
It would have to cover live terrain, actor-list provenance, object lifetime,
and every route to the held-object release writers. Assuming that Mario
never holds Buddy would assume away the cloning question. The new local
proofs and conditional releases are kept separate from that obligation.
The complete no-new-A Ink route remains open; all subjective atlas estimates
are unchanged.

The targeted module build and the four-boundary selected audit pass with
Coq 8.16.1 / CompCert 3.15 in the `sm64-item-proof` switch. The new boundary
uses seven already allowed foundational axioms and introduces no project
axiom or admission. Its explicit gameplay, storage and execution premises
are still premises; a successful audit does not establish Buddy acquisition.
