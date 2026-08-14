(**
  A bounded owner/slot/epoch model for the stale-surface lifecycle window in
  SSL Area 1.

  The generated source has a subtle two-frame shape which is easy to hide by
  talking only about the lifetime of the dynamic-surface list:

    - the pyramid-top behavior calls its native loop and then the collision
      loader in the same behavior-script iteration;
    - the explosion callback can deactivate the top, so that collision loader
      can still install surfaces carrying the top's raw Object address;
    - [unload_deactivated_objects] precedes the final
      [update_mario_platform] query; and
    - on the following frame [clear_dynamic_surfaces] precedes terrain
      allocation, which precedes cached platform application.

  Consequently, clearing the surface list does not by itself clear the
  separately cached [gMarioPlatform] address.  The small executable model
  below records both the inactive-same-epoch and fresh-slot-reuse cases and
  gives an explicit countermodel to that invalid inference.  It is not a
  claim that the required floor query, free-list alignment, or upper-warp
  geometry is reachable from the clean default start.  The final theorems
  show precisely why slot reuse alone does not solve the stock-top geometry:
  a route-capable run must instead escape canonical top capture or raw-Object
  continuity between that capture and the following collision pass.
*)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_obj_behaviors
  jp_behavior_data jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import
  ASTFacts GameTypes Area1PhaseSplit
  Area1QueryScheduleClosure Area1SurfaceOwnerSyntax.

Import ListNotations.
Local Open Scope Z_scope.

Module A1SEL_USBD := us_behavior_data.
Module A1SEL_USOB := us_obj_behaviors.
Module A1SEL_JPBD := jp_behavior_data.
Module A1SEL_JPOB := jp_obj_behaviors.

(** Generated-AST anchors for the candidate lifecycle.  Initializer order is
    only behavior-script data until the interpreter is executed; native call
    occurrence and field assignment are likewise source-shape facts. *)
Definition area1_top_deactivate_then_reload_source_claim : Prop :=
  initializer_addrof_subsequenceb
    [A1SEL_USBD._bhv_pyramid_top_loop;
     A1SEL_USBD._load_object_collision_model]
    (gvar_init A1SEL_USBD.v_bhvPyramidTop) = true /\
  calls_ident_s A1SEL_USOB._bhv_pyramid_top_explode
    (fn_body A1SEL_USOB.f_bhv_pyramid_top_loop) = true /\
  assigns_field_named_s A1SEL_USOB._activeFlags
    (fn_body A1SEL_USOB.f_bhv_pyramid_top_explode) = true /\
  initializer_addrof_subsequenceb
    [A1SEL_JPBD._bhv_pyramid_top_loop;
     A1SEL_JPBD._load_object_collision_model]
    (gvar_init A1SEL_JPBD.v_bhvPyramidTop) = true /\
  calls_ident_s A1SEL_JPOB._bhv_pyramid_top_explode
    (fn_body A1SEL_JPOB.f_bhv_pyramid_top_loop) = true /\
  assigns_field_named_s A1SEL_JPOB._activeFlags
    (fn_body A1SEL_JPOB.f_bhv_pyramid_top_explode) = true.

Theorem area1_top_deactivate_then_reload_source_checked :
  area1_top_deactivate_then_reload_source_claim.
Proof. vm_compute. repeat split. Qed.

(** This combined receipt deliberately remains syntactic.  In particular it
    does not turn the floor selected by [find_floor] into a linked execution
    witness, prove that the same surface temporary survives aliases, or prove
    which free-list slot a later allocation consumes. *)
Definition area1_surface_epoch_lifecycle_source_claim : Prop :=
  area1_top_deactivate_then_reload_source_claim /\
  USDynamicSurfaceOwnerSourceClaim /\
  JPDynamicSurfaceOwnerSourceClaim /\
  area1_active_warp_schedule_source_claim /\
  area1_final_query_overwrite_source_claim.

Theorem area1_surface_epoch_lifecycle_source_checked :
  area1_surface_epoch_lifecycle_source_claim.
