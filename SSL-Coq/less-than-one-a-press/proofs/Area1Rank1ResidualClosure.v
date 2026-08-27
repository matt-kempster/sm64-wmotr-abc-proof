(** Rank-1 residual reduction beyond the immediate Mario child census.

    This file checks two independent generated-source boundaries.

    First, the ordinary named-source route to a second PLAYER-list object is
    smaller than the earlier tail proof left explicit: [bhvMario] occurs in
    exactly one generated initializer, no generated internal body names it,
    and [spawn_objects_from_info] has exactly the two ordinary area-loading
    callers.  This does not close a live pointer-forwarding, table-mutation,
    external-effect, or list-lifecycle escape.

    Second, the dynamic floor-owner data structure has no hidden ordinary
    writer form.  The complete selected US/JP source unions contain no whole
    [Surface] or [SurfaceNode] copy, no builtin or indirect call receiving
    either pointer type, and no unresolved direct callee receiving either
    pointer type.  The only four functions containing non-plain [Surface *]
    derivations contain four identity casts and the checked pool index in
    [alloc_surface].  The only
    analogous [SurfaceNode *] derivation is its allocator's pool index.
    Direct field censuses then reduce the live query lineage to the intended
    node insertion and the two already-known owner writes: allocator null and
    [gCurrentObject].

    These are source-shape theorems, not a linked execution.  In particular,
    an already escaped/type-punned alias, an outside call capable of reaching
    a private allocation without receiving the typed pointer, a wrong live
    [gCurrentObject], or a stale object/surface epoch remains a semantic
    residual.  Out-of-bounds pool indexing is not a successful CompCert
    execution and is outside the in-model route. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Cop Ctypes.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_level_update us_mario_step us_surface_load
  jp_behavior_actions jp_level_update jp_mario_step jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ActionDepthAliasCensus Area1PlayerListTailClosure
  Area1SchedulerSurfaceLifecycleSplit ClightLinkExecution
  InkTimer131EntryExecutionClosure LinkedClightPrograms
  NormalizedClightPrograms PlatformPointerProvenance.

Import ListNotations.

Module R1R_USBehavior := us_behavior_actions.
Module R1R_USLevel := us_level_update.
Module R1R_USStep := us_mario_step.
Module R1R_USSurface := us_surface_load.
Module R1R_JPBehavior := jp_behavior_actions.
Module R1R_JPLevel := jp_level_update.
Module R1R_JPStep := jp_mario_step.
Module R1R_JPSurface := jp_surface_load.

(** * Ordinary named-source PLAYER ingress *)

Fixpoint internal_statement_mention_sites
    (needle : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_mentions_ident_s needle (fn_body body)
      then id :: internal_statement_mention_sites needle rest
      else internal_statement_mention_sites needle rest
  | _ :: rest => internal_statement_mention_sites needle rest
  end.

Definition USOrdinaryPlayerIngressSourceClaim : Prop :=
  count_occ peq (source_union_init_addrof_identifiers us_units)
    IT131E_USData._bhvMario = 1%nat /\
  internal_statement_mention_sites IT131E_USData._bhvMario
    us_generated_definitions = [] /\
  internal_function_direct_call_sites
    IT131E_USArea._spawn_objects_from_info us_generated_definitions =
      [IT131E_USArea._load_area; IT131E_USArea._load_mario_area] /\
  ink_zero_list_behavior_owner_ids (prog_defs IT131E_USData.prog) =
    [IT131E_USData._bhvMario].

Definition JPOrdinaryPlayerIngressSourceClaim : Prop :=
  count_occ peq (source_union_init_addrof_identifiers jp_units)
    IT131E_JPData._bhvMario = 1%nat /\
  internal_statement_mention_sites IT131E_JPData._bhvMario
    jp_generated_definitions_for_alias = [] /\
  internal_function_direct_call_sites
    IT131E_JPArea._spawn_objects_from_info
    jp_generated_definitions_for_alias =
      [IT131E_JPArea._load_area; IT131E_JPArea._load_mario_area] /\
  ink_zero_list_behavior_owner_ids (prog_defs IT131E_JPData.prog) =
    [IT131E_JPData._bhvMario].

Theorem us_ordinary_player_ingress_source_checked :
  USOrdinaryPlayerIngressSourceClaim.
Proof.
  unfold USOrdinaryPlayerIngressSourceClaim.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem jp_ordinary_player_ingress_source_checked :
  JPOrdinaryPlayerIngressSourceClaim.
Proof.
  unfold JPOrdinaryPlayerIngressSourceClaim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact harmless shapes of the remaining pointer derivations *)

Definition current_struct_pointer_derivation_count
    (tag : ident) (value : expr) : nat :=
  match value with
  | Ecast inner target_type =>
      if expression_has_struct_pointer_type tag inner ||
           type_is_struct_pointer tag target_type
      then 1%nat else 0%nat
  | Ebinop operator left_value right_value _ =>
      match operator with
      | Oadd | Osub =>
          if expression_has_struct_pointer_type tag left_value ||
               expression_has_struct_pointer_type tag right_value
          then 1%nat else 0%nat
      | _ => 0%nat
      end
  | _ => 0%nat
  end.

Definition current_identity_struct_pointer_cast_count
    (tag : ident) (value : expr) : nat :=
  match value with
  | Ecast inner target_type =>
      if expression_has_struct_pointer_type tag inner &&
           type_is_struct_pointer tag target_type
      then 1%nat else 0%nat
  | _ => 0%nat
  end.

Definition current_struct_pointer_add_count
    (tag : ident) (value : expr) : nat :=
  match value with
  | Ebinop Oadd left_value right_value _ =>
      if expression_has_struct_pointer_type tag left_value ||
           expression_has_struct_pointer_type tag right_value
      then 1%nat else 0%nat
  | _ => 0%nat
  end.

Fixpoint expression_count
    (counter : expr -> nat) (value : expr) : nat :=
  (counter value +
   match value with
   | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
   | Ecast inner _ | Efield inner _ _ => expression_count counter inner
   | Ebinop _ left_value right_value _ =>
       expression_count counter left_value +
       expression_count counter right_value
   | _ => 0%nat
   end)%nat.

Fixpoint expression_list_count
    (counter : expr -> nat) (values : list expr) : nat :=
  match values with
  | [] => 0%nat
  | value :: rest =>
      (expression_count counter value + expression_list_count counter rest)%nat
  end.

Fixpoint statement_expression_count
    (counter : expr -> nat) (body : statement) : nat :=
  match body with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => 0%nat
  | Sassign lhs rhs =>
      (expression_count counter lhs + expression_count counter rhs)%nat
  | Sset _ rhs => expression_count counter rhs
  | Scall _ callee arguments =>
      (expression_count counter callee +
       expression_list_count counter arguments)%nat
  | Sbuiltin _ _ _ arguments => expression_list_count counter arguments
  | Ssequence first second | Sloop first second =>
      (statement_expression_count counter first +
       statement_expression_count counter second)%nat
  | Sifthenelse condition yes no =>
      (expression_count counter condition +
       statement_expression_count counter yes +
       statement_expression_count counter no)%nat
  | Sreturn (Some value) => expression_count counter value
  | Sswitch value cases =>
      (expression_count counter value +
       labeled_statement_expression_count counter cases)%nat
  | Slabel _ nested => statement_expression_count counter nested
  end
with labeled_statement_expression_count
    (counter : expr -> nat) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (statement_expression_count counter body +
       labeled_statement_expression_count counter rest)%nat
  end.

Definition struct_pointer_derivation_count_s
    (tag : ident) (body : statement) : nat :=
  statement_expression_count
    (current_struct_pointer_derivation_count tag) body.

Definition identity_struct_pointer_cast_count_s
    (tag : ident) (body : statement) : nat :=
  statement_expression_count
    (current_identity_struct_pointer_cast_count tag) body.

Definition struct_pointer_add_count_s
    (tag : ident) (body : statement) : nat :=
  statement_expression_count (current_struct_pointer_add_count tag) body.

Definition USSurfaceDerivationShapeClaim : Prop :=
  struct_pointer_derivation_count_s R1R_USSurface._Surface
    (fn_body R1R_USStep.f_perform_air_quarter_step) = 2%nat /\
  identity_struct_pointer_cast_count_s R1R_USSurface._Surface
    (fn_body R1R_USStep.f_perform_air_quarter_step) = 2%nat /\
  struct_pointer_add_count_s R1R_USSurface._Surface
    (fn_body R1R_USStep.f_perform_air_quarter_step) = 0%nat /\
  struct_pointer_derivation_count_s R1R_USSurface._Surface
    (fn_body R1R_USBehavior.f_bhv_spawned_coin_loop) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_USSurface._Surface
    (fn_body R1R_USBehavior.f_bhv_spawned_coin_loop) = 1%nat /\
  struct_pointer_add_count_s R1R_USSurface._Surface
    (fn_body R1R_USBehavior.f_bhv_spawned_coin_loop) = 0%nat /\
  struct_pointer_derivation_count_s R1R_USSurface._Surface
    (fn_body R1R_USLevel.f_check_instant_warp) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_USSurface._Surface
    (fn_body R1R_USLevel.f_check_instant_warp) = 1%nat /\
  struct_pointer_add_count_s R1R_USSurface._Surface
    (fn_body R1R_USLevel.f_check_instant_warp) = 0%nat /\
  struct_pointer_derivation_count_s R1R_USSurface._Surface
    (fn_body R1R_USSurface.f_alloc_surface) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_USSurface._Surface
    (fn_body R1R_USSurface.f_alloc_surface) = 0%nat /\
  struct_pointer_add_count_s R1R_USSurface._Surface
    (fn_body R1R_USSurface.f_alloc_surface) = 1%nat.

Definition JPSurfaceDerivationShapeClaim : Prop :=
  struct_pointer_derivation_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPStep.f_perform_air_quarter_step) = 2%nat /\
  identity_struct_pointer_cast_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPStep.f_perform_air_quarter_step) = 2%nat /\
  struct_pointer_add_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPStep.f_perform_air_quarter_step) = 0%nat /\
  struct_pointer_derivation_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPBehavior.f_bhv_spawned_coin_loop) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPBehavior.f_bhv_spawned_coin_loop) = 1%nat /\
  struct_pointer_add_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPBehavior.f_bhv_spawned_coin_loop) = 0%nat /\
  struct_pointer_derivation_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPLevel.f_check_instant_warp) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPLevel.f_check_instant_warp) = 1%nat /\
  struct_pointer_add_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPLevel.f_check_instant_warp) = 0%nat /\
  struct_pointer_derivation_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPSurface.f_alloc_surface) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPSurface.f_alloc_surface) = 0%nat /\
  struct_pointer_add_count_s R1R_JPSurface._Surface
    (fn_body R1R_JPSurface.f_alloc_surface) = 1%nat.

