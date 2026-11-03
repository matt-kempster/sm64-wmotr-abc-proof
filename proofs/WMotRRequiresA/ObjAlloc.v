(* spine (via BhvStep's spawn rows): OBJECTS -- the ALLOCATOR, run by its
   real bodies.  try_allocate_object (spawn_object.c:79-99) and the two
   graph relinkers it calls, geo_remove_child / geo_add_child
   (graph_node.c:525-577), walked statement by statement against the
   generated Clight:
     - gfx_at pool bpg m : ObjWorld's GFX clause (ow_gfx) at a fixed
       gObjParentGraphNode block;
     - grc_ok / gac_ok   : each relinker keeps gfx_at and changes only the
       graph link cells (GCELL: a slot node's prev / next / parent, the
       parent's children);
     - try_alloc_ok      : from ObjWorld's rings / free list (ObjRing's
       accessors), the real call either finds the free list empty and
       returns NULL with memory unchanged, or pops its head k, appends k
       to ring i (ObjRing.alloc_rings), keeps gfx_at, returns slot k, and
       changes only link cells (GCELL, a slot's header.next / prev, the
       list heads, gFreeObjectList).
   Nothing here is assumed about memory beyond the clauses obj_w already
   carries (ow_rings / ow_free / ow_part / ow_gfx). *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.
Module GN := SM64.Generated.graph_node.
Module CM := SM64.Proofs.Interp.CMem.

(* ---------------------------------------------------------------------- *)
(* 1. Small kit.                                                            *)
(* ---------------------------------------------------------------------- *)
Lemma fcall_inv0 : forall (G : genv) f m vargs t m' vr, fn_vars f = [] ->
  eval_funcall function_entry2 G m (Internal f) vargs t m' vr ->
  exists le le' out, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le
    /\ exec_stmt function_entry2 G empty_env le m (fn_body f) t le' m' out
    /\ outcome_result_value out (fn_return f) vr m'.
Proof.
  intros G f m vargs t m' vr Hv H.
  remember (Internal f) as fd eqn:Efd.
  destruct H as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
    [ injection Efd as <- | discriminate Efd ].
  destruct Hfe as [_ _ _ Hav Hb]. rewrite Hv in Hav. inversion Hav; subst.
  cbn in Hfr. injection Hfr as <-.
  exists lea, leb, oo. auto.
Qed.

Lemma uadd0 : forall a b, 0 <= a -> 0 <= b -> a + b <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr b)) = a + b.
Proof.
  intros a b Ha Hb H. rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr a), (Ptrofs.unsigned_repr b) by lia.
  apply Ptrofs.unsigned_repr. lia.
Qed.

(* a field of slot j *)
Lemma slot_fld : forall j d, 0 <= j < NSLOT -> 0 <= d < OSZ ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr (j * OSZ)) (Ptrofs.repr d)) = j * OSZ + d.
Proof. intros j d Hj Hd. apply uadd0; unfold NSLOT, OSZ in *; rewrite ?maxu32; lia. Qed.

(* one Mint32 store, seen from a Mint32 load *)
Lemma ld_cases : forall m b z v m', Mem.store Mint32 m b z v = Some m' -> forall b' z',
  (b' = b /\ z' = z /\ Mem.load Mint32 m' b' z' = Some (Val.load_result Mint32 v))
  \/ (Mem.load Mint32 m' b' z' = Mem.load Mint32 m b' z')
  \/ (b' = b /\ z' <> z /\ z' < z + 4 /\ z < z' + 4).
Proof.
  intros m b z v m' Hs b' z'.
  destruct (eq_block b' b) as [-> | Hb].
  - destruct (Z.eq_dec z' z) as [-> | Hz].
    + left. split; [ reflexivity | split; [ reflexivity | exact (Mem.load_store_same _ _ _ _ _ _ Hs) ] ].
    + destruct (Z_le_gt_dec (z + 4) z') as [H1 | H1]; [ right; left | ].
      * apply (Mem.load_store_other _ _ _ _ _ _ Hs). right. right. cbn [size_chunk]. lia.
      * destruct (Z_le_gt_dec (z' + 4) z) as [H2 | H2]; [ right; left | right; right; split; [ reflexivity | lia ] ].
        apply (Mem.load_store_other _ _ _ _ _ _ Hs). right. left. cbn [size_chunk]. lia.
  - right. left. apply (Mem.load_store_other _ _ _ _ _ _ Hs). left. exact Hb.
Qed.

Lemma lr_ptr : forall b o, Val.load_result Mint32 (Vptr b o) = Vptr b o.
Proof. reflexivity. Qed.
Lemma lr_int : forall i, Val.load_result Mint32 (Vint i) = Vint i.
Proof. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The graph-link invariant at a fixed parent block.                     *)
(* ---------------------------------------------------------------------- *)
Section GFX.
  Variables pool bpg : block.
  Hypothesis Hpb : pool <> bpg.

  Definition gn (v : val) : Prop := exists j, 0 <= j < NSLOT /\ v = slot_v pool j.

  Definition gfx_at (m : mem) : Prop :=
    (forall k, 0 <= k < NSLOT ->
       Mem.load Mint32 m pool (k * OSZ + G_PAR) = Some (Vptr bpg Ptrofs.zero)
       /\ slot_node pool (Mem.load Mint32 m pool (k * OSZ + G_PREV))
       /\ slot_node pool (Mem.load Mint32 m pool (k * OSZ + G_NEXT)))
    /\ (Mem.load Mint32 m bpg G_CHILD = Some (Vint Int.zero)
        \/ slot_node pool (Mem.load Mint32 m bpg G_CHILD)).

  Lemma gfx_at_iff : forall (ge : genv) m, Genv.find_symbol ge SO._gObjParentGraphNode = Some bpg ->
    gfx_ok ge pool m <-> gfx_at m.
  Proof.
    intros ge m Hs. unfold gfx_ok, gfx_at. split.
    - intros H. exact (H bpg Hs).
    - intros H b Hb. pose proof (eq_trans (eq_sym Hb) Hs) as E. injection E as <-. exact H.
  Qed.

  (* the graph link cells *)
  Definition GCELL (b : block) (z : Z) : Prop :=
    (b = pool /\ exists j, 0 <= j < NSLOT /\ j * OSZ + G_PREV <= z < j * OSZ + G_CHILD)
    \/ (b = bpg /\ G_CHILD <= z < G_CHILD + 4).
  Definition Gkeep (b : block) (z : Z) : Prop := ~ GCELL b z.

  (* the three kinds of graph store keep the invariant *)
  Definition gstore (b : block) (z : Z) (v : val) : Prop :=
    (b = pool /\ exists j, 0 <= j < NSLOT /\ (z = j * OSZ + G_PREV \/ z = j * OSZ + G_NEXT) /\ gn v)
    \/ (b = pool /\ exists j, 0 <= j < NSLOT /\ z = j * OSZ + G_PAR /\ v = Vptr bpg Ptrofs.zero)
    \/ (b = bpg /\ z = G_CHILD /\ (v = Vint Int.zero \/ gn v)).

  Lemma gn_node : forall v, gn v -> slot_node pool (Some v).
  Proof. intros v (j & Hj & ->). exists j. split; [ exact Hj | reflexivity ]. Qed.

  Lemma gn_lr : forall v, gn v -> Val.load_result Mint32 v = v.
  Proof. intros v (j & _ & ->). reflexivity. Qed.

  Ltac kx := exfalso; first [ congruence | unfold G_PAR, G_PREV, G_NEXT, G_CHILD, OSZ, NSLOT in *; lia ].

  Lemma gfx_store : forall m b z v m', gfx_at m -> Mem.store Mint32 m b z v = Some m' ->
    gstore b z v -> gfx_at m' /\ Mem.unchanged_on Gkeep m m'.
  Proof.
    intros m b z v m' (Hg & Hc) Hs Hk. split.
    - destruct Hk as [(-> & j & Hj & Ez & Hv) | [(-> & j & Hj & -> & ->) | (-> & -> & Hv)]]; split.
      + intros k Hkr. destruct (Hg k Hkr) as (P0 & P1 & P2). refine (conj _ (conj _ _)).
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_PAR)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ kx | rewrite L; exact P0 | kx ].
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_PREV)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ rewrite L, (gn_lr v Hv); exact (gn_node v Hv) | rewrite L; exact P1 | kx ].
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_NEXT)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ rewrite L, (gn_lr v Hv); exact (gn_node v Hv) | rewrite L; exact P2 | kx ].
      + destruct (ld_cases _ _ _ _ _ Hs bpg G_CHILD) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
          [ kx | rewrite L; exact Hc | kx ].
      + intros k Hkr. destruct (Hg k Hkr) as (P0 & P1 & P2). refine (conj _ (conj _ _)).
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_PAR)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ rewrite L; reflexivity | rewrite L; exact P0 | kx ].
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_PREV)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ kx | rewrite L; exact P1 | kx ].
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_NEXT)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ kx | rewrite L; exact P2 | kx ].
      + destruct (ld_cases _ _ _ _ _ Hs bpg G_CHILD) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
          [ kx | rewrite L; exact Hc | kx ].
      + intros k Hkr. destruct (Hg k Hkr) as (P0 & P1 & P2). refine (conj _ (conj _ _)).
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_PAR)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ kx | rewrite L; exact P0 | kx ].
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_PREV)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ kx | rewrite L; exact P1 | kx ].
        * destruct (ld_cases _ _ _ _ _ Hs pool (k * OSZ + G_NEXT)) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
            [ kx | rewrite L; exact P2 | kx ].
      + destruct (ld_cases _ _ _ _ _ Hs bpg G_CHILD) as [(Eb & Ez' & L) | [L | (Eb & Hne & H1 & H2)]];
          [ | rewrite L; exact Hc | kx ].
        rewrite L. destruct Hv as [-> | Hv]; [ left; reflexivity | right; rewrite (gn_lr v Hv); exact (gn_node v Hv) ].
    - apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i Hi Hn. apply Hn. cbn [size_chunk] in Hi.
      unfold gstore, GCELL, G_PREV, G_NEXT, G_PAR, G_CHILD in *.
      destruct Hk as [(-> & j & Hj & [-> | ->] & _) | [(-> & j & Hj & -> & _) | (-> & -> & _)]].
      + left. split; [ reflexivity | exists j; split; [ exact Hj | lia ] ].
      + left. split; [ reflexivity | exists j; split; [ exact Hj | lia ] ].
      + left. split; [ reflexivity | exists j; split; [ exact Hj | lia ] ].
      + right. split; [ reflexivity | lia ].
  Qed.
End GFX.

Lemma sn_gn : forall pool v, slot_node pool (Some v) -> gn pool v.
Proof. intros pool v (j & Hj & E). injection E as ->. exists j. split; [ exact Hj | reflexivity ]. Qed.

Ltac neq0 := let Hq := fresh in intro Hq; vm_compute in Hq; discriminate.
Ltac tmp0 := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq0 ]; reflexivity.
Ltac tmp_in H := repeat first [ rewrite PTree.gss in H | rewrite PTree.gso in H by neq0 ].
Ltac kill_sq0 H1 Hn := exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ H1 eq_refl)).

