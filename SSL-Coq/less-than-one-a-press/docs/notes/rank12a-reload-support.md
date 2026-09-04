# Rank 12A: reload and same-position support refresh

Rank 12A asks whether an area transition can send Mario to an unexpected destination, reconstruct a different entry state, or change the floor/platform selected beneath him without first moving his recorded position. The last possibility is real: an authenticated original-JP machine receipt changes from SSL Area 3 to Area 2 between timers 365 and 366, reports no displacement, and changes Mario's floor address from `0x80192630` to `0x8019DAF0`.

## What the new proof fixes

The selected US and JP level scripts both give the upper Area-1 entrance the normal destination SSL Area 2, node `0x14`, whose Area-2 spawn record is the normal airborne warp at `(0, 5500, 256)` facing 180 degrees. They also encode the Area-2-to-Area-3 and Area-3-to-Area-2 instant warps with zero horizontal displacement. A new root-sensitive source scan distinguishes writes to the private `sWarpDest` object from unrelated fields that merely share names: `initiate_warp` is the only direct writer of its level, area, node, and argument, while the type byte is also cleared after Mario initialization, on the credits path, and during level initialization. The ordinary load call chain clears and rebuilds static surfaces before rebuilding objects and warp-node links, which explains why a floor address can change even when Mario does not.

## The exact witness

The natural (`inject=0`) case in `SSL-Coq/old-proofs/eyerok-manipulation/instrumentation/results/jp_platform_trace.txt` records Area 3, timer 365, floor `0x80192630`, surface type 29, null floor owner, and null platform; at timer 366 it records Area 2, floor `0x8019DAF0`, the same type 29, null owner, and null platform. Mario is printed at `(0.000, 346.080, -1100.000)` on both sides and the printed delta is `(0.000, 0.000, 0.000)`. Thus the changed-support alternative is no longer hypothetical: rebuilding the area can replace the selected static surface while preserving the displayed position.

## What it does and does not establish

This witness is harmless for the no-A route as observed. Both floors are ownerless instant-warp surfaces, `gMarioPlatform` remains null, and there is no upward or horizontal displacement to cross either Area-2 gate. It is also not a clean controller execution: although platform injection is disabled in this case, the harness staged Mario's position and idle action and had earlier written a warp destination to enter the test sequence. The receipt proves that the engine mechanism exists and gives its exact before/after support identities; it does not prove controller reachability or turn a changed pointer into a useful moving support.

## Remaining closure

For the ordinary upper entry, the normal destination, static entry record, zero-offset instant-warp descriptors, and direct destination writers are now checked. A universal impossibility result still needs one linked execution invariant showing that every reached indirect or aliased store preserves the private destination, that every area-load call has the expected memory frame, and that every post-load floor query selects only the rebuilt stock surfaces. A counterexample must now do more than merely refresh a floor address: it must produce an in-bounds nonzero or corrupted destination, an entry different from the checked record, or a changed support with a non-null useful owner or geometry that actually crosses a gate.

The Coq boundary is [Area2Rank12AReloadSupport.v](../../proofs/Area2Rank12AReloadSupport.v).
