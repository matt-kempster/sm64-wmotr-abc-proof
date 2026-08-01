From Coq Require Import List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Errors Maps.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms.

Import ListNotations.

(** This file separates two phenomena that the residual-composite count in
    [NormalizedClightPrograms] deliberately groups together:

    - same C tag names whose generated definitions differ only because their
      member types mention translation-unit-local anonymous tags; and
    - a genuine collision between two unrelated anonymous tags.

    The checks below concern physical layout only.  They are not an execution
    simulation and do not turn the normalized slice into retail semantics. *)

Definition struct_or_union_eqb (left right : struct_or_union) : bool :=
  match left, right with
  | Struct, Struct | Union, Union => true
  | _, _ => false
  end.

Definition bitfield_eqb (left right : bitfield) : bool :=
  match left, right with
  | Full, Full => true
  | Bits lsz lsg lpos lwidth, Bits rsz rsg rpos rwidth =>
      if intsize_eq lsz rsz then
        if signedness_eq lsg rsg then
          andb (Z.eqb lpos rpos) (Z.eqb lwidth rwidth)
        else false
      else false
  | _, _ => false
  end.

Definition mode_eqb (left right : mode) : bool :=
  match left, right with
  | By_value lchunk, By_value rchunk =>
      if chunk_eq lchunk rchunk then true else false
  | By_reference, By_reference
  | By_copy, By_copy
  | By_nothing, By_nothing => true
  | _, _ => false
  end.

Definition field_layout_result_eqb
    (left right : res (Z * bitfield)) : bool :=
  match left, right with
  | OK (loffset, lbits), OK (roffset, rbits) =>
      andb (Z.eqb loffset roffset) (bitfield_eqb lbits rbits)
  (** Two failed layout queries are not evidence of compatible storage. *)
  | Error _, Error _ => false
  | _, _ => false
  end.

Definition member_storage_eqb
    (left_env right_env : composite_env)
    (left_members right_members : members)
    (left right : member) : bool :=
  andb (if peq (name_member left) (name_member right) then true else false)
  (andb
    (field_layout_result_eqb
      (field_offset left_env (name_member left) left_members)
      (field_offset right_env (name_member right) right_members))
  (andb
    (Z.eqb (sizeof left_env (type_member left))
           (sizeof right_env (type_member right)))
  (andb
    (Z.eqb (alignof left_env (type_member left))
           (alignof right_env (type_member right)))
  (andb
    (mode_eqb (access_mode (type_member left))
              (access_mode (type_member right)))
    (Bool.eqb (type_is_volatile (type_member left))
              (type_is_volatile (type_member right))))))).

Fixpoint members_storage_eqb
    (left_env right_env : composite_env)
    (all_left all_right left right : members) : bool :=
  match left, right with
  | [], [] => true
  | left_member :: left_rest, right_member :: right_rest =>
      andb (member_storage_eqb left_env right_env all_left all_right
               left_member right_member)
        (members_storage_eqb left_env right_env all_left all_right
           left_rest right_rest)
  | _, _ => false
  end.

Definition composite_storage_eqb
    (left_env right_env : composite_env)
    (left right : composite) : bool :=
  andb (struct_or_union_eqb (co_su left) (co_su right))
  (andb (attr_eq (co_attr left) (co_attr right))
  (andb (Z.eqb (co_sizeof left) (co_sizeof right))
  (andb (Z.eqb (co_alignof left) (co_alignof right))
    (members_storage_eqb left_env right_env
      (co_members left) (co_members right)
      (co_members left) (co_members right))))).

Definition composite_env_tag_storage_compatible
    (selected : composite_env) (id : ident)
    (source : composite_env) : bool :=
  match PTree.get id source with
  | None => true
  | Some source_composite =>
      match PTree.get id selected with
      | Some selected_composite =>
          composite_storage_eqb
            source selected
            source_composite selected_composite
      | None => false
      end
  end.

Definition program_tag_storage_compatible
    (selected : Clight.program) (id : ident)
    (source : Clight.program) : bool :=
  composite_env_tag_storage_compatible
    (prog_comp_env selected) id (prog_comp_env source).

Definition all_programs_tag_storage_compatible
    (selected : composite_env) (id : ident)
    (environments : list composite_env) : bool :=
  forallb (composite_env_tag_storage_compatible selected id) environments.

(** Composite-only audits use these explicit projections.  Mapping over the
    [nlist Clight.program] values caused Coq's VM compiler to retain unrelated
    function bodies from all 38 units. *)
