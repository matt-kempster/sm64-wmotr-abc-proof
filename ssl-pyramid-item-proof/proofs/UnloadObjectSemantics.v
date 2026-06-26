From Coq Require Import Bool Lia List ZArith.
Import ListNotations.
From compcert Require Import AST Coqlib Ctypes Clight ClightBigstep Cop Errors
  Globalenvs Integers Maps Memory Values Clightdefs.
From SSLPyramid.Generated Require Import spawn_object.
From SSLPyramid.Proofs Require Import ASTFacts Spec UnloadSequence UnloadStore.

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

Definition unload_object_camera_to_object_expr : expr :=
  Efield
    unload_object_gfx_expr
    S._cameraToObject (tarray tfloat 3).

Definition unload_object_graph_node_addr_expr : expr :=
  Eaddrof
    unload_object_graph_node_expr
    (tptr (Tstruct S._GraphNode noattr)).

Definition unload_global_parent_graph_node_addr_expr : expr :=
  Eaddrof
    (Evar S._gObjParentGraphNode (Tstruct S._GraphNode noattr))
    (tptr (Tstruct S._GraphNode noattr)).

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

Theorem unload_stop_sounds_call_shape :
  unload_stop_sounds_call =
  Scall None
    (Evar S._stop_sounds_from_source
      (Tfunction ((tptr tfloat) :: nil) tvoid cc_default))
    (unload_object_camera_to_object_expr :: nil).
Proof. reflexivity. Qed.

Theorem unload_geo_remove_child_call_shape :
  unload_geo_remove_child_call =
  Scall None
    (Evar S._geo_remove_child
      (Tfunction
        ((tptr (Tstruct S._GraphNode noattr)) :: nil)
        (tptr (Tstruct S._GraphNode noattr)) cc_default))
    (unload_object_graph_node_addr_expr :: nil).
Proof. reflexivity. Qed.

Theorem unload_geo_add_child_call_shape :
  unload_geo_add_child_call =
  Scall None
    (Evar S._geo_add_child
      (Tfunction
        ((tptr (Tstruct S._GraphNode noattr)) ::
         (tptr (Tstruct S._GraphNode noattr)) :: nil)
        (tptr (Tstruct S._GraphNode noattr)) cc_default))
    (unload_global_parent_graph_node_addr_expr ::
     unload_object_graph_node_addr_expr :: nil).
Proof. reflexivity. Qed.

Theorem unload_non_deallocate_helper_call_shapes :
  unload_stop_sounds_call =
    Scall None
      (Evar S._stop_sounds_from_source
        (Tfunction ((tptr tfloat) :: nil) tvoid cc_default))
      (unload_object_camera_to_object_expr :: nil) /\
  unload_geo_remove_child_call =
    Scall None
      (Evar S._geo_remove_child
        (Tfunction
          ((tptr (Tstruct S._GraphNode noattr)) :: nil)
          (tptr (Tstruct S._GraphNode noattr)) cc_default))
      (unload_object_graph_node_addr_expr :: nil) /\
  unload_geo_add_child_call =
    Scall None
      (Evar S._geo_add_child
        (Tfunction
          ((tptr (Tstruct S._GraphNode noattr)) ::
           (tptr (Tstruct S._GraphNode noattr)) :: nil)
          (tptr (Tstruct S._GraphNode noattr)) cc_default))
      (unload_global_parent_graph_node_addr_expr ::
       unload_object_graph_node_addr_expr :: nil).
Proof.
  repeat split;
    first
      [ apply unload_stop_sounds_call_shape
      | apply unload_geo_remove_child_call_shape
      | apply unload_geo_add_child_call_shape ].
Qed.

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

Theorem unload_graph_node_prev_layout :
  field_offset unload_object_ce S._prev unload_graph_node_members =
  OK (4, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_graph_node_next_layout :
  field_offset unload_object_ce S._next unload_graph_node_members =
  OK (8, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_graph_node_parent_layout :
  field_offset unload_object_ce S._parent unload_graph_node_members =
  OK (12, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_graph_node_children_layout :
  field_offset unload_object_ce S._children unload_graph_node_members =
  OK (16, Full).
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

Lemma valid_object_slot_zero : valid_object_slot 0.
Proof.
  unfold valid_object_slot, object_pool_capacity.
  lia.
Qed.

Lemma object_node_pointer_zero_external_or_pool_slot_header :
  forall pool_block node_block,
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block Ptrofs.zero.
Proof.
  intros pool_block node_block.
  unfold object_node_pointer_external_or_pool_slot_header.
  destruct (peq node_block pool_block) as [Heq | Hneq].
  - subst node_block.
    right.
    exists 0.
    split; [apply valid_object_slot_zero |].
    replace (0 * object_slot_size) with 0 by lia.
    change (Ptrofs.repr 0) with Ptrofs.zero.
    reflexivity.
  - left.
    exact Hneq.
Qed.

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

Definition value_points_to_external_or_pool_slot_header
    (pool_block : block) (value : val) : Prop :=
  forall target_block target_offset,
    value = Vptr target_block target_offset ->
    object_node_pointer_external_or_pool_slot_header
      pool_block target_block target_offset.

Lemma temp_lookup_value_pointer_shape :
  forall le temporary pool_block value,
    temp_points_to_external_or_pool_slot_header
      le temporary pool_block ->
    le ! temporary = Some value ->
    value_points_to_external_or_pool_slot_header pool_block value.
Proof.
  intros le temporary pool_block value Htemp Hlookup.
  unfold value_points_to_external_or_pool_slot_header.
  intros target_block target_offset Hvalue.
  subst value.
  eapply Htemp.
  exact Hlookup.
Qed.

Lemma sem_cast_object_node_pointer_preserves_value_shape :
  forall memory pool_block value cast_value,
    value_points_to_external_or_pool_slot_header pool_block value ->
    sem_cast value
      (tptr (Tstruct S._ObjectNode noattr))
      (tptr (Tstruct S._ObjectNode noattr))
      memory = Some cast_value ->
    value_points_to_external_or_pool_slot_header pool_block cast_value.
Proof.
  intros memory pool_block value cast_value Hshape Hcast.
  unfold value_points_to_external_or_pool_slot_header in *.
  intros target_block target_offset Hcast_value.
  subst cast_value.
  destruct value; cbn in Hcast; try discriminate;
    inv Hcast; eauto.
Qed.

Lemma storev_shaped_pointer_preserves_object_node_field_deref_shape :
  forall memory memory' pool_block source_block source_offset field_delta
         store_chunk store_block store_offset stored_value,
    Mem.storev store_chunk memory (Vptr store_block store_offset)
      stored_value = Some memory' ->
    value_points_to_external_or_pool_slot_header
      pool_block stored_value ->
    object_node_field_deref_shape
      memory pool_block source_block source_offset field_delta ->
    object_node_field_deref_shape
      memory' pool_block source_block source_offset field_delta.
Proof.
  intros memory memory' pool_block source_block source_offset field_delta
    store_chunk store_block store_offset stored_value Hstore Hstored_shape
    Hfield_shape.
  unfold object_node_field_deref_shape in *.
  intros target_block target_offset Hderef.
  inv Hderef; cbn in *; try discriminate.
  unfold Mem.storev in Hstore.
  unfold Mem.loadv in H0.
  pose proof
    (Mem.load_pointer_store
      store_chunk memory store_block (Ptrofs.unsigned store_offset)
      stored_value memory' chunk source_block
      (Ptrofs.unsigned
        (Ptrofs.add source_offset (Ptrofs.repr field_delta)))
      target_block target_offset Hstore H0) as Hload_case.
  destruct Hload_case as
    [(Hstored_value & _ & _ & _) | Hother].
  - eapply Hstored_shape.
    exact Hstored_value.
  - eapply Hfield_shape.
    econstructor.
    + exact H.
    + unfold Mem.loadv.
      rewrite
        (Mem.load_store_other
          store_chunk memory store_block
          (Ptrofs.unsigned store_offset) stored_value memory'
          Hstore chunk source_block
          (Ptrofs.unsigned
            (Ptrofs.add source_offset (Ptrofs.repr field_delta)))) in H0
        by exact Hother.
      exact H0.
Qed.

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

Theorem graph_node_link_field_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset field_offset byte,
    valid_object_slot watched_slot ->
    0 <= field_offset ->
    field_offset + 4 <= object_active_flags_offset ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr field_offset)) <=
      byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr field_offset)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset field_offset byte
    Hvalid Hnonnegative Hbefore_active Hshape Hrange.
  eapply
    (object_node_field_store_misses_active_flags_from_header_shape
      pool_block watched_slot node_block node_offset field_offset 4 byte).
  - exact Hvalid.
  - exact Hnonnegative.
  - lia.
  - unfold object_slot_size, object_active_flags_offset in *.
    lia.
  - exact Hbefore_active.
  - exact Hshape.
  - exact Hrange.
Qed.

Theorem graph_node_prev_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset byte,
    valid_object_slot watched_slot ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 4)) <= byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 4)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset byte
    Hvalid Hshape Hrange.
  eapply graph_node_link_field_store_misses_active_flags_from_header_shape;
    eauto.
  - lia.
  - unfold object_active_flags_offset; lia.
Qed.

Theorem graph_node_next_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset byte,
    valid_object_slot watched_slot ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 8)) <= byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 8)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset byte
    Hvalid Hshape Hrange.
  eapply graph_node_link_field_store_misses_active_flags_from_header_shape;
    eauto.
  - lia.
  - unfold object_active_flags_offset; lia.