(* ---------------------------------------------------------------------- *)
(* 3. Statement kit over a genv.                                            *)
(* ---------------------------------------------------------------------- *)
Section KIT.
  Variable ge : genv.
  Notation xs := (exec_stmt function_entry2 ge empty_env).
  Definition FO (S f : ident) (d : Z) : Prop :=
    forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full).

  (* x = y->f, a pointer field *)
  Lemma ldp_set : forall le m x y S f T t le' m' out d, FO S f d ->
    xs le m (Sset x (Efield (Ederef (Etempvar y (tptr (Tstruct S noattr))) (Tstruct S noattr)) f (tptr T))) t le' m' out ->
    exists b o v, le ! y = Some (Vptr b o)
      /\ Mem.load Mint32 m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d))) = Some v
      /\ le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
  Proof.
    intros le m x y S f T t le' m' out d Hfo H.
    apply RA.set_inv in H as (v & Ev & -> & -> & ->).
    destruct (RA.ev_fld ge empty_env m le y S f (tptr T) v Mint32 d Hfo eq_refl Ev) as (b & o & Hy & L).
    exists b, o, v. auto.
  Qed.

  (* y->f = z, a pointer field from a pointer temp of the same type *)
  Lemma stp : forall le m y z S f T t le' m' out d, FO S f d ->
    xs le m (Sassign (Efield (Ederef (Etempvar y (tptr (Tstruct S noattr))) (Tstruct S noattr)) f (tptr T))
                     (Etempvar z (tptr T))) t le' m' out ->
    exists b o v, le ! y = Some (Vptr b o) /\ le ! z = Some v
      /\ Mem.store Mint32 m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d))) v = Some m'
      /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m y z S f T t le' m' out d Hfo H.
    apply RA.assign_inv in H as (b & o' & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    destruct (RA.lv_fld ge empty_env m le y S f (tptr T) b o' bf d Hfo Hlv) as (o & Hy & -> & ->).
    apply RA.ev_temp in Ev. cbn [typeof] in Hc. apply RA.cast_ptr_id in Hc. subst v.
    pose proof (RA.store_by_value ge (tptr T) m b _ Full v2 _ Mint32 eq_refl eq_refl Has) as Hs.
    exists b, o, v2. auto.
  Qed.

  (* *x = a, x a temp of pointer-to-pointer type *)
  Lemma st_deref : forall le m x U a t le' m' out,
    xs le m (Sassign (Ederef (Etempvar x (tptr (tptr U))) (tptr U)) a) t le' m' out ->
    exists b o v w, le ! x = Some (Vptr b o) /\ eval_expr ge empty_env le m a v
      /\ sem_cast v (typeof a) (tptr U) m = Some w
      /\ Mem.store Mint32 m b (Ptrofs.unsigned o) w = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m x U a t le' m' out H.
    apply RA.assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    inversion Hlv; subst; match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    pose proof (RA.store_by_value ge (tptr U) m b o Full v _ Mint32 eq_refl eq_refl Has) as Hs.
    exists b, o, v2, v. repeat split; assumption.
  Qed.

  Lemma null_cast : forall le m U v w,
    eval_expr ge empty_env le m (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) v ->
    sem_cast v (tptr tvoid) (tptr U) m = Some w -> w = Vint Int.zero.
  Proof.
    intros le m U v w Ev Hc. apply RA.ev_cast in Ev as (v1 & E1 & C1). apply RA.ev_const in E1. subst v1.
    cbn in C1. injection C1 as <-. cbn in Hc. injection Hc as <-. reflexivity.
  Qed.
End KIT.

