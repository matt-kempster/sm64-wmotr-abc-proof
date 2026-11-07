(* ====================================================================== *)
(* UnloadSharp (GOAL 2 objects, 2026-11-03): unload_object's footprint,   *)
(* byte-exact on the freed slot.                                          *)
(*                                                                        *)
(* UnloadObj.unload_real lets slot k change at every byte outside its     *)
(* link words (ObjCreate.KP).  The real body writes only activeFlags      *)
(* (116), prevObj (108), header.gfx.throwMatrix and, twice,               *)
(* header.gfx.node.flags (2); the graph and list links are the callees'   *)
(* (ObjAlloc / ObjUnload).  Here: fxw, the byte ranges a statement the   *)
(* slot-store walker ObjCreate.fx accepts writes, read off the generated  *)
(* body, and unload_sharp, unload_real with slot k unchanged outside     *)
(* those ranges.  What the unload phase's invariant needs: the freed slot *)
(* keeps its rawData, its parent word and its VM cells (a collided or     *)
(* used object of Mario's, a surface's object, obj_w's slot clauses).     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area audio_external.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate ObjUnload UnloadObj.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop AudioWire AudioInv CapAudio BodyFrame LsContract.

Import ListNotations.
Local Open Scope Z_scope.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.
Module GN := SM64.Generated.graph_node.

(* the byte ranges (offset, length) an fx-walked statement stores into *)
Section FXW.
  Variable ce : composite_env.
  Variable x : ident.
  Fixpoint fxw (s : statement) : list (Z * Z) :=
    match s with
    | Sassign l _ =>
        match ObjSelf.lad ce [x] l, access_mode (typeof l) with
        | Some d, By_value ch => [(d, size_chunk ch)]
        | _, _ => []
        end
    | Ssequence a b => fxw a ++ fxw b
    | Sifthenelse _ a b => fxw a ++ fxw b
    | _ => []
    end.
End FXW.

Fixpoint fxlw (ce : composite_env) (x : ident) (n : nat) (s : statement) : list (Z * Z) :=
  match n, s with
  | O, _ => []
  | S n', Ssequence a b => fxw ce x a ++ fxlw ce x n' b
  | S _, _ => []
  end.

(* the bytes kept: off the pool block, or outside every written range of
   the slot at b0 *)
Definition SKP (pool : block) (b0 : Z) (W : list (Z * Z)) (b : block) (z : Z) : Prop :=
  b <> pool \/ forall d n, In (d, n) W -> z < b0 + d \/ b0 + d + n <= z.

Lemma SKP_app_l : forall pool b0 W1 W2 b z, SKP pool b0 (W1 ++ W2) b z -> SKP pool b0 W1 b z.
Proof.
  intros pool b0 W1 W2 b z [H | H]; [ left; exact H | right ].
  intros d n Hi. apply H. apply in_or_app. left. exact Hi.
Qed.
Lemma SKP_app_r : forall pool b0 W1 W2 b z, SKP pool b0 (W1 ++ W2) b z -> SKP pool b0 W2 b z.
Proof.
  intros pool b0 W1 W2 b z [H | H]; [ left; exact H | right ].
  intros d n Hi. apply H. apply in_or_app. right. exact Hi.
Qed.
Lemma SKP_nil : forall pool b0 b z, SKP pool b0 [] b z.
Proof. intros pool b0 b z. right. intros d n []. Qed.

Section SHARP.
  Variable ge : genv.
  Variables pool gB : block.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Variable ce : composite_env.
  Hypothesis Hce : ObjSelf.cext ge ce.
  Variable x : ident.
  Variable k : Z.
  Hypothesis Hk : 0 <= k < NSLOT.
  Notation b0 := (k * OSZ).
  Notation ov := (slot_v pool k).
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  Lemma fx_sharp : forall s F F', fx ce x s F = Some F' ->
    forall le m t le' m' out, xs le m s t le' m' out ->
    le ! x = Some ov -> facts m pool b0 ov F ->
    Mem.unchanged_on (SKP pool b0 (fxw ce x s)) m m'.
  Proof.
    induction s; intros F F' Hf le m t0 le' m' out H Hx HF; cbn [fx] in Hf; try discriminate Hf.
    - apply RA.skip_inv in H as (-> & -> & ->). apply Mem.unchanged_on_refl.
    - cbn [fxw].
      destruct (ObjSelf.lad ce [x] e) as [d|] eqn:Ed; [ | discriminate Hf ].
      destruct (access_mode (typeof e)) as [ch| | | ] eqn:Ea; try discriminate Hf.
      destruct (wr_ok d (size_chunk ch)) eqn:Ew; [ | discriminate Hf ].
      apply RA.assign_inv in H as (b & o & bf & v2 & v & Hl & He & Hc & Has & -> & ->).
      destruct (lad_at ge pool gB Hpool HgB ce Hce x k le m e b o bf d Hx Hl Ed) as (-> & -> & ->).
      pose proof (RA.store_by_value ge (typeof e) m pool _ Full v m' ch Ea eq_refl Has) as Hs.
      destruct (wr_ok_range _ _ Ew) as (Hd0 & Hd1 & Hn).
      pose proof (size_chunk_pos ch) as Hsz.
      rewrite (slot_fld k d Hk) in Hs by lia.
      apply (Mem.store_unchanged_on _ ch m pool (b0 + d) v m' Hs).
      intros i Hi [N | N]; [ exact (N eq_refl) | ].
      destruct (N d (size_chunk ch) (or_introl eq_refl)); lia.
    - destruct (Pos.eqb i x); [ discriminate Hf | ].
      apply RA.set_inv in H as (v & _ & -> & -> & ->). apply Mem.unchanged_on_refl.
    - cbn [fxw].
      destruct (fx ce x s1 F) as [F1|] eqn:E1; [ | discriminate Hf ].
      apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
      + pose proof (IHs1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as U1.
        destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk s1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (_ & Hx1 & HF1 & _).
        pose proof (IHs2 F1 F' Hf _ _ _ _ _ _ H2 Hx1 HF1) as U2.
        apply (Mem.unchanged_on_trans _ _ m1).
        * apply (Mem.unchanged_on_implies _ _ _ _ U1). intros b z Hb _. exact (SKP_app_l _ _ _ _ _ _ Hb).
        * apply (Mem.unchanged_on_implies _ _ _ _ U2). intros b z Hb _. exact (SKP_app_r _ _ _ _ _ _ Hb).
      + destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk s1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (Ho & _).
        contradiction.
    - cbn [fxw].
      destruct (fx ce x s1 F) as [Fa|] eqn:Ea; [ | discriminate Hf ].
      destruct (fx ce x s2 F) as [Fb|] eqn:Eb; [ | discriminate Hf ].
      apply RA.if_inv in H as (v & bb & _ & _ & H).
      destruct bb.
      + apply (Mem.unchanged_on_implies _ _ _ _ (IHs1 F Fa Ea _ _ _ _ _ _ H Hx HF)).
        intros b z Hb _. exact (SKP_app_l _ _ _ _ _ _ Hb).
      + apply (Mem.unchanged_on_implies _ _ _ _ (IHs2 F Fb Eb _ _ _ _ _ _ H Hx HF)).
        intros b z Hb _. exact (SKP_app_r _ _ _ _ _ _ Hb).
  Qed.

  Lemma fxl_sharp : forall n s F F' s', fxl ce x n s F = Some (F', s') ->
    forall le m t le' m' out, xs le m s t le' m' out ->
    le ! x = Some ov -> facts m pool b0 ov F ->
    exists le1 m1 t2, xs le1 m1 s' t2 le' m' out /\ le1 ! x = Some ov /\ facts m1 pool b0 ov F'
      /\ Mem.unchanged_on (SKP pool b0 (fxlw ce x n s)) m m1.
  Proof.
    induction n; intros s F F' s' Hf le m t le' m' out H Hx HF; cbn [fxl] in Hf.
    - injection Hf as <- <-. exists le, m, t.
      split; [ exact H | split; [ exact Hx | split; [ exact HF | apply Mem.unchanged_on_refl ] ] ].
    - destruct s; try discriminate Hf. cbn [fxlw].
      destruct (fx ce x s1 F) as [F1|] eqn:E1; [ | discriminate Hf ].
      apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
      + pose proof (fx_sharp s1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as U1.
        destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk s1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (_ & Hx1 & HF1 & _).
        destruct (IHn s2 F1 F' s' Hf _ _ _ _ _ _ H2 Hx1 HF1) as (le2 & m2 & t3 & H3 & Hx2 & HF2 & U2).
        exists le2, m2, t3. split; [ exact H3 | split; [ exact Hx2 | split; [ exact HF2 | ] ] ].
        apply (Mem.unchanged_on_trans _ _ m1).
        * apply (Mem.unchanged_on_implies _ _ _ _ U1). intros b z Hb _. exact (SKP_app_l _ _ _ _ _ _ Hb).
        * apply (Mem.unchanged_on_implies _ _ _ _ U2). intros b z Hb _. exact (SKP_app_r _ _ _ _ _ _ Hb).
      + destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk s1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (Ho & _).
        contradiction.
  Qed.
End SHARP.

(* unload_object's two walked prefixes, and what they write *)
Definition uo_s6 : statement :=
  match sdrop 3 (fn_body SO.f_unload_object) with
  | Ssequence _ (Ssequence _ (Ssequence _ s6)) => s6
  | _ => Sskip
  end.
Definition UW : list (Z * Z) :=
  fxlw CE SO._obj 3 (fn_body SO.f_unload_object) ++ fxlw CE SO._obj 2 uo_s6.

(* the written ranges stay off every slot's graph and list link words *)
Definition wokb (dn : Z * Z) : bool :=
  let '(d, n) := dn in
  (0 <=? d) && (d + n <=? OSZ) && ((d + n <=? 4) || (16 <=? d)) && ((d + n <=? 96) || (104 <=? d)).

Lemma skp_link : forall pool k W z, 0 <= k < NSLOT -> forallb wokb W = true ->
  (exists j, 0 <= j < NSLOT /\ ((j * OSZ + 4 <= z < j * OSZ + 16) \/ (j * OSZ + 96 <= z < j * OSZ + 104))) ->
  forall b, SKP pool (k * OSZ) W b z.
Proof.
  intros pool k W z Hk HW (j & Hj & Hz) b. right. intros d n Hin.
  pose proof (proj1 (forallb_forall _ _) HW _ Hin) as E. unfold wokb in E.
  apply andb_true_iff in E as [E E4]. apply andb_true_iff in E as [E E3]. apply andb_true_iff in E as [E1 E2].
  apply Z.leb_le in E1. apply Z.leb_le in E2.
  unfold OSZ, NSLOT in *.
  apply orb_true_iff in E3 as [E3 | E3]; apply Z.leb_le in E3;
    apply orb_true_iff in E4 as [E4 | E4]; apply Z.leb_le in E4;
    (destruct (Z.lt_trichotomy j k) as [Hlt | [-> | Hgt]]; lia).
Qed.

Definition W1L : list (Z * Z) := [(116, 2); (108, 4); (80, 4)].
Definition W2L : list (Z * Z) := [(2, 2); (2, 2)].
(* the freed slot's writes: activeFlags, prevObj, throwMatrix, the node
   flags twice *)
Definition UWL : list (Z * Z) := W1L ++ W2L.

Lemma UW_eq : UW = UWL.
Proof. vm_compute. reflexivity. Qed.
Lemma W1_eq : fxlw (prog_comp_env SO.prog) SO._obj 3 (fn_body SO.f_unload_object) = W1L.
Proof. vm_compute. reflexivity. Qed.
Lemma wok1 : forallb wokb W1L = true.
Proof. vm_compute. reflexivity. Qed.
Lemma wok2 : forallb wokb W2L = true.
Proof. vm_compute. reflexivity. Qed.
Lemma wokU : forallb wokb UWL = true.
Proof. vm_compute. reflexivity. Qed.

Section USH.
  Variable ge : genv.
  Hypothesis Hce : forall id co, (prog_comp_env GN.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Hypothesis Hcs : forall id co, (prog_comp_env SO.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Variables pool la fl bpg gB : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hpf : pool <> fl.
  Hypothesis Hlf : la <> fl.
  Hypothesis Hpb : pool <> bpg.
  Hypothesis Hlb : la <> bpg.
  Hypothesis Hfb : fl <> bpg.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Hypothesis Hbpg : Genv.find_symbol ge SO._gObjParentGraphNode = Some bpg.
  Hypothesis Hfls : Genv.find_symbol ge SO._gFreeObjectList = Some fl.
  Hypothesis Hgrc : forall b fd, Genv.find_symbol ge SO._geo_remove_child = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal GN.f_geo_remove_child.
  Hypothesis Hgac : forall b fd, Genv.find_symbol ge SO._geo_add_child = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal GN.f_geo_add_child.
  Hypothesis Hdao : forall b fd, Genv.find_symbol ge SO._deallocate_object = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SO.f_deallocate_object.
  Variable SS : mem -> Prop.
  Variable SSK : block -> Z -> Prop.
  Hypothesis Hss : forall b fd, Genv.find_symbol ge SO._stop_sounds_from_source = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
    forall m vargs t m' vr, eval_funcall function_entry2 ge m fd vargs t m' vr -> SS m ->
      Mem.unchanged_on SSK m m' /\ SS m'.
  Hypothesis HSp : forall z, SSK pool z.
  Hypothesis HSl : forall z, SSK la z.
  Hypothesis HSf : forall z, SSK fl z.
  Hypothesis HSb : forall z, SSK bpg z.
  Hypothesis HSS : forall m m', SS m ->
    Mem.unchanged_on (fun b _ => b <> pool /\ b <> la /\ b <> fl /\ b <> bpg) m m' -> SS m'.
  Notation CE := (prog_comp_env SO.prog).

  (* the sharp keep of the whole call *)
  Definition USK (k : Z) (b : block) (z : Z) : Prop :=
    SKP pool (k * OSZ) UWL b z /\ Gkeep pool bpg b z /\ ~ RCELL pool la fl b z /\ SSK b z.

  Lemma gc_skp : forall k W b z, 0 <= k < NSLOT -> forallb wokb W = true ->
    GCELL pool bpg b z -> SKP pool (k * OSZ) W b z.
  Proof.
    intros k W b z Hk HW [(-> & j & Hj & Hz) | (-> & _)].
    - apply (skp_link pool k W z Hk HW). exists j. split; [ exact Hj | left ]. unfold G_PREV, G_CHILD in Hz. lia.
    - left. exact (not_eq_sym Hpb).
  Qed.

  Theorem unload_sharp : forall m rs fs i l1 k l2 t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    (i < NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 -> gfx_at pool bpg m -> SS m ->
    eval_funcall function_entry2 ge m (Internal SO.f_unload_object) [slot_v pool k] t m' vr ->
    rings m' pool la = Some (upd rs i (l1 ++ l2)) /\ free_list m' pool fl = Some (k :: fs)
    /\ gfx_at pool bpg m' /\ SS m'
    /\ Mem.load Mint16signed m' pool (k * OSZ + O_FLAGS) = Some (Vint Int.zero)
    /\ Mem.unchanged_on (USK k) m m'.
  Proof using Hce Hcs Hpl Hpf Hlf Hpb Hlb Hfb Hpool HgB Hbpg Hfls Hgrc Hgac Hdao Hss HSp HSl HSf HSb HSS.
    intros m rs fs i l1 k l2 t m' vr Hr Hf Hnd Hi El Hg HS0 H.
    assert (Hk : 0 <= k < NSLOT).
    { pose proof Hr as Hr0. apply (rings_iff pool m la rs Hpl) in Hr0 as (_ & Henc).
      destruct (Henc i Hi) as (_ & Hc0 & _ & _). rewrite El in Hc0.
      apply chain_split in Hc0 as (_ & Hc2). cbn [chain] in Hc2. exact (proj1 Hc2). }
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & _); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params SO.f_unload_object] in Hb. injection Hb as <-.
    set (le0 := PTree.set SO._obj (slot_v pool k) _) in Hx.
    assert (Hx0 : le0 ! SO._obj = Some (slot_v pool k)) by (unfold le0; apply PTree.gss).
    assert (Hce' : ObjSelf.cext ge CE) by exact Hcs.
    (* activeFlags, prevObj, throwMatrix *)
    destruct (fxl_sharp ge pool gB Hpool HgB CE Hce' SO._obj k Hk 3 _ [] _ _
                (fxl_ok CE SO._obj 3 (fn_body SO.f_unload_object) [] ltac:(vm_compute; discriminate))
                _ _ _ _ _ _ Hx Hx0 (facts_nil _ _ _ _))
      as (le1 & m1 & t1 & H1 & Hx1 & HF1 & U1).
    rewrite W1_eq in U1.
    assert (IF1 : In AF0 (ffacts CE SO._obj 3 (fn_body SO.f_unload_object) [])) by (vm_compute; tauto).
    pose proof (HF1 _ _ _ IF1) as A1. cbn [ival] in A1.
    cbn [sdrop fn_body SO.f_unload_object] in H1.
    (* stop_sounds_from_source(...) *)
    apply RA.seq_inv in H1 as [(c1 & lc1 & mc1 & c2 & C1 & C2) | (C1 & Xn)]; [ | kill_sq0 C1 Xn ].
    apply RA.call_inv in C1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bs & Hs & ->) end.
    assert (SS1 : SS m1).
    { apply (HSS m m1 HS0). apply (Mem.unchanged_on_implies _ _ _ _ U1). intros b z (N & _) _. left. exact N. }
    destruct (Hss bs fd Hs Hff _ _ _ _ _ Hc SS1) as (U2 & SS2).
    (* geo_remove_child(&obj->header.gfx.node) *)
    apply RA.seq_inv in C2 as [(c3 & lc3 & mc3 & c4 & C3 & C4) | (C3 & Xn)]; [ | kill_sq0 C3 Xn ].
    apply RA.call_inv in C3 as (tya2 & tyr2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hc2 & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf2 & Hs2 & ->) end.
    rewrite (Hgrc bf2 fd2 Hs2 Hff2) in Hc2.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal2) as (ty1 & v1 & w1 & Ea1 & -> & Ev1 & Cc1). injection Ea1 as <-.
    rewrite (UnloadObj.ev_onode ge Hcs _ _ _ _ _ _ Ev1 Hx1) in Cc1.
    cbn [typeof] in Cc1. apply RA.cast_ptr_id in Cc1. subst w1.
    assert (G1 : gfx_at pool bpg mc1).
    { apply (gfx_keep pool bpg (fun b z => SKP pool (k * OSZ) W1L b z /\ SSK b z) m mc1).
      - apply (Mem.unchanged_on_trans _ _ m1).
        + apply (Mem.unchanged_on_implies _ _ _ _ U1). intros b z (H0 & _) _. exact H0.
        + apply (Mem.unchanged_on_implies _ _ _ _ U2). intros b z (_ & H0) _. exact H0.
      - intros b z Hgc. split; [ exact (gc_skp k W1L b z Hk wok1 Hgc) | ].
        destruct Hgc as [(-> & _) | (-> & _)]; [ apply HSp | apply HSb ].
      - exact Hg. }
    destruct (grc_ok ge Hce pool bpg Hpb _ k _ _ _ G1 Hk Hc2) as (G2 & U3).
    (* geo_add_child(&gObjParentGraphNode, &obj->header.gfx.node) *)
    apply RA.seq_inv in C4 as [(c5 & lc5 & mc5 & c6 & C5 & C6) | (C5 & Xn)]; [ | kill_sq0 C5 Xn ].
    apply RA.call_inv in C5 as (tya3 & tyr3 & cc3 & vf3 & vargs3 & fd3 & vres3 & Hcf3 & Evf3 & Eal3 & Hff3 & _ & Hc3 & -> & _).
    cbn in Hcf3. injection Hcf3 as <- <- <-.
    match type of Evf3 with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf3 (PTree.gempty _ _) eq_refl Evf3) as (bf3 & Hs3 & ->) end.
    rewrite (Hgac bf3 fd3 Hs3 Hff3) in Hc3.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal3) as (ta & tb & u1 & u2 & x1 & x2 & Ea2 & -> & Eva & Cca & Evb & Ccb).
    injection Ea2 as <- <-.
    rewrite (UnloadObj.ev_gaddr ge _ _ _ _ _ _ Hbpg Eva) in Cca. cbn [typeof] in Cca. apply RA.cast_ptr_id in Cca. subst x1.
    rewrite (UnloadObj.ev_onode ge Hcs _ _ _ _ _ _ Evb Hx1) in Ccb. cbn [typeof] in Ccb. apply RA.cast_ptr_id in Ccb. subst x2.
    destruct (gac_ok ge Hce pool bpg Hpb _ k _ _ _ G2 Hk Hc3) as (G3 & U4).
    (* the two flag stores *)
    assert (HFa : facts mc5 pool (k * OSZ) (slot_v pool k) [AF0]).
    { intros ch d s [E | []]. injection E as <- <- <-. cbn [ival].
      apply (Mem.load_unchanged_on (Gkeep pool bpg) mc3 mc5); [ exact U4 | | ].
      { intros z Hz [(_ & j & _ & Hj) | (E & _)]; [ unfold O_FLAGS, G_PREV, G_CHILD, OSZ, NSLOT in *; cbn [size_chunk] in Hz; nia | exact (Hpb E) ]. }
      apply (Mem.load_unchanged_on (Gkeep pool bpg) mc1 mc3); [ exact U3 | | ].
      { intros z Hz [(_ & j & _ & Hj) | (E & _)]; [ unfold O_FLAGS, G_PREV, G_CHILD, OSZ, NSLOT in *; cbn [size_chunk] in Hz; nia | exact (Hpb E) ]. }
      apply (Mem.load_unchanged_on SSK m1 mc1); [ exact U2 | intros z _; apply HSp | exact A1 ]. }
    match type of C6 with exec_stmt _ _ _ _ _ ?s6 _ _ _ _ =>
      destruct (fxl_sharp ge pool gB Hpool HgB CE Hce' SO._obj k Hk 2 s6 [AF0] _ _
                  (fxl_ok CE SO._obj 2 s6 [AF0] ltac:(vm_compute; discriminate))
                  _ _ _ _ _ _ C6 Hx1 HFa)
        as (le7 & m7 & t7 & H7 & Hx7 & HF7 & U7);
      assert (IF7 : In AF0 (ffacts CE SO._obj 2 s6 [AF0])) by (vm_compute; tauto);
      assert (E7 : fxlw CE SO._obj 2 s6 = W2L) by (vm_compute; reflexivity)
    end.
    rewrite E7 in U7.
    pose proof (HF7 _ _ _ IF7) as A7. cbn [ival] in A7.
    cbn [sdrop] in H7.
    (* deallocate_object(&gFreeObjectList, &obj->header) *)
    apply RA.call_inv in H7 as (tya4 & tyr4 & cc4 & vf4 & vargs4 & fd4 & vres4 & Hcf4 & Evf4 & Eal4 & Hff4 & _ & Hc4 & -> & _).
    cbn in Hcf4. injection Hcf4 as <- <- <-.
    match type of Evf4 with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf4 (PTree.gempty _ _) eq_refl Evf4) as (bf4 & Hs4 & ->) end.
    rewrite (Hdao bf4 fd4 Hs4 Hff4) in Hc4.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal4) as (ta4 & tb4 & y1 & y2 & z1 & z2 & Ea4 & -> & Eva4 & Cca4 & Evb4 & Ccb4).
    injection Ea4 as <- <-.
    rewrite (UnloadObj.ev_gaddr ge _ _ _ _ _ _ Hfls Eva4) in Cca4. cbn [typeof] in Cca4. apply RA.cast_ptr_id in Cca4. subst z1.
    rewrite (UnloadObj.ev_hdr ge Hcs _ _ _ _ _ _ Evb4 Hx7) in Ccb4. cbn [typeof] in Ccb4. apply RA.cast_ptr_id in Ccb4. subst z2.
    set (P7 := fun b z => SKP pool (k * OSZ) UWL b z /\ Gkeep pool bpg b z /\ SSK b z).
    assert (U07 : Mem.unchanged_on P7 m m7).
    { apply (Mem.unchanged_on_trans _ _ m1); [ apply (Mem.unchanged_on_implies _ _ _ _ U1); intros b z (H0 & _) _; exact (SKP_app_l _ _ W1L W2L _ _ H0) | ].
      apply (Mem.unchanged_on_trans _ _ mc1); [ apply (Mem.unchanged_on_implies _ _ _ _ U2); intros b z (_ & _ & H0) _; exact H0 | ].
      apply (Mem.unchanged_on_trans _ _ mc3); [ apply (Mem.unchanged_on_implies _ _ _ _ U3); intros b z (_ & H0 & _) _; exact H0 | ].
      apply (Mem.unchanged_on_trans _ _ mc5); [ apply (Mem.unchanged_on_implies _ _ _ _ U4); intros b z (_ & H0 & _) _; exact H0 | ].
      apply (Mem.unchanged_on_implies _ _ _ _ U7). intros b z (H0 & _) _. exact (SKP_app_r _ _ W1L W2L _ _ H0). }
    assert (Prc : forall j i0, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i0 < j * OSZ + O_PREV + 4 -> P7 pool i0).
    { intros j i0 Hj Hi0. split; [ | split; [ | apply HSp ] ].
      - apply (skp_link pool k UWL i0 Hk wokU). exists j. split; [ exact Hj | right ]. unfold O_NEXT, O_PREV in Hi0. lia.
      - intros [(_ & j' & Hj' & Hz) | (E & _)]; [ unfold G_PREV, G_CHILD, O_NEXT, O_PREV, OSZ, NSLOT in *; lia | exact (Hpb E) ]. }
    assert (Pla : forall z, P7 la z).
    { intros z. split; [ left; exact (not_eq_sym Hpl) | split; [ | apply HSl ] ].
      intros [(E & _) | (E & _)]; [ exact (Hpl (eq_sym E)) | exact (Hlb E) ]. }
    assert (Pfl : forall z, P7 fl z).
    { intros z. split; [ left; exact (not_eq_sym Hpf) | split; [ | apply HSf ] ].
      intros [(E & _) | (E & _)]; [ exact (Hpf (eq_sym E)) | exact (Hfb E) ]. }
    assert (R7 : rings m7 pool la = Some rs)
      by exact (rings_keep pool la P7 Prc Pla m m7 rs Hpl U07 Hr).
    assert (F7 : free_list m7 pool fl = Some fs)
      by exact (free_keep pool fl P7 Prc Pfl m m7 fs U07 Hf).
    assert (G7 : gfx_at pool bpg m7).
    { apply (gfx_keep pool bpg (SKP pool (k * OSZ) W2L) mc5 m7 U7); [ intros b z Hgc; exact (gc_skp k W2L b z Hk wok2 Hgc) | exact G3 ]. }
    destruct (dealloc_ok ge Hcs pool la fl Hpl Hpf Hlf m7 rs fs i l1 k l2 t7 m' vres4 R7 F7 Hnd Hi El Hc4)
      as (R8 & F8 & U8).
    assert (SS7 : SS m7).
    { apply (HSS mc1 m7 SS2).
      apply (Mem.unchanged_on_trans _ _ mc3); [ apply (Mem.unchanged_on_implies _ _ _ _ U3) | ].
      { intros b z (N1 & _ & _ & N4) _ [(E & _) | (E & _)]; [ exact (N1 E) | exact (N4 E) ]. }
      apply (Mem.unchanged_on_trans _ _ mc5); [ apply (Mem.unchanged_on_implies _ _ _ _ U4) | ].
      { intros b z (N1 & _ & _ & N4) _ [(E & _) | (E & _)]; [ exact (N1 E) | exact (N4 E) ]. }
      apply (Mem.unchanged_on_implies _ _ _ _ U7). intros b z (N1 & _) _. left. exact N1. }
    split; [ exact R8 | split; [ exact F8 | split; [ | split; [ | split ] ] ] ].
    - apply (gfx_keep pool bpg _ m7 m' U8); [ | exact G7 ].
      intros b z Hgc. eapply gc_nrc; eassumption.
    - apply (HSS m7 m' SS7). apply (Mem.unchanged_on_implies _ _ _ _ U8).
      intros b z (N1 & N2 & N3 & _) _ [(E & _) | [E | E]]; [ exact (N1 E) | exact (N2 E) | exact (N3 E) ].
    - apply (Mem.load_unchanged_on _ m7 m' _ _ _ _ U8); [ | exact A7 ].
      intros z Hz [(_ & j & _ & Hj) | [E | E]];
        [ unfold O_FLAGS, O_NEXT, O_PREV, OSZ, NSLOT in *; cbn [size_chunk] in Hz; nia | exact (Hpl E) | exact (Hpf E) ].
    - apply (Mem.unchanged_on_trans _ _ m7).
      + apply (Mem.unchanged_on_implies _ _ _ _ U07). intros b z (H0 & H2 & _ & H4) _. exact (conj H0 (conj H2 H4)).
      + apply (Mem.unchanged_on_implies _ _ _ _ U8). intros b z (_ & _ & H3 & _) _. exact H3.
  Qed.
End USH.

Section UREALS.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* unload_real, with the freed slot kept outside UWL *)
  Theorem unload_sharp_real : forall pool la fl bpg,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    forall m rs fs i l1 k l2 t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    (i < NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 -> gfx_ok G pool m -> AudioInv.AudioInv G m ->
    Ple (Genv.genv_next G) (Mem.nextblock m) ->
    eval_funcall function_entry2 G m (Internal SO.f_unload_object) [slot_v pool k] t m' vr ->
    rings m' pool la = Some (upd rs i (l1 ++ l2)) /\ free_list m' pool fl = Some (k :: fs)
    /\ gfx_ok G pool m' /\ AudioInv.AudioInv G m'
    /\ Mem.load Mint16signed m' pool (k * OSZ + O_FLAGS) = Some (Vint Int.zero)
    /\ Mem.unchanged_on (USK pool la fl bpg (CapAudio.ak lp ws_u) k) m m'.
  Proof.
    intros pool la fl bpg Hp Hl Hf Hb m rs fs i l1 k l2 t m' vr Hr Hfl Hnd Hi El Hg HA HN H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); RA.neq).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); RA.neq).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); RA.neq).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); RA.neq).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); RA.neq).
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    pose proof (gfx_at_iff pool bpg Hpb G m Hb) as Ig.
    assert (NW : forall id b, Genv.find_symbol G id = Some b -> existsb (Pos.eqb id) ws_u = false ->
              forall z, CapAudio.ak lp ws_u b z).
    { intros id b Hs Hn z. exact (gblk_not G ws_u id b Hs Hn). }
    assert (NL : forall id b, Genv.find_symbol G id = Some b -> existsb (Pos.eqb id) LsContract.ls_ids = false ->
              forall b', LsContract.gblk G LsContract.ls_ids b' -> b' <> b).
    { intros id b Hs Hn b' Hb' ->. exact (gblk_not G _ id b Hs Hn Hb'). }
    set (SSu := fun m0 => AudioInv.AudioInv G m0 /\ Ple (Genv.genv_next G) (Mem.nextblock m0)).
    assert (Hss : forall b fd, Genv.find_symbol G SO._stop_sounds_from_source = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
      forall m0 vargs t0 m1 vr0, eval_funcall function_entry2 G m0 fd vargs t0 m1 vr0 -> SSu m0 ->
        Mem.unchanged_on (CapAudio.ak lp ws_u) m0 m1 /\ SSu m1).
    { intros b fd Hs Hf' m0 vargs t0 m1 vr0 He (A0 & N0).
      rewrite Genv.find_funct_find_funct_ptr in Hf'.
      destruct (uai_ssfs lp H12 b fd Hs Hf' m0 vargs t0 m1 vr0 He A0) as (Q & A1).
      exact (conj (proj1 Q) (conj A1 (Ple_trans _ _ _ N0 (proj1 (proj2 Q))))). }
    assert (HSS : forall m0 m1, SSu m0 ->
      Mem.unchanged_on (fun b _ => b <> pool /\ b <> la /\ b <> fl /\ b <> bpg) m0 m1 -> SSu m1).
    { intros m0 m1 (A0 & N0) U0.
      split; [ | exact (Ple_trans _ _ _ N0 (Mem.unchanged_on_nextblock _ _ _ U0)) ].
      apply (AudioInv.AudioInv_unch G m0 m1); [ | exact A0 ].
      intros b0 ch z Hb0. apply (Mem.load_unchanged_on_1 _ m0 m1 _ _ _ U0).
      + destruct Hb0 as (g & _ & Hg0). unfold Mem.valid_block.
        exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hg0) N0).
      + intros _ _. refine (conj (NL _ _ Hp ltac:(vm_compute; reflexivity) b0 Hb0)
                         (conj (NL _ _ Hl ltac:(vm_compute; reflexivity) b0 Hb0)
                         (conj (NL _ _ Hf ltac:(vm_compute; reflexivity) b0 Hb0)
                               (NL _ _ Hb ltac:(vm_compute; reflexivity) b0 Hb0)))). }
    destruct (unload_sharp G (cenv_of lp _ (linked12_LO_graph_node lp H12)) (cenv_of lp _ (linked12_LO_spawn_object lp H12))
                pool la fl bpg gB Hpl Hpf Hlf Hpb Hlb Hfb Hp HgB Hb Hf
                (fun b fd => fun_res lp _ _ _ (linked12_LO_graph_node lp H12) dm_grc' b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_graph_node lp H12) dm_gac' b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_spawn_object lp H12) dm_dao b fd)
                SSu (CapAudio.ak lp ws_u) Hss
                (NW _ _ Hp ltac:(vm_compute; reflexivity)) (NW _ _ Hl ltac:(vm_compute; reflexivity))
                (NW _ _ Hf ltac:(vm_compute; reflexivity)) (NW _ _ Hb ltac:(vm_compute; reflexivity)) HSS
                m rs fs i l1 k l2 t m' vr Hr Hfl Hnd Hi El (proj1 Ig Hg) (conj HA HN) H)
      as (R & F & Gx & A & L & U).
    split; [ exact R | split; [ exact F | split; [ exact (proj2 (gfx_at_iff pool bpg Hpb G m' Hb) Gx) | ] ] ].
    exact (conj (proj1 A) (conj L U)).
  Qed.
End UREALS.
