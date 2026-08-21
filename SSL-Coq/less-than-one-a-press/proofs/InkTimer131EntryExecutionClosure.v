(** Entry-execution progress for the timer-131 Graphics-retry route.

    The earlier Clight trace bridge deliberately started from three facts
    that the ordinary Area-1 entry postcondition did not provide: cleared
    raw-data words, Mario's behavior pointer, and a live list-0 path.  This
    file moves that boundary in two ways.

    First, the official cleaned JP program's concrete [Genv.init_mem] is
    proved to contain zero in both dangerous words of every valid object-pool
    slot.  This is a real CompCert-memory theorem, not a source comment or a
    caller-chosen postcondition.  The generated allocator/create/spawn/list
    bodies are then checked as one bilateral source chain: allocation clears
    all 80 raw words, [create_object] selects and allocates from the behavior
    list and installs the same behavior, [spawn_objects_from_info] installs
    the returned Mario object, and [bhvMario] selects list 0.

    Second, a generic first-failure theorem is stated over the actual
    [Clight.step2] relation.  Once the entry facts are connected to a selected
    run, any dangerous final state has a first reachable Clight step that
    destroys the live invariant.  That step is the concrete producer that a
    store/callback/external classifier must accept or expose.

    What is still not claimed: initializer zeros do not by themselves prove
    preservation until Mario is allocated, and syntax does not prove that
    [warp_level] executes the allocator/spawn branch or that the returned
    slot and list links survive.  Constructing that live prefix remains the
    exact semantic obligation; this file does not turn it into a new axiom. *)

From Coq Require Import Classical Lia List ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Events Floats Globalenvs Integers Maps Memory
  Smallstep Values.
From LessThanOneAPress.Generated Require Import
  jp_area jp_behavior_data jp_object_list_processor jp_spawn_object
  us_area us_behavior_data us_object_list_processor us_spawn_object.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CleanedClightPrograms EntryMemory InkTimer131ClightTraceBridge
  InkTimer131IndirectAliasClosure InkTimer131LiveIdentityClosure
  InkTimer131MarioTailClosure
  InkTimer131ProducerClosure JPObjectPoolCleanedUnitReceipt
  JPOfficialInitialMemory JPSlotLifetime OrdinaryArea1EntryMemory.

Import ListNotations.
Local Open Scope Z_scope.

Module IT131E_JPObjects := jp_object_list_processor.
Module IT131E_JPSpawn := jp_spawn_object.
Module IT131E_JPData := jp_behavior_data.
Module IT131E_JPArea := jp_area.
Module IT131E_USObjects := us_object_list_processor.
Module IT131E_USSpawn := us_spawn_object.
Module IT131E_USData := us_behavior_data.
Module IT131E_USArea := us_area.

(** * Exact zero bytes in the official initial object pool *)

Lemma jp_official_initial_object_pool_read_as_zero :
  forall memory pool_block,
    Genv.init_mem jp_official_cleaned_slice = Some memory ->
    Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice)
      pool_block = Some IT131E_JPObjects.v_gObjectPool ->
    Genv.read_as_zero memory pool_block 0 (object_size * 240).
Proof.
  intros memory pool_block Hinitial Hpool.
  pose proof (@Genv.init_mem_characterization
    Clight.fundef type jp_official_cleaned_slice pool_block
    IT131E_JPObjects.v_gObjectPool memory Hpool Hinitial) as Hcharacterized.
  destruct Hcharacterized as (_ & _ & Hloads & _).
  specialize (Hloads eq_refl).
  cbn [IT131E_JPObjects.v_gObjectPool] in Hloads.
  exact (proj1 Hloads).
Qed.

Lemma valid_object_slot_timer131_offsets_are_in_initial_pool :
  forall slot,
    (slot < object_pool_capacity)%nat ->
    0 <= object_slot_offset slot + ink_object_flag_cell_offset /\
    object_slot_offset slot + ink_object_flag_cell_offset + 4 <=
      object_size * 240 /\
    0 <= object_slot_offset slot + ink_object_graph_y_offset_cell_offset /\
    object_slot_offset slot + ink_object_graph_y_offset_cell_offset + 4 <=
      object_size * 240.
