# Eyerok Pedro probe manifest

Date: 2026-07-19

The probe ran under Mupen64Plus's pure interpreter in the Ubuntu-24.04 WSL
distribution against the North-American ROM identified by:

```text
MD5:        20b854b239203baf6c961b850a4a51a2
SHA-256:    17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91
header CRC: 635a2bff 8b022326
```

The controller plugin uses the debug menu and instant-warp shortcut to load
Area 3. It discovers the genuine boss and side-`+1` hand by behavior and waits
for the hand's source-created sleeping pose, collision pointer, and home Y.

For each comparison it writes only these Mario fields:

- position and matching Mario-object position;
- current/previous action `ACT_LONG_JUMP`;
- action state, timer, argument, and return code;
- forward/slide speed and facing yaw; and
- zero initial X/Y/Z velocity.

It never writes any hand or boss field. The fixture starts Mario at
`(254.750,-1532.000,-3115.500)`, just outside the right thumb wall, facing
inward. The speed-48 result resolves onto the ordinary upper hand floor at
Y `-1421`; `cancelledXZ=0` and `pedroY=0`.

The speed-424 result reaches the retail Pedro branch at timer 365. Retail air
speed has become `422.650`. Mario's Y snaps to the lower hand floor `-1459`,
but X/Z remains the old exterior position and the saved floor remains the
static arena floor at `-1534` with null object owner. Boss and hand are still
in `SLEEP`. These simultaneous observations distinguish the Pedro branch from
an ordinary hand landing.

This proves a local collision-semantic counterexample after state injection.
It does not prove a controller route to speed 424, repeated Pedro landings, or
speed accumulation. Because `ACT_LONG_JUMP` and speed are injected, it also
proves no A-press count—not 0 A, not 0.5 A, and not a fresh-A route. The
source-audited two-hand wake-frame-11 witness is a separate exact local state
and is not claimed as an emulator TAS.