Definition us_unit_composite_environments : list composite_env :=
  [prog_comp_env us_game_init.prog;
   prog_comp_env us_mario.prog;
   prog_comp_env us_mario_actions_airborne.prog;
   prog_comp_env us_mario_actions_automatic.prog;
   prog_comp_env us_mario_actions_cutscene.prog;
   prog_comp_env us_mario_actions_moving.prog;
   prog_comp_env us_mario_actions_object.prog;
   prog_comp_env us_mario_actions_stationary.prog;
   prog_comp_env us_mario_actions_submerged.prog;
   prog_comp_env us_mario_step.prog;
   prog_comp_env us_interaction.prog;
   prog_comp_env us_save_file.prog;
   prog_comp_env us_object_collision.prog;
   prog_comp_env us_object_list_processor.prog;
   prog_comp_env us_behavior_script.prog;
   prog_comp_env us_level_script.prog;
   prog_comp_env us_graph_node.prog;
   prog_comp_env us_rendering_graph_node.prog;
   prog_comp_env us_spawn_object.prog;
   prog_comp_env us_object_helpers.prog;
   prog_comp_env us_debug.prog;
   prog_comp_env us_memory.prog;
   prog_comp_env us_mario_misc.prog;
   prog_comp_env us_obj_behaviors.prog;
   prog_comp_env us_obj_behaviors_2.prog;
   prog_comp_env us_behavior_actions.prog;
   prog_comp_env us_behavior_data.prog;
   prog_comp_env us_area.prog;
   prog_comp_env us_level_update.prog;
   prog_comp_env us_platform_displacement.prog;
   prog_comp_env us_math_util.prog;
   prog_comp_env us_surface_collision.prog;
   prog_comp_env us_surface_load.prog;
   prog_comp_env us_macro_special_objects.prog;
   prog_comp_env us_ssl_script.prog;
   prog_comp_env us_ssl_area1_macro.prog;
   prog_comp_env us_ssl_area2_macro.prog;
   prog_comp_env us_ssl_collision.prog].

Definition jp_unit_composite_environments : list composite_env :=
  [prog_comp_env jp_game_init.prog;
   prog_comp_env jp_mario.prog;
   prog_comp_env jp_mario_actions_airborne.prog;
   prog_comp_env jp_mario_actions_automatic.prog;
   prog_comp_env jp_mario_actions_cutscene.prog;
   prog_comp_env jp_mario_actions_moving.prog;
   prog_comp_env jp_mario_actions_object.prog;
   prog_comp_env jp_mario_actions_stationary.prog;
   prog_comp_env jp_mario_actions_submerged.prog;
   prog_comp_env jp_mario_step.prog;
   prog_comp_env jp_interaction.prog;
   prog_comp_env jp_save_file.prog;
   prog_comp_env jp_object_collision.prog;
   prog_comp_env jp_object_list_processor.prog;
   prog_comp_env jp_behavior_script.prog;
   prog_comp_env jp_level_script.prog;
   prog_comp_env jp_graph_node.prog;
   prog_comp_env jp_rendering_graph_node.prog;
   prog_comp_env jp_spawn_object.prog;
   prog_comp_env jp_object_helpers.prog;
   prog_comp_env jp_debug.prog;
   prog_comp_env jp_memory.prog;
   prog_comp_env jp_mario_misc.prog;
   prog_comp_env jp_obj_behaviors.prog;
   prog_comp_env jp_obj_behaviors_2.prog;
   prog_comp_env jp_behavior_actions.prog;
   prog_comp_env jp_behavior_data.prog;
   prog_comp_env jp_area.prog;
   prog_comp_env jp_level_update.prog;
   prog_comp_env jp_platform_displacement.prog;
   prog_comp_env jp_math_util.prog;
   prog_comp_env jp_surface_collision.prog;
   prog_comp_env jp_surface_load.prog;
   prog_comp_env jp_macro_special_objects.prog;
   prog_comp_env jp_ssl_script.prog;
   prog_comp_env jp_ssl_area1_macro.prog;
   prog_comp_env jp_ssl_area2_macro.prog;
   prog_comp_env jp_ssl_collision.prog].

(** Projecting [prog_comp_env] from the normalized program forces reduction of
    [make_program], including all 4,000+ body-carrying global definitions.
    Composite audits instead rebuild exactly the same environment from the
    already selected composite definitions alone. *)