Qed.

Theorem graph_node_parent_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset byte,
    valid_object_slot watched_slot ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 12)) <= byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 12)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset byte
    Hvalid Hshape Hrange.
  eapply graph_node_link_field_store_misses_active_flags_from_header_shape;
    eauto.
  - lia.
  - unfold object_active_flags_offset; lia.
Qed.

Theorem graph_node_children_store_misses_active_flags_from_header_shape :
  forall pool_block watched_slot node_block node_offset byte,
    valid_object_slot watched_slot ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 16)) <= byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr 16)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte.
Proof.
  intros pool_block watched_slot node_block node_offset byte
    Hvalid Hshape Hrange.
  eapply graph_node_link_field_store_misses_active_flags_from_header_shape;
    eauto.
  - lia.
  - unfold object_active_flags_offset; lia.
Qed.

Theorem store_to_other_block_preserves_active_flags_bytes :
  forall chunk memory object_block object_offset store_block store_offset
         value memory',
    store_block <> object_block ->
    Mem.store chunk memory store_block store_offset value = Some memory' ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.
Proof.
  intros chunk memory object_block object_offset store_block store_offset
    value memory' Hblock Hstore.
  eapply Mem.store_unchanged_on; eauto.
  intros byte _ Hactive.
  destruct Hactive as (Hsame_block & _).
  subst store_block.
  contradiction.
Qed.

Theorem storev_to_other_block_preserves_active_flags_bytes :
  forall chunk memory object_block object_offset store_block store_offset
         value memory',
    store_block <> object_block ->
    Mem.storev chunk memory (Vptr store_block store_offset) value =
      Some memory' ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.
Proof.
  intros chunk memory object_block object_offset store_block store_offset
    value memory' Hblock Hstore.
  unfold Mem.storev in Hstore.
  eapply store_to_other_block_preserves_active_flags_bytes; eauto.
Qed.

Theorem assign_loc_by_value_to_other_block_preserves_active_flags_bytes :
  forall ce ty chunk memory object_block object_offset store_block
         store_offset value memory',
    access_mode ty = By_value chunk ->
    store_block <> object_block ->
    assign_loc ce ty memory store_block store_offset Full value memory' ->
    Mem.unchanged_on (active_flags_byte object_block object_offset)
      memory memory'.
Proof.
  intros ce ty chunk memory object_block object_offset store_block
    store_offset value memory' Hmode Hblock Hassign.
  inv Hassign; try congruence.
  match goal with
  | Hmode' : access_mode ty = By_value ?stored_chunk,
    Hstore : Mem.storev ?stored_chunk _ (Vptr store_block store_offset) _ =
      Some _ |- _ =>
      assert (stored_chunk = chunk) by congruence;
      subst stored_chunk;
      eapply storev_to_other_block_preserves_active_flags_bytes; eauto
  end.
Qed.

Theorem non_deallocate_helper_write_alias_frames :
  (forall pool_block watched_slot node_block node_offset field_offset byte,
    valid_object_slot watched_slot ->
    (field_offset = 4 \/
     field_offset = 8 \/
     field_offset = 12 \/
     field_offset = 16) ->
    object_node_pointer_external_or_pool_slot_header
      pool_block node_block node_offset ->
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr field_offset)) <=
      byte <
    Ptrofs.unsigned (Ptrofs.add node_offset (Ptrofs.repr field_offset)) + 4 ->
    ~ active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z))
        node_block byte) /\
  (forall chunk memory memory' pool_block watched_slot store_block
          store_offset value,
    valid_object_slot watched_slot ->
    store_block <> pool_block ->
    Mem.store chunk memory store_block store_offset value = Some memory' ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z)))
      memory memory') /\
  (forall ce ty chunk memory memory' pool_block watched_slot store_block
          store_offset value,
    valid_object_slot watched_slot ->
    access_mode ty = By_value chunk ->
    store_block <> pool_block ->
    assign_loc ce ty memory store_block store_offset Full value memory' ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((watched_slot * object_slot_size)%Z)))
      memory memory').
Proof.
  split.
  - intros pool_block watched_slot node_block node_offset field_offset byte
      Hvalid Hfield Hshape Hrange.
    destruct Hfield as
      [Hfield | [Hfield | [Hfield | Hfield]]]; subst field_offset.
    + eapply graph_node_prev_store_misses_active_flags_from_header_shape;
        eauto.
    + eapply graph_node_next_store_misses_active_flags_from_header_shape;
        eauto.
    + eapply graph_node_parent_store_misses_active_flags_from_header_shape;
        eauto.
    + eapply graph_node_children_store_misses_active_flags_from_header_shape;
        eauto.
  - split.
    + intros store_chunk memory memory' pool_block watched_slot store_block
        store_offset value _ Hblock Hstore.
      eapply store_to_other_block_preserves_active_flags_bytes; eauto.
    + intros ce ty store_chunk memory memory' pool_block watched_slot
        store_block store_offset value _ Hmode Hblock Hassign.
      eapply assign_loc_by_value_to_other_block_preserves_active_flags_bytes;
        eauto.
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

Theorem pool_slot_deactivated_is_pointer_slot :
  forall memory pool_block slot,
    valid_object_slot slot ->
    slot_deactivated memory pool_block slot ->
    pointer_slot_deactivated memory pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)).
Proof.
  intros memory pool_block slot Hvalid Hslot.
  unfold pointer_slot_deactivated.
  unfold slot_deactivated in Hslot.
  rewrite (pool_slot_active_flags_address slot Hvalid).
  exact Hslot.
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

Lemma exec_unload_active_flags_assign_preserves_other_pool_slot :
  forall (e : env) le memory pool_block changed_slot kept_slot
         trace le' memory' outcome,
    valid_object_slot changed_slot ->
    kept_slot <> changed_slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((changed_slot * object_slot_size)%Z))) ->
    slot_deactivated memory pool_block kept_slot ->
    exec_stmt function_entry2 unload_object_ge e le memory
      unload_active_flags_assign trace le' memory' outcome ->
    slot_deactivated memory' pool_block kept_slot.
Proof.
  intros e le memory pool_block changed_slot kept_slot trace le' memory'
    outcome Hvalid_changed Hdifferent Hobj Hdeactivated Hexec.
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
        [ constr_eq ofs (Ptrofs.repr (changed_slot * object_slot_size));
          fail 1
        | first
            [ constr_eq b pool_block
            | assert (b = pool_block) by congruence; subst b ];
          assert
            (ofs = Ptrofs.repr (changed_slot * object_slot_size))
            by congruence;
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
      inv Hassign;
      try congruence;
      simpl in H;
      inv H;
      unfold Mem.storev in H0;
      rewrite
        (pool_slot_active_flags_address changed_slot Hvalid_changed)
        in H0;
      eapply store_other_slot_preserves_deactivated;
        eauto
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

Lemma eval_unload_object_header_lhs_lvalue_pointer :
  forall e le memory pool_block slot loc ofs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_lvalue unload_object_ge e le memory
      unload_object_header_lhs loc ofs Full ->
    loc = pool_block /\
    ofs = Ptrofs.repr ((slot * object_slot_size)%Z).
Proof.
  intros e le memory pool_block slot loc ofs Hvalid Hobj Hlv.
  unfold unload_object_header_lhs in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  rewrite unload_object_genv_cenv in *.
  match goal with
  | Hty : typeof (Ederef _ _) = Tstruct _ _ |- _ =>
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
        (Ederef
          (Etempvar S._obj (tptr (Tstruct S._Object noattr)))
          (Tstruct S._Object noattr))
        (Vptr ?base_block ?base_ofs) |- _ =>
      destruct
        (eval_unload_object_base_expr_pointer
          e le memory pool_block slot base_block base_ofs
          Hvalid Hobj Hbase) as (Hblock & Hofs);
      subst base_block base_ofs
  end.
  rewrite Ptrofs.add_zero.
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

Definition statement_preserves_temp_shape
    (temporary : ident) (statement_body : statement) : Prop :=
  forall e le memory pool_block trace le' memory' outcome,
    temp_points_to_external_or_pool_slot_header le temporary pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      statement_body trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header le' temporary pool_block.

Lemma statement_preserves_temp_shape_sset_different :
  forall protected written expression,
    Pos.eqb written protected = false ->
    statement_preserves_temp_shape protected (Sset written expression).
Proof.
  intros protected written expression Hdifferent.
  unfold statement_preserves_temp_shape.
  intros e le memory pool_block trace le' memory' outcome Hshape Hexec.
  destruct
    (exec_sset_different_preserves_temp_shape
      protected written expression e le memory pool_block trace le' memory'
      outcome Hdifferent Hshape Hexec)
    as (Hshape' & _ & _).
  exact Hshape'.
Qed.

Lemma statement_preserves_temp_shape_assign :
  forall protected lhs rhs,
    statement_preserves_temp_shape protected (Sassign lhs rhs).
Proof.
  intros protected lhs rhs.
  unfold statement_preserves_temp_shape.
  intros e le memory pool_block trace le' memory' outcome Hshape Hexec.
  inv Hexec.
  exact Hshape.
Qed.

Lemma statement_preserves_temp_shape_sequence :
  forall protected first rest,
    statement_preserves_temp_shape protected first ->
    statement_preserves_temp_shape protected rest ->
    statement_preserves_temp_shape protected (Ssequence first rest).
Proof.
  intros protected first rest Hfirst Hrest.
  unfold statement_preserves_temp_shape in *.
  intros e le memory pool_block trace le' memory' outcome Hshape Hexec.
  inv Hexec.
  - match goal with
    | Hfirst_exec :
        exec_stmt _ _ _ _ _ first ?trace1 ?le_after_first
          ?memory_after_first Out_normal,
      Hrest_exec :
        exec_stmt _ _ _ ?le_mid ?memory_mid rest ?trace2 le' memory'
          outcome |- _ =>
        assert
          (Hshape_after_first :
            temp_points_to_external_or_pool_slot_header
              le_after_first protected pool_block)
          by (eapply Hfirst; eauto);
        eapply Hrest; eauto
    end.
  - eapply Hfirst; eauto.
Qed.

Lemma deallocate_object_first_splice_preserves_free_list_shape :
  forall e le memory pool_block trace le' memory' outcome,
    temp_points_to_external_or_pool_slot_header le S._freeList pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header
      le' S._freeList pool_block.
Proof.
  change
    (statement_preserves_temp_shape S._freeList
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))).
  apply statement_preserves_temp_shape_sequence.
  - apply statement_preserves_temp_shape_sset_different.
    vm_compute.
    reflexivity.
  - apply statement_preserves_temp_shape_sequence.
    + apply statement_preserves_temp_shape_sset_different.
      vm_compute.
      reflexivity.
    + apply statement_preserves_temp_shape_assign.
