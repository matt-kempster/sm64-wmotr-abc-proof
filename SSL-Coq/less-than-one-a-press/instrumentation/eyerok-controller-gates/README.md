# Eyerok controller-gate paired probe

This probe checks the strongest deterministic movement-only Eyerok recipe on the authentic North-American retail ROM.  The inherited harness shortens Area-1/Area-2 travel with disclosed writes.  Its boundary is the first ordinary Area-3 controller poll with the live boss and both hands present; after that boundary the plugin performs no memory write and supplies only stick input plus B to close the mandatory intro dialog.  A is never set.

Run the paired receipt in WSL Ubuntu 24.04:

```sh
bash instrumentation/eyerok-controller-gates/run_pair.sh \
  /path/to/authentic/baserom.us.z64
```

`run_pair.sh` rejects the wrong ROM digest, uses Mupen64Plus's pure interpreter, runs the positive/front and negative/front sweep placements, and invokes `analyze.py`.  The analyzer fail-closes on chronology, input/write counts, floor ownership, cached-platform ownership, sweep direction, the positive sample's edge fall, and the negative sample's grounded zero-speed displacement.  Its output must exactly reproduce [`results/paired_receipt.txt`](results/paired_receipt.txt).

The result is finite evidence for these two suffixes, not an exhaustive analog-input theorem or a controller-only proof of the shortened pre-Area-3 travel.  The formal arithmetic and source/collision bounds are in [`EyerokControllerReachability.v`](../../proofs/EyerokControllerReachability.v).