Definition normalized_composite_env
    (definitions : list composite_definition) : composite_env :=
  match build_composite_env definitions with
  | OK environment => environment
  | Error _ => PTree.empty _
  end.

Definition us_normalized_composite_env : composite_env :=
  normalized_composite_env us_normalized_composites.

Definition jp_normalized_composite_env : composite_env :=
  normalized_composite_env jp_normalized_composites.

Lemma normalized_composite_env_matches_program_types :
  forall composites (program : Clight.program),
    prog_types program = composites ->
    normalized_composite_env composites = prog_comp_env program.
Proof.
  intros composites program Htypes. subst composites.
  unfold normalized_composite_env.
  rewrite (prog_comp_env_eq program). reflexivity.
Qed.

Theorem us_lightweight_normalized_composite_env_exact_if_types_exact :
  prog_types us_normalized_semantic_slice = us_normalized_composites ->
  us_normalized_composite_env =
    prog_comp_env us_normalized_semantic_slice.
Proof.
  unfold us_normalized_composite_env. intro Htypes.
  now apply normalized_composite_env_matches_program_types.
Qed.

Theorem jp_lightweight_normalized_composite_env_exact_if_types_exact :
  prog_types jp_normalized_semantic_slice = jp_normalized_composites ->
  jp_normalized_composite_env =
    prog_comp_env jp_normalized_semantic_slice.
Proof.
  unfold jp_normalized_composite_env. intro Htypes.
  now apply normalized_composite_env_matches_program_types.
Qed.

Definition us_named_residual_composite_tags : list ident :=
  [us_behavior_actions._Controller;
   us_behavior_actions._FnGraphNode;
   us_behavior_actions._GraphNodeCamera;
   us_behavior_actions._Object;
   us_behavior_actions._Surface].

Definition jp_named_residual_composite_tags : list ident :=
  [jp_behavior_actions._Controller;
   jp_behavior_actions._FnGraphNode;
   jp_behavior_actions._GraphNodeCamera;
   jp_level_update._Object;
   jp_behavior_actions._Surface].

Definition all_named_tags_storage_compatible
    (selected : composite_env) (environments : list composite_env)
    (ids : list ident) : bool :=
  forallb (fun id =>
    all_programs_tag_storage_compatible selected id environments) ids.

(** Declaration cleanup is a separate issue from composite layout.  All
    generated Gvar declarations except [gDisplayListHead] are accepted by the
    exact-or-incomplete-array rule in [NormalizedClightPrograms]. *)

Definition mismatch_is_allowed (allowed : list ident)
    (mismatch : option ident) : bool :=
  match mismatch with
  | None => true
  | Some id => existsb (fun candidate => Pos.eqb id candidate) allowed
  end.

Definition all_gvar_declarations_compatible_except
    (selected : global_definition_map) (allowed : list ident)
    (source : list (ident * globdef Clight.fundef type)) : bool :=
  forallb (fun entry =>
    mismatch_is_allowed allowed (residual_gvar_type_mismatch selected entry))
    source.

Definition type_storage_eqb
    (left_env right_env : composite_env) (left right : type) : bool :=
  andb (Z.eqb (sizeof left_env left) (sizeof right_env right))
  (andb (Z.eqb (alignof left_env left) (alignof right_env right))
  (andb (mode_eqb (access_mode left) (access_mode right))
        (Bool.eqb (type_is_volatile left) (type_is_volatile right)))).

Theorem us_gdisplaylisthead_pointer_declarations_are_storage_equivalent_checked :
  type_storage_eqb
    (prog_comp_env us_area.prog) (prog_comp_env us_game_init.prog)
    (gvar_info us_area.v_gDisplayListHead)
    (gvar_info us_game_init.v_gDisplayListHead) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_gdisplaylisthead_pointer_declarations_are_storage_equivalent_checked :
  type_storage_eqb
    (prog_comp_env jp_area.prog) (prog_comp_env jp_game_init.prog)
    (gvar_info jp_area.v_gDisplayListHead)
    (gvar_info jp_game_init.v_gDisplayListHead) = true.
Proof. vm_compute. reflexivity. Qed.

Definition fundef_call_signature (definition : Clight.fundef) : signature :=
  match definition with
  | Internal function_value =>
      signature_of_type (map snd (fn_params function_value))
        (fn_return function_value) (fn_callconv function_value)
  | External _ parameters result convention =>
      signature_of_type parameters result convention
  end.

