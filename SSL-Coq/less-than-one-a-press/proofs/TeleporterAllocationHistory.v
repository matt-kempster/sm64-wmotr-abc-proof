(** A concrete allocation boundary following a concrete unload.  The pool
    slot returned to the free list can immediately be returned by the real
    allocator.  Consequently a pointer is not an allocation identity.  This
    theorem does not assert a live/free partition for arbitrary later frames,
    or that the old Bob-omb's allocation episode reaches Area 2. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_spawn_object jp_spawn_object.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution InkCopyCaller ContactConsumerExecution
  SelectedClightTarget TeleporterObjectLifetime TeleporterUnloadTraversal
  SecretContactExecution UpperElevatorQueryResolution CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.
Module TAH := us_spawn_object.

Definition tah_try_function version := match version with
| VersionUS => us_spawn_object.f_try_allocate_object
| VersionJP => jp_spawn_object.f_try_allocate_object end.
Definition tah_free_head_read := Efield
  (Ederef (Etempvar TAH._freeList (tptr (Tstruct TAH._ObjectNode noattr)))
    (Tstruct TAH._ObjectNode noattr)) TAH._next
  (tptr (Tstruct TAH._ObjectNode noattr)).
Definition tah_capture := Ssequence
  (Ssequence (Sset TAH._t'5 tah_free_head_read)
    (Sset TAH._t'1
      (Ecast (Etempvar TAH._t'5 (tptr (Tstruct TAH._ObjectNode noattr)))
        (tptr (Tstruct TAH._ObjectNode noattr)))))
  (Sset TAH._nextObj (Etempvar TAH._t'1 (tptr (Tstruct TAH._ObjectNode noattr)))).
Definition tah_guard := Ebinop One
  (Etempvar TAH._t'1 (tptr (Tstruct TAH._ObjectNode noattr)))
  (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint.
Definition tah_choice version := match fn_body (tah_try_function version) with
| Ssequence (Ssequence _ choice) _ => choice | _ => Sskip end.
Definition tah_link_branch version := match tah_choice version with
| Sifthenelse _ branch _ => branch | _ => Sskip end.
Definition tah_link_prefix version := Ssequence tah_capture (tah_choice version).
Definition tah_tail version := match fn_body (tah_try_function version) with
| Ssequence _ tail => tail | _ => Sskip end.
Definition tah_tail_calls version := ocn_prefix_items 2 (tah_tail version).
Definition tah_return := Sreturn (Some
  (Ecast (Etempvar TAH._nextObj (tptr (Tstruct TAH._ObjectNode noattr)))
    (tptr (Tstruct TAH._Object noattr)))).

Lemma tah_generated_try_cuts : forall version,
  fn_body (tah_try_function version) =
    Ssequence (tah_link_prefix version) (tah_tail version) /\
  tah_choice version = Sifthenelse tah_guard (tah_link_branch version)
    (Sreturn (Some (Ecast (Econst_int Int.zero tint) (tptr tvoid)))) /\
  ibk_normal tah_capture = true /\
  ibk_normal (tah_link_branch version) = true /\
  tul_keeps_temp TAH._nextObj (tah_link_branch version) = true /\
  tah_tail version = ocn_prepend (tah_tail_calls version) tah_return /\
  forallb ibk_normal (tah_tail_calls version) = true /\
  tul_keeps_temp TAH._nextObj
    (ocn_prepend (tah_tail_calls version) Sskip) = true /\
  fn_vars (tah_try_function version) = [] /\
  fn_params (tah_try_function version) =
    [(TAH._destList, tptr (Tstruct TAH._ObjectNode noattr));
     (TAH._freeList, tptr (Tstruct TAH._ObjectNode noattr))].
Proof. intros []; repeat split; reflexivity. Qed.

Lemma tah_actual_free_head_read : forall version e le memory fb fo ob oo answer,
  le ! TAH._freeList = Some (Vptr fb fo) ->
  Mem.load Mptr memory fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le memory
    tah_free_head_read answer -> answer = Vptr ob oo.
Proof.
  intros version e le memory fb fo ob oo answer Hfree Hload Hread.
  unfold tah_free_head_read in Hread. inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _
      (Ederef (Etempvar TAH._freeList (tptr (Tstruct TAH._ObjectNode noattr)))
        (Tstruct TAH._ObjectNode noattr)) TAH._ObjectNode TAH._next
      (tptr (Tstruct TAH._ObjectNode noattr)) fb fo 96 _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Hfree|eassumption])
      (tul_selected_next_layout version) Hl) as (-> & -> & ->) end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hd; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hr : Mem.loadv _ _ _ = Some _ |- _ =>
    change (Mem.load Mptr memory fb
      (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some answer) in Hr;
    congruence end.
Qed.

Lemma tah_capture_reads_head : forall version e le before fb fo ob oo tr last after out,
  le ! TAH._freeList = Some (Vptr fb fo) ->
  Mem.load Mptr before fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tah_capture tr last after out ->
  after = before /\ last ! TAH._t'1 = Some (Vptr ob oo) /\
    last ! TAH._nextObj = Some (Vptr ob oo).
Proof.
  intros version e le before fb fo ob oo tr last after out Hfree Hload Hrun.
  unfold tah_capture in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  match goal with Hr : eval_expr _ _ _ _ tah_free_head_read ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply tah_actual_free_head_read; eauto); subst v end.
  match goal with Hr : eval_expr ?ge ?env ?temps ?memory (Ecast ?arg ?ty) ?v |- _ =>
    assert (eval_expr ge env temps memory (Ecast arg ty) (Vptr ob oo)) as Hvalue by
      (eapply eval_Ecast; [apply eval_Etempvar; apply PTree.gss|reflexivity]);
    assert (v = Vptr ob oo) by (eapply ocr_expr_unique; eauto); subst v end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar TAH._t'1 _) ?v |- _ =>
    assert (v = Vptr ob oo) by
      (eapply ocn_temp_value; [exact Hr|apply PTree.gss]); subst v end.
  repeat split; try reflexivity.
  - rewrite PTree.gso by discriminate. apply PTree.gss.
  - apply PTree.gss.
Qed.

Lemma tah_pointer_head_cannot_fail : forall ge e le memory ob oo,
  le ! TAH._t'1 = Some (Vptr ob oo) ->
  ~ ocn_test_value ge e le memory tah_guard false.
Proof.
  intros ge e le memory ob oo Hhead [answer [Hexpr Hbool]].
  unfold tah_guard in Hexpr. inversion Hexpr; subst.
  - match goal with Htemp : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
      assert (v = Vptr ob oo) by (eapply ocn_temp_value; eauto); subst v end.
    match goal with Hcast : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      inversion Hcast; subst end.
    match goal with Hconst : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      apply ocn_const_int_value in Hconst; subst end.
    match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn in Hcast; inversion Hcast; subst end.
    match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some answer |- _ =>
      change (option_map Val.of_bool
        (Val.cmpu_bool (Mem.valid_pointer memory) Cne (Vptr ob oo)
          (Vint Int.zero)) = Some answer) in Hsem;
      cbn [Val.cmpu_bool] in Hsem;
      repeat match type of Hsem with context [if ?test then _ else _] =>
        destruct test eqn:?; cbn in Hsem; try discriminate end;
      inversion Hsem; subst; discriminate
    end.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inversion Hl end.
  - match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hl end.
Qed.

Lemma tah_link_prefix_succeeds_on_pointer_head : forall version e le before
    fb fo ob oo tr last after out,
  le ! TAH._freeList = Some (Vptr fb fo) ->
  Mem.load Mptr before fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tah_link_prefix version) tr last after out ->
  out = Out_normal /\ last ! TAH._nextObj = Some (Vptr ob oo).
Proof.
  intros version e le before fb fo ob oo tr last after out Hfree Hload Hrun.
  destruct (tah_generated_try_cuts version)
    as (_ & Hchoice & Hcapture & Hnormal & Hkeep & _).
  unfold tah_link_prefix in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hcapture Hrun)
    as (middle & memory & pre & tail & Htrace & Hread & Hbranch).
  destruct (tah_capture_reads_head _ _ _ _ _ _ _ _ _ _ _ _ Hfree Hload Hread)
    as (-> & Hhead & Hnext).
  rewrite Hchoice in Hbranch. inversion Hbranch; subst.
  destruct b; cbn in *.
  - split.
    + eapply ibk_normal_outcome; eauto.
    + match goal with Hr : ClightBigstep.exec_stmt _ _ _ _ _
        (tah_link_branch _) _ _ _ _ |- _ =>
        rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hr _ Hkeep);
        exact Hnext end.
  - exfalso. eapply tah_pointer_head_cannot_fail; [exact Hhead|].
    eexists; eauto.
Qed.

Lemma tah_tail_returns_captured_pointer : forall version e le before ob oo
    tr last after out,
  le ! TAH._nextObj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tah_tail version) tr last after out ->
  out = Out_return (Some (Vptr ob oo, tptr (Tstruct TAH._Object noattr))).
