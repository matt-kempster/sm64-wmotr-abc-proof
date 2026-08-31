From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes Events
  Floats Globalenvs Integers Linking Maps Memory Values.
From Pedro.Generated Require Import
  us_behavior_actions us_behavior_script us_object_helpers
  us_object_list_processor us_spawn_object
  jp_behavior_actions jp_behavior_script jp_object_helpers
  jp_object_list_processor jp_spawn_object.
From Pedro.Proofs Require Import DustClightLink DustClightExec.

Import ListNotations.

Module UBA := us_behavior_actions.
Module UBS := us_behavior_script.
Module UOH := us_object_helpers.
Module UOL := us_object_list_processor.
Module USO := us_spawn_object.
Module JBA := jp_behavior_actions.
Module JBS := jp_behavior_script.
Module JOH := jp_object_helpers.
Module JOL := jp_object_list_processor.
Module JSO := jp_spawn_object.

(** Unlike [DustClightLink.make_structural_slice], the left component of each
    link below carries the complete generated composite environment from
    [behavior_actions.c].  The selected object and PRNG functions use those
    exact common [struct Object] identifiers.  The right component remains
    composite-empty so the official linker inherits, rather than duplicates,
    the canonical environment.  Carrying that environment is not itself a
    proof of cross-translation-unit layout refinement or whole-program Clight
    well-typedness. *)
Definition typed_component
    (types : list composite_definition)
    (comp_env : composite_env)
    (comp_env_eq : build_composite_env types = Errors.OK comp_env)
    (definitions : list (ident * globdef Clight.fundef type))
    (main : ident) : Clight.program :=
  {| prog_defs := definitions;
     prog_public := map fst definitions;
     prog_main := main;
     prog_types := types;
     prog_comp_env := comp_env;
     prog_comp_env_eq := comp_env_eq |}.

(** The generated type tables and their certified environments are named once
    and then shared syntactically by the typed slices and the layout facts. *)
Definition us_dust_types : list composite_definition := prog_types UBA.prog.
Definition us_dust_comp_env : composite_env := prog_comp_env UBA.prog.
Definition us_dust_comp_env_eq :
  build_composite_env us_dust_types = Errors.OK us_dust_comp_env :=
  prog_comp_env_eq UBA.prog.

Definition jp_dust_types : list composite_definition := prog_types JBA.prog.
Definition jp_dust_comp_env : composite_env := prog_comp_env JBA.prog.
Definition jp_dust_comp_env_eq :
  build_composite_env jp_dust_types = Errors.OK jp_dust_comp_env :=
  prog_comp_env_eq JBA.prog.

Definition us_dust_typed_core : Clight.program :=
  typed_component us_dust_types us_dust_comp_env us_dust_comp_env_eq
    us_dust_core_definitions UBS._main.

Definition jp_dust_typed_core : Clight.program :=
  typed_component jp_dust_types jp_dust_comp_env jp_dust_comp_env_eq
    jp_dust_core_definitions JBS._main.

(** The official link is obtained without reducing the proof-producing
    composite-environment construction.  Only the bounded AST link and the
    generated-types/empty-types list link are computed. *)
Theorem us_dust_typed_link_exists :
  exists linked,
    link us_dust_typed_core us_dust_leaf_program = Some linked.
Proof.
  assert (Hast_success :
    option_successb
      (link (program_components us_dust_typed_core)
            (program_components us_dust_leaf_program)) = true).
  { vm_compute. reflexivity. }
  destruct (option_successb_has_witness _ _ Hast_success)
    as [ast_linked Hast].
  eapply ast_and_composite_links_lift_to_clight_pair.
  - exact Hast.
  - vm_compute. reflexivity.
Qed.

Theorem jp_dust_typed_link_exists :
  exists linked,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked.
Proof.
  assert (Hast_success :
    option_successb
      (link (program_components jp_dust_typed_core)
            (program_components jp_dust_leaf_program)) = true).
  { vm_compute. reflexivity. }
  destruct (option_successb_has_witness _ _ Hast_success)
    as [ast_linked Hast].
  eapply ast_and_composite_links_lift_to_clight_pair.
  - exact Hast.
  - vm_compute. reflexivity.
Qed.

(** Reusable bounded link-resolution lemma.  The linked program stays opaque;
    computation is confined to a selected component's small definition map. *)
Lemma linkorder_resolves_internal :
  forall (linked component : Clight.program)
      (name : ident) (function : Clight.function),
    linkorder component linked ->
    (prog_defmap component) ! name =
      Some (Gfun (Internal function)) ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) name = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal function).
Proof.
  intros linked component name function Horder Hdefinition.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Horder.
  destruct Horder as [Hast _].
  destruct (prog_defmap_linkorder _ _ _ _ Hast Hdefinition)
    as (linked_definition & Hlinked_definition & Hdefinition_order).
  clear Hast.
  inversion Hdefinition_order; subst.
  match goal with H : linkorder _ _ |- _ => inversion H; subst end.
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hlinked_definition.
  destruct Hlinked_definition as (block & Hsymbol & Hfunction).
  exists block. split; [exact Hsymbol|].
  apply (proj2 (Genv.find_funct_ptr_iff _ _ _)).
  exact Hfunction.
Qed.

(** Global variables need only symbol resolution for the execution theorem.
    This weaker lemma deliberately avoids claiming that a tentative declaration
    is byte-for-byte the linked variable definition. *)
Lemma linkorder_resolves_symbol :
  forall (linked component : Clight.program)
      (name : ident) (definition : globdef Clight.fundef type),
    linkorder component linked ->
    (prog_defmap component) ! name = Some definition ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) name = Some block.
Proof.
  intros linked component name definition Horder Hdefinition.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Horder.
  destruct Horder as [Hast _].
  destruct (prog_defmap_linkorder _ _ _ _ Hast Hdefinition)
    as (linked_definition & Hlinked_definition & _).
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hlinked_definition.
  destruct Hlinked_definition as (block & Hsymbol & _).
  exists block. exact Hsymbol.
Qed.

(** Linking preserves every concrete composite definition supplied by a
    component.  Object-field execution uses this half of CompCert's
    [linkorder_program], rather than assuming that the linked composite
    environment equals a hand-authored layout. *)
Lemma linkorder_comp_env_extends :
  forall (linked component : Clight.program) name composite,
    linkorder component linked ->
    (prog_comp_env component) ! name = Some composite ->
    (prog_comp_env linked) ! name = Some composite.
Proof.
  intros linked component name composite Horder Hcomposite.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Horder.
  destruct Horder as [_ Hextends].
  apply Hextends. exact Hcomposite.
Qed.

Lemma linkorder_field_offset_agrees :
  forall (linked component : Clight.program) field fields,
    linkorder component linked ->
    complete_members (prog_comp_env component) fields = true ->
    field_offset (prog_comp_env linked) field fields =
      field_offset (prog_comp_env component) field fields.
Proof.
  intros linked component field fields Horder Hcomplete.
  eapply field_offset_stable; [|exact Hcomplete].
  intros name composite Hcomposite.
  eapply linkorder_comp_env_extends; eauto.
Qed.

Lemma linkorder_union_field_offset_agrees :
  forall (linked component : Clight.program) field fields,
    linkorder component linked ->
    complete_members (prog_comp_env component) fields = true ->
    union_field_offset (prog_comp_env linked) field fields =
      union_field_offset (prog_comp_env component) field fields.
Proof.
  intros linked component field fields Horder Hcomplete.
  eapply union_field_offset_stable; [|exact Hcomplete].
  intros name composite Hcomposite.
  eapply linkorder_comp_env_extends; eauto.
Qed.

Lemma linked_right_resolves_internal :
  forall (left right linked : Clight.program)
      (name : ident) (function : Clight.function),
    link left right = Some linked ->
    (prog_defmap right) ! name = Some (Gfun (Internal function)) ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) name = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal function).
Proof.
  intros left right linked name function Hlink Hdefinition.
  destruct (link_linkorder _ _ _ Hlink) as [_ Hright].
  eapply linkorder_resolves_internal; eauto.
Qed.

Lemma linked_left_resolves_internal :
  forall (left right linked : Clight.program)
      (name : ident) (function : Clight.function),
    link left right = Some linked ->
    (prog_defmap left) ! name = Some (Gfun (Internal function)) ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) name = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal function).
