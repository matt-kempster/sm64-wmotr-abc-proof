(* SPINE (P1' widening, 2026-10-17): the arg-aware, store-target-aware surface_collision frames; consumed by SurfaceBodies.v, which discharges the five lifted rest cases of RestSurface. *)

(* ====================================================================== *)
(* P1' PRE-REQ P-1 / P-2 (docs/p1prime-atomic-wiring-blueprint.md §4-A, §6). *)
(*                                                                        *)
(* MathGeomBodies.v proved frames for find_floor, find_ceil,                *)
(* find_wall_collisions, f32_find_wall_collision and the three _from_list  *)
(* helpers, but with premises that can never be met at the real link:     *)
(*  - a callee oracle for ALL vargs and a store oracle for ALL envs    *)
(*    (an argument or a local shadow pointing at bm breaks them);          *)
(*  - an MWF oracle every store to a block other than bm keeps MWF,      *)
(*    which is FALSE for the real MWF (MWFReal.MWF_real watches the        *)
(*    controller block, the SafeB chase blocks and several globals);       *)
(*  - an out-param gate the out pointer's block is not bm, which is      *)
(*    FALSE at update_mario_geometry_inputs: it passes &m->floor and        *)
(*    &m->pos[i], pointers INTO Mario's block.                             *)
(*                                                                        *)
(* Here every premise is about the stores the body really does:            *)
(*  - cell_pres / blk_pres: a store to this cell / this block keeps       *)
(*    valid bm, action_sat and MWF -- asked only of the blocks the body   *)
(*    stores into (its out-param target, its own fresh locals, its listed  *)
(*    statics).  At the link these come from the consumer's own MWF rows   *)
(*    (HMWF_localstore for locals, Hmwf_window for a Mario-field window,   *)
(*    Hmwf_glob for statics).                                              *)
(*  - the walk sees the concrete call: the callee is the named global and  *)
(*    its out-param argument is an own local's address (or the gate temp), *)
(*    so the callee premise is needed only for a store-safe argument.      *)
(*  - an out-param written ONLY by `*p = v` (a <=4-byte by-value store at  *)
(*    exactly the pointer) needs only that one cell to be store-safe: the  *)
(*    `exact` gate mode.  This is what &m->floor / &m->pos[i] satisfy.     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require surface_collision mario math_util.
From SM64.Proofs Require Import ActionValueFrame Taint MarioStepSurface RestSurface.
From SM64.Proofs Require CensusV2 RealFrameValue SymbolicLinking.
From SM64.Proofs Require Import MathGeomBodies.

Import ListNotations.

(* ====================================================================== *)
(* 0. Store-safety of a cell / a block.                                    *)
(* ====================================================================== *)

Section PRES.
  Variable Q : int -> Prop.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  Definition cell_pres (ch : memory_chunk) (b : block) (o : Z) : Prop :=
    forall v m1 m2, Mem.store ch m1 b o v = Some m2 ->
      Mem.valid_block m1 bm -> action_sat Q m1 bm -> MWF m1 ->
      Mem.valid_block m2 bm /\ action_sat Q m2 bm /\ MWF m2.

  Definition blk_pres (b : block) : Prop := forall ch o, cell_pres ch b o.

  (* the `exact` out-param gate: every <=4-byte store at the pointer itself *)
  Definition out_cell (b : block) (o : ptrofs) : Prop :=
    forall ch, size_chunk ch <= 4 -> cell_pres ch b (Ptrofs.unsigned o).
End PRES.

(* ====================================================================== *)
(* 1. The gate walk, store-target-aware (for the three _from_list bodies). *)
(* ====================================================================== *)

Lemma gate_assign_pres_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) (bm b_out : block) (oo : ptrofs)
    g lv rhs ge e le m t le' m' out,
    blk_pres Q bm MWF b_out ->
    CensusV2.chain_root_l lv = Some g ->
    (match access_mode (typeof lv) with By_value _ => true | _ => false end) = true ->
    le ! g = Some (Vptr b_out oo) ->
    exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
Proof.
  intros MWF Q bm b_out oo g lv rhs ge e le m t le' m' out
         Hbp Hcr Hac Hg Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
    destruct (CensusV2.chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv) as (o0 & Hleg);
    assert (Hloc : loc = b_out) by congruence; subst loc end.
  match goal with Hass : assign_loc _ (typeof lv) _ _ _ _ _ _ |- _ => inv Hass end.
  - match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
      unfold Mem.storev in Hsv;
      destruct (Hbp _ _ _ _ _ Hsv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
    split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
  - match goal with Hco : access_mode (typeof lv) = By_copy |- _ =>
      rewrite Hco in Hac; discriminate Hac end.
  - match goal with Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb end.
    match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
      unfold Mem.storev in Hsv;
      destruct (Hbp _ _ _ _ _ Hsv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
    split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
Qed.

Lemma gate_walk_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) (bm b_out : block) (oo : ptrofs) (g : ident)
    (Hbp : blk_pres Q bm MWF b_out)
    ge e s le m t le' m' out,
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    gate_chk g s = true ->
    le ! g = Some (Vptr b_out oo) ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ le' ! g = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_out oo g Hbp ge e s le m t le' m' out Hexec.
  induction Hexec; intros Hchk Hg Hv Hsat Hmwf;
    try discriminate Hchk.
  - repeat split; assumption.
  - cbn [gate_chk] in Hchk.
    destruct (CensusV2.chain_root_l a1) as [t0|] eqn:Hcr; [ | discriminate Hchk ].
    apply andb_prop in Hchk as [Hpe Hbv].
    apply Pos.eqb_eq in Hpe; subst t0.
    assert (HH : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
      by (eapply exec_Sassign; eassumption).
    edestruct (gate_assign_pres_B MWF Q bm b_out oo g a1 a2 ge e le m E0 le m' Out_normal
                 Hbp Hcr Hbv Hg HH Hv Hsat Hmwf)
      as (Hv' & Hsat' & Hmwf' & _ & _).
    repeat split; assumption.
  - cbn [gate_chk] in Hchk.
    apply negb_true_iff, Pos.eqb_neq in Hchk.
    repeat split; try assumption.
    rewrite PTree.gso by (apply not_eq_sym; exact Hchk); exact Hg.
  - cbn [gate_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
    exact (IHHexec2 H2 Hg1 Hv1 Hsat1 Hmwf1).
  - cbn [gate_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
    exact (IHHexec H1 Hg Hv Hsat Hmwf).
  - cbn [gate_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    apply IHHexec; [ destruct b; assumption | assumption .. ].
  - repeat split; assumption.
  - repeat split; assumption.
  - repeat split; assumption.
  - repeat split; assumption.
  - cbn [gate_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
    exact (IHHexec H1 Hg Hv Hsat Hmwf).
  - cbn [gate_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
    exact (IHHexec2 H2 Hg1 Hv1 Hsat1 Hmwf1).
  - cbn [gate_chk] in Hchk.
    pose proof Hchk as Hchk0.
    apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
    destruct (IHHexec2 H2 Hg1 Hv1 Hsat1 Hmwf1) as (Hv2 & Hsat2 & Hmwf2 & Hg2).
    exact (IHHexec3 Hchk0 Hg2 Hv2 Hsat2 Hmwf2).
Qed.

(* the three _from_list helpers: the ONLY premise is that the out-param
   block is store-safe (no MWF oracle at all -- they store nowhere else) *)
Lemma find_floor_from_list_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor_from_list) vargs t m' vres ->
      nth_error vargs 4 = Some (Vptr b_out oo) ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hbp m vargs t m' vres Hevf Hn4 Hv Hsat Hmwf.
  unfold surface_collision.f_find_floor_from_list in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Hbp : bind_parameter_temps _ ?vargs _ = Some ?LE,
                  Hn : nth_error ?vargs _ = Some (Vptr _ _) |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 [|a5 vr]]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
      try (cbn [nth_error] in Hn; discriminate Hn);
    cbn [nth_error] in Hn; injection Hn as ->;
    assert (Hled : LE ! surface_collision._pheight = Some (Vptr b_out oo)) by (eapply sc_bind_pheight; exact Hbp)
  end.
  match goal with Hbody : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [fn_body] in Hbody;
    destruct (gate_walk_B MWF not_tainted bm b_out oo surface_collision._pheight Hbp _ _ _ _ _ _ _ _ _ Hbody
                find_floor_from_list_pheight_chk Hled Hv Hsat Hmwf) as (Hvb & Hsatb & Hmwfb & _)
  end.
  match goal with Hfl : Mem.free_list _ _ = Some _ |- _ =>
    rewrite (eq_refl : blocks_of_env _ empty_env = nil) in Hfl;
    cbn [Mem.free_list] in Hfl; injection Hfl as <- end.
  exact (conj Hvb (conj Hsatb Hmwfb)).
Qed.

Lemma find_ceil_from_list_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_ceil_from_list) vargs t m' vres ->
      nth_error vargs 4 = Some (Vptr b_out oo) ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hbp m vargs t m' vres Hevf Hn4 Hv Hsat Hmwf.
  unfold surface_collision.f_find_ceil_from_list in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Hbp : bind_parameter_temps _ ?vargs _ = Some ?LE,
                  Hn : nth_error ?vargs _ = Some (Vptr _ _) |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 [|a5 vr]]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
      try (cbn [nth_error] in Hn; discriminate Hn);
    cbn [nth_error] in Hn; injection Hn as ->;
    assert (Hled : LE ! surface_collision._pheight = Some (Vptr b_out oo)) by (eapply sc_bind_pheight; exact Hbp)
  end.
  match goal with Hbody : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [fn_body] in Hbody;
    destruct (gate_walk_B MWF not_tainted bm b_out oo surface_collision._pheight Hbp _ _ _ _ _ _ _ _ _ Hbody
                find_ceil_from_list_pheight_chk Hled Hv Hsat Hmwf) as (Hvb & Hsatb & Hmwfb & _)
  end.
  match goal with Hfl : Mem.free_list _ _ = Some _ |- _ =>
    rewrite (eq_refl : blocks_of_env _ empty_env = nil) in Hfl;
    cbn [Mem.free_list] in Hfl; injection Hfl as <- end.
  exact (conj Hvb (conj Hsatb Hmwfb)).
Qed.

Lemma find_wall_collisions_from_list_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_wall_collisions_from_list) vargs t m' vres ->
      nth_error vargs 1 = Some (Vptr b_out oo) ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hbp m vargs t m' vres Hevf Hn1 Hv Hsat Hmwf.
  unfold surface_collision.f_find_wall_collisions_from_list in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Hbp : bind_parameter_temps _ ?vargs _ = Some ?LE,
                  Hn : nth_error ?vargs _ = Some (Vptr _ _) |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 [|a5 vr]]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
      try (cbn [nth_error] in Hn; discriminate Hn);
    cbn [nth_error] in Hn; injection Hn as ->;
    assert (Hled : LE ! surface_collision._data = Some (Vptr b_out oo)) by (eapply sc_bind_data; exact Hbp)
  end.
  match goal with Hbody : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [fn_body] in Hbody;
    destruct (gate_walk_B MWF not_tainted bm b_out oo surface_collision._data Hbp _ _ _ _ _ _ _ _ _ Hbody
                find_wall_collisions_from_list_data_chk Hled Hv Hsat Hmwf) as (Hvb & Hsatb & Hmwfb & _)
  end.
  match goal with Hfl : Mem.free_list _ _ = Some _ |- _ =>
    rewrite (eq_refl : blocks_of_env _ empty_env = nil) in Hfl;
    cbn [Mem.free_list] in Hfl; injection Hfl as <- end.
  exact (conj Hvb (conj Hsatb Hmwfb)).
Qed.

(* ====================================================================== *)
(* 2. The call-aware walk.                                                 *)
(* ====================================================================== *)

Definition is_ptr_ty (t : type) : bool := match t with Tpointer _ _ => true | _ => false end.

Definition in_ids (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Lemma in_ids_In : forall x l, in_ids x l = true -> In x l.
Proof.
  intros x l H. unfold in_ids in H. apply existsb_exists in H as (y & Hy & Hxy).
  apply Pos.eqb_eq in Hxy. subst. exact Hy.
Qed.

(* an out-param argument the walk can see is store-safe: the address of one
   of the body's own locals, or (in full-gate mode) the gate temp itself *)
Definition arg_ok (ex : bool) (g : ident) (own : list ident) (a : expr) : bool :=
  match a with
  | Eaddrof (Evar x _) t => is_ptr_ty t && in_ids x own
  | Etempvar t ty => negb ex && Pos.eqb t g && is_ptr_ty ty
  | _ => false
  end.

(* a direct call to the named function, whose k-th argument is arg_ok and
   whose k-th parameter is a pointer *)
Definition call_ok (ex : bool) (g cid : ident) (k : nat) (own : list ident)
    (a : expr) (al : list expr) : bool :=
  match a with
  | Evar id (Tfunction targs _ _) =>
      Pos.eqb id cid &&
      (match nth_error al k, nth_error targs k with
       | Some x, Some tx => arg_ok ex g own x && is_ptr_ty tx
       | _, _ => false
       end)
  | _ => false
  end.

(* a by-value store to a named variable (or a field of one): an own local
   or a listed static *)
Definition sym_ok (own stat : list ident) (lv : expr) : bool :=
  match lv with
  | Evar x ty =>
      (match access_mode ty with By_value _ => true | _ => false end)
      && (in_ids x own || in_ids x stat)
  | Efield (Evar x _) _ fty =>
      (match access_mode fty with By_value _ => true | _ => false end)
      && (in_ids x own || in_ids x stat)
  | _ => false
  end.

(* `*g = v`, a by-value store of at most 4 bytes at the gate pointer itself *)
Definition exact_ok (g : ident) (lv : expr) : bool :=
  match lv with
  | Ederef (Etempvar t _) ty =>
      Pos.eqb t g &&
      (match access_mode ty with By_value ch => (size_chunk ch <=? 4)%Z | _ => false end)
  | _ => false
  end.

Fixpoint cw_chk (ex : bool) (g cid : ident) (k : nat) (own stat : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ => true
  | Sset id _ => negb (Pos.eqb id g)
  | Scall optid a al =>
      call_ok ex g cid k own a al &&
      (match optid with Some ti => negb (Pos.eqb ti g) | None => true end)
  | Sassign lv _ =>
      match CensusV2.chain_root_l lv with
      | Some t =>
          if ex then exact_ok g lv
          else Pos.eqb t g &&
               (match access_mode (typeof lv) with By_value _ => true | _ => false end)
      | None => sym_ok own stat lv
      end
  | Ssequence s1 s2 => cw_chk ex g cid k own stat s1 && cw_chk ex g cid k own stat s2
  | Sifthenelse _ s1 s2 => cw_chk ex g cid k own stat s1 && cw_chk ex g cid k own stat s2
  | Sloop s1 s2 => cw_chk ex g cid k own stat s1 && cw_chk ex g cid k own stat s2
  | _ => false
  end.

Lemma cast_ptr_ptr : forall b o t1 t2 m v,
  is_ptr_ty t1 = true -> is_ptr_ty t2 = true ->
  sem_cast (Vptr b o) t1 t2 m = Some v -> v = Vptr b o.
Proof.
  intros b o t1 t2 m v H1 H2 Hc.
  destruct t1; try discriminate H1; destruct t2; try discriminate H2.
  cbn in Hc. injection Hc as <-. reflexivity.
Qed.

Lemma exprlist_nth : forall ge e le m al tyl vl,
  eval_exprlist ge e le m al tyl vl ->
  forall k a ty, nth_error al k = Some a -> nth_error tyl k = Some ty ->
  exists v1 v2, eval_expr ge e le m a v1 /\ sem_cast v1 (typeof a) ty m = Some v2
                /\ nth_error vl k = Some v2.
Proof.
  intros ge e le m al tyl vl H. induction H; intros [|k] a0 ty0 Ha Ht; cbn in Ha, Ht;
    try discriminate.
  - injection Ha as <-. injection Ht as <-. exists v1, v2.
    split; [ assumption | split; [ assumption | reflexivity ] ].
  - exact (IHeval_exprlist k a0 ty0 Ha Ht).
Qed.

(* the callee of a direct call to a global function name *)
Lemma evar_fun_val : forall ge e le m x a r c vf,
  eval_expr ge e le m (Evar x (Tfunction a r c)) vf -> e ! x = None ->
  exists l, Genv.find_symbol ge x = Some l /\ vf = Vptr l Ptrofs.zero.
Proof.
  intros ge e le m x a r c vf H Hn. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; [ congruence | ].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    try (match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; discriminate Hm end).
  eexists. split; [ eassumption | reflexivity ].
Qed.

Lemma evar_copy_lvalue : forall ge e le m x ty b ofs,
  eval_expr ge e le m (Evar x ty) (Vptr b ofs) -> access_mode ty = By_copy ->
  exists bf, eval_lvalue ge e le m (Evar x ty) b ofs bf.
Proof.
  intros ge e le m x ty b ofs H Hac. inv H.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [typeof] in *; try congruence;
    try (eexists; eassumption);
    match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
Qed.

(* `*g = v` stores exactly at the gate pointer *)
Lemma exact_assign_pres :
  forall (MWF : mem -> Prop) (Q : int -> Prop) (bm b_out : block) (oo : ptrofs)
    g lv rhs ge e le m t le' m' out,
    out_cell Q bm MWF b_out oo ->
    exact_ok g lv = true ->
    le ! g = Some (Vptr b_out oo) ->
    exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
Proof.
  intros MWF Q bm b_out oo g lv rhs ge e le m t le' m' out
         Hcell Hok Hg Hexec Hv Hsat Hmwf.
  destruct lv; try discriminate Hok. destruct lv; try discriminate Hok.
  cbn [exact_ok] in Hok. apply andb_prop in Hok as [Hid Hsz]. apply Pos.eqb_eq in Hid. subst i.
  destruct (access_mode t0) as [ch| | |] eqn:Hac; try discriminate Hsz.
  apply Z.leb_le in Hsz.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev; rewrite Hg in Hev;
    injection Hev as <- <- end.
  match goal with Hass : assign_loc _ (typeof _) _ _ _ Full _ _ |- _ =>
    cbn [typeof] in Hass; inv Hass end;
  [ | match goal with Hco : access_mode t0 = By_copy |- _ =>
        rewrite Hac in Hco; discriminate Hco end ].
  match goal with Hac2 : access_mode t0 = By_value ?c2 |- _ =>
    rewrite Hac in Hac2; injection Hac2 as <- end.
  match goal with Hstv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hstv;
    destruct (Hcell ch Hsz _ _ _ Hstv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
  split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
Qed.

Section ENV.
  Variable ge : genv.
  Variable e : env.
  Variable bm : block.
  Variable Q : int -> Prop.
  Variable MWF : mem -> Prop.
  Variables own stat : list ident.
  Hypothesis Hown : forall x, In x own ->
    exists b ty, e ! x = Some (b, ty) /\ blk_pres Q bm MWF b.
  Hypothesis Hstat : forall x, In x stat -> e ! x = None.
  Hypothesis Hsym : forall x bg, In x stat -> Genv.find_symbol ge x = Some bg ->
    blk_pres Q bm MWF bg.

  Lemma evar_lvalue_blk : forall le m x ty b ofs bf,
    eval_lvalue ge e le m (Evar x ty) b ofs bf ->
    (in_ids x own || in_ids x stat) = true -> blk_pres Q bm MWF b.
  Proof.
    intros le m x ty b ofs bf Hl Hin. apply orb_true_iff in Hin.
    inv Hl.
    - destruct Hin as [Hi | Hi]; apply in_ids_In in Hi.
      + destruct (Hown x Hi) as (b' & ty' & He & Hb).
        first [ congruence | (assert (b = b') by congruence; subst; exact Hb) ].
      + rewrite (Hstat x Hi) in *. discriminate.
    - destruct Hin as [Hi | Hi]; apply in_ids_In in Hi.
      + destruct (Hown x Hi) as (b' & ty' & He & Hb).
        first [ congruence | (assert (b = b') by congruence; subst; exact Hb) ].
      + eapply Hsym; eassumption.
  Qed.

  Lemma sym_lvalue_blk : forall le m lv b ofs bf,
    sym_ok own stat lv = true -> eval_lvalue ge e le m lv b ofs bf -> blk_pres Q bm MWF b.
  Proof.
    intros le m lv b ofs bf Hok Hl.
    destruct lv; try discriminate Hok.
    - cbn [sym_ok] in Hok. apply andb_prop in Hok as [_ Hin].
      eapply evar_lvalue_blk; eassumption.
    - destruct lv; try discriminate Hok.
      cbn [sym_ok] in Hok. apply andb_prop in Hok as [_ Hin].
      inv Hl.
      + match goal with
        | Hx : eval_expr _ _ _ _ (Evar _ _) (Vptr _ _), Ht : typeof (Evar _ _) = Tstruct _ _ |- _ =>
            cbn in Ht; subst;
            destruct (evar_copy_lvalue _ _ _ _ _ _ _ _ Hx eq_refl) as (bf' & Hl')
        end.
        eapply evar_lvalue_blk; eassumption.
      + match goal with
        | Hx : eval_expr _ _ _ _ (Evar _ _) (Vptr _ _), Ht : typeof (Evar _ _) = Tunion _ _ |- _ =>
            cbn in Ht; subst;
            destruct (evar_copy_lvalue _ _ _ _ _ _ _ _ Hx eq_refl) as (bf' & Hl')
        end.
        eapply evar_lvalue_blk; eassumption.
  Qed.

  (* an out-param argument accepted by arg_ok evaluates to a store-safe pointer *)
  Lemma arg_ok_val : forall ex g le m x v b_out oo,
    arg_ok ex g own x = true -> eval_expr ge e le m x v ->
    le ! g = Some (Vptr b_out oo) -> (ex = false -> blk_pres Q bm MWF b_out) ->
    is_ptr_ty (typeof x) = true /\ exists b o, v = Vptr b o /\ blk_pres Q bm MWF b.
  Proof.
    intros ex g le m x v b_out oo Hok Hev Hg Hb.
    destruct x; try discriminate Hok.
    - cbn [arg_ok] in Hok. apply andb_prop in Hok as [Hi Hp]. apply andb_prop in Hi as [Hx Hi].
      apply negb_true_iff in Hx. apply Pos.eqb_eq in Hi. subst.
      split; [ exact Hp | ].
      inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Ht : le ! _ = Some v |- _ => rewrite Hg in Ht; injection Ht as <- end.
      exists b_out, oo. split; [ reflexivity | exact (Hb eq_refl) ].
    - destruct x; try discriminate Hok.
      cbn [arg_ok] in Hok. apply andb_prop in Hok as [Hp Hi].
      split; [ exact Hp | ].
      inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) ?l ?o _ |- _ =>
        exists l, o; split; [ reflexivity | ];
        eapply evar_lvalue_blk; [ exact Hl | rewrite Hi; reflexivity ]
      end.
  Qed.

  Lemma sym_assign_pres : forall lv rhs le m t le' m' out,
      sym_ok own stat lv = true ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros lv rhs le m t le' m' out Hok Hexec Hv Hsat Hmwf.
    assert (Hac : match access_mode (typeof lv) with By_value _ => true | _ => false end = true).
    { destruct lv; try discriminate Hok.
      - cbn [sym_ok] in Hok. apply andb_prop in Hok as [H _]. exact H.
      - destruct lv; try discriminate Hok. cbn [sym_ok] in Hok. apply andb_prop in Hok as [H _].
        exact H. }
    inv Hexec.
    match goal with Hlv : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
      pose proof (sym_lvalue_blk _ _ _ _ _ _ Hok Hlv) as Hbp end.
    match goal with Hass : assign_loc _ (typeof lv) _ _ _ _ _ _ |- _ => inv Hass end.
    - match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv;
        destruct (Hbp _ _ _ _ _ Hsv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
      split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
    - match goal with Hco : access_mode (typeof lv) = By_copy |- _ =>
        rewrite Hco in Hac; discriminate Hac end.
    - match goal with Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb end.
      match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv;
        destruct (Hbp _ _ _ _ _ Hsv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
      split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
  Qed.

  Definition callee_frame (cid : ident) (k : nat) : Prop :=
    forall f m0 vargs t0 m0' vres b o bf,
      Genv.find_symbol ge cid = Some bf -> Genv.find_funct_ptr ge bf = Some f ->
      nth_error vargs k = Some (Vptr b o) -> blk_pres Q bm MWF b ->
      eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
      Mem.valid_block m0 bm -> action_sat Q m0 bm -> MWF m0 ->
      Mem.valid_block m0' bm /\ action_sat Q m0' bm /\ MWF m0'.

  Definition gate_ok (ex : bool) (b_out : block) (oo : ptrofs) : Prop :=
    if ex then out_cell Q bm MWF b_out oo else blk_pres Q bm MWF b_out.

  Lemma cw_call_pres :
    forall (b_out : block) (oo : ptrofs) (ex : bool) (g cid : ident) (k : nat),
      e ! cid = None -> callee_frame cid k -> gate_ok ex b_out oo ->
      forall le m optid a al t le' m' out,
        exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
        call_ok ex g cid k own a al = true ->
        le ! g = Some (Vptr b_out oo) ->
        Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
        Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ out = Out_normal
          /\ exists v, le' = set_opttemp optid v le.
  Proof.
    intros b_out oo ex g cid k Hcid Hcall HG le m optid a al t le' m' out Hexec Hok Hg Hv Hsat Hmwf.
    destruct a; try discriminate Hok. destruct t0; try discriminate Hok.
    cbn [call_ok] in Hok. apply andb_prop in Hok as [Hid Hnth]. apply Pos.eqb_eq in Hid. subst i.
    inv Hexec.
    match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ => cbn in Hcf; injection Hcf as <- <- <- end.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee Hcid) as (lf & Hsy & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
      unfold Genv.find_funct in Hff;
      destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | NE]; [ | congruence ] end.
    destruct (nth_error al k) as [x|] eqn:Ex; [ | discriminate Hnth ].
    destruct (nth_error l k) as [tx|] eqn:Et; [ | discriminate Hnth ].
    apply andb_prop in Hnth as [Harg Hpt].
    match goal with Hel : eval_exprlist _ _ _ _ al _ ?vargs |- _ =>
      destruct (exprlist_nth _ _ _ _ _ _ _ Hel k x tx Ex Et) as (v1 & v2 & Hx & Hc & Hvk) end.
    assert (Hfull : ex = false -> blk_pres Q bm MWF b_out)
      by (intro E; unfold gate_ok in HG; rewrite E in HG; exact HG).
    destruct (arg_ok_val ex g le m x v1 b_out oo Harg Hx Hg Hfull) as (Hpx & b & o & -> & Hbb).
    rewrite (cast_ptr_ptr _ _ _ _ _ _ Hpx Hpt Hc) in Hvk.
    match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?f, Hfc : eval_funcall _ _ _ ?f _ _ _ _ |- _ =>
      destruct (Hcall _ _ _ _ _ _ _ _ _ Hsy Hfp Hvk Hbb Hfc Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf')
    end.
    split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | split; [ reflexivity | ] ] ] ].
    eexists. reflexivity.
  Qed.

  (* THE WALK *)
  Lemma cw_walk :
    forall (b_out : block) (oo : ptrofs) (ex : bool) (g cid : ident) (k : nat)
      (HG : gate_ok ex b_out oo) (Hcid : e ! cid = None) (Hcall : callee_frame cid k)
      s le m t le' m' out,
      exec_stmt function_entry2 ge e le m s t le' m' out ->
      cw_chk ex g cid k own stat s = true ->
      le ! g = Some (Vptr b_out oo) ->
      Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
        /\ le' ! g = Some (Vptr b_out oo).
  Proof.
    intros b_out oo ex g cid k HG Hcid Hcall s le m t le' m' out Hexec.
    remember e as e0 eqn:He0.
    induction Hexec; intros Hchk Hg Hv Hsat Hmwf; try discriminate Hchk; subst e0.
    - repeat split; assumption.
    - (* Sassign : gate store OR named store *)
      cbn [cw_chk] in Hchk.
      assert (HH : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      destruct (CensusV2.chain_root_l a1) as [t0|] eqn:Hcr.
      + destruct ex.
        * edestruct (exact_assign_pres MWF Q bm b_out oo g a1 a2 ge e le m E0 le m' Out_normal
                       HG Hchk Hg HH Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf' & _ & _).
          repeat split; assumption.
        * apply andb_prop in Hchk as [Hpe Hbv]. apply Pos.eqb_eq in Hpe; subst t0.
          edestruct (gate_assign_pres_B MWF Q bm b_out oo g a1 a2 ge e le m E0 le m' Out_normal
                       HG Hcr Hbv Hg HH Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf' & _ & _).
          repeat split; assumption.
      + edestruct (sym_assign_pres a1 a2 le m E0 le m' Out_normal Hchk HH Hv Hsat Hmwf)
          as (Hv' & Hsat' & Hmwf' & _ & _).
        repeat split; assumption.
    - (* Sset *)
      cbn [cw_chk] in Hchk. apply negb_true_iff, Pos.eqb_neq in Hchk.
      repeat split; try assumption.
      rewrite PTree.gso by (apply not_eq_sym; exact Hchk); exact Hg.
    - (* Scall *)
      cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [Hok Hopt].
      assert (HH : exec_stmt function_entry2 ge e le m (Scall optid a al) t
                     (set_opttemp optid vres le) m' Out_normal)
        by (eapply exec_Scall; eassumption).
      destruct (cw_call_pres b_out oo ex g cid k Hcid Hcall HG le m optid a al t _ m' _ HH Hok Hg
                  Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf' & _).
      repeat split; try assumption.
      destruct optid as [ti|]; cbn [set_opttemp].
      + apply negb_true_iff, Pos.eqb_neq in Hopt.
        rewrite PTree.gso by (apply not_eq_sym; exact Hopt); exact Hg.
      + exact Hg.
    - cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
      exact (IHHexec2 eq_refl Hown Hstat Hcid H2 Hg1 Hv1 Hsat1 Hmwf1).
    - cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf).
    - cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | exact Hown | exact Hstat | exact Hcid | destruct b; assumption | assumption .. ].
    - repeat split; assumption.
    - repeat split; assumption.
    - repeat split; assumption.
    - repeat split; assumption.
    - cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf).
    - cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
      exact (IHHexec2 eq_refl Hown Hstat Hcid H2 Hg1 Hv1 Hsat1 Hmwf1).
    - cbn [cw_chk] in Hchk. pose proof Hchk as Hchk0. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
      destruct (IHHexec2 eq_refl Hown Hstat Hcid H2 Hg1 Hv1 Hsat1 Hmwf1) as (Hv2 & Hsat2 & Hmwf2 & Hg2).
      exact (IHHexec3 eq_refl Hown Hstat Hcid Hchk0 Hg2 Hv2 Hsat2 Hmwf2).
  Qed.
End ENV.

(* ====================================================================== *)
(* 3. find_floor / find_ceil.                                              *)
(*    Gate _pfloor/_pceil in EXACT mode (the only stores through it are    *)
(*    `*pfloor = floor`), own locals _height/_dynamicHeight, statics       *)
(*    gNumCalls / gNumFindFloorMisses / gFindFloorIncludeSurfaceIntangible. *)
(* ====================================================================== *)

Definition ff_own : list ident := [surface_collision._height; surface_collision._dynamicHeight].
Definition ff_stat : list ident :=
  [surface_collision._gNumCalls; surface_collision._gNumFindFloorMisses;
   surface_collision._gFindFloorIncludeSurfaceIntangible].
Definition fc_stat : list ident := [surface_collision._gNumCalls].

Lemma find_floor_cw_chk :
  cw_chk true surface_collision._pfloor surface_collision._find_floor_from_list 4 ff_own ff_stat
    (fn_body surface_collision.f_find_floor) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma find_ceil_cw_chk :
  cw_chk true surface_collision._pceil surface_collision._find_ceil_from_list 4 ff_own fc_stat
    (fn_body surface_collision.f_find_ceil) = true.
Proof. vm_compute. reflexivity. Qed.

Definition ff_env (b1 b2 : block) : env :=
  PTree.set surface_collision._dynamicHeight (b2, tfloat)
    (PTree.set surface_collision._height (b1, tfloat) empty_env).

Lemma ff_env_facts : forall (P : block -> Prop) b1 b2, P b1 -> P b2 ->
  (forall x, In x ff_own -> exists b ty, (ff_env b1 b2) ! x = Some (b, ty) /\ P b)
  /\ (forall x, In x ff_stat -> (ff_env b1 b2) ! x = None)
  /\ (forall x, In x fc_stat -> (ff_env b1 b2) ! x = None)
  /\ (ff_env b1 b2) ! surface_collision._find_floor_from_list = None
  /\ (ff_env b1 b2) ! surface_collision._find_ceil_from_list = None.
Proof.
  intros P b1 b2 H1 H2.
  split; [ | split; [ | split; [ | split ] ] ].
  - intros x Hin. destruct Hin as [<- | [<- | []]].
    + exists b1, tfloat. split; [ reflexivity | exact H1 ].
    + exists b2, tfloat. split; [ reflexivity | exact H2 ].
  - intros x Hin. destruct Hin as [<- | [<- | [<- | []]]]; reflexivity.
  - intros x Hin. destruct Hin as [<- | []]; reflexivity.
  - reflexivity.
  - reflexivity.
Qed.

(* the MWF frame premises shared by every body with own locals: alloc and
   free keep MWF, and a freshly allocated block is store-safe (at the link:
   it is a local_blk, so HMWF_localstore applies) *)
Definition frame_oracles (bm : block) (MWF : mem -> Prop) : Prop :=
  (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'')
  /\ (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3)
  /\ (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m ->
        Mem.valid_block m bm -> blk_pres not_tainted bm MWF b).

Lemma find_floor_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    (forall x bg, In x ff_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    callee_frame ge bm not_tainted MWF surface_collision._find_floor_from_list 4 ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      out_cell not_tainted bm MWF b_out oo ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hsym Hcall m vargs t m' vres Hevf Hn3 Hcell Hv Hsat Hmwf.
  unfold surface_collision.f_find_floor in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ (_ :: nil) _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  destruct Hor as (Halloc & Hfree & HallocB).
  match goal with
  | H1 : Mem.alloc ?ma 0 _ = (?mid, ?bb1),
    H2 : Mem.alloc ?mid 0 _ = (?mfin, ?bb2) |- _ =>
      assert (Hb1_bm : bb1 <> bm)
        by (intro EE; subst bb1; exact (Mem.fresh_block_alloc _ _ _ _ _ H1 Hv));
      assert (Hb1_B : blk_pres not_tainted bm MWF bb1) by (eapply HallocB; eassumption);
      assert (HmwfA1 : MWF mid) by (eapply Halloc; [ exact H1 | exact Hmwf ]);
      assert (HvA1 : Mem.valid_block mid bm)
        by (eapply Mem.valid_block_alloc; [ exact H1 | exact Hv ]);
      assert (HsatA1 : action_sat not_tainted mid bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H1 | exact Hv | exact Hsat ]);
      assert (Hb2_bm : bb2 <> bm)
        by (intro EE; subst bb2; exact (Mem.fresh_block_alloc _ _ _ _ _ H2 HvA1));
      assert (Hb2_B : blk_pres not_tainted bm MWF bb2) by (eapply HallocB; eassumption);
      assert (HmwfA2 : MWF mfin) by (eapply Halloc; [ exact H2 | exact HmwfA1 ]);
      assert (HvA2 : Mem.valid_block mfin bm)
        by (eapply Mem.valid_block_alloc; [ exact H2 | exact HvA1 ]);
      assert (HsatA2 : action_sat not_tainted mfin bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H2 | exact HvA1 | exact HsatA1 ]);
      destruct (ff_env_facts (blk_pres not_tainted bm MWF) bb1 bb2 Hb1_B Hb2_B)
        as (Hown & Hstf & Hstc & Hcf & Hcc)
  end.
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some ?LE |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 vr]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
      try (cbn [nth_error] in Hn3; discriminate Hn3);
    cbn [nth_error] in Hn3; injection Hn3 as ->;
    assert (Hled : LE ! surface_collision._pfloor = Some (Vptr b_out oo)) by (eapply sc_bind_pfloor; exact Hbp)
  end.
  cbn [fn_body] in Hbody.
  destruct (cw_walk ge _ bm not_tainted MWF ff_own ff_stat Hown Hstf Hsym b_out oo true
              surface_collision._pfloor surface_collision._find_floor_from_list 4
              Hcell Hcf Hcall _ _ _ _ _ _ _ Hbody find_floor_cw_chk Hled HvA2 HsatA2 HmwfA2)
    as (Hvb & Hsatb & Hmwfb & _).
  rewrite blocks_of_env_ff2 in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge tfloat) :: (_, 0, sizeof ge tfloat) :: nil))
    by (constructor; [ exact Hb1_bm | constructor; [ exact Hb2_bm | constructor ] ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hvb Hsatb) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | eapply Hfree; [ exact Hfl | exact Hmwfb ] ] ].
Qed.

Lemma find_ceil_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    callee_frame ge bm not_tainted MWF surface_collision._find_ceil_from_list 4 ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_ceil) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      out_cell not_tainted bm MWF b_out oo ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hsym Hcall m vargs t m' vres Hevf Hn3 Hcell Hv Hsat Hmwf.
  unfold surface_collision.f_find_ceil in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ (_ :: nil) _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  destruct Hor as (Halloc & Hfree & HallocB).
  match goal with
  | H1 : Mem.alloc ?ma 0 _ = (?mid, ?bb1),
    H2 : Mem.alloc ?mid 0 _ = (?mfin, ?bb2) |- _ =>
      assert (Hb1_bm : bb1 <> bm)
        by (intro EE; subst bb1; exact (Mem.fresh_block_alloc _ _ _ _ _ H1 Hv));
      assert (Hb1_B : blk_pres not_tainted bm MWF bb1) by (eapply HallocB; eassumption);
      assert (HmwfA1 : MWF mid) by (eapply Halloc; [ exact H1 | exact Hmwf ]);
      assert (HvA1 : Mem.valid_block mid bm)
        by (eapply Mem.valid_block_alloc; [ exact H1 | exact Hv ]);
      assert (HsatA1 : action_sat not_tainted mid bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H1 | exact Hv | exact Hsat ]);
      assert (Hb2_bm : bb2 <> bm)
        by (intro EE; subst bb2; exact (Mem.fresh_block_alloc _ _ _ _ _ H2 HvA1));
      assert (Hb2_B : blk_pres not_tainted bm MWF bb2) by (eapply HallocB; eassumption);
      assert (HmwfA2 : MWF mfin) by (eapply Halloc; [ exact H2 | exact HmwfA1 ]);
      assert (HvA2 : Mem.valid_block mfin bm)
        by (eapply Mem.valid_block_alloc; [ exact H2 | exact HvA1 ]);
      assert (HsatA2 : action_sat not_tainted mfin bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H2 | exact HvA1 | exact HsatA1 ]);
      destruct (ff_env_facts (blk_pres not_tainted bm MWF) bb1 bb2 Hb1_B Hb2_B)
        as (Hown & Hstf & Hstc & Hcf & Hcc)
  end.
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some ?LE |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 vr]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
      try (cbn [nth_error] in Hn3; discriminate Hn3);
    cbn [nth_error] in Hn3; injection Hn3 as ->;
    assert (Hled : LE ! surface_collision._pceil = Some (Vptr b_out oo)) by (eapply sc_bind_pceil; exact Hbp)
  end.
  cbn [fn_body] in Hbody.
  destruct (cw_walk ge _ bm not_tainted MWF ff_own fc_stat Hown Hstc Hsym b_out oo true
              surface_collision._pceil surface_collision._find_ceil_from_list 4
              Hcell Hcc Hcall _ _ _ _ _ _ _ Hbody find_ceil_cw_chk Hled HvA2 HsatA2 HmwfA2)
    as (Hvb & Hsatb & Hmwfb & _).
  rewrite blocks_of_env_ff2 in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge tfloat) :: (_, 0, sizeof ge tfloat) :: nil))
    by (constructor; [ exact Hb1_bm | constructor; [ exact Hb2_bm | constructor ] ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hvb Hsatb) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | eapply Hfree; [ exact Hfl | exact Hmwfb ] ] ].
Qed.

(* the callee premise, discharged: the link resolves the callee name to the
   real _from_list body, whose own frame needs only a store-safe out block *)
Definition resolves_to (ge : genv) (id : ident) (fr : Clight.function) : Prop :=
  forall bf f, Genv.find_symbol ge id = Some bf -> Genv.find_funct_ptr ge bf = Some f ->
    f = Internal fr.

Lemma find_floor_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    (forall x bg, In x ff_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    resolves_to ge surface_collision._find_floor_from_list surface_collision.f_find_floor_from_list ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      out_cell not_tainted bm MWF b_out oo ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hsym Hpin.
  apply (find_floor_body_frame_gated ge MWF bm b_out oo Hor Hsym).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_floor_from_list_frame_B ge MWF bm b o Hb m0 vargs t0 m0' vres Hfc Hn).
Qed.

Lemma find_ceil_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    resolves_to ge surface_collision._find_ceil_from_list surface_collision.f_find_ceil_from_list ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_ceil) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      out_cell not_tainted bm MWF b_out oo ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hsym Hpin.
  apply (find_ceil_body_frame_gated ge MWF bm b_out oo Hor Hsym).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_ceil_from_list_frame_B ge MWF bm b o Hb m0 vargs t0 m0' vres Hfc Hn).
Qed.

(* ====================================================================== *)
(* 4. find_wall_collisions: gate _colData in FULL mode (it is f32's own    *)
(*    local, and the body stores `colData->numWalls`), static gNumCalls.   *)
(* ====================================================================== *)

Lemma find_wall_collisions_cw_chk :
  cw_chk false surface_collision._colData surface_collision._find_wall_collisions_from_list 1
    [] fc_stat (fn_body surface_collision.f_find_wall_collisions) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma find_wall_collisions_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    callee_frame ge bm not_tainted MWF surface_collision._find_wall_collisions_from_list 1 ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_wall_collisions) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_out oo) ->
      blk_pres not_tainted bm MWF b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hsym Hcall m vargs t m' vres Hevf Hn0 Hbp Hv Hsat Hmwf.
  unfold surface_collision.f_find_wall_collisions in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some ?LE |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 vr]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
    cbn [nth_error] in Hn0; injection Hn0 as ->;
    assert (Hled : LE ! surface_collision._colData = Some (Vptr b_out oo))
      by (eapply sc_bind_colData; exact Hbp)
  end.
  cbn [fn_body] in Hbody.
  destruct (cw_walk ge empty_env bm not_tainted MWF [] fc_stat (fun x H => match H with end)
              (fun x _ => PTree.gempty _ x) Hsym b_out oo false
              surface_collision._colData surface_collision._find_wall_collisions_from_list 1
              Hbp (PTree.gempty _ _) Hcall _ _ _ _ _ _ _ Hbody
              find_wall_collisions_cw_chk Hled Hv Hsat Hmwf)
    as (Hvb & Hsatb & Hmwfb & _).
  rewrite (eq_refl : blocks_of_env ge empty_env = nil) in Hfl.
  cbn [Mem.free_list] in Hfl. injection Hfl as <-.
  exact (conj Hvb (conj Hsatb Hmwfb)).
Qed.

Lemma find_wall_collisions_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    resolves_to ge surface_collision._find_wall_collisions_from_list
      surface_collision.f_find_wall_collisions_from_list ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_wall_collisions) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_out oo) ->
      blk_pres not_tainted bm MWF b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hsym Hpin.
  apply (find_wall_collisions_body_frame_gated ge MWF bm b_out oo Hsym).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_wall_collisions_from_list_frame_B ge MWF bm b o Hb m0 vargs t0 m0' vres Hfc Hn).
Qed.

(* ====================================================================== *)
(* 5. f32_find_wall_collision: three out-params in EXACT mode (`*xPtr = x` *)
(*    etc.), own local `collision`, and the find_wall_collisions call with *)
(*    &collision.  The hand walk of MathGeomBodies, with each store's      *)
(*    premise narrowed to the cell it writes.                              *)
(* ====================================================================== *)

Lemma sc_efield_local_store_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_coll sid sattr fld fty ch
         ge e le m a2 t le' m' out,
    blk_pres Q bm MWF b_coll ->
    e ! surface_collision._collision = Some (b_coll, Tstruct sid sattr) ->
    True ->
    access_mode fty = By_value ch ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Efield (Evar surface_collision._collision (Tstruct sid sattr)) fld fty) a2)
      t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
Proof.
  intros MWF Q bm b_coll sid sattr fld fty ch ge e le m a2 t le' m' out
         Hbp Hcoll _ Hacc Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (RealFrameValue.eval_lvalue_Efield_base _ _ _ _ _ _ _ _ _ _ Hlv) as (o0 & Hbase) end.
  pose proof (sc_eval_expr_evar_local_struct_block _ _ _ _ _ _ _ _ _ _ _ Hcoll Hbase) as Hloc.
  subst.
  match goal with Hass : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
    cbn [typeof] in Hass; inv Hass end.
  - match goal with Hstv : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ =>
      unfold Mem.storev in Hstv;
      destruct (Hbp _ _ _ _ _ Hstv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
    split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
  - match goal with Hco : access_mode fty = By_copy |- _ =>
      rewrite Hacc in Hco; discriminate Hco end.
  - match goal with Hsb : store_bitfield _ _ _ _ _ _ (Vptr _ _) _ _ _ |- _ => inv Hsb end.
    match goal with Hstv : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ =>
      unfold Mem.storev in Hstv;
      destruct (Hbp _ _ _ _ _ Hstv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
    split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
Qed.

Lemma sc_deref_temp_store_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_out o' T chk
         ge e le m tid a2 t le' m' out,
    cell_pres Q bm MWF chk b_out (Ptrofs.unsigned o') ->
    access_mode T = By_value chk ->
    le ! tid = Some (Vptr b_out o') ->
    True ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Ederef (Etempvar tid (tptr T)) T) a2) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
Proof.
  intros MWF Q bm b_out o' T chk ge e le m tid a2 t le' m' out
         Hcell Hacc Htid _ Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev; rewrite Htid in Hev;
    injection Hev as <- <- end.
  match goal with Hass : assign_loc _ (typeof _) _ _ _ Full _ _ |- _ =>
    cbn [typeof] in Hass; inv Hass end;
  [ | match goal with Hco : access_mode T = By_copy |- _ =>
        rewrite Hacc in Hco; discriminate Hco end ].
  match goal with Hac2 : access_mode T = By_value ?c2 |- _ =>
    rewrite Hacc in Hac2; injection Hac2 as <- end.
  match goal with Hstv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hstv;
    destruct (Hcell _ _ _ Hstv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf') end.
  split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
Qed.

Ltac efstB Hst Hec Hcb Hexec Hac Hv Hs Hm Hv' Hs' Hm' Hr :=
  let Hle := fresh "Hle" in
  edestruct (sc_efield_local_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hst Hec I Hac Hexec Hv Hs Hm) as (Hv' & Hs' & Hm' & Hle & _);
  rewrite Hle in Hr; clear Hle.

Ltac drstB Hst Hac Hexec Htid Hbne Hv Hs Hm Hv' Hs' Hm' Hr :=
  let Hle := fresh "Hle" in
  edestruct (sc_deref_temp_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hst Hac Htid I Hexec Hv Hs Hm) as (Hv' & Hs' & Hm' & Hle & _);
  rewrite Hle in Hr; clear Hle.

Lemma f32_find_wall_collision_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop)
         (bm b_xout b_yout b_zout : block) (oxo oyo ozo : ptrofs),
    frame_oracles bm MWF ->
    callee_frame ge bm not_tainted MWF surface_collision._find_wall_collisions 0 ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_f32_find_wall_collision) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_xout oxo) ->
      nth_error vargs 1 = Some (Vptr b_yout oyo) ->
      nth_error vargs 2 = Some (Vptr b_zout ozo) ->
      out_cell not_tainted bm MWF b_xout oxo -> out_cell not_tainted bm MWF b_yout oyo ->
      out_cell not_tainted bm MWF b_zout ozo ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_xout b_yout b_zout oxo oyo ozo Hor Hcall
         m vargs t m' vres Hevf Hn0 Hn1 Hn2 Hcx Hcy Hcz Hv Hsat Hmwf.
  destruct Hor as (Halloc & Hfree & HallocB).
  assert (HcxF : cell_pres not_tainted bm MWF Mfloat32 b_xout (Ptrofs.unsigned oxo))
    by (apply Hcx; cbn; lia).
  assert (HcyF : cell_pres not_tainted bm MWF Mfloat32 b_yout (Ptrofs.unsigned oyo))
    by (apply Hcy; cbn; lia).
  assert (HczF : cell_pres not_tainted bm MWF Mfloat32 b_zout (Ptrofs.unsigned ozo))
    by (apply Hcz; cbn; lia).
  assert (Hacf : access_mode tfloat = By_value Mfloat32) by reflexivity.
  assert (Hacs : access_mode tshort = By_value Mint16signed) by reflexivity.
  unfold surface_collision.f_f32_find_wall_collision in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  (* ENTRY: alloc the _collision struct, bind the 5 params *)
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hcoll_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HcollB : blk_pres not_tainted bm MWF bb) by (eapply HallocB; eassumption);
    assert (HownC : forall x, In x [surface_collision._collision] ->
              exists b ty, (PTree.set surface_collision._collision
                        (bb, Tstruct surface_collision._WallCollisionData noattr) empty_env) ! x
                        = Some (b, ty) /\ blk_pres not_tainted bm MWF b)
      by (intros x [<- | []]; eexists _, _; split; [ apply PTree.gss | exact HcollB ]);
    assert (Hecoll : (PTree.set surface_collision._collision
                        (bb, Tstruct surface_collision._WallCollisionData noattr) empty_env)
                       ! surface_collision._collision
                     = Some (bb, Tstruct surface_collision._WallCollisionData noattr))
      by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc;[exact Halc|exact Hmwf]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc;[exact Halc|exact Hv]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  (* the 3 out-param temps from the bind *)
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some _ |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 [|a5 vr]]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
    cbn [nth_error] in Hn0, Hn1, Hn2;
    injection Hn0 as ->; injection Hn1 as ->; injection Hn2 as ->;
    destruct (fwc_bind_three _ _ _ _ _ _ _ _ _ _ _ _ Hbp) as (Hlx & Hly & Hlz)
  end.
  assert (Htp0 : three_ptr _ b_xout b_yout b_zout oxo oyo ozo)
    by (unfold three_ptr; exact (conj Hlx (conj Hly Hlz))).
  cbn [fn_body] in Hbody.
  (* ---- S1: Sset numCollisions 0 ---- *)
  peelc Hbody.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._numCollisions _) _ _ _ _ |- _ => rename H into HS1 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._offsetY _) _) _) _ _ _ _ |- _ => rename H into R1 end.
  ssettp HS1 Htp0 Em1 Htp1.
  rewrite Em1 in R1.
  (* ---- S2: collision.offsetY = offsetY ---- *)
  peelc R1.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._offsetY _) _) _ _ _ _ |- _ => rename H into HS2 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._radius _) _) _) _ _ _ _ |- _ => rename H into R2 end.
  efstB HcollB Hecoll Hcoll_bm HS2 Hacf HvA HsatA HmwfA Hv2 Hs2 Hm2 R2.
  (* ---- S3: collision.radius = radius ---- *)
  peelc R2.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._radius _) _) _ _ _ _ |- _ => rename H into HS3 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'7 _) _) _) _ _ _ _ |- _ => rename H into R3 end.
  efstB HcollB Hecoll Hcoll_bm HS3 Hacf Hv2 Hs2 Hm2 Hv3 Hs3 Hm3 R3.
  (* ---- S4: t'7 = *xPtr; collision.x = t'7 ---- *)
  peelc R3.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'7 _) _) _ _ _ _ |- _ => rename H into B4 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'6 _) _) _) _ _ _ _ |- _ => rename H into R4 end.
  peelc B4.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'7 _) _ _ _ _ |- _ => rename H into HR4 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._x _) _) _ _ _ _ |- _ => rename H into HW4 end.
  ssettp HR4 Htp1 Em4 Htp4.
  rewrite Em4 in HW4.
  efstB HcollB Hecoll Hcoll_bm HW4 Hacf Hv3 Hs3 Hm3 Hv4 Hs4 Hm4 R4.
  (* ---- S5: t'6 = *yPtr; collision.y = t'6 ---- *)
  peelc R4.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'6 _) _) _ _ _ _ |- _ => rename H into B5 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'5 _) _) _) _ _ _ _ |- _ => rename H into R5 end.
  peelc B5.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'6 _) _ _ _ _ |- _ => rename H into HR5 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._y _) _) _ _ _ _ |- _ => rename H into HW5 end.
  ssettp HR5 Htp4 Em5 Htp5.
  rewrite Em5 in HW5.
  efstB HcollB Hecoll Hcoll_bm HW5 Hacf Hv4 Hs4 Hm4 Hv5 Hs5 Hm5 R5.
  (* ---- S6: t'5 = *zPtr; collision.z = t'5 ---- *)
  peelc R5.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'5 _) _) _ _ _ _ |- _ => rename H into B6 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._numWalls _) _) _) _ _ _ _ |- _ => rename H into R6 end.
  peelc B6.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'5 _) _ _ _ _ |- _ => rename H into HR6 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._z _) _) _ _ _ _ |- _ => rename H into HW6 end.
  ssettp HR6 Htp5 Em6 Htp6.
  rewrite Em6 in HW6.
  efstB HcollB Hecoll Hcoll_bm HW6 Hacf Hv5 Hs5 Hm5 Hv6 Hs6 Hm6 R6.
  (* ---- S7: collision.numWalls = 0 (tshort) ---- *)
  peelc R6.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._numWalls _) _) _ _ _ _ |- _ => rename H into HS7 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Scall _ _ _) _) _) _ _ _ _ |- _ => rename H into R7 end.
  efstB HcollB Hecoll Hcoll_bm HS7 Hacs Hv6 Hs6 Hm6 Hv7 Hs7 Hm7 R7.
  (* ---- S8: t'1 = find_wall_collisions(&collision); numCollisions = t'1 ---- *)
  peelc R7.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) _) _ _ _ _ |- _ => rename H into B8 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'4 _) _) _) _ _ _ _ |- _ => rename H into R8 end.
  peelc B8.
  match goal with H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => rename H into HC8 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._numCollisions _) _ _ _ _ |- _ => rename H into HN8 end.
  pose proof Htp6 as Htp6x. unfold three_ptr in Htp6x. destruct Htp6x as (Hx6 & _ & _).
  edestruct (cw_call_pres ge _ bm not_tainted MWF [surface_collision._collision] [] HownC
               (fun x H => match H with end) (fun x bg H => match H with end)
               b_xout oxo true surface_collision._xPtr surface_collision._find_wall_collisions 0
               eq_refl Hcall Hcx _ _ _ _ _ _ _ _ _ HC8 ltac:(vm_compute; reflexivity) Hx6 Hv7 Hs7 Hm7)
    as (Hv8 & Hs8 & Hm8 & _ & (vcall & Hlecall)).
  cbn [set_opttemp] in Hlecall.
  assert (Htpcall : three_ptr (PTree.set surface_collision._t'1 vcall _) b_xout b_yout b_zout oxo oyo ozo)
    by (apply three_ptr_set;
        [ vm_compute;discriminate | vm_compute;discriminate | vm_compute;discriminate | exact Htp6 ]).
  rewrite <- Hlecall in Htpcall.
  ssettp HN8 Htpcall Em8 Htp8.
  rewrite Em8 in R8.
  (* ---- S9: t'4 = collision.x; *xPtr = t'4 ---- *)
  peelc R8.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'4 _) _) _ _ _ _ |- _ => rename H into B9 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'3 _) _) _) _ _ _ _ |- _ => rename H into R9 end.
  peelc B9.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'4 _) _ _ _ _ |- _ => rename H into HR9 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._xPtr _) _) _) _ _ _ _ |- _ => rename H into HW9 end.
  ssettp HR9 Htp8 Em9 Htp9.
  rewrite Em9 in HW9.
  drstB HcxF Hacf HW9 (three_ptr_x _ _ _ _ _ _ _ Htp9) I Hv8 Hs8 Hm8 Hv9 Hs9 Hm9 R9.
  (* ---- S10: t'3 = collision.y; *yPtr = t'3 ---- *)
  peelc R9.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'3 _) _) _ _ _ _ |- _ => rename H into B10 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'2 _) _) _) _ _ _ _ |- _ => rename H into R10 end.
  peelc B10.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'3 _) _ _ _ _ |- _ => rename H into HR10 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._yPtr _) _) _) _ _ _ _ |- _ => rename H into HW10 end.
  ssettp HR10 Htp9 Em10 Htp10.
  rewrite Em10 in HW10.
  drstB HcyF Hacf HW10 (three_ptr_y _ _ _ _ _ _ _ Htp10) I Hv9 Hs9 Hm9 Hv10 Hs10 Hm10 R10.
  (* ---- S11: t'2 = collision.z; *zPtr = t'2 ---- *)
  peelc R10.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'2 _) _) _ _ _ _ |- _ => rename H into B11 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => rename H into HRET end.
  peelc B11.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'2 _) _ _ _ _ |- _ => rename H into HR11 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._zPtr _) _) _) _ _ _ _ |- _ => rename H into HW11 end.
  ssettp HR11 Htp10 Em11 Htp11.
  rewrite Em11 in HW11.
  drstB HczF Hacf HW11 (three_ptr_z _ _ _ _ _ _ _ Htp11) I Hv10 Hs10 Hm10 Hv11 Hs11 Hm11 HRET.
  (* ---- S12: return numCollisions (memory unchanged) ---- *)
  inv HRET.
  (* EXIT: free the sole _collision block (bm-distinct) *)
  rewrite blocks_of_env_sc_collision in Hfl.
  match goal with Hfl2 : Mem.free_list _ ?L = Some _ |- _ =>
    assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm) L)
      by (constructor; [ exact Hcoll_bm | constructor ]) end.
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv11 Hs11) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | eapply Hfree; [ exact Hfl | exact Hm11 ] ] ].
Qed.

