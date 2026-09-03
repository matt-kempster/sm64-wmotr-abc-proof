# Rank 11 Goomba installer mesh audit

This diagnostic checks whether any stock Area-2 regular Goomba can reach the second-pole ring through a deliberately permissive static-floor model. It reads the pinned decomp collision source; it does not modify a ROM, save state, or emulator.

Run the reviewed receipt check from the repository root:

```sh
node SSL-Coq/less-than-one-a-press/instrumentation/rank11-goomba-installer/analyze_mesh.js --check
```

Use `--compact` to print the reviewed fields or omit it for the full component/frontier report. An optional final positional argument selects another `collision.inc.c` file.

The graph includes every upward face that `surface_load.c` classifies as a floor (`normalY > 0.01`). It over-approximates ordinary walking, the exact `66 + 78 = 144` jump/query rise, and a separate `216`-unit two-Goomba separation. It expands the triplet spawner into its three exact pinned-table children. A negative result does not cover dynamic surfaces except for the separately reviewed Grindel discharge argument, H/F/R partial updates, stale/forged objects, outside writes, OOB, DMA, or ACE.
