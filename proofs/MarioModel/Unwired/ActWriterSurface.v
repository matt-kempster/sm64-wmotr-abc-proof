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
(* THE act store: m->action := t with t a censused act temp.  This is     *)
(* the ONE store the window machinery must NOT admit (it writes the       *)
(* protected cell), so it gets its own arm consuming mwf_real_act_store   *)
(* (the value is an untainted scalar, never a pointer).                   *)
(* ====================================================================== *)

(* the generated offset of MarioState.action *)
Example act_field_off :
  field_offset (prog_comp_env mario.prog) mario._action mario_state_members
  = OK (12, Full).
Proof. vm_compute. reflexivity. Qed.

Definition act_store_chk (wact : list ident) (a1 a2 : expr) : bool :=
  match a1, a2 with
  | Efield (Ederef (Etempvar p pty) sty) fld fty, Etempvar t rty =>
      Pos.eqb p mario_actions_airborne._m
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && Pos.eqb fld mario._action
      && i32_ty fty && i32_ty rty
      && mem_id t wact
  | _, _ => false
  end.

Lemma act_store_chk_shape : forall wact a1 a2,
    act_store_chk wact a1 a2 = true ->
    exists fty rty t,
      a1 = Efield (Ederef (Etempvar mario_actions_airborne._m (tptr tyMS))
                     tyMS) mario._action fty /\
      a2 = Etempvar t rty /\
      i32_ty fty = true /\ i32_ty rty = true /\ mem_id t wact = true.
Proof.
  intros wact a1 a2 H.
  destruct a1 as [ | | | | | | | | | | | ab fld fty | | ];
    try discriminate H.
  destruct ab as [ | | | | | | bb sty | | | | | | | ]; try discriminate H.
  destruct bb as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
  destruct a2 as [ | | | | | t rty | | | | | | | | ]; try discriminate H.
  cbn [act_store_chk] in H.
  apply andb_prop in H as [H Hmem].
  apply andb_prop in H as [H Hrty].
  apply andb_prop in H as [H Hfty].
  apply andb_prop in H as [H Hfld].
  apply andb_prop in H as [H Hsty].
  apply andb_prop in H as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  apply Pos.eqb_eq in Hfld. subst fld.
  destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
  destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
  exists fty, rty, t. repeat split; assumption.
Qed.

