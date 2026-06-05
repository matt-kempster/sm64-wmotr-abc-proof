(* ====================================================================== *)
(* THE ACT-WRITER KEYSTONE (STAGING -- Unwired until an act-leaf family   *)
(* consumes it): set_mario_action and its four sub-setters, walked.       *)
(*                                                                        *)
(* Every one of the ~200 act-leaf bodies calls                            *)
(*   set_mario_action(m, CONSTANT, _)                                     *)
(* so no leaf census can close without a row for the writer itself.  The  *)
(* writer's contract is call_pres_act: given Mario's pointer, an          *)
(* UNTAINTED-SCALAR action argument and the carried run facts, the        *)
(* funcall preserves them and returns an untainted scalar.                *)
(*                                                                        *)
(* Scout facts (act-writer-keystone memory): the four sub-setters         *)
(* reassign their _action temp ONLY to vm-checkably untainted constants   *)
(* (ACT_FLYING_TRIPLE_JUMP appears solely as a HANDLED case label, never  *)
(* a produced value), and return `Etempvar _action`.  So the value side   *)
(* needs NO A-gate consumption at this level -- pure constant tracking.   *)
(*                                                                        *)
(* The value class is untainted_scalar (Vundef or untainted Vint), NOT    *)
(* bare not_tainted: MWF_real's R4 row (the action cell never holds a     *)
(* pointer; a Vptr would survive a Mint32 round-trip on ptr64=false)      *)
(* forces excluding pointers, and Vundef is harmless for both R4 and      *)
(* action_sat (a non-Vint load satisfies it vacuously).                   *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_airborne.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.

Import ListNotations.

(* ====================================================================== *)
(* The value class and the row shape.                                     *)
(* ====================================================================== *)

(* what the action cell (and the temps feeding it) may hold *)
Definition untainted_scalar (x : val) : Prop :=
  x = Vundef \/ exists v, x = Vint v /\ not_tainted v.

(* the vm-side of the same check, for constants in the AST *)
Definition wact_const (c : int) : bool := negb (is_tainted c).

Lemma wact_const_sound : forall c,
    wact_const c = true -> untainted_scalar (Vint c).
Proof.
  intros c H. right. exists c. split; [ reflexivity | ].
  unfold wact_const in H. unfold not_tainted.
  destruct (is_tainted c); [ discriminate H | reflexivity ].
Qed.

(* the per-writer residual shape: Mario's pointer first, an untainted
   scalar action second, anything after -- the funcall preserves the
   carried run facts and returns an untainted scalar. *)
Definition call_pres_act (lp : Clight.program) (bm : block)
    (NoA MWF : mem -> Prop) (fid : ident) : Prop :=
  forall fd m0 v0 aval rest t0 m1 vres0,
    eval_funcall function_entry2 (lp_ge lp) m0 fd
      (v0 :: aval :: rest) t0 m1 vres0 ->
    resolves_lp lp fid fd ->
    marg_ok bm (v0 :: aval :: rest) ->
    untainted_scalar aval ->
    NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
    action_sat not_tainted m0 bm ->
    Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
    MWF m1 /\ NoA m1 /\ untainted_scalar vres0.

(* I32 int types: the casts between them are value-neutral on Vint
   (ptr64=false makes them the pointer-neutral class), so a censused
   return through them cannot mint a new -- possibly tainted -- value. *)
Definition i32_ty (ty : type) : bool :=
  match ty with Tint I32 _ _ => true | _ => false end.

Lemma sem_cast_i32_neutral : forall v ty1 ty2 m w,
    i32_ty ty1 = true -> i32_ty ty2 = true ->
    sem_cast (Vint v) ty1 ty2 m = Some w -> w = Vint v.
Proof.
  intros v ty1 ty2 m w H1 H2 Hc.
  destruct ty1 as [ | sz1 sg1 a1 | | | | | | | ]; try discriminate H1.
  destruct sz1; try discriminate H1.
  destruct ty2 as [ | sz2 sg2 a2 | | | | | | | ]; try discriminate H2.
  destruct sz2; try discriminate H2.
  unfold sem_cast in Hc. cbn in Hc.
  injection Hc as <-. reflexivity.
Qed.

(* an untainted scalar surviving an I32-to-I32 cast is the same Vint
   (Vundef dies at the cast: pointer-neutral casts reject it). *)
Lemma sem_cast_i32_untainted : forall x ty1 ty2 m w,
    i32_ty ty1 = true -> i32_ty ty2 = true ->
    untainted_scalar x ->
    sem_cast x ty1 ty2 m = Some w -> untainted_scalar w.
Proof.
  intros x ty1 ty2 m w H1 H2 Hu Hc.
  destruct Hu as [-> | (v & -> & Hnt)].
  - destruct ty1 as [ | sz1 sg1 a1 | | | | | | | ]; try discriminate H1.
    destruct sz1; try discriminate H1.
    destruct ty2 as [ | sz2 sg2 a2 | | | | | | | ]; try discriminate H2.
    destruct sz2; try discriminate H2.
    unfold sem_cast in Hc. cbn in Hc. discriminate Hc.
  - rewrite (sem_cast_i32_neutral _ _ _ _ _ H1 H2 Hc).
    right. exists v. split; [ reflexivity | exact Hnt ].
Qed.

(* ====================================================================== *)
(* The INDEXED window store: m->vel[CONST] = ... (a float Vec3 cell).     *)
(* All four sub-setters write m->vel[1]; the geometry check pins the      *)
(* final byte offset delta + 4*idx inside the window.                     *)
(* ====================================================================== *)

Definition idx_geom_chk (fld : ident) (idx : int) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (delta, Full) =>
      (0 <=? delta)%Z
      && (0 <=? Int.signed idx)%Z
      && store_window_ok (delta + 4 * Int.signed idx) (size_chunk Mfloat32)
  | _ => false
  end.

Lemma idx_geom_chk_sound : forall fld idx,
    idx_geom_chk fld idx = true ->
    exists delta,
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) /\
      0 <= delta /\
      0 <= Int.signed idx /\
      store_window_ok (delta + 4 * Int.signed idx) (size_chunk Mfloat32)
        = true.