Proof.
  unfold area1_surface_epoch_lifecycle_source_claim.
  split; [exact area1_top_deactivate_then_reload_source_checked |].
  split; [exact us_dynamic_surface_owner_source_checked |].
  split; [exact jp_dynamic_surface_owner_source_checked |].
  split; [exact area1_active_warp_schedule_source_checked |].
  exact area1_final_query_overwrite_source_checked.
Qed.

(** A payload is the allocation identity currently resident at one physical
    pool address plus the Y displacement that a raw dereference would read.
    The model intentionally separates allocation/activity flags from resident
    bytes: retail [unload_object] returns a slot to the free list but a raw
    pointer can still address the old bytes before reuse. *)
Record LifecyclePayload : Type := {
  lifecycle_payload_owner : ObjectRef;
  lifecycle_payload_delta_y : Z
}.

Record LifecycleSlotCell : Type := {
  lifecycle_cell_payload : LifecyclePayload;
  lifecycle_cell_allocated : bool;
  lifecycle_cell_active : bool
}.

Record SurfaceEpochLifecycleState : Type := {
  lifecycle_slot_cell : LifecycleSlotCell;
  lifecycle_dynamic_surface_owner : option RawPlatformPointer;
  lifecycle_cached_platform : option RawPlatformPointer;
  lifecycle_state_y : Z;
  lifecycle_object_y : Z
}.

Definition lifecycle_pointer_of_payload
    (payload : LifecyclePayload) : RawPlatformPointer :=
  {| platform_slot := object_slot (lifecycle_payload_owner payload);
     platform_captured_epoch :=
       object_epoch (lifecycle_payload_owner payload) |}.

Definition begin_surface_epoch_window
    (payload : LifecyclePayload) (initial_y : Z) :
    SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell :=
       {| lifecycle_cell_payload := payload;
          lifecycle_cell_allocated := true;
          lifecycle_cell_active := true |};
     lifecycle_dynamic_surface_owner := None;
     lifecycle_cached_platform := None;
     lifecycle_state_y := initial_y;
     lifecycle_object_y := initial_y |}.

Definition deactivate_resident_owner
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell :=
       {| lifecycle_cell_payload :=
            lifecycle_cell_payload (lifecycle_slot_cell state);
          lifecycle_cell_allocated :=
            lifecycle_cell_allocated (lifecycle_slot_cell state);
          lifecycle_cell_active := false |};
     lifecycle_dynamic_surface_owner :=
       lifecycle_dynamic_surface_owner state;
     lifecycle_cached_platform := lifecycle_cached_platform state;
     lifecycle_state_y := lifecycle_state_y state;
     lifecycle_object_y := lifecycle_object_y state |}.

(** Mirrors the important feature of the top script: surface installation can
    follow the native callback even when that callback set [activeFlags] to
    zero.  The surface stores the resident Object address and ghost epoch. *)
Definition load_surface_for_resident_owner
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell := lifecycle_slot_cell state;
     lifecycle_dynamic_surface_owner :=
       Some
         (lifecycle_pointer_of_payload
           (lifecycle_cell_payload (lifecycle_slot_cell state)));
     lifecycle_cached_platform := lifecycle_cached_platform state;
     lifecycle_state_y := lifecycle_state_y state;
     lifecycle_object_y := lifecycle_object_y state |}.

Definition unload_resident_owner
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell :=
       {| lifecycle_cell_payload :=
            lifecycle_cell_payload (lifecycle_slot_cell state);
          lifecycle_cell_allocated := false;
          lifecycle_cell_active := false |};
     lifecycle_dynamic_surface_owner :=
       lifecycle_dynamic_surface_owner state;
     lifecycle_cached_platform := lifecycle_cached_platform state;
     lifecycle_state_y := lifecycle_state_y state;
     lifecycle_object_y := lifecycle_object_y state |}.

(** Conditional successful final query: the geometry search has selected the
    modeled dynamic surface.  Proving that selection from clean play is an
    explicit premise outside this bounded lifecycle model. *)
