From Coq Require Import Bool Lia List ZArith.
Import ListNotations.
From compcert Require Import AST Coqlib Ctypes Clight ClightBigstep Cop Errors
  Globalenvs Integers Maps Memory Values Clightdefs.
From SSLPyramid.Generated Require Import spawn_object.
From SSLPyramid.Proofs Require Import ASTFacts Spec.

Module S := spawn_object.

Local Open Scope Z_scope.

Definition unload_object_ge : genv := globalenv S.prog.
Definition unload_object_ce : composite_env := prog_comp_env S.prog.

Definition unload_object_members : members :=
  match unload_object_ce ! S._Object with
  | Some composite => co_members composite
  | None => nil
  end.

Definition unload_object_node_members : members :=
  match unload_object_ce ! S._ObjectNode with
  | Some composite => co_members composite
  | None => nil
  end.

Definition unload_graph_node_object_members : members :=
  match unload_object_ce ! S._GraphNodeObject with
  | Some composite => co_members composite
  | None => nil
  end.

Definition unload_graph_node_members : members :=
  match unload_object_ce ! S._GraphNode with
  | Some composite => co_members composite
  | None => nil
  end.

Definition unload_active_flags_assign : statement :=
  Sassign
    (Efield
      (Ederef
        (Etempvar S._obj (tptr (Tstruct S._Object noattr)))
        (Tstruct S._Object noattr))
      S._activeFlags tshort)
    (Econst_int (Int.repr 0) tint).

Definition unload_object_base_expr : expr :=
  Ederef
    (Etempvar S._obj (tptr (Tstruct S._Object noattr)))
    (Tstruct S._Object noattr).

Definition unload_object_header_expr : expr :=
  Efield
    unload_object_base_expr
    S._header (Tstruct S._ObjectNode noattr).

Definition unload_object_gfx_expr : expr :=
  Efield
    unload_object_header_expr
    S._gfx (Tstruct S._GraphNodeObject noattr).

Definition unload_object_graph_node_expr : expr :=
  Efield
    unload_object_gfx_expr
    S._node (Tstruct S._GraphNode noattr).

Definition unload_object_tail : statement :=
  match fn_body S.f_unload_object with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_prev_obj_assign : statement :=
  Sassign
    (Efield
      (Ederef
        (Etempvar S._obj (tptr (Tstruct S._Object noattr)))
        (Tstruct S._Object noattr))
      S._prevObj (tptr (Tstruct S._Object noattr)))
    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)).

Definition unload_object_after_prev : statement :=
  match unload_object_tail with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_throw_matrix_lhs : expr :=
  Efield
    unload_object_gfx_expr
    S._throwMatrix (tptr (tarray (tarray tfloat 4) 4)).

Definition unload_throw_matrix_assign : statement :=
  Sassign
    unload_throw_matrix_lhs
    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)).

Definition unload_object_after_throw_matrix : statement :=
  match unload_object_after_prev with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_stop_sounds_call : statement :=
  match unload_object_after_throw_matrix with
  | Ssequence head _ => head
  | body => body
  end.

Definition unload_object_after_stop_sounds : statement :=
  match unload_object_after_throw_matrix with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_geo_remove_child_call : statement :=
  match unload_object_after_stop_sounds with
  | Ssequence head _ => head
  | body => body
  end.

Definition unload_object_after_geo_remove_child : statement :=
  match unload_object_after_stop_sounds with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_geo_add_child_call : statement :=
  match unload_object_after_geo_remove_child with
  | Ssequence head _ => head
  | body => body
  end.

Definition unload_object_after_geo_add_child : statement :=
  match unload_object_after_geo_remove_child with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_graph_flags_lhs : expr :=
  Efield
    (Efield
      (Efield
        (Efield
          (Ederef
            (Etempvar S._obj (tptr (Tstruct S._Object noattr)))
            (Tstruct S._Object noattr))
          S._header (Tstruct S._ObjectNode noattr))
        S._gfx (Tstruct S._GraphNodeObject noattr))
      S._node (Tstruct S._GraphNode noattr))
    S._flags tshort.

Definition unload_graph_flags_read_bit2 : statement :=
  Sset S._t'2 unload_graph_flags_lhs.

Definition unload_graph_flags_assign_bit2 : statement :=
  Sassign
    unload_graph_flags_lhs
    (Ebinop Oand (Etempvar S._t'2 tshort)
      (Eunop Onotint
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 2) tint) tint)
        tint)
      tint).

Definition unload_graph_flags_clear_bit2 : statement :=
  Ssequence
    unload_graph_flags_read_bit2
    unload_graph_flags_assign_bit2.

Definition unload_object_after_graph_flags_clear_bit2 : statement :=
  match unload_object_after_geo_add_child with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_graph_flags_read_bit0 : statement :=
  Sset S._t'1 unload_graph_flags_lhs.

Definition unload_graph_flags_assign_bit0 : statement :=
  Sassign
    unload_graph_flags_lhs
    (Ebinop Oand (Etempvar S._t'1 tshort)
      (Eunop Onotint
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 0) tint) tint)
        tint)
      tint).

Definition unload_graph_flags_clear_bit0 : statement :=
  Ssequence
    unload_graph_flags_read_bit0
    unload_graph_flags_assign_bit0.

Definition unload_object_after_graph_flags_clear_bit0 : statement :=
  match unload_object_after_graph_flags_clear_bit2 with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition unload_object_header_lhs : expr :=
  Efield
    (Ederef
      (Etempvar S._obj (tptr (Tstruct S._Object noattr)))
      (Tstruct S._Object noattr))
    S._header (Tstruct S._ObjectNode noattr).

Definition deallocate_object_node_base_expr : expr :=
  Ederef
    (Etempvar S._obj (tptr (Tstruct S._ObjectNode noattr)))
    (Tstruct S._ObjectNode noattr).