Definition fundef_call_signature_eqb
    (left right : Clight.fundef) : bool :=
  if signature_eq (fundef_call_signature left) (fundef_call_signature right)
  then true else false.

Definition function_declaration_abi_compatible
    (selected : global_definition_map)
    (entry : ident * globdef Clight.fundef type) : bool :=
  match entry with
  | (id, Gfun declaration) =>
      match PTree.get id selected with
      | Some (Gfun definition) =>
          fundef_call_signature_eqb declaration definition
      | _ => false
      end
  | _ => true
  end.

Definition all_function_declarations_abi_compatible
    (selected : global_definition_map)
    (source : list (ident * globdef Clight.fundef type)) : bool :=
  forallb (function_declaration_abi_compatible selected) source.

(** The propositions below separate composite layout from function/global
    declaration compatibility for each version.  The generated units are
    large; compiling both traversals in one module retained several gigabytes
    of duplicate VM bytecode.  Independent receipt modules evaluate each
    proposition once, and lightweight aggregators expose named projections
    without weakening any claim. *)

Definition us_expected_residual_composite_mismatches : list ident :=
  [us_game_init._Controller;
   us_behavior_actions._FnGraphNode;
   us_behavior_actions._GraphNodeCamera;
   us_game_init.__538;
   us_behavior_actions._Object;
   us_behavior_actions._Surface].

Definition jp_expected_residual_composite_mismatches : list ident :=
  [jp_behavior_actions._Controller;
   jp_behavior_actions._FnGraphNode;
   jp_behavior_actions._GraphNodeCamera;
   jp_behavior_actions._Object;
   jp_behavior_actions._Surface].

Definition us_expected_residual_function_signature_mismatches : list ident :=
  [us_game_init._clear_viewport;
   us_game_init._make_viewport_clip_rect;
   us_rendering_graph_node._geo_process_root].

Definition jp_expected_residual_function_signature_mismatches : list ident :=
  [jp_game_init._clear_viewport;
   jp_game_init._make_viewport_clip_rect;
   jp_rendering_graph_node._geo_process_root].

Definition USCompositeCompatibilityAudit : Prop :=
  us_residual_composite_mismatches =
    us_expected_residual_composite_mismatches /\
  all_named_tags_storage_compatible
    us_normalized_composite_env us_unit_composite_environments
    us_named_residual_composite_tags = true.

Definition USDeclarationCompatibilityAudit : Prop :=
  let source_definitions := unit_global_definitions us_units in
  let selected_definitions :=
    normalize_global_definition_map source_definitions in
  all_gvar_declarations_compatible_except
    selected_definitions [us_game_init._gDisplayListHead]
    source_definitions = true /\
  all_function_declarations_abi_compatible
    selected_definitions source_definitions = true /\
  residual_function_signature_mismatches
    source_definitions selected_definitions =
    us_expected_residual_function_signature_mismatches.

Definition USCoreDeclarationCompositeAudit : Prop :=
  USCompositeCompatibilityAudit /\ USDeclarationCompatibilityAudit.

Definition JPCompositeCompatibilityAudit : Prop :=
  jp_residual_composite_mismatches =
    jp_expected_residual_composite_mismatches /\
  all_named_tags_storage_compatible
    jp_normalized_composite_env jp_unit_composite_environments
    jp_named_residual_composite_tags = true.

Definition JPDeclarationCompatibilityAudit : Prop :=
  let source_definitions := unit_global_definitions jp_units in
  let selected_definitions :=
    normalize_global_definition_map source_definitions in
  all_gvar_declarations_compatible_except
    selected_definitions [jp_game_init._gDisplayListHead]
    source_definitions = true /\
  all_function_declarations_abi_compatible
    selected_definitions source_definitions = true /\
  residual_function_signature_mismatches
    source_definitions selected_definitions =
    jp_expected_residual_function_signature_mismatches.

Definition JPCoreDeclarationCompositeAudit : Prop :=
  JPCompositeCompatibilityAudit /\ JPDeclarationCompatibilityAudit.

(** The kernel-checked inhabitants live in the versioned composite and
    declaration certificate modules.  [USClightLinkRefinementCertificates]
    and [JPClightLinkRefinementCertificates] aggregate their named projections.
    The definitions here remain the single source of the audited propositions. *)

(** [us_area.__538] and [us_game_init.__538] elaborate to the same atom,
    but denote different source-level anonymous structures.  The former is
    the viewport payload nested in [us_area.__540]; the latter is an RDP
    command payload nested in the selected Gfx union. *)

