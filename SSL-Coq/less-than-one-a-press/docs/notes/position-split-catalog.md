# Where a useful position split could come from

Gameplay catalog updated 4 October 2026; source-unit census refreshed 29 October 2026 after adding the real Bob-omb animation data. The full catalog is also on the private [Fine Print site](https://pyramid-proof-fine-print.tra38.chatgpt.site/#split-catalog).

Mario has three position records. Usually, the game keeps them together. We want to know which tricks can pull them apart, and whether SSL can supply the ingredients before the next copy puts them back together. If an enemy's stock spawn path is impossible, cross off that path. A different actor using the same helper still needs its own check.

This catalog groups whole-game source mechanisms into 27 cases. It includes actual writers, ways to preserve a gap, and tempting false positives. It is not a list of 27 demonstrated Ink routes or a completed classification of every live memory write.

## What counts as useful?

**State** is MarioState.pos, **collision** is MarioObject's raw oPosX/Y/Z, and **display** is the stored header.gfx.pos vector. A rendered animation or camera offset is not necessarily a change to that display vector. The target is immediately after the upper nonfading SSL warp returns success, still in Area 1 and before act_disappeared. State = display with different collision coordinates qualifies; all three need not differ. Useful final Area-1 top capture is reported separately.

Ordinary controller gameplay and defined, in-bounds execution remain the scope. The negative-depth and valid-reward grants are diagnostic assumptions, not a grant of the useful split, failed first query, contact or timer. Arbitrary state injection, memory corruption and debug-action injection are not routes in this catalog.

## The result so far

Chuckya and King Bob-omb's shared anchor, Dorrie's lift, the LLL/BitFS tilting pyramids, Hoot, Heave-Ho, the named bullies, Bowser's shockwave, whirlpools and butterflies have no stock Area-1 selector in the checked paths. The new source checks supplement the existing Chuckya/King Bob-omb and butterfly proofs. These are selector exclusions, not an assumed all-gameplay object-lifetime invariant.

SSL still has ordinary geometry correction and floor retry, platform movement, floor alignment, palm-tree pushes, interactions, a cannon, Tweesters, a shell, quicksand, dialogs and an oasis. A particularly concrete case is normal cannon firing: it moves State and returns before the display copy, but that branch requires an A press. Ordinary confinement refreshes display. Swimming offsets also cannot be excluded just by calling SSL a desert.

The accepted-warp action tail preserves any gap it receives. The successful supplied JP Ink fixture remains conditional; the clean replay has all three records equal. No new clean installation or all-history impossibility has been established. Atlas route estimates are unchanged; no probability is assigned to these source rows.

Seven proved stock-list exclusions now appear in **01 · Already proved** below and on the site. The other 20 entries remain separate. This is a clearer presentation of existing proofs, not seven new route closures. The summaries start with what happens to Mario; the exact scope and proof references remain attached.

## Working backward: how much gap can each case create?

The supplied vertical setup needs actual and collision Y=768 with display Y=1938.8648681640625: an upward gap of **1170.8648681640625** before the first floor query. This is one successful supplied setup, not a universal minimum for every possible Ink installation. After the retry, movement can equal display while collision remains low. A platform changing only movement does not create that display-versus-collision difference by itself.

These 20 reviewed cases are not 20 unresolved gap producers. A zero at a named copy is not a theorem about every surrounding update. Formula-dependent rows still need real incoming values; an unknown maximum is not an unlimited reachable gap. We defer travel to the warp until a producer passes this first test. See the [backward review](ink-gap-backward.md) and [finite arithmetic receipt](ink-gap-arithmetic.json).

**Stopping rule.** A proved upper bound below **1170.8648681640625** counts as **Insufficient — already proved**, under its stated conditions and checkpoint. The normal Tweester and completed ground copies qualify with zero gap. The shell, water, ledge and cannon shortfalls keep their source/finite evidence labels; unknown bounds remain open. A keeper or consumer of an existing gap is not ruled out in that supporting role. This threshold is specific to the supplied setup, not every Ink installation.

The [four concrete producer review](ink-concrete-producers.md) adds actual US/JP execution connections for the accepted floor snap, reached nonrotating platform tail, bounded live bounce snap and real sink magnitude. The families remain open beyond those cuts. The supplied Variant uses a different 1093-unit movement/collision split; zero display/movement gap alone does not exclude it.

The review separates six scoped insufficient cases, five helpers, four concrete unresolved producers, four other-context/lookalike cases, and one ownership question. There is no pole beside the Area-1 upper warp. Its distant palm tree uses pole actions; the two regular SSL poles belong to Area 2. The checked Area-1 static mesh and pyramid top have no hangable triangles; Area 2 has six. These are pinned stock-data checks, not new Coq or all-history exclusions.

| Case | Role in this review | Gap at the stated checkpoint | Verdict |
| --- | --- | --- | --- |
| [01 — ordinary-step](#split-ordinary-step) | Insufficient at the stated checkpoint | 0 movement/display gap at completed ground copy and air-step return; collision stays separate | 01 · Already proved — insufficient: Completed ground-copy checkpoint only; other exits and later writers are separate.<br>Insufficient — already proved at the completed ground copy |
| [02 — geometry-retry](#split-geometry-retry) | Helper, not a height source | 0 between display and movement after retry | Helper only — not a gap source: Consumes an existing gap; it does not supply the raised display.<br>Consumes a gap; does not create the raised display |
| [03 — floor-animation](#split-floor-animation) | Concrete producer still open | 0 at accepted refresh/snap; stopped crawl: pre-snap movement minus remembered height; reachable maximum unknown | 01 · Already proved — insufficient: Accepted quarter, completed ordinary refresh and immediately following alignment snap give zero display-minus-movement gap at that checkpoint. This excludes that raised-display snap subcase only; older collision disagreement and early stopped quarters remain open.<br>Still live — producer unproved: The stopped-crawl snap is now connected to its real refresh/return and speed guard. A useful lower remembered floor needs an earlier writer, then the gap must survive the remaining calls.<br>Accepted refresh/snap is insufficient for the raised-display gap; early stops remain live |
| [04 — platform](#split-platform) | Concrete producer still open | 0 new vertical change in the linked nonrotating tail; rotating displacement still needs a live bound | 01 · Already proved — insufficient: At the reached zero-rotation guard, with local Y linked to entry State Y, the completed real tail leaves State Y unchanged. Display/collision need not agree. Full entry and rotating support remain open.<br>Still live — producer unproved: Separate rotation displacement from floor following. Vertical platform velocity is not directly added; the proved nonrotating tail supplies no new vertical change.<br>Vertical platform velocity alone is insufficient in this helper |
| [09 — push](#split-push) | Helper, not a height source | 0 new vertical gap from the direct push writes | Helper only — not a gap source: Sideways movement can help reach a query; it does not supply the height gap.<br>A sideways helper, not the height source |
| [10 — bounce](#split-bounce) | Concrete producer still open | Fresh upward snap ≤251 under stated live-size/read conditions; completed air display gap 0; zero-particle callback return collision gap 0 | 01 · Already proved — insufficient: From matched actual falling-contact reads and synchronized incoming display, finite movement in [-32768,32768], actor Y≥-32768 and live height in [-32768,250], the actual first bounce store creates at most 251 upward movement/display units. No low-actor/no-clone condition. Live dimensions and earlier contact are not derived; the sound/action tail is retained.<br>Still live — producer unproved: The fresh bounded snap, matched contact, air refresh and mandatory collision copy are scoped proofs. A zero-particle completed callback returns with movement/collision Y equal. Negative Fly Guy scale is real but signed contact constrains it; chosen placement is no size grant. Inherited splits and later writers remain open.<br>01 · Already proved — insufficient: Completed actual Mario callback reaches the real collision copy. With a reached zero particle mask and ordinary pool/receiver/read conditions, its complete tail preserves memory and movement/collision equality through callback return. This is not a frame of later callbacks or the next update.<br>Only finite-tested — not broadly proved: 16 supplied synchronized Mario poses, 12 detected bounces and 384 end-update Y checks; all three heights agree. No subframe collision peak or reachable pose/route is inferred.<br>Fresh bounded snap insufficient alone; mandatory collision copy erases the split in its same callback |
| [12 — attachments](#split-attachments) | Insufficient at the stated checkpoint | Pole/hang copies: 0. Ledge release: a 100-unit subtraction or a shallower floor snap | Geometrically unavailable — scoped: No pole beside the Area-1 warp and no checked hangable Area-1/top triangles: stock-data check, not a whole-history theorem.<br>Source review only — not broadly proved: The remote tree and ordinary ledges remain separate; their full transfer/exit histories are not excluded.<br>Insufficient at the local drop — source review |
| [13 — cannon](#split-cannon) | Insufficient at the stated checkpoint | 0 while seated; firing leaves display at or below movement | Unavailable under route constraints — scoped: Normal cannon firing requires an A press; this excludes that launch in the no-new-A route, not the stock cannon itself.<br>Only finite-tested — not broadly proved: The normal-launch sizing calculation is finite, not a proof of every cannon-related history.<br>Insufficient at normal launch — source and finite checks |
| [14 — tornado](#split-tornado) | Insufficient at the stated checkpoint | 0 at the completed non-ejecting display-copy checkpoint | 01 · Already proved — insufficient: Normal non-ejecting copy checkpoint only; transport, ejection and later writers are separate.<br>Insufficient — already proved at the normal Tweester copy |
| [15 — water](#split-water) | Insufficient at the stated checkpoint | About +208 in the generous one-refresh calculation at Y=768 | Only finite-tested — not broadly proved: The checked expression envelope is insufficient. The oasis exists; all water histories are not excluded.<br>Insufficient in the checked expression envelope |
| [17 — shell](#split-shell) | Insufficient at the stated checkpoint | +42 airborne; +45 on the ground, per ordinary refresh | Only finite-tested — not broadly proved: Source review and supplied-helper branch tests find no stacking; later non-shell writers remain separate.<br>Insufficient alone — source arithmetic |
| [18 — quicksand](#split-quicksand) | Concrete producer still open | Minus depth per real sink; retained -4 can exceed 1170 units after 293 calls | 01 · Already proved — insufficient: Under the accepted classified stock depth-write/action/physical-input contract and no A press, a finite completed real sink cannot raise display. Granting a negative seed for a transfer test deliberately leaves that contract case; unrestricted gameplay coverage is not claimed.<br>Still live — producer unproved: The granted negative can make a large enough display rise arithmetically. Supported update retention and the low-pose transfer still need their actual history; the accepted no-A seed contract is a separate scoped exclusion.<br>Size can be sufficient conditionally; useful gameplay retention is unproved |
| [19 — dialog](#split-dialog) | Helper, not a height source | No independent fixed upward offset; preserves what enters | Helper only — not a gap source: Can preserve a gap; does not create the original height separation.<br>A possible keeper, not the original height source |
| [20 — warp-reset](#split-warp-reset) | No local stock producer identified | Instant warp: incoming gap − vertical warp displacement | Geometrically unavailable — scoped: No Area-1 instant-warp command in the stock data.<br>Source review only — not broadly proved: Other relocation contexts are not proved universally unreachable; the accepted SSL warp tail has its separate proof.<br>Relocation can make a gap elsewhere; no matching Area-1 table |
| [22 — cutscene](#split-cutscene) | No local stock producer identified | Depends on the selected ending/door/action sequence | Coverage unresolved — not a demonstrated lead: No legitimate SSL entry into the cited ending motion is established. Missing reachability is not proof of unavailability.<br>No legitimate SSL producer established |
| [23 — debug](#split-debug) | No local stock producer identified | 0 at its display copy; arbitrary entry is outside this challenge | Unavailable under route constraints — scoped: Injected debug actions are excluded by the ordinary controller-driven stock-gameplay model.<br>No authorized stock-gameplay producer |
| [24 — render](#split-render) | No local stock producer identified | 0 from writes only to camera, proxy, matrix or local vectors | Not a stored-position gap source — scoped: Camera motion and a separate mirror object do not themselves write live Mario’s stored display; an actual writer would need separate evidence.<br>No gap unless the actual stored display vector changes |
| [25 — generic-objects](#split-generic-objects) | Which object is being written? | No common numeric bound; depends on the actual receiver | Coverage unresolved — not a demonstrated lead: Known distinct-child copies do not move Mario; remaining receiver/callback coverage is not a demonstrated height trick.<br>Known distinct-child copies add 0 to Mario; wider coverage remains open |
| [26 — copies-pauses](#split-copies-pauses) | Helper, not a height source | No new display-minus-movement gap; collision copy transfers an existing one | Helper only — not a gap source: Transfers or preserves an existing split; skipping alone supplies no movement.<br>Can complete the low collision record only after a producer exists |
| [27 — query-alias](#split-query-alias) | Helper, not a height source | 0 new position gap | Helper only — not a gap source: Changes a query input or answer; a resulting position write belongs to another case.<br>Changes what a query sees, not where the records are |

## All 27 cases at a glance

| # | Situation | SSL / current verdict |
| --- | --- | --- |
| 01 | [Walking, falling and the ordinary position copies](#split-ordinary-step) | Insufficient at completed ground/air copies · other checkpoints open |
| 02 | [The floor check borrows Mario's display position](#split-geometry-retry) | Helper · needs an earlier height gap |
| 03 | [The floor moves Mario, but does the display follow?](#split-floor-animation) | Accepted snap insufficient · stopped-crawl snap connected |
| 04 | [Ride a platform while the other positions stay put](#split-platform) | Nonrotating tail proved · rotations open |
| 05 | [Chuckya and King Bob-omb: the stock lists cannot choose them](#split-chuckya-anchor) | Ruled out · stock lists |
| 06 | [Dorrie: no neck lift from the stock SSL lists](#split-dorrie) | Ruled out · stock lists |
| 07 | [Those other pyramids are not SSL's pyramid top](#split-tilting-platform) | Ruled out · stock lists |
| 08 | [Hoot: the stock SSL lists cannot supply the ride](#split-hoot) | Ruled out · stock lists |
| 09 | [The palm tree can push one position](#split-push) | Helper · needs an earlier height gap |
| 10 | [Bounces and knockback are different kinds of help](#split-bounce) | Fresh-gap, air refresh and callback collision copy proved · later history open |
| 11 | [Heave-Ho, bullies and Bowser's shockwave are off these lists](#split-absent-launch) | Ruled out · stock lists |
| 12 | [Trees, ledges and hanging points](#split-attachments) | Insufficient alone · source review |
| 13 | [The cannon really can leave the display behind](#split-cannon) | Needs A to fire · other exits open |
| 14 | [A Tweester can move Mario, but it also updates the display](#split-tornado) | Insufficient at normal copy · other checkpoints open |
| 15 | [Yes, the desert has swimming offsets](#split-water) | Insufficient in the checked expression |
| 16 | [The oasis does not come with a whirlpool](#split-whirlpool) | Ruled out · stock lists |
| 17 | [The shell gives Mario a display offset](#split-shell) | Insufficient alone · source review + finite check |
| 18 | [Negative depth plus a dialog that keeps the display](#split-quicksand) | Magnitude proved · transfer history open |
| 19 | [A dialog can keep a gap; it cannot create one by pausing](#split-dialog) | Helper · needs an earlier height gap |
| 20 | [Bringing a gap through a warp or level entry](#split-warp-reset) | Mixed · the actual transition matters |
| 21 | [Butterflies: this stock list cannot supply the unusual writer](#split-butterfly) | Ruled out · stock lists |
| 22 | [Ending cutscenes can place Mario almost wherever they need him](#split-cutscene) | Different context · not a stock SSL entry |
| 23 | [Debug free movement is outside this gameplay challenge](#split-debug) | Outside the chosen rules |
| 24 | [Looking displaced is not always a change to the stored display](#split-render) | Different record · check the target |
| 25 | [A helper moves its object. Which object is that?](#split-generic-objects) | Ownership coverage · not a sized producer |
| 26 | [A skipped update needs something worth preserving](#split-copies-pauses) | Helper · needs an earlier height gap |
| 27 | [A different floor answer is not itself a position write](#split-query-alias) | Helper · needs an earlier height gap |

## 01 · Already proved: these stock spawn choices are ruled out

These lists cannot select the named actors. That is the completed claim. Unexpected later object creation remains a separate question; it is not silently declared impossible here.

<a id="split-chuckya-anchor"></a>

### 05 — Chuckya and King Bob-omb: the stock lists cannot choose them

**Ruled out.** The checked stock Area-1 lists cannot select Chuckya or King Bob-omb.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`anchor_parent_static_area1_exclusion_checked`](../../proofs/InkTimer131ProducerClosure.v).

**What happens to Mario.** While Mario is held, the shared anchor can place his stored display at the anchor's raw position, including its graphical Y offset. When he is thrown, the grabbed action can copy that display position back into movement.

**What we would need.** A Chuckya or King Bob-omb parent has to create and run the anchor.

**Can SSL supply it.** The checked Area-1 regular, macro and special spawn lists choose neither parent. Loading a model does not put that enemy in the level.

**Does the gap last long enough.** This really changes the stored display. It is more than a funny animation or a launch-speed change.

**What we know.** Coq checks both parents, their shared anchor chain and their absence from the stock lists in US and JP. The generated C bodies also have no direct parent reference.

**What this does not rule out.** This stock-list explanation is finished. A different proposal would have to show how legal gameplay creates the missing actor; that broader creation history is still open.

Stock source: [common_anchor_mario_behavior](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/chuckya.inc.c#L17); [obj_set_gfx_pos_at_obj_pos](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L1881); [act_grabbed](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L656).

Related atlas ranks: 21, 2.

<a id="split-dorrie"></a>

### 06 — Dorrie: no neck lift from the stock SSL lists

**Ruled out.** The checked stock SSL lists cannot select Dorrie.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`psc_absent_actor_selectors_checked`](../../proofs/PositionSplitCatalog.v).

**What happens to Mario.** Dorrie's neck lift sets Mario's movement position using his collision position and the movement of Dorrie's head.

**What we would need.** A live Dorrie running the head-lift behavior.

**Can SSL supply it.** The stock SSL lists checked here cannot choose Dorrie.

**Does the gap last long enough.** This is a special movement helper, separate from the ordinary platform ride.

**What we know.** Both versions have a checked Dorrie exclusion. His head lift is also one of exactly three direct callers of the movement-position setter in the generated code.

**What this does not rule out.** The stock-list case is done. Bringing a Dorrie or a useful gap from elsewhere would require a real creation or transition sequence; we have not granted one.

Stock source: [dorrie_raise_head](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/dorrie.inc.c#L3).

Related atlas ranks: 5, 5A.

<a id="split-tilting-platform"></a>

### 07 — Those other pyramids are not SSL's pyramid top

**Ruled out.** The checked stock SSL lists cannot select either LLL or BitFS tilting-pyramid behavior.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`psc_absent_actor_selectors_checked`](../../proofs/PositionSplitCatalog.v).

**What happens to Mario.** The tilting platforms in LLL and BitFS use a special rider correction that sets Mario's movement position.

**What we would need.** One of those two tilting-platform behaviors.

**Can SSL supply it.** Neither behavior is selected by the checked stock SSL lists. SSL's exploding pyramid top is a different object with different code.

**Does the gap last long enough.** Two objects looking like pyramids does not give them the same movement helper.

**What we know.** Coq excludes both stock selections in US and JP. Their shared callback is another of the three direct movement-setter callers.

**What this does not rule out.** The stock-list proposal is ruled out. A different legal way of creating or importing the behavior would need its own demonstration.

Stock source: [bhv_tilting_inverted_pyramid_loop](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/tilting_inverted_pyramid.inc.c#L65).

Related atlas ranks: 5, 5A.

<a id="split-hoot"></a>

### 08 — Hoot: the stock SSL lists cannot supply the ride

**Ruled out.** The checked stock SSL lists cannot select Hoot.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`psc_absent_actor_selectors_checked`](../../proofs/PositionSplitCatalog.v).

**What happens to Mario.** While Mario rides Hoot, the action places his movement position below Hoot and then copies it into display.

**What we would need.** Hoot must exist, Mario must grab him, and the riding action must still be active.

**Can SSL supply it.** The checked stock SSL lists never choose Hoot.

**Does the gap last long enough.** Even with an owl, an intermediate mismatch is only useful if it survives the action's own display copy.

**What we know.** The US/JP stock-list exclusion is proved. The riding code shows where the position change and copy occur.

**What this does not rule out.** The normal stock-spawn explanation is finished. A claim about every possible action history would also need to show that the riding action cannot begin without its proper actor.

Stock source: [act_riding_hoot](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_airborne.c#L1850); [interact_hoot](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1560).

Related atlas ranks: 5, 21.

<a id="split-absent-launch"></a>

### 11 — Heave-Ho, bullies and Bowser's shockwave are off these lists

**Ruled out.** The checked stock SSL lists cannot select Heave-Ho, the five named bully variants or BowserShockWave.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`psc_absent_actor_selectors_checked`](../../proofs/PositionSplitCatalog.v).

**What happens to Mario.** These actors do different jobs. Heave-Ho supplies launch speed and status, not Chuckya's display anchor. Bullies can adjust movement height. Shockwave bouncing moves Mario and then updates display.

**What we would need.** The matching actor and a legitimate interaction or action.

**Can SSL supply it.** The checked stock lists do not select Heave-Ho, the five named bully variants or BowserShockWave.

**Does the gap last long enough.** A speed change is not an immediate position change. We cannot replace all seven behaviors with a generic 'enemy moves Mario' assumption.

**What we know.** The absence of all seven named behavior choices is proved in both generated versions.

**What this does not rule out.** Their stock-list paths are ruled out. A broader exclusion still needs proper actor creation and action history; these checks do not let us invent either.

Stock source: [bhv_heave_ho_throw_mario_loop](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/heave_ho.inc.c#L8); [bully_knock_back_mario](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L450); [act_shockwave_bounce](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_stationary.c#L790).

Related atlas ranks: 5, 13B, 21.

<a id="split-whirlpool"></a>

### 16 — The oasis does not come with a whirlpool

**Ruled out.** The checked stock SSL lists cannot select the whirlpool behavior.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`psc_absent_actor_selectors_checked`](../../proofs/PositionSplitCatalog.v).

**What happens to Mario.** The whirlpool action changes Mario's movement position and updates display.

**What we would need.** A whirlpool object and its matching interaction and action.

**Can SSL supply it.** The checked stock SSL lists do not select a whirlpool. Having water does not supply one.

**Does the gap last long enough.** Ordinary swimming and whirlpool capture are different mechanisms.

**What we know.** The US/JP stock-list exclusion is proved. We keep the separate swimming case open where it belongs.

**What this does not rule out.** The stock-whirlpool explanation is done. A claim about every action history would also have to rule out an illegitimate way into the whirlpool action.

Stock source: [act_caught_in_whirlpool](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_submerged.c#L1040); [interact_whirlpool](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1113).

Related atlas ranks: 5, 21.

<a id="split-butterfly"></a>

### 21 — Butterflies: this stock list cannot supply the unusual writer

**Ruled out.** The checked stock Area-1 lists cannot select butterflies.

**Scope.** Both US and JP; regular script choices and the checked Area-1 macro and special-object lists. This excludes these stock selections, not every possible later object-creation history.

Proof: [`butterfly_area1_selector_exclusion_checked`](../../proofs/Area1ButterflyStaticOriginClosure.v).

**What happens to Mario.** A butterfly briefly adds to Mario's raw collision coordinates to calculate its aim, then subtracts afterward. Those coordinates are being used as temporary working space.

**What we would need.** A live butterfly running that helper.

**Can SSL supply it.** The checked US/JP Area-1 stock lists do not select butterflies.

**Does the gap last long enough.** Adding and subtracting floating-point numbers is not automatically an exact undo. We also do not get to invent a collision check between those operations.

**What we know.** The unusual raw-position writer and the stock-list exclusion are already checked.

**What this does not rule out.** The normal stock-list explanation is finished. A wider claim still needs to establish which callbacks and object records can actually be used during gameplay.

Stock source: [butterfly_calculate_angle](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/butterfly.inc.c#L45).

Related atlas ranks: 13.

### Already proved: insufficient for this supplied gap

**[Walking, falling and the ordinary position copies](#split-ordinary-step) — Insufficient.** At the completed actual US/JP ground-step display copy, with the reached Mario pointer, readable movement Y, a valid Object-pool slot and separate MarioState storage, display Y equals movement Y. The whole ground-call theorem supplies this copy checkpoint. This does not cover an earlier retry, every action, or later offset and position writes.

Proof: [`ipg_ground_refresh_completes_without_old_display`](../../proofs/InkPostDialogGroundReset.v).

**[The floor moves Mario, but does the display follow?](#split-floor-animation) — Insufficient.** Accepted quarter, completed ordinary refresh and immediately following alignment snap give zero display-minus-movement gap at that checkpoint. This excludes that raised-display snap subcase only; older collision disagreement and early stopped quarters remain open.

Proof: [`ifp_accepted_refresh_then_alignment_has_zero_display_gap`](../../proofs/InkFloorProducerEffect.v).

**[Ride a platform while the other positions stay put](#split-platform) — Insufficient.** At the reached zero-rotation guard, with local Y linked to entry State Y, the completed real tail leaves State Y unchanged. Display/collision need not agree. Full entry and rotating support remain open.

Proof: [`iph_nonrotating_tail_has_no_new_vertical_change`](../../proofs/InkPlatformProducerHeight.v).

**[Bounces and knockback are different kinds of help](#split-bounce) — Insufficient.** From matched actual falling-contact reads and synchronized incoming display, finite movement in [-32768,32768], actor Y≥-32768 and live height in [-32768,250], the actual first bounce store creates at most 251 upward movement/display units. No low-actor/no-clone condition. Live dimensions and earlier contact are not derived; the sound/action tail is retained.

Proof: [`ibag_completed_bounce_creates_at_most_251_display_gap`](../../proofs/InkBounceApproachGap.v).

**[A Tweester can move Mario, but it also updates the display](#split-tornado) — Insufficient.** At the completed actual US/JP non-ejecting display copy, under its stated storage conditions, the supplied low-movement/high-display pair is impossible. Both floor-query outcomes are covered. Ejection, the following angle call and other later writers remain outside this result.

Proof: [`twg_copy_cannot_install_supplied_vertical_gap`](../../proofs/TweesterGap.v).

**[Negative depth plus a dialog that keeps the display](#split-quicksand) — Insufficient.** Under the accepted classified stock depth-write/action/physical-input contract and no A press, a finite completed real sink cannot raise display. Granting a negative seed for a transfer test deliberately leaves that contract case; unrestricted gameplay coverage is not claimed.

Proof: [`iqps_classified_no_a_sink_cannot_create_upward_gap`](../../proofs/InkQuicksandProducerSize.v).


## 02 · Remaining cases and other contexts

These entries include open gameplay questions and things that only look like useful producers. Being listed here does not mean a route works.

<a id="split-ordinary-step"></a>

### 01 — Walking, falling and the ordinary position copies

**Role in this review.** Completed ground and air refreshes supply zero movement/display gap, already proved at their named cuts. Collision synchronization and other exits remain separate.

**Gap sizing: 0 movement/display gap at completed ground copy and air-step return; collision stays separate.** Insufficient — already proved at the completed ground copy

The completed actual air call cannot carry an old movement/display height gap through its display copy and return. This works for higher/cloned actors and arbitrary motion in the real prefix, under readable separate MarioState/Object-pool storage conditions. Later shell, water and sand adjustments have their own rows.

**Limits.** This is not a bound on every intermediate displacement or a proof that every action takes one of these completed copies.

**Evidence level.** InkPostDialogGroundReset.v ground copy; InkAirCallBackward.v + InkAirReturnFrame.v actual completed air call

**Already proved — Insufficient.** At the completed actual US/JP ground-step display copy, with the reached Mario pointer, readable movement Y, a valid Object-pool slot and separate MarioState storage, display Y equals movement Y. The whole ground-call theorem supplies this copy checkpoint. This does not cover an earlier retry, every action, or later offset and position writes.

Proof: [`ipg_ground_refresh_completes_without_old_display`](../../proofs/InkPostDialogGroundReset.v).

**What happens to Mario.** Mario takes a step, so his movement position changes. The action usually updates his display next, and Mario's object update later copies the movement position into the collision record. In between, the numbers can disagree.

**What we would need.** This is the everyday machinery behind walking, sliding, falling and airborne actions.

**Can SSL supply it.** Yes. SSL uses it too. Whether Mario can enter a particular airborne action without a new A press is a separate problem.

**Does the gap last long enough.** The warp gets checked before the ordinary action loop. A step taken later in that update is too late to explain a gap that was already there when the warp accepted Mario.

**What we know.** Completed actual US/JP ground and air calls reach their real display refreshes. The air refresh, angle setter, return and local free leave display Y equal to movement Y while preserving collision at the copy cut. The actual quarter/terrain/gravity/wind prefix is retained, including floor-miss outcomes.

**What is left to check.** Connect later action calls and the later raw collision copy to the next useful check; this does not assert that every action takes one of these completed calls.

Stock source: [perform_air_quarter_step](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L388); [perform_ground_step](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L322); [perform_air_step](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L610); [perform_water_step](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_submerged.c#L167); [act_ground_pound](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_airborne.c#L918); [stationary_ground_step](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L236); [stop_and_set_height_to_floor](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L223).

Related atlas ranks: 2, 5, 13B, 18.

<a id="split-geometry-retry"></a>

### 02 — The floor check borrows Mario's display position

**Role in this review.** This is the consumer that makes the supplied Ink setup useful. It needs the earlier raised display; it does not manufacture it.

**Gap sizing: 0 between display and movement after retry.** Consumes a gap; does not create the raised display

The retry can turn low movement into high movement by copying the display. It can leave the collision record low, which is exactly why the supplied setup works. Wall correction is a separate X/Z change, not a new upward display offset.

**Limits.** The useful display-versus-collision gap and first missing floor must already be available. Live correction and floor choice still matter.

**Evidence level.** Existing retry proof + source review

**What happens to Mario.** First, wall correction can move Mario's movement position. Then the game looks for a floor. If it finds nothing, it copies the stored display position into movement and tries again. The collision record can still be back where it started.

**What we would need.** No special enemy is needed. This is part of Mario's normal preparation before interactions.

**Can SSL supply it.** Yes. This is what makes the supplied SSL Ink setup work. We still need gameplay to supply the low collision position and high display together.

**Does the gap last long enough.** The retry happens before the warp interaction. So movement and display can agree up high while the collision record still touches the warp down below.

**What we know.** The real copy and second-query connection are proved. We also have a successful supplied JP setup and a checked floor-list certificate. The supplied starting gap is doing real work in that demonstration.

**What is left to check.** Create the first floor miss, useful display height, low warp contact and correctly timed top in one legal continuation.

Stock source: [update_mario_geometry_inputs](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1314); [resolve_and_return_wall_collisions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L521); [find_floor](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_collision.c#L513).

Related atlas ranks: 1, 2, 3, 13A.

<a id="split-floor-animation"></a>

### 03 — The floor moves Mario, but does the display follow?

**Role in this review.** The stopped-crawl snap is now connected to its real refresh/return and speed guard. A useful lower remembered floor needs an earlier writer, then the gap must survive the remaining calls.

**Gap sizing: 0 at accepted refresh/snap; stopped crawl: pre-snap movement minus remembered height; reachable maximum unknown.** Accepted refresh/snap is insufficient for the raised-display gap; early stops remain live

A conditional stopped snap from 1938.864868 to remembered 1280 leaves 658.864868 units; remembered 768 would give 1170.864868. These are arithmetic candidates, not selected live caches or detected gameplay. The accepted quarter still gives zero gap. The stopped query itself cannot put its lower answer into the cache.

**Limits.** The new caller result reaches the first real snap; it does not establish the earlier cache, whole matrix/action effects or next-update consumption. This is not a Variant exclusion: movement/display can agree above old collision. No reachable stopped-crawl maximum has been measured or proved.

**Evidence level.** Actual generated US/JP execution composition

**Already proved — Insufficient.** Accepted quarter, completed ordinary refresh and immediately following alignment snap give zero display-minus-movement gap at that checkpoint. This excludes that raised-display snap subcase only; older collision disagreement and early stopped quarters remain open.

Proof: [`ifp_accepted_refresh_then_alignment_has_zero_display_gap`](../../proofs/InkFloorProducerEffect.v).

**What happens to Mario.** Floor alignment can set Mario's movement height to the remembered floor height without itself replacing his stored display. Animation movement can also change his movement coordinates.

**What we would need.** Idle plus Z can enter crouching, then Z plus stick can enter crawling; walking plus a Z press can enter crouch slide without A. These source-local constructors give access to alignment, not to its exceptional floor setup. Animation movement is separate.

**Can SSL supply it.** Yes. These ordinary actions exist here. What we do not have is a reached stopped quarter and remembered floor that make the large, surviving mismatch needed for Ink.

**Does the gap last long enough.** Most of this happens during the action. We must keep reading past the interesting assignment: a later copy might immediately remove the advantage.

**What we know.** The accepted-quarter refresh/snap has zero display gap. The new stopped-crawl connection follows the real ground refresh, angle setter, return/free and speed guard to the first alignment store: display is pre-snap movement and movement becomes remembered height. The real stopped query preserves that cache; its lower local answer does not replace it. The final matrix-pointer store preserves positions, but the preceding matrix calls are not yet framed.

**What is left to check.** Derive the earlier origin of a large movement/remembered-height mismatch and the actual stopping exit through wall/ceiling/water calls. Then compose the complete matrix/action tail, collision copy and next useful contact. The stopped-crawl gap formula has no proved reachable maximum and no detected useful creator. Slide's extra caller helpers and animation remain separate.

Stock source: [align_with_floor](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L88); [update_mario_pos_for_anim](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L207).

Related atlas ranks: 2, 5, 13B.

<a id="split-platform"></a>

### 04 — Ride a platform while the other positions stay put

**Role in this review.** Separate rotation displacement from floor following. Vertical platform velocity is not directly added; the proved nonrotating tail supplies no new vertical change.

**Gap sizing: 0 new vertical change in the linked nonrotating tail; rotating displacement still needs a live bound.** Vertical platform velocity alone is insufficient in this helper

There is no y += platform velocity Y assignment. The real X/Z translations preserve local Y, and with zero rotation the reached tail sends that same Y to the actual setter. Existing collision/display differences are preserved by the complete platform-phase theorem.

**Limits.** The new cuts explicitly supply post-getter local bindings and link local Y to State Y at the guard. They do not establish a full entry theorem or bound the matrix branches. Floor following is a separate height writer, and no universal ride-gap bound is claimed.

**Evidence level.** Actual generated US/JP nonrotating cuts and complete real setter

**Already proved — Insufficient.** At the reached zero-rotation guard, with local Y linked to entry State Y, the completed real tail leaves State Y unchanged. Display/collision need not agree. Full entry and rotating support remain open.

Proof: [`iph_nonrotating_tail_has_no_new_vertical_change`](../../proofs/InkPlatformProducerHeight.v).

**What happens to Mario.** The complete platform phase preserves display and collision. The displacement helper adds horizontal platform velocity; it does not directly add vertical velocity. A rotation calculation can change Mario movement Y.

**What we would need.** The final raw-position query must find an owned floor within four units; a live retained platform and enabled apply phase are required. Merely being near a moving object is not enough.

**Can SSL supply it.** SSL has three Tox Boxes and the pyramid top. Tox Box visible rolling changes face angles, not the rotation-speed fields this helper reads; the top writes yaw rotation speed. A useful pitch/roll field writer and reachable rider setup are not established.

**Does the gap last long enough.** This happens before Mario's next update. The support check can erase the remembered platform, and moving Mario here does not move the collision record used for warp contact.

**What we know.** The existing complete US/JP platform phase protects display/collision. The new proof follows real horizontal translations, the zero-rotation test and a reached nonrotating tail through the complete actual set_mario_pos call. Local Y is passed unchanged.

**What is left to check.** Connect local Y after get_mario_pos to complete function entry, then quantify yaw/pitch/roll branches and derive their actual live fields and retained support. Visual rolling alone supplies no pitch/roll displacement. A later collision copy and retained display are distinct checks.

Stock source: [set_mario_pos](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L81); [apply_platform_displacement](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L91); [apply_mario_platform_displacement](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L171); [update_mario_platform](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L22).

Related atlas ranks: 1, 2, 5A, 6.

<a id="split-push"></a>

### 09 — The palm tree can push one position

**Role in this review.** The direct writes are sideways. They may help lose a floor, but an independent height producer must already exist.

**Gap sizing: 0 new vertical gap from the direct push writes.** A sideways helper, not the height source

These helpers write X/Z. They could matter by changing the next floor query while a raised display already exists. The tree push scales its raw horizontal offset by (radius − distance) / radius; the interaction push aims at the combined hitbox radius and padding.

**Limits.** Do not assign a reachable horizontal maximum without the real actor sizes and input positions. Calls through the wall/floor helpers need their own connection.

**Evidence level.** Source review

**What happens to Mario.** The push helpers can change Mario's movement X/Z without directly changing his collision or display coordinates.

**What we would need.** A tree/pole callback or an object interaction that actually reaches the push helper.

**Can SSL supply it.** Yes. The palm tree at (-5989,0,-4850) is there in the stock level. Other solid objects and enemies also use push logic.

**Does the gap last long enough.** The tree's callback runs after collision detection and before Mario's update. Interaction pushes have to fit their own place in the handler order.

**What we know.** We have a source proof of this position-writing path. So 'none of the object callbacks can move Mario' would be false. The new stock-list check also correctly finds the tree.

**What is left to check.** Follow a real push through wall correction, the floor query and the next copies. The tree being far from the warp does not by itself prove that every possible sequence fails.

Stock source: [cur_obj_push_mario_away](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L2200); [push_mario_out_of_object](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L616).

Related atlas ranks: 5, 13A, 13B.

<a id="split-bounce"></a>

### 10 — Bounces and knockback are different kinds of help

**Role in this review.** The fresh bounded snap, matched contact, air refresh and mandatory collision copy are scoped proofs. A zero-particle completed callback returns with movement/collision Y equal. Negative Fly Guy scale is real but signed contact constrains it; chosen placement is no size grant. Inherited splits and later writers remain open.

**Gap sizing: Fresh upward snap ≤251 under stated live-size/read conditions; completed air display gap 0; zero-particle callback return collision gap 0.** Fresh bounded snap insufficient alone; mandatory collision copy erases the split in its same callback

Higher placement still requires Mario above the enemy origin. A negative height does not provide a positive hitbox: matching registered contact blocks a snap below raw collision, even without a height ceiling. The mandatory real copy makes movement/collision Y equal, and the zero-mask particle tail preserves equality through callback return. It offers no intervening warp check before that copy.

**Limits.** The 251 bound is a signed local bound at the first snap, not an absolute inherited-gap or flight-peak bound. The zero-particle return theorem retains reached ownership/symbol/read conditions; nonzero particles and later callbacks/pre-action writers remain outside it. 16 supplied poses and 384 end-update checkpoints give detected gap 0; subframe collision peak was not observed. No complete bounce/knockback exclusion.

**Evidence level.** InkBounceApproachGap.v actual guard/snap; InkBounceProducerEffect.v matched contact; InkAirReturnFrame.v; InkMarioRawCopyCall.v and InkMarioZeroParticleTail.v; bounded JP Wafel receipt

**Already proved — Insufficient.** From matched actual falling-contact reads and synchronized incoming display, finite movement in [-32768,32768], actor Y≥-32768 and live height in [-32768,250], the actual first bounce store creates at most 251 upward movement/display units. No low-actor/no-clone condition. Live dimensions and earlier contact are not derived; the sound/action tail is retained.

Proof: [`ibag_completed_bounce_creates_at_most_251_display_gap`](../../proofs/InkBounceApproachGap.v).

**What happens to Mario.** A bounce can put Mario's movement height at the top of an object's hitbox. Other hits first change his speed or action, leaving later movement to do the actual moving.

**What we would need.** Walking off a ledge can enter freefall and a falling contact from above without A; hostile contact can cause knockback without A. The relevant actor, overlap and interaction must still be reached. A Goomba bounce and a gust of wind do not write the same things.

**Can SSL supply it.** SSL has regular Goombas, Pokey body parts, Fly Guys and Klepto. For this transfer test, chosen cloned-enemy XYZ is granted, including HOLP from another course; actor size, tangibility and the legal clone history are not granted. Negative fire Fly Guy growth uses signed hitbox dimensions.

**Does the gap last long enough.** Most of these handlers come after the warp handler. Once the nonfading warp accepts Mario, the loop stops; we cannot sneak an extra bounce in afterward in that same loop.

**What we know.** The actual matched falling-contact snap creates at most 251 new upward units under its finite/live-height≤250 and synchronized-entry conditions, independently of placement. The actual passed contact prevents a snap below collision when its top reads match, without a height ceiling. Completed air calls refresh display. Every completed Mario callback reaches the collision copy; the zero-particle tail preserves movement/collision equality through callback return under reached ordinary receiver/storage conditions. A bounded JP diagnostic detects 12 bounces in 16 supplied poses; all 384 end-update height records agree.

**What is left to check.** Derive matched contact-to-handler live reads and actual size histories. Frame nonzero particle effects and the remaining callbacks/terrain/pre-action writers before the next useful warp check. Chosen enemy placement does not construct Mario contact or create the inherited split. No all-bounce/knockback exclusion.

Stock source: [bounce_off_object](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L515); [interact_bounce_top](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1368); [interact_damage](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1423); [interact_tornado](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1088); [interact_strong_wind](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1136).

Related atlas ranks: 5, 13B.

<a id="split-attachments"></a>

### 12 — Trees, ledges and hanging points

**Role in this review.** No pole beside the Area-1 top warp. The distant palm tree uses pole actions, whose normal placement copies the display. A local ledge release is only a nominal 100-unit drop; neither is an established source of the supplied gap.

**Gap sizing: Pole/hang copies: 0. Ledge release: a 100-unit subtraction or a shallower floor snap.** Insufficient at the local drop — source review

Letting go of a ledge shifts X/Z back by a nominal 60 and lowers Y by the source's 100-unit cap, before setting soft bonk. From a synchronized pose at ordinary heights this gives at most about +100 of vertical gap at that local write. Pole placement and stationary hanging subsequently copy movement to display.

**Limits.** The ledge number is source arithmetic at the drop, not a proof that the gap survives the resumed action. It is short of 1,170.864868 by itself. Live attachment exits remain separate.

**Evidence level.** Pinned stock area/helper/tree/mesh checks in split_catalog.py; action source review; no full exit-history proof

**What happens to Mario.** These actions attach Mario's movement position to something, or move it along an animation. Usually a display copy follows.

**What we would need.** A climbable tree/pole, a ledge or a hangable surface, plus the action that uses it.

**Can SSL supply it.** There is no stock pole beside the pyramid-top warp. The palm tree at (-5989,0,-4850) uses pole actions, far from the warp at (-2048,768,-1024). The two regular poles are in Area 2. The checked Area-1 static mesh and pyramid top have no hangable triangles; Area 2 has six. Ordinary Area-1 ledges remain relevant.

**Does the gap last long enough.** A gap halfway through an action may be gone before the next warp check. The exit from the attachment matters as much as the attachment itself.

**What we know.** The source identifies the pole, ledge and hanging writers. Our local proofs do not yet classify every way of entering and leaving those actions.

**What is left to check.** The absent local pole cannot supply a release right at the warp. A remote tree exit, a different ledge history or a later dynamic attachment would need its own producer and transfer; the stock-data check does not close all such histories.

Stock source: [set_pole_position](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L58); [check_ledge_climb_down](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L100); [climb_up_ledge](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L509); [let_go_of_ledge](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L490); [update_hang_stationary](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L375).

Related atlas ranks: 5, 13B, 18.

<a id="split-cannon"></a>

### 13 — The cannon really can leave the display behind

**Role in this review.** Normal launch needs an A edge and moves actual Mario upward, leaving the wrong sign of gap. An unusual exit would be a separate claim.

**Gap sizing: 0 while seated; firing leaves display at or below movement.** Insufficient at normal launch — source and finite checks

Firing moves actual Mario 120 units along the aim before the usual display copy. The clamped pitch is nonnegative: the checked sine-table expression raises actual Y by 0 to 118.169815 units. Starting synchronized, display-minus-movement Y is therefore nonpositive at those writes.

**Limits.** The normal firing branch also requires INPUT_A_PRESSED. The finite pitch calculation does not prove controller history, later sound-call effects or a warp transfer.

**Evidence level.** Generated-table parameter calculation + source guard

**What happens to Mario.** While Mario enters and sits in the cannon, the action updates his movement position and copies it to display. Firing moves him 120 units along the aim and returns before that display copy. That can leave the old display behind.

**What we would need.** An opened cannon and an actual cannon-entry interaction.

**Can SSL supply it.** Yes. The cannon is at (6863,0,-6860), and the stock Bob-omb Buddy can open it.

**Does the gap last long enough.** Here is the restriction: the normal firing branch tests INPUT_A_PRESSED. Sitting in the cannon takes the ordinary display-copy path. Invisibility alone does not preserve a useful high display.

**What we know.** This comes from the actual cannon code, including its early return. Coq separately confirms the stock cannon selection. We have not presented the firing observation as a proved universal action-history exclusion.

**What is left to check.** A no-new-A proposal needs a legal exit or interruption with a useful remaining gap. Normal firing does not meet the button rule.

Stock source: [act_in_cannon](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L674); [interact_cannon_base](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1066).

Related atlas ranks: 5, 13B, 18.

<a id="split-tornado"></a>

### 14 — A Tweester can move Mario, but it also updates the display

**Role in this review.** The completed normal Tweester copy supplies zero gap, already proved for either internal floor result. Transporting the enemy does not change that checkpoint.

**Gap sizing: 0 at the completed non-ejecting display-copy checkpoint.** Insufficient — already proved at the normal Tweester copy

Both floor-found and floor-missing branches feed into the same real display copy. The new US/JP proof follows that actual continuation and completed callee: display Y and movement Y are equal there, however far the Tweester just moved Mario.

**Limits.** The theorem starts after the early ejection test and ends at the completed copy. The following angle call and surrounding action history remain outside it. Separate source review follows ordinary ejection into an air step with another display copy, conditional on retaining that action and avoiding common cancellations; this is not a new complete Clight proof. Moving the Tweester itself does not bypass either copy.

**Evidence level.** New Coq execution connection: TweesterGap.v

**Already proved — Insufficient.** At the completed actual US/JP non-ejecting display copy, under its stated storage conditions, the supplied low-movement/high-display pair is impossible. Both floor-query outcomes are covered. Ejection, the following angle call and other later writers remain outside this result.

Proof: [`twg_copy_cannot_install_supplied_vertical_gap`](../../proofs/TweesterGap.v).

**What happens to Mario.** The tornado action moves Mario around the tornado and updates his stored display.

**What we would need.** A real tornado interaction and the tornado-twirling action.

**Can SSL supply it.** Yes. SSL has Tweesters. The checked stock selections confirm this.

**Does the gap last long enough.** Tornado capture is after warp in the interaction list, and the twirling movement occurs during the action. Those placements limit when it could help.

**What we know.** The generated US/JP continuation after the early ejection test now has a completed-copy proof. Both floor outcomes reach equal movement/display Y at that checkpoint, excluding the supplied low-State/high-display pair there. A new finite US/JP transport diagnostic tests 188,416 prescribed home-boundary schedules per version, stopping at first hitbox overlap or hiding. None reaches useful warp proximity. A separate relaxed-steering ledge pose can geometrically overlap Mario at the supplied low contact point; it is not an oscillation route.

**What is left to check.** Find an actual controller-driven oscillation route that avoids unwanted capture and hiding. The tested fixed-ray schedules do not supply one. The conditional western-ledge contact grants the two poses and scale phase, and creates no gap. The ordinary ejection source continues into an air step with another display copy; exceptional interruptions and later writers still need their own proof. Warp acceptance is checked before tornado capture, so a lift from the same accepted contact is too late.

Stock source: [act_tornado_twirling](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L764); [tweester_act_chase](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/tweester.inc.c#L74); [tweester_act_hide](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/tweester.inc.c#L117); [act_twirling](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_airborne.c#L680).

Related atlas ranks: 5, 13B.

<a id="split-water"></a>

### 15 — Yes, the desert has swimming offsets

**Role in this review.** The checked single-refresh pitch/bob expression is below 208 units, even granting independent maxima. The oasis is distant; a separate clamp or later downward move would need its own case.

**Gap sizing: About +208 in the generous one-refresh calculation at Y=768.** Insufficient in the checked expression envelope

Pitch adds up to 60. Reset-derived bob height is at most 147.99609375 over every signed-16 reset pitch. Granting both maxima independently after one copy at actual Y=768 gives display Y=975.99609375, a gap of 207.99609375. That is still 962.868774 below the supplied display.

**Limits.** This finite expression envelope uses the unchanged stock sine table and reset-derived bob state. It is not a reachable swim maximum or a bound on extra calls without a fresh copy. Entry/exit height clamps and support changes are separate writes.

**Evidence level.** Reproducible finite expression calculation

**What happens to Mario.** Entering water or hitting its height limits can move Mario's movement position. Swimming pitch and surface bobbing can then add an offset to the stored display after the swimming copy.

**What we would need.** A water box and the right swimming action.

**Can SSL supply it.** The oasis is real: water box 0 covers X -6911..-4223 and Z -7167..-4607, at Y=-127. We cannot cross swimming off just because this is a desert.

**Does the gap last long enough.** An offset while swimming is not yet a raised display beside the pyramid warp. It has to survive leaving the water and everything done afterward.

**What we know.** The stock water box and swimming writers are identified in the source. No complete oasis-to-Ink transfer is proved.

**What is left to check.** Show how a legal swimming sequence leaves a useful offset after the exit, or rule out a precisely stated transfer.

Stock source: [set_water_plunge_action](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1174); [check_common_submerged_cancels](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_submerged.c#L1500); [update_water_pitch](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_submerged.c#L197); [surface_swim_bob](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_submerged.c#L428).

Related atlas ranks: 2, 5, 19, 21.

<a id="split-shell"></a>

### 17 — The shell gives Mario a display offset

**Role in this review.** Walls do not stack the 42/45-unit shell offset. Keep this scoped insufficiency separate from a later non-shell drop; this batch adds no Coq closure.

**Gap sizing: +42 airborne; +45 on the ground, per ordinary refresh.** Insufficient alone — source arithmetic

At actual Y=768, the shell leaves display Y=810 in air or 813 on the ground. Wall results still pass through the step copy; early A/Z returns add nothing. The native helper-outcome diagnostic found no stacking. See the shell-gap investigation for water, quicksand, speed, mounting and later-writer distinctions.

**Limits.** No shell-specific amplifier was found. This is not a universal bound on shell-assisted histories: another support, dialog or later State write could enlarge a retained small offset, and still needs a concrete useful continuation.

**Evidence level.** Existing scoped proofs + source review + finite native branch diagnostic

**What happens to Mario.** Shell riding updates the display and adds a riding or tilting offset. In the airborne action, the code adds 42 to display Y.

**What we would need.** A Koopa shell and the corresponding riding action.

**Can SSL supply it.** Yes. The stock shell box is at (5840,940,2500).

**Does the gap last long enough.** Ground and air movement refresh before adding 45 or 42, including wall-stop and in-step missing-floor results. A canceled action adds no shell offset. Later non-shell writers need separate analysis.

**What we know.** The normal copy and local source-shape proofs remain scoped. The shell branch diagnostic passes 7760 supplied outcome/height cases and their repeated calls in each US/JP build, plus two early exits. It uses explicit helper test doubles, not live terrain or controller histories.

**What is left to check.** A shell-assisted route still needs a separate downward State writer: at the fixed anchor, another 1125.864868 units after a ground offset. Prove its live helpers, timing and contact before promoting the whole case.

Stock source: [act_riding_shell_air](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_airborne.c#L656); [tilt_body_ground_shell](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L745).

Related atlas ranks: 25, 2.

<a id="split-quicksand"></a>

### 18 — Negative depth plus a dialog that keeps the display

**Role in this review.** The granted negative can make a large enough display rise arithmetically. Supported update retention and the low-pose transfer still need their actual history; the accepted no-A seed contract is a separate scoped exclusion.

**Gap sizing: Minus depth per real sink; retained -4 can exceed 1170 units after 293 calls.** Size can be sufficient conditionally; useful gameplay retention is unproved

The exact supplied negative produces the Original display height in one completed real sink. Even depth -4 exceeds that height after 293 consecutive real sink calls from display 768, preserving movement, collision and depth. This rules out an intrinsic small-magnitude objection, not the route.

**Limits.** Consecutive callee invocations contain no dialog scheduler or intervening update frames. The low candidate lacks a first floor, so repeated dialog updates cannot simply be granted there. A supported start still needs the later low-position transfer. The accepted no-A writer/action/controller conditions exclude upward sinking separately.

**Evidence level.** Complete generated US/JP sink effects, exact binary32 certificate, accepted conditional seed theorem

**Already proved — Insufficient.** Under the accepted classified stock depth-write/action/physical-input contract and no A press, a finite completed real sink cannot raise display. Granting a negative seed for a transfer test deliberately leaves that contract case; unrestricted gameplay coverage is not claimed.

Proof: [`iqps_classified_no_a_sink_cannot_create_upward_gap`](../../proofs/InkQuicksandProducerSize.v).

**What happens to Mario.** Sinking subtracts quicksand depth from display Y. If that depth is negative, the subtraction raises the display instead. Skipping a later refresh can keep it there.

**What we would need.** A useful negative seed, a collectible reward and the right milestone dialog. The accepted classified stock history contract traces a useful seed to physical A; a no-A reward opportunity does not supply it.

**Can SSL supply it.** SSL has quicksand and rewards. That does not prove a no-A negative seed. For the agreed transfer test, we may grant the seed and a valid coin/star opportunity.

**Does the gap last long enough.** A dialog can preserve the display, but the warp interaction and remembered platform still have their own checks. We already know that some conditional continuations move Mario while the display survives.

**What we know.** New complete US/JP sink effects connect the arithmetic to the real writes. Supplied depth -1170.8648681640625 raises display 768 exactly to 1938.8648681640625. Retained depth -4 gives 1936 after 292 real sink calls and 1940 after 293. Under the accepted classified no-A seed contract, depth stays nonnegative and the real sink cannot raise display.

**What is left to check.** For the granted-seed transfer test, derive floor-supported dialog updates, intervening frames, retained depth/display, the earlier low collision pose and useful top timing. The low test pose is already floorless; the 293 calls are not a reached dialog. Unrestricted seed coverage remains open outside the accepted contract.

Stock source: [sink_mario_in_quicksand](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1545); [act_star_dance](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L640); [general_star_dance_handler](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L590); [act_reading_automatic_dialog](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L443).

Related atlas ranks: 19, 2.

<a id="split-dialog"></a>

### 19 — A dialog can keep a gap; it cannot create one by pausing

**Role in this review.** A pause may keep an existing display. The sand subtraction, if any, supplies the height and is counted separately.

**Gap sizing: No independent fixed upward offset; preserves what enters.** A possible keeper, not the original height source

Automatic dialog can leave the stored display untouched. Repeated sand subtraction belongs in the sand row. Ordinary sign alignment moves X/Z and then copies display; NPC dialog also has a display copy.

**Limits.** We need the particular dialog branch and release boundary. We do not assume every dialog preserves a gap. Active automatic dialog also skips the warp handler.

**Evidence level.** Existing dialog-gate results + source review

**What happens to Mario.** Some dialog states skip ordinary movement or display refresh. Reading a sign can also move Mario while aligning him with the sign.

**What we would need.** A particular sign, NPC or reward dialog, at the right action and timer.

**Can SSL supply it.** Signs and Bob-omb Buddy are present. The automatic milestone dialog is a separate reward-dependent case.

**Does the gap last long enough.** Pausing keeps what was already there. On release, the next action or floor check decides whether that old gap is useful.

**What we know.** The dialog gate and particular post-dialog refreshes are proved. We cannot treat every dialog as the same kind of freeze.

**What is left to check.** Find the last position change before the pause and the first useful check afterward, including the floor and contact checks.

Stock source: [act_reading_sign](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L496); [execute_mario_action](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1699); [mario_process_interactions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1780); [act_reading_npc_dialog](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L378).

Related atlas ranks: 2, 6, 19.

<a id="split-warp-reset"></a>

### 20 — Bringing a gap through a warp or level entry

**Role in this review.** Area 1 has no stock instant-warp table. The Area-2/3 instant warps displace by zero and occur after our checkpoint. Ordinary warp-entry and imported-state histories remain separate.

**Gap sizing: Instant warp: incoming gap − vertical warp displacement.** Relocation can make a gap elsewhere; no matching Area-1 table

The instant-warp code moves State and raw collision, leaving stored display for later work. A downward displacement could therefore create the right sign. The stock SSL script supplies no Area-1 instant warp; its Area-2/3 instant warps have zero displacement. The upper object-warp's proved final action tail creates no new split.

**Limits.** This is a stock-script/source distinction, not a theorem about every imported state. A normal area entry and door sequence need their own copies traced; changes after the selected acceptance checkpoint are too late.

**Evidence level.** Pinned script and source review + existing acceptance-tail proof

**What happens to Mario.** Entry and warp code can relocate or reset positions. Door actions have their own movement and animation copies.

**What we would need.** The particular warp or level command and a legitimate way of reaching it.

**Can SSL supply it.** SSL has ordinary fading and nonfading warps. Area 1 has no instant-warp command, and the named door actions are not its stock entrance mechanism.

**Does the gap last long enough.** Our checkpoint is before the disappearing action and Area-2 initialization. A change after that point cannot explain a gap already present when the warp was accepted.

**What we know.** The reached entry-depth reset and real warp-call connection are proved. The accepted-warp final action call also preserves the positions it receives. Earlier calls have separate limits.

**What is left to check.** A gap or actor brought from another course must survive the real transition. We cannot carry it across by assumption.

Stock source: [check_instant_warp](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/level_update.c#L530); [init_mario](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1788); [geo_obj_init_spawninfo](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/graph_node.c#L712); [act_entering_star_door](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L858); [act_going_through_door](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L919); [act_unlocking_key_door](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L775); [act_unlocking_star_door](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L817); [interact_warp](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L855).

Related atlas ranks: 2, 13B, 18, 32.

<a id="split-cutscene"></a>

### 22 — Ending cutscenes can place Mario almost wherever they need him

**Role in this review.** An ending-scene relocation is not a stock SSL reward or action entry. A legal SSL first constructor would be needed before it becomes a gameplay candidate.

**Gap sizing: Depends on the selected ending/door/action sequence.** No legitimate SSL producer established

Some cutscenes relocate movement or display independently. Finding that assignment in the executable does not show an ordinary SSL action can enter the scene. There is no sound universal number for this mixed group.

**Limits.** Identify a legal first action constructor and exact coordinate writer before treating this as a candidate. No arbitrary action selection is granted.

**Evidence level.** Source review; action entry remains open

**What happens to Mario.** The ending and jumbo-star sequences deliberately move Mario or his stored display to stage the scene.

**What we would need.** The proper endgame actions and the code that starts them.

**Can SSL supply it.** The ending sequence is not an ordinary SSL entry or reward dance. SSL's actual dialogs and rewards have their own entries in this catalog.

**Does the gap last long enough.** Finding a function in the executable does not show that SSL can start that action.

**What we know.** The generated position-write scan finds these assignments, so we have kept them visible rather than silently dropping them.

**What is left to check.** A full gameplay proof must check the real action constructors. 'All cutscenes are harmless' is not a substitute for doing that.

Stock source: [act_end_waving_cutscene](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L2639); [end_peach_cutscene_run_to_castle](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L2469); [end_peach_cutscene_run_to_peach](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L2150); [jumbo_star_cutscene_falling](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L1811).

Related atlas ranks: 5, 18, 21.

<a id="split-debug"></a>

### 23 — Debug free movement is outside this gameplay challenge

**Role in this review.** Injected debug-action entry is outside this controller-gameplay task. Listing its code does not make a new route.

**Gap sizing: 0 at its display copy; arbitrary entry is outside this challenge.** No authorized stock-gameplay producer

The debug movement action copies its result into display. Choosing this action by changing game state is not controller-driven gameplay under the selected rules.

**Limits.** This is a scope decision, not a proof that all normal action transitions are covered.

**Evidence level.** Source review + chosen execution scope

**What happens to Mario.** The debug action directly moves Mario and refreshes his display.

**What we would need.** Entry into the debug action.

**Can SSL supply it.** A compiled debug helper does not make injected debug actions an ordinary controller route through SSL.

**Does the gap last long enough.** Choosing an arbitrary action value is outside the model used for this challenge.

**What we know.** The source scan keeps the function on the list, marked as outside scope. That is a scope choice, not a new impossibility proof.

**What is left to check.** A study of debug builds or injected actions would need different rules. This catalog does not include that study.

Stock source: [act_debug_free_move](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L536).

Related atlas ranks: 31.

<a id="split-render"></a>

### 24 — Looking displaced is not always a change to the stored display

**Role in this review.** Moving the camera, a mirror proxy or a draw matrix does not change the stored display used by the retry. A genuine write to Mario would need to be identified separately.

**Gap sizing: 0 from writes only to camera, proxy, matrix or local vectors.** No gap unless the actual stored display vector changes

A drawn or camera-relative movement does not help the retry if the stored Mario display position stays put. The mirror uses its own object; local vectors and transforms must be distinguished from Mario's cells.

**Limits.** Actual receivers and aliases still matter. This is not permission to treat every renderer or animation call as harmless.

**Evidence level.** Receiver-specific source review

**What happens to Mario.** The camera, mirror proxy, object transforms and temporary vectors can all have something called pos. A write to one of those is not automatically a write to Mario's three relevant positions.

**What we would need.** We have to identify the actual object or local variable receiving the write.

**Can SSL supply it.** Camera and rendering code are present. The castle mirror proxy is another object, not another live Mario slot.

**Does the gap last long enough.** A visual animation or matrix shift only helps the retry if it changes the particular stored vector that the retry reads.

**What we know.** The broad scan deliberately catches harmless lookalikes, including a coin-formation local vector and camera bookkeeping. They are accounted for here.

**What is left to check.** Where a proof depends on one of these being separate from Mario, prove that actual storage relationship. Do not classify by the name pos alone.

Stock source: [geo_render_mirror_mario](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_misc.c#L589); [spawn_coin_in_formation](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/coin.inc.c#L170); [create_transform_from_normals](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/tilting_inverted_pyramid.inc.c#L11); [update_ledge_climb_camera](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L516).

Related atlas ranks: 20, 21, 31.

<a id="split-generic-objects"></a>

### 25 — A helper moves its object. Which object is that?

**Role in this review.** This is a coverage question, not one measured gap producer. Distinct-child copies preserve Mario in the existing local proofs; other actual receivers still need checking.

**Gap sizing: No common numeric bound; depends on the actual receiver.** Known distinct-child copies add 0 to Mario; wider coverage remains open

The completed copy into a different valid particle slot preserves Mario. A generic position helper acting on Mario instead would need its own argument and write analysis. Existing stock graphical-offset command payloads are at most +240 even if granted to Mario, but that does not cover every generic write.

**Limits.** The allocator/child theorems keep their stated boundaries. Ownership, other callbacks and alias coverage are not replaced with a blanket zero-gap assumption.

**Evidence level.** Existing local proofs and command census

**What happens to Mario.** Movement helpers and behavior commands write to the object they receive. The allocator initializes the slot it returns.

**What we would need.** A real call, its actual destination and valid Object-pool ownership.

**Can SSL supply it.** SSL runs many of these helpers. A spawned child here is another object, such as a particle; it does not mean another Mario.

**Does the gap last long enough.** Two objects can occupy different slots in the same pool. The proof must show that the writes stay in the intended slot.

**What we know.** The particle-copy and allocator proofs settle specific calls and initialization steps. The full sequence of callbacks and object lifetimes is still open.

**What is left to check.** For the remaining calls in the chosen interval, identify the real destination and its writes. Arbitrary pointer modification is outside the gameplay rules.

Stock source: [allocate_object](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/spawn_object.c#L208); [obj_set_gfx_pos_from_pos](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L634); [obj_update_gfx_pos_and_angle](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/behavior_script.c#L84); [obj_copy_pos_and_angle](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L613); [vec3f_copy](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/math_util.c#L28); [vec3f_set](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/math_util.c#L36).

Related atlas ranks: 5, 13, 20, 21, 31.

<a id="split-copies-pauses"></a>

### 26 — A skipped update needs something worth preserving

**Role in this review.** A collision copy can make an already-low actual position available to contact. A skipped update preserves values; neither supplies the earlier height change.

**Gap sizing: No new display-minus-movement gap; collision copy transfers an existing one.** Can complete the low collision record only after a producer exists

If actual Mario has already moved down while display stayed high, copying State into the raw Object makes collision low too. That is useful bookkeeping for Ink, but it does not create the original height difference. Skipping a phase merely preserves its incoming values.

**Limits.** The crucial order is whether that collision copy happens before another display refresh. The ordinary caller still copies State after execute_mario_action returns.

**Evidence level.** Source order + existing raw-copy proofs

**What happens to Mario.** The ordinary movement-to-Object copy brings collision up to date. A skipped phase may preserve an old mismatch, but skipping alone does not move Mario.

**What we would need.** The actual update order, action return, time-stop flags and copy destination.

**Can SSL supply it.** All of this matters in SSL. The initialized second-State-copy proposal is already excluded in the existing source model.

**Does the gap last long enough.** Even an early return from execute_mario_action goes back to Mario's object update, which then performs the ordinary copy. A skipped-copy proposal must show what really bypasses it.

**What we know.** The copy-index and completed-copy results are checked. That does not yet prove the scheduler and object identity for every possible history.

**What is left to check.** Pair a real position change with an actual delayed or skipped copy, then reach the contact or floor query before the advantage disappears.

Stock source: [copy_mario_state_to_object](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L224); [bhv_mario_update](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L267).

Related atlas ranks: 6, 18.

<a id="split-query-alias"></a>

### 27 — A different floor answer is not itself a position write

**Role in this review.** Coordinate conversion changes the query input, not the three stored positions. A resulting snap or retry is counted under its actual writer.

**Gap sizing: 0 new position gap.** Changes what a query sees, not where the records are

Signed-16 conversion can make the floor query see different coordinates. It does not itself write State, display or raw collision. It may help use a separately created gap.

**Limits.** A changed floor answer can feed a later snap or retry, which belongs to that writer's row. Ordinary coordinates are used by the supplied vertical setup.

**Evidence level.** Existing coordinate/geometry results

**What happens to Mario.** A signed-16 conversion or a different sample point can give a different floor answer without writing any of Mario's three position records.

**What we would need.** The actual converted coordinates, floor lists and query point.

**Can SSL supply it.** SSL uses this collision code too. Useful distant coordinates still need a legal way to reach them and make contact.

**Does the gap last long enough.** This can affect how a gap is used. It does not create the gap by itself.

**What we know.** The finite geometry and coordinate-alias checks keep their stated ranges. They are not a proof about every controller history.

**What is left to check.** Connect a reachable pose to the live floor choice and accepted warp contact. Memory corruption is not part of this mechanism.

Stock source: [find_floor_from_list](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_collision.c#L401); [find_wall_collisions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_collision.c#L184).

Related atlas ranks: 1, 3, 2.

## Exactly what was checked

[PositionSplitCatalog.v](../../proofs/PositionSplitCatalog.v), exposed as `MainTheorem.current_f02_position_split_catalog`, checks the actual generated US/JP program objects. Across all 39 generated units per version, the direct callers of `set_mario_pos` are exactly `dorrie_raise_head`, `bhv_tilting_inverted_pyramid_loop` and `apply_platform_displacement`. Twelve named actor behaviors fail the stock selector checks; tree, Tweester, Tox Box and closed cannon provide positive controls. The regular script test conservatively reads the whole SSL script, while macro and special checks use Area 1. Special-preset IDs reuse the earlier checked collision-data receipt.

The passing audit is `build/audit/20260924-104903-5dt7xgd1`: 595 registered sources, 425 of 519 proof modules in MainTheorem's import closure, 94 standalone modules, and no proof-hole/link problems. The catalog boundary and setter census each use four allowed foundations, the absent-selector theorem uses none, and the existing main Ink boundary still uses nine. Foundation counts do not count explicit gameplay premises.

The separate [source index](position-split-source-index.json) scans 336 pinned src C files, recognizes 4553 textual definition spans and records 824 coordinate-reference spans, including other courses, debug, camera and rendering code. It scans all 78 generated files (2,567 US and 2,561 JP function definitions; 9,156 and 9,110 assignments). All 50 distinct function names whose generated assignment destination contains `_pos` have a catalog home. This text check includes local arrays and other receivers and is deliberately broader than Mario writes. It is not a Coq coverage theorem.

The index reads the generator's pinned Git revision, never the modified decomp checkout. It records generated-file hashes. Five focused tests cover comments/strings, macro return types, version-alternative signatures, assignment destination versus read, and malformed assignment rejection. C spans retain preprocessor alternatives rather than pretending to be parsed bodies. Pointer aliases, union/byte writes, callees, externals and actual receivers remain semantic obligations. A syntactic named-position census cannot close those.

Regenerate with `python3 pipeline/split_catalog.py`; check both the index and this document with `python3 pipeline/split_catalog.py --check`. Run the scanner tests with `python3 pipeline/test_split_catalog.py`. The canonical prose is [position-split-catalog.json](position-split-catalog.json); this document and the private site use the same rows.

## How this becomes an exclusion proof

The remaining task is to prove that every reached write relevant to the fixed checkpoint belongs to the checked cases, with its real receiver and action/actor prerequisites. For each applicable case, prove either that its preconditions cannot occur there or that the next copy/contact/query removes its usefulness. Compose those results through the actual callback and interaction order. This classification is not presently a discharged theorem or an accepted premise.

The most focused next gameplay batch remains the pre-action geometry/retry interval fed by platform or floor alignment, with the raised display's last writer identified. Palm-tree pushes and water/cannon/shell transfers have separate catalog entries, so a proof for that interval will not silently claim to settle them all. Close a named case when its conditions and boundary match; expand only if another row actually reaches that boundary.
