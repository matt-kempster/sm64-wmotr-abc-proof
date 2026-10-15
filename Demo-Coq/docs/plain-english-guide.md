# Can a demo's inputs play in the wrong level?

**We have not proved or disproved that this can happen during normal SM64
play.** Demo-Coq proves concrete startup, input, interpreter and warp paths,
while the complete boot-to-gameplay invariant remains open.

The [primary gameplay specification is partially formalized](notes/gameplay-observation-status.md).
Coq now observes an actual controller-field read in generated gameplay code
and conditionally connects a demo record's emitted value to a real camera read.
The receipt tracks the consumed record before playback advances its pointer;
EOF has a separate origin. A candidate external policy constrains some SDK
calls' memory effects and sequencing. These are parts of the existing first
checklist obligation, which stays unchecked. Loaded-scene identity, complete
input-use coverage, permitted boot states and hardware/SDK adequacy remain open.
No major unchecked gameplay obligation has been closed. This work takes priority
over further local input/exit cases.

Each observed input read now also has a raw scene-probe result, even when the
area is null, unreadable or invalid. Coq checks the selected scripts' nine area
declarations and their geometry/terrain operands. These do not identify an
independently materialized loaded level. Actual geometry/terrain loads expose
an address-model obstruction: numeric addresses cannot be dereferenced by
ordinary Clight, while symbolic pointers fail the helper's bit arithmetic.
The explicit decoder view keeps those representations separate; a justified
execution correspondence remains missing. See the
[exact diagnostic](notes/scene-address-boundary.md).

A [bounded scalar-read connection](notes/native-scalar-read-connection.md)
now evaluates the actual selected geometry/terrain expressions and fetched
retail load instructions in explicit candidate numeric/ISA projections.
Matching scalar byte ranges derive positive data reads, and constructed local
RAM witnesses demonstrate successful execution in that projection. These do
not prove ordinary-Clight/native adequacy, actual loading, scene ownership or
normal-boot reachability. The first checklist item stays unchecked.

Each demo has a four-byte header followed by recorded controller inputs.
The first header byte identifies its level. When the title screen chooses a
demo, it loads one buffer, takes the level from that buffer's header, and
points playback four bytes into that same buffer. There are no independent
choices of “which inputs” and “which level” in this assignment. Advancing the
next-demo index does not change the source of the current level.

Coq now executes the whole first-demo title path under explicit memory and
layout conditions, including its countdown and index stores. The actual loader
is now composed into that proof; its concrete DMA call and post-DMA reads
remain premises. Coq also executes
the active-demo level-selection function and the actual interpreter command
that calls it, captures its result and advances the command pointer. Reaching
that command from startup and loading the selected level still need proof.
The equality helper and a nonmatching script jump are now executed too.
The taken jump exposes an address-model gap: the actual helper shifts pointer
bits, but the current Coq memory represents relocated pointers symbolically.
Coq checks that this shift is undefined on those symbolic values. This does
not say that retail hardware fails; a justified address bridge is required.

The source review also checks what happens if a demo reaches an exit. The
ordinary delayed-warp code redirects active demos to the title/splash route.
HMC's green pool and CCM's slide use this ordinary mechanism. The painting
path needs separate attention because it has no demo check, but the seven
demo-level script units declare no painting or instant warps. Coq verifies
these finite syntax facts. The first US file is named `bitdw.bin`, but its
header is 30: it selects the Bowser 1 arena, not the BITDW course (17).
The earlier report used the wrong script for that stream. The corrected
census checks `bowser_1`, and a generated-table check confirms all seven
header-to-entry mappings. Proving that the actual area memory is constructed
and preserved as intended is still required.

Playback itself does not ask whether it is in the right level. That does
**not** demonstrate a desync: a state that can be constructed by hand may
never arise through normal play. Similarly, playback begins during the title
fade, when a stale current-level number can remain. That scalar mismatch alone
does not establish gameplay in the old level. Actual input application during
a fade must remain eligible. The full property must independently identify the
loaded scene at the time its demo input is used.

