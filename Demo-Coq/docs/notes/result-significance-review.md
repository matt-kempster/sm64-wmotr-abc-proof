# What the existing results contribute to demo desync

**Gameplay verdict: OPEN. Research remains stopped.**

This is a read-only review of the existing published result families, their
theorem statements and defining predicates. It makes no proof changes, adds no
lemmas, runs no Coq build, and supplies no new gameplay evidence. The checked
proof snapshot remains `5dfb2332f69da710f19e0b9ab9891571fc4290d8`.
The [full result catalog](../proven-results.md) retains the exact conditions.

The distinction is between deriving a local game effect from an input state,
checking a fixed piece of source/ROM data, establishing modeling infrastructure,
and recovering properties already stipulated by an observation or policy.
Valid memory and readable input bytes are ordinary prerequisites for a local
function theorem; they are not automatically an assumption of its conclusion.
Authentic stream provenance, unchanged bytes across all intervening gameplay,
correct active image and reached entry states are much larger missing
obligations. A correct conditional theorem can still leave those untouched.

## Assessment of every published family

| Published family | Assessment for the gameplay claim |
| --- | --- |
| Startup installs a stream pointer and returns its own header level | **Substantive local pairing.** Derives the header return and buffer+4 installation from the same incoming buffer; it does not assume that output pairing. Authentic DMA contents, normal entry and the subsequently loaded scene remain unestablished. |
| Interpreter operations and selected header dispatch | **Real local routing; no level-match guarantee.** Derives register transfers, stores, comparisons and branches; finite tables identify selected targets. The level setter accepts the supplied level while preserving the active demo pointer, without proving that level matches the header. Runtime target/image correctness and the complete route remain open. |
| Recorded input playback and controller processing | **Substantive local input processing.** Derives buttons, sticks, timers, pointer changes and protected-memory effects from initial record bytes, including composed post-polling callers. Correct entry stream/mapping resources and square-root contracts remain supplied; authentic all-frame provenance and loaded-level pairing are unproved. |
| Warp, pause and Demo Next paths | **Mixed: real effects, safety guards supplied.** Scheduling and selected countdown/exit effects are derived. Absence of ordinary warp destinations and relevant warp resources is assumed where required, rather than established throughout gameplay. Object/HUD/camera intervals and the intro-text callee remain incompletely composed. |
| Area reset, including an actual unit initial-memory witness | **Substantive isolated initializer.** Constructs the actual area unit's initialized memory and derives clearing all eight area slots without assuming null outputs. This discharges the local reset resources, but proves no linked normal boot or later lifetime invariant. |
| Finite source inventories and selected source links | **Finite facts and substantive modeling infrastructure.** Actual syntax/table checks and selected links are established; declaration normalization also preserves initial memory and Clight steps. These remove specific modeling obstacles, but direct syntax absence is not transitive runtime noninterference and no unified whole-game environment is established. |
| Input-use histories, provenance receipts and raw scene observations | **Mostly observation and transport groundwork.** Expected controller outputs, protected bytes and the reached camera site are supplied. Raw scene probes report supplied memory without establishing a valid loaded scene or its level. Concrete read/layout checks are useful infrastructure, with little direct force against desync. |
| Structure of a candidate external-event policy | **Mostly consequences of a proposed policy.** Permitted effects and sequencing are stipulated by the policy; the lemmas recover those conditions from policy-admitted histories. They do not prove the SDK/hardware obeys it or that any authentic normal gameplay history is admitted. |
| Address-model diagnostics and supplied-image arithmetic | **Model diagnostics and supplied-image arithmetic.** Proves a real helper's local arithmetic and exposes ordinary-Clight representation obstructions. The decoder's block/image is supplied; it neither discovers the active scene nor proves readable/authentic assets, and equality may compare two failed reads. |
| Positive scalar-read connection in explicit candidate projections | **Limited custom-model read agreement.** Derives single-load agreement from matching bytes, code fetches, registers and supplied image placement in candidate expression/ISA models. Correct loading, reachability, active ownership and model adequacy remain open. Prefix values 8 and 64 cannot identify the level. |

## The strongest directly relevant local mechanism