(* f32 with the callee resolved to the real find_wall_collisions (itself
   resolving find_wall_collisions_from_list): no callee premise left. *)
Lemma f32_find_wall_collision_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop)
         (bm b_xout b_yout b_zout : block) (oxo oyo ozo : ptrofs),
    frame_oracles bm MWF ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg ->
       blk_pres not_tainted bm MWF bg) ->
    resolves_to ge surface_collision._find_wall_collisions surface_collision.f_find_wall_collisions ->
    resolves_to ge surface_collision._find_wall_collisions_from_list
      surface_collision.f_find_wall_collisions_from_list ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_f32_find_wall_collision) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_xout oxo) ->
      nth_error vargs 1 = Some (Vptr b_yout oyo) ->
      nth_error vargs 2 = Some (Vptr b_zout ozo) ->
      out_cell not_tainted bm MWF b_xout oxo -> out_cell not_tainted bm MWF b_yout oyo ->
      out_cell not_tainted bm MWF b_zout ozo ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_xout b_yout b_zout oxo oyo ozo Hor Hsym Hpin Hpin2.
  apply (f32_find_wall_collision_body_frame_gated ge MWF bm b_xout b_yout b_zout oxo oyo ozo Hor).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_wall_collisions_body_frame_pinned ge MWF bm b o Hsym Hpin2
           m0 vargs t0 m0' vres Hfc Hn Hb).