Definition composite_member_names (value : composite) : list ident :=
  map name_member (co_members value).

Definition lookup_composite
    (program : Clight.program) (id : ident) : option composite :=
  PTree.get id (prog_comp_env program).

Definition lookup_composite_env
    (environment : composite_env) (id : ident) : option composite :=
  PTree.get id environment.

Theorem us_538_atoms_collide_checked :
  us_area.__538 = us_game_init.__538.
Proof. reflexivity. Qed.

Definition composite_size_and_alignment
    (value : composite) : Z * Z :=
  (co_sizeof value, co_alignof value).

(** A small executable observation of a rebuilt composite environment.  It
    deliberately returns only one tag's layout, rather than quoting the whole
    [PTree] into a proof term. *)
Definition built_composite_tag_layout
    (definitions : list composite_definition) (tag : ident)
    : option (Z * Z) :=
  match build_composite_env definitions with
  | OK environment =>
      option_map composite_size_and_alignment (environment ! tag)
  | Error _ => None
  end.

Lemma built_composite_tag_layout_sound :
  forall definitions tag size alignment,
    built_composite_tag_layout definitions tag = Some (size, alignment) ->
    exists environment value,
      build_composite_env definitions = OK environment /\
      environment ! tag = Some value /\
      co_sizeof value = size /\
      co_alignof value = alignment.
Proof.
  intros definitions tag size alignment Hlayout.
  unfold built_composite_tag_layout in Hlayout.
  destruct (build_composite_env definitions) as [environment | message]
    eqn:Hbuild; [| discriminate].
  destruct (environment ! tag) as [value |] eqn:Hget; [| discriminate].
  unfold composite_size_and_alignment in Hlayout.
  inversion Hlayout; subst. eauto 8.
Qed.

Definition init_data_size_bytes (initial : init_data) : Z :=
  match initial with
  | Init_int8 _ => 1
  | Init_int16 _ => 2
  | Init_int32 _ | Init_float32 _ => 4
  | Init_int64 _ | Init_float64 _ => 8
  | Init_addrof _ _ => if Archi.ptr64 then 8 else 4
  | Init_space bytes => bytes
  end.

Definition initializer_size_bytes (initial : list init_data) : Z :=
  fold_right (fun datum total => init_data_size_bytes datum + total) 0 initial.

Fixpoint ident_list_eqb (left right : list ident) : bool :=
  match left, right with
  | [], [] => true
  | left_id :: left_rest, right_id :: right_rest =>
      andb (Pos.eqb left_id right_id)
           (ident_list_eqb left_rest right_rest)
  | _, _ => false
  end.

Definition program_tag_has_member_names
    (id : ident) (expected : list ident) (program : Clight.program) : bool :=
  match lookup_composite program id with
  | Some value => ident_list_eqb (composite_member_names value) expected
  | None => false
  end.

Definition composite_env_tag_has_member_names
    (id : ident) (expected : list ident) (environment : composite_env) : bool :=
  match PTree.get id environment with
  | Some value => ident_list_eqb (composite_member_names value) expected
  | None => false
  end.

Fixpoint enumerate_from {A : Type} (index : nat) (values : list A)
    : list (nat * A) :=
  match values with
  | [] => []
  | value :: rest => (index, value) :: enumerate_from (S index) rest
  end.

Definition us_viewport_538_unit_indices : list nat :=
  map fst (filter
    (fun indexed => composite_env_tag_has_member_names us_area.__538
      [us_area._vscale; us_area._vtrans] (snd indexed))
    (enumerate_from 0 us_unit_composite_environments)).

