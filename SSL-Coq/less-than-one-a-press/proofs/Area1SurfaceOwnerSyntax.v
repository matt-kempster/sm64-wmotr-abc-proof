(** Exact source-AST receipts for collision-surface owner installation.

    The platform installer copies [floor->object] into [gMarioPlatform].  This
    module checks the earlier source-level dataflow which initializes that
    [Surface.object] field for object collision models:

    - [load_object_surfaces] loads [gCurrentObject], stores that value into a
      surface's [object] field, and only later calls [add_surface] using the
      same syntactic surface-temporary identifier and dynamic flag [1]; and
    - every direct [add_surface] call in [load_static_surfaces] uses the static
      flag [0].

    The call census makes the dynamic receipt exhaustive for direct
    [add_surface] call sites in the two checked loader bodies, rather than
    merely finding one convenient occurrence.  These remain generated-Clight
    syntax facts.  They do not prove that the surface temporary is unreassigned
    between the store and call, that a call site executes, that
    [gCurrentObject] names a live canonical owner, that the dynamic lists keep
    the inserted surface intact, that an object-pool slot has the expected
    epoch, or that linked execution cannot mutate either cell through an alias
    or external frame. *)

From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_surface_load jp_surface_load.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module A1SO_US := us_surface_load.
Module A1SO_JP := jp_surface_load.

(** Match the exact two-argument generated call

      add_surface(surface_temp, flag).

    The surface temporary is an input so the owner-store recognizer can tie
    the call to the same syntactic receiver used by [Surface.object]. *)
Definition is_add_surface_call_s
    (callee surface_temp : ident) (flag : Z) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found_callee _)
      [Etempvar found_surface _; Econst_int found_flag _] =>
      Pos.eqb found_callee callee &&
      Pos.eqb found_surface surface_temp &&
      Int.eq found_flag (Int.repr flag)
  | _ => false
  end.

Fixpoint contains_add_surface_call_s
    (callee surface_temp : ident) (flag : Z) (body : statement) : bool :=
  is_add_surface_call_s callee surface_temp flag body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_add_surface_call_s callee surface_temp flag first ||
      contains_add_surface_call_s callee surface_temp flag second
  | Sifthenelse _ yes no =>
      contains_add_surface_call_s callee surface_temp flag yes ||
      contains_add_surface_call_s callee surface_temp flag no
  | Sswitch _ cases =>
      contains_add_surface_call_ls callee surface_temp flag cases
  | Slabel _ nested =>
      contains_add_surface_call_s callee surface_temp flag nested
  | _ => false
  end
with contains_add_surface_call_ls
    (callee surface_temp : ident) (flag : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_add_surface_call_s callee surface_temp flag body ||
      contains_add_surface_call_ls callee surface_temp flag rest
  end.

(** Universal flag/shape check for direct calls to the selected callee.  A
    direct call to any other identifier is irrelevant; a direct call to
    [callee] with a different argument shape or flag makes the result false. *)
Definition direct_add_surface_call_has_flag_s
    (callee : ident) (flag : Z) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found_callee _)
      [Etempvar _ _; Econst_int found_flag _] =>
      negb (Pos.eqb found_callee callee) ||
      Int.eq found_flag (Int.repr flag)
  | Scall _ (Evar found_callee _) _ =>
      negb (Pos.eqb found_callee callee)
  | _ => true
  end.

Fixpoint all_direct_add_surface_calls_have_flag_s
    (callee : ident) (flag : Z) (body : statement) : bool :=
  match body with
  | Ssequence first second | Sloop first second =>
      all_direct_add_surface_calls_have_flag_s callee flag first &&
      all_direct_add_surface_calls_have_flag_s callee flag second
  | Sifthenelse _ yes no =>
      all_direct_add_surface_calls_have_flag_s callee flag yes &&
      all_direct_add_surface_calls_have_flag_s callee flag no
  | Sswitch _ cases =>
      all_direct_add_surface_calls_have_flag_ls callee flag cases
  | Slabel _ nested =>
      all_direct_add_surface_calls_have_flag_s callee flag nested
  | _ => direct_add_surface_call_has_flag_s callee flag body
  end