Definition final_query_selects_dynamic_surface
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell := lifecycle_slot_cell state;
     lifecycle_dynamic_surface_owner :=
       lifecycle_dynamic_surface_owner state;
     lifecycle_cached_platform := lifecycle_dynamic_surface_owner state;
     lifecycle_state_y := lifecycle_state_y state;
     lifecycle_object_y := lifecycle_object_y state |}.

(** Crucially, surface clearing does not mutate the cached raw pointer. *)
Definition clear_dynamic_surface_window
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell := lifecycle_slot_cell state;
     lifecycle_dynamic_surface_owner := None;
     lifecycle_cached_platform := lifecycle_cached_platform state;
     lifecycle_state_y := lifecycle_state_y state;
     lifecycle_object_y := lifecycle_object_y state |}.

Definition reuse_lifecycle_slot
    (replacement : LifecyclePayload)
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  {| lifecycle_slot_cell :=
       {| lifecycle_cell_payload := replacement;
          lifecycle_cell_allocated := true;
          lifecycle_cell_active := true |};
     lifecycle_dynamic_surface_owner :=
       lifecycle_dynamic_surface_owner state;
     lifecycle_cached_platform := lifecycle_cached_platform state;
     lifecycle_state_y := lifecycle_state_y state;
     lifecycle_object_y := lifecycle_object_y state |}.

(** Raw-address application checks no allocation epoch.  As in the retail
    phase split, this operation writes State and leaves raw Object untouched. *)
Definition apply_cached_lifecycle_payload
    (state : SurfaceEpochLifecycleState) : SurfaceEpochLifecycleState :=
  match lifecycle_cached_platform state with
  | None => state
  | Some pointer =>
      let payload := lifecycle_cell_payload (lifecycle_slot_cell state) in
      if Nat.eqb (platform_slot pointer)
           (object_slot (lifecycle_payload_owner payload)) then
        {| lifecycle_slot_cell := lifecycle_slot_cell state;
           lifecycle_dynamic_surface_owner :=
             lifecycle_dynamic_surface_owner state;
           lifecycle_cached_platform := lifecycle_cached_platform state;
           lifecycle_state_y :=
             lifecycle_state_y state + lifecycle_payload_delta_y payload;
           lifecycle_object_y := lifecycle_object_y state |}
      else state
  end.

Definition freed_surface_inactive_apply
    (old_payload : LifecyclePayload) (initial_y : Z) :=
  apply_cached_lifecycle_payload
    (clear_dynamic_surface_window
      (final_query_selects_dynamic_surface
        (unload_resident_owner
          (load_surface_for_resident_owner
            (deactivate_resident_owner
              (begin_surface_epoch_window old_payload initial_y)))))).

(** This composition is a *conditional abstract trace*.  The generated-AST
    receipts above justify the relevant source order, but this definition
    supplies rather than derives all successful transitions: top
    deactivation, post-callback surface installation, unload, floor-query
    selection, surface clear, same-slot allocation, and cached application.
    It therefore exposes a mechanism and proof obligation, not a retail
    reachability certificate. *)
Definition freed_surface_reuse_apply
    (old_payload replacement : LifecyclePayload) (initial_y : Z) :=
  apply_cached_lifecycle_payload
    (reuse_lifecycle_slot replacement
      (clear_dynamic_surface_window
        (final_query_selects_dynamic_surface
          (unload_resident_owner
            (load_surface_for_resident_owner
              (deactivate_resident_owner
                (begin_surface_epoch_window old_payload initial_y))))))).

Theorem surface_clear_preserves_the_separately_cached_pointer :
  forall state,
    lifecycle_cached_platform (clear_dynamic_surface_window state) =
      lifecycle_cached_platform state.
Proof. reflexivity. Qed.

