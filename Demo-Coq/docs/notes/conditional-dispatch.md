# Executed equality dispatch and the address-model boundary

The full gameplay claim remains **OPEN**. `DemoConditionalDispatchExecution.v`
adds actual generated execution for the equality helper and a nonmatching
conditional jump, and mechanically checks an obstruction to interpreting
symbolic script relocations as numerical N64 addresses.

The complete `eval_script_op(OP_EQ, argument)` function call is executed for
both generated configurations. It reads `sRegister`, executes the real switch
case for operator 2, returns the integer Boolean for register/argument
equality, and leaves memory unchanged. Its function entry and return are
constructed; no callee execution is assumed.

For a nonmatching equality arm, the complete generated `level_cmd_jump_if`
body reads the command's operator and comparison argument, invokes that
proved helper, takes the actual false branch and advances `sCurrentCmd` by
12 bytes. The theorem accepts an arbitrary command pointer offset, permitting
later composition across consecutive arms. Under its explicit symbol,
layout, read, write and block-separation premises, it preserves the script
register and every load from the command's script block. It does not prove
that opcode dispatch reaches this command, construct those memory values
from an initializer, or execute a taken jump.

The taken branch calls `segmented_to_virtual`. Its real first generated
expression is checked to be the pointer-to-unsigned-integer cast of `addr`,
followed by a right shift of 24. For a symbolic CompCert pointer
`Vptr block offset`, the mechanical result is:

- That cast returns the same `Vptr block offset` value.
- `Cop.sem_binary_operation` for the following unsigned right shift returns
  `None` on that value.

The theorem checks the actual first-expression subtree in both generated
`segmented_to_virtual` bodies and the corresponding CompCert operations. It
does not assert that N64 hardware fails to execute the C code. A symbolic
CompCert block pointer carries no numerical retail address from which the
segment bits can be recovered by that operation. Ordinary generated
`Init_addrof` relocations therefore cannot simply be treated as numerical N64
addresses and passed through this expression without an address/memory
refinement. Values already represented as numerical integers are outside
this particular `Vptr` obstruction theorem.

Accordingly, a premise saying that the actual helper maps an arbitrary
symbolic relocation to an arbitrary target block pointer would conceal a
potentially unsatisfiable condition. This work introduces no such premise.
Resolving the boot-to-runtime bridge requires an appropriate numerical
address representation and a justified correspondence with the retail
program, in addition to the remaining reachability and gameplay invariants.
This finding is a proof-model limitation, not a reachable demo mismatch.

An existing result in `Pedro-Coq/proofs/N64AddressRefinement.v`,
`generated_segmented_numeric_execution_us_jp`, already executes the original
helper on a **numeric `Vint` address** and returns its numeric virtual address,
preserving memory. Its dust-script decoder and scalar-word injection lemmas
also provide localized address-refinement work. That existing result confirms
that the helper is not uniformly unexecutable: the obstruction above is
specifically about supplying an unrefined symbolic `Vptr` relocation.
The Pedro development explicitly leaves pointer-relocation representation
and ordinary caller/callee composition open. Its three dust-script decoder
does not establish the seven demo level-script route or the whole gameplay
memory correspondence. Demo needs the corresponding justified simulation;
the numeric helper lemma alone cannot turn a numeric return value into a
dereferenceable symbolic script pointer.

The aggregate boundary is
`demo_conditional_dispatch_execution_boundary_claim_us_jp`, proved by
`generated_demo_conditional_dispatch_execution_boundary_us_jp`. The finite
header-to-script certificate remains separate; see
[script-dispatch.md](script-dispatch.md).