Proof.
  intros left right linked name function Hlink Hdefinition.
  destruct (link_linkorder _ _ _ Hlink) as [Hleft _].
  eapply linkorder_resolves_internal; eauto.
Qed.

Lemma linked_right_resolves_symbol :
  forall (left right linked : Clight.program)
      (name : ident) (definition : globdef Clight.fundef type),
    link left right = Some linked ->
    (prog_defmap right) ! name = Some definition ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) name = Some block.
Proof.
  intros left right linked name definition Hlink Hdefinition.
  destruct (link_linkorder _ _ _ Hlink) as [_ Hright].
  eapply linkorder_resolves_symbol; eauto.
Qed.

(** The big-step [Scall] rule consumes [find_funct], while the global
    environment/linking API exposes [find_funct_ptr].  At the zero offset
    produced by a function-typed [Evar], these are definitionally the same
    lookup. *)
Lemma find_funct_at_zero_offset :
  forall (ge : Clight.genv) block function,
    Genv.find_funct_ptr ge block = Some function ->
    Genv.find_funct ge (Vptr block Ptrofs.zero) = Some function.
Proof.
  intros ge block function Hfunction.
  unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | Hneq].
  - exact Hfunction.
  - exfalso. apply Hneq. reflexivity.
Qed.

(** A linked global function symbol evaluates to its real linked function
    pointer.  This is the expression premise used below by [exec_Scall]; no
    stand-in function environment is introduced. *)
Lemma eval_linked_function_symbol :
  forall (ge : Clight.genv) (environment : env) locals memory
      name argument_types return_type calling_convention block,
    environment ! name = None ->
    Genv.find_symbol ge name = Some block ->
    eval_expr ge environment locals memory
      (Evar name (Tfunction argument_types return_type calling_convention))
      (Vptr block Ptrofs.zero).
Proof.
  intros ge environment locals memory name argument_types return_type
    calling_convention block Hlocal Hsymbol.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; eauto.
  - eapply deref_loc_reference. reflexivity.
Qed.

(** Exactly five definitions are covered here: [cur_obj_update], both white
    puff native loops, [random_float], and [random_u16].  Allocation, spawn,
    and list-walk definitions are present across the two link components but
    are not called a resolved execution chain by this certificate. *)
Theorem us_typed_link_resolves_selected_behavior_leaf_chain :
  forall linked,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) UBS._cur_obj_update =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBS.f_cur_obj_update)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked)
        UBA._bhv_white_puff_1_loop = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBA.f_bhv_white_puff_1_loop)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked)
        UBA._bhv_white_puff_2_loop = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBA.f_bhv_white_puff_2_loop)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) UBS._random_float =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBS.f_random_float)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) UBS._random_u16 =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBS.f_random_u16)).
Proof.
  intros linked Hlink.
  repeat split;
    first
      [ eapply linked_left_resolves_internal;
        [exact Hlink | vm_compute; reflexivity]
      | eapply linked_right_resolves_internal;
        [exact Hlink | vm_compute; reflexivity] ].
Qed.

Theorem jp_typed_link_resolves_selected_behavior_leaf_chain :
  forall linked,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) JBS._cur_obj_update =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBS.f_cur_obj_update)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked)
        JBA._bhv_white_puff_1_loop = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBA.f_bhv_white_puff_1_loop)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked)
        JBA._bhv_white_puff_2_loop = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBA.f_bhv_white_puff_2_loop)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) JBS._random_float =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBS.f_random_float)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) JBS._random_u16 =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBS.f_random_u16)).
Proof.
  intros linked Hlink.
  repeat split;
    first
      [ eapply linked_left_resolves_internal;
        [exact Hlink | vm_compute; reflexivity]
      | eapply linked_right_resolves_internal;
        [exact Hlink | vm_compute; reflexivity] ].
Qed.

Theorem us_typed_link_resolves_obj_translate_xz_random :
  forall linked,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked)
        UOH._obj_translate_xz_random = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UOH.f_obj_translate_xz_random).
Proof.
  intros linked Hlink.
  eapply linked_right_resolves_internal.
  - exact Hlink.
  - vm_compute. reflexivity.
Qed.

Theorem jp_typed_link_resolves_obj_translate_xz_random :
  forall linked,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked)
        JOH._obj_translate_xz_random = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JOH.f_obj_translate_xz_random).
Proof.
  intros linked Hlink.
  eapply linked_right_resolves_internal.
  - exact Hlink.
  - vm_compute. reflexivity.
Qed.

Definition resolves_linked_internal
    (linked : Clight.program) (name : ident) (function : Clight.function) :
    Prop :=
  exists block,
    Genv.find_symbol (Clight.globalenv linked) name = Some block /\
    Genv.find_funct_ptr (Clight.globalenv linked) block =
      Some (Internal function).

(** Complete finite symbol certificate for every selected generated function
    on the object-list/spawn/behavior/RNG path.  This certificate is paired
    below with a real object-bearing big-step; by itself it is intentionally
    only resolution, not execution of the allocator or indirect interpreter. *)
Theorem us_typed_link_resolves_all_selected_chain_functions :
  forall linked,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    resolves_linked_internal linked UOL._spawn_particle
      UOL.f_spawn_particle /\
    resolves_linked_internal linked UOL._bhv_mario_update
      UOL.f_bhv_mario_update /\
    resolves_linked_internal linked UOL._update_objects_starting_at
      UOL.f_update_objects_starting_at /\
    resolves_linked_internal linked UOL._update_non_terrain_objects
      UOL.f_update_non_terrain_objects /\
    resolves_linked_internal linked USO._try_allocate_object
      USO.f_try_allocate_object /\
    resolves_linked_internal linked USO._allocate_object
      USO.f_allocate_object /\
    resolves_linked_internal linked USO._create_object
      USO.f_create_object /\
    resolves_linked_internal linked UBS._cur_obj_update
      UBS.f_cur_obj_update /\
    resolves_linked_internal linked UBS._bhv_cmd_call_native
      UBS.f_bhv_cmd_call_native /\
    resolves_linked_internal linked UBA._bhv_white_puff_1_loop
      UBA.f_bhv_white_puff_1_loop /\
    resolves_linked_internal linked UBA._bhv_white_puff_2_loop
      UBA.f_bhv_white_puff_2_loop /\
    resolves_linked_internal linked UOH._spawn_object_at_origin
      UOH.f_spawn_object_at_origin /\
    resolves_linked_internal linked UOH._obj_translate_xz_random
      UOH.f_obj_translate_xz_random /\
    resolves_linked_internal linked UBS._random_float
      UBS.f_random_float /\
    resolves_linked_internal linked UBS._random_u16
      UBS.f_random_u16.
Proof.
  intros linked Hlink. unfold resolves_linked_internal.
  repeat split;
    first
      [ eapply linked_left_resolves_internal;
        [exact Hlink | vm_compute; reflexivity]
      | eapply linked_right_resolves_internal;
        [exact Hlink | vm_compute; reflexivity] ].
Qed.

Theorem jp_typed_link_resolves_all_selected_chain_functions :
  forall linked,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    resolves_linked_internal linked JOL._spawn_particle
      JOL.f_spawn_particle /\
    resolves_linked_internal linked JOL._bhv_mario_update
      JOL.f_bhv_mario_update /\
    resolves_linked_internal linked JOL._update_objects_starting_at
      JOL.f_update_objects_starting_at /\
    resolves_linked_internal linked JOL._update_non_terrain_objects
      JOL.f_update_non_terrain_objects /\
    resolves_linked_internal linked JSO._try_allocate_object
      JSO.f_try_allocate_object /\
    resolves_linked_internal linked JSO._allocate_object
      JSO.f_allocate_object /\
    resolves_linked_internal linked JSO._create_object
      JSO.f_create_object /\
    resolves_linked_internal linked JBS._cur_obj_update
      JBS.f_cur_obj_update /\
    resolves_linked_internal linked JBS._bhv_cmd_call_native
      JBS.f_bhv_cmd_call_native /\
    resolves_linked_internal linked JBA._bhv_white_puff_1_loop
      JBA.f_bhv_white_puff_1_loop /\
    resolves_linked_internal linked JBA._bhv_white_puff_2_loop
      JBA.f_bhv_white_puff_2_loop /\
    resolves_linked_internal linked JOH._spawn_object_at_origin
      JOH.f_spawn_object_at_origin /\
    resolves_linked_internal linked JOH._obj_translate_xz_random
      JOH.f_obj_translate_xz_random /\
    resolves_linked_internal linked JBS._random_float
      JBS.f_random_float /\
    resolves_linked_internal linked JBS._random_u16
      JBS.f_random_u16.