Proof.
  intros fld idx H. unfold idx_geom_chk in H.
  destruct (field_offset (prog_comp_env mario.prog) fld mario_state_members)
    as [[delta [|]]|] eqn:E; try discriminate H.
  apply andb_prop in H as [H1 H2].
  apply andb_prop in H1 as [H0 H1].
  exists delta. split; [ reflexivity | ].
  split; [ apply Z.leb_le; exact H0 | ].
  split; [ apply Z.leb_le; exact H1 | exact H2 ].
Qed.

Definition idx_mfield_store (mptr : ident) (a1 : expr) : bool :=
  match a1 with
  | Ederef
      (Ebinop Oadd
         (Efield (Ederef (Etempvar p pty) sty) fld aty)
         (Econst_int idx ity) (Tpointer ety pattr)) dty =>
      Pos.eqb p mptr
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && proj_sumbool (type_eq aty (tarray tfloat 3))
      && proj_sumbool (type_eq ity tint)
      && proj_sumbool (type_eq ety tfloat)
      && proj_sumbool (type_eq dty tfloat)
      && idx_geom_chk fld idx
  | _ => false
  end.

Lemma idx_mfield_store_shape : forall mptr a1,
    idx_mfield_store mptr a1 = true ->
    exists fld idx pattr,
      a1 = Ederef
             (Ebinop Oadd
                (Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) fld
                   (tarray tfloat 3))
                (Econst_int idx tint) (Tpointer tfloat pattr)) tfloat /\
      idx_geom_chk fld idx = true.
Proof.
  intros mptr a1 H.
  destruct a1 as [ | | | | | | a dty | | | | | | | ]; try discriminate H.
  destruct a as [ | | | | | | | | | op b1 b2 bty | | | | ];
    try discriminate H.
  destruct op; try discriminate H.
  destruct b1 as [ | | | | | | | | | | | b1a fld aty | | ];
    try discriminate H.
  destruct b1a as [ | | | | | | bb sty | | | | | | | ]; try discriminate H.
  destruct bb as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
  destruct b2 as [ idx ity | | | | | | | | | | | | | ]; try discriminate H.
  destruct bty as [ | | | | ety pattr | | | | ]; try discriminate H.
  cbn in H.
  apply andb_prop in H as [H Hg].
  apply andb_prop in H as [H Hdty].
  apply andb_prop in H as [H Hety].
  apply andb_prop in H as [H Hity].
  apply andb_prop in H as [H Haty].
  apply andb_prop in H as [H Hsty].
  apply andb_prop in H as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
  destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
  destruct (type_eq aty (tarray tfloat 3)); [ subst aty | discriminate Haty ].
  destruct (type_eq ity tint); [ subst ity | discriminate Hity ].
  destruct (type_eq ety tfloat); [ subst ety | discriminate Hety ].
  destruct (type_eq dty tfloat); [ subst dty | discriminate Hdty ].
  exists fld, idx, pattr. split; [ reflexivity | exact Hg ].