Definition deallocate_object_read_next : statement :=
  Sset S._t'4
    (Efield
      deallocate_object_node_base_expr
      S._next (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_read_prev : statement :=
  Sset S._t'5
    (Efield
      deallocate_object_node_base_expr
      S._prev (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_next_prev_lhs : expr :=
  Efield
    (Ederef
      (Etempvar S._t'4 (tptr (Tstruct S._ObjectNode noattr)))
      (Tstruct S._ObjectNode noattr))
    S._prev (tptr (Tstruct S._ObjectNode noattr)).

Definition deallocate_object_next_prev_assign : statement :=
  Sassign
    deallocate_object_next_prev_lhs
    (Etempvar S._t'5 (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_read_prev_again : statement :=
  Sset S._t'2
    (Efield
      deallocate_object_node_base_expr
      S._prev (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_read_next_again : statement :=
  Sset S._t'3
    (Efield
      deallocate_object_node_base_expr
      S._next (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_prev_next_lhs : expr :=
  Efield
    (Ederef
      (Etempvar S._t'2 (tptr (Tstruct S._ObjectNode noattr)))
      (Tstruct S._ObjectNode noattr))
    S._next (tptr (Tstruct S._ObjectNode noattr)).

Definition deallocate_object_prev_next_assign : statement :=
  Sassign
    deallocate_object_prev_next_lhs
    (Etempvar S._t'3 (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_read_free_next : statement :=
  Sset S._t'1
    (Efield
      (Ederef
        (Etempvar S._freeList (tptr (Tstruct S._ObjectNode noattr)))
        (Tstruct S._ObjectNode noattr))
      S._next (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_obj_next_lhs : expr :=
  Efield
    deallocate_object_node_base_expr
    S._next (tptr (Tstruct S._ObjectNode noattr)).

Definition deallocate_object_obj_next_assign : statement :=
  Sassign
    deallocate_object_obj_next_lhs
    (Etempvar S._t'1 (tptr (Tstruct S._ObjectNode noattr))).

Definition deallocate_object_free_list_next_lhs : expr :=
  Efield
    (Ederef
      (Etempvar S._freeList (tptr (Tstruct S._ObjectNode noattr)))
      (Tstruct S._ObjectNode noattr))
    S._next (tptr (Tstruct S._ObjectNode noattr)).

Definition deallocate_object_free_list_next_assign : statement :=
  Sassign
    deallocate_object_free_list_next_lhs
    (Etempvar S._obj (tptr (Tstruct S._ObjectNode noattr))).

Definition unload_deallocate_object_call : statement :=
  Scall None
    (Evar S._deallocate_object
      (Tfunction
        ((tptr (Tstruct S._ObjectNode noattr)) ::
         (tptr (Tstruct S._ObjectNode noattr)) :: nil)
        tvoid cc_default))
    ((Eaddrof
        (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
        (tptr (Tstruct S._ObjectNode noattr))) ::
     (Eaddrof unload_object_header_lhs
        (tptr (Tstruct S._ObjectNode noattr))) ::
     nil).

Theorem unload_object_body_split :
  fn_body S.f_unload_object =
  Ssequence unload_active_flags_assign unload_object_tail.
Proof. reflexivity. Qed.

Theorem deallocate_object_body_split :
  fn_body S.f_deallocate_object =
  Ssequence
    (Ssequence
      deallocate_object_read_next
      (Ssequence
        deallocate_object_read_prev
        deallocate_object_next_prev_assign))
    (Ssequence
      (Ssequence
        deallocate_object_read_prev_again
        (Ssequence
          deallocate_object_read_next_again
          deallocate_object_prev_next_assign))
      (Ssequence
        (Ssequence
          deallocate_object_read_free_next
          deallocate_object_obj_next_assign)
        deallocate_object_free_list_next_assign)).
Proof. reflexivity. Qed.

Theorem unload_object_tail_split_prev :
  unload_object_tail =
  Ssequence unload_prev_obj_assign unload_object_after_prev.
Proof. reflexivity. Qed.

Theorem unload_object_after_prev_split_throw_matrix :
  unload_object_after_prev =
  Ssequence unload_throw_matrix_assign unload_object_after_throw_matrix.
Proof. reflexivity. Qed.

Theorem unload_object_after_throw_matrix_split_stop_sounds :
  unload_object_after_throw_matrix =
  Ssequence unload_stop_sounds_call unload_object_after_stop_sounds.
Proof. reflexivity. Qed.

Theorem unload_object_after_stop_sounds_split_geo_remove_child :
  unload_object_after_stop_sounds =
  Ssequence unload_geo_remove_child_call
    unload_object_after_geo_remove_child.
Proof. reflexivity. Qed.

Theorem unload_object_after_geo_remove_child_split_geo_add_child :
  unload_object_after_geo_remove_child =
  Ssequence unload_geo_add_child_call unload_object_after_geo_add_child.
Proof. reflexivity. Qed.

Theorem unload_object_after_geo_add_child_split_graph_flags_bit2 :
  unload_object_after_geo_add_child =
  Ssequence unload_graph_flags_clear_bit2
    unload_object_after_graph_flags_clear_bit2.
Proof. reflexivity. Qed.

Theorem unload_object_after_graph_flags_bit2_split_graph_flags_bit0 :
  unload_object_after_graph_flags_clear_bit2 =
  Ssequence unload_graph_flags_clear_bit0
    unload_object_after_graph_flags_clear_bit0.
Proof. reflexivity. Qed.

Theorem unload_graph_flags_clear_bit2_split :
  unload_graph_flags_clear_bit2 =
  Ssequence unload_graph_flags_read_bit2 unload_graph_flags_assign_bit2.
Proof. reflexivity. Qed.

Theorem unload_graph_flags_clear_bit0_split :
  unload_graph_flags_clear_bit0 =
  Ssequence unload_graph_flags_read_bit0 unload_graph_flags_assign_bit0.
Proof. reflexivity. Qed.

Theorem unload_object_after_graph_flags_bit0_is_deallocate_call :
  unload_object_after_graph_flags_clear_bit0 = unload_deallocate_object_call.
Proof. reflexivity. Qed.

Theorem unload_object_tail_direct_callees :
  direct_callees_s unload_object_tail =
  [S._stop_sounds_from_source;
   S._geo_remove_child;
   S._geo_add_child;
   S._deallocate_object].
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_tail_has_no_direct_active_flags_assignment :
  assigns_field_s S._activeFlags unload_object_tail = false.
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_tail_does_not_write_obj_temp :
  writes_temp_s S._obj unload_object_tail = false.
Proof. vm_compute; reflexivity. Qed.

Lemma PTree_set_preserves_different :
  forall {A} (tree : PTree.t A) written kept value kept_value,
    Pos.eqb written kept = false ->
    tree ! kept = Some kept_value ->
    (PTree.set written value tree) ! kept = Some kept_value.
Proof.
  intros A tree written kept value kept_value Hneq Hlookup.
  rewrite PTree.gso.
  - exact Hlookup.
  - intro Heq.
    subst written.
    rewrite Pos.eqb_refl in Hneq.
    discriminate.
Qed.

Theorem unload_object_cleanup_event_sequence :
  event_subsequenceb
    [Event_assign_field S._activeFlags;
     Event_assign_field_null S._prevObj;
     Event_assign_field_null S._throwMatrix;
     Event_call S._stop_sounds_from_source;
     Event_call S._geo_remove_child;
     Event_call S._geo_add_child;
     Event_assign_field S._flags;
     Event_assign_field S._flags;
     Event_call S._deallocate_object]
    (statement_events_s (fn_body S.f_unload_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem deallocate_object_body_has_obj_next_store_event :
  event_subsequenceb
    [Event_assign_field_from_temp S._next S._t'1]
    (statement_events_s (fn_body S.f_deallocate_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem deallocate_object_body_event_sequence :
  event_subsequenceb
    [Event_set_temp_from_field S._t'4 S._obj S._next;
     Event_set_temp_from_field S._t'5 S._obj S._prev;
     Event_assign_field_from_temp S._prev S._t'5;
     Event_set_temp_from_field S._t'2 S._obj S._prev;
     Event_set_temp_from_field S._t'3 S._obj S._next;
     Event_assign_field_from_temp S._next S._t'3;
     Event_set_temp_from_field S._t'1 S._freeList S._next;
     Event_assign_field_from_temp S._next S._t'1;
     Event_assign_field_from_temp S._next S._obj]
    (statement_events_s (fn_body S.f_deallocate_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem exec_unload_object_tail_preserves_obj_temp :
  forall e le memory object_block object_offset trace le' memory' outcome,
    le ! S._obj = Some (Vptr object_block object_offset) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    le' ! S._obj = Some (Vptr object_block object_offset).
Proof.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hobj Hexec.
  unfold unload_object_tail in Hexec.
  cbn in Hexec.
  repeat match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
      inv H
  | H : exec_stmt _ _ _ _ _ (Scall None _ _) _ _ _ _ |- _ =>
      inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
      inv H
  end;
  cbn;
  repeat
    (rewrite PTree.gso;
     [ | intro Heq; vm_compute in Heq; discriminate ]);
  exact Hobj.
Qed.

Theorem unload_object_active_flags_layout :
  field_offset unload_object_ce S._activeFlags unload_object_members =
  OK (object_active_flags_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_prev_obj_layout :
  field_offset unload_object_ce S._prevObj unload_object_members =
  OK (108, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_header_layout :
  field_offset unload_object_ce S._header unload_object_members =
  OK (0, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_node_gfx_layout :
  field_offset unload_object_ce S._gfx unload_object_node_members =
  OK (0, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_node_next_layout :
  field_offset unload_object_ce S._next unload_object_node_members =
  OK (96, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_node_prev_layout :
  field_offset unload_object_ce S._prev unload_object_node_members =
  OK (100, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_throw_matrix_layout :
  field_offset unload_object_ce S._throwMatrix
    unload_graph_node_object_members =
  OK (80, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_graph_node_object_node_layout :
  field_offset unload_object_ce S._node unload_graph_node_object_members =
  OK (0, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_graph_node_flags_layout :
  field_offset unload_object_ce S._flags unload_graph_node_members =
  OK (2, Full).
Proof. vm_compute; reflexivity. Qed.

Lemma unload_object_genv_cenv :
  genv_cenv unload_object_ge = unload_object_ce.
Proof.
  unfold unload_object_ge, unload_object_ce, globalenv.
  cbn [genv_cenv].
  reflexivity.
Qed.

Lemma deref_loc_by_copy_pointer :
  forall ty memory block offset value,
    access_mode ty = By_copy ->
    deref_loc ty memory block offset Full value ->
    value = Vptr block offset.
Proof.
  intros ty memory block offset value Hmode Hderef.
  inv Hderef; try congruence.
Qed.

Lemma deref_loc_by_reference_pointer :
  forall ty memory block offset value,
    access_mode ty = By_reference ->
    deref_loc ty memory block offset Full value ->
    value = Vptr block offset.
Proof.
  intros ty memory block offset value Hmode Hderef.
  inv Hderef; try congruence.
Qed.

Lemma deref_loc_by_copy_pointer_any_bitfield :
  forall ty memory block offset bf value,
    access_mode ty = By_copy ->
    deref_loc ty memory block offset bf value ->
    bf = Full /\ value = Vptr block offset.
Proof.
  intros ty memory block offset bf value Hmode Hderef.
  inv Hderef; try congruence.
  - split; reflexivity.
  - inv H;
    repeat match goal with
    | size : intsize |- _ => destruct size
    end;
    repeat match goal with
    | sign : signedness |- _ => destruct sign
    end;
    repeat match goal with
    | H : context[zlt ?lhs ?rhs] |- _ => destruct (zlt lhs rhs)
    end;
    simpl in Hmode;
    discriminate.
Qed.

Theorem unload_throw_matrix_lhs_access_mode :
  access_mode (typeof unload_throw_matrix_lhs) = By_value Mint32.
Proof. reflexivity. Qed.

Theorem unload_graph_flags_lhs_access_mode :
  access_mode (typeof unload_graph_flags_lhs) = By_value Mint16signed.
Proof. reflexivity. Qed.

Theorem unload_object_header_lhs_access_mode :
  access_mode (typeof unload_object_header_lhs) = By_copy.
Proof. reflexivity. Qed.

Definition pointer_slot_deactivated
    (memory : mem) (object_block : block) (object_offset : ptrofs) : Prop :=
  Mem.load Mint16signed memory object_block
    (Ptrofs.unsigned
      (Ptrofs.add object_offset (Ptrofs.repr object_active_flags_offset))) =
  Some (Vint Int.zero).

Definition active_flags_byte
    (object_block : block) (object_offset : ptrofs)
    (block_at_byte : block) (byte_offset : Z) : Prop :=
  block_at_byte = object_block /\
  Ptrofs.unsigned
    (Ptrofs.add object_offset (Ptrofs.repr object_active_flags_offset)) <=
    byte_offset <
  Ptrofs.unsigned
    (Ptrofs.add object_offset (Ptrofs.repr object_active_flags_offset)) +
    size_chunk Mint16signed.

Lemma unchanged_on_active_flags_preserves_pointer_slot_deactivated :
  forall memory memory' object_block object_offset,
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory' ->
    pointer_slot_deactivated memory object_block object_offset ->
    pointer_slot_deactivated memory' object_block object_offset.
Proof.
  intros memory memory' object_block object_offset Hunchanged Hdeactivated.
  unfold pointer_slot_deactivated in *.
  eapply Mem.load_unchanged_on; eauto.
  intros byte Hrange.
  split; [reflexivity | exact Hrange].
Qed.

Theorem pool_slot_active_flags_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr object_active_flags_offset)) =
    object_field_address slot object_active_flags_offset.
Proof.
  intros slot Hslot.
  unfold valid_object_slot, object_pool_capacity in Hslot.
  unfold object_field_address, object_slot_size,
    object_active_flags_offset.
  assert (Hbase :
    Ptrofs.unsigned (Ptrofs.repr (slot * 608)) = slot * 608).
  { apply Ptrofs.unsigned_repr.
    change Ptrofs.max_unsigned with 4294967295.
    lia. }
  assert (Hfield :
    Ptrofs.unsigned (Ptrofs.repr 116) = 116).
  { apply Ptrofs.unsigned_repr.
    change Ptrofs.max_unsigned with 4294967295.
    lia. }
  rewrite Ptrofs.add_unsigned, Hbase, Hfield.
  rewrite Ptrofs.unsigned_repr.
  - reflexivity.
  - change Ptrofs.max_unsigned with 4294967295.
    lia.
Qed.

Theorem pool_slot_field_address :
  forall slot field_offset,
    valid_object_slot slot ->
    0 <= field_offset <= object_slot_size ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr field_offset)) =
    object_field_address slot field_offset.
Proof.
  intros slot field_offset Hslot Hfield.
  unfold valid_object_slot, object_pool_capacity in Hslot.
  unfold object_field_address, object_slot_size in *.
  assert (Hbase :
    Ptrofs.unsigned (Ptrofs.repr (slot * 608)) = slot * 608).
  { apply Ptrofs.unsigned_repr.
    change Ptrofs.max_unsigned with 4294967295.
    lia. }
  assert (Hfield_unsigned :
    Ptrofs.unsigned (Ptrofs.repr field_offset) = field_offset).
  { apply Ptrofs.unsigned_repr.
    change Ptrofs.max_unsigned with 4294967295.
    lia. }
  rewrite Ptrofs.add_unsigned, Hbase, Hfield_unsigned.
  rewrite Ptrofs.unsigned_repr.
  - reflexivity.
  - change Ptrofs.max_unsigned with 4294967295.
    lia.
Qed.

Theorem pool_slot_prev_obj_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 108)) =
    object_field_address slot 108.
Proof.
  intros slot Hvalid.
  apply pool_slot_field_address; [exact Hvalid |].
  unfold object_slot_size.
  lia.
Qed.

Theorem pool_slot_header_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 0)) =
    object_field_address slot 0.
Proof.
  intros slot Hvalid.
  apply pool_slot_field_address; [exact Hvalid |].
  unfold object_slot_size.
  lia.
Qed.

Theorem pool_slot_node_next_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 96)) =
    object_field_address slot 96.
Proof.
  intros slot Hvalid.
  apply pool_slot_field_address; [exact Hvalid |].
  unfold object_slot_size.
  lia.
Qed.

Theorem pool_slot_node_prev_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 100)) =
    object_field_address slot 100.
Proof.
  intros slot Hvalid.
  apply pool_slot_field_address; [exact Hvalid |].
  unfold object_slot_size.
  lia.
Qed.

Theorem pool_slot_throw_matrix_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 80)) =
    object_field_address slot 80.
Proof.
  intros slot Hvalid.
  apply pool_slot_field_address; [exact Hvalid |].
  unfold object_slot_size.
  lia.
Qed.

Theorem pool_slot_throw_matrix_nested_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.add
          (Ptrofs.add
            (Ptrofs.repr ((slot * object_slot_size)%Z))
            (Ptrofs.repr 0))
          (Ptrofs.repr 0))
        (Ptrofs.repr 80)) =
    object_field_address slot 80.
Proof.
  intros slot Hvalid.
  change (Ptrofs.repr 0) with Ptrofs.zero.
  repeat rewrite Ptrofs.add_zero.
  apply pool_slot_throw_matrix_address.
  exact Hvalid.
Qed.

Theorem pool_slot_graph_flags_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 2)) =
    object_field_address slot 2.
Proof.
  intros slot Hvalid.
  apply pool_slot_field_address; [exact Hvalid |].
  unfold object_slot_size.
  lia.
Qed.

Theorem pool_slot_graph_flags_nested_address :
  forall slot,
    valid_object_slot slot ->
    Ptrofs.unsigned
      (Ptrofs.add
        (Ptrofs.add
          (Ptrofs.add
            (Ptrofs.add
              (Ptrofs.repr ((slot * object_slot_size)%Z))
              (Ptrofs.repr 0))
            (Ptrofs.repr 0))
          (Ptrofs.repr 0))
        (Ptrofs.repr 2)) =
    object_field_address slot 2.
Proof.
  intros slot Hvalid.
  change (Ptrofs.repr 0) with Ptrofs.zero.
  repeat rewrite Ptrofs.add_zero.
  apply pool_slot_graph_flags_address.
  exact Hvalid.
Qed.

Lemma pool_slot_active_flags_byte_range :
  forall pool_block slot byte,
    valid_object_slot slot ->
    active_flags_byte pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z))
      pool_block byte ->
    object_field_address slot object_active_flags_offset <= byte <
    object_field_address slot object_active_flags_offset +
    size_chunk Mint16signed.
Proof.
  intros pool_block slot byte Hvalid Hbyte.
  unfold active_flags_byte in Hbyte.
  destruct Hbyte as (_ & Hrange).
  rewrite pool_slot_active_flags_address in Hrange by exact Hvalid.
  exact Hrange.
Qed.

Lemma pool_slot_store_range_misses_active_flags :
  forall pool_block slot store_offset store_size byte,
    valid_object_slot slot ->
    (store_offset + store_size <= object_active_flags_offset \/
     object_active_flags_offset + size_chunk Mint16signed <= store_offset) ->
    object_field_address slot store_offset <= byte <
    object_field_address slot store_offset + store_size ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        pool_block byte.
Proof.
  intros pool_block slot store_offset store_size byte Hvalid Hseparate
    Hstore_range Hactive.
  pose proof
    (pool_slot_active_flags_byte_range
      pool_block slot byte Hvalid Hactive) as Hactive_range.
  unfold object_field_address in *.
  lia.
Qed.

Theorem pool_slot_prev_obj_store_misses_active_flags :
  forall pool_block slot byte,
    valid_object_slot slot ->
    object_field_address slot 108 <= byte <
    object_field_address slot 108 + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        pool_block byte.
Proof.
  intros pool_block slot byte Hvalid Hrange.
  eapply pool_slot_store_range_misses_active_flags; eauto.
  left.
  unfold object_active_flags_offset.
  lia.
Qed.

Theorem pool_slot_throw_matrix_store_misses_active_flags :
  forall pool_block slot byte,
    valid_object_slot slot ->
    object_field_address slot 80 <= byte <
    object_field_address slot 80 + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        pool_block byte.
Proof.
  intros pool_block slot byte Hvalid Hrange.
  eapply pool_slot_store_range_misses_active_flags; eauto.
  left.
  unfold object_active_flags_offset.
  lia.
Qed.

Theorem pool_slot_graph_flags_store_misses_active_flags :
  forall pool_block slot byte,
    valid_object_slot slot ->
    object_field_address slot 2 <= byte <
    object_field_address slot 2 + 2 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        pool_block byte.
Proof.
  intros pool_block slot byte Hvalid Hrange.
  eapply pool_slot_store_range_misses_active_flags; eauto.
  left.
  unfold object_active_flags_offset.
  lia.
Qed.

Theorem pool_slot_node_next_store_misses_active_flags :
  forall pool_block slot byte,
    valid_object_slot slot ->
    object_field_address slot 96 <= byte <
    object_field_address slot 96 + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        pool_block byte.
Proof.
  intros pool_block slot byte Hvalid Hrange.
  eapply pool_slot_store_range_misses_active_flags; eauto.
  left.
  unfold object_active_flags_offset.
  lia.
Qed.

Theorem pool_slot_node_prev_store_misses_active_flags :
  forall pool_block slot byte,
    valid_object_slot slot ->
    object_field_address slot 100 <= byte <
    object_field_address slot 100 + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        pool_block byte.
Proof.
  intros pool_block slot byte Hvalid Hrange.
  eapply pool_slot_store_range_misses_active_flags; eauto.
  left.
  unfold object_active_flags_offset.
  lia.
Qed.

Definition object_node_pointer_external_or_pool_slot_header
    (pool_block node_block : block) (node_offset : ptrofs) : Prop :=
  node_block <> pool_block \/
  exists node_slot,
    valid_object_slot node_slot /\
    node_offset = Ptrofs.repr (node_slot * object_slot_size).

Definition temp_points_to_external_or_pool_slot_header
    (le : temp_env) (temporary : ident) (pool_block : block) : Prop :=
  forall node_block node_offset,
    le ! temporary = Some (Vptr node_block node_offset) ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset.

Definition object_node_field_expr (source field : ident) : expr :=
  Efield
    (Ederef
      (Etempvar source (tptr (Tstruct S._ObjectNode noattr)))
      (Tstruct S._ObjectNode noattr))
    field (tptr (Tstruct S._ObjectNode noattr)).

Definition object_node_field_deref_shape
    (memory : mem) (pool_block source_block : block)
    (source_offset : ptrofs) (field_delta : Z) : Prop :=
  forall target_block target_offset,
    deref_loc (tptr (Tstruct S._ObjectNode noattr)) memory
      source_block (Ptrofs.add source_offset (Ptrofs.repr field_delta))
      Full (Vptr target_block target_offset) ->
    object_node_pointer_external_or_pool_slot_header
      pool_block target_block target_offset.

Definition object_node_field_value_shape
    (e : env) (le : temp_env) (memory : mem)
    (source field : ident) (pool_block : block) : Prop :=
  forall target_block target_offset,
    eval_expr unload_object_ge e le memory
      (object_node_field_expr source field)
      (Vptr target_block target_offset) ->
    object_node_pointer_external_or_pool_slot_header
      pool_block target_block target_offset.

Lemma temp_points_to_external_block :
  forall le temporary pool_block external_block external_offset,
    external_block <> pool_block ->
    le ! temporary = Some (Vptr external_block external_offset) ->
    temp_points_to_external_or_pool_slot_header
      le temporary pool_block.
Proof.
  intros le temporary pool_block external_block external_offset
    Hexternal Hlookup.
  unfold temp_points_to_external_or_pool_slot_header.
  intros node_block node_offset Hnode.
  assert (node_block = external_block) by congruence.
  subst node_block.
  left.
  exact Hexternal.
Qed.

Lemma temp_points_to_pool_slot_header :
  forall le temporary pool_block slot,
    valid_object_slot slot ->
    le ! temporary =
      Some (Vptr pool_block (Ptrofs.repr (slot * object_slot_size))) ->
    temp_points_to_external_or_pool_slot_header
      le temporary pool_block.
Proof.
  intros le temporary pool_block slot Hvalid Hlookup.
  unfold temp_points_to_external_or_pool_slot_header.
  intros node_block node_offset Hnode.
  assert (node_block = pool_block) by congruence.
  assert (node_offset = Ptrofs.repr (slot * object_slot_size))
    by congruence.
  subst node_block node_offset.
  right.
  exists slot.
  split; [exact Hvalid | reflexivity].
Qed.

Lemma exec_object_node_field_read_sets_temp_shape :
  forall target source field e le memory pool_block
         trace le' memory' outcome,
    object_node_field_value_shape e le memory source field pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Sset target (object_node_field_expr source field))
      trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' target pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros target source field e le memory pool_block
    trace le' memory' outcome Hshape Hexec.
  inv Hexec.
  split.
  - unfold temp_points_to_external_or_pool_slot_header.
    intros target_block target_offset Hlookup.
    rewrite PTree.gss in Hlookup.
    inv Hlookup.
    eapply Hshape; eauto.
  - split; reflexivity.
Qed.

Lemma temp_points_to_external_or_pool_slot_header_set_different :
  forall le temporary written value pool_block,
    Pos.eqb written temporary = false ->
    temp_points_to_external_or_pool_slot_header le temporary pool_block ->
    temp_points_to_external_or_pool_slot_header
      (PTree.set written value le) temporary pool_block.
Proof.
  intros le temporary written value pool_block Hdifferent Hshape.
  unfold temp_points_to_external_or_pool_slot_header in *.
  intros node_block node_offset Hlookup.
  apply Hshape.
  rewrite PTree.gso in Hlookup.
  - exact Hlookup.
  - intro Heq.
    subst written.
    rewrite Pos.eqb_refl in Hdifferent.
    discriminate.
Qed.

Lemma exec_sset_different_preserves_temp_shape :
  forall protected written expression e le memory pool_block
         trace le' memory' outcome,
    Pos.eqb written protected = false ->
    temp_points_to_external_or_pool_slot_header le protected pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Sset written expression) trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' protected pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros protected written expression e le memory pool_block
    trace le' memory' outcome Hdifferent Hshape Hexec.
  inv Hexec.
  split.
  - apply temp_points_to_external_or_pool_slot_header_set_different;
      assumption.
  - split; reflexivity.
Qed.

Lemma exec_sset_different_preserves_lookup :
  forall kept kept_value written expression e le memory
         trace le' memory' outcome,
    Pos.eqb written kept = false ->
    le ! kept = Some kept_value ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Sset written expression) trace le' memory' outcome ->
    le' ! kept = Some kept_value /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros kept kept_value written expression e le memory
    trace le' memory' outcome Hdifferent Hlookup Hexec.
  inv Hexec.
  split.
  - eapply PTree_set_preserves_different; eauto.
  - split; reflexivity.
Qed.

Lemma object_node_field_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset field_offset
         store_size byte,
    valid_object_slot watched_slot ->
    0 <= field_offset ->
    0 <= store_size ->
    field_offset + store_size <= object_slot_size ->
    field_offset + store_size <= object_active_flags_offset ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr field_offset)) <=
      byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr field_offset)) +
      store_size ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset field_offset
    store_size byte Hwatched Hfield_nonnegative Hstore_size_nonnegative
    Hfield_in_slot Hfield_before_active Hshape Hrange Hactive.
  destruct (peq node_block pool_block) as [Hsame_block | Hdifferent_block].
  - subst node_block.
    destruct Hshape as [Hneq | (node_slot & Hnode_valid & Hoffset)].
    + exfalso.
      apply Hneq.
      reflexivity.
    + subst node_offset.
      rewrite pool_slot_field_address in Hrange by
        (exact Hnode_valid || lia).
      pose proof
        (pool_slot_active_flags_byte_range
          pool_block watched_slot byte Hwatched Hactive) as Hactive_range.
      unfold object_field_address in *.
      unfold object_slot_size in *.
      destruct (Z.eq_dec node_slot watched_slot) as [Heq | Hneq].
      * subst node_slot.
        unfold object_active_flags_offset in *.
        change (size_chunk Mint16signed) with 2 in Hactive_range.
        lia.
      * unfold valid_object_slot, object_pool_capacity in *.
        unfold object_active_flags_offset in *.
        change (size_chunk Mint16signed) with 2 in Hactive_range.
        lia.
  - destruct Hactive as (Hblock & _).
    contradiction.
Qed.

Theorem object_node_next_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset byte,
    valid_object_slot watched_slot ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 96)) <= byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 96)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset byte
    Hvalid Hshape Hrange.
  eapply object_node_field_store_misses_active_flags_from_header_shape;
    eauto.
  - lia.
  - lia.
  - unfold object_slot_size; lia.
  - unfold object_active_flags_offset; lia.
Qed.

Theorem object_node_prev_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset byte,
    valid_object_slot watched_slot ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 100)) <= byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 100)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset byte
    Hvalid Hshape Hrange.
  eapply object_node_field_store_misses_active_flags_from_header_shape;
    eauto.
  - lia.
  - lia.
  - unfold object_slot_size; lia.
  - unfold object_active_flags_offset; lia.