`proofs/DemoStartExecution.v:185–208` derives both the returned header byte and
the installed `buffer+4` pointer from the same incoming buffer. Its initial
loads and writable/separation premises do not assume this output pairing.
Within that installation suffix, level header and input pointer are not
independent choices. That is a substantive local fact relevant to desync.

The composed first-title/first-cache-miss result removes the whole-loader
execution premise, but still assumes the real `dma_read` call and five
post-DMA reads (`DemoLoadedTitleExecution.v:54–62`). The header value is
arbitrary. It does not prove that authentic ROM bytes were transferred, that
boot reaches this state, that later indices/wrap behave correctly, or that
the header's level becomes the independently identified loaded scene.

## Real input processing, not assumed correct outputs

`DemoPlaybackAdvanceExecution.v:448–485` derives execution and exact
button/stick/timer/pointer outputs from the record bytes. The complete
post-polling caller (`DemoControllerReadExecution.v:307–374`) also derives
`buttonPressed`, analog fields, second-controller behavior and player-three
copies in the stated variants. It proves protected-memory effects rather
than assuming the final output value.

Its entry already contains the designated stream pointer, record and controller
mapping; hardware polling and authentic origin across frames remain open.
The analog path uses an explicit pure `sqrtf` result/trace/memory contract.
These are meaningful local execution results, but no level-pairing invariant
is a conclusion.

## Dispatch is proved; correctness of the supplied level is not

The finite dispatch checks establish actual selected header-to-script routes
(`DemoScriptDispatchFacts.v:123–135`), including header30 selecting Bowser1
arena rather than the BITDW course17. Local interpreter handlers derive their
register transfers, comparisons, command advances and stores.

But `DemoLevelSelectionExecution.v:40–74` explicitly does not relate the
supplied `level` argument to the demo header. Its conclusion stores that
argument while preserving the active demo pointer. This establishes no
header-match guard. It also supplies no normally reachable call with a
different level, so it is not a counterexample.

The later [source-only caller audit](level-setter-callers-source-audit.md)
traces the sole setter command's register input. The normal first-demo route
retains its own header. Later positive ordinary-warp returns and an
already-enabled-debug selector are conditional alternative sources; no normal
mismatched invocation was identified. This adds source evidence, not a new
Coq theorem or discharge of the runtime preservation obligations.

Numeric jumps assume the numeric target cell and segment base
(`DemoNumericDispatchExecution.v:14–45`). The following ordinary-Clight
numeric-pointer dereference remains blocked. Correct local forwarding is
therefore not a complete executable header-to-loaded-level route.

## Warp results contain consequential safety premises

Scheduling and countdown theorems really derive operations, timers, dialog
resets and special exit effects. For example,
`DemoStartSchedulingExecution.v:417–470` derives operation22/timer20;
`DemoDelayedWarpTerminalExecution.v:342–389` derives the terminal path.

However, null painting/instant-warp tables or floors, relevant noncastle and
demo/debug/transition states, and zero ordinary warp destination are supplied
where the branch requires them. Executing a guard after assuming the guarded
condition does not establish that the condition holds throughout gameplay.

The special transition result explicitly requires zero ordinary warp
destination (`DemoGameplayBoundary.v:476–509`); an ordinary nonzero
destination takes priority. This review does not establish that such a
destination can normally arise during a demo, or that it cannot.

The later [source-only intervening-call audit](demo-pause-intervening-calls-source-audit.md)
narrows the pause concern: warp initialization clears a delayed operation but
immediately starts another fade, so that clear alone does not open pause.
An eligible instant area change can conditionally erase the fade; no normal
selected-demo instance was identified. This adds source control/state evidence
without changing the checked theorems or closing their preservation premises.

Selected preobjects and postcamera intervals compose real internal callees,
but omit the intervening object/HUD/camera effects. Separate timer cases are
not twenty consecutive full frames. The Normal Start prefix still assumes the
concrete `print_intro_text` call and post-UI reads
(`DemoNormalStartExecution.v:152–178`).

## Initialization and linking deserve credit within their scope

The final area initializer theorem (`DemoAreaInitialMemory.v:340–374`)
constructs the actual area unit's initial memory and derives null current-area,
painting and instant pointers for all eight slots. It does not assume the
cleared output or leave its own local symbol/access/separation resources
unproved. It establishes one unit's initialization, not linked console boot or
later pointer preservation.

