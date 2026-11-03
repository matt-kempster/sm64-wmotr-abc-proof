(* kept: groundwork for BhvStep's Hobj_unload row (deallocate step); no
   spine consumer yet -- unload_object's other calls (sound stop, geo
   relink, respawn bits) are still open. *)
(* OBJECTS -- the DEALLOCATOR, the mirror of ObjRing's tail insert and of
   ObjAlloc.try_alloc_ok.  deallocate_object (spawn_object.c:119-127)
     obj->next->prev = obj->prev;  obj->prev->next = obj->next;
     obj->next = freeList->next;   freeList->next = obj;
   unlinks slot k from its ring (l1 ++ k :: l2 becomes l1 ++ l2) and pushes
   it on the free list (fs becomes k :: fs).
     - dealloc_rings : the surgery on ObjWorld.rings / free_list, from the
       four link-cell values and a frame on every other aligned word;
     - dealloc_ok    : the real Clight body, walked statement by statement,
       produces exactly that surgery and changes only list link cells
       (ObjAlloc.RCELL);
     - dealloc_real  : on the linked program, from obj_w's ow_rings /
       ow_free / ow_part (NoDup) alone; gfx_ok rides through.
   Statements only mention ObjWorld's, ObjRing's and ObjAlloc's
   definitions. *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require spawn_object object_list_processor area.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.

Lemma next_of_app_gen : forall pool E l1 l2,
  next_of pool E (l1 ++ l2) = next_of pool (next_of pool E l2) l1.
Proof. intros pool E [|a l1] l2; reflexivity. Qed.

Lemma last_of_app_gen : forall pool d l1 l2,
  last_of pool d (l1 ++ l2) = last_of pool (last_of pool d l1) l2.
Proof. intros pool d l1. revert d. induction l1 as [|a l1 IH]; intros d l2; [ reflexivity | exact (IH _ l2) ]. Qed.

(* a chain splits at any point *)
Lemma chain_split : forall pool m E prev l1 l2,
  chain pool m E prev (l1 ++ l2) <->
  chain pool m (next_of pool E l2) prev l1 /\ chain pool m E (last_of pool prev l1) l2.
Proof.
  intros pool m E prev l1. revert prev. induction l1 as [|a l1 IH]; intros prev l2.
  - cbn. tauto.
  - cbn [app chain last_of]. rewrite next_of_app_gen, IH. tauto.
Qed.

Lemma rev_last : forall (l : list Z) j r, rev l = j :: r -> l = rev r ++ [j].
Proof. intros l j r E. apply (f_equal (@rev Z)) in E. rewrite rev_involutive in E. exact E. Qed.

Section DEALLOC.
  Variables pool la fl : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hpf : pool <> fl.
  Hypothesis Hlf : la <> fl.

  (* the predecessor's next cell (the head's when k is first) and the
     successor's prev cell (the head's when k is last) *)
  Definition pred_cell (i : nat) (l1 : list Z) : block * Z :=
    match rev l1 with [] => (la, hoff i + O_NEXT) | j :: _ => (pool, j * OSZ + O_NEXT) end.
  Definition succ_cell (i : nat) (l2 : list Z) : block * Z :=
    match l2 with [] => (la, hoff i + O_PREV) | j :: _ => (pool, j * OSZ + O_PREV) end.

  Definition dealloc_cells (i : nat) (l1 l2 : list Z) (k : Z) : list (block * Z) :=
    [pred_cell i l1; succ_cell i l2; (pool, k * OSZ + O_NEXT); (fl, O_NEXT)].

  Definition dealloc_frame (m m' : mem) (i : nat) (l1 l2 : list Z) (k : Z) : Prop :=
    forall b z, z mod 4 = 0 -> ~ In (b, z) (dealloc_cells i l1 l2 k) -> ld32 m' b z = ld32 m b z.

  Lemma dealloc_rings : forall m m' rs fs i l1 k l2,
    rings m pool la = Some rs -> free_list m pool fl = Some fs ->
    NoDup (concat rs ++ fs) -> (i < NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 ->
    let H := Vptr la (Ptrofs.repr (hoff i)) in
    ld32 m' (fst (pred_cell i l1)) (snd (pred_cell i l1)) = Some (next_of pool H l2) ->
    ld32 m' (fst (succ_cell i l2)) (snd (succ_cell i l2)) = Some (last_of pool H l1) ->
    ld32 m' pool (k * OSZ + O_NEXT) = Some (fnext pool fs) ->
    ld32 m' fl O_NEXT = Some (sv pool k) ->
    dealloc_frame m m' i l1 l2 k ->
    rings m' pool la = Some (upd rs i (l1 ++ l2)) /\ free_list m' pool fl = Some (k :: fs).
  Proof.
    intros m m' rs fs i l1 k l2 Hr Hf Hnd Hi El H Lp Ls Lk Lf HF.
    apply (rings_iff pool m la rs Hpl) in Hr as (Hlen & Henc).
    apply (free_list_iff pool m fl fs) in Hf as (F0 & Fc & Flen).
    assert (Hnd_r : NoDup (concat rs)) by exact (NoDup_app_remove_r _ _ Hnd).
    assert (Hli : forall x, In x (nth i rs []) -> In x (concat rs)) by (intros x Hx; exact (nth_in_concat rs i x Hx)).
    assert (Hndl : NoDup (l1 ++ k :: l2)) by (rewrite <- El; exact (nodup_nth rs i Hnd_r)).
    assert (Hk_r : In k (concat rs)) by (apply Hli; rewrite El; apply in_or_app; right; left; reflexivity).
    assert (Hrf : forall x, In x (concat rs) -> ~ In x fs)
      by (intros x X1 X2; exact (nodup_app_disj _ _ x Hnd X1 X2)).
    assert (Hk1 : ~ In k l1) by (intros X; apply NoDup_remove_2 in Hndl; apply Hndl; apply in_or_app; left; exact X).
    assert (Hk2 : ~ In k l2) by (intros X; apply NoDup_remove_2 in Hndl; apply Hndl; apply in_or_app; right; exact X).
    assert (H12 : forall x, In x l1 -> ~ In x l2).
    { intros x X1 X2. apply NoDup_remove_1 in Hndl. exact (nodup_app_disj _ _ x Hndl X1 X2). }
    destruct (Henc i Hi) as (Hn0 & Hc0 & Hp0 & Hl0). rewrite El in Hn0, Hc0, Hp0, Hl0. fold H in Hn0, Hc0, Hp0.
    apply chain_split in Hc0 as (Hc1 & Hc2). cbn [chain] in Hc2. destruct Hc2 as (Hk & Pk & Nk & Hc2).
    (* frame: a pool link cell of a slot that is none of the written ones *)
    assert (Fp : forall x off, (off = O_PREV \/ off = O_NEXT) -> x <> k ->
               (pool, x * OSZ + off) <> pred_cell i l1 -> (pool, x * OSZ + off) <> succ_cell i l2 ->
               ld32 m' pool (x * OSZ + off) = ld32 m pool (x * OSZ + off)).
    { intros x off Ho Hxk N1 N2. apply HF; [ unfold OSZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; md4 | ].
      unfold dealloc_cells. intros Hin. cbn [In] in Hin.
      destruct Hin as [E | [E | [E | [E | []]]]]; try (exact (N1 (eq_sym E))); try (exact (N2 (eq_sym E)));
        injection E; intros; first [ congruence | unfold OSZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; lia ]. }
    (* frame: a head cell of ring j *)
    assert (Fh : forall j off, (j < NLIST)%nat -> (off = O_PREV \/ off = O_NEXT) ->
               (la, hoff j + off) <> pred_cell i l1 -> (la, hoff j + off) <> succ_cell i l2 ->
               ld32 m' la (hoff j + off) = ld32 m la (hoff j + off)).
    { intros j off Hj Ho N1 N2. apply HF; [ unfold hoff, NODESZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; md4 | ].
      unfold dealloc_cells. intros Hin. cbn [In] in Hin.
      destruct Hin as [E | [E | [E | [E | []]]]]; try (exact (N1 (eq_sym E))); try (exact (N2 (eq_sym E)));
        injection E; intros; congruence. }
    (* the written cells are pool cells of ring-i slots or ring i's head cells *)
    assert (Pnot : forall x off, (pool, x * OSZ + off) = pred_cell i l1 -> (off = O_PREV \/ off = O_NEXT) ->
               off = O_NEXT /\ exists r, rev l1 = x :: r).
    { intros x off E Ho. unfold pred_cell in E. destruct (rev l1) as [|j r] eqn:Er; [ injection E; intros; congruence | ].
      injection E; intros E1. unfold OSZ, O_PREV, O_NEXT in *.
      assert (x = j /\ off = 96) as [-> ->] by (destruct Ho as [-> | ->]; lia). split; [ reflexivity | eauto ]. }
    assert (Snot : forall x off, (pool, x * OSZ + off) = succ_cell i l2 -> (off = O_PREV \/ off = O_NEXT) ->
               off = O_PREV /\ exists r, l2 = x :: r).
    { intros x off E Ho. unfold succ_cell in E. destruct l2 as [|j r]; [ injection E; intros; congruence | ].
      injection E; intros E1. unfold OSZ, O_PREV, O_NEXT in *.
      assert (x = j /\ off = 100) as [-> ->] by (destruct Ho as [-> | ->]; lia). split; [ reflexivity | eauto ]. }
    assert (HPnot : forall j off, (la, hoff j + off) = pred_cell i l1 -> (j < NLIST)%nat -> (off = O_PREV \/ off = O_NEXT) ->
               j = i /\ off = O_NEXT /\ l1 = []).
    { intros j off E Hj Ho. unfold pred_cell in E. destruct (rev l1) as [|j' r] eqn:Er; [ | injection E; intros; congruence ].
      injection E; intros E1. unfold hoff, NODESZ, O_PREV, O_NEXT, NLIST in *.
      assert (j = i /\ off = 96) as [-> ->] by (destruct Ho as [-> | ->]; nia).
      split; [ reflexivity | split; [ reflexivity | ] ]. destruct l1 as [|a l1']; [ reflexivity | ].
      apply (f_equal (@List.length Z)) in Er. rewrite rev_length in Er. discriminate Er. }
    assert (HSnot : forall j off, (la, hoff j + off) = succ_cell i l2 -> (j < NLIST)%nat -> (off = O_PREV \/ off = O_NEXT) ->
               j = i /\ off = O_PREV /\ l2 = []).
    { intros j off E Hj Ho. unfold succ_cell in E. destruct l2 as [|j' r]; [ | injection E; intros; congruence ].
      injection E; intros E1. unfold hoff, NODESZ, O_PREV, O_NEXT, NLIST in *.
      assert (j = i /\ off = 100) as [-> ->] by (destruct Ho as [-> | ->]; nia).
      split; [ reflexivity | split; reflexivity ]. }
    (* a slot of another ring, or of the free list, keeps both link cells *)
    assert (Fo : forall x off, (off = O_PREV \/ off = O_NEXT) -> ~ In x (l1 ++ k :: l2) ->
               ld32 m' pool (x * OSZ + off) = ld32 m pool (x * OSZ + off)).
    { intros x off Ho Hx. apply Fp; [ exact Ho | intros ->; apply Hx; apply in_or_app; right; left; reflexivity | | ].
      - intros E. destruct (Pnot x off E Ho) as (_ & r & Er). apply Hx. apply in_or_app. left.
        apply in_rev. rewrite Er. left. reflexivity.
      - intros E. destruct (Snot x off E Ho) as (_ & r & ->). apply Hx. apply in_or_app. right. right. left. reflexivity. }
    split.
    - apply (rings_iff pool m' la _ Hpl). rewrite upd_length. split; [ exact Hlen | ].
      intros j Hj. destruct (Nat.eq_dec j i) as [-> | Hji].
      + rewrite upd_nth_eq by (rewrite Hlen; exact Hi). fold H.
        (* the new chain: l1 with its last next re-aimed, l2 with its first prev re-aimed *)
        assert (Hc1' : chain pool m' (next_of pool H l2) H l1).
        { destruct (rev l1) as [|j r] eqn:Er.
          - apply (f_equal (@rev Z)) in Er. rewrite rev_involutive in Er. cbn in Er. rewrite Er. exact I.
          - rewrite (rev_last _ _ _ Er) in Hc1 |- *. apply chain_app in Hc1 as (Hc1 & Hj0 & Pj & Nj).
            apply chain_app. split; [ | split; [ exact Hj0 | split ] ].
            + apply (chain_ext pool m m' _ _ _ Hc1). intros x Hx.
              assert (Hxl : In x l1) by (rewrite (rev_last _ _ _ Er); apply in_or_app; left; exact Hx).
              assert (Hxj : x <> j).
              { intros ->. pose proof (NoDup_remove_1 _ _ _ Hndl) as N1. apply NoDup_app_remove_r in N1.
                rewrite (rev_last _ _ _ Er) in N1. apply NoDup_remove_2 in N1. rewrite app_nil_r in N1. exact (N1 Hx). }
              assert (Hxk : x <> k) by (intros ->; exact (Hk1 Hxl)).
              split; apply Fp; first [ left; reflexivity | right; reflexivity | exact Hxk | idtac ].
              * intros E. destruct (Pnot x _ E ltac:(left; reflexivity)) as (X & _). unfold O_PREV, O_NEXT in X. lia.
              * intros E. destruct (Snot x _ E ltac:(left; reflexivity)) as (_ & r' & E2). apply (H12 x Hxl). rewrite E2. left. reflexivity.
              * intros E. destruct (Pnot x _ E ltac:(right; reflexivity)) as (_ & r' & E2).
                revert E2. rewrite ?Er, ?rev_app_distr. cbn [rev app]. intros E2. injection E2; intros; congruence.
              * intros E. destruct (Snot x _ E ltac:(right; reflexivity)) as (X & _). unfold O_PREV, O_NEXT in X. lia.
            + assert (Hjl : In j l1) by (rewrite (rev_last _ _ _ Er); apply in_or_app; right; left; reflexivity).
              rewrite Fp; [ exact Pj | left; reflexivity | intros ->; exact (Hk1 Hjl) | | ].
              * intros E. destruct (Pnot j _ E ltac:(left; reflexivity)) as (X & _). unfold O_PREV, O_NEXT in X. lia.
              * intros E. destruct (Snot j _ E ltac:(left; reflexivity)) as (_ & r' & E2). apply (H12 j Hjl). rewrite E2. left. reflexivity.
            + unfold pred_cell in Lp. rewrite Er in Lp. cbn [fst snd] in Lp. exact Lp. }
        assert (Hc2' : chain pool m' H (last_of pool H l1) l2).
        { destruct l2 as [|j r]; [ exact I | ].
          cbn [chain] in Hc2 |- *. destruct Hc2 as (Hj0 & Pj & Nj & Hc2).
          assert (Hjk : j <> k) by (intros ->; apply Hk2; left; reflexivity).
          assert (Hjl : ~ In j l1) by (intros X; exact (H12 j X (or_introl eq_refl))).
          refine (conj Hj0 (conj _ (conj _ _))).
          - unfold succ_cell in Ls. cbn [fst snd] in Ls. exact Ls.
          - rewrite Fp; [ exact Nj | right; reflexivity | exact Hjk | | ].
            + intros E. destruct (Pnot j _ E ltac:(right; reflexivity)) as (_ & r' & E2). apply Hjl. apply in_rev. rewrite E2. left. reflexivity.
            + intros E. destruct (Snot j _ E ltac:(right; reflexivity)) as (X & _). unfold O_PREV, O_NEXT in X. lia.
          - apply (chain_ext pool m m' _ _ _ Hc2). intros x Hx.
            assert (Hxk : x <> k) by (intros ->; apply Hk2; right; exact Hx).
            assert (Hxl : ~ In x l1) by (intros X; exact (H12 x X (or_intror Hx))).
            assert (Hxj : x <> j).
            { intros ->. pose proof (NoDup_remove_1 _ _ _ Hndl) as N1. apply NoDup_app_remove_l in N1.
              inversion N1; contradiction. }
            split; apply Fp; first [ left; reflexivity | right; reflexivity | exact Hxk | idtac ].
            + intros E. destruct (Pnot x _ E ltac:(left; reflexivity)) as (X & _). unfold O_PREV, O_NEXT in X. lia.
            + intros E. destruct (Snot x _ E ltac:(left; reflexivity)) as (_ & r' & E2). injection E2; intros; congruence.
            + intros E. destruct (Pnot x _ E ltac:(right; reflexivity)) as (_ & r' & E2). apply Hxl. apply in_rev. rewrite E2. left. reflexivity.
            + intros E. destruct (Snot x _ E ltac:(right; reflexivity)) as (X & _). unfold O_PREV, O_NEXT in X. lia. }
        refine (conj _ (conj (proj2 (chain_split pool m' H H l1 l2) (conj Hc1' Hc2')) (conj _ _))).
        * (* head.next *)
          destruct l1 as [|a l1'] eqn:E1.
          -- unfold pred_cell in Lp. cbn in Lp. exact Lp.
          -- cbn [app next_of] in Hn0 |- *. rewrite Fh; [ exact Hn0 | exact Hi | right; reflexivity | | ].
             ++ intros E. destruct (HPnot i _ E Hi ltac:(right; reflexivity)) as (_ & _ & X). discriminate X.
             ++ intros E. destruct (HSnot i _ E Hi ltac:(right; reflexivity)) as (_ & X & _). unfold O_PREV, O_NEXT in X. lia.
        * (* head.prev *)
          destruct l2 as [|a l2'] eqn:E2.
          -- rewrite app_nil_r. unfold succ_cell in Ls. cbn in Ls. exact Ls.
          -- rewrite last_of_app_gen in Hp0 |- *. cbn [last_of] in Hp0 |- *.
             rewrite Fh; [ exact Hp0 | exact Hi | left; reflexivity | | ].
             ++ intros E. destruct (HPnot i _ E Hi ltac:(left; reflexivity)) as (_ & X & _). unfold O_PREV, O_NEXT in X. lia.
             ++ intros E. destruct (HSnot i _ E Hi ltac:(left; reflexivity)) as (_ & _ & X). discriminate X.
        * rewrite app_length in Hl0 |- *. cbn [List.length] in Hl0. lia.
      + rewrite upd_nth_ne by exact Hji.
        destruct (Henc j Hj) as (Hn1 & Hcj & Hp1 & Hl1).
        assert (Hdisj : forall x, In x (nth j rs []) -> ~ In x (l1 ++ k :: l2)).
        { intros x Hx X. rewrite <- El in X. exact (nodup_concat_disj rs j i x Hnd_r Hji Hx X). }
        refine (conj _ (conj _ (conj _ Hl1))).
        * rewrite Fh; [ exact Hn1 | exact Hj | right; reflexivity | | ];
            intros E; [ destruct (HPnot j _ E Hj ltac:(right; reflexivity)) as (X & _)
                      | destruct (HSnot j _ E Hj ltac:(right; reflexivity)) as (X & _) ]; contradiction.
        * apply (chain_ext pool m m' _ _ _ Hcj). intros x Hx.
          split; apply Fo; first [ left; reflexivity | right; reflexivity | exact (Hdisj x Hx) ].
        * rewrite Fh; [ exact Hp1 | exact Hj | left; reflexivity | | ];
            intros E; [ destruct (HPnot j _ E Hj ltac:(left; reflexivity)) as (X & _)
                      | destruct (HSnot j _ E Hj ltac:(left; reflexivity)) as (X & _) ]; contradiction.
    - apply (free_list_iff pool m' fl (k :: fs)). split; [ exact Lf | split ].
      + refine (conj Hk (conj Lk _)). apply (fchain_ext pool m m' fs Fc). intros x Hx.
        apply Fo; [ right; reflexivity | ]. intros X. rewrite <- El in X. exact (Hrf x (Hli x X) Hx).
      + pose proof (slots_len (concat rs ++ fs) Hnd) as Hb.
        assert (Hrng : forall x, In x (concat rs ++ fs) -> 0 <= x < NSLOT).
        { intros x Hx. apply in_app_or in Hx as [Hx | Hx].
          - apply in_concat in Hx as (r & Hr & Hx). apply In_nth with (d := []) in Hr as (j1 & Hj1 & <-).
            rewrite Hlen in Hj1. destruct (Henc j1 Hj1) as (_ & Hcj & _). exact (chain_range pool m _ _ _ Hcj x Hx).
          - exact (fchain_range pool m fs Fc x Hx). }
        specialize (Hb Hrng). rewrite app_length in Hb.
        assert (Hkc : (1 <= List.length (concat rs))%nat) by (destruct (concat rs); [ destruct Hk_r | cbn; lia ]).
        cbn [List.length]. unfold WFUEL. lia.
  Qed.
End DEALLOC.

(* ---------------------------------------------------------------------- *)
(* THE REAL BODY: deallocate_object (spawn_object.c:119-127), walked        *)
(* statement by statement against the generated Clight.                    *)
(* ---------------------------------------------------------------------- *)
Section DREAL.
  Variable ge : genv.
  Hypothesis Hcs : forall id co, (prog_comp_env spawn_object.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Variables pool la fl : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hpf : pool <> fl.
  Hypothesis Hlf : la <> fl.
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  (* THE DEALLOCATOR: the real deallocate_object(&gFreeObjectList, obj) on
     slot k of ring i (l1 ++ k :: l2) unlinks k and pushes it on the free
     list, and changes nothing but list link cells *)
  Theorem dealloc_ok : forall m rs fs i l1 k l2 t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    (i < NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 ->
    eval_funcall function_entry2 ge m (Internal spawn_object.f_deallocate_object)
      [Vptr fl Ptrofs.zero; slot_v pool k] t m' vr ->
    rings m' pool la = Some (upd rs i (l1 ++ l2)) /\ free_list m' pool fl = Some (k :: fs)
    /\ Mem.unchanged_on (fun b z => ~ RCELL pool la fl b z) m m'.
  Proof.
    intros m rs fs i l1 k l2 t m' vr Hr Hf Hnd Hi El H.
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & _); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params spawn_object.f_deallocate_object] in Hb. injection Hb as <-.
    cbn [fn_body spawn_object.f_deallocate_object] in Hx.
    pose proof Hf as Hf0. apply (free_list_iff pool m fl fs) in Hf0 as (F0 & Fc & Flen).
    pose proof Hr as Hr0. apply (rings_iff pool m la rs Hpl) in Hr0 as (Hlen & Henc).
    destruct (Henc i Hi) as (_ & Hc0 & _ & _). rewrite El in Hc0.
    set (HH := Vptr la (Ptrofs.repr (hoff i))) in *.
    apply chain_split in Hc0 as (Hc1 & Hc2). cbn [chain] in Hc2. destruct Hc2 as (Hk & Pk & Nk & Hc2).
    assert (Hnd_r : NoDup (concat rs)) by exact (NoDup_app_remove_r _ _ Hnd).
    assert (Hndl : NoDup (l1 ++ k :: l2)) by (rewrite <- El; exact (nodup_nth rs i Hnd_r)).
    assert (Hk1 : ~ In k l1) by (intros X; apply NoDup_remove_2 in Hndl; apply Hndl; apply in_or_app; left; exact X).
    assert (Hk2 : ~ In k l2) by (intros X; apply NoDup_remove_2 in Hndl; apply Hndl; apply in_or_app; right; exact X).
    pose proof (hoff_range i Hi) as Hho.
    assert (Hhp : forall d, 0 <= d < NODESZ ->
      Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr (hoff i)) (Ptrofs.repr d)) = hoff i + d).
    { intros d Hd. apply uadd0; unfold hoff, NODESZ, NLIST in *; rewrite ?maxu32 in *; lia. }
    (* the predecessor's next cell and the successor's prev cell *)
    set (pc := pred_cell pool la i l1) in *. set (sc := succ_cell pool la i l2) in *.
    assert (PC : (pc = (la, hoff i + O_NEXT) /\ last_of pool HH l1 = HH)
                 \/ (exists j, 0 <= j < NSLOT /\ j <> k /\ pc = (pool, j * OSZ + O_NEXT) /\ last_of pool HH l1 = sv pool j)).
    { unfold pc, pred_cell. rewrite last_of_rev. destruct (rev l1) as [|j r] eqn:Er; [ left; auto | right ].
      assert (Hj : In j l1) by (apply in_rev; rewrite Er; left; reflexivity).
      exists j. split; [ exact (chain_range pool m _ _ _ Hc1 j Hj) | split; [ intros ->; exact (Hk1 Hj) | auto ] ]. }
    assert (SC : (sc = (la, hoff i + O_PREV) /\ next_of pool HH l2 = HH)
                 \/ (exists j, 0 <= j < NSLOT /\ j <> k /\ sc = (pool, j * OSZ + O_PREV) /\ next_of pool HH l2 = sv pool j)).
    { unfold sc, succ_cell. destruct l2 as [|j r]; [ left; auto | right ].
      exists j. split; [ exact (proj1 Hc2) | split; [ intros ->; apply Hk2; left; reflexivity | auto ] ]. }
    assert (Hpcsc : pc <> sc).
    { destruct PC as [(-> & _) | (j1 & _ & _ & -> & _)]; destruct SC as [(-> & _) | (j2 & _ & _ & -> & _)];
        intros E; injection E; intros; first [ congruence | unfold O_NEXT, O_PREV, OSZ in *; lia ]. }
    assert (Apc : snd pc mod 4 = 0) by (destruct PC as [(-> & _) | (j & _ & _ & -> & _)]; cbn [snd];
      [ exact (al_h i O_NEXT eq_refl) | exact (al_s j O_NEXT eq_refl) ]).
    assert (Asc : snd sc mod 4 = 0) by (destruct SC as [(-> & _) | (j & _ & _ & -> & _)]; cbn [snd];
      [ exact (al_h i O_PREV eq_refl) | exact (al_s j O_PREV eq_refl) ]).
    assert (Bpc : fst pc <> fl) by (destruct PC as [(-> & _) | (j & _ & _ & -> & _)]; cbn [fst]; assumption).
    assert (Bsc : fst sc <> fl) by (destruct SC as [(-> & _) | (j & _ & _ & -> & _)]; cbn [fst]; assumption).
    assert (Kpc : forall d, (d = O_NEXT \/ d = O_PREV) -> pc <> (pool, k * OSZ + d)).
    { intros d Hd E. destruct PC as [(Ep & _) | (j & _ & Hjk & Ep & _)]; rewrite Ep in E; injection E; intros;
        first [ congruence | unfold O_NEXT, O_PREV, OSZ in *; destruct Hd as [-> | ->]; apply Hjk; lia ]. }
    assert (Ksc : forall d, (d = O_NEXT \/ d = O_PREV) -> sc <> (pool, k * OSZ + d)).
    { intros d Hd E. destruct SC as [(Ep & _) | (j & _ & Hjk & Ep & _)]; rewrite Ep in E; injection E; intros;
        first [ congruence | unfold O_NEXT, O_PREV, OSZ in *; destruct Hd as [-> | ->]; apply Hjk; lia ]. }
    unfold ld32 in Pk, Nk, F0. rewrite CM.load_eq in Pk, Nk, F0.
    (* t'4 = obj->next; t'5 = obj->prev; t'4->prev = t'5 *)
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & XA & XB) | (XA & Xn)]; [ | kill_sq0 XA Xn ].
    apply RA.seq_inv in XA as [(u1 & lu1 & mu1 & u2 & A1 & A2) | (A1 & Xn)]; [ | kill_sq0 A1 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_onext ge Hcs) A1) as (b0 & o0 & v0 & Hy0 & L0 & -> & -> & _).
    tmp_in Hy0. unfold slot_v in Hy0. injection Hy0 as <- <-.
    rewrite slot_fld in L0 by (exact Hk || (unfold O_NEXT, OSZ; lia)). rewrite Nk in L0. injection L0 as <-.
    apply RA.seq_inv in A2 as [(u3 & lu3 & mu3 & u4 & A3 & A4) | (A3 & Xn)]; [ | kill_sq0 A3 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_oprev ge Hcs) A3) as (b1 & o1 & v1 & Hy1 & L1 & -> & -> & _).
    tmp_in Hy1. injection Hy1 as <- <-.
    rewrite slot_fld in L1 by (exact Hk || (unfold O_PREV, OSZ; lia)). rewrite Pk in L1. injection L1 as <-.
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_oprev ge Hcs) A4) as (b2 & o2 & w2 & Hy2 & Hw2 & S1 & -> & _).
    tmp_in Hy2. tmp_in Hw2. injection Hw2 as <-.
    assert (S1' : Mem.store Mint32 m (fst sc) (snd sc) (last_of pool HH l1) = Some m1).
    { destruct SC as [(Ep & En) | (j & Hj & _ & Ep & En)]; rewrite Ep; cbn [fst snd]; rewrite En in Hy2.
      - unfold HH in Hy2. injection Hy2 as <- <-. rewrite Hhp in S1 by (unfold O_PREV, NODESZ; lia). exact S1.
      - unfold sv, slot_v in Hy2. injection Hy2 as <- <-.
        rewrite slot_fld in S1 by (exact Hj || (unfold O_PREV, OSZ; lia)). exact S1. }
    clear S1.
    (* t'2 = obj->prev; t'3 = obj->next; t'2->next = t'3 *)
    apply RA.seq_inv in XB as [(t3 & le3 & m3 & t4 & XC & XD) | (XC & Xn)]; [ | kill_sq0 XC Xn ].
    apply RA.seq_inv in XC as [(u5 & lu5 & mu5 & u6 & C1 & C2) | (C1 & Xn)]; [ | kill_sq0 C1 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_oprev ge Hcs) C1) as (b3 & o3 & v3 & Hy3 & L3 & -> & -> & _).
    tmp_in Hy3. injection Hy3 as <- <-.
    rewrite slot_fld in L3 by (exact Hk || (unfold O_PREV, OSZ; lia)).
    assert (Pk1 : Mem.load Mint32 m1 pool (k * OSZ + O_PREV) = Some (last_of pool HH l1)).
    { pose proof (st_fr pool (k * OSZ + O_PREV) _ _ _ _ _ S1' Asc (al_s k O_PREV eq_refl)
                    ltac:(intros E; exact (Ksc O_PREV (or_intror eq_refl) (eq_trans (surjective_pairing sc) (eq_sym E))))) as E.
      unfold ld32 in E. rewrite !CM.load_eq in E. rewrite E. exact Pk. }
    rewrite Pk1 in L3. injection L3 as <-.
    apply RA.seq_inv in C2 as [(u7 & lu7 & mu7 & u8 & C3 & C4) | (C3 & Xn)]; [ | kill_sq0 C3 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_onext ge Hcs) C3) as (b4 & o4 & v4 & Hy4 & L4 & -> & -> & _).
    tmp_in Hy4. injection Hy4 as <- <-.
    rewrite slot_fld in L4 by (exact Hk || (unfold O_NEXT, OSZ; lia)).
    assert (Nk1 : Mem.load Mint32 m1 pool (k * OSZ + O_NEXT) = Some (next_of pool HH l2)).
    { pose proof (st_fr pool (k * OSZ + O_NEXT) _ _ _ _ _ S1' Asc (al_s k O_NEXT eq_refl)
                    ltac:(intros E; exact (Ksc O_NEXT (or_introl eq_refl) (eq_trans (surjective_pairing sc) (eq_sym E))))) as E.
      unfold ld32 in E. rewrite !CM.load_eq in E. rewrite E. exact Nk. }
    rewrite Nk1 in L4. injection L4 as <-.
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_onext ge Hcs) C4) as (b5 & o5 & w5 & Hy5 & Hw5 & S2 & -> & _).
    tmp_in Hy5. tmp_in Hw5. injection Hw5 as <-.
    assert (S2' : Mem.store Mint32 m1 (fst pc) (snd pc) (next_of pool HH l2) = Some m3).
    { destruct PC as [(Ep & En) | (j & Hj & _ & Ep & En)]; rewrite Ep; cbn [fst snd]; rewrite En in Hy5.
      - unfold HH in Hy5. injection Hy5 as <- <-. rewrite Hhp in S2 by (unfold O_NEXT, NODESZ; lia). exact S2.
      - unfold sv, slot_v in Hy5. injection Hy5 as <- <-.
        rewrite slot_fld in S2 by (exact Hj || (unfold O_NEXT, OSZ; lia)). exact S2. }
    clear S2.
    (* t'1 = freeList->next; obj->next = t'1; freeList->next = obj *)
    apply RA.seq_inv in XD as [(t5 & le5 & m5 & t6 & XE & XF) | (XE & Xn)]; [ | kill_sq0 XE Xn ].
    apply RA.seq_inv in XE as [(u9 & lu9 & mu9 & u10 & E1 & E2) | (E1 & Xn)]; [ | kill_sq0 E1 Xn ].
    destruct (ldp_set ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_onext ge Hcs) E1) as (b6 & o6 & v6 & Hy6 & L6 & -> & -> & _).
    tmp_in Hy6. injection Hy6 as <- <-.
    rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in L6 by (rewrite maxu32; unfold O_NEXT; lia).
    assert (F1 : Mem.load Mint32 m3 fl O_NEXT = Some (fnext pool fs)).
    { pose proof (st_blk _ _ _ _ _ fl O_NEXT S2' (not_eq_sym Bpc)) as E. pose proof (st_blk _ _ _ _ _ fl O_NEXT S1' (not_eq_sym Bsc)) as E'.
      unfold ld32 in E, E'. rewrite !CM.load_eq in E, E'. rewrite E, E'. exact F0. }
    rewrite F1 in L6. injection L6 as <-.
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_onext ge Hcs) E2) as (b7 & o7 & w7 & Hy7 & Hw7 & S3 & -> & _).
    tmp_in Hy7. unfold slot_v in Hy7. injection Hy7 as <- <-. tmp_in Hw7. injection Hw7 as <-.
    rewrite slot_fld in S3 by (exact Hk || (unfold O_NEXT, OSZ; lia)).
    destruct (stp ge _ _ _ _ _ _ _ _ _ _ _ _ (fo_onext ge Hcs) XF) as (b8 & o8 & w8 & Hy8 & Hw8 & S4 & -> & _).
    tmp_in Hy8. injection Hy8 as <- <-. tmp_in Hw8. injection Hw8 as <-.
    rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in S4 by (rewrite maxu32; unfold O_NEXT; lia).
    (* the four stored values, read back *)
    pose proof (al_s k O_NEXT eq_refl) as Ak.
    assert (Hlo : Val.load_result Mint32 (last_of pool HH l1) = last_of pool HH l1)
      by (destruct PC as [(_ & ->) | (j & _ & _ & _ & ->)]; reflexivity).
    assert (Hno : Val.load_result Mint32 (next_of pool HH l2) = next_of pool HH l2)
      by (destruct SC as [(_ & ->) | (j & _ & _ & _ & ->)]; reflexivity).
    assert (Hfn : Val.load_result Mint32 (fnext pool fs) = fnext pool fs)
      by (destruct fs; cbn [fnext]; [ rewrite vnull | ]; reflexivity).
    assert (Lp : ld32 m' (fst pc) (snd pc) = Some (next_of pool HH l2)).
    { rewrite (st_blk _ _ _ _ _ (fst pc) (snd pc) S4 Bpc).
      rewrite (st_fr (fst pc) (snd pc) _ _ _ _ _ S3 Ak Apc
                 ltac:(rewrite <- surjective_pairing; exact (Kpc O_NEXT (or_introl eq_refl)))).
      rewrite (st_same _ _ _ _ _ S2'), Hno. reflexivity. }
    assert (Ls : ld32 m' (fst sc) (snd sc) = Some (last_of pool HH l1)).
    { rewrite (st_blk _ _ _ _ _ (fst sc) (snd sc) S4 Bsc).
      rewrite (st_fr (fst sc) (snd sc) _ _ _ _ _ S3 Ak Asc
                 ltac:(rewrite <- surjective_pairing; exact (Ksc O_NEXT (or_introl eq_refl)))).
      rewrite (st_fr (fst sc) (snd sc) _ _ _ _ _ S2' Apc Asc
                 ltac:(rewrite <- !surjective_pairing; exact (not_eq_sym Hpcsc))).
      rewrite (st_same _ _ _ _ _ S1'), Hlo. reflexivity. }
    assert (Lk : ld32 m' pool (k * OSZ + O_NEXT) = Some (fnext pool fs)).
    { rewrite (st_blk _ _ _ _ _ pool (k * OSZ + O_NEXT) S4 Hpf), (st_same _ _ _ _ _ S3), Hfn. reflexivity. }
    assert (Lf : ld32 m' fl O_NEXT = Some (sv pool k)) by (rewrite (st_same _ _ _ _ _ S4); reflexivity).
    assert (DF : dealloc_frame pool la fl m m' i l1 l2 k).
    { intros b z Hz Hn. unfold dealloc_cells in Hn. fold pc sc in Hn.
      assert (N : forall c, In c [pc; sc; (pool, k * OSZ + O_NEXT); (fl, O_NEXT)] -> (b, z) <> c)
        by (intros c Hc E; subst c; exact (Hn Hc)).
      rewrite (st_fr b z _ _ _ _ _ S4 eq_refl Hz (N (fl, O_NEXT) ltac:(cbn; tauto))).
      rewrite (st_fr b z _ _ _ _ _ S3 Ak Hz (N (pool, k * OSZ + O_NEXT) ltac:(cbn; tauto))).
      rewrite (st_fr b z _ _ _ _ _ S2' Apc Hz ltac:(rewrite <- surjective_pairing; exact (N pc ltac:(cbn; tauto)))).
      exact (st_fr b z _ _ _ _ _ S1' Asc Hz ltac:(rewrite <- surjective_pairing; exact (N sc ltac:(cbn; tauto)))). }
    destruct (dealloc_rings pool la fl Hpl Hpf Hlf m m' rs fs i l1 k l2 Hr Hf Hnd Hi El Lp Ls Lk Lf DF) as (R1 & F2).
    split; [ exact R1 | split; [ exact F2 | ] ].
    (* only list link cells changed *)
    assert (RCc : forall c, (c = pc \/ c = sc) -> forall z, snd c <= z < snd c + 4 -> RCELL pool la fl (fst c) z).
    { intros c Hc z Hz. destruct Hc as [-> | ->].
      - destruct PC as [(Ep & _) | (j & Hj & _ & Ep & _)]; rewrite Ep in Hz |- *; cbn [fst snd] in Hz |- *;
          [ right; left; reflexivity | left; split; [ reflexivity | exists j; split; [ exact Hj | unfold O_NEXT, O_PREV in *; lia ] ] ].
      - destruct SC as [(Ep & _) | (j & Hj & _ & Ep & _)]; rewrite Ep in Hz |- *; cbn [fst snd] in Hz |- *;
          [ right; left; reflexivity | left; split; [ reflexivity | exists j; split; [ exact Hj | unfold O_NEXT, O_PREV in *; lia ] ] ]. }
    apply (Mem.unchanged_on_trans _ _ m1); [ exact (st_unch (RCELL pool la fl) _ _ _ _ _ S1' (RCc sc (or_intror eq_refl))) | ].
    apply (Mem.unchanged_on_trans _ _ m3); [ exact (st_unch (RCELL pool la fl) _ _ _ _ _ S2' (RCc pc (or_introl eq_refl))) | ].
    apply (Mem.unchanged_on_trans _ _ m5).
    - apply (st_unch (RCELL pool la fl) _ _ _ _ _ S3). intros z Hz.
      left. split; [ reflexivity | exists k; split; [ exact Hk | unfold O_NEXT, O_PREV in *; lia ] ].
    - exact (st_unch (RCELL pool la fl) _ _ _ _ _ S4 (fun z _ => or_intror (or_intror eq_refl))).
  Qed.
End DREAL.

(* ---------------------------------------------------------------------- *)
(* On the real linked program.                                              *)
(* ---------------------------------------------------------------------- *)
Lemma dm_dao : (prog_defmap spawn_object.prog) ! spawn_object._deallocate_object
  = Some (Gfun (Internal spawn_object.f_deallocate_object)).
Proof. vm_compute. reflexivity. Qed.

Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* THE DEALLOCATOR ON THE REAL PROGRAM: the premises are obj_w's ow_rings,
     ow_free and ow_part's NoDup half; the graph cells (gfx_ok) ride through *)
  Theorem dealloc_real : forall pool la fl bpg,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    forall m rs fs i l1 k l2 t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    (i < NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 ->
    eval_funcall function_entry2 G m (Internal spawn_object.f_deallocate_object)
      [Vptr fl Ptrofs.zero; slot_v pool k] t m' vr ->
    rings m' pool la = Some (upd rs i (l1 ++ l2)) /\ free_list m' pool fl = Some (k :: fs)
    /\ (gfx_ok G pool m -> gfx_ok G pool m') /\ Mem.unchanged_on (fun b z => ~ RCELL pool la fl b z) m m'.
  Proof.
    intros pool la fl bpg Hp Hl Hf Hb m rs fs i l1 k l2 t m' vr Hr Hfl Hnd Hi El H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); neq0).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); neq0).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); neq0).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); neq0).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); neq0).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); neq0).
    destruct (dealloc_ok G (cenv_of lp _ (linked12_LO_spawn_object lp H12)) pool la fl Hpl Hpf Hlf
                m rs fs i l1 k l2 t m' vr Hr Hfl Hnd Hi El H) as (R & F & U).
    refine (conj R (conj F (conj _ U))).
    intros Hg. apply (proj2 (gfx_at_iff pool bpg Hpb G m' Hb)).
    apply (gfx_keep pool bpg _ m m' U); [ | exact (proj1 (gfx_at_iff pool bpg Hpb G m Hb) Hg) ].
    intros b z [(-> & j & Hj & Hz) | (-> & Hz)] [(Eb & j' & Hj' & Hz') | [Eb | Eb]];
      try congruence; unfold G_PREV, G_CHILD, O_NEXT, O_PREV, OSZ, NSLOT in *; lia.
  Qed.

  Lemma dao_fun : forall b fd, Genv.find_symbol G spawn_object._deallocate_object = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal spawn_object.f_deallocate_object.
  Proof. exact (fun_res lp _ _ _ (linked12_LO_spawn_object lp H12) dm_dao). Qed.
End LINKED.
