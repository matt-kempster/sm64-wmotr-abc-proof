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
  callees; the actual Start prefix and intervening frame still need proof.
- [x] Complete positive-countdown playback call with second logical
  controller absent, exact input outputs and a byte-range memory frame.
- [ ] Formalize the actual loaded-gameplay/consumed-input observation boundary
  and permitted initial/external events; exclude mere title-fade bookkeeping.
- [ ] Prove loader allocation, table/index/cache and DMA memory invariants
  from the real initialization; connect authenticated ROM data to memory.
- [ ] Discharge the first-start loader premise, cover later indices/wrap,
  and instantiate the local memory/layout conditions in a reachable state.
- [ ] Execute the concrete script-interpreter route from returned header
  through the register and level initializer to the selected gameplay level.
  Include indirect targets, stack/command pointers and segment/address rules.
- [ ] Establish the correct per-unit/private-atom linkage and retail-address
  refinement rather than treating independently generated units as linked.
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
