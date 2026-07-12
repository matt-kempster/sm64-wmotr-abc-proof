# Claim and scope

## Pinned source and target

- SM64 decompile revision: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`
- game version: North American (`VERSION_US=1`)
- CompCert: 3.15, `ppc-eabi`, 32-bit pointers, big-endian memory
- translation flags: `NON_MATCHING=1`, `AVOID_UB=1`, `TARGET_N64=1`, F3DEX2

## Current claim

The unconditional impossibility statement is false at the local Clight-store
boundary. Generated `game_init.c` contains an unsigned-byte assignment for
`gCurrDemoInput->timer`. If the pointer value supplied to that generated
lvalue aliases the most-significant byte of `gMarioStates[0].pos[1]`, and that
byte is `0xC5`, the store writes `0xC4` to exactly that byte. Because the new
timer value is nonzero, the subsequent conditional pointer increment is not
taken.

The capstone `demo_timer_mario_y_counterexample_capstone` combines:

- the exact generated-AST decrement certificate;
- generated layout facts (`DemoInput.timer` at offset 0 and Mario Y at the
  `MarioState.pos` offset plus one `float`);
- the CompCert `Mint8unsigned` store effect; and
- a concrete before/after memory witness.

The proof additionally shows that the generated `run_demo_inputs` body has
exactly one assignment to a `DemoInput.timer` lvalue, that `0xC5 - 1 = 0xC4`,
and that `0xC4` is nonzero. The concrete CompCert store witness changes the
watched byte and preserves every disjoint unsigned-byte load. The separate
corollary `unconditional_no_matching_byte_store_is_false` refutes the narrow
unconditional no-store proposition.

The generated inputs are committed as `generated/game_init.v`,
`generated/title_screen.v`, and `generated/mario.v`. They are produced
directly from the pinned source units by `pipeline/clightgen.sh`; no extracted
or hand-written C model sits between the decompile and Clight. The Mario unit
supplies the complete generated `MarioState` composite needed for the Y-field
layout certificate.

## Reachability verdict

The alias is unreachable from the proved normal initialization/demo path.
`normal_initialization_forbids_demo_pointer_mario_y_alias` combines the exact
generated writers with the allocator invariant, canonical US demo streams,
and linker ordering. A successful 2048-byte left allocation stays below
`SEG_POOL_END`; playback never advances beyond offset 1408; and
`gMarioStates`, defined in `level_update.o(.bss*)`, is linked in later main
NOLOAD. Hence the demo pointer is strictly below the Mario-Y region.

`normal_initialization_refutes_alias_reachability` states the negative result
directly. The normal-state predicate is proved inhabited, so the theorem is
not vacuous.

Scope is literal: "normal" means the authentic US ROM, the generated
initialization/demo dataflow, a successful allocator state satisfying the
generated pool invariant, and no prior undefined out-of-bounds corruption.
The theorem is not a whole-program proof that every possible SM64 glitch is
memory-safe. A positive DOTA_Teabag explanation through this decrement would
need some earlier event to break the proved pointer provenance.

## Controller-input boundary

`generated_controller_boundary_and_normal_initialization` is a conjunction of
two static certificates. The generated AST certifies that the reader contains a
call to demo playback, directly assigns neither `gCurrDemoInput` nor
`gDemoInputsBuf`, and that the scanner finds no direct calls in demo playback.
Its only direct pointer assignment is the already checked one-record increment,
and its only recognized `DemoInput.timer` assignment is the checked one-byte
decrement. Separately, the source shows that playback preserves only the Start
bit; the remaining player-one values come from the demo record, while player two
is cleared.

This certificate does **not** prove that executing `read_controller_inputs` or
a gameplay frame preserves pointer provenance. It has no Clight execution
relation, no before/after memories, and no reachable-callgraph frame theorem.
Likewise, `normal_initialization_reachability_claim` combines generated AST,
ROM/linker receipts, and an arithmetic model of states satisfying the intended
invariants; it does not yet prove that the generated initialization code reaches
that record through Clight semantics. A clean `Print Assumptions` result proves
only that these static propositions use no additional axioms.

This is deliberately not promoted into a whole-game "user input can never
trigger memory corruption" theorem. The pinned decompile contains multiple
documented undefined-behavior and out-of-bounds sites outside this call path,
and this project translates with `AVOID_UB=1`. Establishing that none is
reachable from any controller sequence in the matching US executable would
be sufficient but is stronger than necessary. A target-specific frame proof can
instead enumerate input-reachable stores that might alias the demo pointer,
handler, or allocation. Covering behavior after C undefined behavior in the
matching executable requires machine-level store-address reasoning. Until one
of those obligations is discharged, prior indirect corruption remains an
explicit out-of-scope premise, not something this proof silently rules out.

The more precise assessment and smaller proof options are recorded in
`docs/input-provenance-investigation.md`.

The broader target-frame track now has a mechanically generated closed-world
direct-use surface. `generated_target_use_surface_certificate` checks every
function body in the generated init, title, level, memory, camera, behavior,
rumble, and save-file units. Across that surface the `gCurrDemoInput` global
cell's address is never taken, exactly three runtime assignments target the
cell, and the `gDemoInputsBuf` address is taken exactly twice. The build also
locks the source-file census, including `bowser.inc.c` through
`behavior_actions.c`.

This advances the provenance premise but is not yet the target-frame theorem:
the remaining step is a semantic non-escape result and a finite-callgraph lift
showing that concrete Clight executions preserve the protected blocks except at
the enumerated authorized operations.

The controller-value entry point is also generated and checked.
`generated_controller_input_surface_certificate` proves that the real libultra
`osContGetReadData` body is call-free and contains exactly one stack-local
response copy followed by four stores through its `pad` parameter. The generated
game body calls it exactly once with `&gControllerPads[0]`. This pins arbitrary
button/stick bytes to the controller-pad object at ingestion; a semantic
parameter-provenance lemma is still needed to lift that syntax through the loop.

## Normal N64 hardware boundary

`HardwareContracts.v` now gives the approved external-world boundary a concrete
CompCert memory meaning. SI controller DMA is exactly a 64-byte
`Mem.storebytes` into its PIF destination. PI DMA is a `Mem.storebytes` into its
explicit destination range. Both are proved to preserve every protected region
on a distinct block, and PI DMA also preserves disjoint ranges on the same
block. The generic external locality condition applies only when pointer
arguments do not reach the protected region; the intentional PI demo-buffer
write is handled by its separate range rule.

These are environment specifications, not claims that stock CompCert's opaque
`external_functions_sem` already supplies the behavior. The memory frame
consequences are proved and the locality contract is shown satisfiable. The
remaining spine obligation is to prove from the generated call arguments and
global-symbol blocks that each reached external falls into the disjoint-argument
case or the authorized SI/PI case.

`generated_pointer_provenance_kernel_certificate` composes the generated writer
and non-escape surfaces with the hardware frame. At the CompCert value/memory
level it proves that null is safe, adding an integer (including the generated
one-record increment) to a demo pointer preserves its block, and storing a safe
pointer into the pointer cell establishes a safe loaded value. Thus none of the
three authorized writer forms can manufacture the Mario global's block; the
remaining interprocedural obligation is exclusion of unauthorized stores.

`generated_target_capability_set_certificate` replaces the vague whole-game
callgraph quantifier with the exact generated finite surface. Eleven active US
functions name `gCurrDemoInput`; nine are read-only users, while playback and title
are the two runtime writers already classified. Only `setup_game_memory` and
`run_level_id_or_demo` name the handler global. The controller/libultra units
add no target-capable function. Four rumble readers visible in unpreprocessed
source are absent because the generated US target has `ENABLE_RUMBLE=0`. This is
the concrete function set consumed by the semantic capability-preservation
induction.

The same certificate now checks use context, not merely names: every one of the
nine read-only functions loads `gCurrDemoInput` into a temporary whose only use
is equality/inequality against the null pointer. The loaded capability is never
dereferenced, stored, returned, or passed to a callee. Therefore these functions
do not extend the alias graph; the semantic writer cases are reduced to playback
and title, with setup/title as the only handler-capable functions.

`linked_target_calls_resolve_to_internal_bodies` supplies the linking half of the
operational lift without normalizing a huge merged AST. Given the per-member
`linkorder` facts of the real linked program, setup, title, playback, controller
ingestion, DMA-list setup/load, and SI DMA all resolve through
`Genv.find_funct` to their generated `Internal` bodies. Consequently the final
`eval_funcall` induction traverses these bodies rather than treating them as
arbitrary externals.

`linked_target_composite_layouts` also derives from CompCert `linkorder` that
the generated three-field `DmaHandlerList` definition survives into the linked
program's actual composite environment. The title proof can therefore derive
the `bufTarget` address through linked Clight field evaluation instead of
assuming an independently stated handler layout.

`generated_writer_rhs_execution_preserves_demo_block` is the first direct
operational-semantics rung. It inverts actual `eval_expr` derivations for the
literal generated playback and title RHS expressions. If `_t'5` or `_t'6`
contains a pointer into the demo block, the evaluated value is a pointer in the
same block at Clight's `sizeof(DemoInput)`-scaled one-record offset. This is no longer only an AST
shape or a standalone `Val.add` fact; it connects the generated expressions to
their Clight evaluation.

`generated_writer_statement_execution_preserves_demo_block` continues through
the actual `Sassign` rule. It resolves the global lvalue, checks the pointer
cast/access mode, inverts `assign_loc`, and reads the stored value back with
CompCert memory semantics. Both playback and title therefore establish a safe
same-demo-block value in the concrete `gCurrDemoInput` cell whenever their
immediately preceding generated temp load has demo-block provenance.

For playback, `exec_run_increment_source_load_sets_safe_temp` now discharges
that local provenance premise from the immediately preceding generated
`_t'5 = gCurrDemoInput` statement itself: the proof resolves the global
lvalue, inverts `deref_loc`, identifies the concrete `Mptr` load, and shows
the `Sset` updates `_t'5` with exactly the value read from the safe linked
global cell while leaving memory unchanged.

