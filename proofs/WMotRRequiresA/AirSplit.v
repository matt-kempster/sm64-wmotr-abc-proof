(* ======================================================================= *)
(* AirSplit: GOAL 2's airborne-dispatcher row, split per action case.      *)
(*                                                                         *)
(* FrameSplit leaves one row per call of execute_mario_action; one of them *)
(* is mario_execute_airborne_action, a 43-case switch on m->action.  This  *)
(* file PROVES that row (air_seg, seg_call_rows_of_air) from:              *)
(*   - the two prologue calls (check_common_airborne_cancels,              *)
(*     play_far_fall_sound): air_pro_rows;                                 *)
(*   - one row per case whose label is a no-A action (air_case_list,       *)
(*     computed from the generated switch: 11 cases), where the handler   *)
(*     is called with the action cell EQUAL to the label: air_case_rows.   *)
(* Every other case is dead: the frame world keeps the action in R_noA,    *)
(* and the switch reads that cell.  GOAL 1's per-handler result            *)
(* (air_leaves_linked12) gives mem_ok across each call.  The freefall case *)
(* is what FfRun.ff_move discharges next.                                  *)
(*                                                                         *)
(* The dispatch's floor refresh (2026-10-21): the row is FrameSplit's      *)
(* staged one, entered with FfWorld.fresh_at (fresh when the action is     *)
(* airborne).  The prologue keeps fresh_at (air_pro_rows); a case's        *)
(* handler is entered fresh (its label is airborne, air_case_air) and      *)
(* returns FALSE or leaves the floor fresh (air_case_rows); so the         *)
(* dispatcher returns 0 or leaves fresh_at (air_seg).                      *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne mario_actions_automatic.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface AirborneSurface.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld.
Import ListNotations.

Module AIR := mario_actions_airborne.

Definition f_air : Clight.function := AIR.f_mario_execute_airborne_action.

(* the dispatch switch's cases, read off the generated body *)
Definition air_ls : labeled_statements :=
  match fn_body f_air with
  | Ssequence _ (Ssequence _ (Ssequence (Ssequence _ (Sswitch _ ls)) _)) => ls
  | _ => LSnil
  end.

(* a case `t = f(m); cancel = t; break;` *)
Definition case_call (s : statement) : option ident :=
  match s with
  | Ssequence (Ssequence (Scall (Some t) (Evar f (Tfunction (pty :: nil) _ _))
                                 (Etempvar p ty :: nil))
                         (Sset c (Etempvar t' _)))
              Sbreak =>
      if Pos.eqb p AIR._m && Pos.eqb t t' && Pos.eqb c AIR._cancel
         && type_eq ty tyMSp && type_eq pty tyMSp
      then Some f else None
  | _ => None
  end.

(* the cases whose label is a no-A action: each must be a call case *)
Fixpoint air_cases (ls : labeled_statements) : option (list (Z * ident)) :=
  match ls with
  | LSnil => Some []
  | LScons None _ _ => None
  | LScons (Some k) s rest =>
      match air_cases rest with
      | None => None
      | Some cs =>
          if existsb (Z.eqb k) R_noA_list then
            match case_call s with Some f => Some ((k, f) :: cs) | None => None end
          else Some cs
      end
  end.

Definition air_case_list : list (Z * ident) :=
  match air_cases air_ls with Some l => l | None => [] end.

Lemma air_cases_eq : air_cases air_ls = Some air_case_list.
Proof. vm_compute. reflexivity. Qed.

Definition tyMS : type := Tstruct mario._MarioState noattr.

(* the body, with the switch's cases left as air_ls *)
Lemma air_body :
  fn_body f_air =
  Ssequence
    (Ssequence
       (Scall (Some AIR._t'1) (Evar AIR._check_common_airborne_cancels (Tfunction [tyMSp] tint cc_default))
          [Etempvar AIR._m tyMSp])
       (Sifthenelse (Etempvar AIR._t'1 tint) (Sreturn (Some (Econst_int (Int.repr 1) tint))) Sskip))
    (Ssequence
       (Scall None (Evar AIR._play_far_fall_sound (Tfunction [tyMSp] tvoid cc_default))
          [Etempvar AIR._m tyMSp])
       (Ssequence
          (Ssequence
             (Sset AIR._t'46 (Efield (Ederef (Etempvar AIR._m tyMSp) tyMS) AIR._action tuint))
             (Sswitch (Etempvar AIR._t'46 tuint) air_ls))
          (Sreturn (Some (Etempvar AIR._cancel tuint))))).
Proof. reflexivity. Qed.

Lemma air_vars : fn_vars f_air = [].
Proof. reflexivity. Qed.

Lemma air_params : fn_params f_air = [(AIR._m, tyMSp)].
Proof. reflexivity. Qed.

Lemma action_fo : mario_fo mario._MarioState mario._action = Some (12, Full).
Proof. vm_compute. reflexivity. Qed.

(* statements that touch no memory *)
Fixpoint pure (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sreturn _ | Sbreak | Scontinue => true
  | Ssequence a b | Sifthenelse _ a b => pure a && pure b
  | _ => false
  end.

Lemma pure_mem : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> pure s = true -> m' = m.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hp; cbn [pure] in Hp;
    try discriminate Hp; try reflexivity;
    repeat match goal with Hq : _ && _ = true |- _ => apply andb_prop in Hq as [?Ha ?Hb] end.
  all: first [ rewrite IHexec_stmt2 by assumption; apply IHexec_stmt1; assumption
             | apply IHexec_stmt; assumption
             | match goal with b : bool |- _ => destruct b; cbn in IHexec_stmt; auto end ].
Qed.

(* the cases: a no-A label selects a call case or nothing *)
Lemma air_cases_default : forall ls cs, air_cases ls = Some cs -> select_switch_default ls = LSnil.
Proof.
  induction ls as [| [k|] s rest IH]; intros cs H; cbn [air_cases select_switch_default] in H |- *; [reflexivity | | discriminate H].
  destruct (air_cases rest) as [cs'|] eqn:E; [| discriminate H]. exact (IH cs' eq_refl).
Qed.

Lemma air_cases_select : forall ls cs n, air_cases ls = Some cs ->
  existsb (Z.eqb n) R_noA_list = true ->
  select_switch_case n ls = None
  \/ exists s rest f, select_switch_case n ls = Some (LScons (Some n) s rest)
                       /\ case_call s = Some f /\ In (n, f) cs.
Proof.
  induction ls as [| [k|] s rest IH]; intros cs n H Hn; cbn [air_cases select_switch_case] in H |- *; [left; reflexivity | | discriminate H].
  destruct (air_cases rest) as [cs'|] eqn:E; [| discriminate H].
  destruct (zeq k n) as [<- | Hne].
  - assert (Hk : existsb (Z.eqb k) R_noA_list = true).
    { rewrite existsb_exists in Hn |- *. destruct Hn as (x & Hx & Hxe).
      exists x. split; [exact Hx |]. apply Z.eqb_eq in Hxe. subst. apply Z.eqb_refl. }
    rewrite Hk in H. destruct (case_call s) as [f|] eqn:Ec; [| discriminate H].
    injection H as <-. right. exists s, rest, f. split; [reflexivity |]. split; [exact Ec | left; reflexivity].
  - destruct (IH cs' n eq_refl Hn) as [Hn' | (s' & r' & f & Hs & Hc & Hin)]; [left; exact Hn' |].
    right. exists s', r', f. split; [exact Hs |]. split; [exact Hc |].
    destruct (existsb (Z.eqb k) R_noA_list); [| injection H as <-; exact Hin].
    destruct (case_call s); [| discriminate H]. injection H as <-. right. exact Hin.
Qed.

Lemma case_call_shape : forall s f, case_call s = Some f ->
  exists t c rt cc ty',
    s = Ssequence (Ssequence (Scall (Some t) (Evar f (Tfunction [tyMSp] rt cc)) [Etempvar AIR._m tyMSp])
                             (Sset c (Etempvar t ty'))) Sbreak
    /\ c = AIR._cancel.
Proof.
  intros s f H. unfold case_call in H.
  repeat match type of H with
  | match ?x with _ => _ end = _ =>
      lazymatch x with
      | (_ && _) => fail
      | _ => destruct x; try discriminate H
      end
  end.
  match type of H with (if ?b then _ else _) = _ => destruct b eqn:Eb; [| discriminate H] end.
  injection H as <-.
  repeat rewrite andb_true_iff in Eb.
  destruct Eb as ((((E1 & E2) & E3) & E4) & E5).
  apply Pos.eqb_eq in E1, E2, E3. subst.
  apply proj_sumbool_true in E4, E5. subst.
  do 5 eexists. split; reflexivity.
Qed.

Lemma air_case_callees : forallb (fun kf => mem_id (snd kf) airborne_callee_ids) air_case_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma air_case_mem : forall n f, In (n, f) air_case_list -> mem_id f airborne_callee_ids = true.
Proof.
  intros n f H. pose proof air_case_callees as R. rewrite forallb_forall in R.
  exact (R (n, f) H).
Qed.

(* statements that set no temp and touch no memory *)
Fixpoint noset (s : statement) : bool :=
  match s with
  | Sskip | Sreturn _ | Sbreak | Scontinue => true
  | Ssequence a b | Sifthenelse _ a b => noset a && noset b
  | _ => false
  end.

Lemma noset_le : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> noset s = true -> le' = le /\ m' = m.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hp; cbn [noset] in Hp;
    try discriminate Hp; try (split; reflexivity);
    repeat match goal with Hq : _ && _ = true |- _ => apply andb_prop in Hq as [?Ha ?Hb] end.
  all: first [ destruct (IHexec_stmt1 ltac:(assumption)) as [-> ->];
               destruct (IHexec_stmt2 ltac:(assumption)) as [-> ->]; split; reflexivity
             | apply IHexec_stmt; assumption
             | match goal with b : bool |- _ => destruct b; cbn in IHexec_stmt; auto end ].
Qed.

Lemma seq_inv : forall ge e le m s1 s2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
  (exists t1 le1 m1 t2, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal
                        /\ exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out)
  \/ (exists t1, exec_stmt function_entry2 ge e le m s1 t1 le' m' out /\ out <> Out_normal).
Proof.
  intros. inv H; [left; do 4 eexists; split; eassumption | right; eexists; split; eassumption].
Qed.


Lemma seq_pure_r : forall ge e le m s1 s2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out -> pure s2 = true ->
  exists t1 le1 out1, exec_stmt function_entry2 ge e le m s1 t1 le1 m' out1.
Proof.
  intros ge e le m s1 s2 t le' m' out H Hp.
  destruct (seq_inv _ _ _ _ _ _ _ _ _ _ H) as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & _)].
  - rewrite (pure_mem _ _ _ _ _ _ _ _ _ H2 Hp). eauto.
  - eauto.
Qed.

Lemma seq_break_abnormal : forall ge e le m s1 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence s1 Sbreak) t le' m' out -> out <> Out_normal.
Proof.
  intros ge e le m s1 t le' m' out H.
  destruct (seq_inv _ _ _ _ _ _ _ _ _ _ H) as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & Hn)].
  - inv H2. discriminate.
  - exact Hn.
Qed.

Section AirSplitS.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_air : linkorder mario_actions_airborne.prog lp.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  Notation ge := (lp_ge lp).
  Notation mem_ok := (mem_ok_lp bm MWF).
  Notation FSc := (FS lp bm MWF).

  Hypothesis Hnoa : forall m, MWF m -> NoA_real bm m.
  (* GOAL 1: every airborne handler keeps mem_ok (air_leaves_linked12) *)
  Hypothesis Hleaves : forall fid f, mem_id fid airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.


  (* ---- THE ROWS: the two prologue calls, and each no-A case's handler,
     called with the action cell = its label.  The dispatch's floor
     refresh (FfWorld.fresh_at: fresh when the action is airborne) holds at
     the call (FrameStage); the prologue keeps it, a case's handler gets
     it (its label is airborne) and returns FALSE or leaves it fresh.
     Since 2026-10-21 the prologue row also covers the automatic
     dispatcher's prologue call, check_common_automatic_cancels
     (AutoSplit), the same shape of claim ---- *)
  Definition air_pro_rows : Prop :=
    forall f fd v, (f = AIR._check_common_airborne_cancels \/ f = AIR._play_far_fall_sound
                    \/ f = mario_actions_automatic._check_common_automatic_cancels) ->
      resolves lp f fd ->
      seg_okR lp bm MWF fd [v] (fun m => marg_ok bm [v] /\ fresh_at bm m) (fun m' _ => fresh_at bm m').

  Definition air_case_rows : Prop :=
    forall n f fd v, In (n, f) air_case_list -> resolves lp f fd ->
      seg_okR lp bm MWF fd [v]
        (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n))
                  /\ fresh bm m)
        (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

  Lemma call_step : forall c0 v le m f rt cc optid t le' m' out (pre : mem -> Prop)
      (post : mem -> val -> Prop),
    budget_ok c0 -> FSc c0 m -> le ! AIR._m = Some v -> marg_ok bm [v] -> pre m ->
    mem_id f airborne_callee_ids = true ->
    (forall fd, resolves lp f fd -> seg_okR lp bm MWF fd [v] pre post) ->
    exec_stmt function_entry2 ge empty_env le m
      (Scall optid (Evar f (Tfunction [tyMSp] rt cc)) [Etempvar AIR._m tyMSp]) t le' m' out ->
    FSc c0 m' /\ out = Out_normal /\ exists vr, le' = set_opttemp optid vr le /\ post m' vr.
  Proof.
    intros c0 v le m f rt cc optid t le' m' out pre post Hb HF Hle Hmarg Hpre Hmem Hrow H.
    inv H.
    match goal with Hc : classify_fun _ = _ |- _ => cbn in Hc; injection Hc as <- <- <- end.
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (eval_Evar_fun _ _ _ _ _ _ _ _ He) as (b & Hs & ->) end.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _ |- _ => inv Hl end.
    match goal with Hl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl end.
    match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in He; rewrite Hle in He; injection He as <- end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      assert (v2 = v) as -> by (unfold tyMSp, tptr, sem_cast in Hc; cbn in Hc;
        destruct v; try discriminate Hc; injection Hc as <-; reflexivity) end.
    destruct HF as (Hok & Hw & Hcells).
    match goal with Hf : eval_funcall _ _ _ ?fd _ _ _ _, Hff : Genv.find_funct _ _ = Some ?fd |- _ =>
      rename Hf into Hev; rename Hff into Hff0 end.
    destruct Hok as (Hv & Hnt & HM).
    destruct (tabled_call_pres lp LO_air bm (NoA_real bm) MWF Hnoa Hleaves f _ m [v] _ _ _ Hev Hmem
                (ex_intro _ b (conj Hs Hff0)) Hmarg (Hnoa m HM) HM Hv Hnt) as (Hv' & Hnt' & HM' & _).
    destruct Hcells as (c1 & Hrc & Hmc).
    pose proof (chain_keeps_budget wmotr_floor wmotr_gap_proved wmotr_pole wmotr_poles_proved
                  wmotr_cannon wmotr_cannons_proved c0 c1 Hb Hmc) as Hb1.
    destruct (Hrow _ (ex_intro _ b (conj Hs Hff0)) m _ _ _ c1 (conj Hv (conj Hnt HM)) Hw Hpre
                (conj Hv' (conj Hnt' HM')) Hrc Hb1 Hev) as (Hw' & (c2 & Hrc2 & Hmc2) & Hpost).
    split; [| split; [reflexivity | eexists; split; [reflexivity | exact Hpost]]].
    refine (conj (conj Hv' (conj Hnt' HM')) (conj Hw' (ex_intro _ c2 (conj Hrc2 _)))).
    exact (rt_trans _ _ _ _ _ Hmc Hmc2).
  Qed.

  (* the switch scrutinee: the action cell *)
  Lemma air_action_load : forall le m v va,
    le ! AIR._m = Some v -> marg_ok bm [v] ->
    eval_expr ge empty_env le m (Efield (Ederef (Etempvar AIR._m tyMSp) tyMS) AIR._action tuint) va ->
    v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some va.
  Proof.
    intros le m v va Hle Hmarg H.
    apply eval_expr_Efield_load in H as (loc & ofs & bf & L & D).
    destruct (lv_field lp LO_mario _ _ _ _ _ _ _ _ _ _ L eq_refl action_fo) as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst bf.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->]. split; [reflexivity |].
    inv D; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    assumption.
  Qed.

  (* every case label is an airborne action (group 0x080) *)
  Lemma air_case_grp :
    forallb (fun kf => Int.eq (Int.and (Int.repr (fst kf)) (Int.repr 448)) (Int.repr 128)) air_case_list = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma air_case_air : forall n f, In (n, f) air_case_list ->
    Int.and (Int.repr n) (Int.repr 448) = Int.repr 128.
  Proof.
    intros n f H. pose proof air_case_grp as R. rewrite forallb_forall in R.
    exact (Int.same_if_eq _ _ (R (n, f) H)).
  Qed.

  Lemma sw_part : forall c v le m t le' m' out,
    air_case_rows -> budget_ok c -> FSc c m -> fresh_at bm m -> le ! AIR._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m
      (Ssequence (Sset AIR._t'46 (Efield (Ederef (Etempvar AIR._m tyMSp) tyMS) AIR._action tuint))
                 (Sswitch (Etempvar AIR._t'46 tuint) air_ls)) t le' m' out ->
    FSc c m' /\ (fresh_at bm m' \/ (out = Out_normal /\ le' ! AIR._cancel = Some (Vint Int.zero))).
  Proof.
    intros c v le m t le' m' out Hcase Hb HF HFr Hle Hmarg H.
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ H) as [(t1 & le1 & m1 & t2 & K1 & K2) | (t1 & K1 & Hn)].
    2: { inv K1. congruence. }
    inv K1.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => rename He into Ea end.
    destruct (air_action_load _ _ _ _ Hle Hmarg Ea) as (-> & Hld).
    inv K2.
    match type of Hld with Mem.load _ ?M _ _ = _ => rename M into mF end.
    match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in He; rewrite PTree.gss in He; injection He as <- end.
    match goal with Hs : sem_switch_arg _ _ = Some _ |- _ => rename Hs into Hsw end.
    match goal with Hx : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ => rename Hx into Kx end.
    destruct v0 as [| i | | | | ]; cbn in Hsw; try discriminate Hsw. injection Hsw as <-.
    pose proof HF as (_ & (Hact & _) & _).
    pose proof (Hact i Hld) as Hr. unfold R_noA in Hr.
    assert (Hex : existsb (Z.eqb (Int.unsigned i)) R_noA_list = true).
    { apply existsb_exists. exists (Int.unsigned i). split; [exact Hr | apply Z.eqb_refl]. }
    destruct (air_cases_select air_ls air_case_list _ air_cases_eq Hex)
      as [Hnone | (s & rest & f & Hsel & Hcc & Hin)].
    - unfold select_switch in Kx. rewrite Hnone, (air_cases_default air_ls _ air_cases_eq) in Kx.
      cbn in Kx. inv Kx. exact (conj HF (or_introl HFr)).
    - unfold select_switch in Kx. rewrite Hsel in Kx. cbn [seq_of_labeled_statement] in Kx.
      destruct (case_call_shape s f Hcc) as (t0 & c' & rt & cc & ty' & -> & ->).
      assert (Hle1 : (PTree.set AIR._t'46 (Vint i) le) ! AIR._m = Some (Vptr bm Ptrofs.zero))
        by (rewrite PTree.gso by (apply Pos.eqb_neq; vm_compute; reflexivity); exact Hle).
      assert (Hfr : fresh bm mF).
      { apply (fresh_at_air bm mF i HFr Hld). rewrite <- (Int.repr_unsigned i). exact (air_case_air _ _ Hin). }
      assert (Hrow : forall fd, resolves lp f fd ->
                seg_okR lp bm MWF fd [Vptr bm Ptrofs.zero]
                  (fun m0 => Vptr bm Ptrofs.zero = Vptr bm Ptrofs.zero
                             /\ Mem.load Mint32 m0 bm 12 = Some (Vint (Int.repr (Int.unsigned i)))
                             /\ fresh bm m0)
                  (fun m' vr => vr = Vint Int.zero \/ fresh bm m'))
        by (intros fd Hr'; exact (Hcase _ f fd _ Hin Hr')).
      assert (Hpre : Vptr bm Ptrofs.zero = Vptr bm Ptrofs.zero
                     /\ Mem.load Mint32 mF bm 12 = Some (Vint (Int.repr (Int.unsigned i))) /\ fresh bm mF)
        by (rewrite Int.repr_unsigned; exact (conj eq_refl (conj Hld Hfr))).
      destruct (seq_inv _ _ _ _ _ _ _ _ _ _ Kx) as [(t3 & le3 & m3 & t4 & K3 & _) | (t3 & K3 & _)].
      { exfalso. exact (seq_break_abnormal _ _ _ _ _ _ _ _ _ K3 eq_refl). }
      destruct (seq_inv _ _ _ _ _ _ _ _ _ _ K3) as [(t5 & le5 & m5 & t6 & K5 & K6) | (t5 & K5 & Hn5)].
      + inv K6.
        destruct (seq_inv _ _ _ _ _ _ _ _ _ _ K5) as [(t7 & le7 & m7 & t8 & K7 & K8) | (t7 & K7 & Hn7)].
        * destruct (call_step c (Vptr bm Ptrofs.zero) _ _ f rt cc _ _ _ _ _ _ _
                      Hb HF Hle1 Hmarg Hpre (air_case_mem _ _ Hin) Hrow K7)
            as (HF7 & _ & vr & -> & Hpost).
          inv K8.
          match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in He; cbn [set_opttemp] in He;
            rewrite PTree.gss in He; injection He as -> end.
          split; [exact HF7 |].
          destruct Hpost as [-> | Hf7]; [right | left; exact (fresh_at_of _ _ Hf7)].
          split; [reflexivity | apply PTree.gss].
        * congruence.
      + destruct (seq_inv _ _ _ _ _ _ _ _ _ _ K5) as [(t7 & le7 & m7 & t8 & K7 & K8) | (t7 & K7 & Hn7)].
        * inv K8. congruence.
        * destruct (call_step c (Vptr bm Ptrofs.zero) _ _ f rt cc _ _ _ _ _ _ _
                      Hb HF Hle1 Hmarg Hpre (air_case_mem _ _ Hin) Hrow K7) as (_ & -> & _).
          congruence.
  Qed.

  (* THE AIRBORNE DISPATCHER'S ROW: from the rows above, with the
     dispatch's floor refresh in and, when it returns nonzero, out *)
  Theorem air_seg : forall v,
    air_pro_rows -> air_case_rows -> marg_ok bm [v] ->
    seg_okR lp bm MWF (Internal f_air) [v] (fun m => fresh_at bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh_at bm m').
  Proof.
    intros v Hpro Hcase Hmarg m t m' vr c Hok Hw Hfr Hok' Hc Hb Hev.
    assert (HF0 : FSc c m) by exact (conj Hok (conj Hw (ex_intro _ c (conj Hc (rt_refl _ _ c))))).
    enough (HF : FSc c m' /\ (vr = Vint Int.zero \/ fresh_at bm m'))
      by (destruct HF as ((_ & Hw' & HC) & HP); exact (conj Hw' (conj HC HP))).
    inv Hev.
    match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
    match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars AIR.f_mario_execute_airborne_action) with (@nil (ident * type)) in Hav; inv Hav end.
    match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
      cbn in Hfree; injection Hfree as <- end.
    match goal with Hbind : bind_parameter_temps _ _ _ = Some _ |- _ =>
      change (fn_params AIR.f_mario_execute_airborne_action) with [(AIR._m, tyMSp)] in Hbind;
      cbn in Hbind; injection Hbind as <- end.
    match goal with Hr : outcome_result_value _ _ _ _ |- _ => rename Hr into Hres end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
      rewrite air_body in Hx; rename Hx into HB end.
    set (le0 := PTree.set AIR._m v _) in HB.
    assert (Hle0 : le0 ! AIR._m = Some v) by apply PTree.gss.
    clearbody le0.
    assert (Hpro1 : forall f, (f = AIR._check_common_airborne_cancels \/ f = AIR._play_far_fall_sound) ->
              forall fd, resolves lp f fd ->
                seg_okR lp bm MWF fd [v] (fun m => marg_ok bm [v] /\ fresh_at bm m) (fun m' _ => fresh_at bm m'))
      by (intros f Hf fd Hr; apply (Hpro f fd v); [destruct Hf as [Hf | Hf]; auto | exact Hr]).
    (* the body ends with fresh_at, or returns `cancel` = 0 *)
    match goal with |- FSc c ?M /\ _ => match type of Hres with outcome_result_value ?O _ _ _ =>
    enough (HB' : FSc c M /\ (fresh_at bm M \/ O = Out_return (Some (Vint Int.zero, tuint)))) end end.
    { destruct HB' as (HF & [Hf | ->]); [exact (conj HF (or_intror Hf)) |].
      split; [exact HF | left]. destruct Hres as [_ Hc0]. cbn in Hc0. injection Hc0 as <-. reflexivity. }
    (* prologue 1: cancels; if it says cancel, return *)
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ HB) as [(t1 & le1 & mm1 & t2 & J1 & J2) | (t1 & J1 & Hout)].
    2: { destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J1) as [(ta & lea & ma & tb & Ha & Hb') | (ta & Ha & Hout')].
         - destruct (call_step c v le0 _ AIR._check_common_airborne_cancels _ _ _ _ _ _ _ _ _ Hb HF0 Hle0 Hmarg
                       (conj Hmarg Hfr) eq_refl (Hpro1 _ (or_introl eq_refl)) Ha) as (HFa & _ & _ & _ & Hfa).
           destruct (noset_le _ _ _ _ _ _ _ _ _ Hb' eq_refl) as [_ ->]. exact (conj HFa (or_introl Hfa)).
         - destruct (call_step c v le0 _ AIR._check_common_airborne_cancels _ _ _ _ _ _ _ _ _ Hb HF0 Hle0 Hmarg
                       (conj Hmarg Hfr) eq_refl (Hpro1 _ (or_introl eq_refl)) Ha) as (_ & -> & _).
           congruence. }
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J1) as [(ta & lea & ma & tb & Ha & Hb') | (ta & Ha & Hout')].
    2: { congruence. }
    destruct (call_step c v le0 _ AIR._check_common_airborne_cancels _ _ _ _ _ _ _ _ _ Hb HF0 Hle0 Hmarg
                (conj Hmarg Hfr) eq_refl (Hpro1 _ (or_introl eq_refl)) Ha) as (HFa & _ & vr1 & -> & Hfa).
    destruct (noset_le _ _ _ _ _ _ _ _ _ Hb' eq_refl) as [-> ->].
    assert (Hle1 : (set_opttemp (Some AIR._t'1) vr1 le0) ! AIR._m = Some v)
      by (cbn; rewrite PTree.gso by (apply Pos.eqb_neq; vm_compute; reflexivity); exact Hle0).
    clear HB J1 Ha Hb'.
    (* prologue 2: play_far_fall_sound *)
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J2) as [(t3 & le3 & m3 & t4 & J3 & J4) | (t3 & J3 & Hout)].
    2: { destruct (call_step c v _ _ AIR._play_far_fall_sound _ _ _ _ _ _ _ _ _ Hb HFa Hle1 Hmarg
                     (conj Hmarg Hfa) eq_refl (Hpro1 _ (or_intror eq_refl)) J3) as (_ & -> & _). congruence. }
    destruct (call_step c v _ _ AIR._play_far_fall_sound _ _ _ _ _ _ _ _ _ Hb HFa Hle1 Hmarg
                (conj Hmarg Hfa) eq_refl (Hpro1 _ (or_intror eq_refl)) J3) as (HF3 & _ & vr3 & -> & Hf3).
    cbn [set_opttemp] in J4.
    clear J2 J3.
    (* the switch, then return *)
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J4) as [(t5 & le5 & m5 & t6 & J5 & J6) | (t5 & J5 & Hout)].
    - destruct (sw_part c v _ _ _ _ _ _ Hcase Hb HF3 Hf3 Hle1 Hmarg J5) as (HF5 & [Hf5 | (_ & Hc5)]).
      + destruct (noset_le _ _ _ _ _ _ _ _ _ J6 eq_refl) as [_ ->]. exact (conj HF5 (or_introl Hf5)).
      + inv J6. split; [exact HF5 | right].
        match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
          apply eval_expr_Etempvar_val in He; rewrite Hc5 in He; injection He as <- end.
        reflexivity.
    - destruct (sw_part c v _ _ _ _ _ _ Hcase Hb HF3 Hf3 Hle1 Hmarg J5) as (HF5 & [Hf5 | (-> & _)]);
        [exact (conj HF5 (or_introl Hf5)) | congruence].
  Qed.

  Lemma air_defmap :
    (prog_defmap mario_actions_airborne.prog) ! mario._mario_execute_airborne_action
      = Some (Gfun (Internal f_air)).
  Proof. vm_compute. reflexivity. Qed.

  Hypothesis Hgms : forall m, MWF m -> gms_cond_lp lp m bm.

  (* the airborne dispatcher's pre/post in FrameSplit's staged rows *)
  Lemma air_is : is_umi mario._mario_execute_airborne_action = false
    /\ is_fk mario._mario_execute_airborne_action = false
    /\ is_disp mario._mario_execute_airborne_action = true.
  Proof. vm_compute. repeat split; reflexivity. Qed.

  Theorem seg_call_rows_of_air :
    seg_call_rows_naF lp bm MWF -> air_pro_rows -> air_case_rows -> seg_call_rows_fr lp bm MWF.
  Proof.
    intros Hna Hpro Hcase f fd v Hin Hr.
    destruct (Pos.eq_dec f mario._mario_execute_airborne_action) as [-> | Hne];
      [| exact (Hna f fd v Hin Hne Hr)].
    pose proof (resolve_pin_fd lp _ _ _ _ LO_air air_defmap Hr) as ->.
    destruct air_is as (Iu & Ik & Id).
    intros m t m' vr c Hok Hw (Hgv & Hx) Hok' Hc Hb Hev.
    unfold xpre in Hx. rewrite Ik, Id in Hx. destruct Hx as (Hx & _).
    assert (Hmarg : marg_ok bm [v]).
    { destruct v; cbn; try exact I. destruct Hgv as (gb & Hg & Hl).
      exact (Hgms m (proj2 (proj2 Hok)) gb b i Hg Hl). }
    unfold post_of. rewrite Iu, Ik, Id. cbn [orb].
    exact (air_seg v Hpro Hcase Hmarg m t m' vr c Hok Hw Hx Hok' Hc Hb Hev).
  Qed.
End AirSplitS.
