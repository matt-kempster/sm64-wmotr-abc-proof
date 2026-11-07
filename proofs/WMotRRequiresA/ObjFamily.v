(* ======================================================================= *)
(* ObjFamily.v -- the script family of a slot during one cur_obj_update    *)
(* (GOAL 2 objects, W2, 2026-11-07).                                       *)
(*                                                                         *)
(* FOUND (BhvStep, 2b3aca2b): the per-row keeps took the VM state from     *)
(* anywhere in vm_tab, so a field store of one script was applied to a     *)
(* slot running any other (bhvPoleGrabbing's SET_INT(oInteractType, POLE)  *)
(* on a generic slot breaks ow_cls).  The repair ties the state to the     *)
(* slot's script by a CLASS that every VM step keeps.                      *)
(*                                                                         *)
(* cls s: the facts obj_w reads off the script a slot runs -- special      *)
(* (ObjWorld.sp_scripts: the pole, cannon, boxes, red-coin star, Mario),   *)
(* a list-12 script (ObjCensus.live12, ow_dry12), live (ObjWorld.live_bhvs, *)
(* ow_script), a PARENT_BIT_CLEAR script (pbc_ids, ow_par), and the box /  *)
(* lid / coin-formation scripts (ow_ter's runs).  fam_chk_ok (vm): from a  *)
(* live script every VM step lands in a script of the same class.  The    *)
(* vm probe (2026-11-07) found 6 cross-script edges among 95 scripts; the  *)
(* two that change class start in cut scripts (bhvSpawnedStar,             *)
(* bhvObjectWaveTrail), which no slot runs (ow_script).                    *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib AST.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjCensus.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.

Definition memi (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Lemma memi_in : forall x l, memi x l = true <-> In x l.
Proof.
  intros x l. unfold memi. rewrite existsb_exists. split.
  - intros (y & Hy & E). apply Pos.eqb_eq in E. subst y. exact Hy.
  - intros H. exists x. split; [ exact H | apply Pos.eqb_refl ].
Qed.

(* the computed lists come in as arguments, so a vm check evaluates each
   once (a constant inside the per-state function is re-run per call) *)
Definition clsw (sp l12 lv pbc : list ident) (s : ident) : list bool :=
  [memi s sp; memi s l12; memi s lv; memi s pbc;
   Pos.eqb s OW.BOXS; Pos.eqb s OW.LIDS; Pos.eqb s OW.COINF].

Definition cls (s : ident) : list bool :=
  clsw OW.sp_scripts ObjCensus.live12 OW.live_bhvs OW.pbc_ids s.

Fixpoint bl_eqb (a b : list bool) : bool :=
  match a, b with
  | [], [] => true
  | x :: a', y :: b' => Bool.eqb x y && bl_eqb a' b'
  | _, _ => false
  end.

Lemma bl_eqb_eq : forall a b, bl_eqb a b = true -> a = b.
Proof.
  induction a as [| x a IH]; intros [| y b] H; cbn in H; try discriminate; [ reflexivity | ].
  apply andb_prop in H as [H1 H2]. apply Bool.eqb_prop in H1. rewrite H1, (IH _ H2). reflexivity.
Qed.

(* THE CHECK: from a live script, every step keeps the class *)
Definition fam_chk (tab : list vst) (sp l12 lv pbc : list ident) : bool :=
  forallb (fun st => negb (memi (v_s st) lv)
                     || match succs st with
                        | Some l => forallb (fun x => bl_eqb (clsw sp l12 lv pbc (v_s x))
                                                             (clsw sp l12 lv pbc (v_s st))) l
                        | None => true
                        end) tab.

Lemma fam_chk_ok : fam_chk vm_tab OW.sp_scripts ObjCensus.live12 OW.live_bhvs OW.pbc_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* generic in the lists, so no conversion meets a computed one *)
Lemma fam_chk_step : forall tab sp l12 lv pbc, fam_chk tab sp l12 lv pbc = true ->
  forall st l st', In st tab -> In (v_s st) lv -> succs st = Some l -> In st' l ->
  clsw sp l12 lv pbc (v_s st') = clsw sp l12 lv pbc (v_s st).
Proof.
  intros tab sp l12 lv pbc F st l st' Hst Hl Hs Hin. unfold fam_chk in F.
  rewrite forallb_forall in F. specialize (F st Hst). cbv beta in F.
  assert (Hm : memi (v_s st) lv = true) by (apply memi_in; exact Hl).
  rewrite Hm, Hs in F. cbn [negb orb] in F. rewrite forallb_forall in F.
  exact (bl_eqb_eq _ _ (F st' Hin)).
Qed.

Theorem fam_step : forall st l st', In st vm_tab -> In (v_s st) OW.live_bhvs ->
  succs st = Some l -> In st' l -> cls (v_s st') = cls (v_s st).
Proof.
  intros st l st' Hst Hl Hs Hin. unfold cls.
  exact (fam_chk_step _ _ _ _ _ fam_chk_ok st l st' Hst Hl Hs Hin).
Qed.


(* The facts a class shares, proved GENERIC in the lists: a kernel check of
   a lemma stated on cls itself unfolds the computed lists (cls_live's Qed
   hung), so every lemma below is proved over variables and instantiated. *)
Section Generic.
Variables sp l12 lv pbc : list ident.

Lemma g_bit : forall s s' n, clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' ->
  nth n (clsw sp l12 lv pbc s) false = nth n (clsw sp l12 lv pbc s') false.
Proof. intros s s' n E. rewrite E. reflexivity. Qed.

Lemma g_mem : forall s s' n l, nth n (clsw sp l12 lv pbc s) false = memi s l ->
  nth n (clsw sp l12 lv pbc s') false = memi s' l ->
  clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (In s l <-> In s' l).
Proof.
  intros s s' n l H1 H2 E. rewrite <- !memi_in, <- H1, <- H2, (g_bit s s' n E). reflexivity.
Qed.

Lemma g_sp : forall s s', clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (In s sp <-> In s' sp).
Proof. intros s s'. apply (g_mem s s' 0 sp); reflexivity. Qed.

Lemma g_l12 : forall s s', clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (In s l12 <-> In s' l12).
Proof. intros s s'. apply (g_mem s s' 1 l12); reflexivity. Qed.

Lemma g_lv : forall s s', clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (In s lv <-> In s' lv).
Proof. intros s s'. apply (g_mem s s' 2 lv); reflexivity. Qed.

Lemma g_pbc : forall s s', clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (In s pbc <-> In s' pbc).
Proof. intros s s'. apply (g_mem s s' 3 pbc); reflexivity. Qed.

Lemma g_eqb : forall s s' n x, nth n (clsw sp l12 lv pbc s) false = Pos.eqb s x ->
  nth n (clsw sp l12 lv pbc s') false = Pos.eqb s' x ->
  clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (s = x <-> s' = x).
Proof.
  intros s s' n x H1 H2 E. pose proof (g_bit s s' n E) as B. rewrite H1, H2 in B.
  split; intros Ex; subst; rewrite Pos.eqb_refl in B; apply Pos.eqb_eq; [ exact (eq_sym B) | exact B ].
Qed.

Lemma g_id : forall s s' x, In x [OW.BOXS; OW.LIDS; OW.COINF] ->
  clsw sp l12 lv pbc s = clsw sp l12 lv pbc s' -> (s = x <-> s' = x).
Proof.
  intros s s' x Hx. destruct Hx as [<- | [<- | [<- | []]]];
    [ apply (g_eqb s s' 4) | apply (g_eqb s s' 5) | apply (g_eqb s s' 6) ]; reflexivity.
Qed.
End Generic.

Notation CL s := (clsw OW.sp_scripts ObjCensus.live12 OW.live_bhvs OW.pbc_ids s).

(* THE FAMILY of a start script s0: the states whose script has s0's class
   and is live (stated on clsw with the lists spelled out, so the kernel
   only ever compares them syntactically) *)
Definition Qfam (s0 : ident) (st : vst) : Prop := CL (v_s st) = CL s0 /\ In (v_s st) OW.live_bhvs.

Theorem Qfam_closed : forall s0 st l st', In st vm_tab -> Qfam s0 st -> succs st = Some l -> In st' l ->
  Qfam s0 st'.
Proof.
  intros s0 st l st' Hst (Ec & Hl) Hs Hin.
  pose proof (fam_chk_step _ _ _ _ _ fam_chk_ok st l st' Hst Hl Hs Hin) as E.
  split; [ rewrite E; exact Ec
         | exact (proj2 (g_lv OW.sp_scripts ObjCensus.live12 OW.live_bhvs OW.pbc_ids _ _ E) Hl) ].
Qed.

(* what a family member shares with its start script *)
Lemma Qfam_sp : forall s0 st, Qfam s0 st -> (In (v_s st) OW.sp_scripts <-> In s0 OW.sp_scripts).
Proof. intros s0 st (E & _). exact (g_sp _ _ _ _ _ _ E). Qed.

Lemma Qfam_live12 : forall s0 st, Qfam s0 st -> (In (v_s st) ObjCensus.live12 <-> In s0 ObjCensus.live12).
Proof. intros s0 st (E & _). exact (g_l12 _ _ _ _ _ _ E). Qed.

Lemma Qfam_pbc : forall s0 st, Qfam s0 st -> (In (v_s st) OW.pbc_ids <-> In s0 OW.pbc_ids).
Proof. intros s0 st (E & _). exact (g_pbc _ _ _ _ _ _ E). Qed.

Lemma Qfam_id : forall s0 st x, In x [OW.BOXS; OW.LIDS; OW.COINF] -> Qfam s0 st ->
  (v_s st = x <-> s0 = x).
Proof. intros s0 st x Hx (E & _). exact (g_id _ _ _ _ _ _ _ Hx E). Qed.

Lemma Qfam_start : forall s0 st, v_s st = s0 -> In s0 OW.live_bhvs -> Qfam s0 st.
Proof. intros s0 st <- H. split; [ reflexivity | exact H ]. Qed.
