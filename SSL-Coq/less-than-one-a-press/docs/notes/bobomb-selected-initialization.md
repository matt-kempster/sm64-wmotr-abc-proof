# Successful initialization and readable Bob-omb tables in US and JP

Date: 29 October 2026. Starting report checkpoint:
`bc2afde44980c1f4d8f5db98388e3ac71dec4ed3`.
SM64 source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

This follows the [real animation-data linking correction](bobomb-animation-data-repair.md).
The new US existence proof and the combined initialized-table witness pass
targeted Coq checks, assumption queries and the integrated MainTheorem audit.
Validated proof checkpoint:
[`42d55ad`](https://github.com/tra38/sm64-wmotr-abc-proof/commit/42d55ad9d696c948263aa05b6ae386e212089d0a).
No survival, regrab or wrong-warp result is claimed.

## What is added

The selected US program is still `us_viewport_repaired_program`; JP is still
`jp_official_cleaned_slice`. No generated AST, animation byte, source flag,
definition selector or program constructor changes in this follow-up.

The earlier table-read theorem takes successful initialization as an explicit
premise. The new result supplies a satisfying initialized memory for each
version and derives the actual two pointer loads and NULL-sentinel load in
that same memory. This removes the initialization premise as a possible
source of vacuity for both selected programs. The older conditional theorem
remains available unchanged.

## Proof construction

1. `USInitializerReceipt01` through `USInitializerReceipt12` check all 39
   actual generated US units with the existing initializer-alignment checker.
   `USInitializerAggregate` combines those cached receipts structurally.
2. `USRepairedInitialMemory` uses checked normalized-definition provenance:
   every selected variable originates in the real source-unit union. The
   viewport repair changes type tags but preserves initializer bytes, so the
   source alignment proof transfers to the actual selected US definition list.
3. The existing `us_repaired_init_addrof_identifier_resolves` theorem resolves
   each initializer relocation in the actual repaired US global environment.
   US resolution is proved from its own source census and symbol transport.
4. These two facts construct `ProgramInitialMemoryConditions` and invoke
   CompCert's `Genv.init_mem_exists` through the existing opaque wrapper
   `program_initial_memory_exists_from_conditions`. There is no whole-program
   `vm_compute` of initialized memory and no supplied initialization-success
   hypothesis.
5. `SelectedClightInitialMemory` combines that US theorem with the existing JP
   existence theorem. `BobombAnimationInitialization` applies the already
   checked animation-table theorem to each witness and is consumed by the new
   MainTheorem boundary.

All 16 new proof modules are registered in `_CoqProject`. Per-unit alignment
checks use the real generated programs; no handwritten program or memory is
substituted.

## Exact public statements

```coq
From Coq Require Import ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  GameTypes USWholeASTTagRepair SelectedClightTarget BobombAnimationLink
  USRepairedInitialMemory SelectedClightInitialMemory
  BobombAnimationInitialization.

Theorem us_viewport_repaired_initial_memory_exists :
  exists memory,
    Genv.init_mem us_viewport_repaired_program = Some memory.

Theorem selected_clight_initial_memory_exists : forall version,
  exists memory,
    Genv.init_mem (selected_clight_target version) = Some memory.

Theorem selected_bobomb_animation_initialized_table_exists : forall version,
  exists memory table_block anim0_block anim1_block,
    Genv.init_mem (selected_clight_target version) = Some memory /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some table_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim0_id = Some anim0_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim1_id = Some anim1_block /\
    Mem.load Mptr memory table_block 0 = Some (Vptr anim0_block Ptrofs.zero) /\
    Mem.load Mptr memory table_block 4 = Some (Vptr anim1_block Ptrofs.zero) /\
    Mem.load Mint32 memory table_block 8 = Some (Vint Int.zero).
```

These statements have no explicit initialization-success or gameplay
hypotheses. `version` ranges over exactly `VersionUS` and `VersionJP`.
The full imports are in the three source files. The public aggregate is
`bobomb_animation_initialization_boundary_checked : BobombAnimationInitializationBoundary`;
`MainTheorem.current_bobomb_animation_initialization_boundary` exports that
same proposition, including the earlier exact seven-asset link boundary.

## Validation and reproduction

The targeted US proof and combined witness checks pass. Their assumption
queries and the new MainTheorem boundary use exactly five allowed library
foundations: `Axioms.proof_irr`, `ClassicalDedekindReals.sig_forall_dec`,
`ClassicalDedekindReals.sig_not_dec`, `Classical_Prop.classic` and
`FunctionalExtensionality.functional_extensionality_dep`. There is no
project-specific axiom and no external-call semantic axiom in this new boundary.

Integrated audit `20261029-135749-oykqytoh` passes the build, 702-source
inventory, proof-hole, link-hygiene, all five assumption queries and integration
checks. Main imports 536 of 622 proof modules; 86 remain standalone-only, with
zero integration problems. The new initialization boundary and retained data
boundary use five foundations each; the three established regression queries
retain nine/seven/four. The baseline audit `20261029-133557-v0gjzaa9` also
passed before these changes. The [validation receipt](bobomb-selected-initialization-validation.json)
records the exact commands, source/log hashes, staging failures and final outcomes.

Run in Ubuntu WSL from `SSL-Coq/less-than-one-a-press`, with the existing
`sm64-item-proof` switch, Coq 8.16.1 and CompCert 3.15:

```sh
source pipeline/env.sh
ulimit -S -v 6815744
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/BobombAnimationInitialization.vo
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/MainTheorem.vo
timeout 240 bash pipeline/assumptions.sh LessThanOneAPress.Proofs.USRepairedInitialMemory us_viewport_repaired_initial_memory_exists
timeout 240 bash pipeline/assumptions.sh LessThanOneAPress.Proofs.BobombAnimationInitialization bobomb_animation_initialization_boundary_checked
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_bobomb_animation_initialization_boundary LessThanOneAPress.Proofs.MainTheorem current_bobomb_animation_link_boundary LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked
```

A cold dependency build may need the staging commands before the bounded
selected audit. The memory cap and the audit's 600/240-second limits are
unchanged. An early broad membership tactic timed out; explicitly instantiating
the same membership lemma removed that reduction. Required CompCert coercion
and integer-notation imports were also corrected. Only the final successful
checks count as validation.

## Meaning and remaining boundaries

This is CompCert global-memory initialization and three concrete table loads.
It is not an OS-to-task handoff or an SM64 boot trace. It does not reach a
Bob-omb spawn, execute LOAD_ANIMATIONS/ANIMATE, justify segmented-pointer
conversion, establish later animation-index bounds, preserve the writable
animation globals through later calls, or certify every other actor-data
dependency. Source-to-cleaned/viewport and retail refinement remain separate.

Complete Bob-omb survival, usable Area-2 regrab and a reachable wrong warp
remain open. Mario's render-call memory frame and the teleporter audio,
ownership, allocation and lifetime questions are unchanged. All 45 route
estimates and gameplay verdicts are retained.