Proof.
  intros version e le before ob oo tr last after out Hnext Hrun.
  destruct (tah_generated_try_cuts version)
    as (_ & _ & _ & _ & _ & Htail & Hnormal & Hkeep & _).
  rewrite Htail in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (middle & memory & pre & tail & Htrace & Hcalls & Hreturn).
  assert (middle ! TAH._nextObj = Some (Vptr ob oo)) as Hcaptured.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hcalls _ Hkeep).
    exact Hnext. }
  unfold tah_return in Hreturn. inversion Hreturn; subst.
  match goal with Hr : eval_expr ?ge ?env ?temps ?mem (Ecast ?arg ?ty) ?v |- _ =>
    assert (eval_expr ge env temps mem (Ecast arg ty) (Vptr ob oo)) as Hvalue by
      (eapply eval_Ecast; [apply eval_Etempvar; exact Hcaptured|reflexivity]);
    assert (v = Vptr ob oo) by (eapply ocr_expr_unique; eauto); subst v end.
  reflexivity.
Qed.

Theorem tah_complete_try_body_returns_head : forall version e le before
    fb fo ob oo tr last after out,
  le ! TAH._freeList = Some (Vptr fb fo) ->
  Mem.load Mptr before fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (fn_body (tah_try_function version)) tr last after out ->
  out = Out_return (Some (Vptr ob oo, tptr (Tstruct TAH._Object noattr))).
