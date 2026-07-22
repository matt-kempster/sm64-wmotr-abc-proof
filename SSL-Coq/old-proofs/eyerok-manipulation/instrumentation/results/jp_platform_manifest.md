# Original-JP platform-pointer probe manifest

Date: 2026-07-19

The probe ran under Mupen64Plus 2.5.9's cached interpreter in the
Ubuntu-24.04 WSL distribution.  It used the original Japanese ROM identified
by:

```text
MD5:        85d61f5525af708c9f1e84dce6dc10e9
SHA-1:      8a20a5c83d6ceb0f0506cfc9fa20d8f438cafe51
SHA-256:    9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
header CRC: 4eaa3d0e 74757c24
country:    J
revision:   0
```

A clean `VERSION=jp` build of pinned source revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, made under Ubuntu-24.04
with `SSL_SPAWNING_DISPLACEMENT_TAS_HACK=0`, was byte-identical to that ROM.
The build contains no `clear_mario_platform` symbol.  The probe addresses are
from the matching JP ELF rather than transplanted US addresses.

## Fixture

Mupen's JP level-select cheat is index 6 (US uses index 1).  The controller
plugin loads SSL Area 3, discovers the real sleeping Eyerok boss and side-`+1`
hand by behavior, and moves Mario onto the genuine static Area 3
`SURFACE_INSTANT_WARP_1D` triangle.  It writes Mario's position, zero speed,
and idle action to create that local query fixture.  It never writes a hand,
boss, collision surface, object slot, or Area 2 object field.

The natural case performs no platform write.  At timer 365 the static warp
floor has a null object owner and `gMarioPlatform` is null.  This is the
ordinary coherent source outcome.

The comparison case performs one additional state injection immediately
before `check_instant_warp`: it writes the sleeping hand's raw slot address
`80340d18` (slot 32) to `gMarioPlatform`.  This is deliberately a conditional
seed, not a claimed Mario/controller trace.  On the first Area 2 observation,
the same address contains virtual behavior `800ead50`, which maps to
`bhvWaterDroplet`.  The replacement has zero X/Z velocity and zero angular
velocity.  Mario's measured displacement is `(0,0,0)`, and stored
`forwardVel` remains zero.  The end-of-frame platform refresh then stores
null.

The source/Clight audit supplies the intra-frame fact that original JP applies
the retained nonnull address before that refresh; the input callback cannot
observe the middle of `update_objects` directly.  The zero movement is also
the expected result for this concrete nonrotating replacement.

## Scope

This probe confirms that original JP differs from US and that a raw slot
address, not Eyerok object identity, is the relevant value.  It does not stage
an Eyerok explosion, arrange a rotating Area 2 replacement, or prove that
Mario can authentically combine a stale cached warp floor with a freshly saved
hand platform.  In particular, it is not a particle-platform-displacement TAS
and establishes no 0-A or 0.5-A route.  Pedro's stale-floor landing branch is
the exact remaining escape hatch requiring a controller-reachable trace.
