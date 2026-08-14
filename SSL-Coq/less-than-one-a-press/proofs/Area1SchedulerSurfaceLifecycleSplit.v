(** Scheduler, surface-owner, and lifecycle reduction for the Area-1
    collision/query split.

    This file keeps three logically distinct results together:

    - a generated-source-union census of direct explicit transition-callback
      assignment/call syntax and direct explicit [Surface.object] field writes;
    - a finite stock-semantics theorem saying that an accepted upper-warp
      frame whose final query installs any non-null stock owner necessarily
      queried a position different from the collision position; and
    - an explicit inactive, freed, unreused payload survivor showing why
      proving "no slot reuse" alone does not eliminate the JP lifecycle
      mechanism.

    The source censuses close only the recognized direct syntax.  In
    particular, they do not cover a whole-struct or builtin mutation of a
    [Surface], frame stores through pre-existing aliases or external calls,
    prove the runtime target of the indirect transition callback, or refine
    the finite scheduler and floor-query predicates to linked Clight
    execution. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_level_update us_surface_load
  jp_level_update jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts LinkedClightPrograms NormalizedClightPrograms ClightLinkExecution
  PlatformPointerProvenance GameTypes PyramidTopPU
  Area1SurfaceOwnerSyntax Area1QueryScheduleClosure
  Area1PostCopyObjectWriterClosure
  Area1MovingSkippedQueryClosure Area1PlatformExhaustiveness
  Area1SurfaceEpochLifecycle.

Import ListNotations.
Local Open Scope Z_scope.

Module A1SSLS_USLevel := us_level_update.
Module A1SSLS_USSurface := us_surface_load.
Module A1SSLS_JPLevel := jp_level_update.
Module A1SSLS_JPSurface := jp_surface_load.

(** * Complete direct transition-callback census *)

Inductive TransitionInstallShape : Type :=
| TransitionNullThirty
| TransitionNullMinusOne
| TransitionBasicSeventyFour
| TransitionNullTwo
| TransitionInstallOther.

Definition is_exact_signed_int_expr (expected : Z) (value : expr) : bool :=
  match value with
  | Econst_int found _ => Int.eq found (Int.repr expected)
  | Eunop Oneg (Econst_int found _) _ =>
      Int.eq (Int.neg found) (Int.repr expected)
  | _ => false
  end.

Definition classify_transition_install_call_s
    (callee basic_update : ident) (body : statement) :
    option TransitionInstallShape :=
  match body with
  | Scall _ (Evar found_callee _) [length; callback] =>
      if Pos.eqb found_callee callee then
        if is_exact_signed_int_expr 30 length && rhs_is_null_pointer callback
        then Some TransitionNullThirty
        else if is_exact_signed_int_expr (-1) length &&
                    rhs_is_null_pointer callback
             then Some TransitionNullMinusOne
             else if is_exact_signed_int_expr 74 length &&
                         match callback with
                         | Evar found_callback _ =>
                             Pos.eqb found_callback basic_update
                         | _ => false
                         end
                  then Some TransitionBasicSeventyFour
                  else if is_exact_signed_int_expr 2 length &&
                              rhs_is_null_pointer callback
                       then Some TransitionNullTwo
                       else Some TransitionInstallOther
      else None
  | _ => None
  end.

Fixpoint transition_install_shapes_s
    (callee basic_update : ident) (body : statement) :
    list TransitionInstallShape :=
  match body with
  | Scall _ _ _ =>
      match classify_transition_install_call_s callee basic_update body with
      | Some shape => [shape]
      | None => []
      end
  | Ssequence first second | Sloop first second =>
      transition_install_shapes_s callee basic_update first ++
      transition_install_shapes_s callee basic_update second
  | Sifthenelse _ yes no =>
      transition_install_shapes_s callee basic_update yes ++
      transition_install_shapes_s callee basic_update no
  | Sswitch _ cases =>
      transition_install_shapes_ls callee basic_update cases
  | Slabel _ nested =>
      transition_install_shapes_s callee basic_update nested
  | _ => []
  end
with transition_install_shapes_ls
    (callee basic_update : ident) (cases : labeled_statements) :
    list TransitionInstallShape :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      transition_install_shapes_s callee basic_update body ++
      transition_install_shapes_ls callee basic_update rest
  end.

Fixpoint internal_transition_install_shapes
    (callee basic_update : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list TransitionInstallShape :=
  match definitions with
  | [] => []
  | (_, Gfun (Internal body)) :: rest =>
      transition_install_shapes_s callee basic_update (fn_body body) ++
      internal_transition_install_shapes callee basic_update rest
  | _ :: rest =>
      internal_transition_install_shapes callee basic_update rest
  end.

(** Count every direct syntactic call occurrence across the source union, not
    merely the set of internal bodies which contain at least one occurrence. *)
Fixpoint internal_direct_call_occurrence_count
    (callee : ident)
    (definitions : list (ident * globdef (fundef function) type)) : nat :=
  match definitions with
  | [] => 0%nat
  | (_, Gfun (Internal body)) :: rest =>
      (direct_call_count callee (fn_body body) +
       internal_direct_call_occurrence_count callee rest)%nat
  | _ :: rest => internal_direct_call_occurrence_count callee rest
  end.

Definition USTransitionCallbackDirectSourceUnionClaim : Prop :=
  internal_function_assignment_sites
    A1SSLS_USLevel._sTransitionUpdate
    (unit_global_definitions us_units) =
      [A1SSLS_USLevel._level_set_transition;
       A1SSLS_USLevel._play_mode_change_area;
       A1SSLS_USLevel._play_mode_change_level] /\
  internal_function_address_sites
    A1SSLS_USLevel._sTransitionUpdate
    (unit_global_definitions us_units) = [] /\
  internal_function_direct_call_sites
    A1SSLS_USLevel._level_set_transition
    (unit_global_definitions us_units) =
      [A1SSLS_USLevel._fade_into_special_warp;
       A1SSLS_USLevel._load_level_init_text;
       A1SSLS_USLevel._initiate_painting_warp;
       A1SSLS_USLevel._initiate_delayed_warp] /\
  internal_direct_call_occurrence_count
    A1SSLS_USLevel._level_set_transition
    (unit_global_definitions us_units) = 4%nat /\
  internal_transition_install_shapes
    A1SSLS_USLevel._level_set_transition A1SSLS_USLevel._basic_update
    (unit_global_definitions us_units) =
      [TransitionNullThirty; TransitionNullMinusOne;
       TransitionBasicSeventyFour; TransitionNullTwo] /\
  existsb (Pos.eqb A1SSLS_USLevel._sTransitionUpdate)
    (source_union_init_addrof_identifiers us_units) = false.

Definition JPTransitionCallbackDirectSourceUnionClaim : Prop :=
  internal_function_assignment_sites
    A1SSLS_JPLevel._sTransitionUpdate
    (unit_global_definitions jp_units) =
      [A1SSLS_JPLevel._level_set_transition;
       A1SSLS_JPLevel._play_mode_change_area;
       A1SSLS_JPLevel._play_mode_change_level] /\
  internal_function_address_sites
    A1SSLS_JPLevel._sTransitionUpdate
    (unit_global_definitions jp_units) = [] /\
  internal_function_direct_call_sites
    A1SSLS_JPLevel._level_set_transition
    (unit_global_definitions jp_units) =
      [A1SSLS_JPLevel._fade_into_special_warp;
       A1SSLS_JPLevel._load_level_init_text;
       A1SSLS_JPLevel._initiate_painting_warp;
       A1SSLS_JPLevel._initiate_delayed_warp] /\
  internal_direct_call_occurrence_count
    A1SSLS_JPLevel._level_set_transition
    (unit_global_definitions jp_units) = 4%nat /\
  internal_transition_install_shapes
    A1SSLS_JPLevel._level_set_transition A1SSLS_JPLevel._basic_update
    (unit_global_definitions jp_units) =
      [TransitionNullThirty; TransitionNullMinusOne;
       TransitionBasicSeventyFour; TransitionNullTwo] /\
  existsb (Pos.eqb A1SSLS_JPLevel._sTransitionUpdate)
    (source_union_init_addrof_identifiers jp_units) = false.

Theorem us_transition_callback_direct_source_union_checked :
  USTransitionCallbackDirectSourceUnionClaim.
Proof.
  unfold USTransitionCallbackDirectSourceUnionClaim.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem jp_transition_callback_direct_source_union_checked :
  JPTransitionCallbackDirectSourceUnionClaim.
Proof.
  unfold JPTransitionCallbackDirectSourceUnionClaim.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** * Complete direct [Surface.object] writer census *)

Definition lhs_is_surface_object
    (surface_tag object_field : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield (Ederef _ (Tstruct found_tag _)) found_field _ =>
      Pos.eqb found_tag surface_tag && Pos.eqb found_field object_field
  | _ => false
  end.

Fixpoint surface_object_assignment_count_s
    (surface_tag object_field : ident) (body : statement) : nat :=
  match body with
  | Sassign lhs _ =>
      if lhs_is_surface_object surface_tag object_field lhs then 1 else 0
  | Ssequence first second | Sloop first second =>
      (surface_object_assignment_count_s surface_tag object_field first +
       surface_object_assignment_count_s surface_tag object_field second)%nat
  | Sifthenelse _ yes no =>
      (surface_object_assignment_count_s surface_tag object_field yes +
       surface_object_assignment_count_s surface_tag object_field no)%nat
  | Sswitch _ cases =>
      surface_object_assignment_count_ls surface_tag object_field cases
  | Slabel _ nested =>
      surface_object_assignment_count_s surface_tag object_field nested
  | _ => 0%nat
  end
with surface_object_assignment_count_ls
    (surface_tag object_field : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (surface_object_assignment_count_s surface_tag object_field body +
       surface_object_assignment_count_ls surface_tag object_field rest)%nat
  end.

Fixpoint internal_surface_object_assignment_sites
    (surface_tag object_field : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if Nat.eqb
           (surface_object_assignment_count_s
             surface_tag object_field (fn_body body)) 0%nat
      then internal_surface_object_assignment_sites
             surface_tag object_field rest
      else id :: internal_surface_object_assignment_sites
                   surface_tag object_field rest
  | _ :: rest =>
      internal_surface_object_assignment_sites surface_tag object_field rest
  end.

Fixpoint expression_takes_address_of_surface_object
    (surface_tag object_field : ident) (value : expr) : bool :=
  match value with
  | Eaddrof inner _ =>
      lhs_is_surface_object surface_tag object_field inner ||
      expression_takes_address_of_surface_object
        surface_tag object_field inner
  | Ederef inner _ | Eunop _ inner _ | Ecast inner _ | Efield inner _ _ =>
      expression_takes_address_of_surface_object
        surface_tag object_field inner
  | Ebinop _ left_value right_value _ =>
      expression_takes_address_of_surface_object
        surface_tag object_field left_value ||
      expression_takes_address_of_surface_object
        surface_tag object_field right_value
  | _ => false
  end.

Definition expression_list_takes_address_of_surface_object
    (surface_tag object_field : ident) (values : list expr) : bool :=
  existsb
    (expression_takes_address_of_surface_object surface_tag object_field)
    values.

Fixpoint statement_takes_address_of_surface_object_s
    (surface_tag object_field : ident) (body : statement) : bool :=
  match body with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_takes_address_of_surface_object surface_tag object_field lhs ||
      expression_takes_address_of_surface_object surface_tag object_field rhs
  | Sset _ rhs =>
      expression_takes_address_of_surface_object surface_tag object_field rhs
  | Scall _ callee arguments =>
      expression_takes_address_of_surface_object
        surface_tag object_field callee ||
      expression_list_takes_address_of_surface_object
        surface_tag object_field arguments
  | Sbuiltin _ _ _ arguments =>
      expression_list_takes_address_of_surface_object
        surface_tag object_field arguments
  | Ssequence first second | Sloop first second =>
      statement_takes_address_of_surface_object_s
        surface_tag object_field first ||
      statement_takes_address_of_surface_object_s
        surface_tag object_field second
  | Sifthenelse condition yes no =>
      expression_takes_address_of_surface_object
        surface_tag object_field condition ||
      statement_takes_address_of_surface_object_s
        surface_tag object_field yes ||
      statement_takes_address_of_surface_object_s
        surface_tag object_field no
  | Sreturn (Some value) =>
      expression_takes_address_of_surface_object
        surface_tag object_field value
  | Sswitch value cases =>
      expression_takes_address_of_surface_object
        surface_tag object_field value ||
      statement_takes_address_of_surface_object_ls
        surface_tag object_field cases
  | Slabel _ nested =>
      statement_takes_address_of_surface_object_s
        surface_tag object_field nested
  end
with statement_takes_address_of_surface_object_ls
    (surface_tag object_field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_takes_address_of_surface_object_s
        surface_tag object_field body ||
      statement_takes_address_of_surface_object_ls
        surface_tag object_field rest
  end.

Fixpoint internal_surface_object_address_sites
    (surface_tag object_field : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_takes_address_of_surface_object_s
           surface_tag object_field (fn_body body)
      then id :: internal_surface_object_address_sites
                   surface_tag object_field rest
      else internal_surface_object_address_sites
             surface_tag object_field rest
  | _ :: rest =>
      internal_surface_object_address_sites surface_tag object_field rest
  end.

(** Strengthen the earlier owner-store receipt at its one stated syntactic
    weak point.  After the immediate

      owner := gCurrentObject; surface->object := owner

    pair, the same local surface temporary reaches [add_surface(surface, 1)]
    without another [Sset] to that temporary.  Function-local temporaries are
    not addressable by a callee in Clight, so this removes the generated-source
    "intervening surface-temp reassignment" branch.  It still does not frame
    a store through an alias of the pointed-to [Surface] cell. *)
Fixpoint temp_set_count_s (target : ident) (body : statement) : nat :=
  match body with
  | Sset found _ => if Pos.eqb found target then 1 else 0
  | Ssequence first second | Sloop first second =>
      (temp_set_count_s target first + temp_set_count_s target second)%nat
  | Sifthenelse _ yes no =>
      (temp_set_count_s target yes + temp_set_count_s target no)%nat
  | Sswitch _ cases => temp_set_count_ls target cases
  | Slabel _ nested => temp_set_count_s target nested
  | _ => 0%nat
  end
with temp_set_count_ls (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (temp_set_count_s target body + temp_set_count_ls target rest)%nat
  end.

Definition is_stable_owner_store_before_dynamic_add_s
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
      contains_add_surface_call_s add_surface stored_surface 1 continuation &&
      Nat.eqb (temp_set_count_s stored_surface continuation) 0%nat
  | _ => false
  end.

Fixpoint contains_stable_owner_store_before_dynamic_add_s
    (current_object surface_tag object_field add_surface : ident)
    (body : statement) : bool :=
  is_stable_owner_store_before_dynamic_add_s
    current_object surface_tag object_field add_surface body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_stable_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface first ||
      contains_stable_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface second
  | Sifthenelse _ yes no =>
      contains_stable_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface yes ||
      contains_stable_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface no
  | Sswitch _ cases =>
      contains_stable_owner_store_before_dynamic_add_ls
        current_object surface_tag object_field add_surface cases
  | Slabel _ nested =>
      contains_stable_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface nested
  | _ => false
  end
with contains_stable_owner_store_before_dynamic_add_ls
    (current_object surface_tag object_field add_surface : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_stable_owner_store_before_dynamic_add_s
        current_object surface_tag object_field add_surface body ||
      contains_stable_owner_store_before_dynamic_add_ls
        current_object surface_tag object_field add_surface rest
  end.

Definition USSurfaceObjectDirectSourceUnionClaim : Prop :=
  internal_surface_object_assignment_sites
    A1SSLS_USSurface._Surface A1SSLS_USSurface._object
    (unit_global_definitions us_units) =
      [A1SSLS_USSurface._alloc_surface;
       A1SSLS_USSurface._load_object_surfaces] /\
  surface_object_assignment_count_s
    A1SSLS_USSurface._Surface A1SSLS_USSurface._object
    (fn_body A1SSLS_USSurface.f_alloc_surface) = 1%nat /\
  surface_object_assignment_count_s
    A1SSLS_USSurface._Surface A1SSLS_USSurface._object
    (fn_body A1SSLS_USSurface.f_load_object_surfaces) = 1%nat /\
  internal_surface_object_address_sites
    A1SSLS_USSurface._Surface A1SSLS_USSurface._object
    (unit_global_definitions us_units) = [] /\
  assigns_field_null_pointer_s A1SSLS_USSurface._object
    (fn_body A1SSLS_USSurface.f_alloc_surface) = true /\
  contains_stable_owner_store_before_dynamic_add_s
    A1SSLS_USSurface._gCurrentObject A1SSLS_USSurface._Surface
    A1SSLS_USSurface._object A1SSLS_USSurface._add_surface
    (fn_body A1SSLS_USSurface.f_load_object_surfaces) = true /\
  USDynamicSurfaceOwnerSourceClaim.

Definition JPSurfaceObjectDirectSourceUnionClaim : Prop :=
  internal_surface_object_assignment_sites
    A1SSLS_JPSurface._Surface A1SSLS_JPSurface._object
    (unit_global_definitions jp_units) =
      [A1SSLS_JPSurface._alloc_surface;
       A1SSLS_JPSurface._load_object_surfaces] /\
  surface_object_assignment_count_s
    A1SSLS_JPSurface._Surface A1SSLS_JPSurface._object
    (fn_body A1SSLS_JPSurface.f_alloc_surface) = 1%nat /\
  surface_object_assignment_count_s
    A1SSLS_JPSurface._Surface A1SSLS_JPSurface._object
    (fn_body A1SSLS_JPSurface.f_load_object_surfaces) = 1%nat /\
  internal_surface_object_address_sites
    A1SSLS_JPSurface._Surface A1SSLS_JPSurface._object
    (unit_global_definitions jp_units) = [] /\
  assigns_field_null_pointer_s A1SSLS_JPSurface._object
    (fn_body A1SSLS_JPSurface.f_alloc_surface) = true /\
  contains_stable_owner_store_before_dynamic_add_s
    A1SSLS_JPSurface._gCurrentObject A1SSLS_JPSurface._Surface
    A1SSLS_JPSurface._object A1SSLS_JPSurface._add_surface
    (fn_body A1SSLS_JPSurface.f_load_object_surfaces) = true /\
  JPDynamicSurfaceOwnerSourceClaim.

Theorem us_surface_object_direct_source_union_checked :
  USSurfaceObjectDirectSourceUnionClaim.
Proof.
  unfold USSurfaceObjectDirectSourceUnionClaim.
  split.
  - vm_compute. reflexivity.
  - split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    exact us_dynamic_surface_owner_source_checked.
Qed.

Theorem jp_surface_object_direct_source_union_checked :
  JPSurfaceObjectDirectSourceUnionClaim.
Proof.
  unfold JPSurfaceObjectDirectSourceUnionClaim.
  split.
  - vm_compute. reflexivity.
  - split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    split; [vm_compute; reflexivity |].
    exact jp_dynamic_surface_owner_source_checked.
Qed.

Definition Area1CallbackSurfaceDirectSourceUnionBoundary : Prop :=
  USTransitionCallbackDirectSourceUnionClaim /\
  JPTransitionCallbackDirectSourceUnionClaim /\
  USSurfaceObjectDirectSourceUnionClaim /\
  JPSurfaceObjectDirectSourceUnionClaim.

Theorem area1_callback_surface_direct_source_union_boundary_holds :
  Area1CallbackSurfaceDirectSourceUnionBoundary.
Proof.
  unfold Area1CallbackSurfaceDirectSourceUnionBoundary.
  split; [exact us_transition_callback_direct_source_union_checked |].
  split; [exact jp_transition_callback_direct_source_union_checked |].
  split; [exact us_surface_object_direct_source_union_checked |].
  exact jp_surface_object_direct_source_union_checked.
Qed.

(** * The stock scheduler/owner model derives the split *)

Theorem stock_nonnull_query_after_upper_warp_contact_requires_distinct_sample :
  forall collision_position query_position owner,
    upper_warp_contact collision_position ->
    stock_area1_final_platform_query query_position (Some owner) ->
    query_position <> collision_position.
Proof.
  intros collision_position query_position owner Hcontact Hquery Hequal.
  subst query_position.
  pose proof
    (stock_upper_warp_final_query_clears_platform
      collision_position (Some owner) Hcontact Hquery) as Hnone.
  discriminate Hnone.
Qed.

(** Product lemma for separately supplied event-shape and position facts.  It
    does not by itself identify those positions as fields of one schedule. *)
Theorem modeled_event_and_stock_query_product_derives_split :
  forall shape collision_position query_position owner,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    upper_warp_contact collision_position ->
    stock_area1_final_platform_query query_position (Some owner) ->
    schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) /\
      query_position <> collision_position.
Proof.
  intros shape collision_position query_position owner
    Hselection Hcontact Hquery.
  split.
  - exact (a_schedule_that_selects_upper_warp_action_has_final_query
      shape Hselection).
  - exact
      (stock_nonnull_query_after_upper_warp_contact_requires_distinct_sample
        collision_position query_position owner Hcontact Hquery).
Qed.

(** Schedule-coupled form: the collision and query positions are the two
    named fields of one [UpperWarpSelectionPositionSchedule].  The modeled
    event shape remains a separate finite scheduler witness. *)
Theorem modeled_accepted_warp_schedule_stock_installer_derives_query_and_split :
  forall (schedule : UpperWarpSelectionPositionSchedule) shape owner,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) (Some owner) ->
    schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) /\
      position_z_of_schedule (schedule_final_query schedule) <>
        position_z_of_schedule (schedule_collision_object schedule).
Proof.
  intros schedule shape owner Hselection Hcontact Hquery.
  exact
    (modeled_event_and_stock_query_product_derives_split
      shape
      (position_z_of_schedule (schedule_collision_object schedule))
      (position_z_of_schedule (schedule_final_query schedule))
      owner Hselection Hcontact Hquery).
Qed.

Corollary
    modeled_accepted_warp_schedule_top_installer_derives_collision_query_split :
  forall (schedule : UpperWarpSelectionPositionSchedule) shape,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule))
      (Some A1PyramidTop) ->
    schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) /\
      position_z_of_schedule (schedule_final_query schedule) <>
        position_z_of_schedule (schedule_collision_object schedule).
Proof.
  intros schedule shape.
  exact
    (modeled_accepted_warp_schedule_stock_installer_derives_query_and_split
      schedule shape A1PyramidTop).
Qed.

(** The split conclusion is logically independent of an arbitrary separately
    supplied payload-fate witness: the proof does not inspect that witness.
    This theorem does not couple the fate to the modeled install, establish
    trace ordering between them, or eliminate a lifecycle escape. *)
Theorem modeled_stock_install_split_is_independent_of_supplied_lifecycle_fate :
  forall (schedule : UpperWarpSelectionPositionSchedule)
      shape owner lifecycle_state,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) (Some owner) ->
    CachedApplyPayloadFate lifecycle_state ->
    schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) /\
      position_z_of_schedule (schedule_final_query schedule) <>
        position_z_of_schedule (schedule_collision_object schedule).