Qed.

(* ====================================================================== *)
(* 6. The premises are dischargeable from the consumer's own MWF rows.     *)
(*    (Non-vacuity: each new premise follows from a row shape the spine    *)
(*    already carries and MWFReal already proves.)                         *)
(* ====================================================================== *)

Lemma store_window_ok_mono : forall delta sz sz',
  0 < sz' <= sz -> CensusV2.store_window_ok delta sz = true -> CensusV2.store_window_ok delta sz' = true.
Proof.
  intros delta sz sz' Hsz H. unfold CensusV2.store_window_ok in *.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with Hb : (_ || _)%bool = true |- _ =>
    apply orb_true_iff in Hb; destruct Hb as [Hb | Hb] end;
  repeat match goal with Hb : (_ <=? _) = true |- _ => apply Z.leb_le in Hb end;
  repeat match goal with Hb : (_ <? _) = true |- _ => apply Z.ltb_lt in Hb end;
  repeat (apply andb_true_iff; split);
  try (apply orb_true_iff);
  first [ apply Z.ltb_lt; lia | apply Z.leb_le; lia
        | left; apply Z.leb_le; lia | right; apply Z.leb_le; lia ].
Qed.

Section DISCHARGE.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  (* a Mario-field window: EngineV2Consumer.Hmwf_window's exact shape *)
  Hypothesis Hmwf_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> CensusV2.store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  Lemma out_cell_window : forall delta,
    CensusV2.store_window_ok delta 4 = true -> 0 <= delta <= Ptrofs.max_unsigned ->
    out_cell not_tainted bm MWF bm (Ptrofs.repr delta).
  Proof.
    intros delta Hwin Hrng ch Hsz v m1 m2 Hst Hv Hsat Hmwf.
    rewrite Ptrofs.unsigned_repr in Hst by exact Hrng.
    assert (Hwin' : CensusV2.store_window_ok delta (size_chunk ch) = true)
      by (eapply store_window_ok_mono; [ split; [ destruct ch; cbn; lia | exact Hsz ] | exact Hwin ]).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - intros av Hload.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload; [ exact (Hsat av Hload) | right ].
      unfold CensusV2.store_window_ok in Hwin'.
      repeat (apply andb_true_iff in Hwin'; destruct Hwin' as [Hwin' ?]).
      match goal with
      | Hb : ((delta + _ <=? 12) || (16 <=? delta))%bool = true |- _ =>
          apply orb_true_iff in Hb as [Hb | Hb]; apply Z.leb_le in Hb;
          cbn [size_chunk]; lia
      end.
    - exact (Hmwf_window _ _ _ _ _ Hmwf Hwin' Hst).
  Qed.

  (* a stack-local block: LocalVarsSurface.HMWF_localstore's shape, over
     any predicate L of blocks other than bm *)
  Variable L : block -> Prop.
  Hypothesis HL_bm : forall b, L b -> b <> bm.
  Hypothesis HMWF_localstore : forall m ch b d v m',
      L b -> Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.

  Lemma blk_pres_local : forall b, L b -> blk_pres not_tainted bm MWF b.
  Proof.
    intros b HL ch o v m1 m2 Hst Hv Hsat Hmwf.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (HL_bm b HL Hb).
    - exact (HMWF_localstore _ _ _ _ _ _ HL Hst Hmwf).
  Qed.

  Lemma out_cell_local : forall b o, L b -> out_cell not_tainted bm MWF b o.
  Proof. intros b o HL ch _. exact (blk_pres_local b HL ch _). Qed.

  (* a stored static: EngineV2Consumer.Hmwf_glob's shape *)
  Lemma blk_pres_glob : forall bg,
    bg <> bm -> (forall mm mm' ch0 (d : Z) vv, MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm') ->
    blk_pres not_tainted bm MWF bg.
  Proof.
    intros bg Hne Hst' ch o v m1 m2 Hst Hv Hsat Hmwf.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (Hne Hb).
    - exact (Hst' _ _ _ _ _ Hmwf Hst).
  Qed.
End DISCHARGE.

(* the out-params update_mario_geometry_inputs actually passes are inside
   Mario's block -- &m->floor, &m->pos[0..2] -- and every one of them is a
   window cell (checked against mario.prog's own layout) *)
Lemma geometry_outparams_in_window :
  forall fld, In fld [mario._floor; mario._pos] ->
  exists delta, field_offset (prog_comp_env mario.prog) fld SymbolicLinking.mario_state_members
                  = Errors.OK (delta, Full)
    /\ forall i, (0 <= i < (if Pos.eqb fld mario._pos then 3 else 1))%Z ->
         CensusV2.store_window_ok (delta + 4 * i) 4 = true
         /\ 0 <= delta + 4 * i <= Ptrofs.max_unsigned.
Proof.
  intros fld [<- | [<- | []]].
  - eexists. split; [ vm_compute; reflexivity | ].
    intros i Hi. cbn in Hi. assert (i = 0) by lia. subst i. split; [ vm_compute; reflexivity | ].
    vm_compute. split; discriminate.
  - eexists. split; [ vm_compute; reflexivity | ].
    intros i Hi. cbn in Hi.
    assert (i = 0 \/ i = 1 \/ i = 2) as [-> | [-> | ->]] by lia;
      (split; [ vm_compute; reflexivity | vm_compute; split; discriminate ]).
Qed.

(* ====================================================================== *)
(* 7. The math_util vec3 writers: vec3f_set, vec3f_copy, vec3s_copy.       *)
(*    Their out-param is a 3-element array; at the censused call sites it  *)
(*    is m->pos (a Mario window) or a SafeB object field (camera state,    *)
(*    gfx scale).  Every element store is a float/short cast, so a         *)
(*    NON-POINTER value: the premise is that the three element cells take  *)
(*    non-pointer stores (vec_out), which a SafeB block does (Hmwf_chase). *)
(* ====================================================================== *)

Definition nonptr (v : val) : Prop := forall b o, v <> Vptr b o.

Section NP.
  Variable Q : int -> Prop.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  Definition cell_pres_np (ch : memory_chunk) (b : block) (z : Z) : Prop :=
    forall v m1 m2, nonptr v -> Mem.store ch m1 b z v = Some m2 ->
      Mem.valid_block m1 bm -> action_sat Q m1 bm -> MWF m1 ->
      Mem.valid_block m2 bm /\ action_sat Q m2 bm /\ MWF m2.

  Definition vec_out (ch : memory_chunk) (b : block) (o : ptrofs) : Prop :=
    forall i, 0 <= i < 3 ->
      cell_pres_np ch b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr (size_chunk ch * i)))).
End NP.

Lemma sem_cast_scalar_nonptr : forall v ty m v',
  (sem_cast v ty tfloat m = Some v' \/ sem_cast v ty tshort m = Some v') -> nonptr v'.
Proof.
  intros v ty m v' [H | H]; intros b o E; subst v'; unfold sem_cast in H;
    destruct ty as [ | [] [] ? | [] ? | [] ? | ? ? | ? ? ? | ? ? ? | ? ? | ? ? ];
    cbn in H; destruct v; try discriminate H;
    repeat match goal with
           | H : match ?x with _ => _ end = Some _ |- _ => destruct x; try discriminate H
           end;
    try discriminate H.
Qed.

(* the element address of `*(p + i)` for a float/short array pointer *)
Lemma vec_elem_lvalue :
  forall ge e le m tid T b o ii loc ofs bf,
    le ! tid = Some (Vptr b o) -> (T = tfloat \/ T = tshort) ->
    eval_lvalue ge e le m
      (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T) loc ofs bf ->
    loc = b /\ ofs = Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof ge T)) (Ptrofs.of_ints ii))
    /\ bf = Full.
Proof.
  intros ge e le m tid T b o ii loc ofs bf Htid HT Hlv.
  inv Hlv.
  match goal with Hev : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hev end;
    [ | match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end ].
  match goal with H1 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in H1; rewrite Htid in H1; injection H1 as <- end.
  match goal with H2 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H2 end;
    [ | match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end ].
  match goal with Hb : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    destruct HT as [-> | ->]; cbn in Hb; injection Hb as <- <- end;
  repeat split.
Qed.

Lemma vec_shadow_store_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_dest b_out oo T ge e le m t le' m' out,
    blk_pres Q bm MWF b_dest ->
    e ! math_util._dest = Some (b_dest, tptr T) ->
    le ! math_util._dest = Some (Vptr b_out oo) ->
    True ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Evar math_util._dest (tptr T)) (Etempvar math_util._dest (tptr T)))
      t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ Mem.load Mptr m' b_dest 0 = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_dest b_out oo T ge e le m t le' m' out
         Hbp Hedest Hledest _ Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hedest in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = b_dest) by congruence; subst loc end.
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) ?v2 |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev;
    assert (Hv2e : v2 = Vptr b_out oo) by congruence; rewrite Hv2e in * end.
  match goal with Hc : sem_cast (Vptr b_out oo) _ _ _ = Some ?v |- _ =>
    assert (Hvv : v = Vptr b_out oo) by (cbn in Hc; congruence); rewrite Hvv in * end.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [access_mode typeof] in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hsv; rewrite Ptrofs.unsigned_zero in Hsv end.
  match goal with Hsv : Mem.store Mptr _ b_dest 0 _ = Some m' |- _ =>
    destruct (Hbp _ _ _ _ _ Hsv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf');
    split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ];
    pose proof (Mem.load_store_same _ _ _ _ _ _ Hsv) as Hls end.
  replace (Val.load_result Mptr (Vptr b_out oo)) with (Vptr b_out oo) in Hls
    by (unfold Mptr; reflexivity).
  exact Hls.