Coq now executes every timer branch of the input consumer with the second
logical controller absent. Ordinary records decrement their timer; expiring
records advance the pointer four bytes; terminal records produce END_DEMO.
The proofs give exact stick/button outputs and preservation outside the
specific pad, timer and pointer writes. They also preserve the header when
the record starts after it. Initial pointer provenance, buffer bounds across
all frames, and the complete input-to-gameplay sequence remain open.

The controller-processing branch proves actual button edges for neutral
sticks. A new complete analog-call theorem removes that stick restriction:
it executes arbitrary raw axes, every deadzone and magnitude-cap branch,
and the real stack allocation/free, with exact symbolic float outputs and
a named pure `sqrtf` contract. Hardware polling remains open.
The actual disconnected second-controller branch and player-three copies
also execute separately, with byte frames protecting player one's inputs.
They now compose with playback, analog processing, both actual loop
increments/tests and the final copy in the original post-polling source.
This complete path now handles every timer branch, including EOF and
expiry, arbitrary current and prior buttons, and arbitrary recorded sticks.
It retains exact controller values and the stream pointer, timer and header
through the loop. Start and EOF guards are separate consequences of the
proved final button value. The second logical controller is absent in this
theorem. A [connected-player-two extension](notes/connected-second-controller-read.md)
now executes the same complete path with both logical controllers connected:
the actual playback code clears player two's physical pad, then the real
copy and analog call process those neutral inputs. Every timer branch is
covered, including EOF. This extension fixes the first two physical pads
at byte offsets 0 and 6 and uses two precise pure math contracts. Deriving
pad pointers from initialization, all other physical-port assignments,
hardware polling/boot and all-frame provenance remain open.

The later [generalized physical-pad caller](notes/physical-controller-read-execution.md)
removes the local fixed-base restriction. It consumes actual shifted playback
and controller branches, preserves the mapping pointers and entry-valid
accesses, and covers both one- and two-controller arrangements. This does not
derive the mapping from boot or supply a loaded-gameplay observation.

An additional proof connects ordinary-record playback, including expiry,
to the actual input loop's controller-copy boundary for arbitrary recorded
stick bytes. Under a supplied program's global environment, it follows the
original loop's small steps to its analog call and proves the actual new-Start
and END-clear guards there. Reaching the post-polling entry from boot and
preserving these results through subsequent processing remain open.
The [complete post-polling path](notes/controller-read-execution.md)
extends that earlier analog-entry result through the rest of the loop
under the scope above.

The separate ROM check authenticates the seven US and six JP selected demo
files, their level headers, terminal records and buffer bounds. That is a
finite data check outside Coq; it does not prove that DMA and all intervening
game code preserve those bytes and pointers.

The warp and pause proofs now execute their concrete local paths too. Coq
also executes Demo Next scheduling and its real transition/RGB helpers,
establishing the pending operation and timer from an initially zero operation.
The actual Start-handling prefix now selects that call, with the real intro-text
execution and post-UI reads still explicit premises. A null
painting table prevents the painting routine from acting. A pending warp or
active transition makes the complete pause query return false. The demo exit
branch executes the real `warp_special`, and transition completion returns
its negative title code **provided the ordinary warp destination is zero**.
That condition is essential: an existing destination takes priority. Proving
that ordinary demo frames establish and preserve these conditions is ongoing.
The actual normal-frame timer block now preserves the scheduled operation
through its precise store frame; object, HUD and camera updates remain to be
connected and framed.
The actual warp, instant-warp and timer statements now compose through their
caller up to the object-update boundary. This executes that interval under
explicit entry reads, without assuming either warp callee's execution.

The actual normal-frame interval after camera processing now composes too:
null-table painting, its real local allocation/free, pending demo countdown
from 20 to 19, the full pause query and final zero return. Concrete entry
reads and separation still need connection to the earlier frame. Object,
HUD and camera effects remain open.

