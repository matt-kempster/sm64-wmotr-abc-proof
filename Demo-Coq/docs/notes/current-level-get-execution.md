# The dispatch table's actual current-level GET command

The full gameplay claim remains **OPEN**. `DemoCurrentLevelGetExecution.v`
executes the complete actual US/JP `level_cmd_get_or_set_var` function on
the dispatch table's `GET(VAR_CURR_LEVEL_NUM)` command. Its finite syntax
receipt checks the actual command word `0x3C040103` and actual jump-table
slot 60, identifying this generated function as its handler.

The execution reads the real command pointer, operator byte 1 and variable
byte 3 at command offsets 2 and 3, selects the actual GET switch arm, reads
signed `gCurrLevelNum`, and stores that value in `sRegister`. It then reads
the actual size byte 4 at offset 1 and advances `sCurrentCmd` by four bytes.
Function entry, implicit void return and empty stack cleanup are discharged,
so the result is a complete real `eval_funcall`, with no callee-execution
premise. The US and JP functions are checked identical after private-name
freshening.

Final register, command pointer and current-level reads are exact. The
two real stores preserve every initial valid access and every load outside
the register and command-pointer global blocks. Explicit premises remain
for the real symbol resolutions, command composite/size offset, readable
command and level values, writable cells and necessary block separation.
The existing generated command-layout witness gives a discharge path for
the layout premise; this theorem does not instantiate a reachable linked
environment or claim initial memory has already loaded these bytes.

This closes the command execution that carries the stored level into the
equality-dispatch register. It does not yet compose the whole interpreter
route from the title result, prove opcode dispatch reaches this handler,
resolve the active-overlay numeric/symbolic representation, or establish
the loaded gameplay invariant. The finite command and handler checks are
kept distinct from runtime reachability.

The staged body, full function call and syntax receipt passed the existing
Ubuntu WSL pipeline with Coq 8.16.1 and CompCert 3.15. Registered capstone
validation is recorded by the project checkpoint.