Qed.

Lemma out_store_avoids_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) (bm b_out : block) (o' : ptrofs)
         (T : type) (chk : memory_chunk) (ge : genv) e le m tid ii rhs t le' m' out,
    cell_pres_np Q bm MWF chk b_out
      (Ptrofs.unsigned (Ptrofs.add o' (Ptrofs.mul (Ptrofs.repr (sizeof ge T)) (Ptrofs.of_ints ii)))) ->
    access_mode T = By_value chk ->
    le ! tid = Some (Vptr b_out o') ->
    (T = tfloat \/ T = tshort) ->
    exec_stmt function_entry2 ge e le m
      (Sassign
        (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
        rhs) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ (forall bx ox, bx <> b_out -> Mem.load Mptr m' bx ox = Mem.load Mptr m bx ox).
Proof.
  intros MWF Q bm b_out o' T chk ge e le m tid ii rhs t le' m' out
         Hcell Hac Htid HT Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    destruct (vec_elem_lvalue _ _ _ _ _ _ _ _ _ _ _ _ Htid HT Hlv) as (-> & -> & ->) end.
  match goal with Hc : sem_cast _ _ _ _ = Some ?v |- _ =>
    assert (Hnp : nonptr v)
      by (eapply sem_cast_scalar_nonptr; cbn [typeof] in Hc;
          destruct HT as [E | E]; rewrite E in Hc; [ left | right ]; exact Hc) end.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [typeof] in Ham; rewrite Hac in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [typeof] in Ham; rewrite Hac in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ _ = Some _ |- _ => rename Hsv into Hstv end.
  unfold Mem.storev in Hstv.
  destruct (Hcell _ _ _ Hnp Hstv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf').
  split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ].
  intros bx ox Hbx. eapply Mem.load_store_other; [ exact Hstv | left; exact Hbx ].
Qed.

Lemma vec_block_set_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_dest b_out oo T chk (ge : genv) e le m
         tid ii rhs t le' m' out,
    cell_pres_np Q bm MWF chk b_out
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.mul (Ptrofs.repr (sizeof ge T)) (Ptrofs.of_ints ii)))) ->
    access_mode T = By_value chk ->
    e ! math_util._dest = Some (b_dest, tptr T) ->
    Mem.load Mptr m b_dest 0 = Some (Vptr b_out oo) ->
    (T = tfloat \/ T = tshort) -> b_out <> b_dest ->
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset tid (Evar math_util._dest (tptr T)))
        (Sassign
          (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
          rhs)) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ Mem.load Mptr m' b_dest 0 = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_dest b_out oo T chk ge e le m tid ii rhs t le' m' out
         Hcell Hac Hedest Hload HT Hbdne Hexec Hv Hsat Hmwf.
  peelseq.
  match goal with HSset : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
    rename HSset into HSset0 end.
  match goal with HStore : exec_stmt _ _ _ _ _ (Sassign (Ederef _ _) _) _ _ _ _ |- _ =>
    rename HStore into HStore0 end.
  destruct (sset_shadow_reads _ _ _ _ _ _ _ _ _ _ _ _ _ Hedest Hload HSset0)
    as (Em & Hout & Htid).
  subst.
  destruct (out_store_avoids_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hcell Hac Htid HT HStore0 Hv Hsat Hmwf)
    as (Hv' & Hsat' & Hmwf' & Hpres).
  split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ].
  rewrite (Hpres b_dest 0 (not_eq_sym Hbdne)). exact Hload.
Qed.

Lemma vec_block_copy_B :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_dest b_out oo T chk (ge : genv) e le m
         tid1 tid2 srcexpr ii t le' m' out,
    cell_pres_np Q bm MWF chk b_out
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.mul (Ptrofs.repr (sizeof ge T)) (Ptrofs.of_ints ii)))) ->
    access_mode T = By_value chk ->
    e ! math_util._dest = Some (b_dest, tptr T) ->
    Mem.load Mptr m b_dest 0 = Some (Vptr b_out oo) ->
    (T = tfloat \/ T = tshort) -> b_out <> b_dest -> tid1 <> tid2 ->
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset tid1 (Evar math_util._dest (tptr T)))
        (Ssequence (Sset tid2 srcexpr)
          (Sassign
            (Ederef (Ebinop Oadd (Etempvar tid1 (tptr T)) (Econst_int ii tint) (tptr T)) T)
            (Etempvar tid2 T)))) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ Mem.load Mptr m' b_dest 0 = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_dest b_out oo T chk ge e le m tid1 tid2 srcexpr ii t le' m' out
         Hcell Hac Hedest Hload HT Hbdne Htne Hexec Hv Hsat Hmwf.
  peelseq.
  match goal with HSset : exec_stmt _ _ _ _ _ (Sset tid1 _) _ _ _ _ |- _ =>
    rename HSset into HSset0 end.
  destruct (sset_shadow_reads _ _ _ _ _ _ _ _ _ _ _ _ _ Hedest Hload HSset0)
    as (Em & Hout & Htid1).
  subst.
  peelseq.
  match goal with HSset2 : exec_stmt _ _ _ _ _ (Sset tid2 _) _ _ _ _ |- _ => inv HSset2 end.
  match goal with HStore : exec_stmt _ _ _ ?lenv _ (Sassign (Ederef _ _) _) _ _ _ _ |- _ =>
    rename HStore into HStore0;
    assert (Htid1' : lenv ! tid1 = Some (Vptr b_out oo))
      by (rewrite PTree.gso by exact Htne; exact Htid1) end.
  destruct (out_store_avoids_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hcell Hac Htid1' HT HStore0 Hv Hsat Hmwf)
    as (Hv' & Hsat' & Hmwf' & Hpres).
  split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ].
  rewrite (Hpres b_dest 0 (not_eq_sym Hbdne)). exact Hload.
Qed.

(* vec_out's cells are exactly the three element addresses *)
Lemma vec_out_cell : forall Q bm MWF ch T b o (ge : genv) i,
  vec_out Q bm MWF ch b o -> sizeof ge T = size_chunk ch -> 0 <= i < 3 ->
  cell_pres_np Q bm MWF ch b
    (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof ge T)) (Ptrofs.of_ints (Int.repr i))))).