Qed.

Theorem pointer_slot_deactivated_is_pool_slot :
  forall memory pool_block slot,
    valid_object_slot slot ->
    pointer_slot_deactivated memory pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) ->
    slot_deactivated memory pool_block slot.
Proof.
  intros memory pool_block slot Hvalid Hpointer.
  unfold pointer_slot_deactivated in Hpointer.
  unfold slot_deactivated.
  rewrite <- (pool_slot_active_flags_address slot Hvalid).
  exact Hpointer.
Qed.

Lemma assign_loc_tshort_zero_load_same :
  forall ce memory object_block object_offset memory',
    assign_loc ce tshort memory object_block object_offset Full
      (Vint Int.zero) memory' ->
    Mem.load Mint16signed memory' object_block
      (Ptrofs.unsigned object_offset) = Some (Vint Int.zero).
Proof.
  intros ce memory object_block object_offset memory' Hassign.
  inv Hassign.
  match goal with
  | Hmode : access_mode _ = By_value ?chunk,
    Hstore : Mem.storev ?chunk _ _ _ = Some _ |- _ =>
      simpl in Hmode;
      inversion Hmode;
      subst chunk;
      unfold Mem.storev in Hstore;
      erewrite Mem.load_store_same by exact Hstore;
      reflexivity
  end.
Qed.

Lemma exec_unload_active_flags_assign :
  forall (e : env) le memory object_block object_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr object_block object_offset) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_active_flags_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    pointer_slot_deactivated memory' object_block object_offset.
Proof.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hobj Hexec.
  unfold unload_active_flags_assign in Hexec.
  inv Hexec.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv
  end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with
  | Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee
  end.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with
  | He : eval_expr _ _ _ _ (Etempvar S._obj _) _ |- _ =>
      inv He;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : ?temps ! S._obj = Some (Vptr ?b ?ofs) |- _ =>
      first
        [ constr_eq ofs object_offset; fail 1
        | first
            [ constr_eq b object_block
            | assert (b = object_block) by congruence; subst b ];
          assert (ofs = object_offset) by congruence; subst ofs ]
  end.
  match goal with
  | Hderef : deref_loc _ _ _ _ _ _ |- _ =>
      cbn [typeof] in Hderef;
      inv Hderef
  end;
    try (match goal with
         | Hmode : access_mode (Tstruct _ _) = By_value _ |- _ =>
             discriminate
         end);
    try (match goal with
         | Hmode : access_mode (Tstruct _ _) = By_reference |- _ =>
             discriminate
         end).
  repeat match goal with
  | H : context[typeof (Efield _ _ _)] |- _ => cbn [typeof] in H
  | H : context[typeof (Ederef _ _)] |- _ => cbn [typeof] in H
  end.
  match goal with Hty : Tstruct _ _ = Tstruct _ _ |- _ => inv Hty end.
  rewrite unload_object_genv_cenv in *.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hco : unload_object_ce ! S._Object = Some ?co,
    Hfield :
      field_offset unload_object_ce S._activeFlags (co_members ?co) =
      OK (?delta, ?bf),
    Heval : eval_expr _ _ _ _ (Econst_int _ _) ?rhs_value,
    Hcast : sem_cast ?rhs_value _ _ _ = Some ?stored_value,
    Hassign :
      assign_loc unload_object_ce tshort ?memory0 ?object_block0
        (Ptrofs.add ?object_offset0 (Ptrofs.repr ?delta))
        ?bf ?stored_value memory' |- _ =>
      assert (Hmembers : co_members co = unload_object_members) by
        (unfold unload_object_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_object_active_flags_layout in Hfield;
      inv Hfield;
      inv Heval;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end);
      vm_compute in Hcast;
      inv Hcast;
      unfold pointer_slot_deactivated;
      apply assign_loc_tshort_zero_load_same in Hassign;
      exact Hassign
  end.
Qed.

Definition unload_object_tail_preserves_active_flags_bytes : Prop :=
  forall e le memory object_block object_offset trace le' memory' outcome,
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.

Definition unload_object_tail_preserves_active_flags_bytes_for_obj : Prop :=
  forall e le memory object_block object_offset trace le' memory' outcome,
    le ! S._obj = Some (Vptr object_block object_offset) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.

Definition statement_preserves_active_flags_bytes
    (statement_body : statement) : Prop :=
  forall e le memory object_block object_offset trace le' memory' outcome,
    exec_stmt function_entry2 unload_object_ge e le memory
      statement_body trace le' memory' outcome ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.

Fixpoint statement_leaf_frame_obligations
    (statement_body : statement) : Prop :=
  match statement_body with
  | Sskip => True
  | Sset _ _ => True
  | Ssequence first rest =>
      statement_leaf_frame_obligations first /\
      statement_leaf_frame_obligations rest
  | _ => statement_preserves_active_flags_bytes statement_body
  end.

Lemma statement_preserves_active_flags_bytes_skip :
  statement_preserves_active_flags_bytes Sskip.
Proof.
  unfold statement_preserves_active_flags_bytes.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hexec.
  inv Hexec.
  apply Mem.unchanged_on_refl.
Qed.

Lemma statement_preserves_active_flags_bytes_set :
  forall temporary expression,
    statement_preserves_active_flags_bytes (Sset temporary expression).
Proof.
  intros temporary expression.
  unfold statement_preserves_active_flags_bytes.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hexec.
  inv Hexec.
  apply Mem.unchanged_on_refl.
Qed.

Definition assign_loc_preserves_active_flags_bytes
    (lhs : expr) : Prop :=
  forall memory object_block object_offset store_block store_offset
         bitfield value memory',
    assign_loc unload_object_ce (typeof lhs) memory store_block store_offset
      bitfield value memory' ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.