Qed.

Lemma deallocate_object_second_splice_preserves_free_list_shape :
  forall e le memory pool_block trace le' memory' outcome,
    temp_points_to_external_or_pool_slot_header le S._freeList pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (Ssequence
        deallocate_object_read_prev_again
        (Ssequence
          deallocate_object_read_next_again
          deallocate_object_prev_next_assign))
      trace le' memory' outcome ->
    temp_points_to_external_or_pool_slot_header
      le' S._freeList pool_block.
Proof.
  change
    (statement_preserves_temp_shape S._freeList
      (Ssequence
        deallocate_object_read_prev_again
        (Ssequence
          deallocate_object_read_next_again
          deallocate_object_prev_next_assign))).
  apply statement_preserves_temp_shape_sequence.
  - apply statement_preserves_temp_shape_sset_different.
    vm_compute.
    reflexivity.
  - apply statement_preserves_temp_shape_sequence.
    + apply statement_preserves_temp_shape_sset_different.
      vm_compute.
      reflexivity.
    + apply statement_preserves_temp_shape_assign.
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

Definition deallocate_object_body_shape_obligations
    (e : env) (le : temp_env) (memory : mem)
    (pool_block : block) (slot : Z) : Prop :=
  object_node_field_deref_shape
    memory pool_block pool_block
    (Ptrofs.repr ((slot * object_slot_size)%Z)) 96 /\
  temp_points_to_external_or_pool_slot_header le S._freeList pool_block /\
  (forall trace_first le_after_first memory_after_first,
    exec_stmt function_entry2 unload_object_ge e le memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace_first le_after_first memory_after_first Out_normal ->
    object_node_field_deref_shape
      memory_after_first pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 100).

Lemma deallocate_object_body_pool_slot_frame_from_shape_obligations :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    deallocate_object_body_shape_obligations e le memory pool_block slot ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_deallocate_object) trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj (Hnext_shape & Hfree_shape & Hprev_after_first) Hexec.
  rewrite deallocate_object_body_split in Hexec.
  inv Hexec.
  - match goal with
    | Hfirst :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_next
            (Ssequence
              deallocate_object_read_prev
              deallocate_object_next_prev_assign))
          ?trace_first ?le_after_first ?memory_after_first Out_normal,
      Hrest :
        exec_stmt _ _ _ ?le_mid ?memory_mid
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
              deallocate_object_free_list_next_assign))
          ?trace_rest le' memory' outcome |- _ =>
        destruct
          (deallocate_object_first_splice_pool_slot_frame_from_next_deref_shape
            e le memory pool_block slot trace_first le_after_first
            memory_after_first Out_normal Hvalid Hobj Hnext_shape Hfirst)
          as (Hobj_after_first & Hunchanged_first);
        pose proof
          (deallocate_object_first_splice_preserves_free_list_shape
            e le memory pool_block trace_first le_after_first
            memory_after_first Out_normal Hfree_shape Hfirst)
          as Hfree_after_first;
        pose proof
          (Hprev_after_first trace_first le_after_first
            memory_after_first Hfirst)
          as Hprev_shape;
        inv Hrest
    end.
    + destruct
        (deallocate_object_second_splice_pool_slot_frame_from_prev_deref_shape
          e le1 m1 pool_block slot t0 le2 m0 Out_normal
          Hvalid Hobj_after_first Hprev_shape H5)
        as (Hobj_after_second & Hunchanged_second).
      pose proof
        (deallocate_object_second_splice_preserves_free_list_shape
          e le1 m1 pool_block t0 le2 m0 Out_normal
          Hfree_after_first H5)
        as Hfree_after_second.
      destruct
        (deallocate_object_free_list_insert_pool_slot_frame_from_free_list_shape
          e le2 m0 pool_block slot t3 le' memory' outcome
          Hvalid Hobj_after_second Hfree_after_second H11)
        as (Hobj_final & Hunchanged_final).
      split; [exact Hobj_final |].
      eapply Mem.unchanged_on_trans.
      * exact Hunchanged_first.
      * eapply Mem.unchanged_on_trans; eauto.
    + destruct
        (deallocate_object_second_splice_pool_slot_frame_from_prev_deref_shape
          e le1 m1 pool_block slot t2 le' memory' outcome
          Hvalid Hobj_after_first Hprev_shape H5)
        as (Hobj_after_second & Hunchanged_second).
      split; [exact Hobj_after_second |].
      eapply Mem.unchanged_on_trans; eauto.
  - match goal with
    | Hfirst :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_next
            (Ssequence
              deallocate_object_read_prev
              deallocate_object_next_prev_assign))
          ?trace_first ?le_after_first ?memory_after_first outcome |- _ =>
        destruct
          (deallocate_object_first_splice_pool_slot_frame_from_next_deref_shape
            e le memory pool_block slot trace_first le_after_first
            memory_after_first outcome Hvalid Hobj Hnext_shape Hfirst)
          as (Hobj_after_first & Hunchanged_first);
        split; [exact Hobj_after_first | exact Hunchanged_first]
    end.
Qed.

Theorem deallocate_object_body_preserves_pool_slot_active_flags_from_shape_obligations :
  forall e le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    deallocate_object_body_shape_obligations e le memory pool_block slot ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_deallocate_object) trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hshape Hexec.
  destruct
    (deallocate_object_body_pool_slot_frame_from_shape_obligations
      e le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hshape Hexec) as (_ & Hunchanged).
  exact Hunchanged.
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

Definition deallocate_object_internal_call_shape_obligations
    (memory : mem) (vargs : list val)
    (pool_block : block) (slot : Z) : Prop :=
  forall entry_env entry_temps entry_memory,
    function_entry2 unload_object_ge S.f_deallocate_object
      vargs memory entry_env entry_temps entry_memory ->
    entry_temps ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    deallocate_object_body_shape_obligations
      entry_env entry_temps entry_memory pool_block slot.

Lemma function_entry2_deallocate_object_binds_parameter_temps :
  forall memory free_value obj_value entry_env entry_temps entry_memory,
    function_entry2 unload_object_ge S.f_deallocate_object
      (free_value :: obj_value :: nil)
      memory entry_env entry_temps entry_memory ->
    entry_temps ! S._freeList = Some free_value /\
    entry_temps ! S._obj = Some obj_value /\
    entry_memory = memory.
Proof.
  intros memory free_value obj_value entry_env entry_temps entry_memory
    Hentry.
  inv Hentry.
  cbn in *.
  match goal with
  | Halloc : alloc_variables _ _ _ nil _ _ |- _ => inv Halloc
  end.
  repeat match goal with
  | H : Some _ = Some _ |- _ => inv H
  end.
  repeat split; reflexivity.
Qed.

Definition deallocate_object_bound_entry_shape_obligations
    (memory : mem) (free_value obj_value : val)
    (pool_block : block) (slot : Z) : Prop :=
  forall entry_env entry_temps,
    entry_temps ! S._freeList = Some free_value ->
    entry_temps ! S._obj = Some obj_value ->
    deallocate_object_body_shape_obligations
      entry_env entry_temps memory pool_block slot.

Definition deallocate_object_resolved_free_list_shape_obligations
    (memory : mem) (free_block : block)
    (pool_block : block) (slot : Z) : Prop :=
  object_node_field_deref_shape
    memory pool_block pool_block
    (Ptrofs.repr ((slot * object_slot_size)%Z)) 96 /\
  object_node_pointer_external_or_pool_slot_header
    pool_block free_block Ptrofs.zero /\
  (forall entry_env entry_temps trace_first le_after_first memory_after_first,
    entry_temps ! S._freeList =
      Some (Vptr free_block Ptrofs.zero) ->
    entry_temps ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge entry_env entry_temps memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace_first le_after_first memory_after_first Out_normal ->
    object_node_field_deref_shape
      memory_after_first pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 100).

Definition object_pool_link_fields_well_shaped
    (memory : mem) (pool_block : block) : Prop :=
  forall slot,
    valid_object_slot slot ->
    object_node_field_deref_shape
      memory pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 96 /\
    object_node_field_deref_shape
      memory pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 100.

