# Checked declaration normalization and the selected script link

The gameplay verdict remains **open**. `DemoExternArrayCompletion.v` proves
that nine selected generated script units can be linked by CompCert's actual
Clight linker after an explicit, proved declaration normalization. The source
files and production generated programs are unchanged. This closes the strict
public-array declaration obstacle identified in `private-global-linkage.md`
for this selected link; it does not establish a whole-game link or a retail
execution simulation.

The linked units are the shared dispatcher and the BBH, CCM, HMC, JRB, WF, PSS,
Bowser 1 and BITDW script units, separately for US and JP. Bowser 1 is the arena
selected by demo header 30. BITDW remains included for the independently checked
header-17 course route. The imported private-global hygiene correction is used
unchanged.

The ordinary Clight linker demands exact variable-type metadata. A declaration
such as the dispatcher's `level_bbh_entry : tarray tuint 0` therefore does not
link directly with the initialized `tarray tuint 100` definition. The selected
source also has a readonly metadata discrepancy for `script_func_global_1`:
BBH's empty declaration is readonly, while the initialized shared definition is
writable. Merely completing array extents does not solve that second obstacle.

The derived normalization inspects the exact generated definitions. It only
changes public array declarations with empty initializers and zero extent.
It requires an actual positive-extent initialized array with the same identifier,
element type, attributes and volatility, and takes that definition's extent and
readonly flag. No actual initialized definition, initializer word, volatility
flag, function, identifier, declaration order, public list or composite
environment is changed. This is an explicit declaration normalization with a
Clight semantics proof; it is not an assumption of general C compatibility for
the readonly discrepancy.

Two generic proofs justify the changes. Global-variable `gvar_info` metadata is
absent from the Clight expression, function-call and memory operations used by
`step2`. Official matching-global-environment lemmas establish identical symbol
and function lookups; the complete expression, lvalue, allocation, assignment,
external-call and small-step rules are transported. Changing only readonly on
an empty initializer is justified separately: that global allocates a zero-size
block, so its final permission change acts on an empty interval. The proof
establishes identical `Mem.drop_perm` results for that interval, then identical
ordered global allocations and initialization. Volatility, which is observable
through the symbol environment, is preserved.

The composed result establishes exact equality of `Genv.init_mem` options and
equivalence of every ordinary Clight `step2` transition, with the same state,
trace and memory. It applies to every original selected unit in both versions.
This equality does not itself construct a successful game initialization or a
reachable gameplay state. A finite certificate checks the actual changed
declarations against the initialized source definitions. A separate exact
invariance lemma covers all nonempty-initializer variables.

The link receipt uses the official AST linker, the official composite linker,
and `Ctypes.link_program` itself. A generic induction lifts the successful AST
and composite folds to existence of an actual official nine-unit Clight link;
the result is not a hand-assembled program or just an AST-only receipt.

The combined boundary is `demo_extern_array_completion_boundary_claim_us_jp`,
proved by `generated_demo_extern_array_completion_boundary_us_jp`. Its three
components are `demo_generated_script_declaration_refinement_claim_us_jp`,
`demo_normalized_array_completions_checked_claim_us_jp`, and
`demo_normalized_script_clight_link_claim_us_jp`.

The selected link still has external game callbacks and assets. No theorem here
relates the separate source units' block layouts to the linked initial memory,
proves the numeric active-overlay representation relation, verifies MIPS
execution, or establishes that the complete boot-to-gameplay trace preserves
the demo/level pairing. Those remain work on the full gameplay claim.

Read-only triage of the wider 19-unit inventory found another concrete
metadata boundary: `gDisplayListHead` uses anonymous Gfx union tags
`__549`/`__613` in US game-init/area and `__512`/`__576` in JP. The current
array normalization leaves those pointer declarations unchanged. The
[registered narrow certificate](selected-link-type-boundary.md) checks the
exact failed variable links and corresponding definitions/layouts. No anonymous type,
function prototype or composite environment is rewritten to force the
wider link. The nine-unit link above remains the completed boundary.