Proof.
  intros linked Hlink. unfold resolves_linked_internal.
  repeat split;
    first
      [ eapply linked_left_resolves_internal;
        [exact Hlink | vm_compute; reflexivity]
      | eapply linked_right_resolves_internal;
        [exact Hlink | vm_compute; reflexivity] ].
Qed.

(** Targeted, computation-friendly views of the exact generated object and
    raw-data union layouts.  The concrete offsets below are derived from the
    [behavior_actions.c] composite environment retained by [typed_component]. *)
Definition us_object_members : members :=
  match us_dust_comp_env ! UBA._Object with
  | Some composite => co_members composite
  | None => nil
  end.

Definition us_object_raw_data_members : members :=
  match us_dust_comp_env ! UBA.__764 with
  | Some composite => co_members composite
  | None => nil
  end.

Lemma us_object_composite_exists :
  exists composite,
    us_dust_comp_env ! UBA._Object = Some composite.
Proof.
  assert (Hsome :
    match us_dust_comp_env ! UBA._Object with
    | Some _ => true | None => false
    end = true) by (vm_compute; reflexivity).
  destruct (us_dust_comp_env ! UBA._Object) as [composite|] eqn:Hlookup.
  - exists composite. reflexivity.
  - discriminate Hsome.
Qed.

Lemma us_object_raw_data_composite_exists :
  exists composite,
    us_dust_comp_env ! UBA.__764 = Some composite.
Proof.
  assert (Hsome :
    match us_dust_comp_env ! UBA.__764 with
    | Some _ => true | None => false
    end = true) by (vm_compute; reflexivity).
  destruct (us_dust_comp_env ! UBA.__764) as [composite|] eqn:Hlookup.
  - exists composite. reflexivity.
  - discriminate Hsome.
Qed.

Lemma us_object_members_complete :
  complete_members us_dust_comp_env us_object_members = true.
Proof. vm_compute. reflexivity. Qed.

Lemma us_object_raw_data_members_complete :
  complete_members us_dust_comp_env us_object_raw_data_members = true.
Proof. vm_compute. reflexivity. Qed.

Lemma us_object_raw_data_offset :
  field_offset us_dust_comp_env UBA._rawData us_object_members =
    Errors.OK (136, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma us_object_raw_f32_union_offset :
  union_field_offset us_dust_comp_env UBA._asF32
    us_object_raw_data_members = Errors.OK (0, Full).
Proof. vm_compute. reflexivity. Qed.

(** Opaque specializations of CompCert's layout-stability metatheory.  The
    target environment stays abstract here, so the linked execution proof never
    elaborates a term containing both the full generated members and a linked
    program projection. *)
Lemma us_object_raw_data_offset_stable :
  forall target_env,
    (forall id composite,
      us_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    field_offset target_env UBA._rawData us_object_members =
      Errors.OK (136, Full).
Proof.
  intros target_env Hextends.
  rewrite <- us_object_raw_data_offset.
  exact (field_offset_stable us_dust_comp_env target_env Hextends
    UBA._rawData us_object_members us_object_members_complete).
Qed.

Lemma us_object_raw_f32_union_offset_stable :
  forall target_env,
    (forall id composite,
      us_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    union_field_offset target_env UBA._asF32
      us_object_raw_data_members = Errors.OK (0, Full).
Proof.
  intros target_env Hextends.
  rewrite <- us_object_raw_f32_union_offset.
  exact (union_field_offset_stable us_dust_comp_env target_env Hextends
    UBA._asF32 us_object_raw_data_members
    us_object_raw_data_members_complete).
Qed.

Definition us_object_raw_f32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct UOH._Object noattr)))
        (Tstruct UOH._Object noattr))
      UOH._rawData (Tunion UOH.__764 noattr))
    UOH._asF32 (tarray tfloat 80).

Definition us_object_x_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (us_object_raw_f32_array_expr object_temp)
      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
    tfloat.

