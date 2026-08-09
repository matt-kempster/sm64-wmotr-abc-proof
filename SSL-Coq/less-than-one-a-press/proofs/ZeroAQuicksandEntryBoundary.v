(** Zero-A reachability boundary for the negative-quicksand candidate.

    The prepared retail fixture used by the quicksand experiment starts in a
    late [ACT_LONG_JUMP_LAND] frame.  This file answers three narrower
    questions without treating that fixture as reachable:

    - neither the abstract clean pyramid-entry contract nor either concrete
      entry-memory postcondition starts in the long-jump cycle;
    - among the nine stock landing descriptors, only the long-jump descriptor
      permits a landing-body timer capable of making a nonnegative depth
      negative; and
    - across all 38 generated US and JP translation units, the only direct
      ordinary constructor of [ACT_LONG_JUMP] is the A-edge branch in
      [act_crouch_slide], while the only expression which passes
      [ACT_LONG_JUMP_LAND] to [common_air_action_step] is [act_long_jump].

    These are admission-free clean-boundary and generated-source facts.  They
    disprove an ordinary source-level zero-A prehistory for the injected
    fixture.  They do not yet exclude a corrupt action/timer, a mutable
    landing-descriptor overwrite, an aliased or out-of-bounds store, an
    indirect-call retarget, or an external memory effect in linked retail
    execution. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_mario us_mario_actions_airborne us_mario_actions_moving us_mario_step
  jp_mario jp_mario_actions_airborne jp_mario_actions_moving jp_mario_step.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ActionDepthAliasCensus CleanEntry EntryMemory GameTypes
  LongJumpProvenanceBoundary NormalizedClightPrograms
  OrdinaryArea1EntryMemory JPQuicksandDepth.

Import ListNotations.
Local Open Scope Z_scope.

Module ZA_USMario := us_mario.
Module ZA_USAir := us_mario_actions_airborne.
Module ZA_USMove := us_mario_actions_moving.
Module ZA_USStep := us_mario_step.
Module ZA_JPMario := jp_mario.
Module ZA_JPAir := jp_mario_actions_airborne.
Module ZA_JPMove := jp_mario_actions_moving.
Module ZA_JPStep := jp_mario_step.

Definition zero_a_long_jump : Z := 50333832.      (* 0x03000888 *)
Definition zero_a_long_jump_land : Z := 1145.     (* 0x00000479 *)

(** * The clean interval cannot start in the prepared fixture *)

Theorem clean_pyramid_entry_action_excludes_long_jump_cycle :
  forall state,
    CleanPyramidEntry state ->
    mario_action (state_mario_kinematics state) = airborne_warp_action /\
    mario_action (state_mario_kinematics state) <>
      Int.repr zero_a_long_jump /\
    mario_action (state_mario_kinematics state) <>
      Int.repr zero_a_long_jump_land.
Proof.
  intros state Hclean.
  rewrite (clean_current_kinematics state Hclean).
  pose proof (clean_entry_snapshot state Hclean) as Hsnapshot.
  unfold entry_snapshot_for in Hsnapshot.
  destruct Hsnapshot as (_ & _ & _ & _ & Haction & _).
  rewrite Haction.
  unfold airborne_warp_action, zero_a_long_jump, zero_a_long_jump_land.
  vm_compute. repeat split; congruence.
Qed.

Theorem retail_pyramid_entry_memory_excludes_prepared_fixture :
  forall memory state_block object_block controller_block
      state_base object_base controller_base x y z sample,
    RetailEntryMemoryPostcondition
      memory state_block object_block controller_block
      state_base object_base controller_base x y z sample ->
    load_at Mint32 memory state_block state_base mario_state_action_offset =
      Some (Vint airborne_entry_action) /\
    load_at Mint16unsigned memory state_block state_base
      mario_state_action_timer_offset = Some (Vint Int.zero) /\
    load_at Mfloat32 memory state_block state_base
      mario_state_quicksand_depth_offset =
      Some (Vsingle positive_f32_zero) /\
    airborne_entry_action <> Int.repr zero_a_long_jump /\
    airborne_entry_action <> Int.repr zero_a_long_jump_land.
Proof.
  intros memory state_block object_block controller_block
    state_base object_base controller_base x y z sample Hentry.
  repeat split.
  - exact (entry_action_value _ _ _ _ _ _ _ _ _ _ _ Hentry).
  - exact (entry_action_timer_zero _ _ _ _ _ _ _ _ _ _ _ Hentry).
  - exact (entry_quicksand_depth_zero _ _ _ _ _ _ _ _ _ _ _ Hentry).
  - unfold airborne_entry_action, zero_a_long_jump. vm_compute. congruence.
  - unfold airborne_entry_action, zero_a_long_jump_land.
    vm_compute. congruence.
Qed.

Theorem ordinary_area1_entry_memory_excludes_prepared_fixture :
  forall memory addresses x y z sample,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    load_at Mint32 memory (area1_state_storage_block addresses) 0
      mario_state_action_offset = Some (Vint spin_airborne_entry_action) /\
    load_at Mint16unsigned memory (area1_state_storage_block addresses) 0
      mario_state_action_timer_offset = Some (Vint Int.zero) /\
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_quicksand_depth_offset =
      Some (Vsingle positive_f32_zero) /\
    spin_airborne_entry_action <> Int.repr zero_a_long_jump /\
    spin_airborne_entry_action <> Int.repr zero_a_long_jump_land.
Proof.
  intros memory addresses x y z sample Hentry.
  repeat split.
  - exact (ordinary_area1_action _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_action_timer_zero _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_quicksand_depth_zero _ _ _ _ _ _ Hentry).
  - unfold spin_airborne_entry_action, zero_a_long_jump.
    vm_compute. congruence.
  - unfold spin_airborne_entry_action, zero_a_long_jump_land.
    vm_compute. congruence.
Qed.

(** The concrete memory postconditions above are not inferred merely from
    this syntax receipt.  The receipt nevertheless closes the source-level
    question of what [init_mario] writes: both target versions contain an
    explicit binary32 +0.0 store to [MarioState.quicksandDepth]. *)
Theorem us_jp_init_mario_explicitly_reset_quicksand_depth :
  assigns_field_float32_constant_s ZA_USMario._quicksandDepth 0
      (fn_body ZA_USMario.f_init_mario) = true /\
  assigns_field_float32_constant_s ZA_JPMario._quicksandDepth 0
      (fn_body ZA_JPMario.f_init_mario) = true.
Proof. vm_compute. split; reflexivity. Qed.

(** * Only the six-frame descriptor admits a negative landing write *)

Inductive stock_landing_kind : Type :=
| StockJumpLand
| StockFreefallLand
| StockSideFlipLand
| StockHoldJumpLand
| StockHoldFreefallLand
| StockLongJumpLand
| StockDoubleJumpLand
| StockTripleJumpLand
| StockBackflipLand.

Definition stock_landing_frames (kind : stock_landing_kind) : Z :=
  match kind with
  | StockLongJumpLand => 6
  | _ => 4
  end.

(** [common_landing_cancels] increments the timer and returns before the body
    when the incremented value is at least the descriptor frame count. *)
Definition stock_landing_body_runs
    (kind : stock_landing_kind) (post_increment_timer : Z) : Prop :=
  1 <= post_increment_timer < stock_landing_frames kind.

Definition projected_landing_depth
    (before post_increment_timer : Z) : Z :=
  before + (4 - post_increment_timer) * 350 - 50.

Theorem stock_landing_negative_from_nonnegative_requires_long_jump :
  forall kind before timer,
    0 <= before ->
    stock_landing_body_runs kind timer ->
    projected_landing_depth before timer < 0 ->
    kind = StockLongJumpLand /\ 4 <= timer <= 5.
Proof.
  intros kind before timer Hbefore Hbody Hnegative.
  destruct kind; unfold stock_landing_body_runs in Hbody;
    cbn [stock_landing_frames] in Hbody;
    unfold projected_landing_depth in Hnegative.
  all: try (exfalso; lia).
  split; [reflexivity | lia].
Qed.

Theorem generated_descriptor_frames_match_stock_landing_kinds :
  map descriptor_frame_count us_landing_descriptors =
    map (fun kind => Some (stock_landing_frames kind))
      [StockJumpLand; StockFreefallLand; StockSideFlipLand;
       StockHoldJumpLand; StockHoldFreefallLand; StockLongJumpLand;
       StockDoubleJumpLand; StockTripleJumpLand; StockBackflipLand] /\
  map descriptor_frame_count jp_landing_descriptors =
    map (fun kind => Some (stock_landing_frames kind))
      [StockJumpLand; StockFreefallLand; StockSideFlipLand;
       StockHoldJumpLand; StockHoldFreefallLand; StockLongJumpLand;
       StockDoubleJumpLand; StockTripleJumpLand; StockBackflipLand].
Proof. vm_compute. split; reflexivity. Qed.

(** * Bilateral whole-generated-source target-value census *)

Fixpoint zero_a_internal_int_literal_sites
    (needle : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_mentions_int_s needle (fn_body body)
      then id :: zero_a_internal_int_literal_sites needle rest
      else zero_a_internal_int_literal_sites needle rest
  | _ :: rest => zero_a_internal_int_literal_sites needle rest
  end.

Fixpoint zero_a_internal_two_literal_call_sites
    (callee : ident) (second third : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if calls_ident_with_two_int_literals_s
          callee second third (fn_body body)
      then id :: zero_a_internal_two_literal_call_sites
        callee second third rest
      else zero_a_internal_two_literal_call_sites callee second third rest
  | _ :: rest =>
      zero_a_internal_two_literal_call_sites callee second third rest
  end.

Definition is_second_int_literal_call_s
    (callee : ident) (second : Z) (statement : statement) : bool :=
  match statement with
  | Scall _ (Evar found_callee _) (_ :: Econst_int found_second _ :: _) =>
      Pos.eqb found_callee callee &&
      Int.eq found_second (Int.repr second)
  | _ => false
  end.

Fixpoint contains_second_int_literal_call_s
    (callee : ident) (second : Z) (statement : statement) : bool :=
  is_second_int_literal_call_s callee second statement ||
  match statement with
  | Ssequence first next | Sloop first next =>
      contains_second_int_literal_call_s callee second first ||
      contains_second_int_literal_call_s callee second next
  | Sifthenelse _ yes_branch no_branch =>
      contains_second_int_literal_call_s callee second yes_branch ||
      contains_second_int_literal_call_s callee second no_branch
  | Sswitch _ cases =>
      contains_second_int_literal_call_ls callee second cases
  | Slabel _ body => contains_second_int_literal_call_s callee second body
  | _ => false
  end
with contains_second_int_literal_call_ls
    (callee : ident) (second : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_second_int_literal_call_s callee second body ||
      contains_second_int_literal_call_ls callee second rest
  end.

Fixpoint zero_a_internal_second_literal_call_sites
    (callee : ident) (second : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if contains_second_int_literal_call_s callee second (fn_body body)
      then id :: zero_a_internal_second_literal_call_sites callee second rest
      else zero_a_internal_second_literal_call_sites callee second rest
  | _ :: rest => zero_a_internal_second_literal_call_sites callee second rest
  end.

Definition zero_a_ident_member (needle : ident) (haystack : list ident) : bool :=
  existsb (Pos.eqb needle) haystack.

Definition us_direct_action_writer_target_literal_overlap : list ident :=
  filter
    (fun writer =>
      zero_a_ident_member writer
        (zero_a_internal_int_literal_sites zero_a_long_jump
          us_generated_definitions) ||
      zero_a_ident_member writer
        (zero_a_internal_int_literal_sites zero_a_long_jump_land
          us_generated_definitions))
    us_action_direct_writer_sites.

Definition jp_direct_action_writer_target_literal_overlap : list ident :=
  filter
    (fun writer =>
      zero_a_ident_member writer
        (zero_a_internal_int_literal_sites zero_a_long_jump
          jp_generated_definitions_for_alias) ||
      zero_a_ident_member writer
        (zero_a_internal_int_literal_sites zero_a_long_jump_land
          jp_generated_definitions_for_alias))
    jp_action_direct_writer_sites.

Theorem us_jp_long_jump_expression_sites_are_exhaustive :
  zero_a_internal_int_literal_sites zero_a_long_jump
      us_generated_definitions =
    [ZA_USAir._update_air_with_turn;
     ZA_USAir._update_air_without_turn;
     ZA_USMove._act_crouch_slide;
     ZA_USStep._apply_gravity] /\
  zero_a_internal_int_literal_sites zero_a_long_jump
      jp_generated_definitions_for_alias =
    [ZA_JPAir._update_air_with_turn;
     ZA_JPAir._update_air_without_turn;
     ZA_JPMove._act_crouch_slide;
     ZA_JPStep._apply_gravity].
Proof. vm_compute. split; reflexivity. Qed.

Theorem us_jp_long_jump_land_expression_sites_are_exhaustive :
  zero_a_internal_int_literal_sites zero_a_long_jump_land
      us_generated_definitions = [ZA_USAir._act_long_jump] /\
  zero_a_internal_int_literal_sites zero_a_long_jump_land
      jp_generated_definitions_for_alias = [ZA_JPAir._act_long_jump].
Proof. vm_compute. split; reflexivity. Qed.

Theorem us_jp_direct_action_writers_embed_no_target_literal :
  us_direct_action_writer_target_literal_overlap = [] /\
  jp_direct_action_writer_target_literal_overlap = [].
Proof. vm_compute. split; reflexivity. Qed.

Theorem us_jp_direct_long_jump_constructor_sites_are_exhaustive :
  zero_a_internal_two_literal_call_sites
      ZA_USMove._set_jumping_action zero_a_long_jump 0
      us_generated_definitions = [ZA_USMove._act_crouch_slide] /\
  zero_a_internal_two_literal_call_sites
      ZA_JPMove._set_jumping_action zero_a_long_jump 0
      jp_generated_definitions_for_alias = [ZA_JPMove._act_crouch_slide] /\
  zero_a_internal_two_literal_call_sites
      ZA_USMove._set_mario_action zero_a_long_jump 0
      us_generated_definitions = [] /\
  zero_a_internal_two_literal_call_sites
      ZA_JPMove._set_mario_action zero_a_long_jump 0
      jp_generated_definitions_for_alias = [].
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem us_jp_long_jump_landing_constructor_sites_are_exhaustive :
  zero_a_internal_second_literal_call_sites
      ZA_USAir._common_air_action_step zero_a_long_jump_land
      us_generated_definitions = [ZA_USAir._act_long_jump] /\
  zero_a_internal_second_literal_call_sites
      ZA_JPAir._common_air_action_step zero_a_long_jump_land
      jp_generated_definitions_for_alias = [ZA_JPAir._act_long_jump] /\
  zero_a_internal_two_literal_call_sites
      ZA_USMove._set_mario_action zero_a_long_jump_land 0
      us_generated_definitions = [] /\
  zero_a_internal_two_literal_call_sites
      ZA_JPMove._set_mario_action zero_a_long_jump_land 0
      jp_generated_definitions_for_alias = [].
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The exact guard and indirect callback receipts are kept separate from the
    literal census so the final source boundary does not silently infer
    control flow from mere co-occurrence. *)
Definition ZeroAOrdinaryLongJumpSourceBoundary : Prop :=
  bilateral_long_jump_source_chain_claim /\
  assigns_field_float32_constant_s ZA_USMario._quicksandDepth 0
      (fn_body ZA_USMario.f_init_mario) = true /\
  assigns_field_float32_constant_s ZA_JPMario._quicksandDepth 0
      (fn_body ZA_JPMario.f_init_mario) = true /\
  us_direct_action_writer_target_literal_overlap = [] /\
  jp_direct_action_writer_target_literal_overlap = [] /\
  zero_a_internal_two_literal_call_sites
      ZA_USMove._set_jumping_action zero_a_long_jump 0
      us_generated_definitions = [ZA_USMove._act_crouch_slide] /\
  zero_a_internal_two_literal_call_sites
      ZA_JPMove._set_jumping_action zero_a_long_jump 0
      jp_generated_definitions_for_alias = [ZA_JPMove._act_crouch_slide] /\
  zero_a_internal_second_literal_call_sites
      ZA_USAir._common_air_action_step zero_a_long_jump_land
      us_generated_definitions = [ZA_USAir._act_long_jump] /\
  zero_a_internal_second_literal_call_sites
      ZA_JPAir._common_air_action_step zero_a_long_jump_land
      jp_generated_definitions_for_alias = [ZA_JPAir._act_long_jump].

Theorem zero_a_ordinary_long_jump_source_boundary_checked :
  ZeroAOrdinaryLongJumpSourceBoundary.
Proof.
  unfold ZeroAOrdinaryLongJumpSourceBoundary.
  pose proof bilateral_long_jump_source_chain_checked as Hchain.
  pose proof us_jp_init_mario_explicitly_reset_quicksand_depth as Hreset.
  pose proof us_jp_direct_action_writers_embed_no_target_literal as Hoverlap.
  pose proof us_jp_direct_long_jump_constructor_sites_are_exhaustive as Hjump.
  pose proof us_jp_long_jump_landing_constructor_sites_are_exhaustive as Hland.
  tauto.
Qed.

(** In the source transition/depth kernels, clean zero-edge ordinary traces
    therefore retain both the action exclusion and nonnegative depth.  The
    two kernel traces are premises here; a linked-retail simulation showing
    that every live step refines them remains the explicit residual. *)
Theorem zero_a_ordinary_source_kernels_exclude_prepared_negative_state :
  forall entry action_events final_action final_depth,
    source_action_trace
      (expected_clean_entry_action entry) action_events final_action ->
    no_a_edges action_events ->
    no_forged_action_installs action_events ->
    JPSourceShapedSafeDepthTrace 0 final_depth ->
    non_long_jump_target final_action /\ 0 <= final_depth.
Proof.
  intros entry action_events final_action final_depth
    Hactions Hedges Hforges Hdepth.
  split.
  - eapply clean_no_edge_trace_preserves_long_jump_exclusion; eauto.
    apply expected_clean_entry_action_is_safe.
  - now apply jp_source_shaped_safe_depth_trace_from_zero_is_nonnegative.
Qed.
