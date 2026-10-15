# Can a demo's inputs play in the wrong level?

**We have not proved or disproved that this can happen during normal SM64
play.** Demo-Coq currently proves a smaller fact about the real startup code
and checks the source paths most relevant to the question.

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
fade, when a stale current-level number can remain. That is not already
gameplay in the old level. The full property must observe the actual loaded
gameplay level at the time its demo input is used.

Coq now executes every timer branch of the input consumer with the second
logical controller absent. Ordinary records decrement their timer; expiring
records advance the pointer four bytes; terminal records produce END_DEMO.
The proofs give exact stick/button outputs and preservation outside the
specific pad, timer and pointer writes. They also preserve the header when
the record starts after it. Initial pointer provenance, buffer bounds across
all frames, and the complete input-to-gameplay sequence remain open.

The next controller-processing branch now executes too for neutral sticks,
including its real analog-adjustment call and stack allocation/free. It proves
the actual button-edge formula and controller outputs, with a named pure
`sqrtf` contract. Arbitrary stick values and the complete polling loop are
still outside that local result.

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