Proof.
  intros slot Hslot.
  apply Nat2Z.inj_lt in Hslot.
  unfold object_pool_capacity, object_slot_offset, object_size,
    ink_object_flag_cell_offset, ink_object_graph_y_offset_cell_offset,
    object_raw_float_offset in *.
  lia.
Qed.

Lemma object_slot_timer131_offsets_are_four_aligned :
  forall slot,
    (align_chunk Mint32 |
      object_slot_offset slot + ink_object_flag_cell_offset) /\
    (align_chunk Mfloat32 |
      object_slot_offset slot + ink_object_graph_y_offset_cell_offset).
Proof.
  intro slot.
  cbn [align_chunk].
  unfold object_slot_offset, object_size,
    ink_object_flag_cell_offset, ink_object_graph_y_offset_cell_offset,
    object_raw_float_offset.
  split.
  - exists (152 * Z.of_nat slot + 35). lia.
  - exists (152 * Z.of_nat slot + 55). lia.
Qed.

Theorem jp_official_initial_pool_slot_has_cleared_timer131_cells :
  forall memory pool_block slot,
    Genv.init_mem jp_official_cleaned_slice = Some memory ->
    Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice)
      pool_block = Some IT131E_JPObjects.v_gObjectPool ->
    (slot < object_pool_capacity)%nat ->
    ink_object_cell_load Mint32 ink_object_flag_cell_offset memory
      pool_block (object_slot_offset slot) = Some (Vint Int.zero) /\
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset memory
      pool_block (object_slot_offset slot) = Some (Vsingle positive_f32_zero).
Proof.
  intros memory pool_block slot Hinitial Hpool Hslot.
  pose proof (jp_official_initial_object_pool_read_as_zero
    memory pool_block Hinitial Hpool) as Hzero.
  pose proof (valid_object_slot_timer131_offsets_are_in_initial_pool
    slot Hslot) as (Hflag_low & Hflag_high & Hoffset_low & Hoffset_high).
  pose proof (object_slot_timer131_offsets_are_four_aligned slot)
    as (Hflag_align & Hoffset_align).
  unfold ink_object_cell_load.
  split.
  - eapply Hzero; eauto.
  - transitivity (Some (Vsingle Float32.zero)).
    + eapply Hzero; eauto.
    + reflexivity.
Qed.

Corollary jp_official_initial_memory_supplies_timer131_entry_tail_cells :
  forall memory addresses,
    Genv.init_mem jp_official_cleaned_slice = Some memory ->
    JPArea1EntrySymbolBindings
      (Clight.globalenv jp_official_cleaned_slice) addresses ->
    area1_entry_slots_valid addresses ->
    InkTimer131EntryTailCells memory addresses.
Proof.
  intros memory addresses Hinitial Hbindings Hslots.
  destruct jp_official_gObjectPool_exact_variable_lookup
    as [pool_block [Hpool_symbol Hpool_variable]].
  pose proof (jp_area1_object_pool_symbol _ _ Hbindings) as Hbound_symbol.
  rewrite Hpool_symbol in Hbound_symbol. inversion Hbound_symbol; subst pool_block.
  pose proof (jp_official_initial_pool_slot_has_cleared_timer131_cells
    memory (area1_object_pool_block addresses)
    (area1_mario_slot addresses) Hinitial Hpool_variable (proj1 Hslots))
    as [Hflag Hoffset].
  constructor; assumption.
Qed.

(** * Bilateral source chain for allocation, behavior, and list selection *)

(** This remains deliberately structural.  The exact live consequences are
    supplied only by Clight evaluation, not by these Booleans. *)