Lemma assign_loc_by_value_preserves_active_flags_bytes :
  forall ty chunk memory object_block object_offset store_block store_offset
         value memory',
    access_mode ty = By_value chunk ->
    (forall byte,
      Ptrofs.unsigned store_offset <= byte <
      Ptrofs.unsigned store_offset + size_chunk chunk ->
      ~ active_flags_byte object_block object_offset store_block byte) ->
    assign_loc unload_object_ce ty memory store_block store_offset Full
      value memory' ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.
Proof.
  intros ty chunk memory object_block object_offset store_block store_offset
    value memory' Hmode Hdisjoint Hassign.
  inv Hassign; try congruence.
  match goal with
  | Hmode' : access_mode ty = By_value ?stored_chunk,
    Hstore : Mem.storev ?stored_chunk _ (Vptr store_block store_offset) _ =
      Some _ |- _ =>
      assert (stored_chunk = chunk) by congruence;
      subst stored_chunk;
      unfold Mem.storev in Hstore;
      eapply Mem.store_unchanged_on; eauto;
      intros byte Hrange;
      apply Hdisjoint;
      exact Hrange
  end.
Qed.

Lemma eval_deallocate_object_node_base_expr_pointer :
  forall e le memory pool_block slot loc ofs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_expr unload_object_ge e le memory
      deallocate_object_node_base_expr (Vptr loc ofs) ->
    loc = pool_block /\
    ofs = Ptrofs.repr ((slot * object_slot_size)%Z).
Proof.
  intros e le memory pool_block slot loc ofs Hvalid Hobj Hexpr.
  unfold deallocate_object_node_base_expr in Hexpr.
  inv Hexpr.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with
  | Htemp : eval_expr _ _ _ _ (Etempvar S._obj _) _ |- _ =>
      inv Htemp;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : le ! S._obj = Some (Vptr ?block ?offset) |- _ =>
      assert (block = pool_block) by congruence;
      assert (offset = Ptrofs.repr (slot * object_slot_size)) by congruence;
      subst block offset
  end.
  pose proof
    (deref_loc_by_copy_pointer
      (typeof deallocate_object_node_base_expr)
      memory pool_block (Ptrofs.repr (slot * object_slot_size))
      (Vptr loc ofs) eq_refl H0) as Hcopy.
  inv Hcopy.
  split; reflexivity.
Qed.

Lemma eval_object_node_temp_deref_pointer_with_lookup :
  forall temporary e le memory loc ofs,
    eval_expr unload_object_ge e le memory
      (Ederef
        (Etempvar temporary (tptr (Tstruct S._ObjectNode noattr)))
        (Tstruct S._ObjectNode noattr))
      (Vptr loc ofs) ->
    le ! temporary = Some (Vptr loc ofs).
Proof.
  intros temporary e le memory loc ofs Hexpr.
  inv Hexpr.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with
  | Htemp : eval_expr _ _ _ _
      (Etempvar temporary _) _ |- _ =>
      inv Htemp;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : le ! temporary = Some (Vptr ?base_block ?base_ofs),
    Hderef : deref_loc _ memory ?base_block ?base_ofs Full
      (Vptr loc ofs) |- _ =>
      pose proof
        (deref_loc_by_copy_pointer
          (Tstruct S._ObjectNode noattr)
          memory base_block base_ofs (Vptr loc ofs)
          eq_refl Hderef) as Hcopy;
      inv Hcopy;
      exact Hlookup
  end.
Qed.

Lemma eval_object_node_temp_field_lvalue :
  forall temporary field field_delta e le memory loc ofs bf,
    field_offset unload_object_ce field unload_object_node_members =
      OK (field_delta, Full) ->
    eval_lvalue unload_object_ge e le memory
      (Efield
        (Ederef
          (Etempvar temporary (tptr (Tstruct S._ObjectNode noattr)))
          (Tstruct S._ObjectNode noattr))
        field (tptr (Tstruct S._ObjectNode noattr)))
      loc ofs bf ->
    exists base_block base_ofs,
      le ! temporary = Some (Vptr base_block base_ofs) /\
      loc = base_block /\
      ofs = Ptrofs.add base_ofs (Ptrofs.repr field_delta) /\
      bf = Full.
Proof.
  intros temporary field field_delta e le memory loc ofs bf
    Hlayout Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty :
      typeof
        (Ederef
          (Etempvar temporary (tptr (Tstruct S._ObjectNode noattr)))
          (Tstruct S._ObjectNode noattr)) = Tstruct _ _ |- _ =>
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._ObjectNode = Some ?co,
    Hfield :
      field_offset unload_object_ce field (co_members ?co) =
      OK (?delta, ?bf0) |- _ =>
      assert (Hmembers : co_members co = unload_object_node_members) by
        (unfold unload_object_node_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite Hlayout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hbase :
      eval_expr unload_object_ge e le memory
        (Ederef
          (Etempvar temporary (tptr (Tstruct S._ObjectNode noattr)))
          (Tstruct S._ObjectNode noattr))
        (Vptr ?base_block ?base_ofs) |- _ =>
      exists base_block, base_ofs;
      split;
      [ eapply eval_object_node_temp_deref_pointer_with_lookup;
        exact Hbase
      | split; [reflexivity | split; reflexivity] ]
  end.
Qed.

Lemma object_node_field_value_shape_from_deref_shape :
  forall e le memory source field field_delta pool_block
         source_block source_offset,
    field_offset unload_object_ce field unload_object_node_members =
      OK (field_delta, Full) ->
    le ! source = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset field_delta ->
    object_node_field_value_shape e le memory source field pool_block.
Proof.
  intros e le memory source field field_delta pool_block
    source_block source_offset Hlayout Hsource Hshape.
  unfold object_node_field_value_shape, object_node_field_expr.
  intros target_block target_offset Hexpr.
  inv Hexpr.
  match goal with
  | Hlv :
      eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
      destruct
        (eval_object_node_temp_field_lvalue
          source field field_delta e le memory loc ofs bf
          Hlayout Hlv)
        as (base_block & base_offset & Hbase & Hloc & Hofs & Hbf);
      subst loc ofs bf;
      assert (base_block = source_block) by congruence;
      assert (base_offset = source_offset) by congruence;
      subst base_block base_offset
  end.
  match goal with
  | Hderef :
      deref_loc _ memory source_block
        (Ptrofs.add source_offset (Ptrofs.repr field_delta))
        Full (Vptr target_block target_offset) |- _ =>
      exact (Hshape target_block target_offset Hderef)
  end.
Qed.

Lemma exec_object_node_field_read_sets_temp_shape_from_deref_shape :
  forall target source field field_delta e le memory pool_block
         source_block source_offset trace le' memory' outcome,
    field_offset unload_object_ce field unload_object_node_members =
      OK (field_delta, Full) ->
    le ! source = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset field_delta ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Sset target (object_node_field_expr source field))
      trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' target pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros target source field field_delta e le memory pool_block
    source_block source_offset trace le' memory' outcome
    Hlayout Hsource Hshape Hexec.
  eapply exec_object_node_field_read_sets_temp_shape; eauto.
  eapply object_node_field_value_shape_from_deref_shape; eauto.
Qed.

Lemma exec_deallocate_object_read_next_sets_t4_shape_from_deref_shape :
  forall e le memory pool_block source_block source_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset 96 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_read_next trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' S._t'4 pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros e le memory pool_block source_block source_offset
    trace le' memory' outcome Hsource Hshape Hexec.
  eapply
    (exec_object_node_field_read_sets_temp_shape_from_deref_shape
      S._t'4 S._obj S._next 96).
  - apply unload_object_node_next_layout.
  - exact Hsource.
  - exact Hshape.
  - exact Hexec.
Qed.

Lemma exec_deallocate_object_read_prev_sets_t5_shape_from_deref_shape :
  forall e le memory pool_block source_block source_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset 100 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_read_prev trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' S._t'5 pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros e le memory pool_block source_block source_offset
    trace le' memory' outcome Hsource Hshape Hexec.
  eapply
    (exec_object_node_field_read_sets_temp_shape_from_deref_shape
      S._t'5 S._obj S._prev 100).
  - apply unload_object_node_prev_layout.
  - exact Hsource.
  - exact Hshape.
  - exact Hexec.
Qed.

Lemma exec_deallocate_object_read_prev_again_sets_t2_shape_from_deref_shape :
  forall e le memory pool_block source_block source_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset 100 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_read_prev_again trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' S._t'2 pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros e le memory pool_block source_block source_offset
    trace le' memory' outcome Hsource Hshape Hexec.
  eapply
    (exec_object_node_field_read_sets_temp_shape_from_deref_shape
      S._t'2 S._obj S._prev 100).
  - apply unload_object_node_prev_layout.
  - exact Hsource.
  - exact Hshape.
  - exact Hexec.
Qed.

Lemma exec_deallocate_object_read_next_again_sets_t3_shape_from_deref_shape :
  forall e le memory pool_block source_block source_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset 96 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_read_next_again trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' S._t'3 pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros e le memory pool_block source_block source_offset
    trace le' memory' outcome Hsource Hshape Hexec.
  eapply
    (exec_object_node_field_read_sets_temp_shape_from_deref_shape
      S._t'3 S._obj S._next 96).
  - apply unload_object_node_next_layout.
  - exact Hsource.
  - exact Hshape.
  - exact Hexec.
Qed.

Lemma exec_deallocate_object_read_free_next_sets_t1_shape_from_deref_shape :
  forall e le memory pool_block source_block source_offset
         trace le' memory' outcome,
    le ! S._freeList = Some (Vptr source_block source_offset) ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset 96 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_read_free_next trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' S._t'1 pool_block /\
    memory' = memory /\
    outcome = Out_normal.
Proof.
  intros e le memory pool_block source_block source_offset
    trace le' memory' outcome Hsource Hshape Hexec.
  eapply
    (exec_object_node_field_read_sets_temp_shape_from_deref_shape
      S._t'1 S._freeList S._next 96).
  - apply unload_object_node_next_layout.
  - exact Hsource.
  - exact Hshape.
  - exact Hexec.
Qed.

Lemma eval_deallocate_object_obj_next_lhs_pool_slot :
  forall e le memory pool_block slot loc ofs bf,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_lvalue unload_object_ge e le memory
      deallocate_object_obj_next_lhs loc ofs bf ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 96) /\
    bf = Full.
Proof.
  intros e le memory pool_block slot loc ofs bf Hvalid Hobj Hlv.
  unfold deallocate_object_obj_next_lhs in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof deallocate_object_node_base_expr = Tstruct _ _ |- _ =>
      unfold deallocate_object_node_base_expr in Hty;
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._ObjectNode = Some ?co,
    Hfield :
      field_offset unload_object_ce S._next (co_members ?co) =
      OK (?delta, ?bf0) |- _ =>
      assert (Hmembers : co_members co = unload_object_node_members) by
        (unfold unload_object_node_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_object_node_next_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hbase :
      eval_expr unload_object_ge e le memory
        deallocate_object_node_base_expr (Vptr ?base_block ?base_ofs) |- _ =>
      destruct
        (eval_deallocate_object_node_base_expr_pointer
          e le memory pool_block slot base_block base_ofs
          Hvalid Hobj Hbase) as (Hblock & Hofs);
      subst base_block base_ofs
  end.
  split; [reflexivity | split; reflexivity].
Qed.

Lemma exec_deallocate_object_obj_next_assign_preserves_active_flags :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_obj_next_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  unfold deallocate_object_obj_next_assign in Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hlv :
      eval_lvalue _ ?env ?temps ?mem deallocate_object_obj_next_lhs
        ?loc ?ofs ?bf |- _ =>
      destruct
        (eval_deallocate_object_obj_next_lhs_pool_slot
          env temps mem pool_block slot loc ofs bf Hvalid Hobj Hlv)
        as (Hloc & Hofs & Hbf);
      subst loc ofs bf
  end.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint32) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        rewrite pool_slot_node_next_address in Hrange by exact Hvalid;
        change (size_chunk Mint32) with 4 in Hrange;
        eapply pool_slot_node_next_store_misses_active_flags; eauto ]
  end.
Qed.

Lemma exec_deallocate_object_next_prev_assign_preserves_active_flags_from_target_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._t'4 pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_next_prev_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Htarget_shape Hexec.
  unfold deallocate_object_next_prev_assign in Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hlv :
      eval_lvalue _ ?env ?temps ?mem deallocate_object_next_prev_lhs
        ?loc ?ofs ?bf |- _ =>
      unfold deallocate_object_next_prev_lhs in Hlv;
      destruct
        (eval_object_node_temp_field_lvalue
          S._t'4 S._prev 100 env temps mem loc ofs bf
          unload_object_node_prev_layout Hlv)
        as (target_block & target_offset & Hlookup & Hloc & Hofs & Hbf);
      subst loc ofs bf;
      pose proof
        (Htarget_shape target_block target_offset Hlookup)
        as Htarget
  end.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _,
    Htarget :
      object_node_pointer_external_or_pool_slot_header _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint32) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        change (size_chunk Mint32) with 4 in Hrange;
        eapply object_node_prev_store_misses_active_flags_from_header_shape;
          eauto ]
  end.
Qed.

Lemma exec_deallocate_object_prev_next_assign_preserves_active_flags_from_target_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._t'2 pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_prev_next_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Htarget_shape Hexec.
  unfold deallocate_object_prev_next_assign in Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hlv :
      eval_lvalue _ ?env ?temps ?mem deallocate_object_prev_next_lhs
        ?loc ?ofs ?bf |- _ =>
      unfold deallocate_object_prev_next_lhs in Hlv;
      destruct
        (eval_object_node_temp_field_lvalue
          S._t'2 S._next 96 env temps mem loc ofs bf
          unload_object_node_next_layout Hlv)
        as (target_block & target_offset & Hlookup & Hloc & Hofs & Hbf);
      subst loc ofs bf;
      pose proof
        (Htarget_shape target_block target_offset Hlookup)
        as Htarget
  end.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _,
    Htarget :
      object_node_pointer_external_or_pool_slot_header _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint32) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        change (size_chunk Mint32) with 4 in Hrange;
        eapply object_node_next_store_misses_active_flags_from_header_shape;
          eauto ]
  end.
