(* ======================================================================= *)
(* ObjInv.v -- the loop invariant INV_k of one object's cur_obj_update     *)
(* (GOAL 2 objects, W2, 2026-11-07).                                       *)
(*                                                                         *)
(* BhvStep.cou_real runs the REAL cur_obj_update of slot k under a         *)
(* section invariant INV kept by the frame Pfr (everything but the VM      *)
(* cursor gCurBhvCommand and slot k's VM cells [O_CMD, O_STK + 34)).       *)
(* Between frames the run carries Pobjl (HeightFrame), whose obj_w reads   *)
(* slot k's VM cells (ow_vm, script_ok, sp_vm, ...), so Pobjl itself is    *)
(* not kept while the dispatch loop moves them.  INV_k is Pobjl "up to    *)
(* the VM cells", by a GHOST memory g:                                     *)
(*   Ple nb0 (nextblock m) /\ cur m /\                                     *)
(*   exists g, Pobjl g /\ Vo g st0 /\ Ple (nextblock g) nb0                *)
(*             /\ Mem.unchanged_on Pfr g m                                 *)
(*             /\ nvB (scr_b \/ SafeB) g m                                 *)
(* -- m agrees with a Pobjl memory g whose slot cells hold the update's    *)
(* start state st0, except at the VM cells; and every byte m changes      *)
(* holds no pointer except into a script or a SafeB block (the VALUE side: *)
(* with g's MWF R7 it gives R7 at exit).  g is the frame-start memory     *)
(* itself (inv_entry), so its R7 is the one the start theorem proves from *)
(* boot -- never a fresh hypothesis.  nb0 is the entry's                   *)
(* nextblock (blocks born later -- the local filler[4] -- are not g's).    *)
(* The script tie Qs is ObjFamily.Qfam (v_s st0): every state the loop    *)
(* reaches runs a script of st0's class.                                   *)
(*                                                                         *)
(* PROVED here: BhvStep's frame hypotheses for INV_k -- Hinv (scr_ok /    *)
(* cmdtab_ok), Hinv_cur, Hinv_frame, inv_free -- and the entry (a Pobjl    *)
(* memory whose slot holds st0 is INV_k).                                  *)
(*                                                                         *)
(* STAGED in Unwired/: promoted when the objects step row (cou_real at    *)
(* INV := INVk, Qs := Qk) requires it, after the exit swap and the row /  *)
(* sfr keeps for INV_k are proved.                                         *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Proofs Require Import RealFrameLinked LinkedTwelve MWFReal.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Generated Require behavior_script.
From SM64.Proofs.WMotRRequiresA Require BhvStep HeightFrame ObjWorld ObjFamily ObjSelf.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.

Section Inv.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variables (bm bc0 : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Notation MWF := (MWF_real lp bm bc0 oc0 SafeB).
  Notation Pobjl := (HeightFrame.Pobj lp bm MWF (HeightFrame.PhiW lp bm) (OW.obj_w G bm)).

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
  Definition PV (b : block) : Prop := BhvStep.scr_b lp b \/ SafeB b.
  Notation cur := (BhvStep.cur go pool oc).
  Notation Vo := (BhvStep.Vo lp pool oc).

  (* the update's start state and the entry's nextblock *)
  Variable st0 : vst.
  Variable nb0 : block.

  Definition INVk (m : mem) : Prop :=
    Ple nb0 (Mem.nextblock m) /\ cur m
    /\ exists g, Pobjl g /\ Vo g st0 /\ Ple (Mem.nextblock g) nb0 /\ Mem.unchanged_on Pfr g m
                 /\ BhvStep.nvB PV g m.

  Definition Qk : vst -> Prop := ObjFamily.Qfam (v_s st0).

  Lemma Qk_closed : forall st l st', In st vm_tab -> Qk st -> succs st = Some l -> In st' l -> Qk st'.
  Proof. exact (ObjFamily.Qfam_closed (v_s st0)). Qed.

  (* a symbol's block is valid in a Pobjl memory (MWF's nextblock bound) *)
  Lemma sym_valid : forall g id b, Pobjl g -> Genv.find_symbol G id = Some b -> Mem.valid_block g b.
  Proof.
    intros g id b (Hok & _) Hs. pose proof Hok as (_ & _ & HM).
    pose proof HM as ((_ & _ & _ & _ & _ & _ & _ & Hgn) & _).
    pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Mem.valid_block, Plt, Ple in *. lia.
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
  Theorem inv_frame : forall m m', INVk m -> PfrN m m' -> INVk m'.
  Proof.
    intros m m' (Hn & Hc & g & Hg & HV & Hgn & U & NV) (U' & NV').
    pose proof (Mem.unchanged_on_nextblock _ _ _ U') as N.
    split; [ exact (Ple_trans _ _ _ Hn N) | split; [ exact (cur_unch m m' U' (cur_valid m Hc) Hc) | ] ].
    exists g. split; [ exact Hg | split; [ exact HV | split; [ exact Hgn | split ] ] ].
    - exact (Mem.unchanged_on_trans _ _ _ _ U U').
    - apply (BhvStep.nvB_trans _ _ _ _ NV); [ | exact (Mem.unchanged_on_nextblock _ _ _ U) ].
      apply (BhvStep.nvB_mono (BhvStep.scr_b lp) PV); [ intros b Hb; left; exact Hb | exact NV' ].
  Qed.

  (* ---- Hinv_cur ---- *)
  Theorem inv_cur : forall m, INVk m -> cur m.
  Proof. intros m (_ & Hc & _). exact Hc. Qed.

  (* ---- Hinv: the script blocks and BehaviorCmdTable are Pfr blocks ---- *)
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

  Theorem inv_scr : forall m, INVk m -> OW.scr_ok G m /\ OW.cmdtab_ok G m.
  Proof.
    intros m (_ & _ & g & Hg & _ & _ & U & _).
    pose proof Hg as (_ & _ & _ & _ & _ & How).
    destruct How as (pool' & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    split.
    - apply (OW.scr_ok_ext G g m); [ | exact (OW.ow_scr _ _ _ _ _ _ _ _ _ _ _ _ C) ].
      intros s b Hin Hs ch z.
      apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U (sym_valid g s b Hg Hs)).
      intros i _. split; [ exact (not_bcc s b Hs (scripts_not_bcc s Hin)) | ].
      intros (E & _). exact (scr_not_pool s b Hin Hs E).
    - destruct (OW.ow_cmdtab _ _ _ _ _ _ _ _ _ _ _ _ C) as (b & Hs & L). exists b. split; [ exact Hs | ].
      intros j id Hj. destruct (L j id Hj) as (hb & Hhb & Lj). exists hb. split; [ exact Hhb | ].
      rewrite (Mem.load_unchanged_on_1 _ _ _ _ _ _ U (sym_valid g _ b Hg Hs)); [ exact Lj | ].
      intros i _. split; [ apply (not_bcc _ b Hs); vm_compute; discriminate | ].
      intros (E & _). subst b.
      assert (Ep : behavior_script._BehaviorCmdTable = ObjSelf.POOL) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hpool ]).
      vm_compute in Ep. discriminate Ep.
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
    intros m0 m b m' (Hn0 & _) Hnv (Hn & Hc & g & Hg & HV & Hgn & U & NV) F.
    pose proof (Mem.nextblock_free _ _ _ _ _ F) as N.
    split; [ rewrite N; exact Hn | split ].
    - unfold BhvStep.cur in *. rewrite (Mem.load_free _ _ _ _ _ F); [ exact Hc | ].
      left. intros E. subst b. apply Hnv.
      (* go is a symbol block: valid in the ghost, so below nb0 <= nextblock m0 *)
      pose proof (sym_valid g _ _ Hg Hgo) as Vg. unfold Mem.valid_block in *.
      exact (Plt_Ple_trans _ _ _ (Plt_Ple_trans _ _ _ Vg Hgn) Hn0).
    - exists g. split; [ exact Hg | split; [ exact HV | split; [ exact Hgn | split ] ] ].
      2: { apply (BhvStep.nvB_trans _ _ _ _ NV (BhvStep.nvB_free _ _ _ _ _ _ F)).
           exact (Mem.unchanged_on_nextblock _ _ _ U). }
      apply unch_valid. apply (Mem.unchanged_on_trans _ _ m).
      + exact (Mem.unchanged_on_implies _ _ _ _ U (fun b0 z0 H _ => proj1 H)).
      + apply (Mem.free_unchanged_on _ _ _ _ _ _ F). intros i _ (_ & Vb). apply Hnv. unfold Mem.valid_block in *.
        exact (Plt_Ple_trans _ _ _ (Plt_Ple_trans _ _ _ Vb Hgn) Hn0).
  Qed.

  (* ---- the entry ---- *)
  Theorem inv_entry : forall m, Mem.nextblock m = nb0 -> Pobjl m -> Vo m st0 -> cur m -> INVk m.
  Proof.
    intros m En Hp HV Hc. split; [ rewrite En; apply Ple_refl | split; [ exact Hc | ] ].
    exists m. split; [ exact Hp | split; [ exact HV | split; [ rewrite En; apply Ple_refl | split; [ apply Mem.unchanged_on_refl | apply BhvStep.nvB_refl ] ] ] ].
  Qed.
End Inv.
