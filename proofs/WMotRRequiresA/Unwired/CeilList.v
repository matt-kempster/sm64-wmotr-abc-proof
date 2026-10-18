(* ====================================================================== *)
(* CeilList (unwired, GOAL 2): the VALUE contract of the real find_ceil     *)
(* (surface_collision.c), proved from its generated Clight body, in the     *)
(* same way as FloorList does find_floor (whose generic pieces it reuses:  *)
(* on_list, wf_list, part_head, FL, the triple framework, ffe).            *)
(*                                                                          *)
(* find_ceil_from_list: NULL with memory unchanged, or a surface read from *)
(* a node of the list with one float written through pheight.             *)
(* find_ceil: *pceil gets NULL or a surface off a partition list; every    *)
(* other cell of the entry memory except gNumCalls.ceil is unchanged, and  *)
(* no permission changes.                                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import WMotRRequiresA.Unwired.FloorList.
Import ListNotations.

Local Notation SC := surface_collision.prog.

(* the static cell find_ceil writes: gNumCalls.ceil, bytes [2, 4) *)
Definition fc_statics : list ident := [surface_collision._gNumCalls].
Definition fc_cells : list (ident * Z * Z) := [(surface_collision._gNumCalls, 2, 4)].
Definition is_static_c (ge : genv) (b : block) : Prop :=
  exists id, In id fc_statics /\ Genv.find_symbol ge id = Some b.

Definition fcl_loop : statement :=
  match fn_body surface_collision.f_find_ceil_from_list with
  | Ssequence _ (Ssequence _ (Ssequence l _)) => l | _ => Sskip end.
Definition fcl_s1 : statement := match fcl_loop with Sloop s1 _ => s1 | _ => Sskip end.

Lemma fcl_loop_shape : fcl_loop = Sloop fcl_s1 Sskip.
Proof. reflexivity. Qed.

Lemma fcl_body_shape :
  fn_body surface_collision.f_find_ceil_from_list =
  Ssequence (Sset surface_collision._ceil (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence (Sset surface_collision._ceil (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence fcl_loop
       (Sreturn (Some (Etempvar surface_collision._ceil
                         (tptr (Tstruct surface_collision._Surface noattr))))))).
Proof. reflexivity. Qed.

(* the loop invariant: memory untouched, floor still NULL, the cursor is
   reachable from the head, pheight unchanged *)
Definition InvC (m : mem) (node0 ph : val) (le : temp_env) : Prop :=
  exists nd, le ! surface_collision._surfaceNode = Some nd
    /\ (forall s, on_list m nd s -> on_list m node0 s)
    /\ le ! surface_collision._ceil = Some (Vint Int.zero)
    /\ le ! surface_collision._pheight = Some ph.

Lemma fcl_iter : forall ge e m le t le1 m1 out1 node0 ph,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m fcl_s1 t le1 m1 out1 ->
    InvC m node0 ph le ->
    (out1 = Out_break /\ m1 = m /\ le1 = le)
    \/ (out1 = Out_continue /\ m1 = m /\ InvC m node0 ph le1)
    \/ (out1 = Out_break /\ exists s h, on_list m node0 s
          /\ le1 ! surface_collision._ceil = Some s
          /\ Mem.storev Mfloat32 m ph h = Some m1).
Proof.
  intros ge e m le t le1 m1 out1 node0 ph HC H (nd & Hnd & Hreach & Hfl & Hph).
  cbv [fcl_s1 fcl_loop surface_collision.f_find_ceil_from_list fn_body Swhile] in H.
  xinv.
  (* the guard said stop: nothing changed *)
  all: try (left; split; [reflexivity | split; reflexivity]).
  (* the two node loads *)
  all: match goal with
       Hs : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar surface_collision._surfaceNode _) _)
                                 surface_collision._surface _) _ |- _ =>
         assert (Hle1 : L ! surface_collision._surfaceNode = Some nd) by (ptg; exact Hnd);
         destruct (sn_surf _ _ _ _ _ _ HC Hle1 Hs)
           as (bn & on & -> & Ls)
       end.
  all: match goal with
       Hn : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar surface_collision._surfaceNode _) _)
                                 surface_collision._next _) _ |- _ =>
         assert (Hle2 : L ! surface_collision._surfaceNode = Some (Vptr bn on)) by (ptg; exact Hnd);
         destruct (sn_next _ _ _ _ _ _ HC Hle2 Hn)
           as (bn' & on' & Eb & Ln); injection Eb as <- <-
       end.
  (* a continue: the cursor moved to next, still reachable *)
  all: try (right; left; split; [reflexivity | split; [reflexivity |]];
            eexists; split; [ptg; reflexivity |];
            split; [intros s0 Hs0; apply Hreach; eapply ol_next; [exact Ln | exact Hs0] |];
            split; ptg; assumption).
  (* the floor: pheight written, floor := surf *)
  all: repeat match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  all: repeat match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
         inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end]
       end.
  all: repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ =>
         progress (repeat first [ rewrite PTree.gss in Hx
                                | rewrite PTree.gso in Hx by (let HH := fresh in intro HH; cbv in HH; discriminate HH) ])
       end.
  all: repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  all: match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
       try (cbn in *; discriminate).
  all: right; right; split; [reflexivity |].
  all: eexists; eexists; split; [apply Hreach; apply ol_here; exact Ls |].
  all: split; [ptg; reflexivity |].
  all: match goal with Hp : _ ! surface_collision._pheight = Some (Vptr _ _) |- _ =>
         rewrite Hph in Hp; inv Hp end.
  all: match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; inv Hm end.
  all: eassumption.
Qed.

