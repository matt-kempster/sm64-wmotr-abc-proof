# The next selected-unit type-link boundary

The gameplay verdict remains **open**. The normalized nine-unit script link is
proved, but no link of all 19 currently generated units per version is claimed.
Those 19 units are themselves a selected partial source inventory, not the
complete game.

The next narrow certificate, `DemoSelectedLinkTypeBoundary.v`, connects the
existing nine-unit link result to an additional concrete type mismatch:
`link us_game_init.v_gDisplayListHead us_area.v_gDisplayListHead = None`, and the
same statement for JP. In US, game initialization's initialized global has type
`tptr (Tunion __549 noattr)`, while area's empty declaration has type
`tptr (Tunion __613 noattr)`. In JP the corresponding tags are `__512` and
`__576`. Both versions' definition initializer is `Init_space 4`; area's
initializer is empty, and the readonly and volatile flags are false on both
sides. CompCert compares the pointer types exactly and rejects the different
anonymous union tags.

The proved array-declaration normalization leaves all four pointer globals
exactly unchanged, for every definition catalog and public list. Its scope is
zero-extent array declarations; it does not identify these anonymous composite
types. A read-only Python metadata triage of the current ordered 19-unit list
first observed a variable-metadata mismatch when adding `area`, after the first
17 units. That triage is not a Coq proof that the preceding complete AST or
Clight prefix links: function-prototype and composite constraints also matter.
The narrow checked receipt does not claim an exact first failing full prefix.

The two tags describe corresponding Gfx declarations. An explicit finite tag
table compares all 18 US composite definitions in the Gfx closure, including
the nested triangle structure, and the two JP definitions. The certificate
checks that every source definition and computed layout is present, then proves
exact equality of the generated composite definitions after translating only
the table's tags. Names, field order, bitfield widths, signedness, padding,
attributes and remaining type structure are included in this comparison.
Separately, every paired computed composite has the same kind, attributes,
size, alignment and rank. The union declarations' layouts correspond despite
their distinct generated names.

These finite comparisons do not rename a program. No production generated
type, composite environment, function expression, function prototype or state
has been changed. Equal layouts are not a theorem that an anonymous-tag
translation preserves complete Clight execution. Any such extension would need
an explicit simulation covering those uses, distinct from the existing
`gvar_info`-only declaration normalization proof.

The combined boundary is `demo_selected_link_type_boundary_claim_us_jp`, proved
by `generated_demo_selected_link_type_boundary_us_jp`. It consumes the existing
`demo_extern_array_completion_boundary_claim_us_jp`, the actual failed pointer
links, exact invariance under the current normalization, and the finite
definition/layout correspondence. It establishes a precise remaining selected
source-link obstacle, not a gameplay desync or a whole-game impossibility.
