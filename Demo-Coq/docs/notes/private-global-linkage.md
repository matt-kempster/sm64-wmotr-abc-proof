# Source-private global linkage

The gameplay verdict remains **open**. Source-private global names are now
scoped by translation unit in the actual generated programs. The official
CompCert AST-program linker accepts the eight selected level-script units
together, separately for US and JP. A second receipt proves existence of an
actual official Clight link of BBH and CCM in each version, including composite
compatibility. These certificates do not establish a whole-game link.

The correction addresses a real failure of the previous source-link setup.
BBH, CCM, HMC, JRB and WF reused the C-private `script_func_local_1` spelling.
It was absent from their generated `public_idents`, as required by the pinned
source's `static const LevelScript` declarations. Installed CompCert 3.15
`common/Linking.v`, immediately above
`link_prog_check`, explicitly says that it lacks general global renaming and
therefore leaves linking undefined when static definitions share a name. The
check requires a repeated name to be public in both units. Pipeline-checked
staging examples evaluated the previous BBH/CCM AST-program links to `None` in
both versions. That source-link failure was not a gameplay counterexample.

The authenticated ROM data confirms why the names cannot be identified. US BBH's
first private array is 148 bytes at ROM offset 3,680,448; CCM's is 28 bytes at ROM
offset 3,759,248. Both use segmented virtual address `0x0E000000` in their own
level overlay. Their complete distinct bytes were already authenticated by
`pipeline/check-script-images.py` and recorded in `script-images.json`. The
matching retail object files have separate `.data` sections; the source-private
array spellings are not exported symbols in the linked ELF. Equal segmented
addresses therefore do not select the same overlay image.

A narrowly scoped correction in `pipeline/scope-private-globals.py` now runs
inside `pipeline/clightgen.sh`. It derives private globals from generated
global definitions minus `public_idents`, and scopes only their atom strings by
translation unit. Existing Coq constant names and public names remain intact.
The inventory checked all 38 units: 217 US and 208 JP private globals occur
only in their defining atom, global-definition keys, `Evar` and `Init_addrof`
positions. The transform fails if a private identifier also occurs as
a field, composite, local, temporary or another unhandled position. Existing
version-specific private string naming is retained exactly; other private global
scopes use the same unit stem in alternative US/JP programs so genuine body
equalities are preserved.

The full generation pipeline regenerated all 38 units twice and confirmed
byte-identical results. A whole-file comparison to the previous checkpoint
confirmed that only hygiene headers and 299 nonliteral private atom strings
changed. Every existing private string atom and public/non-global atom remained
identical. `pipeline/check-link-hygiene.sh` now checks the private-global
inventory, exact unit scopes and absence of private-global collisions across
each version. The full 24-module registered proof build passed after
regeneration.

The selected complete script images and callback bytes were reauthenticated
against the clean ROMs. All words, placements and retail hashes remained
unchanged; only the 18 generated-source digest fields in `script-images.json`
changed. The exact Coq numeric transcription was checked and required no edit.

`DemoPrivateGlobalLinkReceipt.v` proves the positive link receipts above and
records an additional source-link boundary. The shared dispatcher declares
`level_bbh_entry` as `tarray tuint 0`; BBH defines `tarray tuint 100`.
`Ctypes.Linker_types` uses exact `type_eq`, and the actual variable-definition
link evaluates to `None` in both versions. This ordinary incomplete/complete C
array pair is rejected by the unmodified strict operation; this is not a
retail C linker failure. The new [checked declaration normalization](extern-array-completion.md)
addresses that selected boundary with a separate semantics proof. It derives
extent and readonly metadata for empty zero-extent public array declarations
from actual initialized definitions, proves exact per-unit initial-memory
and step preservation, and establishes official nine-unit Clight links.
Production generated programs and initialized definitions remain unchanged.

The receipt boundary is
`demo_private_global_link_boundary_claim_us_jp`, proved by
`generated_demo_private_global_link_boundary_us_jp`. It establishes selected
source-link hygiene and identifies the unmodified strict declaration boundary.
Its final-path build and assumption audit passed; the latter reports only
CompCert's existing `Axioms.proof_irr` for the official Clight link construction.
It does not prove that all required game functions have been generated or
linked, or that the source blocks simulate active retail overlays. The
caller/active-overlay representation simulation and full gameplay claim remain
open.
