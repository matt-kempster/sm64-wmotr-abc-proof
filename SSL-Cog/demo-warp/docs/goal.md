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

