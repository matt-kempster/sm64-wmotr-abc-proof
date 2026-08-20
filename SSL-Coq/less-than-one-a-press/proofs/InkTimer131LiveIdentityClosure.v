(** Live-identity boundary for the timer-131 Graphics-retry installer.

    The earlier Ink tranches established that the generic Mario graphical tail
    needs raw-data flag bit zero and the graphical-Y-offset cell, and that a
    defined store can change either four-byte cell only by overlapping Mario's
    pool slot.  This file closes two narrower gaps:

    - the SSL INIT_MARIO command contains the exact [&bhvMario] operand, and
      the generated command/area/object path forwards one stable spawn-record
      behavior value all the way into Mario's Object; and
    - an arbitrary finite trace made only of framed stores, stores to distinct
      valid Object slots, a bit-0-clear flag update, and a zero offset write
      cannot enable the dangerous tail.

    The second result is deliberately an event-classification theorem, not a
    claim that every retail Clight step has already been classified.  A final
    retail disproof must still prove that the actual linked execution enters
    this trace relation.  A forged/interior pointer, overlapping out-of-bounds
    store, untyped external write, same-slot lifecycle failure, or mutation of
    the level-script/dispatch bytes is therefore still an explicit escape. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_area us_level_script us_ssl_script
  jp_area jp_level_script jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts EntryMemory InkTimer131CorruptionClosure
  InkTimer131IndirectAliasClosure InkTimer131MarioTailClosure
  OrdinaryArea1EntryMemory.

Import ListNotations.
Local Open Scope Z_scope.

Module ITLI_USArea := us_area.
Module ITLI_USLevel := us_level_script.
Module ITLI_USSSL := us_ssl_script.
Module ITLI_JPArea := jp_area.
Module ITLI_JPLevel := jp_level_script.
Module ITLI_JPSSL := jp_ssl_script.

(** The three words beginning at index 23 are one INIT_MARIO command:
    command/size/model, model number, and the behavior-script pointer.  Exact
    suffix coordinates prevent an unrelated [&bhvMario] occurrence from
    satisfying the receipt. *)
Definition ink_ssl_init_mario_command_source_claim : Prop :=
  firstn 3 (skipn 23 (gvar_init ITLI_USSSL.v_level_ssl_entry)) =
    [Init_int32 (Int.repr 621543425);
     Init_int32 (Int.repr 1);
     Init_addrof ITLI_USSSL._bhvMario Ptrofs.zero] /\
  firstn 3 (skipn 23 (gvar_init ITLI_JPSSL.v_level_ssl_entry)) =
    [Init_int32 (Int.repr 621543425);
     Init_int32 (Int.repr 1);
     Init_addrof ITLI_JPSSL._bhvMario Ptrofs.zero].

Theorem ink_ssl_init_mario_command_supplies_bhv_mario :
  ink_ssl_init_mario_command_source_claim.
Proof.
  unfold ink_ssl_init_mario_command_source_claim.
  vm_compute. split; reflexivity.
Qed.

(** Match the normalized dataflow in [level_cmd_init_mario]: load the global
    Mario SpawnInfo, load the current level command, obtain one value from an
    expression using that command temporary, then store that same value into
    [SpawnInfo.behaviorScript]. *)
Definition ink_is_command_behavior_to_spawn_info_s
    (spawn_global current_command spawn_tag behavior_field : ident)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset spawn_temp (Evar found_spawn_global _))
      (Ssequence
        (Sset command_temp (Evar found_current_command _))
        (Ssequence
          (Sset value_temp source_expression)
          (Sassign
            (Efield
              (Ederef (Etempvar used_spawn_temp _) (Tstruct found_spawn_tag _))
              found_behavior_field _)
            (Etempvar used_value_temp _)))) =>
      Pos.eqb found_spawn_global spawn_global &&
      Pos.eqb found_current_command current_command &&
      Pos.eqb found_spawn_tag spawn_tag &&
      Pos.eqb found_behavior_field behavior_field &&
      Pos.eqb spawn_temp used_spawn_temp &&
      Pos.eqb value_temp used_value_temp &&
      expression_mentions_ident command_temp source_expression
  | _ => false
  end.