Lemma storev_shaped_pointer_preserves_object_pool_link_fields :
  forall memory memory' pool_block store_chunk store_block store_offset
         stored_value,
    Mem.storev store_chunk memory (Vptr store_block store_offset)
      stored_value = Some memory' ->
    value_points_to_external_or_pool_slot_header
      pool_block stored_value ->
    object_pool_link_fields_well_shaped memory pool_block ->
    object_pool_link_fields_well_shaped memory' pool_block.
Proof.
  intros memory memory' pool_block store_chunk store_block store_offset
    stored_value Hstore Hstored_shape Hlinks.
  unfold object_pool_link_fields_well_shaped in *.
  intros slot Hvalid.
  destruct (Hlinks slot Hvalid) as (Hnext_shape & Hprev_shape).
  split.
  - eapply storev_shaped_pointer_preserves_object_node_field_deref_shape;
      eauto.
  - eapply storev_shaped_pointer_preserves_object_node_field_deref_shape;
      eauto.
Qed.

Lemma assign_loc_shaped_pointer_preserves_object_pool_link_fields :
  forall ty chunk memory memory' pool_block store_block store_offset
         stored_value,
    access_mode ty = By_value chunk ->
    assign_loc unload_object_ce ty memory store_block store_offset
      Full stored_value memory' ->
    value_points_to_external_or_pool_slot_header
      pool_block stored_value ->
    object_pool_link_fields_well_shaped memory pool_block ->
    object_pool_link_fields_well_shaped memory' pool_block.
Proof.
  intros ty chunk memory memory' pool_block store_block store_offset
    stored_value Hmode Hassign Hstored_shape Hlinks.
  inv Hassign; try congruence.
  eapply storev_shaped_pointer_preserves_object_pool_link_fields;
    eauto.
Qed.

Lemma exec_deallocate_object_next_prev_assign_preserves_pool_link_fields_from_value_shape :
  forall e le memory pool_block trace le' memory' outcome,
    temp_points_to_external_or_pool_slot_header le S._t'5 pool_block ->
    object_pool_link_fields_well_shaped memory pool_block ->
    exec_stmt function_entry2 unload_object_ge e le memory
      deallocate_object_next_prev_assign trace le' memory' outcome ->
    le' = le /\
    outcome = Out_normal /\
    object_pool_link_fields_well_shaped memory' pool_block.
Proof.
  intros e le memory pool_block trace le' memory' outcome
    Hvalue_shape Hlinks Hexec.
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
        as (target_block & target_offset & _ & Hloc & Hofs & Hbf);
      subst loc ofs bf
  end.
  split; [reflexivity | split; [reflexivity |]].
  assert
    (Hrhs_shape :
      value_points_to_external_or_pool_slot_header pool_block v2).
  { unfold value_points_to_external_or_pool_slot_header.
    intros rhs_block rhs_offset Hrhs_value.
    subst v2.
    inv H2;
      try (match goal with
           | Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hlv]
           end).
    eapply Hvalue_shape.
    match goal with
    | Hlookup : _ ! S._t'5 = Some (Vptr rhs_block rhs_offset) |- _ =>
        exact Hlookup
    end. }
  assert
    (Hstored_shape :
      value_points_to_external_or_pool_slot_header pool_block v).
  { eapply sem_cast_object_node_pointer_preserves_value_shape; eauto. }
  eapply assign_loc_shaped_pointer_preserves_object_pool_link_fields
    with (chunk := Mint32);
    eauto;
    reflexivity.
Qed.

Definition first_deallocate_splice_shaped_store_preserves_pool_link_fields
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  forall entry_env entry_temps trace_first le_after_first memory_after_first,
    valid_object_slot slot ->
    entry_temps ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_pool_link_fields_well_shaped memory pool_block ->
    exec_stmt function_entry2 unload_object_ge entry_env entry_temps memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace_first le_after_first memory_after_first Out_normal ->
    temp_points_to_external_or_pool_slot_header
      le_after_first S._t'4 pool_block ->
    temp_points_to_external_or_pool_slot_header
      le_after_first S._t'5 pool_block ->
    object_pool_link_fields_well_shaped memory_after_first pool_block.

Definition first_deallocate_splice_preserves_pool_link_fields
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  forall entry_env entry_temps trace_first le_after_first memory_after_first,
    entry_temps ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge entry_env entry_temps memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace_first le_after_first memory_after_first Out_normal ->
    object_pool_link_fields_well_shaped memory_after_first pool_block.

Lemma deallocate_object_first_splice_loads_pool_link_shapes :
  forall entry_env entry_temps memory pool_block slot trace_first
         le_after_first memory_after_first,
    valid_object_slot slot ->
    entry_temps ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_pool_link_fields_well_shaped memory pool_block ->
    exec_stmt function_entry2 unload_object_ge entry_env entry_temps memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace_first le_after_first memory_after_first Out_normal ->
    temp_points_to_external_or_pool_slot_header
      le_after_first S._t'4 pool_block /\
    temp_points_to_external_or_pool_slot_header
      le_after_first S._t'5 pool_block.
