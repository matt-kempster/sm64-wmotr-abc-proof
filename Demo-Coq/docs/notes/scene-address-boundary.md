# Scene builders expose the address-representation boundary

The gameplay verdict remains **OPEN**. `DemoSceneAddressBoundary.v` diagnoses
the current ordinary-Clight representation at actual generated scene-builder
loads. It proves neither that retail scene loading fails nor that a demo
cannot desync. In particular, a stuck model must not produce a vacuous
all-reachable-gameplay safety verdict.

The actual generated `process_geo_layout` calls `segmented_to_virtual` on its
geometry operand and stores the returned value in `gGeoLayoutCommand`. Its
loop reads that command pointer into temporary `t'3`, then `t'4` loads the
opcode byte at pointer plus zero. US/JP source selectors check the actual
helper call, result store and opcode-load statements.

The existing complete helper theorem executes `segmented_to_virtual` for a
numeric `Vint` argument under an explicit segment-table read. Its KSEG result
is another `Vint`, and its high bit makes it nonzero. Ordinary 32-bit Clight
allows the generated pointer-plus-zero arithmetic on that numeric value, but
the subsequent `Ederef` requires a `Vptr`. The new theorem shows that this
actual opcode-load state has no original `step2` successor when its pointer
temporary is numeric.

The actual generated `load_area_terrain` first copies the data parameter to a
local pointer cell. In its loop it loads that pointer into temporary `t'10`,
then `t'11` dereferences it to obtain the first terrain type. A second checked
selector ties the diagnostic to that real US/JP statement. If that temporary
contains the numeric relocated terrain address, the actual load state has
no original `step2` successor either.

Keeping a source relocation as a symbolic `Vptr` does not solve the preceding
helper call: the existing complete helper impossibility theorem shows that
its actual pointer-to-integer cast retains `Vptr`, after which the segment
index bit shift cannot evaluate. These are distinct boundaries: symbolic
operand arithmetic fails in the helper; numeric result dereference fails in
the builders. The module does not assert impossibility of every complete
builder call for arbitrary environments and memories, or claim a boot trace
reaches these local states.

A source/native correspondence must explain active image/segment epochs,
authenticated numerical operands, their represented source allocations and
offsets, and the crossings needed for bit arithmetic, data loads, stores and
indirect callbacks. Numerical words and symbolic pointers cannot simply be
required to inhabit the same ordinary-Clight word cell: on this target
`Mptr` and `Mint32` are the same chunk, while `Vint` and `Vptr` are different
values. An encode/decode metadata view or a round-trip lemma is useful
evidence, but does not itself change Clight dereferencing or establish an
execution simulation. A nonvacuous authentic boot-to-gameplay correspondence
and full observation/producer/scene coverage remain required.

No conditional completed-scene receipt was added to conceal this obstruction.
The owner-independent area snapshot remains a separate raw memory observation;
it cannot establish materialization, lifetime or level ownership.

The diagnostic aggregate is `demo_scene_address_boundary_claim_us_jp`, proved
by `generated_scene_address_boundary_us_jp`. Its conclusions are the selected
actual loads and local original-Clight failures, rather than gameplay safety.
