(* spine (via CamFootInst): the set_mario_npc_dialog leaf of the camera
   footprint, proved from the real bodies of its call tree. *)
(* ====================================================================== *)
(* CamFootNpc.v -- set_mario_npc_dialog's FOOTPRINT under the pins.       *)
(*                                                                        *)
(* The camera's dialog cutscenes call set_mario_npc_dialog(arg) (any arg). *)
(* Its body reads Mario through the gMarioState pin (an FP block:          *)
(* gMarioStates), stores Mario's actionState / usedObj, calls             *)
(* mario_ready_to_speak (no store) and                                    *)
(*     set_mario_action(gMarioState, ACT_READING_NPC_DIALOG, arg)         *)
(* with the action a LITERAL constant (0x20001306).  set_mario_action     *)
(* switches on (action & ACT_GROUP_MASK); for this action only the        *)
(* cutscene arm runs (set_mario_action_cutscene -> mario_set_forward_vel),*)
(* then the common tail stores Mario's flags / prevAction / action /      *)
(* actionArg / actionState / actionTimer.  The moving and airborne arms   *)
(* (which store into Mario's OBJECT, m->marioObj, a block the camera walk *)
(* cannot classify) are dead for this constant: sma_prune proves the real *)
(* body's run equals the run of the body with those arms emptied, read    *)
(* off the generated switch (the selected suffix is the same).           *)
(*                                                                        *)
(* THEOREM (npc_spec): the walk's fspec for the real set_mario_npc_dialog *)
(* at ([fA], fA): from any memory whose pins hold, it changes memory only *)
(* in the FP blocks (here: gMarioStates), blocks born during the call and *)
(* the pin cells (kept), keeps every old permission and the pins.         *)
(* Proved with CamFootSound's walk (a three-body sub-table) and a         *)
(* statement walk of the npc body that admits the one constant-action     *)
(* call.  NO new premise.                                                 *)
(* ====================================================================== *)

From Coq Require Import String List ZArith Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Linking Clightdefs.
From SM64.Generated Require mario mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import CamFootKit CamFootSound CamFootTable.
From SM64.Proofs Require SpawnBodies MtxfBody CameraModeBody MathGeomGated ObjHelpersBodies.
Import ListNotations.
Local Open Scope Z_scope.

Module C := mario_actions_cutscene.

(* ---------------------------------------------------------------------- *)
(* 1. set_mario_action at the npc's constant action.                       *)
(* ---------------------------------------------------------------------- *)

(* ACT_READING_NPC_DIALOG, as the npc body passes it *)
Definition KA : int := Int.repr 536875782.

Definition sma_a : expr :=
  match fn_body mario.f_set_mario_action with Ssequence (Sswitch a _) _ => a | _ => Etempvar 1%positive tint end.
Definition sma_sl : labeled_statements :=
  match fn_body mario.f_set_mario_action with Ssequence (Sswitch _ sl) _ => sl | _ => LSnil end.
Definition sma_rest : statement :=
  match fn_body mario.f_set_mario_action with Ssequence _ r => r | _ => Sskip end.

(* the arms before the cutscene case emptied *)
Definition prune3 (sl : labeled_statements) : labeled_statements :=
  match sl with
  | LScons c1 _ (LScons c2 _ (LScons c3 _ rest)) => LScons c1 Sskip (LScons c2 Sskip (LScons c3 Sskip rest))
  | _ => sl
  end.

Definition f_sma' : function :=
  {| fn_return := fn_return mario.f_set_mario_action;
     fn_callconv := fn_callconv mario.f_set_mario_action;
     fn_params := fn_params mario.f_set_mario_action;
     fn_vars := fn_vars mario.f_set_mario_action;
     fn_temps := fn_temps mario.f_set_mario_action;
     fn_body := Ssequence (Sswitch sma_a (prune3 sma_sl)) sma_rest |}.

Lemma sma_body : fn_body mario.f_set_mario_action = Ssequence (Sswitch sma_a sma_sl) sma_rest.
Proof. reflexivity. Qed.

(* the cutscene group's case selects the same suffix *)
Lemma sma_sel : select_switch 256 sma_sl = select_switch 256 (prune3 sma_sl).
Proof. vm_compute. reflexivity. Qed.

Lemma sma_a_eq : sma_a = Ebinop Oand (Etempvar mario._action tuint) (Econst_int (Int.repr 448) tint) tuint.
Proof. reflexivity. Qed.

(* the switch value at action = KA: (KA & ACT_GROUP_MASK) = ACT_GROUP_CUTSCENE *)
Lemma sma_arg : forall (ge : genv) e le m v n,
    le ! mario._action = Some (Vint KA) -> eval_expr ge e le m sma_a v ->
    sem_switch_arg v (typeof sma_a) = Some n -> n = 256.
Proof.
  intros ge e le m v n Ha Hv Hs.
  rewrite sma_a_eq in Hv, Hs.
  inv Hv; [ | match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end ].
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H end;
    [ | match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end ].
  match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H end;
    [ | match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end ].
  match goal with H : _ ! mario._action = Some _ |- _ => rewrite Ha in H; injection H as <- end.
  match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => vm_compute in H; injection H as <- end.
  vm_compute in Hs. injection Hs as <-. reflexivity.
Qed.

Lemma sma_prune : forall (ge : genv) m v5 va t m' vres,
    eval_funcall function_entry2 ge m (Internal mario.f_set_mario_action) [v5; Vint KA; va] t m' vres ->
    eval_funcall function_entry2 ge m (Internal f_sma') [v5; Vint KA; va] t m' vres.
Proof.
  intros ge m v5 va t m' vres H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hor end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  assert (Hle : forall e le m1, function_entry2 ge mario.f_set_mario_action [v5; Vint KA; va] m e le m1 ->
                  le ! mario._action = Some (Vint KA)).
  { intros e0 le0 m10 Hen. inv Hen.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn in Hb; injection Hb as <- end.
    reflexivity. }
  pose proof (Hle _ _ _ Hentry) as Ha.
  match type of Hentry with function_entry2 _ _ _ _ ?E ?LE ?M1 =>
    assert (Hentry' : function_entry2 ge f_sma' [v5; Vint KA; va] m E LE M1)
      by (destruct Hentry; constructor; assumption) end.
  eapply eval_funcall_internal; [ exact Hentry' | | exact Hor | exact Hfree ].
  rewrite sma_body in Hbody. cbn [fn_body f_sma'].
  match type of Hentry with function_entry2 _ _ _ _ ?E ?LE ?M1 =>
  assert (Hsw : forall tq leq mq outq,
             exec_stmt function_entry2 ge E LE M1 (Sswitch sma_a sma_sl) tq leq mq outq ->
             exec_stmt function_entry2 ge E LE M1 (Sswitch sma_a (prune3 sma_sl)) tq leq mq outq) end.
  { intros tq leq mq outq Hx. inv Hx.
    match goal with Hv : eval_expr _ _ _ _ sma_a ?v, Hs : sem_switch_arg ?v _ = Some ?n,
                    Hd : exec_stmt _ _ _ _ _ (seq_of_labeled_statement (select_switch ?n _)) _ _ _ _ |- _ =>
      pose proof (sma_arg _ _ _ _ _ _ Ha Hv Hs) as En; subst n;
      rewrite sma_sel in Hd; eapply exec_Sswitch; eassumption
    end. }
  inv Hbody.
  - eapply exec_Sseq_1; [ exact (Hsw _ _ _ _ ltac:(eassumption)) | eassumption ].
  - eapply exec_Sseq_2; [ exact (Hsw _ _ _ _ ltac:(eassumption)) | eassumption ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The sub-table: the cutscene arm and mario_ready_to_speak.            *)
(* ---------------------------------------------------------------------- *)

Definition npc_tab : ftab :=
  [(mario._set_mario_action_cutscene, ([fF; fN; fA], fN));
   (mario._mario_set_forward_vel, ([fF; fN], fN));
   (C._mario_ready_to_speak, ([], fN))].

Notation ce_m := (prog_comp_env mario.prog).
Notation ce_c := (prog_comp_env C.prog).

Lemma chk_cut : fchk ce_m cf_FP cf_pins npc_tab [] ([fF; fN; fA], fN) mario.f_set_mario_action_cutscene = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_fwd : fchk ce_m cf_FP cf_pins npc_tab [] ([fF; fN], fN) mario.f_mario_set_forward_vel = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_rts : fchk ce_c cf_FP cf_pins npc_tab [] ([], fN) C.f_mario_ready_to_speak = true.
Proof. vm_compute. reflexivity. Qed.

Definition sig_sma : fsig := ([fF; fN; fA], fA).
Lemma chk_sma' : fchk ce_m cf_FP cf_pins npc_tab [] sig_sma f_sma' = true.
Proof. vm_compute. reflexivity. Qed.

(* the npc body: the walk's checks, plus the one constant-action call *)
Definition sma_ty : type :=
  Tfunction ((tptr (Tstruct mario._MarioState noattr)) :: tuint :: tuint :: nil) tuint cc_default.

Definition is_sma_call (tc : ident -> fcls) (o : option ident) (a : expr) (al : list expr) : bool :=
  match o, a, al with
  | None, Evar f fty, [Etempvar t _; Econst_int k (Tint I32 Signed _); _] =>
      Pos.eqb f mario._set_mario_action && proj_sumbool (type_eq fty sma_ty)
      && Int.eq k KA && fle (tc t) fF
  | _, _, _ => false
  end.

Lemma scast_vptr_inv :
  forall v1 ty1 ty2 m b o,
    sem_cast v1 ty1 ty2 m = Some (Vptr b o) -> v1 = Vptr b o.
Proof.
  intros v1 ty1 ty2 m b o H.
  unfold sem_cast in H.
  destruct (classify_cast ty1 ty2); destruct v1; try discriminate H;
    repeat match type of H with
           | (if ?c then _ else _) = _ => destruct c; try discriminate H
           | (match ?x with _ => _ end) = _ => destruct x; try discriminate H
           end;
    inv H; reflexivity.
Qed.

Lemma is_sma_inv : forall tc o a al, is_sma_call tc o a al = true ->
    o = None /\ a = Evar mario._set_mario_action sma_ty /\
    exists t ty katt a3, al = [Etempvar t ty; Econst_int KA (Tint I32 Signed katt); a3] /\ fle (tc t) fF = true.
Proof.
  intros tc o a al H. unfold is_sma_call in H.
  repeat (match type of H with
          | context [match ?x with _ => _ end] => is_var x; destruct x; try discriminate H
          end).
  apply andb_prop in H as [H Hfl]. apply andb_prop in H as [H Hk].
  apply andb_prop in H as [Hf Hty]. apply Pos.eqb_eq in Hf. subst.
  destruct (type_eq _ sma_ty) as [-> | ]; [ | discriminate Hty ].
  apply Int.same_if_eq in Hk. subst.
  split; [ reflexivity | split; [ reflexivity | ] ].
  do 4 eexists; split; [ reflexivity | exact Hfl ].
Qed.

Definition npc_tc : ident -> fcls := ftc_of ce_c cf_FP cf_pins npc_tab [] [fA] C.f_set_mario_npc_dialog.

Definition npc_chk : bool :=
  SpawnBodies.sw_chk (fp_set ce_c cf_FP cf_pins [] npc_tc) (fp_store ce_c cf_FP cf_pins [] npc_tc)
    (fun o a al => fp_call ce_c cf_FP cf_pins npc_tab [] [] npc_tc o a al || is_sma_call npc_tc o a al)
    (fp_ret ce_c cf_FP cf_pins [] npc_tc fA) (fn_body C.f_set_mario_npc_dialog).

Lemma npc_chk_ok : npc_chk = true.
Proof. vm_compute. reflexivity. Qed.

Lemma npc_tc_arg : npc_tc C._actionArg = fA.
Proof. vm_compute. reflexivity. Qed.

Lemma npc_vars : fn_vars C.f_set_mario_npc_dialog = [].
Proof. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. On the link.                                                         *)
(* ---------------------------------------------------------------------- *)
Section NPC.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation ge := (lp_ge lp).
  Variables (cb : block) (co : Z) (nl : block).
  Hypothesis HSZ : 0 <= co /\ co + cf_SZ <= Ptrofs.max_unsigned.
  Hypothesis HG : forall g b, Genv.find_symbol ge g = Some b -> Plt b nl.
  Hypothesis HPfp : forall x c, pin_of x cf_pins = Some c -> mem_idf x cf_FP = false.
  Hypothesis HPcb : forall x c b, pin_of x cf_pins = Some c -> Genv.find_symbol ge x = Some b -> b <> cb.

  Notation FR := (FR ge cf_FP cf_pins cb co cf_SZ nl).
  Notation St := (St ge cf_FP cf_pins cb co cf_SZ nl).
  Notation KTP := (KTP ge cf_FP cb co cf_SZ nl).
  Notation vokm := (vokm ge cf_FP cb co cf_SZ nl).
  Notation out_ok := (out_ok ge cf_FP cb co cf_SZ nl).
  Notation fspec := (fspec ge cf_FP cf_pins cb co cf_SZ nl).

  Definition Leaf0 (fd : Clight.fundef) (s : fsig) : Prop := False.

  Lemma HLeaf0 : forall fd s, Leaf0 fd s -> fspec fd s.
  Proof. intros fd s []. Qed.

  Lemma CE_m : CEok ge ce_m.
  Proof. intros id c Hc. exact (linkorder_comp_env_extends lp mario.prog id c (linked12_LO_mario lp H12) Hc). Qed.
  Lemma CE_c : CEok ge ce_c.
  Proof. intros id c Hc. exact (linkorder_comp_env_extends lp C.prog id c (linked12_LO_cut lp H12) Hc). Qed.

  Lemma resolve_fd : forall q fid f b fd, linkorder q lp ->
      (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      fd = Internal f.
  Proof.
    intros q fid f b fd LO Hdm Hs Hff.
    destruct (linkorder_resolves_funct lp _ _ _ LO Hdm) as (b' & Hs' & Hff').
    unfold lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-. reflexivity.
  Qed.

  Lemma npc_tab_good : TabGood ge cf_FP cf_pins npc_tab [] Leaf0.
  Proof.
    intros fid s Hf b fd Hs Hff. left.
    unfold ft_find, npc_tab in Hf. cbn [find fst] in Hf.
    destruct (Pos.eqb mario._set_mario_action_cutscene fid) eqn:E1.
    { apply Pos.eqb_eq in E1. subst fid. injection Hf as <-.
      exists mario.f_set_mario_action_cutscene, ce_m.
      split; [ exact (resolve_fd mario.prog mario._set_mario_action_cutscene mario.f_set_mario_action_cutscene b fd (linked12_LO_mario lp H12) ltac:(vm_compute; reflexivity) Hs Hff) | ].
      exact (conj CE_m chk_cut). }
    destruct (Pos.eqb mario._mario_set_forward_vel fid) eqn:E2.
    { apply Pos.eqb_eq in E2. subst fid. injection Hf as <-.
      exists mario.f_mario_set_forward_vel, ce_m.
      split; [ exact (resolve_fd mario.prog mario._mario_set_forward_vel mario.f_mario_set_forward_vel b fd (linked12_LO_mario lp H12) ltac:(vm_compute; reflexivity) Hs Hff) | ].
      exact (conj CE_m chk_fwd). }
    destruct (Pos.eqb C._mario_ready_to_speak fid) eqn:E3.
    { apply Pos.eqb_eq in E3. subst fid. injection Hf as <-.
      exists C.f_mario_ready_to_speak, ce_c.
      split; [ exact (resolve_fd C.prog C._mario_ready_to_speak C.f_mario_ready_to_speak b fd (linked12_LO_cut lp H12) ltac:(vm_compute; reflexivity) Hs Hff) | ].
      exact (conj CE_c chk_rts). }
    discriminate Hf.
  Qed.

  Lemma npc_it_good : ItGood ge cf_FP cf_pins npc_tab [] Leaf0.
  Proof. intros ty s Hf. discriminate Hf. Qed.

  Let MUT := cf_mutual ge cf_FP cf_pins cb co cf_SZ nl HSZ HG HPfp HPcb npc_tab [] Leaf0 HLeaf0
               npc_tab_good npc_it_good.

  (* set_mario_action(m, ACT_READING_NPC_DIALOG, arg): the cutscene arm *)
  Lemma sma_spec : forall b fd m v5 va t m' vres,
      Genv.find_symbol ge mario._set_mario_action = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd [v5; Vint KA; va] t m' vres ->
      vokm m fF v5 -> St m -> FR m m' /\ St m'.
  Proof.
    intros b fd m v5 va t m' vres Hs Hff Hev Hv Hst.
    rewrite (resolve_fd mario.prog mario._set_mario_action mario.f_set_mario_action b fd (linked12_LO_mario lp H12)
               ltac:(vm_compute; reflexivity) Hs Hff) in Hev.
    pose proof (sma_prune ge _ _ _ _ _ _ Hev) as Hev'.
    pose proof (cf_good_spec ge cf_FP cf_pins cb co cf_SZ nl HSZ HG HPfp HPcb npc_tab [] Leaf0 HLeaf0
                  npc_tab_good npc_it_good (Internal f_sma') sig_sma
                  (or_introl (ex_intro _ f_sma' (ex_intro _ ce_m (conj eq_refl (conj CE_m chk_sma'))))))
      as Hsp.
    assert (Hva : Forall2 (vokm m) [fF; fN; fA] [v5; Vint KA; va]).
    { constructor; [ exact Hv | constructor; [ | constructor; [ | constructor ] ] ].
      - intros bb oo E. discriminate E.
      - intros bb oo _. exact I. }
    destruct (Hsp m _ t m' vres Hev' Hva Hst) as (HF & Hs' & _).
    exact (conj HF Hs').
  Qed.

  Lemma KEIL_empty : forall m, KEIL nl m [] empty_env.
  Proof.
    intros m. split.
    - intros x b ty Hx. rewrite PTree.gempty in Hx. discriminate Hx.
    - intros x Hx. discriminate Hx.
  Qed.

  (* the npc body's statement walk *)
  Lemma npc_stmt : forall e le m s t le' m' out,
      exec_stmt function_entry2 ge e le m s t le' m' out -> e = empty_env ->
      SpawnBodies.sw_chk (fp_set ce_c cf_FP cf_pins [] npc_tc) (fp_store ce_c cf_FP cf_pins [] npc_tc)
        (fun o a al => fp_call ce_c cf_FP cf_pins npc_tab [] [] npc_tc o a al || is_sma_call npc_tc o a al)
        (fp_ret ce_c cf_FP cf_pins [] npc_tc fA) s = true ->
      KTP m npc_tc le -> St m ->
      FR m m' /\ St m' /\ KTP m' npc_tc le' /\ out_ok m' fA out.
  Proof.
    intros e le m s t le' m' out Hx.
    induction Hx; intros Ee Hchk HP Hs; subst; cbn [SpawnBodies.sw_chk] in Hchk; try discriminate Hchk.
    - (* Sskip *) exact (conj (FR_refl _ _ _ _ _ _ _ m) (conj Hs (conj HP I))).
    - (* Sassign *)
      assert (Hx : exec_stmt function_entry2 ge empty_env le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      destruct (cf_store ge cf_FP cf_pins cb co cf_SZ nl HSZ HG HPfp HPcb ce_c CE_c [] npc_tc empty_env
                  _ _ _ _ _ _ _ _ Hchk (KEIL_empty m) HP Hs Hx) as (HF & Hs').
      exact (conj HF (conj Hs' (conj (KTP_mono _ _ _ _ _ _ _ _ _ _ (FR_nb _ _ _ _ _ _ _ _ _ HF) HP) I))).
    - (* Sset *)
      exact (conj (FR_refl _ _ _ _ _ _ _ m) (conj Hs (conj
               (cf_set ge cf_FP cf_pins cb co cf_SZ nl HSZ ce_c CE_c [] npc_tc empty_env _ _ _ _ _
                  Hchk (KEIL_empty m) HP Hs ltac:(eassumption)) I))).
    - (* Scall *)
      apply orb_true_iff in Hchk as [Hc | Hc].
      + destruct (cf_call_ih ge cf_FP cf_pins cb co cf_SZ nl HSZ npc_tab [] Leaf0 npc_tab_good npc_it_good
                    ce_c [] npc_tc empty_env optid a al le m tyargs tyres cconv vf vargs f t m' vres
                    CE_c (KEIL_empty m) Hc HP Hs ltac:(eassumption) ltac:(eassumption) ltac:(eassumption)
                    ltac:(eassumption) ltac:(eassumption) (proj2 MUT _ _ _ _ _ _ ltac:(eassumption)))
          as (HF & Hs' & HP').
        exact (conj HF (conj Hs' (conj HP' I))).
      + destruct (is_sma_inv _ _ _ _ Hc) as (-> & -> & t5 & ty5 & katt & a3 & -> & Hfl).
        cbn in H. injection H as <- <- <-.
        destruct (MathGeomGated.evar_fun_val _ _ _ _ _ _ _ _ _ H0 (PTree.gempty _ _)) as (lf & Hsy & ->).
        inv H1.
        match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
        match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
        match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
        match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H end;
          [ | match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end ].
        match goal with H : sem_cast (Vint KA) _ _ _ = Some ?v |- _ =>
          vm_compute in H; injection H as <- end.
        match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?w,
                        Hc : sem_cast ?w _ _ _ = Some ?v5 |- _ =>
          assert (Hv5 : vokm m fF v5);
          [ intros bb oo E; subst v5;
            apply (scast_vptr_inv _ _ _ _ _ _) in Hc; subst w;
            inv H; [ | match goal with H' : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H' end ];
            exact (fle_pc _ _ _ _ _ _ _ _ Hfl (HP _ _ ltac:(eassumption) bb oo eq_refl))
          | ] end.
        destruct (sma_spec lf f m _ _ t m' vres Hsy ltac:(eassumption) ltac:(eassumption) Hv5 Hs) as (HF & Hs').
        exact (conj HF (conj Hs' (conj (KTP_mono _ _ _ _ _ _ _ _ _ _ (FR_nb _ _ _ _ _ _ _ _ _ HF) HP) I))).
    - (* Sseq_1 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHx1 eq_refl H1 HP Hs) as (HF1 & Hs1 & HP1 & _).
      destruct (IHHx2 eq_refl H2 HP1 Hs1) as (HF2 & Hs2 & HP2 & Ho2).
      exact (conj (FR_trans _ _ _ _ _ _ _ _ _ _ HF1 HF2) (conj Hs2 (conj HP2 Ho2))).
    - (* Sseq_2 *)
      apply andb_prop in Hchk as [H1 _]. exact (IHHx eq_refl H1 HP Hs).
    - (* Sifthenelse *)
      apply andb_prop in Hchk as [H1 H2].
      apply IHHx; [ reflexivity | destruct b; assumption | exact HP | exact Hs ].
    - (* Sreturn None *) exact (conj (FR_refl _ _ _ _ _ _ _ m) (conj Hs (conj HP I))).
    - (* Sreturn Some *)
      exact (conj (FR_refl _ _ _ _ _ _ _ m) (conj Hs (conj HP
               (cf_ret ge cf_FP cf_pins cb co cf_SZ nl HSZ ce_c CE_c [] npc_tc empty_env fA _ _ _ _
                  Hchk (KEIL_empty m) HP Hs ltac:(eassumption))))).
    - exact (conj (FR_refl _ _ _ _ _ _ _ m) (conj Hs (conj HP I))).
    - exact (conj (FR_refl _ _ _ _ _ _ _ m) (conj Hs (conj HP I))).
    - (* Sloop_stop1 *)
      apply andb_prop in Hchk as [H1 _].
      destruct (IHHx eq_refl H1 HP Hs) as (HF1 & Hs1 & HP1 & Ho1).
      split; [ exact HF1 | split; [ exact Hs1 | split; [ exact HP1 | ] ] ].
      match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end; [ exact I | exact Ho1 ].
    - (* Sloop_stop2 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHx1 eq_refl H1 HP Hs) as (HF1 & Hs1 & HP1 & _).
      destruct (IHHx2 eq_refl H2 HP1 Hs1) as (HF2 & Hs2 & HP2 & Ho2).
      split; [ exact (FR_trans _ _ _ _ _ _ _ _ _ _ HF1 HF2) | split; [ exact Hs2 | split; [ exact HP2 | ] ] ].
      match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end; [ exact I | exact Ho2 ].
    - (* Sloop_loop *)
      pose proof Hchk as Hchk'. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHx1 eq_refl H1 HP Hs) as (HF1 & Hs1 & HP1 & _).
      destruct (IHHx2 eq_refl H2 HP1 Hs1) as (HF2 & Hs2 & HP2 & _).
      destruct (IHHx3 eq_refl Hchk' HP2 Hs2) as (HF3 & Hs3 & HP3 & Ho3).
      exact (conj (FR_trans _ _ _ _ _ _ _ _ _ _ HF1 (FR_trans _ _ _ _ _ _ _ _ _ _ HF2 HF3)) (conj Hs3 (conj HP3 Ho3))).
    - (* Sswitch *)
      destruct (IHHx eq_refl (SpawnBodies.sw_chk_select _ _ _ _ _ _ Hchk) HP Hs) as (HF & Hs1 & HP1 & Ho1).
      split; [ exact HF | split; [ exact Hs1 | split; [ exact HP1 | ] ] ].
      destruct out as [ | | | [[vr tyr]|] ]; cbn; auto.
  Qed.

  (* ==================================================================== *)
  (* THE RESULT                                                            *)
  (* ==================================================================== *)
  Theorem npc_spec : forall b fd,
      Genv.find_symbol ge C._set_mario_npc_dialog = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      fspec fd ([fA], fA).
  Proof.
    intros b fd Hs Hff.
    rewrite (resolve_fd C.prog C._set_mario_npc_dialog C.f_set_mario_npc_dialog b fd (linked12_LO_cut lp H12)
               ltac:(vm_compute; reflexivity) Hs Hff).
    intros m vargs t m' vres Hev Hva Hst.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hor end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    match goal with Hb : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hb into Hbody end.
    refine (cf_wrap ge cf_FP cf_pins cb co cf_SZ nl HG HPfp HPcb _ _ _ _ _ _ _ _ _ _ _ Hentry Hor Hfree Hst _).
    intros Hs1.
    pose proof Hentry as Hentry'. inv Hentry'.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    rewrite npc_vars in Hav. inv Hav.
    match type of Hbody with exec_stmt _ _ _ ?LE ?M _ _ _ _ _ => assert (HP1 : KTP M npc_tc LE) end.
    { intros t0 v Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. subst v. apply fvok_undef.
      - destruct i as [ | [ | i ] ]; cbn in Hi; try discriminate Hi.
        injection Hi as <-. rewrite npc_tc_arg. intros bb oo _. exact I. }
    destruct (npc_stmt _ _ _ _ _ _ _ _ Hbody eq_refl npc_chk_ok HP1 Hs1) as (HF & Hs2 & _ & Ho).
    exact (conj HF (conj Hs2 Ho)).
  Qed.
End NPC.