Theorem us_surface_derivation_shapes_checked :
  USSurfaceDerivationShapeClaim.
Proof.
  unfold USSurfaceDerivationShapeClaim, struct_pointer_derivation_count_s,
    identity_struct_pointer_cast_count_s, struct_pointer_add_count_s.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem jp_surface_derivation_shapes_checked :
  JPSurfaceDerivationShapeClaim.
Proof.
  unfold JPSurfaceDerivationShapeClaim, struct_pointer_derivation_count_s,
    identity_struct_pointer_cast_count_s, struct_pointer_add_count_s.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Whole-source floor-owner and list-node closure *)

Definition USSurfaceOwnerAliasSourceClaim : Prop :=
  internal_untyped_struct_pointer_derivation_sites
    R1R_USSurface._Surface us_generated_definitions =
      [R1R_USStep._perform_air_quarter_step;
       R1R_USBehavior._bhv_spawned_coin_loop;
       R1R_USLevel._check_instant_warp;
       R1R_USSurface._alloc_surface] /\
  internal_statement_predicate_sites
    (statement_assigns_whole_struct_s R1R_USSurface._Surface)
    us_generated_definitions = [] /\
  length (internal_statement_predicate_sites
    (statement_stores_struct_pointer_s R1R_USSurface._Surface)
    us_generated_definitions) = 13%nat /\
  length (internal_statement_predicate_sites
    (statement_returns_struct_pointer_s R1R_USSurface._Surface)
    us_generated_definitions) = 6%nat /\
  unresolved_direct_struct_pointer_callees
    R1R_USSurface._Surface us_generated_definitions = [] /\
  internal_builtin_struct_pointer_sites
    R1R_USSurface._Surface us_generated_definitions = [] /\
  internal_indirect_struct_pointer_call_sites
    R1R_USSurface._Surface us_generated_definitions = [] /\
  USSurfaceDerivationShapeClaim /\
  USSurfaceObjectDirectSourceUnionClaim.

