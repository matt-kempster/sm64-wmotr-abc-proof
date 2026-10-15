# Source-private global linkage

The gameplay verdict remains **open**. A source-linking obstacle was confirmed:
the separately generated BBH and CCM units assign their different C-private
`script_func_local_1` arrays the same CompCert identifier. The same spelling is
also reused in HMC, JRB, WF and other level units. These identifiers are absent
from each unit's generated `public_idents`, as required by the pinned C source's
`static const LevelScript` declarations.

This is a real failure of the current source-link setup, not a gameplay
counterexample. Installed CompCert 3.15 `common/Linking.v`, immediately above
`link_prog_check`, explicitly says that it lacks general global renaming and
therefore leaves linking undefined when static definitions share a name. The
check requires a repeated name to be public in both units. Pipeline-checked
staging examples evaluate the official AST-program link of the actual generated
BBH and CCM units to `None`, separately for US and JP. Existing local execution
theorems do not establish that those source units form one linked whole game.

The authenticated ROM data confirms why the names cannot be identified. US BBH's
first private array is 148 bytes at ROM offset 3,680,448; CCM's is 28 bytes at ROM
offset 3,759,248. Both use segmented virtual address `0x0E000000` in their own
level overlay. Their complete distinct bytes were already authenticated by
`pipeline/check-script-images.py` and recorded in `script-images.json`. The
matching retail object files have separate `.data` sections; the source-private
array spellings are not exported symbols in the linked ELF. Equal segmented
addresses therefore do not select the same overlay image.

A narrowly scoped generation correction is prepared but **has not yet been
applied to the generated sources**. It derives private globals from generated
global definitions minus `public_idents`, and scopes only their atom strings by
translation unit. Existing Coq constant names and public names remain intact.
The preparatory inventory checked all 19 US units: 217 private globals occur
only in their defining atom, global-definition keys, `Evar` and `Init_addrof`
positions. The proposed transform fails if a private identifier also occurs as
a field, composite, local, temporary or another unhandled position. Existing
version-specific private string naming will be retained; other private global
scopes use the same unit stem in alternative US/JP programs so genuine body
equalities are preserved.

The staged transform was checked against all 38 existing generated units (425
private globals total), including exact preservation of every existing private
string atom and every public/non-global atom. Applying it to staged copies of
BBH and CCM makes the official AST-program links succeed for both US and JP;
those two positive checks also passed through the pipeline. These are checks of
two staged unit pairs, not a completed whole-program link certificate.

The correction still requires regeneration, reproducibility checks, renewed
retail-image hash receipts and proof checks. Removing private-name collisions
will not by itself prove that every public declaration is compatible, that all
required functions have been generated, or that a whole-game link exists.
The caller/active-overlay representation simulation and the complete gameplay
claim remain further work.