Proof.
  intros Q bm MWF ch T b o ge i Hvo Hsz Hi.
  replace (Ptrofs.mul (Ptrofs.repr (sizeof ge T)) (Ptrofs.of_ints (Int.repr i)))
    with (Ptrofs.repr (size_chunk ch * i)); [ exact (Hvo i Hi) | ].
  rewrite Hsz.
  assert (i = 0 \/ i = 1 \/ i = 2) as [-> | [-> | ->]] by lia;
    destruct ch; vm_compute; reflexivity.
Qed.

Lemma vec3f_set_body_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3f_set) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      vec_out not_tainted bm MWF Mfloat32 b_out oo -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor m vargs t m' vres
         Hevf Hhd Hvo Hbov Hv Hsat Hmwf.
  destruct Hor as (Halloc & Hfree & HallocB).
  pose proof (vec_out_cell _ _ _ _ tfloat _ _ ge 0 Hvo eq_refl ltac:(lia)) as Hc0.
  pose proof (vec_out_cell _ _ _ _ tfloat _ _ ge 1 Hvo eq_refl ltac:(lia)) as Hc1.
  pose proof (vec_out_cell _ _ _ _ tfloat _ _ ge 2 Hvo eq_refl ltac:(lia)) as Hc2.
  assert (Hacf : access_mode tfloat = By_value Mfloat32) by reflexivity.
  unfold math_util.f_vec3f_set in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  (* ENTRY: alloc the _dest shadow, bind params *)
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HbdB : blk_pres not_tainted bm MWF bb) by (eapply HallocB; eassumption);
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tfloat) empty_env)
                       ! math_util._dest = Some (bb, tptr tfloat)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  (* le!_dest = Vptr b_out oo *)
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|[E|[E|E]]]; try discriminate E; exact E)
  end.
  (* WALK: shadow store, then three vec3f_set store blocks, then Sreturn+free *)
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              HbdB Hedest Hled I HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_set_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc0 Hacf Hedest Hload1 (or_introl eq_refl) (not_eq_sym Hbd_bo) HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_set_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc1 Hacf Hedest Hload2 (or_introl eq_refl) (not_eq_sym Hbd_bo) HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_set_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc2 Hacf Hedest Hload3 (or_introl eq_refl) (not_eq_sym Hbd_bo) HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  (* Sreturn: memory unchanged *)
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  (* EXIT: free the sole shadow block (bm-distinct) *)
  rewrite blocks_of_env_mu_dest in Hfl.
  match goal with |- _ =>
    assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                        ((_, 0, sizeof ge (tptr tfloat)) :: nil))
      by (constructor; [ exact Hbd_bm | constructor ])
  end.
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.

