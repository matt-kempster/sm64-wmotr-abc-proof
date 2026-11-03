(* kept: groundwork for BhvStep's Hobj_unload row (the unload_object step);
   consumed once the unload loops land. *)
(* OBJECTS -- unload_object (spawn_object.c:187-200), run by its real
   body:
     obj->activeFlags = 0; obj->prevObj = NULL;
     obj->header.gfx.throwMatrix = NULL;
     stop_sounds_from_source(obj->header.gfx.cameraToObject);
     geo_remove_child(&obj->header.gfx.node);
     geo_add_child(&gObjParentGraphNode, &obj->header.gfx.node);
     obj->header.gfx.node.flags &= ~GRAPH_RENDER_BILLBOARD;
     obj->header.gfx.node.flags &= ~GRAPH_RENDER_ACTIVE;
     deallocate_object(&gFreeObjectList, &obj->header);
   on slot k of ring i: k leaves its ring for the free list
   (ObjUnload.dealloc_ok), the graph shape stays (ObjAlloc.grc_ok /
   gac_ok), activeFlags reads 0, and memory changes only at slot k's own
   non-link bytes (ObjCreate.fx), the graph and list link cells, and the
   sound call's footprint (a section hypothesis in UNL; PROVED on the
   link by AudioWire's walk, uai_ssfs: unload_real, no new premise). *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area audio_external.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate ObjUnload.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop AudioWire AudioInv BodyFrame.
From SM64.Proofs Require CensusV2.

Import ListNotations.
Local Open Scope Z_scope.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.
Module GN := SM64.Generated.graph_node.

Section UNL.
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
  (* the sound call keeps SS and changes nothing SSK names; SSK names
     every pool, list-head, free-list and parent-node byte, and SS reads
     none of them *)
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
  Notation xs := (exec_stmt function_entry2 ge empty_env).
  Notation CE := (prog_comp_env SO.prog).
  Notation OBJ := (Tstruct SO._Object noattr).
  Notation ON := (Tstruct SO._ObjectNode noattr).
  Notation GT := (Tstruct GN._GraphNode noattr).
  Notation GNO := (Tstruct SO._GraphNodeObject noattr).

  Lemma fo_hdr : FO ge SO._Object SO._header 0.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env SO.prog)); [ vm_compute; reflexivity | exact Hcs ]. Qed.

  (* &x->header is x *)
  Lemma ev_hdr : forall le m x v b o,
    eval_expr ge empty_env le m (Eaddrof (Efield (Ederef (Etempvar x (tptr OBJ)) OBJ) SO._header ON) (tptr ON)) v ->
    le ! x = Some (Vptr b o) -> v = Vptr b o.
  Proof.
    intros le m x v b o H Hx.
    inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
      [ | match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end ].
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (fo_hdr _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    match goal with H1 : le ! x = Some _, H2 : le ! x = Some _ |- _ => rewrite H1 in H2; injection H2; intros; subst end.
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero. reflexivity.
  Qed.

  (* &x->header.gfx.node is x *)
  Lemma ev_onode : forall le m x v b o,
    eval_expr ge empty_env le m
      (Eaddrof (Efield (Efield (Efield (Ederef (Etempvar x (tptr OBJ)) OBJ) SO._header ON) SO._gfx GNO) SO._node GT) (tptr GT)) v ->
    le ! x = Some (Vptr b o) -> v = Vptr b o.
  Proof.
    intros le m x v b o H Hx.
    inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
      [ | match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end ].
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (fo_node ge Hcs _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
      [ | match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end ].
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (fo_ogfx ge Hcs _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
      [ | match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end ].
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (fo_hdr _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    match goal with H1 : le ! x = Some _, H2 : le ! x = Some _ |- _ => rewrite H1 in H2; injection H2; intros; subst end.
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero. reflexivity.
  Qed.

  Lemma ev_gaddr : forall le m id b T v, Genv.find_symbol ge id = Some b ->
    eval_expr ge empty_env le m (Eaddrof (Evar id T) (tptr T)) v -> v = Vptr b Ptrofs.zero.
  Proof.
    intros le m id b T v Hs H. inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
      destruct (RA.lv_gvar ge empty_env m le _ _ _ _ _ (PTree.gempty _ _) Hl) as (Hs' & -> & _) end.
    rewrite Hs in Hs'. injection Hs' as ->. reflexivity.
  Qed.

  (* the keep of the whole call *)
  Definition UK (k : Z) (b : block) (z : Z) : Prop :=
    KP pool (k * OSZ) b z /\ Gkeep pool bpg b z /\ ~ RCELL pool la fl b z /\ SSK b z.

  Lemma kp_rc : forall k j i, 0 <= k < NSLOT -> 0 <= j < NSLOT ->
    j * OSZ + O_NEXT <= i < j * OSZ + O_PREV + 4 -> KP pool (k * OSZ) pool i.
  Proof.
    intros k j i Hk Hj Hi. unfold KP, O_NEXT, O_PREV, OSZ, NSLOT in *.
    destruct (Z.lt_trichotomy j k) as [Hlt | [-> | Hgt]];
      [ right; left; nia | right; right; right; right; lia | right; right; left; nia ].
  Qed.

  Lemma gc_kp : forall k b z, 0 <= k < NSLOT -> GCELL pool bpg b z -> KP pool (k * OSZ) b z.
  Proof.
    intros k b z Hk [(-> & j & Hj & Hz) | (-> & Hz)].
    - unfold KP, G_PREV, G_CHILD, OSZ, NSLOT in *.
      destruct (Z.lt_trichotomy j k) as [Hlt | [-> | Hgt]];
        [ right; left; nia | right; right; right; left; lia | right; right; left; nia ].
    - left. exact (not_eq_sym Hpb).
  Qed.

  Lemma gc_ss : forall b z, GCELL pool bpg b z -> SSK b z.
  Proof. intros b z [(-> & _) | (-> & _)]; [ apply HSp | apply HSb ]. Qed.

  Lemma rc_ss : forall b z, RCELL pool la fl b z -> SSK b z.
  Proof. intros b z [(-> & _) | [-> | ->]]; [ apply HSp | apply HSl | apply HSf ]. Qed.

  Lemma hl_kp : forall k z, KP pool (k * OSZ) la z.
  Proof. intros k z. left. exact (not_eq_sym Hpl). Qed.
  Lemma hf_kp : forall k z, KP pool (k * OSZ) fl z.
  Proof. intros k z. left. exact (not_eq_sym Hpf). Qed.
  Lemma hl_gk : forall z, Gkeep pool bpg la z.
  Proof. intros z [(E & _) | (E & _)]; [ exact (Hpl (eq_sym E)) | exact (Hlb E) ]. Qed.
  Lemma hf_gk : forall z, Gkeep pool bpg fl z.
  Proof. intros z [(E & _) | (E & _)]; [ exact (Hpf (eq_sym E)) | exact (Hfb E) ]. Qed.
  Lemma ss_keep : forall (P : block -> Z -> Prop) m m', SS m ->
    (forall b z, b <> pool -> b <> la -> b <> fl -> b <> bpg -> P b z) -> Mem.unchanged_on P m m' -> SS m'.
  Proof.
    intros P m m' Hs HP U. apply (HSS m m' Hs).
    apply (Mem.unchanged_on_implies _ _ _ _ U). intros b z (N1 & N2 & N3 & N4) _. exact (HP b z N1 N2 N3 N4).
  Qed.

  Definition AF0 : fact := (Mint16signed, O_FLAGS, SC (Vint Int.zero)).

  (* THE UNLOADER: the real unload_object on slot k of ring i *)
  Theorem unload_ok : forall m rs fs i l1 k l2 t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    (i < NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 -> gfx_at pool bpg m -> SS m ->
    eval_funcall function_entry2 ge m (Internal SO.f_unload_object) [slot_v pool k] t m' vr ->
    rings m' pool la = Some (upd rs i (l1 ++ l2)) /\ free_list m' pool fl = Some (k :: fs)
    /\ gfx_at pool bpg m' /\ SS m'
    /\ Mem.load Mint16signed m' pool (k * OSZ + O_FLAGS) = Some (Vint Int.zero)
    /\ Mem.unchanged_on (UK k) m m'.
  Proof.
    intros m rs fs i l1 k l2 t m' vr Hr Hf Hnd Hi El Hg HS0 H.
    (* k is a slot *)
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
    destruct (fxl_sound ge pool gB Hpool HgB CE Hce' SO._obj k Hk 3 _ [] _ _
                (fxl_ok CE SO._obj 3 (fn_body SO.f_unload_object) [] ltac:(vm_compute; discriminate))
                _ _ _ _ _ _ Hx Hx0 (facts_nil _ _ _ _))
      as (le1 & m1 & t1 & H1 & Hx1 & HF1 & U1).
    assert (IF1 : In AF0 (ffacts CE SO._obj 3 (fn_body SO.f_unload_object) [])) by (vm_compute; tauto).
    pose proof (HF1 _ _ _ IF1) as A1. cbn [ival] in A1.
    cbn [sdrop fn_body SO.f_unload_object] in H1.
    (* stop_sounds_from_source(...) *)
    apply RA.seq_inv in H1 as [(c1 & lc1 & mc1 & c2 & C1 & C2) | (C1 & Xn)]; [ | kill_sq0 C1 Xn ].
    apply RA.call_inv in C1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bs & Hs & ->) end.
    assert (SS1 : SS m1) by (apply (ss_keep (KP pool (k * OSZ)) m m1 HS0); [ intros b z N _ _ _; left; exact N | exact U1 ]).
    destruct (Hss bs fd Hs Hff _ _ _ _ _ Hc SS1) as (U2 & SS2).
    (* geo_remove_child(&obj->header.gfx.node) *)
    apply RA.seq_inv in C2 as [(c3 & lc3 & mc3 & c4 & C3 & C4) | (C3 & Xn)]; [ | kill_sq0 C3 Xn ].
    apply RA.call_inv in C3 as (tya2 & tyr2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hc2 & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf2 & Hs2 & ->) end.
    rewrite (Hgrc bf2 fd2 Hs2 Hff2) in Hc2.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal2) as (ty1 & v1 & w1 & Ea1 & -> & Ev1 & Cc1). injection Ea1 as <-.
    rewrite (ev_onode _ _ _ _ _ _ Ev1 Hx1) in Cc1.
    cbn [typeof] in Cc1. apply RA.cast_ptr_id in Cc1. subst w1.
    (* the graph shape before the relink *)
    assert (G1 : gfx_at pool bpg mc1).
    { apply (gfx_keep pool bpg (fun b z => KP pool (k * OSZ) b z /\ SSK b z) m mc1).
      - apply (Mem.unchanged_on_trans _ _ m1).
        + apply (Mem.unchanged_on_implies _ _ _ _ U1). intros b z (H0 & _) _. exact H0.
        + apply (Mem.unchanged_on_implies _ _ _ _ U2). intros b z (_ & H0) _. exact H0.
      - intros b z Hgc. exact (conj (gc_kp k b z Hk Hgc) (gc_ss b z Hgc)).
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
    rewrite (ev_gaddr _ _ _ _ _ _ Hbpg Eva) in Cca. cbn [typeof] in Cca. apply RA.cast_ptr_id in Cca. subst x1.
    rewrite (ev_onode _ _ _ _ _ _ Evb Hx1) in Ccb. cbn [typeof] in Ccb. apply RA.cast_ptr_id in Ccb. subst x2.
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
      destruct (fxl_sound ge pool gB Hpool HgB CE Hce' SO._obj k Hk 2 s6 [AF0] _ _
                  (fxl_ok CE SO._obj 2 s6 [AF0] ltac:(vm_compute; discriminate))
                  _ _ _ _ _ _ C6 Hx1 HFa)
        as (le7 & m7 & t7 & H7 & Hx7 & HF7 & U7);
      assert (IF7 : In AF0 (ffacts CE SO._obj 2 s6 [AF0])) by (vm_compute; tauto)
    end.
    pose proof (HF7 _ _ _ IF7) as A7. cbn [ival] in A7.
    cbn [sdrop] in H7.
    (* deallocate_object(&gFreeObjectList, &obj->header) *)
    apply RA.call_inv in H7 as (tya4 & tyr4 & cc4 & vf4 & vargs4 & fd4 & vres4 & Hcf4 & Evf4 & Eal4 & Hff4 & _ & Hc4 & -> & _).
    cbn in Hcf4. injection Hcf4 as <- <- <-.
    match type of Evf4 with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf4 (PTree.gempty _ _) eq_refl Evf4) as (bf4 & Hs4 & ->) end.
    rewrite (Hdao bf4 fd4 Hs4 Hff4) in Hc4.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal4) as (ta4 & tb4 & y1 & y2 & z1 & z2 & Ea4 & -> & Eva4 & Cca4 & Evb4 & Ccb4).
    injection Ea4 as <- <-.
    rewrite (ev_gaddr _ _ _ _ _ _ Hfls Eva4) in Cca4. cbn [typeof] in Cca4. apply RA.cast_ptr_id in Cca4. subst z1.
    rewrite (ev_hdr _ _ _ _ _ _ Evb4 Hx7) in Ccb4. cbn [typeof] in Ccb4. apply RA.cast_ptr_id in Ccb4. subst z2.
    (* the rings and the free list before the call *)
    assert (U07 : Mem.unchanged_on (fun b z => KP pool (k * OSZ) b z /\ Gkeep pool bpg b z /\ SSK b z) m m7).
    { apply (Mem.unchanged_on_trans _ _ m1); [ apply (Mem.unchanged_on_implies _ _ _ _ U1); intros b z (H0 & _) _; exact H0 | ].
      apply (Mem.unchanged_on_trans _ _ mc1); [ apply (Mem.unchanged_on_implies _ _ _ _ U2); intros b z (_ & _ & H0) _; exact H0 | ].
      apply (Mem.unchanged_on_trans _ _ mc3); [ apply (Mem.unchanged_on_implies _ _ _ _ U3); intros b z (_ & H0 & _) _; exact H0 | ].
      apply (Mem.unchanged_on_trans _ _ mc5); [ apply (Mem.unchanged_on_implies _ _ _ _ U4); intros b z (_ & H0 & _) _; exact H0 | ].
      apply (Mem.unchanged_on_implies _ _ _ _ U7). intros b z (H0 & _) _. exact H0. }
    set (P7 := fun b z => KP pool (k * OSZ) b z /\ Gkeep pool bpg b z /\ SSK b z) in U07.
    assert (Prc : forall j i0, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i0 < j * OSZ + O_PREV + 4 -> P7 pool i0).
    { intros j i0 Hj Hi0. split; [ exact (kp_rc k j i0 Hk Hj Hi0) | split; [ intros [(_ & j' & Hj' & Hz) | (E & _)]; [ unfold G_PREV, G_CHILD, O_NEXT, O_PREV, OSZ, NSLOT in *; lia | exact (Hpb E) ] | apply HSp ] ]. }
    assert (R7 : rings m7 pool la = Some rs)
      by exact (rings_keep pool la P7 Prc (fun z => conj (hl_kp k z) (conj (hl_gk z) (HSl z))) m m7 rs Hpl U07 Hr).
    assert (F7 : free_list m7 pool fl = Some fs)
      by exact (free_keep pool fl P7 Prc (fun z => conj (hf_kp k z) (conj (hf_gk z) (HSf z))) m m7 fs U07 Hf).
    assert (G7 : gfx_at pool bpg m7).
    { apply (gfx_keep pool bpg (KP pool (k * OSZ)) mc5 m7 U7); [ intros b z Hgc; exact (gc_kp k b z Hk Hgc) | exact G3 ]. }
    destruct (dealloc_ok ge Hcs pool la fl Hpl Hpf Hlf m7 rs fs i l1 k l2 t7 m' vres4 R7 F7 Hnd Hi El Hc4)
      as (R8 & F8 & U8).
    assert (SS7 : SS m7).
    { apply (ss_keep (fun b z => Gkeep pool bpg b z /\ KP pool (k * OSZ) b z) mc1 m7 SS2).
      - intros b z N1 _ _ N4. split; [ intros [(E & _) | (E & _)]; [ exact (N1 E) | exact (N4 E) ] | left; exact N1 ].
      - apply (Mem.unchanged_on_trans _ _ mc3); [ apply (Mem.unchanged_on_implies _ _ _ _ U3); intros b z (H0 & _) _; exact H0 | ].
        apply (Mem.unchanged_on_trans _ _ mc5); [ apply (Mem.unchanged_on_implies _ _ _ _ U4); intros b z (H0 & _) _; exact H0 | ].
        apply (Mem.unchanged_on_implies _ _ _ _ U7). intros b z (_ & H0) _. exact H0. }
    split; [ exact R8 | split; [ exact F8 | split; [ | split; [ | split ] ] ] ].
    - apply (gfx_keep pool bpg _ m7 m' U8); [ | exact G7 ].
      intros b z Hgc. eapply gc_nrc; eassumption.
    - apply (ss_keep (fun b z => ~ RCELL pool la fl b z) m7 m' SS7); [ | exact U8 ].
      intros b z N1 N2 N3 _ [(E & _) | [E | E]]; [ exact (N1 E) | exact (N2 E) | exact (N3 E) ].
    - apply (Mem.load_unchanged_on _ m7 m' _ _ _ _ U8); [ | exact A7 ].
      intros z Hz [(_ & j & _ & Hj) | [E | E]];
        [ unfold O_FLAGS, O_NEXT, O_PREV, OSZ, NSLOT in *; cbn [size_chunk] in Hz; nia | exact (Hpl E) | exact (Hpf E) ].
    - apply (Mem.unchanged_on_trans _ _ m7).
      + apply (Mem.unchanged_on_implies _ _ _ _ U07). intros b z (H0 & H2 & _ & H4) _. exact (conj H0 (conj H2 H4)).
      + apply (Mem.unchanged_on_implies _ _ _ _ U8). intros b z (_ & _ & H3 & _) _. exact H3.
  Qed.
End UNL.

(* ---------------------------------------------------------------------- *)
(* The sound call on the link: AudioWire's walk.  stop_sounds_from_source *)
(* (external.c:2235) zeroes soundBits in sSoundBanks and, through         *)
(* update_background_music_after_sound, may clear a bit of               *)
(* sSoundBanksThatLowerBackgroundMusic and begin a music fade (the        *)
(* camera's walked leaves, AudioWire.cai_bbmf).  From an AudioInv memory  *)
(* it changes only the blocks of ws_u and keeps AudioInv -- no new        *)
(* premise: only load_sequence's scoped contract (TRUST 4.1), which this  *)
(* path never reaches, sits under AudioWire.                             *)
(* ---------------------------------------------------------------------- *)
Module AX := SM64.Generated.audio_external.

Definition ws_u : list ident :=
  [AX._sSoundBanks; AX._sSoundBanksThatLowerBackgroundMusic] ++ AudioWire.cam_aud_ids.

Lemma dm_ubmas : (prog_defmap AX.prog) ! AX._update_background_music_after_sound
  = Some (Gfun (Internal AX.f_update_background_music_after_sound)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ssfs : (prog_defmap AX.prog) ! AX._stop_sounds_from_source
  = Some (Gfun (Internal AX.f_stop_sounds_from_source)).
Proof. vm_compute. reflexivity. Qed.

Section AUD.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  Lemma afi_mono : forall ws ws' g, (forall x, In x ws -> In x ws') ->
    AudioWire.afi lp ws g -> AudioWire.afi lp ws' g.
  Proof.
    intros ws ws' g Hi A b fd Hs Hf m vargs t m' vres He Ai.
    destruct (A b fd Hs Hf m vargs t m' vres He Ai) as (Q & A').
    split; [ | exact A' ].
    refine (BodyFrame.Q2_mono _ _ m m' _ Q).
    intros b0 z Hk (g0 & Ig & Hg). apply Hk. exists g0. split; [ exact (Hi g0 Ig) | exact Hg ].
  Qed.

  Lemma uai_bbmf : AudioWire.afi lp ws_u AX._begin_background_music_fade.
  Proof.
    apply (afi_mono AudioWire.cam_aud_ids); [ intros x Hx; unfold ws_u; right; right; exact Hx | ].
    exact (AudioWire.cai_bbmf lp H12).
  Qed.

  Lemma uai_ubmas : AudioWire.afi lp ws_u AX._update_background_music_after_sound.
  Proof.
    pose proof uai_bbmf.
    refine (AudioWire.afi_of_body lp ws_u AX.prog _ AX.f_update_background_music_after_sound
              (linked12_LO_audio_external lp H12) dm_ubmas _).
    apply (AudioWire.afi_body lp ws_u (@nil (ident * ident)) [AX._begin_background_music_fade]
             AX.f_update_background_music_after_sound); [ vm_compute; reflexivity | ].
    intros g Hg. cbv [CensusV2.mem_id existsb] in Hg. rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst g. assumption.
  Qed.

  Lemma uai_ssfs : AudioWire.afi lp ws_u AX._stop_sounds_from_source.
  Proof.
    pose proof uai_ubmas.
    refine (AudioWire.afi_of_body lp ws_u AX.prog _ AX.f_stop_sounds_from_source
              (linked12_LO_audio_external lp H12) dm_ssfs _).
    apply (AudioWire.afi_body lp ws_u (@nil (ident * ident)) [AX._update_background_music_after_sound]
             AX.f_stop_sounds_from_source); [ vm_compute; reflexivity | ].
    intros g Hg. cbv [CensusV2.mem_id existsb] in Hg. rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst g. assumption.
  Qed.
End AUD.

(* ---------------------------------------------------------------------- *)
(* unload_object on the real program.                                      *)
(* ---------------------------------------------------------------------- *)
Lemma dm_grc' : (prog_defmap GN.prog) ! SO._geo_remove_child = Some (Gfun (Internal GN.f_geo_remove_child)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_gac' : (prog_defmap GN.prog) ! SO._geo_add_child = Some (Gfun (Internal GN.f_geo_add_child)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_uo : (prog_defmap SO.prog) ! SO._unload_object = Some (Gfun (Internal SO.f_unload_object)).
Proof. vm_compute. reflexivity. Qed.

Lemma gblk_not : forall (G : genv) ids id b, Genv.find_symbol G id = Some b ->
  existsb (Pos.eqb id) ids = false -> ~ LsContract.gblk G ids b.
Proof.
  intros G ids id b Hs Hn (g & Ig & Hg).
  assert (E : g = id) by (eapply Genv.genv_vars_inj; [ exact Hg | exact Hs ]). subst g.
  assert (T : existsb (Pos.eqb id) ids = true) by (apply existsb_exists; exists id; split; [ exact Ig | apply Pos.eqb_refl ]).
  congruence.
Qed.

Section UREAL.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* THE UNLOADER ON THE REAL PROGRAM: from obj_w's rings, free list,
     partition and graph clauses and the audio state (lvl_w's aud_w), the
     real unload_object on a listed slot k frees it; memory changes only
     at slot k's own non-link bytes, the graph and list link cells and the
     sound blocks ws_u *)
  Theorem unload_real : forall pool la fl bpg,
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
    /\ Mem.unchanged_on (UK pool la fl bpg (CapAudio.ak lp ws_u) k) m m'.
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
    destruct (unload_ok G (cenv_of lp _ (linked12_LO_graph_node lp H12)) (cenv_of lp _ (linked12_LO_spawn_object lp H12))
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
End UREAL.
