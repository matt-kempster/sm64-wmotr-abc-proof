(** Actual generated initializer suffixes, exposed as chronological memory
    effects.  The finite leaf census below names the real remaining calls;
    preservation is derived from disjoint stores and individual call frames,
    never supplied as a frame assumption for the complete suffix. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario jp_mario.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  TeleporterWrongWarpBoundary TeleporterDestinationReset InkBodyResetFrame
  InkBodyResetConstruction SelectedClightTarget InkBackwardExecution
  InkCopyCaller InkSharedReadings EyerokRank15LiveMovement.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Fixpoint tif_leaves (s : statement) : list statement :=
  match s with
  | Sassign _ _ | Scall _ _ _ => [s]
  | Ssequence first rest | Sifthenelse _ first rest =>
      tif_leaves first ++ tif_leaves rest
  | _ => [] end.

Fixpoint tif_call_ids (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence first rest | Sifthenelse _ first rest =>
      tif_call_ids first ++ tif_call_ids rest
  | _ => [] end.

Inductive TIFMemoryEvent : Type :=
| TIFAssignment (temps : temp_env) (lhs rhs : expr) (before after : mem)
    (target : block) (offset : ptrofs) (bits : bitfield) (value : val)
| TIFCall (temps : temp_env) (optid : option ident) (callee : expr) (actuals : list expr)
    (before after : mem) (fd : Clight.fundef) (args : list val)
    (trace : trace) (result : val).

Definition tif_event_node event := match event with
| TIFAssignment _ lhs rhs _ _ _ _ _ _ => Sassign lhs rhs
| TIFCall _ optid callee actuals _ _ _ _ _ _ => Scall optid callee actuals end.
Definition tif_event_before event := match event with
| TIFAssignment _ _ _ before _ _ _ _ _ => before
| TIFCall _ _ _ _ before _ _ _ _ _ => before end.
Definition tif_event_after event := match event with
| TIFAssignment _ _ _ _ after _ _ _ _ => after
| TIFCall _ _ _ _ _ after _ _ _ _ => after end.
Definition tif_event_valid (ge : genv) (e : env) event : Prop := match event with
| TIFAssignment temps lhs rhs before after target offset bits value =>
    exists raw,
      eval_lvalue ge e temps before lhs target offset bits /\
      eval_expr ge e temps before rhs raw /\
      sem_cast raw (typeof rhs) (typeof lhs) before = Some value /\
      assign_loc ge (typeof lhs) before target offset bits value after
| TIFCall temps _ callee actuals before after fd args trace result =>
    exists tyargs tyres cconv vf,
      classify_fun (typeof callee) = fun_case_f tyargs tyres cconv /\
      eval_expr ge e temps before callee vf /\
      eval_exprlist ge e temps before actuals tyargs args /\
      Genv.find_funct ge vf = Some fd /\
      type_of_fundef fd = Tfunction tyargs tyres cconv /\
      ClightBigstep.Clight2.eval_funcall ge before fd args trace after result end.

Inductive TIFMemoryChain : mem -> list TIFMemoryEvent -> mem -> Prop :=
| tif_chain_nil : forall memory, TIFMemoryChain memory [] memory
| tif_chain_cons : forall event events after,
    TIFMemoryChain (tif_event_after event) events after ->
    TIFMemoryChain (tif_event_before event) (event :: events) after.

Lemma tif_chain_append : forall before first middle,
  TIFMemoryChain before first middle -> forall second after,
  TIFMemoryChain middle second after ->
  TIFMemoryChain before (first ++ second) after.
Proof.
  intros before first middle Hfirst. induction Hfirst; intros second finish Hsecond.
  - exact Hsecond.
  - cbn. constructor. eauto.
Qed.

Definition tif_mario_pointer := tptr (Tstruct us_mario._MarioState noattr).
Definition tif_object_pointer := tptr (Tstruct us_mario._Object noattr).
Definition tif_state_read := Evar us_mario._gMarioState tif_mario_pointer.
Definition tif_neighbor_reset temp field := Ssequence
  (Sset temp tif_state_read)
  (Sassign (ibr_field temp us_mario._MarioState field tif_object_pointer)
    (Ecast (Econst_int Int.zero tint) (tptr tvoid))).
Definition tif_ridden_reset := tif_neighbor_reset us_mario._t'89 us_mario._riddenObj.
Definition tif_used_reset := tif_neighbor_reset us_mario._t'88 us_mario._usedObj.
Definition tif_neighbor_prefix := Ssequence tif_ridden_reset
  (Ssequence tif_used_reset Sskip).
Definition tif_after_neighbors version :=
  tww_drop_sequence_prefix 2 (tdr_init_after_held version).

Theorem tif_generated_neighbor_prefix_exact : forall version,
  tdr_init_after_held version = Ssequence tif_ridden_reset
    (Ssequence tif_used_reset (tif_after_neighbors version)).
Proof. intros []; reflexivity. Qed.

Lemma tif_global_state_read_value : forall (ge : genv) e le memory gs mb value,
  e ! us_mario._gMarioState = None ->
  Genv.find_symbol ge us_mario._gMarioState = Some gs ->
  Mem.load Mptr memory gs 0 = Some (Vptr mb Ptrofs.zero) ->
  eval_expr ge e le memory tif_state_read value ->
  value = Vptr mb Ptrofs.zero.
Proof.
  intros ge e le memory gs mb value Hlocal Hsymbol Hload Hread.
  inversion Hread; subst.
  match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    inversion Hlv; subst; try congruence end.
  match goal with Hfind : Genv.find_symbol _ _ = Some ?found |- _ =>
    assert (found = gs) by congruence; subst found end.
  match goal with Hderef : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hderef; subst; try discriminate end.
  match goal with Haccess : access_mode _ = By_value _ |- _ =>
    cbn [tif_state_read tif_mario_pointer tptr access_mode] in Haccess;
    inversion Haccess; subst end.
  match goal with Hr : Mem.loadv _ _ _ = Some _ |- _ =>
    change (Mem.load Mptr memory gs 0 = Some value) in Hr; congruence end.
Qed.

Lemma tif_neighbor_reset_frames : forall version e le before temp field delta
    gs mb trace last after out,
  e ! us_mario._gMarioState = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_mario._gMarioState = Some gs ->
  Mem.load Mptr before gs 0 = Some (Vptr mb Ptrofs.zero) ->
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    us_mario._MarioState field delta = true ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tif_neighbor_reset temp field) trace last after out ->
  trace = E0 /\ out = Out_normal /\
  (forall cell, ibr_cell_disjoint mb Mptr
    (Ptrofs.unsigned (Ptrofs.repr delta)) cell ->
    ink_read after cell = ink_read before cell).
Proof.
  intros version e le before temp field delta gs mb trace last after out
    Hlocal Hsymbol Hload Hlayout Hrun.
  unfold tif_neighbor_reset in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (Sset temp tif_state_read) _ _ _ _ _
    eq_refl Hrun) as (middle & memory & pre & suf & Htrace & Hread & Hwrite).
  inversion Hread; subst; clear Hread.
  match goal with Hr : eval_expr _ _ _ _ tif_state_read ?value |- _ =>
    assert (value = Vptr mb Ptrofs.zero) by
      (eapply tif_global_state_read_value; eauto); subst value end.
  destruct (ibr_field_assignment_store _ e _ _ temp us_mario._MarioState
    field tif_object_pointer delta Mptr _ _ _ _ _ mb Ptrofs.zero
    ltac:(apply PTree.gss) Hlayout eq_refl Hwrite)
    as (-> & _ & -> & value & Hstore).
  split; [reflexivity|]. split; [reflexivity|].
  intros cell Hseparate. eapply ibr_single_store_frames; [exact Hstore|].
  unfold ibr_cell_disjoint in *. rewrite Ptrofs.add_zero_l. exact Hseparate.
