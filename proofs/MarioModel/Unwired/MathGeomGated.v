(* kept: P1' Unwired pre-stage — the arg-aware re-statements of the four surface_collision aggregator frames, consumed at the future fourteen-TU link commit; NOT yet capstone-wired. *)

(* ====================================================================== *)
(* P1' PRE-REQ P-1 / P-2 (docs/p1prime-atomic-wiring-blueprint.md §4-A, §6). *)
(*                                                                        *)
(* MathGeomBodies.v proved the frames of find_floor, find_ceil,             *)
(* find_wall_collisions and f32_find_wall_collision, but each one assumed   *)
(* a callee oracle "for ALL vargs" and a store oracle "for ALL envs".       *)
(* Both are FALSE in general (an argument or a local shadow pointing at bm  *)
(* breaks them), so those lemmas could never be applied.                    *)
(*                                                                        *)
(* Here the walk sees the concrete call: the callee is the named global    *)
(* (the body's env has no local of that name), and its out-param argument  *)
(* is either the address of one of the body's own fresh locals or the      *)
(* body's own gate pointer -- in both cases a block other than bm.  Stores *)
(* to named variables go to an own local (fresh, <> bm) or to a listed     *)
(* static (its symbol block, <> bm by a layout premise).  So the callee    *)
(* premise only has to hold for arguments that really are bm-free, which   *)
(* the callee's own gated frame (find_floor_from_list_body_frame etc.)     *)
(* gives.  The `_pinned` corollaries discharge it that way.                *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import ActionValueFrame Taint MarioStepSurface RestSurface.
From SM64.Proofs Require CensusV2.
From SM64.Proofs.MarioModel.Unwired Require Import MathGeomBodies.

Import ListNotations.

Definition is_ptr_ty (t : type) : bool := match t with Tpointer _ _ => true | _ => false end.

Definition in_ids (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Lemma in_ids_In : forall x l, in_ids x l = true -> In x l.
Proof.
  intros x l H. unfold in_ids in H. apply existsb_exists in H as (y & Hy & Hxy).
  apply Pos.eqb_eq in Hxy. subst. exact Hy.
Qed.

(* an out-param argument the walk can see is bm-free: the address of one of
   the body's own locals, or the body's gate temp itself *)
Definition arg_ok (g : ident) (own : list ident) (a : expr) : bool :=
  match a with
  | Eaddrof (Evar x _) t => is_ptr_ty t && in_ids x own
  | Etempvar t ty => Pos.eqb t g && is_ptr_ty ty
  | _ => false
  end.

(* a direct call to the named function, whose k-th argument is arg_ok and
   whose k-th parameter is a pointer *)
Definition call_ok (g cid : ident) (k : nat) (own : list ident) (a : expr) (al : list expr) : bool :=
  match a with
  | Evar id (Tfunction targs _ _) =>
      Pos.eqb id cid &&
      (match nth_error al k, nth_error targs k with
       | Some x, Some tx => arg_ok g own x && is_ptr_ty tx
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

Fixpoint cw_chk (g cid : ident) (k : nat) (own stat : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ => true
  | Sset id _ => negb (Pos.eqb id g)
  | Scall optid a al =>
      call_ok g cid k own a al &&
      (match optid with Some ti => negb (Pos.eqb ti g) | None => true end)
  | Sassign lv _ =>
      match CensusV2.chain_root_l lv with
      | Some t =>
          Pos.eqb t g &&
          (match access_mode (typeof lv) with By_value _ => true | _ => false end)
      | None => sym_ok own stat lv
      end
  | Ssequence s1 s2 => cw_chk g cid k own stat s1 && cw_chk g cid k own stat s2
  | Sifthenelse _ s1 s2 => cw_chk g cid k own stat s1 && cw_chk g cid k own stat s2
  | Sloop s1 s2 => cw_chk g cid k own stat s1 && cw_chk g cid k own stat s2
  | _ => false
  end.

(* ---------------------------------------------------------------------- *)
(* Expression facts.                                                       *)
(* ---------------------------------------------------------------------- *)

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

Section ENV.
  Variable ge : genv.
  Variable e : env.
  Variable bm : block.
  Variables own stat : list ident.
  Hypothesis Hown : forall x, In x own -> exists b ty, e ! x = Some (b, ty) /\ b <> bm.
  Hypothesis Hstat : forall x, In x stat -> e ! x = None.
  Hypothesis Hsym : forall x bg, In x stat -> Genv.find_symbol ge x = Some bg -> bg <> bm.

  Lemma evar_lvalue_blk : forall le m x ty b ofs bf,
    eval_lvalue ge e le m (Evar x ty) b ofs bf ->
    (in_ids x own || in_ids x stat) = true -> b <> bm.
  Proof.
    intros le m x ty b ofs bf Hl Hin. apply orb_true_iff in Hin.
    inv Hl.
    - destruct Hin as [Hi | Hi]; apply in_ids_In in Hi.
      + destruct (Hown x Hi) as (b' & ty' & He & Hb). congruence.
      + rewrite (Hstat x Hi) in *. discriminate.
    - destruct Hin as [Hi | Hi]; apply in_ids_In in Hi.
      + destruct (Hown x Hi) as (b' & ty' & He & Hb). congruence.
      + eapply Hsym; eassumption.
  Qed.

  Lemma evar_copy_lvalue : forall le m x ty b ofs,
    eval_expr ge e le m (Evar x ty) (Vptr b ofs) -> access_mode ty = By_copy ->
    exists bf, eval_lvalue ge e le m (Evar x ty) b ofs bf.
  Proof.
    intros le m x ty b ofs H Hac. inv H.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      cbn [typeof] in *; try congruence;
      try (eexists; eassumption);
      match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
  Qed.

  Lemma sym_lvalue_blk : forall le m lv b ofs bf,
    sym_ok own stat lv = true -> eval_lvalue ge e le m lv b ofs bf -> b <> bm.
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
            destruct (evar_copy_lvalue _ _ _ _ _ _ Hx eq_refl) as (bf' & Hl')
        end.
        eapply evar_lvalue_blk; eassumption.
      + match goal with
        | Hx : eval_expr _ _ _ _ (Evar _ _) (Vptr _ _), Ht : typeof (Evar _ _) = Tunion _ _ |- _ =>
            cbn in Ht; subst;
            destruct (evar_copy_lvalue _ _ _ _ _ _ Hx eq_refl) as (bf' & Hl')
        end.
        eapply evar_lvalue_blk; eassumption.
  Qed.

  (* an out-param argument accepted by arg_ok evaluates to a bm-free pointer *)
  Lemma arg_ok_val : forall g le m x v b_out oo,
    arg_ok g own x = true -> eval_expr ge e le m x v ->
    le ! g = Some (Vptr b_out oo) -> b_out <> bm ->
    is_ptr_ty (typeof x) = true /\ exists b o, v = Vptr b o /\ b <> bm.
  Proof.
    intros g le m x v b_out oo Hok Hev Hg Hb.
    destruct x; try discriminate Hok.
    - (* Etempvar *)
      cbn [arg_ok] in Hok. apply andb_prop in Hok as [Hi Hp]. apply Pos.eqb_eq in Hi. subst.
      split; [ exact Hp | ].
      inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Ht : le ! _ = Some v |- _ => rewrite Hg in Ht; injection Ht as <- end.
      exists b_out, oo. split; [ reflexivity | exact Hb ].
    - (* Eaddrof *)
      destruct x; try discriminate Hok.
      cbn [arg_ok] in Hok. apply andb_prop in Hok as [Hp Hi].
      split; [ exact Hp | ].
      inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) ?l ?o _ |- _ =>
        exists l, o; split; [ reflexivity | ];
        eapply evar_lvalue_blk; [ exact Hl | rewrite Hi; reflexivity ]
      end.
  Qed.

  (* a store accepted by sym_ok lands off bm *)
  Lemma sym_assign_pres :
    forall (MWF : mem -> Prop) (Q : int -> Prop) lv rhs le m t le' m' out,
      (forall ch b0 o0 v0 m1 m2,
          b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
      sym_ok own stat lv = true ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros MWF Q lv rhs le m t le' m' out Hstore Hok Hexec Hv Hsat Hmwf.
    assert (Hac : match access_mode (typeof lv) with By_value _ => true | _ => false end = true).
    { destruct lv; try discriminate Hok.
      - cbn [sym_ok] in Hok. apply andb_prop in Hok as [H _]. exact H.
      - destruct lv; try discriminate Hok. cbn [sym_ok] in Hok. apply andb_prop in Hok as [H _].
        exact H. }
    inv Hexec.
    match goal with Hlv : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
      pose proof (sym_lvalue_blk _ _ _ _ _ _ Hok Hlv) as Hbne end.
    match goal with Hass : assign_loc _ (typeof lv) _ _ _ _ _ _ |- _ => inv Hass end.
    - match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv;
        destruct (store_off_bm_pres MWF Q bm _ _ _ _ m m' Hstore Hbne Hsv Hv Hsat Hmwf)
          as (Hv' & Hsat' & Hmwf') end.
      split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
    - match goal with Hco : access_mode (typeof lv) = By_copy |- _ =>
        rewrite Hco in Hac; discriminate Hac end.
    - match goal with Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb end.
      match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv;
        destruct (store_off_bm_pres MWF Q bm _ _ _ _ m m' Hstore Hbne Hsv Hv Hsat Hmwf)
          as (Hv' & Hsat' & Hmwf') end.
      split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
  Qed.

  (* a call accepted by call_ok: the callee is the named global, and the
     callee premise is needed only for a bm-free k-th argument *)
  Lemma cw_call_pres :
    forall (MWF : mem -> Prop) (Q : int -> Prop) (b_out : block) (oo : ptrofs) (g cid : ident) (k : nat),
      e ! cid = None ->
      (forall f m0 vargs t0 m0' vres b o bf,
          Genv.find_symbol ge cid = Some bf -> Genv.find_funct_ptr ge bf = Some f ->
          nth_error vargs k = Some (Vptr b o) -> b <> bm ->
          eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
          Mem.valid_block m0 bm -> action_sat Q m0 bm -> MWF m0 ->
          Mem.valid_block m0' bm /\ action_sat Q m0' bm /\ MWF m0') ->
      forall le m optid a al t le' m' out,
        exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
        call_ok g cid k own a al = true ->
        le ! g = Some (Vptr b_out oo) -> b_out <> bm ->
        Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
        Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ out = Out_normal
          /\ exists v, le' = set_opttemp optid v le.
  Proof.
    intros MWF Q b_out oo g cid k Hcid Hcall le m optid a al t le' m' out Hexec Hok Hg Hb Hv Hsat Hmwf.
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
    destruct (arg_ok_val g le m x v1 b_out oo Harg Hx Hg Hb) as (Hpx & b & o & -> & Hbb).
    rewrite (cast_ptr_ptr _ _ _ _ _ _ Hpx Hpt Hc) in Hvk.
    match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?f, Hfc : eval_funcall _ _ _ ?f _ _ _ _ |- _ =>
      destruct (Hcall _ _ _ _ _ _ _ _ _ Hsy Hfp Hvk Hbb Hfc Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf')
    end.
    split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | split; [ reflexivity | ] ] ] ].
    eexists. reflexivity.
  Qed.

  (* THE WALK *)
  Lemma cw_walk :
    forall (MWF : mem -> Prop) (Q : int -> Prop) (b_out : block) (oo : ptrofs) (g cid : ident) (k : nat)
      (Hstore : forall ch b0 o0 v0 m1 m2,
          b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2)
      (Hbne : b_out <> bm)
      (Hcid : e ! cid = None)
      (Hcall : forall f m0 vargs t0 m0' vres b o bf,
          Genv.find_symbol ge cid = Some bf -> Genv.find_funct_ptr ge bf = Some f ->
          nth_error vargs k = Some (Vptr b o) -> b <> bm ->
          eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
          Mem.valid_block m0 bm -> action_sat Q m0 bm -> MWF m0 ->
          Mem.valid_block m0' bm /\ action_sat Q m0' bm /\ MWF m0')
      s le m t le' m' out,
      exec_stmt function_entry2 ge e le m s t le' m' out ->
      cw_chk g cid k own stat s = true ->
      le ! g = Some (Vptr b_out oo) ->
      Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
        /\ le' ! g = Some (Vptr b_out oo).
  Proof.
    intros MWF Q b_out oo g cid k Hstore Hbne Hcid Hcall s le m t le' m' out Hexec.
    remember e as e0 eqn:He0.
    induction Hexec; intros Hchk Hg Hv Hsat Hmwf; try discriminate Hchk; subst e0.
    - repeat split; assumption.
    - (* Sassign : gate store OR named store *)
      cbn [cw_chk] in Hchk.
      assert (HH : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      destruct (CensusV2.chain_root_l a1) as [t0|] eqn:Hcr.
      + apply andb_prop in Hchk as [Hpe Hbv]. apply Pos.eqb_eq in Hpe; subst t0.
        edestruct (gate_assign_pres MWF Q bm b_out oo g a1 a2 ge e le m E0 le m' Out_normal
                     Hstore Hcr Hbv Hg Hbne HH Hv Hsat Hmwf)
          as (Hv' & Hsat' & Hmwf' & _ & _).
        repeat split; assumption.
      + edestruct (sym_assign_pres MWF Q a1 a2 le m E0 le m' Out_normal Hstore Hchk HH Hv Hsat Hmwf)
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
      destruct (cw_call_pres MWF Q b_out oo g cid k Hcid Hcall le m optid a al t _ m' _ HH Hok Hg Hbne
                  Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf' & _).
      repeat split; try assumption.
      destruct optid as [ti|]; cbn [set_opttemp].
      + apply negb_true_iff, Pos.eqb_neq in Hopt.
        rewrite PTree.gso by (apply not_eq_sym; exact Hopt); exact Hg.
      + exact Hg.
    - (* Sseq_1 *)
      cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
      exact (IHHexec2 eq_refl Hown Hstat Hcid H2 Hg1 Hv1 Hsat1 Hmwf1).
    - (* Sseq_2 *)
      cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf).
    - (* Sifthenelse *)
      cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | exact Hown | exact Hstat | exact Hcid | destruct b; assumption | assumption .. ].
    - repeat split; assumption.
    - repeat split; assumption.
    - repeat split; assumption.
    - repeat split; assumption.
    - (* Sloop_stop1 *)
      cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf).
    - (* Sloop_stop2 *)
      cbn [cw_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
      exact (IHHexec2 eq_refl Hown Hstat Hcid H2 Hg1 Hv1 Hsat1 Hmwf1).
    - (* Sloop_loop *)
      cbn [cw_chk] in Hchk. pose proof Hchk as Hchk0. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl Hown Hstat Hcid H1 Hg Hv Hsat Hmwf) as (Hv1 & Hsat1 & Hmwf1 & Hg1).
      destruct (IHHexec2 eq_refl Hown Hstat Hcid H2 Hg1 Hv1 Hsat1 Hmwf1) as (Hv2 & Hsat2 & Hmwf2 & Hg2).
      exact (IHHexec3 eq_refl Hown Hstat Hcid Hchk0 Hg2 Hv2 Hsat2 Hmwf2).
  Qed.
End ENV.

(* ====================================================================== *)
(* find_floor / find_ceil, re-stated.                                      *)
(* ====================================================================== *)

Definition ff_own : list ident := [surface_collision._height; surface_collision._dynamicHeight].
Definition ff_stat : list ident :=
  [surface_collision._gNumCalls; surface_collision._gNumFindFloorMisses;
   surface_collision._gFindFloorIncludeSurfaceIntangible].
Definition fc_stat : list ident := [surface_collision._gNumCalls].

Lemma find_floor_cw_chk :
  cw_chk surface_collision._pfloor surface_collision._find_floor_from_list 4 ff_own ff_stat
    (fn_body surface_collision.f_find_floor) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma find_ceil_cw_chk :
  cw_chk surface_collision._pceil surface_collision._find_ceil_from_list 4 ff_own fc_stat
    (fn_body surface_collision.f_find_ceil) = true.
Proof. vm_compute. reflexivity. Qed.

Definition ff_env (b1 b2 : block) : env :=
  PTree.set surface_collision._dynamicHeight (b2, tfloat)
    (PTree.set surface_collision._height (b1, tfloat) empty_env).

Lemma ff_env_facts : forall bm b1 b2, b1 <> bm -> b2 <> bm ->
  (forall x, In x ff_own -> exists b ty, (ff_env b1 b2) ! x = Some (b, ty) /\ b <> bm)
  /\ (forall x, In x ff_stat -> (ff_env b1 b2) ! x = None)
  /\ (forall x, In x fc_stat -> (ff_env b1 b2) ! x = None)
  /\ (ff_env b1 b2) ! surface_collision._find_floor_from_list = None
  /\ (ff_env b1 b2) ! surface_collision._find_ceil_from_list = None.
Proof.
  intros bm b1 b2 H1 H2.
  split; [ | split; [ | split; [ | split ] ] ].
  - intros x Hin. destruct Hin as [<- | [<- | []]].
    + exists b1, tfloat. split; [ reflexivity | exact H1 ].
    + exists b2, tfloat. split; [ reflexivity | exact H2 ].
  - intros x Hin. destruct Hin as [<- | [<- | [<- | []]]]; reflexivity.
  - intros x Hin. destruct Hin as [<- | []]; reflexivity.
  - reflexivity.
  - reflexivity.
Qed.

Lemma find_floor_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x ff_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall f m0 vargs t0 m0' vres b o bf,
        Genv.find_symbol ge surface_collision._find_floor_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        nth_error vargs 4 = Some (Vptr b o) -> b <> bm ->
        eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
        Mem.valid_block m0 bm -> action_sat not_tainted m0 bm -> MWF m0 ->
        Mem.valid_block m0' bm /\ action_sat not_tainted m0' bm /\ MWF m0') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      b_out <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore Hsym Hcall
         m vargs t m' vres Hevf Hn3 Hbne Hv Hsat Hmwf.
  unfold surface_collision.f_find_floor in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ (_ :: nil) _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with
  | H1 : Mem.alloc ?ma 0 _ = (?mid, ?bb1),
    H2 : Mem.alloc ?mid 0 _ = (?mfin, ?bb2) |- _ =>
      assert (Hb1_bm : bb1 <> bm)
        by (intro EE; subst bb1; exact (Mem.fresh_block_alloc _ _ _ _ _ H1 Hv));
      assert (HmwfA1 : MWF mid) by (eapply Halloc; [ exact H1 | exact Hmwf ]);
      assert (HvA1 : Mem.valid_block mid bm)
        by (eapply Mem.valid_block_alloc; [ exact H1 | exact Hv ]);
      assert (HsatA1 : action_sat not_tainted mid bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H1 | exact Hv | exact Hsat ]);
      assert (Hb2_bm : bb2 <> bm)
        by (intro EE; subst bb2; exact (Mem.fresh_block_alloc _ _ _ _ _ H2 HvA1));
      assert (HmwfA2 : MWF mfin) by (eapply Halloc; [ exact H2 | exact HmwfA1 ]);
      assert (HvA2 : Mem.valid_block mfin bm)
        by (eapply Mem.valid_block_alloc; [ exact H2 | exact HvA1 ]);
      assert (HsatA2 : action_sat not_tainted mfin bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H2 | exact HvA1 | exact HsatA1 ]);
      destruct (ff_env_facts bm bb1 bb2 Hb1_bm Hb2_bm) as (Hown & Hstf & Hstc & Hcf & Hcc)
  end.
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some ?LE |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 vr]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
    cbn [nth_error] in Hn3; injection Hn3 as ->;
    assert (Hled : LE ! surface_collision._pfloor = Some (Vptr b_out oo)) by (eapply sc_bind_pfloor; exact Hbp)
  end.
  cbn [fn_body] in Hbody.
  destruct (cw_walk ge _ bm ff_own ff_stat Hown Hstf Hsym MWF not_tainted b_out oo
              surface_collision._pfloor surface_collision._find_floor_from_list 4
              Hstore Hbne Hcf Hcall _ _ _ _ _ _ _ Hbody find_floor_cw_chk Hled HvA2 HsatA2 HmwfA2)
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
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall f m0 vargs t0 m0' vres b o bf,
        Genv.find_symbol ge surface_collision._find_ceil_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        nth_error vargs 4 = Some (Vptr b o) -> b <> bm ->
        eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
        Mem.valid_block m0 bm -> action_sat not_tainted m0 bm -> MWF m0 ->
        Mem.valid_block m0' bm /\ action_sat not_tainted m0' bm /\ MWF m0') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_ceil) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      b_out <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore Hsym Hcall
         m vargs t m' vres Hevf Hn3 Hbne Hv Hsat Hmwf.
  unfold surface_collision.f_find_ceil in Hevf.
  match goal with Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ => inv Hevf end.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ (_ :: nil) _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with
  | H1 : Mem.alloc ?ma 0 _ = (?mid, ?bb1),
    H2 : Mem.alloc ?mid 0 _ = (?mfin, ?bb2) |- _ =>
      assert (Hb1_bm : bb1 <> bm)
        by (intro EE; subst bb1; exact (Mem.fresh_block_alloc _ _ _ _ _ H1 Hv));
      assert (HmwfA1 : MWF mid) by (eapply Halloc; [ exact H1 | exact Hmwf ]);
      assert (HvA1 : Mem.valid_block mid bm)
        by (eapply Mem.valid_block_alloc; [ exact H1 | exact Hv ]);
      assert (HsatA1 : action_sat not_tainted mid bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H1 | exact Hv | exact Hsat ]);
      assert (Hb2_bm : bb2 <> bm)
        by (intro EE; subst bb2; exact (Mem.fresh_block_alloc _ _ _ _ _ H2 HvA1));
      assert (HmwfA2 : MWF mfin) by (eapply Halloc; [ exact H2 | exact HmwfA1 ]);
      assert (HvA2 : Mem.valid_block mfin bm)
        by (eapply Mem.valid_block_alloc; [ exact H2 | exact HvA1 ]);
      assert (HsatA2 : action_sat not_tainted mfin bm)
        by (eapply action_sat_unchanged_on;
            [ eapply Mem.alloc_unchanged_on; exact H2 | exact HvA1 | exact HsatA1 ]);
      destruct (ff_env_facts bm bb1 bb2 Hb1_bm Hb2_bm) as (Hown & Hstf & Hstc & Hcf & Hcc)
  end.
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some ?LE |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 vr]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
    cbn [nth_error] in Hn3; injection Hn3 as ->;
    assert (Hled : LE ! surface_collision._pceil = Some (Vptr b_out oo)) by (eapply sc_bind_pceil; exact Hbp)
  end.
  cbn [fn_body] in Hbody.
  destruct (cw_walk ge _ bm ff_own fc_stat Hown Hstc Hsym MWF not_tainted b_out oo
              surface_collision._pceil surface_collision._find_ceil_from_list 4
              Hstore Hbne Hcc Hcall _ _ _ _ _ _ _ Hbody find_ceil_cw_chk Hled HvA2 HsatA2 HmwfA2)
    as (Hvb & Hsatb & Hmwfb & _).
  rewrite blocks_of_env_ff2 in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge tfloat) :: (_, 0, sizeof ge tfloat) :: nil))
    by (constructor; [ exact Hb1_bm | constructor; [ exact Hb2_bm | constructor ] ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hvb Hsatb) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | eapply Hfree; [ exact Hfl | exact Hmwfb ] ] ].
Qed.

(* ---------------------------------------------------------------------- *)
(* The callee premise is DISCHARGEABLE: when the link resolves the callee  *)
(* name to the real _from_list body, its own gated frame gives it.         *)
(* ---------------------------------------------------------------------- *)
Lemma find_floor_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x ff_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall bf f, Genv.find_symbol ge surface_collision._find_floor_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f -> f = Internal surface_collision.f_find_floor_from_list) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      b_out <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore Hsym Hpin.
  apply (find_floor_body_frame_gated ge MWF bm b_out oo Halloc Hfree Hstore Hsym).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_floor_from_list_body_frame ge MWF bm b o Hstore m0 vargs t0 m0' vres Hfc Hn Hb).
Qed.

Lemma find_ceil_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall bf f, Genv.find_symbol ge surface_collision._find_ceil_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f -> f = Internal surface_collision.f_find_ceil_from_list) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_ceil) vargs t m' vres ->
      nth_error vargs 3 = Some (Vptr b_out oo) ->
      b_out <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore Hsym Hpin.
  apply (find_ceil_body_frame_gated ge MWF bm b_out oo Halloc Hfree Hstore Hsym).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_ceil_from_list_body_frame ge MWF bm b o Hstore m0 vargs t0 m0' vres Hfc Hn Hb).
Qed.

(* ====================================================================== *)
(* find_wall_collisions / f32_find_wall_collision, re-stated (P-2).        *)
(* ====================================================================== *)

Lemma find_wall_collisions_cw_chk :
  cw_chk surface_collision._colData surface_collision._find_wall_collisions_from_list 1
    [] fc_stat (fn_body surface_collision.f_find_wall_collisions) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma find_wall_collisions_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall f m0 vargs t0 m0' vres b o bf,
        Genv.find_symbol ge surface_collision._find_wall_collisions_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        nth_error vargs 1 = Some (Vptr b o) -> b <> bm ->
        eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
        Mem.valid_block m0 bm -> action_sat not_tainted m0 bm -> MWF m0 ->
        Mem.valid_block m0' bm /\ action_sat not_tainted m0' bm /\ MWF m0') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_wall_collisions) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_out oo) ->
      b_out <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hstore Hsym Hcall m vargs t m' vres
         Hevf Hn0 Hbne Hv Hsat Hmwf.
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
  destruct (cw_walk ge empty_env bm [] fc_stat (fun x H => match H with end)
              (fun x _ => PTree.gempty _ x) Hsym MWF not_tainted b_out oo
              surface_collision._colData surface_collision._find_wall_collisions_from_list 1
              Hstore Hbne (PTree.gempty _ _) Hcall _ _ _ _ _ _ _ Hbody
              find_wall_collisions_cw_chk Hled Hv Hsat Hmwf)
    as (Hvb & Hsatb & Hmwfb & _).
  assert (Hben : blocks_of_env ge empty_env = nil) by reflexivity.
  rewrite Hben in Hfl. cbn [Mem.free_list] in Hfl. injection Hfl as <-.
  exact (conj Hvb (conj Hsatb Hmwfb)).
Qed.

Lemma find_wall_collisions_body_frame_pinned :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall bf f, Genv.find_symbol ge surface_collision._find_wall_collisions_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        f = Internal surface_collision.f_find_wall_collisions_from_list) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_wall_collisions) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_out oo) ->
      b_out <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hstore Hsym Hpin.
  apply (find_wall_collisions_body_frame_gated ge MWF bm b_out oo Hstore Hsym).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_wall_collisions_from_list_body_frame ge MWF bm b o Hstore m0 vargs t0 m0' vres Hfc Hn Hb).
Qed.

Lemma f32_find_wall_collision_body_frame_gated :
  forall (ge : genv) (MWF : mem -> Prop)
         (bm b_xout b_yout b_zout : block) (oxo oyo ozo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall c b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store c m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall f m0 vargs t0 m0' vres b o bf,
        Genv.find_symbol ge surface_collision._find_wall_collisions = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        nth_error vargs 0 = Some (Vptr b o) -> b <> bm ->
        eval_funcall function_entry2 ge m0 f vargs t0 m0' vres ->
        Mem.valid_block m0 bm -> action_sat not_tainted m0 bm -> MWF m0 ->
        Mem.valid_block m0' bm /\ action_sat not_tainted m0' bm /\ MWF m0') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_f32_find_wall_collision) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_xout oxo) ->
      nth_error vargs 1 = Some (Vptr b_yout oyo) ->
      nth_error vargs 2 = Some (Vptr b_zout ozo) ->
      b_xout <> bm -> b_yout <> bm -> b_zout <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_xout b_yout b_zout oxo oyo ozo Halloc Hfree Hstore Hcall
         m vargs t m' vres Hevf Hn0 Hn1 Hn2 Hbx Hby Hbz Hv Hsat Hmwf.
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
  efst Hstore Hecoll Hcoll_bm HS2 Hacf HvA HsatA HmwfA Hv2 Hs2 Hm2 R2.
  (* ---- S3: collision.radius = radius ---- *)
  peelc R2.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._radius _) _) _ _ _ _ |- _ => rename H into HS3 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'7 _) _) _) _ _ _ _ |- _ => rename H into R3 end.
  efst Hstore Hecoll Hcoll_bm HS3 Hacf Hv2 Hs2 Hm2 Hv3 Hs3 Hm3 R3.
  (* ---- S4: t'7 = *xPtr; collision.x = t'7 ---- *)
  peelc R3.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'7 _) _) _ _ _ _ |- _ => rename H into B4 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'6 _) _) _) _ _ _ _ |- _ => rename H into R4 end.
  peelc B4.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'7 _) _ _ _ _ |- _ => rename H into HR4 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._x _) _) _ _ _ _ |- _ => rename H into HW4 end.
  ssettp HR4 Htp1 Em4 Htp4.
  rewrite Em4 in HW4.
  efst Hstore Hecoll Hcoll_bm HW4 Hacf Hv3 Hs3 Hm3 Hv4 Hs4 Hm4 R4.
  (* ---- S5: t'6 = *yPtr; collision.y = t'6 ---- *)
  peelc R4.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'6 _) _) _ _ _ _ |- _ => rename H into B5 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'5 _) _) _) _ _ _ _ |- _ => rename H into R5 end.
  peelc B5.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'6 _) _ _ _ _ |- _ => rename H into HR5 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._y _) _) _ _ _ _ |- _ => rename H into HW5 end.
  ssettp HR5 Htp4 Em5 Htp5.
  rewrite Em5 in HW5.
  efst Hstore Hecoll Hcoll_bm HW5 Hacf Hv4 Hs4 Hm4 Hv5 Hs5 Hm5 R5.
  (* ---- S6: t'5 = *zPtr; collision.z = t'5 ---- *)
  peelc R5.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'5 _) _) _ _ _ _ |- _ => rename H into B6 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._numWalls _) _) _) _ _ _ _ |- _ => rename H into R6 end.
  peelc B6.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'5 _) _ _ _ _ |- _ => rename H into HR6 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._z _) _) _ _ _ _ |- _ => rename H into HW6 end.
  ssettp HR6 Htp5 Em6 Htp6.
  rewrite Em6 in HW6.
  efst Hstore Hecoll Hcoll_bm HW6 Hacf Hv5 Hs5 Hm5 Hv6 Hs6 Hm6 R6.
  (* ---- S7: collision.numWalls = 0 (tshort) ---- *)
  peelc R6.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._numWalls _) _) _ _ _ _ |- _ => rename H into HS7 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Scall _ _ _) _) _) _ _ _ _ |- _ => rename H into R7 end.
  efst Hstore Hecoll Hcoll_bm HS7 Hacs Hv6 Hs6 Hm6 Hv7 Hs7 Hm7 R7.
  (* ---- S8: t'1 = find_wall_collisions(&collision); numCollisions = t'1 ---- *)
  peelc R7.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) _) _ _ _ _ |- _ => rename H into B8 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'4 _) _) _) _ _ _ _ |- _ => rename H into R8 end.
  peelc B8.
  match goal with H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => rename H into HC8 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._numCollisions _) _ _ _ _ |- _ => rename H into HN8 end.
  (* the call: callee = the global find_wall_collisions, arg 0 = &collision
     (own fresh block, <> bm) -- the gated callee premise applies *)
  pose proof Htp6 as Htp6x. unfold three_ptr in Htp6x. destruct Htp6x as (Hx6 & _ & _).
  edestruct (cw_call_pres ge _ bm [surface_collision._collision] []
               ltac:(intros x [<- | []]; eexists _, _; split; [ exact Hecoll | exact Hcoll_bm ])
               ltac:(intros x []) ltac:(intros x bg []) MWF not_tainted b_xout oxo
               surface_collision._xPtr surface_collision._find_wall_collisions 0
               eq_refl Hcall _ _ _ _ _ _ _ _ _ HC8 ltac:(vm_compute; reflexivity) Hx6 Hbx Hv7 Hs7 Hm7)
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
  drst Hstore Hacf HW9 (three_ptr_x _ _ _ _ _ _ _ Htp9) Hbx Hv8 Hs8 Hm8 Hv9 Hs9 Hm9 R9.
  (* ---- S10: t'3 = collision.y; *yPtr = t'3 ---- *)
  peelc R9.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'3 _) _) _ _ _ _ |- _ => rename H into B10 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'2 _) _) _) _ _ _ _ |- _ => rename H into R10 end.
  peelc B10.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'3 _) _ _ _ _ |- _ => rename H into HR10 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._yPtr _) _) _) _ _ _ _ |- _ => rename H into HW10 end.
  ssettp HR10 Htp9 Em10 Htp10.
  rewrite Em10 in HW10.
  drst Hstore Hacf HW10 (three_ptr_y _ _ _ _ _ _ _ Htp10) Hby Hv9 Hs9 Hm9 Hv10 Hs10 Hm10 R10.
  (* ---- S11: t'2 = collision.z; *zPtr = t'2 ---- *)
  peelc R10.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'2 _) _) _ _ _ _ |- _ => rename H into B11 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => rename H into HRET end.
  peelc B11.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'2 _) _ _ _ _ |- _ => rename H into HR11 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._zPtr _) _) _) _ _ _ _ |- _ => rename H into HW11 end.
  ssettp HR11 Htp10 Em11 Htp11.
  rewrite Em11 in HW11.
  drst Hstore Hacf HW11 (three_ptr_z _ _ _ _ _ _ _ Htp11) Hbz Hv10 Hs10 Hm10 Hv11 Hs11 Hm11 HRET.
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
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall c b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store c m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall x bg, In x fc_stat -> Genv.find_symbol ge x = Some bg -> bg <> bm) ->
    (forall bf f, Genv.find_symbol ge surface_collision._find_wall_collisions = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        f = Internal surface_collision.f_find_wall_collisions) ->
    (forall bf f, Genv.find_symbol ge surface_collision._find_wall_collisions_from_list = Some bf ->
        Genv.find_funct_ptr ge bf = Some f ->
        f = Internal surface_collision.f_find_wall_collisions_from_list) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_f32_find_wall_collision) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_xout oxo) ->
      nth_error vargs 1 = Some (Vptr b_yout oyo) ->
      nth_error vargs 2 = Some (Vptr b_zout ozo) ->
      b_xout <> bm -> b_yout <> bm -> b_zout <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_xout b_yout b_zout oxo oyo ozo Halloc Hfree Hstore Hsym Hpin Hpin2.
  apply (f32_find_wall_collision_body_frame_gated ge MWF bm b_xout b_yout b_zout oxo oyo ozo
           Halloc Hfree Hstore).
  intros f m0 vargs t0 m0' vres b o bf Hs Hf Hn Hb Hfc.
  rewrite (Hpin bf f Hs Hf) in Hfc.
  exact (find_wall_collisions_body_frame_pinned ge MWF bm b o Hstore Hsym Hpin2
           m0 vargs t0 m0' vres Hfc Hn Hb).
Qed.