Definition USViewportCollisionAudit : Prop :=
  let area_env := prog_comp_env us_area.prog in
  let game_init_env := prog_comp_env us_game_init.prog in
  let cutscene_env := prog_comp_env us_mario_actions_cutscene.prog in
  let normalized_env := us_normalized_composite_env in
  (option_map composite_member_names
    (lookup_composite_env area_env us_area.__538) =
      Some [us_area._vscale; us_area._vtrans] /\
   option_map composite_member_names
    (lookup_composite_env game_init_env us_game_init.__538) =
      Some [us_game_init._cmd; us_game_init._sl; us_game_init._tl;
            us_game_init._pad; us_game_init._tile; us_game_init._sh;
            us_game_init._th]) /\
  (option_map composite_size_and_alignment
    (lookup_composite_env area_env us_area.__538) = Some (16, 2) /\
   option_map composite_size_and_alignment
    (lookup_composite_env game_init_env us_game_init.__538) = Some (8, 4) /\
   composite_env_tag_storage_compatible
    normalized_env us_area.__538 area_env = false) /\
  option_map composite_member_names
    (lookup_composite_env normalized_env us_area.__538) =
      Some [us_game_init._cmd; us_game_init._sl; us_game_init._tl;
            us_game_init._pad; us_game_init._tile; us_game_init._sh;
            us_game_init._th] /\
  (sizeof area_env
      (Tunion us_area.__540 noattr) = 16 /\
   sizeof cutscene_env
      (Tunion us_mario_actions_cutscene.__540 noattr) = 16 /\
   sizeof normalized_env
      (Tunion us_area.__540 noattr) = 8) /\
  (initializer_size_bytes (gvar_init us_area.v_D_8032CF00) = 16 /\
   sizeof normalized_env
      (gvar_info us_area.v_D_8032CF00) = 8 /\
   sizeof normalized_env
      (gvar_info us_area.v_D_8032CF00) <
    initializer_size_bytes (gvar_init us_area.v_D_8032CF00)) /\
  us_viewport_538_unit_indices = [4%nat; 27%nat].

(** Syntactic coverage of the viewport tag and its containing union. *)

Fixpoint type_mentions_any (ids : list ident) (ty : type) : bool :=
  match ty with
  | Tpointer pointed _ => type_mentions_any ids pointed
  | Tarray element _ _ => type_mentions_any ids element
  | Tfunction parameters result _ =>
      orb (existsb (type_mentions_any ids) parameters)
          (type_mentions_any ids result)
  | Tstruct id _ | Tunion id _ => existsb (fun wanted => Pos.eqb id wanted) ids
  | _ => false
  end.

Fixpoint expr_mentions_any (ids : list ident) (expression : expr) : bool :=
  let own_type := type_mentions_any ids (typeof expression) in
  orb own_type
    (match expression with
     | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
     | Ecast inner _ | Efield inner _ _ => expr_mentions_any ids inner
     | Ebinop _ left_expression right_expression _ =>
         orb (expr_mentions_any ids left_expression)
             (expr_mentions_any ids right_expression)
     | Esizeof measured _ | Ealignof measured _ =>
         type_mentions_any ids measured
     | _ => false
     end).

Fixpoint statement_mentions_any
    (ids : list ident) (statement_value : statement) : bool :=
  match statement_value with
  | Sskip | Sbreak | Scontinue | Sgoto _ => false
  | Sassign left_expression right_expression =>
      orb (expr_mentions_any ids left_expression)
          (expr_mentions_any ids right_expression)
  | Sset _ value => expr_mentions_any ids value
  | Scall _ function arguments =>
      orb (expr_mentions_any ids function)
          (existsb (expr_mentions_any ids) arguments)
  | Sbuiltin _ _ types arguments =>
      orb (existsb (type_mentions_any ids) types)
          (existsb (expr_mentions_any ids) arguments)
  | Ssequence first second | Sloop first second =>
      orb (statement_mentions_any ids first)
          (statement_mentions_any ids second)
  | Sifthenelse condition yes no =>
      orb (expr_mentions_any ids condition)
        (orb (statement_mentions_any ids yes)
             (statement_mentions_any ids no))
  | Sreturn value =>
      match value with Some expression => expr_mentions_any ids expression
      | None => false end
  | Sswitch expression cases =>
      orb (expr_mentions_any ids expression)
          (labeled_statements_mentions_any ids cases)
  | Slabel _ body => statement_mentions_any ids body
  end