Qed.

Lemma tif_selected_neighbor_layouts : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    us_mario._MarioState us_mario._riddenObj 132 = true /\
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    us_mario._MarioState us_mario._usedObj 128 = true.
Proof.
  intro version.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    us_mario._MarioState us_mario._riddenObj 132 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version))
    us_mario._MarioState us_mario._usedObj 128 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; split; reflexivity.
Qed.

(** The first two suffix stores do preserve heldObj and the separate
    platform cell. The Mario receiver is freshly loaded from its actual
    global, whose value is itself preserved by the first store. *)
Definition TIFNeighborStoresPreserveHeldAndPlatform : Prop :=
  forall version e le before gs mb pb trace last after out held platform,
  e ! us_mario._gMarioState = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_mario._gMarioState = Some gs ->
  Mem.load Mptr before gs 0 = Some (Vptr mb Ptrofs.zero) ->
  mb <> gs -> mb <> pb ->
  Mem.load Mptr before mb 124 = Some held ->
  Mem.load Mptr before pb 0 = Some platform ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tif_neighbor_prefix trace last after out ->
  Mem.load Mptr after mb 124 = Some held /\
  Mem.load Mptr after pb 0 = Some platform.

Theorem tif_neighbor_stores_preserve_held_and_platform :
  TIFNeighborStoresPreserveHeldAndPlatform.
