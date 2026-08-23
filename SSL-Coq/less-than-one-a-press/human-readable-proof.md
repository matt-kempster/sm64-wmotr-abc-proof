# Human-readable proof guide

This document explains the proof project for a reader who understands software
engineering but does not know *Super Mario 64*.

> **Current status:** the project does not yet prove the retail-game theorem.
> It proves a collection/provenance reduction in an abstract event model, a
> finite normal-star/save-writer classification, exact first-target
> gate-or-named-bypass theorems, selected facts about generated US and JP
> Clight syntax, and exact equality/count facts for the generated route-relevant
> collision arrays.  `FirstTargetRefinement.v` now gives bypasses concrete
> Clight-frame, projected-state, writer, and collision-cut evidence and rules
> out several classes inside the certified model.  It also proves the needed
> direction from an aligned newly set Act 3/Act 6 bit to the corresponding
> target-region cut, then blocks both bits when an evidence-bearing classifier
> and exclusions for all six open writer families are supplied.  It does
> **not** construct those premises from a complete retail execution.
> `ModelGapAudit.v` proves that the older abstract event relation admits a
> spurious one-frame collection from a clean entry, so that relation cannot by
> itself establish the retail theorem.

> **Where linked gameplay starts:** **SSL Area 1 (the exterior)**, at node
> `0x0A` and coordinates `(653,1038,6566)`.  The proof assumes
> `DefaultArea1StartBoundary` there.  It does not execute the optional
> castle-to-SSL Area 1 route; that route and possible castle glitches are a
> separate investigation.

> **Whole-program boundary:** there are 38 generated translation units per
> version, but CompCert's unmodified linker rejects both 38-unit programs.  In
> its right-associated order, the first AST join fails at `ssl_script` (index
> 34) and the first composite-definition join fails at `area` (index 27).  The
> audit finds 402 US and 401 JP duplicate public variables whose generated
> types differ.  The project can mechanically choose one definition per name
> and build a normalized semantic candidate; that value is not itself
> CompCert's linked semantics.  A separate source-owned cleaning now has
> kernel-checked US and JP inhabitants showing that CompCert's unmodified
> `link_list` returns each official cleaned target.  This is a syntactic
> structural-link result, not a semantics-preservation result.  The declaration
> and storage audits isolate a concrete incompatible US anonymous-tag choice,
> described below.  Actual-target global-reference classification and CompCert
> external-call injection transport are proved.  The project now also has a
> whole-AST rewrite function, concrete strong-definition membership, generic
> relocation-aware initialization, injected environments/continuations/states,
> pointer and scalar-expression compatibility, and a lockstep composition
> theorem.  The concrete public/name-based memory instances, the US
> expression/internal-step simulation, and writable `EF_external` frames remain
> open.  No retail conclusion below is derived merely from these components.

> **Execution-model boundary:** all current run witnesses use defined CompCert
> Clight steps.  A successful invalid load/store, invalid function target,
> arbitrary code execution, or continuation after source undefined behavior
> cannot appear in that relation; raw DMA and interrupts are absent unless
> modeled explicitly.  This is not proof that the N64 ROM cannot perform such
> behavior.  CompCert does not target N64 MIPS, and its own documentation says
> generated machine code may continue after a source operation becomes
> undefined.  Defined in-bounds aliases, wrong logical object slots, stale pool
> bytes, ordinary scheduler/owner/lifecycle effects, and retargets to other
> registered functions remain in scope; unresolved externals need exact
> effects.  The checked distinction and route consequences are in
> [`docs/compcert-execution-scope.md`](docs/compcert-execution-scope.md).

> **Newest clean-JP gap-installer result:** no clean retail installer for the
> timer-131 `>=960` Graphics/Object Y gap has been found.  The new checked
> reduction is stronger than a movement-speed bound.  At the collision phase,
> an arbitrary sequence of writes already refined to affect
> `MarioState.pos` alone leaves the old collision Object
> and Graphics samples unchanged, so it preserves their pre-existing gap
> exactly.  It can carry a gap, but cannot create one from synchronized entry.
> Ordinary motion, platform displacement, and PU-scale motion are covered only
> at phases for which that State-only dataflow premise has been established.
> The audit now uses `CleanJPArea1GapAuditState`, which fixes JP and **SSL Area
> 1 (the exterior)**,
> clear target bits, coherent save state, well-formed pools/lists, no pending
> interaction or warp, and a well-formed input history with no entry A edge.
> It is deliberately separate from the Area-2-only `CleanPyramidEntry`.
> Reaching this audit state from an ordinary castle entry is a separate
> optional reachability problem, not part of the scoped gameplay proof.
>
> The generated JP Clight census now computes the direct writers of
> `MarioState.quicksandDepth` across all 38 selected translation units.  It
> also inventories, by generated unit, direct assignment-bearing functions:
> 33 for `pos[1]`, 215 for raw-data slot 7, 180 for raw-data slot 10, and 15
> mentioning `throwMatrix` on the assignment LHS.  A second all-unit receipt
> proves the receiver annotations: `pos[1]` is on `MarioState`,
> `GraphNodeObject`, or `PlayerCameraState`; raw slots 7/10 are on `Object`;
> and `throwMatrix` is on `GraphNodeObject`.  This is static source typing, not
> proof that a live receiver aliases Mario.  A source-shaped relation that excludes the late
> long-jump writer preserves nonnegative depth from zero.  The source path
> found that can make the depth negative is a late `ACT_LONG_JUMP_LAND` frame;
> the sole ordinary constructor of `ACT_LONG_JUMP` is the
> `INPUT_A_PRESSED` branch of `act_crouch_slide`.
>
> The timer-131 producer audit now rules out the other two obvious ways to
> make the rendered Mario position arbitrarily high in normal stock Area 1.
> Across both versions, all 40 behavior commands targeting the graphical Y
> offset are fixed `SET_FLOAT` commands no larger than `+240`, while even the
> lowest timer-131 top retry needs `+632`.  Mario's own behavior has no offset
> command, starts from zeroed raw words, and enables bit 8 rather than the
> dangerous bit 0.  The only full cross-object rendered-position copy is the
> Chuckya/King Bob-omb anchor chain, and neither parent is selected or directly
> spawned by the audited Area-1 sources.  A deliberately non-stock `+1160`
> offset is nevertheless accepted at warp-center X/Z, showing that the
> geometry is possible and that the remaining in-scope question is live
> provenance: object identity and lifetime, faithful behavior dispatch,
> dynamic spawn closure, defined aliasing, and concrete external effects.
> Out-of-bounds/ACE/DMA variants are outside the Clight run and therefore
> deferred without a retail verdict.
> The follow-up now checks the full ordinary direct-call graph, not merely
> Mario's three callback bodies.  In both versions that graph reaches none of
> the direct flag or offset writers, including writes spelled through another
> raw-data union view, and Mario's `OR 0x100` command provably leaves bit 0
> unchanged.  The normal spawn/list source chain also identifies where
> `gCurrentObject = gMarioObject` must come from; proving that equality in live
> memory across the slot lifetime remains the decisive bridge.
> The next refinement checks the exact SSL `INIT_MARIO(..., &bhvMario)` command
> and follows that value through the spawn record and constructor.  It also
> proves safety across any finite sequence of ordinary framed or distinct-slot
> writes, rather than only one write.  Consequently a corruption-style Ink
> installer needs one identifiable live event outside that relation; the proof
> does not yet show that every retail step belongs to it.
>
> The official cleaned JP link now has a real initialized-memory witness.
> Resource-bounded unit receipts prove initializer alignment, and the checked
> relocation inventory proves every `Init_addrof` target resolves.  The exact
> `thread5_game_loop` lookup and first step are closed; these remain
> source/refinement evidence rather than the scoped gameplay root.  Twelve
> further focused receipts now
> construct the complete official-JP Area-1 symbol-address bundle at object
> slots `0`/`1` and prove limited global-block separation.  This supplies no
> live memory contents or execution.
>
> The bilateral proof now goes further than that census.  It checks all nine
> landing descriptors, both action dispatches, the airborne landing edge, and
> the descriptor-driven landing callback.  Its finite first-occurrence kernel
> proves that a stock entry trace cannot acquire either long-jump action
> without an A-edge event or a forged-state install.  Defined descriptor
> corruption, callback/interaction retargeting, MarioState aliasing, specified
> external mutation, and unclassified valid writers remain explicit escape
> classes; out-of-bounds variants require a separate machine model.
> Refining every clean linked retail step into this kernel is still open, so
> this is not yet the whole-program action-provenance theorem.
>
> The audit also found a real conditional escape that prevents an unsound
> per-frame bound.  The old prepared-depth example, `-2.650000095f`, is valid
> but is not the strongest writer.  The moving dispatcher samples quicksand
> before movement; the landing body samples the floor again after
> `perform_ground_step`.  Crossing from ordinary floor onto quicksand in that
> frame therefore gives exact source-shaped binary32 depth `-0.5f` at timer 4
> or `-4.0f` at timer 5.  With no Graphics reanchor, the proved integer model
> needs 240 four-unit sinks for a 960-unit rise.  The same 240-step recurrence
> in live binary32 memory is a named remaining obligation.
>
> **Can a zero-A run reach the required late long-jump state in the first
> place?**  Inside the finite source-shaped no-edge/no-forgery transition
> kernel, no.  The
> abstract clean pyramid contract begins in airborne warp action `0x1932`.
> A separate, not-yet-executed concrete entry-memory postcondition assumes/
> fixes timer zero and depth `+0.0`; the ordinary Area-1 entry-memory
> postcondition separately fixes spawn-spin-airborne `0x1924` with
> timer/depth zero.  Of the nine stock landing descriptors, only long
> jump's six-frame descriptor reaches the dangerous timer-4/5 body.  The full
> generated US/JP census finds exactly one ordinary constructor of long jump:
> `act_crouch_slide` tests `INPUT_A_PRESSED` before installing it.  Long-jump
> landing is produced only by the long-jump action itself.  In the kernel,
> holding A before the interval is insufficient because the constructor is
> classified as an A-edge event and the abstract clean contract fixes a
> different initial action.  The live Controller-to-Mario input-bit execution
> that justifies this classification remains a separate obligation.
>
> That is a proved finite-kernel/clean-boundary exclusion, not yet a proof of
> linked source execution or total ROM memory safety.  The live step still has
> to refine the source assignment
> from `Controller.buttonPressed` to Mario's `INPUT_A_PRESSED` bit.  A
> corrupted action, input, or timer, a mutated landing
> descriptor or callback, an aliased/out-of-bounds store, or an external write
> could bypass the ordinary transition graph if reachable.  No such clean SSL
> writer has been found; proving that none is reachable is the remaining
> whole-linked-program obligation.  Therefore the star/dialog/PU work below
> describes what the payload would do *if a forged installer exists*, rather
> than an ordinary zero-A route to the payload.
> A Parallel Universe can alter surface lookup and position without thereby
> writing Mario's action, timer, or landing descriptor; it helps create this
> payload only if paired with a concrete memory-corrupting writer, which has
> not been found.
>
> The forgery audit also rules out several tempting shortcuts.  Merely forcing
> a timer to 4 or 5 is insufficient for any normal four-frame landing: the
> cancel check returns before the dangerous body.  Its descriptor's frame
> count would also have to be changed.  All nine descriptors and the
> interaction callback table are writable generated-Clight globals, but the
> generated C
> contains no direct assignment to them; normal code only takes each
> descriptor's address in its matching wrapper.  Under CompCert memory, an
> action change requires a store into the same allocation with overlapping
> bytes.  What remains is the harder ROM question of whether an actual
> flat-address OOB/alias or external effect can create such a store.
>
> `ACT_READING_AUTOMATIC_DIALOG` is a cutscene action, not an arm of the
> automatic dispatcher that clears quicksand depth.  The bilateral generated
> checks find no recognized direct depth write or State-to-Graphics copy in
> its handler.  When the finite model is supplied the same surviving depth, it
> can hold the open-dialog state for any requested number of frames and shows
> how accumulation follows.  Proving that the live constructor and helper
> calls actually preserve the depth cell remains open.
>
> The four real ground quarters have now been executed in authenticated US and
> JP retail runs from an injected late-long-jump fixture.  Every run performed
> four lower-wall, upper-wall, floor, and ceiling queries; walls and ceilings
> were null, and all four selected floors were static shallow-moving quicksand
> surfaces with no object owner.  Both versions ended at binary32 Z bits
> `0x4599198b`, about `4899.19287`, and Y bits `0xc0fc4011`, about
> `-7.88282061`.  This corrects the earlier handwritten endpoint `4900`: the
> later quarters are shortened by the quicksand plane's normal Y.  The run
> proves the conditional engine execution, not clean reachability of the
> injected long-jump state.
>
> The prepared pre-timer-3 case was then run for one real successor frame,
> without another memory injection.  US and JP again agree: four more ground
> quarters select static shallow-moving quicksand, every wall and ceiling
> result and the platform pointer is null, and no A edge is observed.  Mario
> ends at raw Y `-19.1441002`, Z `4949.92139`, Graphics Y `-16.4941006`, and
> exact depth `-2.6500001`.  In other words, the negative payload really does
> survive the next physics frame in this prepared retail execution.
>
> The finite freshly spawned 100-coin-star lifecycle model is also narrowed,
> supported by generated source-shape receipts.  In that model, its action-2
> frame clears time stop without installing the hitbox; Mario receives an
> unstopped update before the later level-object update makes the star
> collision-eligible.  The modeled update does not eliminate both fixtures. From
> post timer 4, it first raises `-0.5f` to `1.35f`, then the timer-5 landing
> body writes the exact `-2.65f` payload.  From post timer 5, timer 6 exits
> before that body and the same action loop reaches stationary processing,
> ending positive at `1.85f`.  The finite prepared star orbit starts at its
> `spawnY+250` home and settles five units below it, at `spawnY+245`.  Mario
> therefore needs at least an 85-unit height gain for overlap.  Linked
> binary32/12k motion refinement, that height gain, and an older
> pre-positioned tangible star are not yet excluded.  For the particular
> prepared star and successor-frame coordinates, however, the checked
> binary32 words put Mario's modeled raw hitbox top more than 96 units below
> the star's first-hitbox Y; even Graphics Y is lower.  So the finite timing
> model preserves the payload, while its 160/50-hitbox arithmetic pairing is
> vertically separated.  This calculation composes two independent finite
> artifacts; live hitbox fields, the overlap routine, and the star-spawn trace
> have not yet been executed in linked Clight.
>
> Finally, in the finite untransported-dialog model, amplification changes the
> vertical Graphics gap but does not transport raw Object X/Z from X=`5760`
> and Z about `4899` on F
> (`4949.9` on the isolated G replay) to the upper warp at `(-2048,-1024)`.
> The X-only exclusion applies provided no intervening raw-X writer is added.
> Separate generated source-shape and arithmetic checks identify a stationary
> post-dialog sanitizer and the idle/walking Graphics reanchor helpers; linked
> branch/helper execution remains open.  A live
> platform moving State/raw Object during the dialog, warp
> relocation/substitution, collision
> aliasing, or another raw-coordinate writer remains the required handoff into
> timer 131.  Thus the mechanism remains conditional; no clean zero-A
> installer or target-star counterexample has been found.  The exact source,
> collision, and remaining-witness breakdown is in
> [`docs/notes/negative-quicksand-unreanchored-dialog.md`](docs/notes/negative-quicksand-unreanchored-dialog.md).

> **Ordinary entry and zero-A composition:** the ordinary Area-1 painting
> entry is node `0x0A` with `bhvSpinAirborneWarp` and
> `ACT_SPAWN_SPIN_AIRBORNE`, not the no-spin Area-2 entry action.  The new
> source/layout kernel and symbol-bound postcondition synchronize State,
> collision Object, and Graphics, while correctly preserving the incoming JP
> global platform pointer.  Executing that postcondition from the castle route,
> including external frames and pool/list ownership, remains open.  A separate
> zero-edge relation follows actual `Clight.step2` states and tests the live
> `buttonPressed` A bit, allowing A to be held.  Its program, controller
> address, and entry are parameters, so it does not itself prove that the run
> is clean or JP retail.  Its global `<960` theorem is conditional on total
> state projection and classification of every reachable step; the latter is
> exactly the unresolved writer/refinement premise.
>
> The postcondition consequences are now sharper.  At ordinary Area-1 entry,
> all three coordinates agree across Mario State, the collision Object, and the
> Graphics anchor; the action is spin-airborne; and quicksand depth is the
> binary32 value `+0.0f`.  The generated static data contains 46 Area-1 macro
> objects in each version, every preset lookup is in bounds, and neither those
> objects nor the Area-1 script installs an ordinary door or warp door.  Thus
> the static roots do not directly install either door.  The earlier
> direct-source condition is too strong for the real object graph: the
> pyramid-top callbacks mention normal pillar-detector and fragment children
> that do not occur in those direct lists.  Rocq now states the correct
> transitive spawn-closure boundary and proves its generic exclusion lemma.
> The complete generated spawn graph, door non-reachability, linked entry
> execution, and alias/corruption closure remain open.
> A separate complete JP syntax census finds eight bodies that directly assign
> a field named `action`.  None also embeds the long-jump constant; the only
> direct ordinary long-jump constructor remains the A-edge-guarded
> `act_crouch_slide` call.  Because a field-name census does not establish the
> receiver or follow arbitrary indirect values, it narrows but does not finish
> the live action-provenance proof.
> The depth sign proof is no longer only an integer approximation.  An exact
> CompCert/Flocq binary32 candidate relation now covers the sink-visible reset,
> clamp, increment, cap, ordinary-landing, paired quicksand-jump, and death
> updates.  From binary32 `+0.0f`, finite non-overflowing steps in that relation
> cannot make the C comparison `depth < 0.0f` true.  The relation is handwritten
> and imports no generated writer AST.  Timers 4 and 5 are deliberately outside
> it.  The later split-floor audit proves that timer 4 can be `-0.5f` and timer
> 5 can be `-4.0f` when the updater sees ordinary floor but the ground step
> enters quicksand.  The linked proof must still classify every actual store,
> establish
> the finite bounds, and prevent an observation between quicksand-jump's raw
> subtraction and immediate clamp.
>
> A suspected fire-particle writer was checked and rejected.  Mario's render
> callback guards on `obj == gMarioObject`, but passes `obj->prevObj` (the flame
> object) to both position helpers.  It moves the flame, not Mario's Graphics
> anchor.  The remaining positive direct forms are the normal shell offsets
> (`+42` air, `+45` ground), bounded water visuals, and explicitly modeled
> writers; none reaches `960` inside the checked relation.
>
> A hash-gated JP probe adds bounded evidence only.  Its input plugin performs
> no game-memory writes, and the zero-A schedules observed no A edge, no A-down
> frame, and no controller A frame.  The ordinary/B-interaction schedule's
> maximum positive Graphics/Object gap was `0`; the deliberate quicksand path
> moved Graphics downward, not upward.  The probe uses an externally enabled
> level-select bootstrap, so equivalence of its post-entry state to an ordinary
> castle entry is not proved.  It samples at controller-poll boundaries, so it
> cannot exclude a split created and consumed entirely within one frame, and
> finite schedules are not exhaustive.  Modes 4--6 nevertheless found a real
> zero-A elevation primitive: jumping box into repeated Tweester captures.
> One, two, and four captures reached synchronized peaks of `1550.83582` and
> `1654.52148`, but never produced a positive gap, used the upper warp, or put
> Mario on the pyramid top.  Mode 7 later reached two eastern pillar detectors
> with zero A.  Modes 9 and 10 each ran once for 8,000 frames, reproduced that
> checkpoint and pointer-identified southeast/northeast Tweester relays, then
> reflected from the central pyramid and died before the west Tweester or
> western detectors.  Neither started the top or sampled a positive gap; these
> are bounded schedule failures, not an impossibility result.  See
> [`proofs/CleanJPGraphicsGap.v`](proofs/CleanJPGraphicsGap.v),
> [`proofs/JPQuicksandDepth.v`](proofs/JPQuicksandDepth.v), and
> [`docs/notes/clean-jp-graphics-gap-source-audit.md`](docs/notes/clean-jp-graphics-gap-source-audit.md).