Proof.
  intros version e le before fb fo ob oo tr last after out Hfree Hload Hrun.
  rewrite (proj1 (tah_generated_try_cuts version)) in Hrun.
  inversion Hrun; subst.
  - match goal with Hprefix : ClightBigstep.exec_stmt _ _ _ _ _
      (tah_link_prefix _) _ _ _ _ |- _ =>
      destruct (tah_link_prefix_succeeds_on_pointer_head _ _ _ _ _ _ _ _ _ _ _ _
        Hfree Hload Hprefix) as (_ & Hnext) end.
    eapply tah_tail_returns_captured_pointer; eauto.
  - match goal with Hprefix : ClightBigstep.exec_stmt _ _ _ _ _
      (tah_link_prefix _) _ _ _ _ |- _ =>
      destruct (tah_link_prefix_succeeds_on_pointer_head _ _ _ _ _ _ _ _ _ _ _ _
        Hfree Hload Hprefix) as (Hnormal & _); contradiction end.
Qed.

Theorem tah_complete_try_call_returns_head : forall version before
    db dofs fb fo ob oo tr after result,
  Mem.load Mptr before fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tah_try_function version)) [Vptr db dofs; Vptr fb fo]
    tr after result ->
  result = Vptr ob oo.
Proof.
  intros version before db dofs fb fo ob oo tr after result Hhead Hcall.
  destruct (tah_generated_try_cuts version)
    as (_ & _ & _ & _ & _ & _ & _ & _ & Hvars & Hparams).
  inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb;
    inversion Hb; subst temps end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _
      (fn_body (tah_try_function _)) _ _ _ ?out |- _ =>
    assert (out = Out_return
      (Some (Vptr ob oo, tptr (Tstruct TAH._Object noattr)))) as Hout by
      (eapply tah_complete_try_body_returns_head;
        [apply PTree.gss|exact Hhead|exact Hbody]); subst out end.
  match goal with Hvalue : outcome_result_value _ _ _ _ |- _ =>
    replace (fn_return (tah_try_function version))
      with (tptr (Tstruct TAH._Object noattr)) in Hvalue
      by (destruct version; reflexivity);
    cbn in Hvalue; destruct Hvalue as [_ Hvalue];
    change (Some (Vptr ob oo) = Some result) in Hvalue; congruence end.
Qed.