Qed.

Lemma exec_deallocate_object_free_list_next_assign_preserves_active_flags_from_target_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._freeList pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_free_list_next_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Htarget_shape Hexec.
  unfold deallocate_object_free_list_next_assign in Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hlv :
      eval_lvalue _ ?env ?temps ?mem deallocate_object_free_list_next_lhs
        ?loc ?ofs ?bf |- _ =>
      unfold deallocate_object_free_list_next_lhs in Hlv;
      destruct
        (eval_object_node_temp_field_lvalue
          S._freeList S._next 96 env temps mem loc ofs bf
          unload_object_node_next_layout Hlv)
        as (target_block & target_offset & Hlookup & Hloc & Hofs & Hbf);
      subst loc ofs bf;
      pose proof
        (Htarget_shape target_block target_offset Hlookup)
        as Htarget
  end.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _,
    Htarget :
      object_node_pointer_external_or_pool_slot_header _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint32) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        change (size_chunk Mint32) with 4 in Hrange;
        eapply object_node_next_store_misses_active_flags_from_header_shape;
          eauto ]
  end.
Qed.

Lemma exec_unload_prev_obj_assign_preserves_active_flags :
  forall (e : env) le memory pool_block slot
         trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_prev_obj_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  unfold unload_prev_obj_assign in Hexec.
  inv Hexec.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv
  end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with
  | Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee
  end.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with
  | He : eval_expr _ _ _ _ (Etempvar S._obj _) _ |- _ =>
      inv He;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : ?temps ! S._obj = Some (Vptr ?b ?ofs) |- _ =>
      first
        [ constr_eq ofs (Ptrofs.repr (slot * object_slot_size)); fail 1
        | first
            [ constr_eq b pool_block
            | assert (b = pool_block) by congruence; subst b ];
          assert (ofs = Ptrofs.repr (slot * object_slot_size)) by congruence;
          subst ofs ]
  end.
  match goal with
  | Hderef : deref_loc _ _ _ _ _ _ |- _ =>
      cbn [typeof] in Hderef;
      inv Hderef
  end;
    try (match goal with
         | Hmode : access_mode (Tstruct _ _) = By_value _ |- _ =>
             discriminate
         end);
    try (match goal with
         | Hmode : access_mode (Tstruct _ _) = By_reference |- _ =>
             discriminate
         end).
  repeat match goal with
  | H : context[typeof (Efield _ _ _)] |- _ => cbn [typeof] in H
  | H : context[typeof (Ederef _ _)] |- _ => cbn [typeof] in H
  end.
  match goal with Hty : Tstruct _ _ = Tstruct _ _ |- _ => inv Hty end.
  rewrite unload_object_genv_cenv in *.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hco : unload_object_ce ! S._Object = Some ?co,
    Hfield :
      field_offset unload_object_ce S._prevObj (co_members ?co) =
      OK (?delta, ?bf) |- _ =>
      assert (Hmembers : co_members co = unload_object_members) by
        (unfold unload_object_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_object_prev_obj_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint32) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        rewrite pool_slot_prev_obj_address in Hrange by exact Hvalid;
        change (size_chunk Mint32) with 4 in Hrange;
        eapply pool_slot_prev_obj_store_misses_active_flags; eauto ]
      end.
Qed.

Lemma eval_unload_object_base_expr_pointer :
  forall e le memory pool_block slot loc ofs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_expr unload_object_ge e le memory
      unload_object_base_expr (Vptr loc ofs) ->
    loc = pool_block /\
    ofs = Ptrofs.repr ((slot * object_slot_size)%Z).
Proof.
  intros e le memory pool_block slot loc ofs Hvalid Hobj Hexpr.
  unfold unload_object_base_expr in Hexpr.
  inv Hexpr.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with
  | Htemp : eval_expr _ _ _ _ (Etempvar S._obj _) _ |- _ =>
      inv Htemp;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : le ! S._obj = Some (Vptr ?block ?offset) |- _ =>
      assert (block = pool_block) by congruence;
      assert (offset = Ptrofs.repr (slot * object_slot_size)) by congruence;
      subst block offset
  end.
  pose proof
    (deref_loc_by_copy_pointer
      (typeof unload_object_base_expr)
      memory pool_block (Ptrofs.repr (slot * object_slot_size))
      (Vptr loc ofs) eq_refl H0) as Hcopy.
  inv Hcopy.
  split; reflexivity.
Qed.

Lemma eval_unload_object_header_expr_pointer :
  forall e le memory pool_block slot loc ofs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_expr unload_object_ge e le memory
      unload_object_header_expr (Vptr loc ofs) ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr 0).
Proof.
  intros e le memory pool_block slot loc ofs Hvalid Hobj Hexpr.
  unfold unload_object_header_expr in Hexpr.
  inv Hexpr.
  pose proof
    (deref_loc_by_copy_pointer_any_bitfield
      (typeof unload_object_header_expr)
      _ _ _ _ _ eq_refl H0) as Hcopy.
  destruct Hcopy as (Hbf & Hcopy).
  subst bf.
  inv Hcopy.
  match goal with
  | Hlv :
      eval_lvalue _ _ _ _
        (Efield unload_object_base_expr S._header _) _ _ _ |- _ =>
      inv Hlv
  end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof unload_object_base_expr = Tstruct _ _ |- _ =>
      unfold unload_object_base_expr in Hty;
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._Object = Some ?co,
    Hfield :
      field_offset unload_object_ce S._header (co_members ?co) =
      OK (?delta, ?bf) |- _ =>
      assert (Hmembers : co_members co = unload_object_members) by
        (unfold unload_object_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_object_header_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hbase :
      eval_expr unload_object_ge e le memory
        unload_object_base_expr (Vptr ?base_block ?base_ofs) |- _ =>
      destruct
        (eval_unload_object_base_expr_pointer
          e le memory pool_block slot base_block base_ofs
          Hvalid Hobj Hbase) as (Hblock & Hofs);
      subst base_block base_ofs
  end.
  split; reflexivity.
Qed.

Lemma eval_unload_object_gfx_expr_pointer :
  forall e le memory pool_block slot loc ofs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_expr unload_object_ge e le memory
      unload_object_gfx_expr (Vptr loc ofs) ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.add
          (Ptrofs.repr ((slot * object_slot_size)%Z))
          (Ptrofs.repr 0))
        (Ptrofs.repr 0).
Proof.
  intros e le memory pool_block slot loc ofs Hvalid Hobj Hexpr.
  unfold unload_object_gfx_expr in Hexpr.
  inv Hexpr.
  pose proof
    (deref_loc_by_copy_pointer_any_bitfield
      (typeof unload_object_gfx_expr)
      _ _ _ _ _ eq_refl H0) as Hcopy.
  destruct Hcopy as (Hbf & Hcopy).
  subst bf.
  inv Hcopy.
  match goal with
  | Hlv :
      eval_lvalue _ _ _ _
        (Efield unload_object_header_expr S._gfx _) _ _ _ |- _ =>
      inv Hlv
  end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof unload_object_header_expr = Tstruct _ _ |- _ =>
      unfold unload_object_header_expr in Hty;
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._ObjectNode = Some ?co,
    Hfield :
      field_offset unload_object_ce S._gfx (co_members ?co) =
      OK (?delta, ?bf) |- _ =>
      assert (Hmembers : co_members co = unload_object_node_members) by
        (unfold unload_object_node_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_object_node_gfx_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hheader :
      eval_expr unload_object_ge e le memory
        unload_object_header_expr (Vptr ?header_block ?header_ofs) |- _ =>
      destruct
        (eval_unload_object_header_expr_pointer
          e le memory pool_block slot header_block header_ofs
          Hvalid Hobj Hheader) as (Hblock & Hofs);
      subst header_block header_ofs
  end.
  split; reflexivity.
Qed.

Lemma eval_unload_throw_matrix_lhs_pool_slot :
  forall e le memory pool_block slot loc ofs bf,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_lvalue unload_object_ge e le memory
      unload_throw_matrix_lhs loc ofs bf ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.add
          (Ptrofs.add
            (Ptrofs.repr ((slot * object_slot_size)%Z))
            (Ptrofs.repr 0))
          (Ptrofs.repr 0))
        (Ptrofs.repr 80) /\
    bf = Full.
Proof.
  intros e le memory pool_block slot loc ofs bf Hvalid Hobj Hlv.
  change unload_throw_matrix_lhs with
    (Efield unload_object_gfx_expr S._throwMatrix
      (tptr (tarray (tarray tfloat 4) 4))) in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof unload_object_gfx_expr = Tstruct _ _ |- _ =>
      unfold unload_object_gfx_expr in Hty;
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._GraphNodeObject = Some ?co,
    Hfield :
      field_offset unload_object_ce S._throwMatrix (co_members ?co) =
      OK (?delta, ?bf0) |- _ =>
      assert (Hmembers : co_members co = unload_graph_node_object_members) by
        (unfold unload_graph_node_object_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_object_throw_matrix_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hgfx :
      eval_expr unload_object_ge e le memory
        unload_object_gfx_expr (Vptr ?gfx_block ?gfx_ofs) |- _ =>
      destruct
        (eval_unload_object_gfx_expr_pointer
          e le memory pool_block slot gfx_block gfx_ofs
          Hvalid Hobj Hgfx) as (Hblock & Hofs);
      subst gfx_block gfx_ofs
  end.
  split; [reflexivity | split; reflexivity].
Qed.

Lemma eval_unload_object_graph_node_expr_pointer :
  forall e le memory pool_block slot loc ofs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_expr unload_object_ge e le memory
      unload_object_graph_node_expr (Vptr loc ofs) ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.add
          (Ptrofs.add
            (Ptrofs.repr ((slot * object_slot_size)%Z))
            (Ptrofs.repr 0))
          (Ptrofs.repr 0))
        (Ptrofs.repr 0).
Proof.
  intros e le memory pool_block slot loc ofs Hvalid Hobj Hexpr.
  unfold unload_object_graph_node_expr in Hexpr.
  inv Hexpr.
  pose proof
    (deref_loc_by_copy_pointer_any_bitfield
      (typeof unload_object_graph_node_expr)
      _ _ _ _ _ eq_refl H0) as Hcopy.
  destruct Hcopy as (Hbf & Hcopy).
  subst bf.
  inv Hcopy.
  match goal with
  | Hlv :
      eval_lvalue _ _ _ _
        (Efield unload_object_gfx_expr S._node _) _ _ _ |- _ =>
      inv Hlv
  end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof unload_object_gfx_expr = Tstruct _ _ |- _ =>
      unfold unload_object_gfx_expr in Hty;
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._GraphNodeObject = Some ?co,
    Hfield :
      field_offset unload_object_ce S._node (co_members ?co) =
      OK (?delta, ?bf) |- _ =>
      assert (Hmembers : co_members co = unload_graph_node_object_members) by
        (unfold unload_graph_node_object_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_graph_node_object_node_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hgfx :
      eval_expr unload_object_ge e le memory
        unload_object_gfx_expr (Vptr ?gfx_block ?gfx_ofs) |- _ =>
      destruct
        (eval_unload_object_gfx_expr_pointer
          e le memory pool_block slot gfx_block gfx_ofs
          Hvalid Hobj Hgfx) as (Hblock & Hofs);
      subst gfx_block gfx_ofs
  end.
  split; reflexivity.
Qed.

Lemma eval_unload_graph_flags_lhs_pool_slot :
  forall e le memory pool_block slot loc ofs bf,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_lvalue unload_object_ge e le memory
      unload_graph_flags_lhs loc ofs bf ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.add
          (Ptrofs.add
            (Ptrofs.add
              (Ptrofs.repr ((slot * object_slot_size)%Z))
              (Ptrofs.repr 0))
            (Ptrofs.repr 0))
          (Ptrofs.repr 0))
        (Ptrofs.repr 2) /\
    bf = Full.
Proof.
  intros e le memory pool_block slot loc ofs bf Hvalid Hobj Hlv.
  change unload_graph_flags_lhs with
    (Efield unload_object_graph_node_expr S._flags tshort) in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof unload_object_graph_node_expr = Tstruct _ _ |- _ =>
      unfold unload_object_graph_node_expr in Hty;
      cbn [typeof] in Hty;
      inv Hty
  end.
  match goal with
  | Hco : unload_object_ce ! S._GraphNode = Some ?co,
    Hfield :
      field_offset unload_object_ce S._flags (co_members ?co) =
      OK (?delta, ?bf0) |- _ =>
      assert (Hmembers : co_members co = unload_graph_node_members) by
        (unfold unload_graph_node_members; rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite unload_graph_node_flags_layout in Hfield;
      inv Hfield
  end.
  match goal with
  | Hnode :
      eval_expr unload_object_ge e le memory
        unload_object_graph_node_expr (Vptr ?node_block ?node_ofs) |- _ =>
      destruct
        (eval_unload_object_graph_node_expr_pointer
          e le memory pool_block slot node_block node_ofs
          Hvalid Hobj Hnode) as (Hblock & Hofs);
      subst node_block node_ofs
  end.
  split; [reflexivity | split; reflexivity].
Qed.

Lemma exec_unload_throw_matrix_assign_preserves_active_flags :
  forall rhs e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Sassign unload_throw_matrix_lhs rhs) trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros rhs e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hlv :
      eval_lvalue _ ?env ?temps ?mem unload_throw_matrix_lhs
        ?loc ?ofs ?bf |- _ =>
      destruct
        (eval_unload_throw_matrix_lhs_pool_slot
          env temps mem pool_block slot loc ofs bf Hvalid Hobj Hlv)
        as (Hloc & Hofs & Hbf);
      subst loc ofs bf
  end.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint32) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        rewrite pool_slot_throw_matrix_nested_address in Hrange
          by exact Hvalid;
        change (size_chunk Mint32) with 4 in Hrange;
        eapply pool_slot_throw_matrix_store_misses_active_flags; eauto ]
  end.