Declaration normalization (`DemoExternArrayCompletion.v:602–620`) preserves
the initial-memory result and every ordinary Clight step. Positive nine-unit
normalized script links are checked at `:746–757`. This is substantive
semantic infrastructure, not merely a wished-for execution contract.
Private-global and selected link receipts also establish finite facts, but
no whole-game scoping/type-renaming simulation or common initialized
environment has been established. The wider `gDisplayListHead` link failure is itself checked
(`DemoSelectedLinkTypeBoundary.v:10–16`).

## Syntax, metadata and ROM checks are genuine finite facts

Direct-name/opcode absence and the nine selected AREA/TERRAIN declarations
are checked, not assumed (`SourceFacts.v:49–67,97–132`;
`DemoSceneSourceInventory.v:395–511`). They say what occurs in the selected
syntax. They do not prove transitive absence through aliases, callbacks,
indirect stores, decompression or subsequent gameplay.

Canonical-ROM/ELF checks independently verify selected data, relocations,
instruction words and asset bytes outside Coq. Existing bounded emulator
observations found no mismatch in the tested cases. These facts improve the
identity of the evidence being studied, but neither establish all-run behavior
nor authenticate the premises of every formal runtime history.

## The weakest gameplay evidence is observation/policy transport

The camera connection assumes expected final controller fields, protected
bytes and the reached camera site. The resulting real typed read is checked;
the central gameplay premises remain supplied. See the
[camera connection analysis](gameplay-observation-status.md).

Area snapshots similarly assume the recorded loads
(`DemoAreaSceneObservation.v:76–82`). Pairing an already-given read with a
total raw probe is essentially definitional
(`DemoGameplaySceneObservation.v:161–164`). Retaining missing/null/invalid
results is good specification design, but does not establish a present,
materialized scene or identify its level.

The external policy stipulates effects and phase sequencing.
`DemoPermittedExternalSpec.v:443–504` recovers actual-history steps,
continuity, exact call/return conditions and builtin rejection from those
definitions. The actual-step lemma already follows from the supplied history.
No SDK/hardware implementation is proved to meet the policy; no initial-state
or authentic admitted-gameplay witness is supplied. This is proposed
specification plus structural consequences.

## Address and native results leave the runtime connection supplied

The ordinary-Clight stuckness results diagnose a real proof-model
representation problem. They say nothing about retail scene loading failing,
normal gameplay being unreachable, or desync being impossible.

The supplied-image decoder maps into the block/image named in its input
(`DemoSceneAddressView.v:100–155`). It does not discover active ownership;
its read equality can be `None = None`.

The positive scalar connections go further: matching readable source/RAM
byte ranges imply successful typed loads, selected generated expressions are
evaluated, and fetched retail load words execute in an explicit partial native
model (`DemoSceneReadNativeConnection.v:42–160`). This is a real bounded
calculation, but matching bytes, placement, registers and reached PCs are
premises. The expression evaluator is custom, not ordinary Clight numeric
dereferencing; native-model/hardware adequacy and full caller execution remain
open. The fixed prefix corollaries assume byte8 or halfword64 in their matched
ranges (`:182–290`). Those values are shared across the selected areas and
cannot identify the loaded level.

Constructed local witnesses establish satisfiability of their local read
premises. The four separately validated staged files are finite fixtures,
partial-model properties and joint constructed scalar witnesses. They are not
authentic boot/asset/gameplay witnesses and are outside the capstone.
Three other staged files failed compilation and are excluded from proved
results. This review neither repairs nor promotes them.

## What the capstone does and does not do

`MainTheorem.v:113–139` collects conditional components in a conjunction.
Importing them and proving that conjunction does not compose their separately
quantified memories, environments and histories into one authentic normal
execution. There is no established common boot-to-gameplay witness, independent
loaded-level identity, or all-frames pairing invariant.

No published result presently proves that normal gameplay cannot consume one
demo's sequence in a different loaded level. Startup pairing is the strongest
direct local mechanism; playback and reset are substantive supporting behavior;
metadata and linking establish narrower facts; observation/policy/image
connections largely leave the difficult runtime premises supplied.

This review changes the assessment and reporting, not the proof snapshot,
unchecked gameplay obligations, or OPEN verdict. Research remains stopped.
