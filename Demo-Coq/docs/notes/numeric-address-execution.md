# Numeric execution of the actual address helper

The gameplay claim remains **OPEN**. `DemoNumericAddressExecution.v` now proves
both sides of the address-domain distinction directly against Demo-Coq's own
generated US/JP functions. It adapts the existing exact-body Pedro proofs
without importing the Pedro project or changing source flags or semantics.

`generated_demo_numeric_segment_execution_us_jp` constructs the complete
`segmented_to_virtual` function call on a numeric `Vint address`. It reads the
actual `sSegmentTable` cell indexed by the high address byte, adds the low
24-bit offset to that base, applies the KSEG0 bit, and returns the resulting
numeric `Vint` address. Trace and memory are unchanged. The theorem constructs
function entry, every body statement, return conversion and stack cleanup.
Its remaining premises are the actual segment-table symbol and readable cell;
it does not assume that the callee execution already exists.

`generated_demo_segmented_call_cannot_execute_symbolic_pointer` proves that
the complete original helper has no ordinary terminating `eval_funcall` on
any symbolic `Vptr` argument. It inverts the real function entry and first
statement: the pointer-to-unsigned cast preserves the `Vptr`, and the next
integer shift has no semantic result. The US and JP helper definitions are
checked identical, so both complete-call results apply to both versions.

These results are combined in
`demo_numeric_address_execution_boundary_claim_us_jp`, proved by
`generated_demo_numeric_address_execution_boundary_us_jp`. Numeric local
execution is valid; the symbolic input-domain obstruction is also valid.
Neither is a reachable gameplay counterexample or a global no-desync theorem.

The numeric result remains a `Vint`. Ordinary Clight dereferences and function
resolution require `Vptr` values, so this theorem does not silently resume a
symbolic caller at the numerical result. The finite image and explicit word
representation are described in [script-numeric-image.md](script-numeric-image.md).
The remaining caller/memory/indirect-call simulation and boot connection are
recorded in [address-refinement.md](address-refinement.md).