(* ---------------------------------------------------------------------- *)
(* 4. geo_remove_child / geo_add_child (graph_node.c:525-577).             *)
(* ---------------------------------------------------------------------- *)
Section GEO.
  Variable ge : genv.
  Hypothesis Hce : forall id co, (prog_comp_env GN.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Variables pool bpg : block.
  Hypothesis Hpb : pool <> bpg.
  Notation xs := (exec_stmt function_entry2 ge empty_env).
  Notation GT := (Tstruct GN._GraphNode noattr).

  Lemma fo_gprev : FO ge GN._GraphNode GN._prev G_PREV.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env GN.prog)); [ vm_compute; reflexivity | exact Hce ]. Qed.
  Lemma fo_gnext : FO ge GN._GraphNode GN._next G_NEXT.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env GN.prog)); [ vm_compute; reflexivity | exact Hce ]. Qed.
  Lemma fo_gpar : FO ge GN._GraphNode GN._parent G_PAR.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env GN.prog)); [ vm_compute; reflexivity | exact Hce ]. Qed.
  Lemma fo_gchild : FO ge GN._GraphNode GN._children G_CHILD.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env GN.prog)); [ vm_compute; reflexivity | exact Hce ]. Qed.

  (* a pointer field of a slot node, read *)
  Lemma sld : forall le m x y f t le' m' out d j, FO ge GN._GraphNode f d -> 0 <= d < OSZ -> 0 <= j < NSLOT ->
    xs le m (Sset x (Efield (Ederef (Etempvar y (tptr GT)) GT) f (tptr GT))) t le' m' out ->
    le ! y = Some (slot_v pool j) ->
    exists v, Mem.load Mint32 m pool (j * OSZ + d) = Some v /\ le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
  Proof.
    intros le m x y f t le' m' out d j Hfo Hd Hj H Hy.
    destruct (ldp_set ge le m x y _ f GT t le' m' out d Hfo H) as (b & o & v & Hy' & L & -> & -> & ->).
    rewrite Hy in Hy'. unfold slot_v in Hy'. injection Hy' as <- <-. rewrite slot_fld in L by exact Hj || lia.
    exists v. auto.
  Qed.

  (* a pointer field of a slot node, written from a temp *)
  Lemma sst : forall le m y z f t le' m' out d j, FO ge GN._GraphNode f d -> 0 <= d < OSZ -> 0 <= j < NSLOT ->
    xs le m (Sassign (Efield (Ederef (Etempvar y (tptr GT)) GT) f (tptr GT)) (Etempvar z (tptr GT))) t le' m' out ->
    le ! y = Some (slot_v pool j) ->
    exists v, le ! z = Some v /\ Mem.store Mint32 m pool (j * OSZ + d) v = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m y z f t le' m' out d j Hfo Hd Hj H Hy.
    destruct (stp ge le m y z _ f GT t le' m' out d Hfo H) as (b & o & v & Hy' & Hz & S & -> & ->).
    rewrite Hy in Hy'. unfold slot_v in Hy'. injection Hy' as <- <-. rewrite slot_fld in S by exact Hj || lia.
    exists v. auto.
  Qed.

  Ltac step_st S Hg U :=
    let Hg' := fresh "Hg" in let U' := fresh "U" in
    destruct (gfx_store pool bpg Hpb _ _ _ _ _ Hg S) as (Hg' & U'); [ | clear Hg; rename Hg' into Hg;
      pose proof (Mem.unchanged_on_trans _ _ _ _ U U') as U''; clear U U'; rename U'' into U ].

  (* THE UNLINK: gfx_at kept, only graph link cells change *)
  Lemma grc_ok : forall m k t m' vr, gfx_at pool bpg m -> 0 <= k < NSLOT ->
    eval_funcall function_entry2 ge m (Internal GN.f_geo_remove_child) [slot_v pool k] t m' vr ->
    gfx_at pool bpg m' /\ Mem.unchanged_on (Gkeep pool bpg) m m'.
  Proof.
    intros m k t m' vr Hg Hk H.
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & _); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params GN.f_geo_remove_child] in Hb. injection Hb as <-.
    cbn [fn_body GN.f_geo_remove_child] in Hx.
    pose proof (Mem.unchanged_on_refl (Gkeep pool bpg) m) as U.
    (* parent = graphNode->parent *)
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq0 X1 Xn ].
    destruct (sld _ _ _ _ _ _ _ _ _ _ _ fo_gpar ltac:(unfold G_PAR, OSZ; lia) Hk X1 ltac:(tmp0))
      as (vp & Lp & -> & -> & _).
    destruct (proj1 Hg k Hk) as (P0 & _ & _). rewrite P0 in Lp. injection Lp as <-.
    (* firstChild = &parent->children *)
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq0 X3 Xn ].
    apply RA.set_inv in X3 as (vf & Evf & -> & -> & _).
    destruct (RA.ev_addr_fld ge empty_env m _ _ _ _ _ _ _ fo_gchild Evf) as (bf & of & Hpf & ->).
    rewrite PTree.gss in Hpf. injection Hpf as <- <-.
    (* graphNode->prev->next = graphNode->next *)
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq0 X5 Xn ].
    apply RA.seq_inv in X5 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq0 X7 Xn ].
    destruct (sld _ _ _ _ _ _ _ _ _ _ k fo_gprev ltac:(unfold G_PREV, OSZ; lia) Hk X7 ltac:(tmp0))
      as (v6 & L6 & -> & -> & _).
    destruct (proj1 Hg k Hk) as (_ & P1 & _). rewrite L6 in P1. destruct (sn_gn _ _ P1) as (j6 & Hj6 & ->).
    apply RA.seq_inv in X8 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Xn)]; [ | kill_sq0 X9 Xn ].
    destruct (sld _ _ _ _ _ _ _ _ _ _ k fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hk X9 ltac:(tmp0))
      as (v7 & L7 & -> & -> & _).
    destruct (proj1 Hg k Hk) as (_ & _ & P2). rewrite L7 in P2. destruct (sn_gn _ _ P2) as (j7 & Hj7 & ->).
    destruct (sst _ _ _ _ _ _ _ _ _ _ j6 fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hj6 X10 ltac:(tmp0))
      as (w & Hw & S1 & -> & _).
    tmp_in Hw. injection Hw as <-.
    destruct (gfx_store pool bpg Hpb _ _ _ _ _ Hg S1) as (Hg1 & U1);
      [ left; split; [ reflexivity | exists j6; split; [ exact Hj6 | split; [ right; reflexivity | exists j7; auto ] ] ] | ].
    clear Hg. pose proof (Mem.unchanged_on_trans _ _ _ _ U U1) as U2. clear U U1.
    (* graphNode->next->prev = graphNode->prev *)
    apply RA.seq_inv in X6 as [(s1 & lx1 & mx1 & s2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq0 Y1 Xn ].
    apply RA.seq_inv in Y1 as [(s3 & lx3 & mx3 & s4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq0 Y3 Xn ].
    destruct (sld _ _ _ _ _ _ _ _ _ _ k fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hk Y3 ltac:(tmp0))
      as (v4 & L4 & -> & -> & _).
    destruct (proj1 Hg1 k Hk) as (_ & _ & Q2). rewrite L4 in Q2. destruct (sn_gn _ _ Q2) as (j4 & Hj4 & ->).
    apply RA.seq_inv in Y4 as [(s5 & lx5 & mx5 & s6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq0 Y5 Xn ].
    destruct (sld _ _ _ _ _ _ _ _ _ _ k fo_gprev ltac:(unfold G_PREV, OSZ; lia) Hk Y5 ltac:(tmp0))
      as (v5 & L5 & -> & -> & _).
    destruct (proj1 Hg1 k Hk) as (_ & Q1 & _). rewrite L5 in Q1. destruct (sn_gn _ _ Q1) as (j5 & Hj5 & ->).
    destruct (sst _ _ _ _ _ _ _ _ _ _ j4 fo_gprev ltac:(unfold G_PREV, OSZ; lia) Hj4 Y6 ltac:(tmp0))
      as (w2 & Hw2 & S2 & -> & _).
    tmp_in Hw2. injection Hw2 as <-.
    destruct (gfx_store pool bpg Hpb _ _ _ _ _ Hg1 S2) as (Hg2 & U3);
      [ left; split; [ reflexivity | exists j4; split; [ exact Hj4 | split; [ left; reflexivity | exists j5; auto ] ] ] | ].
    clear Hg1. pose proof (Mem.unchanged_on_trans _ _ _ _ U2 U3) as U4. clear U2 U3.
    (* the first-child fix-up *)
    apply RA.seq_inv in Y2 as [(s7 & lx7 & mx7 & s8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq0 Y7 Xn ].
    apply RA.ret_inv in Y8 as (-> & _).
    apply RA.seq_inv in Y7 as [(s9 & lx9 & mx9 & s10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq0 Y9 Xn ].
    apply RA.set_inv in Y9 as (v1 & _ & -> & -> & _).
    apply RA.if_inv in Y10 as (vc & bc & _ & _ & Y10). destruct bc.
    - apply RA.seq_inv in Y10 as [(s11 & lx11 & mx11 & s12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq0 Y11 Xn ].
      destruct (sld _ _ _ _ _ _ _ _ _ _ k fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hk Y11 ltac:(tmp0))
        as (v2 & _ & -> & -> & _).
      apply RA.if_inv in Y12 as (vc2 & bc2 & _ & _ & Y12). destruct bc2.
      + destruct (st_deref ge _ _ _ _ _ _ _ _ _ Y12) as (b & o & v & w & Hfc & Ev & Hc & S3 & _ & _).
        tmp_in Hfc. injection Hfc as <- <-. pose proof (null_cast ge _ _ _ _ _ Ev Hc) as ->.
        rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in S3 by (rewrite maxu32; unfold G_CHILD; lia).
        destruct (gfx_store pool bpg Hpb _ _ _ _ _ Hg2 S3) as (Hg3 & U5);
          [ right; right; split; [ reflexivity | split; [ reflexivity | left; reflexivity ] ] | ].
        exact (conj Hg3 (Mem.unchanged_on_trans _ _ _ _ U4 U5)).
      + apply RA.seq_inv in Y12 as [(s13 & lx13 & mx13 & s14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq0 Y13 Xn ].
        destruct (sld _ _ _ _ _ _ _ _ _ _ k fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hk Y13 ltac:(tmp0))
          as (v3 & L3 & -> & -> & _).
        destruct (proj1 Hg2 k Hk) as (_ & _ & Q3). rewrite L3 in Q3. destruct (sn_gn _ _ Q3) as (j3 & Hj3 & ->).
        destruct (st_deref ge _ _ _ _ _ _ _ _ _ Y14) as (b & o & v & w & Hfc & Ev & Hc & S3 & _ & _).
        tmp_in Hfc. injection Hfc as <- <-.
        apply RA.ev_temp in Ev. tmp_in Ev. injection Ev as <-. cbn [typeof] in Hc. apply RA.cast_ptr_id in Hc. subst w.
        rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in S3 by (rewrite maxu32; unfold G_CHILD; lia).
        destruct (gfx_store pool bpg Hpb _ _ _ _ _ Hg2 S3) as (Hg3 & U5);
          [ right; right; split; [ reflexivity | split; [ reflexivity | right; exists j3; auto ] ] | ].
        exact (conj Hg3 (Mem.unchanged_on_trans _ _ _ _ U4 U5)).
    - apply RA.skip_inv in Y10 as (-> & _ & _). exact (conj Hg2 U4).
  Qed.

  Lemma bpg16 : Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr G_CHILD)) = G_CHILD.
  Proof. reflexivity. Qed.

  Lemma gstep_l : forall m0 m b z v m', gfx_at pool bpg m -> Mem.unchanged_on (Gkeep pool bpg) m0 m ->
    Mem.store Mint32 m b z v = Some m' -> gstore pool bpg b z v ->
    gfx_at pool bpg m' /\ Mem.unchanged_on (Gkeep pool bpg) m0 m'.
  Proof.
    intros m0 m b z v m' Hg U S W. destruct (gfx_store pool bpg Hpb _ _ _ _ _ Hg S W) as (Hg' & U').
    exact (conj Hg' (Mem.unchanged_on_trans _ _ _ _ U U')).
  Qed.

  (* THE LINK: adding slot k's node under gObjParentGraphNode keeps gfx_at *)
  Lemma gac_ok : forall m k t m' vr, gfx_at pool bpg m -> 0 <= k < NSLOT ->
    eval_funcall function_entry2 ge m (Internal GN.f_geo_add_child) [Vptr bpg Ptrofs.zero; slot_v pool k] t m' vr ->
    gfx_at pool bpg m' /\ Mem.unchanged_on (Gkeep pool bpg) m m'.
  Proof.
    intros m k t m' vr Hg Hk H.
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & _); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params GN.f_geo_add_child] in Hb. injection Hb as <-.
    cbn [fn_body GN.f_geo_add_child] in Hx.
    pose proof (Mem.unchanged_on_refl (Gkeep pool bpg) m) as U.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq0 X1 Xn ].
    apply RA.ret_inv in X2 as (-> & _).
    apply RA.if_inv in X1 as (vc & bc & _ & _ & X1). destruct bc; [ | apply RA.skip_inv in X1 as (-> & _ & _); exact (conj Hg U) ].
    (* childNode->parent = parent *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq0 X3 Xn ].
    destruct (sst _ _ _ _ _ _ _ _ _ _ k fo_gpar ltac:(unfold G_PAR, OSZ; lia) Hk X3 ltac:(tmp0))
      as (w & Hw & S1 & -> & _).
    tmp_in Hw. injection Hw as <-.
    destruct (gstep_l _ _ _ _ _ _ Hg U S1) as (G1 & V1); [ right; left; split; [ reflexivity | exists k; auto ] | ].
    (* parentFirstChild = parent->children *)
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq0 X5 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ fo_gchild X5) as (b0 & o0 & vf & Hp & Lf & -> & -> & _).
    tmp_in Hp. injection Hp as <- <-. rewrite bpg16 in Lf.
    pose proof (proj2 G1) as Hcf. rewrite Lf in Hcf.
    apply RA.if_inv in X6 as (vc2 & bc2 & _ & _ & X6). destruct bc2.
    - (* first child: parent->children = child; child->prev = child->next = child *)
      apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq0 X7 Xn ].
      destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ fo_gchild X7) as (b1 & o1 & w1 & Hp1 & Hw1 & S2 & -> & _).
      tmp_in Hp1. injection Hp1 as <- <-. rewrite bpg16 in S2. tmp_in Hw1. injection Hw1 as <-.
      destruct (gstep_l _ _ _ _ _ _ G1 V1 S2) as (G2 & V2); [ right; right; split; [ reflexivity | split; [ reflexivity | right; exists k; auto ] ] | ].
      apply RA.seq_inv in X8 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Xn)]; [ | kill_sq0 X9 Xn ].
      destruct (sst _ _ _ _ _ _ _ _ _ _ k fo_gprev ltac:(unfold G_PREV, OSZ; lia) Hk X9 ltac:(tmp0))
        as (w2 & Hw2 & S3 & -> & _).
      tmp_in Hw2. injection Hw2 as <-.
      destruct (gstep_l _ _ _ _ _ _ G2 V2 S3) as (G3 & V3); [ left; split; [ reflexivity | exists k; split; [ exact Hk | split; [ left; reflexivity | exists k; auto ] ] ] | ].
      destruct (sst _ _ _ _ _ _ _ _ _ _ k fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hk X10 ltac:(tmp0))
        as (w3 & Hw3 & S4 & -> & _).
      tmp_in Hw3. injection Hw3 as <-.
      destruct (gstep_l _ _ _ _ _ _ G3 V3 S4) as (G4 & V4); [ left; split; [ reflexivity | exists k; split; [ exact Hk | split; [ right; reflexivity | exists k; auto ] ] ] | ].
      exact (conj G4 V4).
    - (* append before the first child *)
      apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq0 X7 Xn ].
      destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ fo_gprev X7) as (b1 & o1 & vl & Hp1 & Ll & -> & -> & _).
      tmp_in Hp1. injection Hp1 as Evf. subst vf.
      destruct Hcf as [Ef | (j1 & Hj1 & Ef)]; [ discriminate Ef | ].
      unfold slot_v in Ef. injection Ef as -> ->.
      rewrite slot_fld in Ll by (exact Hj1 || (unfold G_PREV, OSZ; lia)).
      destruct (proj1 G1 j1 Hj1) as (_ & R1 & _). rewrite Ll in R1. destruct (sn_gn _ _ R1) as (j2 & Hj2 & ->).
      apply RA.seq_inv in X8 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Xn)]; [ | kill_sq0 X9 Xn ].
      destruct (sst _ _ _ _ _ _ _ _ _ _ k fo_gprev ltac:(unfold G_PREV, OSZ; lia) Hk X9 ltac:(tmp0))
        as (w2 & Hw2 & S3 & -> & _).
      tmp_in Hw2. injection Hw2 as <-.
      destruct (gstep_l _ _ _ _ _ _ G1 V1 S3) as (G5 & V5); [ left; split; [ reflexivity | exists k; split; [ exact Hk | split; [ left; reflexivity | exists j2; auto ] ] ] | ].
      apply RA.seq_inv in X10 as [(t11 & le11 & m11 & t12 & X11 & X12) | (X11 & Xn)]; [ | kill_sq0 X11 Xn ].
      destruct (sst _ _ _ _ _ _ _ _ _ _ k fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hk X11 ltac:(tmp0))
        as (w3 & Hw3 & S4 & -> & _).
      tmp_in Hw3. injection Hw3 as <-.
      destruct (gstep_l _ _ _ _ _ _ G5 V5 S4) as (G6 & V6); [ left; split; [ reflexivity | exists k; split; [ exact Hk | split; [ right; reflexivity | exists j1; auto ] ] ] | ].
      apply RA.seq_inv in X12 as [(t13 & le13 & m13 & t14 & X13 & X14) | (X13 & Xn)]; [ | kill_sq0 X13 Xn ].
      destruct (sst _ _ _ _ _ _ _ _ _ _ j1 fo_gprev ltac:(unfold G_PREV, OSZ; lia) Hj1 X13 ltac:(tmp0))
        as (w4 & Hw4 & S5 & -> & _).
      tmp_in Hw4. injection Hw4 as <-.
      destruct (gstep_l _ _ _ _ _ _ G6 V6 S5) as (G7 & V7); [ left; split; [ reflexivity | exists j1; split; [ exact Hj1 | split; [ left; reflexivity | exists k; auto ] ] ] | ].
      destruct (sst _ _ _ _ _ _ _ _ _ _ j2 fo_gnext ltac:(unfold G_NEXT, OSZ; lia) Hj2 X14 ltac:(tmp0))
        as (w5 & Hw5 & S6 & -> & _).
      tmp_in Hw5. injection Hw5 as <-.
      destruct (gstep_l _ _ _ _ _ _ G7 V7 S6) as (G8 & V8); [ left; split; [ reflexivity | exists j2; split; [ exact Hj2 | split; [ right; reflexivity | exists k; auto ] ] ] | ].
      exact (conj G8 V8).
  Qed.