Definition JPSurfaceOwnerAliasSourceClaim : Prop :=
  internal_untyped_struct_pointer_derivation_sites
    R1R_JPSurface._Surface jp_generated_definitions_for_alias =
      [R1R_JPStep._perform_air_quarter_step;
       R1R_JPBehavior._bhv_spawned_coin_loop;
       R1R_JPLevel._check_instant_warp;
       R1R_JPSurface._alloc_surface] /\
  internal_statement_predicate_sites
    (statement_assigns_whole_struct_s R1R_JPSurface._Surface)
    jp_generated_definitions_for_alias = [] /\
  length (internal_statement_predicate_sites
    (statement_stores_struct_pointer_s R1R_JPSurface._Surface)
    jp_generated_definitions_for_alias) = 13%nat /\
  length (internal_statement_predicate_sites
    (statement_returns_struct_pointer_s R1R_JPSurface._Surface)
    jp_generated_definitions_for_alias) = 6%nat /\
  unresolved_direct_struct_pointer_callees
    R1R_JPSurface._Surface jp_generated_definitions_for_alias = [] /\
  internal_builtin_struct_pointer_sites
    R1R_JPSurface._Surface jp_generated_definitions_for_alias = [] /\
  internal_indirect_struct_pointer_call_sites
    R1R_JPSurface._Surface jp_generated_definitions_for_alias = [] /\
  JPSurfaceDerivationShapeClaim /\
  JPSurfaceObjectDirectSourceUnionClaim.

