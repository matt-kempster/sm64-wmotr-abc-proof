# Native Buddy acquisition control

The preserved history reaches the real SSL Area 1 pink Bob-omb, talks to him,
then reaches and grabs the native western Crazy Box. It **does not grab or
clone the Buddy**: the Crazy Box selection replaces the old dialogue target
before the delayed pickup reads it. No usable Ink actor is delivered.

All controller inputs keep A released. The sole startup grant is the existing
debug level-select entry. No Mario position, action, velocity, reference,
actor position/identity, object lifetime or RNG field is supplied.

`inputs.jsonl` is the complete 3471-input history: the first 2339 inputs of the
existing native capture, 329 inputs that approach and finish Buddy dialogue,
801 inputs that reach and pick up the western box, and two neutral inputs to
observe the result. The original capture has **2852**, not 2548, inputs;
`base_at` now asserts the requested prefix exists. `controller.inputs` is
the exact four-column schedule accepted by the existing native recorder.

`wafel-trace.json.gz` contains 3123 before-poll observations, beginning at
poll349. `search-records.json.gz` preserves five finite branches, including
the failed approach and failed Crazy Box transport, with every controller
input and suffix sample. The input history, not the current search policy,
is authoritative for reproducing an exploratory branch. No branch includes
a supplied state cut. `search-check.json` records independent fresh replay of
all five histories, matching 1755 exact suffix samples.

Run from `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-acquisition/verify-wafel.py
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-acquisition/preserve-search.py
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-acquisition/audit-artifacts.py
```

The Wafel guard rejects every post-startup write except the three controller
pad fields; it rejects A in both the pad and the resulting Mario input flags.
No held-A entry is assumed. The DLL is authenticated by the existing loader.

For original Japanese ROM reproduction, run in Ubuntu-24.04. The existing
recorder creates a fresh output directory and prints its path:

```sh
WAFEL_PILOT_PROBE=instrumentation/ink-buddy-acquisition/native-probe.c \
  bash instrumentation/wafel-jp-pilot/capture.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  instrumentation/ink-buddy-acquisition/controller.inputs
python3 instrumentation/ink-buddy-acquisition/check-native.py \
  build/wafel-pilot/capture.PRINTED_SUFFIX
```

`native-probe.c` adds read-only before-input observations to the existing
recorder. It imports no game-memory write API. The original ROM is hash-gated
by the existing pipeline. The native checker compares exact binary32
movement/collision/stored-graphics/floor and integer action/reference/object
fields. Wafel's global timer is one greater at this observation boundary;
controller poll indices match exactly. This is a finite field comparison,
not whole-memory equivalence or a global no-cloning theorem.

The original-JP run in `native-record/` **passed**: all 3471 controller inputs
reproduced, with 3123 matching native/Wafel observations and zero mismatches.
The archive contains the compressed emulator log, checker receipt and source
hashes; it contains no ROM, DLL, or emulator plugin binary. To recheck those
archived observations without running the emulator:

```sh
python3 instrumentation/ink-buddy-acquisition/check-native.py \
  instrumentation/ink-buddy-acquisition/native-record \
  --output build/buddy-acquisition-archive-recheck.json
```

See [the runtime report](../../docs/notes/ink-buddy-acquisition-runtime.md)
and [source audit](../../docs/notes/ink-buddy-acquisition-source.md).