Qed.

(* ====================================================================== *)
(* The semantic brick for the indexed store.                              *)
(* ====================================================================== *)

Section ActWriterBricks.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.
  Variable MWF : mem -> Prop.

  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  Lemma idx_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      idx_mfield_store mario_actions_airborne._m a1 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hix Htat Hexec HM HV HS.
    destruct (idx_mfield_store_shape _ _ Hix)
      as (fld & idx & pattr & -> & Hg).
    destruct (idx_geom_chk_sound _ _ Hg)
      as (delta & Hfo & Hdel0 & Hidx0 & Hwin).
    inv Hexec.
    (* the lvalue: Ederef of the pointer-arithmetic result *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    (* the index literal *)
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    (* the array field expression: eval_Elvalue is its ONLY constructor *)
    match goal with
    | Ha : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv Ha
    end.
    (* reduce the typeof in the deref hyp BEFORE inverting (else the
       spurious branches survive -- see deref_loc struct inversion) *)
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (tarray tfloat 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Hacc : access_mode (tarray tfloat 3) = _ |- _ =>
                 cbn in Hacc; discriminate Hacc
             end);
        try (match goal with
             | Hlb : load_bitfield (tarray tfloat 3) _ _ _ _ _ _ _ |- _ =>
                 inv Hlb
             end)
    end.
    (* the field lvalue geometry: (bm, delta) *)
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        pose proof Hflv as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        (* bff is already the literal Full (pinned by the By_reference
           deref), so only the block and offset get substituted *)
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    lf of bff _ _ _ Hlvb Hfo Hflv) as (E3 & E4 & _);
        subst lf of
    end.
    (* the pointer add: block bm, offset delta + 4*idx *)
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
        cbn in Hsem; injection Hsem as <- <-
    end.
    (* the store *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has;
        inv Has;
        try (match goal with
             | Hac2 : access_mode tfloat = _ |- _ =>
                 cbn in Hac2; discriminate Hac2
             end)
    end.
    match goal with
    | Hac2 : access_mode tfloat = By_value ?ch2 |- _ =>
        change (access_mode tfloat) with (By_value Mfloat32) in Hac2;
        injection Hac2 as <-
    end.
    match goal with
    | Hstv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hstv; rename Hstv into Hst
    end.
    (* the final offset reduces to delta + 4 * Int.signed idx; every
       unsigned_repr side condition is LINEAR in: 0 <= delta (checker),
       0 <= Int.signed idx (checker), and the window's range booleans. *)
    assert (Hbounds : 0 <= delta + 4 * Int.signed idx /\
                      delta + 4 * Int.signed idx + 4 <= Ptrofs.max_unsigned).
    { unfold store_window_ok in Hwin.
      change (size_chunk Mfloat32) with 4 in Hwin.
      repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
      match goal with
      | Hb1 : (0 <=? delta + 4 * Int.signed idx)%Z = true,
        Hb2 : (delta + 4 * Int.signed idx + _ <=? _)%Z = true |- _ =>
          apply Z.leb_le in Hb1; apply Z.leb_le in Hb2; lia
      end. }
    destruct Hbounds as [Hb0 Hb1].
    assert (Eofs : Ptrofs.unsigned
                     (Ptrofs.add (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta))
                        (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints idx)))
                   = delta + 4 * Int.signed idx).
    { rewrite Ptrofs.add_zero_l.
      unfold Ptrofs.of_ints.
      unfold Ptrofs.mul.
      rewrite (Ptrofs.unsigned_repr 4) by lia.
      rewrite (Ptrofs.unsigned_repr (Int.signed idx)) by lia.
      unfold Ptrofs.add.
      rewrite (Ptrofs.unsigned_repr delta) by lia.
      rewrite (Ptrofs.unsigned_repr (4 * Int.signed idx)) by lia.
      apply Ptrofs.unsigned_repr. lia. }
    rewrite Eofs in Hst.
    (* the posts: a window store *)
    split; [ eauto using Mem.store_valid_block_1 | ].
    split.
    { intros av Hload.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
        [ exact (HS av Hload) | right ].
      unfold store_window_ok in Hwin.
      apply andb_true_iff in Hwin as [Hwin _].
      apply andb_true_iff in Hwin as [Hwin _].
      apply andb_true_iff in Hwin as [Hwin Hw12].
      apply orb_true_iff in Hw12 as [Hw12 | Hw12]; apply Z.leb_le in Hw12;
        [ right; exact Hw12 | left; cbn [size_chunk]; lia ]. }
    split.
    { exact (HMWF_window _ _ _ _ _ HM Hwin Hst). }
    split; reflexivity.
  Qed.