Theorem freed_surface_inactive_apply_exact :
  forall old_payload initial_y,
    let after := freed_surface_inactive_apply old_payload initial_y in
    lifecycle_dynamic_surface_owner after = None /\
    lifecycle_cached_platform after =
      Some (lifecycle_pointer_of_payload old_payload) /\
    lifecycle_cell_allocated (lifecycle_slot_cell after) = false /\
    lifecycle_cell_active (lifecycle_slot_cell after) = false /\
    lifecycle_state_y after =
      initial_y + lifecycle_payload_delta_y old_payload /\
    lifecycle_object_y after = initial_y.
Proof.
  intros old_payload initial_y.
  unfold freed_surface_inactive_apply, apply_cached_lifecycle_payload.
  cbn.
  rewrite Nat.eqb_refl.
  repeat split; reflexivity.
Qed.

(** Inactivity or removal from the free-list ownership relation does not make
    the resident payload harmless.  If the bytes still encode any nonzero
    displacement, applying the separately cached raw pointer creates a
    State/Object split even without allocating a replacement epoch.  This is
    the payload fate supported by the authenticated JP allocation-depth
    evidence; proving the concrete exploded-top delta and its preservation up
    to the linked apply remains a separate execution obligation. *)
Theorem inactive_same_epoch_nonzero_payload_opens_state_object_split :
  forall old_payload initial_y,
    lifecycle_payload_delta_y old_payload <> 0 ->
    let after := freed_surface_inactive_apply old_payload initial_y in
    lifecycle_state_y after <> lifecycle_object_y after.
Proof.
  intros old_payload initial_y Hnonzero.
  pose proof (freed_surface_inactive_apply_exact old_payload initial_y) as H.
  cbn zeta in H |- *.
  destruct H as (_ & _ & _ & _ & Hstate & Hobject).
  rewrite Hstate, Hobject.
  lia.
Qed.

Theorem freed_surface_reuse_apply_exact :
  forall old_payload replacement initial_y,
    object_slot (lifecycle_payload_owner old_payload) =
      object_slot (lifecycle_payload_owner replacement) ->
    let after :=
      freed_surface_reuse_apply old_payload replacement initial_y in
    lifecycle_dynamic_surface_owner after = None /\
    lifecycle_cached_platform after =
      Some (lifecycle_pointer_of_payload old_payload) /\
    lifecycle_cell_payload (lifecycle_slot_cell after) = replacement /\
    lifecycle_state_y after =
      initial_y + lifecycle_payload_delta_y replacement /\
    lifecycle_object_y after = initial_y.
Proof.
  intros old_payload replacement initial_y Hslot.
  unfold freed_surface_reuse_apply, apply_cached_lifecycle_payload.
  cbn.
  assert (Hslotb :
    Nat.eqb
      (object_slot (lifecycle_payload_owner old_payload))
      (object_slot (lifecycle_payload_owner replacement)) = true).
  { apply Nat.eqb_eq. exact Hslot. }
  rewrite Hslotb.
  repeat split; reflexivity.
Qed.

Theorem freed_surface_reuse_opens_state_object_split :
  forall old_payload replacement initial_y,
    object_slot (lifecycle_payload_owner old_payload) =
      object_slot (lifecycle_payload_owner replacement) ->
    lifecycle_payload_delta_y replacement <> 0 ->
    lifecycle_state_y
      (freed_surface_reuse_apply old_payload replacement initial_y) <>
    lifecycle_object_y
      (freed_surface_reuse_apply old_payload replacement initial_y).
Proof.
  intros old_payload replacement initial_y Hslot Hdelta.
  unfold freed_surface_reuse_apply, apply_cached_lifecycle_payload.
  cbn.
  assert (Hslotb :
    Nat.eqb
      (object_slot (lifecycle_payload_owner old_payload))
      (object_slot (lifecycle_payload_owner replacement)) = true).
  { apply Nat.eqb_eq. exact Hslot. }
  rewrite Hslotb.
  cbn.
  intro Hequal.
  apply Hdelta.
  lia.
Qed.

(** The query-owner token names the allocation whose surface supplied the raw
    pointer.  The apply-payload token names the allocation whose bytes occupy
    that address when platform application later dereferences it. *)