Definition ink_timer131_mario_entry_source_chain_claim : Prop :=
  assigns_dynamic_raw_s32_zero_s
    IT131E_USSpawn._rawData IT131E_USSpawn._asS32 IT131E_USSpawn._i
    (fn_body IT131E_USSpawn.f_allocate_object) = true /\
  assigns_dynamic_raw_s32_zero_s
    IT131E_JPSpawn._rawData IT131E_JPSpawn._asS32 IT131E_JPSpawn._i
    (fn_body IT131E_JPSpawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body IT131E_USSpawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body IT131E_JPSpawn.f_allocate_object) = true /\
  calls_ident_s IT131E_USSpawn._try_allocate_object
    (fn_body IT131E_USSpawn.f_allocate_object) = true /\
  calls_ident_s IT131E_JPSpawn._try_allocate_object
    (fn_body IT131E_JPSpawn.f_allocate_object) = true /\
  assigns_field_named_s IT131E_USSpawn._next
    (fn_body IT131E_USSpawn.f_try_allocate_object) = true /\
  assigns_field_named_s IT131E_USSpawn._prev
    (fn_body IT131E_USSpawn.f_try_allocate_object) = true /\
  assigns_field_named_s IT131E_JPSpawn._next
    (fn_body IT131E_JPSpawn.f_try_allocate_object) = true /\
  assigns_field_named_s IT131E_JPSpawn._prev
    (fn_body IT131E_JPSpawn.f_try_allocate_object) = true /\
  calls_ident_s IT131E_USSpawn._allocate_object
    (fn_body IT131E_USSpawn.f_create_object) = true /\
  calls_ident_s IT131E_JPSpawn._allocate_object
    (fn_body IT131E_JPSpawn.f_create_object) = true /\
  statement_mentions_ident_s IT131E_USSpawn._gObjectLists
    (fn_body IT131E_USSpawn.f_create_object) = true /\
  statement_mentions_ident_s IT131E_JPSpawn._gObjectLists
    (fn_body IT131E_JPSpawn.f_create_object) = true /\
  assigns_field_named_s IT131E_USSpawn._behavior
    (fn_body IT131E_USSpawn.f_create_object) = true /\
  assigns_field_named_s IT131E_JPSpawn._behavior
    (fn_body IT131E_JPSpawn.f_create_object) = true /\
  ink_contains_call_result_to_global_s
    IT131E_USObjects._create_object IT131E_USObjects._object
    IT131E_USObjects._gMarioObject
    (fn_body IT131E_USObjects.f_spawn_objects_from_info) = true /\
  ink_contains_call_result_to_global_s
    IT131E_JPObjects._create_object IT131E_JPObjects._object
    IT131E_JPObjects._gMarioObject
    (fn_body IT131E_JPObjects.f_spawn_objects_from_info) = true /\
  behavior_begin_list_index (gvar_init IT131E_USData.v_bhvMario) = Some 0 /\
  behavior_begin_list_index (gvar_init IT131E_JPData.v_bhvMario) = Some 0.

Theorem ink_timer131_mario_entry_source_chain_checked :
  ink_timer131_mario_entry_source_chain_claim.
Proof.
  unfold ink_timer131_mario_entry_source_chain_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * The list-0 source boundary and its concrete memory endpoint *)

Definition ink_zero_list_behavior_owner
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable =>
      match behavior_begin_list_index (gvar_init variable) with
      | Some index => Z.eqb index 0
      | None => false
      end
  | _ => false
  end.

Definition ink_zero_list_behavior_owner_ids
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst (filter ink_zero_list_behavior_owner definitions).

(** Within the complete generated behavior-data translation unit, Mario is
    the sole script selecting list 0.  Turning this source fact into a live
    statement still requires every pre-Mario constructor argument to come
    from the checked behavior-data globals. *)
Theorem ink_bhv_mario_is_the_only_generated_list_zero_behavior :
  ink_zero_list_behavior_owner_ids (prog_defs IT131E_USData.prog) =
    [IT131E_USData._bhvMario] /\
  ink_zero_list_behavior_owner_ids (prog_defs IT131E_JPData.prog) =
    [IT131E_JPData._bhvMario].
Proof.
  unfold ink_zero_list_behavior_owner_ids, ink_zero_list_behavior_owner,
    behavior_begin_list_index.
  vm_compute. split; reflexivity.