> **Newest timer-131 result, in software-engineering terms:** the JP candidate
> now has a real conditional integration trace across the difficult lifetime
> boundary.  Think of `gMarioPlatform` as a cached pointer to a pool object.  A
> debugger supplies the still-missing precondition: on exactly the useful
> Area-1 frame, collision sees Mario's old Object at the upper warp, the first
> State floor query misses, and the Graphics retry lands on the live spinning
> pyramid top.  Retail code then owns the rest of the tested path: it caches the
> top pointer, frees the top during its explosion, retains the stale slot through
> the delayed area change, leaves that slot 47 allocations deep at the first
> Area-2 platform application, and applies the retained yaw payload to Mario.
> This is analogous to a reproducible integration test that begins after an
> unimplemented input adapter: it validates the downstream lifecycle and effect,
> but it does not show that normal program inputs can reach the injected state.
>
> The clean-entry side now follows one real original-JP run from the accepted
> level-select clear through Area-1 loading, the separate Area-object and Mario
> spawns, Mario initialization, and Mario's first behavior update.  Read-only
> watchpoints cover both Mario pointers, slot 67's behavior/active/list fields,
> both player-list links, and the two dangerous words.  Exactly 19 stores occur:
> clear resets old pointer/list metadata; Mario's allocation makes the first
> zero writes to both dangerous words; spawn and initialization install slot 67,
> `bhvMario`, both Mario pointers, and the one-object player list; then the first
> behavior pass writes the safe flag `0x100`.  No instruction writes a dangerous
> flag or nonzero graphical offset.  The runner rejects any changed or reordered
> store, and Coq replays the receipt from arbitrary old watched values to derive
> the entire recorded endpoint while checking every protected write safe.
> A second exact receipt asks which conservative outside-call candidates really
> run.  It observes 73 successful allocations and one ordinary area-loading
> sound call, but no allocation-failure cleanup, object unload, or source-sound
> call.  Coq checks the machine branch and call targets, so the source-sound
> candidate is genuinely absent from this entry and needs no effect assumption;
> the surface square-root candidate was not eliminated by this test.  The
> reached sound call's first entry stack pointer is also recorded as
> `0x80207128`.
>
> A separate all-path check now reads the actual JP instructions for all three
> outside routines and every sound helper they can call.  Across 332
> authenticated instructions it finds exactly 42 stores and eight direct
> calls, no indirect or linking escape, and no branch leaving its routine.
> `sqrtf` cannot write memory.  Every sound store goes only to sound data,
> fixed music data, or a bounded call stack; the recorded live stack is far
> below Mario's object pool.  This proves that none of the three pre-entry
> outside-call candidates can change Mario's slot or either dangerous word,
> without pretending the IDO binary is a CompCert program.
>
> That completes the watched-memory classification for this authenticated retail
> execution, including machine code reached indirectly or through an outside
> routine.  The project now deliberately accepts this authenticated receipt as
> the Timer-131 entry theorem: it fixes the checkpoint order, the two distinct
> spawn calls, Mario's slot/list/behavior identity, and both safe values at the
> endpoint.  This does not magically turn the IDO-built retail program into a
> CompCert run.  An IDO-MIPS-to-Clight simulation and a reconstructed Clight
> prefix remain possible strengthenings, but they are no longer route-closing
> requirements; the outside-call effects are already closed directly at the
> retail-MIPS boundary.  The required proof now starts at the accepted endpoint
> and checks every later step through
> timer 131.  Ordinary castle entry is not required because level select is the
> accepted boundary.
>
> Starting at that accepted endpoint, two new exact receipts now check the
> later interval.  The neutral one follows 131 ordinary updates.  The
> route-specific one makes one clearly separated write to the pyramid top's
> own pillar counter in slot 61, then follows 144 real game updates until the
> top reaches spinning action 1, timer 131.  Mario remains slot 67 throughout:
> both Mario pointers, the player-list ring, normal behavior, safe `0x100`
> flag, zero graphical offset, behavior commands, and dispatch table all stay
> unchanged.  Every watched write is the same collision-reset halfword at
> offset `0x76`, immediately after and disjoint from `activeFlags` at `0x74`.
> The spinning interval includes 93 allocation calls, 71 unloads, 71
> source-sound calls, and more than a thousand HUD print calls without any
> protected write; the source-sound body also has the independent all-path
> machine frame.  The two debug-specific print callsites never execute.
>
> So the selected conditional spinning timeline has been closed and contains
> no corruption producer.  That is narrower than a universal impossibility
> proof: the single pillar-counter fixture still needs replacement by the
> known clean pillar path, other controller/lifecycle histories need a common
> protected-step theorem, and the debugger watchpoint mechanism is not yet a
> formal semantics of the whole N64.  A differing overlapping write or
> identity change in that universalization would be the first real producer.
>
> The exact timer-131 collision calculation matters.  The old home-pose sample
> `(-2048,1791,-1024)` is rejected by the raised and rotated top.  A corrected
> low-side sample `(-1641,1456,-783)` is accepted, but Mario loses top support
> before the explosion, so that sample cannot carry the pointer to Area 2.  The
> strict-interior midpoint `(-1862,1778,-902)` is accepted at returned floor Y
> `1783.940186f` and stays top-supported through the explosion and delayed warp
> in the conditional JP run.  It requires Graphics to be at least `960` units
> above any warp-overlapping Object, or exactly `1010` units above an Object at
> the warp centre.  The currently modeled `45`- and `208`-unit writer envelopes
> cannot supply that gap, but applying either envelope to every reachable retail
> writer remains open.
>
> A timer sweep and its Rocq arithmetic classification make timer `131` the
> unique tested `0..150` timing with the useful shape: earlier installations
> freeze before the explosion and lose the payload during destination setup;
> later installations permit another Area-1 update that clears the pointer.
> This uniqueness is proved for the observed affine schedule, not derived from
> a complete linked Clight execution.  At the injected boundary, a zero-A
> controller continuation has now consumed all five Puzzle triggers, spawned
> the Act-6 star, and used a B/Z slide kick to overlap it by one vertical unit.
> The authentic JP save byte changes from `00` to `20` while every A counter
> remains zero.  No clean retail installer for the `>=960` three-view gap is
> known, so this is neither a stock-game counterexample nor a completed
> impossibility proof.
>
> The destination-side arithmetic is now tied to the official linked JP object
> layout.  A pool object is 608 bytes, so observed slot 61 begins at offset
> 37,088; the twelve payload-witness ranges listed by the fixture stay within
> that object.  Extracting the complete generated access set is still open.
> Exactly one cleaned JP declaration is retained for `_gObjectPool`, and it is
> an exact writable, nonvolatile 145,920-byte global.  A focused proof
> chain now resolves the exact generated variable in the official cleaned
> global environment and proves that the constructive initial memory grants
> `Cur Writable` permission to the complete slot-61 range
> `[37,088,37,696)`.  The watched CompCert pointer is the resolved pool block
> plus 37,088.  If the linked run
> realizes the observed duplicate-free sequence of
> 131 teardown pushes followed by 84 destination allocations, the first 84
> pops cannot select slot 61 and it is still at depth 47.  Writes confined to
> the popped slots preserve slot 61's payload.  The remaining proof must derive
> that sequence, establish the initial payload bytes and preserve them into the
> relevant current memory, bind the runtime-loaded pointer and allocation
> epoch, prove terrain frames, execute first-apply loads from Clight small steps,
> and connect the selected Clight result to retail semantics.
>
> The installer case split is also narrower.  The formal stock model excludes
> State-first selection at the fixed upper warp, fixed stock-top co-location,
> every one of the fourteen other fixed stock owners, post-commit selection
> that leaves the final query in the warp region, and a frozen pointer whose
> history already has stock provenance.  It does not exclude moving or cloning
> geometry, moving the final query onto an owner, non-stock/corrupt owners, or
> an unmodeled query skip.  Ink's graphical retry therefore remains logically
> possible but has not been reached from clean retail input.
>
> The newest temporal proof removes one important ambiguity in that last
> sentence.  An active frame may move Mario's collision Object, but the final
> platform query then recomputes the pointer at the new Object sample.  A
> frozen/query-skipping frame carries the old pointer only by carrying the same
> Object sample with it.  US spawn clears the pointer, and JP retention begins
> at one of three checked inbound nodes, none of which is the upper warp.  An
> arbitrary finite composition of those stock shapes therefore cannot produce
> a non-null pre-apply pointer while the Object is at the upper warp.  Any
> survivor must now expose a different query/current sample, out-of-model
> geometry, a noncanonical slot or epoch, an unclassified owner, retained
> inbound transport, or an unframed/aliased transition.  This is still a
> theorem of the checked temporal projection, not yet a proof that every retail
> frame inhabits it.
>
> The generated source narrows one more version of "moving geometry."  The
> stock upper warp's native body contains no direct X/Y/Z access or write.
> The stock pyramid top does write X and Y, and a separate binary32 check of every
> spinning timer from 0 through 150 keeps it within X `[-2087,-2007]`,
> Y `[1536,1879)`, and fixed Z `-1023`; timer 131 agrees with the detailed
> surface calculation.  But the mirror is not yet linked to every live Clight
> step, so it does not prove that neither stock object moves into the other.
> An aliased writer, another behavior, a clone, or an object-identity/epoch
> failure could also escape the checked bodies.

> **Newest turning-animation result:** Marbler's `0xBD` observation is a real
> numerical coincidence, but it is not an animation-induced upwarp.
> `MARIO_ANIM_TURNING_PART2` is animation-table index 189.  The different
> field `MarioState.unkB0` is also initialized to 189 and is copied to
> `AnimInfo.animYTrans` when the animation changes.  The pinned Part-2 asset,
> like all 209 pinned Mario animations, has `animYTransDivisor = 189`.
> The renderer therefore computes exact binary32 `189 / 189 = 1`.  This is a
> normal rendering scale, not “add 189 to Mario's Y.”
>
> A useful software analogy is that the same integer appears once as an array
> index and once as a normalization constant.  They never feed back into each
> other.  `load_patchable_table` bounds-checks the array index and, when
> necessary, copies the selected animation bytes into a dedicated cache.  It
> does not patch code.  `set_mario_animation` then writes animation metadata;
> it does not directly write the physics position, raw collision-object
> position, or graphical base position used by the OOB fallback.
>
> This project now translates `rendering_graph_node.c` for both US and JP, so
> the sole `animYTrans` consumer is inside the generated boundary.
> `geo_set_animation_globals` writes a renderer-global ratio, and
> `geo_process_animated_part` uses that ratio to construct child matrices.
> Part 2's visual root Y is bounded to 21.75–71.5 world units relative to
> `header.gfx.pos`; the renderer does not assign that anchor.  Its X/Z root
> values are zero, and its flags contain no physical animation-translation
> bit.
>
> The reported turning correlation still has a source-backed explanation.
> In the ordinary non-stopping turning handler, `perform_ground_step` runs
> before the code compares `forwardVel` with `18.0f` and selects Part 1 or
> Part 2.  A floor snap can therefore happen on the same visible turning
> frame while preceding the animation call.  The finish-turning handler uses
> the opposite local order, but the animation setter still preserves the
> three gameplay coordinate views; its later ground step remains the possible
> displacement source.
>
> `TurningAnimation.v` proves the binary32 ratio, asset arithmetic bounds,
> fresh-frame behavior, absence of physical translation flags, exact visual
> extrema, and a metadata transition that cannot create Ink's
> State/Object/Graphics-anchor split from synchronized input.  Generated-AST
> receipts separately check the exact `18.0f` selector with IDs 188/189, both
> ground-step orderings, the `unkB0 -> animYTrans` dataflow, loader footprint,
> and renderer ratio for US and JP.
>
> The proof deliberately does not claim that animations globally cannot
> affect gameplay.  Door/ending cutscenes use an explicit animation-root
> position helper, pole actions read animation Y, and a rendered hand matrix
> can update the held-object-last-position used by later throw/drop code.
> None is a Turning-Part-2 upwarp path: turning calls no physical root-motion
> helper, Part 2 has no corresponding flags, and the walking path drops a held
> object before selecting turning.
>
> There is one formal abstraction counterexample.  If an unconstrained model
> allows the animation DMA destination to alias Mario's position, loading
> bytes can change that position.  Rocq records this one-cell alias witness;
> it is not a retail state.  The linked proof must still establish the normal
> `0x4000` animation-buffer separation, converter/table mapping, DMA frame
> rule, and concrete before/after coordinate projection.  Thus this tranche
> eliminates the proposed `0xBD` mechanism at the checked
> source/arithmetic/model boundary, while leaving the real
> `perform_ground_step`/surface-selection obligation open.  See
> [`docs/notes/turning-animation-upwarp.md`](docs/notes/turning-animation-upwarp.md).
>
> **Newest Ink fallback result:** the engine can observe three different Mario
> positions during one frame.  Object collision reads the old raw Object
> position; ordinary geometry reads MarioState; and, if that State has no
> floor, the null-floor graphical fallback (often described informally as the
> OOB fallback) copies the graphical position into MarioState and retries.  It
> is not specific to the wall-push routine; a wall push is only one candidate
> producer of the floorless State.  This makes Ink's scheduling idea
> conditionally real: an Object at
> Area-1 warp node `0x1E`, a floorless State, and Graphics over a loaded
> pyramid-top-owned surface can cache the warp and later copy the top-side
> coordinates into MarioState in the same update.
>
> `InkFallback.v` proves local and Parallel-Universe conditional pipeline
> coordinate witnesses for that schedule.  It checks nearby generated Area-1
> mesh receipts at State `(-2200,768,-1024)`, excludes all fifteen modeled
> stock dynamic owners for that first query, and proves that a generic
> top-height retry with Graphics Y in signed-16 range needs at least 385 units
> of upward Graphics/Object
> separation.  Either exact proposed prestate needs at least `973` units.  It
> also proves that any sequence already refined to State-only preserves Object
> and Graphics, so such writes cannot create their split from synchronized
> input.  The disappeared-action snap is followed by an
> unconditional quicksand sink; the projected Graphics-position write cannot
> change the Object coordinate later copied from State, while the conditional
> `gfx.throwMatrix` write still needs a memory-provenance proof.  The first
> sink specification was false: an unrestricted execution could pass the
> first return and call the function again, and a linear interval check missed
> a concrete 32-bit pointer-wrap alias.  The repaired statement stops at the
> first matching return and compares the individual modular memory cells, but
> remains unproved.  After the
> copy, later object lists and deactivated-object unloading occur before the
> final platform query.  That order admits a separate explosion-frame
> inactive-slot candidate, but does not yet prove free-list membership or
> retained concrete-surface identity.  The two closed coordinate witnesses
> use the zero-yaw home top and floor Y `1791`; they do not instantiate the
> later translated/rotated explosion pose.  The source audit uses
> `45` as the dry route-specific visual-offset target, while `208` is a
> deliberately conservative modeled writer relation.  Both are below the
> required gap, but neither covers retail until reachable writer/action state
> closure is proved.
>
> **Checked fatal-latch result.** `RetailFatalLatch.v` now proves that, for
> every trace admitted by the source-audited latch event system, once the
> both-`NULL` frame has accepted death or game-over, the fatal operation either
> remains pending or a terminal/reset barrier destroys the old
> `ACT_DISAPPEARED` continuation.  No such abstract trace accepts the upper
> object-warp request.  The initial modeled state records the exact audited
> chronology: fatal timer `48` is installed, cached warp contact selects
> `ACT_DISAPPEARED` with low count `2`, action dispatch is skipped because the
> floor remains `NULL`, and the normal-play tail reduces the fatal timer to
> `47`.  The three abstract floor outcomes are:
>
> | State query | Graphics retry | Source-ordered consequence |
> | --- | --- | --- |
> | floor | not run | no fallback and no fatal request; cached warp may select `ACT_DISAPPEARED` |
> | `NULL` | floor | Graphics is copied to State, no fatal request; cached warp may select `ACT_DISAPPEARED` |
> | `NULL` | `NULL` | death/game-over is requested before interaction and is stored if the latch is empty; the cached warp may still select `ACT_DISAPPEARED`, but action dispatch is skipped |
>
> “Failsafe to Mario’s position” is therefore not a separate first branch:
> the first branch simply keeps the post-wall State sample.  Also, “trigger
> the warp” initially means selecting `ACT_DISAPPEARED` with a two-tick
> argument, not changing areas immediately.  The successful Graphics retry
> performs only the first tick.  A second floor-supported Mario update is
> required to request node `0x1E`.  If the following update instead has both
> floor queries return `NULL`, an initially empty latch stores the fatal
> operation before the skipped action could issue that request.  The
> clean-entry model now separately records that
> the generic delayed-warp cell is empty, instead of conflating that condition
> with “no delayed star exit.”  Deriving an empty latch at this exact live
> Area-1 call boundary remains part of the Clight scheduler refinement.
>
> `retail_fatal_latch_source_kernel_checked` separately packages generated
> US/JP checks for the guarded first writer, the exact five-function
> direct-writer census for `sDelayedWarpOp` inside the generated
> `level_update.c` translation unit, absence of an explicit address-taking use
> in that unit, clear-site call-presence/callee-order plus separate
> clear-presence anchors, normal-play call order, and the packed SSL Area-1
> death-warp record.  The clear-site receipts do not relate assignment position
> to those calls, and the packed record receipt does not prove command
> decoding, destination selection, or transition execution.
> `over_permissive_clear_accepts_upper_counterexample` demonstrates why
> allowing a clear while retaining `ACT_DISAPPEARED(1)` would be unsound; it is
> a counterexample to the old abstraction, not a retail-game witness.
>
> This closes the finite scheduler invariant, not its linked-program
> refinement.  The project has not yet proved that a concrete linked US or JP
> Clight run reaches the both-`NULL` boundary with an empty latch, that every
> concrete scheduler step projects to the event system, that each concrete
> clear is followed by reset or object destruction before another Mario
> behavior update, or that linked memory cannot alter the latch outside the
> checked direct assignments.  Neither `find_floor` result nor reachability of
> the required prestate is proved.  The result therefore eliminates the
> both-`NULL` shape only at the checked source/event boundary; the surviving
> Ink shape still requires a non-`NULL` retry floor.
>
> **Newest Goomba-raising result.** A Goomba is a small enemy whose update can
> be partially disabled when Mario is far away.  Think of this as an entity
> whose state-machine callback still runs while its physics component is
> paused.  The attached proposal tries to alternate one active upward physics
> tick with paused reset/rearm ticks.
>
> Source inspection found a real conditional cycle, but also corrected both
> chatbot descriptions.  In the selected branch with no preceding
> notice/random walk jump, the first grounded collision only primes the
> mechanism.  Because walk action runs before attack handling, another branch
> may already have velocity `25` and make that collision productive.  After
> the first productive rise, the repeating ready state is airborne jump action
> `2`, not walk action `0`:
>
> | Phase | State-machine effect | Physics effect |
> | --- | --- | --- |
> | H: hit/depart | cached damage selects attacked action `1` | active gravity changes velocity `25` to `21`, then binary32 updates Y by `Y + 21`; FAR becomes set |
> | F: far reset | action `1` calls the jump initializer, producing action `2` and velocity `25` | old FAR suppresses movement |
> | R: near rearm | airborne action `2` remains action `2`; FAR clears at the end | old FAR still suppresses movement; the endpoint is positioned for the next frame's collision |
>
> Rocq proves the exact CompCert-binary32 velocity result
> `25 + (-4) = 21` and an idealized integer-position `y + 21*n` formula.
> Position growth is not exactly 21 for every binary32 Y, so the selected Y
> `51` runs for 31 and 83 rises are computed separately.  Rocq also supplies a
> checked binary32 fixed point: at Y `2^29`, adding `21.0f` leaves the stored
> value unchanged.  This does not prove that the selected Y `51` orbit reaches
> that fixed point.  For the
> proposed Area-2 Spindel station, the integer hitbox abstraction maps the
> audited Mario-height interval `[2036,2336]` to a Goomba collision band
> `[1961,2496]`, with an idealized final hit to `2517`; the integer-Y `778`
> singleton cannot use it directly.  Linked binary32 collision/addition bounds
> remain open.  For Area 1, the
> post-collision-return H/F/R schedule permits at most 31 productive hits in
> the 91-frame pyramid-top window, while 83 are needed arithmetically.  A
> distinct pre-collision raw-Object writer schedule is not excluded.
>
> The remaining Rocq schemas are deliberately hard to satisfy accidentally.
> They require a functional projection from each concrete Clight state, a
> certificate that the listed trace contains every modeled frame, and no A
> edge at every projected state.  The pre-collision alternative explicitly
> separates the raw-Object writer, collision-cache, Goomba-update, and
> no-collision departure phases; each classified writer is tied to its
> corresponding trace.  At the named phase boundaries, overlap changes only
> across those writer phases and the Goomba position remains fixed until the
> upward update.  Constraining every internal Clight small-step remains part of
> the missing linked instantiation.  Its cached-hit field means that both retail
> `INTERACTED` and `ATTACKED_MARIO` are set; geometric overlap is a separate
> fact.  Every Goomba-carrying raising, transport, and handoff trace preserves
> the same live singleton slot/epoch throughout.  The Spindel-capture schema
> starts only after its moving collision is already loaded, so loading that
> collision is still part of the missing route construction.
>
> The source also confirms the crucial limitation.  Goomba interaction and
> moving-collision loading use full-float object distance; terrain aliasing
> does not teleport a local Goomba into a PU or keep a PU-distant Spindel
> loaded.  Transformed dynamic vertices are narrowed back to signed-16 terrain
> data.  The project has no trace-wide no-A linked witness for the
> one-segment local-load/PU platform capture, either full-float near/far
> scheduling shape, physical singleton transport, or the horizontal height
> handoffs.  Therefore Goomba
> raising is evidence for a conditional engine primitive, not a counterexample
> to the no-A claim and not proof that the second pole can be bypassed.  The
> detailed audit is
> [`docs/notes/goomba-raising.md`](docs/notes/goomba-raising.md).
>
> **Newest wall/floor diagnostic:** Rocq now parses the actual generated US/JP
> Area-1 initializers, obtains all 574 vertices and 962 triangle records, and
> computes the exact 17-wall/26-floor static inventories for cell `(5,7)`.
> At `q = (-2200,768,-1024)`, a pure evaluator computes all four static-wall
> and both static-floor decision lists as all-rejection, then packages
> zero-push and `Area1FloorNull`/`-11000.0f` records.  The record is not an
> independently executed collision traversal.  Its computed trace
> derives 12 first-edge failures, 8 second-edge failures, 5 third-edge
> failures, and one height-buffer failure.  Rocq also checks signed-32
> intermediate bounds and exact CompCert-binary32 planes/offsets for the
> decisive axis-aligned faces.  A separate theorem states the meaningful
> executable premises directly: all four wall decision lists and both floor
> decision lists consist entirely of computed rejections.
> The sole X/Z-accepting face is the Y=1280 roof and is 434 units too high for
> the query allowance.
> At `x=-2199`, the west-wall offset is exactly `-50` and pushes to
> `x=-2099`, where support exists; at `x=-2200`, offset `-51` is rejected.
> Thus the wall push does not create this miss.
>
> An exhaustive integer scan of the radius-187 warp-contact disk at Y=768
> found no supported point pushed to `NULL` and no wall-hit point ending at
> `NULL`.  Every post-wall-null point had no wall hit.  That scan remains an
> external audit result rather than a committed formal verifier.
> `Area1FirstNull.v` now derives the exact static diagnostic.  It does **not**
> yet prove the pure evaluator refines the live Clight allocator/list
> traversal, exclude extra dynamic entries, justify every cast/pointer effect,
> prove a clean trajectory reaches `q`, or prove a continuous-binary32
> neighborhood theorem.  In particular, `q` lies under
> the Y=1280 roof, so ordinary falling from above lands on the roof instead of
> reaching the sample.
>
> **Shell/wall writer result:** the pinned source puts each shell step before
> the `+42`/`+45` literal.  A handwritten two-step normal-frame transition
> threads the first result through an arbitrary State-only interframe write,
> then explicitly reanchors Object and Graphics from current State; under
> that model definition the second 42/45 gap replaces rather than adds to the
> first.  This is not yet a Clight transition theorem.  The ground
> dispatcher calls the quicksand update first; its riding-shell branch clears
> quicksand depth.  The airborne common-cancel path likewise clears depth
> before dispatching the shell-air body.  Those audited continuing source
> paths would block retained negative depth from amplifying the normal `+45`
> and `+42` writes.  Generated-AST receipts check the zero assignments and
> call ordering; linked branch/dataflow execution remains open.  The audited wall
> loop changes collision-record X/Z; its wrapper copies an unchanged Y back to
> the caller.  The shell step uses a local `nextPos`, while the interaction
> push uses State Y plus local X/Z, so neither directly passes Graphics.  A wall
> can still enable the fallback schedule by changing X/Z or making the later
> floor lookup miss; it is not a positive Graphics-Y writer in the inspected
> source.  Exact call arguments, pointer disjointness, every caller, and linked
> execution remain open.  An abstract State-only writer
> therefore preserves rather than enlarges an existing gap.  When cached warp
> contact selects
> `ACT_DISAPPEARED`, the shell action is not dispatched in that frame, so wall
> contact cannot combine with a same-frame shell addition.  These are
> source-shape and normal-form results, not yet a binary32 Clight proof with
> pointer non-aliasing and every caller covered.
>
> An unrestricted binary32 endpoint difference can be about `0.000061` larger
> than the `42.0f`/`45.0f` source operand when an addition crosses a binade;
> Rocq now checks concrete witnesses.  Those witnesses establish no general
> upper bound.  The remaining route-specific work is split into a pending
> exact-arithmetic lemma for Y in `608..818` and a separate live US/JP
> refinement that must derive that range.  The ground tilt helper also performs potentially
> problematic float-to-integer casts before `+45`; a total proof needs a
> reachable speed/yaw bound or compiled-MIPS semantics.  That issue can stop
> the source-level path but cannot increase its Graphics-Y add.
>
> Direct source inspection finds that the interaction table puts warp before
> Koopa shell and that the loop stops after a successful handler.  Thus the
> inspected source path would select the nonfading warp without processing a
> simultaneous shell collision.  Generated receipts check only the table
> subsequence and named bodies; indirect-call/break execution remains open.  The generic
> behavior-interpreter Graphics synchronizer is flag-bit-0 gated, while
> `bhvMario` ORs bit 8 (`0x100`) and does not itself introduce bit 0.  Retail
> allocation clears the raw words.  The complete behavior-data scan now adds
> that Mario has no offset command and every stock script offset is at most
> `+240`, too small for timer 131, but the project has not linked those facts
> through slot reuse and every live mutation.  An over-permissive state with
> bit 0 and a non-stock `+1160` `oGraphYOffset` is an exact accepted-face
> counterexample to closure, not evidence of a retail route. The
> retail-resident debug callback also contains a guarded spawn path.  Proving
> live flag initialization/mutations, the debug guard false, and complete
> writer/action/spawn closure remains open.
>
> **Entry-memory result:** `EntryMemory.v` now proves the generated 32-bit
> US/JP composite layouts, defines a concrete `Mem.load` postcondition, and
> proves a narrower projection from that postcondition.  The important offsets
> are:
>
> | Structure | Field | Byte offset |
> | --- | --- | ---: |
> | `MarioState` (size 200) | action/state/timer/argument | `12 / 24 / 26 / 28` |
> | `MarioState` | `framesSinceA/B` | `40 / 41` |
> | `MarioState` | position / velocity / forward velocity | `60 / 72 / 84` |
> | `MarioState` | floor / floor height | `104 / 112` |
> | `MarioState` | Mario-object / controller pointers | `136 / 156` |
> | `MarioState` | quicksand depth | `192` |
> | `Object` (size 608) | Graphics position / throw matrix | `32 / 80` |
> | `Object` | raw `oPosX/Y/Z` | `160 / 164 / 168` |
> | `Controller` (size 28) | down / pressed | `16 / 18` |
>
> Given the concrete post-entry loads, Rocq proves State, raw Object, and
> Graphics carry the same three binary32 coordinates; action is `6450`
> (`ACT_SPAWN_NO_SPIN_AIRBORNE`); action state, timer, argument, velocities,
> forward velocity, and quicksand depth are positive zero; both
> `framesSinceA/B` are 255; and the throw-matrix pointer is null.  This is a
> real memory-layout/projection theorem, but it is conditional on those loads.
> The project has **not** yet executed `init_mario_after_warp` to derive them
> from a clean retail predecessor.  Exact advertised spawn coordinates also
> require proving the initial floor does not raise Mario.
>
> `OrdinaryArea1EntryMemory.v` now separates a different boundary: ordinary
> entry into the outside desert, where the Area-1 node `0x0A` object is
> `bhvSpinAirborneWarp` at `(653,1038,6566)` and selects spawn type `0x16`,
> action `0x1924` (`ACT_SPAWN_SPIN_AIRBORNE`).  It binds MarioState,
> controller, object-pool, list, free-list, Mario-object, and warp-object
> addresses to named globals and in-range object slots.  From its explicit
> postcondition it proves the three coordinate views are exactly synchronized
> and the depth is binary32 positive zero.  It also proves global-storage and
> distinct-slot non-alias facts.  On US entry the postcondition requires the
> global platform pointer to be cleared; on JP it preserves the predecessor
> pointer because the relevant call is compiled out.  Source receipts prove
> this version split, but the complete `warp_level` execution, castle painting
> routing, behavior-table resolution, external-call frame rules, and live
> object-pool/list graph are still named obligations.
>
> The controller boundary was corrected at the same time.  Controller input is
> read before the area warp, so the residual entry frame already has a live
> `buttonPressed`.  `CleanPyramidEntry` now records current `buttonDown`, the
> actual previous-down sample, and the resulting live `buttonPressed`, and
> requires the source edge formula relating them.  It no longer manufactures
> “no edge” by equating current and previous samples.  The separate no-A
> execution hypothesis must rule out bit 15 of that live pressed value.
>
> This is not a reachable game trace.  The project has not proved that a clean
> execution creates the Object/State/Graphics prestate, that the first live
> floor query returns `NULL`, that the retry selects a loaded top-owned
> surface, or that the post-copy lifecycle preserves the needed Object and
> owner epoch.  The current lifecycle proposition is not a sound proof target:
> its program link and memory projection are underconstrained, and importing
> `behavior_script.c` does not by itself construct the exact indirect call path; external effects and pointer-to-slot/epoch
> linkage are missing, and arbitrary binary32 samples include NaNs.  It must be
> replaced, not merely discharged.  No stock-reachable US/JP retail trace with
> a newly set target bit was found.
> The finite null-platform theorem applies only to pre-existing platform
> origins; it does not eliminate a graphical retry that captures the top
> afterward.  The focused audit is
> [`docs/notes/ink-fallback.md`](docs/notes/ink-fallback.md).