with labeled_statements_mentions_any
    (ids : list ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      orb (statement_mentions_any ids body)
          (labeled_statements_mentions_any ids rest)
  end.

Definition typed_ident_list_mentions_any
    (ids : list ident) (values : list (ident * type)) : bool :=
  existsb (fun entry => type_mentions_any ids (snd entry)) values.

Definition function_mentions_any
    (ids : list ident) (function_value : Clight.function) : bool :=
  orb (type_mentions_any ids (fn_return function_value))
  (orb (typed_ident_list_mentions_any ids (fn_params function_value))
  (orb (typed_ident_list_mentions_any ids (fn_vars function_value))
  (orb (typed_ident_list_mentions_any ids (fn_temps function_value))
       (statement_mentions_any ids (fn_body function_value))))).

Definition fundef_mentions_any
    (ids : list ident) (definition : Clight.fundef) : bool :=
  match definition with
  | Internal function_value => function_mentions_any ids function_value
  | External _ parameters result _ =>
      orb (existsb (type_mentions_any ids) parameters)
          (type_mentions_any ids result)
  end.

Definition globdef_mentions_any
    (ids : list ident) (definition : globdef Clight.fundef type) : bool :=
  match definition with
  | Gfun function_definition => fundef_mentions_any ids function_definition
  | Gvar variable => type_mentions_any ids (gvar_info variable)
  end.

Definition globals_mentioning_any
    (ids : list ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst (filter (fun entry => globdef_mentions_any ids (snd entry)) definitions).

Definition us_area_viewport_tag_family : list ident :=
  [us_area.__538; us_area.__540].

Definition us_expected_area_viewport_affected_globals : list ident :=
  [us_area._clear_viewport;
   us_area._make_viewport_clip_rect;
   us_area._geo_process_root;
   us_area._D_8032CE74;
   us_area._D_8032CE78;
   us_area._D_8032CF00;
   us_area._override_viewport_and_clip;
   us_area._render_game].

Definition us_cutscene_viewport_tag_family : list ident :=
  [us_mario_actions_cutscene.__538; us_mario_actions_cutscene.__540].

Definition us_expected_cutscene_viewport_affected_globals : list ident :=
  [us_mario_actions_cutscene._override_viewport_and_clip;
   us_mario_actions_cutscene._sEndCutsceneVp;
   us_mario_actions_cutscene._act_end_peach_cutscene;
   us_mario_actions_cutscene._act_credits_cutscene].

Definition USAffectedViewportGlobalsAudit : Prop :=
  globals_mentioning_any us_area_viewport_tag_family us_area.global_definitions =
    us_expected_area_viewport_affected_globals /\
  globals_mentioning_any us_cutscene_viewport_tag_family
    us_mario_actions_cutscene.global_definitions =
    us_expected_cutscene_viewport_affected_globals.

(** A deterministic type-level alpha-renaming operation.  A future cleaned
    area unit must apply this mapping to composites, globals, every function
    declaration and body annotation, locals, temporaries, [sizeof], and
    [alignof].  Merely replacing the composite definition is insufficient. *)

Definition rename_tag_ident (old fresh id : ident) : ident :=
  if peq id old then fresh else id.

Fixpoint rename_type_tag (old fresh : ident) (ty : type) : type :=
  match ty with
  | Tvoid => Tvoid
  | Tint size signed attributes => Tint size signed attributes
  | Tlong signed attributes => Tlong signed attributes
  | Tfloat size attributes => Tfloat size attributes
  | Tpointer pointed attributes =>
      Tpointer (rename_type_tag old fresh pointed) attributes
  | Tarray element count attributes =>
      Tarray (rename_type_tag old fresh element) count attributes
  | Tfunction parameters result convention =>
      Tfunction (map (rename_type_tag old fresh) parameters)
        (rename_type_tag old fresh result) convention
  | Tstruct id attributes => Tstruct (rename_tag_ident old fresh id) attributes
  | Tunion id attributes => Tunion (rename_tag_ident old fresh id) attributes
  end.

Definition rename_member_type_tag
    (old fresh : ident) (value : member) : member :=
  match value with
  | Member_plain id ty => Member_plain id (rename_type_tag old fresh ty)
  | Member_bitfield id size signed attributes width padding =>
      Member_bitfield id size signed attributes width padding
  end.

Definition rename_composite_type_tag
    (old fresh : ident) (definition : composite_definition) :=
  match definition with
  | Composite id kind member_values attributes =>
      Composite (rename_tag_ident old fresh id) kind
        (map (rename_member_type_tag old fresh) member_values) attributes
  end.

Definition tag_absent_from_composites
    (id : ident) (definitions : list composite_definition) : Prop :=
  ~ In id (composite_identifiers definitions).

Definition identifier_absentb (id : ident) (ids : list ident) : bool :=
  negb (existsb (fun candidate => Pos.eqb id candidate) ids).

Definition composite_definition_mentions_any
    (ids : list ident) (definition : composite_definition) : bool :=
  match definition with
  | Composite id _ member_values _ =>
      orb (existsb (fun wanted => Pos.eqb id wanted) ids)
          (existsb (fun value => type_mentions_any ids (type_member value))
             member_values)
  end.

Definition no_composite_definition_mentions
    (id : ident) (definitions : list composite_definition) : bool :=
  forallb (fun definition =>
    negb (composite_definition_mentions_any [id] definition)) definitions.

Definition USFreshTagGloballyUnused (fresh : ident) : Prop :=
  no_composite_definition_mentions fresh
    (unit_composite_definitions us_units) = true /\
  identifier_absentb fresh
    (global_identifiers (unit_global_definitions us_units)) = true /\
  globals_mentioning_any [fresh] (unit_global_definitions us_units) = [] /\
  identifier_absentb fresh (unit_public_idents us_units) = true.

(** This obligation records the minimum composite/type-level part of the
    required repair.  Its concrete inhabitant below certifies that the local
    composite environment can be rebuilt with a fresh tag and the viewport
    retains its size and alignment.  Expression/statement transformation and
    execution simulation are separate requirements, made unavoidable by the
    exact affected-global audit above. *)
Definition USAreaViewportTagAlphaRenamingLayoutObligation
    (fresh : ident) (renamed_composites : list composite_definition) : Prop :=
  fresh <> us_area.__538 /\
  tag_absent_from_composites fresh us_area.composites /\
  renamed_composites =
    map (rename_composite_type_tag us_area.__538 fresh) us_area.composites /\
  exists renamed_env,
    build_composite_env renamed_composites = OK renamed_env /\
    sizeof renamed_env (Tstruct fresh noattr) =
      sizeof (prog_comp_env us_area.prog) (Tstruct us_area.__538 noattr) /\
    alignof renamed_env (Tstruct fresh noattr) =
      alignof (prog_comp_env us_area.prog) (Tstruct us_area.__538 noattr).

Definition us_area_viewport_fresh_tag : ident := 1000000%positive.

Definition us_area_viewport_renamed_composites :=
  map (rename_composite_type_tag
         us_area.__538 us_area_viewport_fresh_tag) us_area.composites.

Definition us_area_viewport_renamed_composite_env : composite_env :=
  match build_composite_env us_area_viewport_renamed_composites with
  | OK environment => environment
  | Error _ => PTree.empty _
  end.

Definition USCutsceneViewportTagAlphaRenamingLayoutObligation
    (fresh : ident) (renamed_composites : list composite_definition) : Prop :=
  fresh <> us_mario_actions_cutscene.__538 /\
  tag_absent_from_composites fresh us_mario_actions_cutscene.composites /\
  renamed_composites =
    map (rename_composite_type_tag
           us_mario_actions_cutscene.__538 fresh)
        us_mario_actions_cutscene.composites /\
  exists renamed_env,
    build_composite_env renamed_composites = OK renamed_env /\
    sizeof renamed_env (Tstruct fresh noattr) =
      sizeof (prog_comp_env us_mario_actions_cutscene.prog)
        (Tstruct us_mario_actions_cutscene.__538 noattr) /\
    alignof renamed_env (Tstruct fresh noattr) =
      alignof (prog_comp_env us_mario_actions_cutscene.prog)
        (Tstruct us_mario_actions_cutscene.__538 noattr).

Definition us_cutscene_viewport_renamed_composites :=
  map (rename_composite_type_tag
         us_mario_actions_cutscene.__538 us_area_viewport_fresh_tag)
      us_mario_actions_cutscene.composites.

Definition us_cutscene_viewport_renamed_composite_env : composite_env :=
  match build_composite_env us_cutscene_viewport_renamed_composites with
  | OK environment => environment
  | Error _ => PTree.empty _
  end.

Definition USAllViewport538AlphaRenamingLayoutObligation : Prop :=
  USFreshTagGloballyUnused us_area_viewport_fresh_tag /\
  USAreaViewportTagAlphaRenamingLayoutObligation
    us_area_viewport_fresh_tag us_area_viewport_renamed_composites /\
  USCutsceneViewportTagAlphaRenamingLayoutObligation
    us_area_viewport_fresh_tag us_cutscene_viewport_renamed_composites.

(** The preceding local constructions repair the two composite environments
    only.  [USClightLinkRefinementCertificates] checks global freshness and
    packages the combined inhabitant.  A sound linked target must
    additionally rename the four cutscene and eight
    area global definitions enumerated above, then prove a Clight execution
    simulation.  In particular it cannot be definitionally equal to the old
    [us_normalized_semantic_slice], whose [__540] has size 8. *)
