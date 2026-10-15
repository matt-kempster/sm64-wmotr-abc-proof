# Obligations for a gameplay verdict

The requested all-executions claim remains **OPEN**. Completed local work is
kept separate from unproved composition and reachability.

- [x] Separate Demo-Coq project, US/JP pin, reproducible Clight pipeline and
  registered proof modules.
- [x] Constructive local CompCert execution of the generated installation
  suffix and return, with explicit memory/layout premises.
- [x] Generated syntax checks for input playback, delayed-demo interception,
  interpreter register transfer, direct level writes and demo script opcodes.
- [x] Authenticated finite ROM metadata check (outside Coq).
- [x] Whole first-demo title body, with the real loader still an execution
  premise; full active-demo level-selection and interpreter call executions.
- [x] Composed actual first-miss loader/title-body execution, replacing that
  loader premise with the concrete `dma_read` call and post-DMA reads.
- [x] Actual equality-helper and nonmatching conditional-jump execution;
  mechanical diagnosis of symbolic-pointer shift in the real address helper.
- [x] Exact generated header-to-level-entry dispatch mapping, correcting
  `bitdw.bin` header 30 to the Bowser 1 arena rather than course 17.
- [x] Actual local painting-null, delayed-demo/internal-warp, transition
  completion and full pause/dialog-query executions under explicit premises.
- [x] Complete Demo Next scheduling, including the real transition and RGB
  callees, and its actual Start caller prefix with the real intro-text call
  still a premise; the intervening frame still needs proof.
- [x] Complete playback consumer for ordinary, expiring and terminal records
  with second logical controller absent, exact outputs and byte-range frames.
- [x] Complete instant-warp rejection for null floor or null table under
  explicit actual field reads and the non-castle level condition.
- [x] Execute the numeric address helper and authenticate finite selected
  script/callback images; kernel-check numeric script representations and
  the seven-header decoder. Runtime caller/overlay simulation remains open.
- [x] Actual taken conditional jump with numeric target-cell input, both
  real callees, exact numeric PC store and other-block frame. The following
  opcode dereference still requires a representation simulation.
- [x] Actual connected-controller branch with neutral sticks through the real
  analog-adjustment call and its allocation/free, using an explicit pure
  contract for the named external `sqrtf` call. Arbitrary-stick and whole-loop
  composition remain open. A separate complete analog-call theorem now
  handles arbitrary sticks and both cap branches under the same named
  pure math contract.
- [x] Actual disconnected second-controller branch and player-three field
  copy suffixes, preserving player-one bytes and entry-valid accesses.
  The positive-record post-polling caller below now composes both iterations.
- [x] Actual normal-frame timer segment, including preservation of the scheduled
  operation/timer via its concrete memory frame.
- [x] Contiguous actual warp/instant-warp/timer caller interval up to object
  updates, with no warp-callee execution premise and explicit entry reads.
- [x] Contiguous actual post-camera interval through painting's real
  allocation/free, pending timer20-to19, full pause query and zero return,
  with explicit entry reads; earlier object/HUD/camera effects remain open.
- [x] Complete eight-iteration area reset, null painting/instant pointers
  and actual generated layout witness. A composed theorem now constructs
  the actual area unit's initial memory and discharges all reset resources.
  Linked boot and later lifecycle remain open.
- [x] Complete real current-level GET command and call, exact register and
  pointer results, actual handler-table and command-word syntax checks.
- [x] Actual ordinary playback through the controller-copy boundary with
  arbitrary stick bytes and new-Start/END guards; original-loop small-step
  path to the analog call under a supplied program's global environment.
- [x] Complete original post-polling controller path for every timer branch,
  including EOF and expiry, arbitrary sticks/current/prior buttons, actual
  analog call, both loop iterations and player-three copies. Exact outputs,
  stream pointer/timer/header and protected reads are preserved. Start/EOF
  guards follow as separate corollaries. Second logical controller absent,
  concrete resources and named math contract remain explicit; connected P2,
  hardware entry and all-frame provenance remain open.
- [x] Scoped private globals in all 38 regenerated units, positive eight-unit
  AST links and two actual Clight unit-pair links. Public declarations and
  the full game link remain separate obligations.
- [x] Proved empty-array declaration normalization from actual initialized
  definitions, with exact per-unit initial-memory and step preservation;
  official nine-unit Clight links in both versions. This is a selected
  script-data link; full game linking and overlay simulation remain open.
- [x] Complete actual delayed Demo Next calls for timers 2 through 20 and
  terminal timer 1, including real dialog reset, transition helper and
  special-warp call. Terminal debug0/non-null-demo/dialogtype!=1 reads
  and scalar resources remain explicit. Consecutive gameplay-frame
  preservation, dialog zoom and caller composition remain separate.
- [x] Actual normal caller after painting through the complete terminal
  delayed call and mode-4 zero return; full post-camera painting/countdown/
  pause/return interval for every pending timer 2–20. These do not establish
  twenty consecutive gameplay frames or the earlier object/HUD/camera frame.
- [x] Exact next selected-source pointer-type link failure, current
  normalization's invariance on it, and finite corresponding Gfx definition/
  layout checks. This certifies a remaining anonymous-tag boundary, not an
  all-19-unit link or a type-renaming simulation.
- [ ] Formalize the actual loaded-gameplay/consumed-input observation boundary
  and permitted initial/external events; exclude mere title-fade bookkeeping.
- [ ] Prove loader allocation, table/index/cache and DMA memory invariants
  from the real initialization; connect authenticated ROM data to memory.
- [ ] Discharge the first-start loader premise, cover later indices/wrap,
  and instantiate the local memory/layout conditions in a reachable state.
- [ ] Execute the concrete script-interpreter route from returned header
  through the register and level initializer to the selected gameplay level.
  Include indirect targets, stack/command pointers and segment/address rules.
- [ ] Complete the public declaration/source-link and retail-address
  refinement rather than treating selected unit links as a complete game.
  Include numerical segmented addresses and a non-vacuous boot trace: the
  actual helper's shift is undefined on an unrefined symbolic `Vptr`.
- [ ] Prove construction and preservation of absent painting/instant-warp
  tables for loaded demo areas; the local opcode census alone is insufficient.
- [ ] Cover every reached level-changing path and its debug, pause, credits
  and ordinary-play guards under the chosen start conditions.
- [ ] Establish/preserve zero ordinary warp destination: it takes priority
  over a negative demo-exit code during transition completion.
- [ ] Prove all reached direct/indirect stores and external/DMA operations
  preserve stream identity, input bounds, level, area and script state,
  except for specified authorized updates.
- [ ] Compose these results into a no-mismatch invariant, or supply a
  normally reachable counterexample with the stream and gameplay level
  authenticated.

A generated syntax equality is not an executed branch. An executed local
branch is not a reachable retail frame. Neither clean assumptions nor a
successful build closes the unchecked obligations.