Qed.

Definition ink_timer131_area_load_order_source_claim : Prop :=
  calls_ident_s IT131E_USArea._load_area
    (fn_body IT131E_USArea.f_load_mario_area) = true /\
  calls_ident_s IT131E_USArea._spawn_objects_from_info
    (fn_body IT131E_USArea.f_load_mario_area) = true /\
  calls_ident_s IT131E_JPArea._load_area
    (fn_body IT131E_JPArea.f_load_mario_area) = true /\
  calls_ident_s IT131E_JPArea._spawn_objects_from_info
    (fn_body IT131E_JPArea.f_load_mario_area) = true /\
  calls_ident_s IT131E_USObjects._clear_object_lists
    (fn_body IT131E_USObjects.f_clear_objects) = true /\
  calls_ident_s IT131E_JPObjects._clear_object_lists
    (fn_body IT131E_JPObjects.f_clear_objects) = true /\
  statement_mentions_int_s 13
    (fn_body IT131E_USSpawn.f_clear_object_lists) = true /\
  statement_mentions_int_s 13
    (fn_body IT131E_JPSpawn.f_clear_object_lists) = true.

Theorem ink_timer131_area_load_order_source_checked :
  ink_timer131_area_load_order_source_claim.
Proof.
  unfold ink_timer131_area_load_order_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The semantic list obligation at the end of Mario's insertion can be
    discharged by one exact post-spawn load.  Unlike the earlier per-step
    byte frame, this predicate permits legitimate insertion and removal of
    other list nodes. *)
Lemma list_zero_head_next_is_mario_supplies_membership :
  forall memory addresses,
    load_at Mptr memory (area1_object_lists_storage_block addresses) 0
      object_next_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses)) ->
    InkTimer131MarioInListZero memory addresses.
Proof.
  intros memory addresses Hnext.
  exists 1%nat.
  split.
  - unfold object_pool_capacity. lia.
  - eapply InkListPathHead with
      (next := object_slot_pointer addresses (area1_mario_slot addresses)).
    + exact Hnext.
    + constructor.
Qed.

Theorem ordinary_entry_with_direct_list_link_supplies_live_invariant :
  forall memory addresses x y z sample behavior_block loads,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    InkTimer131EntryTailCells memory addresses ->
    load_at Mptr memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_behavior_offset =
      Some (Vptr behavior_block Ptrofs.zero) ->
    load_at Mptr memory (area1_object_lists_storage_block addresses) 0
      object_next_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses)) ->
    InkTimer131ProtectedLoadsHold memory loads ->
    InkTimer131LiveInvariant memory addresses behavior_block loads.
Proof.
  intros memory addresses x y z sample behavior_block loads Hentry Hcells
    Hbehavior Hnext Hloads.
  eapply ink_timer131_entry_supplies_live_invariant; eauto.
  eapply list_zero_head_next_is_mario_supplies_membership; eauto.
Qed.

(** * First concrete failure in an actual Clight trace *)

Definition InkTimer131StateInvariant
    (addresses : Area1EntryAddresses) (behavior_block : block)
    (loads : list InkTimer131ProtectedLoad) (state : Clight.state) : Prop :=
  InkTimer131LiveInvariant (ink_timer131_clight_state_memory state)
    addresses behavior_block loads.