Proof.
  intros schedule shape owner lifecycle_state
    Hselection Hcontact Hquery _.
  exact
    (modeled_accepted_warp_schedule_stock_installer_derives_query_and_split
      schedule shape owner
      Hselection Hcontact Hquery).
Qed.

(** * Concrete remaining lifecycle survivor in the bounded model

    Slot 17, epoch 3, and delta 1 are deliberately small abstract values;
    they are not the authenticated timer-131 slot, free-list depth, or retail
    displacement. *)

Definition inactive_unreused_survivor_payload : LifecyclePayload :=
  {| lifecycle_payload_owner :=
       {| object_slot := 17%nat; object_epoch := 3%nat |};
     lifecycle_payload_delta_y := 1 |}.

Definition inactive_unreused_survivor : SurfaceEpochLifecycleState :=
  freed_surface_inactive_apply inactive_unreused_survivor_payload 1000.

Theorem inactive_unreused_payload_is_a_concrete_lifecycle_survivor :
  lifecycle_dynamic_surface_owner inactive_unreused_survivor = None /\
  lifecycle_cached_platform inactive_unreused_survivor =
    Some (lifecycle_pointer_of_payload inactive_unreused_survivor_payload) /\
  lifecycle_cell_allocated
    (lifecycle_slot_cell inactive_unreused_survivor) = false /\
  lifecycle_cell_active
    (lifecycle_slot_cell inactive_unreused_survivor) = false /\
  lifecycle_apply_payload_token inactive_unreused_survivor =
    lifecycle_payload_owner inactive_unreused_survivor_payload /\
  lifecycle_state_y inactive_unreused_survivor = 1001 /\
  lifecycle_object_y inactive_unreused_survivor = 1000 /\
  lifecycle_state_y inactive_unreused_survivor <>
    lifecycle_object_y inactive_unreused_survivor.