Fixpoint ink_contains_command_behavior_to_spawn_info_s
    (spawn_global current_command spawn_tag behavior_field : ident)
    (statement : statement) : bool :=
  ink_is_command_behavior_to_spawn_info_s
      spawn_global current_command spawn_tag behavior_field statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      ink_contains_command_behavior_to_spawn_info_s
        spawn_global current_command spawn_tag behavior_field first ||
      ink_contains_command_behavior_to_spawn_info_s
        spawn_global current_command spawn_tag behavior_field second
  | Sifthenelse _ yes no =>
      ink_contains_command_behavior_to_spawn_info_s
        spawn_global current_command spawn_tag behavior_field yes ||
      ink_contains_command_behavior_to_spawn_info_s
        spawn_global current_command spawn_tag behavior_field no
  | Sswitch _ cases =>
      ink_contains_command_behavior_to_spawn_info_ls
        spawn_global current_command spawn_tag behavior_field cases
  | Slabel _ nested =>
      ink_contains_command_behavior_to_spawn_info_s
        spawn_global current_command spawn_tag behavior_field nested
  | _ => false
  end
with ink_contains_command_behavior_to_spawn_info_ls
    (spawn_global current_command spawn_tag behavior_field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      ink_contains_command_behavior_to_spawn_info_s
        spawn_global current_command spawn_tag behavior_field body ||
      ink_contains_command_behavior_to_spawn_info_ls
        spawn_global current_command spawn_tag behavior_field rest
  end.

(** Match [load_mario_area]'s stable
    [spawn_objects_from_info(0, gMarioSpawnInfo)] call. *)
Definition ink_is_spawn_global_to_binary_call_s
    (spawn_global callee : ident) (first_argument : Z)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset spawn_temp (Evar found_spawn_global _))
      (Scall None (Evar found_callee _)
        [Econst_int found_first _; Etempvar used_spawn_temp _]) =>
      Pos.eqb found_spawn_global spawn_global &&
      Pos.eqb found_callee callee &&
      Pos.eqb spawn_temp used_spawn_temp &&
      Z.eqb (Int.signed found_first) first_argument
  | _ => false
  end.

Fixpoint ink_contains_spawn_global_to_binary_call_s
    (spawn_global callee : ident) (first_argument : Z)
    (statement : statement) : bool :=
  ink_is_spawn_global_to_binary_call_s
      spawn_global callee first_argument statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      ink_contains_spawn_global_to_binary_call_s
        spawn_global callee first_argument first ||
      ink_contains_spawn_global_to_binary_call_s
        spawn_global callee first_argument second
  | Sifthenelse _ yes no =>
      ink_contains_spawn_global_to_binary_call_s
        spawn_global callee first_argument yes ||
      ink_contains_spawn_global_to_binary_call_s
        spawn_global callee first_argument no
  | Sswitch _ cases =>
      ink_contains_spawn_global_to_binary_call_ls
        spawn_global callee first_argument cases
  | Slabel _ nested =>
      ink_contains_spawn_global_to_binary_call_s
        spawn_global callee first_argument nested
  | _ => false
  end