Lemma clight_star_has_first_timer131_invariant_failure :
  forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131StateInvariant addresses behavior_block loads start ->
    ~ InkTimer131StateInvariant addresses behavior_block loads final ->
    exists before step_trace after prefix suffix,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start prefix before /\
      Clight.step2 (Clight.globalenv program) before step_trace after /\
      InkTimer131StateInvariant addresses behavior_block loads before /\
      ~ InkTimer131StateInvariant addresses behavior_block loads after /\
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        after suffix final.
Proof.
  intros program start trace final addresses behavior_block loads Hstar.
  induction Hstar as [state | first first_trace second rest_trace last
      whole_trace Hstep Htail IH Heq]; intros Hinitial Hfinal.
  - contradiction.
  - destruct (classic
      (InkTimer131StateInvariant addresses behavior_block loads second))
      as [Hsecond | Hsecond].
    + destruct (IH Hsecond Hfinal)
        as (before & violating_trace & after & prefix & suffix & Hprefix &
            Hviolating & Hbefore & Hafter & Hsuffix).
      exists before, violating_trace, after, (first_trace ** prefix), suffix.
      split.
      * eapply Smallstep.star_step.
        -- exact Hstep.
        -- exact Hprefix.
        -- reflexivity.
      * split; [exact Hviolating |].
        split; [exact Hbefore |].
        split; [exact Hafter | exact Hsuffix].
    + exists first, first_trace, second, E0, rest_trace.
      split; [constructor |].
      split; [exact Hstep |].
      split; [exact Hinitial |].
      split; [exact Hsecond | exact Htail].
Qed.

Theorem dangerous_timer131_trace_exposes_first_invariant_failure :
  forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131StateInvariant addresses behavior_block loads start ->
    ink_timer131_tail_cells_dangerous
      (ink_timer131_clight_state_memory final)
      (area1_object_pool_block addresses) (area1_mario_slot addresses) ->
    exists before step_trace after prefix suffix,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start prefix before /\
      Clight.step2 (Clight.globalenv program) before step_trace after /\
      InkTimer131StateInvariant addresses behavior_block loads before /\
      ~ InkTimer131StateInvariant addresses behavior_block loads after /\
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        after suffix final.
Proof.
  intros program start trace final addresses behavior_block loads
    Hstar Hinitial Hdangerous.
  eapply clight_star_has_first_timer131_invariant_failure; eauto.
  intros Hfinal.
  eapply safe_timer131_cells_are_not_dangerous; eauto.
  exact (ink_live_invariant_safe_cells _ _ _ _ Hfinal).
Qed.

Definition InkTimer131EntryExecutionCheckedBoundary : Prop :=
  (forall memory pool_block slot,
    Genv.init_mem jp_official_cleaned_slice = Some memory ->
    Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice)
      pool_block = Some IT131E_JPObjects.v_gObjectPool ->
    (slot < object_pool_capacity)%nat ->
    ink_object_cell_load Mint32 ink_object_flag_cell_offset memory
      pool_block (object_slot_offset slot) = Some (Vint Int.zero) /\
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset memory
      pool_block (object_slot_offset slot) = Some (Vsingle positive_f32_zero)) /\
  ink_timer131_mario_entry_source_chain_claim /\
  (ink_zero_list_behavior_owner_ids (prog_defs IT131E_USData.prog) =
      [IT131E_USData._bhvMario] /\
   ink_zero_list_behavior_owner_ids (prog_defs IT131E_JPData.prog) =
      [IT131E_JPData._bhvMario]) /\
  ink_timer131_area_load_order_source_claim /\
  (forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131StateInvariant addresses behavior_block loads start ->
    ink_timer131_tail_cells_dangerous
      (ink_timer131_clight_state_memory final)
      (area1_object_pool_block addresses) (area1_mario_slot addresses) ->
    exists before step_trace after prefix suffix,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start prefix before /\
      Clight.step2 (Clight.globalenv program) before step_trace after /\
      InkTimer131StateInvariant addresses behavior_block loads before /\
      ~ InkTimer131StateInvariant addresses behavior_block loads after /\
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        after suffix final).

Theorem ink_timer131_entry_execution_checked_boundary_holds :
  InkTimer131EntryExecutionCheckedBoundary.
Proof.
  unfold InkTimer131EntryExecutionCheckedBoundary.
  split.
  - exact jp_official_initial_pool_slot_has_cleared_timer131_cells.
  - split; [exact ink_timer131_mario_entry_source_chain_checked |].
    split; [exact ink_bhv_mario_is_the_only_generated_list_zero_behavior |].
    split; [exact ink_timer131_area_load_order_source_checked |].
    exact dangerous_timer131_trace_exposes_first_invariant_failure.
Qed.