End ActWriterBricks.

(* ====================================================================== *)
(* The WRITER WALKER: like the generic walker, but additionally tracks a  *)
(* censused set of "act temps" (wact) whose values stay untainted-scalar. *)
(* Rules: an act temp may only be Sset from an untainted I32 constant;    *)
(* call results may NOT land in an act temp (the manual set_mario_action  *)
(* walk owns that pattern); returns are censused (untainted constant or   *)
(* act temp, at an I32 type so the return cast is value-neutral).         *)
(* ====================================================================== *)

Definition wret_ok (out : outcome) : Prop :=
  match out with
  | Out_return (Some (v, ty)) => untainted_scalar v /\ i32_ty ty = true
  | _ => True
  end.

Definition wconst_chk (a : expr) : bool :=
  match a with
  | Econst_int c ty => i32_ty ty && wact_const c
  | _ => false
  end.

Fixpoint wwalk_chk (wact ids : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn None => true
  | Sreturn (Some a) =>
      match a with
      | Econst_int c ty => i32_ty ty && wact_const c
      | Etempvar t ty => i32_ty ty && mem_id t wact
      | _ => false
      end
  | Sset id a =>
      negb (Pos.eqb id mario_actions_airborne._m)
      && (negb (mem_id id wact) || wconst_chk a)
  | Sassign a1 _ =>
      safe_mfield_store mario_actions_airborne._m a1
      || glob_store_chk a1
      || idx_mfield_store mario_actions_airborne._m a1
  | Scall optid a al =>
      match a with
      | Evar fid fty =>
          opt_ne_m optid
          && match optid with
             | Some t => negb (mem_id t wact)
             | None => true
             end
          && match fty, al with
             | Tfunction (ty1 :: tys) rty cc, Etempvar p pty :: args =>
                 Pos.eqb p mario_actions_airborne._m
                 && mem_id fid ids
                 && proj_sumbool (type_eq ty1 tyMSp)
                 && proj_sumbool (type_eq pty tyMSp)
             | _, _ => false
             end
      | _ => false
      end
  | Ssequence s1 s2 => wwalk_chk wact ids s1 && wwalk_chk wact ids s2
  | Sifthenelse _ s1 s2 => wwalk_chk wact ids s1 && wwalk_chk wact ids s2
  | Sloop s1 s2 => wwalk_chk wact ids s1 && wwalk_chk wact ids s2
  | Sswitch _ sl => wwalk_chk_ls wact ids sl
  | _ => false
  end
with wwalk_chk_ls (wact ids : list ident) (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => wwalk_chk wact ids s && wwalk_chk_ls wact ids sl'
  end.

(* ---- the switch-selection transfer (mirror of walk_chk's) ---- *)

Lemma wwalk_chk_ls_seq : forall wact ids sl,
    wwalk_chk_ls wact ids sl = true ->
    wwalk_chk wact ids (seq_of_labeled_statement sl) = true.
Proof.
  intros wact ids sl; induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn in H. apply andb_prop in H as [H1 H2].
    cbn. rewrite H1. cbn. exact (IH H2).
Qed.

Lemma wwalk_chk_ls_case : forall wact ids n sl sl',
    wwalk_chk_ls wact ids sl = true ->
    select_switch_case n sl = Some sl' ->
    wwalk_chk_ls wact ids sl' = true.
Proof.
  intros wact ids n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma wwalk_chk_ls_default : forall wact ids sl,
    wwalk_chk_ls wact ids sl = true ->
    wwalk_chk_ls wact ids (select_switch_default sl) = true.
Proof.
  intros wact ids sl; induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn.
    + exact (IH H2).
    + rewrite H1, H2. reflexivity.
Qed.

Lemma wwalk_chk_select : forall wact ids n sl,
    wwalk_chk_ls wact ids sl = true ->
    wwalk_chk wact ids (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros wact ids n sl H. apply wwalk_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (wwalk_chk_ls_case _ _ _ _ _ H E).
  - exact (wwalk_chk_ls_default _ _ _ H).
Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section ActWriterWalk.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').

  (* the act-temp invariant the walk threads through le *)
  Definition act_inv (wact : list ident) (le : temp_env) : Prop :=
    forall t, mem_id t wact = true ->
      forall x, le ! t = Some x -> untainted_scalar x.

  (* n-ary Mario-head call at the empty env: the TAIL is arbitrary
     (marg_ok constrains only the head; eval_exprlist is pure). *)
  Lemma kit_scalln_pres :
    forall optid fid tys rty cc args le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSp :: tys) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp :: args))
        tr le1 m1 out0 ->
      call_pres lp bm NoA MWF fid ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid tys rty cc args le0 m0 tr le1 m1 out0 Hexec Hcp Htat
           HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply eval_Evar_funct_empty in Hv; destruct Hv as (b & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr b Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists b; split; assumption)
    end.
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1
    end.
    match goal with
    | Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hc; subst
    end.
    match goal with
    | Hv1' : le0 ! _ = Some ?vv,
      Hevf : eval_funcall _ _ _ _ (?vv :: ?vrest) _ _ _ |- _ =>
        assert (Hmarg : marg_ok bm (vv :: vrest))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* ================================================================== *)
  (* THE WRITER WALK.                                                   *)
  (* ================================================================== *)
  Lemma wwalk_pres :
    forall (wact ids : list ident),
      (forall fid, mem_id fid ids = true -> call_pres lp bm NoA MWF fid) ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        e = empty_env ->
        wwalk_chk wact ids s = true ->
        (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        act_inv wact le ->
        NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
        action_sat not_tainted m0 bm ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
        NoA m' /\
        (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        act_inv wact le' /\ wret_ok out.
  Proof.
    intros wact ids Hcp s e le m0 tr le' m' out Hexec.
    induction Hexec; intros He Hchk Htat Hact HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact I)))))).
    - (* Sassign: window / global / indexed-window bricks *)
      cbn [wwalk_chk] in Hchk.
      subst e.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hix].
      + apply orb_true_iff in Hchk.
        destruct Hchk as [Hsf | Hgs].
        * destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                      a1 a2 _ _ _ _ _ _ _ Hsf Htat Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact I)))))).
        * destruct (glob_assign_pres lp bm MWF HMWF_glob
                      a1 a2 _ _ _ _ _ _ Hgs Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact I)))))).
      + destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hix Htat Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                 (conj Htat (conj Hact I)))))).
    - (* Sset: non-_m temp; an act temp only from an untainted constant *)
      cbn [wwalk_chk] in Hchk.
      apply andb_prop in Hchk as [Hnm Hrest].
      refine (conj HV (conj HS (conj HM (conj HN (conj _ (conj _ I)))))).
      + intros b o Hg.
        rewrite PTree.gso in Hg
          by (intro EE; rewrite <- EE in Hnm; cbn in Hnm;
              discriminate Hnm).
        exact (Htat _ _ Hg).
      + intros t Hmem x Hg.
        destruct (Pos.eq_dec t id) as [-> | Hne].
        * rewrite PTree.gss in Hg. injection Hg as <-.
          rewrite Hmem in Hrest. cbn [negb orb] in Hrest.
          destruct a as [ c cty | | | | | | | | | | | | | ];
            try discriminate Hrest.
          cbn [wconst_chk] in Hrest.
          apply andb_prop in Hrest as [_ Hwc].
          match goal with
          | Hev : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
              inv Hev;
              try (match goal with
                   | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                       inv Hlv
                   end)
          end.
          exact (wact_const_sound _ Hwc).
        * rewrite PTree.gso in Hg by exact Hne.
          exact (Hact _ Hmem _ Hg).
    - (* Scall: censused Mario-head call, result NOT into an act temp *)
      subst e.
      destruct a as [ ci cty | cf cty | cs cty | cl cty | cid fty | tv tvy
                    | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                    | f1 f2 f3 | s1' s2' | g1 g2 ];
        try discriminate Hchk.
      cbn [wwalk_chk] in Hchk.
      apply andb_prop in Hchk as [Hopt Hchk].
      apply andb_prop in Hopt as [Hopt Hnw].
      destruct fty as [ | i1 i2 i3 | l1' l2' | r1 r2 | p1 p2 | ar1 ar2 ar3
                      | params res cc | st1 st2 | un1 un2 ];
        try discriminate Hchk.
      destruct params as [| ty1 tys]; try discriminate Hchk.
      destruct al as [| a1 args]; try discriminate Hchk.
      destruct a1 as [ xa xb | xa xb | xa xb | xa xb | xa xb | p pty
                     | xa xb | xa xb | xa xb xc | xa xb xc xd | xa xb
                     | xa xb xc | xa xb | xa xb ];
        try discriminate Hchk.
      apply andb_prop in Hchk as [Hchk Hpty].
      apply andb_prop in Hchk as [Hchk Hty1].
      apply andb_prop in Hchk as [Hp Hfid].
      apply Pos.eqb_eq in Hp. subst p.
      destruct (type_eq ty1 tyMSp); [ subst ty1 | discriminate Hty1 ].
      destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                      (Scall optid
                         (Evar cid (Tfunction (tyMSp :: tys) res cc))
                         (Etempvar mario_actions_airborne._m tyMSp :: args))
                      t (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      destruct (kit_scalln_pres
                  _ _ _ _ _ _ _ _ _ _ _ _ Hex (Hcp _ Hfid) Htat HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & _).
      refine (conj HV' (conj HS' (conj HM' (conj HN' (conj _ (conj _ I)))))).
      + intros b o Hg.
        destruct optid as [t'|]; cbn [set_opttemp] in Hg.
        * rewrite PTree.gso in Hg
            by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                discriminate Hopt).
          exact (Htat _ _ Hg).
        * exact (Htat _ _ Hg).
      + intros t0' Hmem x Hg.
        destruct optid as [t'|]; cbn [set_opttemp] in Hg.
        * rewrite PTree.gso in Hg
            by (intro EE; rewrite EE in Hmem; rewrite Hmem in Hnw;
                cbn in Hnw; discriminate Hnw).
          exact (Hact _ Hmem _ Hg).
        * exact (Hact _ Hmem _ Hg).
    - (* Sbuiltin: excluded *)
      cbn [wwalk_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat Hact HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & _).
      exact (IHHexec2 He H2 Htat1 Hact1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec He H1 Htat Hact HN HM HV HS).
    - (* Sifthenelse *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact I)))))).
    - (* Sreturn (Some a): the censused return *)
      cbn [wwalk_chk] in Hchk.
      refine (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact _)))))).
      destruct a as [ c cty | | | | | tret tty | | | | | | | | ];
        try discriminate Hchk;
        apply andb_prop in Hchk as [Hi32 Hsnd].
      + (* constant *)
        match goal with
        | Hev : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
            inv Hev;
            try (match goal with
                 | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv
                 end)
        end.
        cbn. split; [ exact (wact_const_sound _ Hsnd) | exact Hi32 ].
      + (* act temp *)
        match goal with
        | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hev;
            cbn; split; [ exact (Hact _ Hsnd _ Hev) | exact Hi32 ]
        end.
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact I)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact I)))))).
    - (* Sloop stop1 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      destruct (IHHexec He H1 Htat Hact HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hret1).
      refine (conj HV1 (conj HS1 (conj HM1 (conj HN1
               (conj Htat1 (conj Hact1 _)))))).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + exact I.
      + exact Hret1.
    - (* Sloop stop2 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat Hact HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & _).
      destruct (IHHexec2 He H2 Htat1 Hact1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Htat2 & Hact2 & Hret2).
      refine (conj HV2 (conj HS2 (conj HM2 (conj HN2
               (conj Htat2 (conj Hact2 _)))))).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + exact I.
      + exact Hret2.
    - (* Sloop loop *)
      cbn [wwalk_chk] in Hchk.
      pose proof Hchk as Hchk2.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat Hact HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & _).
      destruct (IHHexec2 He H2 Htat1 Hact1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Htat2 & Hact2 & _).
      apply IHHexec3; try assumption;
        cbn [wwalk_chk]; exact Hchk2.
    - (* Sswitch *)
      cbn [wwalk_chk] in Hchk.
      destruct (IHHexec He (wwalk_chk_select _ _ n _ Hchk)
                  Htat Hact HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hret1).
      refine (conj HV1 (conj HS1 (conj HM1 (conj HN1
               (conj Htat1 (conj Hact1 _)))))).
      destruct out as [ | | | ov ]; try exact I.
      exact Hret1.
  Qed.

End ActWriterWalk.