Definition us_object_z_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (us_object_raw_f32_array_expr object_temp)
      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
        (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
    tfloat.

(** A named rendering of the two arithmetic right-hand sides emitted by
    [clightgen].  Keeping it separate avoids asking conversion to compare the
    same generated expression four times inside the big-step proof. *)
Definition us_translated_coordinate_expr
    (initial_temp random_temp range_temp : ident) : expr :=
  Ebinop Oadd (Etempvar initial_temp tfloat)
    (Ebinop Osub
      (Ebinop Omul (Etempvar random_temp tfloat)
        (Etempvar range_temp tfloat) tfloat)
      (Ebinop Omul (Etempvar range_temp tfloat)
        (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
        tfloat) tfloat) tfloat.

(** Exact, generated-AST body certificate for the executable object segment.
    This definition is not a replacement semantics: the following opaque
    reflexivity theorem checks it against [UOH.f_obj_translate_xz_random]. *)
Definition us_obj_translate_xz_random_body : statement :=
  Ssequence
    (Ssequence
      (Scall (Some UOH._t'1)
        (Evar UOH._random_float (Tfunction nil tfloat cc_default)) nil)
      (Ssequence
        (Sset UOH._t'4 (us_object_x_lvalue UOH._obj))
        (Sassign (us_object_x_lvalue UOH._obj)
          (us_translated_coordinate_expr UOH._t'4 UOH._t'1
            UOH._rangeLength))))
    (Ssequence
      (Scall (Some UOH._t'2)
        (Evar UOH._random_float (Tfunction nil tfloat cc_default)) nil)
      (Ssequence
        (Sset UOH._t'3 (us_object_z_lvalue UOH._obj))
        (Sassign (us_object_z_lvalue UOH._obj)
          (us_translated_coordinate_expr UOH._t'3 UOH._t'2
            UOH._rangeLength)))).

Lemma us_obj_translate_xz_random_body_exact :
  fn_body UOH.f_obj_translate_xz_random =
    us_obj_translate_xz_random_body.
Proof. reflexivity. Qed.

(** Evaluation of the raw-data float array is rooted in the linked program's
    preserved generated composites.  The returned address is the concrete
    32-bit target-ABI [struct Object.rawData] offset 136. *)
Lemma eval_us_object_raw_f32_array_pointer :
  forall linked environment locals memory object_temp object_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (us_object_raw_f32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr 136)).
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  destruct (link_linkorder _ _ _ Hlink) as [Hleft _].
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Hleft.
  destruct Hleft as [_ Hextends].
  unfold us_dust_typed_core, typed_component in Hextends.
  destruct us_object_composite_exists as [object_composite Hobject].
  destruct us_object_raw_data_composite_exists as
    [raw_composite Hraw_composite].
  assert (Hlinked_object :
      (prog_comp_env linked) ! UBA._Object = Some object_composite).
  { apply Hextends. exact Hobject. }
  assert (Hlinked_raw :
      (prog_comp_env linked) ! UBA.__764 = Some raw_composite).
  { apply Hextends. exact Hraw_composite. }
  assert (Hobject_members :
      us_object_members = co_members object_composite).
  { unfold us_object_members. rewrite Hobject. reflexivity. }
  assert (Hraw_members :
      us_object_raw_data_members = co_members raw_composite).
  { unfold us_object_raw_data_members. rewrite Hraw_composite. reflexivity. }
  assert (Hraw_offset :
      field_offset (prog_comp_env linked) UBA._rawData us_object_members =
        Errors.OK (136, Full)).
  { apply us_object_raw_data_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  assert (Harray_offset :
      union_field_offset (prog_comp_env linked) UBA._asF32
        us_object_raw_data_members = Errors.OK (0, Full)).
  { apply us_object_raw_f32_union_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  unfold us_object_raw_f32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr 136) with
      (Ptrofs.add (Ptrofs.repr 136) (Ptrofs.repr 0))
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := UBA.__764) (co := raw_composite) (att := noattr)
      (delta := 0) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr 136) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := UBA._Object) (co := object_composite) (att := noattr)
          (delta := 136) (bf := Full).
        -- eapply eval_Elvalue.
           ++ eapply eval_Ederef.
              eapply eval_Etempvar. exact Hobject_temp.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- change ((prog_comp_env linked) ! UBA._Object =
             Some object_composite).
           exact Hlinked_object.
         -- rewrite <- Hobject_members. exact Hraw_offset.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + change ((prog_comp_env linked) ! UBA.__764 = Some raw_composite).
      exact Hlinked_raw.
    + rewrite <- Hraw_members. exact Harray_offset.
  - eapply deref_loc_reference. reflexivity.
Qed.

Lemma eval_us_object_x_lvalue :
  forall linked environment locals memory object_temp object_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_lvalue (Clight.globalenv linked) environment locals memory
      (us_object_x_lvalue object_temp) object_block (Ptrofs.repr 160) Full.
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  unfold us_object_x_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - exact (eval_us_object_raw_f32_array_pointer linked environment locals
      memory object_temp object_block Hlink Hobject_temp).
  - eapply eval_Ebinop; [constructor | constructor | cbn; reflexivity].
  - cbn. reflexivity.
Qed.

Lemma eval_us_object_z_lvalue :
  forall linked environment locals memory object_temp object_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_lvalue (Clight.globalenv linked) environment locals memory
      (us_object_z_lvalue object_temp) object_block (Ptrofs.repr 168) Full.
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  unfold us_object_z_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - exact (eval_us_object_raw_f32_array_pointer linked environment locals
      memory object_temp object_block Hlink Hobject_temp).
  - eapply eval_Ebinop; [constructor | constructor | cbn; reflexivity].
  - cbn. reflexivity.
Qed.

Lemma eval_us_object_x_value :
  forall linked environment locals memory object_temp object_block value,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mfloat32 memory object_block 160 = Some (Vsingle value) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (us_object_x_lvalue object_temp) (Vsingle value).
Proof.
  intros linked environment locals memory object_temp object_block value
    Hlink Htemp Hload.
  eapply eval_Elvalue.
  - eapply eval_us_object_x_lvalue; eauto.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv.
      change (Mem.load Mfloat32 memory object_block 160 =
        Some (Vsingle value)).
      exact Hload.
Qed.

Lemma eval_us_object_z_value :
  forall linked environment locals memory object_temp object_block value,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mfloat32 memory object_block 168 = Some (Vsingle value) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (us_object_z_lvalue object_temp) (Vsingle value).
Proof.
  intros linked environment locals memory object_temp object_block value
    Hlink Htemp Hload.
  eapply eval_Elvalue.
  - eapply eval_us_object_z_lvalue; eauto.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv.
      change (Mem.load Mfloat32 memory object_block 168 =
        Some (Vsingle value)).
      exact Hload.
Qed.

Lemma assign_us_object_x_value :
  forall linked memory_before memory_after object_block value,
    Mem.store Mfloat32 memory_before object_block 160 (Vsingle value) =
      Some memory_after ->
    assign_loc (genv_cenv (Clight.globalenv linked)) tfloat memory_before
      object_block (Ptrofs.repr 160) Full (Vsingle value) memory_after.
Proof.
  intros linked memory_before memory_after object_block value Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev.
    change (Mem.store Mfloat32 memory_before object_block 160
      (Vsingle value) = Some memory_after).
    exact Hstore.
Qed.

Lemma assign_us_object_z_value :
  forall linked memory_before memory_after object_block value,
    Mem.store Mfloat32 memory_before object_block 168 (Vsingle value) =
      Some memory_after ->
    assign_loc (genv_cenv (Clight.globalenv linked)) tfloat memory_before
      object_block (Ptrofs.repr 168) Full (Vsingle value) memory_after.
Proof.
  intros linked memory_before memory_after object_block value Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev.
    change (Mem.store Mfloat32 memory_before object_block 168
      (Vsingle value) = Some memory_after).
    exact Hstore.
Qed.

(** Constructor tactics for the exact scalar leaf in an arbitrary successful
    typed link.  The linked [genv] is not replaced by a hand-written one. *)
Ltac linked_eval_closed_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Evar _ _) _ =>
      eapply eval_Elvalue;
      [ eapply eval_Evar_global; [ reflexivity | eassumption ]
      | eapply deref_loc_value; [ reflexivity | cbn; eassumption ] ]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [ linked_eval_closed_expr | cbn; reflexivity ]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop;
      [ linked_eval_closed_expr | linked_eval_closed_expr | cbn; reflexivity ]
  end.

Ltac linked_exec_closed_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
      [ linked_exec_closed_stmt | linked_exec_closed_stmt ]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; linked_eval_closed_expr
  | |- exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ =>
      eapply exec_Sassign;
      [ eapply eval_Evar_global; [ reflexivity | eassumption ]
      | linked_eval_closed_expr
      | cbn; reflexivity
      | eapply assign_loc_value; [ reflexivity | cbn; eassumption ] ]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
        [ eapply exec_Sifthenelse with (b := false);
          [ linked_eval_closed_expr | vm_compute; reflexivity
          | cbn; linked_exec_closed_stmt ]
        | eapply exec_Sifthenelse with (b := true);
          [ linked_eval_closed_expr | vm_compute; reflexivity
          | cbn; linked_exec_closed_stmt ] ]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; linked_eval_closed_expr
  end.

Theorem generated_random_u16_executes_in_any_genv :
  forall (ge : Clight.genv) memory_before seed_block,
    Genv.find_symbol ge UBS._gRandomSeed16 =
      Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 ge memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr 57460)) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 57460)).
Proof.
  intros ge memory_before seed_block Hsymbol Hload0 Hwrite0.
  destruct (Mem.valid_access_store memory_before Mint16unsigned
      seed_block 0 (Vint Int.zero) Hwrite0) as [memory_swapped Hstore0].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore0
    Mint16unsigned seed_block 0 Writable Hwrite0) as Hwrite1.
  destruct (Mem.valid_access_store memory_swapped Mint16unsigned
      seed_block 0 (Vint (Int.repr 57460)) Hwrite1)
    as [memory_after Hstore1].
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload2.
  cbn in Hload1, Hload2.
  exists memory_after.
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + simpl fn_body. linked_exec_closed_stmt.
    + cbn. split; [ discriminate | cbn; reflexivity ].
    + cbn. reflexivity.
  - exact Hload2.
Qed.

(** Strengthened form used for sequential generated calls.  It exposes that
    the exact final store preserves writability of the seed cell. *)
Theorem generated_random_u16_executes_in_any_genv_with_writable_seed :
  forall (ge : Clight.genv) memory_before seed_block,
    Genv.find_symbol ge UBS._gRandomSeed16 =
      Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 ge memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr 57460)) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 57460)) /\
      Mem.valid_access memory_after Mint16unsigned seed_block 0 Writable.
Proof.
  intros ge memory_before seed_block Hsymbol Hload0 Hwrite0.
  destruct (Mem.valid_access_store memory_before Mint16unsigned
      seed_block 0 (Vint Int.zero) Hwrite0) as [memory_swapped Hstore0].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore0
    Mint16unsigned seed_block 0 Writable Hwrite0) as Hwrite1.
  destruct (Mem.valid_access_store memory_swapped Mint16unsigned
      seed_block 0 (Vint (Int.repr 57460)) Hwrite1)
    as [memory_after Hstore1].
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload2.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore1
    Mint16unsigned seed_block 0 Writable Hwrite1) as Hwrite2.
  cbn in Hload1, Hload2.
  exists memory_after.
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + simpl fn_body. linked_exec_closed_stmt.
    + cbn. split; [ discriminate | cbn; reflexivity ].
    + cbn. reflexivity.
  - split; assumption.
Qed.

(** The second concrete retail-seed transition is proved by executing the
    same generated body again, not by applying the arithmetic recurrence.
    Starting from 57460, its byte-swap store writes 29844 and its final store
    and return value are both 55882.  This second leaf step is what lets the
    generated [random_float] caller below run twice in sequence. *)