Proof.
  unfold TIFNeighborStoresPreserveHeldAndPlatform.
  intros version e le before gs mb pb trace last after out held platform
    Hlocal Hsymbol Hpointer Hstateglobal Hplatformglobal Hheld Hplatform Hrun.
  unfold tif_neighbor_prefix in Hrun.
  destruct (ibk_split_sequence _ _ _ _ tif_ridden_reset _ _ _ _ _ eq_refl Hrun)
    as (middle & memory & pre & suf & Htrace & Hridden & Hrest).
  destruct (tif_neighbor_reset_frames version e le before us_mario._t'89
    us_mario._riddenObj 132 gs mb _ _ _ _ Hlocal Hsymbol Hpointer
    (proj1 (tif_selected_neighbor_layouts version)) Hridden)
    as (_ & _ & Hframe1).
  assert (Mem.load Mptr memory gs 0 = Some (Vptr mb Ptrofs.zero)) as Hpointer'.
  { rewrite <- Hpointer. apply (Hframe1
      {| ink_cell_block := gs; ink_cell_chunk := Mptr; ink_cell_offset := 0 |}).
    left. cbn. congruence. }
  destruct (ibk_split_sequence _ _ _ _ tif_used_reset _ _ _ _ _ eq_refl Hrest)
    as (done & final & used_t & skip_t & Hresttrace & Hused & Hskip).
  inversion Hskip; subst.
  destruct (tif_neighbor_reset_frames version e middle memory us_mario._t'88
    us_mario._usedObj 128 gs mb _ _ _ _ Hlocal Hsymbol Hpointer'
    (proj2 (tif_selected_neighbor_layouts version)) Hused)
    as (_ & _ & Hframe2).
  split.
  - rewrite <- Hheld. transitivity (Mem.load Mptr memory mb 124).
    + apply (Hframe2 {| ink_cell_block := mb; ink_cell_chunk := Mptr;
        ink_cell_offset := 124 |}).
      right; left. change (124 + 4 <= 128). lia.
    + apply (Hframe1 {| ink_cell_block := mb; ink_cell_chunk := Mptr;
        ink_cell_offset := 124 |}).
      right; left. change (124 + 4 <= 132). lia.
  - rewrite <- Hplatform. transitivity (Mem.load Mptr memory pb 0).
    + apply (Hframe2 {| ink_cell_block := pb; ink_cell_chunk := Mptr;
        ink_cell_offset := 0 |}). left. cbn. congruence.
    + apply (Hframe1 {| ink_cell_block := pb; ink_cell_chunk := Mptr;
        ink_cell_offset := 0 |}). left. cbn. congruence.
