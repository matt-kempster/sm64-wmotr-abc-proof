# JP Rank-1 direct outside-root receipt

This read-only certificate authenticates the direct retail-JP bodies of the
five Rank-1 routines that were not already covered by the square-root and
sound-stop certificate:

- `set_camera_shake_from_point`;
- `create_sound_spawner`;
- `cur_obj_play_sound_2`;
- `play_sound`; and
- `play_puzzle_jingle`.

`verify.sh` first requires the original-JP ROM SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
It then hash-checks five exact text ranges, disassembles all 163 instructions,
and compares their complete 29-store and 11-direct-call projection with
`expected-store-call-manifest.csv`.  Any extra store, changed instruction,
changed call target, or indirect/linking call fails the receipt.

Run it with:

```sh
bash verify.sh /path/to/baserom.jp.z64
```

The direct stores are exact: they target the game-thread stack, the object
pool, the sound-request array and count, or the fixed puzzle-music byte.  None
targets the live surface-node or surface-payload ranges.  `sqrtf` and
`stop_sounds_from_source`, including the latter's transitive helpers, are
covered separately by [`../jp-mips-external-frames/`](../jp-mips-external-frames/).

This certificate does not pretend that authenticating a caller authenticates
all of its callees.  `Area1SurfacePoolRangeSeparation.v` therefore gives the
transitive camera, object, and audio work an explicit protected-memory effect:
each reached store must remain in its bounded stack, static state, object
pool, sound-request storage, or initialized JP audio heap.  A corrupted audio
or object descriptor retargeted into the shared main pool fails that relation
and is the first concrete residual; connecting every live descriptor to its
initialized region remains part of the continuous-execution proof.