The delayed-warp routine itself now executes every Demo Next countdown
value from 2 through 20 and its full terminal timer-1 path. Under the real
debug/demo guards and initially a non-zoom dialog type, terminal expiry executes
the actual dialog reset, transition helper and special-warp call. It
sets mode 4, control code -2, zero transition timer and null callback.
This is a proof of the actual calls, not an induction over gameplay frames;
intervening frame effects and the zero ordinary warp destination remain
necessary obligations.
The [actual caller composition](notes/normal-delayed-execution.md) now covers
every pending timer from 2 through 20 through the painting call, countdown,
pause query and zero return. For terminal timer 1 it covers the suffix
immediately after painting through the full delayed call and final mode-4
decision. The different entry points and explicit guards remain part of
those statements.

The [all-dialog terminal extension](notes/dialog-zoom-execution.md) now removes
the non-zoom restriction from the complete terminal call and normal caller
after painting. It executes the real camera `trigger_cutscene_dialog(2)`
when required, rather than assuming that callee's execution. Exact camera
cell and target-resolution resources replace the old dialog-type premise.
The whole camera update and the earlier frame remain separate obligations.

The [full terminal post-camera interval](notes/normal-terminal-postcamera-execution.md)
now starts before painting's actual allocation/free and transports the terminal
resources through it. This removes a local caller-entry restriction, not an
unchecked boot/gameplay obligation.

The complete area-reset call now executes all eight loop iterations. It
establishes null painting and instant-warp tables in all eight area records,
using checked generated layouts. A composed theorem now constructs the
actual US/JP area unit's initial memory and discharges its starting-memory
conditions, including the actual spawn pointer and writable allocations.
The linked game's boot execution, later area selection and preservation
through script/gameplay calls remain to be connected.

The complete instant-warp check now returns without writes for a null floor
or null instant-warp table under its stated conditions. A separate finite
check authenticates the selected script images and native callback byte
ranges against the clean retail ROMs. Coq checks their numeric dispatch
transcriptions and executes the numeric address helper. This still needs a
runtime bridge: equal addresses can hold different loaded level images,
and ordinary CompCert pointers cannot simply be replaced by integers.
Coq now executes a taken script jump when its target cell already contains
the numeric address, using both real callees and storing the exact returned
address. The next opcode read still cannot dereference that integer in
ordinary Clight. This pinpoints the remaining simulation boundary; it does
not establish a reachable boot route.

The dispatch table's current-level GET command also executes completely:
it copies the signed stored level into the script register and advances the
command pointer four bytes. Private global names are now scoped by source
unit, and selected real source links succeed. A new declaration
normalization now resolves the selected public-array mismatch: it derives
empty declarations from actual initialized definitions, proves that each
unit keeps exactly the same initialized memory and Clight steps, and links
nine script-data units with the official linker in each version. The
generated source files are unchanged. Full game linking, active-overlay
execution and normal-boot reachability remain open.
The [next source-link certificate](notes/selected-link-type-boundary.md)
identifies a graphics pointer's different anonymous type names across two
units. Their corresponding definitions/layouts are checked, but proving a
complete type-renaming simulation and wider link is separate work.

Four authenticated retail-ROM experiments provide a separate finite check of
idle cycles and physical Start interruptions. They observed 12,866 demo
updates without a mismatch or observer error. The observer checks stream
provenance and authenticated terrain prefixes. No reachable mismatch has been found;
the exact runs and limits are in [the search note](notes/gameplay-search.md).
Finite observations cannot establish the all-executions claim.

The next work is concrete: connect the header through the real script
interpreter to the loaded level, prove initialization and record-pointer
provenance, and prove that every reached store preserves the protected state.
Until that chain is proved or a reachable mismatch is demonstrated, the
requested impossibility claim stays **open**.

See [the exact boundary](claim.md), [source audit](notes/source-audit.md),
[executed paths](notes/gameplay-execution.md),
[remaining obligations](checklist.md), and the
[private report site](https://demo-proof-notes.tra38.chatgpt.site).
