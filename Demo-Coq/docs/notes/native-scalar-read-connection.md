# The first scene reads: a bounded source/native connection

The gameplay verdict remains **OPEN** and the primary specification checklist
item remains partial and unchecked. This work addresses its existing address
execution gap. It does not complete a scene builder or identify a loaded level.

## What is connected

The actual generated US/JP `process_geo_layout` first opcode expression and
`load_area_terrain` first type expression are selected from their original
`Sset` statements. They read an unsigned byte and signed halfword respectively.
`DemoConcreteExpression.v` evaluates these unchanged expressions using a
separate candidate numeric-address evaluator and actual flat CompCert RAM.
This evaluator is **not** ordinary `Clight.eval_expr` or a new `Clight.step2`
rule. Its scalar fragment has a one-way ordinary-Clight soundness theorem;
numeric dereference does not thereby acquire an ordinary-Clight derivation.

`DemoNativeAddressMachine.v` fetches an actual instruction word from that same
RAM, decodes its load operation and performs the actual typed RAM load. It uses
64-bit GPRs, a hardwired zero register, a sign-extended immediate, 64-bit effective
address addition and sign-extended word results. Canonical bases, no signed32
address overflow and a canonical KSEG0 result restrict its domain. Its successful
load projection follows the [NEC VR4300 manual](https://datasheets.chipdb.org/NEC/Vr-Series/Vr43xx/U10504EJ7V0UMJ1.pdf),
printed pages 134/137 for address formation/mapping and 440/450/458 for LBU/LH/LW.
Big-endian kernel RAM, coherent caches and absence of an intervening hardware
event are scope conditions; their retail adequacy remains unproved.

The connected native sites are the actual `LBU t4,0(t3)` at `0x8037e150` and
`LH t7,0(t6)` at `0x803833fc`, in both versions. The site corollaries require
these exact PCs, actual code fetches, the matching source temporary/native GPR
and sequential pending next PC. They derive the selected source-expression
result, native load step, destination value, unchanged RAM and exact next PC.
This is a single-load connection in the explicitly limited projection, **not**
a whole-language simulation or a proof of VR4300 hardware semantics.

`DemoConcreteScalarRange.v` discharges a bare scalar-load-success premise from
equal actual `Mem.loadbytes` ranges, with explicit extent and alignment. Only
the selected byte/halfword range must be pure bytes. Other words of a symbolic
source initializer may still contain pointer fragments. The whole-image
transport in `DemoConcreteMemoryTransport.v` remains separately limited to pure
byte images; symbolic pointer encodings cannot silently satisfy that premise.
Neither range relation derives image placement, activation or ownership.

`DemoNativeReadWitness.v` constructs local 4 MiB RAM with code/data stores and
proves positive instruction fetch, data read, selected expression evaluation
and native step for both sites and versions. The data is explicitly placed at
`0x80001000`. These are hand-constructed local witnesses, not normal-boot,
authentic loaded-asset, or boot-to-gameplay witnesses.

## External finite authentication

`pipeline/check-native-address-images.py` checks canonical US/JP ROM SHA-1 and
SHA-256, equality with the existing matching-build ROM, ELF section bytes and
complete disassembly words. It uses each routine's actual main or engine
segment mapping. The authenticated ranges contain 22 helper words, 58 geometry
caller words and 123 terrain caller words per version; authentication does not
execute those complete ranges. It also checks the 33-entry geometry dispatch
table, without executing its indirect callbacks.

The existing script-image checker first authenticates the seven selected
source entries and relocations. Every selected geometry symbol is checked in
full against ROM/ELF bytes; every terrain symbol is checked in full against
its local ELF and the canonical ROM's MIO0 output. Only hashes, placements and
the first scalar values are exported. All nine selected areas per version have
first geometry opcode 8 and terrain halfword 64. Those shared scalar values
**cannot distinguish which level is loaded**.

The receipt is `native-address-images.json`; `DemoNativeAddressImages.v` is its
mechanically checked small transcription. The finite source/fixture agreement
connects its operand words to the existing nine generated source descriptors.
No ROM, complete asset, or recorded demo sequence is published.

## What remains on the same original obligation

- Execute and connect the complete helper/caller path, including real stack
  effects, calls and delay slots. The first terrain read follows the real
  `clear_static_surfaces` call; the current connection starts after its return.
- Justify the candidate numeric language and partial ISA projection against
  the actual whole source/native execution, including indirect callback dispatch.
- Establish authentic code/data loading, active segment/image epochs, asset
  extents, processed geometry/collision ownership and preservation under reuse.
- Complete input-use/producer coverage, permitted normal starts and adequate
  SDK/hardware events; exhibit an authentic boot-to-gameplay history.
- Prove the full no-mismatch invariant, or establish a normally reachable
  authenticated mismatch at the same gameplay observation boundary.

No major unchecked obligation is closed. The change replaces decoder lookup
alone with a positive, bounded expression/native-load connection under precise
memory and state premises. It does not promote that local result to gameplay.