For title, `exec_title_install_source_load_sets_safe_temp` performs the
corresponding derivation for the generated
`_t'6 = gDemoInputsBuf.bufTarget` statement. Using the linked composite
certificate, it derives `bufTarget` at byte offset 8, resolves the handler
global, identifies the concrete `Mptr` load, and proves `_t'6` receives exactly
that safe demo-block pointer without changing memory.

`generated_authorized_update_pairs_preserve_demo_block` composes each source
load with its immediately following generated assignment under `exec_stmt`.
The playback pair starts from the pointer stored in `gCurrDemoInput`; the title
pair starts from the pointer stored in linked `gDemoInputsBuf.bufTarget`.
Neither paired theorem retains a free assumption about `_t'5` or `_t'6`.

The paired store certificate inverts both authorized executions to one
concrete `Mem.store Mptr` at offset 0 of the linked `gCurrDemoInput` cell. This
exposes the exact frame needed to preserve `bufTarget` and all live block
identities. A crucial path-sensitivity point was also checked: on the 32-bit
target, CompCert can evaluate pointer-typed `Vint 0 + 1` to the integer-scaled
address `sizeof(DemoInput)`. Therefore the playback pair is not safe from an
arbitrary null state; its enclosing generated `gCurrDemoInput != NULL` branch
must supply the non-null provenance fact in the whole-body proof.

