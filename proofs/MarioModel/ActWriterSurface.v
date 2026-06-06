(* ====================================================================== *)
(* THE ACT-WRITER KEYSTONE (SPINE: consumed by the object-family leaf     *)
(* rows in ObjectLeafSurface, which the capstone consumes):               *)
(* set_mario_action and its four sub-setters, walked.                     *)
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
From SM64.Generated Require mario mario_step mario_actions_airborne
  interaction mario_actions_object.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface LocalVarsSurface.

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

(* the THIRD-position writer residual shape (the asgs class): Mario's
   pointer first, anything second, an UNTAINTED scalar action third.
   No return-value claim -- nothing consumes the result. *)
Definition call_pres_act3 (lp : Clight.program) (bm : block)
    (NoA MWF : mem -> Prop) (fid : ident) : Prop :=
  forall fd m0 v0 v1 aval rest t0 m1 vres0,
    eval_funcall function_entry2 (lp_ge lp) m0 fd
      (v0 :: v1 :: aval :: rest) t0 m1 vres0 ->
    resolves_lp lp fid fd ->
    marg_ok bm (v0 :: v1 :: aval :: rest) ->
    untainted_scalar aval ->
    NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
    action_sat not_tainted m0 bm ->
    Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
    MWF m1 /\ NoA m1.

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
(* Non-pointer value bricks: no sem_cast case CONSTRUCTS a pointer (a     *)
(* Vptr result is always the input passed through), a shift never makes   *)
(* one, and a sub-word load never decodes one.                            *)
(* ====================================================================== *)

Lemma sem_cast_vptr_inv : forall v t1 t2 m bb oo,
    sem_cast v t1 t2 m = Some (Vptr bb oo) -> v = Vptr bb oo.
Proof.
  intros v t1 t2 m bb oo Hc.
  unfold sem_cast in Hc.
  destruct (classify_cast t1 t2);
    destruct v as [ | i | l | f | s | b0 o0 ]; cbn in Hc;
    try discriminate Hc;
    repeat match goal with
           | H : (if ?b then _ else _) = Some _ |- _ =>
               destruct b; try discriminate H
           | H : match ?x with _ => _ end = Some _ |- _ =>
               destruct x; try discriminate H
           end;
    try discriminate Hc;
    try (injection Hc as E1 E2; subst; reflexivity);
    (injection Hc as E1; discriminate E1).
Qed.

Lemma sem_cast_nonptr_pres : forall v t1 t2 m w,
    sem_cast v t1 t2 m = Some w ->
    (forall bb oo, v <> Vptr bb oo) ->
    forall bb oo, w <> Vptr bb oo.
Proof.
  intros v t1 t2 m w Hc Hnp bb oo ->.
  exact (Hnp _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
Qed.

Lemma sem_shl_nonptr : forall v1 t1 v2 t2 v,
    sem_shl v1 t1 v2 t2 = Some v ->
    forall bb oo, v <> Vptr bb oo.
Proof.
  intros v1 t1 v2 t2 v Hs bb oo ->.
  unfold sem_shl, sem_shift in Hs.
  destruct (classify_shift t1 t2);
    destruct v1; try discriminate Hs;
    destruct v2; try discriminate Hs;
    repeat match goal with
           | H : (if ?b then _ else _) = Some _ |- _ =>
               destruct b; try discriminate H
           end;
    injection Hs as Hs; discriminate Hs.
Qed.

(* sub-word By_value loads: decode_val's sub-word cases are Vint/Vundef *)
Definition subword_chunk (ch : memory_chunk) : bool :=
  match ch with
  | Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned => true
  | _ => false
  end.

Lemma load_subword_nonptr : forall ch m b o v,
    subword_chunk ch = true ->
    Mem.load ch m b o = Some v ->
    forall bb oo, v <> Vptr bb oo.
Proof.
  intros ch m b o v Hch Hld bb oo ->.
  apply Mem.load_result in Hld.
  destruct ch; try discriminate Hch;
    unfold decode_val in Hld;
    destruct (proj_bytes _); discriminate Hld.
Qed.

Definition small_int_ty (ty : type) : bool :=
  match ty with
  | Tint I8 _ _ | Tint I16 _ _ => true
  | _ => false
  end.

Lemma small_int_access : forall ty, small_int_ty ty = true ->
    exists ch, access_mode ty = By_value ch /\ subword_chunk ch = true.
Proof.
  intros ty H.
  destruct ty as [ | sz sg aa | | | | | | | ]; try discriminate H.
  destruct sz; try discriminate H; destruct sg;
    eexists; split; reflexivity.
Qed.

(* ====================================================================== *)
(* The INDEXED window store: m->vel[CONST] = ... (a float Vec3 cell).     *)
(* All four sub-setters write m->vel[1]; the geometry check pins the      *)
(* final byte offset delta + 4*idx inside the window.                     *)
(* ====================================================================== *)

(* esz = the array element stride, ch = the element's access chunk
   (tfloat -> 4/Mfloat32, tshort -> 2/Mint16signed) *)
Definition idx_geom_chk (fld : ident) (idx : int) (esz : Z)
    (ch : memory_chunk) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (delta, Full) =>
      (0 <=? delta)%Z
      && (0 <=? Int.signed idx)%Z
      && store_window_ok (delta + esz * Int.signed idx) (size_chunk ch)
  | _ => false
  end.

Lemma idx_geom_chk_sound : forall fld idx esz ch,
    idx_geom_chk fld idx esz ch = true ->
    exists delta,
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) /\
      0 <= delta /\
      0 <= Int.signed idx /\
      store_window_ok (delta + esz * Int.signed idx) (size_chunk ch)
        = true.
Proof.
  intros fld idx esz ch H. unfold idx_geom_chk in H.
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
      && idx_geom_chk fld idx 4 Mfloat32
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
      idx_geom_chk fld idx 4 Mfloat32 = true.
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

(* the tshort (Vec3s) twin: m->faceAngle[CONST] = ... (2-byte elements,
   Mint16signed access). *)
Definition idx16_mfield_store (mptr : ident) (a1 : expr) : bool :=
  match a1 with
  | Ederef
      (Ebinop Oadd
         (Efield (Ederef (Etempvar p pty) sty) fld aty)
         (Econst_int idx ity) (Tpointer ety pattr)) dty =>
      Pos.eqb p mptr
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && proj_sumbool (type_eq aty (tarray tshort 3))
      && proj_sumbool (type_eq ity tint)
      && proj_sumbool (type_eq ety tshort)
      && proj_sumbool (type_eq dty tshort)
      && idx_geom_chk fld idx 2 Mint16signed
  | _ => false
  end.

Lemma idx16_mfield_store_shape : forall mptr a1,
    idx16_mfield_store mptr a1 = true ->
    exists fld idx pattr,
      a1 = Ederef
             (Ebinop Oadd
                (Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) fld
                   (tarray tshort 3))
                (Econst_int idx tint) (Tpointer tshort pattr)) tshort /\
      idx_geom_chk fld idx 2 Mint16signed = true.
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
  destruct (type_eq aty (tarray tshort 3)); [ subst aty | discriminate Haty ].
  destruct (type_eq ity tint); [ subst ity | discriminate Hity ].
  destruct (type_eq ety tshort); [ subst ety | discriminate Hety ].
  destruct (type_eq dty tshort); [ subst dty | discriminate Hdty ].
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

(* the INLINE constant action store `m->action = <untainted const>`: the
   ledge-climb leaves write a stationary action constant DIRECTLY (no temp
   staging).  Same protected cell (bm,12) as act_store_chk; the difference
   is only the RHS -- a statically untainted Econst_int rather than a
   censused act temp.  wact_const c witnesses c is not in the tainted set. *)
Definition const_act_store_chk (a1 a2 : expr) : bool :=
  match a1, a2 with
  | Efield (Ederef (Etempvar p pty) sty) fld fty, Econst_int c rty =>
      Pos.eqb p mario_actions_airborne._m
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && Pos.eqb fld mario._action
      && i32_ty fty && i32_ty rty
      && wact_const c
  | _, _ => false
  end.

Lemma const_act_store_chk_shape : forall a1 a2,
    const_act_store_chk a1 a2 = true ->
    exists fty c rty,
      a1 = Efield (Ederef (Etempvar mario_actions_airborne._m (tptr tyMS))
                     tyMS) mario._action fty /\
      a2 = Econst_int c rty /\
      i32_ty fty = true /\ i32_ty rty = true /\ wact_const c = true.
Proof.
  intros a1 a2 H.
  destruct a1 as [ | | | | | | | | | | | ab fld fty | | ];
    try discriminate H.
  destruct ab as [ | | | | | | bb sty | | | | | | | ]; try discriminate H.
  destruct bb as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
  destruct a2 as [ c rty | | | | | | | | | | | | | ]; try discriminate H.
  cbn [const_act_store_chk] in H.
  apply andb_prop in H as [H Hwc].
  apply andb_prop in H as [H Hrty].
  apply andb_prop in H as [H Hfty].
  apply andb_prop in H as [H Hfld].
  apply andb_prop in H as [H Hsty].
  apply andb_prop in H as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  apply Pos.eqb_eq in Hfld. subst fld.
  destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
  destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
  exists fty, c, rty. repeat split; assumption.
Qed.

(* ====================================================================== *)
(* The INDEXED LOCAL store: a write into a stack-allocated array local,    *)
(* `_nextPos[i] = ...` (gen mario_actions_automatic.f_update_hang_moving:  *)
(* Sassign (Ederef (Ebinop Oadd (Evar lid (Tarray ..)) (Econst_int i tint) *)
(* ..) ety2) rhs).  The base is a fn_vars local (an Evar, NOT through _m), *)
(* so it is watched-disjoint (local_blk) and the store leaves every        *)
(* watched cell untouched.  Census `lids` lists the function's local       *)
(* array vars; the engine dispatches this Sassign to local_idx_assign_pres.*)
(* ====================================================================== *)
Definition local_idx_store_chk (lids : list ident) (a1 : expr) : bool :=
  match a1 with
  | Ederef (Ebinop Oadd (Evar lid (Tarray _ _ _)) (Econst_int _ cty) _) ety2 =>
      mem_id lid lids
      && proj_sumbool (type_eq cty tint)
      && match access_mode ety2 with By_value _ => true | _ => false end
  | _ => false
  end.

Lemma local_idx_store_chk_shape : forall lids a1,
    local_idx_store_chk lids a1 = true ->
    exists lid ety sz attr idxN itya ety2 ch,
      a1 = Ederef (Ebinop Oadd (Evar lid (Tarray ety sz attr))
                     (Econst_int idxN tint) itya) ety2
      /\ mem_id lid lids = true
      /\ access_mode ety2 = By_value ch.
Proof.
  intros lids a1 H.
  destruct a1 as [ | | | | | | inner ety2 | | | | | | | ]; try discriminate H.
  destruct inner as [ | | | | | | | | | op e1 e2 bty | | | | ]; try discriminate H.
  destruct op; try discriminate H.
  destruct e1 as [ | | | | lid vty | | | | | | | | | ]; try discriminate H.
  destruct vty as [ | | | | | ety sz attr | | | ]; try discriminate H.
  destruct e2 as [ idxN cty | | | | | | | | | | | | | ]; try discriminate H.
  cbn [local_idx_store_chk] in H.
  apply andb_prop in H as [H Hacc].
  apply andb_prop in H as [Hmem Hcty].
  destruct (type_eq cty tint) as [Hc | Hc]; [ subst cty | discriminate Hcty ].
  destruct (access_mode ety2) as [ch | | | ] eqn:Eam; try discriminate Hacc.
  exists lid, ety, sz, attr, idxN, bty, ety2, ch.
  refine (conj _ (conj _ _)).
  - reflexivity.
  - exact Hmem.
  - exact Eam.
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
               || (Pos.eqb fld mario._statusForCamera
                   || (Pos.eqb fld mario._heldObj
                       || (Pos.eqb fld mario._usedObj
                           || (Pos.eqb fld mario._riddenObj
                               || (Pos.eqb fld mario._animList
                                   || (Pos.eqb fld mario._interactObj
                                       || false))))))))%bool
          = true) in Hmem.
  repeat (apply orb_true_iff in Hmem; destruct Hmem as [Hm | Hmem]);
    try discriminate Hmem; apply Pos.eqb_eq in Hm; subst fld.
  - exists 136. vm_compute. reflexivity.
  - exists 152. vm_compute. reflexivity.
  - exists 148. vm_compute. reflexivity.
  - exists 124. vm_compute. reflexivity.
  - exists 128. vm_compute. reflexivity.
  - exists 132. vm_compute. reflexivity.
  - exists 160. vm_compute. reflexivity.
  - exists 120. vm_compute. reflexivity.
Qed.

(* the root offsets sit past the action cell and inside ptrofs range:
   the root-store brick needs both bounds. *)
Lemma chase_root_offset_bounds : forall fld delta,
    mem_id fld chase_root_fields = true ->
    field_offset (prog_comp_env mario.prog) fld mario_state_members
      = OK (delta, Full) ->
    16 <= delta /\ delta + 4 <= 164.
