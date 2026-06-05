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