Lemma vec3f_copy_body_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3f_copy) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      vec_out not_tainted bm MWF Mfloat32 b_out oo -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor m vargs t m' vres
         Hevf Hhd Hvo Hbov Hv Hsat Hmwf.
  destruct Hor as (Halloc & Hfree & HallocB).
  pose proof (vec_out_cell _ _ _ _ tfloat _ _ ge 0 Hvo eq_refl ltac:(lia)) as Hc0.
  pose proof (vec_out_cell _ _ _ _ tfloat _ _ ge 1 Hvo eq_refl ltac:(lia)) as Hc1.
  pose proof (vec_out_cell _ _ _ _ tfloat _ _ ge 2 Hvo eq_refl ltac:(lia)) as Hc2.
  assert (Hacf : access_mode tfloat = By_value Mfloat32) by reflexivity.
  assert (Hne56 : math_util._t'5 <> math_util._t'6) by (cbv; discriminate).
  assert (Hne34 : math_util._t'3 <> math_util._t'4) by (cbv; discriminate).
  assert (Hne12 : math_util._t'1 <> math_util._t'2) by (cbv; discriminate).
  unfold math_util.f_vec3f_copy in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HbdB : blk_pres not_tainted bm MWF bb) by (eapply HallocB; eassumption);
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tfloat) empty_env)
                       ! math_util._dest = Some (bb, tptr tfloat)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|E]; try discriminate E; exact E)
  end.
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              HbdB Hedest Hled I HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_copy_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc0 Hacf Hedest Hload1 (or_introl eq_refl) (not_eq_sym Hbd_bo) Hne56 HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_copy_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc1 Hacf Hedest Hload2 (or_introl eq_refl) (not_eq_sym Hbd_bo) Hne34 HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_copy_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc2 Hacf Hedest Hload3 (or_introl eq_refl) (not_eq_sym Hbd_bo) Hne12 HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  rewrite blocks_of_env_mu_dest in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge (tptr tfloat)) :: nil))
    by (constructor; [ exact Hbd_bm | constructor ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.

Lemma vec3s_copy_body_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3s_copy) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      vec_out not_tainted bm MWF Mint16signed b_out oo -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor m vargs t m' vres
         Hevf Hhd Hvo Hbov Hv Hsat Hmwf.
  destruct Hor as (Halloc & Hfree & HallocB).
  pose proof (vec_out_cell _ _ _ _ tshort _ _ ge 0 Hvo eq_refl ltac:(lia)) as Hc0.
  pose proof (vec_out_cell _ _ _ _ tshort _ _ ge 1 Hvo eq_refl ltac:(lia)) as Hc1.
  pose proof (vec_out_cell _ _ _ _ tshort _ _ ge 2 Hvo eq_refl ltac:(lia)) as Hc2.
  assert (Hacs : access_mode tshort = By_value Mint16signed) by reflexivity.
  assert (Hne56 : math_util._t'5 <> math_util._t'6) by (cbv; discriminate).
  assert (Hne34 : math_util._t'3 <> math_util._t'4) by (cbv; discriminate).
  assert (Hne12 : math_util._t'1 <> math_util._t'2) by (cbv; discriminate).
  unfold math_util.f_vec3s_copy in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HbdB : blk_pres not_tainted bm MWF bb) by (eapply HallocB; eassumption);
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tshort) empty_env)
                       ! math_util._dest = Some (bb, tptr tshort)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|E]; try discriminate E; exact E)
  end.
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              HbdB Hedest Hled I HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_copy_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc0 Hacs Hedest Hload1 (or_intror eq_refl) (not_eq_sym Hbd_bo) Hne56 HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_copy_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc1 Hacs Hedest Hload2 (or_intror eq_refl) (not_eq_sym Hbd_bo) Hne34 HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_copy_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc2 Hacs Hedest Hload3 (or_intror eq_refl) (not_eq_sym Hbd_bo) Hne12 HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  rewrite blocks_of_env_mu_dest in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge (tptr tshort)) :: nil))
    by (constructor; [ exact Hbd_bm | constructor ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.

(* ---- the vec_out premise is dischargeable from the consumer's rows ---- *)
Section VEC_DISCHARGE.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  Lemma vec_out_of_blk : forall ch b o,
    blk_pres not_tainted bm MWF b -> vec_out not_tainted bm MWF ch b o.
  Proof. intros ch b o Hbp i _ v m1 m2 _. exact (Hbp ch _ v m1 m2). Qed.

  (* a SafeB chase target: EngineV2Consumer.Hmwf_chase's exact shape *)
  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis Hmwf_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  Lemma vec_out_safeb : forall ch b o, SafeB b -> vec_out not_tainted bm MWF ch b o.
  Proof.
    intros ch b o Hs i _ v m1 m2 Hnp Hst Hv Hsat Hmwf.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i0 _ [Hb _]. exact (HSafeNotBm b Hs Hb).
    - exact (Hmwf_chase _ _ _ _ _ _ Hmwf Hs Hnp Hst).
  Qed.

  (* a Mario-field window *)
  Hypothesis Hmwf_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> CensusV2.store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  Lemma vec_out_window : forall ch delta,
    (forall i, 0 <= i < 3 ->
       CensusV2.store_window_ok (delta + size_chunk ch * i) (size_chunk ch) = true
       /\ 0 <= delta + size_chunk ch * i <= Ptrofs.max_unsigned) ->
    0 <= delta <= Ptrofs.max_unsigned ->
    vec_out not_tainted bm MWF ch bm (Ptrofs.repr delta).
  Proof.
    intros ch delta Hcells Hd i Hi v m1 m2 _ Hst Hv Hsat Hmwf.
    destruct (Hcells i Hi) as (Hwin & Hrng).
    assert (Hsz : 0 <= size_chunk ch * i <= Ptrofs.max_unsigned).
    { pose proof (size_chunk_pos ch). split; nia. }
    rewrite Ptrofs.add_unsigned in Hst.
    rewrite (Ptrofs.unsigned_repr delta) in Hst by lia.
    rewrite (Ptrofs.unsigned_repr (size_chunk ch * i)) in Hst by nia.
    rewrite Ptrofs.unsigned_repr in Hst by nia.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - intros av Hload.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload; [ exact (Hsat av Hload) | right ].
      unfold CensusV2.store_window_ok in Hwin.
      repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
      match goal with
      | Hb : ((_ + _ <=? 12) || (16 <=? _))%bool = true |- _ =>
          apply orb_true_iff in Hb as [Hb | Hb]; apply Z.leb_le in Hb;
          cbn [size_chunk]; lia
      end.
    - exact (Hmwf_window _ _ _ _ _ Hmwf Hwin Hst).
  Qed.
End VEC_DISCHARGE.

(* the one Mario-window vec3 destination a censused body passes
   (update_mario_geometry_inputs: vec3f_copy(m->pos, ...)) is a window *)
Lemma pos_vec_in_window :
  exists delta, field_offset (prog_comp_env mario.prog) mario._pos SymbolicLinking.mario_state_members
                  = Errors.OK (delta, Full)
    /\ (forall i, 0 <= i < 3 ->
          CensusV2.store_window_ok (delta + size_chunk Mfloat32 * i) (size_chunk Mfloat32) = true
          /\ 0 <= delta + size_chunk Mfloat32 * i <= Ptrofs.max_unsigned)
    /\ 0 <= delta <= Ptrofs.max_unsigned.
Proof.
  eexists. split; [ vm_compute; reflexivity | split ].
  - intros i Hi.
    assert (i = 0 \/ i = 1 \/ i = 2) as [-> | [-> | ->]] by lia;
      (split; [ vm_compute; reflexivity | vm_compute; split; discriminate ]).
  - vm_compute; split; discriminate.
Qed.

(* ====================================================================== *)
(* 8. atan2s: its callee premise (for ALL envs, a call named atan2_lookup  *)
(*    keeps memory) was false (a local shadow can point the name at any   *)
(*    function block).  atan2s has no locals, so the name resolves to the  *)
(*    global; with the link resolving it to the real atan2_lookup body,    *)
(*    whose memory identity is proved, nothing is left to assume.          *)
(* ====================================================================== *)

Definition is_atan2_lookup_gcall (a : expr) : bool :=
  match a with
  | Evar id (Tfunction _ _ _) => Pos.eqb id math_util._atan2_lookup
  | _ => false
  end.

Fixpoint cpure2_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ => true
  | Sset _ _ => true
  | Scall _ a _ => is_atan2_lookup_gcall a
  | Ssequence s1 s2 => cpure2_chk s1 && cpure2_chk s2
  | Sifthenelse _ s1 s2 => cpure2_chk s1 && cpure2_chk s2
  | Sloop s1 s2 => cpure2_chk s1 && cpure2_chk s2
  | _ => false
  end.

Lemma atan2s_cpure2_chk : cpure2_chk (fn_body math_util.f_atan2s) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cpure2_walk :
  forall (ge : genv),
    resolves_to ge math_util._atan2_lookup math_util.f_atan2_lookup ->
    forall s le m tr le' m' out,
      exec_stmt function_entry2 ge empty_env le m s tr le' m' out ->
      cpure2_chk s = true -> m' = m.
Proof.
  intros ge Hpin s le m tr le' m' out Hexec.
  remember empty_env as e0 eqn:He0.
  induction Hexec; intros Hchk; try reflexivity; try discriminate Hchk;
    try (match goal with H : ?x = empty_env |- _ => subst x end).
  - (* Scall *)
    cbn [cpure2_chk] in Hchk.
    destruct a; try discriminate Hchk. destruct t0; try discriminate Hchk.
    apply Pos.eqb_eq in Hchk. subst i.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
      unfold Genv.find_funct in Hff;
      destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | NE]; [ | congruence ] end.
    match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?f, Hfc : eval_funcall _ _ _ ?f _ _ _ _ |- _ =>
      rewrite (Hpin _ _ Hsy Hfp) in Hfc; exact (atan2_lookup_memid _ _ _ _ _ _ Hfc) end.
  - cbn [cpure2_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    rewrite (IHHexec2 eq_refl H2). exact (IHHexec1 eq_refl H1).
  - cbn [cpure2_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
    exact (IHHexec eq_refl H1).
  - cbn [cpure2_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    apply IHHexec; [ reflexivity | destruct b; assumption ].
  - cbn [cpure2_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
    exact (IHHexec eq_refl H1).
  - cbn [cpure2_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    rewrite (IHHexec2 eq_refl H2). exact (IHHexec1 eq_refl H1).
  - cbn [cpure2_chk] in Hchk.
    pose proof Hchk as Hchk0.
    apply andb_prop in Hchk as [H1 H2].
    rewrite (IHHexec3 eq_refl Hchk0), (IHHexec2 eq_refl H2). exact (IHHexec1 eq_refl H1).
Qed.

Lemma atan2s_memid_pinned :
  forall (ge : genv),
    resolves_to ge math_util._atan2_lookup math_util.f_atan2_lookup ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal math_util.f_atan2s) vargs t m' vres ->
      m' = m.
Proof.
  intros ge Hpin m vargs t m' vres Hevf.
  unfold math_util.f_atan2s in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  pose proof (cpure2_walk ge Hpin _ _ _ _ _ _ _ Hbody atan2s_cpure2_chk) as Em.
  subst m1.
  rewrite (eq_refl : blocks_of_env ge empty_env = nil) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-. reflexivity.
Qed.

Lemma atan2s_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm : block),
    resolves_to ge math_util._atan2_lookup math_util.f_atan2_lookup ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal math_util.f_atan2s) vargs t m' vres ->
      MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm Hpin m vargs t m' vres Hevf Hmwf Hv Hsat.
  rewrite (atan2s_memid_pinned ge Hpin m vargs t m' vres Hevf).
  exact (conj Hv (conj Hsat Hmwf)).
Qed.

(* ====================================================================== *)
(* 9. The engine's argument gate meets the writer frames.                  *)
(*    CensusV2.wgate (handed to the rest leaf by the engine's Hcallgate)   *)
(*    is keyed on the callee's function type.  The real writer bodies'     *)
(*    types ARE those signatures (so the gate is not silently vacuous),    *)
(*    and the gate's content supplies exactly the out_cell / vec_out       *)
(*    premises of sections 3-7.                                            *)
(* ====================================================================== *)

Lemma writer_types_pinned :
  type_of_fundef (Internal surface_collision.f_find_floor) = CensusV2.T_ffc /\
  type_of_fundef (Internal surface_collision.f_find_ceil) = CensusV2.T_ffc /\
  type_of_fundef (Internal surface_collision.f_f32_find_wall_collision) = CensusV2.T_f32w /\
  type_of_fundef (Internal math_util.f_vec3f_copy) = CensusV2.T_v3fcopy /\
  type_of_fundef (Internal math_util.f_vec3f_set) = CensusV2.T_v3fset /\
  type_of_fundef (Internal math_util.f_vec3s_copy) = CensusV2.T_v3scopy.
Proof. vm_compute. repeat split. Qed.

Lemma store_window_ok_sub : forall d n k sz,
  CensusV2.store_window_ok d n = true -> 0 <= k -> 0 < sz -> k + sz <= n ->
  CensusV2.store_window_ok (d + k) sz = true.
Proof.
  intros d n k sz H Hk Hsz Hkn. unfold CensusV2.store_window_ok in *.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with Hb : (_ || _)%bool = true |- _ =>
    apply orb_true_iff in Hb; destruct Hb as [Hb | Hb] end;
  repeat match goal with Hb : (_ <=? _) = true |- _ => apply Z.leb_le in Hb end;
  repeat match goal with Hb : (_ <? _) = true |- _ => apply Z.ltb_lt in Hb end;
  repeat (apply andb_true_iff; split);
  try (apply orb_true_iff);
  first [ apply Z.ltb_lt; lia | apply Z.leb_le; lia
        | left; apply Z.leb_le; lia | right; apply Z.leb_le; lia ].
Qed.

Section GATE.
  Variable bm : block.
  Variable MWF : mem -> Prop.
  Variable SafeB : block -> Prop.
  Hypothesis Hmwf_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> CensusV2.store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis Hmwf_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* a window-gated out-param: find_floor / find_ceil / f32's exact cells *)
  Lemma owin_out_cell : forall v,
    CensusV2.owin bm 4 v -> exists o, v = Vptr bm o /\ out_cell not_tainted bm MWF bm o.
  Proof.
    intros v (o & -> & Hw). exists o. split; [ reflexivity | ].
    rewrite <- (Ptrofs.repr_unsigned o).
    apply (out_cell_window bm MWF Hmwf_window); [ exact Hw | ].
    pose proof (Ptrofs.unsigned_range_2 o). lia.
  Qed.

  (* a window-or-SafeB vec3 out-param: vec3f_copy / vec3f_set / vec3s_copy *)
  Lemma osafe_vec_out : forall n ch v b o,
    size_chunk ch * 3 <= n ->
    CensusV2.osafe bm SafeB n v -> v = Vptr b o -> vec_out not_tainted bm MWF ch b o.
  Proof.
    intros n ch v b o Hn Hg Ev.
    destruct (Hg b o Ev) as [[-> Hw] | Hs].
    - rewrite <- (Ptrofs.repr_unsigned o).
      pose proof (size_chunk_pos ch) as Hp.
      pose proof (Ptrofs.unsigned_range_2 o) as Hr.
      apply (vec_out_window bm MWF Hmwf_window).
      + intros i Hi. split.
        * apply (store_window_ok_sub _ n); [ exact Hw | nia | lia | nia ].
        * pose proof (store_window_ok_sub _ n (size_chunk ch * i) (size_chunk ch) Hw
                        ltac:(nia) ltac:(lia) ltac:(nia)) as Hc.
          unfold CensusV2.store_window_ok in Hc.
          repeat (apply andb_true_iff in Hc; destruct Hc as [Hc ?]).
          repeat match goal with Hb : (_ <=? _) = true |- _ => apply Z.leb_le in Hb end.
          lia.
      + exact Hr.
    - exact (vec_out_safeb bm MWF SafeB HSafeNotBm Hmwf_chase ch b o Hs).
  Qed.
End GATE.
