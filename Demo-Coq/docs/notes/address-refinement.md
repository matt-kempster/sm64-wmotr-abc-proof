# Existing address results and the remaining runtime bridge

The Demo-Coq gameplay verdict remains **OPEN**. A read-only audit found a
proved local numeric-address execution in Pedro-Coq, alongside a stronger
proof of the symbolic-pointer obstruction. Neither establishes the missing
boot-to-gameplay representation bridge. The helper is executable on its
numeric input domain; it is not executable on the symbolic `Vptr` input
domain under the ordinary CompCert semantics.

## Existing results that can be reused

Both projects pin revision `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Read-only comparison confirmed that their generated US helper definitions
match exactly, and likewise their JP definitions. The following references
are existing Pedro results; no Pedro report or proof was changed for this
audit.

- [N64AddressRefinement.v](../../../Pedro-Coq/proofs/N64AddressRefinement.v),
  line 54: `generated_segmented_numeric_execution_us_jp` constructs a complete
  execution of the original generated `segmented_to_virtual`, given a
  numeric `Vint` argument and the actual segment-table cell's value. It returns
  a numeric `Vint` address, with trace `E0` and unchanged memory. Its arithmetic
  uses the real top-byte segment index, low 24-bit offset, segment-table base
  and KSEG0 bit.
- The same file, lines 262 and 350: `n64_dust_address_round_trip` and
  `generated_n64_dust_conversion_us_jp` explicitly decode the numeric result
  into one of three bounded dust-script blocks and offsets. The decoder is
  visible in the statement; it is not an ordinary Clight dereference rule.
- The same file, line 390: `n64_dust_scalar_word_injection` transports a scalar
  word load into a flat CompCert RAM block under a supplied `Mem.inject`
  relation and block placement. It explicitly excludes pointer-relocation
  words from that scalar theorem.
- [N64DustImage.v](../../../Pedro-Coq/proofs/N64DustImage.v), line 76:
  `retail_n64_dust_words_refine_generated` checks the full finite script-word
  transcription, including named relocation words. The companion
  [checker](../../../Pedro-Coq/pipeline/check-n64-dust-addresses.py) authenticates
  the ROMs outside Coq. This is finite image evidence, not callback-code
  execution semantics.
- [N64AllocationHeader.v](../../../Pedro-Coq/proofs/N64AllocationHeader.v),
  line 79: `generated_n64_dust_header_refinement_us_jp` composes numeric
  conversion, explicit decoding and the two real leading allocator
  statements. The representation change remains explicit between executions.
- [DustAllocationBoundary.v](../../../Pedro-Coq/proofs/DustAllocationBoundary.v),
  line 20: `generated_segmented_call_cannot_execute_from_symbolic_pointer_us_jp`
  proves that the complete original helper has no ordinary terminating
  `eval_funcall` on a `Vptr` argument. Its proof uses
  `segment_index_expression_cannot_eval_from_vptr` in
  [SegmentedPointerBoundary.v](../../../Pedro-Coq/proofs/SegmentedPointerBoundary.v),
  line 91.

The numeric helper proof is suitable for a small Demo-specific adaptation
against Demo's own generated functions. Directly importing the Pedro module
would also import its project namespace and allocation/action dependencies;
the present Demo pipeline does not configure that namespace. Replaying the
small exact-body proof requires no new semantics, source flags or axioms.
The dust-specific placement and decoder theorems are useful examples, but
their three behavior-script regions are not the demo level-script domain.

That Demo-specific adaptation is now implemented in
[`DemoNumericAddressExecution.v`](../../proofs/DemoNumericAddressExecution.v),
including both the complete numeric execution and complete `Vptr` call
impossibility. See [numeric-address-execution.md](numeric-address-execution.md).
The new authenticated finite demo script/relocation image is described in
[script-numeric-image.md](script-numeric-image.md). These results sharpen the
remaining representation-simulation obligation; they do not discharge it.

## Why linking and ordinary memory injection do not finish it

The installed CompCert 3.15 sources make the representation distinction
concrete:

| Operation | Verified rule in the installed source |
| --- | --- |
| `Globalenvs.store_init_data`, line 618 | `Init_addrof` resolves its symbol and stores a `Vptr`, at lines 626–629. |
| `Values.Val.inject`, line 2318 | Its pointer constructor maps `Vptr` to `Vptr`, at lines 2327–2331; it has no `Vptr`-to-`Vint` case. |
| `Clight.eval_Ederef`, line 418 | Dereference requires an expression evaluated to `Vptr block offset`. |
| `Globalenvs.find_funct`, line 198 | Function resolution accepts a `Vptr` with zero offset; a `Vint` is rejected. |

Thus the positive numeric helper result cannot simply resume the original
symbolic caller. Script relocation loads, stored pointers, subsequent
dereferences and native callback calls need a representation relation and
execution simulation that preserves their actual meaning. A scalar-memory
injection alone supplies no such pointer-to-integer conversion.

Existing SSL infrastructure does not assert that missing simulation:

- [ClightLinkExecution.v](../../../SSL-Coq/less-than-one-a-press/proofs/ClightLinkExecution.v),
  line 79, `official_link_resolves_internal_globalenv` proves actual Internal
  callee resolution after a successful official link. It preserves the
  symbolic-pointer representation.
- [ClightGlobalMemoryRefinement.v](../../../SSL-Coq/less-than-one-a-press/proofs/ClightGlobalMemoryRefinement.v),
  line 208, `matched_program_initial_memory_is_relocation_aware` covers
  CompCert initialization and relocation-aware memory injection between
  matched source programs. It does not replace relocations with numerical
  retail addresses.
- [ClightEndToEndRefinement.v](../../../SSL-Coq/less-than-one-a-press/proofs/ClightEndToEndRefinement.v),
  line 444, `clight_lockstep_components_forward_simulation` is a composition
  theorem requiring its explicit initial/final/step simulation components.
  The file does not instantiate them for numerical N64 addresses or hardware.

The old `SSL-Coq/old-proofs/demo-warp` project supplies conditional
physical-pool arithmetic in `NormalInitialization.v` and DMA `storebytes`
frame contracts in `HardwareContracts.v`. Its own claim document distinguishes
these records and contracts from generated initialization execution. Its
different source pin and US-only scope also require fresh source checks.
The repository's narrow retail-MIPS instruction/store manifests do not supply
a whole-console ISA or normal-boot simulation.

## Exact remaining work

No already proved whole-boot numerical-address or matching-binary execution
bridge was found in the audited repository or installed proof environment.
Ubuntu has the `sm64-item-proof` switch and the configured CompCert PowerPC
backend; the installed package inventory contains no separate MIPS semantics
framework. The emulator and authenticated finite observations remain useful
evidence, not a kernel-checked replacement for that bridge.

The full route still needs an authenticated numerical image for the relevant
level scripts, relocation words and callback targets; actual loader/segment
base invariants; a justified relation across numeric and symbolic values and
memories; and caller, load, store and indirect-call simulation through the
representation changes. Hardware/external effects and the global gameplay
invariant remain separate obligations. These are gaps in the current proof
connection to the game, not evidence that the gameplay claim is false or
that it cannot be proved.
