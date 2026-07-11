# Goal

Determine, with Rocq/Coq proofs over CompCert Clight generated from the real
SM64 decompile, whether the codebase can make a single byte-sized update to
Mario's Y float.

The motivating candidate is the demo playback update:

```c
if (--gCurrDemoInput->timer == 0) {
    gCurrDemoInput++;
}
```

On the North American N64 target, if `gCurrDemoInput` aliases the first byte
of Mario's Y float, the timer decrement can change byte `0xC5` to `0xC4`.
The project must either rule out that state from the real program's reachable
states or provide a precise counterexample and identify the remaining
reachability question.

Success requires generated-AST receipts, no proof holes, an assumption audit,
and documentation that distinguishes a local Clight execution witness from a
gameplay-reachable execution.

The first milestone is complete: the project has a checked local byte-store
counterexample and direct-writer census. The remaining research goal is the
stronger reachability decision—prove the demo-buffer/Mario-state separation
invariant for real executions or find a generated path that breaks it.

The memory-frame side of that decision is also complete: distinct CompCert
blocks imply preservation of Mario's Y byte, while a matching change implies
block aliasing. What remains is specifically the real-program proof of which
block `gDemoInputsBuf.bufTarget` can inhabit over reachable executions.