Lemma tah_us_try_source :
  nth_error us_spawn_object.global_definitions
    (ueqr_definition_index TAH._try_allocate_object us_spawn_object.global_definitions) =
  Some (TAH._try_allocate_object, Gfun (Internal (tah_try_function VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma tah_us_try_member :
  In (TAH._try_allocate_object, Gfun (Internal (tah_try_function VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 18 us_units).
  - exact (us_nlist_at_nIn _ 18 us_units).
  - change (In (TAH._try_allocate_object,
      Gfun (Internal (tah_try_function VersionUS))) us_spawn_object.global_definitions).
    eapply nth_error_In. exact tah_us_try_source.
Qed.
Lemma tah_us_try_selection :
  us_normalized_global_definition_map ! TAH._try_allocate_object =
    Some (Gfun (Internal (tah_try_function VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact tah_us_try_member.
Qed.
Lemma tah_us_try_selected_member :
  In (TAH._try_allocate_object, Gfun (Internal (tah_try_function VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (TAH._try_allocate_object, Gfun (Internal (tah_try_function VersionUS))) = false)
      as Hrepair by (vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact tah_us_try_selection.
Qed.
Theorem tah_selected_try_allocate_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TAH._try_allocate_object = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tah_try_function version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact tah_us_try_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 18 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 18 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.

Definition tah_allocate_function version := match version with
| VersionUS => us_spawn_object.f_allocate_object
| VersionJP => jp_spawn_object.f_allocate_object end.
Definition tah_allocate_initial_call := Scall (Some TAH._t'1)
  (Evar TAH._try_allocate_object
    (Tfunction [tptr (Tstruct TAH._ObjectNode noattr);
      tptr (Tstruct TAH._ObjectNode noattr)]
      (tptr (Tstruct TAH._Object noattr)) cc_default))
  [Etempvar TAH._objList (tptr (Tstruct TAH._ObjectNode noattr));
   Eaddrof (Evar TAH._gFreeObjectList (Tstruct TAH._ObjectNode noattr))
     (tptr (Tstruct TAH._ObjectNode noattr))].
Lemma tah_allocate_initial_call_is_generated : forall version,
  match fn_body (tah_allocate_function version) with
  | Ssequence (Ssequence call _) _ => call | _ => Sskip end =
    tah_allocate_initial_call.
Proof. intros []; reflexivity. Qed.

Theorem tah_reached_allocate_initial_call_returns_head :
  forall version e le before fb db dofs ob oo tr last after out,
  e ! TAH._try_allocate_object = None ->
  e ! TAH._gFreeObjectList = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TAH._gFreeObjectList = Some fb ->
  le ! TAH._objList = Some (Vptr db dofs) ->
  Mem.load Mptr before fb 96 = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tah_allocate_initial_call tr last after out ->
  last ! TAH._t'1 = Some (Vptr ob oo) /\ out = Out_normal.
Proof.
  intros version e le before fb db dofs ob oo tr last after out
    Hlocal HfreeLocal Hsymbol Hlist Hhead Hrun.
  destruct (tah_selected_try_allocate_resolves version) as (b & HfunctionSymbol & Hfunction).
  unfold tah_allocate_initial_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  lazymatch goal with Hexpr : eval_expr ?ge0 ?env0 ?temps0 ?memory0
      (Evar ?id (Tfunction ?args ?ret ?cc)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by
      (exact (sce_function_name_value ge0 env0 temps0 memory0 id args ret cc b vf
        Hlocal HfunctionSymbol Hexpr)); subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b = Some fd)
      in Hfind; rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hty : type_of_fundef _ = _ |- _ =>
    assert (type_of_fundef (Internal (tah_try_function version)) =
      Tfunction [tptr (Tstruct TAH._ObjectNode noattr);
        tptr (Tstruct TAH._ObjectNode noattr)]
        (tptr (Tstruct TAH._Object noattr)) cc_default) as Ety
      by (destruct version; reflexivity);
    rewrite Ety in Hty; inversion Hty; subst end.
  repeat match goal with Ha : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar TAH._objList _) ?v |- _ =>
    assert (v = Vptr db dofs) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hr : eval_expr _ _ _ _ (Eaddrof (Evar _ _) _) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by
      (eapply tul_actual_free_list_address; eauto); subst v end.
  repeat match goal with Hcast : sem_cast (Vptr ?vb ?vo) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr vb vo) = Some v) in Hcast;
    inversion Hcast; subst v; clear Hcast end.
  lazymatch goal with Hcall : ClightBigstep.eval_funcall _ _ _ _ _ _ _ ?result |- _ =>
    assert (result = Vptr ob oo) as Hreturned by
      (eapply (tah_complete_try_call_returns_head version before db dofs fb
        Ptrofs.zero ob oo tr after); [exact Hhead|exact Hcall]); subst result end.
  split; [apply PTree.gss|reflexivity].
Qed.

(** The second call is the actual generated allocator, started in exactly
    the memory returned by the actual generated unload.  The conclusion is
    address reuse, not survival of the previous allocation episode. *)
Definition TeleporterUnloadThenAllocationReusesSlot : Prop :=
  forall version before freed after fb ob oo db dofs unload_trace allocation_trace
    unload_result allocation_result,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TAH._gFreeObjectList = Some fb ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tol_unload_function version)) [Vptr ob oo]
    unload_trace freed unload_result ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) freed
    (Internal (tah_try_function version)) [Vptr db dofs; Vptr fb Ptrofs.zero]
    allocation_trace after allocation_result ->
  allocation_result = Vptr ob oo.

Theorem teleporter_unload_then_allocation_reuses_slot :
  TeleporterUnloadThenAllocationReusesSlot.
Proof.
  intros version before freed after fb ob oo db dofs unload_trace allocation_trace
    unload_result allocation_result Hsymbol Hunload Hallocate.
  pose proof (tul_complete_unload_call_returns_free_head _ _ _ _ _ _ _ _
    Hsymbol Hunload) as Hhead.
  eapply tah_complete_try_call_returns_head; [|exact Hallocate].
  exact Hhead.
Qed.