Proof.
  intros fld delta Hmem Hfo.
  change ((Pos.eqb fld mario._marioObj
           || (Pos.eqb fld mario._marioBodyState
               || (Pos.eqb fld mario._statusForCamera
                   || (Pos.eqb fld mario._heldObj
                       || (Pos.eqb fld mario._usedObj
                           || (Pos.eqb fld mario._riddenObj
                               || (Pos.eqb fld mario._animList
                                   || (Pos.eqb fld mario._interactObj
                                       || false))))))))%bool
          = true) in Hmem.
  repeat (apply orb_true_iff in Hmem; destruct Hmem as [Hm | Hmem]);
    try discriminate Hmem; apply Pos.eqb_eq in Hm; subst fld.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._marioObj
                  mario_state_members = OK (136, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._marioBodyState
                  mario_state_members = OK (152, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._statusForCamera
                  mario_state_members = OK (148, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._heldObj
                  mario_state_members = OK (124, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._usedObj
                  mario_state_members = OK (128, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._riddenObj
                  mario_state_members = OK (132, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._animList
                  mario_state_members = OK (160, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
  - assert (E : field_offset (prog_comp_env mario.prog) mario._interactObj
                  mario_state_members = OK (120, Full))
      by (vm_compute; reflexivity).
    rewrite E in Hfo. inv Hfo. lia.
Qed.

(* the written value must be provably non-Vptr: a non-pointer scalar
   target (I8/I16/IBool/float -- the cast itself launders), or an I32
   target fed by an integer literal or a censused act temp (act temps
   hold untainted scalars -- never pointers) *)
Definition wchase_rhs_ok (wact : list ident) (ty : type) (a2 : expr)
    : bool :=
  nonptr_scalar ty
  || (i32_ty ty && match a2 with
                   | Econst_int _ _ => true
                   | Etempvar q _ => mem_id q wact
                   | Ebinop Oshl _ _ _ => true
                   | _ => false
                   end).

Definition chase_store_chk (wact cact : list ident) (a1 a2 : expr) : bool :=
  match chain_root_l a1 with
  | Some ct => mem_id ct cact && wchase_rhs_ok wact (typeof a1) a2
  | None => false
  end.

(* a store INTO a tabled root cell itself (mario_grab_used_object's
   `m->heldObj = m->usedObj`, the drop/throw helpers' `= NULL`): the
   rhs census keeps the stored value SafeB-if-a-pointer -- a censused
   chase temp (its value is SafeB when a pointer) or a cast integer
   literal (never a pointer). *)
Definition root_rhs_ok (cact : list ident) (a2 : expr) : bool :=
  match a2 with
  | Etempvar q _ => mem_id q cact
  | Ecast (Econst_int _ _) _ => true
  | _ => false
  end.

Definition root_store_chk (cact : list ident) (a1 a2 : expr) : bool :=
  chase_root_chk a1 && root_rhs_ok cact a2.

(* the chase-STEP Sset source: a POINTER field loaded through a censused
   chase temp (`targetAnim = m->animList->bufTarget`).  The loaded value
   is SafeB-if-a-pointer by MWF R7 (SafeB is load-closed). *)
Definition chase_step_chk (cact : list ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar t1 (Tpointer _ _)) (Tstruct _ _)) _
      (Tpointer _ _) => mem_id t1 cact
  | _ => false
  end.

(* a chase store of a CENSUSED POINTER temp (`o->..curAnim = targetAnim`):
   the stored value is SafeB-if-a-pointer by the chase invariant; the MWF
   chase-ptr row absorbs the store. *)
Definition chase_ptr_store_chk (cact : list ident) (a1 a2 : expr) : bool :=
  match chain_root_l a1, typeof a1, a2 with
  | Some ct, Tpointer _ _, Etempvar r (Tpointer _ _) =>
      mem_id ct cact && mem_id r cact
  | _, _, _ => false
  end.

(* the N64 segmented-pointer MASK store: `anim->values = cast-to-void-ptr
   of ((cast-to-u8-ptr of anim + off) & 0x1FFFFFFF)`.  In CompCert's
   semantics the Oand of a POINTER and an integer has NO value
   (sem_binarith refuses Vptr), while the store target forces the SAME
   base temp to BE a pointer -- so the statement can never execute.  The
   walker accepts it as DEAD CODE: the exec-derivation case discharges
   by contradiction. *)
Definition dead_mask_chk (a1 a2 : expr) : bool :=
  match chain_root_l a1, a2 with
  | Some q,
    Ecast
      (Ebinop Oand
         (Ecast
            (Ebinop Oadd
               (Ecast (Etempvar q' (Tpointer _ _)) (Tpointer _ _))
               (Ecast (Etempvar _ _) (Tint I32 Unsigned _))
               (Tpointer _ _))
            (Tint I32 Unsigned _))
         (Econst_int _ (Tint I32 Signed _)) (Tint I32 Unsigned _))
      (Tpointer _ _) => Pos.eqb q q'
  | _, _ => false
  end.

(* the non-pointer SOURCES for the fused pair arm: reading the
   gGlobalTimer global (its cell is non-Vptr by the MWF sglob row), or
   any By_value sub-word load (the decode cannot produce a pointer). *)
Definition npsrc_chk (a : expr) : bool :=
  match a with
  | Evar gid gty =>
      Pos.eqb gid interaction._gGlobalTimer
      && proj_sumbool (type_eq gty tuint)
  | Ederef _ ty => small_int_ty ty
  | _ => false
  end.

(* the fused PAIR `t = SRC; <chase>[...] = t`: the temp's value is
   non-Vptr by provenance, consumed immediately by a chase store.
   Fused so the provenance never needs a fourth census list. *)
Definition npsrc_pair_chk (wact cact : list ident) (s1 s2 : statement)
    : bool :=
  match s1, s2 with
  | Sset t a, Sassign a1 (Etempvar q _) =>
      Pos.eqb q t
      && negb (Pos.eqb t mario_actions_airborne._m)
      && negb (mem_id t wact) && negb (mem_id t cact)
      && npsrc_chk a
      && match chain_root_l a1 with
         | Some ct => mem_id ct cact
         | None => false
         end
  | _, _ => false
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
    destruct (idx_geom_chk_sound _ _ _ _ Hg)
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

  (* the tshort twin (Vec3s elements, stride 2, Mint16signed) *)
  Lemma idx16_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      idx16_mfield_store mario_actions_airborne._m a1 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hix Htat Hexec HM HV HS.
    destruct (idx16_mfield_store_shape _ _ Hix)
      as (fld & idx & pattr & -> & Hg).
    destruct (idx_geom_chk_sound _ _ _ _ Hg)
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
    | Hd : deref_loc (tarray tshort 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Hacc : access_mode (tarray tshort 3) = _ |- _ =>
                 cbn in Hacc; discriminate Hacc
             end);
        try (match goal with
             | Hlb : load_bitfield (tarray tshort 3) _ _ _ _ _ _ _ |- _ =>
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
    (* the pointer add: block bm, offset delta + 2*idx *)
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
             | Hac2 : access_mode tshort = _ |- _ =>
                 cbn in Hac2; discriminate Hac2
             end)
    end.
    match goal with
    | Hac2 : access_mode tshort = By_value ?ch2 |- _ =>
        change (access_mode tshort) with (By_value Mint16signed) in Hac2;
        injection Hac2 as <-
    end.
    match goal with
    | Hstv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hstv; rename Hstv into Hst
    end.
    (* the final offset reduces to delta + 2 * Int.signed idx; every
       unsigned_repr side condition is LINEAR in: 0 <= delta (checker),
       0 <= Int.signed idx (checker), and the window's range booleans. *)
    assert (Hbounds : 0 <= delta + 2 * Int.signed idx /\
                      delta + 2 * Int.signed idx + 2 <= Ptrofs.max_unsigned).
    { unfold store_window_ok in Hwin.
      change (size_chunk Mint16signed) with 2 in Hwin.
      repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
      match goal with
      | Hb1 : (0 <=? delta + 2 * Int.signed idx)%Z = true,
        Hb2 : (delta + 2 * Int.signed idx + _ <=? _)%Z = true |- _ =>
          apply Z.leb_le in Hb1; apply Z.leb_le in Hb2; lia
      end. }
    destruct Hbounds as [Hb0 Hb1].
    assert (Eofs : Ptrofs.unsigned
                     (Ptrofs.add (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta))
                        (Ptrofs.mul (Ptrofs.repr 2) (Ptrofs.of_ints idx)))
                   = delta + 2 * Int.signed idx).
    { rewrite Ptrofs.add_zero_l.
      unfold Ptrofs.of_ints.
      unfold Ptrofs.mul.
      rewrite (Ptrofs.unsigned_repr 2) by lia.
      rewrite (Ptrofs.unsigned_repr (Int.signed idx)) by lia.
      unfold Ptrofs.add.
      rewrite (Ptrofs.unsigned_repr delta) by lia.
      rewrite (Ptrofs.unsigned_repr (2 * Int.signed idx)) by lia.
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

(* what an act temp may be Sset from: an untainted constant, a COPY
   of another act temp (set_mario_action's `_action := _t'1` pattern;
   Sset has no cast, so the value transfers verbatim), or an I32 cast
   of an untainted constant (airborne's `_t'4 := (int)0/1`). *)
Definition wsrc_chk (wact : list ident) (a : expr) : bool :=
  match a with
  | Econst_int c _ => wact_const c
  | Etempvar q _ => mem_id q wact
  | Ecast (Econst_int c ity) cty => i32_ty ity && i32_ty cty && wact_const c
  | _ => false
  end.

(* the act-writer call with a CONSTANT action argument: the leaf pattern
   `set_mario_action(m, ACT_X, _)` -- the untainted-scalar premise of the
   call_pres_act row is met by the vm-checked constant itself. *)
Definition smact_call_chk (wact sids : list ident) (fid : ident)
    (tys : list type) (args : list expr) : bool :=
  mem_id fid sids
  && match tys, args with
     | ty2 :: _, Econst_int c ity :: _ =>
         wact_const c && i32_ty ty2 && i32_ty ity
     | ty2 :: _, Etempvar q qty :: _ =>
         mem_id q wact && i32_ty ty2 && i32_ty qty
     | _, _ => false
     end.

(* the THIRD-position act-writer call (the asgs class): BOTH value args
   are vm-checked constants -- the animation (any I32 const) and the
   UNTAINTED action third. *)
Definition act3_call_chk (tids : list ident) (fid : ident)
    (tys : list type) (args : list expr) : bool :=
  mem_id fid tids
  && match tys, args with
     | ty2 :: ty3 :: _, Econst_int _ i2 :: Econst_int c ity :: _ =>
         i32_ty ty2 && i32_ty i2 && wact_const c && i32_ty ty3
         && i32_ty ity
     | _, _ => false
     end.

(* xids = external (or otherwise marg-free) censused callees: the
   call_pres_ext row has NO marg premise, so ANY argument list fits. *)
(* The walker check is now indexed by an extra `lids` census (the
   function's stack-allocated local ARRAY ids).  The primed Fixpoint
   carries it and accepts an indexed-local store into any lid in lids
   (local_idx_store_chk).  The unprimed wrapper instantiates lids := nil,
   so every existing producer/walk (which writes `wwalk_chk ...`) is
   UNCHANGED: with lids=nil the new disjunct is identically false. *)
Fixpoint wwalk_chk' (lids : list ident) (rt : bool)
    (wact ids wids cact xids sids tids : list ident)
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
      && (negb (mem_id id cact)
          || chase_root_chk a || chase_step_chk cact a)
  | Sassign a1 a2 =>
      safe_mfield_store mario_actions_airborne._m a1
      || glob_store_chk a1
      || idx_mfield_store mario_actions_airborne._m a1
      || idx16_mfield_store mario_actions_airborne._m a1
      || act_store_chk wact a1 a2
      || const_act_store_chk a1 a2
      || chase_store_chk wact cact a1 a2
      || root_store_chk cact a1 a2
      || chase_ptr_store_chk cact a1 a2
      || dead_mask_chk a1 a2
      || local_idx_store_chk lids a1
  | Scall optid a al =>
      match a with
      | Evar fid fty =>
          opt_ne_m optid
          && match optid with
             | Some t => negb (mem_id t cact)
             | None => true
             end
          && ((mem_id fid xids
               && match optid with
                  | Some t => negb (mem_id t wact)
                  | None => true
                  end
               && is_tfun fty)
              || match fty, al with
                 | Tfunction nil rty cc, nil =>
                     (* a censused NULLARY call: marg_ok nil is trivial,
                        and the (uncensused) result may not land in an
                        act temp *)
                     match optid with
                     | Some t => negb (mem_id t wact)
                     | None => true
                     end && mem_id fid ids
                 | Tfunction (ty1 :: tys) rty cc, Etempvar p pty :: args =>
                     Pos.eqb p mario_actions_airborne._m
                     && proj_sumbool (type_eq ty1 tyMSp)
                     && proj_sumbool (type_eq pty tyMSp)
                     && match optid with
                        | Some t =>
                            if mem_id t wact
                            then (* an act-writer call: result feeds wact,
                                    so the second arg must itself be a
                                    censused act temp at an I32 type *)
                              mem_id fid wids
                              && match tys, args with
                                 | ty2 :: _, Etempvar q qty :: _ =>
                                     mem_id q wact && i32_ty ty2
                                     && i32_ty qty
                                 | _, _ => false
                                 end
                            else mem_id fid ids
                                 || smact_call_chk wact sids fid tys args
                                 || act3_call_chk tids fid tys args
                        | None => mem_id fid ids
                                  || smact_call_chk wact sids fid tys args
                                  || act3_call_chk tids fid tys args
                        end
                 | _, _ => false
                 end)
      | _ => false
      end
  | Ssequence s1 s2 =>
      npsrc_pair_chk wact cact s1 s2
      || (wwalk_chk' lids rt wact ids wids cact xids sids tids s1
          && wwalk_chk' lids rt wact ids wids cact xids sids tids s2)
  | Sifthenelse _ s1 s2 =>
      wwalk_chk' lids rt wact ids wids cact xids sids tids s1
      && wwalk_chk' lids rt wact ids wids cact xids sids tids s2
  | Sloop s1 s2 =>
      wwalk_chk' lids rt wact ids wids cact xids sids tids s1
      && wwalk_chk' lids rt wact ids wids cact xids sids tids s2
  | Sswitch _ sl => wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl
  | _ => false
  end
with wwalk_chk_ls' (lids : list ident) (rt : bool)
    (wact ids wids cact xids sids tids : list ident)
    (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' =>
      wwalk_chk' lids rt wact ids wids cact xids sids tids s
      && wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl'
  end.

(* the lids = nil WRAPPERS -- the producer-facing names.  Keeping these
   the same arity as before means the ~120 existing walk/producer sites are
   untouched: they compute through `wwalk_chk' nil` and the local-store
   disjunct vanishes. *)
Definition wwalk_chk (rt : bool) (wact ids wids cact xids sids tids : list ident)
    (s : statement) : bool :=
  wwalk_chk' nil rt wact ids wids cact xids sids tids s.
Definition wwalk_chk_ls (rt : bool) (wact ids wids cact xids sids tids : list ident)
    (sl : labeled_statements) : bool :=
  wwalk_chk_ls' nil rt wact ids wids cact xids sids tids sl.

(* ---- the switch-selection transfer (mirror of walk_chk's) ---- *)

Lemma wwalk_chk_ls_seq' : forall lids rt wact ids wids cact xids sids tids sl,
    wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl = true ->
    wwalk_chk' lids rt wact ids wids cact xids sids tids (seq_of_labeled_statement sl) = true.
Proof.
  intros lids rt wact ids wids cact xids sids tids sl;
    induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn in H. apply andb_prop in H as [H1 H2].
    cbn. apply orb_true_iff. right.
    rewrite H1, (IH H2). reflexivity.
Qed.

Lemma wwalk_chk_ls_case' : forall lids rt wact ids wids cact xids sids tids n sl sl',
    wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl = true ->
    select_switch_case n sl = Some sl' ->
    wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl' = true.
Proof.
  intros lids rt wact ids wids cact xids sids tids n sl;
    induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma wwalk_chk_ls_default' : forall lids rt wact ids wids cact xids sids tids sl,
    wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl = true ->
    wwalk_chk_ls' lids rt wact ids wids cact xids sids tids (select_switch_default sl)
    = true.
Proof.
  intros lids rt wact ids wids cact xids sids tids sl;
    induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn.
    + exact (IH H2).
    + rewrite H1, H2. reflexivity.
Qed.

Lemma wwalk_chk_select' : forall lids rt wact ids wids cact xids sids tids n sl,
    wwalk_chk_ls' lids rt wact ids wids cact xids sids tids sl = true ->
    wwalk_chk' lids rt wact ids wids cact xids sids tids
      (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros lids rt wact ids wids cact xids sids tids n sl H. apply wwalk_chk_ls_seq'.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (wwalk_chk_ls_case' _ _ _ _ _ _ _ _ _ _ _ _ H E).
  - exact (wwalk_chk_ls_default' _ _ _ _ _ _ _ _ _ _ H).
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
  (* the chase-ROOT-cell store row: instantiated by mwf_real_root_store *)
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  (* the scalar-global row: instantiated by mwf_real_sglob *)
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  (* SafeB is load-closed (MWF R7): instantiated by mwf_real_chase_step *)
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  (* a SafeB-IF-POINTER store into a SafeB block: mwf_real_chase_ptr *)
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
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
  (* The chase-STEP Sset brick: evaluating `t1->fld` (a POINTER field    *)
  (* through a censused chase temp) forces a Mptr load from t1's SafeB  *)
  (* block; R7 (HchaseStep) pins any pointer it yields into SafeB.      *)
  (* ================================================================== *)
  Lemma chase_step_set_sound :
    forall cact a e le m v,
      chase_step_chk cact a = true ->
      chase_inv cact le ->
      MWF m ->
      eval_expr (lp_ge lp) e le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros cact a e le m v Hck Hch HM Hev b o ->.
    unfold chase_step_chk in Hck.
    destruct a as [ | | | | | | | | | | | af fld fty | | ];
      try discriminate Hck.
    destruct af as [ | | | | | | ad ady | | | | | | | ];
      try discriminate Hck.
    destruct ad as [ | | | | | t1 t1ty | | | | | | | | ];
      try discriminate Hck.
    destruct t1ty; try discriminate Hck.
    destruct ady; try discriminate Hck.
    destruct fty; try discriminate Hck.
    (* split the Efield rvalue into lvalue + load *)
    destruct (eval_expr_Efield_load _ _ _ _ _ _ _ _ Hev)
      as (loc & ofs & bf & Hlv & Hd).
    (* the lvalue's block is the BASE pointer's block *)
    destruct (eval_lvalue_Efield_inv _ _ _ _ _ _ _ _ _ _ Hlv)
      as (o0 & sid2 & att2 & co & delta & Hbase & _ & _ & _).
    (* the base Ederef: a struct-typed deref passes the pointer through *)
    destruct (eval_expr_Ederef_load _ _ _ _ _ _ _ Hbase)
      as (l2 & o2 & bf2 & Hlv2 & Hd2).
    apply eval_lvalue_Ederef_base in Hlv2.
    apply eval_expr_Etempvar_val in Hlv2.
    pose proof (Hch _ Hck _ _ Hlv2) as Hsafe.
    assert (Eloc : loc = l2).
    { cbn [typeof] in Hd2.
      refine (proj1 (deref_loc_aggregate_eq _ _ _ _ _ _ _ _ Hd2)).
      right; reflexivity. }
    subst loc.
    (* the field load: By_value Mptr from the SafeB block *)
    cbn [typeof] in Hd. inv Hd.
    - match goal with
      | Hac : access_mode _ = By_value _ |- _ =>
          cbn [access_mode] in Hac; injection Hac as <-
      end.
      match goal with
      | Hld : Mem.loadv Mptr _ _ = Some (Vptr _ _) |- _ =>
          exact (HchaseStep _ _ _ _ _ HM Hsafe Hld)
      end.
    - match goal with
      | Hac : access_mode _ = By_reference |- _ =>
          cbn [access_mode] in Hac; discriminate Hac
      end.
    - match goal with
      | Hac : access_mode _ = By_copy |- _ =>
          cbn [access_mode] in Hac; discriminate Hac
      end.
    - match goal with
      | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
      end.
  Qed.

  (* ================================================================== *)
  (* The chase-store brick (the v2 engine's class C, restated against   *)
  (* the walk's chase invariant): the chain brick pins the written      *)
  (* block to the temp's SafeB block; the rhs census makes the written  *)
  (* value non-Vptr; SafeB is bm-disjoint so valid/action_sat carry.    *)
  (* ================================================================== *)
  Lemma chase_assign_pres :
    forall wact cact a1 a2 e le m0 tr le' m' out,
      chase_store_chk wact cact a1 a2 = true ->
      act_inv wact le ->
      chase_inv cact le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros wact0 cact a1 a2 e le m0 tr le' m' out Hck Hact Hch Hexec
           HM HV HS.
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
        destruct a2 as [ c2 ity | | | | | q qty | | | |
                         op2 aa2 ab2 bty2 | | | | ];
          try discriminate Ha2.
        + (* integer literal *)
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
          end.
        + (* censused act temp: untainted scalar, never a pointer *)
          match goal with
          | Hev2 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
              apply eval_expr_Etempvar_val in Hev2;
              destruct (Hact _ Ha2 _ Hev2) as [Ev | (w & Ev & _)];
              subst
          end.
          * match goal with
            | Hcast0 : sem_cast Vundef _ _ _ = Some _ |- _ =>
                rewrite (sem_cast_vundef_inv _ _ _ _ Hcast0);
                intros bb oo EE; discriminate EE
            end.
          * match goal with
            | Hcast0 : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
                exact (sem_cast_vint_nonptr _ _ _ _ _ Hcast0)
            end.
        + (* an Oshl rhs: shifts only produce Vint/Vlong, and the cast
             cannot mint a pointer from a non-pointer *)
          destruct op2; try discriminate Ha2.
          match goal with
          | Hev2 : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
              inv Hev2;
              try (match goal with
                   | Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _
                     |- _ => inv Hlv
                   end)
          end.
          match goal with
          | Hsem : sem_binary_operation _ Oshl _ _ _ _ _ = Some _ |- _ =>
              cbn [sem_binary_operation] in Hsem
          end.
          match goal with
          | Hcast0 : sem_cast ?vv _ _ _ = Some _,
            Hshl : sem_shl _ _ _ _ = Some ?vv |- _ =>
              exact (sem_cast_nonptr_pres _ _ _ _ _ Hcast0
                       (sem_shl_nonptr _ _ _ _ _ Hshl))
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
  (* The chase POINTER-store brick: the rhs is a CENSUSED chase temp    *)
  (* (SafeB-if-a-pointer by the chase invariant), stored through a      *)
  (* chased lvalue (SafeB block).  The MWF chase-ptr row absorbs it.    *)
  (* ================================================================== *)
  Lemma chase_ptr_assign_pres :
    forall cact a1 a2 e le m0 tr le' m' out,
      chase_ptr_store_chk cact a1 a2 = true ->
      chase_inv cact le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros cact a1 a2 e le m0 tr le' m' out Hck Hch Hexec HM HV HS.
    unfold chase_ptr_store_chk in Hck.
    destruct (chain_root_l a1) as [ct|] eqn:Hcr; [ | discriminate Hck ].
    destruct (typeof a1) eqn:Hty1; try discriminate Hck.
    destruct a2 as [ | | | | | r rty | | | | | | | | ];
      try discriminate Hck.
    destruct rty; try discriminate Hck.
    apply andb_prop in Hck as [Hctm Hrm].
    inv Hexec.
    (* the store target's block is the chase temp's SafeB block *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv)
          as (o0 & Hlet)
    end.
    pose proof (Hch _ Hctm _ _ Hlet) as Hsafe.
    pose proof (HSafeNotBm _ Hsafe) as Hneq.
    (* the rhs temp's value -- hence the stored value -- is SafeB when
       it is a pointer (sem_cast never CONSTRUCTS a pointer) *)
    match goal with
    | Hev2 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hev2
    end.
    match goal with
    | Hcast0 : sem_cast ?v2 _ _ _ = Some ?vw,
      Hler : _ ! _ = Some ?v2 |- _ =>
        assert (Hsp : forall bb oo, vw = Vptr bb oo -> SafeB bb)
          by (intros bb oo Evw; rewrite Evw in Hcast0;
              apply sem_cast_vptr_inv in Hcast0;
              rewrite Hcast0 in Hler;
              exact (Hch _ Hrm _ _ Hler))
    end.
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
            [ exact (HMWF_chase_safe _ _ _ _ _ _ HM Hsafe Hsp Hsv)
            | split; reflexivity ] ]
      end.
    - (* By_copy: refuted -- the target's type is a POINTER (By_value) *)
      match goal with
      | Hac : access_mode (typeof a1) = By_copy |- _ =>
          rewrite Hty1 in Hac; cbn [access_mode] in Hac;
          discriminate Hac
      end.
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
  (* The dead-mask brick: the N64 segmented-pointer mask store cannot   *)
  (* EXECUTE -- the lvalue forces the base temp to hold a Vptr, and     *)
  (* sem_binarith refuses Oand on a Vptr.  Pure contradiction.          *)
  (* ================================================================== *)
  Lemma dead_mask_dead :
    forall a1 a2 e le m0 tr le' m' out,
      dead_mask_chk a1 a2 = true ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      False.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hck Hexec.
    unfold dead_mask_chk in Hck.
    destruct (chain_root_l a1) as [q|] eqn:Hcr; [ | discriminate Hck ].
    (* peel the rhs shape in the chk's examination order *)
    destruct a2 as [ | | | | | | | | | | c cty | | | ];
      try discriminate Hck.
    destruct c as [ | | | | | | | | | ob cL cR oty | | | | ];
      try discriminate Hck.
    destruct ob; try discriminate Hck.
    destruct cL as [ | | | | | | | | | | d dty | | | ];
      try discriminate Hck.
    destruct d as [ | | | | | | | | | db dL dR aty | | | | ];
      try discriminate Hck.
    destruct db; try discriminate Hck.
    destruct dL as [ | | | | | | | | | | tq pty | | | ];
      try discriminate Hck.
    destruct tq as [ | | | | | q' qty | | | | | | | | ];
      try discriminate Hck.
    destruct qty; try discriminate Hck.
    destruct pty; try discriminate Hck.
    destruct dR as [ | | | | | | | | | | tr2 ity | | | ];
      try discriminate Hck.
    destruct tr2 as [ | | | | | r' rty' | | | | | | | | ];
      try discriminate Hck.
    destruct ity as [ | szi sgi atti | | | | | | | ];
      try discriminate Hck.
    destruct szi; try discriminate Hck.
    destruct sgi; try discriminate Hck.
    destruct aty; try discriminate Hck.
    destruct dty as [ | szd sgd attd | | | | | | | ];
      try discriminate Hck.
    destruct szd; try discriminate Hck.
    destruct sgd; try discriminate Hck.
    destruct cR as [ c2 sty | | | | | | | | | | | | | ];
      try discriminate Hck.
    destruct sty as [ | szs sgs2 atts | | | | | | | ];
      try discriminate Hck.
    destruct szs; try discriminate Hck.
    destruct sgs2; try discriminate Hck.
    destruct oty as [ | szo sgo atto | | | | | | | ];
      try discriminate Hck.
    destruct szo; try discriminate Hck.
    destruct sgo; try discriminate Hck.
    destruct cty; try discriminate Hck.
    pose proof (proj1 (Pos.eqb_eq _ _) Hck) as Eqq; subst q'.
    inv Hexec.
    (* the lvalue pins le!q to a Vptr *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv)
          as (o0 & Hlet)
    end.
    (* unwind the rhs evaluation down to the Oand *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Ecast (Ebinop Oand _ _ _) _) _ |- _ =>
        inv Hev;
        try match goal with
            | Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl
            end
    end.
    match goal with
    | Hev : eval_expr _ _ _ _ (Ebinop Oand _ _ _) _ |- _ =>
        inv Hev;
        try match goal with
            | Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
                inv Hl
            end
    end.
    (* the right operand: an integer literal *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hev;
        try match goal with
            | Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                inv Hl
            end
    end.
    (* the left operand: cast of the Oadd *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Ecast (Ebinop Oadd _ _ _) _) _ |- _ =>
        inv Hev;
        try match goal with
            | Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl
            end
    end.
    match goal with
    | Hev : eval_expr _ _ _ _ (Ebinop Oadd _ _ _) _ |- _ =>
        inv Hev;
        try match goal with
            | Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
                inv Hl
            end
    end.
    (* the base: the SAME temp q, cast ptr->ptr keeps the Vptr *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Ecast (Etempvar _ _) (Tpointer _ _)) _
      |- _ =>
        inv Hev;
        try match goal with
            | Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl
            end
    end.
    match goal with
    | Hev : eval_expr _ _ _ _ (Etempvar q _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hev;
        rewrite Hlet in Hev; injection Hev as <-
    end.
    match goal with
    | Hc : sem_cast (Vptr _ _) (typeof (Etempvar _ _)) _ _ = Some _
      |- _ => cbn in Hc; injection Hc as <-
    end.
    (* the Oadd: pointer + int is a Vptr (or no value at all) *)
    match goal with
    | Hadd : sem_binary_operation _ Oadd (Vptr _ _) _ ?vr _ _ = Some _
      |- _ =>
        cbn [sem_binary_operation typeof classify_add sem_add] in Hadd;
        destruct vr; cbn [sem_add_ptr_int] in Hadd;
        try discriminate Hadd;
        injection Hadd as <-
    end.
    (* Archi.ptr64 is Global Opaque: case-split it (the repo idiom).
       ptr64 = true: the ptr->uint cast itself refuses the Vptr.
       ptr64 = false: the cast is cast_case_pointer (keeps the Vptr)
       and then the Oand's sem_binarith refuses it. *)
    destruct Archi.ptr64 eqn:Hp64.
    { match goal with
      | Hc : sem_cast (Vptr _ _) (typeof (Ebinop Oadd _ _ _)) _ _
             = Some _ |- _ =>
          unfold sem_cast in Hc; cbn [typeof classify_cast] in Hc;
          rewrite Hp64 in Hc; cbn in Hc; discriminate Hc
      end. }
    match goal with
    | Hc : sem_cast (Vptr _ _) (typeof (Ebinop Oadd _ _ _)) _ _ = Some _
      |- _ =>
        unfold sem_cast in Hc; cbn [typeof classify_cast] in Hc;
        rewrite Hp64 in Hc; cbn in Hc; injection Hc as <-
    end.
    (* the Oand on a Vptr: sem_binarith refuses -- contradiction *)
    match goal with
    | Hand : sem_binary_operation _ Oand (Vptr _ _) _ (Vint _) _ _
             = Some _ |- _ =>
        unfold sem_binary_operation, sem_and, sem_binarith in Hand;
        cbn [typeof classify_binarith binarith_type] in Hand;
        unfold sem_cast in Hand; cbn [classify_cast] in Hand;
        repeat (rewrite Hp64 in Hand; cbn in Hand);
        discriminate Hand
    end.
  Qed.

  (* ================================================================== *)
  (* The chase-store brick, VALUE form: the rhs is a temp whose value   *)
  (* is known non-Vptr by provenance (the fused pair arm), not by the   *)
  (* rhs census.  Same tail as chase_assign_pres.                       *)
  (* ================================================================== *)
  Lemma chase_assign_value_pres :
    forall cact a1 q qty e le m0 tr le' m' out v,
      (match chain_root_l a1 with
       | Some ct => mem_id ct cact
       | None => false
       end) = true ->
      chase_inv cact le ->
      le ! q = Some v ->
      (forall bb oo, v <> Vptr bb oo) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign a1 (Etempvar q qty)) tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros cact a1 q qty e le m0 tr le' m' out v Hck Hch Hleq Hnpv Hexec
           HM HV HS.
    destruct (chain_root_l a1) as [ct|] eqn:Hcr; [ | discriminate Hck ].
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv)
          as (o0 & Hlet)
    end.
    pose proof (Hch _ Hck _ _ Hlet) as Hsafe.
    pose proof (HSafeNotBm _ Hsafe) as Hneq.
    (* the rhs value is the temp's, non-Vptr through the cast *)
    match goal with
    | Hev2 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hev2;
        rewrite Hleq in Hev2; injection Hev2 as ->
    end.
    match goal with
    | Hcast0 : sem_cast _ _ _ _ = Some ?vw |- _ =>
        assert (Hnp : forall bb oo, vw <> Vptr bb oo)
          by (exact (sem_cast_nonptr_pres _ _ _ _ _ Hcast0 Hnpv))
    end.
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
    - (* By_copy: the copied value is a Vptr -- refuted *)
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
  (* The chase-ROOT-cell store brick: `m->heldObj = ...` writes the      *)
  (* tabled root cell itself; HMWF_root re-establishes MWF from the      *)
  (* SafeB-if-a-pointer rhs census.                                      *)
  (* ================================================================== *)
  Lemma root_assign_pres :
    forall cact a1 a2 e le m0 tr le' m' out,
      root_store_chk cact a1 a2 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv cact le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros cact a1 a2 e le m0 tr le' m' out Hck Htat Hch Hexec HM HV HS.
    apply andb_prop in Hck as [Hcr Hrhs].
    destruct (chase_root_chk_shape _ Hcr) as (fld & pt & pa & -> & Hfld).
    destruct (chase_root_field_offset _ Hfld) as (delta & Hfo).
    destruct (chase_root_offset_bounds _ _ Hfld Hfo) as [Hlo Hhi].
    inv Hexec.
    (* the lvalue: (bm, delta) via the Mario param pin + the geometry *)
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
    (* the stored value is SafeB-if-a-pointer *)
    match goal with
    | Hcast0 : sem_cast _ _ _ _ = Some ?vw |- _ =>
        assert (Hsv2 : forall bb oo, vw = Vptr bb oo -> SafeB bb)
    end.
    { unfold root_rhs_ok in Hrhs.
      destruct a2 as [ c2 ity | | | | | q qty | | | | |
                       ca cty | | | ];
        try discriminate Hrhs.
      - (* a censused chase temp: SafeB when a pointer *)
        match goal with
        | Hev2 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hev2
        end.
        intros bb oo Evw.
        match goal with
        | Hcast0 : sem_cast ?v2 _ _ _ = Some _ |- _ =>
            subst; apply sem_cast_vptr_inv in Hcast0; subst v2
        end.
        match goal with
        | Hev2 : _ ! _ = Some (Vptr _ _) |- _ =>
            exact (Hch _ Hrhs _ _ Hev2)
        end.
      - (* a cast integer literal: never a pointer *)
        destruct ca as [ c3 ity3 | | | | | | | | | | | | | ];
          try discriminate Hrhs.
        match goal with
        | Hev2 : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
            inv Hev2;
            try (match goal with
                 | Hlv : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ =>
                     inv Hlv
                 end)
        end.
        match goal with
        | Hev1 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
            inv Hev1;
            try (match goal with
                 | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _
                   |- _ => inv Hlv
                 end)
        end.
        intros bb oo Evw.
        match goal with
        | Hcast0 : sem_cast ?v2 _ _ _ = Some _ |- _ =>
            subst; apply sem_cast_vptr_inv in Hcast0; subst v2
        end.
        match goal with
        | Hc1 : sem_cast (Vint _) _ _ _ = Some (Vptr _ _) |- _ =>
            apply sem_cast_vptr_inv in Hc1; discriminate Hc1
        end. }
    (* the store: a By_value Mptr write of the root cell *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has
    end.
    - (* By_value *)
      match goal with
      | Hac : access_mode _ = By_value _ |- _ =>
          change (access_mode (Tpointer pt pa)) with (By_value Mptr)
            in Hac;
          injection Hac as <-
      end.
      match goal with
      | Hsv0 : Mem.storev _ _ _ _ = Some m' |- _ =>
          unfold Mem.storev in Hsv0;
          rewrite Ptrofs.add_zero_l in Hsv0;
          rewrite Ptrofs.unsigned_repr in Hsv0
            by (change Ptrofs.max_unsigned with 4294967295; lia)
      end.
      match goal with
      | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
          split; [ eauto using Mem.store_valid_block_1 | split ];
          [ intros av Hload;
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
            [ exact (HS av Hload)
            | right; left; change (size_chunk Mint32) with 4; lia ]
          | split;
            [ exact (HMWF_root _ _ _ _ _ Hfld Hfo Hsv2 HM Hsv)
            | split; reflexivity ] ]
      end.
    - (* By_copy: a pointer type is By_value *)
      match goal with
      | Hac : access_mode _ = By_copy |- _ =>
          cbn in Hac; discriminate Hac
      end.
  Qed.

  (* ================================================================== *)
  (* The fused non-pointer-source PAIR brick: `t = SRC; <chase>[i] = t`. *)
  (* SRC's value is non-Vptr by the sglob row (gGlobalTimer) or by the   *)
  (* sub-word decode; the store consumes it via the value-form chase     *)
  (* brick.                                                              *)
  (* ================================================================== *)
  Lemma npsrc_pair_pres :
    forall wact cact s1 s2 e le m0 tr1 le1 m1 tr2 le' m' out,
      npsrc_pair_chk wact cact s1 s2 = true ->
      e ! interaction._gGlobalTimer = None ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv wact le -> chase_inv cact le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s1
        tr1 le1 m1 Out_normal ->
      exec_stmt function_entry2 (lp_ge lp) e le1 m1 s2
        tr2 le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv wact le' /\ chase_inv cact le' /\ out = Out_normal.
  Proof.
    intros wact0 cact s1 s2 e le m0 tr1 le1 m1 tr2 le' m' out
           Hck He_gt Htat Hact Hch Hx1 Hx2 HM HV HS.
    unfold npsrc_pair_chk in Hck.
    destruct s1 as [ | a1x a2x | t a | | | | | | | | | | | ];
      try discriminate Hck.
    destruct s2 as [ | a1 a2r | | | | | | | | | | | | ];
      try discriminate Hck.
    destruct a2r as [ | | | | | q qty | | | | | | | | ];
      try discriminate Hck.
    apply andb_prop in Hck as [Hck Hroot].
    apply andb_prop in Hck as [Hck Hsrc].
    apply andb_prop in Hck as [Hck Htnc].
    apply andb_prop in Hck as [Hck Htnw].
    apply andb_prop in Hck as [Hqt Htnm].
    apply Pos.eqb_eq in Hqt. subst q.
    inv Hx1.
    (* the temp's value is non-Vptr by provenance *)
    match goal with
    | Hev : eval_expr _ _ _ _ a ?vv |- _ =>
        assert (Hnpv : forall bb oo, vv <> Vptr bb oo)
    end.
    { unfold npsrc_chk in Hsrc.
      destruct a as [ | | | | gid gty | | ad ady | | | | | | | ];
        try discriminate Hsrc.
      - (* the gGlobalTimer read *)
        apply andb_prop in Hsrc as [Hgid Hgty].
        apply Pos.eqb_eq in Hgid. subst gid.
        destruct (type_eq gty tuint); [ subst gty | discriminate Hgty ].
        match goal with
        | Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hev
        end.
        match goal with
        | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
        end.
        + (* local: e does not bind the gGlobalTimer ident *)
          match goal with
          | Hl : e ! _ = Some _ |- _ =>
              rewrite He_gt in Hl; discriminate Hl
          end.
        + (* global: a Mint32 load of the gGlobalTimer cell *)
          match goal with
          | Hdl : deref_loc _ _ _ _ _ _ |- _ =>
              cbn [typeof] in Hdl; inv Hdl
          end.
          * match goal with
            | Hac : access_mode _ = By_value _ |- _ =>
                change (access_mode tuint) with (By_value Mint32) in Hac;
                injection Hac as <-
            end.
            match goal with
            | Hldv : Mem.loadv Mint32 ?mm (Vptr ?gb Ptrofs.zero)
                       = Some _,
              Hfs : Genv.find_symbol _ _ = Some _ |- _ =>
                change (Mem.loadv Mint32 mm (Vptr gb Ptrofs.zero))
                  with (Mem.load Mint32 mm gb 0) in Hldv;
                exact (HMWF_sglob _ _ _ HM Hfs Hldv)
            end.
          * match goal with
            | Hac : access_mode _ = By_reference |- _ =>
                cbn in Hac; discriminate Hac
            end.
          * match goal with
            | Hac : access_mode _ = By_copy |- _ =>
                cbn in Hac; discriminate Hac
            end.
      - (* a sub-word Ederef load: the decode is non-Vptr *)
        destruct (small_int_access _ Hsrc) as (ch & Hacc & Hsub).
        match goal with
        | Hev : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hev
        end.
        match goal with
        | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
        end.
        match goal with
        | Hdl : deref_loc _ _ _ _ _ _ |- _ =>
            cbn [typeof] in Hdl; inv Hdl
        end.
        + match goal with
          | Hac : access_mode _ = By_value _ |- _ =>
              rewrite Hacc in Hac; injection Hac as <-
          end.
          match goal with
          | Hldv : Mem.loadv _ _ (Vptr _ _) = Some _ |- _ =>
              cbn [Mem.loadv] in Hldv;
              exact (load_subword_nonptr _ _ _ _ _ Hsub Hldv)
          end.
        + match goal with
          | Hac : access_mode _ = By_reference |- _ =>
              rewrite Hacc in Hac; discriminate Hac
          end.
        + match goal with
          | Hac : access_mode _ = By_copy |- _ =>
              rewrite Hacc in Hac; discriminate Hac
          end. }
    (* the chase invariants carry over the set (t is uncensused) *)
    assert (Hne_m : t <> mario_actions_airborne._m).
    { intro EE. rewrite EE in Htnm. cbn in Htnm. discriminate Htnm. }
    match goal with
    | Hev : eval_expr _ _ _ _ a ?vv |- _ =>
        assert (Hch1 : chase_inv cact (PTree.set t vv le))
    end.
    { intros t0 Hmem b o Hg.
      destruct (Pos.eq_dec t0 t) as [-> | Hne].
      - rewrite Hmem in Htnc. discriminate Htnc.
      - rewrite PTree.gso in Hg by exact Hne. exact (Hch _ Hmem _ _ Hg). }
    match goal with
    | Hx : exec_stmt _ _ _ _ _ (Sassign _ (Etempvar _ _)) _ _ _ _ |- _ =>
        destruct (chase_assign_value_pres _ _ _ _ _ _ _ _ _ _ _ _
                    Hroot Hch1 (PTree.gss _ _ _) Hnpv Hx HM HV HS)
          as (HV' & HS' & HM' & Hle2 & Hout2)
    end.
    subst.
    refine (conj HV' (conj HS' (conj HM' (conj _ (conj _ (conj Hch1
             eq_refl)))))).
    - intros b o Hg.
      rewrite PTree.gso in Hg by (exact (not_eq_sym Hne_m)).
      exact (Htat _ _ Hg).
    - intros t0 Hmem x Hg.
      destruct (Pos.eq_dec t0 t) as [-> | Hne].
      + rewrite Hmem in Htnw. discriminate Htnw.
      + rewrite PTree.gso in Hg by exact Hne. exact (Hact _ Hmem _ Hg).
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

  (* ================================================================== *)
  (* The CONSTANT action-store brick: m->action := <untainted const>.   *)
  (* The inline twin of act_assign_pres -- the RHS is a statically       *)
  (* untainted Econst_int (the ledge-climb-slow stationary action 1357)  *)
  (* rather than a censused act temp.  Same protected cell (bm,12); MWF  *)
  (* survives (the value is Vint, never a pointer) and action_sat is     *)
  (* re-established by the constant's wact_const witness.                *)
  (* ================================================================== *)
  Lemma const_act_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      const_act_store_chk a1 a2 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hck Htat Hexec HM HV.
    destruct (const_act_store_chk_shape _ _ Hck)
      as (fty & c & rty & -> & -> & Hfty & Hrty & Hwc).
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
    (* the RHS: a statically untainted constant *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hev;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv
             end)
    end.
    assert (Hnt : not_tainted c).
    { unfold wact_const in Hwc. unfold not_tainted.
      destruct (is_tainted c); [ discriminate Hwc | reflexivity ]. }
    (* the cast: I32-to-I32, a Vint survives verbatim *)
    match goal with
    | Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hc; rename Hc into Hcast
    end.
    pose proof (sem_cast_i32_neutral _ _ _ _ _ Hrty Hfty Hcast) as ->.
    (* the assign: a By_value Mint32 store at (bm,12) *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        rewrite Ptrofs.add_zero_l in Has;
        cbn [typeof] in Has;
        inv Has
    end.
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
        [ intros av Hload;
          rewrite (Mem.load_store_same _ _ _ _ _ _ Hsv) in Hload;
          cbn in Hload; injection Hload as <-; exact Hnt
        | split;
          [ refine (HMWF_act _ _ _ HM _ Hsv);
            intros bb oo EE; discriminate EE
          | split; reflexivity ] ]
    end.
  Qed.

  (* the function-name resolution, generalized from the empty env to any e
     in which the callee fid is NOT a local (He_fid).  empty_env satisfies
     that via PTree.gempty; a real local env satisfies it because no callee
     ident is a stack-allocated local.  Refutes eval_Evar_local via He_fid;
     the global case is unchanged from eval_Evar_funct_empty. *)
  Lemma eval_Evar_funct :
    forall e le m fid tyl rty cc vf,
      e ! fid = None ->
      eval_expr (lp_ge lp) e le m (Evar fid (Tfunction tyl rty cc)) vf ->
      exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
                vf = Vptr b Ptrofs.zero.
  Proof.
    intros e le m fid tyl rty cc vf He Hev.
    inv Hev.
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl
    end.
    - (* local: refuted -- the callee is not a local in e *)
      match goal with
      | Hb : e ! _ = Some _ |- _ => rewrite He in Hb; discriminate Hb
      end.
    - (* global: deref at By_reference hands back the pointer *)
      match goal with
      | Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd
      end;
        try (match goal with
             | Hac : access_mode _ = _ |- _ => cbn in Hac; discriminate Hac
             end).
      eexists. split; [ eassumption | reflexivity ].
  Qed.

  (* n-ary Mario-head call at the empty env: the TAIL is arbitrary
     (marg_ok constrains only the head; eval_exprlist is pure). *)
  Lemma kit_scalln_pres :
    forall optid fid tys rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
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
    intros optid fid tys rty cc args e le0 m0 tr le1 m1 out0 He_fid Hexec Hcp Htat
           HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
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

  (* the NULLARY censused call: no arguments at all, marg_ok nil is
     trivially true (smyvbof's get_additive_y_vel_for_jumps() pattern). *)
  Lemma kit_scall0_pres :
    forall optid fid rty cc e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction nil rty cc)) nil)
        tr le1 m1 out0 ->
      call_pres lp bm NoA MWF fid ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid rty cc e le0 m0 tr le1 m1 out0 He_fid Hexec Hcp HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr b Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists b; split; assumption)
    end.
    match goal with
    | Ha : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Ha
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ nil _ _ _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf Hres I HN HM HV HS)
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
    forall t fid ty2 tys rty cc q qty args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
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
    intros t fid ty2 tys rty cc q qty args e le0 m0 tr le1 m1 out0
           He_fid Hexec Hcpa Hty2 Hqty Htat Hq HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
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

  (* the EXTERNAL censused call: call_pres_ext has NO marg premise, so
     the argument list is arbitrary (play_sound's
     (SOUND_X, m->marioObj->header.gfx.cameraToObject) pattern) and we
     never invert the exprlist. *)
  Lemma kit_scallx_pres :
    forall optid fid targs tres tcc al e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction targs tres tcc)) al)
        tr le1 m1 out0 ->
      call_pres_ext lp bm NoA MWF fid ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid targs tres tcc al e le0 m0 tr le1 m1 out0 He_fid Hexec Hcpe
           HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr b Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists b; split; assumption)
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hcpe _ _ _ _ _ _ Hevf Hres HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* the act-writer call with a CONSTANT action argument: the leaf
     pattern `set_mario_action(m, ACT_X, 0)`.  The vm-checked constant
     itself meets the row's untainted-scalar premise; the result (if
     any) does NOT feed the act tracking (the caller's census keeps the
     destination temp out of wact). *)
  Lemma kit_scallc_pres :
    forall optid fid ty2 tys rty cc c ity args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid
           (Evar fid (Tfunction (tyMSp :: ty2 :: tys) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp
              :: Econst_int c ity :: args))
        tr le1 m1 out0 ->
      call_pres_act lp bm NoA MWF fid ->
      wact_const c = true -> i32_ty ty2 = true -> i32_ty ity = true ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid ty2 tys rty cc c ity args e le0 m0 tr le1 m1 out0
           He_fid Hexec Hcpa Hc2 Hty2 Hity Htat HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2' Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
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
    (* peel the second arg: the untainted constant, value-neutral cast *)
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hev1 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hev1;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv
             end)
    end.
    match goal with
    | Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
        pose proof (sem_cast_i32_neutral _ _ _ _ _ Hity Hty2 Hcast) as ->
    end.
    pose proof (wact_const_sound _ Hc2) as Hu.
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
          as (HV' & HS' & HM' & HN' & _)
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* the act-writer call whose ACTION argument is a censused act TEMP
     (asgs's own set_mario_action(m, endAction, 0) call): act_inv
     supplies untainted_scalar for the temp's value and the I32 cast
     preserves it (Vundef dies at the cast).  The result (if any) does
     NOT feed the act tracking. *)
  Lemma kit_scallt_pres :
    forall optid fid ty2 tys rty cc q qty args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid
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
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid ty2 tys rty cc q qty args e le0 m0 tr le1 m1 out0
           He_fid Hexec Hcpa Hty2 Hqty Htat Hq HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
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
          as (HV' & HS' & HM' & HN' & _)
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* the THIRD-position act-writer call brick (the asgs class): both
     value arguments are vm-checked constants -- the animation constant
     is value-irrelevant, the action constant meets the act3 row's
     untainted-scalar premise.  No result joins the act tracking. *)
  Lemma kit_scall3_pres :
    forall optid fid ty2 ty3 tys rty cc c2 i2 c3 ity args
           e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid
           (Evar fid (Tfunction (tyMSp :: ty2 :: ty3 :: tys) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp
              :: Econst_int c2 i2 :: Econst_int c3 ity :: args))
        tr le1 m1 out0 ->
      call_pres_act3 lp bm NoA MWF fid ->
      wact_const c3 = true -> i32_ty ty3 = true -> i32_ty ity = true ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid ty2 ty3 tys rty cc c2 i2 c3 ity args
           e le0 m0 tr le1 m1 out0 He_fid Hexec Hcp3 Hc3 Hty3 Hity Htat
           HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hcf1 Hcf2 Hcf3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply (eval_Evar_funct _ _ _ _ _ _ _ _ He_fid) in Hv;
        destruct Hv as (b & Hsym & ->)
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
    (* peel the second arg: the animation constant (value-irrelevant) *)
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hev1 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hev1;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv
             end)
    end.
    (* peel the third arg: the untainted action constant *)
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hev1 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hev1;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv
             end)
    end.
    match goal with
    | Hcast : sem_cast (Vint c3) _ _ _ = Some _ |- _ =>
        pose proof (sem_cast_i32_neutral _ _ _ _ _ Hity Hty3 Hcast) as ->
    end.
    pose proof (wact_const_sound _ Hc3) as Hu.
    (* the marg fact *)
    match goal with
    | Hv1' : le0 ! _ = Some ?vv,
      Hevf : eval_funcall _ _ _ _ (?vv :: ?vrest) _ _ _ |- _ =>
        assert (Hmarg : marg_ok bm (vv :: vrest))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _ |- _ =>
        destruct (Hcp3 _ _ _ _ _ _ _ _ _ Hevf Hres Hmarg Hu HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* ================================================================== *)
  (* THE WRITER WALK.                                                   *)
  (* ================================================================== *)

  (* empty_env discharges every env-unbound premise of the engine
     vacuously: nothing is bound, so e!g = None for ANY ident.  The 8
     fn_vars=nil consumers below feed this for all 7 env premises. *)
  Lemma empty_env_unbound :
    forall (l : list ident) g, mem_id g l = true -> empty_env ! g = None.
  Proof. intros l g _. apply PTree.gempty. Qed.

  (* the lids = nil engine premises, discharged vacuously: a fn_vars=nil
     (or no-local-array) leaf has no indexed-local stores, so the gated
     store row never fires and the binding obligation is over an empty
     census.  These feed the wwalk_pres0 wrapper below. *)
  Lemma hls_nil :
    (@nil ident) <> nil ->
    forall m ch b d v m',
      local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.
  Proof. intros H; exfalso; exact (H eq_refl). Qed.

  Lemma hlocal_nil : forall (e : env) lid,
      mem_id lid (@nil ident) = true ->
      exists lblk tyenv, e ! lid = Some (lblk, tyenv) /\ local_blk lp bm SafeB lblk.
  Proof. intros e lid H. discriminate H. Qed.

  (* ---- the Tier-2 new-content brick: a single indexed-local store
     `(Evar lid (Tarray ..))[i] = rhs` preserves the carried run facts.
     Hls supplies the MWF localstore frame row (the HMWF_localstore witness,
     discharged at the capstone from MWFReal: a store to a watched-disjoint
     stack block leaves every watched cell untouched); Hlocal binds each
     censused local-array id to a watched-disjoint (local_blk) block.  This
     is what the engine's new Sassign case dispatches to. *)
  Lemma wwalk_local_store_pres :
    forall (lids : list ident) (e : env),
      (lids <> nil ->
       forall m ch b d v m',
          local_blk lp bm SafeB b ->
          Mem.store ch m b d v = Some m' -> MWF m -> MWF m') ->
      (forall lid, mem_id lid lids = true ->
         exists lblk tyenv,
           e ! lid = Some (lblk, tyenv) /\ local_blk lp bm SafeB lblk) ->
      forall a1 a2 le m0 tr le' m' out,
        local_idx_store_chk lids a1 = true ->
        exec_stmt function_entry2 (lp_ge lp) e le m0
          (Sassign a1 a2) tr le' m' out ->
        Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
        MWF m0 -> NoA m0 ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\
        MWF m' /\ NoA m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros lids e Hls Hlocal a1 a2 le m0 tr le' m' out Hchk Hexec HV HS HM HN.
    destruct (local_idx_store_chk_shape _ _ Hchk)
      as (lid & ety & sz & attr & idxN & itya & ety2 & ch & -> & Hmem & Hacc).
    assert (Hne : lids <> nil).
    { destruct lids as [| x xs]; [ discriminate Hmem | congruence ]. }
    specialize (Hls Hne).
    destruct (Hlocal lid Hmem) as (lblk & tyenv & Hbind & Hlb).
    assert (Hc0 : carried bm NoA MWF m0).
    { hnf. exact (conj HV (conj HS (conj HM HN))). }
    destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls HNoA_of_MWF
                e lid ety sz attr idxN itya ety2 a2 le m0 tr le' m' out
                lblk tyenv ch Hbind Hlb Hacc Hexec Hc0)
      as (Hc' & Hle & Hout).
    hnf in Hc'. destruct Hc' as (HV' & HS' & HM' & HN').
    exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Hle Hout))))).
  Qed.

  Lemma wwalk_pres :
    forall (rt : bool) (wact ids wids cact xids sids tids lids : list ident),
      (forall fid, mem_id fid ids = true -> call_pres lp bm NoA MWF fid) ->
      (forall fid, mem_id fid wids = true ->
                   call_pres_act lp bm NoA MWF fid) ->
      (forall fid, mem_id fid xids = true ->
                   call_pres_ext lp bm NoA MWF fid) ->
      (forall fid, mem_id fid sids = true ->
                   call_pres_act lp bm NoA MWF fid) ->
      (forall fid, mem_id fid tids = true ->
                   call_pres_act3 lp bm NoA MWF fid) ->
      forall s e le m0 tr le' m' out,
        (lids <> nil ->
         forall m ch b d v m',
            local_blk lp bm SafeB b ->
            Mem.store ch m b d v = Some m' -> MWF m -> MWF m') ->
        (forall lid, mem_id lid lids = true ->
           exists lblk tyenv,
             e ! lid = Some (lblk, tyenv) /\ local_blk lp bm SafeB lblk) ->
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        (forall g, mem_id g stored_globals = true -> e ! g = None) ->
        (forall g, mem_id g ids = true -> e ! g = None) ->
        (forall g, mem_id g wids = true -> e ! g = None) ->
        (forall g, mem_id g xids = true -> e ! g = None) ->
        (forall g, mem_id g sids = true -> e ! g = None) ->
        (forall g, mem_id g tids = true -> e ! g = None) ->
        e ! interaction._gGlobalTimer = None ->
        wwalk_chk' lids rt wact ids wids cact xids sids tids s = true ->
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
    intros rt wact ids wids cact xids sids tids lids Hcp Hcpa Hcpx Hcps Hcp3
           s e le m0 tr le' m' out Hls Hlocal Hexec.
    induction Hexec; intros He Hubi Hubw Hubx Hubs Hubt Hubgt Hchk Htat Hact Hch
                            HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch I))))))).
    - (* Sassign: window / global / indexed-window / action-store bricks *)
      cbn [wwalk_chk'] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hlis].
      2:{ destruct (wwalk_local_store_pres lids e Hls Hlocal
                      _ _ _ _ _ _ _ _ Hlis Hex HV HS HM HN)
            as (HV' & HS' & HM' & HN' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj HN'
                   (conj Htat (conj Hact (conj Hch I))))))). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hdm].
      2:{ exfalso. exact (dead_mask_dead a1 a2 _ _ _ _ _ _ _ Hdm Hex). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hcpt].
      2:{ destruct (chase_ptr_assign_pres _ a1 a2 _ _ _ _ _ _ _ Hcpt Hch
                      Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hrs].
      2:{ destruct (root_assign_pres _ a1 a2 _ _ _ _ _ _ _ Hrs Htat Hch
                      Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hcs].
      2:{ destruct (chase_assign_pres _ _ a1 a2 _ _ _ _ _ _ _ Hcs Hact Hch
                      Hex HM HV HS)
            as (HV' & HS' & HM' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                   (conj Htat (conj Hact (conj Hch I))))))). }
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hchk | Hcac].
      2:{ destruct (const_act_assign_pres a1 a2 _ _ _ _ _ _ _ Hcac Htat
                      Hex HM HV)
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
      destruct Hchk as [Hchk | Hi16].
      2:{ destruct (idx16_assign_pres lp LO_mario bm MWF HMWF_window
                      a1 a2 _ _ _ _ _ _ _ Hi16 Htat Hex HM HV HS)
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
                      a1 a2 _ _ _ _ _ _ _ Hgs He Hex HM HV HS)
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
      cbn [wwalk_chk'] in Hchk.
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
          destruct a as [ c cty | | | | | q qty | | | | | ca cty2 | | | ];
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
          { (* I32 cast of an untainted constant: value-neutral *)
            destruct ca as [ c3 ity | | | | | | | | | | | | | ];
              try discriminate Hrest.
            apply andb_prop in Hrest as [Hrest Hc3].
            apply andb_prop in Hrest as [Hity Hcty2].
            match goal with
            | Hev : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
                inv Hev;
                try (match goal with
                     | Hlv : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ =>
                         inv Hlv
                     end)
            end.
            match goal with
            | Hev1 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
                inv Hev1;
                try (match goal with
                     | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _
                       |- _ => inv Hlv
                     end)
            end.
            match goal with
            | Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
                rewrite (sem_cast_i32_neutral _ _ _ _ _ Hity Hcty2 Hcast)
            end.
            exact (wact_const_sound _ Hc3). }
        * rewrite PTree.gso in Hg by exact Hne.
          exact (Hact _ Hmem _ Hg).
      + intros t Hmem b o Hg.
        destruct (Pos.eq_dec t id) as [-> | Hne].
        * rewrite PTree.gss in Hg. injection Hg as ->.
          rewrite Hmem in Hcc. cbn [negb orb] in Hcc.
          apply orb_true_iff in Hcc. destruct Hcc as [Hcc | Hcs].
          { match goal with
            | Hev : eval_expr _ _ _ _ a _ |- _ =>
                exact (chase_root_set_sound _ _ _ _ _ Hcc Htat HM Hev
                         _ _ eq_refl)
            end. }
          match goal with
          | Hev : eval_expr _ _ _ _ a _ |- _ =>
              exact (chase_step_set_sound _ _ _ _ _ _ Hcs Hch HM Hev
                       _ _ eq_refl)
          end.
        * rewrite PTree.gso in Hg by exact Hne.
          exact (Hch _ Hmem _ _ Hg).
    - (* Scall: censused Mario-head call (plain, into an act temp, an
         EXTERNAL any-arg callee, or the smact-const leaf pattern) *)
      destruct a as [ ci cty | cf cty | cs cty | cl cty | cid fty | tv tvy
                    | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                    | f1 f2 f3 | s1' s2' | g1 g2 ];
        try discriminate Hchk.
      cbn [wwalk_chk'] in Hchk.
      apply andb_prop in Hchk as [Hchk1 Hchk].
      apply andb_prop in Hchk1 as [Hopt Hnc].
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hx | Hchk].
      { (* the EXTERNAL any-arg censused call: no exprlist analysis *)
        apply andb_prop in Hx as [Hx Htf].
        apply andb_prop in Hx as [Hfx How].
        destruct fty as [ | i1 i2 i3 | l1' l2' | r1 r2 | p1 p2
                        | ar1 ar2 ar3 | params res cc | st1 st2
                        | un1 un2 ];
          try discriminate Htf.
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall optid (Evar cid (Tfunction params res cc))
                           al)
                        t (set_opttemp optid vres le) m' Out_normal)
          by (econstructor; eauto).
        destruct (kit_scallx_pres _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubx _ Hfx) Hex
                    (Hcpx _ Hfx) HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        refine (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj _ (conj _ (conj _ I))))))).
        { intros b o Hg. destruct optid as [t'|];
            cbn [set_opttemp] in Hg.
          - rewrite PTree.gso in Hg
              by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                  discriminate Hopt).
            exact (Htat _ _ Hg).
          - exact (Htat _ _ Hg). }
        { intros t0 Hmem x Hg. destruct optid as [t'|];
            cbn [set_opttemp] in Hg.
          - rewrite PTree.gso in Hg
              by (intro EE; rewrite EE in Hmem; rewrite Hmem in How;
                  discriminate How).
            exact (Hact _ Hmem _ Hg).
          - exact (Hact _ Hmem _ Hg). }
        { intros t0 Hmem b o Hg. destruct optid as [t'|];
            cbn [set_opttemp] in Hg.
          - rewrite PTree.gso in Hg
              by (intro EE; rewrite EE in Hmem; rewrite Hmem in Hnc;
                  discriminate Hnc).
            exact (Hch _ Hmem _ _ Hg).
          - exact (Hch _ Hmem _ _ Hg). } }
      destruct fty as [ | i1 i2 i3 | l1' l2' | r1 r2 | p1 p2 | ar1 ar2 ar3
                      | params res cc | st1 st2 | un1 un2 ];
        try discriminate Hchk.
      destruct params as [| ty1 tys].
      { (* the censused NULLARY call *)
        destruct al as [| a1 args]; [ | discriminate Hchk ].
        apply andb_prop in Hchk as [How Hfid].
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall optid (Evar cid (Tfunction nil res cc)) nil)
                        t (set_opttemp optid vres le) m' Out_normal)
          by (econstructor; eauto).
        destruct (kit_scall0_pres _ _ _ _ _ _ _ _ _ _ _ (Hubi _ Hfid) Hex (Hcp _ Hfid)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        refine (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj _ (conj _ (conj _ I))))))).
        { intros b o Hg. destruct optid as [t'|];
            cbn [set_opttemp] in Hg.
          - rewrite PTree.gso in Hg
              by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                  discriminate Hopt).
            exact (Htat _ _ Hg).
          - exact (Htat _ _ Hg). }
        { intros t0 Hmem x Hg. destruct optid as [t'|];
            cbn [set_opttemp] in Hg.
          - rewrite PTree.gso in Hg
              by (intro EE; rewrite EE in Hmem; rewrite Hmem in How;
                  discriminate How).
            exact (Hact _ Hmem _ Hg).
          - exact (Hact _ Hmem _ Hg). }
        { intros t0 Hmem b o Hg. destruct optid as [t'|];
            cbn [set_opttemp] in Hg.
          - rewrite PTree.gso in Hg
              by (intro EE; rewrite EE in Hmem; rewrite Hmem in Hnc;
                  discriminate Hnc).
            exact (Hch _ Hmem _ _ Hg).
          - exact (Hch _ Hmem _ _ Hg). } }
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
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                          (Scall (Some t')
                             (Evar cid (Tfunction (tyMSp :: ty2 :: tys')
                                          res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: Etempvar q qty :: args'))
                          t (set_opttemp (Some t') vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scallw_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubw _ Hfw) Hex
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
        * (* plain censused call, or the smact-const leaf pattern --
             either way the result does NOT land in an act temp *)
          apply orb_true_iff in Hbr.
          destruct Hbr as [Hbr | Ha3].
          2:{ (* the act3 leaf call (the asgs class): both value args
                 vm-checked constants, result discarded from wact *)
            unfold act3_call_chk in Ha3.
            apply andb_prop in Ha3 as [Hf3 Ha3].
            destruct tys as [| ty2 tys2]; try discriminate Ha3.
            destruct tys2 as [| ty3 tys3]; try discriminate Ha3.
            destruct args as [| a2 args2]; try discriminate Ha3.
            destruct a2 as [ c2 i2 | | | | | | | | | | | | | ];
              try discriminate Ha3.
            destruct args2 as [| a3 args3]; try discriminate Ha3.
            destruct a3 as [ c3 ity | | | | | | | | | | | | | ];
              try discriminate Ha3.
            apply andb_prop in Ha3 as [Ha3 Hity].
            apply andb_prop in Ha3 as [Ha3 Hty3].
            apply andb_prop in Ha3 as [Ha3 Hc3].
            apply andb_prop in Ha3 as [Hty2 Hi2].
            assert (Hex : exec_stmt function_entry2 (lp_ge lp) e
                            le m
                            (Scall (Some t')
                               (Evar cid (Tfunction
                                            (tyMSp :: ty2 :: ty3 :: tys3)
                                            res cc))
                               (Etempvar mario_actions_airborne._m tyMSp
                                  :: Econst_int c2 i2
                                  :: Econst_int c3 ity :: args3))
                            t (set_opttemp (Some t') vres le) m'
                            Out_normal)
              by (econstructor; eauto).
            destruct (kit_scall3_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                        _ (Hubt _ Hf3) Hex (Hcp3 _ Hf3) Hc3 Hty3 Hity Htat HN HM HV HS)
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
              exact (Hch _ Hmem _ _ Hg). } }
          apply orb_true_iff in Hbr.
          destruct Hbr as [Hbr | Hsm].
          { (* plain censused call *)
            assert (Hex : exec_stmt function_entry2 (lp_ge lp) e
                            le m
                            (Scall (Some t')
                               (Evar cid (Tfunction (tyMSp :: tys) res cc))
                               (Etempvar mario_actions_airborne._m tyMSp
                                  :: args))
                            t (set_opttemp (Some t') vres le) m'
                            Out_normal)
              by (econstructor; eauto).
            destruct (kit_scalln_pres
                        _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubi _ Hbr) Hex (Hcp _ Hbr) Htat
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
              exact (Hch _ Hmem _ _ Hg). } }
          (* the smact-const leaf call *)
          unfold smact_call_chk in Hsm.
          apply andb_prop in Hsm as [Hfs Hsm].
          destruct tys as [| ty2 tys']; try discriminate Hsm.
          destruct args as [| a2 args']; try discriminate Hsm.
          destruct a2 as [ c2 ity | | | | | q qty | | | | | | | | ];
            try discriminate Hsm.
          2:{ (* the temp-arg form: the action comes from a censused
                 act temp (asgs's own smact(m, endAction, 0) call) *)
            apply andb_prop in Hsm as [Hsm Hqty].
            apply andb_prop in Hsm as [Hq Hty2].
            assert (Hex : exec_stmt function_entry2 (lp_ge lp) e
                            le m
                            (Scall (Some t')
                               (Evar cid (Tfunction (tyMSp :: ty2 :: tys')
                                            res cc))
                               (Etempvar mario_actions_airborne._m tyMSp
                                  :: Etempvar q qty :: args'))
                            t (set_opttemp (Some t') vres le) m'
                            Out_normal)
              by (econstructor; eauto).
            destruct (kit_scallt_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubs _ Hfs) Hex
                        (Hcps _ Hfs) Hty2 Hqty Htat
                        (fun x Hx => Hact _ Hq x Hx) HN HM HV HS)
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
              exact (Hch _ Hmem _ _ Hg). } }
          apply andb_prop in Hsm as [Hsm Hity].
          apply andb_prop in Hsm as [Hc2 Hty2].
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                          (Scall (Some t')
                             (Evar cid (Tfunction (tyMSp :: ty2 :: tys')
                                          res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: Econst_int c2 ity :: args'))
                          t (set_opttemp (Some t') vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scallc_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubs _ Hfs) Hex
                      (Hcps _ Hfs) Hc2 Hty2 Hity Htat HN HM HV HS)
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
      + (* a result-less call: plain censused, or smact-const *)
        apply orb_true_iff in Hbr.
        destruct Hbr as [Hbr | Ha3].
        2:{ (* the act3 leaf call, result-less *)
          unfold act3_call_chk in Ha3.
          apply andb_prop in Ha3 as [Hf3 Ha3].
          destruct tys as [| ty2 tys2]; try discriminate Ha3.
          destruct tys2 as [| ty3 tys3]; try discriminate Ha3.
          destruct args as [| a2 args2]; try discriminate Ha3.
          destruct a2 as [ c2 i2 | | | | | | | | | | | | | ];
            try discriminate Ha3.
          destruct args2 as [| a3 args3]; try discriminate Ha3.
          destruct a3 as [ c3 ity | | | | | | | | | | | | | ];
            try discriminate Ha3.
          apply andb_prop in Ha3 as [Ha3 Hity].
          apply andb_prop in Ha3 as [Ha3 Hty3].
          apply andb_prop in Ha3 as [Ha3 Hc3].
          apply andb_prop in Ha3 as [Hty2 Hi2].
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) e
                          le m
                          (Scall None
                             (Evar cid (Tfunction
                                          (tyMSp :: ty2 :: ty3 :: tys3)
                                          res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: Econst_int c2 i2
                                :: Econst_int c3 ity :: args3))
                          t (set_opttemp None vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scall3_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                      _ (Hubt _ Hf3) Hex (Hcp3 _ Hf3) Hc3 Hty3 Hity Htat HN HM HV HS)
            as (HV' & HS' & HM' & HN' & _ & _).
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                   (conj _ (conj _ (conj _ I))))))).
          { intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat _ _ Hg). }
          { intros t0 Hmem x Hg. cbn [set_opttemp] in Hg.
            exact (Hact _ Hmem _ Hg). }
          { intros t0 Hmem b o Hg. cbn [set_opttemp] in Hg.
            exact (Hch _ Hmem _ _ Hg). } }
        apply orb_true_iff in Hbr.
        destruct Hbr as [Hbr | Hsm].
        { (* plain censused call *)
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                          (Scall None
                             (Evar cid (Tfunction (tyMSp :: tys) res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: args))
                          t (set_opttemp None vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scalln_pres
                      _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubi _ Hbr) Hex (Hcp _ Hbr) Htat
                      HN HM HV HS)
            as (HV' & HS' & HM' & HN' & _ & _).
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                   (conj _ (conj _ (conj _ I))))))).
          { intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat _ _ Hg). }
          { intros t0 Hmem x Hg. cbn [set_opttemp] in Hg.
            exact (Hact _ Hmem _ Hg). }
          { intros t0 Hmem b o Hg. cbn [set_opttemp] in Hg.
            exact (Hch _ Hmem _ _ Hg). } }
        (* the smact-const leaf call, result discarded *)
        unfold smact_call_chk in Hsm.
        apply andb_prop in Hsm as [Hfs Hsm].
        destruct tys as [| ty2 tys']; try discriminate Hsm.
        destruct args as [| a2 args']; try discriminate Hsm.
        destruct a2 as [ c2 ity | | | | | q qty | | | | | | | | ];
          try discriminate Hsm.
        2:{ (* the temp-arg form, result-less *)
          apply andb_prop in Hsm as [Hsm Hqty].
          apply andb_prop in Hsm as [Hq Hty2].
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) e
                          le m
                          (Scall None
                             (Evar cid (Tfunction (tyMSp :: ty2 :: tys')
                                          res cc))
                             (Etempvar mario_actions_airborne._m tyMSp
                                :: Etempvar q qty :: args'))
                          t (set_opttemp None vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scallt_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubs _ Hfs) Hex
                      (Hcps _ Hfs) Hty2 Hqty Htat
                      (fun x Hx => Hact _ Hq x Hx) HN HM HV HS)
            as (HV' & HS' & HM' & HN' & _ & _).
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                   (conj _ (conj _ (conj _ I))))))).
          { intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat _ _ Hg). }
          { intros t0 Hmem x Hg. cbn [set_opttemp] in Hg.
            exact (Hact _ Hmem _ Hg). }
          { intros t0 Hmem b o Hg. cbn [set_opttemp] in Hg.
            exact (Hch _ Hmem _ _ Hg). } }
        apply andb_prop in Hsm as [Hsm Hity].
        apply andb_prop in Hsm as [Hc2 Hty2].
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall None
                           (Evar cid (Tfunction (tyMSp :: ty2 :: tys')
                                        res cc))
                           (Etempvar mario_actions_airborne._m tyMSp
                              :: Econst_int c2 ity :: args'))
                        t (set_opttemp None vres le) m' Out_normal)
          by (econstructor; eauto).
        destruct (kit_scallc_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (Hubs _ Hfs) Hex
                    (Hcps _ Hfs) Hc2 Hty2 Hity Htat HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        refine (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj _ (conj _ (conj _ I))))))).
        { intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat _ _ Hg). }
        { intros t0 Hmem x Hg. cbn [set_opttemp] in Hg.
          exact (Hact _ Hmem _ Hg). }
        { intros t0 Hmem b o Hg. cbn [set_opttemp] in Hg.
          exact (Hch _ Hmem _ _ Hg). }
    - (* Sbuiltin: excluded *)
      cbn [wwalk_chk'] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [wwalk_chk'] in Hchk.
      apply orb_true_iff in Hchk. destruct Hchk as [Hpair | Hchk].
      { (* the fused non-pointer-source pair *)
        match goal with
        | Hx1 : exec_stmt _ _ _ _ _ s1 _ _ _ Out_normal,
          Hx2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
            destruct (npsrc_pair_pres _ _ _ _ _ _ _ _ _ _ _ _ _ _
                        Hpair Hubgt Htat Hact Hch Hx1 Hx2 HM HV HS)
              as (HV' & HS' & HM' & Htat' & Hact' & Hch' & ->)
        end.
        exact (conj HV' (conj HS' (conj HM' (conj (HNoA_of_MWF _ HM')
                 (conj Htat' (conj Hact' (conj Hch' I))))))). }
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & _).
      exact (IHHexec2 Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [wwalk_chk'] in Hchk.
      apply orb_true_iff in Hchk. destruct Hchk as [Hpair | Hchk].
      { (* a pair's Sset head cannot exit abnormally *)
        exfalso.
        unfold npsrc_pair_chk in Hpair.
        destruct s1; try discriminate Hpair.
        match goal with
        | Hx : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hx
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ => exact (Hne eq_refl)
        end. }
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H1 Htat Hact Hch HN HM HV HS).
    - (* Sifthenelse *)
      cbn [wwalk_chk'] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch I))))))).
    - (* Sreturn (Some a): the censused return (only when rt = true) *)
      cbn [wwalk_chk'] in Hchk.
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
      cbn [wwalk_chk'] in Hchk. apply andb_prop in Hchk as [H1 _].
      destruct (IHHexec Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & Hret1).
      refine (conj HV1 (conj HS1 (conj HM1 (conj HN1
               (conj Htat1 (conj Hact1 (conj Hch1 _))))))).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + exact I.
      + exact Hret1.
    - (* Sloop stop2 *)
      cbn [wwalk_chk'] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & _).
      destruct (IHHexec2 Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Htat2 & Hact2 & Hch2 & Hret2).
      refine (conj HV2 (conj HS2 (conj HM2 (conj HN2
               (conj Htat2 (conj Hact2 (conj Hch2 _))))))).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + exact I.
      + exact Hret2.
    - (* Sloop loop *)
      cbn [wwalk_chk'] in Hchk.
      pose proof Hchk as Hchk2.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & _).
      destruct (IHHexec2 Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Htat2 & Hact2 & Hch2 & _).
      apply IHHexec3; try assumption;
        cbn [wwalk_chk']; exact Hchk2.
    - (* Sswitch *)
      cbn [wwalk_chk'] in Hchk.
      destruct (IHHexec Hlocal He Hubi Hubw Hubx Hubs Hubt Hubgt
                  (wwalk_chk_select' _ _ _ _ _ _ _ _ _ n _ Hchk)
                  Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & Hret1).
      refine (conj HV1 (conj HS1 (conj HM1 (conj HN1
               (conj Htat1 (conj Hact1 (conj Hch1 _))))))).
      destruct out as [ | | | ov ]; try exact I.
      exact Hret1.
  Qed.

  (* the lids = nil specialization -- the producer-facing engine.  Every
     existing producer (fn_vars=nil, or no indexed-local stores) calls THIS,
     so its arg list is the pre-Tier-2 one (no lids / Hls / Hlocal): they are
     discharged here from hls_nil / hlocal_nil.  Only the new Tier-2 producer
     calls wwalk_pres directly with a real lids. *)
  Lemma wwalk_pres0 :
    forall (rt : bool) (wact ids wids cact xids sids tids : list ident),
      (forall fid, mem_id fid ids = true -> call_pres lp bm NoA MWF fid) ->
      (forall fid, mem_id fid wids = true ->
                   call_pres_act lp bm NoA MWF fid) ->
      (forall fid, mem_id fid xids = true ->
                   call_pres_ext lp bm NoA MWF fid) ->
      (forall fid, mem_id fid sids = true ->
                   call_pres_act lp bm NoA MWF fid) ->
      (forall fid, mem_id fid tids = true ->
                   call_pres_act3 lp bm NoA MWF fid) ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        (forall g, mem_id g stored_globals = true -> e ! g = None) ->
        (forall g, mem_id g ids = true -> e ! g = None) ->
        (forall g, mem_id g wids = true -> e ! g = None) ->
        (forall g, mem_id g xids = true -> e ! g = None) ->
        (forall g, mem_id g sids = true -> e ! g = None) ->
        (forall g, mem_id g tids = true -> e ! g = None) ->
        e ! interaction._gGlobalTimer = None ->
        wwalk_chk rt wact ids wids cact xids sids tids s = true ->
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
    intros rt wact ids wids cact xids sids tids Hcp Hcpa Hcpx Hcps Hcp3
           s e le m0 tr le' m' out Hexec He Hubi Hubw Hubx Hubs Hubt Hubgt
           Hchk Htat Hact Hch HN HM HV HS.
    exact (wwalk_pres rt wact ids wids cact xids sids tids nil
             Hcp Hcpa Hcpx Hcps Hcp3 s e le m0 tr le' m' out
             hls_nil (hlocal_nil e) Hexec
             He Hubi Hubw Hubx Hubs Hubt Hubgt Hchk Htat Hact Hch HN HM HV HS).
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

(* a censused id avoids a list when the whole census checks against it *)
Lemma forallb_negb_mem_id : forall (l census : list ident) t,
    forallb (fun t' => negb (mem_id t' l)) census = true ->
    mem_id t census = true ->
    mem_id t l = false.
Proof.
  induction census as [| c cs IH]; intros t Hf Hm; [ discriminate Hm | ].
  cbn [forallb] in Hf. apply andb_prop in Hf as [Hc Hcs].
  unfold mem_id in Hm. cbn [existsb] in Hm.
  apply orb_true_iff in Hm as [He | Hm].
  - apply Pos.eqb_eq in He. subst c. exact (proj1 (negb_true_iff _) Hc).
  - exact (IH _ Hcs Hm).
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

(* the asgs-class param triple: Mario's pointer, the animation, the
   UNTAINTED action THIRD (the act3 row's seed). *)
Definition act3_params : list (ident * type) :=
  (mario_actions_airborne._m, tyMSp)
    :: (mario_actions_object._animation, tint)
    :: (mario_actions_object._endAction, tuint) :: nil.

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
Example smas_ret : i32_ty (fn_return mario.f_set_mario_action_submerged) = true.
Proof. vm_compute. reflexivity. Qed.

Example smac_vars : fn_vars mario.f_set_mario_action_cutscene = nil.
Proof. vm_compute. reflexivity. Qed.
Example smac_params :
  fn_params mario.f_set_mario_action_cutscene = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smac_ret : i32_ty (fn_return mario.f_set_mario_action_cutscene) = true.
Proof. vm_compute. reflexivity. Qed.

Example smact_vars : fn_vars mario.f_set_mario_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example smact_params : fn_params mario.f_set_mario_action = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smact_ret : i32_ty (fn_return mario.f_set_mario_action) = true.
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
  wwalk_chk true wact_sub nil nil nil nil nil nil
    (fn_body mario.f_set_mario_action_submerged) = true.
Proof. vm_compute. reflexivity. Qed.

Example smac_walk :
  wwalk_chk true wact_sub smac_ids nil nil nil nil nil
    (fn_body mario.f_set_mario_action_cutscene) = true.
Proof. vm_compute. reflexivity. Qed.

Example smact_walk :
  wwalk_chk true wact_smact nil smact_wids nil nil nil nil
    (fn_body mario.f_set_mario_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the writer census bites -- an empty wids fails *)
Example smact_walk_not_vacuous :
  wwalk_chk true wact_smact nil nil nil nil nil nil
    (fn_body mario.f_set_mario_action) = false.
Proof. vm_compute. reflexivity. Qed.

Example msfv_walk :
  wwalk_chk false nil nil nil nil nil nil nil
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
Example smam_ret : i32_ty (fn_return mario.f_set_mario_action_moving) = true.
Proof. vm_compute. reflexivity. Qed.

Example smam_walk :
  wwalk_chk true wact_sub mov_ids nil mov_cact nil nil nil
    (fn_body mario.f_set_mario_action_moving) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the chase census bites -- an empty cact fails *)
Example smam_walk_not_vacuous :
  wwalk_chk true wact_sub mov_ids nil nil nil nil nil
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
  wwalk_chk false nil nil nil nil nil nil nil
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
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_facing_downhill) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- AIRBORNE (smaa): FIVE chase temps (the per-case marioObj/gfx
   pointer loads), two tshort faceAngle[CONST] idx stores, a rawData
   store fed by _t'4 (itself Sset only from I32 casts of constants, so
   it joins the act census), and two plain Mario-head callees.  The
   y-vel helper calls the NULLARY get_additive_y_vel_for_jumps, whose
   body lives in the mario_step TU. ---- *)
Definition wact_air : list ident := mario._action :: mario._t'4 :: nil.
Definition air_ids : list ident :=
  mario._set_mario_y_vel_based_on_fspeed :: mario._mario_set_forward_vel
    :: nil.
Definition air_cact : list ident :=
  mario._t'10 :: mario._t'12 :: mario._t'14 :: mario._t'18
    :: mario._t'20 :: nil.
Definition smyv_ids : list ident :=
  mario._get_additive_y_vel_for_jumps :: nil.

Example gayvfj_pin :
  (prog_defmap mario_step.prog) ! mario._get_additive_y_vel_for_jumps
  = Some (Gfun (Internal mario_step.f_get_additive_y_vel_for_jumps)).
Proof. vm_compute. reflexivity. Qed.

Example gayvfj_vars :
  fn_vars mario_step.f_get_additive_y_vel_for_jumps = nil.
Proof. vm_compute. reflexivity. Qed.
Example gayvfj_params :
  fn_params mario_step.f_get_additive_y_vel_for_jumps = nil.
Proof. vm_compute. reflexivity. Qed.

Example gayvfj_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_get_additive_y_vel_for_jumps) = true.
Proof. vm_compute. reflexivity. Qed.

Example smyv_pin :
  (prog_defmap mario.prog) ! mario._set_mario_y_vel_based_on_fspeed
  = Some (Gfun (Internal mario.f_set_mario_y_vel_based_on_fspeed)).
Proof. vm_compute. reflexivity. Qed.

Example smyv_vars : fn_vars mario.f_set_mario_y_vel_based_on_fspeed = nil.
Proof. vm_compute. reflexivity. Qed.
Example smyv_params_ok :
  match fn_params mario.f_set_mario_y_vel_based_on_fspeed with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Example smyv_walk :
  wwalk_chk false nil smyv_ids nil nil nil nil nil
    (fn_body mario.f_set_mario_y_vel_based_on_fspeed) = true.
Proof. vm_compute. reflexivity. Qed.

Example smaa_pin :
  (prog_defmap mario.prog) ! mario._set_mario_action_airborne
  = Some (Gfun (Internal mario.f_set_mario_action_airborne)).
Proof. vm_compute. reflexivity. Qed.

Example smaa_vars : fn_vars mario.f_set_mario_action_airborne = nil.
Proof. vm_compute. reflexivity. Qed.
Example smaa_params :
  fn_params mario.f_set_mario_action_airborne = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example smaa_ret : i32_ty (fn_return mario.f_set_mario_action_airborne) = true.
Proof. vm_compute. reflexivity. Qed.

Example smaa_walk :
  wwalk_chk true wact_air air_ids nil air_cact nil nil nil
    (fn_body mario.f_set_mario_action_airborne) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the chase census bites -- an empty cact fails *)
Example smaa_walk_not_vacuous :
  wwalk_chk true wact_air air_ids nil nil nil nil nil
    (fn_body mario.f_set_mario_action_airborne) = false.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)
Section ActWriterRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.

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
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* ---- the stack-frame MWF rows for the local-vars arc (Tier-1: a leaf
     whose stack locals are written ONLY by external out-param calls, never
     directly stored into).  Both discharge from MWFReal at the capstone:
     HMWF_alloc <- mwf_real entry-alloc (MWF_real_transfer), HMWF_free <-
     mwf_real_free (free_list preserves MWF_real unconditionally).  No
     globals-valid / SafeB-valid rows are needed: the Tier-1 exit only uses
     that the freed stack blocks miss bm. ---- *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.

  (* ---- the funcall->body entry for a PLAIN walked leaf WITH STACK LOCALS
     (fn_vars f <> nil): the entry alloc_variables builds e_loc binding each
     local to a FRESH (watched-disjoint) block, the e-parametric engine walks
     the body over e_loc, and the exit free_list frees those local blocks --
     all preserving the carried run facts.  The local idents must be disjoint
     from every census + the read globals (so the engine's e!g=None premises
     hold for e_loc); that is a finite vm_compute check per leaf. *)
  Lemma call_pres_of_lwalk :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (ids wids xids sids : list ident),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      match fn_params f with
      | (i, ty) :: ps =>
          Pos.eqb i mario_actions_airborne._m
          && proj_sumbool (type_eq ty tyMSp)
          && negb (mem_id mario_actions_airborne._m (map fst ps))
      | nil => false
      end = true ->
      (forall g, mem_id g stored_globals = true ->
                 ~ In g (map fst (fn_vars f))) ->
      (forall g, mem_id g ids = true -> ~ In g (map fst (fn_vars f))) ->
      (forall g, mem_id g wids = true -> ~ In g (map fst (fn_vars f))) ->
      (forall g, mem_id g xids = true -> ~ In g (map fst (fn_vars f))) ->
      (forall g, mem_id g sids = true -> ~ In g (map fst (fn_vars f))) ->
      ~ In interaction._gGlobalTimer (map fst (fn_vars f)) ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids nil xids sids nil (fn_body f) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros TU fid f ids wids xids sids LOtu Hdm Hps
           Hdg Hdi Hdw Hdx Hds Hdgt
           Hcp Hcpa Hcpx Hcps Hchk
           fd m0 vargs0 t0 mF vres0 Hevf Hres Hmarg HN HM HV HS.
    pose proof (resolve_pin_fd lp _ _ _ _ LOtu Hdm Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    (* name the body env e_loc *)
    match goal with
    | Hb : exec_stmt _ _ ?E _ _ _ _ _ _ _ |- _ => set (eloc := E) in *
    end.
    (* carried at the post-alloc memory (alloc only adds fresh blocks) *)
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV
         | split; [ exact HS | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    destruct Hca as (HVa & HSa & HMa & HNa).
    (* param check + bind: _m holds Mario's pinned pointer *)
    destruct (fn_params f) as [| [i ty] ps ] eqn:Eps;
      [ discriminate Hps | ].
    apply andb_prop in Hps as [Hps Hnm].
    apply andb_prop in Hps as [Hi Hty].
    apply Pos.eqb_eq in Hi. subst i.
    destruct (type_eq ty tyMSp); [ subst ty | discriminate Hty ].
    apply negb_true_iff in Hnm.
    destruct vargs0 as [| v0 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
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
    (* the empty tids census + the seven e_loc-unbound premises *)
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    eloc ! g = None)
      by (intros g Hg;
          rewrite (alloc_variables_unbound (lp_ge lp) m0 (fn_vars f)
                     empty_env _ _ Halloc g (Hdg g Hg)); apply PTree.gempty).
    assert (Hub_i : forall g, mem_id g ids = true -> eloc ! g = None)
      by (intros g Hg;
          rewrite (alloc_variables_unbound (lp_ge lp) m0 (fn_vars f)
                     empty_env _ _ Halloc g (Hdi g Hg)); apply PTree.gempty).
    assert (Hub_w : forall g, mem_id g wids = true -> eloc ! g = None)
      by (intros g Hg;
          rewrite (alloc_variables_unbound (lp_ge lp) m0 (fn_vars f)
                     empty_env _ _ Halloc g (Hdw g Hg)); apply PTree.gempty).
    assert (Hub_x : forall g, mem_id g xids = true -> eloc ! g = None)
      by (intros g Hg;
          rewrite (alloc_variables_unbound (lp_ge lp) m0 (fn_vars f)
                     empty_env _ _ Halloc g (Hdx g Hg)); apply PTree.gempty).
    assert (Hub_s : forall g, mem_id g sids = true -> eloc ! g = None)
      by (intros g Hg;
          rewrite (alloc_variables_unbound (lp_ge lp) m0 (fn_vars f)
                     empty_env _ _ Halloc g (Hds g Hg)); apply PTree.gempty).
    assert (Hub_t : forall g, mem_id g (@nil ident) = true -> eloc ! g = None)
      by (intros g HH; discriminate HH).
    assert (Hub_gt : eloc ! interaction._gGlobalTimer = None)
      by (rewrite (alloc_variables_unbound (lp_ge lp) m0 (fn_vars f)
                     empty_env _ _ Halloc interaction._gGlobalTimer Hdgt);
          apply PTree.gempty).
    (* the walk over e_loc *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids wids nil xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_w Hub_x Hub_s Hub_t Hub_gt
                Hchk Htat0 Hact0 Hch0 HNa HMa HVa HSa)
      as (HVb & HSb & HMb & HNb & _ & _ & _ & _).
    (* the exit free_list frees only the FRESH local blocks -- each misses bm,
       so it leaves bm's window/action cell (and MWF unconditionally) intact *)
    pose proof (blocks_of_env_bm lp bm m0 (fn_vars f) eloc _ Halloc HV)
      as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF
                  Hforall Hfree (conj HVb (conj HSb (conj HMb HNb)))) as Hcf.
    destruct Hcf as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf (conj HMf HNf))).
  Qed.

  (* ---- the funcall->body entry for a PLAIN walked leaf (rt = false,
     no act census): any param list with Mario's pointer at the head. *)
  Lemma call_pres_of_wwalk :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (ids wids xids sids : list ident),
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
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids nil xids sids nil (fn_body f) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros TU fid f ids wids xids sids LOtu Hdm Hvars Hps
           Hcp Hcpa Hcpx Hcps Hchk
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
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids wids nil xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the funcall->body entry for a PLAIN walked leaf WITH a chase
     census: Mario's pointer at the head, and every censused chase temp
     a NON-param (undef at entry, so chase_inv holds vacuously). *)
  Lemma call_pres_of_wwalk_cact :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (ids wids cact xids sids : list ident),
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
      forallb (fun t' => negb (mem_id t' (map fst (fn_params f)))) cact
        = true ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids cact xids sids nil (fn_body f) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros TU fid f ids wids cact xids sids LOtu Hdm Hvars Hps Hnpc
           Hcp Hcpa Hcpx Hcps Hchk
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
        assert (Hch0 : chase_inv SafeB cact le1)
          by (intros t' Hmem' b o Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpc Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              discriminate EE)
    end.
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids wids cact xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the cact entry with a NONEMPTY act-temp census: leaves whose
     smact calls pass a LOCAL untainted const through a temp
     (mario_check_object_grab's t'5, mario_update_punch_sequence's
     endAction/crouchEndAction).  At entry every wact temp is Vundef
     (untainted_scalar's left disjunct); wsrc_chk keeps it untainted. *)
  Lemma call_pres_of_wwalk_wact :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (wact ids wids cact xids sids : list ident),
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
      forallb (fun t' => negb (mem_id t' (map fst (fn_params f)))) cact
        = true ->
      forallb (fun t' => negb (mem_id t' (map fst (fn_params f)))) wact
        = true ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false wact ids wids cact xids sids nil (fn_body f) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros TU fid f wact ids wids cact xids sids LOtu Hdm Hvars Hps Hnpc
           Hnpw Hcp Hcpa Hcpx Hcps Hchk
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
        assert (Hact0 : act_inv wact le1)
          by (intros t' Hmem' x Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpw Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              rewrite EE; left; reflexivity);
        assert (Hch0 : chase_inv SafeB cact le1)
          by (intros t' Hmem' b o Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpc Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              discriminate EE)
    end.
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false wact ids wids cact xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the funcall->body entry for a NULLARY leaf (params = nil):
     no Mario pointer at all, so every env fact is vacuous at entry. *)
  Lemma call_pres_of_wwalk0 :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (ids wids xids sids : list ident),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil ->
      fn_params f = nil ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids nil xids sids nil (fn_body f) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros TU fid f ids wids xids sids LOtu Hdm Hvars Hparams
           Hcp Hcpa Hcpx Hcps Hchk
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
    rewrite Hparams in Hbind.
    destruct vargs0 as [| v0 vrest];
      cbn [bind_parameter_temps] in Hbind; [ | discriminate Hbind ].
    injection Hbind as <-.
    (* the entry env facts: everything starts Vundef *)
    assert (Htat0 : forall b o,
               (create_undef_temps (fn_temps f))
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      pose proof (create_undef_temps_val _ _ _ Hg) as EE.
      discriminate EE. }
    assert (Hact0 : act_inv nil (create_undef_temps (fn_temps f)))
      by (intros t' Hmem' x Hg'; discriminate Hmem').
    assert (Hch0 : chase_inv SafeB nil (create_undef_temps (fn_temps f)))
      by (intros t' Hmem' b o Hg'; discriminate Hmem').
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids wids nil xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the funcall->body entry for a per-family LEAF residual
     (RestSurface.body_pres): the same Mario-head shape as
     call_pres_of_wwalk, but takes the function DIRECTLY -- the
     capstone's Hpres_*_callees hypotheses quantify over the censused
     body, not a resolution.  The marg premise is unlocked by computing
     marg_exempt = false from the Mario-head parameter shape. *)
  Lemma body_pres_of_wwalk :
    forall (f : Clight.function) (ids wids xids sids tids : list ident),
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
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' tids = true ->
                    call_pres_act3 lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids nil xids sids tids (fn_body f) = true ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros f ids wids xids sids tids Hvars Hps Hcp Hcpa Hcpx Hcps Hcp3t Hchk
           m0 vargs0 t0 m1 vres0 Hmargf Hevf HN HM HV HS.
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
    (* the Mario-head parameter shape computes marg_exempt = false,
       unlocking the funcall's marg premise *)
    assert (Hmarg : marg_ok bm vargs0).
    { apply Hmargf. unfold marg_exempt. rewrite Eps. reflexivity. }
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
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids wids nil xids sids tids Hcp Hcpa Hcpx Hcps
                Hcp3t _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & _).
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* ---- the per-family LEAF entry WITH a chase census: the same
     Mario-head shape as body_pres_of_wwalk, every censused chase temp
     a NON-param (undef at entry, so chase_inv holds vacuously). *)
  Lemma body_pres_of_wwalk_cact :
    forall (f : Clight.function)
           (ids wids cact xids sids tids : list ident),
      fn_vars f = nil ->
      match fn_params f with
      | (i, ty) :: ps =>
          Pos.eqb i mario_actions_airborne._m
          && proj_sumbool (type_eq ty tyMSp)
          && negb (mem_id mario_actions_airborne._m (map fst ps))
      | nil => false
      end = true ->
      forallb (fun t' => negb (mem_id t' (map fst (fn_params f)))) cact
        = true ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' tids = true ->
                    call_pres_act3 lp bm NoA MWF fid') ->
      wwalk_chk false nil ids wids cact xids sids tids (fn_body f)
        = true ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros f ids wids cact xids sids tids Hvars Hps Hnpc
           Hcp Hcpa Hcpx Hcps Hcp3t Hchk
           m0 vargs0 t0 m1 vres0 Hmargf Hevf HN HM HV HS.
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
    (* the Mario-head parameter shape computes marg_exempt = false,
       unlocking the funcall's marg premise *)
    assert (Hmarg : marg_ok bm vargs0).
    { apply Hmargf. unfold marg_exempt. rewrite Eps. reflexivity. }
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
        assert (Hch0 : chase_inv SafeB cact le1)
          by (intros t' Hmem' b o Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpc Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              discriminate EE)
    end.
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids wids cact xids sids tids Hcp Hcpa Hcpx Hcps
                Hcp3t _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & _).
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* ---- the per-family LEAF entry WITH an untainted action-temp census
     (wact): the same Mario-head shape as body_pres_of_wwalk_cact, but the
     action argument handed to a writer (set_mario_action via sids) is a
     TEMP in wact, seeded from an untainted const/copy (e.g. act_grabbed's
     _t'1 := ACT_THROWN_FORWARD/BACKWARD). Every censused temp is a
     NON-param, so at entry every wact temp is Vundef (act_inv's left
     disjunct) and every cact temp is Vundef (chase_inv vacuous). This is
     body_pres_of_wwalk_cact + the wact seeding from call_pres_of_wwalk_wact;
     it reuses the SAME wwalk_pres engine. *)
  Lemma body_pres_of_wwalk_wact :
    forall (f : Clight.function)
           (wact ids wids cact xids sids tids : list ident),
      fn_vars f = nil ->
      match fn_params f with
      | (i, ty) :: ps =>
          Pos.eqb i mario_actions_airborne._m
          && proj_sumbool (type_eq ty tyMSp)
          && negb (mem_id mario_actions_airborne._m (map fst ps))
      | nil => false
      end = true ->
      forallb (fun t' => negb (mem_id t' (map fst (fn_params f)))) cact
        = true ->
      forallb (fun t' => negb (mem_id t' (map fst (fn_params f)))) wact
        = true ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' tids = true ->
                    call_pres_act3 lp bm NoA MWF fid') ->
      wwalk_chk false wact ids wids cact xids sids tids (fn_body f)
        = true ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros f wact ids wids cact xids sids tids Hvars Hps Hnpc Hnpw
           Hcp Hcpa Hcpx Hcps Hcp3t Hchk
           m0 vargs0 t0 m1 vres0 Hmargf Hevf HN HM HV HS.
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
    assert (Hmarg : marg_ok bm vargs0).
    { apply Hmargf. unfold marg_exempt. rewrite Eps. reflexivity. }
    destruct vargs0 as [| v0 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    match goal with
    | Hbind' : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
        assert (Htat0 : forall b o,
                   le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero)
          by (intros b o Hg;
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnm) in Hg;
              rewrite PTree.gss in Hg; injection Hg as ->;
              cbn in Hmarg; exact Hmarg);
        assert (Hact0 : act_inv wact le1)
          by (intros t' Hmem' x Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpw Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              rewrite EE; left; reflexivity);
        assert (Hch0 : chase_inv SafeB cact le1)
          by (intros t' Hmem' b o Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpc Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              discriminate EE)
    end.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false wact ids wids cact xids sids tids Hcp Hcpa Hcpx Hcps
                Hcp3t _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & _).
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* ---- the funcall->body entry for a WRITER (rt = true): the shared
     three-param shape; the act census is seeded by the untainted action
     argument, every other censused temp starts Vundef. *)
  Lemma call_pres_act_of_wwalk :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (wact ids wids cact xids sids : list ident),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil ->
      fn_params f = writer_params ->
      i32_ty (fn_return f) = true ->
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
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk true wact ids wids cact xids sids nil (fn_body f) = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros TU fid f wact ids wids cact xids sids LOtu Hdm Hvars Hparams
           Hret Hwa Hwm Hwarg Hcm Hca Hcarg Hcp Hcpa Hcpx Hcps Hchk
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
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                true wact ids wids cact xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & Hret').
    (* the return value: an I32 fn_return forces a censused return *)
    destruct (fn_return f) as [ | rsz rsg raa | | | | | | | ] eqn:Eret;
      try discriminate Hret.
    destruct rsz; try discriminate Hret.
    unfold outcome_result_value in Hout.
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
               (sem_cast_i32_untainted _ _ _ _ _ Hi32' Hret
                  Huv Hcast))))).
  Qed.

  (* ---- the funcall->body entry for the THIRD-position writer (the
     asgs class, void return / rt = false): Mario's pointer first, the
     animation second, the UNTAINTED action THIRD seeding the act
     census. *)
  Lemma call_pres_act3_of_wwalk :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function)
           (wact ids wids cact xids sids : list ident),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil ->
      fn_params f = act3_params ->
      mem_id mario_actions_object._endAction wact = true ->
      mem_id mario_actions_airborne._m wact = false ->
      mem_id mario_actions_object._animation wact = false ->
      mem_id mario_actions_airborne._m cact = false ->
      mem_id mario_actions_object._animation cact = false ->
      mem_id mario_actions_object._endAction cact = false ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      wwalk_chk false wact ids wids cact xids sids nil (fn_body f) = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros TU fid f wact ids wids cact xids sids LOtu Hdm Hvars Hparams
           Hwa Hwm Hwanim Hcm Hcanim Hcend Hcp Hcpa Hcpx Hcps Hchk
           fd m0 v0 v1 aval rest t0 m1 vres0 Hevf Hres Hmarg Hu HN HM HV HS.
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
    rewrite Hparams in Hbind. unfold act3_params in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct rest as [| vx restx ];
      cbn [bind_parameter_temps] in Hbind; [ | discriminate Hbind ].
    injection Hbind as <-.
    set (base := create_undef_temps (fn_temps f)) in *.
    (* the entry env facts *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_object._endAction aval
                  (PTree.set mario_actions_object._animation v1
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
               (PTree.set mario_actions_object._endAction aval
                  (PTree.set mario_actions_object._animation v1
                     (PTree.set mario_actions_airborne._m v0 base)))).
    { intros t' Hmem' x Hg'.
      destruct (Pos.eq_dec t' mario_actions_object._endAction)
        as [-> | Hne1].
      { rewrite PTree.gss in Hg'. injection Hg' as <-. exact Hu. }
      rewrite PTree.gso in Hg' by exact Hne1.
      destruct (Pos.eq_dec t' mario_actions_object._animation)
        as [-> | Hne2].
      { rewrite Hmem' in Hwanim. discriminate Hwanim. }
      rewrite PTree.gso in Hg' by exact Hne2.
      destruct (Pos.eq_dec t' mario_actions_airborne._m) as [-> | Hne3].
      { rewrite Hmem' in Hwm. discriminate Hwm. }
      rewrite PTree.gso in Hg' by exact Hne3.
      left. exact (create_undef_temps_val _ _ _ Hg'). }
    assert (Hch0 : chase_inv SafeB cact
               (PTree.set mario_actions_object._endAction aval
                  (PTree.set mario_actions_object._animation v1
                     (PTree.set mario_actions_airborne._m v0 base)))).
    { intros t' Hmem' b o Hg'.
      destruct (Pos.eq_dec t' mario_actions_object._endAction)
        as [-> | Hne1].
      { rewrite Hmem' in Hcend. discriminate Hcend. }
      rewrite PTree.gso in Hg' by exact Hne1.
      destruct (Pos.eq_dec t' mario_actions_object._animation)
        as [-> | Hne2].
      { rewrite Hmem' in Hcanim. discriminate Hcanim. }
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
    assert (Hcpt0 : forall fid', mem_id fid' nil = true ->
                    call_pres_act3 lp bm NoA MWF fid')
      by (intros fid' HH; discriminate HH).
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false wact ids wids cact xids sids nil Hcp Hcpa Hcpx Hcps
                Hcpt0 _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _ & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the helper row: mario_set_forward_vel (PROVED -- its only
     non-window store is the vel[0] indexed write). ---- *)
  Lemma msfv_row : call_pres lp bm NoA MWF mario._mario_set_forward_vel.
  Proof.
    apply (call_pres_of_wwalk mario.prog mario._mario_set_forward_vel
             mario.f_mario_set_forward_vel nil nil nil nil LO_mario
             msfv_pin msfv_vars msfv_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
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
             nil nil
             LO_mario smas_pin smas_vars smas_params smas_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smas_walk.
  Qed.

  Lemma smac_row :
    call_pres_act lp bm NoA MWF mario._set_mario_action_cutscene.
  Proof.
    apply (call_pres_act_of_wwalk mario.prog _
             mario.f_set_mario_action_cutscene wact_sub smac_ids nil nil
             nil nil
             LO_mario smac_pin smac_vars smac_params smac_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact smac_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smac_walk.
  Qed.

  (* ---- the MOVING row, PROVED via the chase census (cact = [_t'7]
     traces the marioObj pointer; its rawData.asS32[34] := 0 store is
     the chase_store_chk arm). ---- *)
  Lemma mgfc_row : call_pres lp bm NoA MWF mario._mario_get_floor_class.
  Proof.
    apply (call_pres_of_wwalk mario.prog mario._mario_get_floor_class
             mario.f_mario_get_floor_class nil nil nil nil LO_mario
             mgfc_pin mgfc_vars mgfc_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mgfc_walk.
  Qed.

  Lemma mfd_row : call_pres lp bm NoA MWF mario._mario_facing_downhill.
  Proof.
    apply (call_pres_of_wwalk mario.prog mario._mario_facing_downhill
             mario.f_mario_facing_downhill nil nil nil nil LO_mario
             mfd_pin mfd_vars mfd_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
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
             nil nil
             LO_mario smam_pin smam_vars smam_params smam_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact mov_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smam_walk.
  Qed.

  (* ---- the AIRBORNE row, PROVED: five chase temps, the tshort
     faceAngle idx stores, the wact-censused rawData value, and the
     nullary mario_step callee under its two plain Mario-head leaves. *)
  Lemma gayvfj_row :
    call_pres lp bm NoA MWF mario._get_additive_y_vel_for_jumps.
  Proof.
    apply (call_pres_of_wwalk0 mario_step.prog
             mario._get_additive_y_vel_for_jumps
             mario_step.f_get_additive_y_vel_for_jumps nil nil nil nil
             LO_mario_step gayvfj_pin gayvfj_vars gayvfj_params).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact gayvfj_walk.
  Qed.

  Lemma smyv_ids_rows : forall fid, mem_id fid smyv_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold smyv_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact gayvfj_row | ].
    discriminate H.
  Qed.

  Lemma smyv_row :
    call_pres lp bm NoA MWF mario._set_mario_y_vel_based_on_fspeed.
  Proof.
    apply (call_pres_of_wwalk mario.prog
             mario._set_mario_y_vel_based_on_fspeed
             mario.f_set_mario_y_vel_based_on_fspeed smyv_ids nil nil nil
             LO_mario smyv_pin smyv_vars smyv_params_ok).
    - exact smyv_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smyv_walk.
  Qed.

  Lemma air_ids_rows : forall fid, mem_id fid air_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smyv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact msfv_row | ].
    discriminate H.
  Qed.

  Lemma smaa_row :
    call_pres_act lp bm NoA MWF mario._set_mario_action_airborne.
  Proof.
    apply (call_pres_act_of_wwalk mario.prog _
             mario.f_set_mario_action_airborne wact_air air_ids nil
             air_cact nil nil
             LO_mario smaa_pin smaa_vars smaa_params smaa_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact air_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smaa_walk.
  Qed.

  Lemma smact_wids_rows : forall fid, mem_id fid smact_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold smact_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smam_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smaa_row | ].
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
             wact_smact nil smact_wids nil nil nil
             LO_mario smact_pin smact_vars smact_params smact_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - exact smact_wids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smact_walk.
  Qed.

End ActWriterRows.
