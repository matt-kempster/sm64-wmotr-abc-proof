# Controller loop tail and player-three copies

`proofs/DemoControllerCopyExecution.v` executes two actual subtrees of
`read_controller_inputs`. The selectors are checked nonempty and equal
between the generated US and JP functions. The aggregate is
`demo_controller_copy_execution_claim`, proved by
`generated_controller_copy_execution_us_jp`.

`generated_disconnected_second_controller_executes` starts at the second
controller's real `controllerData` load and null decision. With the actual
controller pointer at array offset 28 and a null data field at offset 52,
it executes the disconnected branch's seven zero stores: two raw axes,
two button fields and three analog fields. The proof preserves the loop
index and controller temporary. Its memory frame protects every byte
outside controller-array offsets 28 through 47, and it preserves all
initial valid accesses and valid blocks.

`generated_player_three_copy_executes` executes the complete real suffix
that copies player one's seven input fields to player three. The pointer
cells must resolve to controller-array offsets 0 and 56, and must be
separate from that array block. The theorem accepts arbitrary readable
raw axes, float analog values and button values; it proves those exact
values in the destination, unchanged loop/controller temporaries, all
initial valid accesses and blocks, and a byte frame outside offsets 56
through 75. Narrow integer normalization follows from the actual source
loads rather than an extra bound on the supplied integers.

These are seven typed field stores in each subtree. The generated code
contains no structure `memcpy` or `storebytes` operation here. The proved
`Mem.unchanged_on` byte frames also support the exported typed-load and
`Mem.loadbytes` preservation lemmas. In particular, player one's entire
controller record lies outside both write intervals. Stream or level
reads are protected when their actual byte ranges avoid those intervals;
the theorem does not silently assume a whole-game frame property.

The remaining caller work includes the first controller's arbitrary-stick
analog call, actual loop increments and tests, and composition with these
two subtrees. Layout, symbol, pointer-cell, readability and writability
premises remain explicit. Hardware polling, reachable post-polling memory,
boot and all later gameplay frames remain outside this local result.
Consequently the full gameplay no-desync claim remains open.

The full staged module passed the established Ubuntu WSL pipeline with
Coq 8.16.1 and CompCert 3.15. The promoted source is byte-identical to that
checked source; project-wide build, audit and kernel checks are recorded
by the checkpoint.
