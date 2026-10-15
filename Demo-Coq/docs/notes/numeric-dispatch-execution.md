# Taken conditional dispatch and the next opcode

The gameplay verdict remains **open**. `DemoNumericDispatchExecution.v` executes
the complete generated `level_cmd_jump_if` body on its matching `OP_EQ` arm,
using both real generated callees: `eval_script_op` and
`segmented_to_virtual`. It reads the operator at command offset 2, the equality
argument at offset 4, and the numeric target word at offset 8. The actual segment
table load determines the helper's exact numeric result, which the actual caller
stores in `sCurrentCmd`. The theorem records that exact store and preservation
of loads from every other memory block. US and JP body equality is checked.
The module also discharges actual function entry, implicit void return and the
empty stack-freeing list, so the body result composes into a complete command
function call.

The theorem's premises name the actual source globals, resolved actual internal
callee bodies, command/register/table loads, matching equality result, and the
writable current-command cell. It assumes no whole callee execution. It does
require the target cell to contain numeric `Vint` data already. The authenticated
script image checks establish which retail words belong there; they have not
yet established a simulation that relates generated symbolic initial memory,
the active loaded overlay and this numeric caller state.

The following boundary is checked directly against generated code. The module
extracts the actual opcode field expression from `level_script_execute` in both
versions and proves it cannot evaluate if the command temporary contains the
numeric `Vint` just returned by the address helper. Ordinary Clight requires a
symbolic `Vptr` to dereference that struct. This is a limitation of the current
numeric/source representation composition, not a reachable game failure or a
proof of desynchronization. A justified active-overlay address simulation must
connect that numeric address to the loaded script block before the interpreter
can execute another opcode in the source proof.

The load-bearing boundary is named
`demo_numeric_dispatch_execution_boundary_claim_us_jp`, proved by
`generated_demo_numeric_dispatch_execution_boundary_us_jp`. This local result
shrinks the actual caller gap; it does not close normal boot, overlay loading,
later interpreter calls, or gameplay.