`exec_stmt_eval_funcall_target_lift` supplies the interprocedural semantic
induction. It is proved with CompCert's combined `exec_stmt`/`eval_funcall`
induction, composes sequencing/branches/loops/switches, descends into every
internal function body after `function_entry2`, and composes frame allocation,
body execution, and `free_list`. Certified generated load/write sequences are
handled as atomic authorized updates; all remaining assignments and reached
externals must preserve the chosen target invariant.

Authority is node-local: when the recognizer marks a sequence, that exact
sequence's certificate contains its `statement_preserves` proof. The induction
does not rely on a global promise about every statement a shape recognizer
might accept, so a hypothetical look-alike AST with changed types receives no
authority from the two generated proofs.

The exit-frame premise is also tied to the same `function_entry2` derivation
that allocated the callee environment. This freshness link is essential:
`free_list` is proved safe for those callee-local blocks, not postulated safe
for an arbitrary environment that could name a protected global.

`generated_authorized_pair_certificate` instantiates that mechanism on the
generated program. Its recognizer identifies the exact playback and title
source-load/write shapes, proves one occurrence in each corresponding body,
and computes exactly two occurrences across all ten generated target-surface
translation units. Thus no third assignment sequence is silently granted
authorized-update status.

`target_pointer_invariant` is the concrete state consumed by the callgraph
lift. It requires the demo, current-pointer-cell, and handler blocks to remain
valid; the current cell to contain null or a pointer into the demo block; and
`bufTarget` at linked offset 8 to contain a pointer into that same demo block.
`target_frame_boundary_certificate` proves `function_entry2` allocation and
the matching fresh-local `free_list` preserve this state. Normal N64 external
locality yields the same result once the reached external arguments are shown
not to carry either protected cell address.