with ink_contains_spawn_global_to_binary_call_ls
    (spawn_global callee : ident) (first_argument : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      ink_contains_spawn_global_to_binary_call_s
        spawn_global callee first_argument body ||
      ink_contains_spawn_global_to_binary_call_ls
        spawn_global callee first_argument rest
  end.

Definition ink_mario_spawn_record_forwarding_source_claim : Prop :=
  ink_contains_command_behavior_to_spawn_info_s
    ITLI_USLevel._gMarioSpawnInfo ITLI_USLevel._sCurrentCmd
    ITLI_USLevel._SpawnInfo ITLI_USLevel._behaviorScript
    (fn_body ITLI_USLevel.f_level_cmd_init_mario) = true /\
  ink_contains_command_behavior_to_spawn_info_s
    ITLI_JPLevel._gMarioSpawnInfo ITLI_JPLevel._sCurrentCmd
    ITLI_JPLevel._SpawnInfo ITLI_JPLevel._behaviorScript
    (fn_body ITLI_JPLevel.f_level_cmd_init_mario) = true /\
  ink_contains_spawn_global_to_binary_call_s
    ITLI_USArea._gMarioSpawnInfo ITLI_USArea._spawn_objects_from_info 0
    (fn_body ITLI_USArea.f_load_mario_area) = true /\
  ink_contains_spawn_global_to_binary_call_s
    ITLI_JPArea._gMarioSpawnInfo ITLI_JPArea._spawn_objects_from_info 0
    (fn_body ITLI_JPArea.f_load_mario_area) = true /\
  ink_mario_constructor_behavior_forwarding_claim.

Theorem ink_mario_spawn_record_forwards_ssl_bhv_mario_source :
  ink_mario_spawn_record_forwarding_source_claim.
Proof.
  unfold ink_mario_spawn_record_forwarding_source_claim.
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  exact ink_mario_constructor_forwards_one_stable_behavior_value.
Qed.

(** * Arbitrary finite clean-store traces *)

Definition ink_timer131_cells_safe
    (memory : mem) (pool_block : block) (mario_slot : nat) : Prop :=
  exists flags,
    ink_object_cell_load Mint32 ink_object_flag_cell_offset
      memory pool_block (object_slot_offset mario_slot) = Some (Vint flags) /\
    Z.testbit (Int.unsigned flags) 0 = false /\
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset
      memory pool_block (object_slot_offset mario_slot) =
        Some (Vsingle positive_f32_zero).

Definition ink_store_frames_timer131_cell
    (read_chunk write_chunk : memory_chunk) (cell_offset : Z)
    (pool_block write_block : block) (mario_slot : nat)
    (write_offset : Z) : Prop :=
  write_block <> pool_block \/
  write_offset + size_chunk write_chunk <=
    object_slot_offset mario_slot + cell_offset \/
  object_slot_offset mario_slot + cell_offset + size_chunk read_chunk <=
    write_offset.

Inductive InkTimer131CleanStoreStep
    (pool_block : block) (mario_slot : nat) : mem -> mem -> Prop :=
| InkCleanFramedStore :
    forall before after write_chunk write_block write_offset value,
      Mem.store write_chunk before write_block write_offset value = Some after ->
      ink_store_frames_timer131_cell Mint32 write_chunk
        ink_object_flag_cell_offset pool_block write_block mario_slot
        write_offset ->
      ink_store_frames_timer131_cell Mfloat32 write_chunk
        ink_object_graph_y_offset_cell_offset pool_block write_block mario_slot
        write_offset ->
      InkTimer131CleanStoreStep pool_block mario_slot before after
| InkCleanSafeFlagStore :
    forall before after written,
      Z.testbit (Int.unsigned written) 0 = false ->
      Mem.store Mint32 before pool_block
        (object_slot_offset mario_slot + ink_object_flag_cell_offset)
        (Vint written) = Some after ->
      InkTimer131CleanStoreStep pool_block mario_slot before after
| InkCleanZeroGraphOffsetStore :
    forall before after,
      Mem.store Mfloat32 before pool_block
        (object_slot_offset mario_slot + ink_object_graph_y_offset_cell_offset)
        (Vsingle positive_f32_zero) = Some after ->
      InkTimer131CleanStoreStep pool_block mario_slot before after.

Lemma ink_clean_store_step_preserves_timer131_cell_safety :
  forall pool_block mario_slot before after,
    ink_timer131_cells_safe before pool_block mario_slot ->
    InkTimer131CleanStoreStep pool_block mario_slot before after ->
    ink_timer131_cells_safe after pool_block mario_slot.
Proof.
  intros pool_block mario_slot before after
    [flags [Hflag [Hbit Hoffset]]] Hstep.
  destruct Hstep as
    [before after write_chunk write_block write_offset value
       Hstore Hflag_frame Hoffset_frame
    |before after written Hwritten Hstore
    |before after Hstore].
  - exists flags. split.
    + rewrite <- Hflag.
      eapply framed_store_preserves_object_cell; eauto.
    + split; [exact Hbit |].
      rewrite <- Hoffset.
      eapply framed_store_preserves_object_cell; eauto.
  - exists written. split.
    + unfold ink_object_cell_load.
      exact (Mem.load_store_same Mint32 before pool_block
        (object_slot_offset mario_slot + ink_object_flag_cell_offset)
        (Vint written) after Hstore).
    + split; [exact Hwritten |].
      rewrite <- Hoffset.
      eapply framed_store_preserves_object_cell; eauto.
      right. left. cbn [size_chunk].
      unfold ink_object_flag_cell_offset,
        ink_object_graph_y_offset_cell_offset, object_raw_float_offset.
      lia.
  - exists flags. split.
    + rewrite <- Hflag.
      eapply framed_store_preserves_object_cell; eauto.
      right. right. cbn [size_chunk].
      unfold ink_object_flag_cell_offset,
        ink_object_graph_y_offset_cell_offset, object_raw_float_offset.
      lia.
    + split; [exact Hbit |].
      unfold ink_object_cell_load.
      exact (Mem.load_store_same Mfloat32 before pool_block
        (object_slot_offset mario_slot + ink_object_graph_y_offset_cell_offset)
        (Vsingle positive_f32_zero) after Hstore).
Qed.

Inductive InkTimer131CleanStoreTrace
    (pool_block : block) (mario_slot : nat) : mem -> mem -> Prop :=
| InkCleanTraceRefl :
    forall memory,
      InkTimer131CleanStoreTrace pool_block mario_slot memory memory
| InkCleanTraceStep :
    forall before middle after,
      InkTimer131CleanStoreStep pool_block mario_slot before middle ->
      InkTimer131CleanStoreTrace pool_block mario_slot middle after ->
      InkTimer131CleanStoreTrace pool_block mario_slot before after.

Theorem finite_clean_store_trace_preserves_timer131_cell_safety :
  forall pool_block mario_slot before after,
    InkTimer131CleanStoreTrace pool_block mario_slot before after ->
    ink_timer131_cells_safe before pool_block mario_slot ->
    ink_timer131_cells_safe after pool_block mario_slot.
Proof.
  intros pool_block mario_slot before after Htrace.
  induction Htrace; intro Hsafe.
  - exact Hsafe.
  - apply IHHtrace.
    eapply ink_clean_store_step_preserves_timer131_cell_safety; eauto.
Qed.

(** Any well-bounded store to a distinct pool slot belongs to the framed
    branch.  This lifts the earlier one-store preservation fact into the
    arbitrary finite trace relation. *)
Lemma distinct_slot_in_bounds_store_is_clean_timer131_step :
  forall before after pool_block writer_slot mario_slot
      write_chunk write_inner_offset value,
    writer_slot <> mario_slot ->
    0 <= write_inner_offset ->
    write_inner_offset + size_chunk write_chunk <= object_size ->
    Mem.store write_chunk before pool_block
      (object_slot_offset writer_slot + write_inner_offset) value = Some after ->
    InkTimer131CleanStoreStep pool_block mario_slot before after.
Proof.
  intros before after pool_block writer_slot mario_slot
    write_chunk write_inner_offset value
    Hdistinct Hlower Hupper Hstore.
  apply InkCleanFramedStore with
    (write_chunk := write_chunk) (write_block := pool_block)
    (write_offset := object_slot_offset writer_slot + write_inner_offset)
    (value := value); [exact Hstore | |].
  all: unfold ink_store_frames_timer131_cell;
    right;
    pose proof (distinct_object_slot_intervals_are_disjoint
      writer_slot mario_slot Hdistinct) as Hslots;
    destruct Hslots as [Hwriter_before | Hmario_before].
  - left. unfold ink_object_flag_cell_offset, object_raw_float_offset. lia.
  - right. cbn [size_chunk].
    unfold ink_object_flag_cell_offset, object_raw_float_offset,
      object_size in *. lia.
  - left.
    unfold ink_object_graph_y_offset_cell_offset, object_raw_float_offset.
    lia.
  - right. cbn [size_chunk].
    unfold ink_object_graph_y_offset_cell_offset, object_raw_float_offset,
      object_size in *. lia.
Qed.

Corollary live_unimportant_eviction_store_is_clean_timer131_step :
  forall Object (projection : InkLiveObjectListSlotProjection Object)
      before after pool_block write_chunk write_inner_offset value,
    0 <= write_inner_offset ->
    write_inner_offset + size_chunk write_chunk <= object_size ->
    Mem.store write_chunk before pool_block
      (object_slot_offset
        (ink_live_object_slot Object projection
          (ink_live_eviction_object Object projection)) + write_inner_offset)
      value = Some after ->
    InkTimer131CleanStoreStep pool_block
      (ink_live_object_slot Object projection
        (ink_live_mario_object Object projection)) before after.
Proof.
  intros Object projection before after pool_block write_chunk
    write_inner_offset value Hlower Hupper Hstore.
  exact (distinct_slot_in_bounds_store_is_clean_timer131_step
    before after pool_block
    (ink_live_object_slot Object projection
      (ink_live_eviction_object Object projection))
    (ink_live_object_slot Object projection
      (ink_live_mario_object Object projection))
    write_chunk write_inner_offset value
    (live_unimportant_eviction_uses_a_distinct_mario_slot Object projection)
    Hlower Hupper Hstore).
Qed.

Definition ink_timer131_tail_cells_dangerous
    (memory : mem) (pool_block : block) (mario_slot : nat) : Prop :=
  exists flags offset,
    ink_object_cell_load Mint32 ink_object_flag_cell_offset
      memory pool_block (object_slot_offset mario_slot) = Some (Vint flags) /\
    Z.testbit (Int.unsigned flags) 0 = true /\
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset
      memory pool_block (object_slot_offset mario_slot) = Some (Vsingle offset) /\
    offset <> positive_f32_zero.

Lemma safe_timer131_cells_are_not_dangerous :
  forall memory pool_block mario_slot,
    ink_timer131_cells_safe memory pool_block mario_slot ->
    ~ ink_timer131_tail_cells_dangerous memory pool_block mario_slot.
Proof.
  intros memory pool_block mario_slot
    [safe_flags [Hsafe_load [Hsafe_bit Hsafe_offset]]]
    [danger_flags [danger_offset
      [Hdanger_load [Hdanger_bit [Hdanger_offset Hnonzero]]]]].
  rewrite Hsafe_load in Hdanger_load. inversion Hdanger_load; subst danger_flags.
  rewrite Hsafe_bit in Hdanger_bit. discriminate.
Qed.

Theorem clean_finite_trace_cannot_install_timer131_tail_cells :
  forall pool_block mario_slot before after,
    InkTimer131CleanStoreTrace pool_block mario_slot before after ->
    ink_timer131_cells_safe before pool_block mario_slot ->
    ~ ink_timer131_tail_cells_dangerous after pool_block mario_slot.
Proof.
  intros pool_block mario_slot before after Htrace Hsafe.
  apply safe_timer131_cells_are_not_dangerous.
  eapply finite_clean_store_trace_preserves_timer131_cell_safety; eauto.
Qed.

Definition InkTimer131LiveIdentityCheckedBoundary : Prop :=
  ink_ssl_init_mario_command_source_claim /\
  ink_mario_spawn_record_forwarding_source_claim /\
  (forall pool_block mario_slot before after,
    InkTimer131CleanStoreTrace pool_block mario_slot before after ->
    ink_timer131_cells_safe before pool_block mario_slot ->
    ~ ink_timer131_tail_cells_dangerous after pool_block mario_slot).

Theorem ink_timer131_live_identity_checked_boundary_holds :
  InkTimer131LiveIdentityCheckedBoundary.
Proof.
  unfold InkTimer131LiveIdentityCheckedBoundary.
  split; [exact ink_ssl_init_mario_command_supplies_bhv_mario |].
  split; [exact ink_mario_spawn_record_forwards_ssl_bhv_mario_source |].
  exact clean_finite_trace_cannot_install_timer131_tail_cells.
Qed.

(** The exact live bridge still needed after this tranche. *)
Record InkTimer131PostLiveIdentityResidual : Type := {
  ink_live_identity_entry_reaches_safe_cells : Prop;
  ink_live_identity_mario_stays_in_list_zero_and_same_slot : Prop;
  ink_live_identity_all_retail_stores_refine_to_clean_trace : Prop;
  ink_live_identity_level_command_bytes_are_preserved : Prop;
  ink_live_identity_behavior_and_dispatch_bytes_are_preserved : Prop;
  ink_live_identity_no_forged_interior_oob_or_external_store : Prop
}.