End GEO.

(* ---------------------------------------------------------------------- *)
(* 5. Frames of the walk's memories.                                        *)
(* ---------------------------------------------------------------------- *)
Ltac al4 := unfold OSZ, O_NEXT, O_PREV, NODESZ, hoff in *; Z.div_mod_to_equations; lia.

(* one aligned store leaves every other aligned cell *)
Lemma st_frame : forall m b0 z0 v m', Mem.store Mint32 m b0 z0 v = Some m' -> z0 mod 4 = 0 ->
  forall b z, z mod 4 = 0 -> (b, z) <> (b0, z0) -> ld32 m' b z = ld32 m b z.
Proof.
  intros m b0 z0 v m' Hs H0 b z Hz Hne. unfold ld32. rewrite !CM.load_eq.
  destruct (ld_cases _ _ _ _ _ Hs b z) as [(-> & -> & _) | [L | (-> & Hn & H1 & H2)]];
    [ congruence | exact L | exfalso; Z.div_mod_to_equations; lia ].
Qed.

Lemma ld_keep : forall (P : block -> Z -> Prop) m m' b z v, Mem.unchanged_on P m m' ->
  (forall i, z <= i < z + 4 -> P b i) -> Mem.load Mint32 m b z = Some v -> Mem.load Mint32 m' b z = Some v.
Proof. intros P m m' b z v U HP L. exact (Mem.load_unchanged_on P m m' Mint32 b z v U HP L). Qed.

Lemma ld32_keep : forall (P : block -> Z -> Prop) m m' b z v, Mem.unchanged_on P m m' ->
  (forall i, z <= i < z + 4 -> P b i) -> ld32 m b z = Some v -> ld32 m' b z = Some v.
Proof. intros P m m' b z v U HP L. unfold ld32 in *. rewrite CM.load_eq in *. exact (ld_keep P m m' b z v U HP L). Qed.