Definition lifecycle_query_owner_token
    (pointer : RawPlatformPointer) : ObjectRef :=
  captured_platform_ref pointer.

Definition lifecycle_apply_payload_token
    (state : SurfaceEpochLifecycleState) : ObjectRef :=
  lifecycle_payload_owner
    (lifecycle_cell_payload (lifecycle_slot_cell state)).

(** Exact four-way classification at a non-null cached-pointer dereference.

    The first three constructors are the sound same-address, monotone-epoch
    fates.  The last constructor is intentionally explicit: a different slot
    or a backwards epoch means that the projected payload is invalid/aliased,
    rather than silently being called a legitimate replacement. *)
Inductive CachedApplyPayloadFate
    (state : SurfaceEpochLifecycleState) : Prop :=
| PayloadFromLiveQueryOwner : forall pointer,
    lifecycle_cached_platform state = Some pointer ->
    object_ref_equal
      (lifecycle_apply_payload_token state)
      (lifecycle_query_owner_token pointer) ->
    lifecycle_cell_allocated (lifecycle_slot_cell state) = true ->
    lifecycle_cell_active (lifecycle_slot_cell state) = true ->
    CachedApplyPayloadFate state
| PayloadFromInactiveOrFreedQueryOwner : forall pointer,
    lifecycle_cached_platform state = Some pointer ->
    object_ref_equal
      (lifecycle_apply_payload_token state)
      (lifecycle_query_owner_token pointer) ->
    (lifecycle_cell_allocated (lifecycle_slot_cell state) = false \/
     lifecycle_cell_active (lifecycle_slot_cell state) = false) ->
    CachedApplyPayloadFate state
| PayloadFromFreshSameSlotEpoch : forall pointer,
    lifecycle_cached_platform state = Some pointer ->
    object_slot
      (lifecycle_apply_payload_token state) =
      object_slot (lifecycle_query_owner_token pointer) ->
    (object_epoch (lifecycle_query_owner_token pointer) <
      object_epoch (lifecycle_apply_payload_token state))%nat ->
    CachedApplyPayloadFate state
| PayloadFromInvalidOrAliasedCell : forall pointer,
    lifecycle_cached_platform state = Some pointer ->
    (object_slot (lifecycle_apply_payload_token state) <>
       object_slot (lifecycle_query_owner_token pointer) \/
     (object_epoch (lifecycle_apply_payload_token state) <
       object_epoch (lifecycle_query_owner_token pointer))%nat) ->
    CachedApplyPayloadFate state.

Theorem cached_apply_payload_fate_exhaustive :
  forall state pointer,
    lifecycle_cached_platform state = Some pointer ->
    CachedApplyPayloadFate state.
Proof.
  intros state pointer Hpointer.
  destruct (Nat.eq_dec
    (object_slot (lifecycle_apply_payload_token state))
    (object_slot (lifecycle_query_owner_token pointer)))
    as [Hslot | Hslot].
  - destruct (Nat.lt_trichotomy
      (object_epoch (lifecycle_apply_payload_token state))
      (object_epoch (lifecycle_query_owner_token pointer)))
      as [Hbackwards | [Hepoch | Hfresh]].
    + econstructor 4 with (pointer := pointer).
      * exact Hpointer.
      * right. exact Hbackwards.
    + destruct (lifecycle_cell_allocated (lifecycle_slot_cell state))
        eqn:Hallocated;
      destruct (lifecycle_cell_active (lifecycle_slot_cell state))
        eqn:Hactive.
      * econstructor 1 with (pointer := pointer).
        -- exact Hpointer.
        -- split; assumption.
        -- exact Hallocated.
        -- exact Hactive.
      * econstructor 2 with (pointer := pointer).
        -- exact Hpointer.
        -- split; assumption.
        -- right. exact Hactive.
      * econstructor 2 with (pointer := pointer).
        -- exact Hpointer.
        -- split; assumption.
        -- left. exact Hallocated.
      * econstructor 2 with (pointer := pointer).
        -- exact Hpointer.
        -- split; assumption.
        -- left. exact Hallocated.
    + econstructor 3 with (pointer := pointer).
      * exact Hpointer.
      * exact Hslot.
      * exact Hfresh.
  - econstructor 4 with (pointer := pointer).
    + exact Hpointer.
    + left. exact Hslot.
