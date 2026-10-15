# Actual area initialization and empty warp tables

`proofs/DemoAreaInitialization.v` proves the complete generated
`clear_areas` internal call for US and JP. It executes the initial stores
to `gCurrentArea`, the transition flags and the spawn area index, then all
eight iterations of the actual generated area-reset loop. The 152 loop
stores are checked against the generated body; they are store receipts
used to build the execution proof, rather than a substitute game model.

After this call, `gCurrentArea` is null and each of the eight real
60-byte Area records has a null painting-warp pointer at offset 24 and a
null instant-warp pointer at offset 28. The call has empty trace. Every
load outside the actual area-array, current-area-pointer, transition and
spawn blocks is unchanged.

The generated Area member list and size, SpawnInfo.areaIndex offset 12,
and WarpTransition active/pause offsets 0 and 3 are proved from the actual
US/JP composite definitions. The layout execution corollary
`generated_clear_areas_executes_with_checked_layout` constructs the layout
witness under the selected generated program's composite-environment
equality, removing the free layout-record argument from that corollary.
`generated_demo_area_initialization_us_jp` proves the aggregate
`demo_area_initialization_claim_us_jp`.

The generic execution theorem's entry premises are concrete symbol resolution, separation
of the written objects, the real `gMarioSpawnInfo` pointer read, writable
accesses for the initial fields, and the writable 480-byte area-array
range. The [actual unit initial-memory composition](area-initial-memory.md)
now discharges all of these for the selected generated area unit, and
proves that its initial memory exists. Linking that unit environment and
initial-memory image into the complete game's boot execution remains
separate work.

This supplies the actual reset producer for the
[instant-warp null-table execution](instant-warp-execution.md) and
[painting-warp null-table execution](gameplay-boundary.md). Subsequent
area selection and script commands still need to connect this producer to
those consumers and preserve the relevant table contents. The call alone
does not establish boot reachability, an invariant across gameplay, or the
full no-desync claim. That gameplay verdict remains open.

The complete staged module passed the existing Ubuntu pipeline with Coq
8.16.1 and CompCert 3.15, retaining the established memory limit. It took
223.9 seconds. The registered checkpoint records its aggregate audit and
kernel validation.