Theorem generated_random_u16_executes_from_57460_in_any_genv :
  forall (ge : Clight.genv) memory_before seed_block,
    Genv.find_symbol ge UBS._gRandomSeed16 =
      Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint (Int.repr 57460)) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 ge memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr 55882)) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.valid_access memory_after Mint16unsigned seed_block 0 Writable.
Proof.
  intros ge memory_before seed_block Hsymbol Hload0 Hwrite0.
  destruct (Mem.valid_access_store memory_before Mint16unsigned
      seed_block 0 (Vint (Int.repr 29844)) Hwrite0)
    as [memory_swapped Hstore0].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore0
    Mint16unsigned seed_block 0 Writable Hwrite0) as Hwrite1.
  destruct (Mem.valid_access_store memory_swapped Mint16unsigned
      seed_block 0 (Vint (Int.repr 55882)) Hwrite1)
    as [memory_after Hstore1].
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload2.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore1
    Mint16unsigned seed_block 0 Writable Hwrite1) as Hwrite2.
  cbn in Hload1, Hload2.
  exists memory_after.
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + simpl fn_body. linked_exec_closed_stmt.
    + cbn. split; [ discriminate | cbn; reflexivity ].
    + cbn. reflexivity.
  - split; assumption.
Qed.

(** Store-explicit forms used when embedding the leaf in a caller that
    interleaves object-field writes between PRNG calls. *)
Lemma generated_random_u16_zero_with_given_stores :
  forall (ge : Clight.genv) memory_before memory_swapped memory_after
      seed_block,
    Genv.find_symbol ge UBS._gRandomSeed16 = Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.store Mint16unsigned memory_before seed_block 0 (Vint Int.zero) =
      Some memory_swapped ->
    Mem.store Mint16unsigned memory_swapped seed_block 0
      (Vint (Int.repr 57460)) = Some memory_after ->
    eval_funcall function_entry2 ge memory_before
      (Internal UBS.f_random_u16) [] E0 memory_after
      (Vint (Int.repr 57460)).
Proof.
  intros ge memory_before memory_swapped memory_after seed_block
    Hsymbol Hload0 Hstore0 Hstore1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload2.
  cbn in Hload1, Hload2.
  eapply eval_funcall_internal.
  - eapply function_entry2_intro.
    + constructor.
    + constructor.
    + intros x y Hnone. inversion Hnone.
    + constructor.
    + reflexivity.
  - simpl fn_body. linked_exec_closed_stmt.
  - cbn. split; [ discriminate | cbn; reflexivity ].
  - cbn. reflexivity.
Qed.

Lemma generated_random_u16_57460_with_given_stores :
  forall (ge : Clight.genv) memory_before memory_swapped memory_after
      seed_block,
    Genv.find_symbol ge UBS._gRandomSeed16 = Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint (Int.repr 57460)) ->
    Mem.store Mint16unsigned memory_before seed_block 0
      (Vint (Int.repr 29844)) = Some memory_swapped ->
    Mem.store Mint16unsigned memory_swapped seed_block 0
      (Vint (Int.repr 55882)) = Some memory_after ->
    eval_funcall function_entry2 ge memory_before
      (Internal UBS.f_random_u16) [] E0 memory_after
      (Vint (Int.repr 55882)).
Proof.
  intros ge memory_before memory_swapped memory_after seed_block
    Hsymbol Hload0 Hstore0 Hstore1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload2.
  cbn in Hload1, Hload2.
  eapply eval_funcall_internal.
  - eapply function_entry2_intro.
    + constructor.
    + constructor.
    + intros x y Hnone. inversion Hnone.
    + constructor.
    + reflexivity.
  - simpl fn_body. linked_exec_closed_stmt.
  - cbn. split; [ discriminate | cbn; reflexivity ].
  - cbn. reflexivity.
Qed.

(** The two generated versions emit the same scalar wrapper as well as the
    same [random_u16] leaf. *)
Theorem random_float_body_us_jp_identical :
  UBS.f_random_float = JBS.f_random_float.
Proof. reflexivity. Qed.