Qed.

(** Per-function frame helper for the actual generated body-reset function.
    Applying it to a reached initializer event still requires identifying that
    event's callee and MarioState receiver with this call. *)
Definition TIFBodyStateCallFrame : Prop :=
  forall version before mb body bo pb trace after result held platform,
  Mem.load Mint32 before mb 152 = Some (Vptr body bo) ->
  body <> mb -> mb <> pb -> body <> pb ->
  Mem.load Mptr before mb 124 = Some held ->
  Mem.load Mptr before pb 0 = Some platform ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (ibr_body version)) [Vptr mb Ptrofs.zero]
    trace after result ->
  Mem.load Mptr after mb 124 = Some held /\
  Mem.load Mptr after pb 0 = Some platform.

Theorem tif_bodystate_call_preserves_held_and_platform : TIFBodyStateCallFrame.
Proof.
  unfold TIFBodyStateCallFrame.
  intros version before mb body bo pb trace after result held platform
    Hbody Hbodymario Hmarioplatform Hbodyplatform Hheld Hplatform Hcall.
  destruct (ibr_completed_reset_exact_frame version before mb body bo trace after
    result Hbody Hcall) as [_ Hframe].
  split.
  - rewrite <- Hheld. apply (Hframe
      {| ink_cell_block := mb; ink_cell_chunk := Mptr; ink_cell_offset := 124 |}).
    + apply Forall_forall. intros spec Hin. left. cbn. congruence.
    + right; right. cbn. lia.
  - rewrite <- Hplatform. apply (Hframe
      {| ink_cell_block := pb; ink_cell_chunk := Mptr; ink_cell_offset := 0 |}).
    + apply Forall_forall. intros spec Hin. left. cbn. congruence.
    + left. cbn. congruence.
Qed.

Definition TIFReachedNeighborCheckpoint : Prop :=
  forall version e le before gs mb pb trace last after out held platform,
  e ! us_mario._gMarioState = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_mario._gMarioState = Some gs ->
  Mem.load Mptr before gs 0 = Some (Vptr mb Ptrofs.zero) ->
  mb <> gs -> mb <> pb ->
  Mem.load Mptr before mb 124 = Some held ->
  Mem.load Mptr before pb 0 = Some platform ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tdr_init_after_held version) trace last after out ->
  exists cut_le cut_m pre suf,
    trace = pre ++ suf /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
      tif_neighbor_prefix pre cut_le cut_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e cut_le cut_m
      (tif_after_neighbors version) suf last after out /\
    Mem.load Mptr cut_m mb 124 = Some held /\
    Mem.load Mptr cut_m pb 0 = Some platform.

Theorem tif_reached_neighbor_checkpoint : TIFReachedNeighborCheckpoint.
Proof.
  unfold TIFReachedNeighborCheckpoint.
  intros version e le before gs mb pb trace last after out held platform
    Hlocal Hsymbol Hpointer Hstateglobal Hplatformglobal Hheld Hplatform Hrun.
  rewrite tif_generated_neighbor_prefix_exact in Hrun.
  change (ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (ocn_prepend [tif_ridden_reset; tif_used_reset] (tif_after_neighbors version))
    trace last after out) in Hrun.
  destruct (ibk_split_prefix _ _ [tif_ridden_reset; tif_used_reset]
    _ _ _ _ _ _ _ eq_refl Hrun)
    as (cut_le & cut_m & pre & suf & Htrace & Hprefix & Hsuffix).
  change (ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tif_neighbor_prefix pre cut_le cut_m Out_normal) in Hprefix.
  destruct (tif_neighbor_stores_preserve_held_and_platform version e le before
    gs mb pb pre cut_le cut_m Out_normal held platform
    Hlocal Hsymbol Hpointer Hstateglobal Hplatformglobal Hheld Hplatform Hprefix)
    as [Hheld' Hplatform'].
  exists cut_le, cut_m, pre, suf. repeat split; assumption.
