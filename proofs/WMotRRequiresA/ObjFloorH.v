(* ====================================================================== *)
(* spine (via BhvStep's row 30): OBJECTS -- DROP_TO_FLOOR's callee,       *)
(* find_floor_height (surface_collision.c), run by its real body:         *)
(*   struct Surface *floor;                                              *)
(*   return find_floor(x, y, z, &floor);                                 *)
(* ffh_foot: the run changes no cell of the entry memory outside the      *)
(* three static cells find_floor writes (FloorList.ff_statics), changes   *)
(* no permission of the entry memory, and returns a float.  The local     *)
(* `floor` is allocated fresh and freed.  find_floor is run on its real   *)
(* body through FloorList.ff_value_contract.                              *)
(* What it needs of the entry memory (ff_ok): the statics and the two     *)
(* partition arrays are allocated, and every list head a partition array  *)
(* holds is a well-formed list whose nodes are not the statics.  These    *)
(* are facts of the object phase's invariant (ObjWorld's surface clause:  *)
(* every partition list walks the sSurfaceNodePool), to be read off it    *)
(* when the loop invariant is fixed; nothing about the run is assumed.    *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA Require Import FloorList.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.

Module RA := RenderAnim.
Module SC := SM64.Generated.surface_collision.

Local Ltac idne' := let HH := fresh in intro HH; cbv in HH; discriminate HH.

(* what find_floor needs of the entry memory *)
Definition ff_ok (ge : genv) (m : mem) : Prop :=
  (forall b, is_static ge b -> Mem.valid_block m b)
  /\ (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> Mem.valid_block m bp)
  /\ (forall hd, part_head ge m hd -> wf_list m (is_static ge) hd).

(* the cells find_floor_height keeps: every allocated non-static cell *)
Definition ns (ge : genv) (m : mem) (b : block) (_ : Z) : Prop :=
  Mem.valid_block m b /\ ~ is_static ge b.

Lemma part_ns : forall (ge : genv) id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
  ~ is_static ge bp.
Proof.
  intros ge id bp Hin Hs (id2 & Hin2 & Hs2).
  assert (Hne : id <> id2).
  { unfold part_ids in Hin. unfold ff_statics in Hin2. cbn [In] in Hin, Hin2.
    destruct Hin as [<- | [<- | []]]; destruct Hin2 as [<- | [<- | [<- | []]]]; idne'. }
  exact (Genv.global_addresses_distinct ge Hne Hs Hs2 eq_refl).
Qed.

Lemma cells_static : forall (ge : genv) id sz b, In (id, sz) ff_cells ->
  Genv.find_symbol ge id = Some b -> is_static ge b.
Proof.
  intros ge id sz b Hin Hs. exists id. split; [ | exact Hs ].
  unfold ff_cells in Hin. unfold ff_statics. cbn [In] in Hin |- *.
  destruct Hin as [E | [E | [E | []]]]; injection E as <- <-; auto.
Qed.

(* a well-formed list survives a step that keeps its old blocks *)
Lemma wf_list_move' : forall m m1 (A A1 : block -> Prop) hd, wf_list m A hd ->
  (forall b, Mem.valid_block m b -> Mem.valid_block m1 b) ->
  (forall ch b z, Mem.valid_block m b -> Mem.load ch m1 b z = Mem.load ch m b z) ->
  (forall b, Mem.valid_block m b -> ~ A b -> ~ A1 b) -> wf_list m1 A1 hd.
Proof.
  intros m m1 A A1 hd W HV HL HA. induction W as [| bn on nx Hv Hav Hld W IH]; [ constructor | ].
  eapply wf_cons; [ exact (HV _ Hv) | exact (HA _ Hv Hav) | | exact IH ].
  cbn [Mem.loadv] in *. rewrite (HL _ _ _ Hv). exact Hld.
Qed.

Theorem ffh_foot : forall (ge : genv), cenv_has ge -> ffl_pinned ge ->
  (forall b fd, Genv.find_symbol ge SC._find_floor = Some b ->
     Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SC.f_find_floor) ->
  forall m xv yv zv t m' vres, ff_ok ge m ->
  eval_funcall function_entry2 ge m (Internal SC.f_find_floor_height) [xv; yv; zv] t m' vres ->
  Mem.unchanged_on (ns ge m) m m'
  /\ (forall b i k p, Mem.valid_block m b -> (Mem.perm m b i k p <-> Mem.perm m' b i k p))
  /\ exists h, vres = Vsingle h.
Proof.
  intros ge HC Hpin Hffr m xv yv zv t m' vres (Hsv & Hpv & Hwf) H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [SC.f_find_floor_height fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with A1 : Mem.alloc m 0 _ = (?M1, ?b1) |- _ =>
    rename b1 into bF, A1 into HA, M1 into mA end.
  assert (HnF : ~ Mem.valid_block m bF) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA).
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return SC.f_find_floor_height] in Ho; destruct (orv_single _ _ _ Ho) as (h & ->) end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into X0 end.
  cbn [fn_body SC.f_find_floor_height] in X0.
  apply RA.seq_inv in X0 as [(q1 & qe1 & qm1 & q2 & X1 & X2) | (X1 & Xn)];
    [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X1 eq_refl)) ].
  apply RA.seq_inv in X1 as [(q3 & qe3 & qm3 & q4 & X3 & X4) | (X3 & Xn)];
    [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X3 eq_refl)) ].
  apply RA.set_inv in X4 as (v4 & _ & -> & -> & _).
  apply RA.ret_inv in X2 as (-> & _).
  apply RA.call_inv in X3 as (tya & tyr & cc & vf & vargs & fd & vr1 & Hcf & Evf & Eal & Hff & _ & Hcall & _ & _).
  cbn in Hcf. injection Hcf as <- <- <-.
  match type of Evf with eval_expr _ ?E _ _ (Evar _ ?ty) _ =>
    assert (He0 : E ! SC._find_floor = None) by (rewrite PTree.gso by idne'; apply PTree.gempty);
    destruct (RA.ev_fun ge E mA _ _ ty vf He0 eq_refl Evf) as (bf & Hsf & ->) end.
  rewrite (Hffr bf fd Hsf Hff) in Hcall.
  (* the arguments: x, y, z and &floor = (bF, 0) *)
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  match goal with Hl : eval_exprlist _ _ _ _ [] _ _ |- _ => inv Hl end.
  match goal with Ea : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv Ea end;
    try (match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end).
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  all: match goal with Hg : (PTree.set _ _ _) ! _ = _ |- _ => rewrite PTree.gss in Hg end.
  2: discriminate.
  match goal with Hg : Some (bF, _) = Some (?y, _) |- _ => injection Hg; intros; subst y end.
  match goal with Hc : sem_cast (Vptr _ _) _ _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  (* find_floor's contract, with the local and the statics avoided *)
  destruct (ff_value_contract ge (fun b => is_static ge b \/ b = bF) HC Hpin mA _ _ _ bF Ptrofs.zero _ _ _
              (or_intror eq_refl) (Mem.valid_new_block _ _ _ _ _ HA)
              (fun b Hs => conj (or_introl Hs) (fun E => HnF (eq_ind b _ (Hsv b Hs) bF E)))
              (fun id bp Hin Hs => conj (Mem.valid_block_alloc _ _ _ _ _ HA _ (Hpv id bp Hin Hs))
                 (fun Ha => match Ha with
                            | or_introl Hst => part_ns ge id bp Hin Hs Hst
                            | or_intror E => HnF (eq_ind bp _ (Hpv id bp Hin Hs) bF E)
                            end))
              ltac:(intros hd (id & bp & o & Hin & Hs & Hl);
                    assert (Hvp : Mem.valid_block m bp) by exact (Hpv id bp Hin Hs);
                    assert (Hph : part_head ge m hd)
                      by (exists id, bp, o; split; [ exact Hin | split; [ exact Hs | ] ];
                          cbn [Mem.loadv] in Hl |- *;
                          rewrite <- (Mem.load_alloc_unchanged _ _ _ _ _ HA _ _ _ Hvp); exact Hl);
                    apply (wf_list_move' m mA (is_static ge) _ hd (Hwf hd Hph));
                    [ exact (Mem.valid_block_alloc _ _ _ _ _ HA)
                    | intros ch b z Hv; exact (Mem.load_alloc_unchanged _ _ _ _ _ HA ch b z Hv)
                    | intros b Hv Hn [Hs' | ->]; [ exact (Hn Hs') | exact (HnF Hv) ] ])
              Hcall) as (fl & _ & _ & (U & Hperm) & _ & _).
  (* the local is freed *)
  match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
    change (Mem.free_list M [(bF, 0, 4)] = Some R) in Hf; cbn [Mem.free_list] in Hf;
    destruct (Mem.free M bF 0 4) as [M5 |] eqn:F1; [ injection Hf as <- | discriminate Hf ] end.
  split; [ | split; [ | exists h; reflexivity ] ].
  - eapply Mem.unchanged_on_trans; [ eapply Mem.alloc_unchanged_on; exact HA | ].
    eapply Mem.unchanged_on_trans.
    + eapply Mem.unchanged_on_implies; [ exact U | ].
      intros b i (Hv & Hns) _. split; [ exact (Mem.valid_block_alloc _ _ _ _ _ HA _ Hv) | ].
      intros [(-> & _) | (id & sz & Hin & Hs & _)]; [ exact (HnF Hv) | ].
      exact (Hns (cells_static ge id sz b Hin Hs)).
    + eapply Mem.free_unchanged_on; [ exact F1 | ].
      intros i _ (Hv & _). exact (HnF Hv).
  - intros b i k p Hv.
    assert (NF : b <> bF) by (intros ->; exact (HnF Hv)).
    assert (HvA : Mem.valid_block mA b) by exact (Mem.valid_block_alloc _ _ _ _ _ HA _ Hv).
    split; intro HH.
    + eapply Mem.perm_free_1; [ exact F1 | left; exact NF | ].
      apply (Hperm b i k p HvA). eapply Mem.perm_alloc_1; [ exact HA | exact HH ].
    + eapply Mem.perm_alloc_4; [ exact HA | | exact NF ].
      apply (Hperm b i k p HvA). eapply Mem.perm_free_3; [ exact F1 | exact HH ].
Qed.

(* a three-argument list, inverted *)
Lemma exl3 : forall (G : genv) e le m a1 a2 a3 tys vs, eval_exprlist G e le m [a1; a2; a3] tys vs ->
  exists ty1 ty2 ty3 v1 v2 v3 w1 w2 w3, tys = [ty1; ty2; ty3] /\ vs = [w1; w2; w3]
    /\ eval_expr G e le m a1 v1 /\ sem_cast v1 (typeof a1) ty1 m = Some w1
    /\ eval_expr G e le m a2 v2 /\ sem_cast v2 (typeof a2) ty2 m = Some w2
    /\ eval_expr G e le m a3 v3 /\ sem_cast v3 (typeof a3) ty3 m = Some w3.
Proof.
  intros G e le m a1 a2 a3 tys vs H. inv H.
  match goal with Hx : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hx end.
  match goal with Hx : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hx end.
  match goal with Hx : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hx end. eauto 30.
Qed.