(** Execute the exact generated [random_float] body around one already-proved
    generated [random_u16] call.  In particular, the proof constructs the
    genuine [exec_Scall] node, evaluates the linked function-typed [Evar],
    resolves it with [Genv.find_funct], and then performs the generated casts
    and division.  The existential result is the value prescribed by
    CompCert's binary32/binary64 operators. *)
Theorem generated_random_float_executes_linked_random_u16 :
  forall (ge : Clight.genv) memory_before memory_after
      random_u16_block random_u16_result,
    Genv.find_symbol ge UBS._random_u16 = Some random_u16_block ->
    Genv.find_funct_ptr ge random_u16_block =
      Some (Internal UBS.f_random_u16) ->
    eval_funcall function_entry2 ge memory_before
      (Internal UBS.f_random_u16) [] E0 memory_after
      (Vint random_u16_result) ->
    exists result,
      eval_funcall function_entry2 ge memory_before
        (Internal UBS.f_random_float) [] E0 memory_after (Vsingle result).
Proof.
  intros ge memory_before memory_after random_u16_block random_u16_result
    Hsymbol Hfunction Hu16.
  eexists.
  eapply eval_funcall_internal.
  - eapply function_entry2_intro.
    + constructor.
    + constructor.
    + intros x y Hnone. inversion Hnone.
    + constructor.
    + reflexivity.
  - simpl fn_body.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Scall.
        -- cbn. reflexivity.
        -- eapply eval_linked_function_symbol.
           ++ reflexivity.
           ++ exact Hsymbol.
        -- constructor.
        -- eapply find_funct_at_zero_offset. exact Hfunction.
        -- cbn. reflexivity.
        -- exact Hu16.
      * eapply exec_Sset. linked_eval_closed_expr.
    + eapply exec_Sreturn_some. linked_eval_closed_expr.
  - cbn. split; [ discriminate | cbn; reflexivity ].
  - cbn. reflexivity.
Qed.

(** Two actual generated [random_float] invocations, each containing its own
    generated [random_u16] [Scall], advance a writable zero seed to 55882.
    This is the exact number of PRNG calls made by
    [obj_translate_xz_random]; this theorem deliberately does not yet claim
    that the surrounding object-field loads and stores have executed. *)
Theorem generated_two_random_float_calls_from_zero_in_any_genv :
  forall (ge : Clight.genv) memory_before seed_block random_u16_block,
    Genv.find_symbol ge UBS._gRandomSeed16 = Some seed_block ->
    Genv.find_symbol ge UBS._random_u16 = Some random_u16_block ->
    Genv.find_funct_ptr ge random_u16_block =
      Some (Internal UBS.f_random_u16) ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after_first memory_after_second result_first result_second,
      eval_funcall function_entry2 ge memory_before
        (Internal UBS.f_random_float) [] E0 memory_after_first
        (Vsingle result_first) /\
      eval_funcall function_entry2 ge memory_after_first
        (Internal UBS.f_random_float) [] E0 memory_after_second
        (Vsingle result_second) /\
      Mem.load Mint16unsigned memory_after_second seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.valid_access memory_after_second Mint16unsigned seed_block 0 Writable.
Proof.
  intros ge memory_before seed_block random_u16_block Hseed Hrandom_symbol
    Hrandom_function Hload0 Hwrite0.
  destruct (generated_random_u16_executes_in_any_genv_with_writable_seed
    ge memory_before seed_block Hseed Hload0 Hwrite0)
    as (memory_after_first & Hu16_first & Hload_first & Hwrite_first).
  destruct (generated_random_float_executes_linked_random_u16
    ge memory_before memory_after_first random_u16_block
      (Int.repr 57460) Hrandom_symbol Hrandom_function Hu16_first)
    as [result_first Hfloat_first].
  destruct (generated_random_u16_executes_from_57460_in_any_genv
    ge memory_after_first seed_block Hseed Hload_first Hwrite_first)
    as (memory_after_second & Hu16_second & Hload_second & Hwrite_second).
  destruct (generated_random_float_executes_linked_random_u16
    ge memory_after_first memory_after_second random_u16_block
      (Int.repr 55882) Hrandom_symbol Hrandom_function Hu16_second)
    as [result_second Hfloat_second].
  exists memory_after_first, memory_after_second, result_first, result_second.
  split; [exact Hfloat_first|].
  split; [exact Hfloat_second|].
  split; [exact Hload_second|exact Hwrite_second].
Qed.

(** The exact two-call execution is available in the actual US typed link;
    both the seed cell and callee block are obtained from that link. *)
Theorem generated_two_random_float_calls_in_us_typed_link :
  forall linked,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    exists seed_block,
      Genv.find_symbol (Clight.globalenv linked) UBS._gRandomSeed16 =
        Some seed_block /\
      forall memory_before,
        Mem.load Mint16unsigned memory_before seed_block 0 =
          Some (Vint Int.zero) ->
        Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
        exists memory_after_first memory_after_second
            result_first result_second,
          eval_funcall function_entry2 (Clight.globalenv linked) memory_before
            (Internal UBS.f_random_float) [] E0
            memory_after_first (Vsingle result_first) /\
          eval_funcall function_entry2 (Clight.globalenv linked)
            memory_after_first (Internal UBS.f_random_float) [] E0
            memory_after_second (Vsingle result_second) /\
          Mem.load Mint16unsigned memory_after_second seed_block 0 =
            Some (Vint (Int.repr 55882)) /\
          Mem.valid_access memory_after_second Mint16unsigned seed_block 0
            Writable.
Proof.
  intros linked Hlink.
  destruct (linked_right_resolves_symbol us_dust_typed_core
    us_dust_leaf_program linked UBS._gRandomSeed16
    (Gvar UBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - pose proof
      (us_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
      as [_ [_ [_ [_ [random_u16_block
        [Hrandom_symbol Hrandom_function]]]]]].
    exists seed_block. split; [exact Hseed|].
    intros memory_before Hload Hwrite.
    eapply generated_two_random_float_calls_from_zero_in_any_genv; eauto.
Qed.

(** JP emits the same two scalar function bodies, so the identical linked
    big-step is available in the JP typed link as well. *)
Theorem generated_two_random_float_calls_in_jp_typed_link :
  forall linked,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    exists seed_block,
      Genv.find_symbol (Clight.globalenv linked) JBS._gRandomSeed16 =
        Some seed_block /\
      forall memory_before,
        Mem.load Mint16unsigned memory_before seed_block 0 =
          Some (Vint Int.zero) ->
        Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
        exists memory_after_first memory_after_second
            result_first result_second,
          eval_funcall function_entry2 (Clight.globalenv linked) memory_before
            (Internal JBS.f_random_float) [] E0
            memory_after_first (Vsingle result_first) /\
          eval_funcall function_entry2 (Clight.globalenv linked)
            memory_after_first (Internal JBS.f_random_float) [] E0
            memory_after_second (Vsingle result_second) /\
          Mem.load Mint16unsigned memory_after_second seed_block 0 =
            Some (Vint (Int.repr 55882)) /\
          Mem.valid_access memory_after_second Mint16unsigned seed_block 0
            Writable.
Proof.
  intros linked Hlink.
  destruct (linked_right_resolves_symbol jp_dust_typed_core
    jp_dust_leaf_program linked JBS._gRandomSeed16
    (Gvar JBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - pose proof
      (jp_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
      as [_ [_ [_ [_ [random_u16_block
        [Hrandom_symbol Hrandom_function]]]]]].
    exists seed_block. split; [exact Hseed|].
    intros memory_before Hload Hwrite.
    rewrite <- random_float_body_us_jp_identical.
    rewrite <- random_u16_body_us_jp_identical in Hrandom_function.
    eapply generated_two_random_float_calls_from_zero_in_any_genv; eauto.
Qed.

Definition translated_coordinate
    (initial random_sample range : float32) : float32 :=
  Float32.add initial
    (Float32.sub (Float32.mul random_sample range)
      (Float32.mul range
        (Float32.of_bits (Int.repr 1056964608)))).

(** Frame facts exposed by the object-bearing execution.  They are derived
    from the six exact generated stores, and let a verified caller retain
    unrelated globals without postulating a hand-written callee semantics. *)
Definition preserves_loads_outside_two_blocks
    (memory_before memory_after : mem) (first second : block) : Prop :=
  forall chunk frame_block frame_offset value,
    frame_block <> first ->
    frame_block <> second ->
    Mem.load chunk memory_before frame_block frame_offset = Some value ->
    Mem.load chunk memory_after frame_block frame_offset = Some value.

Definition preserves_all_valid_accesses
    (memory_before memory_after : mem) : Prop :=
  forall chunk frame_block frame_offset permission,
    Mem.valid_access memory_before chunk frame_block frame_offset permission ->
    Mem.valid_access memory_after chunk frame_block frame_offset permission.

(** This is the first object-bearing linked big-step in the chain.  It uses a
    concrete memory image consisting of a writable seed cell and the exact
    generated Object X/Z cells at byte offsets 160 and 168.  The proof
    interleaves two real [random_float -> random_u16] calls with the two real
    generated object stores, rather than composing two isolated leaf calls. *)
Theorem generated_obj_translate_xz_random_executes_in_us_typed_link :
  forall linked memory_before seed_block random_float_block random_u16_block
      object_block x_before z_before range,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) UBS._gRandomSeed16 =
      Some seed_block ->
    Genv.find_symbol (Clight.globalenv linked) UBS._random_float =
      Some random_float_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal UBS.f_random_float) ->
    Genv.find_symbol (Clight.globalenv linked) UBS._random_u16 =
      Some random_u16_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal UBS.f_random_u16) ->
    object_block <> seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    Mem.load Mfloat32 memory_before object_block 160 =
      Some (Vsingle x_before) ->
    Mem.valid_access memory_before Mfloat32 object_block 160 Writable ->
    Mem.load Mfloat32 memory_before object_block 168 =
      Some (Vsingle z_before) ->
    Mem.valid_access memory_before Mfloat32 object_block 168 Writable ->
    exists memory_after random_x random_z,
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal UOH.f_obj_translate_xz_random)
        [Vptr object_block Ptrofs.zero; Vsingle range]
        E0 memory_after Vundef /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x range)) /\
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z range)) /\
      preserves_loads_outside_two_blocks memory_before memory_after
        seed_block object_block /\
      preserves_all_valid_accesses memory_before memory_after.