Definition USSurfaceNodeLineageSourceClaim : Prop :=
  internal_surface_object_assignment_sites
    R1R_USSurface._SurfaceNode R1R_USSurface._surface
    us_generated_definitions = [R1R_USSurface._add_surface_to_cell] /\
  internal_surface_object_assignment_sites
    R1R_USSurface._SurfaceNode R1R_USSurface._next
    us_generated_definitions =
      [R1R_USSurface._alloc_surface_node;
       R1R_USSurface._clear_spatial_partition;
       R1R_USSurface._add_surface_to_cell] /\
  internal_surface_object_address_sites
    R1R_USSurface._SurfaceNode R1R_USSurface._surface
    us_generated_definitions = [] /\
  internal_surface_object_address_sites
    R1R_USSurface._SurfaceNode R1R_USSurface._next
    us_generated_definitions = [] /\
  internal_untyped_struct_pointer_derivation_sites
    R1R_USSurface._SurfaceNode us_generated_definitions =
      [R1R_USSurface._alloc_surface_node] /\
  internal_statement_predicate_sites
    (statement_assigns_whole_struct_s R1R_USSurface._SurfaceNode)
    us_generated_definitions = [] /\
  unresolved_direct_struct_pointer_callees
    R1R_USSurface._SurfaceNode us_generated_definitions = [] /\
  internal_builtin_struct_pointer_sites
    R1R_USSurface._SurfaceNode us_generated_definitions = [] /\
  internal_indirect_struct_pointer_call_sites
    R1R_USSurface._SurfaceNode us_generated_definitions = [] /\
  struct_pointer_derivation_count_s R1R_USSurface._SurfaceNode
    (fn_body R1R_USSurface.f_alloc_surface_node) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_USSurface._SurfaceNode
    (fn_body R1R_USSurface.f_alloc_surface_node) = 0%nat /\
  struct_pointer_add_count_s R1R_USSurface._SurfaceNode
    (fn_body R1R_USSurface.f_alloc_surface_node) = 1%nat.

