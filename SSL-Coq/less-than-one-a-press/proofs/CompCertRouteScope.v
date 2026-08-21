(** The execution-model boundary for the route atlas.

    The active project describes runs with CompCert Clight [step2].  That
    relation contains only successful, defined source operations.  In
    particular, an ordinary load or store needs a valid CompCert access and a
    Clight call needs a function value resolved by the program's global
    environment.  An invalid operation therefore has no next Clight step.

    This does *not* say that the compiled N64 machine code cannot continue
    after source undefined behavior.  CompCert's compiler-correctness theorem
    explicitly permits target behavior to become more defined after a source
    program goes wrong.  Raw post-undefined-behavior execution, arbitrary
    instruction jumps, DMA, interrupts, and self-modifying code require an
    assembly/hardware model and are not disproved here.

    Official references for this boundary:
    - https://compcert.org/man/manual004.html
    - https://compcert.org/man/manual005.html
    - https://compcert.org/doc/html/compcert.cfrontend.Clight.html
    - https://compcert.org/doc/html/compcert.driver.Complements.html
 *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Coqlib Events Globalenvs Memory Values.

Import ListNotations.

(** Four distinct statuses are needed.  Treating all of them as merely
    "memory corruption" would incorrectly mix defined Clight behavior with
    behavior for which the current project has no execution witness. *)
Inductive CompCertRouteScope : Type :=
| DefinedInternalClight
| ParameterizedClightExternal
| StuckBeforeAClightSuccessor
| RequiresMachineSemantics.

Inductive RouteMechanism : Type :=
| OrdinaryGameTransition
| DefinedInBoundsStore
| DefinedSameBlockAlias
| DefinedInteriorPointerAccess
| DefinedObjectSlotReuse
| DefinedKnownFunctionRetarget
| UnresolvedExternalCallEffect
| OutOfBoundsLoad
| OutOfBoundsStore
| InvalidPointerDereference
| InvalidFunctionPointerCall
| ArbitraryInstructionJump
| PostUndefinedBehaviorAssemblyContinuation
| HardwareDmaOrInterruptWrite
| SelfModifyingCode.

Definition route_mechanism_scope
    (mechanism : RouteMechanism) : CompCertRouteScope :=
  match mechanism with
  | OrdinaryGameTransition
  | DefinedInBoundsStore
  | DefinedSameBlockAlias
  | DefinedInteriorPointerAccess
  | DefinedObjectSlotReuse
  | DefinedKnownFunctionRetarget => DefinedInternalClight
  | UnresolvedExternalCallEffect => ParameterizedClightExternal
  | OutOfBoundsLoad
  | OutOfBoundsStore
  | InvalidPointerDereference
  | InvalidFunctionPointerCall => StuckBeforeAClightSuccessor
  | ArbitraryInstructionJump
  | PostUndefinedBehaviorAssemblyContinuation
  | HardwareDmaOrInterruptWrite
  | SelfModifyingCode => RequiresMachineSemantics
  end.

Definition route_mechanism_scope_table :
    list (RouteMechanism * CompCertRouteScope) :=
  [ (OrdinaryGameTransition, DefinedInternalClight);
    (DefinedInBoundsStore, DefinedInternalClight);
    (DefinedSameBlockAlias, DefinedInternalClight);
    (DefinedInteriorPointerAccess, DefinedInternalClight);
    (DefinedObjectSlotReuse, DefinedInternalClight);
    (DefinedKnownFunctionRetarget, DefinedInternalClight);
    (UnresolvedExternalCallEffect, ParameterizedClightExternal);
    (OutOfBoundsLoad, StuckBeforeAClightSuccessor);
    (OutOfBoundsStore, StuckBeforeAClightSuccessor);
    (InvalidPointerDereference, StuckBeforeAClightSuccessor);
    (InvalidFunctionPointerCall, StuckBeforeAClightSuccessor);
    (ArbitraryInstructionJump, RequiresMachineSemantics);
    (PostUndefinedBehaviorAssemblyContinuation, RequiresMachineSemantics);
    (HardwareDmaOrInterruptWrite, RequiresMachineSemantics);
    (SelfModifyingCode, RequiresMachineSemantics) ].

Theorem route_mechanism_scope_table_checked :
  map (fun entry =>
    (fst entry, route_mechanism_scope (fst entry)))
    route_mechanism_scope_table = route_mechanism_scope_table.
Proof. reflexivity. Qed.

(** A successful CompCert load or store supplies the corresponding access
    proof.  Therefore an invalid access cannot be the successful state-changing
    event in a Clight route witness. *)
Theorem successful_compcert_load_requires_readable_access :
  forall memory chunk block offset value,
    Mem.load chunk memory block offset = Some value ->
    Mem.valid_access memory chunk block offset Readable.
Proof.
  intros memory chunk block offset value Hload.
  exact (Mem.load_valid_access memory chunk block offset value Hload).
Qed.

Theorem invalid_compcert_load_has_no_value :
  forall memory chunk block offset,
    ~ Mem.valid_access memory chunk block offset Readable ->
    forall value, Mem.load chunk memory block offset <> Some value.
Proof.
  intros memory chunk block offset Hinvalid value Hload.
  apply Hinvalid.
  exact
    (successful_compcert_load_requires_readable_access
      memory chunk block offset value Hload).
Qed.

Theorem successful_compcert_store_requires_writable_access :
  forall memory chunk block offset value after,
    Mem.store chunk memory block offset value = Some after ->
    Mem.valid_access memory chunk block offset Writable.
Proof.
  intros memory chunk block offset value after Hstore.
  exact
    (Mem.store_valid_access_3 chunk memory block offset value after Hstore).
Qed.

Theorem invalid_compcert_store_has_no_successor :
  forall memory chunk block offset value,
    ~ Mem.valid_access memory chunk block offset Writable ->
    forall after, Mem.store chunk memory block offset value <> Some after.
Proof.
  intros memory chunk block offset value Hinvalid after Hstore.
  apply Hinvalid.
  exact
    (successful_compcert_store_requires_writable_access
      memory chunk block offset value after Hstore).
Qed.

(** Every Clight transition into a [Callstate] resolves that function through
    the global environment.  A raw data pointer or arbitrary instruction
    address that is not a registered function cannot be the target of such a
    step.  A corrupted pointer to another *known* function is different: it
    remains a defined mechanism and must be analyzed rather than dismissed. *)
Theorem clight_call_target_must_be_a_registered_function :
  forall ge before trace definition arguments continuation memory,
    Clight.step2 ge before trace
      (Clight.Callstate definition arguments continuation memory) ->
    exists block, Genv.find_funct_ptr ge block = Some definition.
Proof.
  intros ge before trace definition arguments continuation memory Hstep.
  inversion Hstep; subst.
  exploit Genv.find_funct_inv; eauto.
  intros [block Hvalue]. subst.
  exists block.
  rewrite Genv.find_funct_find_funct_ptr in *.
  assumption.
Qed.

Corollary unregistered_definition_cannot_be_a_clight_call_target :
  forall (ge : Clight.genv) definition,
    (forall block, Genv.find_funct_ptr ge block <> Some definition) ->
    forall before trace arguments continuation memory,
      ~ Clight.step2 ge before trace
          (Clight.Callstate definition arguments continuation memory).
Proof.
  intros ge definition Hunregistered before trace arguments continuation
    memory Hstep.
  destruct (clight_call_target_must_be_a_registered_function
    ge before trace definition arguments continuation memory Hstep)
    as [block Hregistered].
  exact (Hunregistered block Hregistered).
Qed.

(** Route-level applications of the generic semantic classes.  These entries
    are deliberately about *mechanisms*, not verdicts on the retail binary. *)
Inductive AtlasScopeCase : Type :=
| Rank1CollisionOwnerSchedulerLifecycle
| Rank1DefinedAliasInstaller
| Rank1OutOfBoundsInstaller
| Rank1ExternalInstaller
| Rank2StockGraphicsOrNegativeDepth
| Rank2DefinedSameSlotOrKnownBehaviorRetarget
| Rank2OutOfBoundsTailOverwrite
| Rank2ExternalInstaller
| Rank2AceOrDmaInstaller
| Rank3DefinedPlatformDisplacementOrInstall
| Rank3OutOfBoundsPlatformInstall
| Rank3ExternalPlatformInstall
| GenericFalseCollisionOrHitboxMutation
| GenericPostUndefinedBehaviorExploit.

Definition atlas_scope_case_mechanism
    (route_case : AtlasScopeCase) : RouteMechanism :=
  match route_case with
  | Rank1CollisionOwnerSchedulerLifecycle => OrdinaryGameTransition
  | Rank1DefinedAliasInstaller => DefinedSameBlockAlias
  | Rank1OutOfBoundsInstaller => OutOfBoundsStore
  | Rank1ExternalInstaller => UnresolvedExternalCallEffect
  | Rank2StockGraphicsOrNegativeDepth => OrdinaryGameTransition
  | Rank2DefinedSameSlotOrKnownBehaviorRetarget => DefinedKnownFunctionRetarget
  | Rank2OutOfBoundsTailOverwrite => OutOfBoundsStore
  | Rank2ExternalInstaller => UnresolvedExternalCallEffect
  | Rank2AceOrDmaInstaller => HardwareDmaOrInterruptWrite
  | Rank3DefinedPlatformDisplacementOrInstall => DefinedInBoundsStore
  | Rank3OutOfBoundsPlatformInstall => OutOfBoundsStore
  | Rank3ExternalPlatformInstall => UnresolvedExternalCallEffect
  | GenericFalseCollisionOrHitboxMutation => DefinedInBoundsStore
  | GenericPostUndefinedBehaviorExploit =>
      PostUndefinedBehaviorAssemblyContinuation
  end.

Definition atlas_scope_case_scope (route_case : AtlasScopeCase) :
    CompCertRouteScope :=
  route_mechanism_scope (atlas_scope_case_mechanism route_case).

Definition atlas_scope_table :
    list (AtlasScopeCase * CompCertRouteScope) :=
  [ (Rank1CollisionOwnerSchedulerLifecycle, DefinedInternalClight);
    (Rank1DefinedAliasInstaller, DefinedInternalClight);
    (Rank1OutOfBoundsInstaller, StuckBeforeAClightSuccessor);
    (Rank1ExternalInstaller, ParameterizedClightExternal);
    (Rank2StockGraphicsOrNegativeDepth, DefinedInternalClight);
    (Rank2DefinedSameSlotOrKnownBehaviorRetarget, DefinedInternalClight);
    (Rank2OutOfBoundsTailOverwrite, StuckBeforeAClightSuccessor);
    (Rank2ExternalInstaller, ParameterizedClightExternal);
    (Rank2AceOrDmaInstaller, RequiresMachineSemantics);
    (Rank3DefinedPlatformDisplacementOrInstall, DefinedInternalClight);
    (Rank3OutOfBoundsPlatformInstall, StuckBeforeAClightSuccessor);
    (Rank3ExternalPlatformInstall, ParameterizedClightExternal);
    (GenericFalseCollisionOrHitboxMutation, DefinedInternalClight);
    (GenericPostUndefinedBehaviorExploit, RequiresMachineSemantics) ].

Theorem atlas_scope_table_checked :
  map (fun entry =>
    (fst entry, atlas_scope_case_scope (fst entry)))
    atlas_scope_table = atlas_scope_table.
Proof. reflexivity. Qed.

Inductive RouteResearchDisposition : Type :=
| AnalyzeInCurrentClight
| SpecifyExternalEffectFirst
| DeferUntilMachineModelExists.

Definition scope_research_disposition
    (scope : CompCertRouteScope) : RouteResearchDisposition :=
  match scope with
  | DefinedInternalClight => AnalyzeInCurrentClight
  | ParameterizedClightExternal => SpecifyExternalEffectFirst
  | StuckBeforeAClightSuccessor
  | RequiresMachineSemantics => DeferUntilMachineModelExists
  end.

Theorem current_focus_excludes_oob_ace_and_dma_but_not_defined_aliases :
  scope_research_disposition
      (route_mechanism_scope DefinedSameBlockAlias) =
      AnalyzeInCurrentClight /\
  scope_research_disposition
      (route_mechanism_scope DefinedKnownFunctionRetarget) =
      AnalyzeInCurrentClight /\
  scope_research_disposition
      (route_mechanism_scope UnresolvedExternalCallEffect) =
      SpecifyExternalEffectFirst /\
  scope_research_disposition
      (route_mechanism_scope OutOfBoundsStore) =
      DeferUntilMachineModelExists /\
  scope_research_disposition
      (route_mechanism_scope ArbitraryInstructionJump) =
      DeferUntilMachineModelExists /\
  scope_research_disposition
      (route_mechanism_scope HardwareDmaOrInterruptWrite) =
      DeferUntilMachineModelExists.
Proof. repeat split; reflexivity. Qed.

(** This proposition is the semantic, rather than classificatory, part of the
    boundary.  It is phrased only in terms of CompCert's actual memory and
    Clight transition relations. *)
Definition compcert_internal_step_boundary : Prop :=
  (forall memory chunk block offset value,
    Mem.load chunk memory block offset = Some value ->
    Mem.valid_access memory chunk block offset Readable) /\
  (forall memory chunk block offset value after,
    Mem.store chunk memory block offset value = Some after ->
    Mem.valid_access memory chunk block offset Writable) /\
  (forall ge before trace definition arguments continuation memory,
    Clight.step2 ge before trace
      (Clight.Callstate definition arguments continuation memory) ->
    exists block, Genv.find_funct_ptr ge block = Some definition).

Theorem compcert_internal_step_boundary_checked :
  compcert_internal_step_boundary.
Proof.
  unfold compcert_internal_step_boundary.
  split.
  - exact successful_compcert_load_requires_readable_access.
  - split.
    + exact successful_compcert_store_requires_writable_access.
    + exact clight_call_target_must_be_a_registered_function.
Qed.

Definition compcert_execution_scope_boundary_holds : Prop :=
  compcert_internal_step_boundary /\
  (map (fun entry =>
     (fst entry, route_mechanism_scope (fst entry)))
     route_mechanism_scope_table = route_mechanism_scope_table) /\
  (map (fun entry =>
     (fst entry, atlas_scope_case_scope (fst entry)))
     atlas_scope_table = atlas_scope_table) /\
  (scope_research_disposition
      (route_mechanism_scope DefinedSameBlockAlias) =
      AnalyzeInCurrentClight /\
   scope_research_disposition
      (route_mechanism_scope DefinedKnownFunctionRetarget) =
      AnalyzeInCurrentClight /\
   scope_research_disposition
      (route_mechanism_scope UnresolvedExternalCallEffect) =
      SpecifyExternalEffectFirst /\
   scope_research_disposition
      (route_mechanism_scope OutOfBoundsStore) =
      DeferUntilMachineModelExists /\
   scope_research_disposition
      (route_mechanism_scope ArbitraryInstructionJump) =
      DeferUntilMachineModelExists /\
   scope_research_disposition
      (route_mechanism_scope HardwareDmaOrInterruptWrite) =
      DeferUntilMachineModelExists).

Theorem compcert_execution_scope_boundary_checked :
  compcert_execution_scope_boundary_holds.
Proof.
  unfold compcert_execution_scope_boundary_holds.
  split.
  - exact compcert_internal_step_boundary_checked.
  - split.
    + exact route_mechanism_scope_table_checked.
    + split.
      * exact atlas_scope_table_checked.
      * exact current_focus_excludes_oob_ace_and_dma_but_not_defined_aliases.
Qed.
