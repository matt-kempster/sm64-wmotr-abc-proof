(* ======================================================================= *)
(* AutoSplit: GOAL 2's automatic-dispatcher row, split per action case.    *)
(*                                                                         *)
(* The AirSplit analogue for mario_execute_automatic_action, a 17-case     *)
(* switch on m->action.  Until 2026-10-21 its whole row sat inside         *)
(* FrameSplit's per-call row Hseg_call_na.  This file PROVES that row      *)
(* (aut_seg, seg_call_rows_naF_of_auto) from:                              *)
(*   - the prologue call check_common_automatic_cancels: one more call of *)
(*     AirSplit.air_pro_rows (the dispatchers' prologue rows);            *)
(*   - the store m->quicksandDepth = 0.0f, PROVED here: it keeps GOAL 1's *)
(*     mem_ok (MWF's window, NoAImpliesNoFlyTwelve.mwf_window_linked12),  *)
(*     the frame world (in particular WMotRWorld's quicksandDepth = 0     *)
(*     conjunct, which it re-establishes), Phi's cells and fresh_at;      *)
(*   - one row per case whose label is a no-A action (aut_case_list,      *)
(*     computed from the generated switch: 12 cases, 6 pole, 5 ledge and  *)
(*     IN_CANNON), each handler called with the action cell EQUAL to its   *)
(*     label and the floor fresh (its label is in the automatic group,    *)
(*     which FfWorld.fresh_at covers): aut_case_rows.                     *)
(* The other 5 cases (the 3 hang actions, GRABBED, TORNADO_TWIRLING) are   *)
(* dead: the frame world keeps the action in R_noA, and the switch reads   *)
(* that cell.  GOAL 1's per-handler result (auto_leaves_linked12) gives    *)
(* mem_ok across each call.                                               *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_automatic.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface AirborneSurface
  DispatchKit AutomaticSurface.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FloorExec FfWorld AirSplit.
From SM64.Proofs.WMotRRequiresA Require AnimWorld AnimKeep.
From SM64.Proofs Require Import Generic.ClosedMem.
Import ListNotations.

Module AUT := mario_actions_automatic.

Definition f_aut : Clight.function := AUT.f_mario_execute_automatic_action.

(* the dispatch switch's cases, read off the generated body *)
Definition aut_ls : labeled_statements :=
  match fn_body f_aut with
  | Ssequence _ (Ssequence _ (Ssequence (Ssequence _ (Sswitch _ ls)) _)) => ls
  | _ => LSnil
  end.

(* a case `t = f(m); cancel = t; break;` *)
Definition aut_case_call (s : statement) : option ident :=
  match s with
  | Ssequence (Ssequence (Scall (Some t) (Evar f (Tfunction (pty :: nil) _ _))
                                 (Etempvar p ty :: nil))
                         (Sset c (Etempvar t' _)))
              Sbreak =>
      if Pos.eqb p AUT._m && Pos.eqb t t' && Pos.eqb c AUT._cancel
         && type_eq ty tyMSp && type_eq pty tyMSp
      then Some f else None
  | _ => None
  end.

(* the cases whose label is a no-A action: each must be a call case *)
Fixpoint aut_cases (ls : labeled_statements) : option (list (Z * ident)) :=
  match ls with
  | LSnil => Some []
  | LScons None _ _ => None
  | LScons (Some k) s rest =>
      match aut_cases rest with
      | None => None
      | Some cs =>
          if existsb (Z.eqb k) R_noA_list then
            match aut_case_call s with Some f => Some ((k, f) :: cs) | None => None end
          else Some cs
      end
  end.

Definition aut_case_list : list (Z * ident) :=
  match aut_cases aut_ls with Some l => l | None => [] end.

Lemma aut_cases_eq : aut_cases aut_ls = Some aut_case_list.
Proof. vm_compute. reflexivity. Qed.

(* the twelve live cases, computed *)
Lemma aut_case_list_eq : aut_case_list =
  [(135267136, AUT._act_holding_pole); (1049409, AUT._act_grab_pole_slow);
   (1049410, AUT._act_grab_pole_fast); (1049411, AUT._act_climbing_pole);
   (1049412, AUT._act_top_of_pole_transition); (1049413, AUT._act_top_of_pole);
   (134218571, AUT._act_ledge_grab); (1356, AUT._act_ledge_climb_slow);
   (1357, AUT._act_ledge_climb_slow); (1358, AUT._act_ledge_climb_down);
   (1359, AUT._act_ledge_climb_fast); (4977, AUT._act_in_cannon)].
Proof. vm_compute. reflexivity. Qed.

(* the switch has 17 cases; the 5 not above are dead under R_noA *)
Fixpoint ls_labels (ls : labeled_statements) : list (option Z) :=
  match ls with LSnil => [] | LScons k _ rest => k :: ls_labels rest end.
Lemma aut_ls_labels : length (ls_labels aut_ls) = 17%nat.
Proof. vm_compute. reflexivity. Qed.

(* WMotRWorld's pole / cannon action list is the switch's *)
Lemma used_acts_cases :
  forallb (fun a => existsb (fun kf => Z.eqb (fst kf) a) aut_case_list) used_acts = true.
Proof. vm_compute. reflexivity. Qed.

(* the body, with the switch's cases left as aut_ls *)
Definition qsd_stmt : statement :=
  Sassign (Efield (Ederef (Etempvar AUT._m tyMSp) (Tstruct mario._MarioState noattr))
                  AUT._quicksandDepth tfloat)
          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat).

Lemma aut_body :
  fn_body f_aut =
  Ssequence
    (Ssequence
       (Scall (Some AUT._t'1) (Evar AUT._check_common_automatic_cancels (Tfunction [tyMSp] tint cc_default))
          [Etempvar AUT._m tyMSp])
       (Sifthenelse (Etempvar AUT._t'1 tint) (Sreturn (Some (Econst_int (Int.repr 1) tint))) Sskip))
    (Ssequence qsd_stmt
       (Ssequence
          (Ssequence
             (Sset AUT._t'19 (Efield (Ederef (Etempvar AUT._m tyMSp) (Tstruct mario._MarioState noattr))
                                AUT._action tuint))
             (Sswitch (Etempvar AUT._t'19 tuint) aut_ls))
          (Sreturn (Some (Etempvar AUT._cancel tint))))).
Proof. reflexivity. Qed.

Lemma aut_vars : fn_vars f_aut = [].
Proof. reflexivity. Qed.

Lemma aut_params : fn_params f_aut = [(AUT._m, tyMSp)].
Proof. reflexivity. Qed.

Lemma qsd_fo : mario_fo mario._MarioState AUT._quicksandDepth = Some (QSD_OFF, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma qsd_window : store_window_ok QSD_OFF (size_chunk Mfloat32) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma qsd_zero : Float32.of_bits (Int.repr 0) = Float32.zero.
Proof. reflexivity. Qed.

(* the cases: a no-A label selects a call case or nothing *)
Lemma aut_cases_default : forall ls cs, aut_cases ls = Some cs -> select_switch_default ls = LSnil.
Proof.
  induction ls as [| [k|] s rest IH]; intros cs H; cbn [aut_cases select_switch_default] in H |- *; [reflexivity | | discriminate H].
  destruct (aut_cases rest) as [cs'|] eqn:E; [| discriminate H]. exact (IH cs' eq_refl).
Qed.

Lemma aut_cases_select : forall ls cs n, aut_cases ls = Some cs ->
  existsb (Z.eqb n) R_noA_list = true ->
  select_switch_case n ls = None
  \/ exists s rest f, select_switch_case n ls = Some (LScons (Some n) s rest)
                       /\ aut_case_call s = Some f /\ In (n, f) cs.
Proof.
  induction ls as [| [k|] s rest IH]; intros cs n H Hn; cbn [aut_cases select_switch_case] in H |- *; [left; reflexivity | | discriminate H].
  destruct (aut_cases rest) as [cs'|] eqn:E; [| discriminate H].
  destruct (zeq k n) as [<- | Hne].
  - assert (Hk : existsb (Z.eqb k) R_noA_list = true).
    { rewrite existsb_exists in Hn |- *. destruct Hn as (x & Hx & Hxe).
      exists x. split; [exact Hx |]. apply Z.eqb_eq in Hxe. subst. apply Z.eqb_refl. }
    rewrite Hk in H. destruct (aut_case_call s) as [f|] eqn:Ec; [| discriminate H].
    injection H as <-. right. exists s, rest, f. split; [reflexivity |]. split; [exact Ec | left; reflexivity].
  - destruct (IH cs' n eq_refl Hn) as [Hn' | (s' & r' & f & Hs & Hc & Hin)]; [left; exact Hn' |].
    right. exists s', r', f. split; [exact Hs |]. split; [exact Hc |].
    destruct (existsb (Z.eqb k) R_noA_list); [| injection H as <-; exact Hin].
    destruct (aut_case_call s); [| discriminate H]. injection H as <-. right. exact Hin.
Qed.

Lemma aut_case_call_shape : forall s f, aut_case_call s = Some f ->
  exists t c rt cc ty',
    s = Ssequence (Ssequence (Scall (Some t) (Evar f (Tfunction [tyMSp] rt cc)) [Etempvar AUT._m tyMSp])
                             (Sset c (Etempvar t ty'))) Sbreak
    /\ c = AUT._cancel.
Proof.
  intros s f H. unfold aut_case_call in H.
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

Lemma aut_case_callees : forallb (fun kf => mem_id (snd kf) automatic_callee_ids) aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma aut_case_mem : forall n f, In (n, f) aut_case_list -> mem_id f automatic_callee_ids = true.
Proof.
  intros n f H. pose proof aut_case_callees as R. rewrite forallb_forall in R.
  exact (R (n, f) H).
Qed.

Lemma ccac_mem : mem_id AUT._check_common_automatic_cancels automatic_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* every case label is an automatic action (group 0x140) *)
Lemma aut_case_grp :
  forallb (fun kf => Int.eq (Int.and (Int.repr (fst kf)) (Int.repr 448)) (Int.repr 320)) aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma aut_case_auto : forall n f, In (n, f) aut_case_list ->
  Int.and (Int.repr n) (Int.repr 448) = Int.repr 320.
Proof.
  intros n f H. pose proof aut_case_grp as R. rewrite forallb_forall in R.
  exact (Int.same_if_eq _ _ (R (n, f) H)).
Qed.

Lemma ld_store_other_q : forall m m' v ch b z bm,
  Mem.store Mfloat32 m bm QSD_OFF v = Some m' ->
  b <> bm \/ z + size_chunk ch <= QSD_OFF \/ QSD_OFF + 4 <= z ->
  Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros m m' v ch b z bm Hst H. eapply Mem.load_store_other; [exact Hst |]. exact H.
Qed.


(* side conditions of the store's frame: a cell apart from quicksandDepth *)
Ltac qside := unfold QSD_OFF, OFS_ACTION, OFS_ASTATE, OFS_ATIMER, OFS_POSY, OFS_VELY, OFS_FLOORH,
  OFS_MARIOOBJ, FFW_OBJ, FFW_ANIM, FFW_FLOOR, FFW_AREA, FFW_CTL, FFW_WALL, FFW_CEIL, WALL_OFF,
  CEIL_OFF, FLOOR_OFF, HELD_OFF, RIDDEN_OFF, MARIOOBJ_OFF, USED_OFF;
  try change (size_chunk Mptr) with 4;
  simpl; lia.

Section AutSplitS.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_aut : linkorder mario_actions_automatic.prog lp.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  Notation ge := (lp_ge lp).
  Notation mem_ok := (mem_ok_lp bm MWF).
  Notation FSc := (FS lp bm MWF).

  Hypothesis Hnoa : forall m, MWF m -> NoA_real bm m.
  (* GOAL 1: MWF's window (NoAImpliesNoFlyTwelve.mwf_window_linked12) *)
  Hypothesis Hwin : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  (* GOAL 1: every automatic handler keeps mem_ok (auto_leaves_linked12) *)
  Hypothesis Hleaves : forall fid f, mem_id fid automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.

  (* what the walk's world (FfWorld.ffw) says about where the cells live:
     Mario's object, his wall / ceiling / floor surfaces and his controller
     are not in his state block *)
  Lemma ffw_apart : forall m, ffw ge bm m ->
    (forall bo oo, Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo) -> bo <> bm)
    /\ (forall off sb so, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
          Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm)
    /\ (forall bc oc, Mem.load Mint32 m bm FFW_CTL = Some (Vptr bc oc) -> bc <> bm).
  Proof.
    intros m (_ & EX & _).
    destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                    HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                    W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
    assert (Rb : rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) bm)
      by (exists Ptrofs.zero; cbn; auto).
    split; [| split].
    - intros bo' oo' Hl. change MARIOOBJ_OFF with FFW_OBJ in Hl. rewrite Lo in Hl.
      injection Hl as <- _. exact D1.
    - intros off sb so Hoff Hl ->.
      destruct Hoff as [-> | [-> | ->]].
      + exact (Wc0 FFW_WALL bm so (or_introl eq_refl) Hl Rb).
      + exact (Wc0 FFW_CEIL bm so (or_intror eq_refl) Hl Rb).
      + change FLOOR_OFF with FFW_FLOOR in Hl. rewrite Lf in Hl. injection Hl as ->.
        destruct Wf as (b' & o' & E & _ & _ & _ & Nr). injection E as <- _. exact (Nr Rb).
    - intros bc oc Hl ->. rewrite Lc in Hl. injection Hl as ->.
      destruct Wc as (b' & o' & E & _ & _ & _ & Nr). injection E as <- _. exact (Nr Rb).
  Qed.

  (* ---- THE STORE m->quicksandDepth = 0.0f keeps everything ---- *)
  Section QSD.
    Variables (m m' : mem).
    Hypothesis Hst : Mem.store Mfloat32 m bm QSD_OFF (Vsingle Float32.zero) = Some m'.

    Lemma LQ : forall ch b z, b <> bm \/ z + size_chunk ch <= QSD_OFF \/ QSD_OFF + 4 <= z ->
      Mem.load ch m' b z = Mem.load ch m b z.
    Proof. intros ch b z H. exact (ld_store_other_q m m' _ ch b z bm Hst H). Qed.

    Lemma LQb : forall ch b z, b <> bm -> Mem.load ch m' b z = Mem.load ch m b z.
    Proof. intros ch b z H. apply LQ. left. exact H. Qed.

    Lemma LQm : forall ch z, z + size_chunk ch <= QSD_OFF \/ QSD_OFF + 4 <= z ->
      Mem.load ch m' bm z = Mem.load ch m bm z.
    Proof. intros ch z H. apply LQ. right. exact H. Qed.

    Ltac lqm := rewrite LQm by qside.
    Ltac lqm_in H := rewrite LQm in H by qside.

    Lemma qsd_action_sat : forall Q, action_sat Q m bm -> action_sat Q m' bm.
    Proof. intros Q H v Hl. apply H. lqm_in Hl. exact Hl. Qed.

    Lemma qsd_cells : forall c, ffw ge bm m -> read_cells bm m c -> read_cells bm m' c.
    Proof.
      intros c Hf (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8).
      destruct (ffw_apart m Hf) as (Ao & _).
      split; [lqm; exact H1 |]. split; [lqm; exact H2 |]. split; [lqm; exact H3 |].
      split; [lqm; exact H4 |]. split; [lqm; exact H5 |]. split; [lqm; exact H6 |].
      exists bo, oo. split; [lqm; exact H7 |].
      rewrite LQb; [exact H8 | exact (Ao bo oo H7)].
    Qed.

    Lemma qsd_fresh : fresh bm m -> fresh bm m'.
    Proof.
      intros H y fh Ly Lf. lqm_in Ly. lqm_in Lf.
      destruct (H y fh Ly Lf) as (A & [B | B]); (split; [exact A |]); [left; lqm; exact B | right; exact B].
    Qed.

    Lemma qsd_fresh_at : fresh_at bm m -> fresh_at bm m'.
    Proof.
      intros H a La Hg. lqm_in La. exact (qsd_fresh (H a La Hg)).
    Qed.

    Lemma qsd_nb : Mem.nextblock m' = Mem.nextblock m.
    Proof. exact (Mem.nextblock_store _ _ _ _ _ _ Hst). Qed.

    Lemma qsd_ffw : ffw ge bm m -> ffw ge bm m'.
    Proof.
      intros (Hgn & EX & FD).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                      HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                      W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
      set (rl := ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) in *.
      assert (Rb : rblk rl bm) by (exists Ptrofs.zero; cbn; auto).
      assert (Hnb : Ple (Mem.nextblock m) (Mem.nextblock m')) by (rewrite qsd_nb; apply Ple_refl).
      assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
        by (intros b ofs k p _ Hp; exact (Mem.perm_store_1 _ _ _ _ _ _ Hst b ofs k p Hp)).
      assert (Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk rl b -> Mem.load ch m' b z = Mem.load ch m b z)
        by (intros ch b z _ Nr; apply LQb; intros ->; exact (Nr Rb)).
      assert (Gbm : gp bm = Some (bm, 0)).
      { destruct (gp bm) as [[b' d]|] eqn:G0; [| congruence].
        destruct (closed_flat _ _ _ _ _ HC G0) as (-> & ->). reflexivity. }
      split; [rewrite qsd_nb; exact Hgn |].
      split.
      - exists gp, bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, blk, bpc, bsr, bsrc, bsms, bo, oo, bt, ot, fl, ar, inp, ctl.
        split; [refine (store_closed gp m m' Mfloat32 bm QSD_OFF (Vsingle Float32.zero) Hst HC Gbm _);
                right; intros b' o' E; discriminate E |].
        split; [exact HS |]. split; [exact HM |].
        do 13 (split; [assumption |]).
        split; [lqm; exact Lo |]. split; [exact Soo |]. split; [lqm; exact La |].
        split; [rewrite LQ by (right; left; qside); exact Lb |].
        do 5 (split; [assumption |]).
        split; [exact (Wff_keep2 ge m m' rl Hnb Hperm Hld gp gp (fun b h => h) W) |].
        split; [lqm; exact Lf |]. split; [exact (wblk_keep2 m m' rl Hnb Hperm Hld _ _ _ Wf) |].
        split; [intros off sb so Hoff Hl;
                destruct Hoff as [-> | ->]; lqm_in Hl;
                [exact (Wc0 FFW_WALL sb so (or_introl eq_refl) Hl)
                | exact (Wc0 FFW_CEIL sb so (or_intror eq_refl) Hl)] |].
        split; [lqm; exact Lar |]. split; [exact (wblk_keep2 m m' rl Hnb Hperm Hld _ _ _ War) |].
        split; [lqm; exact Li |]. split; [exact Ai |].
        split; [lqm; exact Lc |]. split; [exact (wblk_keep2 m m' rl Hnb Hperm Hld _ _ _ Wc) |].
        split; [intros i cb co Hi Hl; rewrite LQb in Hl by exact D1; exact (Co i cb co Hi Hl) |].
        lqm; exact LPC.
      - exact (floor_data_keep2 ge m m' rl Hnb Hperm Hld gp W FD).
    Qed.

    Lemma qsd_coll : forall v, (forall b o, v = Vptr b o -> b <> bm) -> coll_obj_ok m v -> coll_obj_ok m' v.
    Proof.
      intros v Hb (b & o & t & -> & Lt & Hin & Hp & Hc).
      pose proof (Hb b o eq_refl) as Nb.
      exists b, o, t. split; [reflexivity |]. split; [rewrite LQb by exact Nb; exact Lt |].
      split; [exact Hin |]. split.
      - intros Ht. destruct (Hp Ht) as (base & top & Hi & P1 & P2 & P3).
        exists base, top. split; [exact Hi |]. rewrite !LQb by exact Nb. tauto.
      - intros Ht. destruct (Hc Ht) as (y & Hi & P1).
        exists y. split; [exact Hi |]. rewrite LQb by exact Nb. exact P1.
    Qed.

    Lemma qsd_world : ffw ge bm m -> wmotr_world bm m -> wmotr_world bm m'.
    Proof.
      intros Hf (Hw & Hc & Hfl & Hh & Hr & Hq & Ho).
      pose proof Hf as (_ & EX & _).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                      HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                      W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
      destruct (ffw_apart m Hf) as (Ao & As & _).
      split; [| split; [| split; [| split; [| split; [| split]]]]].
      - intros v Hl. lqm_in Hl. destruct (Hw v Hl) as [-> | (b & o & t & -> & Lt & Hin)]; [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        rewrite LQb; [exact Lt | exact (As WALL_OFF b o (or_introl eq_refl) Hl)].
      - intros v Hl. lqm_in Hl. destruct (Hc v Hl) as [-> | (b & o & t & -> & Lt & Hin)]; [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        rewrite LQb; [exact Lt | exact (As CEIL_OFF b o (or_intror (or_introl eq_refl)) Hl)].
      - intros v Hl. lqm_in Hl. destruct (Hfl v Hl) as (b & o & t & -> & Lt & Hin).
        exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        rewrite LQb; [exact Lt | exact (As FLOOR_OFF b o (or_intror (or_intror eq_refl)) Hl)].
      - lqm. exact Hh.
      - lqm. exact Hr.
      - rewrite (Mem.load_store_same _ _ _ _ _ _ Hst). reflexivity.
      - destruct Ho as (mb & mo & s & n & Hl & Ls & Hs & Ln & Hn & Hall).
        pose proof (Ao mb mo Hl) as Nb.
        exists mb, mo, s, n. split; [lqm; exact Hl |].
        split; [rewrite LQb by exact Nb; exact Ls |]. split; [exact Hs |].
        split; [rewrite LQb by exact Nb; exact Ln |]. split; [exact Hn |].
        intros i v Hi Hl2. rewrite LQb in Hl2 by exact Nb.
        apply qsd_coll; [| exact (Hall i v Hi Hl2)].
        intros cb co ->. change MARIOOBJ_OFF with FFW_OBJ in Hl. rewrite Lo in Hl.
        injection Hl as <- <-.
        rewrite (Co i cb co ltac:(lia) Hl2). exact D1.
    Qed.

    Lemma qsd_anim : ffw ge bm m -> anim_apart lp bm m -> anim_apart lp bm m'.
    Proof.
      intros Hf Han ab bt ot Hs Hl.
      destruct (ffw_apart m Hf) as (Ao & _ & _).
      rewrite LQ in Hl by (right; left; qside).
      destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
      - intros off sb so Hoff Hl'.
        destruct Hoff as [-> | [-> | ->]]; lqm_in Hl';
          [exact (A1 WALL_OFF sb so (or_introl eq_refl) Hl')
          | exact (A1 CEIL_OFF sb so (or_intror (or_introl eq_refl)) Hl')
          | exact (A1 FLOOR_OFF sb so (or_intror (or_intror eq_refl)) Hl')].
      - intros mb mo i cb co Hl' Hi Hl2. lqm_in Hl'.
        rewrite LQb in Hl2 by exact (Ao mb mo Hl').
        exact (A2 mb mo i cb co Hl' Hi Hl2).
    Qed.

    Lemma qsd_mobj : ffw ge bm m -> mobj_apart bm m -> mobj_apart bm m'.
    Proof.
      intros Hf Hmo mb mo Hl.
      destruct (ffw_apart m Hf) as (Ao & _ & _).
      lqm_in Hl.
      destruct (Hmo mb mo Hl) as (P1 & P2 & P3).
      split; [exact P1 |]. split.
      - intros off sb so Hoff Hl'.
        destruct Hoff as [-> | [-> | ->]]; lqm_in Hl';
          [exact (P2 WALL_OFF sb so (or_introl eq_refl) Hl')
          | exact (P2 CEIL_OFF sb so (or_intror (or_introl eq_refl)) Hl')
          | exact (P2 FLOOR_OFF sb so (or_intror (or_intror eq_refl)) Hl')].
      - intros i cb co Hi Hl'. rewrite LQb in Hl' by exact (Ao mb mo Hl).
        exact (P3 i cb co Hi Hl').
    Qed.

    Lemma qsd_adown : ffw ge bm m -> a_down_real bm m' = a_down_real bm m.
    Proof.
      intros Hf. destruct (ffw_apart m Hf) as (_ & _ & Ac).
      unfold a_down_real. lqm.
      destruct (Mem.load Mptr m bm 156) as [[] |] eqn:E; try reflexivity.
      rewrite LQb; [reflexivity | exact (Ac _ _ E)].
    Qed.

    Lemma qsd_used : ffw ge bm m -> used_ok bm m -> used_ok bm m'.
    Proof.
      intros Hf. destruct (ffw_apart m Hf) as (Hmbm & _ & _).
      apply used_ok_keep.
      - intros o ch Hin. apply LQm. cbn [In] in Hin.
        destruct Hin as [E | [E | [E | [E | []]]]]; injection E as <- <-; qside.
      - intros ub uo _ A z _. exact (LQb _ _ _ (proj1 A)).
      - intros mb mo Hl. apply LQb. exact (Hmbm mb mo Hl).
      - intros mb mo Hl i Hi. apply LQb. exact (Hmbm mb mo Hl).
    Qed.

    (* the animation world: the store is in Mario's state, away from its cells *)
    Lemma qsd_anim_w : ffw ge bm m -> AnimWorld.anim_w ge bm m -> AnimWorld.anim_w ge bm m'.
    Proof.
      intros Hf AW. pose proof Hf as (Hgn & EX & FD).
      destruct (ffw_apart m Hf) as (Ao & _ & _).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot
                      & fl & ar & inp & ctl & HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS
                      & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 & W & _).
      pose proof AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & _).
      pose proof B as (Sab & _ & _ & _ & L8 & _ & Sy & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & Hbm0).
      assert (ab' = ab) by congruence. subst ab'.
      rewrite Lb in L8. injection L8 as <- <-.
      assert (Nab : ab <> bm) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 Hbm0 eq_refl).
      apply (AnimKeep.anim_w_keep ge bm m m' gp bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bo oo bt ot
               S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS Lo Lb W AW).
      - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). apply Ple_refl.
      - intros b ofs k p _ Hp. exact (Mem.perm_store_1 _ _ _ _ _ _ Hst b ofs k p Hp).
      - intros ch b z _ Hr. apply LQb. intros ->. apply Hr. exists Ptrofs.zero.
        unfold ff_rl. cbn. left; reflexivity.
      - lqm. reflexivity.
      - apply LQb. exact Nab.
      - apply LQb. exact Nab.
      - lqm. reflexivity.
      - lqm. reflexivity.
      - right. split; [lqm; reflexivity |]. split; [apply LQb; exact Nab |]. split.
        + intros o ch _. apply LQb. exact (Ao bo oo Lo).
        + intros k rel ch v0 _ _. apply LQb. exact (not_eq_sym (proj2 (Sy _ _ Hbm0))).
    Qed.

    Lemma qsd_fworld : fworld lp bm m -> fworld lp bm m'.
    Proof.
      intros (Ha & Hw & Han & Hmo & Hd & Hf & Hu & Haw).
      split; [exact (qsd_action_sat _ Ha) |].
      split; [exact (qsd_world Hf Hw) |].
      split; [exact (qsd_anim Hf Han) |].
      split; [exact (qsd_mobj Hf Hmo) |].
      split; [rewrite (qsd_adown Hf); exact Hd |].
      split; [exact (qsd_ffw Hf) |]. split; [exact (qsd_used Hf Hu) | exact (qsd_anim_w Hf Haw)].
    Qed.

    Lemma qsd_mem_ok : mem_ok m -> mem_ok m'.
    Proof.
      intros (Hv & Hnt & HM).
      split; [exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hst bm Hv) |].
      split; [exact (qsd_action_sat _ Hnt) |].
      exact (Hwin m m' Mfloat32 QSD_OFF _ HM qsd_window Hst).
    Qed.

    Lemma qsd_FS : forall c0, FSc c0 m -> FSc c0 m'.
    Proof.
      intros c0 (Hok & Hw & c & Hc & Hmc).
      pose proof Hw as (_ & _ & _ & _ & _ & Hf & _).
      split; [exact (qsd_mem_ok Hok) |]. split; [exact (qsd_fworld Hw) |].
      exists c. split; [exact (qsd_cells c Hf Hc) | exact Hmc].
    Qed.
  End QSD.

  (* the store statement's effect *)
  Lemma qsd_eff : forall le m t le' m' out v,
    le ! AUT._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m qsd_stmt t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.store Mfloat32 m bm QSD_OFF (Vsingle Float32.zero) = Some m'.
  Proof.
    intros le m t le' m' out v Hle Hmarg H.
    unfold qsd_stmt in H. inv H.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp LO_mario _ _ _ _ _ _ _ _ _ _ L1 eq_refl qsd_fo) as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->].
    match goal with He : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ =>
      inv He; try match goal with Hl : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _ |- _ =>
                    solve [inv Hl] end end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn in Hc; injection Hc as <- end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    split; [reflexivity |]. split; [reflexivity |].
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => exact Hs end.
  Qed.

  (* ---- the calls ---- *)
  Lemma call_step_aut : forall c0 v le m f rt cc optid t le' m' out (pre : mem -> Prop)
      (post : mem -> val -> Prop),
    budget_ok c0 -> FSc c0 m -> le ! AUT._m = Some v -> marg_ok bm [v] -> pre m ->
    mem_id f automatic_callee_ids = true ->
    (forall fd, resolves lp f fd -> seg_okR lp bm MWF fd [v] pre post) ->
    exec_stmt function_entry2 ge empty_env le m
      (Scall optid (Evar f (Tfunction [tyMSp] rt cc)) [Etempvar AUT._m tyMSp]) t le' m' out ->
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
    destruct (aut_call_pres lp LO_aut bm (NoA_real bm) MWF Hnoa Hleaves f Hmem
                _ m [v] _ _ _ Hev (ex_intro _ b (conj Hs Hff0)) Hmarg (Hnoa m HM) HM Hv Hnt)
      as (Hv' & Hnt' & HM' & _).
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
  Lemma aut_action_load : forall le m v va,
    le ! AUT._m = Some v -> marg_ok bm [v] ->
    eval_expr ge empty_env le m (Efield (Ederef (Etempvar AUT._m tyMSp) (Tstruct mario._MarioState noattr))
                                   AUT._action tuint) va ->
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

  (* ---- THE ROWS: each no-A case's handler, called with the action cell =
     its label and the floor fresh (its label is automatic, which fresh_at
     covers); it returns FALSE or leaves the floor fresh ---- *)
  Definition aut_case_rows : Prop :=
    forall n f fd v, In (n, f) aut_case_list -> resolves lp f fd ->
      seg_okR lp bm MWF fd [v]
        (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n))
                  /\ fresh bm m)
        (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

  Lemma aut_sw_part : forall c v le m t le' m' out,
    aut_case_rows -> budget_ok c -> FSc c m -> fresh_at bm m -> le ! AUT._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m
      (Ssequence (Sset AUT._t'19 (Efield (Ederef (Etempvar AUT._m tyMSp) (Tstruct mario._MarioState noattr))
                                    AUT._action tuint))
                 (Sswitch (Etempvar AUT._t'19 tuint) aut_ls)) t le' m' out ->
    FSc c m' /\ (fresh_at bm m' \/ (out = Out_normal /\ le' ! AUT._cancel = Some (Vint Int.zero))).
  Proof.
    intros c v le m t le' m' out Hcase Hb HF HFr Hle Hmarg H.
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ H) as [(t1 & le1 & m1 & t2 & K1 & K2) | (t1 & K1 & Hn)].
    2: { inv K1. congruence. }
    inv K1.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => rename He into Ea end.
    destruct (aut_action_load _ _ _ _ Hle Hmarg Ea) as (-> & Hld).
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
    destruct (aut_cases_select aut_ls aut_case_list _ aut_cases_eq Hex)
      as [Hnone | (s & rest & f & Hsel & Hcc & Hin)].
    - unfold select_switch in Kx. rewrite Hnone, (aut_cases_default aut_ls _ aut_cases_eq) in Kx.
      cbn in Kx. inv Kx. exact (conj HF (or_introl HFr)).
    - unfold select_switch in Kx. rewrite Hsel in Kx. cbn [seq_of_labeled_statement] in Kx.
      destruct (aut_case_call_shape s f Hcc) as (t0 & c' & rt & cc & ty' & -> & ->).
      assert (Hle1 : (PTree.set AUT._t'19 (Vint i) le) ! AUT._m = Some (Vptr bm Ptrofs.zero))
        by (rewrite PTree.gso by (apply Pos.eqb_neq; vm_compute; reflexivity); exact Hle).
      assert (Hfr : fresh bm mF).
      { apply (HFr i Hld). right. rewrite <- (Int.repr_unsigned i). exact (aut_case_auto _ _ Hin). }
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
        * destruct (call_step_aut c (Vptr bm Ptrofs.zero) _ _ f rt cc _ _ _ _ _ _ _
                      Hb HF Hle1 Hmarg Hpre (aut_case_mem _ _ Hin) Hrow K7)
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
        * destruct (call_step_aut c (Vptr bm Ptrofs.zero) _ _ f rt cc _ _ _ _ _ _ _
                      Hb HF Hle1 Hmarg Hpre (aut_case_mem _ _ Hin) Hrow K7) as (_ & -> & _).
          congruence.
  Qed.

  (* THE AUTOMATIC DISPATCHER'S ROW: from the prologue row, the store and
     the case rows, with the dispatch's floor refresh in and, when it
     returns nonzero, out *)
  Theorem aut_seg : forall v,
    air_pro_rows lp bm MWF -> aut_case_rows -> marg_ok bm [v] ->
    seg_okR lp bm MWF (Internal f_aut) [v] (fun m => fresh_at bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh_at bm m').
  Proof.
    intros v Hpro Hcase Hmarg m t m' vr c Hok Hw Hfr Hok' Hc Hb Hev.
    assert (HF0 : FSc c m) by exact (conj Hok (conj Hw (ex_intro _ c (conj Hc (rt_refl _ _ c))))).
    enough (HF : FSc c m' /\ (vr = Vint Int.zero \/ fresh_at bm m'))
      by (destruct HF as ((_ & Hw' & HC) & HP); exact (conj Hw' (conj HC HP))).
    inv Hev.
    match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
    match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars AUT.f_mario_execute_automatic_action) with (@nil (ident * type)) in Hav; inv Hav end.
    match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
      cbn in Hfree; injection Hfree as <- end.
    match goal with Hbind : bind_parameter_temps _ _ _ = Some _ |- _ =>
      change (fn_params AUT.f_mario_execute_automatic_action) with [(AUT._m, tyMSp)] in Hbind;
      cbn in Hbind; injection Hbind as <- end.
    match goal with Hr : outcome_result_value _ _ _ _ |- _ => rename Hr into Hres end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
      rewrite aut_body in Hx; rename Hx into HB end.
    set (le0 := PTree.set AUT._m v _) in HB.
    assert (Hle0 : le0 ! AUT._m = Some v) by apply PTree.gss.
    clearbody le0.
    assert (Hpro1 : forall fd, resolves lp AUT._check_common_automatic_cancels fd ->
                seg_okR lp bm MWF fd [v] (fun m => marg_ok bm [v] /\ fresh_at bm m) (fun m' _ => fresh_at bm m'))
      by (intros fd Hr; exact (Hpro _ fd v (or_intror (or_intror eq_refl)) Hr)).
    (* the body ends with fresh_at, or returns `cancel` = 0 *)
    match goal with |- FSc c ?M /\ _ => match type of Hres with outcome_result_value ?O _ _ _ =>
    enough (HB' : FSc c M /\ (fresh_at bm M \/ O = Out_return (Some (Vint Int.zero, tint)))) end end.
    { destruct HB' as (HF & [Hf | ->]); [exact (conj HF (or_intror Hf)) |].
      split; [exact HF | left]. destruct Hres as [_ Hc0]. cbn in Hc0. injection Hc0 as <-. reflexivity. }
    (* prologue: the cancels; if it says cancel, return *)
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ HB) as [(t1 & le1 & mm1 & t2 & J1 & J2) | (t1 & J1 & Hout)].
    2: { destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J1) as [(ta & lea & ma & tb & Ha & Hb') | (ta & Ha & Hout')].
         - destruct (call_step_aut c v le0 _ AUT._check_common_automatic_cancels _ _ _ _ _ _ _ _ _ Hb HF0 Hle0 Hmarg
                       (conj Hmarg Hfr) ccac_mem Hpro1 Ha) as (HFa & _ & _ & _ & Hfa).
           destruct (noset_le _ _ _ _ _ _ _ _ _ Hb' eq_refl) as [_ ->]. exact (conj HFa (or_introl Hfa)).
         - destruct (call_step_aut c v le0 _ AUT._check_common_automatic_cancels _ _ _ _ _ _ _ _ _ Hb HF0 Hle0 Hmarg
                       (conj Hmarg Hfr) ccac_mem Hpro1 Ha) as (_ & -> & _).
           congruence. }
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J1) as [(ta & lea & ma & tb & Ha & Hb') | (ta & Ha & Hout')].
    2: { congruence. }
    destruct (call_step_aut c v le0 _ AUT._check_common_automatic_cancels _ _ _ _ _ _ _ _ _ Hb HF0 Hle0 Hmarg
                (conj Hmarg Hfr) ccac_mem Hpro1 Ha) as (HFa & _ & vr1 & -> & Hfa).
    destruct (noset_le _ _ _ _ _ _ _ _ _ Hb' eq_refl) as [-> ->].
    assert (Hle1 : (set_opttemp (Some AUT._t'1) vr1 le0) ! AUT._m = Some v)
      by (cbn; rewrite PTree.gso by (apply Pos.eqb_neq; vm_compute; reflexivity); exact Hle0).
    clear HB J1 Ha Hb'.
    (* the store quicksandDepth = 0 *)
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J2) as [(t3 & le3 & m3 & t4 & J3 & J4) | (t3 & J3 & Hout)].
    2: { destruct (qsd_eff _ _ _ _ _ _ _ Hle1 Hmarg J3) as (_ & -> & _). congruence. }
    destruct (qsd_eff _ _ _ _ _ _ _ Hle1 Hmarg J3) as (-> & _ & Hst3).
    pose proof (qsd_FS _ _ Hst3 c HFa) as HF3.
    pose proof (qsd_fresh_at _ _ Hst3 Hfa) as Hf3.
    clear J2 J3.
    (* the switch, then return *)
    destruct (seq_inv _ _ _ _ _ _ _ _ _ _ J4) as [(t5 & le5 & m5 & t6 & J5 & J6) | (t5 & J5 & Hout)].
    - destruct (aut_sw_part c v _ _ _ _ _ _ Hcase Hb HF3 Hf3 Hle1 Hmarg J5) as (HF5 & [Hf5 | (_ & Hc5)]).
      + destruct (noset_le _ _ _ _ _ _ _ _ _ J6 eq_refl) as [_ ->]. exact (conj HF5 (or_introl Hf5)).
      + inv J6. split; [exact HF5 | right].
        match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
          apply eval_expr_Etempvar_val in He; rewrite Hc5 in He; injection He as <- end.
        reflexivity.
    - destruct (aut_sw_part c v _ _ _ _ _ _ Hcase Hb HF3 Hf3 Hle1 Hmarg J5) as (HF5 & [Hf5 | (-> & _)]);
        [exact (conj HF5 (or_introl Hf5)) | congruence].
  Qed.

  Lemma aut_defmap :
    (prog_defmap mario_actions_automatic.prog) ! mario._mario_execute_automatic_action
      = Some (Gfun (Internal f_aut)).
  Proof. vm_compute. reflexivity. Qed.

  Hypothesis Hgms : forall m, MWF m -> gms_cond_lp lp m bm.

  Lemma aut_is : is_umi mario._mario_execute_automatic_action = false
    /\ is_fk mario._mario_execute_automatic_action = false
    /\ is_disp mario._mario_execute_automatic_action = true.
  Proof. vm_compute. repeat split; reflexivity. Qed.

  (* the per-call rows with BOTH dispatchers apart: what stays assumed *)
  Definition seg_call_rows_naFA : Prop :=
    forall f fd v, In (OCall f) ema_obls -> f <> mario._mario_execute_airborne_action ->
      f <> mario._mario_execute_automatic_action ->
      resolves lp f fd -> seg_okR lp bm MWF fd [v] (pre_of lp bm f v) (post_of bm f).

  Theorem seg_call_rows_naF_of_auto :
    seg_call_rows_naFA -> air_pro_rows lp bm MWF -> aut_case_rows -> seg_call_rows_naF lp bm MWF.
  Proof.
    intros Hna Hpro Hcase f fd v Hin Hnair Hr.
    destruct (Pos.eq_dec f mario._mario_execute_automatic_action) as [-> | Hne];
      [| exact (Hna f fd v Hin Hnair Hne Hr)].
    pose proof (resolve_pin_fd lp _ _ _ _ LO_aut aut_defmap Hr) as ->.
    destruct aut_is as (Iu & Ik & Id).
    intros m t m' vr c Hok Hw (Hgv & Hx) Hok' Hc Hb Hev.
    unfold xpre in Hx. rewrite Ik, Id in Hx.
    assert (Hmarg : marg_ok bm [v]).
    { destruct v; cbn; try exact I. destruct Hgv as (gb & Hg & Hl).
      exact (Hgms m (proj2 (proj2 Hok)) gb b i Hg Hl). }
    unfold post_of. rewrite Iu, Ik, Id. cbn [orb].
    exact (aut_seg v Hpro Hcase Hmarg m t m' vr c Hok Hw Hx Hok' Hc Hb Hev).
  Qed.
End AutSplitS.