Proof.
  intros linked memory_before seed_block random_float_block random_u16_block
    object_block x_before z_before range Hlink Hseed Hfloat_symbol
    Hfloat_function Hu16_symbol Hu16_function Hobject_seed Hload_seed0
    Hwrite_seed0 Hload_x0 Hwrite_x0 Hload_z0 Hwrite_z0.

  (* First generated random_u16 store pair and its enclosing random_float. *)
  destruct (Mem.valid_access_store memory_before Mint16unsigned seed_block 0
    (Vint Int.zero) Hwrite_seed0) as [memory_swap1 Hstore_swap1].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
    Mint16unsigned seed_block 0 Writable Hwrite_seed0) as Hwrite_seed_swap1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
    Mfloat32 object_block 160 Writable Hwrite_x0) as Hwrite_x_swap1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
    Mfloat32 object_block 168 Writable Hwrite_z0) as Hwrite_z_swap1.
  destruct (Mem.valid_access_store memory_swap1 Mint16unsigned seed_block 0
    (Vint (Int.repr 57460)) Hwrite_seed_swap1)
    as [memory_random1 Hstore_random1].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
    Mint16unsigned seed_block 0 Writable Hwrite_seed_swap1)
    as Hwrite_seed_random1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
    Mfloat32 object_block 160 Writable Hwrite_x_swap1) as Hwrite_x_random1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
    Mfloat32 object_block 168 Writable Hwrite_z_swap1) as Hwrite_z_random1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_random1)
    as Hload_seed_random1.
  cbn in Hload_seed_random1.
  assert (Hload_x_random1 :
      Mem.load Mfloat32 memory_random1 object_block 160 =
        Some (Vsingle x_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random1).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap1).
      + exact Hload_x0.
      + left. exact Hobject_seed.
    - left. exact Hobject_seed. }
  assert (Hload_z_random1 :
      Mem.load Mfloat32 memory_random1 object_block 168 =
        Some (Vsingle z_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random1).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap1).
      + exact Hload_z0.
      + left. exact Hobject_seed.
    - left. exact Hobject_seed. }
  pose proof (generated_random_u16_zero_with_given_stores
    (Clight.globalenv linked) memory_before memory_swap1 memory_random1
    seed_block Hseed Hload_seed0 Hstore_swap1 Hstore_random1) as Hu16_first.
  destruct (generated_random_float_executes_linked_random_u16
    (Clight.globalenv linked) memory_before memory_random1 random_u16_block
    (Int.repr 57460) Hu16_symbol Hu16_function Hu16_first)
    as [random_x Hfloat_first].

  (* The generated X store is between the two RNG calls. *)
  destruct (Mem.valid_access_store memory_random1 Mfloat32 object_block 160
    (Vsingle (translated_coordinate x_before random_x range))
    Hwrite_x_random1) as [memory_x Hstore_x].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_x
    Mint16unsigned seed_block 0 Writable Hwrite_seed_random1)
    as Hwrite_seed_x.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_x
    Mfloat32 object_block 168 Writable Hwrite_z_random1) as Hwrite_z_x.
  assert (Hload_seed_x :
      Mem.load Mint16unsigned memory_x seed_block 0 =
        Some (Vint (Int.repr 57460))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_x).
    - exact Hload_seed_random1.
    - left. exact (not_eq_sym Hobject_seed). }
  assert (Hload_z_x :
      Mem.load Mfloat32 memory_x object_block 168 =
        Some (Vsingle z_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_x).
    - exact Hload_z_random1.
    - right. right.
      change (164 <= 168)%Z. lia. }

  (* Second generated random_u16 store pair and enclosing random_float. *)
  destruct (Mem.valid_access_store memory_x Mint16unsigned seed_block 0
    (Vint (Int.repr 29844)) Hwrite_seed_x)
    as [memory_swap2 Hstore_swap2].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap2
    Mint16unsigned seed_block 0 Writable Hwrite_seed_x) as Hwrite_seed_swap2.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap2
    Mfloat32 object_block 168 Writable Hwrite_z_x) as Hwrite_z_swap2.
  destruct (Mem.valid_access_store memory_swap2 Mint16unsigned seed_block 0
    (Vint (Int.repr 55882)) Hwrite_seed_swap2)
    as [memory_random2 Hstore_random2].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random2
    Mfloat32 object_block 168 Writable Hwrite_z_swap2) as Hwrite_z_random2.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_random2)
    as Hload_seed_random2.
  cbn in Hload_seed_random2.
  assert (Hload_z_random2 :
      Mem.load Mfloat32 memory_random2 object_block 168 =
        Some (Vsingle z_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random2).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap2).
      + exact Hload_z_x.
      + left. exact Hobject_seed.
    - left. exact Hobject_seed. }
  pose proof (generated_random_u16_57460_with_given_stores
    (Clight.globalenv linked) memory_x memory_swap2 memory_random2 seed_block
    Hseed Hload_seed_x Hstore_swap2 Hstore_random2) as Hu16_second.
  destruct (generated_random_float_executes_linked_random_u16
    (Clight.globalenv linked) memory_x memory_random2 random_u16_block
    (Int.repr 55882) Hu16_symbol Hu16_function Hu16_second)
    as [random_z Hfloat_second].

  (* The final generated Z store. *)
  destruct (Mem.valid_access_store memory_random2 Mfloat32 object_block 168
    (Vsingle (translated_coordinate z_before random_z range))
    Hwrite_z_random2) as [memory_after Hstore_z].
  assert (Hload_seed_after :
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_z).
    - exact Hload_seed_random2.
    - left. exact (not_eq_sym Hobject_seed). }
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_z) as Hload_z_after.
  cbn in Hload_z_after.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_x) as Hload_x_store.
  cbn in Hload_x_store.
  assert (Hload_x_after :
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x range))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_z).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random2).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap2).
        -- exact Hload_x_store.
        -- left. exact Hobject_seed.
      + left. exact Hobject_seed.
    - right. left.
      change (164 <= 168)%Z. lia. }

  assert (Hframe :
      preserves_loads_outside_two_blocks memory_before memory_after
        seed_block object_block).
  { unfold preserves_loads_outside_two_blocks.
    intros chunk frame_block frame_offset value Hframe_seed Hframe_object
      Hload_frame.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_z).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random2).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap2).
        * rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_x).
          -- rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random1).
             ++ rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap1).
                ** exact Hload_frame.
                ** left. exact Hframe_seed.
             ++ left. exact Hframe_seed.
          -- left. exact Hframe_object.
        * left. exact Hframe_seed.
      + left. exact Hframe_seed.
    - left. exact Hframe_object. }
  assert (Hvalid :
      preserves_all_valid_accesses memory_before memory_after).
  { unfold preserves_all_valid_accesses.
    intros chunk frame_block frame_offset permission Haccess0.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
      chunk frame_block frame_offset permission Haccess0) as Haccess1.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
      chunk frame_block frame_offset permission Haccess1) as Haccess2.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_x
      chunk frame_block frame_offset permission Haccess2) as Haccess3.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap2
      chunk frame_block frame_offset permission Haccess3) as Haccess4.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random2
      chunk frame_block frame_offset permission Haccess4) as Haccess5.
    exact (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_z
      chunk frame_block frame_offset permission Haccess5). }

  assert (Hexec :
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal UOH.f_obj_translate_xz_random)
        [Vptr object_block Ptrofs.zero; Vsingle range]
        E0 memory_after Vundef).
  { eapply eval_funcall_internal.
  - eapply function_entry2_intro.
    + constructor.
    + cbn.
      apply Coqlib.list_norepet_cons.
      * cbn. intros [Hequal | Hfalse].
        -- vm_compute in Hequal. discriminate.
        -- contradiction.
      * apply Coqlib.list_norepet_cons.
        -- cbn. tauto.
        -- apply Coqlib.list_norepet_nil.
    + red.
      intros parameter temporary Hparameter Htemporary Hequal.
      subst temporary.
      cbn in Hparameter, Htemporary.
      destruct Hparameter as [Hparameter | [Hparameter | Hnone]];
        try contradiction;
      destruct Htemporary as
        [Htemporary | [Htemporary | [Htemporary | [Htemporary | Hnone]]]];
        try contradiction;
      subst parameter;
      vm_compute in Htemporary;
      discriminate.
    + constructor.
    + cbn. reflexivity.
  - rewrite us_obj_translate_xz_random_body_exact.
    unfold us_obj_translate_xz_random_body.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Scall.
        -- cbn. reflexivity.
        -- eapply eval_linked_function_symbol.
           ++ reflexivity.
           ++ exact Hfloat_symbol.
        -- constructor.
        -- eapply find_funct_at_zero_offset. exact Hfloat_function.
        -- cbn. reflexivity.
         -- exact Hfloat_first.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_us_object_x_value; [exact Hlink | cbn; reflexivity |
             exact Hload_x_random1].
        -- eapply exec_Sassign.
           ++ eapply eval_us_object_x_lvalue;
                [exact Hlink | cbn; reflexivity].
           ++ unfold us_translated_coordinate_expr, translated_coordinate.
              linked_eval_closed_expr.
           ++ cbn. reflexivity.
           ++ eapply assign_us_object_x_value. exact Hstore_x.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Scall.
        -- cbn. reflexivity.
        -- eapply eval_linked_function_symbol.
           ++ reflexivity.
           ++ exact Hfloat_symbol.
        -- constructor.
        -- eapply find_funct_at_zero_offset. exact Hfloat_function.
        -- cbn. reflexivity.
         -- exact Hfloat_second.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_us_object_z_value; [exact Hlink | cbn; reflexivity |
             exact Hload_z_random2].
        -- eapply exec_Sassign.
           ++ eapply eval_us_object_z_lvalue;
                [exact Hlink | cbn; reflexivity].
           ++ unfold us_translated_coordinate_expr, translated_coordinate.
              linked_eval_closed_expr.
           ++ cbn. reflexivity.
           ++ eapply assign_us_object_z_value. exact Hstore_z.
  - cbn. reflexivity.
  - cbn. reflexivity. }
  exists memory_after, random_x, random_z.
  split; [exact Hexec|].
  split; [exact Hload_seed_after|].
  split; [exact Hload_x_after|].
  split; [exact Hload_z_after|].
  split; [exact Hframe|exact Hvalid].