Lemma fcl_loop_spec : forall ge e m le t le' m' out node0 ph,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m fcl_loop t le' m' out ->
    InvC m node0 ph le ->
    out = Out_normal
    /\ ((m' = m /\ le' ! surface_collision._ceil = Some (Vint Int.zero))
        \/ (exists s h, on_list m node0 s
              /\ le' ! surface_collision._ceil = Some s
              /\ Mem.storev Mfloat32 m ph h = Some m')).
Proof.
  intros ge e m le t le' m' out node0 ph HC H.
  rewrite fcl_loop_shape in H.
  remember (Sloop fcl_s1 Sskip) as S eqn:ES. revert ES.
  induction H; intros ES HI; try discriminate ES.
  - (* the body broke out (or returned) *)
    injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ fcl_s1 _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ =>
      destruct (fcl_iter _ _ _ _ _ _ _ _ _ _ HC Hx HI)
        as [(-> & -> & ->) | [(-> & _ & _) | (-> & s & h & Hs & Hf & Hst)]];
      inv Hb
    end.
    + destruct HI as (nd & _ & _ & Hfl & _). split; [reflexivity | left; split; auto].
    + split; [reflexivity | right; eauto].
  - (* the body continued, then Sskip went abrupt: impossible *)
    injection ES as -> ->.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ => inv Hs; inv Hb end.
  - (* one more round *)
    injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ fcl_s1 _ _ _ _,
                    Hn : out_normal_or_continue _ |- _ =>
      destruct (fcl_iter _ _ _ _ _ _ _ _ _ _ HC Hx HI)
        as [(-> & _ & _) | [(-> & -> & HI') | (-> & _)]];
      [inv Hn | | inv Hn]
    end.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hs end.
    eauto.
Qed.


(* THE CONTRACT *)
Theorem fcl_value_contract : forall (ge : genv),
    cenv_has ge ->
    forall m node x y z ph t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_ceil_from_list) [node; x; y; z; ph] t m' vres ->
      (m' = m /\ vres = Vint Int.zero)
      \/ (on_list m node vres /\ exists h, Mem.storev Mfloat32 m ph h = Some m').
Proof.
  intros ge HC m node x y z ph t m' vres H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_ceil_from_list fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rewrite fcl_body_shape in Hx; inv Hx end;
    [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end;
       congruence].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) _) _ _ _ _ |- _ => inv Hx end;
    [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end;
       congruence].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  repeat match goal with Hc : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Hc; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end] end.
  repeat match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  repeat match goal with Hc : sem_cast (Vint _) _ _ ?mm = Some _ |- _ =>
    change (sem_cast (Vint (Int.repr 0)) (typeof (Econst_int (Int.repr 0) tint)) (tptr tvoid) mm)
      with (Some (Vint (Int.repr 0))) in Hc; injection Hc as <- end.
  match goal with Hx : exec_stmt _ _ _ ?L ?mm (Ssequence fcl_loop _) _ _ _ _ |- _ =>
    assert (HI : InvC mm node ph L)
      by (exists node; split; [ptg; reflexivity |]; split; [auto |]; split; ptg; reflexivity)
  end.
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv Hx end.
  - match goal with Hl : exec_stmt _ _ _ _ _ fcl_loop _ _ _ _ |- _ =>
      destruct (fcl_loop_spec _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (_ & Hr) end.
    match goal with Hs : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hs end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => destruct Ho as (_ & Hc) end.
    apply cast_surf_ptr in Hc. subst vres.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      cbn [blocks_of_env PTree.elements Mem.free_list] in Hf; injection Hf as <- end.
    destruct Hr as [(-> & Hf) | (s & h & Hs & Hf & Hst)];
      match goal with Hg : _ ! surface_collision._ceil = Some _ |- _ => rewrite Hf in Hg; inv Hg end.
    + left; auto.
    + right; eauto.
  - match goal with Hl : exec_stmt _ _ _ _ _ fcl_loop _ _ _ _ |- _ =>
      destruct (fcl_loop_spec _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (-> & _) end.
    congruence.
Qed.


Definition fcl_pinned (ge : genv) : Prop :=
  forall bf f, Genv.find_symbol ge surface_collision._find_ceil_from_list = Some bf ->
    Genv.find_funct_ptr ge bf = Some f -> f = Internal surface_collision.f_find_ceil_from_list.

Lemma fcl_args5 : forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil_from_list)
      vargs t m' vres ->
    exists node x y z ph, vargs = [node; x; y; z; ph].
Proof.
  intros ge m vargs t m' vres H.
  destruct vargs as [|node [|x [|y [|z [|ph [|w r]]]]]]; eauto 7;
    inv H; match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end;
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [bind_parameter_temps surface_collision.f_find_ceil_from_list fn_params] in Hb;
      discriminate Hb end.
Qed.

Lemma fcl_call : forall (ge : genv) e le m tid args targs tres cc t le' m' out,
    cenv_has ge -> fcl_pinned ge -> e ! surface_collision._find_ceil_from_list = None ->
    exec_stmt function_entry2 ge e le m
      (Scall (Some tid) (Evar surface_collision._find_ceil_from_list (Tfunction targs tres cc)) args)
      t le' m' out ->
    exists node x y z ph fl,
      eval_exprlist ge e le m args targs [node; x; y; z; ph]
      /\ out = Out_normal /\ le' = PTree.set tid fl le
      /\ ((m' = m /\ fl = Vint Int.zero)
          \/ (on_list m node fl /\ exists h, Mem.storev Mfloat32 m ph h = Some m')).
Proof.
  intros ge e le m tid args targs tres cc t le' m' out HC Hpin He H.
  inv H.
  cbn [typeof classify_fun] in *.
  match goal with Hc : fun_case_f _ _ _ = fun_case_f _ _ _ |- _ => inv Hc end.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [congruence |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  match goal with Hf : Genv.find_funct _ (Vptr _ _) = Some _ |- _ =>
    cbn [Genv.find_funct] in Hf; rewrite pred_dec_true in Hf by reflexivity;
    rewrite (Hpin _ _ ltac:(eassumption) Hf) in * end.
  match goal with Hev : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
    destruct (fcl_args5 _ _ _ _ _ _ Hev) as (node & x & y & z & ph & ->);
    destruct (fcl_value_contract _ HC _ _ _ _ _ _ _ _ _ Hev) as [(-> & ->) | (Ho & h & Hst)] end.
  - do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |]. left; auto.
  - do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |]. right; eauto.
Qed.


Section FC.
Variable ge : genv.
Variable avoid : block -> Prop.
Variable m : mem.
Variable bpf : block.
Variable opf : ptrofs.
Variables bH bD : block.
Hypothesis HC : cenv_has ge.
Hypothesis Hpin : fcl_pinned ge.
Hypothesis Hpf_av : avoid bpf.
Hypothesis Hpf_v : Mem.valid_block m bpf.
Hypothesis Hst : forall b, is_static_c ge b -> avoid b /\ b <> bpf.
Hypothesis Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
  Mem.valid_block m bp /\ ~ avoid bp.
Hypothesis Hwf : forall hd, part_head ge m hd -> wf_list m avoid hd.
Hypothesis HnvH : ~ Mem.valid_block m bH.
Hypothesis HnvD : ~ Mem.valid_block m bD.

Local Notation e := (ffe bH bD).

(* the cells find_floor may write: the *pfloor cell and the static cells *)
Definition wcc (b : block) (i : Z) : Prop :=
  (b = bpf /\ Ptrofs.unsigned opf <= i < Ptrofs.unsigned opf + 4)
  \/ (exists id lo hi, In (id, lo, hi) fc_cells /\ Genv.find_symbol ge id = Some b /\ lo <= i < hi).

Definition keptc (b : block) (i : Z) : Prop := Mem.valid_block m b /\ ~ wcc b i.

(* every other cell of m is unchanged, and no permission of m changes *)
Definition UOc (M : mem) : Prop :=
  Mem.unchanged_on keptc m M
  /\ (forall b i k p, Mem.valid_block m b -> (Mem.perm m b i k p <-> Mem.perm M b i k p)).

Lemma avoid_wc : forall b i, wcc b i -> avoid b.
Proof.
  intros b i [(-> & _) | (id & lo & hi & Hin & Hs & _)]; [exact Hpf_av |].
  apply Hst. exists id. split; [| exact Hs].
  cbn in Hin |- *. destruct Hin as [Eq | []]; inv Eq; auto.
Qed.

Lemma UO_keep : forall M, UOc M -> Mem.unchanged_on (keep m avoid) m M.
Proof.
  intros M (U & _). eapply Mem.unchanged_on_implies; [exact U |].
  intros b i (Hv & Hna) _. split; [exact Hv |]. intro Hw. exact (Hna (avoid_wc _ _ Hw)).
Qed.

(* a store into a block that is new, or into written cells only *)
Lemma UO_store : forall M M' ch b ofs v,
    UOc M -> Mem.store ch M b ofs v = Some M' ->
    (~ Mem.valid_block m b \/ forall i, ofs <= i < ofs + size_chunk ch -> wcc b i) -> UOc M'.
Proof.
  intros M M' ch b ofs v (U & P) Hs Hb. split.
  - eapply Mem.unchanged_on_trans; [exact U |].
    eapply Mem.store_unchanged_on; [exact Hs |].
    intros i Hi (Hv & Hn). destruct Hb as [Hb | Hb]; [exact (Hb Hv) | exact (Hn (Hb i Hi))].
  - intros b' i k p Hv. rewrite (P b' i k p Hv).
    split; intro HH; [eapply Mem.perm_store_1; eauto | eapply Mem.perm_store_2; eauto].
Qed.
(* *pfloor holds a floor; the cell was writable already in m *)
Definition PFc (M : mem) : Prop :=
  exists v, (FL ge m v /\ Mem.valid_access m Mint32 bpf (Ptrofs.unsigned opf) Writable)
    /\ Mem.loadv Mint32 M (Vptr bpf opf) = Some (Val.load_result Mint32 v).

Definition IVc (pfs sl dyn fl : bool) (le : temp_env) (M : mem) : Prop :=
  UOc M
  /\ le ! surface_collision._pceil = Some (Vptr bpf opf)
  /\ (pfs = true -> PFc M)
  /\ (sl = true -> exists v, le ! surface_collision._surfaceList = Some v /\ part_head ge m v)
  /\ (dyn = true -> exists v, le ! surface_collision._dynamicCeil = Some v /\ FL ge m v)
  /\ (fl = true -> exists v, le ! surface_collision._ceil = Some v /\ FL ge m v).

Definition RRc (le : temp_env) (M : mem) : Prop := UOc M /\ PFc M.

Lemma bpf_ne : forall b, ~ Mem.valid_block m b -> b <> bpf.
Proof. intros b H ->. contradiction. Qed.

(* a step that touches one block outside the keptc part, never bpf *)
Lemma IV_frame : forall pfs sl dyn fl le M M' ch b ofs v,
    IVc pfs sl dyn fl le M -> Mem.store ch M b ofs v = Some M' ->
    (~ Mem.valid_block m b \/ forall i, ofs <= i < ofs + size_chunk ch -> wcc b i) -> b <> bpf ->
    IVc pfs sl dyn fl le M'.
Proof.
  intros pfs sl dyn fl le M M' ch b ofs v (U & Hp & PF & SL & DY & FLo) Hs Hb Hne.
  split; [| split; [exact Hp | split; [| split; [exact SL | split; [exact DY | exact FLo]]]]].
  - exact (UO_store _ _ _ _ _ _ U Hs Hb).
  - intros Ht. destruct (PF Ht) as (w & Hfl & Hl). exists w. split; [exact Hfl |].
    cbn [Mem.loadv] in *. erewrite Mem.load_store_other; [exact Hl | exact Hs |].
    left. exact (not_eq_sym Hne).
Qed.

Lemma lv_H : forall le M ty b ofs bf,
    eval_lvalue ge e le M (Evar surface_collision._height ty) b ofs bf -> b = bH.
Proof.
  intros le M ty b ofs bf H. inv H; rewrite ffe_H in *; congruence.
Qed.
Lemma lv_D : forall le M ty b ofs bf,
    eval_lvalue ge e le M (Evar surface_collision._dynamicHeight ty) b ofs bf -> b = bD.
Proof.
  intros le M ty b ofs bf H. inv H; rewrite ffe_D in *; congruence.
Qed.
Lemma lv_static : forall x le M ty b ofs bf,
    In x fc_statics -> eval_lvalue ge e le M (Evar x ty) b ofs bf ->
    Genv.find_symbol ge x = Some b /\ ofs = Ptrofs.zero /\ bf = Full.
Proof.
  intros x le M ty b ofs bf Hin H. inv H.
  - exfalso. cbn in Hin.
    match goal with Hx : (ffe _ _) ! _ = Some _ |- _ =>
      rewrite ffe_other in Hx; [discriminate Hx | |] end;
    destruct Hin as [<- | []]; idne.
  - auto.
Qed.

Lemma ntc_ceil_ofs : forall co,
    (genv_cenv ge) ! surface_collision._NumTimesCalled = Some co ->
    field_offset ge surface_collision._ceil (co_members co) = OK (2, Full).
Proof.
  intros co H.
  assert (M : match (prog_comp_env SC) ! surface_collision._NumTimesCalled with
              | Some co => co_members co | None => nil end
              = [Member_plain surface_collision._floor tshort;
                 Member_plain surface_collision._ceil tshort;
                 Member_plain surface_collision._wall tshort]) by (vm_compute; reflexivity).
  destruct ((prog_comp_env SC) ! surface_collision._NumTimesCalled) as [co0|] eqn:E0;
    [| discriminate M].
  rewrite (HC _ _ E0) in H. injection H as <-. rewrite M. reflexivity.
Qed.

Lemma lv_calls_ceil : forall le M b ofs bf,
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._ceil tshort) b ofs bf ->
    Genv.find_symbol ge surface_collision._gNumCalls = Some b /\ ofs = Ptrofs.repr 2 /\ bf = Full.
Proof.
  intros le M b ofs bf H. inv H; cbn [typeof] in *; try discriminate.
  match goal with Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate;
    [| match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    apply lv_static in Hl; [destruct Hl as (Hs & -> & _) | cbn; auto] end.
  match goal with Ht : Tstruct _ _ = Tstruct _ _ |- _ => injection Ht as <- _ end.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (ntc_ceil_ofs _ Hc) in Hf; injection Hf as <- <- end.
  split; [exact Hs | split; [apply Ptrofs.add_zero_l | reflexivity]].
Qed.

(* the written lvalue: a new block (any access), or a static cell written
   by value *)
Definition wr_ok (ty : type) (b : block) (ofs : ptrofs) (bf : bitfield) : Prop :=
  b <> bpf /\
  (~ Mem.valid_block m b
   \/ (bf = Full /\ exists ch, access_mode ty = By_value ch
         /\ forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + size_chunk ch -> wcc b i)).

Lemma tri_frame : forall lhs rhs pfs sl dyn fl R,
    (forall le M b ofs bf, eval_lvalue ge e le M lhs b ofs bf -> wr_ok (typeof lhs) b ofs bf) ->
    tri ge e (IVc pfs sl dyn fl) (Sassign lhs rhs) (IVc pfs sl dyn fl) R.
Proof.
  intros lhs rhs pfs sl dyn fl R Hl. apply tri_assign.
  intros le M b ofs bf v v' M' HI Hlv _ _ Ha.
  destruct (Hl _ _ _ _ _ Hlv) as (Hne & [Hnv | (-> & ch & Ham & Hw)]).
  - (* a new block: any kind of write keeps UOc and the pfloor cell *)
    destruct HI as (U & Hp & PF & SL & DY & FLo).
    pose proof (assign_loc_frame _ _ _ _ _ _ _ _ Ha) as Hu.
    assert (Hperm : forall b' i k p, b' <> b -> (Mem.perm M b' i k p <-> Mem.perm M' b' i k p)).
    { intros b' i k p Hn. inv Ha.
      - cbn [Mem.storev] in *. split; intro HH; [eapply Mem.perm_store_1 | eapply Mem.perm_store_2]; eauto.
      - split; intro HH; [eapply Mem.perm_storebytes_1 | eapply Mem.perm_storebytes_2]; eauto.
      - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        cbn [Mem.storev] in *. split; intro HH; [eapply Mem.perm_store_1 | eapply Mem.perm_store_2]; eauto. }
    destruct U as (U & P).
    split; [split |].
    + eapply Mem.unchanged_on_trans; [exact U |].
      eapply Mem.unchanged_on_implies; [exact Hu |].
      intros b' i (Hv & _) _ ->. contradiction.
    + intros b' i k p Hv. rewrite (P b' i k p Hv). apply Hperm. intros ->. contradiction.
    + split; [exact Hp | split; [| split; [exact SL | split; [exact DY | exact FLo]]]].
      intros Ht. destruct (PF Ht) as (w & Hfl & Hld). exists w. split; [exact Hfl |].
      cbn [Mem.loadv] in *.
      erewrite Mem.load_unchanged_on_1; [exact Hld | exact Hu | | intros i _; exact (not_eq_sym Hne)].
      eapply Mem.valid_access_valid_block.
      eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; eauto | constructor].
  - inv Ha; try congruence;
      match goal with Hm : access_mode _ = _ |- _ => rewrite Ham in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => inv Hm end.
    cbn [Mem.storev] in *.
    exact (IV_frame _ _ _ _ _ _ _ _ _ _ _ HI ltac:(eassumption) (or_intror Hw) Hne).
Qed.

Lemma tri_set_un : forall x a pfs sl dyn fl R,
    x <> surface_collision._pceil -> x <> surface_collision._surfaceList ->
    x <> surface_collision._dynamicCeil -> x <> surface_collision._ceil ->
    tri ge e (IVc pfs sl dyn fl) (Sset x a) (IVc pfs sl dyn fl) R.
Proof.
  intros x a pfs sl dyn fl R N1 N2 N3 N4. apply tri_set.
  intros le M v (U & Hp & PF & SL & DY & FLo) _.
  split; [exact U |]. split; [rewrite PTree.gso by congruence; exact Hp |].
  split; [exact PF |].
  split; [intros Ht; destruct (SL Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  split; [intros Ht; destruct (DY Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  intros Ht; destruct (FLo Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto.
Qed.

Lemma UO_free : forall M M' b lo hi,
    UOc M -> Mem.free M b lo hi = Some M' -> ~ Mem.valid_block m b -> UOc M'.
Proof.
  intros M M' b lo hi (U & P) Hf Hn. split.
  - eapply Mem.unchanged_on_trans; [exact U |].
    eapply Mem.free_unchanged_on; [exact Hf |]. intros i _ (Hv & _). exact (Hn Hv).
  - intros b' i k p Hv. rewrite (P b' i k p Hv).
    assert (Hne : b' <> b) by (intros ->; contradiction).
    split; intro HH; [eapply Mem.perm_free_1; eauto | eapply Mem.perm_free_3; eauto].
Qed.

Definition untracked (x : ident) : Prop :=
  x <> surface_collision._pceil /\ x <> surface_collision._surfaceList
  /\ x <> surface_collision._dynamicCeil /\ x <> surface_collision._ceil.

Lemma IV_set_un : forall pfs sl dyn fl le M x v,
    IVc pfs sl dyn fl le M -> untracked x -> IVc pfs sl dyn fl (PTree.set x v le) M.
Proof.
  intros pfs sl dyn fl le M x v (U & Hp & PF & SL & DY & FLo) (N1 & N2 & N3 & N4).
  split; [exact U |]. split; [rewrite PTree.gso by congruence; exact Hp |].
  split; [exact PF |].
  split; [intros Ht; destruct (SL Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  split; [intros Ht; destruct (DY Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  intros Ht; destruct (FLo Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto.
Qed.

Definition surf_t : type := Tstruct surface_collision._Surface noattr.

Lemma tri_pf_store : forall rhs pfs sl dyn fl R,
    (forall le M v v', IVc pfs sl dyn fl le M -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) (tptr surf_t) M = Some v' -> FL ge m v') ->
    tri ge e (IVc pfs sl dyn fl)
      (Sassign (Ederef (Etempvar surface_collision._pceil (tptr (tptr surf_t))) (tptr surf_t)) rhs)
      (IVc true sl dyn fl) R.
Proof.
  intros rhs pfs sl dyn fl R Hv le M t le' M' out HI H. inv H. left; split; [reflexivity |].
  pose proof HI as (U & Hp & PF & SL & DY & FLo).
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Hp in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hc : sem_cast _ _ _ _ = Some _, He : eval_expr _ _ _ _ rhs _ |- _ =>
    pose proof (Hv _ _ _ _ HI He Hc) as Hfl end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    pose proof (assign_loc_frame _ _ _ _ _ _ _ _ Ha) as Hu; inv Ha end;
    cbn [access_mode typeof] in *; try discriminate.
  match goal with Hm : access_mode _ = By_value _ |- _ =>
    change (access_mode (tptr surf_t)) with (By_value Mint32) in Hm; inv Hm end.
  split; [refine (UO_store _ _ _ _ _ _ U ltac:(eassumption) (or_intror _));
          intros i Hi; left; split; [reflexivity | exact Hi] |].
  split; [exact Hp |].
  split; [| split; [exact SL | split; [exact DY | exact FLo]]].
  intros _. eexists. split; [split; [exact Hfl |] |].
  { cbn [Mem.storev] in *.
    match goal with Hs : Mem.store _ _ _ _ _ = Some _ |- _ =>
      destruct (Mem.store_valid_access_3 _ _ _ _ _ _ Hs) as (Hr & Ha) end.
    split; [| exact Ha]. intros i Hi.
    apply (proj2 U bpf i Cur Writable Hpf_v). exact (Hr i Hi). }
  cbn [Mem.loadv Mem.storev] in *.
  erewrite Mem.load_store_same; [reflexivity | eassumption].
Qed.

Lemma tri_sl : forall pid A pfs sl dyn fl R,
    In pid part_ids -> gaddr pid A = true ->
    tri ge e (IVc pfs sl dyn fl)
      (Sset surface_collision._surfaceList
         (Efield (Ederef A (Tstruct surface_collision._SurfaceNode noattr))
            surface_collision._next (tptr (Tstruct surface_collision._SurfaceNode noattr))))
      (IVc pfs true dyn fl) R.
Proof.
  intros pid A pfs sl dyn fl R Hin G le M t le' M' out HI H. inv H. left; split; [reflexivity |].
  destruct HI as (U & Hp & PF & SL & DY & FLo).
  match goal with Hx : eval_expr _ _ ?L ?MM (Efield _ _ _) ?v |- _ =>
    destruct (deref_field ge e L MM A surface_collision._SurfaceNode surface_collision._next
                (tptr (Tstruct surface_collision._SurfaceNode noattr)) v SN_NEXT
                (fun co Hc => proj1 (sn_offsets_ge ge co HC Hc)) eq_refl Hx)
      as (l & ofs & HA & Hld) end.
  assert (Hne : e ! pid = None)
    by (apply ffe_other; destruct Hin as [<- | [<- | []]]; idne).
  destruct (gaddr_eval ge e _ _ pid Hne A _ G HA) as (bp & o & Hs & Eq). inv Eq.
  destruct (Hpart pid bp Hin Hs) as (Hvb & Hna).
  split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
  split; [exact PF |].
  split; [intros _; eexists; split; [apply PTree.gss |] |].
  { exists pid, bp, (Ptrofs.add o (Ptrofs.repr SN_NEXT)). split; [exact Hin |]. split; [exact Hs |].
    cbn [Mem.loadv] in *.
    erewrite <- Mem.load_unchanged_on_1; [exact Hld | exact (UO_keep _ U) | exact Hvb |].
    intros i _. split; assumption. }
  split; [intros Ht; destruct (DY Ht) as (w & ? & ?); exists w; rewrite PTree.gso by idne; auto |].
  intros Ht; destruct (FLo Ht) as (w & ? & ?); exists w; rewrite PTree.gso by idne; auto.
Qed.

Definition IVkc (pfs dyn fl : bool) (tk : ident) (le : temp_env) (M : mem) : Prop :=
  IVc pfs true dyn fl le M /\ exists v, le ! tk = Some v /\ FL ge m v.

Lemma tri_call1 : forall tk tres cc loc bL a1 a2 a3 pfs dyn fl R,
    ((loc = surface_collision._height /\ bL = bH)
     \/ (loc = surface_collision._dynamicHeight /\ bL = bD)) ->
    untracked tk ->
    tri ge e (IVc pfs true dyn fl)
      (Scall (Some tk)
         (Evar surface_collision._find_ceil_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          a1; a2; a3; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      (IVkc pfs dyn fl tk) R.
Proof.
  intros tk tres cc loc bL a1 a2 a3 pfs dyn fl R Hloc Htk.
  intros le M t le' M' out HI H.
  assert (Hn : e ! surface_collision._find_ceil_from_list = None) by (apply ffe_other; idne).
  destruct (fcl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin Hn H)
    as (node & x & y & z & ph & fl0 & Hargs & -> & -> & Hres).
  left; split; [reflexivity |].
  pose proof HI as (U & Hp & PF & SL & DY & FLo).
  destruct (SL eq_refl) as (vsl & Hsl & PH).
  (* the arguments *)
  inv Hargs.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ (typeof (Etempvar _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  rewrite Hsl in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [| destruct Hloc as [(-> & _) | (-> & _)];
       [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  match goal with Hx : (ffe _ _) ! loc = Some (?bb, _) |- _ =>
    assert (Eb : bb = bL)
      by (destruct Hloc as [(-> & ->) | (-> & ->)];
          [rewrite ffe_H in Hx | rewrite ffe_D in Hx]; congruence);
    subst bb end.
  match goal with Hc : sem_cast _ (typeof (Eaddrof _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  assert (HnvL : ~ Mem.valid_block m bL) by (destruct Hloc as [(_ & ->) | (_ & ->)]; assumption).
  destruct Hres as [(-> & ->) | (Hon & h & Hstv)].
  + split; [exact (IV_set_un _ _ _ _ _ _ _ _ HI Htk) |].
    eexists; split; [apply PTree.gss | left; reflexivity].
  + cbn [Mem.storev] in Hstv.
    split; [exact (IV_set_un _ _ _ _ _ _ _ _
                     (IV_frame _ _ _ _ _ _ _ _ _ _ _ HI Hstv (or_introl HnvL) (bpf_ne _ HnvL)) Htk) |].
    eexists; split; [apply PTree.gss |].
    right. eexists. split; [exact PH |].
    exact (on_list_back _ _ _ (Hwf _ PH) _ _ (UO_keep _ U) Hon).
Qed.

Lemma tri_take : forall tk dst Tk pfs dyn fl dyn' fl' R,
    ((dst = surface_collision._dynamicCeil /\ dyn' = true /\ fl' = fl)
     \/ (dst = surface_collision._ceil /\ dyn' = dyn /\ fl' = true)) ->
    tri ge e (IVkc pfs dyn fl tk) (Sset dst (Etempvar tk Tk)) (IVc pfs true dyn' fl') R.
Proof.
  intros tk dst Tk pfs dyn fl dyn' fl' R Hdst.
  apply tri_set2. intros le M v ((U & Hp & PF & SL & DY & FLo) & (w & Hw & Hfw)) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hx : le ! tk = Some _ |- _ => rewrite Hw in Hx; inv Hx end.
  destruct Hdst as [(-> & -> & ->) | (-> & -> & ->)].
  + split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
    split; [exact PF |].
    split; [intros Ht; destruct (SL Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
    split; [intros _; exists v; split; [apply PTree.gss | exact Hfw] |].
    intros Ht; destruct (FLo Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto.
  + split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
    split; [exact PF |].
    split; [intros Ht; destruct (SL Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
    split; [intros Ht; destruct (DY Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
    intros _; exists v; split; [apply PTree.gss | exact Hfw].
Qed.

Lemma tri_floor_dyn : forall T pfs sl fl R,
    tri ge e (IVc pfs sl true fl)
      (Sset surface_collision._ceil (Etempvar surface_collision._dynamicCeil T))
      (IVc pfs sl true true) R.
Proof.
  intros T pfs sl fl R. apply tri_set2.
  intros le M v (U & Hp & PF & SL & DY & FLo) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  destruct (DY eq_refl) as (w & Hw & Hfw).
  match goal with Hx : le ! _ = Some v |- _ => rewrite Hw in Hx; inv Hx end.
  split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
  split; [exact PF |].
  split; [intros Ht; destruct (SL Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
  split; [intros _; eexists; rewrite PTree.gso by idne; eauto |].
  intros _; eexists; split; [apply PTree.gss | eassumption].
Qed.

Lemma IV_RR : forall sl dyn fl le M, IVc true sl dyn fl le M -> RRc le M.
Proof. intros sl dyn fl le M (U & _ & PF & _). split; [exact U | exact (PF eq_refl)]. Qed.

Lemma null_FL : forall le M v v',
    eval_expr ge e le M (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) v ->
    sem_cast v (tptr tvoid) (tptr surf_t) M = Some v' -> FL ge m v'.
Proof.
  intros le M v v' Hev Hc.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with H1 : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
    change (sem_cast (Vint (Int.repr 0)) (typeof (Econst_int (Int.repr 0) tint)) (tptr tvoid) M)
      with (Some (Vint (Int.repr 0))) in H1; injection H1 as <- end.
  change (sem_cast (Vint (Int.repr 0)) (tptr tvoid) (tptr surf_t) M)
    with (Some (Vint (Int.repr 0))) in Hc.
  injection Hc as <-. left. reflexivity.
Qed.

Lemma floor_FL : forall pfs sl dyn le M v v',
    IVc pfs sl dyn true le M ->
    eval_expr ge e le M (Etempvar surface_collision._ceil (tptr surf_t)) v ->
    sem_cast v (tptr surf_t) (tptr surf_t) M = Some v' -> FL ge m v'.
Proof.
  intros pfs sl dyn le M v v' (_ & _ & _ & _ & _ & FLo) Hev Hc.
  apply cast_ptr_same in Hc. subst v'.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  destruct (FLo eq_refl) as (w & Hw & Hf). congruence.
Qed.

Ltac untr := split; [idne | split; [idne | split; idne]].
Ltac locok := first [left; split; reflexivity | right; split; reflexivity].
Ltac dstok := first [left; split; [reflexivity | split; reflexivity]
                    | right; split; [reflexivity | split; reflexivity]].
Ltac inlist := cbn; repeat (first [left; reflexivity | right]).
Ltac wcok Hs :=
  lazymatch type of Hs with Genv.find_symbol _ ?x = Some ?b =>
    let Hin := fresh in let Hne := fresh in
    assert (Hin : In x fc_statics) by inlist;
    destruct (Hst b (ex_intro _ x (conj Hin Hs))) as (_ & Hne);
    split; [exact Hne |];
    right; split; [reflexivity |]; eexists; split; [reflexivity |];
    let i := fresh in let Hi := fresh in
    intros i Hi; right; exists x; eexists; eexists; split; [inlist | split; [exact Hs |]];
    change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in Hi; cbn [size_chunk] in Hi; lia
  end.
Ltac lvok :=
  let le := fresh in let M := fresh in let b := fresh in let o := fresh in
  let bf := fresh in let Hl := fresh in
  intros le M b o bf Hl;
  first [ apply lv_H in Hl; subst b; split; [exact (bpf_ne _ HnvH) | left; exact HnvH]
        | apply lv_D in Hl; subst b; split; [exact (bpf_ne _ HnvD) | left; exact HnvD]
        | apply lv_calls_ceil in Hl; destruct Hl as (Hs & -> & ->); wcok Hs
        | apply lv_static in Hl; [destruct Hl as (Hs & -> & ->); wcok Hs | inlist] ].
Ltac pfok :=
  let le := fresh in let M := fresh in let v := fresh in let v' := fresh in
  let HI := fresh in let Hev := fresh in let Hc := fresh in
  intros le M v v' HI Hev Hc; cbn [typeof] in Hc;
  first [ exact (null_FL _ _ _ _ Hev Hc) | exact (floor_FL _ _ _ _ _ _ _ HI Hev Hc) ].

Ltac base_id A :=
  lazymatch A with
  | Evar ?x _ => x
  | Ebinop _ ?a1 _ _ => base_id a1
  | Ederef ?a1 _ => base_id a1
  end.

Ltac solve_tri :=
  lazymatch goal with
  | |- tri _ _ _ (Ssequence (Scall _ _ _) (Sset _ _)) _ _ =>
      eapply tri_seq; [eapply tri_call1; [locok | untr] | eapply tri_take; dstok]
  | |- tri _ _ _ (Ssequence _ _) _ _ => eapply tri_seq; [solve_tri | solve_tri]
  | |- tri _ _ _ (Sifthenelse _ _ _) _ _ => eapply tri_ite; [solve_tri | solve_tri]
  | |- tri _ _ _ Sskip _ _ => eapply tri_skip
  | |- tri _ _ _ (Sreturn _) _ _ =>
      eapply tri_ret; let HH := fresh in intros ? ? HH; eapply IV_RR; exact HH
  | |- tri _ _ _ (Scall _ _ _) _ _ => eapply tri_call1; [locok | untr]
  | |- tri _ _ _ (Sset surface_collision._surfaceList (Efield (Ederef ?A _) _ _)) _ _ =>
      let pid := base_id A in eapply (tri_sl pid); [inlist | reflexivity]
  | |- tri _ _ (IVkc _ _ _ _) (Sset _ _) _ _ => eapply tri_take; dstok
  | |- tri _ _ _ (Sset surface_collision._ceil (Etempvar surface_collision._dynamicCeil _)) _ _ =>
      eapply tri_floor_dyn
  | |- tri _ _ _ (Sset _ _) _ _ => eapply tri_set_un; idne
  | |- tri _ _ _ (Sassign (Ederef (Etempvar surface_collision._pceil _) _) _) _ _ =>
      eapply tri_pf_store; pfok
  | |- tri _ _ _ (Sassign _ _) _ _ => eapply tri_frame; lvok
  end.

Lemma fc_body_tri :
  tri ge e (IVc false false false false) (fn_body surface_collision.f_find_ceil)
    (fun _ _ => True) RRc.
Proof.
  eapply tri_strengthen; [| intros; exact I].
  cbn [fn_body surface_collision.f_find_ceil].
  solve_tri.
  Unshelve. all: exact (fun _ _ => True).
Qed.

End FC.


(* freeing a block that is new keeps UOc and the pfloor cell *)
Lemma free_keeps_c : forall ge m bpf opf M M' b,
    Mem.valid_block m bpf -> UOc ge m bpf opf M -> PFc ge m bpf opf M -> ~ Mem.valid_block m b ->
    Mem.free M b 0 4 = Some M' -> UOc ge m bpf opf M' /\ PFc ge m bpf opf M'.
Proof.
  intros ge m bpf opf M M' b Hpv U (v & Hv & Hl) Hn Hf.
  split; [eapply UO_free; eauto |].
  exists v; split; [exact Hv |].
  cbn [Mem.loadv] in *. erewrite Mem.load_free; [exact Hl | exact Hf |].
  left. intros ->. contradiction.
Qed.

(* THE CONTRACT: find_floor stores into *pfloor either NULL or a surface
   read off a partition list (of the entry memory).  Every cell of the entry
   memory other than *pfloor and the three static cells (fc_cells) is
   unchanged, and no permission changes.  The statics and the pfloor block
   must be outside the lists ("avoid"); the lists must be well formed. *)
Theorem fc_value_contract : forall (ge : genv) avoid,
    cenv_has ge -> fcl_pinned ge ->
    forall m xv yv zv bpf opf t m' vres,
      avoid bpf -> Mem.valid_block m bpf ->
      (forall b, is_static_c ge b -> avoid b /\ b <> bpf) ->
      (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
         Mem.valid_block m bp /\ ~ avoid bp) ->
      (forall hd, part_head ge m hd -> wf_list m avoid hd) ->
      eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil)
        [xv; yv; zv; Vptr bpf opf] t m' vres ->
      exists fl, FL ge m fl
        /\ Mem.loadv Mint32 m' (Vptr bpf opf) = Some (Val.load_result Mint32 fl)
        /\ UOc ge m bpf opf m'
        /\ Mem.valid_access m Mint32 bpf (Ptrofs.unsigned opf) Writable
        /\ exists h, vres = Vsingle h.
Proof.
  intros ge avoid HC Hpin m xv yv zv bpf opf t m' vres Hav Hpv Hst Hpart Hwf H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_ceil fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with
  | A1 : Mem.alloc m 0 _ = (?M1, ?b1), A2 : Mem.alloc ?M1 0 _ = (?M2, ?b2) |- _ =>
      rename b1 into bH, b2 into bD, A1 into HA1, A2 into HA2, M1 into mA, M2 into mB
  end.
  assert (HnvH : ~ Mem.valid_block m bH) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA1).
  assert (HnvD : ~ Mem.valid_block m bD)
    by (intro HH; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_block_alloc _ _ _ _ _ HA1 _ HH))).
  assert (U2 : UOc ge m bpf opf mB).
  { split.
    - eapply Mem.unchanged_on_trans; eapply Mem.alloc_unchanged_on; eassumption.
    - intros b i k p Hv.
      assert (N1 : b <> bH) by (intros ->; contradiction).
      assert (N2 : b <> bD) by (intros ->; contradiction).
      split; intro HH.
      + eapply Mem.perm_alloc_1; [exact HA2 |]. eapply Mem.perm_alloc_1; [exact HA1 | exact HH].
      + eapply Mem.perm_alloc_4; [exact HA1 | | exact N1].
        eapply Mem.perm_alloc_4; [exact HA2 | exact HH | exact N2]. }
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HI : IVc ge m bpf opf false false false false L mB)
  end.
  { match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [bind_parameter_temps surface_collision.f_find_ceil fn_params] in Hb;
      injection Hb as <- end.
    split; [exact U2 |]. split; [ptg; reflexivity |].
    repeat split; discriminate. }
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (fc_body_tri ge avoid m bpf opf bH bD HC Hpin Hav Hpv Hst Hpart Hwf HnvH HnvD
                _ _ _ _ _ _ HI Hx) as [(-> & _) | (_ & U3 & PF3)] end.
  { match goal with Ho : outcome_result_value _ _ _ _ |- _ => cbn in Ho; contradiction end. }
  match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
    first [ change (Mem.free_list M [(bH, 0, 4); (bD, 0, 4)] = Some R) in Hf
          | change (Mem.free_list M [(bD, 0, 4); (bH, 0, 4)] = Some R) in Hf ];
    cbn [Mem.free_list] in Hf end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M4|] eqn:F1; [| discriminate Hf];
    assert (N1 : ~ Mem.valid_block m b1) by assumption end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M5|] eqn:F2; [| discriminate Hf]; injection Hf as <-;
    assert (N2 : ~ Mem.valid_block m b1) by assumption end.
  destruct (free_keeps_c _ _ _ _ _ _ _ Hpv U3 PF3 N1 F1) as (U4 & PF4).
  destruct (free_keeps_c _ _ _ _ _ _ _ Hpv U4 PF4 N2 F2) as (U5 & (fl & (Hfl & Hwr) & Hld)).
  exists fl. split; [exact Hfl | split; [exact Hld | split; [exact U5 | split; [exact Hwr |]]]].
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return surface_collision.f_find_ceil] in Ho; exact (orv_single _ _ _ Ho) end.
Qed.