Proof.
  intros entry_env entry_temps memory pool_block slot trace_first
    le_after_first memory_after_first Hvalid Hobj Hlinks Hexec.
  destruct (Hlinks slot Hvalid) as (Hnext_shape & Hprev_shape).
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
          ?memory_after_next Out_normal |- _ =>
        change deallocate_object_read_next with
          (Sset S._t'4 (object_node_field_expr S._obj S._next))
          in Hread_next;
        destruct
          (exec_deallocate_object_read_next_sets_t4_shape_from_deref_shape
            entry_env entry_temps memory pool_block pool_block
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
            entry_env entry_temps memory trace_next le_after_next
            memory_after_next Out_normal Ht4_not_obj Hobj Hread_next)
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
    + match goal with
      | Hread_prev :
          exec_stmt _ _ _ ?le_after_next memory
            deallocate_object_read_prev ?trace_prev ?le_after_prev
            ?memory_after_prev Out_normal,
        Hassign :
          exec_stmt _ _ _ ?le_after_prev ?memory_after_prev
            deallocate_object_next_prev_assign ?trace_assign
            le_after_first memory_after_first Out_normal |- _ =>
          change deallocate_object_read_prev with
            (Sset S._t'5 (object_node_field_expr S._obj S._prev))
            in Hread_prev;
          destruct
            (exec_deallocate_object_read_prev_sets_t5_shape_from_deref_shape
              entry_env le_after_next memory pool_block pool_block
              (Ptrofs.repr (slot * object_slot_size))
              trace_prev le_after_prev memory_after_prev Out_normal
              Hobj_after_next Hprev_shape Hread_prev)
            as (Ht5_after_prev & Hmemory_after_prev & _);
          destruct
            (exec_sset_different_preserves_lookup
              S._obj
              (Vptr pool_block
                (Ptrofs.repr (slot * object_slot_size)))
              S._t'5 (object_node_field_expr S._obj S._prev)
              entry_env le_after_next memory trace_prev le_after_prev
              memory_after_prev Out_normal
              Ht5_not_obj Hobj_after_next Hread_prev)
            as (Hobj_after_prev & _ & _);
          destruct
            (exec_sset_different_preserves_temp_shape
              S._t'4 S._t'5
              (object_node_field_expr S._obj S._prev)
              entry_env le_after_next memory pool_block trace_prev
              le_after_prev memory_after_prev Out_normal
              Ht5_not_t4 Ht4_after_next Hread_prev)
            as (Ht4_after_prev & _ & _);
          subst memory_after_prev;
          destruct
            (exec_deallocate_object_next_prev_assign_preserves_active_flags_from_target_shape
              entry_env le_after_prev memory pool_block slot trace_assign
              le_after_first memory_after_first Out_normal
              Hvalid Hobj_after_prev Ht4_after_prev Hassign)
            as (Hle_final & _ & _);
          subst le_after_first;
          split; assumption
      end.
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

Theorem first_deallocate_splice_shaped_store_preserves_pool_link_fields_holds :
  forall memory pool_block slot,
    first_deallocate_splice_shaped_store_preserves_pool_link_fields
      memory pool_block slot.
Proof.
  unfold first_deallocate_splice_shaped_store_preserves_pool_link_fields.
  intros memory pool_block slot entry_env entry_temps trace_first
    le_after_first memory_after_first Hvalid Hobj Hlinks Hexec _ _.
  destruct (Hlinks slot Hvalid) as (_ & Hprev_shape).
  assert (Ht4_not_obj : Pos.eqb S._t'4 S._obj = false)
    by (vm_compute; reflexivity).
  inv Hexec.
  - change deallocate_object_read_next with
      (Sset S._t'4 (object_node_field_expr S._obj S._next))
      in H4.
    destruct
      (exec_sset_different_preserves_lookup
        S._obj
        (Vptr pool_block
          (Ptrofs.repr (slot * object_slot_size)))
        S._t'4 (object_node_field_expr S._obj S._next)
        entry_env entry_temps memory t1 le1 m1 Out_normal
        Ht4_not_obj Hobj H4)
      as (Hobj_after_next & Hm1 & _).
    subst m1.
    match goal with
    | Hrest :
        exec_stmt _ _ _ _ _
          (Ssequence
            deallocate_object_read_prev
            deallocate_object_next_prev_assign)
          _ _ _ _ |- _ =>
        inv Hrest
    end.
    + match goal with
      | Hread_prev :
          exec_stmt _ _ _ ?le_after_next memory
            deallocate_object_read_prev ?trace_prev ?le_after_prev
            ?memory_after_prev Out_normal,
        Hassign :
          exec_stmt _ _ _ ?le_after_prev ?memory_after_prev
            deallocate_object_next_prev_assign ?trace_assign
            le_after_first memory_after_first Out_normal |- _ =>
          change deallocate_object_read_prev with
            (Sset S._t'5 (object_node_field_expr S._obj S._prev))
            in Hread_prev;
          destruct
            (exec_deallocate_object_read_prev_sets_t5_shape_from_deref_shape
              entry_env le_after_next memory pool_block pool_block
              (Ptrofs.repr (slot * object_slot_size))
              trace_prev le_after_prev memory_after_prev Out_normal
              Hobj_after_next Hprev_shape Hread_prev)
            as (Ht5_after_prev & Hmemory_after_prev & _);
          subst memory_after_prev;
          destruct
            (exec_deallocate_object_next_prev_assign_preserves_pool_link_fields_from_value_shape
              entry_env le_after_prev memory pool_block trace_assign
              le_after_first memory_after_first Out_normal
              Ht5_after_prev Hlinks Hassign)
            as (_ & _ & Hlinks_after_first);
          exact Hlinks_after_first
      end.
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

Theorem first_deallocate_splice_preserves_pool_link_fields_from_shaped_store :
  forall memory pool_block slot,
    valid_object_slot slot ->
    object_pool_link_fields_well_shaped memory pool_block ->
    first_deallocate_splice_shaped_store_preserves_pool_link_fields
      memory pool_block slot ->
    first_deallocate_splice_preserves_pool_link_fields
      memory pool_block slot.
Proof.
  unfold first_deallocate_splice_shaped_store_preserves_pool_link_fields,
    first_deallocate_splice_preserves_pool_link_fields.
  intros memory pool_block slot Hvalid Hlinks Hstore
    entry_env entry_temps trace_first le_after_first memory_after_first
    Hobj Hexec.
  destruct
    (deallocate_object_first_splice_loads_pool_link_shapes
      entry_env entry_temps memory pool_block slot trace_first
      le_after_first memory_after_first Hvalid Hobj Hlinks Hexec)
    as (Ht4_shape & Ht5_shape).
  eapply Hstore; eauto.
Qed.

Theorem first_deallocate_splice_preserves_pool_link_fields_from_pool_link_fields :
  forall memory pool_block slot,
    valid_object_slot slot ->
    object_pool_link_fields_well_shaped memory pool_block ->
    first_deallocate_splice_preserves_pool_link_fields
      memory pool_block slot.
Proof.
  intros memory pool_block slot Hvalid Hlinks.
  eapply first_deallocate_splice_preserves_pool_link_fields_from_shaped_store;
    eauto.
  apply first_deallocate_splice_shaped_store_preserves_pool_link_fields_holds.
Qed.

Definition deallocate_object_resolved_free_list_deref_shape_obligations
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  object_node_field_deref_shape
    memory pool_block pool_block
    (Ptrofs.repr ((slot * object_slot_size)%Z)) 96 /\
  (forall entry_env entry_temps trace_first le_after_first memory_after_first,
    entry_temps ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge entry_env entry_temps memory
      (Ssequence
        deallocate_object_read_next
        (Ssequence
          deallocate_object_read_prev
          deallocate_object_next_prev_assign))
      trace_first le_after_first memory_after_first Out_normal ->
    object_node_field_deref_shape
      memory_after_first pool_block pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)) 100).

Theorem deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields :
  forall memory pool_block slot,
    valid_object_slot slot ->
    object_pool_link_fields_well_shaped memory pool_block ->
    first_deallocate_splice_preserves_pool_link_fields
      memory pool_block slot ->
    deallocate_object_resolved_free_list_deref_shape_obligations
      memory pool_block slot.
Proof.
  intros memory pool_block slot Hvalid Hlinks Hfirst_splice.
  unfold deallocate_object_resolved_free_list_deref_shape_obligations.
  destruct (Hlinks slot Hvalid) as (Hnext_shape & _).
  split; [exact Hnext_shape |].
  intros entry_env entry_temps trace_first le_after_first
    memory_after_first Hobj Hexec.
  pose proof
    (Hfirst_splice entry_env entry_temps trace_first le_after_first
      memory_after_first Hobj Hexec) as Hlinks_after_first.
  destruct (Hlinks_after_first slot Hvalid) as (_ & Hprev_shape).
  exact Hprev_shape.
Qed.

Theorem deallocate_object_resolved_free_list_deref_shapes_from_pool_link_shaped_store :
  forall memory pool_block slot,
    valid_object_slot slot ->
    object_pool_link_fields_well_shaped memory pool_block ->
    first_deallocate_splice_shaped_store_preserves_pool_link_fields
      memory pool_block slot ->
    deallocate_object_resolved_free_list_deref_shape_obligations
      memory pool_block slot.
Proof.
  intros memory pool_block slot Hvalid Hlinks Hstore.
  eapply deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields;
    eauto.
  eapply first_deallocate_splice_preserves_pool_link_fields_from_shaped_store;
    eauto.
Qed.

Theorem deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields_holds :
  forall memory pool_block slot,
    valid_object_slot slot ->
    object_pool_link_fields_well_shaped memory pool_block ->
    deallocate_object_resolved_free_list_deref_shape_obligations
      memory pool_block slot.
Proof.
  intros memory pool_block slot Hvalid Hlinks.
  eapply deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields;
    eauto.
  eapply first_deallocate_splice_preserves_pool_link_fields_from_pool_link_fields;
    eauto.
Qed.

Theorem deallocate_object_resolved_free_list_shape_obligations_from_deref_shapes :
  forall memory free_block pool_block slot,
    deallocate_object_resolved_free_list_deref_shape_obligations
      memory pool_block slot ->
    deallocate_object_resolved_free_list_shape_obligations
      memory free_block pool_block slot.
Proof.
  intros memory free_block pool_block slot
    (Hnext_shape & Hprev_after_first).
  unfold deallocate_object_resolved_free_list_shape_obligations.
  split; [exact Hnext_shape |].
  split.
  - apply object_node_pointer_zero_external_or_pool_slot_header.
  - intros entry_env entry_temps trace_first le_after_first
      memory_after_first _ Hobj Hexec.
    eapply Hprev_after_first; eauto.
Qed.

Theorem deallocate_object_bound_entry_shape_obligations_from_resolved_free_list_shapes :
  forall memory free_block pool_block slot,
    deallocate_object_resolved_free_list_shape_obligations
      memory free_block pool_block slot ->
    deallocate_object_bound_entry_shape_obligations
      memory (Vptr free_block Ptrofs.zero)
      (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      pool_block slot.
Proof.
  intros memory free_block pool_block slot
    (Hnext_shape & Hfree_pointer_shape & Hprev_after_first).
  unfold deallocate_object_bound_entry_shape_obligations.
  intros entry_env entry_temps Hfree Hobj.
  unfold deallocate_object_body_shape_obligations.
  split; [exact Hnext_shape |].
  split.
  - unfold temp_points_to_external_or_pool_slot_header.
    intros node_block node_offset Hnode.
    assert (node_block = free_block) by congruence.
    assert (node_offset = Ptrofs.zero) by congruence.
    subst node_block node_offset.
    exact Hfree_pointer_shape.
  - intros trace_first le_after_first memory_after_first Hexec.
    eapply Hprev_after_first; eauto.
Qed.

Theorem deallocate_object_internal_call_shape_obligations_from_bound_entry_shapes :
  forall memory free_value pool_block slot,
    deallocate_object_bound_entry_shape_obligations
      memory free_value
      (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      pool_block slot ->
    deallocate_object_internal_call_shape_obligations
      memory
      (free_value ::
       Vptr pool_block
         (Ptrofs.repr ((slot * object_slot_size)%Z)) ::
       nil)
      pool_block slot.
Proof.
  intros memory free_value pool_block slot Hbound.
  unfold deallocate_object_internal_call_shape_obligations.
  intros entry_env entry_temps entry_memory Hentry.
  destruct
    (function_entry2_deallocate_object_binds_parameter_temps
      memory free_value
      (Vptr pool_block
        (Ptrofs.repr (slot * object_slot_size)))
      entry_env entry_temps entry_memory Hentry)
    as (Hfree & Hobj & Hmemory).
  subst entry_memory.
  split.
  - exact Hobj.
  - apply Hbound; assumption.
Qed.

Theorem eval_funcall_internal_deallocate_object_preserves_pool_slot_active_flags_from_shape_obligations :
  forall memory vargs trace memory' result pool_block slot,
    valid_object_slot slot ->
    deallocate_object_internal_call_shape_obligations
      memory vargs pool_block slot ->
    eval_funcall function_entry2 unload_object_ge memory
      (Internal S.f_deallocate_object) vargs trace memory' result ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros memory vargs trace memory' result pool_block slot
    Hvalid Hshape_call Hcall.
  inv Hcall.
  match goal with
  | Hentry :
      function_entry2 unload_object_ge S.f_deallocate_object
        vargs memory ?entry_env ?entry_temps ?entry_memory |- _ =>
      destruct (Hshape_call entry_env entry_temps entry_memory Hentry)
        as (Hobj_entry & Hshape_entry);
      inv Hentry
  end.
  cbn in *.
  match goal with
  | Halloc : alloc_variables _ _ _ nil _ _ |- _ => inv Halloc
  end.
  match goal with
  | Hexec :
      exec_stmt function_entry2 unload_object_ge ?entry_env ?entry_temps
        ?initial_memory ?statement_body
        ?body_trace ?body_temps ?body_memory ?body_out |- _ =>
      change statement_body with (fn_body S.f_deallocate_object) in Hexec;
      pose proof
        (deallocate_object_body_preserves_pool_slot_active_flags_from_shape_obligations
          entry_env entry_temps initial_memory pool_block slot body_trace
          body_temps body_memory body_out Hvalid Hobj_entry Hshape_entry
          Hexec) as Hunchanged_body
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

Lemma unload_object_ge_resolves_gFreeObjectList :
  exists block,
    Genv.find_symbol unload_object_ge S._gFreeObjectList = Some block.
Proof.
  assert (Hdefmap :
    (prog_defmap S.prog) ! S._gFreeObjectList =
    Some (Gvar S.v_gFreeObjectList)).
  { vm_compute. reflexivity. }
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hdefmap.
  destruct Hdefmap as (block & Hsymbol & _).
  exists block.
  exact Hsymbol.
Qed.

Definition deallocate_object_argument_types : list type :=
  (tptr (Tstruct S._ObjectNode noattr)) ::
  (tptr (Tstruct S._ObjectNode noattr)) ::
  nil.

Lemma unload_deallocate_object_call_argument_values :
  forall le memory pool_block slot vargs,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_exprlist unload_object_ge empty_env le memory
      ((Eaddrof
          (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
          (tptr (Tstruct S._ObjectNode noattr))) ::
       (Eaddrof unload_object_header_lhs
          (tptr (Tstruct S._ObjectNode noattr))) ::
       nil)
      deallocate_object_argument_types vargs ->
    exists free_block,
      Genv.find_symbol unload_object_ge S._gFreeObjectList =
      Some free_block /\
      vargs =
        Vptr free_block Ptrofs.zero ::
        Vptr pool_block
          (Ptrofs.repr ((slot * object_slot_size)%Z)) ::
        nil.
Proof.
  intros le memory pool_block slot vargs Hvalid Hobj Hargs.
  unfold deallocate_object_argument_types in Hargs.
  inv Hargs.
  match goal with
  | Hfree_expr :
      eval_expr _ _ _ _
        (Eaddrof
          (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
          (tptr (Tstruct S._ObjectNode noattr))) _ |- _ =>
      inv Hfree_expr
  end.
  all:
    try match goal with
    | Hbad :
        eval_lvalue _ _ _ _
          (Eaddrof
            (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
            (tptr (Tstruct S._ObjectNode noattr))) _ _ _ |- _ =>
        inv Hbad
    end.
  match goal with
  | Hfree_lvalue :
      eval_lvalue _ empty_env _ _
        (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
        _ _ _ |- _ =>
      inv Hfree_lvalue
  end.
  - cbn in *.
    discriminate.
  - match goal with
    | Hcast_free : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn in Hcast_free;
        inv Hcast_free
    end.
    match goal with
    | Htail :
        eval_exprlist _ _ _ _
          ((Eaddrof unload_object_header_lhs
             (tptr (Tstruct S._ObjectNode noattr))) :: nil)
          _ _ |- _ =>
        inv Htail
    end.
    match goal with
    | Hheader_expr :
        eval_expr _ _ _ _
          (Eaddrof unload_object_header_lhs
            (tptr (Tstruct S._ObjectNode noattr))) _ |- _ =>
        inv Hheader_expr
    end.
    all:
      try match goal with
      | Hbad :
          eval_lvalue _ _ _ _
            (Eaddrof unload_object_header_lhs
              (tptr (Tstruct S._ObjectNode noattr))) _ _ _ |- _ =>
          inv Hbad
      end.
    match goal with
    | Hheader_lvalue :
        eval_lvalue _ empty_env le memory
          unload_object_header_lhs ?header_block ?header_ofs Full |- _ =>
        destruct
          (eval_unload_object_header_lhs_lvalue_pointer
            empty_env le memory pool_block slot header_block header_ofs
            Hvalid Hobj Hheader_lvalue) as (Hheader_block & Hheader_ofs);
        subst header_block header_ofs
    end.
    match goal with
    | Hcast_header : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn in Hcast_header;
        inv Hcast_header
    end.
    match goal with
    | Hnil : eval_exprlist _ _ _ _ nil nil _ |- _ => inv Hnil
    end.
    eexists.
    split; [eassumption | reflexivity].
Qed.

Definition unload_deallocate_object_call_actual_argument_shape_obligations
    (le : temp_env) (memory : mem)
    (pool_block : block) (slot : Z) : Prop :=
  forall vargs,
    eval_exprlist unload_object_ge empty_env le memory
      ((Eaddrof
          (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
          (tptr (Tstruct S._ObjectNode noattr))) ::
       (Eaddrof unload_object_header_lhs
          (tptr (Tstruct S._ObjectNode noattr))) ::
       nil)
      deallocate_object_argument_types vargs ->
    deallocate_object_internal_call_shape_obligations
      memory vargs pool_block slot.

Theorem unload_deallocate_object_call_actual_argument_shapes_from_bound_entry_shapes :
  forall le memory pool_block slot,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    (forall free_block,
      Genv.find_symbol unload_object_ge S._gFreeObjectList =
      Some free_block ->
      deallocate_object_bound_entry_shape_obligations
        memory (Vptr free_block Ptrofs.zero)
        (Vptr pool_block
          (Ptrofs.repr ((slot * object_slot_size)%Z)))
        pool_block slot) ->
    unload_deallocate_object_call_actual_argument_shape_obligations
      le memory pool_block slot.
Proof.
  intros le memory pool_block slot Hvalid Hobj Hbound.
  unfold unload_deallocate_object_call_actual_argument_shape_obligations.
  intros vargs Hargs.
  destruct
    (unload_deallocate_object_call_argument_values
      le memory pool_block slot vargs Hvalid Hobj Hargs)
    as (free_block & Hfree_symbol & Hvargs).
  subst vargs.
  apply deallocate_object_internal_call_shape_obligations_from_bound_entry_shapes.
  apply Hbound.
  exact Hfree_symbol.
Qed.

Definition unload_deallocate_object_call_argument_shape_obligations
    (le : temp_env) (memory : mem)
    (pool_block : block) (slot : Z) : Prop :=
  forall tyargs vargs,
    eval_exprlist unload_object_ge empty_env le memory
      ((Eaddrof
          (Evar S._gFreeObjectList (Tstruct S._ObjectNode noattr))
          (tptr (Tstruct S._ObjectNode noattr))) ::
       (Eaddrof unload_object_header_lhs
          (tptr (Tstruct S._ObjectNode noattr))) ::
       nil)
      tyargs vargs ->
    deallocate_object_internal_call_shape_obligations
      memory vargs pool_block slot.

Definition unload_deallocate_object_call_empty_env_actual_shape_frame_obligation
    : Prop :=
  deallocate_object_function_resolves_in_empty_env ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    unload_deallocate_object_call_actual_argument_shape_obligations
      le memory pool_block slot ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_deallocate_object_call trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.

Theorem unload_deallocate_object_call_empty_env_actual_shape_frame_obligation_holds :
  unload_deallocate_object_call_empty_env_actual_shape_frame_obligation.
Proof.
  unfold unload_deallocate_object_call_empty_env_actual_shape_frame_obligation.
  intros Hresolve le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hshape_args Hexec.
  unfold unload_deallocate_object_call in Hexec.
  inv Hexec.
  match goal with
  | Hclassify :
      classify_fun
        (typeof
          (Evar S._deallocate_object
            (Tfunction
              ((tptr (Tstruct S._ObjectNode noattr)) ::
               (tptr (Tstruct S._ObjectNode noattr)) :: nil)
              tvoid cc_default))) = fun_case_f _ _ _ |- _ =>
      cbn in Hclassify;
      inv Hclassify
  end.
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
    | Hargs :
        eval_exprlist _ empty_env le memory _ ?tyargs ?vargs,
      Hcall :
        eval_funcall function_entry2 unload_object_ge memory
          (Internal S.f_deallocate_object) ?vargs trace memory' _ |- _ =>
        change tyargs with deallocate_object_argument_types in Hargs;
        pose proof (Hshape_args vargs Hargs) as Hshape_call;
        eapply
          (eval_funcall_internal_deallocate_object_preserves_pool_slot_active_flags_from_shape_obligations
            memory vargs trace memory' _ pool_block slot
            Hvalid Hshape_call);
        exact Hcall
    end.
Qed.

Theorem unload_deallocate_object_call_empty_env_frame_from_actual_shape_obligations :
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    unload_deallocate_object_call_actual_argument_shape_obligations
      le memory pool_block slot ->
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
  eapply
    unload_deallocate_object_call_empty_env_actual_shape_frame_obligation_holds.
  apply deallocate_object_function_resolves_in_empty_env_holds.
Qed.

Theorem unload_deallocate_object_call_empty_env_frame_from_bound_entry_shapes :
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    (forall free_block,
      Genv.find_symbol unload_object_ge S._gFreeObjectList =
      Some free_block ->
      deallocate_object_bound_entry_shape_obligations
        memory (Vptr free_block Ptrofs.zero)
        (Vptr pool_block
          (Ptrofs.repr ((slot * object_slot_size)%Z)))
        pool_block slot) ->
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
  intros le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hbound Hexec.
  eapply unload_deallocate_object_call_empty_env_frame_from_actual_shape_obligations;
    eauto.
  eapply unload_deallocate_object_call_actual_argument_shapes_from_bound_entry_shapes;
    eauto.
Qed.

Theorem unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_shapes :
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    (forall free_block,
      Genv.find_symbol unload_object_ge S._gFreeObjectList =
      Some free_block ->
      deallocate_object_resolved_free_list_shape_obligations
        memory free_block pool_block slot) ->
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
  intros le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hresolved Hexec.
  eapply unload_deallocate_object_call_empty_env_frame_from_bound_entry_shapes;
    eauto.
  intros free_block Hsymbol.
  apply deallocate_object_bound_entry_shape_obligations_from_resolved_free_list_shapes.
  apply Hresolved.
  exact Hsymbol.
Qed.

Theorem unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_deref_shapes :
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    deallocate_object_resolved_free_list_deref_shape_obligations
      memory pool_block slot ->
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
  intros le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hderef_shapes Hexec.
  eapply unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_shapes;
    eauto.
  intros free_block _.
  apply deallocate_object_resolved_free_list_shape_obligations_from_deref_shapes.
  exact Hderef_shapes.
Qed.

Definition empty_env_pool_slot_statement_preserves_obj_and_active_flags
    (statement_body : statement) : Prop :=
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      statement_body trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.

Lemma pool_slot_statement_preserves_obj_and_active_flags_in_empty_env :
  forall statement_body,
    pool_slot_statement_preserves_obj_and_active_flags statement_body ->
    empty_env_pool_slot_statement_preserves_obj_and_active_flags
      statement_body.
Proof.
  unfold pool_slot_statement_preserves_obj_and_active_flags,
    empty_env_pool_slot_statement_preserves_obj_and_active_flags.
  intros statement_body Hframe le memory pool_block slot trace le' memory'
    outcome Hvalid Hobj Hexec.
  eapply Hframe; eauto.
Qed.

Lemma empty_env_pool_slot_statement_preserves_sequence :
  forall first rest,
    empty_env_pool_slot_statement_preserves_obj_and_active_flags first ->
    empty_env_pool_slot_statement_preserves_obj_and_active_flags rest ->
    empty_env_pool_slot_statement_preserves_obj_and_active_flags
      (Ssequence first rest).
Proof.
  intros first rest Hfirst Hrest.
  unfold empty_env_pool_slot_statement_preserves_obj_and_active_flags in *.
  intros le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  inv Hexec.
  - match goal with
    | Hexec_first :
        exec_stmt _ _ _ _ _ first _ ?le_mid ?memory_mid Out_normal,
      Hexec_rest :
        exec_stmt _ _ _ ?le_mid ?memory_mid rest _ _ _ _ |- _ =>
        destruct
          (Hfirst le memory pool_block slot _ le_mid memory_mid
            Out_normal Hvalid Hobj Hexec_first)
          as (Hobj_mid & Hunchanged_first);
        destruct
          (Hrest le_mid memory_mid pool_block slot _ le' memory'
            outcome Hvalid Hobj_mid Hexec_rest)
          as (Hobj_final & Hunchanged_rest);
        split;
          [ exact Hobj_final
          | eapply Mem.unchanged_on_trans; eauto ]
    end.
  - match goal with
    | Hexec_first :
        exec_stmt _ _ _ _ _ first _ _ _ ?outcome_first |- _ =>
        destruct
          (Hfirst le memory pool_block slot _ le' memory'
            outcome_first Hvalid Hobj Hexec_first)
          as (Hobj_final & Hunchanged_first);
        split; [exact Hobj_final | exact Hunchanged_first]
    end.
Qed.

Definition unload_deallocate_object_call_empty_env_deref_shape_obligations
    : Prop :=
  forall le memory pool_block slot,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    deallocate_object_resolved_free_list_deref_shape_obligations
      memory pool_block slot.

Theorem unload_deallocate_object_call_empty_env_frame_from_deref_shape_obligations :
  unload_deallocate_object_call_empty_env_deref_shape_obligations ->
  empty_env_pool_slot_statement_preserves_obj_and_active_flags
    unload_deallocate_object_call.
Proof.
  unfold unload_deallocate_object_call_empty_env_deref_shape_obligations,
    empty_env_pool_slot_statement_preserves_obj_and_active_flags.
  intros Hderef le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  eapply unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_deref_shapes;
    eauto.
Qed.

Definition unload_deallocate_object_call_empty_env_pool_link_shape_obligations
    : Prop :=
  forall le memory pool_block slot,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_pool_link_fields_well_shaped memory pool_block /\
    first_deallocate_splice_preserves_pool_link_fields
      memory pool_block slot.

Definition unload_deallocate_object_call_empty_env_pool_link_fields_obligations
    : Prop :=
  forall le memory pool_block slot,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_pool_link_fields_well_shaped memory pool_block.

Definition unload_deallocate_object_call_empty_env_pool_link_store_obligations
    : Prop :=
  forall le memory pool_block slot,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    object_pool_link_fields_well_shaped memory pool_block /\
    first_deallocate_splice_shaped_store_preserves_pool_link_fields
      memory pool_block slot.

Theorem unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_shapes :
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations ->
  unload_deallocate_object_call_empty_env_deref_shape_obligations.
Proof.
  unfold unload_deallocate_object_call_empty_env_pool_link_shape_obligations,
    unload_deallocate_object_call_empty_env_deref_shape_obligations.
  intros Hpool_links le memory pool_block slot Hvalid Hobj.
  destruct (Hpool_links le memory pool_block slot Hvalid Hobj)
    as (Hlinks & Hfirst_splice).
  eapply deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields;
    eauto.
Qed.

Theorem unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_field_obligations :
  unload_deallocate_object_call_empty_env_pool_link_fields_obligations ->
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations.
Proof.
  unfold unload_deallocate_object_call_empty_env_pool_link_fields_obligations,
    unload_deallocate_object_call_empty_env_pool_link_shape_obligations.
  intros Hfields le memory pool_block slot Hvalid Hobj.
  pose proof (Hfields le memory pool_block slot Hvalid Hobj)
    as Hlinks.
  split; [exact Hlinks |].
  eapply first_deallocate_splice_preserves_pool_link_fields_from_pool_link_fields;
    eauto.
Qed.

Theorem unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_field_obligations :
  unload_deallocate_object_call_empty_env_pool_link_fields_obligations ->
  unload_deallocate_object_call_empty_env_deref_shape_obligations.
Proof.
  intros Hfields.
  apply unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_shapes.
  apply
    unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_field_obligations.
  exact Hfields.
Qed.

Theorem unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_store_obligations :
  unload_deallocate_object_call_empty_env_pool_link_store_obligations ->
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations.
Proof.
  unfold unload_deallocate_object_call_empty_env_pool_link_store_obligations,
    unload_deallocate_object_call_empty_env_pool_link_shape_obligations.
  intros Hstore le memory pool_block slot Hvalid Hobj.
  destruct (Hstore le memory pool_block slot Hvalid Hobj)
    as (Hlinks & Hshaped_store).
  split; [exact Hlinks |].
  eapply first_deallocate_splice_preserves_pool_link_fields_from_shaped_store;
    eauto.
Qed.

Theorem unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_store_obligations :
  unload_deallocate_object_call_empty_env_pool_link_store_obligations ->
  unload_deallocate_object_call_empty_env_deref_shape_obligations.
Proof.
  intros Hstore.
  apply unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_shapes.
  apply
    unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_store_obligations.
  exact Hstore.
Qed.

Definition unload_object_tail_empty_env_deref_shape_pool_slot_frame_obligations
    : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  unload_deallocate_object_call_empty_env_deref_shape_obligations.

Theorem unload_object_tail_empty_env_pool_slot_frame_from_deref_shape_obligations :
  unload_object_tail_empty_env_deref_shape_pool_slot_frame_obligations ->
  empty_env_pool_slot_statement_preserves_obj_and_active_flags
    unload_object_tail.
Proof.
  intros (Hstop & Hremove & Hadd & Hdeallocate).
  rewrite unload_object_tail_split_prev.
  apply empty_env_pool_slot_statement_preserves_sequence.
  - apply pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
    apply unload_prev_obj_assign_pool_slot_frame.
  - rewrite unload_object_after_prev_split_throw_matrix.
    apply empty_env_pool_slot_statement_preserves_sequence.
    + apply pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
      apply unload_throw_matrix_assign_pool_slot_frame.
    + rewrite unload_object_after_throw_matrix_split_stop_sounds.
      apply empty_env_pool_slot_statement_preserves_sequence.
      * apply pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
        exact Hstop.
      * rewrite unload_object_after_stop_sounds_split_geo_remove_child.
        apply empty_env_pool_slot_statement_preserves_sequence.
        -- apply pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
           exact Hremove.
        -- rewrite unload_object_after_geo_remove_child_split_geo_add_child.
           apply empty_env_pool_slot_statement_preserves_sequence.
           ++ apply
                pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
              exact Hadd.
           ++ rewrite unload_object_after_geo_add_child_split_graph_flags_bit2.
              apply empty_env_pool_slot_statement_preserves_sequence.
              ** apply
                   pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
                 apply unload_graph_flags_clear_bit2_pool_slot_frame_from_assign.
                 apply unload_graph_flags_assign_bit2_pool_slot_frame.
              ** rewrite
                   unload_object_after_graph_flags_bit2_split_graph_flags_bit0.
                 apply empty_env_pool_slot_statement_preserves_sequence.
                 --- apply
                       pool_slot_statement_preserves_obj_and_active_flags_in_empty_env.
                     apply
                       unload_graph_flags_clear_bit0_pool_slot_frame_from_assign.
                     apply unload_graph_flags_assign_bit0_pool_slot_frame.
                 --- rewrite
                       unload_object_after_graph_flags_bit0_is_deallocate_call.
                     apply
                       unload_deallocate_object_call_empty_env_frame_from_deref_shape_obligations.
                     exact Hdeallocate.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_deref_shape_obligations :
  unload_object_tail_empty_env_deref_shape_pool_slot_frame_obligations ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  destruct
    (unload_object_tail_empty_env_pool_slot_frame_from_deref_shape_obligations
      Hframes le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (_ & Hunchanged).
  exact Hunchanged.
Qed.

Definition unload_object_tail_empty_env_pool_link_shape_frame_obligations
    : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations.

Theorem unload_object_tail_empty_env_pool_slot_frame_from_pool_link_shape_obligations :
  unload_object_tail_empty_env_pool_link_shape_frame_obligations ->
  empty_env_pool_slot_statement_preserves_obj_and_active_flags
    unload_object_tail.
Proof.
  intros (Hstop & Hremove & Hadd & Hdeallocate).
  apply unload_object_tail_empty_env_pool_slot_frame_from_deref_shape_obligations.
  split; [exact Hstop |].
  split; [exact Hremove |].
  split; [exact Hadd |].
  apply
    unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_shapes.
  exact Hdeallocate.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_shape_obligations :
  unload_object_tail_empty_env_pool_link_shape_frame_obligations ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  destruct
    (unload_object_tail_empty_env_pool_slot_frame_from_pool_link_shape_obligations
      Hframes le memory pool_block slot trace le' memory' outcome
      Hvalid Hobj Hexec) as (_ & Hunchanged).
  exact Hunchanged.
Qed.

Definition unload_object_tail_empty_env_pool_link_store_frame_obligations
    : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  unload_deallocate_object_call_empty_env_pool_link_store_obligations.

Definition unload_object_tail_empty_env_pool_link_fields_frame_obligations
    : Prop :=
  pool_slot_statement_preserves_obj_and_active_flags
    unload_stop_sounds_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_remove_child_call /\
  pool_slot_statement_preserves_obj_and_active_flags
    unload_geo_add_child_call /\
  unload_deallocate_object_call_empty_env_pool_link_fields_obligations.

Theorem unload_object_tail_empty_env_pool_link_shape_obligations_from_field_obligations :
  unload_object_tail_empty_env_pool_link_fields_frame_obligations ->
  unload_object_tail_empty_env_pool_link_shape_frame_obligations.
Proof.
  intros (Hstop & Hremove & Hadd & Hdeallocate).
  split; [exact Hstop |].
  split; [exact Hremove |].
  split; [exact Hadd |].
  apply
    unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_field_obligations.
  exact Hdeallocate.
Qed.

Theorem unload_object_tail_empty_env_pool_slot_frame_from_pool_link_field_obligations :
  unload_object_tail_empty_env_pool_link_fields_frame_obligations ->
  empty_env_pool_slot_statement_preserves_obj_and_active_flags
    unload_object_tail.
Proof.
  intros Hframes.
  apply unload_object_tail_empty_env_pool_slot_frame_from_pool_link_shape_obligations.
  apply
    unload_object_tail_empty_env_pool_link_shape_obligations_from_field_obligations.
  exact Hframes.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_field_obligations :
  unload_object_tail_empty_env_pool_link_fields_frame_obligations ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes.
  apply
    unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_shape_obligations.
  apply
    unload_object_tail_empty_env_pool_link_shape_obligations_from_field_obligations.
  exact Hframes.
Qed.

Theorem unload_object_tail_empty_env_pool_link_shape_obligations_from_store_obligations :
  unload_object_tail_empty_env_pool_link_store_frame_obligations ->
  unload_object_tail_empty_env_pool_link_shape_frame_obligations.
Proof.
  intros (Hstop & Hremove & Hadd & Hdeallocate).
  split; [exact Hstop |].
  split; [exact Hremove |].
  split; [exact Hadd |].
  apply
    unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_store_obligations.
  exact Hdeallocate.
Qed.

Theorem unload_object_tail_empty_env_pool_slot_frame_from_pool_link_store_obligations :
  unload_object_tail_empty_env_pool_link_store_frame_obligations ->
  empty_env_pool_slot_statement_preserves_obj_and_active_flags
    unload_object_tail.
Proof.
  intros Hframes.
  apply unload_object_tail_empty_env_pool_slot_frame_from_pool_link_shape_obligations.
  apply
    unload_object_tail_empty_env_pool_link_shape_obligations_from_store_obligations.
  exact Hframes.
Qed.

Theorem unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_store_obligations :
  unload_object_tail_empty_env_pool_link_store_frame_obligations ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_object_tail trace le' memory' outcome ->
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.
Proof.
  intros Hframes.
  apply
    unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_shape_obligations.
  apply
    unload_object_tail_empty_env_pool_link_shape_obligations_from_store_obligations.
  exact Hframes.
Qed.

Definition unload_deallocate_object_call_empty_env_shape_frame_obligation
    : Prop :=
  deallocate_object_function_resolves_in_empty_env ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    unload_deallocate_object_call_argument_shape_obligations
      le memory pool_block slot ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      unload_deallocate_object_call trace le' memory' outcome ->
    le' ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) /\
    Mem.unchanged_on
      (active_flags_byte pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z)))
      memory memory'.

Theorem unload_deallocate_object_call_empty_env_shape_frame_obligation_holds :
  unload_deallocate_object_call_empty_env_shape_frame_obligation.
Proof.
  unfold unload_deallocate_object_call_empty_env_shape_frame_obligation.
  intros Hresolve le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hshape_args Hexec.
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
    | Hargs :
        eval_exprlist _ empty_env le memory _ ?tyargs ?vargs,
      Hcall :
        eval_funcall function_entry2 unload_object_ge memory
          (Internal S.f_deallocate_object) ?vargs trace memory' _ |- _ =>
        pose proof (Hshape_args tyargs vargs Hargs) as Hshape_call;
        eapply
          (eval_funcall_internal_deallocate_object_preserves_pool_slot_active_flags_from_shape_obligations
            memory vargs trace memory' _ pool_block slot
            Hvalid Hshape_call);
        exact Hcall
    end.
Qed.

Theorem unload_deallocate_object_call_empty_env_frame_from_shape_obligations :
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    unload_deallocate_object_call_argument_shape_obligations
      le memory pool_block slot ->
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
  eapply unload_deallocate_object_call_empty_env_shape_frame_obligation_holds.
  apply deallocate_object_function_resolves_in_empty_env_holds.
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

Theorem exec_unload_object_deactivates_pool_slot_from_empty_env_pool_link_field_obligations :
  unload_object_tail_empty_env_pool_link_fields_frame_obligations ->
  forall le memory pool_block slot trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge empty_env le memory
      (fn_body S.f_unload_object) trace le' memory' outcome ->
    slot_deactivated memory' pool_block slot.
Proof.
  intros Htail_frames le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  apply pointer_slot_deactivated_is_pool_slot; [exact Hvalid |].
  rewrite unload_object_body_split in Hexec.
  destruct
    (exec_seq_assign _ _ _ _ _ _ _ _ _ _ _ _ Hexec)
    as (trace1 & le1 & memory1 & trace2 & Hfirst & Hrest).
  destruct
    (exec_unload_active_flags_assign
      empty_env le memory pool_block
      (Ptrofs.repr (slot * object_slot_size))
      trace1 le1 memory1 Out_normal Hobj Hfirst)
    as (Hle1 & _ & Hdeactivated).
  subst le1.
  eapply unchanged_on_active_flags_preserves_pointer_slot_deactivated.
  - eapply
      unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_field_obligations;
      eauto.
  - exact Hdeactivated.
Qed.

Theorem exec_unload_object_valid_deactivation_step_from_tail_frame :
  unload_object_tail_preserves_active_flags_bytes ->
  forall (e : env) le memory pool_block slot
         trace le' memory' outcome,
    valid_object_slot slot ->
    le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    exec_stmt function_entry2 unload_object_ge e le memory
      (fn_body S.f_unload_object) trace le' memory' outcome ->
    valid_deactivation_step pool_block slot memory memory'.
Proof.
  intros Htail e le memory pool_block slot trace le' memory' outcome
    Hvalid Hobj Hexec.
  split.
  - eapply exec_unload_object_deactivates_pool_slot.
    + apply unload_object_tail_preserves_deactivation_from_frame.
      exact Htail.
    + exact Hvalid.
    + exact Hobj.
    + exact Hexec.
  - intros kept_slot Hvalid_kept Hdifferent Hdeactivated.
    rewrite unload_object_body_split in Hexec.
    destruct
      (exec_seq_assign _ _ _ _ _ _ _ _ _ _ _ _ Hexec)
      as (trace1 & le1 & memory1 & trace2 & Hfirst & Hrest).
    pose proof
      (exec_unload_active_flags_assign_preserves_other_pool_slot
        e le memory pool_block slot kept_slot trace1 le1 memory1
        Out_normal Hvalid Hdifferent Hobj Hdeactivated Hfirst)
      as Hdeactivated_after_first.
    eapply pointer_slot_deactivated_is_pool_slot; [exact Hvalid_kept |].
    eapply unchanged_on_active_flags_preserves_pointer_slot_deactivated.
    + eapply Htail.
      exact Hrest.
    + apply pool_slot_deactivated_is_pointer_slot; assumption.
Qed.