> **Newest first-crossing result:** `FirstCrossingWriterCoverage.v` repairs a
> second abstraction boundary.  The older
> `FirstTargetWriterCoverageObligation` is no longer used: it could name any
> projected event no later than the target without showing that the event
> crossed a route cut.  An unrestricted `CollisionSupportCut` was also only a
> data record; `an_unvalidated_cut_can_place_one_state_on_both_sides` gives an
> admission-free witness whose source and target sides overlap.
>
> The replacement scopes construction and exclusions to a selected
> `TargetCollisionCutFamily` parameter indexed by version, entrance, and
> target.  `FirstValidatedCutCrossingAt` records source and non-target
> membership for the actual projected initial state, then carries the
> source-to-target Clight
> frame, its non-target event, endpoint-local side separation, a matching
> target-event segment later in the same Clight run, and ordered evidence for
> every earlier frame index.  The local separation avoids
> assuming that arbitrary, independently populated `GameState` fields describe
> a coherent collision query.
> `validated_pre_target_first_crossing_writer_coverage` proves, without
> admissions, that such a crossing has one of five projected abstract-event
> labels--ordinary physics, platform displacement, object impulse, collision
> clip, or area reload--or instead changes floor/platform support selection
> while keeping Mario's position fixed.  Ordinary physics is further split by
> whether its
> endpoint is in the local coordinate-cast domain.  Thus the corrected
> no-A interface has six movement/domain exclusions plus a separate seventh
> support-selection exclusion.  Coordinate alias/out-of-bounds is an endpoint
> domain of ordinary physics, not an independent store.
>
> This is abstract writer coverage, not the retail route theorem.  Constructing
> the validated first crossing from linked US/JP execution, connecting the
> target collision to the validated target side, and representing crossings
> that occur within the same frame or subframe as the target collision all
> remain open.  So do all six linked-retail movement/domain exclusions and the
> separate support-selection exclusion.

> **Newest bounded result:** `Area1PlatformExhaustiveness.v` replaces the
> earlier focus on one `[top, box]` free-list prefix with a finite stock Area-1
> platform-owner model.  The source audit finds three pre-apply angular-payload
> classes—pyramid-top yaw, breakable-box dirt triangles, and exclamation-box
> cartoon triangles—with parameterized depth, mist-count, and FIFO-eviction
> variants.  `[top, box]` is therefore one example, not a unique schedule.
> Nevertheless, every stock pre-apply platform-origin case in the bounded model
> has a null platform when Mario's old collision object overlaps warp node
> `0x1E`.  Non-top dynamic owners are horizontally disjoint from the warp; the
> pyramid top is vertically disjoint; static floors carry no object owner; and
> the US clear, retained stock inbound positions, completed-query, and
> frozen-carry cases all reduce to null.  Thus no bounded stock schedule whose
> split starts from a pre-existing platform pointer can create the older
> State/Object platform-displacement split.  This does not exclude Ink's
> null-preapply three-view graphical retry.
>
> `PyramidTopSurface.v` and `PyramidTopPU.v` retain the exact cast, mesh,
> partition-cell, and arithmetic kernel.  The retail cast question is closed
> for the exact candidate inputs: authenticated US/JP disassembly uses
> `trunc.w.s; mfc1; sh; lh`, and Rocq checks its signed-halfword arithmetic.
> The new null result is conditional on the linked Clight state projecting into
> the finite stock-owner/pre-apply relation.  That live-memory refinement,
> actual surface ownership and list selection, alternative constructions outside
> the bounded relation, and JP delayed-warp lifetime remain open.
> `JPSlotLifetime.v` narrows the destination-area question but does not extract
> the reachable memory trace.  The ultimate theorem is still incomplete.

> **Newest stock-projection and Ink-installer result:** the proof no longer
> treats a retained platform pointer as though it were necessarily written at
> Mario's current collision position.  `StockProjectionExhaustiveness.v`
> tracks a modeled write-candidate sample separately from the current sample.
> For a supplied abstract stock-candidate record at the upper warp, it proves
> only that the samples are unequal.  Its separation witness shows why the old
> same-position relation is insufficient; it does not model an actual write,
> pointer retention, physical movement, or a reachable game trace.
>
> The owner cases are exhaustive only after a caller supplies an abstract
> observation, classifier, and canonical map: a modeled candidate; canonical
> identity outside that candidate relation; a recognized kind with a
> different-slot identity or same-slot different ghost epoch; or an
> unclassified owner.  None of this establishes live-list selection,
> allocation ordering, liveness, or classifier soundness.
>
> `PlatformPointerProvenance.v` computes the complete 38-unit source census for
> both versions.  JP's only direct `gMarioPlatform` writer is
> `update_mario_platform`; US adds `clear_mario_platform`, whose generated body
> writes only null.  The update's only source-shaped non-null value comes from
> `Surface.object`.  No generated internal body takes the address of the
> global cell and no initializer relocates a pointer to it.  Existing
> official-link definition provenance is packaged alongside these inventories.
> A linked reachable-store theorem still needs control-flow execution,
> no-alias, and external-call frame invariants.
>
> `Area1QueryScheduleClosure.v` computes intraprocedural generated-AST
> call/guard receipts and proves properties of a separate finite schedule
> model.  In that model, the frame where interaction selects the upper-warp
> `ACT_DISAPPEARED` action has a later query; its two null-callback
> change-area steps abstractly preserve the earlier result.  A changed final
> sample fits the post-wall State sample, Graphics retry, cached-floor Y snap,
> or an unclassified post-copy discrepancy.  Linked execution must still
> prove that these are the live branches and identify or eliminate that
> discrepancy.
> The newest bilateral AST receipt pins the three source values more tightly:
> `gMarioObject.rawData.asF32[6..8]` are loaded into the X/Y/Z temporaries used
> by the immediately following `find_floor` call.  A split resolution proof
> also shows that both selected Clight targets resolve `update_mario_platform`
> to exactly that generated body.  This does not yet preserve the object or
> its three raw cells to the later collision sample.
> If the Graphics retry is still null, geometry input has already requested
> death/game-over.  Cached interaction may still select `ACT_DISAPPEARED` and
> the frame still reaches the final platform query, so that shape matters to
> pointer chronology; it is not a successful Area-2 warp under the separately
> checked fatal-latch model.
>
> `Area1PostPlayerTailSource.v` now narrows the post-copy question with concrete
> bilateral source receipts.  PLAYER is followed in the exact list-order array
> by `[5; 4; 2; 6; 8; 12; -1]`, but this suffix starts only after PLAYER is
> finished.  It is not the entire post-copy tail.  In `bhv_mario_update`, the
> copy is followed by `spawn_particle`; the `bhvMario` script then names
> `try_do_mario_debug_object_spawn`, whose body calls `spawn_object_relative`;
> and traversal may advance to later PLAYER nodes.  These receipts do not prove
> that a guarded spawn occurs or that another PLAYER node exists.  The exact
> `sParticleTypes` identifier lists are
> coupled to 18 behavior definitions whose leading word is `8 << 16`, placing
> every table target in list 8.  The same receipt follows the selected behavior
> field into `spawn_particle` and onward to `spawn_object_at_origin`.  This is
> source wiring, not a proof of loop/index execution, an enabled flag,
> successful allocation, a visited child, a coordinate write, or a reachable
> retail counterexample.  After those
> intra-PLAYER possibilities, the updater proceeds to unload and the final
> platform query.  None of the fixed scheduler/traversal, unload, or final-
> query bodies contains a recognized direct State-position or raw-Object XYZ
> store.  That is useful negative evidence, but it deliberately stops before
> behavior-interpreter callbacks.
> It also stops at the final query rather than covering the complete next-pre-
> collision boundary: `update_objects` subsequently calls
> `try_print_debug_mario_object_info`.  That post-query callback remains an
> explicit residual.
>
> The same file records a concrete reason for that boundary.  A stock SSL
> Area-1 `bhvBreakableBox` root can reach `obj_explode_and_spawn_coins` and
> then `spawn_triangle_break_particles`,
> which requests `bhvBreakBoxTriangle`; the latter's behavior word places it in
> list 12, after PLAYER.  The traversal and allocator syntax makes same-frame
> observation possible, but does not prove successful allocation, callback
> return, or visitation.  A retail impossibility proof must still close the
> intra-PLAYER particle/debug paths and possible later PLAYER nodes, the
> transitive spawn/interpreter graph, receiver and alias identity, external
> effects, unload/pool reuse, and the next frame's warp/instant-warp prefix.
> The abstract `SuppliedFrameTail` theorem does not fill these source gaps:
> its snapshots and origin labels are caller-authored, so it establishes
> neither adjacency of game statements nor retail execution semantics.
>
> Two narrower rank-1 mismatch ideas are now closed.  Across both generated
> programs, the only direct receivers which explicitly designate Mario's raw
> Object and write XYZ are initialization, the butterfly callback, and the
> pre-object-update instant-warp routine.  After phase exclusions, stock Area
> 1's macro, regular-script, and selected special-preset data do not select the
> remaining butterfly behavior.  Separately, merely snapping Mario to the
> ordinary cached floor height Y=`768` while keeping collision X/Z cannot move
> the completed-copy query away from the upper warp, so the finite stock model
> still returns no platform.  This does not cover indirect or forged behavior
> pointers, alias receivers, external writes, lifecycle retargeting, or a
> genuinely different live floor sample.
>
> `Area1CachedFloorSplitWitness.v` now exhibits that cached-floor difference
> explicitly rather than assuming the two samples coincide.  Collision reads
> `(-2048,818,-1024)` and the completed-copy final query reads
> `(-2048,768,-1024)`, so the exact split is `(0,-50,0)`.  At the actual
> Y=`818` query, both generated US and JP cell-`(6,7)` inventories contain
> floor face `(498,500,501)`; the finite source-shaped evaluator says the face
> would hit and computes its height as `768`.  The schedule construction needs
> no A-input premise, but it does not prove clean zero-A reachability, live
> list traversal/selection, or the dispatch/receiver/alias/owner/lifecycle
> refinements.
>
> More importantly, every accepted cached-floor continuation in this model
> preserves X/Z.  This concrete split moves `50` units downward, while a final
> query capable of capturing the top from upper-warp contact must be more than
> `459` units upward; the conditional finite-stock query is therefore null.
> The result proves that collision and query samples can differ without giving
> the rank-1 route a useful installer.  The next proof target is a linked useful
> split or elimination of the remaining escapes, not the western-pillar route.
>
> `Area1SchedulerSurfaceLifecycleSplit.v` sharpens what “remaining escapes”
> means.  Across the generated US and JP source unions, it checks the
> recognized direct explicit callback-assignment/call syntax, including exactly
> four direct calls to the callback installer, and the direct explicit
> `Surface.object` field assignments.  The only recognized direct non-null
> owner write copies the currently updating object; the same local surface
> temporary is then inserted into the dynamic list without being assigned
> again.  Whole-struct or builtin surface mutation, an aliased store, external
> effect, indirect callback target, or bad live owner/list projection is still
> outside the result.
>
> In the finite scheduler/owner model, however, the consequence is exact: if an
> accepted upper-warp frame finishes with any non-null stock owner, it performed
> the final query at a position different from the collision position.  The
> formal lifecycle theorem only says this conclusion is unchanged by adding an
> arbitrary, separately supplied payload-fate witness; the proof does not
> inspect it.  It does not couple the query and fate, or order them in one
> trace.  Separately, the module retains an inactive, freed, unreused payload
> witness, so proving “no slot reuse” alone would still leave a stale-payload
> mechanism to analyze once a pointer is installed.
>
> `Area1Rank1OrdinaryBridgeNoGo.v` packages the corresponding ordinary no-go as
> five inspectable bridge premises: same-frame scheduling, real upper-warp
> contact, selected cached-floor refinement, faithful callback/sample/memory/
> final-receiver behavior, and stock surface-owner/list/query refinement.  If
> all five are supplied, the top-install contradiction is independent of an
> arbitrary separately supplied lifecycle fate, because the ordinary query is
> already null and the fate argument is unused.  No coupled chronology follows.
> This is a conditional interface, not a proof that retail execution satisfies
> those premises and not a claim that the known downward Y-only split is the
> only possible retail split.  A useful installer must expose which named
> bridge fails.  Finding that split or closing those bridges still comes before
> routing the remaining pillars.
>
> `Area1WarpTopCloneCensus.v` finds the pyramid-top mesh in only the stock top
> behavior initializer, the top behavior pointer only in the SSL Area-1 level
> script, and no direct C-body reference that requests another top.  It
> enumerates all 21 direct `Object.collisionData` writer bodies, checks that
> the allocator contains only null direct assignments to that field, and
> verifies that the ordinary pose-copy
> helper does not copy behavior or collision identity.  This rules out a
> direct use of that pose-copy helper as a collision-preserving clone, but
> does not prove successful allocation executes the reset and does not exclude generic
> runtime behavior arguments, replayed area spawning, aliased writes, or an
> unexpected receiver of one of those 21 writers.
>
> Ink therefore remains unresolved.  No clean retail gap installer was found.
> The corrected timer-131 sample still needs at least `960` units of
> Graphics-minus-Object Y separation (`1010` at the warp centre).  Eliminating
> it now requires: executing the action-selection frame in linked memory; proving Mario's
> object remains non-null and the final query really runs; eliminating or
> explaining or eliminating post-copy discrepancies; projecting live surface-list owners to exact
> slots and allocation epochs; closing relocation/clone provenance; and
> proving every clean binary32 coordinate writer preserves a gap below `960`.
> The detailed case table is
> [`docs/notes/stock-projection-exhaustiveness.md`](docs/notes/stock-projection-exhaustiveness.md).

> **Newest linked-lineage result:** the direct platform-pointer census is now
> connected to the constructed official cleaned US and JP linked definition
> lists. US's clear name is the only additional recognized direct named writer;
> no retained internal body directly takes the cell's address; and any retained
> internal direct updater caller must be named `update_objects`.
>
> JP additionally has a checked Clight dataflow fragment from the updater's
> surface temporary's `Surface.object` field into `gMarioPlatform`, followed by the apply
> function's load of that global. Real `Clight.step2` lemmas execute the
> individual statements once their starting states, expression evaluation,
> and stores are supplied, over an abstract global environment. Specialization
> to the concrete official global environment and symbol blocks remains open.
> Composing the surrounding sequence/skip steps into the complete fragment
> trace also remains open.
> That is a local store/load proof, not a proof that `find_floor` reaches the
> branch, that the source fragment is the body resolved by the official global
> environment, or that later execution preserves the cell.  Separately,
> `Area1SurfaceOwnerSyntax.v` checks the exact generated loader ordering from
> `gCurrentObject` to `Surface.object`, followed later by an
> `add_surface(surface, 1)` call using the same syntactic surface-temporary
> identifier, in both versions.  The direct-source-union follow-up proves that
> this local temporary has no intervening explicit assignment.  It does not
> frame the pointed-to surface cell through whole-struct/builtin mutation,
> aliases, or externals.  Static insertion uses flag `0`; live list integrity
> and canonical pool ownership remain open.
>
> Given a supplied pre-apply projection whose seed is required to decode from
> the declared null exterior run-start memory, the chronology cannot finish as
> retained JP inbound lineage, reducing that abstract residual interface from
> five cases to four.  Deriving the projection's events and endpoint from the
> linked active run remains open.
> Different query/current samples, out-of-model geometry, noncanonical
> slot/epoch, and unclassified owners still need live control-flow, owner,
> alias/external-frame, and lifecycle proofs.  The JP load theorem still
> strengthens a conditional stale-pointer route if a post-boundary query
> installs a pointer and later execution preserves it. The exact case table is
> [`docs/notes/linked-platform-lineage.md`](docs/notes/linked-platform-lineage.md).

## The problem in software terms

The game runs an update loop.  Each frame reads a controller, updates Mario and
the object pool, detects collisions, runs object behaviors, and may update the
save file.  The two outcomes of interest are save-file bits for these stars:

- Act 3, **Inside the Ancient Pyramid**, whose zero-based star index is `2`;
- Act 6, **Pyramid Puzzle**, whose zero-based star index is `5`.

A star is *newly collected* only when its bit is clear in the initial save
flags and set in the final save flags.  Starting with the bit already set does
not count.

The controller stores both the buttons currently held and the buttons newly
pressed on this frame.  In the source, the relevant update is equivalent to:

```c
buttonPressed = current & (current ^ previousButtonDown);
buttonDown = current;
```

The project therefore defines "fewer than one A press" as: the A bit of the
edge-triggered pressed value is false on every modeled frame.  A may already be
held when execution begins.  Holding A continuously is not a new press.

The pyramid interior is area 2.  A clean execution can begin through either:

- the **upper entrance**, which places Mario inside a descending elevator; or
- the **lower entrance**, which places Mario at the bottom of the pyramid.

`CleanPyramidEntry` also requires the two target bits to be clear, all five
Puzzle triggers to be unconsumed, no substitute target star to be waiting in
the object pool, valid spawn/list state, no pending collection or exit, enough
controller history to compute the first edge, and the version-specific
platform-pointer state needed by US and JP.  It now also requires the backup
save slot to agree on both target bits.  This matters because the game-over
path can copy the backup slot over the active one; without coherence, a model
could "collect" a target merely by reloading an already-set backup.

