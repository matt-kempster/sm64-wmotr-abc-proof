(** Rank-1 audit of the six remaining live floor-owner/PLAYER escapes.

    This file deliberately distinguishes three outcomes.

    - Ordinary named-source explanations can be closed by a whole-program
      census.  In particular, canonical surface callbacks do not re-enter an
      object-list traversal which changes [gCurrentObject], and the only
      ordinary writers of an Object's behavior and list links are the checked
      creation, behavior-setter, allocation, and removal helpers.

    - Stock geometry is already impossible at the upper-warp sample (and at
      the checked low-Y cached-floor retry) once the live result is projected
      into the finite fifteen-owner model.

    - Object lifetime is not an invariant: both the bounded model and the
      authenticated JP receipt exhibit an inactive, freed, unreused cached
      object whose bytes are read later.  This is a real survivor, but it does
      not install the missing Area-1 query owner by itself.

    The pool-alias/external case is also sharpened rather than hidden.  Unlike
    the writable action tables, [sSurfacePool] and [sSurfaceNodePool] are
    public pointer globals.  Consequently a linked proof may not merely omit
    the pointed-to pool from a private self-injection after those cells hold
    the pool pointers.  Every reached outside call needs an exact effect (or
    an unreachability proof), and the live allocator ranges still need a
    separation invariant against generic main-pool aliases.

    These are source and observation boundaries, not a fabricated continuous
    Clight execution.  OOB pointer fabrication, ACE, DMA, and continuation
    after undefined behavior remain outside the selected CompCert model. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import
  AST Clight Ctypes Events Globalenvs Memory Values.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_behavior_data
  us_memory us_object_helpers us_object_list_processor us_spawn_object us_surface_load
  jp_behavior_actions jp_behavior_data
  jp_memory jp_object_helpers jp_object_list_processor jp_spawn_object jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1CachedFloorSelectionClosure Area1PlatformExhaustiveness
  Area1PlayerListTailClosure Area1Rank1ResidualClosure
  Area1Rank3PayloadWriterClosure
  Area1SchedulerSurfaceLifecycleSplit Area1StateFirstRetailTrace
  Area1SurfaceEpochLifecycle
  InkTimer131EntryExecutionClosure InkTimer131IndirectAliasClosure
  InkTimer131MarioTailClosure LinkedClightPrograms
  InkTimer131RetailMipsCode
  PlatformPointerProvenance PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

Module R1S_USHelpers := us_object_helpers.
Module R1S_USData := us_behavior_data.
Module R1S_USMemory := us_memory.
Module R1S_USActions := us_behavior_actions.
Module R1S_USObjects := us_object_list_processor.
Module R1S_USSpawn := us_spawn_object.
Module R1S_USSurface := us_surface_load.
Module R1S_JPHelpers := jp_object_helpers.
Module R1S_JPData := jp_behavior_data.
Module R1S_JPMemory := jp_memory.
Module R1S_JPActions := jp_behavior_actions.
Module R1S_JPObjects := jp_object_list_processor.
Module R1S_JPSpawn := jp_spawn_object.
Module R1S_JPSurface := jp_surface_load.

(** * Wrong live current object *)

Definition us_current_object_direct_writers : list ident :=
  internal_function_assignment_sites R1S_USObjects._gCurrentObject
    rank3_us_definitions.

Definition jp_current_object_direct_writers : list ident :=
  internal_function_assignment_sites R1S_JPObjects._gCurrentObject
    rank3_jp_definitions.

Definition CurrentObjectWriterClosureClaim : Prop :=
  us_current_object_direct_writers =
    [R1S_USObjects._update_objects_starting_at;
     R1S_USObjects._update_objects_during_time_stop;
     R1S_USObjects._unload_deactivated_objects_in_list] /\
  jp_current_object_direct_writers =
    [R1S_JPObjects._update_objects_starting_at;
     R1S_JPObjects._update_objects_during_time_stop;
     R1S_JPObjects._unload_deactivated_objects_in_list] /\
  identifiers_in us_current_object_direct_writers
    (rank3_us_owner_call_closure 5) = [] /\
  identifiers_in jp_current_object_direct_writers
    (rank3_jp_owner_call_closure 5) = [].

Theorem canonical_owner_direct_closure_has_no_current_object_writer :
  CurrentObjectWriterClosureClaim.
Proof.
  unfold CurrentObjectWriterClosureClaim,
    us_current_object_direct_writers, jp_current_object_direct_writers.
  vm_compute. repeat split; reflexivity.
Qed.

(** There is exactly one syntactically indirect call in the entire
    ninety-three-function direct closure: the generic action-table helper.
    This makes the two concrete target arrays below exhaustive for ordinary
    canonical-owner dispatch rather than two examples selected by hand. *)
Fixpoint rank1_indirect_call_count_s (body : statement) : nat :=
  match body with
  | Scall _ (Evar _ _) _ => 0%nat
  | Scall _ _ _ => 1%nat
  | Ssequence first second | Sloop first second =>
      (rank1_indirect_call_count_s first +
       rank1_indirect_call_count_s second)%nat
  | Sifthenelse _ yes no =>
      (rank1_indirect_call_count_s yes +
       rank1_indirect_call_count_s no)%nat
  | Sswitch _ cases => rank1_indirect_call_count_ls cases
  | Slabel _ nested => rank1_indirect_call_count_s nested
  | _ => 0%nat
  end
with rank1_indirect_call_count_ls (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (rank1_indirect_call_count_s body +
       rank1_indirect_call_count_ls rest)%nat
  end.

Fixpoint rank1_internal_indirect_call_sites
    (wanted : list ident)
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    : list (ident * nat) :=
  match definitions with
  | [] => []
  | (id, Gfun (Ctypes.Internal body)) :: rest =>
      let count := rank1_indirect_call_count_s (fn_body body) in
      if existsb (Pos.eqb id) wanted && negb (Nat.eqb count 0)
      then (id, count) :: rank1_internal_indirect_call_sites wanted rest
      else rank1_internal_indirect_call_sites wanted rest
  | _ :: rest => rank1_internal_indirect_call_sites wanted rest
  end.

Definition CanonicalOwnerIndirectCallClaim : Prop :=
  rank1_internal_indirect_call_sites (rank3_us_owner_call_closure 5)
    rank3_us_definitions =
      [(R1S_USHelpers._cur_obj_call_action_function, 1%nat)] /\
  rank1_internal_indirect_call_sites (rank3_jp_owner_call_closure 5)
    rank3_jp_definitions =
      [(R1S_JPHelpers._cur_obj_call_action_function, 1%nat)].

Theorem canonical_owner_has_one_exact_indirect_dispatch :
  CanonicalOwnerIndirectCallClaim.
Proof.
  unfold CanonicalOwnerIndirectCallClaim.
  vm_compute. split; reflexivity.
Qed.

(** The two canonical Area-1 owner families which use the generic indirect
    action dispatcher have complete stock target arrays here.  The arrays are
    writable and public, so alias/external preservation remains necessary,
    but ordinary initialization points only at the already-audited action
    bodies and none of those targets is a [gCurrentObject] writer. *)
Definition CanonicalOwnerActionDispatchClaim : Prop :=
  initializer_addrof_idents
    (gvar_init R1S_USActions.v_sToxBoxActions) =
      [R1S_USActions._tox_box_act_init;
       R1S_USActions._tox_box_act_roll_land;
       R1S_USActions._tox_box_act_idle;
       R1S_USActions._tox_box_act_unused_idle;
       R1S_USActions._tox_box_act_roll_forward;
       R1S_USActions._tox_box_act_roll_backward;
       R1S_USActions._tox_box_act_roll_right;
       R1S_USActions._tox_box_act_roll_left] /\
  initializer_addrof_idents
    (gvar_init R1S_USActions.v_sExclamationBoxActions) =
      [R1S_USActions._exclamation_box_act_0;
       R1S_USActions._exclamation_box_act_1;
       R1S_USActions._exclamation_box_act_2;
       R1S_USActions._exclamation_box_act_3;
       R1S_USActions._exclamation_box_act_4;
       R1S_USActions._exclamation_box_act_5] /\
  initializer_addrof_idents
    (gvar_init R1S_JPActions.v_sToxBoxActions) =
      [R1S_JPActions._tox_box_act_init;
       R1S_JPActions._tox_box_act_roll_land;
       R1S_JPActions._tox_box_act_idle;
       R1S_JPActions._tox_box_act_unused_idle;
       R1S_JPActions._tox_box_act_roll_forward;
       R1S_JPActions._tox_box_act_roll_backward;
       R1S_JPActions._tox_box_act_roll_right;
       R1S_JPActions._tox_box_act_roll_left] /\
  initializer_addrof_idents
    (gvar_init R1S_JPActions.v_sExclamationBoxActions) =
      [R1S_JPActions._exclamation_box_act_0;
       R1S_JPActions._exclamation_box_act_1;
       R1S_JPActions._exclamation_box_act_2;
       R1S_JPActions._exclamation_box_act_3;
       R1S_JPActions._exclamation_box_act_4;
       R1S_JPActions._exclamation_box_act_5] /\
  gvar_readonly R1S_USActions.v_sToxBoxActions = false /\
  gvar_readonly R1S_USActions.v_sExclamationBoxActions = false /\
  gvar_readonly R1S_JPActions.v_sToxBoxActions = false /\
  gvar_readonly R1S_JPActions.v_sExclamationBoxActions = false /\
  ident_mem R1S_USActions._sToxBoxActions
    R1S_USActions.public_idents = true /\
  ident_mem R1S_USActions._sExclamationBoxActions
    R1S_USActions.public_idents = true /\
  ident_mem R1S_JPActions._sToxBoxActions
    R1S_JPActions.public_idents = true /\
  ident_mem R1S_JPActions._sExclamationBoxActions
    R1S_JPActions.public_idents = true /\
  internal_function_assignment_sites R1S_USActions._sToxBoxActions
    rank3_us_definitions = [] /\
  internal_function_assignment_sites R1S_USActions._sExclamationBoxActions
    rank3_us_definitions = [] /\
  internal_function_assignment_sites R1S_JPActions._sToxBoxActions
    rank3_jp_definitions = [] /\
  internal_function_assignment_sites R1S_JPActions._sExclamationBoxActions
    rank3_jp_definitions = [] /\
  internal_statement_mention_sites R1S_USActions._sToxBoxActions
    rank3_us_definitions = [R1S_USActions._bhv_tox_box_loop] /\
  internal_statement_mention_sites R1S_USActions._sExclamationBoxActions
    rank3_us_definitions = [R1S_USActions._bhv_exclamation_box_loop] /\
  internal_statement_mention_sites R1S_JPActions._sToxBoxActions
    rank3_jp_definitions = [R1S_JPActions._bhv_tox_box_loop] /\
  internal_statement_mention_sites R1S_JPActions._sExclamationBoxActions
    rank3_jp_definitions = [R1S_JPActions._bhv_exclamation_box_loop] /\
  identifiers_in
    (initializer_addrof_idents (gvar_init R1S_USActions.v_sToxBoxActions))
    us_current_object_direct_writers = [] /\
  identifiers_in
    (initializer_addrof_idents
      (gvar_init R1S_USActions.v_sExclamationBoxActions))
    us_current_object_direct_writers = [] /\
  identifiers_in
    (initializer_addrof_idents (gvar_init R1S_JPActions.v_sToxBoxActions))
    jp_current_object_direct_writers = [] /\
  identifiers_in
    (initializer_addrof_idents
      (gvar_init R1S_JPActions.v_sExclamationBoxActions))
    jp_current_object_direct_writers = [].

Theorem canonical_owner_action_dispatch_is_stock_and_store_free :
  CanonicalOwnerActionDispatchClaim.
Proof.
  unfold CanonicalOwnerActionDispatchClaim,
    us_current_object_direct_writers, jp_current_object_direct_writers.
  vm_compute. repeat split; reflexivity.
Qed.

(** The traversal-to-interpreter source receipt and the closed callback graph
    complement one another: a linked run still has to prove that the visited
    node is the intended canonical owner, but an ordinary direct callback
    cannot secretly replace [gCurrentObject] before surface installation. *)
Definition CurrentObjectOrdinaryInstallBoundary : Prop :=
  ink_mario_current_object_source_identity_claim /\
  CurrentObjectWriterClosureClaim /\
  CanonicalOwnerIndirectCallClaim /\
  CanonicalOwnerActionDispatchClaim.

Theorem current_object_ordinary_install_boundary_holds :
  CurrentObjectOrdinaryInstallBoundary.
Proof.
  exact (conj ink_mario_current_object_source_identity_checked
    (conj canonical_owner_direct_closure_has_no_current_object_writer
    (conj canonical_owner_has_one_exact_indirect_dispatch
      canonical_owner_action_dispatch_is_stock_and_store_free))).
Qed.

(** * Surface-pool visibility and the alias/external boundary *)

Definition SurfacePoolPublicAliasClaim : Prop :=
  ident_mem R1S_USSurface._sSurfacePool R1S_USSurface.public_idents = true /\
  ident_mem R1S_USSurface._sSurfaceNodePool R1S_USSurface.public_idents = true /\
  ident_mem R1S_JPSurface._sSurfacePool R1S_JPSurface.public_idents = true /\
  ident_mem R1S_JPSurface._sSurfaceNodePool R1S_JPSurface.public_idents = true /\
  internal_function_assignment_sites R1S_USSurface._sSurfacePool
    rank3_us_definitions = [R1S_USSurface._alloc_surface_pools] /\
  internal_function_assignment_sites R1S_USSurface._sSurfaceNodePool
    rank3_us_definitions = [R1S_USSurface._alloc_surface_pools] /\
  internal_function_assignment_sites R1S_JPSurface._sSurfacePool
    rank3_jp_definitions = [R1S_JPSurface._alloc_surface_pools] /\
  internal_function_assignment_sites R1S_JPSurface._sSurfaceNodePool
    rank3_jp_definitions = [R1S_JPSurface._alloc_surface_pools].

Theorem surface_pool_public_aliases_are_exact :
  SurfacePoolPublicAliasClaim.
Proof.
  unfold SurfacePoolPublicAliasClaim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The pool globals do not name fresh standalone blocks.  Surface loading
    obtains both pointers from two calls to [main_pool_alloc], whose body
    computes returned addresses from the shared left/right main-pool heads
    while updating the shared free-space counter.  These exact AST facts are
    the reason a linked proof needs a byte-range separation invariant, not
    merely a typed-[Surface] alias census. *)
Definition SurfacePoolMainPoolOriginClaim : Prop :=
  count_occ Pos.eq_dec
    (direct_callees_s (fn_body R1S_USSurface.f_alloc_surface_pools))
    R1S_USSurface._main_pool_alloc = 2%nat /\
  count_occ Pos.eq_dec
    (direct_callees_s (fn_body R1S_JPSurface.f_alloc_surface_pools))
    R1S_JPSurface._main_pool_alloc = 2%nat /\
  statement_mentions_ident_s R1S_USMemory._sPoolFreeSpace
    (fn_body R1S_USMemory.f_main_pool_alloc) = true /\
  statement_mentions_ident_s R1S_USMemory._sPoolListHeadL
    (fn_body R1S_USMemory.f_main_pool_alloc) = true /\
  statement_mentions_ident_s R1S_USMemory._sPoolListHeadR
    (fn_body R1S_USMemory.f_main_pool_alloc) = true /\
  statement_mentions_ident_s R1S_JPMemory._sPoolFreeSpace
    (fn_body R1S_JPMemory.f_main_pool_alloc) = true /\
  statement_mentions_ident_s R1S_JPMemory._sPoolListHeadL
    (fn_body R1S_JPMemory.f_main_pool_alloc) = true /\
  statement_mentions_ident_s R1S_JPMemory._sPoolListHeadR
    (fn_body R1S_JPMemory.f_main_pool_alloc) = true.

Theorem surface_pools_have_shared_main_pool_origin :
  SurfacePoolMainPoolOriginClaim.
Proof.
  unfold SurfacePoolMainPoolOriginClaim.
  vm_compute. repeat split; reflexivity.
Qed.

(** A semantic reason the action-table private-block argument does not transfer
    automatically.  Once a public global cell contains a pool pointer, every
    self-injection which maps public symbols and the current memory must also
    map the pointed-to pool block.  The pool therefore cannot be deliberately
    omitted to obtain CompCert's generic unmapped-block external-call frame. *)
Theorem public_pointer_cell_forces_pointee_mapping :
  forall ge injection before identifier global_block global_offset
      pool_block pool_offset,
    symbols_inject injection ge ge ->
    Mem.inject injection before before ->
    Senv.public_symbol ge identifier = true ->
    Senv.find_symbol ge identifier = Some global_block ->
    Mem.load Mptr before global_block global_offset =
      Some (Vptr pool_block pool_offset) ->
    exists delta, injection pool_block = Some (pool_block, delta).
Proof.
  intros ge injection before identifier global_block global_offset
    pool_block pool_offset
    [_ [_ [Hpublic_mapped _]]] Hmemory Hpublic Hsymbol Hload.
  destruct (Hpublic_mapped identifier global_block Hpublic Hsymbol)
    as [target_block [Hglobal_mapping Htarget_symbol]].
  rewrite Hsymbol in Htarget_symbol.
  inversion Htarget_symbol. subst target_block.
  destruct (Mem.load_inject injection before before Mptr global_block
    global_offset global_block 0 (Vptr pool_block pool_offset)
    Hmemory Hload Hglobal_mapping) as
    [target_value [Htarget_load Hvalue]].
  rewrite Z.add_0_r in Htarget_load.
  rewrite Hload in Htarget_load.
  inversion Htarget_load. subst target_value.
  inversion Hvalue; subst.
  eauto.
Qed.

Corollary public_pointer_cell_cannot_omit_pointee_from_self_injection :
  forall ge injection before identifier global_block global_offset
      pool_block pool_offset,
    symbols_inject injection ge ge ->
    Mem.inject injection before before ->
    Senv.public_symbol ge identifier = true ->
    Senv.find_symbol ge identifier = Some global_block ->
    Mem.load Mptr before global_block global_offset =
      Some (Vptr pool_block pool_offset) ->
    injection pool_block = None ->
    False.
Proof.
  intros ge injection before identifier global_block global_offset
    pool_block pool_offset Hsymbols Hmemory Hpublic Hsymbol Hload Homitted.
  destruct (public_pointer_cell_forces_pointee_mapping ge injection before
    identifier global_block global_offset pool_block pool_offset
    Hsymbols Hmemory Hpublic Hsymbol Hload) as [delta Hmapped].
  congruence.
Qed.

(** The six unresolved names in the canonical-owner direct closure are kept
    explicit.  Typed Surface/SurfaceNode arguments were already excluded by
    [Area1Rank1ResidualClosure]; public pool globals are why that exclusion is
    not, by itself, an independent-access frame. *)
Definition CanonicalOwnerOutsideCallBoundary : Prop :=
  unresolved_identifiers rank3_us_definitions
    (rank3_us_owner_call_closure 5) =
      [A1R3_USObjects._play_puzzle_jingle;
       R1S_USHelpers._create_sound_spawner;
       R1S_USHelpers._cur_obj_play_sound_2;
       R1S_USHelpers._set_camera_shake_from_point;
       R1S_USHelpers._sqrtf;
       R1S_USSpawn._stop_sounds_from_source] /\
  unresolved_identifiers rank3_jp_definitions
    (rank3_jp_owner_call_closure 5) =
      [A1R3_JPObjects._play_puzzle_jingle;
       R1S_JPHelpers._create_sound_spawner;
       R1S_JPHelpers._cur_obj_play_sound_2;
       R1S_JPHelpers._set_camera_shake_from_point;
       R1S_JPHelpers._sqrtf;
       R1S_JPSpawn._stop_sounds_from_source] /\
  SurfacePoolPublicAliasClaim /\
  SurfacePoolMainPoolOriginClaim /\
  USSurfaceOwnerAliasSourceClaim /\
  JPSurfaceOwnerAliasSourceClaim /\
  USSurfaceNodeLineageSourceClaim /\
  JPSurfaceNodeLineageSourceClaim.

Theorem canonical_owner_outside_call_boundary_holds :
  CanonicalOwnerOutsideCallBoundary.
Proof.
  unfold CanonicalOwnerOutsideCallBoundary.
  split.
  - exact (proj1 rank3_owner_unresolved_call_inventory_checked).
  - split.
    + exact (proj2 rank3_owner_unresolved_call_inventory_checked).
    + exact (conj surface_pool_public_aliases_are_exact
        (conj surface_pools_have_shared_main_pool_origin
        (conj us_surface_owner_alias_source_checked
        (conj jp_surface_owner_alias_source_checked
        (conj us_surface_node_lineage_source_checked
          jp_surface_node_lineage_source_checked))))).
Qed.

(** One of the six outside names is already closed at the authenticated JP
    retail boundary: [sqrtf] consists of a return and one floating-point
    square-root instruction, with no store and no transitive call.  This is a
    machine receipt, not an IDO-to-Clight bridge and not a US-library claim. *)
Definition JPCanonicalOwnerSqrtfMachineFrameClaim : Prop :=
  filter (fun entry => jp_mips_is_store (snd entry))
    (jp_range_code jp_sqrtf_range) = [] /\
  filter (fun entry => jp_mips_is_jal (snd entry) ||
                       jp_mips_is_jalr (snd entry) ||
                       jp_mips_is_linking_branch (snd entry))
    (jp_range_code jp_sqrtf_range) = [].

Theorem jp_canonical_owner_sqrtf_has_no_independent_store :
  JPCanonicalOwnerSqrtfMachineFrameClaim.
Proof. exact jp_retail_sqrtf_is_store_and_call_free. Qed.

(** * Runtime behavior forwarding and PLAYER-list mutation *)

Definition us_object_behavior_direct_writers : list ident :=
  internal_surface_object_assignment_sites
    R1S_USSpawn._Object R1S_USSpawn._behavior rank3_us_definitions.

Definition jp_object_behavior_direct_writers : list ident :=
  internal_surface_object_assignment_sites
    R1S_JPSpawn._Object R1S_JPSpawn._behavior rank3_jp_definitions.

Definition ObjectBehaviorWriterClaim : Prop :=
  us_object_behavior_direct_writers =
    [R1S_USObjects._spawn_objects_from_info;
     R1S_USSpawn._create_object;
     R1S_USHelpers._cur_obj_set_behavior;
     R1S_USHelpers._obj_set_behavior] /\
  jp_object_behavior_direct_writers =
    [R1S_JPObjects._spawn_objects_from_info;
     R1S_JPSpawn._create_object;
     R1S_JPHelpers._cur_obj_set_behavior;
     R1S_JPHelpers._obj_set_behavior] /\
  internal_surface_object_address_sites
    R1S_USSpawn._Object R1S_USSpawn._behavior rank3_us_definitions = [] /\
  internal_surface_object_address_sites
    R1S_JPSpawn._Object R1S_JPSpawn._behavior rank3_jp_definitions = [].

Theorem object_behavior_writer_inventory_is_exact :
  ObjectBehaviorWriterClaim.
Proof.
  unfold ObjectBehaviorWriterClaim,
    us_object_behavior_direct_writers, jp_object_behavior_direct_writers.
  vm_compute. repeat split; reflexivity.
Qed.

Definition ObjectListLinkWriterClaim : Prop :=
  internal_surface_object_assignment_sites
    R1S_USSpawn._ObjectNode R1S_USSpawn._next rank3_us_definitions =
      [R1S_USSpawn._try_allocate_object;
       R1S_USSpawn._deallocate_object;
       R1S_USSpawn._clear_object_lists] /\
  internal_surface_object_assignment_sites
    R1S_USSpawn._ObjectNode R1S_USSpawn._prev rank3_us_definitions =
      [R1S_USSpawn._try_allocate_object;
       R1S_USSpawn._deallocate_object;
       R1S_USSpawn._clear_object_lists] /\
  internal_surface_object_assignment_sites
    R1S_JPSpawn._ObjectNode R1S_JPSpawn._next rank3_jp_definitions =
      [R1S_JPSpawn._try_allocate_object;
       R1S_JPSpawn._deallocate_object;
       R1S_JPSpawn._clear_object_lists] /\
  internal_surface_object_assignment_sites
    R1S_JPSpawn._ObjectNode R1S_JPSpawn._prev rank3_jp_definitions =
      [R1S_JPSpawn._try_allocate_object;
       R1S_JPSpawn._deallocate_object;
       R1S_JPSpawn._clear_object_lists] /\
  internal_function_direct_call_sites R1S_USSpawn._try_allocate_object
    rank3_us_definitions = [R1S_USSpawn._allocate_object] /\
  internal_function_direct_call_sites R1S_JPSpawn._try_allocate_object
    rank3_jp_definitions = [R1S_JPSpawn._allocate_object] /\
  internal_function_direct_call_sites R1S_USSpawn._allocate_object
    rank3_us_definitions = [R1S_USSpawn._create_object] /\
  internal_function_direct_call_sites R1S_JPSpawn._allocate_object
    rank3_jp_definitions = [R1S_JPSpawn._create_object] /\
  internal_function_direct_call_sites R1S_USSpawn._create_object
    rank3_us_definitions =
      [R1S_USObjects._spawn_objects_from_info;
       R1S_USHelpers._spawn_object_at_origin] /\
  internal_function_direct_call_sites R1S_JPSpawn._create_object
    rank3_jp_definitions =
      [R1S_JPObjects._spawn_objects_from_info;
       R1S_JPHelpers._spawn_object_at_origin].

Theorem object_list_link_writer_and_constructor_chain_is_exact :
  ObjectListLinkWriterClaim.
Proof.
  unfold ObjectListLinkWriterClaim.
  vm_compute. repeat split; reflexivity.
Qed.

(** Retargeting the global list base is another way a forged PLAYER tail could
    bypass ordinary node insertion.  All four direct writers copy the same
    canonical array, exactly once.  Likewise [gMarioObject] has only its spawn
    assignment and clear-to-null writer, and its pointer cell is never passed
    by address in the selected source. *)
Fixpoint rank1_global_assignment_count_s
    (target : ident) (body : statement) : nat :=
  match body with
  | Sassign (Evar found _) _ =>
      if Pos.eqb found target then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (rank1_global_assignment_count_s target first +
       rank1_global_assignment_count_s target second)%nat
  | Sifthenelse _ yes no =>
      (rank1_global_assignment_count_s target yes +
       rank1_global_assignment_count_s target no)%nat
  | Sswitch _ cases => rank1_global_assignment_count_ls target cases
  | Slabel _ nested => rank1_global_assignment_count_s target nested
  | _ => 0%nat
  end
with rank1_global_assignment_count_ls
    (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (rank1_global_assignment_count_s target body +
       rank1_global_assignment_count_ls target rest)%nat
  end.

Fixpoint rank1_global_copy_count_s
    (target source : ident) (body : statement) : nat :=
  match body with
  | Sassign (Evar found_target _) (Evar found_source _) =>
      if Pos.eqb found_target target && Pos.eqb found_source source
      then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (rank1_global_copy_count_s target source first +
       rank1_global_copy_count_s target source second)%nat
  | Sifthenelse _ yes no =>
      (rank1_global_copy_count_s target source yes +
       rank1_global_copy_count_s target source no)%nat
  | Sswitch _ cases => rank1_global_copy_count_ls target source cases
  | Slabel _ nested => rank1_global_copy_count_s target source nested
  | _ => 0%nat
  end
with rank1_global_copy_count_ls
    (target source : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (rank1_global_copy_count_s target source body +
       rank1_global_copy_count_ls target source rest)%nat
  end.

Definition us_player_list_root_writer_bodies : list Clight.function :=
  [R1S_USObjects.f_unload_objects_from_area;
   R1S_USObjects.f_spawn_objects_from_info;
   R1S_USObjects.f_clear_objects;
   R1S_USObjects.f_update_objects].

Definition jp_player_list_root_writer_bodies : list Clight.function :=
  [R1S_JPObjects.f_unload_objects_from_area;
   R1S_JPObjects.f_spawn_objects_from_info;
   R1S_JPObjects.f_clear_objects;
   R1S_JPObjects.f_update_objects].

Definition PlayerListRootAndMarioGlobalWriterClaim : Prop :=
  internal_function_assignment_sites R1S_USObjects._gObjectLists
    rank3_us_definitions =
      [R1S_USObjects._unload_objects_from_area;
       R1S_USObjects._spawn_objects_from_info;
       R1S_USObjects._clear_objects;
       R1S_USObjects._update_objects] /\
  internal_function_assignment_sites R1S_JPObjects._gObjectLists
    rank3_jp_definitions =
      [R1S_JPObjects._unload_objects_from_area;
       R1S_JPObjects._spawn_objects_from_info;
       R1S_JPObjects._clear_objects;
       R1S_JPObjects._update_objects] /\
  map (fun body =>
    (rank1_global_assignment_count_s R1S_USObjects._gObjectLists
       (fn_body body),
     rank1_global_copy_count_s R1S_USObjects._gObjectLists
       R1S_USObjects._gObjectListArray (fn_body body)))
    us_player_list_root_writer_bodies =
      [(1%nat, 1%nat); (1%nat, 1%nat);
       (1%nat, 1%nat); (1%nat, 1%nat)] /\
  map (fun body =>
    (rank1_global_assignment_count_s R1S_JPObjects._gObjectLists
       (fn_body body),
     rank1_global_copy_count_s R1S_JPObjects._gObjectLists
       R1S_JPObjects._gObjectListArray (fn_body body)))
    jp_player_list_root_writer_bodies =
      [(1%nat, 1%nat); (1%nat, 1%nat);
       (1%nat, 1%nat); (1%nat, 1%nat)] /\
  internal_function_assignment_sites R1S_USObjects._gMarioObject
    rank3_us_definitions =
      [R1S_USObjects._spawn_objects_from_info;
       R1S_USObjects._clear_objects] /\
  internal_function_assignment_sites R1S_JPObjects._gMarioObject
    rank3_jp_definitions =
      [R1S_JPObjects._spawn_objects_from_info;
       R1S_JPObjects._clear_objects] /\
  internal_function_address_sites R1S_USObjects._gMarioObject
    rank3_us_definitions = [] /\
  internal_function_address_sites R1S_JPObjects._gMarioObject
    rank3_jp_definitions = [].

Theorem player_list_root_and_mario_global_writers_are_exact :
  PlayerListRootAndMarioGlobalWriterClaim.
Proof.
  unfold PlayerListRootAndMarioGlobalWriterClaim,
    us_player_list_root_writer_bodies, jp_player_list_root_writer_bodies.
  vm_compute. repeat split; reflexivity.
Qed.

(** The one unresolved helper that really does allocate an object is
    [create_sound_spawner].  Its public source implementation is outside the
    selected 38-unit program, so this does not supply that function's full
    effect.  It does close the specific duplicate-PLAYER concern: the exact
    spawned behavior begins in list 12 and its only native initializer target
    is the sound callback. *)
Definition SoundSpawnerNonPlayerClaim : Prop :=
  behavior_begin_list_index (gvar_init R1S_USData.v_bhvSoundSpawner) =
    Some 12 /\
  behavior_begin_list_index (gvar_init R1S_JPData.v_bhvSoundSpawner) =
    Some 12 /\
  initializer_addrof_idents (gvar_init R1S_USData.v_bhvSoundSpawner) =
    [R1S_USActions._bhv_sound_spawner_init] /\
  initializer_addrof_idents (gvar_init R1S_JPData.v_bhvSoundSpawner) =
    [R1S_JPActions._bhv_sound_spawner_init] /\
  calls_ident_s R1S_USActions._play_sound
    (fn_body R1S_USActions.f_bhv_sound_spawner_init) = true /\
  calls_ident_s R1S_JPActions._play_sound
    (fn_body R1S_JPActions.f_bhv_sound_spawner_init) = true.

Theorem sound_spawner_cannot_extend_the_player_list :
  SoundSpawnerNonPlayerClaim.
Proof.
  unfold SoundSpawnerNonPlayerClaim, behavior_begin_list_index.
  vm_compute. repeat split; reflexivity.
Qed.

(** Changing [Object.behavior] after allocation does not move the already
    linked node to another object list.  Thus the two behavior setters are not
    PLAYER-node constructors; [create_object] is the only checked constructor
    above, and [spawn_objects_from_info] only repeats its returned pointer.  A
    linked proof still has to classify every live argument passed to
    [create_object] and every direct list-link mutation. *)
Definition OrdinaryPlayerIngressBoundary : Prop :=
  USOrdinaryPlayerIngressSourceClaim /\
  JPOrdinaryPlayerIngressSourceClaim /\
  Area1PlayerListTailCheckedBoundary /\
  ObjectBehaviorWriterClaim /\
  ObjectListLinkWriterClaim /\
  PlayerListRootAndMarioGlobalWriterClaim /\
  SoundSpawnerNonPlayerClaim.

Theorem ordinary_player_ingress_boundary_holds :
  OrdinaryPlayerIngressBoundary.
Proof.
  exact (conj us_ordinary_player_ingress_source_checked
    (conj jp_ordinary_player_ingress_source_checked
    (conj area1_player_list_tail_checked_boundary_holds
    (conj object_behavior_writer_inventory_is_exact
    (conj object_list_link_writer_and_constructor_chain_is_exact
    (conj player_list_root_and_mario_global_writers_are_exact
      sound_spawner_cannot_extend_the_player_list)))))).
Qed.

(** * Stock geometry and the genuine lifecycle survivor *)

Definition StockAlternativeFloorNoGoBoundary : Prop :=
  (forall position platform,
    upper_warp_contact position ->
    stock_area1_final_platform_query position platform ->
    platform = None) /\
  (forall collision final_query platform,
    upper_warp_contact collision ->
    position_x final_query = position_x collision ->
    position_z final_query = position_z collision ->
    position_y final_query <= 896 ->
    stock_area1_final_platform_query final_query platform ->
    platform = None).

Theorem stock_alternative_floor_no_go_boundary_holds :
  StockAlternativeFloorNoGoBoundary.
Proof.
  split.
  - exact stock_upper_warp_final_query_clears_platform.
  - exact warp_horizontal_low_y_stock_query_is_null.
Qed.

Definition GenuineLifetimeSurvivorBoundary : Prop :=
  lifecycle_dynamic_surface_owner inactive_unreused_survivor = None /\
  lifecycle_cached_platform inactive_unreused_survivor =
    Some (lifecycle_pointer_of_payload inactive_unreused_survivor_payload) /\
  lifecycle_cell_allocated
    (lifecycle_slot_cell inactive_unreused_survivor) = false /\
  lifecycle_cell_active
    (lifecycle_slot_cell inactive_unreused_survivor) = false /\
  lifecycle_state_y inactive_unreused_survivor <>
    lifecycle_object_y inactive_unreused_survivor /\
  state_first_lifecycle_first_apply_active
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_first_apply_free_depth
    jp_area1_state_first_lifecycle_trace = 47 /\
  state_first_lifecycle_first_apply_entry_seen
    jp_area1_state_first_lifecycle_trace = true /\
  state_first_lifecycle_first_apply_return_seen
    jp_area1_state_first_lifecycle_trace = true.

Theorem genuine_lifetime_survivor_boundary_holds :
  GenuineLifetimeSurvivorBoundary.
Proof.
  unfold GenuineLifetimeSurvivorBoundary.
  pose proof inactive_unreused_payload_is_a_concrete_lifecycle_survivor
    as Hbounded.
  pose proof jp_area1_state_first_lifecycle_record_checked as Hretail.
  repeat split.
  all: try tauto.
Qed.

(** One audit target which exposes, without overclaiming, what is closed and
    what remains a linked semantic interface. *)
Definition Area1Rank1SixResidualAuditBoundary : Prop :=
  CurrentObjectOrdinaryInstallBoundary /\
  CanonicalOwnerOutsideCallBoundary /\
  JPCanonicalOwnerSqrtfMachineFrameClaim /\
  OrdinaryPlayerIngressBoundary /\
  StockAlternativeFloorNoGoBoundary /\
  GenuineLifetimeSurvivorBoundary.

Theorem area1_rank1_six_residual_audit_boundary_holds :
  Area1Rank1SixResidualAuditBoundary.
Proof.
  exact (conj current_object_ordinary_install_boundary_holds
    (conj canonical_owner_outside_call_boundary_holds
    (conj jp_canonical_owner_sqrtf_has_no_independent_store
    (conj ordinary_player_ingress_boundary_holds
    (conj stock_alternative_floor_no_go_boundary_holds
      genuine_lifetime_survivor_boundary_holds))))).
Qed.