Proof.
  vm_compute.
  repeat split; try reflexivity; lia.
Qed.

Definition Area1SchedulerSurfaceLifecycleSplitCheckedBoundary : Prop :=
  Area1MovingSkippedQueryCheckedBoundary /\
  USTransitionCallbackDirectSourceUnionClaim /\
  JPTransitionCallbackDirectSourceUnionClaim /\
  USSurfaceObjectDirectSourceUnionClaim /\
  JPSurfaceObjectDirectSourceUnionClaim /\
  area1_surface_epoch_lifecycle_source_claim /\
  (forall (schedule : UpperWarpSelectionPositionSchedule) shape owner,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) (Some owner) ->
    schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) /\
      position_z_of_schedule (schedule_final_query schedule) <>
        position_z_of_schedule (schedule_collision_object schedule)) /\
  lifecycle_state_y inactive_unreused_survivor <>
    lifecycle_object_y inactive_unreused_survivor.

Theorem area1_scheduler_surface_lifecycle_split_checked_boundary_holds :
  Area1SchedulerSurfaceLifecycleSplitCheckedBoundary.
Proof.
  unfold Area1SchedulerSurfaceLifecycleSplitCheckedBoundary.
  split; [exact area1_moving_skipped_query_checked_boundary_holds |].
  split; [exact us_transition_callback_direct_source_union_checked |].
  split; [exact jp_transition_callback_direct_source_union_checked |].
  split; [exact us_surface_object_direct_source_union_checked |].
  split; [exact jp_surface_object_direct_source_union_checked |].
  split; [exact area1_surface_epoch_lifecycle_source_checked |].
  split.
  - exact
      modeled_accepted_warp_schedule_stock_installer_derives_query_and_split.
  - exact (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 (proj2
      inactive_unreused_payload_is_a_concrete_lifecycle_survivor))))))).
Qed.