There is an important current abstraction gap here.  The abstract JP branch
accepts a non-null platform pointer when its pool slot is merely well formed;
it does not yet prove the gameplay prehistory that made Mario stand on that
surface or that preserved the pointer across the load.  This is deliberately
reported rather than hidden by strengthening clean entry to require `None`.
The concrete clean-entry refinement must instead recover the pointer, slot,
allocation epoch, raw platform fields, unload, and possible reuse from an
actual predecessor Clight execution.

The two entrances are not represented by a label alone.  The entry snapshot
records source warp node `0x0A` or `0x14`, exact Float32 position, 180-degree
facing, zero velocity, zero forward speed, and the airborne-spawn action
`0x1932`.  It also identifies the static Act 3 star and all five macro triggers
by allocation reference, macro kind, and exact Float32 position.  The concrete
surface pointer behind the abstract floor reference still needs a Clight
projection.

The pinned area definitions provide concrete landmarks for the future geometry
proof: the lower and upper entry warp objects are at `(0, 300, 6451)` and
`(0, 5500, 256)`; the elevator starts at `(0, 4966, 256)`; the second pole is
at `(0, 3200, 1331)` with behavior parameter `92`; the Act 3 star is at
`(500, 5050, -500)`; the Act 6 hidden-star controller is at
`(900, 1400, 2350)`; and the upper trigger is at `(260, 3913, -600)`.  These
initializer facts identify objects and candidate regions.  Coordinates alone
do not prove that Mario can or cannot reach them.

## The route argument in one diagram

The transcript suggests two normal-route gates.  The formal cut cannot be
defined only as "outside the elevator" or "above the second pole," because
those phrases omit collision phase, moving support, and passage topology.
The current evidence interface therefore describes each cut by source-side
and target-side static surface identifiers, dynamic object identifiers, and
Float32 `AxisAlignedOpenCell` boxes whose current membership test uses closed
bounds:

```text
clean upper entry
       |
       v
 spawn shaft / elevator supports
       |
       +-- first collision-phase crossing of the upper cut --+
                                                              |
clean lower entry                                             v
       |                                             shared target-side supports
       +-- ordinary lower route --> second-pole area --+      |             |
                                                       |      v             v
                                                       +--> Act 3 region  upper trigger
                          first crossing of the lower target-side cut
```

The "second pole" is still the likely normal control-flow gate, but its grip
top is at Y `4020`, while real target-side support and the upper trigger are
lower (support Y `3942`, trigger Y `3913`).  A predicate such as
`marioY > 4020` would therefore miss a genuine route.  The lower proof
obligation is the first collision-phase transition into the target-side
support/open-cell component around the access hole, not a height threshold.

This is a control-flow-cut argument:

1. Select the first collision observation of the Act 3 star region or upper
   hidden-star trigger.
2. Fix the entrance/target-specific cut family, prove the actual projected
   initial state is source-side and not target-side, and
   prove source/target separation at the actual projected crossing endpoint.
3. Recover the minimal pre-target source-to-target crossing from an actual
   Clight segment.
4. Classify the cause as local ordinary physics, an ordinary-physics endpoint
   outside the local cast domain, platform displacement, object impulse,
   collision clip, area reload, or same-position floor/platform support
   selection.
5. Prove the applicable cause cannot cross the entrance-specific cut without
   an A edge, or record its exact reachable witness.

The Rocq route-gate model proves the logical case split itself.  The strengthened
version first selects the exact earliest target observation, including its
position within a frame, and synchronizes the route prefix with the event
prefix.  For a trace satisfying its explicit route-coverage premise, that first
access has one of two entrance-specific forms:

- an A edge occurred at the elevator or second-pole gate before the target; or
- one bypass class tag occurred before the target.

The historical route tags are still only vocabulary.  The new
`EvidenceBearingBypassAt` record does carry the missing payload: an indexed
Clight segment, projected before/after `GameState`s, an exact certified event,
a writer class, a collision-support cut crossing, and alignment to the route
tag.  It also adds the previously omitted ordinary Mario/static-geometry
class.  `EvidenceBearingFirstTargetCutClassification` is the narrow remaining
coverage interface that must be constructed from the linked program.

Inside the present certified semantics, the proof eliminates direct area-2/3
warp displacement, invalid target identity/provenance, invalid hidden-star
lifecycle, coherent save-reload mutation, and projection mismatch once the
indexed certificate exists.  A bounded static quarter-step cannot make the
modeled 65536-unit coordinate alias.

The newer first-crossing module proves a different, corrected coverage result.
Its five position-writer constructors are ordinary physics, platform
displacement, object impulse, collision clip, and area reload.  If the
position does not change, a valid source-to-target crossing must instead
change the selected floor or platform.  It partitions ordinary-physics
endpoints into local-cast and coordinate-alias/out-of-bounds domains; the
latter is not a sixth function that writes Mario's coordinates.  Certified
ordinary administrative events preserve Mario's kinematics.  A changed reload
must return to the entry snapshot and is excluded from a validated target cut
when the post-reload state shares the initial version, entrance, and snapshot.
The bounded Area-1 upper-warp platform bootstrap is also closed.  These
results do not yet eliminate the six movement/domain cases or the seventh
same-position support-selection case for linked retail executions.

The evidence-bearing conditional theorem is:

```coq
Theorem evidence_classifier_with_open_writers_closed_requires_a_edge :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection
      projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    reaches_any_target_region trace ->
    trace_contains_a_press trace.
```

Every substantial premise in this statement is visible.  In particular, it is
not the unconditional retail theorem.  This older capstone still uses the
evidence-bearing bypass interface.  The corrected first-crossing theorem proves
coverage only after `FirstValidatedCutCrossingAt` has been constructed; the
linked-run construction, six movement/domain exclusions, and separate
support-selection exclusion are still required.

The proof now connects this route result to the save bits in the direction an
impossibility argument needs:

```coq
Theorem evidence_bearing_route_cut_blocks_new_target_bits :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act6_index.
```

The key intermediate lemmas say “new Act 3 bit implies an Act 3 interaction
cut” and “new Act 6 bit implies an upper-trigger cut.”  They do **not** reverse
that implication: merely entering a region is not modeled as collecting a
star.  The whole-run wrapper
`conditional_evidence_bearing_clight_run_impossibility` keeps three residuals
visible: whole-program Clight/event refinement, construction of the
evidence-bearing route classification, and unreachability of the six open
writer families.  All three remain open for the retail programs.

The older, coarser capstone-facing statement remains:

```coq
Theorem transcript_route_gate_reduction :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
```

The lower-level theorem
`no_a_target_access_requires_preceding_gate_bypass` keeps the selected frame
indices, so the bypass is proved to occur before the selected target
observation.  `transcript_route_gate_reduction` is its simpler capstone-facing
corollary and intentionally forgets those indices.

`TranscriptRouteGateModel` is an explicit route-coverage premise.  It says the
chronological observation stream contains the entrance-specific gate before a
target observation: either an A-edge-labelled gate observation paired with the
same modeled frame input, or the corresponding bypass.  The theorem removes
the A-action branch when every input frame has no A edge.  It does not prove
the gate label's control-flow meaning or the coverage premise from C.

The model deliberately targets the **Act 3 interaction region** and the
**upper hidden-star trigger**, rather than claiming that merely reaching a
floor writes a save bit.  The collection layer separately explains why those
regions matter.

### Ordinary motion: what is proved and what is not

“No A press” is not “Mario cannot move.”  The ordinary-motion class includes
walking, momentum, gravity, falling, sliding, landing, pole actions, and normal
static floor/wall/ceiling response.  The generated source also exposes a less
obvious case: A may already be held at clean entry, and stationary or moving
punching can then select `ACT_JUMP_KICK` after a B press without a new A edge.
That is a real counterexample to the shortcut “no A edge implies no upward
motion.”

The current abstract event model cannot decide whether such motion reaches a
route cut.  A `MotionPhysicsFrame` still accepts an arbitrary endpoint, so its
label is comparable to a log record whose payload has not been validated
against the implementation.  Moreover, an earlier platform, object, clip, or
lifecycle event could prepare the action or velocity used by the later
ordinary frame.  The sound shape is therefore a preservation proof: define a
finite, source/mesh-backed safe envelope and prove that every writer class
preserves it until the first target-side crossing.

The new `OrdinaryMotion.v` module proves that explicit generic preservation
and target-exclusion obligations compose.  The follow-up
`UpperElevatorQuarterStepClosure.v` executes the finite upper-elevator
arithmetic at collision-query granularity:

- held-A jump kick executes exactly 32 binary32 quarter-step queries and peaks
  at `134` units relative to the descending elevator;
- B rollout executes exactly 40 queries and peaks at `224.5` units;
- every scaled transition is checked against the generated binary32 addition,
  and the quarter-step body returns only literal codes `0,1,2,3,4,6`; and
- the generated elevator mesh has side vertices through local Y `256`, the
  dynamic-surface loader adds an upper-Y pad of `5`, and the lower wall query
  samples Mario at Y offset `30`, so an integer-translated wall is rejected
  vertically only when relative center Y is strictly greater than
  `256 + 5 - 30 = 231`.

Thus both modeled ascent chains remain below the wall-clearance threshold at
every query: `134 < 231` and `224.5 < 231`, on the non-Wing branch.  Their
generated US/JP action bodies call
`perform_air_step` with literal step argument zero, so these actions do not
request the ledge-grab check.  Exact US/JP mesh receipts also recover the
20 elevator vertices and the lower-route pole-base and upper-ring vertices.
`MainTheorem.v` packages this exact checked boundary, together with the
Wing-Cap arithmetic below, as the closed theorem
`current_ordinary_motion_evidence_boundary`; that theorem is not a retail
containment theorem.

Cap state is a necessary engineering precondition, not decorative state.
The stock upper entrance is Area-1 warp node `0x1E`, whose LevelScript route
targets Area 2 node `0x14`.  Because this is a same-level area change rather
than an instant warp, `warp_area` unloads and reloads the area and then runs
`init_mario_after_warp`; that function runs `init_mario` and the initial-action
helper.  `init_mario` overwrites Mario's flags with either `0` or `1 | 16` and
zeros the cap timer, so both outcomes erase Wing.  The final initial-cap helper
offers special caps only for course offsets `0`, `1`, and `2`; SSL is course
8, whose offset from the cap courses is `8 - 20 = -12`, so it cannot restore
Wing.  Thus a Wing Cap carried into the Area-1 entrance cannot survive the
stock defined transition.  The formal receipt still needs the usual linked
execution bridge showing that this decoded route and these calls use the same
live Mario receiver; a forged route/course, different receiver, or post-reset
writer is a distinct escape, not cap preservation.

For diagnosis, a hypothetical Wing installed after that reset would make held
A flutter gravity slow Mario's fall after rollout turns downward.  Exact replay
finds only two samples above the `231` wall cutoff: zero-based samples 44 and
45 are `234` and `232`; samples 46 and 47 are already `230` and `228`.  Each
quarter-step first resolves upper and lower walls, then queries floor, ceiling,
and water.  The rollout remains in rollout on no collision, changes to the
landing action on a floor, loses forward speed but stays in rollout on a normal
wall, and delegates a lava wall to the lava-boost handler.  The two-sample
window therefore helps only if live X/Z, transformed elevator ownership,
surface-list selection, and the wall response all line up; it is not itself a
bypass.

This is not yet an unconditional elevator-containment proof.  It still needs
linked Clight execution of the action and gravity paths, live transformed-wall
ownership and list selection, bounds for every intermediate collision query,
normal collision rather than a clip/tunnel, the stock route/reset-to-live-
receiver connection, and closure of the reachable upper-entry action states.
The lower route is less complete: Z can leave the second pole through
`ACT_SOFT_BONK`, so A is not literally the only pole exit.  The existing
normalized pole arithmetic blocks that restricted Z-exit model, but does not
cover every lower-entry ordinary trajectory.

There is also an earlier upper-entry phase that the ascent arithmetic does not
cover.  Mario's clean snapshot is at Y `5500`, above the elevator's initial
raw rim top at Y `5222`.  The generated no-spin-airborne action contains the
expected zero-forward-speed launch-helper and air-step calls, which supports a
vertical entry fall at the syntax level.  The proof still has to execute that
path, select the live elevator floor, and establish the post-landing state
before applying either ascent bound.

The precise result and remaining obligations are documented in
[`docs/notes/ordinary-motion.md`](docs/notes/ordinary-motion.md).  No retail ordinary-motion
trace reached either target region in this tranche, and the ultimate theorem
remains incomplete.

### The Area-2 cuts are now concrete, but the gates are not closed

The historical phrase "above the second pole" has been removed from the
geometric boundary.  It was not even directionally safe: source/gameplay
evidence supplies an ordinary pole-top sample `(0,4020,1331)` without a new A
edge (formal reachability of that sample remains open), while the ring and
some target-side geometry are lower than that grip point.

For the lower entrance, `Area2LowerTargetCut.v` now reads the generated US and
JP Area-2 collision initializers and identifies:

- eight ring triangles, source ordinals `1414..1421`, at Y `3942`;
- eight `SURFACE_NO_CAM_COLLISION` aperture-plane records intended as vertical
  wall candidates, ordinals `1534..1541`, from Y `3712` to `3942`; and
- four conservative closed binary32 boxes over the ring rectangle, excluding
  the central shaft X `[-101,102]`, Z `[1229,1434]`.

This is a support/closed-box candidate cut, not a floor-number predicate.  The
checked legacy soft-bonk subcase stays at most 82 units from the pole centre
when high enough to meet the ring, so it remains strictly inside the aperture.
That theorem is an integer/source-mesh subcase only.  The source component,
live `Surface` mapping, Float32 wall/floor traversal, all other writers,
nonlocal endpoints, moving geometry, and same-frame collision-phase crossings
remain open.

For the upper entrance, `Area2ElevatorCut.v` authenticates the elevator base,
inner walls, upper rim, surrounding Y=5222 floor, and fixed chamber-wall
triangles.  A useful abstraction bug was caught during review: the generic
`CollisionSupportCut` stores absolute closed boxes, but the elevator moves.  A
box containing the union of every elevator pose can overlap a rim surface that
is supposed to be target-side.  The proof therefore separates:

- a moving-relative candidate using the live elevator origin and distinct
  base/rim `SurfaceRef` names; and
- a conservative absolute adapter used by the existing first-crossing writer
  theorem.

The strongest upper and lower theorems are conditional reductions.  Once a
valid strictly earlier-frame crossing is constructed, every abstract writer
case is one of local ordinary physics, platform displacement, object impulse,
clip/tunnel, nonlocal/failed-cast motion, lifecycle/entry displacement, or a
same-position support-selection change.  If all seven cases are proved
unreachable, target access is impossible.  None of those linked retail
exclusion bundles is inhabited yet.  A separate named obligation requires
every projected target-event frame to have a strictly earlier validated cut
crossing; a real same-frame or earlier transient crossing would refute that
obligation and require exact collision-program-point semantics.

Downstream capability is now kept logically separate from gate reachability.
`Area2DownstreamContinuations.v` uses version-indexed suffix certificates that
begin at a supplied target-side boundary state; an optional clean-prefix
record composes such a suffix with the still-open gate proof.  This avoids the
circular argument "assuming a clean no-A route through the gate, prove the
rest of the no-A route."

The generated support receipts locate a floor under the Act-3 star and one
support triangle at each of the five Puzzle triggers.  Standing on the checked
Act-3 floor leaves Mario's 160-unit hitbox 75 units below the star, so mere
arrival at that floor is not a continuation proof.  The existing injected JP
receipt conditionally overlaps all five trigger regions and spawns the Act-6
star; a separate injected receipt collects it.  These are not one cut-starting
suffix and are not clean-entry Clight reachability.

The supplied transcript does specify how Act 3 is reached after either gate is
passed.  From the upper entrance, it proposes spawning the 100-coin star near
the Act-3 platform, storing rollout upward speed, reactivating that speed into
a ground pound that collects the 100-coin star, using the resulting star-dance
ledge grab to reach the platform, and rolling out into Act 3.  From the lower
entrance, it first lures a homing amp from the next floor and uses the shock to
ledge grab past the post-pole ledge, traverses the ramp, uses the one-unit floor
misalignment on the upper horizontal Grindel, rolls onto the corresponding
misalignment on the still-undescended upper-route elevator, triggers and rides
the elevator, crosses to the Act-3 platform, and rolls into the star.
`Area2DownstreamContinuations.v` records both ordered candidate-stage lists and
defines separate upper/lower no-A suffix obligations.  It does **not** yet
refine the stage labels to homing-amp behavior, live surface ownership, exact
quarter steps, elevator state, or Clight program points, and neither suffix
obligation has an inhabitant.

A transient hash-gated JP experiment instead tried direct steering from the
known upper-trigger route toward the upper horizontal Grindel.  It found the
Grindel at timer 516, but did not attempt the transcript's Grindel/elevator
misalignment sequence; it left the Y=3913 support, fell to Y=-101, never rode
the object, never overlapped Act 3, and consumed only the upper trigger.  This
is a failed unrelated schedule, not an Act-3 exclusion.  Therefore the current
Area-2 verdict is deliberately incomplete: no new clean counterexample was
found, but Area 2 has not been ruled out.

See the focused [upper-cut](docs/notes/area2-elevator-cut.md),
[lower-cut](docs/notes/area2-lower-target-cut.md), and
[downstream](docs/notes/area2-downstream-continuations.md) notes.

### Conditional stale pyramid-top route

The user's additional route observation is represented explicitly rather than
ruled out by definition.  The relevant source is Area-1 warp node `0x1E` at
`(-2048, 768, -1024)`; it enters Area 2 at node `0x14`,
`(0, 5500, 256)`.  On JP, if a top-owned `gMarioPlatform` pointer survives
that warp and the top's slot becomes inactive or reused, Area 2 can read the
slot's displacement fields.  The current source-shaped payload with position
`(-2047, *, -1023)` and yaw delta `0x1800` maps upper-entry Mario from
approximately `(0, 5500, 256)` to
`(365.592773, 5500, -1096.8027)`.  That leaves the ordinary shaft/cage region
without an A edge and is therefore a serious platform-displacement
constructor in the current abstraction.

The newest source/Clight audit sharply narrows the tempting **intact-top
self-bootstrap** subcase.  The C source narrows `find_floor` coordinates to a
signed 16-bit type.  The generated Clight body and CompCert semantics now prove
that the concrete binary32 sample `(63488,1791,-1024)` becomes
`(-2048,1791,-1024)`, and the finite partition calculation places X and Z in
cells 6 and 7.  Authenticated US and JP retail disassembly now supplies the
same byte-identical coordinate conversion at `find_floor`: `trunc.w.s`,
`mfc1`, store-halfword, then signed load-halfword.  The Rocq theorem
`concrete_retail_cast_fragment_arithmetic` checks that instruction-fragment
result for all three concrete inputs.

The newer nonlocal-endpoint audit separates two cases that should not be
called the same kind of out-of-bounds behavior.  A **finite value that converts
to a signed 32-bit word** may still wrap when `find_floor` stores it through a
signed 16-bit temporary; that Parallel-Universe primitive is real.  Rocq now
checks the complete example

```text
MarioState        = (-1862, 67314, -902)
find_floor query  = (-1862,  1778, -902)
```

including the exact binary32 conversion of X, Y, and Z.  The narrowed query is
the already accepted timer-131 midpoint.  This is no longer only an arithmetic
proposal.  In a hash-gated original-JP run, a fixture places Mario's collision
Object at the upper warp, State at the nonlocal value, and Graphics at a third,
deliberately different point.  State X/Z survive the frame; the returned floor
belongs to the live timer-131 top and has the predicted height; the cached warp
selects `ACT_DISAPPEARED`; the snap and copy synchronize all three views; and
the final platform query caches that top.  If the first query had failed, the
source branch would instead have copied the different Graphics X/Z, so the
post-frame discriminator supports the State-first path under the audited
source order.  The probe does not directly breakpoint the branch, and linked
writer closure must still exclude an unclassified restoring write.  All
recorded A counters are zero.

The high State Y also makes both wall passes simpler than expected.  Their
query heights are `67374` and `67344`, while every surface's stored upper Y is
a signed 16-bit value no greater than `32767`.  Rocq proves in a source-shaped
list model that every wall is rejected before the X/Z push code.  The exact
State-first fixture was also continued through the top's explosion/free, the
retained slot at depth 47 during the authentic first Area-2 platform apply,
and consumption of the upper hidden-star trigger, again with zero A counts.
These observations establish a **conditional State-first engine
continuation** that does not need Ink's Graphics retry or its `>=960`
Graphics/Object Y gap.

The complete displacement now has an exact payload-level construction from a
synchronized upper-warp sample.  Platform displacement first adds the
platform's X/Z velocity, so velocity `(186,122)` changes State
`(-2048,768,-1024)` to `(-1862,768,-902)`.  A platform centered at
`(-1862,34041,-902)` then changes pitch from `0` to `180` degrees and mirrors
that point to exactly `(-1862,67314,-902)`.  The operation uses exact zero,
one, and minus-one entries from both generated sine tables.  This also exposes
a correction to the earlier rotation-only witness: its starting point was not
inside the upper-warp radius and therefore already assumed a horizontal
State/Object split.

The payload is possible, but its stock installation is not.  In the audited
Area-1 scheduler and surface-owner model, every upper-warp pre-apply boundary
has a null cached platform, so the payload cannot be read.  The canonical
surface callbacks also do not directly write the required pitch velocity;
fresh slots contain zero, the checked fragment values are `3840` or `6400`,
and the stock top never reaches pivot Y `34041`.  A whole-ROM result still
needs the live execution bridge: any successful classified installation must
use an alias/external platform write, a surface-owner projection failure, a
post-query Object writer, a moving query skip, unchecked retained entry, or an
unclassified scheduler shape.

By contrast, quiet NaN, either infinity, `+2^31`, and the first binary32 value
below `-2^31` fail the word conversion.  The US and JP startup receipts set the
Invalid-enable bit; the stock floating-point exception path stops the faulting
thread rather than resuming it; and the small target-prefix model produces a
trap before `mfc1` or the signed-halfword store.  Thus the common
"failed cast becomes halfword zero" story is not a usable continuation under
that initialized prefix.  The adjacent finite inputs `2147483520` and
`-2147483648` do succeed and narrow to `-128` and `0`, respectively.  This
retail conclusion is still conditional in Rocq on
`RetailInvalidCastExecutionRefinementObligation`,
`RetailInvalidEnablePreservationObligation`, and the handler fact named by
`RetailInvalidTrapContinuationExclusionSchema`: the project has not yet
imported a whole VR4300 small-step/exception semantics or proved that every
reachable execution preserves the FPCSR bit.