Qed.

Lemma exec_unload_graph_flags_assign_preserves_active_flags :
  forall rhs e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Sassign unload_graph_flags_lhs rhs) trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros rhs e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hlv :
      eval_lvalue _ ?env ?temps ?mem unload_graph_flags_lhs
        ?loc ?ofs ?bf |- _ =>
      destruct
        (eval_unload_graph_flags_lhs_pool_slot
          env temps mem pool_block slot loc ofs bf Hvalid Hobj Hlv)
        as (Hloc & Hofs & Hbf);
      subst loc ofs bf
  end.
  split; [reflexivity | split; [reflexivity |]].
  match goal with
  | Hassign :
      assign_loc unload_object_ce _ _ _ _ _ _ _ |- _ =>
      eapply assign_loc_by_value_preserves_active_flags_bytes
        with (chunk := Mint16signed) in Hassign;
      [ exact Hassign
      | reflexivity
      | intros byte Hrange;
        rewrite pool_slot_graph_flags_nested_address in Hrange
          by exact Hvalid;
        change (size_chunk Mint16signed) with 2 in Hrange;
        eapply pool_slot_graph_flags_store_misses_active_flags; eauto ]
  end.
Qed.

Definition pool_slot_statement_preserves_obj_and_active_flags
    (statement_body : statement) : Prop :=
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      statement_body trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.

Lemma deallocate_object_obj_next_assign_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags
    deallocate_object_obj_next_assign.
