# Source-owned AREA and terrain declarations

`DemoSceneSourceInventory.v` is a source inventory intended to support the runtime loaded-scene receipt. It obtains the owner key from the checked generated level-dispatch route, resolves that route's actual entry initializer among the seven selected level units, then parses the complete initializer at command boundaries. Input demo headers and filenames do not determine the owner.

The command parser checks each opcode, command length, four-byte alignment and initializer word form. Its soundness theorem produces a full command partition and exact initializer prefix/suffix witnesses. The AREA parser rejects nested AREA commands, terrain declarations outside an AREA, repeated terrain within an AREA, unmatched END_AREA and unterminated AREA blocks. It records the raw AREA geometry relocation and the terrain relocation within the corresponding AREA/END_AREA scope. General soundness exposes the original relocation words at their parsed command positions.

The selected scope has nine areas per version: BBH1, CCM1/2, HMC1, JRB1/2, WF1, PSS1 and Bowser1 arena1. The independent owner keys are 4, 5, 7, 12, 24, 27 and 30. In particular, owner30 resolves to the Bowser1 entry through the actual dispatch; it is not inferred from the historical name of a demo file. The finite result enumerates all AREA scopes in each complete selected entry initializer, with the exact raw geometry and terrain identifiers and byte offsets. Owner17 is outside this selected source inventory.

`scene_source_area_checked us descriptor` supplies the source premise for a future runtime correspondence; no completed runtime scene receipt has been established. Its soundness theorem exposes the actual checked dispatch route, selected entry initializer, complete command partition, enclosing declaration scope and exact command locations. `scene_source_geo_symbol` denotes raw geometry script input. It is not identified with the allocated processed geometry root. The terrain symbol likewise requires the actual segmented conversion and load path before it identifies materialized collision data.

This inventory does not prove source-image placement, runtime command activation, execution of helper scripts, successful geometry processing or collision construction, scene lifecycle ownership, preservation through gameplay, or that every playable scene belongs to the selected seven entries. These remain explicit obligations in the loaded-scene and full gameplay specifications. Gameplay verdict: open.

The native operand fixture is mechanically regenerated and checked by
`pipeline/check-scene-source-images.py --check-coq proofs/DemoSceneSourceInventory.v`.
The existing script-images check first authenticates the complete script receipt
against the clean ROMs/matching ELF. The new check verifies generated hashes,
actual command operands and all 18 US/JP geometry/terrain pairs (nine per version).
For example, CCM area2 geometry is US234882552 versus JP234882536.
This establishes finite source/native-word metadata; runtime active images,
processed roots and construction/ownership are still unproved.

The October 22 [shared-script/callback source review](demo-instant-warp-installation-source-audit.md)
separately follows all 40 named selected root/helper arrays and reviews instant
table writers and area lifetime. It finds no hidden installer or inherited
table route. This is source evidence outside the Coq inventory; helper
execution and runtime ownership/preservation remain unproved.
