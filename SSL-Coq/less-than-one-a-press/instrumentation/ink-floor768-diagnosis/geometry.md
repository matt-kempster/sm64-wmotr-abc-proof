# Loaded-mesh explanation of the two producer queries

This companion to the native query trace extracts loaded surfaces from Wafel JP
and evaluates the source floor-selection predicates. It replays two existing
supplied histories; it does not add a gameplay route or a new height search.
The two histories have exactly the same loaded top mesh at producer phase 130.
Extraction occurs after that update, when the top timer reads 131; reading the
mesh before the update would instead inspect the previous phase's mesh.

The native trace supplies these actual **pre-interaction** query coordinates.
The decimal trace values round back to the exact binary32 values preserved in
`geometry-probes.json`. Evaluations below use signed-16 truncated coordinates,
the native surface-list order, and binary32 rounding after each source arithmetic
operation. All vertices, plane coefficients, edge predicates and ordered lists
are retained in `geometry-native-results.json.gz`.

| Query | Signed query XYZ | Top triangle / height | Height minus 78 | Result |
|---|---|---|---|---|
| Successful Buddy history | (-2140, 1830, -1115) | 963 / 1909.11376953125 | 1831.11376953125 | Top rejected by 1.11376953125; static triangle 473 supplies 768 |
| Failed retimed history | (-2168, 1889, -1036) | 964 / 1933.4923095703125 | 1855.4923095703125 | Top accepted by 33.5076904296875; static triangle 600 below it is 1280 |

The raw successful XYZ is
`(-2140.031982421875, 1830.177978515625, -1115.0291748046875)`.
The raw failed XYZ is
`(-2168.8564453125, 1889.0369873046875, -1036.69287109375)`.
The failed history still has the platform reference before this update, so its
saved boundary position `(-2140.712646484375, 1889.0369873046875,
-1102.0850830078125)` is moved before the native geometry query. That saved
position must not be substituted for the actual query position.

This also explains why merely rejecting the top is insufficient for the failed
history. At its actual initial query X/Z, the static floor is 1280, outside the
768 pad. The successful history starts its geometry query over the 768 pad,
rejects the top, and only then gets shoved elsewhere. The failed history gets
shoved over the pad after its initial cache has already selected the top.
The native trace documents why its stopped quarter step retains that old cache.

At the successful post-shove point
`(-2210.062255859375, 1830.177978515625, -1075.10888671875)`, the source query
selects static triangle 599 at 1280. At the failed post-shove point
`(-2104.462890625, 1889.0369873046875, -988.58447265625)`, it selects triangle
473 at 768. These are fresh query answers at those positions, not statements
that the cached floor field has changed. Their inversion is consistent with
the native stopped-step trace.

## Fixed-mesh sensitivity checks, not replay edits

These extra probes only change numbers passed to the read-only source-derived
evaluator. They do not change Mario in the replay or establish neighboring
successful histories.

- At the successful query's fixed X/Z, adding 1 to raw Y still rejects the top
  (integer Y 1831); adding 2 accepts it (integer Y 1832). In this local positive
  Y domain, the exact raw cutoff for this top triangle is 1832 because the query
  truncates Y before comparing it. This is not a global setup-height bound.
- At the failed query's fixed X/Z, subtracting 33 still selects the top (integer
  Y 1856). Subtracting 34 or 35 rejects it (integer Y 1855 or 1854), but returns
  static 1280 rather than 768.
- Evaluating the failed history's saved position before platform carry, with
  its unchanged Y, selects top height 1920.5714111328125. Thus this purely
  geometric counterfactual also does not by itself supply 768. It is not a
  replay with the platform removed.

The pad triangle 473 has vertices `(-1945,768,-921)`,
`(-2149,768,-1125)`, and `(-2149,768,-921)`. The successful query is inside it;
the failed initial query is outside it. Triangle indices are from this
deterministic runtime surface allocation, not permanent retail object IDs.

## Reproduction and scope

From `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-floor768-diagnosis/geometry.py --verify instrumentation/ink-floor768-diagnosis/geometry-results.json.gz
& build/wafel-pilot/python/python.exe instrumentation/ink-floor768-diagnosis/geometry.py --extra-probes instrumentation/ink-floor768-diagnosis/geometry-probes.json --verify instrumentation/ink-floor768-diagnosis/geometry-native-results.json.gz
```

Each invocation independently reconstructs both histories from two fresh roots
and compares their full snapshots and extracted geometry. No broad search is
run. Existing fake-pickup, high HOLP, initial airborne Mario and actor-position
cuts remain supplied; the numerical diagnostic adds no state writes.
Native events and all existing post-preparation cuts are retained. Preparatory
cuts remain documented in the imported isolation/replacement packages.

Work started from proof revision
`510ab2d31a625676c1ef7b3769892efd5ac8ffc6`; source behavior uses the applicable JP
pin `9921382a68bb0c865e5e45eb594d9c64db59b1af` in local decompile revision
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Runtime is Wafel 0.8.5 / Python
3.9.13. Runtime and exact local surface-collision-source SHA-256 hashes are in
both result files. The original-JP query trace is separate evidence; these
surface and sensitivity checks are native Wafel extraction plus source-derived
numerical evaluation, without a new Coq theorem.