(* ====================================================================== *)
(* The CHASE store: a write THROUGH a censused chase temp (a pointer      *)
(* loaded from one of Mario's three tabled chase-root fields).  The       *)
(* chain brick (CensusV2.chain_root_l_block) pins the written block to    *)
(* the temp's value; the chase invariant says that value is SafeB         *)
(* (bm-disjoint); the rhs census makes the written value non-Vptr.        *)
(* ====================================================================== *)

(* `ct = m->marioObj` (etc.): the canonical chase-root load *)
Definition chase_root_chk (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      Pos.eqb p mario_actions_airborne._m
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && mem_id fld chase_root_fields
      && is_ptr_ty fty
  | _ => false
  end.

Lemma chase_root_chk_shape : forall a,
    chase_root_chk a = true ->
    exists fld pt pa,
      a = Efield (Ederef (Etempvar mario_actions_airborne._m (tptr tyMS))
                    tyMS) fld (Tpointer pt pa) /\
      mem_id fld chase_root_fields = true.
Proof.
  intros a H.
  destruct a as [ | | | | | | | | | | | ab fld fty | | ];
    try discriminate H.
  destruct ab as [ | | | | | | bb sty | | | | | | | ]; try discriminate H.
  destruct bb as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
  cbn [chase_root_chk] in H.
  apply andb_prop in H as [H Hptr].
  apply andb_prop in H as [H Hfld].
  apply andb_prop in H as [H Hsty].
  apply andb_prop in H as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
  destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
  destruct fty as [ | | | | pt pa | | | | ]; try discriminate Hptr.
  exists fld, pt, pa. split; [ reflexivity | exact Hfld ].
Qed.

(* every tabled chase root has a generated (delta, Full) field offset *)
Lemma chase_root_field_offset : forall fld,
    mem_id fld chase_root_fields = true ->
    exists delta,
      field_offset (prog_comp_env mario.prog) fld mario_state_members
      = OK (delta, Full).
Proof.
  intros fld Hmem.
  change ((Pos.eqb fld mario._marioObj
           || (Pos.eqb fld mario._marioBodyState
               || (Pos.eqb fld mario._statusForCamera || false)))%bool
          = true) in Hmem.
  repeat (apply orb_true_iff in Hmem; destruct Hmem as [Hm | Hmem]);
    try discriminate Hmem; apply Pos.eqb_eq in Hm; subst fld.
  - exists 136. vm_compute. reflexivity.
  - exists 152. vm_compute. reflexivity.
  - exists 148. vm_compute. reflexivity.
Qed.

(* the written value must be provably non-Vptr: a non-pointer scalar
   target (I8/I16/IBool/float -- the cast itself launders), or an I32
   target fed by an integer literal *)
Definition wchase_rhs_ok (ty : type) (a2 : expr) : bool :=
  nonptr_scalar ty
  || (i32_ty ty && match a2 with Econst_int _ _ => true | _ => false end).

Definition chase_store_chk (cact : list ident) (a1 a2 : expr) : bool :=
  match chain_root_l a1 with
  | Some ct => mem_id ct cact && wchase_rhs_ok (typeof a1) a2
  | None => false
  end.

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

(* rt = "returns are censused": true for the act-writer bodies (their
   return value feeds the caller's act tracking), false for plain
   helper leaves (call_pres says nothing about vres). *)
Definition wret_ok (rt : bool) (out : outcome) : Prop :=
  match out with
  | Out_return (Some (v, ty)) =>
      rt = true -> untainted_scalar v /\ i32_ty ty = true
  | _ => True
  end.

(* what an act temp may be Sset from: an untainted constant, or a COPY
   of another act temp (set_mario_action's `_action := _t'1` pattern;
   Sset has no cast, so the value transfers verbatim). *)
Definition wsrc_chk (wact : list ident) (a : expr) : bool :=
  match a with
  | Econst_int c _ => wact_const c
  | Etempvar q _ => mem_id q wact
  | _ => false
  end.

Fixpoint wwalk_chk (rt : bool) (wact ids wids cact : list ident)
    (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn None => true
  | Sreturn (Some a) =>
      negb rt
      || match a with
         | Econst_int c ty => i32_ty ty && wact_const c
         | Etempvar t ty => i32_ty ty && mem_id t wact
         | _ => false
         end
  | Sset id a =>
      negb (Pos.eqb id mario_actions_airborne._m)
      && (negb (mem_id id wact) || wsrc_chk wact a)
      && (negb (mem_id id cact) || chase_root_chk a)
  | Sassign a1 a2 =>
      safe_mfield_store mario_actions_airborne._m a1
      || glob_store_chk a1
      || idx_mfield_store mario_actions_airborne._m a1
      || act_store_chk wact a1 a2
      || chase_store_chk cact a1 a2
  | Scall optid a al =>
      match a with
      | Evar fid fty =>
          opt_ne_m optid
          && match optid with
             | Some t => negb (mem_id t cact)
             | None => true
             end
          && match fty, al with
             | Tfunction (ty1 :: tys) rty cc, Etempvar p pty :: args =>
                 Pos.eqb p mario_actions_airborne._m
                 && proj_sumbool (type_eq ty1 tyMSp)
                 && proj_sumbool (type_eq pty tyMSp)
                 && match optid with
                    | Some t =>
                        if mem_id t wact
                        then (* an act-writer call: result feeds wact, so
                                the second arg must itself be a censused
                                act temp at an I32 type *)
                          mem_id fid wids
                          && match tys, args with
                             | ty2 :: _, Etempvar q qty :: _ =>
                                 mem_id q wact && i32_ty ty2 && i32_ty qty
                             | _, _ => false
                             end
                        else mem_id fid ids
                    | None => mem_id fid ids
                    end
             | _, _ => false
             end
      | _ => false
      end
  | Ssequence s1 s2 =>
      wwalk_chk rt wact ids wids cact s1
      && wwalk_chk rt wact ids wids cact s2
  | Sifthenelse _ s1 s2 =>
      wwalk_chk rt wact ids wids cact s1
      && wwalk_chk rt wact ids wids cact s2
  | Sloop s1 s2 =>
      wwalk_chk rt wact ids wids cact s1
      && wwalk_chk rt wact ids wids cact s2
  | Sswitch _ sl => wwalk_chk_ls rt wact ids wids cact sl
  | _ => false
  end
with wwalk_chk_ls (rt : bool) (wact ids wids cact : list ident)
    (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' =>
      wwalk_chk rt wact ids wids cact s
      && wwalk_chk_ls rt wact ids wids cact sl'
  end.

(* ---- the switch-selection transfer (mirror of walk_chk's) ---- *)

Lemma wwalk_chk_ls_seq : forall rt wact ids wids cact sl,
    wwalk_chk_ls rt wact ids wids cact sl = true ->
    wwalk_chk rt wact ids wids cact (seq_of_labeled_statement sl) = true.
Proof.
  intros rt wact ids wids cact sl; induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn in H. apply andb_prop in H as [H1 H2].
    cbn. rewrite H1. cbn. exact (IH H2).
Qed.

Lemma wwalk_chk_ls_case : forall rt wact ids wids cact n sl sl',
    wwalk_chk_ls rt wact ids wids cact sl = true ->
    select_switch_case n sl = Some sl' ->
    wwalk_chk_ls rt wact ids wids cact sl' = true.
Proof.
  intros rt wact ids wids cact n sl; induction sl as [| o s sl0 IH];
    intros sl' H Hsel.
  - discriminate Hsel.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma wwalk_chk_ls_default : forall rt wact ids wids cact sl,
    wwalk_chk_ls rt wact ids wids cact sl = true ->
    wwalk_chk_ls rt wact ids wids cact (select_switch_default sl) = true.
Proof.
  intros rt wact ids wids cact sl; induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn.
    + exact (IH H2).
    + rewrite H1, H2. reflexivity.
Qed.

Lemma wwalk_chk_select : forall rt wact ids wids cact n sl,
    wwalk_chk_ls rt wact ids wids cact sl = true ->
    wwalk_chk rt wact ids wids cact
      (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros rt wact ids wids cact n sl H. apply wwalk_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (wwalk_chk_ls_case _ _ _ _ _ _ _ _ H E).
  - exact (wwalk_chk_ls_default _ _ _ _ _ _ H).
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

  (* the action-cell store row: MWF survives a non-pointer Mint32 store
     at (bm,12).  Instantiated by MWFReal.mwf_real_act_store. *)
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.

  (* the chase rows: instantiated by MWFReal at the capstone
     (HSafeB_not_bm / mwf_real_chase_root / mwf_real_chase). *)
  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* the act-temp invariant the walk threads through le *)
  Definition act_inv (wact : list ident) (le : temp_env) : Prop :=
    forall t, mem_id t wact = true ->
      forall x, le ! t = Some x -> untainted_scalar x.

  (* the chase-temp invariant: a censused chase temp, when it holds a
     pointer, holds a SafeB (bm-disjoint) one *)
  Definition chase_inv (cact : list ident) (le : temp_env) : Prop :=
    forall t, mem_id t cact = true ->
      forall b o, le ! t = Some (Vptr b o) -> SafeB b.

  (* ================================================================== *)
  (* The chase-root Sset brick: evaluating `m->marioObj` (etc.) forces  *)
  (* the load through (bm, root_off), whose pointer values the MWF      *)
  (* chase-root row pins into SafeB.                                    *)
  (* ================================================================== *)
  Lemma chase_root_set_sound :
    forall a e le m v,
      chase_root_chk a = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      MWF m ->
      eval_expr (lp_ge lp) e le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros a e le m v Hck Htat HM Hev b o ->.
    destruct (chase_root_chk_shape _ Hck) as (fld & pt & pa & -> & Hfld).
    destruct (chase_root_field_offset _ Hfld) as (delta & Hfo).
    inv Hev.
    (* the base temp holds Mario's pointer *)
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv0 as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb Hfo Hlv0)
          as (E3 & E4 & E5);
        subst loc ofs bf
    end.
    (* the deref: a By_value Mptr load of the root cell *)
    match goal with
    | Hd : deref_loc _ _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; inv Hd
    end.
    - match goal with
      | Hac : access_mode _ = By_value _ |- _ =>
          change (access_mode (Tpointer pt pa)) with (By_value Mptr)
            in Hac;
          injection Hac as <-
      end.
      match goal with
      | Hld : Mem.loadv Mptr _ _ = Some (Vptr _ _) |- _ =>
          exact (HchaseRoot _ _ _ _ _ Hfld Hfo HM Hld)
      end.
    - (* By_reference: access_mode of a pointer type is By_value *)
      match goal with
      | Hac : access_mode _ = By_reference |- _ =>
          cbn in Hac; discriminate Hac
      end.
    - match goal with
      | Hac : access_mode _ = By_copy |- _ =>
          cbn in Hac; discriminate Hac
      end.
    (* (the bitfield ctor is auto-killed: load_bitfield yields a Vint,
       ours is a Vptr) *)
  Qed.

  (* ================================================================== *)
  (* The chase-store brick (the v2 engine's class C, restated against   *)
  (* the walk's chase invariant): the chain brick pins the written      *)
  (* block to the temp's SafeB block; the rhs census makes the written  *)
  (* value non-Vptr; SafeB is bm-disjoint so valid/action_sat carry.    *)
  (* ================================================================== *)
  Lemma chase_assign_pres :
    forall cact a1 a2 e le m0 tr le' m' out,
      chase_store_chk cact a1 a2 = true ->
      chase_inv cact le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros cact a1 a2 e le m0 tr le' m' out Hck Hch Hexec HM HV HS.
    unfold chase_store_chk in Hck.
    destruct (chain_root_l a1) as [ct|] eqn:Hcr; [ | discriminate Hck ].
    apply andb_prop in Hck as [Hctm Hrhs].
    inv Hexec.
    (* the store target's block is the chase temp's SafeB block *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv)
          as (o0 & Hlet)
    end.
    pose proof (Hch _ Hctm _ _ Hlet) as Hsafe.
    pose proof (HSafeNotBm _ Hsafe) as Hneq.
    (* the written value is not a pointer *)
    match goal with
    | Hcast0 : sem_cast _ _ _ _ = Some ?vw |- _ =>
        assert (Hnp : forall bb oo, vw <> Vptr bb oo)
    end.
    { unfold wchase_rhs_ok in Hrhs.
      apply orb_true_iff in Hrhs as [Hsc | HI32].
      - match goal with
        | Hcast0 : sem_cast _ _ _ _ = Some _ |- _ =>
            exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hsc Hcast0)
        end.
      - apply andb_prop in HI32 as [_ Ha2].
        destruct a2; try discriminate Ha2.
        match goal with
        | Hev2 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
            inv Hev2;
            try (match goal with
                 | Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hl
                 end)
        end.
        match goal with
        | Hcast0 : sem_cast _ _ _ _ = Some _ |- _ =>
            exact (sem_cast_vint_nonptr _ _ _ _ _ Hcast0)
        end. }
    (* the store lands in the SafeB block *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has
    end.
    - (* By_value *)
      match goal with
      | Hsv0 : Mem.storev _ _ _ _ = Some m' |- _ =>
          unfold Mem.storev in Hsv0
      end.
      match goal with
      | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
          split; [ eauto using Mem.store_valid_block_1 | split ];
          [ intros av Hload;
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
            [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
          | split;
            [ exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnp Hsv)
            | split; reflexivity ] ]
      end.
    - (* By_copy: the copied value is a Vptr -- refuted by the census *)
      exfalso. exact (Hnp _ _ eq_refl).
    - (* bitfield: store_bitfield writes a Vint into the SafeB block *)
      match goal with
      | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb
      end.
      match goal with
      | Hsv0 : Mem.storev _ _ _ (Vint _) = Some m' |- _ =>
          unfold Mem.storev in Hsv0
      end.
      match goal with
      | Hsv : Mem.store _ _ _ _ (Vint _) = Some m' |- _ =>
          split; [ eauto using Mem.store_valid_block_1 | split ];
          [ intros av Hload;
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
            [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
          | split;
            [ refine (HMWF_chase _ _ _ _ _ _ HM Hsafe _ Hsv);
              intros bb oo E; discriminate E
            | split; reflexivity ] ]
      end.
  Qed.

  (* ================================================================== *)
  (* The action-store brick: m->action := t with t a censused act temp. *)
  (* The store is at the protected cell (bm,12); MWF survives via the   *)
  (* act row (the value is Vint, never a pointer), and action_sat is    *)
  (* re-established DIRECTLY by load_store_same + the temp's untainted  *)
  (* value (the one store the window machinery must never admit).       *)
  (* ================================================================== *)
  Lemma act_assign_pres :
    forall wact a1 a2 e le m0 tr le' m' out,
      act_store_chk wact a1 a2 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv wact le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros wact0 a1 a2 e le m0 tr le' m' out Hck Htat Hact Hexec HM HV.
    destruct (act_store_chk_shape _ _ _ Hck)
      as (fty & rty & t & -> & -> & Hfty & Hrty & Hmem).
    destruct fty as [ | szf sgf af | | | | | | | ]; try discriminate Hfty.
    destruct szf; try discriminate Hfty.
    destruct rty as [ | szr sgr ar | | | | | | | ]; try discriminate Hrty.
    destruct szr; try discriminate Hrty.
    inv Hexec.
    (* the base temp holds Mario's pointer *)
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv0 as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    (* the lvalue geometry: Mario's block at the action offset 12 *)
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb act_field_off Hlv0)
          as (E3 & E4 & E5);
        subst loc ofs bf
    end.
    (* the RHS: a censused act temp, hence an untainted scalar *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hev; rename Hev into Hvt
    end.
    pose proof (Hact _ Hmem _ Hvt) as Hu.
    (* the cast: I32-to-I32, a Vint survives verbatim, Vundef dies *)
    match goal with
    | Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hc; rename Hc into Hcast
    end.
    destruct Hu as [Eu | (w & Eu & Hnt)]; subst.
    { exfalso. unfold sem_cast in Hcast. cbn in Hcast.
      discriminate Hcast. }
    pose proof (sem_cast_i32_neutral _ _ _ _ _ Hrty Hfty Hcast) as ->.
    (* the assign: a By_value Mint32 store at (bm,12) *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        rewrite Ptrofs.add_zero_l in Has;
        cbn [typeof] in Has;
        inv Has
    end.
    (* only the By_value ctor survives: the copy ctor needs a Vptr value *)
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv;
        change (Ptrofs.unsigned (Ptrofs.repr 12)) with 12 in Hsv
    end.
    match goal with
    | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
        split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hsv _ HV) | ];
        split;
        [ (* action_sat: the cell now holds exactly the untainted w *)
          intros av Hload;
          rewrite (Mem.load_store_same _ _ _ _ _ _ Hsv) in Hload;
          cbn in Hload; injection Hload as <-; exact Hnt
        | split;
          [ (* MWF: the act-store row -- the value is never a pointer *)
            refine (HMWF_act _ _ _ HM _ Hsv);
            intros bb oo EE; discriminate EE
          | split; reflexivity ] ]
    end.
  Qed.

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

  (* the act-WRITER call brick: the result lands in an act temp.  The
     second argument is itself a censused act temp cast at I32 (meeting
     the row's untainted-scalar premise), and the row's vres post feeds
     the caller's act tracking. *)
  Lemma kit_scallw_pres :
    forall t fid ty2 tys rty cc q qty args le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall (Some t)
           (Evar fid (Tfunction (tyMSp :: ty2 :: tys) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp
              :: Etempvar q qty :: args))
        tr le1 m1 out0 ->
      call_pres_act lp bm NoA MWF fid ->
      i32_ty ty2 = true -> i32_ty qty = true ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      (forall x, le0 ! q = Some x -> untainted_scalar x) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      (forall x, le1 ! t = Some x -> untainted_scalar x) /\
      (forall t0, t0 <> t -> le1 ! t0 = le0 ! t0).
  Proof.
    intros t fid ty2 tys rty cc q qty args le0 m0 tr le1 m1 out0
           Hexec Hcpa Hty2 Hqty Htat Hq HN HM HV HS.
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
    (* peel the head: Mario's pointer through the identity cast *)
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
    (* peel the second arg: the censused act temp at the I32 cast *)
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hv; rename Hv into Hv2
    end.
    match goal with
    | Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        pose proof (sem_cast_i32_untainted _ _ _ _ _ Hqty Hty2
                      (Hq _ Hv2) Hc) as Hu
    end.
    (* the marg fact *)
    match goal with
    | Hv1' : le0 ! _ = Some ?vv,
      Hevf : eval_funcall _ _ _ _ (?vv :: ?vrest) _ _ _ |- _ =>
        assert (Hmarg : marg_ok bm (vv :: vrest))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _ |- _ =>
        destruct (Hcpa _ _ _ _ _ _ _ _ Hevf Hres Hmarg Hu HN HM HV HS)
          as (HV' & HS' & HM' & HN' & Hu')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN'
             (conj eq_refl (conj _ _)))))).
    { intros x Hg. cbn [set_opttemp] in Hg.
      rewrite PTree.gss in Hg. injection Hg as <-. exact Hu'. }
    intros t0 Hne. cbn [set_opttemp].
    rewrite PTree.gso by exact Hne. reflexivity.
  Qed.

  (* ================================================================== *)
  (* THE WRITER WALK.                                                   *)
  (* ================================================================== *)
  Lemma wwalk_pres :
    forall (rt : bool) (wact ids wids cact : list ident),
      (forall fid, mem_id fid ids = true -> call_pres lp bm NoA MWF fid) ->
      (forall fid, mem_id fid wids = true ->
                   call_pres_act lp bm NoA MWF fid) ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        e = empty_env ->
        wwalk_chk rt wact ids wids cact s = true ->
        (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        act_inv wact le ->
        chase_inv cact le ->
        NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
        action_sat not_tainted m0 bm ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
        NoA m' /\
        (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        act_inv wact le' /\ chase_inv cact le' /\ wret_ok rt out.
  Proof.
    intros rt wact ids wids cact Hcp Hcpa s e le m0 tr le' m' out Hexec.
    induction Hexec; intros He Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch I))))))).
    - (* Sassign: window / global / indexed-window / action-store bricks *)
      cbn [wwalk_chk] in Hchk.
      subst e.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hcs].
      2:{ destruct (chase_assign_pres _ a1 a2 _ _ _ _ _ _ _ Hcs Hch
                      Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hac].
      2:{ destruct (act_assign_pres _ a1 a2 _ _ _ _ _ _ _ Hac Htat Hact
                      Hex HM HV)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hix].
      + apply orb_true_iff in Hchk.
        destruct Hchk as [Hsf | Hgs].
        * destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                      a1 a2 _ _ _ _ _ _ _ Hsf Htat Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))).
        * destruct (glob_assign_pres lp bm MWF HMWF_glob
                      a1 a2 _ _ _ _ _ _ Hgs Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))).
      + destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hix Htat Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                 (conj Htat (conj Hact (conj Hch I))))))).
    - (* Sset: non-_m; an act temp only from an untainted const or copy;
         a chase temp only from a canonical chase-root load *)
      cbn [wwalk_chk] in Hchk.
      apply andb_prop in Hchk as [Hchk Hcc].
      apply andb_prop in Hchk as [Hnm Hrest].
      refine (conj HV (conj HS (conj HM (conj HN
               (conj _ (conj _ (conj _ I))))))).
      + intros b o Hg.
        rewrite PTree.gso in Hg
          by (intro EE; rewrite <- EE in Hnm; cbn in Hnm;
              discriminate Hnm).
        exact (Htat _ _ Hg).
      + intros t Hmem x Hg.
        destruct (Pos.eq_dec t id) as [-> | Hne].
        * rewrite PTree.gss in Hg. injection Hg as <-.
          rewrite Hmem in Hrest. cbn [negb orb] in Hrest.
          destruct a as [ c cty | | | | | q qty | | | | | | | | ];
            try discriminate Hrest;
            cbn [wsrc_chk] in Hrest.
          { (* untainted constant *)
            match goal with
            | Hev : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
                inv Hev;
                try (match goal with
                     | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _
                       |- _ => inv Hlv
                     end)
            end.
            exact (wact_const_sound _ Hrest). }
          { (* copy of another act temp: the value transfers verbatim *)
            match goal with
            | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
                apply eval_expr_Etempvar_val in Hev;
                exact (Hact _ Hrest _ Hev)
            end. }
        * rewrite PTree.gso in Hg by exact Hne.
          exact (Hact _ Hmem _ Hg).
      + intros t Hmem b o Hg.
        destruct (Pos.eq_dec t id) as [-> | Hne].
        * rewrite PTree.gss in Hg. injection Hg as ->.
          rewrite Hmem in Hcc. cbn [negb orb] in Hcc.
          match goal with
          | Hev : eval_expr _ _ _ _ a _ |- _ =>
              exact (chase_root_set_sound _ _ _ _ _ Hcc Htat HM Hev
                       _ _ eq_refl)
          end.
        * rewrite PTree.gso in Hg by exact Hne.
          exact (Hch _ Hmem _ _ Hg).
    - (* Scall: censused Mario-head call (plain, or into an act temp) *)
      subst e.
      destruct a as [ ci cty | cf cty | cs cty | cl cty | cid fty | tv tvy
                    | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                    | f1 f2 f3 | s1' s2' | g1 g2 ];
        try discriminate Hchk.
      cbn [wwalk_chk] in Hchk.
      apply andb_prop in Hchk as [Hchk1 Hchk].
      apply andb_prop in Hchk1 as [Hopt Hnc].
      destruct fty as [ | i1 i2 i3 | l1' l2' | r1 r2 | p1 p2 | ar1 ar2 ar3
                      | params res cc | st1 st2 | un1 un2 ];
        try discriminate Hchk.
      destruct params as [| ty1 tys]; try discriminate Hchk.
      destruct al as [| a1 args]; try discriminate Hchk.
      destruct a1 as [ xa xb | xa xb | xa xb | xa xb | xa xb | p pty
                     | xa xb | xa xb | xa xb xc | xa xb xc xd | xa xb
                     | xa xb xc | xa xb | xa xb ];
        try discriminate Hchk.
      apply andb_prop in Hchk as [Hchk Hbr].
      apply andb_prop in Hchk as [Hchk Hpty].
      apply andb_prop in Hchk as [Hp Hty1].
      apply Pos.eqb_eq in Hp. subst p.
      destruct (type_eq ty1 tyMSp); [ subst ty1 | discriminate Hty1 ].
      destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
      destruct optid as [t'|].
      + (* a result-carrying call *)
        destruct (mem_id t' wact) eqn:Hmw.
        * (* the act-WRITER call: the result feeds the act tracking *)
          apply andb_prop in Hbr as [Hfw Hbr].
          destruct tys as [| ty2 tys']; try discriminate Hbr.
          destruct args as [| aq args']; try discriminate Hbr.
          destruct aq as [ ya yb | ya yb | ya yb | ya yb | ya yb | q qty
                         | ya yb | ya yb | ya yb yc | ya yb yc yd | ya yb
                         | ya yb yc | ya yb | ya yb ];
            try discriminate Hbr.
          apply andb_prop in Hbr as [Hbr Hqty].
          apply andb_prop in Hbr as [Hq Hty2].
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                          (Scall (Some t')
                             (Evar cid (Tfunction (tyMSp :: ty2 :: tys')
                                          res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: Etempvar q qty :: args'))
                          t (set_opttemp (Some t') vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scallw_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hex
                      (Hcpa _ Hfw) Hty2 Hqty Htat
                      (fun x Hx => Hact _ Hq x Hx) HN HM HV HS)
            as (HV' & HS' & HM' & HN' & _ & Hnew & Hold).
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                   (conj _ (conj _ (conj _ I))))))).
          { intros b o Hg.
            rewrite Hold in Hg
              by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                  discriminate Hopt).
            exact (Htat _ _ Hg). }
          { intros t0 Hmem x Hg.
            destruct (Pos.eq_dec t0 t') as [-> | Hne].
            - exact (Hnew _ Hg).
            - rewrite Hold in Hg by exact Hne.
              exact (Hact _ Hmem _ Hg). }
          { intros t0 Hmem b o Hg.
            destruct (Pos.eq_dec t0 t') as [-> | Hne].
            - rewrite Hmem in Hnc. discriminate Hnc.
            - rewrite Hold in Hg by exact Hne.
              exact (Hch _ Hmem _ _ Hg). }
        * (* plain censused call, result NOT into an act temp *)
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                          (Scall (Some t')
                             (Evar cid (Tfunction (tyMSp :: tys) res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: args))
                          t (set_opttemp (Some t') vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scalln_pres
                      _ _ _ _ _ _ _ _ _ _ _ _ Hex (Hcp _ Hbr) Htat
                      HN HM HV HS)
            as (HV' & HS' & HM' & HN' & _ & _).
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                   (conj _ (conj _ (conj _ I))))))).
          { intros b o Hg. cbn [set_opttemp] in Hg.
            rewrite PTree.gso in Hg
              by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                  discriminate Hopt).
            exact (Htat _ _ Hg). }
          { intros t0 Hmem x Hg. cbn [set_opttemp] in Hg.
            rewrite PTree.gso in Hg
              by (intro EE; rewrite EE in Hmem; rewrite Hmem in Hmw;
                  discriminate Hmw).
            exact (Hact _ Hmem _ Hg). }
          { intros t0 Hmem b o Hg. cbn [set_opttemp] in Hg.
            rewrite PTree.gso in Hg
              by (intro EE; rewrite EE in Hmem; rewrite Hmem in Hnc;
                  discriminate Hnc).
            exact (Hch _ Hmem _ _ Hg). }
      + (* a result-less call *)
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                        (Scall None
                           (Evar cid (Tfunction (tyMSp :: tys) res cc))
                           (Etempvar mario_actions_airborne._m tyMSp
                              :: args))
                        t (set_opttemp None vres le) m' Out_normal)
          by (econstructor; eauto).
        destruct (kit_scalln_pres
                    _ _ _ _ _ _ _ _ _ _ _ _ Hex (Hcp _ Hbr) Htat
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        refine (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj _ (conj _ (conj _ I))))))).
        { intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat _ _ Hg). }
        { intros t0 Hmem x Hg. cbn [set_opttemp] in Hg.
          exact (Hact _ Hmem _ Hg). }
        { intros t0 Hmem b o Hg. cbn [set_opttemp] in Hg.
          exact (Hch _ Hmem _ _ Hg). }
    - (* Sbuiltin: excluded *)
      cbn [wwalk_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & _).
      exact (IHHexec2 He H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec He H1 Htat Hact Hch HN HM HV HS).
    - (* Sifthenelse *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch I))))))).
    - (* Sreturn (Some a): the censused return (only when rt = true) *)
      cbn [wwalk_chk] in Hchk.
      refine (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch _))))))).
      destruct rt; [ | intro Hrt; discriminate Hrt ].
      cbn [negb orb] in Hchk.
      destruct a as [ c cty | | | | | tret tty | | | | | | | | ];
        try discriminate Hchk;
        apply andb_prop in Hchk as [Hi32 Hsnd];
        intros _.
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
               (conj Htat (conj Hact (conj Hch I))))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch I))))))).
    - (* Sloop stop1 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      destruct (IHHexec He H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & Hret1).
      refine (conj HV1 (conj HS1 (conj HM1 (conj HN1
               (conj Htat1 (conj Hact1 (conj Hch1 _))))))).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + exact I.
      + exact Hret1.
    - (* Sloop stop2 *)
      cbn [wwalk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & _).
      destruct (IHHexec2 He H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Htat2 & Hact2 & Hch2 & Hret2).
      refine (conj HV2 (conj HS2 (conj HM2 (conj HN2
               (conj Htat2 (conj Hact2 (conj Hch2 _))))))).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + exact I.
      + exact Hret2.
    - (* Sloop loop *)
      cbn [wwalk_chk] in Hchk.
      pose proof Hchk as Hchk2.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & _).
      destruct (IHHexec2 He H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Htat2 & Hact2 & Hch2 & _).
      apply IHHexec3; try assumption;
        cbn [wwalk_chk]; exact Hchk2.
    - (* Sswitch *)
      cbn [wwalk_chk] in Hchk.
      destruct (IHHexec He (wwalk_chk_select _ _ _ _ _ n _ Hchk)
                  Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & Hret1).
      refine (conj HV1 (conj HS1 (conj HM1 (conj HN1
               (conj Htat1 (conj Hact1 (conj Hch1 _))))))).
      destruct out as [ | | | ov ]; try exact I.
      exact Hret1.
  Qed.

End ActWriterWalk.

(* ====================================================================== *)
(* Function-entry plumbing: parameter binds and the undef temps.          *)
(* ====================================================================== *)

Lemma create_undef_temps_val : forall temps t x,
    (create_undef_temps temps) ! t = Some x -> x = Vundef.
Proof.
  induction temps as [| [id ty] tl IH]; intros t x H; cbn in H.
  - discriminate H.
  - destruct (Pos.eq_dec t id) as [-> | Hne].
    + rewrite PTree.gss in H. injection H as <-. reflexivity.
    + rewrite PTree.gso in H by exact Hne. exact (IH _ _ H).
Qed.

Lemma bind_params_other : forall ps vl base le t,
    bind_parameter_temps ps vl base = Some le ->
    mem_id t (map fst ps) = false ->
    le ! t = base ! t.
Proof.
  induction ps as [| [id ty] tl IH]; intros vl base le t Hb Hm.
  - destruct vl; cbn in Hb; [ injection Hb as <- | discriminate Hb ].
    reflexivity.
  - destruct vl as [| v vl']; cbn in Hb; [ discriminate Hb | ].
    unfold mem_id in Hm. cbn [map fst existsb] in Hm.
    apply orb_false_iff in Hm as [H1 H2].
    apply Pos.eqb_neq in H1.
    rewrite (IH _ _ _ _ Hb H2).
    rewrite PTree.gso by exact H1.
    reflexivity.
Qed.

(* ====================================================================== *)
(* The generated bodies, pinned and walked (vm_compute over the AST).     *)
(* ====================================================================== *)

(* the act-temp censuses *)
Definition wact_sub : list ident := mario._action :: nil.
Definition wact_smact : list ident :=
  mario._action :: mario._t'1 :: mario._t'2 :: mario._t'3 :: mario._t'4
    :: nil.
(* the writer census (the four sub-setters), and cutscene's one callee *)
Definition smact_wids : list ident :=
  mario._set_mario_action_moving :: mario._set_mario_action_airborne ::
  mario._set_mario_action_submerged :: mario._set_mario_action_cutscene
    :: nil.
Definition smac_ids : list ident := mario._mario_set_forward_vel :: nil.

(* the shared writer parameter list (all four sub-setters + the writer) *)
Definition writer_params : list (ident * type) :=
  (mario_actions_airborne._m, tyMSp)
    :: (mario._action, tuint) :: (mario._actionArg, tuint) :: nil.

(* ---- defmap pins: each walked body is Internal in mario.prog ---- *)
Example smas_pin :
  (prog_defmap mario.prog) ! mario._set_mario_action_submerged
  = Some (Gfun (Internal mario.f_set_mario_action_submerged)).
Proof. vm_compute. reflexivity. Qed.

Example smac_pin :
  (prog_defmap mario.prog) ! mario._set_mario_action_cutscene
  = Some (Gfun (Internal mario.f_set_mario_action_cutscene)).
Proof. vm_compute. reflexivity. Qed.

Example smact_pin :
  (prog_defmap mario.prog) ! mario._set_mario_action
  = Some (Gfun (Internal mario.f_set_mario_action)).
Proof. vm_compute. reflexivity. Qed.

Example msfv_pin :
  (prog_defmap mario.prog) ! mario._mario_set_forward_vel
  = Some (Gfun (Internal mario.f_mario_set_forward_vel)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shape pins ---- *)
Example smas_vars : fn_vars mario.f_set_mario_action_submerged = nil.
Proof. vm_compute. reflexivity. Qed.
Example smas_params :
  fn_params mario.f_set_mario_action_submerged = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smas_ret : fn_return mario.f_set_mario_action_submerged = tuint.
Proof. vm_compute. reflexivity. Qed.

Example smac_vars : fn_vars mario.f_set_mario_action_cutscene = nil.
Proof. vm_compute. reflexivity. Qed.
Example smac_params :
  fn_params mario.f_set_mario_action_cutscene = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smac_ret : fn_return mario.f_set_mario_action_cutscene = tuint.
Proof. vm_compute. reflexivity. Qed.

Example smact_vars : fn_vars mario.f_set_mario_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example smact_params : fn_params mario.f_set_mario_action = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smact_ret : fn_return mario.f_set_mario_action = tuint.
Proof. vm_compute. reflexivity. Qed.

Example msfv_vars : fn_vars mario.f_mario_set_forward_vel = nil.
Proof. vm_compute. reflexivity. Qed.
(* msfv: Mario's pointer at the head, no later param shadows _m *)
Example msfv_params_ok :
  match fn_params mario.f_mario_set_forward_vel with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the walks (the heavy vm pins over the real bodies) ---- *)
Example smas_walk :
  wwalk_chk true wact_sub nil nil nil
    (fn_body mario.f_set_mario_action_submerged) = true.
Proof. vm_compute. reflexivity. Qed.

Example smac_walk :
  wwalk_chk true wact_sub smac_ids nil nil
    (fn_body mario.f_set_mario_action_cutscene) = true.
Proof. vm_compute. reflexivity. Qed.

Example smact_walk :
  wwalk_chk true wact_smact nil smact_wids nil
    (fn_body mario.f_set_mario_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the writer census bites -- an empty wids fails *)
Example smact_walk_not_vacuous :
  wwalk_chk true wact_smact nil nil nil
    (fn_body mario.f_set_mario_action) = false.
Proof. vm_compute. reflexivity. Qed.

Example msfv_walk :
  wwalk_chk false nil nil nil nil
    (fn_body mario.f_mario_set_forward_vel) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- MOVING (smam): the chase census traces _t'7 := m->marioObj and
   the rawData.asS32[34] := 0 store through it.  Its two plain callees
   (mario_get_floor_class / mario_facing_downhill) walk with empty
   censuses. ---- *)
Definition mov_ids : list ident :=
  mario._mario_get_floor_class :: mario._mario_facing_downhill :: nil.
Definition mov_cact : list ident := mario._t'7 :: nil.

Example smam_pin :
  (prog_defmap mario.prog) ! mario._set_mario_action_moving
  = Some (Gfun (Internal mario.f_set_mario_action_moving)).
Proof. vm_compute. reflexivity. Qed.

Example smam_vars : fn_vars mario.f_set_mario_action_moving = nil.
Proof. vm_compute. reflexivity. Qed.
Example smam_params :
  fn_params mario.f_set_mario_action_moving = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smam_ret : fn_return mario.f_set_mario_action_moving = tuint.
Proof. vm_compute. reflexivity. Qed.

Example smam_walk :
  wwalk_chk true wact_sub mov_ids nil mov_cact
    (fn_body mario.f_set_mario_action_moving) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the chase census bites -- an empty cact fails *)
Example smam_walk_not_vacuous :
  wwalk_chk true wact_sub mov_ids nil nil
    (fn_body mario.f_set_mario_action_moving) = false.
Proof. vm_compute. reflexivity. Qed.

Example mgfc_pin :
  (prog_defmap mario.prog) ! mario._mario_get_floor_class
  = Some (Gfun (Internal mario.f_mario_get_floor_class)).
Proof. vm_compute. reflexivity. Qed.

Example mgfc_vars : fn_vars mario.f_mario_get_floor_class = nil.
Proof. vm_compute. reflexivity. Qed.
Example mgfc_params_ok :
  match fn_params mario.f_mario_get_floor_class with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Example mgfc_walk :
  wwalk_chk false nil nil nil nil
    (fn_body mario.f_mario_get_floor_class) = true.
Proof. vm_compute. reflexivity. Qed.

Example mfd_pin :
  (prog_defmap mario.prog) ! mario._mario_facing_downhill
  = Some (Gfun (Internal mario.f_mario_facing_downhill)).
Proof. vm_compute. reflexivity. Qed.

Example mfd_vars : fn_vars mario.f_mario_facing_downhill = nil.
Proof. vm_compute. reflexivity. Qed.
Example mfd_params_ok :
  match fn_params mario.f_mario_facing_downhill with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Example mfd_walk :
  wwalk_chk false nil nil nil nil
    (fn_body mario.f_mario_facing_downhill) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)
Section ActWriterRows.
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
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.

  (* the chase rows (same shapes as the walk section's; instantiated by
     MWFReal at the capstone) *)
  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* ---- the funcall->body entry for a PLAIN walked leaf (rt = false,
     no act census): any param list with Mario's pointer at the head. *)
  Lemma call_pres_of_wwalk :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (ids wids : list ident),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil ->
      match fn_params f with
      | (i, ty) :: ps =>
          Pos.eqb i mario_actions_airborne._m
          && proj_sumbool (type_eq ty tyMSp)
          && negb (mem_id mario_actions_airborne._m (map fst ps))
      | nil => false
      end = true ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids nil (fn_body f) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros TU fid f ids wids LOtu Hdm Hvars Hps Hcp Hcpa Hchk
           fd m0 vargs0 t0 m1 vres0 Hevf Hres Hmarg HN HM HV HS.
    pose proof (resolve_pin_fd lp _ _ _ _ LOtu Hdm Hres) as ->.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        rewrite Hvars in Ha; inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    destruct (fn_params f) as [| [i ty] ps ] eqn:Eps;
      [ discriminate Hps | ].
    apply andb_prop in Hps as [Hps Hnm].
    apply andb_prop in Hps as [Hi Hty].
    apply Pos.eqb_eq in Hi. subst i.
    destruct (type_eq ty tyMSp); [ subst ty | discriminate Hty ].
    apply negb_true_iff in Hnm.
    destruct vargs0 as [| v0 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    (* the entry env facts *)
    match goal with
    | Hbind' : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
        assert (Htat0 : forall b o,
                   le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero)
          by (intros b o Hg;
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnm) in Hg;
              rewrite PTree.gss in Hg; injection Hg as ->;
              cbn in Hmarg; exact Hmarg);
        assert (Hact0 : act_inv nil le1)
          by (intros t' Hmem' x Hg'; discriminate Hmem');
        assert (Hch0 : chase_inv SafeB nil le1)
          by (intros t' Hmem' b o Hg'; discriminate Hmem')
    end.
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the walk *)
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                false nil ids wids nil Hcp Hcpa
                _ _ _ _ _ _ _ _ Hbody eq_refl Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the funcall->body entry for a WRITER (rt = true): the shared
     three-param shape; the act census is seeded by the untainted action
     argument, every other censused temp starts Vundef. *)
  Lemma call_pres_act_of_wwalk :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (wact ids wids cact : list ident),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil ->
      fn_params f = writer_params ->
      fn_return f = tuint ->
      mem_id mario._action wact = true ->
      mem_id mario_actions_airborne._m wact = false ->
      mem_id mario._actionArg wact = false ->
      mem_id mario_actions_airborne._m cact = false ->
      mem_id mario._action cact = false ->
      mem_id mario._actionArg cact = false ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk true wact ids wids cact (fn_body f) = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros TU fid f wact ids wids cact LOtu Hdm Hvars Hparams Hret
           Hwa Hwm Hwarg Hcm Hca Hcarg Hcp Hcpa Hchk
           fd m0 v0 aval rest t0 m1 vres0 Hevf Hres Hmarg Hu HN HM HV HS.
    pose proof (resolve_pin_fd lp _ _ _ _ LOtu Hdm Hres) as ->.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hout
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        rewrite Hvars in Ha; inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    rewrite Hparams in Hbind. unfold writer_params in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct rest as [| v2 rest2 ];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct rest2 as [| v3 rest3 ];
      cbn [bind_parameter_temps] in Hbind; [ | discriminate Hbind ].
    injection Hbind as <-.
    set (base := create_undef_temps (fn_temps f)) in *.
    (* the entry env facts *)
    assert (Htat0 : forall b o,
               (PTree.set mario._actionArg v2
                  (PTree.set mario._action aval
                     (PTree.set mario_actions_airborne._m v0 base)))
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hact0 : act_inv wact
               (PTree.set mario._actionArg v2
                  (PTree.set mario._action aval
                     (PTree.set mario_actions_airborne._m v0 base)))).
    { intros t' Hmem' x Hg'.
      destruct (Pos.eq_dec t' mario._actionArg) as [-> | Hne1].
      { rewrite Hmem' in Hwarg. discriminate Hwarg. }
      rewrite PTree.gso in Hg' by exact Hne1.
      destruct (Pos.eq_dec t' mario._action) as [-> | Hne2].
      { rewrite PTree.gss in Hg'. injection Hg' as <-. exact Hu. }
      rewrite PTree.gso in Hg' by exact Hne2.
      destruct (Pos.eq_dec t' mario_actions_airborne._m) as [-> | Hne3].
      { rewrite Hmem' in Hwm. discriminate Hwm. }
      rewrite PTree.gso in Hg' by exact Hne3.
      left. exact (create_undef_temps_val _ _ _ Hg'). }
    assert (Hch0 : chase_inv SafeB cact
               (PTree.set mario._actionArg v2
                  (PTree.set mario._action aval
                     (PTree.set mario_actions_airborne._m v0 base)))).
    { intros t' Hmem' b o Hg'.
      destruct (Pos.eq_dec t' mario._actionArg) as [-> | Hne1].
      { rewrite Hmem' in Hcarg. discriminate Hcarg. }
      rewrite PTree.gso in Hg' by exact Hne1.
      destruct (Pos.eq_dec t' mario._action) as [-> | Hne2].
      { rewrite Hmem' in Hca. discriminate Hca. }
      rewrite PTree.gso in Hg' by exact Hne2.
      destruct (Pos.eq_dec t' mario_actions_airborne._m) as [-> | Hne3].
      { rewrite Hmem' in Hcm. discriminate Hcm. }
      rewrite PTree.gso in Hg' by exact Hne3.
      pose proof (create_undef_temps_val _ _ _ Hg') as EE.
      discriminate EE. }
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the walk *)
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                true wact ids wids cact Hcp Hcpa
                _ _ _ _ _ _ _ _ Hbody eq_refl Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & Hret').
    (* the return value: fn_return = tuint forces a censused return *)
    rewrite Hret in Hout.
    unfold outcome_result_value, tuint in Hout.
    match type of Hret' with
    | wret_ok _ ?oo => destruct oo as [ | | | ov ]
    end.
    - destruct Hout.
    - destruct Hout.
    - destruct Hout.
    - destruct ov as [ [v' t'] | ]; [ | destruct Hout ].
      destruct Hout as [_ Hcast].
      destruct (Hret' eq_refl) as [Huv Hi32'].
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (sem_cast_i32_untainted _ _ _ _ _ Hi32'
                  (eq_refl : i32_ty (Tint I32 Unsigned noattr) = true)
                  Huv Hcast))))).
  Qed.

  (* ---- the helper row: mario_set_forward_vel (PROVED -- its only
     non-window store is the vel[0] indexed write). ---- *)
  Lemma msfv_row : call_pres lp bm NoA MWF mario._mario_set_forward_vel.
  Proof.
    apply (call_pres_of_wwalk mario.prog mario._mario_set_forward_vel
             mario.f_mario_set_forward_vel nil nil LO_mario
             msfv_pin msfv_vars msfv_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact msfv_walk.
  Qed.

  Lemma smac_ids_rows : forall fid, mem_id fid smac_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold smac_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | Hrest].
    - apply Pos.eqb_eq in Hm. subst fid. exact msfv_row.
    - discriminate Hrest.
  Qed.

  (* ---- sub-setter rows: submerged and cutscene, PROVED. ---- *)
  Lemma smas_row :
    call_pres_act lp bm NoA MWF mario._set_mario_action_submerged.
  Proof.
    apply (call_pres_act_of_wwalk mario.prog _
             mario.f_set_mario_action_submerged wact_sub nil nil nil
             LO_mario smas_pin smas_vars smas_params smas_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smas_walk.
  Qed.

  Lemma smac_row :
    call_pres_act lp bm NoA MWF mario._set_mario_action_cutscene.
  Proof.
    apply (call_pres_act_of_wwalk mario.prog _
             mario.f_set_mario_action_cutscene wact_sub smac_ids nil nil
             LO_mario smac_pin smac_vars smac_params smac_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact smac_ids_rows.
    - intros fid' H. discriminate H.
    - exact smac_walk.
  Qed.

  (* ---- the MOVING row, PROVED via the chase census (cact = [_t'7]
     traces the marioObj pointer; its rawData.asS32[34] := 0 store is
     the chase_store_chk arm). ---- *)
  Lemma mgfc_row : call_pres lp bm NoA MWF mario._mario_get_floor_class.
  Proof.
    apply (call_pres_of_wwalk mario.prog mario._mario_get_floor_class
             mario.f_mario_get_floor_class nil nil LO_mario
             mgfc_pin mgfc_vars mgfc_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mgfc_walk.
  Qed.

  Lemma mfd_row : call_pres lp bm NoA MWF mario._mario_facing_downhill.
  Proof.
    apply (call_pres_of_wwalk mario.prog mario._mario_facing_downhill
             mario.f_mario_facing_downhill nil nil LO_mario
             mfd_pin mfd_vars mfd_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mfd_walk.
  Qed.

  Lemma mov_ids_rows : forall fid, mem_id fid mov_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mfd_row | ].
    discriminate H.
  Qed.

  Lemma smam_row :
    call_pres_act lp bm NoA MWF mario._set_mario_action_moving.
  Proof.
    apply (call_pres_act_of_wwalk mario.prog _
             mario.f_set_mario_action_moving wact_sub mov_ids nil mov_cact
             LO_mario smam_pin smam_vars smam_params smam_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact mov_ids_rows.
    - intros fid' H. discriminate H.
    - exact smam_walk.
  Qed.

  (* ---- THE ONE DEFERRED ROW (named per-symbol residual): airborne
     stores through a chased gfx pointer (animID, 4 Efield hops) AND has
     two tshort faceAngle[i] indexed stores -- needs the chase census
     keyed on its real temp plus an element-generalized idx arm.  A real
     generated body, finite and walkable; not a forall-phantom. ---- *)
  Hypothesis Hpres_smaa :
    call_pres_act lp bm NoA MWF mario._set_mario_action_airborne.

  Lemma smact_wids_rows : forall fid, mem_id fid smact_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold smact_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smam_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpres_smaa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smas_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smac_row | ].
    discriminate H.
  Qed.

  (* ================================================================== *)
  (* THE KEYSTONE: the call_pres_act row for set_mario_action itself.   *)
  (* Every one of the ~200 act-leaf bodies calls it; this is the row    *)
  (* their censuses consume.                                            *)
  (* ================================================================== *)
  Theorem smact_pres :
    call_pres_act lp bm NoA MWF mario._set_mario_action.
  Proof.
    apply (call_pres_act_of_wwalk mario.prog _ mario.f_set_mario_action
             wact_smact nil smact_wids nil
             LO_mario smact_pin smact_vars smact_params smact_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - exact smact_wids_rows.
    - exact smact_walk.
  Qed.

End ActWriterRows.
