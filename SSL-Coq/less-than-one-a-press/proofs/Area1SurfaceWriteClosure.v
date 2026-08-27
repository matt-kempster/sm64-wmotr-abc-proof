(** Whole-selected-source closure for writes rooted in [struct Surface].

    The surface pools are interior byte ranges of the shared main pool, so a
    proof may not infer immutability merely from the C type.  This file first
    performs the complementary source check: it finds every generated Clight
    assignment whose destination expression contains a dereference of
    [struct Surface].  The result deliberately includes nested vector and
    vertex lvalues, rather than looking only for direct scalar fields.

    The census exposes three post-load [originOffset] assignments.  Each is
    in a riding-shell water branch which first selects the separate global
    [gWaterSurfacePseudoFloor]; the queried floor is not the receiver of the
    store.  The remaining rooted assignments are surface construction in
    [read_surface_data], plus the checked owner initialization/installation
    stores in the surface loader. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_mario_actions_moving us_mario_step us_surface_load
  jp_mario_actions_moving jp_mario_step jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  Area1Rank3PayloadWriterClosure Area1SchedulerSurfaceLifecycleSplit.

Import ListNotations.

Module A1SW_USMoving := us_mario_actions_moving.
Module A1SW_USStep := us_mario_step.
Module A1SW_USSurface := us_surface_load.
Module A1SW_JPMoving := jp_mario_actions_moving.
Module A1SW_JPStep := jp_mario_step.
Module A1SW_JPSurface := jp_surface_load.

Fixpoint expression_contains_struct_deref
    (tag : ident) (value : expr) : bool :=
  match value with
  | Ederef inner (Tstruct found _) =>
      Pos.eqb found tag || expression_contains_struct_deref tag inner
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ | Efield inner _ _ =>
      expression_contains_struct_deref tag inner
  | Ebinop _ left_value right_value _ =>
      expression_contains_struct_deref tag left_value ||
      expression_contains_struct_deref tag right_value
  | _ => false
  end.

Fixpoint struct_rooted_assignment_count_s
    (tag : ident) (body : statement) : nat :=
  match body with
  | Sassign lhs _ =>
      if expression_contains_struct_deref tag lhs then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (struct_rooted_assignment_count_s tag first +
       struct_rooted_assignment_count_s tag second)%nat
  | Sifthenelse _ yes no =>
      (struct_rooted_assignment_count_s tag yes +
       struct_rooted_assignment_count_s tag no)%nat
  | Sswitch _ cases => struct_rooted_assignment_count_ls tag cases
  | Slabel _ nested => struct_rooted_assignment_count_s tag nested
  | _ => 0%nat
  end
with struct_rooted_assignment_count_ls
    (tag : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (struct_rooted_assignment_count_s tag body +
       struct_rooted_assignment_count_ls tag rest)%nat
  end.

Fixpoint internal_struct_rooted_assignment_sites
    (tag : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list (ident * nat) :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      let count := struct_rooted_assignment_count_s tag (fn_body body) in
      if Nat.eqb count 0%nat
      then internal_struct_rooted_assignment_sites tag rest
      else (id, count) :: internal_struct_rooted_assignment_sites tag rest
  | _ :: rest => internal_struct_rooted_assignment_sites tag rest
  end.

Definition us_surface_rooted_assignment_sites :=
  internal_struct_rooted_assignment_sites A1SW_USSurface._Surface
    rank3_us_definitions.

Definition jp_surface_rooted_assignment_sites :=
  internal_struct_rooted_assignment_sites A1SW_JPSurface._Surface
    rank3_jp_definitions.

Definition SurfaceRootedAssignmentSiteClaim : Prop :=
  us_surface_rooted_assignment_sites =
    [(A1SW_USMoving._update_shell_speed, 1%nat);
     (A1SW_USStep._perform_ground_quarter_step, 1%nat);
     (A1SW_USStep._perform_air_quarter_step, 1%nat);
     (A1SW_USSurface._alloc_surface, 5%nat);
     (A1SW_USSurface._add_surface_to_cell, 1%nat);
     (A1SW_USSurface._read_surface_data, 15%nat);
     (A1SW_USSurface._load_static_surfaces, 5%nat);
     (A1SW_USSurface._load_object_surfaces, 6%nat)] /\
  jp_surface_rooted_assignment_sites =
    [(A1SW_JPMoving._update_shell_speed, 1%nat);
     (A1SW_JPStep._perform_ground_quarter_step, 1%nat);
     (A1SW_JPStep._perform_air_quarter_step, 1%nat);
     (A1SW_JPSurface._alloc_surface, 5%nat);
     (A1SW_JPSurface._add_surface_to_cell, 1%nat);
     (A1SW_JPSurface._read_surface_data, 15%nat);
     (A1SW_JPSurface._load_static_surfaces, 5%nat);
     (A1SW_JPSurface._load_object_surfaces, 6%nat)].

Theorem surface_rooted_assignment_sites_are_exact :
  SurfaceRootedAssignmentSiteClaim.
Proof.
  unfold SurfaceRootedAssignmentSiteClaim,
    us_surface_rooted_assignment_sites, jp_surface_rooted_assignment_sites.
  vm_compute. split; reflexivity.
Qed.

(** The only direct assignments to the plane offset outside the loader are
    the three riding-shell pseudo-floor branches. *)
Definition SurfaceOriginOffsetAssignmentSiteClaim : Prop :=
  internal_surface_object_assignment_sites
    A1SW_USSurface._Surface A1SW_USSurface._originOffset
    rank3_us_definitions =
      [A1SW_USMoving._update_shell_speed;
       A1SW_USStep._perform_ground_quarter_step;
       A1SW_USStep._perform_air_quarter_step;
       A1SW_USSurface._read_surface_data] /\
  internal_surface_object_assignment_sites
    A1SW_JPSurface._Surface A1SW_JPSurface._originOffset
    rank3_jp_definitions =
      [A1SW_JPMoving._update_shell_speed;
       A1SW_JPStep._perform_ground_quarter_step;
       A1SW_JPStep._perform_air_quarter_step;
       A1SW_JPSurface._read_surface_data] /\
  internal_surface_object_address_sites
    A1SW_USSurface._Surface A1SW_USSurface._originOffset
    rank3_us_definitions = [] /\
  internal_surface_object_address_sites
    A1SW_JPSurface._Surface A1SW_JPSurface._originOffset
    rank3_jp_definitions = [].

Theorem surface_origin_offset_assignment_sites_are_exact :
  SurfaceOriginOffsetAssignmentSiteClaim.
Proof.
  unfold SurfaceOriginOffsetAssignmentSiteClaim.
  vm_compute. repeat split; reflexivity.
Qed.

(** A small syntax recognizer checks the crucial data-flow shape without
    relying on comments from the C source.  CompCert introduces a temporary
    between the source assignment and field store, so the checked sequence is
    [bind pseudo-floor; copy that binding to a fresh temp; store through the
    unchanged temp]. *)
Inductive PseudoFloorReceiver : Type :=
| MarioFloorReceiver
| LocalFloorReceiver.

Definition expression_is_water_pseudo_floor_address
    (pseudo_floor : ident) (value : expr) : bool :=
  match value with
  | Eaddrof (Evar found _) _ => Pos.eqb found pseudo_floor
  | _ => false
  end.

Definition lhs_is_mario_floor
    (mario_tag floor_field : ident) (value : expr) : bool :=
  match value with
  | Efield (Ederef _ (Tstruct found_tag _)) found_field _ =>
      Pos.eqb found_tag mario_tag && Pos.eqb found_field floor_field
  | _ => false
  end.

Definition rhs_is_mario_floor
    (mario_tag floor_field : ident) (value : expr) : bool :=
  match value with
  | Efield (Ederef _ (Tstruct found_tag _)) found_field _ =>
      Pos.eqb found_tag mario_tag && Pos.eqb found_field floor_field
  | _ => false
  end.

Definition rhs_is_local_floor (floor_local : ident) (value : expr) : bool :=
  match value with
  | Evar found _ => Pos.eqb found floor_local
  | _ => false
  end.

Definition lhs_is_surface_origin_through_temp
    (surface_tag receiver_temp origin_field : ident)
    (value : expr) : bool :=
  match value with
  | Efield
      (Ederef (Etempvar found_temp _) (Tstruct found_surface _))
      found_origin _ =>
      Pos.eqb found_temp receiver_temp &&
      Pos.eqb found_surface surface_tag &&
      Pos.eqb found_origin origin_field
  | _ => false
  end.

Definition is_pseudo_floor_binding
    (receiver : PseudoFloorReceiver)
    (mario_tag floor_field floor_temp pseudo_floor : ident)
    (body : statement) : bool :=
  match receiver, body with
  | MarioFloorReceiver, Sassign lhs rhs =>
      lhs_is_mario_floor mario_tag floor_field lhs &&
      expression_is_water_pseudo_floor_address pseudo_floor rhs
  | LocalFloorReceiver, Sassign (Evar found_local _) rhs =>
      Pos.eqb found_local floor_temp &&
      expression_is_water_pseudo_floor_address pseudo_floor rhs
  | _, _ => false
  end.

Definition pseudo_floor_copy_target
    (receiver : PseudoFloorReceiver)
    (mario_tag floor_field floor_local : ident)
    (body : statement) : option ident :=
  match body with
  | Sset target rhs =>
      let source_matches :=
        match receiver with
        | MarioFloorReceiver => rhs_is_mario_floor mario_tag floor_field rhs
        | LocalFloorReceiver => rhs_is_local_floor floor_local rhs
        end in
      if source_matches then Some target else None
  | _ => None
  end.

Fixpoint temp_assignment_count_s
    (target : ident) (body : statement) : nat :=
  match body with
  | Sset found _ => if Pos.eqb found target then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (temp_assignment_count_s target first +
       temp_assignment_count_s target second)%nat
  | Sifthenelse _ yes no =>
      (temp_assignment_count_s target yes +
       temp_assignment_count_s target no)%nat
  | Sswitch _ cases => temp_assignment_count_ls target cases
  | Slabel _ nested => temp_assignment_count_s target nested
  | _ => 0%nat
  end
with temp_assignment_count_ls
    (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (temp_assignment_count_s target body +
       temp_assignment_count_ls target rest)%nat
  end.

Fixpoint contains_origin_store_through_temp_s
    (surface_tag receiver_temp origin_field : ident)
    (body : statement) : bool :=
  match body with
  | Sassign lhs _ =>
      lhs_is_surface_origin_through_temp
        surface_tag receiver_temp origin_field lhs
  | Ssequence first second | Sloop first second =>
      contains_origin_store_through_temp_s surface_tag receiver_temp
        origin_field first ||
      contains_origin_store_through_temp_s surface_tag receiver_temp
        origin_field second
  | Sifthenelse _ yes no =>
      contains_origin_store_through_temp_s surface_tag receiver_temp
        origin_field yes ||
      contains_origin_store_through_temp_s surface_tag receiver_temp
        origin_field no
  | Sswitch _ cases =>
      contains_origin_store_through_temp_ls surface_tag receiver_temp
        origin_field cases
  | Slabel _ nested =>
      contains_origin_store_through_temp_s surface_tag receiver_temp
        origin_field nested
  | _ => false
  end
with contains_origin_store_through_temp_ls
    (surface_tag receiver_temp origin_field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_origin_store_through_temp_s surface_tag receiver_temp
        origin_field body ||
      contains_origin_store_through_temp_ls surface_tag receiver_temp
        origin_field rest
  end.

Definition starts_with_pseudo_copy_then_origin_store
    (receiver : PseudoFloorReceiver)
    (mario_tag surface_tag floor_field floor_local origin_field : ident)
    (body : statement) : bool :=
  match body with
  | Ssequence copy remainder =>
      match pseudo_floor_copy_target receiver mario_tag floor_field
              floor_local copy with
      | Some receiver_temp =>
          Nat.eqb (temp_assignment_count_s receiver_temp remainder) 0%nat &&
          contains_origin_store_through_temp_s
            surface_tag receiver_temp origin_field remainder
      | None => false
      end
  | _ => false
  end.

Fixpoint contains_adjacent_pseudo_floor_origin_store_s
    (receiver : PseudoFloorReceiver)
    (mario_tag surface_tag floor_field floor_temp pseudo_floor
      origin_field : ident)
    (body : statement) : bool :=
  match body with
  | Ssequence first second =>
      (is_pseudo_floor_binding receiver mario_tag floor_field floor_temp
         pseudo_floor first &&
       starts_with_pseudo_copy_then_origin_store receiver mario_tag surface_tag
         floor_field floor_temp origin_field second) ||
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field first ||
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field second
  | Sloop first second =>
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field first ||
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field second
  | Sifthenelse _ yes no =>
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field yes ||
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field no
  | Sswitch _ cases =>
      contains_adjacent_pseudo_floor_origin_store_ls receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field cases
  | Slabel _ nested =>
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field nested
  | _ => false
  end
with contains_adjacent_pseudo_floor_origin_store_ls
    (receiver : PseudoFloorReceiver)
    (mario_tag surface_tag floor_field floor_temp pseudo_floor
      origin_field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_adjacent_pseudo_floor_origin_store_s receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field body ||
      contains_adjacent_pseudo_floor_origin_store_ls receiver mario_tag
        surface_tag floor_field floor_temp pseudo_floor origin_field rest
  end.

Definition SurfacePseudoFloorStoreShapeClaim : Prop :=
  contains_adjacent_pseudo_floor_origin_store_s MarioFloorReceiver
    A1SW_USMoving._MarioState A1SW_USMoving._Surface
    A1SW_USMoving._floor A1SW_USMoving._floor
    A1SW_USMoving._gWaterSurfacePseudoFloor A1SW_USMoving._originOffset
    (fn_body A1SW_USMoving.f_update_shell_speed) = true /\
  contains_adjacent_pseudo_floor_origin_store_s LocalFloorReceiver
    A1SW_USStep._MarioState A1SW_USStep._Surface
    A1SW_USStep._floor A1SW_USStep._floor
    A1SW_USStep._gWaterSurfacePseudoFloor A1SW_USStep._originOffset
    (fn_body A1SW_USStep.f_perform_ground_quarter_step) = true /\
  contains_adjacent_pseudo_floor_origin_store_s LocalFloorReceiver
    A1SW_USStep._MarioState A1SW_USStep._Surface
    A1SW_USStep._floor A1SW_USStep._floor
    A1SW_USStep._gWaterSurfacePseudoFloor A1SW_USStep._originOffset
    (fn_body A1SW_USStep.f_perform_air_quarter_step) = true /\
  contains_adjacent_pseudo_floor_origin_store_s MarioFloorReceiver
    A1SW_JPMoving._MarioState A1SW_JPMoving._Surface
    A1SW_JPMoving._floor A1SW_JPMoving._floor
    A1SW_JPMoving._gWaterSurfacePseudoFloor A1SW_JPMoving._originOffset
    (fn_body A1SW_JPMoving.f_update_shell_speed) = true /\
  contains_adjacent_pseudo_floor_origin_store_s LocalFloorReceiver
    A1SW_JPStep._MarioState A1SW_JPStep._Surface
    A1SW_JPStep._floor A1SW_JPStep._floor
    A1SW_JPStep._gWaterSurfacePseudoFloor A1SW_JPStep._originOffset
    (fn_body A1SW_JPStep.f_perform_ground_quarter_step) = true /\
  contains_adjacent_pseudo_floor_origin_store_s LocalFloorReceiver
    A1SW_JPStep._MarioState A1SW_JPStep._Surface
    A1SW_JPStep._floor A1SW_JPStep._floor
    A1SW_JPStep._gWaterSurfacePseudoFloor A1SW_JPStep._originOffset
    (fn_body A1SW_JPStep.f_perform_air_quarter_step) = true.

Theorem nonloader_origin_stores_select_the_water_pseudo_floor :
  SurfacePseudoFloorStoreShapeClaim.
Proof.
  unfold SurfacePseudoFloorStoreShapeClaim.
  vm_compute. repeat split; reflexivity.
Qed.

Definition Area1SurfaceWriteClosureBoundary : Prop :=
  SurfaceRootedAssignmentSiteClaim /\
  SurfaceOriginOffsetAssignmentSiteClaim /\
  SurfacePseudoFloorStoreShapeClaim.

Theorem area1_surface_write_closure_boundary_holds :
  Area1SurfaceWriteClosureBoundary.
Proof.
  exact (conj surface_rooted_assignment_sites_are_exact
    (conj surface_origin_offset_assignment_sites_are_exact
      nonloader_origin_stores_select_the_water_pseudo_floor)).
Qed.
