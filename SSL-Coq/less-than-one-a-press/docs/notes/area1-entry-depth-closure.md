# Ordinary Area-1 entry and depth closure

`proofs/Area1EntryDepthClosure.v` closes three narrow parts of the proposed
clean-JP Graphics/Object-gap exclusion.

First, any memory satisfying the existing ordinary-entry postcondition has
identical Mario State, Object-raw, and Object-Graphics coordinates in all
three axes.  At that boundary Mario's action is the generated spin-airborne
entry action and the live `quicksandDepth` cell contains binary32 `+0.0f`
(bit pattern zero).  This proves the consequences of the postcondition; the
linked execution of `warp_level` that establishes it is still open.

Second, the proof decodes the actual US and JP SSL Area-1 macro arrays.  Each
contains 46 entries, each decoded preset index is within the complete
366-entry generated preset table, and neither version selects `bhvDoor` or
`bhvDoorWarp`.  Each stream is exactly 231 halfwords: 46 complete five-word
records followed by the `30` terminator that decodes to negative one.  Every
record's decoded preset is separately proved nonnegative before the upper-bound
check.  The Area-1 level-script initializers likewise contain no relocation to
either behavior.  These receipts avoid silent parser truncation or `Z.to_nat`
clipping as evidence of absence.

Third, the old direct-static-source conditional is proved but is deliberately
not used as retail closure.  Rocq computes that the generated pyramid-top
callbacks mention the ordinary pillar-detector and fragment child behaviors,
while both children are absent from the direct macro/script source relation.
The project therefore defines a transitive spawn-closure provenance relation
and proves the generic lemma that a forbidden behavior absent from every
source-rooted spawn path cannot be live.  Extracting the complete generated
spawn graph, proving both door behaviors absent from that graph, and closing
cloning, corrupt or aliased writes, and object-pool ownership remain open.

`proofs/JPActionProvenanceCensus.v` independently scans all 38 generated JP
units for direct assignments to a field named `action`.  It finds exactly eight
function bodies.  None of those direct writer bodies also contains the
`ACT_LONG_JUMP` literal, while the exact call census still identifies
`act_crouch_slide` as the sole direct ordinary long-jump constructor and the
generated source-shape theorem places that call under `INPUT_A_PRESSED`.
Because the field-name scan is receiver-neutral and does not follow indirect
values or prove pointer separation, this is not yet the live no-long-jump
invariant.

`proofs/JPBinary32DepthWrites.v` replaces the earlier integer-hundredths sign
argument with a handwritten exact CompCert/Flocq binary32 candidate layer.  It
imports no generated writer AST.  Its sink-visible writer relation includes
the selected reset/clamp constants, the retail `.25f` and
`.5f` quicksand increments, the `10f`/`25f`/`60f` caps, ordinary landing
timers 1--3, the paired quicksand-jump subtraction and clamp, death `+5f`, and
unchanged depth.  Finite nonnegative operands remain nonnegative under the
explicit IEEE no-overflow condition, and a trace from binary32 `+0.0f` makes
the exact Clight comparison `depth < 0.0f` false.

The binary32 theorem intentionally excludes common-landing timers 4 and 5.
The later two-floor audit shows why: exact source-shaped binary32 produces
`-0.5f` at timer 4 or `-4.0f` at timer 5 when the updater samples ordinary
floor and the later ground step selects quicksand.  It also requires linked
execution to supply finite/depth
bounds, prove the raw quicksand-jump store cannot be observed between its
subtraction and immediate clamp, and show that every reachable write belongs
to this relation.

These facts do not eliminate the `>=960` installer.  The remaining decisive
work is linked ordinary-entry execution, complete writer/action and
non-aliasing coverage, exact binary32 sign preservation for every reachable
depth write, and live cutscene reanchoring plus the following quicksand sink.
