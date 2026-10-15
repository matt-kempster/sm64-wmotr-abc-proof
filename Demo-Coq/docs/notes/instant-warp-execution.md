# Complete instant-warp calls with no table or no floor

The full gameplay no-desync verdict remains **OPEN**. This result executes
one more actual routine in the normal-frame interval. It does not prove
the table's initialization/preservation, the loaded level's authenticity,
or all object/HUD/camera effects.

`DemoInstantWarpExecution.v` proves
`generated_demo_instant_warp_execution_us_jp`. It constructs complete
internal calls of each actual US and JP `check_instant_warp` function,
including function entry, its generated control flow, return and cleanup.
Both paths below have an empty trace and exactly unchanged memory; no
callee execution or preservation premise is used.

- **Null instant-warp table:** the actual current level differs from
  castle level 6, the real Mario floor pointer is readable and valid, the
  real surface type is readable, and the current area's real
  `instantWarps` pointer is null. The proof covers every readable surface
  type. It executes the actual subtraction by 27 and both index-range
  comparisons. An out-of-range index rejects immediately; an in-range
  index loads the real null table and rejects. None of the warp-body
  stores, displacement calculations or camera/area calls runs.
- **Null floor:** with the same non-castle level condition, the real Mario
  floor-pointer load returns null. The function skips without reading a
  surface, area pointer or instant-warp table.

The non-castle condition is necessary for this particular execution
boundary: level 6 has an earlier save-file/star-count query and optional
early return. That different route is not silently assumed harmless.
Authentic demo-header/loaded-level facts must instantiate the condition
when this theorem is composed into gameplay.

The explicit memory/layout premises use `gCurrLevelNum`, `gMarioState`,
Mario's floor field at byte 104, `Surface.type` at byte zero,
`gCurrentArea`, and `Area.instantWarps` at byte 28. The full US and JP
function bodies are not treated as identical; the finite version selector
chooses each actual generated function and the proof executes both
separately.

This is a consumer of a null-table invariant. Constructing null tables in
actual areas and preserving them through script initialization and the
reached frame callees remains separate. Alongside the existing
zero-destination `warp_area` call, null-table painting body and pending
demo delayed dispatcher, it narrows the remaining frame interval to
precise initialization, aliasing and object/HUD/camera/UI obligations.

The cleaned staged module passed the existing Ubuntu WSL targeted audit
pipeline with Coq 8.16.1 and CompCert 3.15 in `sm64-item-proof`, retaining
the established memory cap. The registered capstone's final audits and
assumptions are recorded in the main report.