Qed.

(** A small closed countermodel.  Numbers are abstract pool/epoch/Y values,
    not claimed retail observations.  It starts with a null cached pointer,
    captures epoch 4 after unload, clears the surface list, reuses the same
    slot at epoch 5, and applies +400 to State while Object remains at 1000. *)
Definition lifecycle_counterexample_old : LifecyclePayload :=
  {| lifecycle_payload_owner :=
       {| object_slot := 17%nat; object_epoch := 4%nat |};
     lifecycle_payload_delta_y := 5 |}.

Definition lifecycle_counterexample_replacement : LifecyclePayload :=
  {| lifecycle_payload_owner :=
       {| object_slot := 17%nat; object_epoch := 5%nat |};
     lifecycle_payload_delta_y := 400 |}.

Definition lifecycle_counterexample : SurfaceEpochLifecycleState :=
  freed_surface_reuse_apply
    lifecycle_counterexample_old lifecycle_counterexample_replacement 1000.

Theorem lifecycle_counterexample_checked :
  lifecycle_dynamic_surface_owner lifecycle_counterexample = None /\
  lifecycle_cached_platform lifecycle_counterexample =
    Some (lifecycle_pointer_of_payload lifecycle_counterexample_old) /\
  platform_captured_epoch
    (lifecycle_pointer_of_payload lifecycle_counterexample_old) = 4%nat /\
  object_epoch
    (lifecycle_payload_owner
      (lifecycle_cell_payload
        (lifecycle_slot_cell lifecycle_counterexample))) = 5%nat /\
  lifecycle_state_y lifecycle_counterexample = 1400 /\
  lifecycle_object_y lifecycle_counterexample = 1000 /\
  lifecycle_state_y lifecycle_counterexample <>
    lifecycle_object_y lifecycle_counterexample.
Proof. vm_compute. repeat split; try reflexivity; lia. Qed.

Theorem lifecycle_counterexample_has_fresh_replacement_payload_fate :
  CachedApplyPayloadFate lifecycle_counterexample.
Proof.
  apply PayloadFromFreshSameSlotEpoch with
    (pointer := lifecycle_pointer_of_payload lifecycle_counterexample_old).
  - exact (proj1 (proj2 lifecycle_counterexample_checked)).
  - vm_compute. reflexivity.
  - vm_compute. lia.
Qed.

Theorem lifecycle_counterexample_separates_query_and_apply_owner_tokens :
  lifecycle_query_owner_token
    (lifecycle_pointer_of_payload lifecycle_counterexample_old) =
      lifecycle_payload_owner lifecycle_counterexample_old /\
  lifecycle_apply_payload_token lifecycle_counterexample =
      lifecycle_payload_owner lifecycle_counterexample_replacement /\
  ~ object_ref_equal
      (lifecycle_apply_payload_token lifecycle_counterexample)
      (lifecycle_query_owner_token
        (lifecycle_pointer_of_payload lifecycle_counterexample_old)).
Proof. vm_compute. repeat split; try reflexivity; lia. Qed.

(** These are two independently checked abstract witnesses: the schedule
    witness has a post-copy query/collision discrepancy, and the lifecycle
    witness reads a fresh payload through an old same-slot pointer.  Their
    conjunction does not identify their samples, owner, pointer, memory, or
    timing, and therefore does not prove that the mechanisms are mutually
    compatible in one execution.  A coupled linked chronology remains the
    counterexample search target. *)
