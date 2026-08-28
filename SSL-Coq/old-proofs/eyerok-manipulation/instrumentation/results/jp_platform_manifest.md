# Original-JP platform-pointer probe manifest

Date: 2026-08-27

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
plugin loads SSL Area 3, discovers the real sleeping Eyerok boss and both
hands by behavior and side, and moves Mario onto the genuine static Area 3
`SURFACE_INSTANT_WARP_1D` triangle.  It writes Mario's position, zero speed,
and idle action to create that local query fixture.  It never writes a hand,
boss, collision surface, object slot, or Area 2 object field.

The natural case performs no platform write.  At timer 365 the static warp
floor has a null object owner and `gMarioPlatform` is null.  This is the
ordinary coherent source outcome.

The two comparison cases each perform one additional state injection
immediately before `check_instant_warp`: one writes right-hand address
`80340d18` (slot 32) and the other writes left-hand address `80346e78` (slot
73) to `gMarioPlatform`.  These are deliberately conditional seeds, not
claimed Mario/controller traces.  Debugger breakpoints at retail unload,
allocation, and platform-apply code show that the right address is freed and
becomes Area-2 allocation 1, while the left address becomes allocation 2.  At
the first Area-2 apply, after all 83 allocations, both addresses contain
virtual behavior `800ead50` with command words
`00080000,11010001,0a000000`; the generated initializer identifies this as
`bhvStaticObject`, not `bhvWaterDroplet`.  Both replacements have zero linear
and angular motion.  With time stop clear, Mario present, and the injected
pointer nonnull, the retail apply runs but Mario's measured displacement is
`(0,0,0)` and stored `forwardVel` remains zero.  The end-of-frame platform
refresh then stores null.

The debugger now observes the actual apply entry and return, so the
intra-frame application no longer depends only on the source/Clight ordering
argument.  It also records the three guards directly: time stop is clear,
`gMarioObject` is nonnull, and the retained pointer is nonnull.  The zero
movement is the expected result for either concrete nonrotating replacement.

## Destroyed-hand ordinary payload suffix

A separate authenticated baseline census records all 83 Area-2 allocations at
the first platform apply.  Source-audited death ordering places a stale last-
or first-destroyed hand cell at allocation 53 or 54.  Under the deliberately
generous assumption that prior persistent state only deletes entries from the
baseline allocation stream, every reused payload is therefore baseline
allocation 53 through 83.  The validator checks the exact fields consumed by
platform displacement: every suffix entry has zero X/Z velocity and zero
angular velocity except allocation 64, `bhvSpindel`.  Allocations 60 through
63 have Y velocity only, which the audited displacement body does not add to
Mario.  The matching CompCert binary32 proof evaluates Spindel at the recorded
ordinary warp center as approximately `(0,338.5134,-1138.419)` from
`(0,346.08044,-1100)`, a small downward/backward movement rather than a lift.
This census does not cover a cell that is never reused, state changes that do
more than delete baseline allocations, or reachability of the required cached-
floor/hand-pointer mismatch.

## Scope

This probe confirms that original JP differs from US and that a raw slot
address, not Eyerok object identity, is the relevant value.  It closes the
tested ordinary sleeping-hand payload for both hands, and the related census
closes every reused deletion-only suffix payload as an immediate Act-3 lift;
neither stages an Eyerok explosion or proves that Mario can authentically
combine a stale cached warp floor with a freshly saved hand platform.  In
particular, these are not particle-platform-displacement TASes and establish no
0-A or 0.5-A route.  The ordinary branch still needs the exact mismatch, an
unreused-slot classification, and a verdict on the later usefulness of the
small Spindel shift.  The separate PU-scale clean installation is disproved by
the checked support, transport, and dialog lifecycle bounds in the active
proof; corruption and post-undefined-behavior execution remain out of scope.