The finite alias is still not a clean route.  The fixture injects the split and
also arms the top.  No clean zero-A writer has been shown to create the required
pre-collision three-dimensional State/Object split.  Ordinary and action-phase
PU movement run after collision and are copied back to the raw Object, so they
cannot leave the next frame's Object local while State stays remote.
Pre-collision cached platform displacement is the identified stock exception,
but the temporal stock model now proves more than a same-sample null result.
It permits arbitrary Object movement on active frames and arbitrarily many
exact frozen carries: the active frame's final query rebinds the pointer, while
the frozen frame preserves both pointer and Object.  Along with US clear and
the checked JP inbound positions, those transitions cannot finish at the upper
warp with a non-null pre-apply pointer.  The generated pre-collision census
also identifies an abstract State-only platform phase.  Assuming linked
refinements for the terrain frame, true platform branch, and collision frame,
a synchronized State/Object split must come from an effective State-only
platform apply; that abstract phase cannot create Ink's Object/Graphics gap.

A clean route must therefore escape the linked projection through a different
query/current sample, relocated or out-of-model geometry, a clone/reused epoch,
an unclassified owner, retained-inbound transport, or an aliased/external or
otherwise unframed coordinate/pointer write.  Dynamic-list ownership and the
warp/snap/copy/lifecycle results are observed conditionally, but still need a
single linked Clight execution proof.  The exact checked boundaries are
documented in
[`docs/notes/area1-nonlocal-endpoints.md`](docs/notes/area1-nonlocal-endpoints.md)
and
[`docs/notes/installer-temporal-closure.md`](docs/notes/installer-temporal-closure.md).

Warp hitboxes continue to use full binary32 object positions.  The parsed
source mesh has minimum home-relative world Y `1281`; the arithmetic platform
predicate then requires full Mario Y strictly above `1277`, while the upper
warp ends at Y `818`.  Under the explicit premise that the stock yaw transform
preserves MarioState Y, the floor query's 78-unit allowance cannot lift a
warp-altitude query to the top.
`one_coordinate_cannot_contact_warp_and_capture_live_top` and
`stock_yaw_only_top_cannot_seed_upper_warp_bridge` prove those arithmetic
statements.  The quantitative theorem
`upper_warp_to_live_top_query_requires_385_y_units` also proves that, for a
post-copy Y coordinate still in signed-16 range, any such phase split needs
at least 385 units of upward State displacement.  That is a lower bound on a
candidate reused-slot writer, not evidence that one exists.  The matrix and
surface-loader bodies are now internal generated functions.  Rocq links
parsed top face `(1,4,3)` to manually translated zero-yaw home vertices, then
evaluates a hand-mirrored CompCert binary32 transform formula, all three
hand-mirrored signed edge expressions
(`521730`, `0`, `1023`), and their strict-negative tests.  What is still
missing is generated-expression extraction and linked execution over live
object/surface memory, initial-angle/state refinement, dynamic-list ownership
and order, and proof that the actual `find_floor` traversal returns this
top-owned face.  The result removes the motivation for an enormous X/Z search
within the Y-preserving stock model; it is not yet a retail impossibility
theorem.

A pinned-source audit gives the stock or inactive-but-unreused top an even
wider horizontal margin: its pivot X stays in `[-2087,-2007]`, Z is `-1023`,
X/Z velocity is zero, and only yaw rotates.  A Mario object overlapping the
upper warp is then within about 228 horizontal units of the pivot, whereas
the concrete PU candidate is at least 65,495 units away.  Exact real yaw
rotation preserves that radius.  The project does not yet call this a Rocq
Float32 theorem because the generated sine table and matrix multiply/add
rounding still need a conservative coefficient-bound refinement.  The result
also says nothing about a reused slot whose replacement object installs a new
pivot, velocity, pitch, or roll.

That same-sample result does **not** close the broader stale/reused-slot case.
Direct inspection of the pinned source shows that platform displacement writes
MarioState before collision, while collision still reads the old Mario object.
The older admission-free theorem `phase_split_countermodel_exists` checks this
concrete two-sample model:

```text
collision MarioObject = (-2048,  768, -1024)
displaced MarioState  = (63488, 1791, -1024)
```

CompCert's exact signed-short cast maps X `63488` back to `-2048`.  Rocq checks
the parsed triangle index, its manually translated zero-yaw vertices, the
hand-mirrored transform and face-edge arithmetic, world Y `1791`, and the
numeric 78-unit floor-query condition.  It does not yet prove loaded
dynamic-surface ownership or actual `find_floor` selection.  The two-sample
model needs a Y change of `1023`; more generally, the proved floor-query bound
requires at least 385 upward units from an upper-warp overlap.  An X/Z-only
alias or any Y-preserving transform therefore cannot realize it.

Ink's graphical-fallback proposal exposes a third sample that the older model
omitted:

```text
collision MarioObject = (-2048,  768, -1024)
first-query State     = (-2200,  768, -1024)
fallback Graphics     = (-2048, 1791, -1024)
```

The relevant Object-to-Graphics Y gaps are:

| Case | Object Y | Graphics Y | Gap | Meaning |
| --- | ---: | ---: | ---: | --- |
| Synchronized entry | same | same | `0` | Intended starting relationship; linked-memory proof pending |
| Dry audited envelope | arbitrary | arbitrary | at most `45` | Route-specific source-audit target |
| Conservative modeled envelope | arbitrary | arbitrary | at most `208` | Preserved by covered abstract writers; retail coverage pending |
| Signed-range generic top-query threshold | at most `818` | at least `1203` | at least `385` | Necessary for a floor at least `1281`, using the 78-unit query allowance |
| Exact Ink prestate schema, worst warp-overlap Y | at most `818` | `1791` | at least `973` | Admission-free arithmetic theorem |
| Displayed witness above | `768` | `1791` | exactly `1023` | Coordinate witness only, not a reachable trace |
| Timer-131 low-side retry | at most `818` | `1456` | at least `638` | Accepted by the exact timer-131 face, but loses top support before explosion |
| Timer-131 midpoint retry | at most `818` | `1778` | at least `960` | Accepted strict-interior point; conditionally preserves the top pointer to Area 2 |
| Timer-131 midpoint at warp centre | `768` | `1778` | exactly `1010` | Exact injected Object/Graphics separation; no clean installer is known |

The interaction/action side has a separate displacement table:

| Producer | Immediate coordinate effect | Amount |
| --- | --- | --- |
| Successful Koopa-shell interaction | Manual source audit finds no direct Mario position write; it changes action/object references | `0` immediate coordinate write under well-formed non-aliasing state; linked call-segment proof pending |
| Failed Koopa-shell contact | Pushes State X/Z toward a radial target before wall correction | Stock scale-1 target radius `50 + 37 + 2 = 89`; not a proved total bound |
| Riding-shell air renderer | Graphics Y in the source audit | `+42` source operand/model offset |
| Riding-shell ground renderer | Graphics Y in the source audit | `+45` source operand/model offset |
| Object-top bounce | State Y becomes `objectY + hitboxHeight` | Snap is geometry-dependent; callers set Y velocity `30` or `80` |
| Generic object push | State X/Z radial correction plus wall resolution | `objectRadius + 37 + padding`; no total bound without live walls |
| Bully response | State X/Z from the two-body solver | No fixed global bound without radii/speed/state closure |
| Water pitch plus bob | Graphics Y only | Conservative modeled envelope `<=208`, not linked retail coverage |
| Quicksand sink | Graphics Y, optionally throw-matrix Y | `-depth`; prepared negative-depth example raises a zero base by about `2.65` |

Walls do not supply a hidden `+Y` term to the two shell rows.  In the
inspected source, wall collision changes X/Z and may indirectly select a
different floor, so it can change the absolute height to which the step
synchronizes Mario.  The step then sets Graphics from State and adds exactly
one shell source operand; the end-of-behavior copy sets raw Object from the
same State.  Consequently a wall/floor lift moves Object along with State and
does not enlarge the next-frame Graphics-minus-Object gap.  The ground
wall-hit branch still reaches the one `+45`; the air wall-hit branch still
reaches the one `+42`.  On the frame where cached upper-warp interaction
succeeds, direct source inspection instead selects `ACT_DISAPPEARED` before
action dispatch, so neither shell body runs.

Rocq proves these statements only in the explicit three-view abstraction:
an arbitrary State-only writer has zero Graphics-Y delta, and an arbitrary
wall/floor-selected State height followed by the modeled shell reanchor leaves
a gap at most `45`.  Applying them to retail requires the still-open Clight
pointer/dataflow, action-dispatch, object-copy, and flag-closure proofs.  The
separate bit-0/`oGraphYOffset` behavior-tail overwrite remains a model
counterexample until retail initialization and all flag mutations are closed;
it is not caused by wall contact.

