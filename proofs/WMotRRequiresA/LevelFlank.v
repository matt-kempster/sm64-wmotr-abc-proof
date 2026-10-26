(* ====================================================================== *)
(* LevelFlank (GOAL 2): the level phase of a WMotR frame, as statement    *)
(* slices of the real play_mode_normal (2026-10-24).                     *)
(*                                                                        *)
(* level_script.c (the CALL_LOOP that calls lvl_init_or_update(1) ->      *)
(* update_level -> play_mode_normal) is not linked, so the frame cannot   *)
(* root at a call of play_mode_normal.  It roots INSIDE its generated     *)
(* body (generated/level_update.v, f_play_mode_normal), cut at the       *)
(* area_update_objects call (whose inside is the platform / Mario action  *)
(* / object segments of HeightFrame):                                     *)
(*   PRE  = demo guard ; warp_area() ; check_instant_warp() ; timer++     *)
(*   POST = update_hud_values() ; if (gCurrentArea) update_camera(..) ;   *)
(*          initiate_painting_warp() ; initiate_delayed_warp() ;          *)
(*          play-mode switch ; return 0                                   *)
(* The slices are positional projections of the real body (the lv_ terms), pinned *)
(* by vm-checked shape booleans; nothing here restates the code.          *)
(*                                                                        *)
(* level_pins: the warp cells the guards read, = FfWorld.warp_w (PhiW's   *)
(* lvl_w conjunct).  Without them                                         *)
(* the PRE is FALSE of the real code: a SAME_AREA sWarpDest sends         *)
(* warp_area into init_mario_after_warp (rewrites Mario's action and y).  *)
(* The instant / painting warps are ruled out by Mario's floor type       *)
(* (floor_safe: WMotRWorld's floor clause + MWF_real's gMarioState).      *)
(*                                                                        *)
(* Under them the PRE's three guards are no-ops (demo_noop, wa_noop,      *)
(* ciw_noop, walked here from the real bodies) and the painting call      *)
(* only allocates and frees its local (paint_noop, through the walked     *)
(* get_painting_warp_node returning NULL).                                *)
(* ====================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require level_update.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve.
From SM64.Proofs Require MathGeomGated.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim.
From SM64.Proofs.WMotRRequiresA Require FfWorld.
Import ListNotations.
Local Open Scope Z_scope.

Module LU := level_update.

(* ---------------------------------------------------------------------- *)
(* 1. The slices.                                                          *)
(* ---------------------------------------------------------------------- *)

Definition sq1 (s : statement) : statement := match s with Ssequence a _ => a | _ => Sskip end.
Definition sq2 (s : statement) : statement := match s with Ssequence _ b => b | _ => Sskip end.
Definition is_seq (s : statement) : bool := match s with Ssequence _ _ => true | _ => false end.

Lemma seq_eta : forall s, is_seq s = true -> s = Ssequence (sq1 s) (sq2 s).
Proof. intros s H. destruct s; try discriminate H. reflexivity. Qed.

Definition PMN : statement := fn_body LU.f_play_mode_normal.
Definition lv_demo : statement := sq1 PMN.
Definition lv_r1 : statement := sq2 PMN.
Definition lv_wa : statement := sq1 lv_r1.
Definition lv_ciw : statement := sq1 (sq2 lv_r1).
Definition lv_timer : statement := sq1 (sq2 (sq2 lv_r1)).
Definition lv_auo : statement := sq1 (sq2 (sq2 (sq2 lv_r1))).
Definition lv_post : statement := sq2 (sq2 (sq2 (sq2 lv_r1))).
Definition lv_hud : statement := sq1 lv_post.
Definition lv_cam : statement := sq1 (sq2 lv_post).
Definition lv_paint : statement := sq1 (sq2 (sq2 lv_post)).
Definition lv_tail : statement := sq2 (sq2 (sq2 lv_post)).

(* the PRE slice: everything before area_update_objects *)
Definition lv_pre : statement := Ssequence lv_demo (Ssequence lv_wa (Ssequence lv_ciw lv_timer)).

Lemma pmn_shape :
  is_seq PMN && is_seq lv_r1 && is_seq (sq2 lv_r1) && is_seq (sq2 (sq2 lv_r1))
  && is_seq (sq2 (sq2 (sq2 lv_r1))) && is_seq lv_post && is_seq (sq2 lv_post)
  && is_seq (sq2 (sq2 lv_post)) = true.
Proof. vm_compute. reflexivity. Qed.

(* the real body IS demo ; wa ; ciw ; timer ; area_update_objects ; POST,
   and POST IS hud ; cam ; paint ; tail *)
Lemma pmn_body_eq :
  fn_body LU.f_play_mode_normal
  = Ssequence lv_demo (Ssequence lv_wa (Ssequence lv_ciw (Ssequence lv_timer (Ssequence lv_auo lv_post)))).
Proof.
  pose proof pmn_shape as H. repeat (apply andb_prop in H as [H ?]).
  change (fn_body LU.f_play_mode_normal) with PMN.
  rewrite (seq_eta PMN H). fold lv_demo lv_r1. f_equal.
  all: try ((rewrite (seq_eta lv_r1) by assumption); fold lv_wa; f_equal).
  all: try ((rewrite (seq_eta (sq2 lv_r1)) by assumption); fold lv_ciw; f_equal).
  all: try ((rewrite (seq_eta (sq2 (sq2 lv_r1))) by assumption); fold lv_timer; f_equal).
  all: try ((rewrite (seq_eta (sq2 (sq2 (sq2 lv_r1)))) by assumption); reflexivity).
Qed.

Lemma post_eq : lv_post = Ssequence lv_hud (Ssequence lv_cam (Ssequence lv_paint lv_tail)).
Proof.
  pose proof pmn_shape as H. repeat (apply andb_prop in H as [H ?]).
  all: try ((rewrite (seq_eta lv_post) at 1 by assumption); fold lv_hud; f_equal).
  all: try ((rewrite (seq_eta (sq2 lv_post)) at 1 by assumption); fold lv_cam; f_equal).
  all: try ((rewrite (seq_eta (sq2 (sq2 lv_post))) at 1 by assumption); reflexivity).
Qed.

(* the camera statement, pinned against the generated AST:
   `t'10 = gCurrentArea; if (t'10 != NULL) { t'11 = gCurrentArea;
    t'12 = t'11->camera; update_camera(t'12); }` *)
Definition area_ty : type := tptr (Tstruct LU._Area noattr).
Definition camp_ty : type := tptr (Tstruct LU._Camera noattr).
Lemma lv_cam_eq : lv_cam =
  Ssequence (Sset LU._t'10 (Evar LU._gCurrentArea area_ty))
    (Sifthenelse (Ebinop One (Etempvar LU._t'10 area_ty)
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence (Sset LU._t'11 (Evar LU._gCurrentArea area_ty))
        (Ssequence
          (Sset LU._t'12 (Efield (Ederef (Etempvar LU._t'11 area_ty) (Tstruct LU._Area noattr))
                            LU._camera camp_ty))
          (Scall None (Evar LU._update_camera (Tfunction (camp_ty :: nil) tvoid cc_default))
             (Etempvar LU._t'12 camp_ty :: nil))))
      Sskip).
Proof. vm_cast_no_check (eq_refl lv_cam). Qed.

Definition type_eqb (a b : type) : bool := if type_eq a b then true else false.
Lemma type_eqb_eq : forall a b, type_eqb a b = true -> a = b.
Proof. intros a b H. unfold type_eqb in H. destruct (type_eq a b); [ exact e | discriminate H ]. Qed.

Definition fn0 : type := Tfunction nil tvoid cc_default.

(* `f();` *)
Definition is_call0 (s : statement) (f : ident) : bool :=
  match s with Scall None (Evar g ty) nil => Pos.eqb g f && type_eqb ty fn0 | _ => false end.

Lemma call0_eq : forall s f, is_call0 s f = true -> s = Scall None (Evar f fn0) nil.
Proof.
  intros s f H. destruct s; try discriminate H. destruct o; try discriminate H.
  destruct e; try discriminate H. destruct l; try discriminate H.
  cbn in H. apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. apply type_eqb_eq in H2.
  subst. reflexivity.
Qed.

Lemma lv_calls :
  is_call0 lv_wa LU._warp_area && is_call0 lv_ciw LU._check_instant_warp
  && is_call0 lv_auo LU._area_update_objects && is_call0 lv_hud LU._update_hud_values
  && is_call0 lv_paint LU._initiate_painting_warp = true.
Proof. vm_compute. reflexivity. Qed.

Lemma lv_wa_eq : lv_wa = Scall None (Evar LU._warp_area fn0) nil.
Proof. pose proof lv_calls as H. repeat (apply andb_prop in H as [H ?]). apply call0_eq. assumption. Qed.
Lemma lv_ciw_eq : lv_ciw = Scall None (Evar LU._check_instant_warp fn0) nil.
Proof. pose proof lv_calls as H. repeat (apply andb_prop in H as [H ?]). apply call0_eq. assumption. Qed.
Lemma lv_auo_eq : lv_auo = Scall None (Evar LU._area_update_objects fn0) nil.
Proof. pose proof lv_calls as H. repeat (apply andb_prop in H as [H ?]). apply call0_eq. assumption. Qed.
Lemma lv_hud_eq : lv_hud = Scall None (Evar LU._update_hud_values fn0) nil.
Proof. pose proof lv_calls as H. repeat (apply andb_prop in H as [H ?]). apply call0_eq. assumption. Qed.
Lemma lv_paint_eq : lv_paint = Scall None (Evar LU._initiate_painting_warp fn0) nil.
Proof. pose proof lv_calls as H. repeat (apply andb_prop in H as [H ?]). apply call0_eq. assumption. Qed.

(* the demo guard: `t'16 = gCurrDemoInput; if (t'16 != NULL) { ... }` *)
Definition demo_ty : type := tptr (Tstruct LU._DemoInput noattr).

Definition demo_view (s : statement) : option statement :=
  match s with
  | Ssequence (Sset t (Evar g ty)) (Sifthenelse (Ebinop One (Etempvar t' ty1) (Ecast (Econst_int z tz) ty2) tr) X Sskip) =>
      if Pos.eqb t LU._t'16 && Pos.eqb g LU._gCurrDemoInput && Pos.eqb t' LU._t'16
         && type_eqb ty demo_ty && type_eqb ty1 demo_ty && Int.eq z Int.zero && type_eqb tz tint
         && type_eqb ty2 (tptr tvoid) && type_eqb tr tint
      then Some X else None
  | _ => None
  end.

Lemma demo_view_eq : forall s X, demo_view s = Some X ->
  s = Ssequence (Sset LU._t'16 (Evar LU._gCurrDemoInput demo_ty))
        (Sifthenelse (Ebinop One (Etempvar LU._t'16 demo_ty) (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint)
           X Sskip).
Proof.
  intros s X H. unfold demo_view in H.
  repeat match type of H with
  | context [match ?x with _ => _ end] => destruct x eqn:?; try discriminate H
  end.
  injection H as <-.
  repeat match goal with
  | E : (_ && _) = true |- _ => apply andb_prop in E as [? ?]
  | E : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in E; subst
  | E : type_eqb _ _ = true |- _ => apply type_eqb_eq in E; subst
  | E : Int.eq _ Int.zero = true |- _ => apply Int.same_if_eq in E; subst
  end.
  reflexivity.
Qed.

Lemma lv_demo_view : exists X, demo_view lv_demo = Some X.
Proof. eexists. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The steps.                                                           *)
(* ---------------------------------------------------------------------- *)

Section Steps.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).

  (* PRE: the slice runs from the body's entry temps (play_mode_normal's
     fn_vars are nil: empty_env), and the dispatcher only calls
     play_mode_normal in PLAY_MODE_NORMAL (update_level's switch on
     sCurrPlayMode, level_update.c; level_script.c's CALL_LOOP is not
     linked -- TRUST 0.5). *)
  Definition level_pre_call (m m' : mem) : Prop :=
    (forall b, Genv.find_symbol G LU._sCurrPlayMode = Some b ->
       Mem.loadv Mint16signed m (Vptr b Ptrofs.zero) = Some (Vint Int.zero))
    /\ exists t le' out,
         exec_stmt function_entry2 G empty_env
           (create_undef_temps (fn_temps LU.f_play_mode_normal)) m lv_pre t le' m' out.

  (* POST: the slice after area_update_objects, from the temps the body
     has there (any) *)
  Definition level_post_call (m m' : mem) : Prop :=
    exists le t le' out, exec_stmt function_entry2 G empty_env le m lv_post t le' m' out.

  (* the camera statement `if (gCurrentArea != NULL) update_camera(gCurrentArea->camera);`
     of the POST slice, on its own (LevelKeep's labeled camera row) *)
  Definition cam_step (m m' : mem) : Prop :=
    exists le t le' out, exec_stmt function_entry2 G empty_env le m lv_cam t le' m' out.
End Steps.

(* ---------------------------------------------------------------------- *)
(* 3. The warp pins: FfWorld.warp_w (lvl_w's conjunct, carried by PhiW):   *)
(*    NOT_WARPING in NORMAL play mode, no demo, no credits, a set warp op   *)
(*    has a WMotR source node.                                             *)
(* ---------------------------------------------------------------------- *)

Definition level_pins (G : genv) (m : mem) : Prop := FfWorld.warp_w G m.

(* What the instant / painting warp guards read: gMarioState points at
   Mario (GOAL 1's MWF_real R5) and his floor is a surface of one of
   WMotR's types (WMotRWorld.wmotr_world's floor clause,
   wmotr_surface_types = [5; 10; 21; 55; 0]): none is an instant-warp
   (0x1B..0x1E) or painting-warp (0xD3..) type.  LevelKeep derives it. *)
Definition floor_safe (ge : genv) (bm : block) (m : mem) : Prop :=
  exists bs, Genv.find_symbol ge LU._gMarioState = Some bs
  /\ (forall b o, Mem.load Mint32 m bs 0 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero)
  /\ (forall v, Mem.load Mint32 m bm 104 = Some v ->
        exists fb fo t, v = Vptr fb fo
          /\ Mem.load Mint16signed m fb (Ptrofs.unsigned fo) = Some (Vint t)
          /\ In (Int.signed t) [5; 10; 21; 55; 0])
  /\ Mem.valid_block m bm.

Definition OFS_WD_TYPE : Z := 0.        (* WarpDest.type, u8 *)

(* ---------------------------------------------------------------------- *)
(* 4. The guards under the pins, walked from the real bodies.              *)
(* ---------------------------------------------------------------------- *)

(* a statement of temp sets, sequences and ifs keeps memory and ends normally *)
Fixpoint sets_only (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ => true
  | Ssequence a b | Sifthenelse _ a b => sets_only a && sets_only b
  | _ => false
  end.

Lemma sets_only_mem : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> sets_only s = true -> m' = m /\ out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hp; cbn [sets_only] in Hp;
    try discriminate Hp; try (split; reflexivity).
  - apply andb_prop in Hp as [A1 A2].
    destruct (IHexec_stmt1 A1) as (-> & _). exact (IHexec_stmt2 A2).
  - apply andb_prop in Hp as [A1 _]. exfalso. exact (H0 (proj2 (IHexec_stmt A1))).
  - apply andb_prop in Hp as [A1 A2]. apply IHexec_stmt. destruct b; assumption.
Qed.

Section Walks.
  Variable ge : genv.
  Hypothesis Hcenv : forall id co, (prog_comp_env LU.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.

  Ltac fo_lu := apply (fo_ok_lift (prog_comp_env LU.prog)); [ vm_compute; reflexivity | exact Hcenv ].

  Lemma fo_wd_type : forall co, (genv_cenv ge) ! LU._WarpDest = Some co ->
    field_offset ge LU._type (co_members co) = OK (OFS_WD_TYPE, Full).
  Proof. fo_lu. Qed.
  Lemma fo_floor : forall co, (genv_cenv ge) ! LU._MarioState = Some co ->
    field_offset ge LU._floor (co_members co) = OK (104, Full).
  Proof. fo_lu. Qed.
  Lemma fo_stype : forall co, (genv_cenv ge) ! LU._Surface = Some co ->
    field_offset ge LU._type (co_members co) = OK (0, Full).
  Proof. fo_lu. Qed.

  Section EVG.
    Variable e : env.
    Variable m : mem.
    (* g.f, g a global struct *)
    Lemma ev_gfld : forall le g S f ty v ch d, e ! g = None ->
      (forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full)) ->
      access_mode ty = By_value ch ->
      eval_expr ge e le m (Efield (Evar g (Tstruct S noattr)) f ty) v ->
      exists b, Genv.find_symbol ge g = Some b
        /\ Mem.loadv ch m (Vptr b (Ptrofs.add Ptrofs.zero (Ptrofs.repr d))) = Some v.
    Proof.
      intros le g S f ty v ch d He Hfo Ham H.
      inv H. match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
      all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
      match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
      match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
        rewrite (Hfo _ Hc) in Hf; injection Hf; intros; subst end.
      match goal with He2 : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv He2 end.
      all: match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; try congruence.
      all: cbn [typeof] in *.
      all: match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
           cbn [access_mode] in *; try discriminate.
      all: eexists; split; [ eassumption |].
      all: match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; try congruence.
      all: repeat match goal with H1 : access_mode _ = By_value ?c |- _ =>
        tryif constr_eq H1 Ham then fail else (rewrite Ham in H1; injection H1; intros; subst; clear H1) end.
      all: assumption.
    Qed.
  End EVG.

  (* the step tactic for the guards: evaluate one expression hypothesis *)
  Ltac g1 :=
    match goal with
    | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
    | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
    | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
        apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
    | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
        apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
    | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
    | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
    | H : Vptr _ _ = Vptr _ _ |- _ => injection H; clear H; intros; subst
    | H : bool_val _ (typeof _) _ = _ |- _ => progress cbn [typeof] in H
    | H : sem_cast (Vint _) _ _ _ = Some _ |- _ => vm_compute in H; injection H; clear H; intros; subst
    | H : sem_binary_operation _ _ (Vint _) _ (Vint _) _ _ = Some _ |- _ =>
        vm_compute in H; injection H; clear H; intros; subst
    | H : bool_val (Vint _) _ _ = Some _ |- _ => vm_compute in H; first [ discriminate H | clear H ]
    end.

  (* function entry of a no-locals, no-params body: the body runs from m
     and the call ends in the body's memory *)
  Lemma entry0 : forall f m t m' vres, fn_vars f = nil -> fn_params f = nil ->
    eval_funcall function_entry2 ge m (Internal f) nil t m' vres ->
    exists le out, exec_stmt function_entry2 ge empty_env (create_undef_temps (fn_temps f)) m (fn_body f) t le m' out.
  Proof.
    intros f m t m' vres Hv Hp H. inv H.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hv in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rewrite Hp in Hb; cbn in Hb; injection Hb as <- end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
    eauto.
  Qed.

  (* the demo guard: gCurrDemoInput is NULL, so the statement only sets a temp *)
  Lemma demo_noop : forall le m t le' m' out bd,
    Genv.find_symbol ge LU._gCurrDemoInput = Some bd ->
    Mem.loadv Mint32 m (Vptr bd Ptrofs.zero) = Some (Vint Int.zero) ->
    exec_stmt function_entry2 ge empty_env le m lv_demo t le' m' out -> m' = m /\ out = Out_normal.
  Proof.
    intros le m t le' m' out bd Hs Hl H.
    destruct lv_demo_view as (X & HX). rewrite (demo_view_eq _ _ HX) in H.
    repeat walk1.
    all: match goal with H1 : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
           eapply ev_gvar in H1; [ destruct H1 as (? & ? & H1) | apply PTree.gempty | reflexivity ] end.
    all: match goal with Hs' : Genv.find_symbol _ _ = Some ?x |- _ =>
           rewrite Hs in Hs'; injection Hs' as <- end.
    all: try (change Mptr with Mint32 in * ).
    all: try (match goal with H1 : Mem.loadv _ _ _ = Some ?v, H2 : Mem.loadv _ _ _ = Some _ |- _ =>
           rewrite H2 in H1; injection H1 as <- end).
    all: repeat g1.
    all: auto.
  Qed.

  (* warp_area(): in PLAY_MODE_NORMAL sWarpDest.type is NOT_WARPING *)
  Lemma wa_noop : forall m t m' vres bw,
    Genv.find_symbol ge LU._sWarpDest = Some bw ->
    Mem.loadv Mint8unsigned m (Vptr bw (Ptrofs.add Ptrofs.zero (Ptrofs.repr OFS_WD_TYPE))) = Some (Vint Int.zero) ->
    eval_funcall function_entry2 ge m (Internal LU.f_warp_area) nil t m' vres -> m' = m.
  Proof.
    intros m t m' vres bw Hs Hl H.
    destruct (entry0 LU.f_warp_area _ _ _ _ eq_refl eq_refl H) as (le & out & Hx).
    cbn [LU.f_warp_area fn_body] in Hx.
    repeat walk1.
    all: repeat match goal with H1 : eval_expr _ _ _ _ (Efield (Evar _ _) _ _) _ |- _ =>
           eapply ev_gfld in H1;
           [ destruct H1 as (? & ? & H1) | exact (PTree.gempty _ _) | exact fo_wd_type | reflexivity ] end.
    all: repeat match goal with Hs' : Genv.find_symbol _ _ = Some ?x |- _ =>
           tryif (constr_eq Hs' Hs) then fail else (rewrite Hs in Hs'; injection Hs' as <-) end.
    all: repeat match goal with H1 : Mem.loadv _ _ _ = Some ?v |- _ =>
           tryif (constr_eq H1 Hl) then fail else (rewrite Hl in H1; injection H1 as <-) end.
    all: repeat g1.
    all: reflexivity.
  Qed.


  (* gCurrLevelNum's load *)
  Ltac gv_at id Hs Hl :=
    match goal with H1 : eval_expr _ _ _ _ (Evar id _) _ |- _ =>
      eapply ev_gvar in H1;
      [ let Hs' := fresh in destruct H1 as (? & Hs' & H1);
        rewrite Hs in Hs'; injection Hs' as <-; rewrite Hl in H1; injection H1 as <-
      | first [ apply PTree.gempty | rewrite PTree.gso by neq; apply PTree.gempty ]
      | reflexivity ]
    end.

  (* the floor chase gMarioState -> floor -> type, under floor_safe *)
  Ltac ms_ld Hsm Hpm :=
    lazymatch type of Hpm with forall b o, Mem.load _ ?M _ _ = _ -> _ =>
    match goal with H1 : eval_expr _ _ _ M (Evar LU._gMarioState _) _ |- _ =>
      eapply ev_gvar in H1;
      [ let Hs' := fresh in destruct H1 as (? & Hs' & H1);
        rewrite Hsm in Hs'; injection Hs' as <-; cbn [Mem.loadv] in H1;
        change Mptr with Mint32 in H1; change (Ptrofs.unsigned Ptrofs.zero) with 0 in H1
      | first [ apply PTree.gempty | rewrite PTree.gso by neq; apply PTree.gempty ]
      | reflexivity ]
    end end.

  Ltac fl_ld Hpm Hfl :=
    match goal with H1 : eval_expr _ _ _ _ (Efield (Ederef (Etempvar _ _) _) LU._floor _) _ |- _ =>
      eapply ev_fld in H1; [ | exact fo_floor | reflexivity ];
      let Ht := fresh in destruct H1 as (? & ? & Ht & H1);
      getnorm Ht; injection Ht as ->;
      match goal with Hl : Mem.load _ _ _ _ = Some (Vptr ?b ?o) |- _ =>
        destruct (Hpm b o Hl) as (-> & ->) end;
      let fb := fresh "fb" in let fo := fresh "fo" in let ft := fresh "ft" in
      let Hty := fresh "Hty" in let Hin := fresh "Hin" in
      destruct (Hfl _ H1) as (fb & fo & ft & -> & Hty & Hin)
    end.

  Ltac ty_ld :=
    match goal with H1 : eval_expr _ _ _ _ (Efield (Ederef (Etempvar _ _) _) LU._type _) _ |- _ =>
      eapply ev_fld in H1; [ | exact fo_stype | reflexivity ];
      let Ht := fresh in destruct H1 as (? & ? & Ht & H1);
      getnorm Ht; injection Ht as <- <-;
      change (Ptrofs.repr 0) with Ptrofs.zero in H1; rewrite Ptrofs.add_zero in H1;
      cbn [Mem.loadv] in H1;
      match goal with Hty : Mem.load Mint16signed _ _ _ = Some (Vint ?t),
                      Hin : In (Int.signed ?t) _ |- _ =>
        rewrite Hty in H1; injection H1 as <-;
        let E := fresh "E" in let E' := fresh "E'" in
        destruct Hin as [E | [E | [E | [E | [E | []]]]]];
        (assert (E' : t = Int.repr (Int.signed t)) by (symmetry; apply Int.repr_signed);
         rewrite <- E in E'; subst t)
      end
    end.

  Ltac g2 :=
    match goal with
    | H : sem_cast (Vptr _ _) (tptr _) (tptr _) _ = Some _ |- _ => apply cast_ptr_id in H; subst
    | _ => g1
    end.

  (* floor_safe survives the allocation of a callee's locals *)
  Lemma load_alloc_back : forall m lo hi m1 b ch b' z v,
    Mem.alloc m lo hi = (m1, b) -> Mem.load ch m1 b' z = Some v ->
    v = Vundef \/ Mem.load ch m b' z = Some v.
  Proof.
    intros m lo hi m1 b ch b' z v Ha Hl.
    destruct (eq_block b' b) as [-> | Ne].
    - left. exact (Mem.load_alloc_same _ _ _ _ _ Ha _ _ _ Hl).
    - right. rewrite <- Hl. symmetry. apply (Mem.load_alloc_unchanged _ _ _ _ _ Ha).
      pose proof (Mem.load_valid_access _ _ _ _ _ Hl) as Hv.
      apply (Mem.valid_access_implies _ _ _ _ _ Nonempty) in Hv; [ | constructor ].
      apply Mem.valid_access_valid_block in Hv.
      destruct (Mem.valid_block_alloc_inv _ _ _ _ _ Ha _ Hv) as [E | V]; [ congruence | exact V ].
  Qed.

  Section Floor.
    Variable bm : block.

    Lemma floor_safe_alloc : forall m lo hi m1 b,
      Mem.alloc m lo hi = (m1, b) -> floor_safe ge bm m -> floor_safe ge bm m1.
    Proof.
      intros m lo hi m1 b Ha (bs & Hsm & Hpm & Hfl & Hvb).
      exists bs. split; [ exact Hsm | split; [ | split ] ].
      - intros b' o Hl. destruct (load_alloc_back _ _ _ _ _ _ _ _ _ Ha Hl) as [E | Hl'];
          [ discriminate E | exact (Hpm _ _ Hl') ].
      - intros v Hl. rewrite (Mem.load_alloc_unchanged _ _ _ _ _ Ha _ _ _ Hvb) in Hl.
        destruct (Hfl _ Hl) as (fb & fo & t & -> & Ht & Hin).
        exists fb, fo, t. split; [ reflexivity | split; [ | exact Hin ] ].
        exact (Mem.load_alloc_other _ _ _ _ _ Ha _ _ _ _ Ht).
      - exact (Mem.valid_block_alloc _ _ _ _ _ Ha _ Hvb).
    Qed.

    (* check_instant_warp(): not the castle; Mario's floor is no
       instant-warp surface *)
    Lemma ciw_noop : forall m t m' vres bl,
      Genv.find_symbol ge LU._gCurrLevelNum = Some bl ->
      Mem.loadv Mint16signed m (Vptr bl Ptrofs.zero) = Some (Vint (Int.repr 31)) ->
      floor_safe ge bm m ->
      eval_funcall function_entry2 ge m (Internal LU.f_check_instant_warp) nil t m' vres -> m' = m.
    Proof.
      intros m t m' vres bl Hsl Hll (bs & Hsm & Hpm & Hfl & _) H.
      destruct (entry0 LU.f_check_instant_warp _ _ _ _ eq_refl eq_refl H) as (le & out & Hx).
      cbn [LU.f_check_instant_warp fn_body] in Hx.
      repeat walk1.
      all: try reflexivity.
      all: try (gv_at LU._gCurrLevelNum Hsl Hll).
      all: repeat g2.
      all: repeat first
        [ ms_ld Hsm Hpm
        | fl_ld Hpm Hfl
        | ty_ld
        | g2 ].
    Qed.

    (* get_painting_warp_node(): Mario's floor is no painting surface, so
       it returns NULL and changes nothing *)
    Lemma gpwn_null : forall m t m' vres,
      floor_safe ge bm m ->
      eval_funcall function_entry2 ge m (Internal LU.f_get_painting_warp_node) nil t m' vres ->
      m' = m /\ vres = Vint Int.zero.
    Proof.
      intros m t m' vres (bs & Hsm & Hpm & Hfl & _) H.
      inv H.
      match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
      match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn in Ha; inv Ha end.
      match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in Hb; injection Hb as <- end.
      match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
      match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
        cbn [LU.f_get_painting_warp_node fn_body] in Hx end.
      repeat walk1.
      all: repeat first
        [ ms_ld Hsm Hpm
        | fl_ld Hpm Hfl
        | ty_ld
        | g2 ].
      all: match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
             cbn [outcome_result_value fn_return LU.f_get_painting_warp_node typeof] in Ho;
             destruct Ho as (_ & Ho); vm_compute in Ho; injection Ho as <- end.
      all: split; reflexivity.
    Qed.

    Hypothesis Hgp : forall b fd, Genv.find_symbol ge LU._get_painting_warp_node = Some b ->
      Genv.find_funct_ptr ge b = Some fd -> fd = Internal LU.f_get_painting_warp_node.

    (* `t = get_painting_warp_node();` *)
    Lemma call_gpwn : forall e le m id targs tres cc t le' m' out,
      e ! LU._get_painting_warp_node = None -> floor_safe ge bm m ->
      exec_stmt function_entry2 ge e le m
        (Scall (Some id) (Evar LU._get_painting_warp_node (Tfunction targs tres cc)) nil)
        t le' m' out ->
      m' = m /\ le' = PTree.set id (Vint Int.zero) le /\ out = Out_normal.
    Proof.
      intros e le m id targs tres cc t le' m' out He Hfs Hx.
      apply call_inv in Hx.
      destruct Hx as (tyargs & tyres & cc' & vf & vargs & fd & vres & Hcl & Hev & Hel & Hff & _ & Hfc & -> & ->).
      cbn [classify_fun] in Hcl. injection Hcl as <- <- <-.
      destruct (MathGeomGated.evar_fun_val _ _ _ _ _ _ _ _ _ Hev He) as (lf & Hsy & ->).
      rewrite Genv.find_funct_find_funct_ptr in Hff.
      rewrite (Hgp _ _ Hsy Hff) in Hfc. inv Hel.
      destruct (gpwn_null _ _ _ _ Hfs Hfc) as (-> & ->).
      auto.
    Qed.

    (* initiate_painting_warp(): get_painting_warp_node is NULL, so the call
       only allocates and frees its local warpNode *)
    Lemma paint_noop : forall m t m' vres,
      floor_safe ge bm m ->
      eval_funcall function_entry2 ge m (Internal LU.f_initiate_painting_warp) nil t m' vres ->
      exists m1 b sz, Mem.alloc m 0 sz = (m1, b) /\ Mem.free m1 b 0 sz = Some m'.
    Proof.
      intros m t m' vres Hfs H.
      inv H.
      match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
      match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        cbn [LU.f_initiate_painting_warp fn_vars] in Ha; inv Ha end.
      match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
      match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in Hb; injection Hb as <- end.
      match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
      match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfr end.
      match goal with Hal : Mem.alloc _ _ _ = (?m1, ?b1) |- _ =>
        rename Hal into Halloc; rename m1 into ma; rename b1 into ba end.
      pose proof (floor_safe_alloc _ _ _ _ _ Halloc Hfs) as Hfs1.
      cbn [LU.f_initiate_painting_warp fn_body] in Hbody.
      assert (Hmb : forall le0 le1 m1 t1 out1,
        exec_stmt function_entry2 ge (PTree.set LU._warpNode (ba, Tstruct LU._WarpNode noattr) empty_env)
          le0 ma (fn_body LU.f_initiate_painting_warp) t1 le1 m1 out1 -> m1 = ma).
      { clear Hbody Hfr. intros qle0 qle1 qm1 qt1 qout1 Hb.
        assert (Hge : (PTree.set LU._warpNode (ba, Tstruct LU._WarpNode noattr) empty_env)
                        ! LU._get_painting_warp_node = None)
          by (rewrite PTree.gso by neq; apply PTree.gempty).
        cbn [LU.f_initiate_painting_warp fn_body] in Hb.
        apply seq_inv in Hb as [(qt2 & qle2 & qm2 & qt3 & HA & HB) | (HA & Hout)].
        2: { exfalso. apply Hout. exact (proj2 (sets_only_mem _ _ _ _ _ _ _ _ _ HA eq_refl)). }
        destruct (sets_only_mem _ _ _ _ _ _ _ _ _ HA eq_refl) as (-> & _).
        apply if_inv in HB. destruct HB as (v & [|] & Hev & Hbv & HB); cbv beta iota in HB.
        2: { exact (proj1 (skip_inv _ _ _ _ _ _ _ _ HB)). }
        apply seq_inv in HB as [(qt4 & qle4 & qm4 & qt5 & HC & HD) | (HC & Hout)].
        2: { exfalso. apply seq_inv in HC as [(qt6 & qle6 & qm6 & qt7 & HE & HF) | (HE & Hout')].
             - apply set_inv in HF. destruct HF as (? & _ & _ & _ & HF). exact (Hout HF).
             - destruct (call_gpwn _ _ _ _ _ _ _ _ _ _ _ Hge Hfs1 HE) as (_ & _ & HF).
               exact (Hout' HF). }
        apply seq_inv in HC as [(qt6 & qle6 & qm6 & qt7 & HE & HF) | (HE & Hout')].
        2: { exfalso. destruct (call_gpwn _ _ _ _ _ _ _ _ _ _ _ Hge Hfs1 HE) as (_ & _ & HF).
             exact (Hout' HF). }
        destruct (call_gpwn _ _ _ _ _ _ _ _ _ _ _ Hge Hfs1 HE) as (-> & -> & _).
        apply set_inv in HF. destruct HF as (vp & Hvp & -> & -> & _).
        apply ev_temp in Hvp. rewrite PTree.gss in Hvp. injection Hvp as <-.
        apply if_inv in HD. destruct HD as (v' & b' & Hev' & Hbv' & HD).
        destruct b'; cbv beta iota in HD; repeat g1.
        all: exact (proj1 (skip_inv _ _ _ _ _ _ _ _ HD)). }
      rewrite (Hmb _ _ _ _ _ Hbody) in Hfr.
      exists ma, ba, (sizeof ge (Tstruct LU._WarpNode noattr)). split; [ exact Halloc | ].
      assert (E : PTree.elements (PTree.set LU._warpNode (ba, Tstruct LU._WarpNode noattr) empty_env)
                  = [(LU._warpNode, (ba, Tstruct LU._WarpNode noattr))]) by reflexivity.
      unfold blocks_of_env in Hfr. rewrite E in Hfr. cbn [map block_of_binding Mem.free_list] in Hfr.
      destruct (Mem.free ma ba 0 (sizeof ge (Tstruct LU._WarpNode noattr))) as [m4|] eqn:Ef.
      - cbn in Hfr. congruence.
      - discriminate Hfr.
    Qed.
  End Floor.
End Walks.
