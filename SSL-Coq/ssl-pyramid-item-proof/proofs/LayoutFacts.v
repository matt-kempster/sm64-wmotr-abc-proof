From Coq Require Import Lia ZArith.
From compcert Require Import AST Ctypes Clight Errors Maps.
From SSLPyramid.Generated Require Import area level_update mario
  object_list_processor.
From SSLPyramid.Proofs Require Import Spec.

Module M := mario.
Module O := object_list_processor.
Module A := area.
Module L := level_update.

Local Open Scope Z_scope.

Definition object_ce : composite_env := prog_comp_env O.prog.

Definition object_members : members :=
  match object_ce ! O._Object with
  | Some composite => co_members composite
  | None => nil
  end.

Definition object_node_members : members :=
  match object_ce ! O._ObjectNode with
  | Some composite => co_members composite
  | None => nil
  end.

Definition graph_node_object_members : members :=
  match object_ce ! O._GraphNodeObject with
  | Some composite => co_members composite
  | None => nil
  end.

Definition graph_node_members : members :=
  match object_ce ! O._GraphNode with
  | Some composite => co_members composite
  | None => nil
  end.

Theorem object_header_offset :
  field_offset object_ce O._header object_members = OK (0, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem object_node_gfx_offset :
  field_offset object_ce O._gfx object_node_members = OK (0, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_active_area_offset :
  field_offset object_ce O._activeAreaIndex graph_node_object_members =
  OK (object_active_area_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem object_active_flags_offset :
  field_offset object_ce O._activeFlags object_members =
  OK (Spec.object_active_flags_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem object_prev_obj_offset :
  field_offset object_ce O._prevObj object_members = OK (108, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_object_node_offset :
  field_offset object_ce O._node graph_node_object_members = OK (0, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_object_throw_matrix_offset :
  field_offset object_ce O._throwMatrix graph_node_object_members =
  OK (80, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_flags_offset :
  field_offset object_ce O._flags graph_node_members = OK (2, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem unload_object_direct_store_offsets_miss_active_flags :
  (108 + 4 <= Spec.object_active_flags_offset) /\
  (80 + 4 <= Spec.object_active_flags_offset) /\
  (2 + 2 <= Spec.object_active_flags_offset).
Proof.
  unfold Spec.object_active_flags_offset.
  lia.
Qed.

Theorem object_size_is_608 :
  sizeof object_ce (Tstruct O._Object noattr) = object_slot_size.
Proof. vm_compute; reflexivity. Qed.

Theorem object_pool_has_240_slots :
  gvar_info O.v_gObjectPool =
  Tarray (Tstruct O._Object noattr) object_pool_capacity noattr.
Proof. reflexivity. Qed.

Definition mario_ce : composite_env := prog_comp_env M.prog.

Definition mario_state_members : members :=
  match mario_ce ! M._MarioState with
  | Some composite => co_members composite
  | None => nil
  end.

Theorem mario_interact_object_offset :
  field_offset mario_ce M._interactObj mario_state_members = OK (120, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem mario_held_object_offset :
  field_offset mario_ce M._heldObj mario_state_members = OK (124, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem mario_used_object_offset :
  field_offset mario_ce M._usedObj mario_state_members = OK (128, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem mario_ridden_object_offset :
  field_offset mario_ce M._riddenObj mario_state_members = OK (132, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem mario_state_size_is_200 :
  sizeof mario_ce (Tstruct M._MarioState noattr) = 200%Z.
Proof. vm_compute; reflexivity. Qed.

Definition warp_ce : composite_env := prog_comp_env L.prog.

Definition warp_dest_members : members :=
  match warp_ce ! L._WarpDest with
  | Some composite => co_members composite
  | None => nil
  end.

Theorem warp_dest_type_layout :
  field_offset warp_ce L._type warp_dest_members =
  OK (warp_dest_type_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem warp_dest_level_layout :
  field_offset warp_ce L._levelNum warp_dest_members =
  OK (warp_dest_level_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem warp_dest_area_layout :
  field_offset warp_ce L._areaIdx warp_dest_members =
  OK (warp_dest_area_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem warp_dest_node_layout :
  field_offset warp_ce L._nodeId warp_dest_members =
  OK (warp_dest_node_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem warp_dest_global_has_concrete_type :
  gvar_info L.v_sWarpDest = Tstruct L._WarpDest noattr.
Proof. reflexivity. Qed.

Theorem current_area_index_is_signed_16 :
  gvar_info A.v_gCurrAreaIndex = Tint I16 Signed noattr.
Proof. reflexivity. Qed.