Definition JPSurfaceNodeLineageSourceClaim : Prop :=
  internal_surface_object_assignment_sites
    R1R_JPSurface._SurfaceNode R1R_JPSurface._surface
    jp_generated_definitions_for_alias =
      [R1R_JPSurface._add_surface_to_cell] /\
  internal_surface_object_assignment_sites
    R1R_JPSurface._SurfaceNode R1R_JPSurface._next
    jp_generated_definitions_for_alias =
      [R1R_JPSurface._alloc_surface_node;
       R1R_JPSurface._clear_spatial_partition;
       R1R_JPSurface._add_surface_to_cell] /\
  internal_surface_object_address_sites
    R1R_JPSurface._SurfaceNode R1R_JPSurface._surface
    jp_generated_definitions_for_alias = [] /\
  internal_surface_object_address_sites
    R1R_JPSurface._SurfaceNode R1R_JPSurface._next
    jp_generated_definitions_for_alias = [] /\
  internal_untyped_struct_pointer_derivation_sites
    R1R_JPSurface._SurfaceNode jp_generated_definitions_for_alias =
      [R1R_JPSurface._alloc_surface_node] /\
  internal_statement_predicate_sites
    (statement_assigns_whole_struct_s R1R_JPSurface._SurfaceNode)
    jp_generated_definitions_for_alias = [] /\
  unresolved_direct_struct_pointer_callees
    R1R_JPSurface._SurfaceNode jp_generated_definitions_for_alias = [] /\
  internal_builtin_struct_pointer_sites
    R1R_JPSurface._SurfaceNode jp_generated_definitions_for_alias = [] /\
  internal_indirect_struct_pointer_call_sites
    R1R_JPSurface._SurfaceNode jp_generated_definitions_for_alias = [] /\
  struct_pointer_derivation_count_s R1R_JPSurface._SurfaceNode
    (fn_body R1R_JPSurface.f_alloc_surface_node) = 1%nat /\
  identity_struct_pointer_cast_count_s R1R_JPSurface._SurfaceNode
    (fn_body R1R_JPSurface.f_alloc_surface_node) = 0%nat /\
  struct_pointer_add_count_s R1R_JPSurface._SurfaceNode
    (fn_body R1R_JPSurface.f_alloc_surface_node) = 1%nat.

Theorem us_surface_owner_alias_source_checked :
  USSurfaceOwnerAliasSourceClaim.
Proof.
  unfold USSurfaceOwnerAliasSourceClaim.
  repeat split.
  all: try exact us_surface_derivation_shapes_checked.
  all: try exact us_surface_object_direct_source_union_checked.
  all: vm_compute; reflexivity.
Qed.

Theorem jp_surface_owner_alias_source_checked :
  JPSurfaceOwnerAliasSourceClaim.
Proof.
  unfold JPSurfaceOwnerAliasSourceClaim.
  repeat split.
  all: try exact jp_surface_derivation_shapes_checked.
  all: try exact jp_surface_object_direct_source_union_checked.
  all: vm_compute; reflexivity.
Qed.

Theorem us_surface_node_lineage_source_checked :
  USSurfaceNodeLineageSourceClaim.
Proof.
  unfold USSurfaceNodeLineageSourceClaim, struct_pointer_derivation_count_s,
    identity_struct_pointer_cast_count_s, struct_pointer_add_count_s.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem jp_surface_node_lineage_source_checked :
  JPSurfaceNodeLineageSourceClaim.
Proof.
  unfold JPSurfaceNodeLineageSourceClaim, struct_pointer_derivation_count_s,
    identity_struct_pointer_cast_count_s, struct_pointer_add_count_s.
  vm_compute. repeat split; reflexivity.
Qed.

Definition Area1Rank1ResidualCheckedBoundary : Prop :=
  Area1PlayerListTailCheckedBoundary /\
  USOrdinaryPlayerIngressSourceClaim /\
  JPOrdinaryPlayerIngressSourceClaim /\
  USSurfaceOwnerAliasSourceClaim /\
  JPSurfaceOwnerAliasSourceClaim /\
  USSurfaceNodeLineageSourceClaim /\
  JPSurfaceNodeLineageSourceClaim.

Theorem area1_rank1_residual_checked_boundary_holds :
  Area1Rank1ResidualCheckedBoundary.
Proof.
  unfold Area1Rank1ResidualCheckedBoundary.
  exact (conj area1_player_list_tail_checked_boundary_holds
    (conj us_ordinary_player_ingress_source_checked
    (conj jp_ordinary_player_ingress_source_checked
    (conj us_surface_owner_alias_source_checked
    (conj jp_surface_owner_alias_source_checked
    (conj us_surface_node_lineage_source_checked
      jp_surface_node_lineage_source_checked)))))).
Qed.