Qed.

Definition us_obj_translate_memory_image
    (memory : mem) (seed_block object_block : block)
    (x_value z_value : float32) : Prop :=
  object_block <> seed_block /\
  Mem.load Mint16unsigned memory seed_block 0 = Some (Vint Int.zero) /\
  Mem.valid_access memory Mint16unsigned seed_block 0 Writable /\
  Mem.load Mfloat32 memory object_block 160 = Some (Vsingle x_value) /\
  Mem.valid_access memory Mfloat32 object_block 160 Writable /\
  Mem.load Mfloat32 memory object_block 168 = Some (Vsingle z_value) /\
  Mem.valid_access memory Mfloat32 object_block 168 Writable.

(** Capstone for the genuinely executable object-bearing frontier.  The
    object function itself is resolved in the link, and every memory image
    satisfying the explicit seed/X/Z cells has an actual generated-Clight
    [eval_funcall] whose two nested RNG calls finish at seed 55882. *)
Definition us_linked_obj_translate_execution_claim : Prop :=
  exists linked seed_block translate_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) UBS._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked)
      UOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal UOH.f_obj_translate_xz_random) /\
    forall memory_before object_block x_before z_before range,
      us_obj_translate_memory_image memory_before seed_block object_block
        x_before z_before ->
      exists memory_after random_x random_z,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal UOH.f_obj_translate_xz_random)
          [Vptr object_block Ptrofs.zero; Vsingle range]
          E0 memory_after Vundef /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 55882)) /\
        Mem.load Mfloat32 memory_after object_block 160 =
          Some (Vsingle (translated_coordinate x_before random_x range)) /\
        Mem.load Mfloat32 memory_after object_block 168 =
          Some (Vsingle (translated_coordinate z_before random_z range)).

Theorem checked_us_linked_obj_translate_execution :
  us_linked_obj_translate_execution_claim.
Proof.
  destruct us_dust_typed_link_exists as [linked Hlink].
  destruct (linked_right_resolves_symbol us_dust_typed_core
    us_dust_leaf_program linked UBS._gRandomSeed16
    (Gvar UBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - destruct (us_typed_link_resolves_obj_translate_xz_random linked Hlink)
      as [translate_block [Htranslate_symbol Htranslate_function]].
    pose proof
      (us_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
      as [_ [_ [_ [[random_float_block
        [Hfloat_symbol Hfloat_function]]
        [random_u16_block [Hu16_symbol Hu16_function]]]]]].
    exists linked, seed_block, translate_block.
    repeat split; try assumption.
    intros memory_before object_block x_before z_before range Hmemory.
    destruct Hmemory as
      (Hobject_seed & Hload_seed & Hwrite_seed & Hload_x & Hwrite_x &
       Hload_z & Hwrite_z).
    destruct (generated_obj_translate_xz_random_executes_in_us_typed_link
      linked memory_before seed_block random_float_block random_u16_block
      object_block x_before z_before range Hlink Hseed Hfloat_symbol
      Hfloat_function Hu16_symbol Hu16_function Hobject_seed Hload_seed
      Hwrite_seed Hload_x Hwrite_x Hload_z Hwrite_z)
      as (memory_after & random_x & random_z & Hexec & Hseed_after &
          Hx_after & Hz_after & _ & _).
    exists memory_after, random_x, random_z.
    split; [exact Hexec|].
    split; [exact Hseed_after|].
    split; [exact Hx_after|exact Hz_after].
Qed.

Theorem generated_random_u16_executes_in_us_typed_link :
  forall linked memory_before seed_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) UBS._gRandomSeed16 =
      Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr 57460)) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 57460)).
Proof.
  intros linked memory_before seed_block _ Hsymbol Hload Hwrite.
  exact (generated_random_u16_executes_in_any_genv
    (Clight.globalenv linked) memory_before seed_block
    Hsymbol Hload Hwrite).
Qed.

Theorem generated_random_u16_executes_in_jp_typed_link :
  forall linked memory_before seed_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) JBS._gRandomSeed16 =
      Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal JBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr 57460)) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 57460)).
Proof.
  intros linked memory_before seed_block _ Hsymbol Hload Hwrite.
  rewrite <- random_u16_body_us_jp_identical.
  exact (generated_random_u16_executes_in_any_genv
    (Clight.globalenv linked) memory_before seed_block
    Hsymbol Hload Hwrite).
Qed.

(** This capstone says exactly what has become executable: an official link
    exists with the generated composite environment on its left, the selected
    behavior-command engine and PRNG leaf resolve in that linked [genv], the
    seed symbol is supplied by the link, and the exact PRNG leaf takes a real
    big-step there.  The broader five-function certificate above separately
    resolves both puff natives and [random_float].  This theorem intentionally
    does not claim that
    [cur_obj_update]'s indirect behavior-command loop or object allocation has
    executed; those require the command table, remaining globals/callees, and
    a concrete object-list memory image. *)
Definition typed_linked_execution_frontier_claim : Prop :=
  exists linked seed_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) UBS._gRandomSeed16 =
      Some seed_block /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) UBS._cur_obj_update =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBS.f_cur_obj_update)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) UBS._random_u16 =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal UBS.f_random_u16)) /\
    (forall memory_before,
      Mem.load Mint16unsigned memory_before seed_block 0 =
        Some (Vint Int.zero) ->
      Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
      exists memory_after,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal UBS.f_random_u16) [] E0 memory_after
          (Vint (Int.repr 57460)) /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 57460))).

Theorem checked_typed_linked_execution_frontier :
  typed_linked_execution_frontier_claim.
Proof.
  destruct us_dust_typed_link_exists as [linked Hlink].
  destruct (linked_right_resolves_symbol us_dust_typed_core
    us_dust_leaf_program linked UBS._gRandomSeed16
    (Gvar UBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - exists linked, seed_block. split; [exact Hlink|].
    split; [exact Hseed|].
  pose proof
    (us_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
    as [Hcur [_ [_ [_ Hrandom]]]].
  split; [exact Hcur|].
  split; [exact Hrandom|].
  intros memory_before Hload Hwrite.
  exact (generated_random_u16_executes_in_us_typed_link linked memory_before
    seed_block Hlink Hseed Hload Hwrite).
Qed.

Definition jp_typed_linked_execution_frontier_claim : Prop :=
  exists linked seed_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) JBS._gRandomSeed16 =
      Some seed_block /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) JBS._cur_obj_update =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBS.f_cur_obj_update)) /\
    (exists block,
      Genv.find_symbol (Clight.globalenv linked) JBS._random_u16 =
        Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal JBS.f_random_u16)) /\
    (forall memory_before,
      Mem.load Mint16unsigned memory_before seed_block 0 =
        Some (Vint Int.zero) ->
      Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
      exists memory_after,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal JBS.f_random_u16) [] E0 memory_after
          (Vint (Int.repr 57460)) /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 57460))).

Theorem checked_jp_typed_linked_execution_frontier :
  jp_typed_linked_execution_frontier_claim.
Proof.
  destruct jp_dust_typed_link_exists as [linked Hlink].
  destruct (linked_right_resolves_symbol jp_dust_typed_core
    jp_dust_leaf_program linked JBS._gRandomSeed16
    (Gvar JBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - exists linked, seed_block. split; [exact Hlink|].
    split; [exact Hseed|].
  pose proof
    (jp_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
    as [Hcur [_ [_ [_ Hrandom]]]].
  split; [exact Hcur|].
  split; [exact Hrandom|].
  intros memory_before Hload Hwrite.
  exact (generated_random_u16_executes_in_jp_typed_link linked memory_before
    seed_block Hlink Hseed Hload Hwrite).
Qed.

Definition typed_linked_execution_frontier_us_jp_claim : Prop :=
  typed_linked_execution_frontier_claim /\
  jp_typed_linked_execution_frontier_claim.

Theorem checked_typed_linked_execution_frontier_us_jp :
  typed_linked_execution_frontier_us_jp_claim.
Proof.
  split.
  - exact checked_typed_linked_execution_frontier.
  - exact checked_jp_typed_linked_execution_frontier.
Qed.