Theorem independent_different_sample_and_fresh_reuse_witnesses_checked :
  schedule_upper_warp_contact
    (schedule_collision_object
      arbitrary_post_copy_discrepancy_countermodel) /\
  horizontal_position_differs
    (schedule_final_query arbitrary_post_copy_discrepancy_countermodel)
    (schedule_collision_object arbitrary_post_copy_discrepancy_countermodel) /\
  post_copy_sample_discrepancy
    arbitrary_post_copy_discrepancy_countermodel /\
  CachedApplyPayloadFate lifecycle_counterexample /\
  lifecycle_state_y lifecycle_counterexample <>
    lifecycle_object_y lifecycle_counterexample.
Proof.
  pose proof
    arbitrary_post_copy_discrepancy_countermodel_is_the_open_branch as
    Hsample.
  split.
  - exact (proj1 Hsample).
  - split.
    + exact (proj1 (proj2 Hsample)).
    + split.
      * exact (proj2 (proj2 Hsample)).
      * split.
        -- exact lifecycle_counterexample_has_fresh_replacement_payload_fate.
        -- exact (proj2 (proj2 (proj2 (proj2 (proj2 (proj2
             lifecycle_counterexample_checked)))))).
Qed.

(** Slot fate changes the payload read by platform application; it does not
    change where the preceding final query had to find the captured surface,
    nor the raw Object position consumed by the following collision pass. *)
Theorem route_relevant_top_lifecycle_requires_a_geometry_escape :
  forall boundary,
    route_relevant_area1_phase_split boundary ->
    (captured_stock_top_epoch boundary ->
      ~ collision_preserves_prior_object_sample boundary) /\
    (collision_preserves_prior_object_sample boundary ->
      ~ captured_stock_top_epoch boundary).
Proof.
  intros boundary Hroute.
  split.
  - intros Hcapture Hpreserved.
    eapply
      (captured_top_epoch_cannot_realize_route_relevant_phase_split
        boundary Hcapture Hpreserved).
    exact Hroute.
  - intros Hpreserved Hcapture.
    eapply
      (captured_top_epoch_cannot_realize_route_relevant_phase_split
        boundary Hcapture Hpreserved).
    exact Hroute.
Qed.

Theorem every_cached_payload_fate_still_needs_a_geometry_escape :
  forall boundary state,
    CachedApplyPayloadFate state ->
    captured_stock_top_epoch boundary ->
    collision_preserves_prior_object_sample boundary ->
    ~ route_relevant_area1_phase_split boundary.
Proof.
  intros boundary state _ Hcapture Hpreserved.
  exact
    (captured_top_epoch_cannot_realize_route_relevant_phase_split
      boundary Hcapture Hpreserved).
Qed.

(** Assumption-audit target: source receipts, executable countermodel, exact
    lifecycle trichotomy, and the remaining geometry escape classification. *)
Theorem area1_surface_epoch_lifecycle_boundary_checked :
  area1_surface_epoch_lifecycle_source_claim /\
  CachedApplyPayloadFate lifecycle_counterexample /\
  ~ object_ref_equal
      (lifecycle_apply_payload_token lifecycle_counterexample)
      (lifecycle_query_owner_token
        (lifecycle_pointer_of_payload lifecycle_counterexample_old)) /\
  lifecycle_state_y lifecycle_counterexample <>
    lifecycle_object_y lifecycle_counterexample /\
  (forall boundary,
    route_relevant_area1_phase_split boundary ->
    (captured_stock_top_epoch boundary ->
      ~ collision_preserves_prior_object_sample boundary) /\
    (collision_preserves_prior_object_sample boundary ->
      ~ captured_stock_top_epoch boundary)).
Proof.
  split; [exact area1_surface_epoch_lifecycle_source_checked |].
  split;
    [exact lifecycle_counterexample_has_fresh_replacement_payload_fate |].
  split.
  - exact (proj2 (proj2
      lifecycle_counterexample_separates_query_and_apply_owner_tokens)).
  - split.
    + exact (proj2 (proj2 (proj2 (proj2 (proj2 (proj2
      lifecycle_counterexample_checked)))))).
    + exact route_relevant_top_lifecycle_requires_a_geometry_escape.
Qed.