Qed.

(** These are the actual memory operations in the completed execution, with
    its exact order and endpoints. Untaken branches contribute no events. *)
Theorem tif_completed_execution_has_actual_effect_chain :
  forall ge e le before statement trace last after out,
  ibk_normal statement = true ->
  ocn_exec ge e le before statement trace last after out ->
  exists events,
    TIFMemoryChain before events after /\
    Forall (tif_event_valid ge e) events /\
    Forall (fun event => In (tif_event_node event) (tif_leaves statement)) events.
Proof.
  intros ge e le before statement trace last after out Hshape Hrun.
  induction Hrun; cbn in Hshape; try discriminate.
  - exists []. repeat split; constructor.
  - exists [TIFAssignment le a1 a2 m m' loc ofs bf v].
    split.
    + exact (tif_chain_cons (TIFAssignment le a1 a2 m m' loc ofs bf v)
        [] m' (tif_chain_nil m')).
    + split.
      * constructor; [exists v2; repeat split; assumption|constructor].
      * repeat constructor; auto.
  - exists []. repeat split; constructor.
  - exists [TIFCall le optid a al m m' f vargs t vres].
    split.
    + exact (tif_chain_cons (TIFCall le optid a al m m' f vargs t vres)
        [] m' (tif_chain_nil m')).
    + split.
      * constructor; [exists tyargs, tyres, cconv, vf; repeat split; assumption|constructor].
      * repeat constructor; auto.
  - apply andb_true_iff in Hshape as [Hfirst Hsecond].
    destruct (IHHrun1 Hfirst) as (first & Hchain1 & Hvalid1 & Hnodes1).
    destruct (IHHrun2 Hsecond) as (second & Hchain2 & Hvalid2 & Hnodes2).
    exists (first ++ second). split; [eapply tif_chain_append; eauto|].
    split; [now apply Forall_app|]. apply Forall_app; split.
    + eapply Forall_impl; [|exact Hnodes1]. intros event Hin.
      cbn. apply in_or_app. auto.
    + eapply Forall_impl; [|exact Hnodes2]. intros event Hin.
      cbn. apply in_or_app. auto.
  - apply andb_true_iff in Hshape as [Hfirst Hsecond].
    exfalso.
    match goal with
    | Hnot : ?result <> Out_normal,
      Hex : ClightBigstep.exec_stmt _ _ _ _ _ s1 _ _ _ ?result |- _ =>
      apply Hnot; eapply ibk_normal_outcome; [exact Hfirst|exact Hex]
    end.
  - apply andb_true_iff in Hshape as [Hfirst Hsecond].
    assert (ibk_normal (if b then s1 else s2) = true) as Hchosen
      by (destruct b; assumption).
    destruct (IHHrun Hchosen) as (events & Hchain & Hvalid & Hnodes).
    exists events. repeat split; try assumption.
    eapply Forall_impl; [|exact Hnodes]. intros event Hin.
    cbn. apply in_or_app. destruct b; auto.
Qed.

(** A store obligation is byte-range nonoverlap, rather than the desired
    complete memory effect. A call obligation is attached to that reached
    individual real call, with its actual arguments and endpoints. *)
Definition tif_event_guard (cell : InkReadCell) event : Prop :=
  match event with
  | TIFAssignment _ lhs _ _ _ target offset bits _ =>
      bits = Full /\ exists chunk,
      access_mode (typeof lhs) = By_value chunk /\
      ibr_cell_disjoint target chunk (Ptrofs.unsigned offset) cell
  | TIFCall _ _ _ _ before after _ _ _ _ =>
      ink_read after cell = ink_read before cell end.

Lemma tif_guarded_event_frames : forall ge e event cell,
  tif_event_valid ge e event -> tif_event_guard cell event ->
  ink_read (tif_event_after event) cell = ink_read (tif_event_before event) cell.
Proof.
  intros ge e [] cell Hvalid Hguard; cbn in *; [|exact Hguard].
  destruct Hvalid as (raw & Hlvalue & Hrhs & Hcast & Hvalid).
  destruct Hguard as [-> [chunk [Hmode Hdisjoint]]].
  inversion Hvalid; subst; try congruence.
  match goal with Haccess : access_mode _ = By_value _ |- _ =>
    rewrite Hmode in Haccess; inversion Haccess; subst end.
  eapply ibr_single_store_frames; eauto.
Qed.

Lemma tif_guarded_chain_frames : forall ge e before events after,
  TIFMemoryChain before events after -> forall cell,
  Forall (tif_event_valid ge e) events ->
  Forall (tif_event_guard cell) events ->
  ink_read after cell = ink_read before cell.
Proof.
  intros ge e before events after Hchain. induction Hchain;
    intros cell Hvalid Hguard; [reflexivity|].
  inversion Hvalid; subst. inversion Hguard; subst.
  rewrite (IHHchain cell ltac:(assumption) ltac:(assumption)).
  eapply tif_guarded_event_frames; eauto.
Qed.

Definition tif_suffix_calls :=
  [us_mario._find_water_level; us_mario._vec3s_copy; us_mario._vec3s_set;
   us_mario._vec3s_to_vec3f; us_mario._vec3f_set; us_mario._find_floor;
   us_mario._mario_reset_bodystate; us_mario._update_mario_info_for_cam;
   us_mario._vec3f_copy; us_mario._vec3s_set;
   us_mario._save_file_get_cap_pos; us_mario._spawn_object].

Theorem tif_generated_suffix_census : forall version,
  ibk_normal (tdr_init_after_held version) = true /\
  tif_call_ids (tdr_init_after_held version) = tif_suffix_calls.
Proof. intros []; split; reflexivity. Qed.

(** A full actual suffix is now reduced to its finite reached stores and
    named calls. This is a conditional refinement, not a discharged aliasing
    invariant or a statement about the first displacement's chronology. *)
Definition TIFActualInitializerSuffixFrame : Prop :=
  forall version e le before trace last after out,
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tdr_init_after_held version) trace last after out ->
  exists events,
    TIFMemoryChain before events after /\
    Forall (tif_event_valid
      (Clight.globalenv (selected_clight_target version)) e) events /\
    Forall (fun event => In (tif_event_node event)
      (tif_leaves (tdr_init_after_held version))) events /\
    (forall cell, Forall (tif_event_guard cell) events ->
      ink_read after cell = ink_read before cell).

Theorem tif_actual_initializer_suffix_frame : TIFActualInitializerSuffixFrame.
Proof.
  unfold TIFActualInitializerSuffixFrame.
  intros version e le before trace last after out Hrun.
  destruct (tif_completed_execution_has_actual_effect_chain _ _ _ _ _ _ _ _ _
    (proj1 (tif_generated_suffix_census version)) Hrun)
    as (events & Hchain & Hvalid & Hnodes).
  exists events. repeat split; try assumption.
  intros. eapply tif_guarded_chain_frames; eauto.
Qed.

Definition TeleporterInitializerFrameBoundary : Prop :=
  TIFActualInitializerSuffixFrame /\
  TIFNeighborStoresPreserveHeldAndPlatform /\
  TIFReachedNeighborCheckpoint /\
  TIFBodyStateCallFrame /\
  (forall version,
    tif_call_ids (tdr_init_after_held version) = tif_suffix_calls).

Theorem teleporter_initializer_frame_boundary_checked :
  TeleporterInitializerFrameBoundary.
Proof.
  split; [exact tif_actual_initializer_suffix_frame|].
  split; [exact tif_neighbor_stores_preserve_held_and_platform|].
  split; [exact tif_reached_neighbor_checkpoint|].
  split; [exact tif_bodystate_call_preserves_held_and_platform|].
  intro version. exact (proj2 (tif_generated_suffix_census version)).
Qed.