The shell `42`/`45` constants now have US/JP generated-AST occurrence receipts
and a Rocq integer-model bound.  The field/formula meaning comes from manual
source inspection; a statement-level Clight proof and route-local binary32
arithmetic/live-range results remain open.  The checked out-of-range witnesses
show that the source operand is not a valid arbitrary-input endpoint bound.
The `89` shell figure is the pre-wall
radial target, not permission to claim that every shell frame moves Mario by
at most 89.
The complete source formulas and caveats are in
[`docs/notes/ink-fallback.md`](docs/notes/ink-fallback.md#interaction-and-action-displacement-census).

The PU variant uses Graphics X `63488`, which the floor query narrows to
`-2048`.  Object collision can cache the warp from the first sample.  The wall
and first floor queries use the second sample.  If that first floor query
returns `NULL`, `update_mario_geometry_inputs` copies Graphics into State and
retries.  A loaded top-owned retry floor can then feed `ACT_DISAPPEARED`; State
is later copied to raw Object.  If the retry is also `NULL`, however,
`update_mario_geometry_inputs` requests `WARP_OP_DEATH` before it processes
the cached object interactions.  The interaction selects `ACT_DISAPPEARED`
with a two-count argument and requests the object warp later.
`level_trigger_warp` only writes an empty delayed-warp slot; at zero lives it
rewrites death to the still-nonzero game-over operation.  In the small model,
an uncleared fatal request prevents the later node-`0x1E` request from becoming
pending.  `retail_fatal_persists_or_reset_destroys_disappeared` now proves the
block-or-reset invariant for the explicit event system, and
`two_supported_disappeared_ticks_cannot_replace_fatal` computes the direct
two-tick race.  Thus a surviving schedule must obtain a non-null retry floor,
subject to the still-open linked refinement described below.

No pinned-source scheduling shape outside the checked event alphabet was
identified.  The
retry-null frame still processes the cached interaction and sets
`ACT_DISAPPEARED`, but `execute_mario_action` returns on the null floor before
dispatching it.  Later usable-floor frames can decrement its two-count
argument and eventually request the object warp; meanwhile the normal
delayed-warp countdown does not directly clear the fatal operation.  Pinned
source inspection sees warp-arrival/credits paths call Mario initialization or
action replacement before the clear, while `init_level` and
`lvl_init_from_save_file` are intended initialization barriers.  The generated
receipts only establish call presence/callee order and separate clear
presence; they do not prove assignment/call order or that no Mario callback
can intervene.

The remaining issue is no longer the finite invariant itself.  It is the
linked refinement showing that the actual US/JP call and memory trace belongs
to this event system.  That proof must construct the exact link, prove the
indirect `cur_obj_update` callback and concrete clear-to-reset barriers, provide
a latch-memory frame condition, and refine compiled `find_floor` to the two
queried results.

Remaining object lists and the deactivated unload pass run before the final
platform query.  The exact timer-131 follow-up separates two accepted retry
points.  The low-side point `(-1641,1456,-783)` captures the top initially, but
its support changes to the static Y=`1280` floor at global timer 498 and
`gMarioPlatform` becomes null.  It therefore cannot carry the stale pointer to
Area 2.  The midpoint `(-1862,1778,-902)` instead remains on a top-owned floor
through timer 498; at timer 513 the top is inactive at free-list depth zero,
yet the final floor owner and platform pointer still name its slot.  After the
area unload and 84 destination allocations, the slot remains free at depth 47
and the first Area-2 application produces exact State bits
`(43b6cbe0,45abe000,c48919af)`.

Those facts come from a hash-gated authentic-JP runtime trace beginning at an
injected three-view boundary.  The probe does not write the subsequent
lifecycle, allocation, displacement, collision, or hidden-trigger state.  Its
execution breakpoints now locate the true first destination application
directly: authentic JP entry `0x802c83f0` at timer 515 has the stale slot-61
pointer at free depth 47 and all three Mario views at `(0,5500,256)`; caller
return `0x8029cfc8` has displaced State bits
`(43b6cbe0,45abe000,c48919af)` while Object and Graphics still hold the spawn
coordinates.  The Rocq observation records check the copied bit
patterns, free-list arithmetic, pointer identities, and zero-A counters; they
do not turn the emulator trace into a linked Clight small-step execution.
`ink_local_conditional_pipeline_coordinate_witness` and
`ink_pu_conditional_pipeline_coordinate_witness` remain handwritten coordinate
evaluations, while `Timer131Surface.v` supplies the exact raised/rotated surface
arithmetic for the corrected midpoint.

The five-obligation audit produced three different outcomes:

1. The surface, prestate, and writer propositions are predicate-sensitive
   schemas.  Rocq exhibits interpretations making each accept or reject.  They
   still need concrete linked-run relations before they can decide retail
   reachability.
2. The old sink proposition was refuted.  Its unrestricted `Smallstep.star`
   could continue past one return into a second invocation, and its aggregate
   address ranges admitted a concrete modular pointer alias.  The repaired
   obligation uses a first-return relation and pairwise-disjoint four-byte
   cells.  It is a plausible concrete memory obligation, but remains unproved.
3. The old lifecycle proposition can be false under a hostile projection/link.
   Although `behavior_script.c` is imported, that interface neither constructs
   the exact link nor establishes the indirect callback.  The new JP trace
   supplies strong conditional runtime evidence after an injected boundary,
   including actual explosion/free-list and destination effects, but it is not
   a repair of that semantic interface.  A linked theorem still needs
   external-call frame conditions, pointer-to-pool-slot/epoch linkage,
   finite-float premises, and a clean-run installer.  The checked NaN
   counterexample explains why equal Coq-level binary32 values alone do not
   imply the retail `< 4.0f` platform-tolerance comparison.

These are specification counterexamples, not gameplay counterexamples.

The older closed coordinate witnesses use the zero-yaw home top and floor Y
`1791`; they are not explosion-pose witnesses.  `Timer131Surface.v` now computes
the fresh timer-131 pose and collision mesh with CompCert binary32 operations.
It rejects that old sample, accepts the low-side and midpoint replacements, and
the conditional JP trace shows why only the midpoint preserves support through
the tested explosion schedule.  A linked proof must still execute the generated
matrix/surface helpers over live memory and establish list ownership and
selection rather than importing the runtime observation as an axiom.

This answers the chatbot disagreement precisely.  The second chatbot is right
that object collision does not wrap, the stock warp and top are vertically
disjoint at one coordinate, platform displacement cannot newly create the
same-frame warp collision, and Mario's model moves later.  Its conclusion is
too broad: the graphical fallback permits three different coordinate samples
in one frame.  The PU floor-alias primitive is real, but an audited PU-sized
State-only displacement writes only State and cannot manufacture the required
Object/Graphics split.  The midpoint is now a conditional retail-ROM trace
after debugger installation, but no clean gameplay trace or linked Clight
execution constructs its three-view prestate.

The Area-1-first audit now answers the next question more precisely.  A generic
three-dimensional raw payload really does exist in stock source.  Triangle
fragments spawned by breakable and exclamation boxes write nonzero pitch
angular velocity.  `area1_fragment_writer_source_checked` verifies those
source fields, and
`concrete_area1_fragment_displacement_is_route_sized_3d` evaluates one selected
payload using CompCert binary32 operations: it changes all three MarioState
coordinates, taking the selected old sample `(-2048,768,-1024)` to
approximately
`(-2350.8427734375,1878.6683349609375,-714.5823974609375)`.  The roughly
`1110.6683`-unit Y rise exceeds the signed-range 385-unit necessary lower
bound, and the
three exact binary32 words are `[3306351996,1156240739,3291653446]`.  The
signed-short collision query is `(-2350,1878,-714)`.  For an
attacked breakable box, an object count above 210 suppresses the mist
allocation, so the first triangle
allocation becomes a concrete candidate for reuse of a just-freed slot.

That first-allocation example is not exhaustive and is not intended to be.
Deallocation pushes a slot onto the free-list head, while allocation pops the
head; `[top, box]` is only the shortest illustrative prefix.  The generic
source schedule has three stock angular-payload classes before platform apply:

1. the pyramid top's live/retained yaw payload;
2. breakable-box dirt-triangle pitch/yaw payloads; and
3. exclamation-box cartoon-triangle pitch payloads.

Each class admits different free-list depths.  The fragment classes also admit
the source's `20`, `10`, or `0` mist-allocation branches, and pool exhaustion
can substitute FIFO eviction for an ordinary free-list pop.  Coin-formation and
other zero-angular allocations shift depths without adding a fourth angular
class.  This is why proving one controller history for `[top, box]` would never
have established schedule exhaustiveness.

More precisely, let `A` be the number of earlier allocations in the frame,
`d` the watched slot's zero-based free-list depth, and
`m ∈ {20,10,0}` the source-selected mist count.  With `M`, `D`, `C`, and `T`
standing for mist, dirt-triangle, contents, and cartoon-triangle allocations,
the two fragment bursts have these words:

```text
large breakable:    M^m D^30 S
exclamation box:    C M^m T^20 S
```

Here `S` is a trailing zero-angular allocation.  The watched slot receives a
dirt payload exactly when `A + m <= d < A + m + 30`, and a cartoon payload
exactly when `A + 1 + m <= d < A + 1 + m + 20`.  A nearby coin formation may
add `k` zero-angular allocations for `0 <= k <= 5`; other zero-angular
allocations shift `A`.  If the free list empties, the allocator evicts the
oldest eligible unimportant object, replacing the depth condition with the
corresponding FIFO-rank condition.  These variants change which payload reaches
a slot, not the node-`0x1E` owner-null conclusion.

The arithmetic witness is reproducible rather than existential.  Rocq checks
the packed US and JP Area-1 macro records for all three wing-cap/exclamation
boxes and both no-coin breakable boxes, then selects the middle wing-cap box.
Its real action-4 object position is `(-3000,540,800)`; the fragment
initializer's 100-unit Y offset makes the transform pivot
`(-3000,640,800)`.  It also evaluates the stock 16-bit PRNG recurrence for the
seed-0 payload and checks the selected sine-table words in both generated
versions.  This proves that the chosen angular payload is compatible with the
source formulas.  It deliberately does not claim that seed 0, the required
object count, or the watched free-list head occur together.  That concrete
lineage is no longer needed for the **pre-existing-platform-origin** subcase
because the generic stock pre-apply result below rules out every bounded
platform origin at the warp collision sample.  It does not rule out a first
query returning `NULL` followed by a graphical retry and a new top capture.
The breakable-box "fragment can be first" case and the middle-wing-cap-box
numeric pivot are separate source-backed subcases; the proof does not combine
them into a fabricated execution.

The proof then checks both floor candidates at the short query.  The transformed
top face has signed edge values `[207669,313344,2763]` and binary32 plane
height `1483.603515625`.  A static face has signed edge values
`[2460,77749,76821]` and height `1280`.  Those are exact arithmetic facts, not
a proof that either face is live, owns the relevant list entry, wins the real
list traversal, or came from a reachable object-pool state.

That sounds like the missing writer, but `Area1PlatformExhaustiveness.v`
eliminates the pre-existing-platform bootstrap more generally than the
original top-slot argument.
It defines and checks a finite inventory of fifteen modeled stock Area-1
dynamic-floor owners:
the pyramid top, three Tox Boxes, two large breakable boxes, five exclamation
boxes, the cannon lid, and three message panels.  Four newly imported generated
collision meshes—breakable-box, exclamation-box outline, cannon lid, and wooden
signpost—supply exact local bounds for the fixed owners.

At node `0x1E`, every non-top owner is excluded by its horizontal envelope.
The top overlaps horizontally but its lowest stock floor is at least Y `1281`,
which cannot satisfy the warp's Y interval and platform-query tolerance.
Static floors have a null object owner.  Therefore
`stock_upper_warp_final_query_clears_platform` proves that a completed stock
final query at the warp returns `None`.

The theorem then classifies every modeled pre-apply platform origin as a
completed final query, the US spawn clear, a retained pointer at one of the
three in-scope stock inbound Area-1 positions, or frozen carry from one of
those cases.  The retained case covers JP cross-area entry and US/JP same-area
`0x1F`/`0x20` warps.
Generated LevelScript receipts prove that the clean, non-credits inbound node
set is `0x0A`, `0x1F`, and `0x20`; node `0x1E` only exits Area 1, to Area 2
node `0x14`.
`stock_area1_upper_warp_preapply_platform_null` proves that every such case is
null when the old collision object overlaps node `0x1E`.  Consequently
`stock_upper_warp_has_no_platform_created_route_split` leaves **zero bounded
stock schedules whose split starts from a pre-existing platform pointer** in
that model, regardless of payload class, depth, mist branch, FIFO behavior, or
controller lineage.  A null pre-apply pointer is compatible with Ink's
graphical fallback: the retry can select the top and the final query can then
create a new platform pointer.

The older top-specific explanation remains a useful sanity check:

1. At the end of a frame, `update_mario_platform` can save the pyramid-top
   pointer only if the copied Mario object is within four vertical units of a
   top-owned floor.  The proved bounds put that object above Y `1277`.
2. On the next frame, platform displacement may change MarioState, but object
   collision still reads the old Mario object from step 1.
3. Node-`0x1E` warp overlap requires that old object at or below Y `818`.
   Those requirements are incompatible.
4. If the top has deactivated, its slot is freed only after that frame's
   platform apply.  A fragment can reuse it only in a later terrain-update
   phase, after `clear_dynamic_surfaces` removed the old top surfaces.

The admission-free theorems
`captured_top_epoch_cannot_bootstrap_upper_warp_collision` and
`captured_top_epoch_cannot_realize_route_relevant_phase_split` formalize that
finite phase/epoch argument.  The newer owner theorem subsumes the
pre-existing-platform conclusion for all stock owners in its source-bounded
relation.  In software terms, Area 1 has real "replacement object mutates all
three coordinates" primitives, but none has a non-null **pre-apply** platform
producer at the required old-object warp sample.  This does not exclude a
post-collision graphical retry and later top capture.

This is still not a retail counterexample or a whole-program impossibility
proof.  `Area1StockPreapplyProjectionSound` is a stated refinement premise, not
yet a construction from linked Clight memory.  The proof has not executed the
surface loaders and final floor selection over a live object pool or shown that
every retail pre-apply state projects into the fifteen-owner relation.
For the graphical-fallback shape, it also has not proved entry-time
Object/Graphics equality in live memory, complete reachable graphics-writer
and action/spawn closure, the first-query `NULL`, the loaded-top retry,
sink-memory provenance, or the post-copy active/inactive-same-epoch owner
lifecycle.  The old sink statement is refuted and its repaired first-return
form is open.  The lifecycle statement itself must be replaced with an exact
link, certified projection, anchored clean run, constrained external effects,
and a pointer-to-slot/epoch relation before any unload or final-owner result
can be claimed.  It does not prove that the top is scanned/deallocated or
placed on the free list.
Moving/loading the warp onto the top, moving the top down to the warp,
collision-preserving cloning, or a direct post-query pointer/object writer must
either be shown to project into the excluded cases or handled separately.

Even one successful collision frame would be insufficient: node
`0x1E` uses an action countdown followed by a delayed warp.  The trigger frame
sets timer `20` transiently during Mario's object update.  After
`area_update_objects` returns, the same frame decrements it to `19`.  Object
updates precede each of the 20 normal-play decrements through `1 -> 0`; the next
two change-area frames run no object updates; then `warp_area` unloads/loads
before the first Area-2 object update.  JP pointer retention or recapture
through that interval remains `delayed_warp_top_lifetime_obligation`.  Its
phase-indexed trace tracks the action-argument prelude, stable timer values,
version/area state, allocation epochs sampled after terrain updates and before
each platform apply, object-update validity, and the pre-first-platform-apply
Area-2 boundary.  The separate
`us_spawn_clear_blocks_retained_epoch_before_first_apply` lemma proves the
state-level consequence of a successful US clear; deriving that clear effect
from Clight execution remains open.

`JPSlotLifetime.v` and `JPFirstApply.v` now make the JP allocation boundary
less vague.  The former checks
that area terrain loads before SpawnInfo objects, follows the macro and
SpawnInfo allocation call chains, checks the free-list head push/pop assignment
shapes, and checks that the selected unload/deallocation bodies do not directly
mention `rawData`.  It also confirms that allocation contains a loop, literal
`80`, and the indexed zero-write shape expected for clearing `rawData`.  Those
are path-insensitive syntax anchors: they prove neither all possible indirect
writes nor that 80 writes execute on the relevant path.  It also proves that
the packed Area-2
macro stream contains 50 complete records in both versions and proves the
finite LIFO recurrence: if the watched slot is released before a later bulk
release, it is reached exactly after that bulk prefix is allocated.

The source audit now supplies the conditional fresh destination census.  With
all 50 macros spawning, enough free slots, and no saved cap, there are 74
loader allocations followed by ten elevator marker balls before the true
first platform application: 84 total.  A saved cap makes 85.  The first
spawner pass creates no coin children because it observes the object's old
zero flags and initialized distance 19000.  Spindel is SpawnInfo allocation
64, or zero-based free-list depth 63; allocations 60 through 63 are moving
walls.  The new Rocq module proves the `74 + 10`, optional-cap, and
popped/surviving depth arithmetic without pretending that constants are a
linked execution proof.

The control point was also corrected.  The normal destination frame runs
`warp_area`, loads Area 2, and reaches the true first
`apply_mario_platform_displacement` before Mario's first controller poll that
observes Area 2.  The older successful fixture staged its payload at that poll,
so it affected the **second** Area-2 application.  The newer midpoint fixture
starts at the post-installer Area-1 boundary and observes the stale payload's
effect at the true first destination application instead.  A valid first-apply
certificate must be destination-scoped; a record that simply forbids every
earlier platform application from the beginning of an Area-1 prelude would be
unsatisfiable because ordinary Area-1 frames contain those calls.

The midpoint run observes the top freed at depth zero, 131 old-area slots
pushed ahead of it, 84 destination allocations, and therefore depth 47 at the
first application; it also records the exact binary32 before/after Mario State.
`JPLifecycleTrace.v` proves the corresponding finite list arithmetic and the
internal consistency of the copied observation record.  These are runtime and
finite-record facts, not the missing clean game trace or linked Clight proof.
The exact pointer block/offset and epoch projection, ordered linked small-step
allocation execution, Clight refinement of the confirmed instruction boundary,
and clean installer remain explicit obligations.

For Area 1 proper, the newer audit classifies the stock pre-apply angular
payloads into top yaw, dirt triangles, and cartoon triangles.  It does not need
to decide which generic controller schedule realizes a fragment because all
bounded pre-existing platform origins are null at the old-object warp sample.
That result does not exclude a null first query followed by Ink's graphical
retry and a new top capture.  The separate JP destination-area pointer/payload
census above narrows, but does not close, that continuation.

Moving/loading the warp onto the top, moving the top down to the already-loaded
warp, collision-preserving cloning, and direct post-query writers remain
separate unresolved constructions.  The full audit and theorem boundary are in
[`docs/notes/pyramid-top-pu.md`](docs/notes/pyramid-top-pu.md).

`UpperWarpTopCoincidenceMechanism`,
`UpperWarpTopPreludeCaptureEvidence`,
`UpperWarpTopPreludeToCleanEntryBridge`, unload-retention/reuse evidence, and
`UpperWarpStaleTopConditionalPathEvidence` name the older same-sample
conditional path.  They do not encode the new three-view schedule.  A
replacement Clight evidence record must carry collision Object C, first-query
State S, pre-fallback Graphics G, the first-query `NULL`, loaded-top retry
selection, post-action State/Graphics (including the intervening
Graphics-position and throw-matrix sink writes), the copied Object, intervening
object-list/unload lifecycle, an active-or-inactive-same-epoch final
surface owner, final platform query, and delayed-warp lifetime.  If the
explosion/free-list branch is claimed, separate evidence must prove that the
top itself is scanned/deallocated and inserted into that list.  A source-backed
clean-entry theorem must either construct that evidence or prove every family
unreachable; it must not simply decree the JP platform pointer null or safe.

The midpoint probe supplies runtime values for each of those lifecycle stages
after its injected prestate: successful retry, copied State/Object, continuing
top ownership, explosion and early free, delayed-warp retention, destination
free-list depth, first application, and downstream trigger observations.  That
closes the earlier *empirical* question of whether this particular captured
pointer can survive.  It does not construct the replacement Clight evidence
record, prove the runtime's clean predecessor, or make the old underconstrained
lifecycle proposition safe to assume.

The mechanism was also tested in the authentic JP executable with a
top-derived raw payload installed once in a reused slot at the first Area-2
input poll.  With buttons always zero and the stick held straight for 60
frames, the following, second platform application moved Mario to approximately
`(365.592773, 5496, -1096.802734)`.  Mario later fell through the upper-trigger
hitbox, whose controller count changed from zero to one.  The trace contained
zero `A_BUTTON_DOWN` and zero `A_BUTTON_PRESSED` frames.  No Act 3 overlap
occurred, and the Act 6 controller remained at one of five, so the Act 6 star
was not spawned; the probe did not directly read save bits.  The payload is
route-equivalent, not yet proved byte-identical to the natural explosion-frame
top state.

The stronger current experiment no longer injects a destination slot.  It
injects only the timer-131 three-view Area-1 prestate with midpoint Graphics
`(-1862,1778,-902)`.  Retail JP then selects the live top-owned retry, retains
that same slot through its explosion/free and delayed warp, and applies the
stale pure-yaw payload at the first Area-2 application.  The resulting State is
exactly `(365.5927734375,5500,-1096.8026123046875)`.  A zero-A stick schedule
then consumes all five triggers.  A refined B/Z continuation spawns the Act-6
star at timer `949`, reaches it at timer `1342`, and records the initially-clear
primary SSL byte changing from `00` to `20` at timer `1343`.  Mario's hitbox
overlaps the star by one vertical unit, `usedObj` is the spawned pointer, and
the action becomes `ACT_FALL_AFTER_STAR_GRAB`.  The injected three-view split
remains the decisive non-retail seam.

| Counter after update | Global timer | Mario State after update |
| ---: | ---: | --- |
| `1` | `595` | `(391.871216,3949,-588.824097)` |
| `2` | `693` | `(-254.559387,2940,-602.704346)` |
| `3` | `748` | `(252.736115,1967,-602.249512)` |
| `4` | `869` | `(-1807.365845,1229,-600.141235)` |
| `5` | `1111` | `(-1909.462524,1229,2198.828857)` |

Preparing it repeatedly in numerical pool slot 60 only while Area 1 remained
loaded instead put that cell at free-list depth 7.  Area-2 macro object #5
reused and cleared it before the true first application, and the later final
floor query cleared the pointer.  The velocity and yaw logged at the controller
poll were Goomba writes after the first application.  This negative schedule
does not reproduce a top deactivated before bulk unload or the top's 30
fragments, so it does not refute an early-freed-top predecessor with a
different depth.

This trace is a concrete counterexample to “every bypass constructor is
unreachable from the current state-only clean boundary.”  It is not a
counterexample to the retail theorem, because each fixture supplies a boundary
state whose clean controller prehistory has not yet been constructed.  The
exact RAM fields and earlier frame trace are recorded in
[`docs/notes/model-counterexample.md`](docs/notes/model-counterexample.md).
The corrected chronology, exact fresh allocation table, and two-layer
installer analysis are in
[`docs/notes/jp-first-apply.md`](docs/notes/jp-first-apply.md).
The corrected timer-131 face and the conditional retained-slot lifecycle are
documented in
[`docs/notes/timer131-surface.md`](docs/notes/timer131-surface.md) and
[`docs/notes/jp-lifecycle-trace.md`](docs/notes/jp-lifecycle-trace.md).

This composition is currently the checklist's most promising counterexample
family.  Ink's Graphics-minus-Object gap is one possible **installer** for the
Area-1 top owner; it is not a competing final route.  The timed hybrid requires
the collision frame to see the spinning top at timer 131, frame 19 to run
spinning timer 150, and frame 20 to run explosion timer 0.  The old zero-yaw
home-pose Graphics Y=`1791` witness is therefore not the relevant retry surface:
timer 131 has a raised, rotated top.  The value-level binary32 transform and
selected midpoint face are now computed, and the conditional JP run observes
that selection; linked live-memory Clight execution and clean reachability
remain open.

The graphics gap may be unnecessary if a State-first top selection, physical
warp/top co-location or clone, post-commit transport, another dynamic owner,
or a skipped-query frozen carry installs the same final pointer.  None of those
alternatives is proved reachable, impossible, or collectively exhaustive in
linked retail execution.
`InkPayloadInstaller.v` records this split with data-bearing constructors and
keeps the captured Area-1 owner distinct from a same-slot, new-epoch Area-2
replacement owner.  Its theorem is conditional composition, not proof that
any constructor occurs in the game.

### What the route theorem does not establish

The route contract is a formal transcription of the supplied strategy
argument, not yet a derived projection of the retail executable.  The new
evidence structures make the required projection checkable, but their
coverage and the entrance cuts are still unproved:

- extract the collision arrays into exact surface identifiers and prove the
  source/target connected-component cuts, their run-local initial membership,
  endpoint-local separation, and their
  selection by `TargetCollisionCutFamily`;
- construct `FirstValidatedCutCrossingAt` from each linked US/JP first target
  access, including target-collision-to-cut refinement and any crossing inside
  the same frame or subframe as that collision;
- prove the six movement/domain cases and the separate same-position
  support-selection case impossible from a source-backed clean entry, or else
  produce an exact reachable counterexample trace; and
- after either cut, the transcript's remaining no-A strategies work under the
  actual Float32 movement, collision, object, and version semantics.

Completed target traces must carry a `RealizedRouteTrace`: a synchronized
abstract `CertifiedExecution` whose Act 3 and upper-trigger observations are
backed by collection and trigger-consumption events at the same frame index.
That prevents downstream access from being certified by appending a free target
label.  `CertifiedExecution` is still the handwritten event model, so this is
not a replacement for the missing Clight refinement.

Likewise, `SpawningDisplacementEscape` is currently a route-observation tag.
The new stale-top evidence interface records the predecessor, unload,
retention/reuse, and cut crossing separately, but no theorem constructs all of
those records from retail controller input.

The transcript's rollout measurements--six units short in the observed setup
and a hypothetical seven-unit lift escaping--are candidate geometric facts, not
premises of the current theorem.  They need a checked state/mesh calculation
before they can support elevator closure.

Consequently, finding an authentic no-A crossing of either entrance-specific
collision cut would invalidate that lower-bound case.  If the downstream
continuation claim is also validated, the witness would provide the missing
capability for a zero-A route to each relevant region in separate executions.
The separation matters because collecting a star normally exits the course;
the claim is not that both stars are collected in one run.  The conditional
stale pyramid-top calculations are evidence about one such mechanism.  The
Y-preserving stock-yaw arithmetic case is excluded; its execution refinement
is open.  Area 1 supplies three stock pre-apply angular-payload classes, but
the source-bounded owner/provenance theorem leaves none with a non-null platform
at the node-`0x1E` collision sample.  A generic fragment controller/free-list
lineage is therefore no longer a Layer-B obligation for the bounded
pre-existing-platform-origin subcase.  The null-preapply graphical retry, the
linked-Clight projection of that theorem, constructions outside its bounded
owner relation, and delayed-lifetime questions remain open.

The readable, family-ranked inventory of active and retired approaches is the
[`docs/no-a-route-atlas.md`](docs/no-a-route-atlas.md).  The corresponding
formal route-classification and proof boundary are spelled out in
[`docs/notes/route-exhaustiveness.md`](docs/notes/route-exhaustiveness.md).

## Why reaching those regions is relevant

The collection/provenance layer treats the save file like a protected data
sink and asks which execution events are authorized to change it.

For Act 3, a newly set bit requires a collection event involving an active
star-or-key object with index `2`, the static pyramid-star origin, and a
registered Mario/star collision in the Act 3 interaction region.

For Act 6, a newly set bit requires an active star-or-key object with index
`5`, originating from the designated hidden-star controller.  Its parent
reference, home position, and collection hitbox are fixed in the abstract
provenance invariant; its current position is fixed only at spawn because the
spawn animation moves it.  Spawning it requires all five hidden-star triggers
to have been consumed.  Consumption of the upper trigger requires the
designated macro object, its exact trigger hitbox, and a registered
Mario/trigger collision in the relevant collision phase.  The consumed
trigger's macro state is then set and no active same-kind trigger remains.
The 100-coin star uses index `6`, so it cannot directly set either target bit
even though it may be useful as a movement resource.

An executable finite source inventory separately lists all seven normal SSL
star sources.  It proves that indices `0`, `1`, `3`, `4`, and `6` cannot alias
target indices `2` or `5`.  Its first-writer classifier has three exhaustive
causes: the matching normal star interaction, an incoherent backup reload, or
an explicit corruption/unmodeled writer.  Starting from coherent active and
backup target bits and allowing no anomaly writer rules out the latter two.
This closes the logical save-reload loophole in the finite model, but a
Clight-to-writer-inventory theorem is still needed before it becomes a
whole-program result.

These statements are proved by inversion over `CertifiedExecution`.  That is
useful, but it is not yet a whole-program Clight proof: the event constructors
already require the provenance, overlap, bit-update, and trigger facts.  A
future refinement must derive those constructor premises from actual Clight
steps.

Combining the intended layers gives this proof plan:

```text
new target bit
    => authorized target collection event                 (collection layer)
    => Act 3 collision or upper-trigger collision          (provenance reduction)
    => matching target-region route cut                    (PROVED under route/event alignment)
    => first entrance collision-support cut crossing       (OPEN: Clight/mesh coverage)
    => position writer or changed support selection        (PROVED for a validated
                                                            pre-target non-target frame)
    => every crossing cause requires an A edge             (OPEN: six movement/domain
                                                            cases plus support selection)
    => at least one edge-triggered A press                 (OPEN: gate geometry)
```

The first two arrows are proved inside the abstract certified event model.
The target-region arrow is now proved by the route/event alignment carried by
`ClightRouteTraceProjection`; constructing that alignment from a retail
execution is part of the open whole-program refinement.  `ModelGapAudit.v`
shows why the old abstract endpoint relation cannot stand in for that
execution.  `FirstTargetRefinement.v` defines the older entrance-cut and
evidence-bearing bypass arrows and proves several finite eliminations.
`FirstCrossingWriterCoverage.v` proves admission-free writer coverage for an
already-constructed `FirstValidatedCutCrossingAt`; unlike the unused
`FirstTargetWriterCoverageObligation`, the cited frame is star-ordered before
a matching target-event segment, every earlier index has ordered evidence,
and none of those earlier endpoints is on the target side.  The selected
cut-family construction, mesh
connectivity, target-collision refinement, same-frame/subframe case, six
movement/domain exclusions, and support-selection exclusion remain open.  No
global US/JP bypass exclusion is proved.  The reverse direction--a cut bypass
continuing to a target--also remains conditional on separate downstream and
abstract-execution certificates.

## What the generated source already confirms

The current project regenerates CompCert Clight ASTs for both target versions
from the pinned decomp revision: 38 translation units per version, 76 modules
in total.  Direct inspection of that pinned C source shows:

The project now also executes CompCert's syntactic link checks over those
38-unit lists.  They fail for both versions: the first AST failure is the
`ssl_script` join with the SSL data wrappers, and the first composite failure
is the `area` join with the suffix beginning at `level_update`.  A deterministic
census finds 402 US and 401 JP duplicate public variable atoms whose generated
types differ, mostly because one unit has an incomplete extern array and the
defining unit has its complete length.  This is a proved linking boundary, not
a retail whole-program semantics.  The exact unresolved global externals are
listed by CompCert constructor in
`docs/notes/linked-symbol-coverage-{us,jp}.txt`: US has 133
`EF_external`, 75 `EF_builtin`, and 19 `EF_runtime` definitions; JP has
132, 75, and 19 respectively.

`NormalizedClightPrograms.v` mechanically retains the strongest available
definition for each global atom and the first generated definition for each
composite atom, then successfully builds concrete US/JP `Clight.program`
values.  That construction is called a *normalized semantic slice* on purpose:
it does not by itself repair translation-unit-local anonymous tags or prove
that incomplete-array uses and external effects simulate the C program.
`CleanedClightPrograms.v` separately builds source-owned cleaned unit lists.
The kernel-checked
`us_normalized_cleaned_units_official_link_structural` and
`jp_normalized_cleaned_units_official_link_structural` theorems inhabit the two
`NormalizedCleanedUnitsOfficialLinkStructuralObligation` propositions: the
unmodified CompCert linker returns the official US and JP cleaned targets.
That result remains syntactic; a later execution refinement is still required.

The declaration audit proves equal CompCert call ABIs for every generated
function declaration and selected definition.  Variable declarations satisfy
the exact-or-incomplete-array rule except for `gDisplayListHead`, whose pointer
views nevertheless have equal checked size, alignment, access mode, and
volatility.  All named JP residual composite layouts and the five named US
residual layouts agree.  The remaining US atom `__538` is not cosmetic: it is
a 16-byte/alignment-2 viewport structure in affected `area` and cutscene source
uses and an 8-byte/alignment-4 graphics-command structure in `game_init`.  The
actual official US target inherits the graphics-command `__538`; its `__540`
viewport wrapper is consequently 8 bytes while the corresponding source
wrapper/storage is 16 bytes.  This is a checked negative result: structural
linkability is not composite refinement.  The proof constructs a fresh-tag
  local layout for the viewport uses.  `USWholeASTTagRepair.v` now defines the
  recursive rewrite over affected type positions in expressions, statements,
  functions, globals, continuations, and states while preserving identifiers
  and initializer data.  The repaired whole-AST program is now checked to
  build.  Together with the checked official cleaned JP link, it forms the
  exact selected-program boundary used by observation projections.  The old
  demand for one `TargetLinkedProgram` above every original unit is impossible
  for the incompatible composite bindings and is no longer the selection
  premise.  The replacement boundary separates a checked structural fact from
  an open semantic fact.  `OriginalUnitsHeaderNormalizationStructuralObligation`
  is inhabited by the source-owned cleaned-link certificate; it proves
  ownership, verbatim strong definitions, identifier/composite coverage,
  normalized-header use, and successful whole linking, but not standalone-unit
  execution equivalence.  `WholeLinkedSourceToSelectedTargetRefinementObligation`
  starts semantics only from that whole link and requires lockstep with the
  selected target at matching runtime-task starts.  The start predicate fixes
  initialized `thread5_game_loop`, one null pointer argument, `Kstop`, and a
  real first Clight step, so neither a missing `_main` nor a false match
  relation can make the interface vacuous.  JP now has initialized memory,
  exact task-body resolution, a genuine null-argument first step, and an
  identity source-to-selected lockstep witness.  The OS handoff is outside the
  scoped gameplay run.  The repaired-US initialization/start and
  lockstep also remain open.  Replacing only the target's composite table would leave the old
  annotations behind and is unsound.

The repaired target now has its own static audit rather than borrowing receipts
from the official cleaned slice.  Conditional on a projection selecting
`VersionUS` and `us_viewport_repaired_program`, `USSelectedTargetAudit.v` checks
that the actual successful repaired program has no direct `Sbuiltin`, only the
supported external constructors, resolvable internal-body `Evar` names and
initializer `Init_addrof` names, and a `find_symbol` witness for each of the five
core identifiers.  These facts do not identify live memory blocks or prove their
shape or contents, initialization, or any source-to-selected execution step.

`ClightLinkExecution.v` uses exact-definition provenance from each official
target, through its cleaned unit, back to the source units.  On both actual
official targets it proves that every nonlocal internal-body `Evar` and every
global-initializer `Init_addrof` occurrence resolves to a linked symbol.  Every
retained or reachable global `External` is one of `EF_external`, `EF_builtin`,
or `EF_runtime`, and exhaustive recursion through the official function bodies
proves that neither target contains a direct `Sbuiltin`.  The source/normalized
external inventories remain exactly US 133/75/19 (227 total) and JP 132/75/19
(226 total) for those three constructors.

There is now one deliberately bounded execution bridge beyond that syntax
census.  If a global name resolves in the source, the source and target
function environments both show that the name is not a stack local,
`NamedSymbolCoverage` supplies its target block, and the current memories are
already related by the name-based `Mem.inject`, then
`named_global_evar_lvalue_execution_bridge` constructs the source and target
`eval_lvalue` derivations for that `Evar` and proves that their zero-offset
pointers satisfy CompCert `Val.inject`.  `ClightEndToEndRefinement.v` now
relates locals, temporaries, all continuation constructors, and all Clight state
constructors; it also proves injected loads, stores, dereferences, pointer
validity, unary/binary operations, and casts.  The US/JP whole-expression
induction and concrete internal-step instance are still unproved.

`GlobalInterfaceStructural.v` adds a generic selector-exactness result: under
explicit uniqueness and checked-selection hypotheses, each definition emitted
by the cleaned selector is exactly the normalized map entry at that name.  It
does not instantiate those hypotheses for US or JP and does not prove the
concrete global-definition map, public-name map, or initialized memory.

One smaller JP fact is concrete: an explicit definition receipt from any
generated JP unit transports through the checked source-union coverage and
official cleaned link to existence of the same named linked symbol.  That
one-name theorem alone does not build the ordinary-entry bundle.  Twelve
focused receipts plus `JPArea1EntrySymbolResolution.v` now do construct an
`Area1EntryAddresses` witness for the official cleaned JP environment, fix its
Mario and entry-warp slots to `0` and `1`, and inhabit all twelve
`JPArea1EntrySymbolBindings`.  The structural capstone also proves both slots
valid, makes Mario-state/controller/object-pool storage pairwise distinct, and
separates every pointer cell from those core storage blocks.  The platform
receipt uses aggregate public-name coverage and cleaned-link transport rather
than a direct definition-map receipt.  None of this proves allocation or layout
sizes, initializer values, live memory contents, routing, reachability, or
execution.

The same file uses CompCert's real external-call simulation interface.  Given
`symbols_inject`, `Mem.inject`, and injected argument values, it produces an
injected result and memory, a growing and separated injection, and the standard
`loc_unmapped` and `loc_out_of_reach` preservation facts.  It lifts external
`Callstate` steps and, generically, direct `Sbuiltin` steps after separately
injecting the evaluated arguments.  Those theorems do not manufacture the
premises needed for the game: the normalized/original-to-official global
interface and public-name agreement, initial and current-state memory
injections, expression/continuation/internal-step relation, and writable
Mario/object/controller frames remain to be proved.

The external-frame target is now more precise.  A reachable call chooses its
protected cells from the external, its actual arguments, and its pre-memory;
the effect must either preserve those cells or be modeled as a concrete
writer/lifecycle transition.  The old declaration-wide frame over every byte
of `gObjectPool` is overstrong because legitimate omitted helpers can allocate
and write pool slots.  Six body-local receipts, two per-version aggregations,
and a final certificate now prove that the selected unresolved direct-callee
set of the seven dialog/depth bodies is exactly the expected ten names for US
and JP.  Path-sensitive reachable call sequences, transitive reachability,
argument provenance, and actual frame-or-writer cases remain explicit obligations.

The observation bridge now has a sounder data path as well.  A data-bearing
frame chronology records concrete Clight endpoints and traces, projected
states, inputs, events, collision observations, and local `CertifiedStep`
witnesses under one fixed observer.  Every observed gameplay or administrative
frame contains a nonempty Clight `plus`; silent no-poll chunks may stutter and
emit no input or event.  The observer interface pins the controller and pointer
bindings plus the exact poll and Mario-consumer bodies.  It authenticates a separate
boundary input and supports gameplay and poll-only administrative frames.
Checked composition turns a supplied
exact chronology into the whole-run refinement certificate, and supplied
nonempty `thread5_game_loop` task-entry prefixes into clean-entry nonvacuity for
the optional upstream extension.  The scoped proof instead starts at
`DefaultArea1StartBoundary`.  It constructs none of the observer, concrete
frame classification, projection, chronologies, or two boundary-to-clean-entry
prefixes.

For SSL Area 1 (the exterior),
`DefaultArea1StartBoundary` assumes exact ordinary-entry memory, coherent no-A
history, and a null global platform pointer.  A separate conditional upstream
theorem turns a supplied
entry memory postcondition and no-A sample into the live controller predicate
and a reflexive zero-A suffix.  If the castle-to-`warp_level` prefix, the
`warp_level` symbol and expected internal-body resolution, its execution, all
entry symbol bindings, and that postcondition are also supplied in one program,
their traces compose at the real return state.  The theorem does not construct
those premises.  `JPWarpLevelEntryResolution.v` separately supplies the exact
symbol/body resolution for the official cleaned JP program.  The focused
`USWarpLevel*Receipt.v` chain and `USWarpLevelEntryResolution.v` transport the
generated US definition through normalization and viewport repair and resolve
that exact internal body in the selected repaired program.  Live castle
routing and entry execution remain optional upstream work.  Boundary
projection, post-boundary routing, and the remaining US bindings remain open.
The twelve official-JP symbol bindings and limited separation facts are now
available separately from `JPArea1EntrySymbolResolution.v`; they do not turn
the conditional bridge into a live prefix.

- the controller input calculation distinguishes `buttonPressed` from
  `buttonDown`;
- the pole action bodies test `INPUT_A_PRESSED` on paths selecting pole-jump
  actions;
- the pole source also contains the Z-triggered soft-bonk/drop path,
  so "the source mentions A" alone is not a pole-impossibility proof;
- object processing applies Mario's platform displacement before detecting
  object collisions;
- platform displacement writes MarioState, object collision reads the old
  Mario object, and Mario's later behavior copies State back to the object;
- `find_floor` narrows all three coordinates to a signed 16-bit C type, while
  object hitboxes use full binary32 coordinates; the concrete CompCert cast is
  proved, and authenticated US/JP disassembly plus Rocq fragment arithmetic
  confirms the same three concrete retail results;
- `math_util.c` and `surface_load.c` are now imported, so the matrix and
  transformed dynamic-surface helper bodies are no longer unconstrained
  externals in the linked-program obligation;
- the Area-1 macro wrapper exposes three wing-cap/exclamation-box records and
  two no-coin breakable-box records at their exact source coordinates;
- the generated fragment helpers contain the nonzero pitch/yaw fields, the
  object-count `210` mist-suppression threshold, and the fresh-allocation
  80-word clearing shapes used by the Area-1 candidate;
- the stock source audit classifies pre-apply angular payloads as pyramid-top
  yaw, dirt triangles, or cartoon triangles, with parametric free-list depth,
  mist-count, zero-allocation, and FIFO-eviction variants;
- the normal warp interaction, geometry refresh, disappeared-action floor
  snap, projected Graphics-position quicksand sink, and state/object copy occur
  in the phase order used by the new PU coordinate witness.  The sink can also
  write `gfx.throwMatrix`; remaining object lists and deactivated-object unload
  run before the final platform query.  The generated source admits a distinct
  explosion-frame inactive-owner candidate.  Exact timer-131 arithmetic rejects
  the home-pose Y `1791` sample and accepts midpoint
  `(-1862,1778,-902)`; the injected JP run then observes free-list membership,
  retained ownership, and first-apply displacement.  The repaired first-return
  sink refinement, clean installer, and linked post-copy lifecycle interface
  remain open;
- the geometry refresh has a guarded first-floor-null branch that copies
  `MarioObject.header.gfx.pos` into MarioState and retries `find_floor`, which
  creates the three-view scheduling shape used by `InkFallback.v`;
- if that retry is also null, the geometry refresh calls
  `level_trigger_warp(m, WARP_OP_DEATH)` before interaction processing.  The
  generated US/JP recognizers check this guarded call, the direct-assignment
  first-writer shape, and the call order.
  `retail_fatal_latch_source_kernel_checked` packages those facts with the
  five-function direct-writer census, explicit address-taking census,
  clear-site call-presence/callee-order plus separate clear-presence anchors,
  and Area-1 death-destination record.  The receipts do not prove
  assignment/call order or destination selection.
  `retail_fatal_persists_or_reset_destroys_disappeared` proves the finite
  event-system invariant; `retail_fatal_latch_checked_boundary` conjoins that
  theorem with the generated receipts, and
  `over_permissive_clear_accepts_upper_counterexample` refutes the old
  clear-with-live-continuation abstraction.  That conjunction is not a
  source-to-event semantic refinement.  Concrete accepted-fatal
  initialization, event coverage, clear/reset barriers, linked latch-memory
  preservation, and both `find_floor` outcomes remain open;
- arbitrary ordinary, platform, or PU-sized **State-only** writes preserve the
  collision Object and fallback Graphics samples.  The source audit identifies
  `45` as the dry route-specific visual-offset target, while the deliberately
  conservative modeled water/bob writer relation uses `208`; both are below
  the signed-range generic required `385`.  The two exact proposed prestates
  require
  `973`; applying any bound to every reachable retail writer is open.
  Complete retail writer/action/spawn closure remains open.  In particular, a
  prepared `ACT_LONG_JUMP_LAND` state can produce negative depth.  If the
  updater already sees quicksand, timer 5 gives about `-2.65`; if the updater
  sees ordinary floor and the later ground step crosses onto quicksand, timer
  4 gives exactly `-0.5f` and timer 5 gives exactly `-4.0f` in the checked
  source-shaped binary32 model.  In the ordinary action graph, reaching these
  long-jump landing timers requires a prior A-edge setup.  Stock upper-warp
  support is `SURFACE_WALL_MISC` and cannot itself generate that adjustment,
  but persisted depth still requires linked action/state and alias closure;
- node `0x1E` is delayed: object updates run before each of the 20 normal-play
  timer decrements, two change-area frames omit object updates, and the
  following normal frame loads Area 2 before its first object update;
- the US spawn path directly clears `gMarioPlatform`, while the JP path does
  not contain that direct clear call; and
- the no-spin airborne entry handler calls the launch helper with single-
  precision zero, and that helper calls forward-velocity setup and
  `perform_air_step`;
- `mario_actions_submerged.c` is now imported for both versions.  Admission-free
  AST receipts cover the water full-step helper calls, all three direct
  whirlpool position slots, and the common water-level clamp.  This closes the
  missing translation-unit hole, not SSL action reachability or complete
  position-writer callgraph refinement; and
- target collection, hidden-star, area transition, object lifecycle, and
  collision functions are present in the generated source set.

The checked Rocq AST theorems are narrower: they establish selected operator,
identifier, constant, direct-call, and direct-callee-order shapes.  In
particular, the pole AST theorem checks occurrences of the relevant input and
action constants; it does not prove branch control dependence or that those
branches exhaust every way past the pole.  The new raw-slot recognizers are
also base-insensitive, so the phase pipeline is a direct-source inspection
backed by separate syntax anchors, not an AST-level dataflow theorem.

The generated collision wrapper contains the area 1/2/3 static arrays and the
pyramid-top, Tox Box, Grindel, Spindel, moving-wall, elevator, Eyerok,
breakable-box, exclamation-box outline, cannon-lid, and wooden-signpost arrays.
Rocq proves their checked initializer word counts and that the route-relevant
US and JP initializers are identical.  The new Area-1 owner audit also proves
the exact local X/Y/Z bounds of the last four meshes.  The pyramid audit checks
all 39 top words exactly and parses its five vertices and six triangle indices.
For the selected top face, it links those parsed words to manually translated
zero-yaw home vertices and evaluates signed-short casts, partition cells, and
hand-mirrored binary32 transform and edge arithmetic.  Generated helper bodies
are present, but the arithmetic is not extracted from or executed through those
bodies.  The general area arrays are not yet parsed into surfaces, and no
linked live-surface construction, actual `find_floor` list selection, or
surface connected-component theorem is proved.

The area script also contains a conditional
`SSL_SPAWNING_DISPLACEMENT_TAS_HACK` branch used for experiments.  The target
generation leaves that branch disabled.  Its hacked position/platform setup is
therefore not evidence about either target ROM.

These are syntax and source-shape checks.  They do not prove branch dominance,
loop execution, exact memory effects, route coverage, or reachability.

## How the six earlier projects support the argument

The archived projects are treated like previous design investigations: they
identify invariants, failure modes, and candidate lemmas.  The current project
does not import an old generated AST or assume an old capstone.  Selected facts
are regenerated or reproved in the current namespace.

| Prior project | Evidence in favor of the route argument | What it still does not prove |
| --- | --- | --- |
| `ssl-spawning-displacement-proof` | Identifies the JP stale-platform mechanism, retained inactive/reused slot cases, and the exact spinning-top payload that can move upper-entry Mario outside the shaft. Its State/Object timing observations motivated the rechecked phase-split source facts. The injected-boundary JP trace now observes midpoint capture, explosion/free retention, the first Area-2 apply, all five triggers, star spawn, overlap, and an Act-6 save-bit transition. | A linked Clight proof covering every retail Area-1 pre-apply state, or a clean installer for the required `>=960` Graphics/Object gap. The archive's hand-selected unowned-floor observation is not stock provenance. |
| `ssl-pyramid-item-proof` | Shows the proof shape needed for area unload/reload, object deletion, free-list slot reuse, and allocation identity.  This supports the claim that outside objects do not simply survive as substitute target stars. | A linked execution proof of the unload loop, target-star provenance, or either route gate. |
| `ssl-parallel-universe` | Correctly models continuously held A as zero new edges and warns that a bounded-position proof must cover every movement writer.  It tests a possible way of bypassing ordinary geometry. | Complete movement-writer coverage or non-reachability of either target region. |
| `pole-bypass` | Proves a one-A lower bound for a restricted normalized pole model and isolates `bypass_model_complete` as the missing global premise.  This is evidence about the normal second-pole route. | Every approach state, pole avoidance route, object/platform interaction, Float32 collision phase, JP execution, or the actual target-side support cut.  Its pole-height abstraction is not route-exhaustive. |
| `eyerok-manipulation` | Provides negative evidence against using the area-3 boss and platform state to manufacture unbounded height, and records the US/JP platform-state split. | A complete exclusion of every area-2/area-3 high-entry technique or a route to either target. |
| `demo-warp` | Demonstrates why memory provenance matters: a byte store can alter Mario state under an aliasing premise, while normal initialization can rule out that alias in a narrower model. | Any direct pyramid route result, or a current-revision whole-program memory proof. |

Taken together, the projects make the two-gate hypothesis more credible and
make its missing completeness assumptions much more precise.  They do not
compose into a proof of the final claim.

## Exact remaining obligations

The ultimate theorem needs all of the following:

1. Use the exact selected targets—the checked repaired US program and checked
   official cleaned JP link—without treating their construction as retail
   semantics.  The actual-target `Evar`, `Init_addrof`, external-constructor,
   and no-direct-`Sbuiltin` results are proved.  Instantiate the generic
   selector theorem for US/JP; retain the checked original-unit structural
   link/header-normalization certificate and the now-checked reflexive JP
   source-to-selected instance.  The JP exact-program/syntax/five-core-symbol
   selected-target audit is also checked, and its capstone reduces the
   official-JP `SelectedTargetClightRefinementObligation` to the generic
   `TargetClightRefinementObligation`.  That remaining obligation still needs
   the concrete observer, chronology, boundary-to-entry prefixes, and selected-to-retail
   semantics.  Retain the separately checked repaired-US actual-program
   syntax/five-core-symbol-existence audit, and inhabit repaired-US
   whole-linked-source-to-selected viewport-repair execution lockstep at a
   matching runtime-task start.  Prove the full global-reference/public-name and
   name-based memory interface; the static audit supplies none of the required
   initialization, memory shape/content/block correspondence, boundary-start
   routing/prefix/chronology, or selected-to-retail semantics.
   Establish current `Mem.inject` and expression, continuation, internal-step,
   and final execution simulation.  Classify every reachable external effect
   through the new callsite-sensitive frame-or-writer interface.  The exact
   ten-name dialog/depth direct-callee inventory is checked; path-sensitive
   reachable call sequences, transitive reachability, argument provenance, and effects remain.  Do not
   impose the false whole-pool frame on legitimate object writers.  The exact normalized/source
   coverage inventories remain US 133/75/19 and JP 132/75/19; the 75 builtins
   and 19 runtime helpers per version are not `EF_external` calls.
2. Project Clight memory and traces to `GameState`, frame inputs, lifecycle
   events, and complete collision observations.  Construct one fixed observer,
   instantiate its pinned bindings, classify gameplay/admin frames, construct
   exact data-bearing frame chronologies for the selected runs, and execute
   nonempty prefixes from `DefaultArea1StartBoundary` in SSL Area 1 (the
   exterior) to both clean pyramid entrances;
   the generic chronology and entry bridges are conditional on these witnesses.
3. Prove that the projection produces `CertifiedExecution`, including object
   provenance, behavior-parameter decoding, deletion/reuse, macro respawn,
   unload/reload, instant-warp, and collision-list timing.
4. Parse the generated collision arrays into surfaces and prove exact
   source/target support and open-cell cuts for both entrances.  The selected
   pyramid-top home face and exact timer-131 raised/rotated face arithmetic are
   checked.  The conditional JP probe observes the corrected face selection,
   but its linked live construction, list ownership/order, actual Clight
   `find_floor` traversal, and the general support graph remain open.
5. Construct `FirstValidatedCutCrossingAt` from every linked first target
   access.  The abstract non-target-frame writer coverage theorem is now
   proved; the remaining construction must connect the target collision to a
   selected `TargetCollisionCutFamily` member and account for crossings inside
   the same frame or subframe as the target collision.
6. Eliminate, under the linked retail no-A execution, local ordinary motion,
   platform displacement, object/moving geometry, clip/tunnel,
   coordinate-alias/out-of-bounds ordinary-physics endpoints, and
   lifecycle/entry displacement.  Separately eliminate the seventh
   same-position floor/platform support-selection case.  None of these global
   exclusions is proved.  For Ink's graphical fallback, replace the
   predicate-sensitive surface, writer, and prestate schemas with concrete
   linked-run relations.  The surface replacement must execute the real first
   `find_floor` query and graphical retry over the live static and dynamic
   lists.  Then prove entry-time Object/Graphics synchronization plus complete
   reachable writer/action/spawn closure, or construct the exact clean no-A
   three-view prestate.  Prove the repaired first-return,
   modular-cell-disjoint `InkFallbackSinkMemoryRefinementObligation`.  Replace
   `InkFallbackPostCopyLifecycleRefinementObligation` with an exact linked
   program that exactly links the imported `behavior_script.c`, an anchored clean run, a certified
   memory projection, external-call frame conditions, finite transformed
   surface samples, and concrete pointer-to-slot/epoch linkage.  The conditional
   midpoint run observes later writers, unload, retained surface identity,
   explosion/free at depth zero, and the final inactive owner, but those
   observations are not a linked theorem and begin after debugger installation.
   Prove the same facts from a clean run rather than assuming the trace record.
7. For JP platform displacement, derive every admissible raw pointer from an
   actual predecessor, including inactive/reused slot epochs and the
   upper-warp/spinning-top coincidence families.  The source-level LIFO shape,
   50 packed macro records, and Before/At/After count cases are proved.  The
   Area-1 audit classifies the three stock pre-apply angular-payload classes and
   proves that every source-bounded stock platform origin is null at node
   `0x1E`; generic fragment controller/free-list lineage is therefore no longer
   a Layer-B obligation.  `JPInstallTimerWindow.v` proves timer 131 unique for
   the observed affine freeze/explosion schedule, while `JPLifecycleTrace.v`
   proves the copied depth arithmetic `131 - 84 = 47` and trace consistency.
   What remains is the linked-Clight proof that every
   retail Area-1 pre-apply state projects into that owner/origin relation, plus
   live surface construction/list selection, alternative constructions outside
   the bounded relation, and a clean installer.  The injected JP run observes
   delayed-warp retention, the exact early-free depth and destination allocation
   state, and the first-apply payload; an authentic entry/return receipt now
   confirms the retail instruction boundary.  The pointer/epoch and linked
   Clight refinement remain open.  The concrete candidate cast is
   verified for both retail versions, but it does not discharge the replacement
   surface interface described in item 6.
8. Validate the no-A downstream paths from each successful bypass.  The current
   conditional midpoint route consumes all five Act-6 triggers, spawns and
   overlaps the star, and newly sets its bit using B/Z/stick without A.
   Any Act-3 continuation and clean reachability of the injected boundary
   remain open.

Until these obligations are discharged,
`conditional_evidence_bearing_clight_run_impossibility` and
`conditional_target_clight_run_impossibility` are correctly named
*conditional* and the retail-game theorem remains open.

## How to inspect and build the proof

The most useful entry points are:

- `proofs/TranscriptRouteModel.v`: route-observation contract and gate/bypass
  lemmas;
- `proofs/InputSemantics.v`: edge-triggered A definition;
- `proofs/SourceExhaustiveness.v`: finite normal-star and target-save writer
  inventory;
- `proofs/StarCollection.v` and `proofs/HiddenStar.v`: collection reduction;
- `proofs/ClightFacts.v`: checked generated-AST source facts;
- `proofs/ClightRefinement.v`: the explicit missing semantic bridge;
- `proofs/CompCertRouteScope.v`: successful-access and registered-call-target
  semantic lemmas plus the checked ranks 1–3 scope/disposition table separating
  defined Clight work, external-effect refinement, and deferred machine-only
  OOB/ACE/DMA routes;
- `proofs/SelectedClightTarget.v`: exact repaired-US/cleaned-JP target
  selection, checked original-unit structural normalization, whole-linked
  task-anchored source-refinement interface, concrete runtime-task-start
  predicate, and selected-target audit-transport obligation;
- `proofs/ClightProjectionChronology.v`: data-bearing frame chronology,
  projection-certificate composition, and conditional entry-prefix bridge;
- `proofs/LinkedClightPrograms.v`: exact 38-unit CompCert link-failure
  certificates and first failed joins;
- `proofs/NormalizedClightPrograms.v`: executable normalized semantic slices
  plus the explicit, unproved semantic-refinement boundary;
- `proofs/CompositeLayoutRefinement.v`: definitions and generic lemmas for
  declaration ABI/storage checks, residual composite layouts, the exact US
  `__538` collision, fresh-tag coverage, and local layout repair;
- the `US*Certificate.v` and `JP*Certificate.v` receipt modules: independently
  compiled composite, declaration, collision, alpha-renaming, fresh-tag, and
  whole-body affected-global checks, split so clean builds remain memory-bounded;
- `proofs/CleanedClightPrograms.v`: source-owned cleaned-unit construction,
  exact definition/source provenance, and kernel-checked US/JP structural
  official-link inhabitants;
- `proofs/CompositeOfficialLinkBridge.v`: kernel bridges from those structural
  targets to the audited composite environments, including the proved negative
  result that the current official US target has an incompatible `__538` and an
  8-byte `__540` viewport wrapper where the affected sources require 16 bytes;
- `proofs/ClightLinkExecution.v`: actual-official-target `Evar`,
  `Init_addrof`, external-constructor, and no-direct-`Sbuiltin` checks, plus
  CompCert `symbols_inject`/`Mem.inject` transport for external `Callstate` and
  generic direct-`Sbuiltin` execution;
- `proofs/USWholeASTTagRepair.v`: recursive syntax/state transformer for the US
  viewport tag and the still-open repaired-program execution simulation;
- `proofs/USViewportRepairedProgramCertificate.v`: checked success flag for
  the concrete repaired US program construction;
- `proofs/NormalizedDefinitionNameTransport.v`,
  `proofs/DefinitionListSyntaxTransport.v`,
  `proofs/USViewportRepairDefinitionPreimage.v`,
  `proofs/USViewportRepairDefinitionListSyntax.v`, and the focused
  `proofs/USRepaired*Audit.v`/name-transport modules: syntax and identifier-name
  transport to the actual successful repaired program;
- `proofs/USSelectedCoreGameInitReceipt.v` and
  `proofs/USSelectedCoreObjectListReceipt.v`: `find_symbol` existence for the
  five core US identifiers, without memory-shape/content/block claims;
- `proofs/USSelectedTargetAudit.v`: conditional repaired-US
  `SelectedTargetAuditTransportObligation` capstone; no initialization,
  source-to-selected execution lockstep, boundary-start route/prefix/chronology,
  or selected-to-retail semantics;
- `proofs/ClightGlobalMemoryRefinement.v`: concrete strong-definition
  membership, generic relocation-aware initialization, and the explicit US/JP
  name-based initial-memory obligations;
- `proofs/GlobalInterfaceStructural.v`: generic cleaned-selector exactness;
  concrete US/JP global/public-map instantiation remains open;
- `proofs/JPSelectedTargetAudit.v`: exact-program, syntax, and five-core-symbol
  selected-target audit for projections fixed to the official cleaned JP link,
  plus reduction of its full selected-target obligation to the generic target
  Clight refinement obligation; no observer/chronology, entry prefix,
  or selected-to-retail semantics;
- `proofs/JPSourceSymbolTransport.v`: one-definition JP source-to-official
  symbol transport used by most focused entry-symbol receipts;
- the twelve `proofs/JPArea1Symbol*Receipt.v` modules and
  `proofs/JPArea1EntrySymbolResolution.v`: official-JP twelve-symbol
  `Area1EntryAddresses` construction at slots `0`/`1`, slot validity, core
  storage separation, and pointer-cell/core-storage separation; no live memory
  contents, sizes, initializer values, or execution;
- `proofs/RetailExternalFrames.v`: concrete Mario/object/controller byte
  footprints, proved builtin/runtime frames, and the legacy declaration-wide
  unresolved-external boundary;
- `proofs/RetailExternalFrameReachability.v`: reachable callsite-sensitive
  frame-or-writer interface and finite dialog/depth inventory definition;
- the `proofs/DialogDepth*Receipt.v`, `DialogDepthUSFiniteInventory.v`,
  `DialogDepthJPFiniteInventory.v`, and `DialogDepthFiniteInventory.v`
  modules: exact US/JP ten-name selected unresolved direct-callee certificate;
- `proofs/ClightEndToEndRefinement.v`: environment, continuation, state,
  pointer, scalar-operation, lockstep, and initial-to-final composition lemmas;
- `proofs/OrdinaryArea1EntryMemory.v`: ordinary node-`0x0A` entry receipts,
  symbol/layout/slot facts, synchronized memory postcondition, and remaining
  live-entry obligations;
- `proofs/Area1EntryZeroAPrefix.v`: conditional entry-postcondition/no-A
  reduction, generic caller-supplied route/`warp_level` symbol/body/execution
  prefix composition, and an official-JP corollary with exact symbol/body
  lookup discharged;
- `proofs/JPGeneratedWriterCensus.v`: receiver-neutral 38-unit coordinate,
  depth, action, dialog, and lifecycle writer census;
- `proofs/InkTimer131ProducerClosure.v`: bilateral all-behavior graphical-
  offset bound, Mario flag/offset source receipts, exact Chuckya/King-Bob-omb
  anchor provenance exclusion, and the non-stock `+1160` accepted retry
  witness;
- `proofs/InkTimer131MarioTailClosure.v`: bilateral direct flag/offset writer
  inventories, closed Mario-callback direct-call graph, spawn/current-object
  source identity receipts, exact `OR_INT` path, and bit-0 preservation;
- `proofs/InkTimer131IndirectAliasClosure.v`: stock landing/interaction
  indirect-target closure, typed outside-call handoff exclusion, exact
  dangerous-cell overlap boundary, sole reachable behavior writer, and
  list-12 eviction versus list-0 Mario slot-reuse frame;
- `proofs/InkTimer131CorruptionClosure.v`: exact named-use/no-writer censuses
  for both mutable dispatch tables, stable Mario constructor behavior
  forwarding, the imported initialized-interaction closure, and the clean-seed
  plus untransported-dialog no-go results;
- `proofs/NegativeDepthInteractionClosure.v`: bilateral closure of all 29
  initialized interaction handlers, their 23 direct action literals, four
  local selectors, both dynamic action helpers, and all 18 knockback-table
  entries; every stock outcome is non-long-jump, while writable-table and
  pointer/external preservation remain explicit;
- `proofs/WritableActionTableClosure.v`: packages the ordinary-controller
  no-writer boundary for the 320-byte handler/knockback storage, proves that a
  hypothetical selected four-byte knockback cell can carry any action word
  including long jump, connects that cell to the checked action consumer, and
  identifies signature-compatible coin/pole handler-pointer payloads; a valid
  alias or reached outside-table write remains the exact in-model residual;
- `proofs/InkTimer131LiveIdentityClosure.v`: exact SSL `&bhvMario` command and
  spawn-record forwarding receipts, plus arbitrary finite clean-store safety
  and a distinct-slot/list-12 eviction trace embedding;
- `proofs/InkTimer131ClightTraceBridge.v`: concrete entry tail loads, bounded
  list-0 pointer-path and same-slot identity, command/dispatch load snapshots,
  membership-preserving mutable-list steps, callsite-sensitive external
  frame-or-writer effects, and preservation/no-danger results across an actual
  reachable CompCert small-step trace;
- `proofs/InkTimer131EntryExecutionClosure.v`: exact official-JP initial zeros
  for both watched words in every valid pool slot, the bilateral
  allocator/load/spawn and sole-list-0-behavior receipts, a direct list-head
  membership constructor, and first-failing-step extraction for dangerous
  actual traces;
- `proofs/InkTimer131RealEntryPrefix.v`: the accepted authenticated 19-write
  machine-entry theorem with exact checkpoint, spawn, slot/list/behavior, and
  safe-tail facts; an optional phase-correct continuous clear/load/spawn/init
  CompCert certificate with per-step watched-cell classification; and the
  theorem deriving the live invariant from any completed Clight prefix and its
  final entry/behavior/list observations;
- `proofs/InkTimer131PostEntryMachineTrace.v`: exact neutral and conditional
  spinning post-entry receipts, safe watched-write replay, disjoint slot-61
  pillar fixture, callback/lifecycle/outside-call counters, authentic
  debug-print JAL targets, and selected timer-131 safe-tail boundaries;
- `proofs/UpperElevatorQuarterStepClosure.v`: exact 32/40-query non-Wing
  binary32 schedules, six-result source split, safe initializer cap writes,
  and the retained-Wing transient `234` query that invalidates endpoint-only
  closure;
- `proofs/JPCoordinateLvalueReceiverPartition.v`: 38-unit allowed receiver-tag
  check for the four coordinate-lvalue census shapes;
- `proofs/JPOfficialInitialMemory.v`: constructive initial-memory existence for
  the official cleaned JP link, via split alignment and relocation receipts;
- `proofs/LinkedGlobalInitialMemory.v`,
  `proofs/JPObjectPoolCleanedUnitDefmapReceipt.v`,
  `proofs/JPObjectPoolLinkorderShape.v`,
  `proofs/JPObjectPoolOfficialLinkorderReceipt.v`,
  `proofs/CheckedLinkedDefinitionShape.v`,
  `proofs/JPObjectPoolOfficialShapeReceipt.v`,
  `proofs/JPObjectPoolOfficialDefmapReceipt.v`,
  `proofs/JPObjectPoolCleanedUnitReceipt.v`, and
  `proofs/JPLinkedObjectPoolInitialMemory.v`: resource-bounded transport of the
  exact JP object-pool variable through the official cleaned link, exact global
  lookup, and static initial-memory `Cur Writable` permission for
  `[37088,37696)`; no byte/payload contents, current-memory preservation,
  pointer epoch, allocation chronology, execution, or retail refinement;
- `proofs/JPThread5EntryResolution.v`: exact official-link symbol/body
  resolution for `thread5_game_loop`;
- `proofs/JPSelectedRuntimeTaskStart.v`: initialized null-argument call state,
  concrete first `Clight.step2`, and checked reflexive JP source-to-selected
  refinement; it does not model the optional OS/castle-to-boundary extension;
- `proofs/JPWarpLevelEntryResolution.v`: exact official-JP `warp_level`
  symbol/body resolution; it does not prove castle routing, body execution, or
  the entry postcondition;
- `proofs/USWarpLevelSourceReceipt.v`,
  `proofs/USWarpLevelSourceUnionReceipt.v`,
  `proofs/USWarpLevelNormalizedReceipt.v`,
  `proofs/USWarpLevelViewportReceipt.v`,
  `proofs/USWarpLevelRepairIdentity.v`,
  `proofs/USWarpLevelRepairReceipt.v`, and
  `proofs/USWarpLevelEntryResolution.v`: focused source-to-normalized-to-repaired
  transport and exact `_warp_level` symbol/internal-body resolution in the
  selected viewport-repaired US program; no routing, reachability, execution,
  entry postcondition, or complete US binding bundle;
- `proofs/JPZeroAReachability.v`: parameterized live-`buttonPressed`
  zero-edge relation and conditional per-step-to-global gap composition;
- `proofs/CollisionMeshFacts.v`: generated collision-array counts and
  cross-version equality, the exact 39-word pyramid-top initializer, and exact
  local bounds for the breakable-box, exclamation-box-outline, cannon-lid, and
  wooden-signpost meshes;
- `proofs/Area1FirstNull.v`: generated-initializer parser and exact static
  cell-inventory computation; a pure static wall/floor evaluator with computed
  rejection trace, signed-32 bounds, and decisive binary32 receipts; plus
  explicitly separate live-Clight/dynamic-list/reachability obligations;
- `proofs/EntryMemory.v`: generated layout certificates and the conditional
  `Mem.load` postcondition-to-projection theorem; entry execution is pending;
- `proofs/PyramidTopSurface.v`: generated matrix/surface bodies and checked
  concrete Clight/retail-fragment cast values, parsed-to-manual zero-yaw
  face link, hand-mirrored cell/transform/edge arithmetic, and guarded
  dynamic-floor assignment source shape;
- `proofs/PyramidTopPU.v`: the modeled same-sample contradiction, conditional
  Y-preserving stock-yaw arithmetic exclusion lemmas, the phase-separated
  coordinate countermodel, and delayed-lifetime obligation;
- `proofs/Area1NonlocalCastSemantics.v`,
  `proofs/Area1InvalidCastArithmetic.v`,
  `proofs/Area1NonlocalYCastArithmetic.v`, and
  `proofs/Area1NonlocalEndpointBoundary.v`: failed-conversion classification,
  checked trapping prefix, exact three-axis finite alias, and the
  conditional State-first timer-131 capability with its named retail bridges;
- `proofs/Area1NonlocalPlatformMirror.v`: the concrete X/Z-velocity plus
  180-degree platform payload and generated sine-table receipt that map the
  synchronized upper-warp centre to the exact State-first alias in binary32;
- `proofs/Area1NonlocalPlatformInstallationClosure.v`: the stock scheduler
  no-go for applying that payload at the upper warp, canonical payload-source
  exclusions, and the six-case residual classification for a linked escape;
- `proofs/Area1StateFirstWallExclusion.v` and
  `proofs/Area1StateFirstRetailTrace.v`: exact high-Y wall rejection in a
  source-shaped list model plus transparent one-frame and downstream-lifecycle
  copies of the authenticated JP State-first observations;
- `proofs/InkFallback.v`: exact nearby Area-1 mesh arithmetic, local and PU
  three-view conditional pipeline coordinate witnesses, State-only
  preservation, the signed-range generic `385`-unit necessary gap, the exact
  proposed
  prestate's `973`-unit gap, conditional theorems for the dry audit target `45`
  and modeled `208` writer relation, the retry-null death-latch transition,
  schema-sensitivity witnesses, the modular pointer-wrap counterexample, the
  repaired first-return sink obligation, and the deliberately retained but
  invalid lifecycle interface that must be replaced;
- `proofs/Area1PhaseSplit.v`: checked triangle-fragment payload fields, exact
  binary32 three-dimensional displacement, and the ordinary captured-top epoch
  bootstrap exclusion for node `0x1E`;
- `proofs/Area1SurfaceWitness.v`: exact signed-short query, parsed top-face and
  static-face edge tests, binary32 plane height, 78-unit floor-buffer test, and
  candidate-height comparison, without claiming live list selection;
- `proofs/Area1PlatformExhaustiveness.v`: the fifteen-owner stock Area-1
  inventory, source-bounded pre-apply provenance cases, node-`0x1E` null
  platform result, and checked three-dimensional fragment capability;
- `proofs/Area1PrecollisionWriterClosure.v`: bilateral generated pre-collision
  writer receipts plus the State-only-platform classification conditional on
  terrain, platform-phase, and collision refinements;
- `proofs/Area1PolePushSchedule.v`: bilateral POLELIKE-before-PLAYER and
  State-X/Z-only pole-push receipts, plus a bounded theorem that a completed,
  correctly targeted player copy resynchronizes that push;
- `proofs/Area1PolePushLinkage.v`: exterior-palm-to-`bhvTree` static linkage,
  a documented but not interpreted attribution of the explicit grabbing poles
  to a later packed area subscript, and a bounded initializer-data exclusion
  for manually identified cylinder-push families, without a caller census or
  linked reachability claim;
- `proofs/Area1InstallerTemporalClosure.v`: finite temporal preservation of
  the upper-warp-null invariant across active, frozen, clear, and inbound
  scheduler shapes;
- `proofs/StateFirstPlatformChronology.v`: executable last-effective-pointer
  lineage and the five residual classes for any projected non-null upper-warp
  pre-apply;
- `proofs/Area1GapApproachCoverage.v`: synchronized-prefix first-divergence,
  four-way split-survival, seven-route query/current-sample, and data-bearing
  pre-collision stage classifications, plus faithful-versus-explicit-escape
  classification for a supplied accepted upper-warp collision-cache
  observation; all remain conditional on supplied trace/projection/observation
  relations and, for a sustained suffix, explicit trace-local
  split-preservation evidence;
- `proofs/Area1PostCopyTailClassification.v`: conditional classification of a
  supplied State-to-Object-copy tail into full synchronization preservation or
  a broad classified residual.  The broad residual may preserve both projected
  coordinate values.  Its stronger theorem assumes a faithful copy and a final
  State/Object value split, skips all such value-preserving edges, and extracts
  an actual State-only, Object-only, or joint value-changing edge.  No linked
  retail tail or origin label is constructed;
- `proofs/Area1PostPlayerTailSource.v`: exact bilateral post-PLAYER suffix
  `[5; 4; 2; 6; 8; 12; -1]` plus the explicit intra-PLAYER post-copy
  `spawn_particle`, debug-spawn, and possible later-node residuals; exact
  coupling and local argument forwarding of both 18-entry particle tables to
  list-8 behavior definitions; also
  action/copy and tail-order receipts, a fixed-body negative direct State/raw-
  Object XYZ writer census, and the concrete Area-1 breakable-box-to-list-12
  triangle-spawn path.  Transitive callback execution, aliases/externals,
  lifecycle/reuse, the post-final-query debug callback, and next-frame warp
  effects remain open.  The abstract supplied tail is caller-authored evidence,
  not a source-adjacency or execution-semantics theorem;
- `proofs/Area1PostCopyObjectWriterClosure.v`: complete bilateral
  direct-designated raw-Mario-Object XYZ writer partitions, post-copy reduction
  to the butterfly callback after phase exclusions, and conditional
  cached-Y=`768`/exact-centre proofs that the finite-stock final query is null;
- `proofs/Area1ButterflyStaticOriginClosure.v`: bilateral exclusion of
  `bhvButterfly` from stock SSL Area-1 macro, regular level-script, and selected
  special-preset sources, without claiming transitive live provenance;
- `proofs/Area1InteractionShortCircuitClosure.v`: exact bilateral source
  receipt for the accepted nonfading warp handler's nonzero return and
  interaction-loop break, plus a conditional schedule theorem reducing later
  selection changes to cached-floor Y;
- `proofs/Area1CachedFloorSelectionClosure.v`: finite-model proof that every
  same-sample cached floor accepted from upper-warp contact is at most Y=`896`
  and cannot yield a non-null modeled stock final query at preserved warp X/Z;
- `proofs/Area1CachedFloorSplitWitness.v`: concrete source-shaped
  `(-2048,818,-1024)` collision to `(-2048,768,-1024)` final-query witness,
  exact `(0,-50,0)` delta, bilateral generated cell-`(6,7)` membership and
  `WouldHit`/height-`768` receipt for face `(498,500,501)`, general X/Z
  preservation, greater-than-`459` upward top threshold, and conditional
  finite-stock null result.  The construction has no A-input premise but does
  not prove clean reachability or linked traversal/selection and runtime
  refinement;
- `proofs/Area1SchedulerSurfaceLifecycleSplit.v`: generated US/JP source-union
  census of recognized direct explicit transition-callback assignment/call
  syntax and direct explicit `Surface.object` field assignments, including
  exactly four installer-call occurrences and stable local surface-temporary
  insertion; schedule-coupled finite proof that every modeled accepted
  non-null stock query uses a sample distinct from collision; independence of
  that result from an arbitrary separately supplied lifecycle-fate witness;
  and an independent inactive, freed, unreused payload survivor.  Whole-struct/
  builtin mutation, aliases, externals, indirect callback targets, live owner/
  list projection, lifecycle coupling, and linked execution remain outside the
  census;
- `proofs/Area1MovingSkippedQueryClosure.v`: audited-source reduction showing
  moving area/instant-warp paths precede a full same-frame query and the two
  modeled delayed query-free frames are stationary in the checked syntax;
- `proofs/DefaultArea1Rank1ResidualCapstone.v`: default-null-seed reduction to
  completed-query lineage and expansion of a supplied sample difference into
  seven named approaches;
- `proofs/DefaultArea1Rank1BoundaryUnderdetermination.v`: constructive proof
  that the current active-preapply wrapper is too weak for a rank-1
  impossibility result because it does not derive events, samples, or owner
  identity from the active run; this is a diagnostic, not a retail witness;
- `proofs/Area1Rank1OrdinaryBridgeNoGo.v`: conditional five-field ordinary
  bridge no-go combining the concrete Y-only/downward/null split, the modeled
  schedule-coupled non-null-query-implies-distinct-sample result, and a top-
  install contradiction independent of an arbitrary separately supplied
  lifecycle-fate argument.  It does not couple that fate or construct the
  scheduler, collision, selection/runtime-memory, or surface-owner/list/query
  bridges from linked retail execution;
- `proofs/Area1SurfaceEpochLifecycle.v`: separate query-owner/apply-payload
  tokens, four exhaustive cached-payload fates, and a closed abstract
  same-slot epoch-reuse countermodel without a retail-reachability claim;
- `proofs/PlatformExternalGapSemantics.v` and
  `proofs/PlatformAliasExternalClosure.v`: defined-store endpoint reduction,
  unresolved-external writer refinement, and official alias-origin reduction;
- `proofs/StateFirstInstaller.v`: the source-bounded stock State-first
  contradiction and the explicit linked-memory projection obligation;
- `proofs/Timer131Surface.v`: exact timer-131 pose, transformed mesh, rejected
  old point, two accepted replacement points, midpoint `960`/`1010` gap bounds,
  and checked conditional JP observation records;
- `proofs/JPInstallTimerWindow.v`: timer 131 uniqueness inside the observed
  affine scheduling arithmetic, without claiming linked-run reachability;
- `proofs/JPSlotLifetime.v`: the JP allocation/free-list source boundary,
  50-record macro count, finite LIFO recurrence, and exact open first-apply
  memory obligation;
- `proofs/JPLifecycleTrace.v`: generated source-order receipts, exact finite
  free-list/depth arithmetic, and internal consistency of the injected-boundary
  JP lifecycle record; not a clean Clight execution theorem;
- `proofs/JPDestinationChronologyCertificate.v`: official cleaned JP object
  layout, cleaned `_gObjectPool` declaration shape, watched pointer offset,
  payload bounds, and conditional 131-push/84-pop non-selection certificate;
- `proofs/InstallerCoverage.v`: contradictions for five bounded abstract
  installer-attempt records and the
  explicitly conditional timer-131 Ink trace boundary;
- `proofs/StockWarpTopMotion.v`: stock upper-warp direct-writer source-shape
  receipt and separate finite binary32 pyramid-top timer `0..150` mirror;
- `proofs/Area1EntryDepthClosure.v`: ordinary-entry synchronization/depth
  consequences and complete static Area-1 door-source exclusion;
- `proofs/JPActionProvenanceCensus.v`: receiver-neutral all-unit direct-action
  assignment and long-jump-literal overlap census;
- `proofs/JPBinary32DepthWrites.v`: exact handwritten sink-visible safe-depth
  candidate relation and trace sign-preservation theorem;
- `proofs/FirstTargetRefinement.v`: indexed Clight-frame evidence, collision
  cuts, concrete bypass classes, and conditional stale-top path;
- `proofs/ModelGapAudit.v`: executable countermodels to the old abstraction
  boundary;
- `proofs/LowerEntrance.v` and `proofs/UpperEntrance.v`: open Layer B
  obligations;
- `proofs/MainTheorem.v`: proved reduction and conditional capstone; and
- `docs/notes/archived-proof-evidence.md`: detailed audit of every prior project;
  and
- `docs/notes/pyramid-top-pu.md`: source audit and exact boundary of the newest
  pyramid-top PU result;
- `docs/notes/ink-fallback.md`: the human-readable scheduling verdict, writer census,
  PU distinction, and remaining reachability/surface obligations;
- `docs/notes/pyramid-top-surface-refinement.md`: exact checked surface kernel versus
  remaining live-memory refinement;
- `docs/notes/retail-find-floor-cast.md`: authenticated US/JP function offsets,
  instruction receipt, hashes, and reproduction commands; and
- `docs/notes/area1-nonlocal-endpoints.md`: failed-cast versus finite-alias
  verdict, exact State-first sample, and clean-reachability boundary;
- `docs/notes/jp-slot-lifetime.md`: exact JP slot-lifetime facts and unresolved
  allocation trace;
- `docs/notes/timer131-surface.md`: exact raised/rotated surface calculation and
  the rejected, transient, and capture-preserving retry points; and
- `docs/notes/jp-lifecycle-trace.md`: conditional explosion/free, delayed-warp,
  first-apply, and zero-A continuation observations.

Build and run all project checks with:

```sh
source pipeline/env.sh
make clean
make check
make verify-generated
```

The check rejects `Admitted`/`admit` and audits the assumptions of the named
capstone theorems.  A successful build means the stated conditional and model
theorems type-check; it does not convert open bridge obligations into proved
facts.
