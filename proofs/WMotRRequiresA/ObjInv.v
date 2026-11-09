(* ======================================================================= *)
(* ObjInv.v -- the loop invariant INV_k of one object's cur_obj_update     *)
(* (GOAL 2 objects, W2, 2026-11-07; state-indexed 2026-11-09).             *)
(*                                                                         *)
(* BhvStep.cou_real runs the REAL cur_obj_update of slot k under a         *)
(* section invariant INV st m (the VM is about to execute st), kept by  *)
(* the frame Pfr (everything but the VM cursor gCurBhvCommand and slot k's *)
(* VM cells [O_CMD, O_STK + 34)).  Between frames the run carries Pobjl    *)
(* (HeightFrame), whose obj_w reads slot k's VM cells, so Pobjl itself is  *)
(* not kept while the dispatch loop moves them.  INV_k is Pobjl up to    *)
(* the VM cells, by a GHOST memory g:                                     *)
(*   Ple nb0 (nextblock m) /\ cur m /\                                     *)
(*   exists g, GPs st g /\ Ple (nextblock g) nb0                           *)
(*             /\ Mem.unchanged_on Pfr g m /\ nvB scr_b g m                *)
(* GPs st g: g is a Pobjl memory whose slot k holds the update's start     *)
(* state st0 and the step's fact X (GPo) -- or, at the pole window Wp, g   *)
(* is such a memory up to slot k's interact type and hitbox (PPk).         *)
(*                                                                         *)
(* THE POLE WINDOW (2026-11-09, FOUND/REPAIRED; docs/TRUST.md).            *)
(* bhvPoleGrabbing's first update runs word 2 SET_INT(oInteractType,      *)
(* INTERACT_POLE), words 3-4 SET_HITBOX(80, 1500), words 5-6 CALL_NATIVE  *)
(* bhv_pole_init (hitboxHeight = 10 * bparam2).  Between word 2 and the    *)
(* native the slot is an INTERACT_POLE object whose hitboxHeight is not    *)
(* its pole's (allocate_object's 100, then 1500), so obj_w's kind_ok is    *)
(* false there IN THE GAME: the earlier INV_k (Pobjl after every command) *)
(* was not an invariant, and its row premises were false (both capstones  *)
(* vacuous from ef77325a).  The repair relaxes slot k's interact type and  *)
(* hitbox cells (Rc) at the states 2, 3, 5 of bhvPoleGrabbing (Wp) ONLY;   *)
(* every other slot and every other cell keeps the frame-start memory's    *)
(* obj_w.  The native (BhvStep.native_res, the special scripts' residual)  *)
(* re-establishes GPo: obj_w's pole pins (ObjWorld.pin_ok, P) give the     *)
(* height bhv_pole_init writes.  Words 2-5 run once (before BEGIN_LOOP at  *)
(* word 8); every later update runs words 9-11 only.                       *)
(* The exit (ObjExit) is at a successor of a BREAK-type command (ext),     *)
(* never in Wp (vm, ext_nW): there the ghost is GPo.                       *)
(*                                                                         *)
(* PROVED here: BhvStep's frame hypotheses for INV_k -- Hinv (scr_ok /    *)
(* cmdtab_ok), Hinv_cur, Hinv_frame, Hinv_succ, inv_free -- and the entry. *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Proofs Require Import RealFrameLinked LinkedTwelve MWFReal.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Generated Require behavior_script.
From SM64.Proofs.WMotRRequiresA Require WMotRWorld BhvStep ClearKeep ObjWorld ObjFamily ObjSelf.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.

(* ---------------------------------------------------------------------- *)
(* 1. The pole window, decided over the VM table.                          *)
(* ---------------------------------------------------------------------- *)
Definition Wp (s : vst) : Prop := v_s s = OW.POLES /\ In (v_i s) [2; 3; 5]%nat.

Definition Wpb (s : vst) : bool := Pos.eqb (v_s s) OW.POLES && existsb (Nat.eqb (v_i s)) [2; 3; 5]%nat.

Lemma Wp_b : forall s, Wp s <-> Wpb s = true.
Proof.
  intros s. unfold Wp, Wpb. rewrite andb_true_iff, Pos.eqb_eq, existsb_exists. split.
  - intros (E & H). split; [ exact E | exists (v_i s); split; [ exact H | apply Nat.eqb_refl ] ].
  - intros (E & (x & Hx & Ex)). apply Nat.eqb_eq in Ex. subst x. exact (conj E Hx).
Qed.

Lemma Wp_dec : forall s, {Wp s} + {~ Wp s}.
Proof.
  intros s. destruct (Wpb s) eqn:E; [ left; apply Wp_b; exact E | right; intros H; apply Wp_b in H; congruence ].
Qed.

Definition ncnb (st : vst) : bool :=
  match word_at (v_s st) (v_i st) with Some w => negb (Z.shiftr w 24 =? 12) | None => true end
  || negb (existsb (Pos.eqb (v_s st)) BhvStep.sp_scripts).

Lemma ncn_b : forall st, BhvStep.ncn st -> ncnb st = true.
Proof.
  intros st [H | H]; unfold ncnb.
  - destruct (word_at (v_s st) (v_i st)) as [w|] eqn:E; [ | reflexivity ].
    pose proof (H w eq_refl) as Hn. apply Z.eqb_neq in Hn. rewrite Hn. reflexivity.
  - rewrite H. apply orb_true_r.
Qed.

(* PERF TRAP: stated inline (see BhvStep.chk42_ok) *)
Lemma wsucc_chk :
  forallb (fun st => negb (Wpb st) || negb (ncnb st)
                     || match succs st with Some l => forallb Wpb l | None => true end) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

(* the index stays in the window along an edge whose command is not the
   pole's CALL_NATIVE (word 5, the residual's) *)
Lemma W_succ : forall st l st', In st vm_tab -> succs st = Some l -> In st' l ->
  BhvStep.ncn st -> Wp st -> Wp st'.
Proof.
  intros st l st' Hst Hl Hin Hn Hw. pose proof wsucc_chk as A. rewrite forallb_forall in A.
  specialize (A st Hst). cbv beta in A.
  rewrite (proj1 (Wp_b st) Hw), (ncn_b st Hn), Hl in A. cbn [negb orb] in A.
  apply Wp_b. rewrite forallb_forall in A. exact (A st' Hin).
Qed.

Lemma ext_chk :
  forallb (fun sp => match word_at (v_s sp) (v_i sp) with
                     | Some w => negb (existsb (Z.eqb (Z.shiftr w 24)) BhvStep.brk_ops)
                     | None => true end
                     || match succs sp with Some l => forallb (fun x => negb (Wpb x)) l | None => true end)
    vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

(* the loop exits outside the window *)
Lemma ext_nW : forall st', BhvStep.ext st' -> ~ Wp st'.
Proof.
  intros st' (sp & w & l & Hsp & Hw & Hb & Hl & Hin) Hwp. pose proof ext_chk as A.
  rewrite forallb_forall in A. specialize (A sp Hsp). cbv beta in A. rewrite Hw, Hl in A.
  assert (E : existsb (Z.eqb (Z.shiftr w 24)) BhvStep.brk_ops = true)
    by (apply existsb_exists; exists (Z.shiftr w 24); split; [ exact Hb | apply Z.eqb_refl ]).
  rewrite E in A. cbn [negb orb] in A. rewrite forallb_forall in A.
  pose proof (A st' Hin) as B. rewrite (proj1 (Wp_b st') Hwp) in B. discriminate B.
Qed.

Lemma wops_chk :
  forallb (fun st => negb (Wpb st)
                     || match word_at (v_s st) (v_i st) with
                        | Some w => ((Z.shiftr w 24 =? 16) && (byte2 w =? 42)
                                     && Int.eq (BhvStep.s16_of w) (Int.repr WMotRWorld.INTERACT_POLE))
                                    || (Z.shiftr w 24 =? 35) || (Z.shiftr w 24 =? 12)
                        | None => false end) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

(* the window's commands: SET_INT(oInteractType, POLE), SET_HITBOX, CALL_NATIVE *)
Lemma W_ops : forall st w, In st vm_tab -> Wp st -> word_at (v_s st) (v_i st) = Some w ->
  (Z.shiftr w 24 = 16 /\ byte2 w = 42 /\ BhvStep.s16_of w = Int.repr WMotRWorld.INTERACT_POLE)
  \/ Z.shiftr w 24 = 35 \/ Z.shiftr w 24 = 12.
Proof.
  intros st w Hst Hwp Hw. pose proof wops_chk as A. rewrite forallb_forall in A.
  specialize (A st Hst). cbv beta in A. rewrite (proj1 (Wp_b st) Hwp), Hw in A. cbn [negb orb] in A.
  apply orb_true_iff in A as [A | A]; [ apply orb_true_iff in A as [A | A] | ].
  - left. apply andb_prop in A as [A A3]. apply andb_prop in A as [A1 A2].
    apply Z.eqb_eq in A1. apply Z.eqb_eq in A2. apply Int.same_if_eq in A3. tauto.
  - right; left. apply Z.eqb_eq. exact A.
  - right; right. apply Z.eqb_eq. exact A.
Qed.

(* an op outside the window's three is not run in the window *)
Lemma W_not : forall st w op, In st vm_tab -> Wp st -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = op -> op <> 16 -> op <> 35 -> op <> 12 -> False.
Proof.
  intros st w op Hst Hwp Hw Ho N1 N2 N3.
  destruct (W_ops st w Hst Hwp Hw) as [(E & _) | [E | E]]; rewrite Ho in E; contradiction.
Qed.

(* the pole is a special script (its natives are the residual's) *)
Lemma W_sp : forall st, Wp st -> existsb (Pos.eqb (v_s st)) BhvStep.sp_scripts = true.
Proof. intros st (E & _). rewrite E. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. INV_k.                                                               *)
(* ---------------------------------------------------------------------- *)
Section Inv.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variables (bm bc0 : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Notation MWF := (MWF_real lp bm bc0 oc0 SafeB).
  Notation Pobjl := (ClearKeep.Pobjc lp bm bc0 oc0 SafeB).

  (* the running slot (gCurrentObject = &pool[oc]) and the VM cursor *)
  Variables (go pool : block) (oc : Z) (bcc : block).
  Hypothesis Hgo : Genv.find_symbol G BhvStep.BS._gCurrentObject = Some go.
  Hypothesis Hbcc : Genv.find_symbol G BhvStep.BS._gCurBhvCommand = Some bcc.
  Hypothesis Hpool : Genv.find_symbol G ObjSelf.POOL = Some pool.
  Hypothesis Hpg : pool <> go.
  Hypothesis Hbg : bcc <> go.
  Hypothesis Hps : forall st b, In st vm_tab -> Genv.find_symbol G (v_s st) = Some b -> b <> pool.

  Notation Pfr := (BhvStep.Pfr pool oc bcc).
  Notation PfrN := (BhvStep.PfrN lp pool oc bcc).
  Notation scr := (BhvStep.scr_b lp).
  Notation cur := (BhvStep.cur go pool oc).
  Notation Vo := (BhvStep.Vo lp pool oc).

  (* the update's start state and the entry's nextblock *)
  Variable st0 : vst.
  Variable nb0 : block.
  (* a fact of the ghost the step must keep (the wiring: the running object
     stays in its ring, ObjStep) -- any X; the keeps keep it *)
  Variable X : mem -> Prop.

  (* the window's relaxed cells: slot k's oInteractType and hitbox radius /
     height *)
  Definition Rc (b : block) (o : Z) : Prop :=
    b = pool /\ (oc + 304 <= o < oc + 308 \/ oc + 504 <= o < oc + 512).

  Definition GPo (g : mem) : Prop := Pobjl g /\ Vo g st0 /\ X g.

  Definition PPk (g : mem) : Prop :=
    exists g0, GPo g0 /\ Mem.unchanged_on (fun b o => ~ Rc b o) g0 g /\ Mem.nextblock g = Mem.nextblock g0
      /\ (Mem.load Mint32 g pool (oc + 304) = Mem.load Mint32 g0 pool (oc + 304)
          \/ Mem.load Mint32 g pool (oc + 304) = Some (Vint (Int.repr WMotRWorld.INTERACT_POLE))).

  Definition GPs (s : vst) (g : mem) : Prop := GPo g \/ (Wp s /\ PPk g).

  Definition INVk (s : vst) (m : mem) : Prop :=
    Ple nb0 (Mem.nextblock m) /\ cur m
    /\ exists g, GPs s g /\ Ple (Mem.nextblock g) nb0 /\ Mem.unchanged_on Pfr g m /\ BhvStep.nvB scr g m.

  Definition Qk : vst -> Prop := ObjFamily.Qfam (v_s st0).

  Lemma Qk_closed : forall st l st', In st vm_tab -> Qk st -> succs st = Some l -> In st' l -> Qk st'.
  Proof. exact (ObjFamily.Qfam_closed (v_s st0)). Qed.

  (* a symbol's block is valid in a Pobjl memory (MWF's nextblock bound) *)
  Lemma sym_valid : forall g id b, Pobjl g -> Genv.find_symbol G id = Some b -> Mem.valid_block g b.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros g id b (Hok & _) Hs. pose proof Hok as (_ & _ & HM).
    pose proof HM as ((_ & _ & _ & _ & _ & _ & _ & Hgn) & _).
    pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Mem.valid_block, Plt, Ple in *. lia.
  Qed.

  (* the ghost's Pobjl witness: g itself, or the window's g0 *)
  Lemma gps_g0 : forall s g, GPs s g ->
    exists g0, Pobjl g0 /\ Mem.unchanged_on (fun b o => ~ Rc b o) g0 g /\ Mem.nextblock g = Mem.nextblock g0.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros s g [(Hp & _) | (_ & g0 & (Hp & _) & U & N & _)].
    - exists g. split; [ exact Hp | split; [ apply Mem.unchanged_on_refl | reflexivity ] ].
    - exists g0. exact (conj Hp (conj U N)).
  Qed.

  Lemma gps_valid : forall s g id b, GPs s g -> Genv.find_symbol G id = Some b -> Mem.valid_block g b.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros s g id b H Hs. destruct (gps_g0 s g H) as (g0 & Hp & _ & N).
    pose proof (sym_valid g0 id b Hp Hs) as V. unfold Mem.valid_block in *. rewrite N. exact V.
  Qed.

  (* cur reads gCurrentObject's cell, a Pfr cell *)
  Lemma cur_unch : forall m m', Mem.unchanged_on Pfr m m' -> Mem.valid_block m go -> cur m -> cur m'.
  Proof.
    intros m m' U Hv Hc. unfold BhvStep.cur in *.
    rewrite (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Hv); [ exact Hc | ].
    intros i _. split; [ exact (fun E => Hbg (eq_sym E)) | intros (E & _); exact (Hpg (eq_sym E)) ].
  Qed.

  Lemma cur_valid : forall m, cur m -> Mem.valid_block m go.
  Proof.
    intros m Hc. unfold BhvStep.cur in Hc. apply (Mem.valid_access_valid_block m Mint32 go 0).
    apply (Mem.valid_access_implies _ _ _ _ Readable); [ exact (Mem.load_valid_access _ _ _ _ _ Hc) | constructor ].
  Qed.

  (* ---- Hinv_frame ---- *)
  Theorem inv_frame : forall s m m', INVk s m -> PfrN m m' -> INVk s m'.
  Proof.
    intros s m m' (Hn & Hc & g & Hg & Hgn & U & NV) (U' & NV').
    pose proof (Mem.unchanged_on_nextblock _ _ _ U') as N.
    split; [ exact (Ple_trans _ _ _ Hn N) | split; [ exact (cur_unch m m' U' (cur_valid m Hc) Hc) | ] ].
    exists g. split; [ exact Hg | split; [ exact Hgn | split ] ].
    - exact (Mem.unchanged_on_trans _ _ _ _ U U').
    - exact (BhvStep.nvB_trans _ _ _ _ NV NV' (Mem.unchanged_on_nextblock _ _ _ U)).
  Qed.

  (* ---- Hinv_cur ---- *)
  Theorem inv_cur : forall s m, INVk s m -> cur m.
  Proof. intros s m (_ & Hc & _). exact Hc. Qed.

  (* ---- Hinv_succ: along a VM edge, the window is left only by the pole's
     CALL_NATIVE (the residual moves the index there itself) ---- *)
  Theorem inv_succ : forall st l st' m, In st vm_tab -> Qk st -> succs st = Some l -> In st' l ->
    BhvStep.ncn st -> INVk st m -> INVk st' m.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros st l st' m Hst _ Hl Hin Hn (Hnb & Hc & g & Hg & R).
    split; [ exact Hnb | split; [ exact Hc | exists g; split; [ | exact R ] ] ].
    destruct Hg as [Hg | (Hw & Hp)]; [ left; exact Hg | right ].
    exact (conj (W_succ st l st' Hst Hl Hin Hn Hw) Hp).
  Qed.

  (* ---- Hinv: the script blocks and BehaviorCmdTable are Pfr blocks off
     the window's cells ---- *)
  Lemma not_bcc : forall id b, Genv.find_symbol G id = Some b -> id <> BhvStep.BS._gCurBhvCommand -> b <> bcc.
  Proof. intros id b Hs Ne ->. apply Ne. eapply Genv.genv_vars_inj; [ exact Hs | exact Hbcc ]. Qed.

  Lemma scripts_not_bcc : forall s, In s (map v_s vm_tab) -> s <> BhvStep.BS._gCurBhvCommand.
  Proof.
    intros s Hin E. subst s.
    assert (A : existsb (Pos.eqb BhvStep.BS._gCurBhvCommand) (map v_s vm_tab) = false) by (vm_compute; reflexivity).
    assert (B : existsb (Pos.eqb BhvStep.BS._gCurBhvCommand) (map v_s vm_tab) = true)
      by (apply existsb_exists; exists BhvStep.BS._gCurBhvCommand; split; [ exact Hin | apply Pos.eqb_refl ]).
    rewrite B in A. discriminate A.
  Qed.

  Lemma scr_not_pool : forall s b, In s (map v_s vm_tab) -> Genv.find_symbol G s = Some b -> b <> pool.
  Proof.
    intros s b Hin Hs.
    destruct (proj1 (in_map_iff v_s vm_tab s) Hin) as [st [Es Hst]].
    rewrite <- Es in Hs. exact (Hps st b Hst Hs).
  Qed.

  (* a block off the pool and the cursor reads the same in m as in g0 *)
  Lemma ld_back : forall g0 g m b, Mem.unchanged_on (fun b o => ~ Rc b o) g0 g -> Mem.nextblock g = Mem.nextblock g0 ->
    Mem.unchanged_on Pfr g m -> b <> pool -> b <> bcc -> Mem.valid_block g0 b ->
    forall ch z, Mem.load ch m b z = Mem.load ch g0 b z.
  Proof.
    intros g0 g m b U0 N U Hbp Hbc V ch z.
    assert (Vg : Mem.valid_block g b) by (unfold Mem.valid_block in *; rewrite N; exact V).
    rewrite (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Vg); [ | intros i _; split; [ exact Hbc | intros (E & _); exact (Hbp E) ] ].
    apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U0 V). intros i _ (E & _). exact (Hbp E).
  Qed.

  Theorem inv_scr : forall s m, INVk s m -> OW.scr_ok G m /\ OW.cmdtab_ok G m.
  Proof.
    intros s m (_ & _ & g & Hg & _ & U & _).
    destruct (gps_g0 s g Hg) as (g0 & Hp & U0 & N).
    pose proof Hp as (_ & _ & _ & _ & _ & How).
    destruct How as (pool' & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    split.
    - apply (OW.scr_ok_ext G g0 m); [ | exact (OW.ow_scr _ _ _ _ _ _ _ _ _ _ _ _ C) ].
      intros s' b Hin Hs ch z.
      exact (ld_back g0 g m b U0 N U (scr_not_pool s' b Hin Hs) (not_bcc s' b Hs (scripts_not_bcc s' Hin))
               (sym_valid g0 s' b Hp Hs) ch z).
    - destruct (OW.ow_cmdtab _ _ _ _ _ _ _ _ _ _ _ _ C) as (b & Hs & L). exists b. split; [ exact Hs | ].
      intros j id Hj. destruct (L j id Hj) as (hb & Hhb & Lj). exists hb. split; [ exact Hhb | ].
      assert (Nbp : b <> pool).
      { intros ->.
        assert (Ep : behavior_script._BehaviorCmdTable = ObjSelf.POOL) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hpool ]).
        vm_compute in Ep. discriminate Ep. }
      rewrite (ld_back g0 g m b U0 N U Nbp (not_bcc _ b Hs ltac:(vm_compute; discriminate)) (sym_valid g0 _ b Hp Hs)).
      exact Lj.
  Qed.

  (* ---- inv_free: a block born after the entry is no ghost's ---- *)
  Lemma unch_valid : forall (P : block -> Z -> Prop) g m,
    Mem.unchanged_on (fun b z => P b z /\ Mem.valid_block g b) g m -> Mem.unchanged_on P g m.
  Proof.
    intros P g m U. destruct U as [N Hp Hc]. constructor.
    - exact N.
    - intros b ofs k p HP Hv. exact (Hp b ofs k p (conj HP Hv) Hv).
    - intros b ofs HP Hr. exact (Hc b ofs (conj HP (Mem.perm_valid_block _ _ _ _ _ Hr)) Hr).
  Qed.

  Theorem inv_free : BhvStep.inv_free INVk.
  Proof.
    intros s0 s m0 m b m' (Hn0 & _) Hnv (Hn & Hc & g & Hg & Hgn & U & NV) F.
    pose proof (Mem.nextblock_free _ _ _ _ _ F) as N.
    split; [ rewrite N; exact Hn | split ].
    - unfold BhvStep.cur in *. rewrite (Mem.load_free _ _ _ _ _ F); [ exact Hc | ].
      left. intros E. subst b. apply Hnv.
      (* go is a symbol block: valid in the ghost, so below nb0 <= nextblock m0 *)
      pose proof (gps_valid s g _ _ Hg Hgo) as Vg. unfold Mem.valid_block in *.
      exact (Plt_Ple_trans _ _ _ (Plt_Ple_trans _ _ _ Vg Hgn) Hn0).
    - exists g. split; [ exact Hg | split; [ exact Hgn | split ] ].
      2: { refine (BhvStep.nvB_free_new _ _ _ _ _ _ _ NV _ (Mem.unchanged_on_nextblock _ _ _ U) F).
           intros Vb. apply Hnv. unfold Mem.valid_block in *.
           exact (Plt_Ple_trans _ _ _ (Plt_Ple_trans _ _ _ Vb Hgn) Hn0). }
      apply unch_valid. apply (Mem.unchanged_on_trans _ _ m).
      + exact (Mem.unchanged_on_implies _ _ _ _ U (fun b0 z0 H _ => proj1 H)).
      + apply (Mem.free_unchanged_on _ _ _ _ _ _ F). intros i _ (_ & Vb). apply Hnv. unfold Mem.valid_block in *.
        exact (Plt_Ple_trans _ _ _ (Plt_Ple_trans _ _ _ Vb Hgn) Hn0).
  Qed.

  (* ---- the entry ---- *)
  Theorem inv_entry : forall m, Mem.nextblock m = nb0 -> Pobjl m -> Vo m st0 -> cur m -> X m -> INVk st0 m.
  Proof.
    intros m En Hp HV Hc HX. split; [ rewrite En; apply Ple_refl | split; [ exact Hc | ] ].
    exists m. split; [ left; exact (conj Hp (conj HV HX)) | ].
    split; [ rewrite En; apply Ple_refl | split; [ apply Mem.unchanged_on_refl | apply BhvStep.nvB_refl ] ].
  Qed.

  (* ---- the window's own stores (PROVED, ObjRows.t_set / t_hb): a change
     of the ghost at the relaxed cells only, that leaves slot k's interact
     type or sets it to INTERACT_POLE, keeps it a window ghost ---- *)
  Theorem win_keep : forall s g g1, Wp s -> GPs s g ->
    Mem.unchanged_on (fun b o => ~ Rc b o) g g1 -> Mem.nextblock g1 = Mem.nextblock g ->
    (Mem.load Mint32 g1 pool (oc + 304) = Mem.load Mint32 g pool (oc + 304)
     \/ Mem.load Mint32 g1 pool (oc + 304) = Some (Vint (Int.repr WMotRWorld.INTERACT_POLE))) ->
    PPk g1.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros s g g1 _ Hg U1 N1 D1.
    assert (B : exists g0, GPo g0 /\ Mem.unchanged_on (fun b o => ~ Rc b o) g0 g /\ Mem.nextblock g = Mem.nextblock g0
                /\ (Mem.load Mint32 g pool (oc + 304) = Mem.load Mint32 g0 pool (oc + 304)
                    \/ Mem.load Mint32 g pool (oc + 304) = Some (Vint (Int.repr WMotRWorld.INTERACT_POLE)))).
    { destruct Hg as [Hg | (_ & Hp)]; [ | exact Hp ].
      exists g. split; [ exact Hg | split; [ apply Mem.unchanged_on_refl | split; [ reflexivity | left; reflexivity ] ] ]. }
    destruct B as (g0 & Hg0 & U0 & N0 & D0).
    exists g0. split; [ exact Hg0 | split; [ exact (Mem.unchanged_on_trans _ _ _ _ U0 U1) | split ] ].
    - rewrite N1. exact N0.
    - destruct D1 as [D1 | D1]; [ rewrite D1; exact D0 | right; exact D1 ].
  Qed.

  (* a store inside the relaxed cells *)
  Lemma rc_store : forall g ch z v g1, Mem.store ch g pool z v = Some g1 ->
    (oc + 304 <= z /\ z + size_chunk ch <= oc + 308) \/ (oc + 504 <= z /\ z + size_chunk ch <= oc + 512) ->
    Mem.unchanged_on (fun b o => ~ Rc b o) g g1 /\ Mem.nextblock g1 = Mem.nextblock g.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros g ch z v g1 S Hz. split; [ | exact (Mem.nextblock_store _ _ _ _ _ _ S) ].
    apply (Mem.store_unchanged_on _ _ _ _ _ _ _ S). intros i Hi Hn. apply Hn. split; [ reflexivity | lia ].
  Qed.

  (* ---- the exit: outside the window the ghost is GPo ---- *)
  Lemma inv_out : forall s m, ~ Wp s -> INVk s m ->
    exists g, GPo g /\ Ple (Mem.nextblock g) nb0 /\ Mem.unchanged_on Pfr g m /\ BhvStep.nvB scr g m.
  Proof using Type. clear Hgo Hbcc Hpool Hpg Hbg Hps.
    intros s m Hn (_ & _ & g & [Hg | (Hw & _)] & R); [ exists g; exact (conj Hg R) | contradiction ].
  Qed.
End Inv.