The authorized-update theorems now preserve that complete invariant, not only
the value reloaded from `gCurrDemoInput`. Their concrete current-cell store
preserves the distinct handler field by `Mem.load_store_other` and preserves
all three live blocks. The title theorem obtains its pointer from invariant
`bufTarget`; the playback theorem deliberately requires the non-null
demo-pointer load established by the generated outer branch.

For the counterfactual rumble configuration, the build also generates
`rumble_enabled.v` from the same `rumble_init.c`, with the N64/US flags retained
and the `VERSION_SH` feature bit used to make `config.h` select
`ENABLE_RUMBLE=1`. This variant is kept separate from the canonical US program
and exists solely to audit how enabling the feature changes the capability
surface.

`enabled_rumble_pointer_capability_certificate` gives the result. Enabling
rumble adds exactly four users: `queue_rumble_data`, `reset_rumble_timers`,
`reset_rumble_timers_2`, and `func_sh_8024CA04`. Each loads
`gCurrDemoInput` into one temporary and uses it only in `!= NULL` to return
early during demo playback. Across the enabled translation unit there are
zero assignments to the pointer, zero address-of escapes of its cell, and zero
recognized authorized update pairs. Thus rumble does not add a direct or
capability-mediated way to change `gCurrDemoInput`; it expands the read-only
callgraph surface that the ordinary-store frame proof must cover.

## Conditional impossibility result

`separated_demo_pointer_cannot_change_mario_y` combines the generated direct-
writer certificate with a CompCert memory-frame theorem: a one-byte store in
a demo block preserves Mario's Y byte whenever the demo and Mario blocks are
distinct. `alias_is_necessary_for_demo_timer_mario_y_byte_change` proves the
contrapositive boundary—a changed Mario-Y byte requires block equality.

Thus the formal split is now exact:

- distinct blocks: the proposed timer mechanism cannot change Mario Y;
- same block at the Y-byte offset: the checked `0xC5 -> 0xC4` counterexample
  exists;
- normal initialization: the generated provenance and address bounds rule out
  that block alias.

## Verification status

`pipeline/check.sh` regenerates as needed, builds all eight proof modules,
rejects proof-hole keywords, checks the source census, and compiles a strict
`Print Assumptions` query. The capstone currently reports only the standard
classical and functional-extensionality axioms inherited from CompCert. The
same strict assumption check also runs for the separated-block safety theorem.
It additionally checks the normal-initialization no-alias capstone, which is
closed under the global context.

## Reachability receipts

Generated `main.c`, `memory.c`, and `level_update.c` ASTs certify the fixed US
main-pool bounds and the path from
`main_pool_alloc(0x800, MEMORY_POOL_LEFT)` through `setup_dma_table_list` into
`gDemoInputsBuf.bufTarget`, and the concrete `gMarioStates` global. Physical
linker ordering and authentic demo-stream termination are necessarily audited
alongside Clight because neither final addresses nor ROM bytes are represented
inside a translation-unit AST.

The generated bridge is now present as `generated/reachability_facts.v`. For
the canonical US ROM, the active table order is BITDW, WF, CCM, BBH, JRB, HMC,
and PSS. Their first zero timers occur at byte offsets 1408, 668, 1316, 984,
616, 976, and 744 respectively; every DMA size is at most 2048 bytes. The
generator also verifies that `level_update.o(.bss*)` is linked in main NOLOAD
after `SEG_BUFFERS = SEG_POOL_END`, and that `level_update.c` concretely
defines `gMarioStates[1]`.

`proofs/ASTReachabilityFacts.v` now supplies the generated-AST half of the
composition. Its certificate follows the exact temporary carrying the
2048-byte allocation into `gDemoInputsMemAlloc`, reloads that global into the
third argument of `setup_dma_table_list`, proves the setup function stores its
`buffer` parameter into `bufTarget` exactly once, and proves
`load_patchable_table` reads but never assigns that field. The title-screen
certificate then follows the same loaded `bufTarget` temporary into
`gCurrDemoInput = buffer + 1 DemoInput`.
