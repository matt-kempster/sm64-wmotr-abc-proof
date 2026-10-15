# Authenticated numeric script and callback images

The gameplay verdict remains **OPEN**. This result connects generated script
initializers to finite numerical images from authenticated US/JP retail ROMs.
It does not prove that a normal boot loads those images into a corresponding
runtime state or simulate their full execution.

The read-only `pipeline/check-script-images.py` checks each clean ROM's pinned
SHA-1 and requires its bytes to equal the existing matching ELF build's ROM.
The ELF supplies symbol/section placements. Every selected initializer word
is then checked against both the actual ROM slice and the ELF section bytes:
scalar words must match exactly, and relocation words must equal the referenced
symbol's numerical address plus the generated relocation offset, modulo 32
bits. Source pin and version are checked. Initializers stay within their
declared segments, and their placed ranges are checked disjoint within each
unit.

This covers nine complete script units per version: the main/shared script
unit and BBH, CCM, HMC, JRB, WF, PSS, Bowser 1 and BITDW units. All 88 nonempty
initializers in each version are checked, totaling 3016 US words and 3010 JP
words. BITDW is additional coverage: the US stream named `bitdw` has header
30, selecting Bowser 1, whereas the BITDW course is level 17. JP's demo table
omits that named stream; the image coverage deliberately includes both units.

The ELF does not export the static `script_exec_*` labels. Their placements
are derived only from the exact corresponding generated relocation operands
in an already placed initializer. The pointed-to initializer is then checked
in full against both images. This procedure follows the source relocation
graph; it does not search for arbitrary address occurrences or infer a level
from an asset filename. Placement maps remain per unit, preserving the scope
of private identifiers.

The checker also compares every byte in the three complete native callback
ranges `lvl_init_from_save_file`, `lvl_set_current_level` and
`lvl_init_or_update` between the matching ELF and authenticated main ROM.
It records addresses, extents and hashes. It does not prove MIPS instruction
semantics or equivalence of those callback bytes to their Clight functions.

The metadata receipt is [script-images.json](script-images.json). It contains
hashes, placements and extents, with no ROM files or recorded demo inputs.
Authentication and ELF symbol provenance remain outside Coq.

`DemoScriptNumericImage.v` kernel-checks complete numeric transcriptions of
the main script, level dispatch table and eight five-word `EXECUTE`/`RETURN`
scripts in each version, totaling 273 words per version. Its explicit
initializer-word relation preserves scalar words and represents each
`Init_addrof` word using the declared numeric placement plus offset. A small
Boolean checker uses `Int.eq`; a general soundness lemma lifts the result to
the full `Forall2` representation statement without expanding integer proof
records during computation.

The numeric dispatch decoder checks the complete `GET`/equality-jump/`EXIT`
table grammar and proves that each of the seven authenticated demo headers
selects the numeric address of its previously checked source dispatch script.
The capstone boundary is `demo_script_numeric_image_boundary_claim_us_jp`,
proved by `generated_demo_script_numeric_image_boundary_us_jp`.

The file also defines a visible symbol-address value relation between a
symbolic `Vptr` and its represented numeric `Vint`, under explicit symbol and
placement bindings. It proves that ordinary `Val.inject` cannot relate those
two value forms. This representation is not a new Clight dereference rule,
and no caller or whole-program simulation is asserted.

The selected level entries occupy overlay segment `0x0E`, at varying offsets.
PSS and Bowser 1 both enter at `0x0E000000`; for example, BBH instead enters
at `0x0E000418`. Equal numeric entry addresses do not identify which level
image is loaded. A runtime representation must therefore track the active
loaded segment/image as well as the numerical address. The remaining bridge
must establish actual loading and segment bases, preserve relocation and
callback meanings through calls/stores, and justify numeric-to-symbolic
observations before applying the local Clight executions. The ordinary
`Genv.find_funct` and dereference rules do not make a `Vint` executable or
dereferenceable merely because its address has been authenticated.

Recheck the finite images and Coq transcription with:

```sh
python3 pipeline/check-script-images.py \
  --check-receipt docs/notes/script-images.json \
  --check-coq proofs/DemoScriptNumericImage.v
```
