# Rank 9 static ledge-and-landing diagnostic

Run from `SSL-Coq/less-than-one-a-press`:

```sh
node instrumentation/rank9-upper-star-dance/check.js
```

The script only reads the pinned static pyramid mesh. It reconstructs
surface normals, cell membership, source-order wall lists and first-vertex
sorted floor/ceiling lists, then evaluates a particular falling-star catch.
It checks the preceding geometry-input walls, first quarter, and next landing,
including all 50 successful integer entry heights in the tested 201-height
range. Low/high and disabled-ledge controls must fail to catch.

This is not an emulator, controller movie, live-memory receipt, or proof of
clean reachability. Dynamic surfaces and other frame effects are not supplied;
`sqrtf` is an unverified host-math approximation followed by Float32 rounding.
No game state, executable, or process is edited or accessed. See the
[proof note](../../docs/notes/rank9-upper-star-dance.md) for the separately
checked Coq fragments and the exact remaining route obligations.
