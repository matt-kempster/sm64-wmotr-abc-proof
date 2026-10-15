# Area reset from the actual unit's initial memory

`proofs/DemoAreaInitialMemory.v` proves
`generated_area_initial_memory_executes_clear_areas_us_jp`, with claim
`demo_area_initial_memory_execution_claim`. For each actual generated US
or JP area unit, it constructs an initial memory, resolves the real
`clear_areas` function, and executes its complete verified internal call.
There is no caller-supplied initial-memory-existence, layout, symbol,
block-separation, pointer-read, writability or range premise in this final
theorem.

The proof checks the actual global names for uniqueness and checks the
actual initializer metadata for alignment and declared relocation
targets. Standard CompCert `Genv.init_mem_exists` then gives the initial
memory. It does not compute the memory or run a large computation over
generated function bodies. Indexed source receipts select the actual
global declarations; their indices are checked by Coq against both
generated versions.

CompCert's initial-memory characterization supplies the real writable
480-byte `gAreaData` allocation, current-area and transition accesses,
and the writable spawn object. The actual `gMarioSpawnInfo` initializer
points to `gPlayerSpawnInfos[0]`, a writable 32-byte object. Global-symbol
injectivity gives every separation needed by the
[complete initializer](area-initialization.md). The proof composes those
resources with its checked generated-layout corollary.

The resulting call has empty trace, leaves `gCurrentArea` null, and leaves
both painting-warp and instant-warp pointers null in all eight real Area
records. Its exact memory frame preserves loads outside the area-array,
current-area-pointer, transition and spawn blocks.

This theorem uses `Clight.globalenv us_area.prog` or the corresponding JP
unit environment and that unit's actual initializer image. The complete
linked game environment, its boot execution, compatibility with the
authenticated retail memory image, subsequent script/area selection,
and preservation during gameplay remain separate obligations. Other
translation units are still represented by their declarations in this
unit image. The full gameplay no-desync verdict remains open.

The staged leaf passed the existing Ubuntu pipeline with Coq 8.16.1 and
CompCert 3.15 in 3.6 seconds after the already checked initializer
dependency. The promoted source is byte-identical to that green file and
ends in one LF. Registered build, assumptions and kernel validation are
recorded by the project checkpoint.