Section KEEP.
  Variables pool la fl : block.
  Variable P : block -> Z -> Prop.
  (* P covers every slot's header.next / prev and the two list blocks *)
  Hypothesis HPp : forall j i, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i < j * OSZ + O_PREV + 4 -> P pool i.
  Hypothesis HPl : forall i, P la i.
  Hypothesis HPf : forall i, P fl i.

  Lemma chain_keep : forall m m' E prev l, Mem.unchanged_on P m m' -> chain pool m E prev l -> chain pool m' E prev l.
  Proof.
    intros m m' E prev l U. revert prev. induction l as [|k l IH]; intros prev Hc; [ exact I | ].
    destruct Hc as (Hk & Lp & Ln & Hc).
    refine (conj Hk (conj _ (conj _ (IH _ Hc)))).
    - apply (ld32_keep P m m' _ _ _ U); [ intros i Hi; apply (HPp k i Hk); unfold O_PREV, O_NEXT in *; lia | exact Lp ].
    - apply (ld32_keep P m m' _ _ _ U); [ intros i Hi; apply (HPp k i Hk); unfold O_PREV, O_NEXT in *; lia | exact Ln ].
  Qed.

  Lemma fchain_keep : forall m m' l, Mem.unchanged_on P m m' -> fchain pool m l -> fchain pool m' l.
  Proof.
    intros m m' l U. induction l as [|k l IH]; intros Hc; [ exact I | ].
    destruct Hc as (Hk & Ln & Hc). refine (conj Hk (conj _ (IH Hc))).
    apply (ld32_keep P m m' _ _ _ U); [ intros i Hi; apply (HPp k i Hk); unfold O_PREV, O_NEXT in *; lia | exact Ln ].
  Qed.

  Lemma rings_keep : forall m m' rs, pool <> la -> Mem.unchanged_on P m m' ->
    rings m pool la = Some rs -> rings m' pool la = Some rs.
  Proof.
    intros m m' rs Hpl U H. apply (rings_iff pool m la rs Hpl) in H as (Hl & Hn).
    apply (rings_iff pool m' la rs Hpl). split; [ exact Hl | intros i Hi ].
    destruct (Hn i Hi) as (L1 & Hc & L2 & Hw). unfold ring_enc.
    refine (conj _ (conj (chain_keep m m' _ _ _ U Hc) (conj _ Hw))).
    - exact (ld32_keep P m m' _ _ _ U (fun i _ => HPl i) L1).
    - exact (ld32_keep P m m' _ _ _ U (fun i _ => HPl i) L2).
  Qed.

  Lemma free_keep : forall m m' fs, Mem.unchanged_on P m m' ->
    free_list m pool fl = Some fs -> free_list m' pool fl = Some fs.
  Proof.
    intros m m' fs U H. apply (free_list_iff pool m fl fs) in H as (L & Hc & Hn).
    apply (free_list_iff pool m' fl fs).
    exact (conj (ld32_keep P m m' _ _ _ U (fun i _ => HPf i) L) (conj (fchain_keep m m' fs U Hc) Hn)).
  Qed.
End KEEP.

Lemma gfx_keep : forall pool bpg (P : block -> Z -> Prop) m m', Mem.unchanged_on P m m' ->
  (forall b z, GCELL pool bpg b z -> P b z) -> gfx_at pool bpg m -> gfx_at pool bpg m'.
Proof.
  intros pool bpg P m m' U HP (Hg & Hc).
  assert (K : forall j d v, 0 <= j < NSLOT -> G_PREV <= d -> d + 4 <= G_CHILD ->
            Mem.load Mint32 m pool (j * OSZ + d) = Some v -> Mem.load Mint32 m' pool (j * OSZ + d) = Some v).
  { intros j d v Hj H1 H2 L. apply (ld_keep P m m' _ _ _ U); [ | exact L ].
    intros i Hi. apply HP. left. split; [ reflexivity | exists j; split; [ exact Hj | lia ] ]. }
  split.
  - intros k Hk. destruct (Hg k Hk) as (P0 & (j1 & Hj1 & P1) & (j2 & Hj2 & P2)).
    refine (conj (K k G_PAR _ Hk ltac:(unfold G_PAR, G_PREV; lia) ltac:(unfold G_PAR, G_CHILD; lia) P0) (conj _ _)).
    + exists j1. split; [ exact Hj1 | exact (K k G_PREV _ Hk ltac:(unfold G_PREV; lia) ltac:(unfold G_PREV, G_CHILD; lia) P1) ].
    + exists j2. split; [ exact Hj2 | exact (K k G_NEXT _ Hk ltac:(unfold G_PREV, G_NEXT; lia) ltac:(unfold G_NEXT, G_CHILD; lia) P2) ].
  - assert (KC : forall v, Mem.load Mint32 m bpg G_CHILD = Some v -> Mem.load Mint32 m' bpg G_CHILD = Some v).
    { intros v L. apply (ld_keep P m m' _ _ _ U); [ | exact L ]. intros i Hi. apply HP. right. split; [ reflexivity | exact Hi ]. }
    destruct Hc as [Hc | (j & Hj & Hc)]; [ left; exact (KC _ Hc) | right; exists j; split; [ exact Hj | exact (KC _ Hc) ] ].
Qed.

Lemma last_of_rev : forall pool d l,
  last_of pool d l = match rev l with [] => d | j :: _ => sv pool j end.
Proof.
  intros pool d l. destruct l as [|a l'] using rev_ind; [ reflexivity | ].
  rewrite last_of_app, rev_app_distr. reflexivity.
Qed.

Lemma al_h : forall i d, d mod 4 = 0 -> (hoff i + d) mod 4 = 0.
Proof. intros i d Hd. unfold hoff, NODESZ. Z.div_mod_to_equations. lia. Qed.
Lemma al_s : forall j d, d mod 4 = 0 -> (j * OSZ + d) mod 4 = 0.
Proof. intros j d Hd. unfold OSZ. Z.div_mod_to_equations. lia. Qed.

Section NP.
  Local Transparent Archi.ptr64.
  Lemma vnull : Vnullptr = Vint Int.zero.
  Proof. reflexivity. Qed.
End NP.

(* p != NULL on a pointer temp *)
Lemma cmp_null : forall (ge : genv) m T v vc bc,
  sem_binary_operation ge One v (tptr T) (Vint Int.zero) (tptr tvoid) m = Some vc ->
  bool_val vc tint m = Some bc ->
  (v = Vint Int.zero -> bc = false) /\ (forall b o, v = Vptr b o -> bc = true).
Proof.
  intros ge m T v vc bc H Hb. split.
  - intros ->. cbn in H. injection H as <-. cbn in Hb. injection Hb as <-. reflexivity.
  - intros b o ->. cbn in H.
    unfold cmp_ptr in H. cbn in H. repeat match type of H with context [if ?c then _ else _] => destruct c end; cbn in H; try discriminate H.
    injection H as <-. cbn in Hb. injection Hb as <-. reflexivity.
  Qed.

(* ---------------------------------------------------------------------- *)
(* 6. try_allocate_object (spawn_object.c:79-99).                           *)
(* ---------------------------------------------------------------------- *)
Section TRY.
  Variable ge : genv.
  Hypothesis Hce : forall id co, (prog_comp_env GN.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Hypothesis Hcs : forall id co, (prog_comp_env SO.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Notation ON := (Tstruct SO._ObjectNode noattr).
  Notation GT := (Tstruct GN._GraphNode noattr).
  Notation GNO := (Tstruct SO._GraphNodeObject noattr).

  Lemma fo_onext : FO ge SO._ObjectNode SO._next O_NEXT.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env SO.prog)); [ vm_compute; reflexivity | exact Hcs ]. Qed.
  Lemma fo_oprev : FO ge SO._ObjectNode SO._prev O_PREV.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env SO.prog)); [ vm_compute; reflexivity | exact Hcs ]. Qed.
  Lemma fo_ogfx : FO ge SO._ObjectNode SO._gfx 0.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env SO.prog)); [ vm_compute; reflexivity | exact Hcs ]. Qed.
  Lemma fo_node : FO ge SO._GraphNodeObject SO._node 0.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env SO.prog)); [ vm_compute; reflexivity | exact Hcs ]. Qed.

  (* &x->gfx.node is x *)
  Lemma ev_node : forall le m x v b o,
    eval_expr ge empty_env le m
      (Eaddrof (Efield (Efield (Ederef (Etempvar x (tptr ON)) ON) SO._gfx GNO) SO._node GT) (tptr GT)) v ->
    le ! x = Some (Vptr b o) -> v = Vptr b o.
  Proof.
    intros le m x v b o H Hx.
    inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
      [ | match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end ].
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (fo_node _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
      [ | match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end ].
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (fo_ogfx _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    match goal with H1 : le ! x = Some _, H2 : le ! x = Some _ |- _ => rewrite H1 in H2; injection H2; intros; subst end.
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero. reflexivity.
  Qed.

  Variables pool la fl bpg : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hpf : pool <> fl.
  Hypothesis Hlf : la <> fl.
  Hypothesis Hpb : pool <> bpg.
  Hypothesis Hlb : la <> bpg.
  Hypothesis Hfb : fl <> bpg.
  Hypothesis Hbpg : Genv.find_symbol ge SO._gObjParentGraphNode = Some bpg.
  Hypothesis Hgrc : forall b fd, Genv.find_symbol ge SO._geo_remove_child = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal GN.f_geo_remove_child.
  Hypothesis Hgac : forall b fd, Genv.find_symbol ge SO._geo_add_child = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal GN.f_geo_add_child.
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  (* the list link cells: a slot's header.next / prev, the list heads, the free list *)
  Definition RCELL (b : block) (z : Z) : Prop :=
    (b = pool /\ exists j, 0 <= j < NSLOT /\ j * OSZ + O_NEXT <= z < j * OSZ + O_PREV + 4) \/ b = la \/ b = fl.
  (* what the allocation keeps: everything but the graph and list link cells *)
  Definition AKEEP (b : block) (z : Z) : Prop := Gkeep pool bpg b z /\ ~ RCELL b z.

  Lemma st_blk : forall m b z v m' b' z', Mem.store Mint32 m b z v = Some m' -> b' <> b ->
    ld32 m' b' z' = ld32 m b' z'.
  Proof.
    intros m b z v m' b' z' Hs Hb. unfold ld32. rewrite !CM.load_eq.
    apply (Mem.load_store_other _ _ _ _ _ _ Hs). left. exact Hb.
  Qed.

  Lemma st_same : forall m b z v m', Mem.store Mint32 m b z v = Some m' ->
    ld32 m' b z = Some (Val.load_result Mint32 v).
  Proof. intros m b z v m' Hs. unfold ld32. rewrite CM.load_eq. exact (Mem.load_store_same _ _ _ _ _ _ Hs). Qed.

  Lemma st_fr : forall b z m b0 z0 v m', Mem.store Mint32 m b0 z0 v = Some m' -> z0 mod 4 = 0 ->
    z mod 4 = 0 -> (b, z) <> (b0, z0) -> ld32 m' b z = ld32 m b z.
  Proof. intros b z m b0 z0 v m' Hs H0 Hz Hne. exact (st_frame m b0 z0 v m' Hs H0 b z Hz Hne). Qed.

  Lemma st_unch : forall (Q : block -> Z -> Prop) m b z v m', Mem.store Mint32 m b z v = Some m' ->
    (forall i, z <= i < z + 4 -> Q b i) -> Mem.unchanged_on (fun b z => ~ Q b z) m m'.
  Proof.
    intros Q m b z v m' Hs HQ. apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs).
    intros i Hi Hn. apply Hn. apply HQ. exact Hi.
  Qed.

  Lemma ev_gpar : forall le m v,
    eval_expr ge empty_env le m (Eaddrof (Evar SO._gObjParentGraphNode GT) (tptr GT)) v -> v = Vptr bpg Ptrofs.zero.
  Proof.
    intros le m v H. inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
      destruct (RA.lv_gvar ge empty_env m le _ _ _ _ _ (PTree.gempty _ _) Hl) as (Hs & -> & _) end.
    rewrite Hbpg in Hs. injection Hs as ->. reflexivity.
  Qed.

  Lemma gc_nrc : forall b z, GCELL pool bpg b z -> ~ RCELL b z.
  Proof.
    intros b z [(-> & j & Hj & Hz) | (-> & Hz)] [(Eb & j' & Hj' & Hz') | [Eb | Eb]];
      try congruence; unfold G_PREV, G_CHILD, O_NEXT, O_PREV, OSZ, NSLOT in *; lia.
  Qed.

  Lemma rc_gk : forall j i, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i < j * OSZ + O_PREV + 4 -> Gkeep pool bpg pool i.
  Proof.
    intros j i Hj Hi [(_ & j' & Hj' & Hz) | (E & _)]; [ | exact (Hpb E) ].
    unfold G_PREV, G_CHILD, O_NEXT, O_PREV, OSZ, NSLOT in *; lia.
  Qed.

  (* THE ALLOCATOR: the real try_allocate_object(&gObjectLists[i]-as-head,
     &gFreeObjectList) either finds the free list empty (NULL, memory
     unchanged) or pops its head k into the tail of ring i *)
  Theorem try_alloc_ok : forall m rs fs i t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_at pool bpg m -> (i < NLIST)%nat ->
    eval_funcall function_entry2 ge m (Internal SO.f_try_allocate_object)
      [Vptr la (Ptrofs.repr (hoff i)); Vptr fl Ptrofs.zero] t m' vr ->
    (fs = [] /\ vr = Vint Int.zero /\ m' = m)
    \/ (exists k fs', fs = k :: fs' /\ vr = slot_v pool k
        /\ rings m' pool la = Some (upd rs i (nth i rs [] ++ [k])) /\ free_list m' pool fl = Some fs'
        /\ gfx_at pool bpg m' /\ Mem.unchanged_on AKEEP m m').
  Proof.
    intros m rs fs i t m' vr Hr Hf Hnd Hg Hi H.
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & Hov); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params SO.f_try_allocate_object] in Hb. injection Hb as <-.
    cbn [fn_body fn_return SO.f_try_allocate_object] in Hx, Hov.
    pose proof Hf as Hf0. apply (free_list_iff pool m fl fs) in Hf0 as (F0 & Fc & Flen).
    unfold ld32 in F0. rewrite CM.load_eq in F0.
    (* the common prefix: nextObj = t'1 = freeList->next *)
    assert (PRE : forall s t1 le1 m1 out1,
      xs (PTree.set SO._freeList (Vptr fl Ptrofs.zero) (PTree.set SO._destList (Vptr la (Ptrofs.repr (hoff i)))
            (create_undef_temps (fn_temps SO.f_try_allocate_object)))) m
         (Ssequence (Ssequence (Ssequence
            (Sset SO._t'5 (Efield (Ederef (Etempvar SO._freeList (tptr ON)) ON) SO._next (tptr ON)))
            (Sset SO._t'1 (Ecast (Etempvar SO._t'5 (tptr ON)) (tptr ON))))
            (Sset SO._nextObj (Etempvar SO._t'1 (tptr ON)))) s) t1 le1 m1 out1 ->
      exists t2, xs (PTree.set SO._nextObj (fnext pool fs) (PTree.set SO._t'1 (fnext pool fs)
            (PTree.set SO._t'5 (fnext pool fs) (PTree.set SO._freeList (Vptr fl Ptrofs.zero)
            (PTree.set SO._destList (Vptr la (Ptrofs.repr (hoff i)))
            (create_undef_temps (fn_temps SO.f_try_allocate_object))))))) m s t2 le1 m1 out1).
    { intros s t1 le1 m1 out1 X.
      apply RA.seq_inv in X as [(u1 & lu1 & mu1 & u2 & P1 & P2) | (P1 & Xn)]; [ | kill_sq0 P1 Xn ].
      apply RA.seq_inv in P1 as [(u3 & lu3 & mu3 & u4 & P3 & P4) | (P3 & Xn)]; [ | kill_sq0 P3 Xn ].
      apply RA.seq_inv in P3 as [(u5 & lu5 & mu5 & u6 & P5 & P6) | (P5 & Xn)]; [ | kill_sq0 P5 Xn ].
      destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ fo_onext P5) as (b0 & o0 & v0 & Hy0 & L0 & -> & -> & _).
      tmp_in Hy0. injection Hy0 as <- <-.
      rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in L0 by (rewrite maxu32; unfold O_NEXT; lia).
      rewrite F0 in L0. injection L0 as <-.
      apply RA.set_inv in P6 as (v1 & Ev1 & -> & -> & _).
      apply RA.ev_cast in Ev1 as (v2 & Ev2 & C2). apply RA.ev_temp in Ev2. tmp_in Ev2. injection Ev2 as <-.
      cbn [typeof] in C2. apply RA.cast_ptr_id in C2. subst v1.
      apply RA.set_inv in P4 as (v3 & Ev3 & -> & -> & _).
      apply RA.ev_temp in Ev3. tmp_in Ev3. injection Ev3 as <-.
      exists u2. exact P2. }
    (* the test t'1 != NULL *)
    assert (COND : forall le1 m1 vc bc,
      eval_expr ge empty_env le1 m1
        (Ebinop One (Etempvar SO._t'1 (tptr ON)) (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint) vc ->
      bool_val vc tint m1 = Some bc -> le1 ! SO._t'1 = Some (fnext pool fs) ->
      bc = match fs with [] => false | _ => true end).
    { intros le1 m1 vc bc Ec Bc Ht.
      apply RA.ev_binop in Ec as (c1 & c2 & Ec1 & Ec2 & Ecmp).
      apply RA.ev_temp in Ec1. rewrite Ht in Ec1. injection Ec1 as <-.
      apply RA.ev_cast in Ec2 as (c3 & Ec3 & C3). apply RA.ev_const in Ec3. subst c3.
      cbn in C3. injection C3 as <-. cbn [typeof] in Ecmp.
      destruct (cmp_null ge m1 _ _ _ _ Ecmp Bc) as (Z0 & Z1).
      destruct fs as [|k fs']; [ exact (Z0 vnull) | exact (Z1 _ _ eq_refl) ]. }
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & XA & XB) | (XA & Xo)].
    2: { (* the prefix returned: the empty list *)
      destruct (PRE _ _ _ _ _ XA) as (t3 & XI).
      apply RA.if_inv in XI as (vc & bc & Ec & Bc & XI).
      rewrite (COND _ _ _ _ Ec Bc ltac:(tmp0)) in XI.
      destruct fs as [|k fs'].
      - apply RA.ret_inv in XI as (-> & v & Ev & ->). left.
        apply RA.ev_cast in Ev as (c3 & Ec3 & C3). apply RA.ev_const in Ec3. subst c3.
        cbn in C3. injection C3 as <-. cbn in Hov. destruct Hov as (_ & Hov). cbn in Hov. injection Hov as <-.
        auto.
      - kill_sq0 XI Xo. }
    destruct (PRE _ _ _ _ _ XA) as (t3 & XI).
    apply RA.if_inv in XI as (vc & bc & Ec & Bc & XI).
    rewrite (COND _ _ _ _ Ec Bc ltac:(tmp0)) in XI.
    destruct fs as [|k fs'].
    { apply RA.ret_inv in XI as (_ & vr0 & _ & E). discriminate E. }
    right. exists k, fs'. split; [ reflexivity | ].
    destruct Fc as (Hk & Fk & Fc). unfold fnext in XI, XB, Hov.
    pose proof Hr as Hr0. apply (rings_iff pool m la rs Hpl) in Hr0 as (Hlen & Henc).
    destruct (Henc i Hi) as (E1 & Ec0 & E2 & Ew).
    set (l := nth i rs []) in *. set (HH := Vptr la (Ptrofs.repr (hoff i))) in *.
    assert (Hkr : ~ In k (concat rs)) by (intros X; exact (nodup_app_disj _ _ k Hnd X (or_introl eq_refl))).
    assert (Hkl : ~ In k l) by (intros X; exact (Hkr (nth_in_concat rs i k X))).
    pose proof (hoff_range i Hi) as Hho. unfold hoff, NLIST, NODESZ in Hho.
    (* the tail cell *)
    assert (TC : (fst (tail_cell pool la i l) = la /\ snd (tail_cell pool la i l) = hoff i + O_NEXT
                  /\ last_of pool HH l = HH)
              \/ (exists j, In j l /\ 0 <= j < NSLOT /\ j <> k /\ tail_cell pool la i l = (pool, j * OSZ + O_NEXT)
                  /\ last_of pool HH l = sv pool j)).
    { rewrite last_of_rev. unfold tail_cell. destruct (rev l) as [|j r] eqn:Er; [ left; auto | right ].
      assert (Hj : In j l) by (apply in_rev; rewrite Er; left; reflexivity).
      exists j. split; [ exact Hj | split; [ exact (chain_range pool m _ _ _ Ec0 j Hj) | split; [ | auto ] ] ].
      intros ->. exact (Hkl Hj). }
    assert (Hhp : forall d, 0 <= d < NODESZ ->
      Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr (hoff i)) (Ptrofs.repr d)) = hoff i + d).
    { intros d Hd. apply uadd0; unfold hoff, NODESZ, NLIST in *; rewrite ?maxu32 in *; lia. }
    (* S1: freeList->next = nextObj->next *)
    apply RA.seq_inv in XI as [(s1 & l1 & n1 & s2 & B1 & B2) | (B1 & Xn)]; [ | kill_sq0 B1 Xn ].
    apply RA.seq_inv in B1 as [(s3 & l3 & n3 & s4 & B3 & B4) | (B3 & Xn)]; [ | kill_sq0 B3 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ fo_onext B3) as (b0 & o0 & v4 & Hy0 & L0 & -> & -> & _).
    tmp_in Hy0. unfold sv, slot_v in Hy0. injection Hy0 as <- <-.
    rewrite slot_fld in L0 by (exact Hk || (unfold O_NEXT, OSZ; lia)).
    unfold ld32 in Fk. rewrite CM.load_eq in Fk. rewrite Fk in L0. injection L0 as <-.
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ fo_onext B4) as (b1 & o1 & w1 & Hy1 & Hw1 & S1 & -> & _).
    tmp_in Hy1. injection Hy1 as <- <-. tmp_in Hw1. injection Hw1 as <-.
    rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in S1 by (rewrite maxu32; unfold O_NEXT; lia).
    (* S2: nextObj->prev = destList->prev *)
    apply RA.seq_inv in B2 as [(s5 & l5 & n5 & s6 & B5 & B6) | (B5 & Xn)]; [ | kill_sq0 B5 Xn ].
    apply RA.seq_inv in B5 as [(s7 & l7 & n7 & s8 & B7 & B8) | (B7 & Xn)]; [ | kill_sq0 B7 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ fo_oprev B7) as (b2 & o2 & v3 & Hy2 & L2 & -> & -> & _).
    tmp_in Hy2. injection Hy2 as <- <-. rewrite Hhp in L2 by (unfold O_PREV, NODESZ; lia).
    assert (E2' : ld32 n1 la (hoff i + O_PREV) = Some (last_of pool HH l)) by (rewrite (st_blk _ _ _ _ _ _ _ S1 Hlf); exact E2).
    unfold ld32 in E2'. rewrite CM.load_eq in E2'. rewrite E2' in L2. injection L2 as <-.
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ fo_oprev B8) as (b3 & o3 & w3 & Hy3 & Hw3 & S2 & -> & _).
    tmp_in Hy3. unfold sv, slot_v in Hy3. injection Hy3 as <- <-. tmp_in Hw3. injection Hw3 as <-.
    rewrite slot_fld in S2 by (exact Hk || (unfold O_PREV, OSZ; lia)).
    (* S3: nextObj->next = destList *)
    apply RA.seq_inv in B6 as [(s9 & l9 & n9 & s10 & B9 & B10) | (B9 & Xn)]; [ | kill_sq0 B9 Xn ].
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ fo_onext B9) as (b4 & o4 & w4 & Hy4 & Hw4 & S3 & -> & _).
    tmp_in Hy4. unfold sv, slot_v in Hy4. injection Hy4 as <- <-. tmp_in Hw4. injection Hw4 as <-.
    rewrite slot_fld in S3 by (exact Hk || (unfold O_NEXT, OSZ; lia)).
    (* S4: destList->prev->next = nextObj *)
    apply RA.seq_inv in B10 as [(s11 & l11 & n11 & s12 & B11 & B12) | (B11 & Xn)]; [ | kill_sq0 B11 Xn ].
    apply RA.seq_inv in B11 as [(s13 & l13 & n13 & s14 & B13 & B14) | (B13 & Xn)]; [ | kill_sq0 B13 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ fo_oprev B13) as (b5 & o5 & v2 & Hy5 & L5 & -> & -> & _).
    tmp_in Hy5. injection Hy5 as <- <-. rewrite Hhp in L5 by (unfold O_PREV, NODESZ; lia).
    assert (E2'' : ld32 n9 la (hoff i + O_PREV) = Some (last_of pool HH l)).
    { rewrite (st_blk _ _ _ _ _ _ _ S3 (not_eq_sym Hpl)), (st_blk _ _ _ _ _ _ _ S2 (not_eq_sym Hpl)).
      unfold ld32. rewrite CM.load_eq. exact E2'. }
    unfold ld32 in E2''. rewrite CM.load_eq in E2''. rewrite E2'' in L5. injection L5 as <-.
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ fo_onext B14) as (b6 & o6 & w6 & Hy6 & Hw6 & S4 & -> & _).
    tmp_in Hy6. tmp_in Hw6. injection Hw6 as <-.
    assert (S4' : Mem.store Mint32 n9 (fst (tail_cell pool la i l)) (snd (tail_cell pool la i l)) (sv pool k) = Some n11).
    { destruct TC as [(T1 & T2 & T3) | (j & Hjl & Hj & Hjk & T1 & T2)].
      - rewrite T1, T2. rewrite T3 in Hy6. unfold HH in Hy6. injection Hy6 as <- <-.
        rewrite Hhp in S4 by (unfold O_NEXT, NODESZ; lia). exact S4.
      - rewrite T1. rewrite T2 in Hy6. unfold sv, slot_v in Hy6. injection Hy6 as <- <-.
        rewrite slot_fld in S4 by (exact Hj || (unfold O_NEXT, OSZ; lia)). exact S4. }
    clear S4.
    (* S5: destList->prev = nextObj *)
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ fo_oprev B12) as (b7 & o7 & w7 & Hy7 & Hw7 & S5 & -> & _).
    tmp_in Hy7. injection Hy7 as <- <-. tmp_in Hw7. injection Hw7 as <-.
    rewrite Hhp in S5 by (unfold O_PREV, NODESZ; lia).
    (* the five stored values, read back at the end of the surgery *)
    set (tc := tail_cell pool la i l) in *.
    assert (TF : snd tc mod 4 = 0 /\ tc <> (pool, k * OSZ + O_PREV) /\ tc <> (pool, k * OSZ + O_NEXT)
                 /\ tc <> (la, hoff i + O_PREV) /\ fst tc <> fl
                 /\ (fst tc = la \/ (fst tc = pool /\ exists j, 0 <= j < NSLOT /\ snd tc = j * OSZ + O_NEXT))).
    { destruct TC as [(T1 & T2 & _) | (j & Hjl & Hj & Hjk & T1 & _)].
      - destruct tc as [tb tz]. cbn [fst snd] in T1, T2 |- *. subst tb tz.
        refine (conj (al_h i O_NEXT eq_refl) (conj _ (conj _ (conj _ (conj (fun E => Hlf E) (or_introl eq_refl)))))).
        + intros E; injection E; intros; congruence.
        + intros E; injection E; intros; congruence.
        + intros E; injection E; intros; unfold O_NEXT, O_PREV in *; lia.
      - rewrite T1. cbn [fst snd].
        refine (conj (al_s j O_NEXT eq_refl) (conj _ (conj _ (conj _ (conj Hpf (or_intror (conj eq_refl (ex_intro _ j (conj Hj eq_refl))))))))).
        + intros E; injection E; intros; unfold OSZ, O_NEXT, O_PREV in *; lia.
        + intros E; injection E; intros; unfold OSZ, O_NEXT in *; apply Hjk; lia.
        + intros E; injection E; intros; congruence. }
    destruct TF as (TFa & TFb & TFc & TFd & TFe & TFf).
    assert (Hfn : Val.load_result Mint32 (fnext pool fs') = fnext pool fs')
      by (destruct fs'; cbn [fnext]; [ rewrite vnull | ]; reflexivity).
    assert (Hlo : Val.load_result Mint32 (last_of pool HH l) = last_of pool HH l)
      by (destruct TC as [(_ & _ & ->) | (j & _ & _ & _ & _ & ->)]; reflexivity).
    pose proof (al_s k O_PREV eq_refl) as Ak1.
    pose proof (al_s k O_NEXT eq_refl) as Ak2.
    pose proof (al_h i O_PREV eq_refl) as Ah.
    assert (L1 : ld32 m1 fl O_NEXT = Some (fnext pool fs')).
    { rewrite (st_blk _ _ _ _ _ _ _ S5 (not_eq_sym Hlf)), (st_blk _ _ _ _ _ _ _ S4' (not_eq_sym TFe)),
        (st_blk _ _ _ _ _ _ _ S3 (not_eq_sym Hpf)), (st_blk _ _ _ _ _ _ _ S2 (not_eq_sym Hpf)), (st_same _ _ _ _ _ S1), Hfn.
      reflexivity. }
    assert (L2 : ld32 m1 pool (k * OSZ + O_PREV) = Some (last_of pool HH l)).
    { rewrite (st_blk _ _ _ _ _ _ _ S5 Hpl), (st_fr pool _ _ _ _ _ _ S4' TFa Ak1 (fun E => TFb (eq_trans (surjective_pairing tc) (eq_sym E)))),
        (st_fr pool _ _ _ _ _ _ S3 Ak2 Ak1 ltac:(intros E; injection E; intros; unfold O_PREV, O_NEXT in *; lia)),
        (st_same _ _ _ _ _ S2), Hlo.
      reflexivity. }
    assert (L3 : ld32 m1 pool (k * OSZ + O_NEXT) = Some HH).
    { rewrite (st_blk _ _ _ _ _ _ _ S5 Hpl), (st_fr pool _ _ _ _ _ _ S4' TFa Ak2 (fun E => TFc (eq_trans (surjective_pairing tc) (eq_sym E)))),
        (st_same _ _ _ _ _ S3). reflexivity. }
    assert (L5 : ld32 m1 la (hoff i + O_PREV) = Some (sv pool k)) by (rewrite (st_same _ _ _ _ _ S5); reflexivity).
    assert (L4 : ld32 m1 (fst tc) (snd tc) = Some (sv pool k)).
    { rewrite (st_fr (fst tc) (snd tc) _ _ _ _ _ S5 Ah TFa ltac:(rewrite <- surjective_pairing; exact TFd)),
        (st_same _ _ _ _ _ S4'). reflexivity. }
    assert (AF : alloc_frame pool la fl m m1 i l k).
    { intros b z Hz Hn. unfold alloc_cells in Hn. fold tc in Hn.
      assert (N : forall c, In c [(fl, O_NEXT); (pool, k * OSZ + O_PREV); (pool, k * OSZ + O_NEXT); (la, hoff i + O_PREV); tc] ->
                  (b, z) <> c) by (intros c Hc E; subst c; exact (Hn Hc)).
      rewrite (st_fr b z _ _ _ _ _ S5 Ah Hz (N (la, hoff i + O_PREV) ltac:(cbn; tauto))).
      rewrite (st_fr b z _ _ _ _ _ S4' TFa Hz ltac:(rewrite <- surjective_pairing; exact (N tc ltac:(cbn; tauto)))).
      rewrite (st_fr b z _ _ _ _ _ S3 Ak2 Hz (N (pool, k * OSZ + O_NEXT) ltac:(cbn; tauto))).
      rewrite (st_fr b z _ _ _ _ _ S2 Ak1 Hz (N (pool, k * OSZ + O_PREV) ltac:(cbn; tauto))).
      exact (st_fr b z _ _ _ _ _ S1 eq_refl Hz (N (fl, O_NEXT) ltac:(cbn; tauto))). }
    destruct (alloc_rings pool la fl Hpl Hpf Hlf m m1 rs fs' k i Hr Hf Hnd Hi L1 L2 L3 L5 L4 AF) as (R1 & F1).
    (* the surgery touched only list link cells *)
    assert (RCk : forall d, (d = O_NEXT \/ d = O_PREV) -> forall z, k * OSZ + d <= z < k * OSZ + d + 4 -> RCELL pool z).
    { intros d Hd z Hz. left. split; [ reflexivity | exists k; split; [ exact Hk | unfold O_NEXT, O_PREV in *; lia ] ]. }
    assert (UR : Mem.unchanged_on (fun b z => ~ RCELL b z) m m1).
    { apply (Mem.unchanged_on_trans _ _ n1); [ exact (st_unch RCELL _ _ _ _ _ S1 (fun z _ => or_intror (or_intror eq_refl))) | ].
      apply (Mem.unchanged_on_trans _ _ n5); [ exact (st_unch RCELL _ _ _ _ _ S2 (RCk O_PREV (or_intror eq_refl))) | ].
      apply (Mem.unchanged_on_trans _ _ n9); [ exact (st_unch RCELL _ _ _ _ _ S3 (RCk O_NEXT (or_introl eq_refl))) | ].
      apply (Mem.unchanged_on_trans _ _ n11); [ | exact (st_unch RCELL _ _ _ _ _ S5 (fun z _ => or_intror (or_introl eq_refl))) ].
      apply (st_unch RCELL _ _ _ _ _ S4'). intros z Hz.
      destruct TFf as [-> | (-> & j & Hj & Ej)]; [ right; left; reflexivity | ].
      left. split; [ reflexivity | exists j; split; [ exact Hj | rewrite Ej in Hz; unfold O_NEXT, O_PREV in *; lia ] ]. }
    pose proof (gfx_keep pool bpg _ m m1 UR gc_nrc Hg) as G1.
    (* geo_remove_child(&nextObj->gfx.node) *)
    apply RA.seq_inv in XB as [(c1 & lc1 & mc1 & c2 & C1 & C2) | (C1 & Xn)]; [ | kill_sq0 C1 Xn ].
    apply RA.call_inv in C1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->) end.
    rewrite (Hgrc bf fd Hs Hff) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & Ea1 & -> & Ev1 & Cc1). injection Ea1 as <-.
    rewrite (ev_node _ _ _ _ _ _ Ev1 ltac:(tmp0)) in Cc1.
    cbn [typeof] in Cc1. apply RA.cast_ptr_id in Cc1. subst w1.
    destruct (grc_ok ge Hce pool bpg Hpb _ k _ _ _ G1 Hk Hc) as (G2 & U2).
    (* geo_add_child(&gObjParentGraphNode, &nextObj->gfx.node) *)
    apply RA.seq_inv in C2 as [(c3 & lc3 & mc3 & c4 & C3 & C4) | (C3 & Xn)]; [ | kill_sq0 C3 Xn ].
    apply RA.call_inv in C3 as (tya2 & tyr2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hc2 & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ => destruct (RA.ev_fun ge empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf2 & Hs2 & ->) end.
    rewrite (Hgac bf2 fd2 Hs2 Hff2) in Hc2.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal2) as (ta & tb & u1 & u2 & x1 & x2 & Ea2 & -> & Eva & Cca & Evb & Ccb).
    injection Ea2 as <- <-.
    rewrite (ev_gpar _ _ _ Eva) in Cca. cbn [typeof] in Cca. apply RA.cast_ptr_id in Cca. subst x1.
    rewrite (ev_node _ _ _ _ _ _ Evb ltac:(tmp0)) in Ccb. cbn [typeof] in Ccb. apply RA.cast_ptr_id in Ccb. subst x2.
    destruct (gac_ok ge Hce pool bpg Hpb _ k _ _ _ G2 Hk Hc2) as (G3 & U3).
    (* return (struct Object * ) nextObj *)
    apply RA.ret_inv in C4 as (-> & v & Ev & ->).
    apply RA.ev_cast in Ev as (v0 & Ev0 & Cv). apply RA.ev_temp in Ev0. tmp_in Ev0. injection Ev0 as <-.
    cbn [typeof] in Cv. apply RA.cast_ptr_id in Cv. subst v.
    cbn in Hov. destruct Hov as (_ & Hov). injection Hov as <-.
    pose proof (Mem.unchanged_on_trans _ _ _ _ U2 U3) as UG.
    assert (HPl : forall z, Gkeep pool bpg la z) by (intros z [(E & _) | (E & _)]; [ exact (Hpl (eq_sym E)) | exact (Hlb E) ]).
    assert (HPf : forall z, Gkeep pool bpg fl z) by (intros z [(E & _) | (E & _)]; [ exact (Hpf (eq_sym E)) | exact (Hfb E) ]).
    split; [ reflexivity | split; [ | split; [ | split ] ] ].
    - exact (rings_keep pool la _ rc_gk HPl _ _ _ Hpl UG R1).
    - exact (free_keep pool fl _ rc_gk HPf _ _ _ UG F1).
    - exact G3.
    - apply (Mem.unchanged_on_trans _ _ m1).
      + apply (Mem.unchanged_on_implies _ _ _ _ UR). intros b z (_ & Hn) _. exact Hn.
      + apply (Mem.unchanged_on_implies _ _ _ _ UG). intros b z (Hk' & _) _. exact Hk'.
  Qed.
End TRY.

(* ---------------------------------------------------------------------- *)
(* 7. On the real linked program.                                           *)
(* ---------------------------------------------------------------------- *)
Lemma dm_grc : (prog_defmap GN.prog) ! SO._geo_remove_child = Some (Gfun (Internal GN.f_geo_remove_child)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_gac : (prog_defmap GN.prog) ! SO._geo_add_child = Some (Gfun (Internal GN.f_geo_add_child)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_tao : (prog_defmap SO.prog) ! SO._try_allocate_object = Some (Gfun (Internal SO.f_try_allocate_object)).
Proof. vm_compute. reflexivity. Qed.

Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  Lemma fun_res : forall q id f, Linking.linkorder q lp -> (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b -> Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof.
    intros q id f Hlo Hdm b fd Hb Hf.
    destruct (linkorder_resolves_internal lp q _ _ Hlo Hdm) as (b' & Hs & Hp).
    unfold lp_ge in Hb. rewrite Hb in Hs. injection Hs as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf. unfold lp_ge in Hf.
    rewrite Hp in Hf. injection Hf as <-. reflexivity.
  Qed.

  Lemma cenv_of : forall q, Linking.linkorder q lp ->
    forall id co, (prog_comp_env q) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof. intros q Hlo id co H. exact (linkorder_comp_env_extends lp q id co Hlo H). Qed.

  Lemma sym_ne : forall x y b1 b2, Genv.find_symbol G x = Some b1 -> Genv.find_symbol G y = Some b2 ->
    x <> y -> b1 <> b2.
  Proof. intros x y b1 b2 Hx Hy Hne E. subst b2. apply Hne. eapply Genv.genv_vars_inj; [ exact Hx | exact Hy ]. Qed.

  (* THE ALLOCATOR ON THE REAL PROGRAM: the premises are obj_w's ow_rings,
     ow_free, ow_part (its NoDup half) and ow_gfx -- nothing else *)
  Theorem try_alloc_real : forall pool la fl bpg,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    forall m rs fs i t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> (i < NLIST)%nat ->
    eval_funcall function_entry2 G m (Internal SO.f_try_allocate_object)
      [Vptr la (Ptrofs.repr (hoff i)); Vptr fl Ptrofs.zero] t m' vr ->
    (fs = [] /\ vr = Vint Int.zero /\ m' = m)
    \/ (exists k fs', fs = k :: fs' /\ vr = slot_v pool k
        /\ rings m' pool la = Some (upd rs i (nth i rs [] ++ [k])) /\ free_list m' pool fl = Some fs'
        /\ gfx_ok G pool m' /\ Mem.unchanged_on (AKEEP pool la fl bpg) m m').
  Proof.
    intros pool la fl bpg Hp Hl Hf Hb m rs fs i t m' vr Hr Hfl Hnd Hg Hi H.
    assert (Hpl : pool <> la) by (apply (sym_ne _ _ _ _ Hp Hl); neq0).
    assert (Hpf : pool <> fl) by (apply (sym_ne _ _ _ _ Hp Hf); neq0).
    assert (Hlf : la <> fl) by (apply (sym_ne _ _ _ _ Hl Hf); neq0).
    assert (Hpb : pool <> bpg) by (apply (sym_ne _ _ _ _ Hp Hb); neq0).
    assert (Hlb : la <> bpg) by (apply (sym_ne _ _ _ _ Hl Hb); neq0).
    assert (Hfb : fl <> bpg) by (apply (sym_ne _ _ _ _ Hf Hb); neq0).
    pose proof (gfx_at_iff pool bpg Hpb G m Hb) as Ig.
    destruct (try_alloc_ok G (cenv_of _ (linked12_LO_graph_node lp H12)) (cenv_of _ (linked12_LO_spawn_object lp H12))
                pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb Hb
                (fun b fd => fun_res _ _ _ (linked12_LO_graph_node lp H12) dm_grc b fd)
                (fun b fd => fun_res _ _ _ (linked12_LO_graph_node lp H12) dm_gac b fd)
                m rs fs i t m' vr Hr Hfl Hnd (proj1 Ig Hg) Hi H) as [A | (k & fs' & E & Ev & R & F & Gx & U)].
    - left. exact A.
    - right. exists k, fs'. refine (conj E (conj Ev (conj R (conj F (conj _ U))))).
      exact (proj2 (gfx_at_iff pool bpg Hpb G m' Hb) Gx).
  Qed.

  (* the call by name: gObjectLists' i-th head and &gFreeObjectList *)
  Lemma tao_fun : forall b fd, Genv.find_symbol G SO._try_allocate_object = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SO.f_try_allocate_object.
  Proof. exact (fun_res _ _ _ (linked12_LO_spawn_object lp H12) dm_tao). Qed.
End LINKED.
