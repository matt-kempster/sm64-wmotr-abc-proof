# One enlarged Bob-omb replaces the earlier Box + Buddy pushes

This package finds a conditional native JP Wafel handoff with a frozen shell,
one enlarged black Bob-omb at update129 and one Crazy Box at update130. There
is no Buddy, no Box placement at129, and no Mario state edit after the initial
supplied airborne cut in the actual replay histories. The exact useful Area2
arrival is `(365.5927734375,5500,-1096.8026123046875)`.

The Bob profile is taken from an actual no-new-A donor history: after628
controller inputs it is free, radius91, height158.1999969482422, fuse170.
Its scalar fields are conditionally transplanted into the target world's
native Bob39 **before** the initial airborne cut. Every copied field is in
`profileInstall.writes`; this is not a joined delivery history. Behavior,
interaction type/subtype and callback remain native, and its explosion
continues. The radius does not remain91: after the push it begins its native
explosion sequence, and the subsequent producer boundary has radius65.
The helper and donor evidence are in `../ink-enlarged-bob-profile/`.

## Exact positive

Initial phase128: supply FREEFALL M=C=G at `(-1960,19900,-1230)`, speed0,
velocity `(0,-16,0)`, yaw0; place the genuinely initialized/frozen shell71
at `(-1960,19890,-1230)`. Press Z that update, then neutral throughout.
The earlier shell preparation retains its explicit spawn-action, pickup
pointer, high-HOLP and initial position grants; see the complete preparation
ledger. No allowed high delivery or complete controller route is claimed.

Before129, place Bob39 at
`(-2080.06005859375,1809.2066650390625,-1230.322021484375)`.
Before130, place Crazy Box49 at
`(-2102.720703125,1839.447265625,-1119.5618896484375)`.

| Update executed | Movement = Collision after update | Stored Graphics Y | Floor / platform | Result |
|---|---|---:|---|---|
|128|(-1960,1809.206665,-1230)|19900|top / top|Native shell mount, Z cancel, butt slide|
|129|(-2117.026855,1839.447266,-1113.008545)|1809.206665|top / none|Enlarged Bob push reaches next-update low-floor geometry|
|130|(-2200.001709,768,-1075.003906)|1839.447266|static768 / none|Final Box produces1071.447266-unit gap|
|131|(-2200.001709,1914.854980,-1075.003906)|1914.854980|top / top|Warp64 accepted, top61 captured|
|Area2| (365.5927734375,5500,-1096.8026123046875)|5500|Area2|Useful displaced spawn|

Every observed remaining Area1 boundary retains platform61 after acceptance.
The actual useful producer starts at1839.447266, not the original airborne
19900 height. Stored Graphics is `gfx.pos`, not the rendered model matrix.

The enlarged hitbox matters for registration as well as displacement. Before
129, old Collision X/Z is(-1960,-1230), while native platform carry has moved
Movement to approximately(-2082.9241,-1221.2260). The Bob center is120.06 from
old Collision, inside91+37 but outside65+37. It is then only about9.54 from
Movement; the native push separates them to91+37−5=123.

## Evidence and controls

`geometry.py` scans147 supplied airborne initializers and extracts native
loaded meshes. It evaluates source predicates numerically to propose13,200
radius91/117 placements. Those proposals are not native floor-call traces or
gameplay witnesses. `native.py` tests the first four ranked proposals and21
producer candidates, stopping at the first useful result; the selected full
history is independently regenerated in a fresh native runtime.

Ranking uses an isolated save-state branch with action DISAPPEARED/argument0
to read the next geometry cache without the normal action overwriting it.
The complete original state is restored before actual actor continuations.
That temporary action and its Movement/Graphics changes never enter a
selected replay. Independently regenerated full histories do not use the
ranking branch. The positive's next-update cache is768, ceiling1523.

`controls.py` independently repeats eight complete histories from two fresh
runtimes. Results:

- Positive radius91: top capture, retention and useful spawn.
- Omit final Box: fresh768 and gap, but ordinary Area2 `(0,5500,256)`.
- Omit Bob: no fresh768 producer and no capture.
- Stock radius65 at the exact Bob position: does not register, no capture.
- Stock radius65 moved to98/100/101 units from old Collision: registers,
  but the final caches are1885.5376/1887.3004/1889.5341 and no capture.
- Actual terminal radius117 profile at the same position: registers and
  reaches768, but gives an ordinary Area2 spawn with the same final Box cut.

These finite controls do not establish a minimum radius, a height interval,
or impossibility for other actor positions/timings. No original-ROM or Coq
claim is made by this package itself. Original-ROM validation, if performed,
belongs to its separately linked receipt.

## Reproduction

From the SSL project directory, using the existing native Wafel runtime:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-enlarged-bob-target/geometry.py --verify instrumentation/ink-enlarged-bob-target/geometry-results.json.gz
& build/wafel-pilot/python/python.exe instrumentation/ink-enlarged-bob-target/native.py --verify instrumentation/ink-enlarged-bob-target/native-results.json.gz
& build/wafel-pilot/python/python.exe instrumentation/ink-enlarged-bob-target/controls.py --verify instrumentation/ink-enlarged-bob-target/controls-results.json.gz
```

Timing fields are excluded from exact verification. Inputs, actor edits,
profile grants, action events, M/C/G, floor/cache, collisions and outcomes are
preserved. Starting proof checkout was
`32f5eb4d5911b2e0a7972b748065c71ebe016717`; runtime bytes are pinned in
`native-results.json.gz`. The source base remains the project's JP
`9921382a68bb0c865e5e45eb594d9c64db59b1af` decompile revision, with the
existing instrumentation fork/runtime conventions.
