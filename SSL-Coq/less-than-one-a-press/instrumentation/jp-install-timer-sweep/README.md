# JP installation-timer sweep

This search-only harness composes the conditional Area-1 three-view fixture
with a robust midpoint sample on the pyramid top.  It varies the top's action
timer at installation so that some delayed warps unload the top before its
normal explosion.  The trace records the resulting object/free-list lineage
and the first observed Area-2 position.

The harness writes an injected Graphics position and therefore does **not**
establish reachability from a clean entry.  Its results only classify payloads
that would follow if a gameplay mechanism supplied the three-view split.

Run one timer against the hash-gated original Japanese ROM:

```sh
./instrumentation/jp-install-timer-sweep/run.sh /path/to/baserom.jp.z64 120
```

Controller A is always zero after the injected boundary.