with all_direct_add_surface_calls_have_flag_ls
    (callee : ident) (flag : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      all_direct_add_surface_calls_have_flag_s callee flag body &&
      all_direct_add_surface_calls_have_flag_ls callee flag rest
  end.

(** Match a sequence prefix of the generated form

      owner_temp := gCurrentObject;
      surface_temp->object := owner_temp;
      ...;
      add_surface(surface_temp, 1).

    Because the call is searched only in the continuation of the outer
    [Ssequence], the result records source evaluation order and reuse of the
    surface-receiver identifier and owner temporary.  It does not exclude an
    intervening reassignment of the surface temporary. *)
Definition is_owner_store_before_dynamic_add_s
    (current_object surface_tag object_field add_surface : ident)
    (body : statement) : bool :=
  match body with
  | Ssequence
      (Ssequence
        (Sset loaded_owner (Evar found_current_object _))
        (Sassign
          (Efield
            (Ederef (Etempvar stored_surface _) (Tstruct found_surface_tag _))
            found_object_field _)
          (Etempvar stored_owner _)))
      continuation =>
      Pos.eqb found_current_object current_object &&
      Pos.eqb found_surface_tag surface_tag &&
      Pos.eqb found_object_field object_field &&
      Pos.eqb stored_owner loaded_owner &&
      contains_add_surface_call_s add_surface stored_surface 1 continuation
  | _ => false
  end.

Fixpoint contains_owner_store_before_dynamic_add_s
    (current_object surface_tag object_field add_surface : ident)
    (body : statement) : bool :=
  is_owner_store_before_dynamic_add_s
    current_object surface_tag object_field add_surface body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface first ||
      contains_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface second
  | Sifthenelse _ yes no =>
      contains_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface yes ||
      contains_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface no
  | Sswitch _ cases =>
      contains_owner_store_before_dynamic_add_ls
        current_object surface_tag object_field add_surface cases
  | Slabel _ nested =>
      contains_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface nested
  | _ => false
  end
with contains_owner_store_before_dynamic_add_ls
    (current_object surface_tag object_field add_surface : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface body ||
      contains_owner_store_before_dynamic_add_ls
        current_object surface_tag object_field add_surface rest
  end.

Definition direct_call_count (callee : ident) (body : statement) : nat :=
  count_occ Pos.eq_dec (direct_callees_s body) callee.

Definition USDynamicSurfaceOwnerSourceClaim : Prop :=
  contains_owner_store_before_dynamic_add_s
    A1SO_US._gCurrentObject A1SO_US._Surface A1SO_US._object
    A1SO_US._add_surface
    (fn_body A1SO_US.f_load_object_surfaces) = true /\
  direct_call_count A1SO_US._add_surface
    (fn_body A1SO_US.f_load_object_surfaces) = 1%nat /\
  all_direct_add_surface_calls_have_flag_s A1SO_US._add_surface 1
    (fn_body A1SO_US.f_load_object_surfaces) = true.

Definition JPDynamicSurfaceOwnerSourceClaim : Prop :=
  contains_owner_store_before_dynamic_add_s
    A1SO_JP._gCurrentObject A1SO_JP._Surface A1SO_JP._object
    A1SO_JP._add_surface
    (fn_body A1SO_JP.f_load_object_surfaces) = true /\
  direct_call_count A1SO_JP._add_surface
    (fn_body A1SO_JP.f_load_object_surfaces) = 1%nat /\
  all_direct_add_surface_calls_have_flag_s A1SO_JP._add_surface 1
    (fn_body A1SO_JP.f_load_object_surfaces) = true.

Definition StaticSurfacePartitionSourceClaim : Prop :=
  direct_call_count A1SO_US._add_surface
    (fn_body A1SO_US.f_load_static_surfaces) = 1%nat /\
  all_direct_add_surface_calls_have_flag_s A1SO_US._add_surface 0
    (fn_body A1SO_US.f_load_static_surfaces) = true /\
  direct_call_count A1SO_JP._add_surface
    (fn_body A1SO_JP.f_load_static_surfaces) = 1%nat /\
  all_direct_add_surface_calls_have_flag_s A1SO_JP._add_surface 0
    (fn_body A1SO_JP.f_load_static_surfaces) = true.

Theorem us_dynamic_surface_owner_source_checked :
  USDynamicSurfaceOwnerSourceClaim.
Proof.
  unfold USDynamicSurfaceOwnerSourceClaim, direct_call_count.
  vm_compute. repeat split.
Qed.

Theorem jp_dynamic_surface_owner_source_checked :
  JPDynamicSurfaceOwnerSourceClaim.
Proof.
  unfold JPDynamicSurfaceOwnerSourceClaim, direct_call_count.
  vm_compute. repeat split.
Qed.

Theorem static_surface_partition_source_checked :
  StaticSurfacePartitionSourceClaim.
Proof.
  unfold StaticSurfacePartitionSourceClaim, direct_call_count.
  vm_compute. repeat split.
Qed.

(** Single assumption-audit target for the complete source receipt. *)
Theorem area1_surface_owner_source_boundary_checked :
  USDynamicSurfaceOwnerSourceClaim /\
  JPDynamicSurfaceOwnerSourceClaim /\
  StaticSurfacePartitionSourceClaim.
Proof.
  exact (conj us_dynamic_surface_owner_source_checked
    (conj jp_dynamic_surface_owner_source_checked
      static_surface_partition_source_checked)).
Qed.