Proof.
  unfold pool_slot_statement_preserves_obj_and_active_flags.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  destruct
    (exec_deallocate_object_obj_next_assign_preserves_active_flags
      e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma deallocate_object_next_prev_assign_pool_slot_frame_from_target_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._t'4 pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_next_prev_assign trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Htarget Hexec.
  destruct
    (exec_deallocate_object_next_prev_assign_preserves_active_flags_from_target_shape
      e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Htarget Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma deallocate_object_prev_next_assign_pool_slot_frame_from_target_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._t'2 pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_prev_next_assign trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Htarget Hexec.
  destruct
    (exec_deallocate_object_prev_next_assign_preserves_active_flags_from_target_shape
      e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Htarget Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma deallocate_object_free_list_next_assign_pool_slot_frame_from_target_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._freeList pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_free_list_next_assign trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Htarget Hexec.
  destruct
    (exec_deallocate_object_free_list_next_assign_preserves_active_flags_from_target_shape
      e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Htarget Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma deallocate_object_first_splice_pool_slot_frame_from_next_deref_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_node_field_deref_shape
      memory pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 96 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hnext_shape Hexec.
  assert (Ht4_not_obj : Pos.eqb S._t'4 S._obj = false)
    by (vm_compute; reflexivity).
  assert (Ht5_not_obj : Pos.eqb S._t'5 S._obj = false)
    by (vm_compute; reflexivity).
  assert (Ht5_not_t4 : Pos.eqb S._t'5 S._t'4 = false)
    by (vm_compute; reflexivity).
  inv Hexec.
  - match goal with
    | Hread_next :
        exec_stmt _ _ _ _ _
          deallocate_object_read_next ?trace_next ?le_after_next
          ?memory_after_next Out_normal,
      Hrest :
        exec_stmt _ _ _ ?le_mid ?memory_mid
          (Ssequence
            deallocate_object_read_prev
            deallocate_object_next_prev_assign)
          ?trace_rest le' memory' outcome |- _ =>
        change deallocate_object_read_next with
          (Sset S._t'4 (object_node_field_expr S._obj S._next))
          in Hread_next;
        destruct
          (exec_deallocate_object_read_next_sets_t4_shape_from_deref_shape
            e le memory pool_block pool_block
            (Ptrofs.repr (slot * object_slot_size))
            trace_next le_after_next memory_after_next Out_normal
            Hobj Hnext_shape Hread_next)
          as (Ht4_after_next & Hmemory_after_next & _);
        destruct
          (exec_sset_different_preserves_lookup
            S._obj
            (Vptr pool_block
              (Ptrofs.repr (slot * object_slot_size)))
            S._t'4 (object_node_field_expr S._obj S._next)
            e le memory trace_next le_after_next memory_after_next
            Out_normal Ht4_not_obj Hobj Hread_next)
          as (Hobj_after_next & _ & _);
        subst memory_after_next
    end.
    match goal with
    | Hrest :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_prev
            deallocate_object_next_prev_assign)
          _ _ _ _ |- _ =>
        inv Hrest
    end.
    + change deallocate_object_read_prev with
        (Sset S._t'5 (object_node_field_expr S._obj S._prev))
        in H5.
      destruct
        (exec_sset_different_preserves_lookup
          S._obj
          (Vptr pool_block
            (Ptrofs.repr (slot * object_slot_size)))
          S._t'5 (object_node_field_expr S._obj S._prev)
          e le1 memory t0 le2 m1 Out_normal
          Ht5_not_obj Hobj_after_next H5)
        as (Hobj_after_prev & Hm1 & _).
      destruct
        (exec_sset_different_preserves_temp_shape
          S._t'4 S._t'5
          (object_node_field_expr S._obj S._prev)
          e le1 memory pool_block t0 le2 m1 Out_normal
          Ht5_not_t4 Ht4_after_next H5)
        as (Ht4_after_prev & _ & _).
      subst m1.
      destruct
        (deallocate_object_next_prev_assign_pool_slot_frame_from_target_shape
          e le2 memory pool_block slot t3 le' memory' outcome
          Hvalid Hobj_after_prev Ht4_after_prev H11)
        as (Hobj_final & Hunchanged).
      split; [exact Hobj_final | exact Hunchanged].
    + match goal with
      | Hread_prev :
          exec_stmt _ _ _ _ _
            deallocate_object_read_prev _ _ _ _ |- _ =>
          change deallocate_object_read_prev with
            (Sset S._t'5 (object_node_field_expr S._obj S._prev))
            in Hread_prev;
          inv Hread_prev
      end.
      match goal with
      | Hneq : Out_normal <> Out_normal |- _ =>
          exfalso; apply Hneq; reflexivity
      end.
  - match goal with
    | Hread_next :
        exec_stmt _ _ _ _ _
          deallocate_object_read_next _ _ _ _ |- _ =>
        change deallocate_object_read_next with
          (Sset S._t'4 (object_node_field_expr S._obj S._next))
          in Hread_next;
        inv Hread_next
    end.
    match goal with
    | Hneq : Out_normal <> Out_normal |- _ =>
        exfalso; apply Hneq; reflexivity
    end.
Qed.

Lemma deallocate_object_second_splice_pool_slot_frame_from_prev_deref_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_node_field_deref_shape
      memory pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 100 ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Ssequence
        deallocate_object_read_prev_again
        (Ssequence
          deallocate_object_read_next_again
          deallocate_object_prev_next_assign))
      trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hprev_shape Hexec.
  assert (Ht2_not_obj : Pos.eqb S._t'2 S._obj = false)
    by (vm_compute; reflexivity).
  assert (Ht3_not_obj : Pos.eqb S._t'3 S._obj = false)
    by (vm_compute; reflexivity).
  assert (Ht3_not_t2 : Pos.eqb S._t'3 S._t'2 = false)
    by (vm_compute; reflexivity).
  inv Hexec.
  - match goal with
    | Hread_prev :
        exec_stmt _ _ _ _ _
          deallocate_object_read_prev_again ?trace_prev ?le_after_prev
          ?memory_after_prev Out_normal,
      Hrest :
        exec_stmt _ _ _ ?le_mid ?memory_mid
          (Ssequence
            deallocate_object_read_next_again
            deallocate_object_prev_next_assign)
          ?trace_rest le' memory' outcome |- _ =>
        change deallocate_object_read_prev_again with
          (Sset S._t'2 (object_node_field_expr S._obj S._prev))
          in Hread_prev;
        destruct
          (exec_deallocate_object_read_prev_again_sets_t2_shape_from_deref_shape
            e le memory pool_block pool_block
            (Ptrofs.repr (slot * object_slot_size))
            trace_prev le_after_prev memory_after_prev Out_normal
            Hobj Hprev_shape Hread_prev)
          as (Ht2_after_prev & Hmemory_after_prev & _);
        destruct
          (exec_sset_different_preserves_lookup
            S._obj
            (Vptr pool_block
              (Ptrofs.repr (slot * object_slot_size)))
            S._t'2 (object_node_field_expr S._obj S._prev)
            e le memory trace_prev le_after_prev memory_after_prev
            Out_normal Ht2_not_obj Hobj Hread_prev)
          as (Hobj_after_prev & _ & _);
        subst memory_after_prev
    end.
    match goal with
    | Hrest :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_next_again
            deallocate_object_prev_next_assign)
          _ _ _ _ |- _ =>
        inv Hrest
    end.
    + change deallocate_object_read_next_again with
        (Sset S._t'3 (object_node_field_expr S._obj S._next))
        in H5.
      destruct
        (exec_sset_different_preserves_lookup
          S._obj
          (Vptr pool_block
            (Ptrofs.repr (slot * object_slot_size)))
          S._t'3 (object_node_field_expr S._obj S._next)
          e le1 memory t0 le2 m1 Out_normal
          Ht3_not_obj Hobj_after_prev H5)
        as (Hobj_after_next & Hm1 & _).
      destruct
        (exec_sset_different_preserves_temp_shape
          S._t'2 S._t'3
          (object_node_field_expr S._obj S._next)
          e le1 memory pool_block t0 le2 m1 Out_normal
          Ht3_not_t2 Ht2_after_prev H5)
        as (Ht2_after_next & _ & _).
      subst m1.
      destruct
        (deallocate_object_prev_next_assign_pool_slot_frame_from_target_shape
          e le2 memory pool_block slot t3 le' memory' outcome
          Hvalid Hobj_after_next Ht2_after_next H11)
        as (Hobj_final & Hunchanged).
      split; [exact Hobj_final | exact Hunchanged].
    + match goal with
      | Hread_next :
          exec_stmt _ _ _ _ _
            deallocate_object_read_next_again _ _ _ _ |- _ =>
          change deallocate_object_read_next_again with
            (Sset S._t'3 (object_node_field_expr S._obj S._next))
            in Hread_next;
          inv Hread_next
      end.
      match goal with
      | Hneq : Out_normal <> Out_normal |- _ =>
          exfalso; apply Hneq; reflexivity
      end.
  - match goal with
    | Hread_prev :
        exec_stmt _ _ _ _ _
          deallocate_object_read_prev_again _ _ _ _ |- _ =>
        change deallocate_object_read_prev_again with
          (Sset S._t'2 (object_node_field_expr S._obj S._prev))
          in Hread_prev;
        inv Hread_prev
    end.
    match goal with
    | Hneq : Out_normal <> Out_normal |- _ =>
        exfalso; apply Hneq; reflexivity
    end.
Qed.

Lemma deallocate_object_free_list_insert_pool_slot_frame_from_free_list_shape :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    temp_points_to_external_or_pool_slot_header le S._freeList pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Ssequence
        (Ssequence
          deallocate_object_read_free_next
          deallocate_object_obj_next_assign)
        deallocate_object_free_list_next_assign)
      trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hfree_shape Hexec.
  assert (Ht1_not_obj : Pos.eqb S._t'1 S._obj = false)
    by (vm_compute; reflexivity).
  assert (Ht1_not_freeList : Pos.eqb S._t'1 S._freeList = false)
    by (vm_compute; reflexivity).
  inv Hexec.
  - match goal with
    | Hprefix :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_free_next
            deallocate_object_obj_next_assign)
          ?trace_prefix ?le_after_prefix ?memory_after_prefix Out_normal,
      Hfree_assign :
        exec_stmt _ _ _ ?le_mid ?memory_mid
          deallocate_object_free_list_next_assign ?trace_free le' memory'
          outcome |- _ =>
        inv Hprefix
    end.
    + change deallocate_object_read_free_next with
        (Sset S._t'1 (object_node_field_expr S._freeList S._next))
        in H5.
      destruct
        (exec_sset_different_preserves_lookup
          S._obj
          (Vptr pool_block
            (Ptrofs.repr (slot * object_slot_size)))
          S._t'1 (object_node_field_expr S._freeList S._next)
          e le memory t0 le2 m0 Out_normal
          Ht1_not_obj Hobj H5)
        as (Hobj_after_read & Hm0 & _).
      destruct
        (exec_sset_different_preserves_temp_shape
          S._freeList S._t'1
          (object_node_field_expr S._freeList S._next)
          e le memory pool_block t0 le2 m0 Out_normal
          Ht1_not_freeList Hfree_shape H5)
        as (Hfree_after_read & _ & _).
      subst m0.
      destruct
        (exec_deallocate_object_obj_next_assign_preserves_active_flags
          e le2 memory pool_block slot t3 le1 m1
          Out_normal Hvalid Hobj_after_read H11)
        as (Hle1 & _ & Hunchanged_obj_next).
      subst le1.
      destruct
        (deallocate_object_free_list_next_assign_pool_slot_frame_from_target_shape
          e le2 m1 pool_block slot t2 le' memory'
          outcome Hvalid Hobj_after_read Hfree_after_read H9)
        as (Hobj_final & Hunchanged_free).
      split; [exact Hobj_final |].
      eapply Mem.unchanged_on_trans; eauto.
    + match goal with
      | Hread_free :
          exec_stmt _ _ _ _ _
            (Sset S._t'1 (object_node_field_expr S._freeList S._next))
            _ _ _ _ |- _ =>
          inv Hread_free
      | Hread_free :
          exec_stmt _ _ _ _ _
            deallocate_object_read_free_next _ _ _ _ |- _ =>
          change deallocate_object_read_free_next with
            (Sset S._t'1 (object_node_field_expr S._freeList S._next))
            in Hread_free;
          inv Hread_free
      end.
      exfalso; apply H11; reflexivity.
  - match goal with
    | Hprefix :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_free_next
            deallocate_object_obj_next_assign)
          _ _ _ _ |- _ =>
        inv Hprefix
    end.
    + match goal with
      | Hread_free :
          exec_stmt _ _ _ _ _
            deallocate_object_read_free_next _ _ _ _ |- _ =>
          change deallocate_object_read_free_next with
            (Sset S._t'1 (object_node_field_expr S._freeList S._next))
            in Hread_free;
          inv Hread_free
      end.
      unfold deallocate_object_obj_next_assign in H11.
      inv H11.
      exfalso; apply H9; reflexivity.
    + match goal with
      | Hread_free :
          exec_stmt _ _ _ _ _
            (Sset S._t'1 (object_node_field_expr S._freeList S._next))
            _ _ _ _ |- _ =>
          inv Hread_free
      | Hread_free :
          exec_stmt _ _ _ _ _
            deallocate_object_read_free_next _ _ _ _ |- _ =>
          change deallocate_object_read_free_next with
            (Sset S._t'1 (object_node_field_expr S._freeList S._next))
            in Hread_free;
          inv Hread_free
      end.
      match goal with
      | Hneq : Out_normal <> Out_normal |- _ =>
          exfalso; apply Hneq; reflexivity
      end.
Qed.

Lemma pool_slot_statement_preserves_sequence :
  forall first rest,
    pool_slot_statement_preserves_obj_and_active_flags first ->
    pool_slot_statement_preserves_obj_and_active_flags rest ->
    pool_slot_statement_preserves_obj_and_active_flags
      (Ssequence first rest).
Proof.
  intros first rest Hfirst Hrest.
  unfold pool_slot_statement_preserves_obj_and_active_flags in *.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  inv Hexec.
  - match goal with
    | Hfirst_exec :
        exec_stmt _ _ _ _ _ first ?trace1 ?le1 ?memory1 Out_normal,
      Hrest_exec :
        exec_stmt _ _ _ ?le_mid ?memory_mid rest ?trace2 le' memory'
          outcome |- _ =>
        destruct
          (Hfirst e le memory pool_block slot trace1 le1 memory1
            Out_normal Hvalid Hobj Hfirst_exec)
          as (Hobj1 & Hunchanged1);
        destruct
          (Hrest e le_mid memory_mid pool_block slot trace2 le' memory'
            outcome Hvalid Hobj1 Hrest_exec)
          as (Hobj' & Hunchanged2);
        split; [exact Hobj' |];
        eapply Mem.unchanged_on_trans; eauto
    end.
  - eapply Hfirst; eauto.
Qed.

Lemma pool_slot_statement_preserves_sset_different :
  forall temporary expression,
    Pos.eqb temporary S._obj = false ->
    pool_slot_statement_preserves_obj_and_active_flags
      (Sset temporary expression).
Proof.
  intros temporary expression Hdifferent.
  unfold pool_slot_statement_preserves_obj_and_active_flags.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  inv Hexec.
  split.
  - eapply PTree_set_preserves_different; eauto.
  - apply Mem.unchanged_on_refl.
Qed.

Definition deallocate_object_body_remaining_pool_slot_frame_obligations
    : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    deallocate_object_next_prev_assign /\
  pool_slot_statement_preserves_obj_and_active_flags
    deallocate_object_prev_next_assign /\
  pool_slot_statement_preserves_obj_and_active_flags
    deallocate_object_free_list_next_assign.

Lemma deallocate_object_body_pool_slot_frame_from_remaining_obligations :
  deallocate_object_body_remaining_pool_slot_frame_obligations ->
  pool_slot_statement_preserves_obj_and_active_flags
    (fn_body S.f_deallocate_object).
Proof.
  intros (Hnext_prev & Hprev_next & Hfree_next).
  rewrite deallocate_object_body_split.
  apply pool_slot_statement_preserves_sequence.
  - apply pool_slot_statement_preserves_sequence.
    + apply pool_slot_statement_preserves_sset_different.
      vm_compute.
      reflexivity.
    + apply pool_slot_statement_preserves_sequence.
      * apply pool_slot_statement_preserves_sset_different.
        vm_compute.
        reflexivity.
      * exact Hnext_prev.
  - apply pool_slot_statement_preserves_sequence.
    + apply pool_slot_statement_preserves_sequence.
      * apply pool_slot_statement_preserves_sset_different.
        vm_compute.
        reflexivity.
      * apply pool_slot_statement_preserves_sequence.
        -- apply pool_slot_statement_preserves_sset_different.
           vm_compute.
           reflexivity.
        -- exact Hprev_next.
    + apply pool_slot_statement_preserves_sequence.
      * apply pool_slot_statement_preserves_sequence.
        -- apply pool_slot_statement_preserves_sset_different.
           vm_compute.
           reflexivity.
        -- apply deallocate_object_obj_next_assign_pool_slot_frame.
      * exact Hfree_next.
Qed.

Theorem deallocate_object_body_preserves_pool_slot_active_flags_from_remaining_obligations :
  deallocate_object_body_remaining_pool_slot_frame_obligations ->
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_deallocate_object) trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  destruct
    (deallocate_object_body_pool_slot_frame_from_remaining_obligations
      Hframes e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (_ & Hunchanged).
  exact Hunchanged.
Qed.

Lemma unload_prev_obj_assign_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags unload_prev_obj_assign.
Proof.
  unfold pool_slot_statement_preserves_obj_and_active_flags.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  destruct
    (exec_unload_prev_obj_assign_preserves_active_flags
      e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma unload_throw_matrix_assign_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_throw_matrix_assign.
Proof.
  unfold pool_slot_statement_preserves_obj_and_active_flags.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  unfold unload_throw_matrix_assign in Hexec.
  destruct
    (exec_unload_throw_matrix_assign_preserves_active_flags
      _ e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma unload_graph_flags_read_bit2_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_read_bit2.
Proof.
  unfold unload_graph_flags_read_bit2.
  apply pool_slot_statement_preserves_sset_different.
  vm_compute.
  reflexivity.
Qed.

Lemma unload_graph_flags_read_bit0_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_read_bit0.
Proof.
  unfold unload_graph_flags_read_bit0.
  apply pool_slot_statement_preserves_sset_different.
  vm_compute.
  reflexivity.
Qed.

Lemma unload_graph_flags_assign_bit2_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_assign_bit2.
Proof.
  unfold pool_slot_statement_preserves_obj_and_active_flags.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  unfold unload_graph_flags_assign_bit2 in Hexec.
  destruct
    (exec_unload_graph_flags_assign_preserves_active_flags
      _ e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Lemma unload_graph_flags_assign_bit0_pool_slot_frame :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_assign_bit0.
Proof.
  unfold pool_slot_statement_preserves_obj_and_active_flags.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  unfold unload_graph_flags_assign_bit0 in Hexec.
  destruct
    (exec_unload_graph_flags_assign_preserves_active_flags
      _ e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (Hle' & _ & Hunchanged).
  subst le'.
  split; [exact Hobj | exact Hunchanged].
Qed.

Theorem unload_graph_flags_clear_bit2_pool_slot_frame_from_assign :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_assign_bit2 ->
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_clear_bit2.
Proof.
  intros Hassign.
  rewrite unload_graph_flags_clear_bit2_split.
  apply pool_slot_statement_preserves_sequence.
  - apply unload_graph_flags_read_bit2_pool_slot_frame.
  - exact Hassign.
Qed.

Theorem unload_graph_flags_clear_bit0_pool_slot_frame_from_assign :
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_assign_bit0 ->
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_clear_bit0.
Proof.
  intros Hassign.
  rewrite unload_graph_flags_clear_bit0_split.
  apply pool_slot_statement_preserves_sequence.
  - apply unload_graph_flags_read_bit0_pool_slot_frame.
  - exact Hassign.
Qed.

Definition unload_object_tail_named_pool_slot_frame_obligations : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_throw_matrix_assign /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_clear_bit2 /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_clear_bit0 /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_deallocate_object_call.

Definition unload_object_tail_refined_pool_slot_frame_obligations : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_throw_matrix_assign /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_assign_bit2 /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_graph_flags_assign_bit0 /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_deallocate_object_call.

Definition unload_object_tail_remaining_pool_slot_frame_obligations : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_deallocate_object_call.

Theorem unload_object_tail_refined_frames_from_remaining_frames :
  unload_object_tail_remaining_pool_slot_frame_obligations ->
  unload_object_tail_refined_pool_slot_frame_obligations.
Proof.
  intros (Hstop & Hremove & Hadd & Hdeallocate).
  split; [apply unload_throw_matrix_assign_pool_slot_frame |].
  split; [exact Hstop |].
  split; [exact Hremove |].
  split; [exact Hadd |].
  split; [apply unload_graph_flags_assign_bit2_pool_slot_frame |].
  split; [apply unload_graph_flags_assign_bit0_pool_slot_frame |].
  exact Hdeallocate.
Qed.

Theorem unload_object_tail_named_frames_from_refined_frames :
  unload_object_tail_refined_pool_slot_frame_obligations ->
  unload_object_tail_named_pool_slot_frame_obligations.
Proof.
  intros (Hthrow &
          Hstop &
          Hremove &
          Hadd &
          Hflags_assign2 &
          Hflags_assign0 &
          Hdeallocate).
  split; [exact Hthrow |].
  split; [exact Hstop |].
  split; [exact Hremove |].
  split; [exact Hadd |].
  split.
  - apply unload_graph_flags_clear_bit2_pool_slot_frame_from_assign.
    exact Hflags_assign2.
  - split.
    + apply unload_graph_flags_clear_bit0_pool_slot_frame_from_assign.
      exact Hflags_assign0.
    + exact Hdeallocate.
Qed.

Theorem unload_object_tail_pool_slot_frame_from_named_obligations :
  unload_object_tail_named_pool_slot_frame_obligations ->
  pool_slot_statement_preserves_obj_and_active_flags unload_object_tail.
Proof.
  intros (Hthrow &
          Hstop &
          Hremove &
          Hadd &
          Hflags2 &
          Hflags0 &
          Hdeallocate).
  rewrite unload_object_tail_split_prev.
  apply pool_slot_statement_preserves_sequence.
  - apply unload_prev_obj_assign_pool_slot_frame.
  - rewrite unload_object_after_prev_split_throw_matrix.
    apply pool_slot_statement_preserves_sequence.
    + exact Hthrow.
    + rewrite unload_object_after_throw_matrix_split_stop_sounds.
      apply pool_slot_statement_preserves_sequence.
      * exact Hstop.
      * rewrite unload_object_after_stop_sounds_split_geo_remove_child.
        apply pool_slot_statement_preserves_sequence.
        -- exact Hremove.
        -- rewrite unload_object_after_geo_remove_child_split_geo_add_child.
           apply pool_slot_statement_preserves_sequence.
           ++ exact Hadd.
           ++ rewrite unload_object_after_geo_add_child_split_graph_flags_bit2.
              apply pool_slot_statement_preserves_sequence.
              ** exact Hflags2.
              ** rewrite
                   unload_object_after_graph_flags_bit2_split_graph_flags_bit0.
                 apply pool_slot_statement_preserves_sequence.
                 --- exact Hflags0.
                 --- rewrite
                       unload_object_after_graph_flags_bit0_is_deallocate_call.
                     exact Hdeallocate.
Qed.

Theorem unload_object_tail_pool_slot_frame_from_refined_obligations :
  unload_object_tail_refined_pool_slot_frame_obligations ->
  pool_slot_statement_preserves_obj_and_active_flags unload_object_tail.
Proof.
  intros Hframes.
  apply unload_object_tail_pool_slot_frame_from_named_obligations.
  apply unload_object_tail_named_frames_from_refined_frames.
  exact Hframes.
Qed.

Theorem unload_object_tail_pool_slot_frame_from_remaining_obligations :
  unload_object_tail_remaining_pool_slot_frame_obligations ->
  pool_slot_statement_preserves_obj_and_active_flags unload_object_tail.
Proof.
  intros Hframes.
  apply unload_object_tail_pool_slot_frame_from_refined_obligations.
  apply unload_object_tail_refined_frames_from_remaining_frames.
  exact Hframes.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_named_frames :
  unload_object_tail_named_pool_slot_frame_obligations ->
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  destruct
    (unload_object_tail_pool_slot_frame_from_named_obligations
      Hframes e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (_ & Hunchanged).
  exact Hunchanged.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_refined_frames :
  unload_object_tail_refined_pool_slot_frame_obligations ->
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes.
  apply unload_object_tail_preserves_pool_slot_active_flags_from_named_frames.
  apply unload_object_tail_named_frames_from_refined_frames.
  exact Hframes.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_remaining_frames :
  unload_object_tail_remaining_pool_slot_frame_obligations ->
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes.
  apply unload_object_tail_preserves_pool_slot_active_flags_from_refined_frames.
  apply unload_object_tail_refined_frames_from_remaining_frames.
  exact Hframes.
Qed.

Lemma statement_preserves_active_flags_bytes_assign :
  forall lhs rhs,
    assign_loc_preserves_active_flags_bytes lhs ->
    statement_preserves_active_flags_bytes (Sassign lhs rhs).
Proof.
  intros lhs rhs Hassign_frame.
  unfold statement_preserves_active_flags_bytes.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hexec.
  inv Hexec.
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hassign :
      assign_loc unload_object_ce (typeof lhs) memory ?store_block
        ?store_offset ?bitfield ?value memory' |- _ =>
      eapply Hassign_frame; exact Hassign
  end.
Qed.

Lemma statement_preserves_active_flags_bytes_sequence :
  forall first rest,
    statement_preserves_active_flags_bytes first ->
    statement_preserves_active_flags_bytes rest ->
    statement_preserves_active_flags_bytes (Ssequence first rest).
Proof.
  intros first rest Hfirst Hrest.
  unfold statement_preserves_active_flags_bytes in *.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hexec.
  inv Hexec.
  - eapply Mem.unchanged_on_trans.
    + eapply Hfirst; eauto.
    + eapply Hrest; eauto.
  - eapply Hfirst; eauto.
Qed.

Lemma statement_leaf_frame_obligations_preserve :
  forall statement_body,
    statement_leaf_frame_obligations statement_body ->
    statement_preserves_active_flags_bytes statement_body.
Proof.
  induction statement_body; simpl; intros Hframes;
    try exact Hframes.
  - apply statement_preserves_active_flags_bytes_skip.
  - apply statement_preserves_active_flags_bytes_set.
  - destruct Hframes as (Hfirst & Hrest).
    apply statement_preserves_active_flags_bytes_sequence.
    + apply IHstatement_body1. exact Hfirst.
    + apply IHstatement_body2. exact Hrest.
Qed.

Definition unload_object_tail_leaf_frame_obligations : Prop :=
  statement_leaf_frame_obligations unload_object_tail.

Definition deallocate_object_body_leaf_frame_obligations : Prop :=
  statement_leaf_frame_obligations (fn_body S.f_deallocate_object).

Theorem unload_object_tail_preserves_active_flags_bytes_from_leaf_frames :
  unload_object_tail_leaf_frame_obligations ->
  unload_object_tail_preserves_active_flags_bytes.
Proof.
  intros Hframes.
  unfold unload_object_tail_preserves_active_flags_bytes.
  pose proof
    (statement_leaf_frame_obligations_preserve
      unload_object_tail Hframes) as Htail.
  unfold statement_preserves_active_flags_bytes in Htail.
  intros e le memory object_block object_offset trace le' memory' outcome
    Hexec.
  eapply Htail; eauto.
Qed.

Theorem deallocate_object_body_preserves_active_flags_bytes_from_leaf_frames :
  deallocate_object_body_leaf_frame_obligations ->
  statement_preserves_active_flags_bytes (fn_body S.f_deallocate_object).
Proof.
  intros Hframes.
  apply statement_leaf_frame_obligations_preserve.
  exact Hframes.
Qed.

Theorem eval_funcall_internal_deallocate_object_preserves_active_flags_from_body_frame :
  statement_preserves_active_flags_bytes (fn_body S.f_deallocate_object) ->
  forall memory vargs trace memory' result object_block object_offset,
    eval_funcall function_entry2 unload_object_ge memory
      (Internal S.f_deallocate_object) vargs trace memory' result ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.
Proof.
  intros Hbody_frame memory vargs trace memory' result object_block
    object_offset Hcall.
  inv Hcall.
  match goal with
  | Hentry :
      function_entry2 unload_object_ge S.f_deallocate_object
        vargs memory ?entry_env ?entry_temps ?entry_memory |- _ =>
      inv Hentry
  end.
  cbn in *.
  match goal with
  | Halloc : alloc_variables _ _ _ nil _ _ |- _ => inv Halloc
  end.
  match goal with
  | Hbody : statement_preserves_active_flags_bytes ?statement_body,
    Hexec :
      exec_stmt function_entry2 unload_object_ge ?entry_env ?entry_temps
        ?initial_memory ?statement_body
        ?body_trace ?body_temps ?body_memory ?body_out |- _ =>
      pose proof
        (Hbody entry_env entry_temps initial_memory
          object_block object_offset body_trace body_temps body_memory
          body_out Hexec) as Hunchanged_body
  end.
  match goal with
  | Hfree : Mem.free_list ?body_memory (blocks_of_env _ empty_env) =
      Some memory' |- _ =>
      cbn in Hfree;
      inv Hfree
  end.
  exact Hunchanged_body.
Qed.

Definition deallocate_object_function_resolves_in_empty_env : Prop :=
  forall le memory function_value,
    eval_expr unload_object_ge empty_env le memory
      (Evar S._deallocate_object
        (Tfunction
          ((tptr (Tstruct S._ObjectNode noattr)) ::
           (tptr (Tstruct S._ObjectNode noattr)) :: nil)
          tvoid cc_default)) function_value ->
    Genv.find_funct unload_object_ge function_value =
    Some (Internal S.f_deallocate_object).

Lemma unload_object_ge_resolves_deallocate_object :
  exists block,
    Genv.find_symbol unload_object_ge S._deallocate_object = Some block /\
    Genv.find_funct unload_object_ge (Vptr block Ptrofs.zero) =
    Some (Internal S.f_deallocate_object).
Proof.
  assert (Hdefmap :
    (prog_defmap S.prog) ! S._deallocate_object =
    Some (Gfun (Internal S.f_deallocate_object))).
  { vm_compute. reflexivity. }
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hdefmap.
  destruct Hdefmap as (block & Hsymbol & Hdefinition).
  exists block.
  split; [exact Hsymbol |].
  unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | Hneq].
  - apply (proj2 (Genv.find_funct_ptr_iff _ _ _)).
    exact Hdefinition.
  - exfalso.
    apply Hneq.
    reflexivity.
Qed.

Theorem deallocate_object_function_resolves_in_empty_env_holds :
  deallocate_object_function_resolves_in_empty_env.
Proof.
  unfold deallocate_object_function_resolves_in_empty_env.
  intros le memory function_value Hexpr.
  destruct unload_object_ge_resolves_deallocate_object
    as (deallocate_block & Hsymbol & Hfunct).
  inv Hexpr.
  match goal with
  | Hlv : eval_lvalue _ _ _ _
      (Evar S._deallocate_object _) _ _ _ |- _ =>
      inv Hlv
  end.
  - match goal with
    | Hlocal : empty_env ! S._deallocate_object = Some _ |- _ =>
        cbn in Hlocal;
        discriminate
    end.
  - assert (loc = deallocate_block) by congruence.
    subst loc.
    change (deref_loc
      (Tfunction
        ((tptr (Tstruct S._ObjectNode noattr)) ::
         (tptr (Tstruct S._ObjectNode noattr)) :: nil)
        tvoid cc_default)
      memory deallocate_block Ptrofs.zero Full function_value) in H0.
    pose proof
      (deref_loc_by_reference_pointer
        (Tfunction
          ((tptr (Tstruct S._ObjectNode noattr)) ::
           (tptr (Tstruct S._ObjectNode noattr)) :: nil)
          tvoid cc_default)
        memory deallocate_block Ptrofs.zero function_value
        eq_refl H0) as Hvalue.
    subst function_value.
    exact Hfunct.
Qed.

Definition unload_deallocate_object_call_empty_env_frame_obligation : Prop :=
  statement_preserves_active_flags_bytes (fn_body S.f_deallocate_object) ->
  deallocate_object_function_resolves_in_empty_env ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_deallocate_object_call trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.

Theorem unload_deallocate_object_call_empty_env_frame_obligation_holds :
  unload_deallocate_object_call_empty_env_frame_obligation.
Proof.
  unfold unload_deallocate_object_call_empty_env_frame_obligation.
  intros Hbody_frame Hresolve le memory pool_block slot trace le' memory'
    outcome Hvalid Hobj Hexec.
  unfold unload_deallocate_object_call in Hexec.
  inv Hexec.
  match goal with
  | Hfun_expr :
      eval_expr _ _ _ _ _ ?function_value,
    Hfind :
      Genv.find_funct _ ?function_value = Some _
      |- _ =>
      pose proof
        (Hresolve le memory function_value Hfun_expr) as Hresolved;
      rewrite Hresolved in Hfind;
      inv Hfind
  end.
  split.
  - exact Hobj.
  - match goal with
    | Hcall :
        eval_funcall function_entry2 unload_object_ge memory
          (Internal S.f_deallocate_object) _ trace memory' _ |- _ =>
        eapply
          (eval_funcall_internal_deallocate_object_preserves_active_flags_from_body_frame
            Hbody_frame memory _ trace memory' _ pool_block
            (Ptrofs.repr (slot * object_slot_size)));
        exact Hcall
    end.
Qed.

Theorem unload_deallocate_object_call_empty_env_frame_from_body_frame :
  statement_preserves_active_flags_bytes (fn_body S.f_deallocate_object) ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_deallocate_object_call trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hbody_frame.
  eapply unload_deallocate_object_call_empty_env_frame_obligation_holds.
  - exact Hbody_frame.
  - apply deallocate_object_function_resolves_in_empty_env_holds.
Qed.

Definition unload_object_tail_preserves_deactivation : Prop :=
  forall e le memory object_block object_offset trace le' memory' outcome,
    pointer_slot_deactivated memory object_block object_offset ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_object_tail trace le' memory' outcome ->
    pointer_slot_deactivated memory' object_block object_offset.

Theorem unload_object_tail_preserves_deactivation_from_frame :
  unload_object_tail_preserves_active_flags_bytes ->
  unload_object_tail_preserves_deactivation.
Proof.
  intros Hframe e le memory object_block object_offset trace le' memory'
    outcome Hdeactivated Hexec.
  eapply unchanged_on_active_flags_preserves_pointer_slot_deactivated.
  - eapply Hframe; eauto.
  - exact Hdeactivated.
Qed.

Lemma exec_seq_assign :
  forall fe ge e le memory lhs rhs rest trace le' memory' outcome,
    exec_stmt fe ge e le memory (Ssequence (Sassign lhs rhs) rest)
      trace le' memory' outcome ->
    exists trace1 le1 memory1 trace2,
      exec_stmt fe ge e le memory (Sassign lhs rhs)
        trace1 le1 memory1 Out_normal /\
      exec_stmt fe ge e le1 memory1 rest trace2 le' memory' outcome.
Proof.
  intros fe ge e le memory lhs rhs rest trace le' memory' outcome Hexec.
  inv Hexec.
  - do 4 eexists; split; eassumption.
  - match goal with
    | Hfirst : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
        inv Hfirst; congruence
    end.
Qed.

Theorem exec_unload_object_deactivates :
  unload_object_tail_preserves_deactivation ->
  forall (e : env) le memory object_block object_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr object_block object_offset) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_unload_object) trace le' memory' outcome ->
    pointer_slot_deactivated memory' object_block object_offset.
Proof.
  intros Htail e le memory object_block object_offset
    trace le' memory' outcome Hobj Hexec.
  rewrite unload_object_body_split in Hexec.
  destruct
    (exec_seq_assign _ _ _ _ _ _ _ _ _ _ _ _ Hexec)
    as (trace1 & le1 & memory1 & trace2 & Hfirst & Hrest).
  destruct
    (exec_unload_active_flags_assign
      e le memory object_block object_offset
      trace1 le1 memory1 Out_normal Hobj Hfirst)
    as (_ & _ & Hdeactivated).
  eapply Htail; eauto.
Qed.

Theorem exec_unload_object_deactivates_from_same_obj_frame :
  unload_object_tail_preserves_active_flags_bytes_for_obj ->
  forall (e : env) le memory object_block object_offset
         trace le' memory' outcome,
    le ! S._obj = Some (Vptr object_block object_offset) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_unload_object) trace le' memory' outcome ->
    pointer_slot_deactivated memory' object_block object_offset.
Proof.
  intros Htail_frame e le memory object_block object_offset
    trace le' memory' outcome Hobj Hexec.
  rewrite unload_object_body_split in Hexec.
  destruct
    (exec_seq_assign _ _ _ _ _ _ _ _ _ _ _ _ Hexec)
    as (trace1 & le1 & memory1 & trace2 & Hfirst & Hrest).
  destruct
    (exec_unload_active_flags_assign
      e le memory object_block object_offset
      trace1 le1 memory1 Out_normal Hobj Hfirst)
    as (Hle1 & _ & Hdeactivated).
  subst le1.
  eapply unchanged_on_active_flags_preserves_pointer_slot_deactivated.
  - eapply Htail_frame; eauto.
  - exact Hdeactivated.
Qed.

Theorem exec_unload_object_deactivates_pool_slot :
  unload_object_tail_preserves_deactivation ->
  forall (e : env) le memory pool_block slot
         trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_unload_object) trace le' memory' outcome ->
    slot_deactivated memory' pool_block slot.
Proof.
  intros Htail e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  apply pointer_slot_deactivated_is_pool_slot; [exact Hvalid |].
  eapply exec_unload_object_deactivates; eauto.
Qed.

Theorem exec_unload_object_deactivates_pool_slot_from_same_obj_frame :
  unload_object_tail_preserves_active_flags_bytes_for_obj ->
  forall (e : env) le memory pool_block slot
         trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_unload_object) trace le' memory' outcome ->
    slot_deactivated memory' pool_block slot.
Proof.
  intros Htail_frame e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  apply pointer_slot_deactivated_is_pool_slot; [exact Hvalid |].
  eapply exec_unload_object_deactivates_from_same_obj_frame; eauto.
Qed.
