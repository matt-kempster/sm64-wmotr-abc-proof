(* ====================================================================== *)
(* CensusV2 -- the PER-BODY census + temp-table for the engine-v2 lp       *)
(* discharge (ActionValueFrame.exec_funcall_reach_value_v2).               *)
(*                                                                         *)
(* The engine's TI and C are indexed by an opaque per-body census index:   *)
(* here the index is `body_census`, a record naming the body's Mario       *)
(* param and ITS OWN gate/dispatch temps. clightgen reuses temp idents      *)
(* (_t'N is the same positive in every body), so the tables MUST be        *)
(* per-body -- a global table would collide.                               *)
(*                                                                         *)
(* TI_of: the temp-table invariant. Three families of facts:               *)
(*  - the Mario param holds EXACTLY (bm,0) (established at entry from the   *)
(*    exact marg_ok; preserved because the census forbids Sset to it);      *)
(*  - an input-A-gate temp's Vint value has bit 1 clear (established at     *)
(*    its defining Sset from input_a_clear; the census forces every Sset    *)
(*    to a tabled gate temp to be the canonical m->input load);             *)
(*  - a dispatch temp's Vint value satisfies Q (= not_tainted at the        *)
(*    consumer; established from action_sat at the m->action load).         *)
(*                                                                         *)
(* chk: the boolean per-statement census (reflexivity-checkable per body).  *)
(*  - the if rule EXEMPTS the THEN branch of a censused input A-gate        *)
(*    (engine HCif + the gate temp's TI fact kill it semantically);          *)
(*  - the switch rule on a censused dispatch temp only requires the         *)
(*    NON-T-labeled suffixes (engine HCsw + action_sat kill the T arms);     *)
(*    ordinary switches require EVERY suffix (chk_all_ls);                   *)
(*  - the Ssequence rule is break-aware: the tail census may be waived      *)
(*    when the head provably never completes normally (dispatch arms end    *)
(*    in break; the textually-following dead arms never run);               *)
(*  - Sassign passes the store classes of store_class (window stores to     *)
(*    bm, the A-clear input store, whitelisted globals, non-pointer SafeB   *)
(*    chase stores); Scall requires a TABLED callee (an Evar at Tfunction   *)
(*    type whose ident is on mptr_callees with the Mario-ptr head arg, or   *)
(*    on exempt_callees) and an optid off the body's temp tables;           *)
(*    Sbuiltin stays false (no censused body uses builtins).                *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario level_update mario_step mario_actions_submerged.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.

Import ListNotations.
Local Open Scope Z_scope.

(* ====================================================================== *)
(* The per-body census record.                                             *)
(* ====================================================================== *)

Record body_census : Type := {
  bc_mptr    : ident;       (* the body's MarioState* parameter *)
  bc_gates   : list ident;  (* THIS body's input-A-gate temps *)
  bc_disp    : list ident;  (* THIS body's action-dispatch temps *)
  bc_globals : list ident;  (* the globals THIS body stores (class G) or
                               reads as census-tracked loads (gMarioState) *)
  bc_gms     : list ident;  (* temps Sset from the gMarioState global --
                               pinned to (bm,0) like the mptr row *)
  bc_chase   : list ident   (* chase-pointer temps (m->marioObj etc.):
                               their Vptr values land in SafeB blocks *)
}.

Definition mem_id (t : ident) (l : list ident) : bool :=
  existsb (Pos.eqb t) l.

(* ====================================================================== *)
(* The temp-table invariant.                                               *)
(* ====================================================================== *)

(* The mptr fact is Vptr-CONDITIONAL (not "the value IS (bm,0)"): marg_ok's
   non-pointer branch is vacuous, so entry seeding from the exact marg must
   tolerate a (semantically impossible, body-refuted) non-pointer arg.  Every
   consumer extracts a Vptr from the execution first (the body's own deref),
   then pins it here -- so nothing is lost.
   The 4th row is the ENV row (the engine threads e through TI): the body's
   stored globals are not shadowed by locals.  e is constant per body, so
   this row carries no re-establishment obligations -- it is seeded at entry
   (alloc_variables domain) and passed through verbatim.
   The DISP row is value-UNCONDITIONAL (Vundef-or-Q-Vint, not Vint=>Q):
   chase stores of action mirrors (`bodyState->action = t` with t a disp
   temp) must KNOW the stored value is a non-pointer, which the conditional
   form cannot supply.  Entry seeds the Vundef disjunct; the action load
   seeds the Vint one (HactVint: the action cell never holds a pointer).
   The GMS row pins gMarioState-loaded temps to (bm,0) exactly like the
   mptr row (HPgms, CONDITIONAL: if the gMarioState cell holds a pointer
   it is (bm,0) -- the load evidence comes from the Sset execution).  The CHASE row sends a chase temp's Vptr value
   into SafeB -- an abstract block predicate the consumer instantiates
   ("not bm, not the controller block, MWF tolerates stores there");
   seeded at the canonical chase loads (HchaseRoot / HchaseStep). *)
Definition TI_of (Q : int -> Prop) (bm : block) (SafeB : block -> Prop)
    (bc : body_census) (e : env) (le : temp_env) : Prop :=
  (forall b o, le ! (bc_mptr bc) = Some (Vptr b o) ->
     b = bm /\ o = Ptrofs.zero) /\
  (forall t, mem_id t (bc_gates bc) = true ->
     forall vi, le ! t = Some (Vint vi) ->
       Int.and vi (Int.repr 2) = Int.zero) /\
  (forall t, mem_id t (bc_disp bc) = true ->
     forall v, le ! t = Some v ->
       v = Vundef \/ exists vi, v = Vint vi /\ Q vi) /\
  (forall gid, mem_id gid (bc_globals bc) = true -> e ! gid = None) /\
  (forall t, mem_id t (bc_gms bc) = true ->
     forall b o, le ! t = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
  (forall t, mem_id t (bc_chase bc) = true ->
     forall b o, le ! t = Some (Vptr b o) -> SafeB b).

(* ====================================================================== *)
(* Shape detectors -- EXACT (type_eq-pinned) so the AGates eval bricks      *)
(* apply syntactically. The canonical clightgen shapes:                     *)
(*   input load:  (Efield (Ederef (Etempvar m (tptr MarioState)) MarioState) *)
(*                 _input tushort)                                           *)
(*   action load: ... _action tuint                                          *)
(*   gate guard:  (Ebinop Oand (Etempvar t tushort) (Econst_int 2 tint) tint)*)
(* ====================================================================== *)

Definition tyMS : type := Tstruct mario._MarioState noattr.

Definition is_input_load_x (mptr : ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      Pos.eqb p mptr && Pos.eqb fld mario._input
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && proj_sumbool (type_eq fty tushort)
  | _ => false
  end.

Definition is_action_load_x (mptr : ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      Pos.eqb p mptr && Pos.eqb fld mario._action
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && proj_sumbool (type_eq fty tuint)
  | _ => false
  end.

Lemma is_input_load_x_shape :
  forall mptr a, is_input_load_x mptr a = true ->
    a = Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) mario._input tushort.
Proof.
  intros mptr a H. destruct a; try discriminate H.
  destruct a; try discriminate H.
  destruct a; try discriminate H.
  unfold is_input_load_x in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hp : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in Hp
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  subst. reflexivity.
Qed.

Lemma is_action_load_x_shape :
  forall mptr a, is_action_load_x mptr a = true ->
    a = Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) mario._action tuint.
Proof.
  intros mptr a H. destruct a; try discriminate H.
  destruct a; try discriminate H.
  destruct a; try discriminate H.
  unfold is_action_load_x in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hp : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in Hp
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  subst. reflexivity.
Qed.

(* the input-A-gate guard, returning the gate temp on an exact match. *)
Definition input_guard_temp (a : expr) : option ident :=
  match a with
  | Ebinop Oand (Etempvar t ty1) (Econst_int c ty2) ty3 =>
      if Int.eq c (Int.repr 2)
         && proj_sumbool (type_eq ty1 tushort)
         && proj_sumbool (type_eq ty2 tint)
         && proj_sumbool (type_eq ty3 tint)
      then Some t else None
  | _ => None
  end.

Lemma input_guard_temp_shape :
  forall a t, input_guard_temp a = Some t ->
    a = Ebinop Oand (Etempvar t tushort)
          (Econst_int (Int.repr 2) tint) tint.
Proof.
  intros a t H. destruct a; try discriminate H.
  destruct b; try discriminate H.
  destruct a1; try discriminate H.
  destruct a2; try discriminate H.
  unfold input_guard_temp in H.
  match type of H with (if ?cond then _ else _) = _ =>
    destruct cond eqn:Hc; [ | discriminate H ] end.
  inv H.
  repeat (apply andb_true_iff in Hc; destruct Hc as [Hc ?]).
  repeat match goal with
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  apply Int.same_if_eq in Hc. subst. reflexivity.
Qed.

(* the dispatch scrutinee, returning the dispatch temp on an exact match. *)
Definition disp_scrut_temp (a : expr) : option ident :=
  match a with
  | Etempvar t ty =>
      if proj_sumbool (type_eq ty tuint) then Some t else None
  | _ => None
  end.

Lemma disp_scrut_temp_shape :
  forall a t, disp_scrut_temp a = Some t -> a = Etempvar t tuint.
Proof.
  intros a t H. destruct a; try discriminate H. unfold disp_scrut_temp in H.
  match type of H with (if ?cond then _ else _) = _ =>
    destruct cond eqn:Hc; [ | discriminate H ] end.
  inv H.
  apply proj_sumbool_true in Hc. subst. reflexivity.
Qed.

Definition gate_if (bc : body_census) (g : expr) : bool :=
  match input_guard_temp g with
  | Some t => mem_id t (bc_gates bc)
  | None => false
  end.

Definition disp_switch (bc : body_census) (a : expr) : bool :=
  match disp_scrut_temp a with
  | Some t => mem_id t (bc_disp bc)
  | None => false
  end.

(* ====================================================================== *)
(* Chase-pointer machinery.                                                *)
(*                                                                         *)
(* chain_root_e: the syntactic "offset chain" check -- an expression that   *)
(* evaluates (when it yields a pointer) to an address INSIDE the block of   *)
(* its root pointer temp.  Every step is address arithmetic: Oadd with a   *)
(* pointer/array left operand, Efield/Ederef at aggregate (By_reference /  *)
(* By_copy) type -- never a By_value load, which would CHASE to another     *)
(* block.  chain_root_l is the lvalue-position variant (the store target). *)
(* ====================================================================== *)

Definition by_addr (ty : type) : bool :=
  match access_mode ty with
  | By_reference | By_copy => true
  | _ => false
  end.

Definition ptrish (ty : type) : bool :=
  match ty with Tpointer _ _ | Tarray _ _ _ => true | _ => false end.

Definition is_ptr_ty (ty : type) : bool :=
  match ty with Tpointer _ _ => true | _ => false end.

Fixpoint chain_root_e (a : expr) : option ident :=
  match a with
  | Etempvar t (Tpointer _ _) => Some t
  | Ebinop Oadd a1 _ _ => if ptrish (typeof a1) then chain_root_e a1 else None
  | Efield a' _ ty => if by_addr ty then chain_root_e a' else None
  | Ederef a' ty => if by_addr ty then chain_root_e a' else None
  | _ => None
  end.

Definition chain_root_l (a : expr) : option ident :=
  match a with
  | Ederef a' _ => chain_root_e a'
  | Efield a' _ _ => chain_root_e a'
  | _ => None
  end.

(* the canonical chase ROOT loads: the MarioState pointer fields the
   frame-reached bodies chase-store through.  heldObj/usedObj/riddenObj
   (the held-object trio, interaction.prog) and animList (the anim DMA
   table, set_mario_animation) joined for the object-family leaves. *)
Definition chase_root_fields : list ident :=
  mario._marioObj :: mario._marioBodyState :: mario._statusForCamera
    :: mario._heldObj :: mario._usedObj :: mario._riddenObj
    :: mario._animList :: mario._interactObj :: nil.

(* `t = gMarioState` -- a By_value load of the global Mario pointer.  The
   bc_globals membership requirement puts the symbol under TI's env row, so
   the eval is forced through eval_Evar_global. *)
Definition is_gms_load (bc : body_census) (a : expr) : bool :=
  match a with
  | Evar gid gty =>
      Pos.eqb gid mario._gMarioState
      && mem_id gid (bc_globals bc)
      && proj_sumbool (type_eq gty (tptr tyMS))
  | _ => false
  end.

(* `t = m->marioObj` (etc.) -- base is the mptr param OR a gms temp. *)
Definition is_chase_root_load (bc : body_census) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      (Pos.eqb p (bc_mptr bc) || mem_id p (bc_gms bc))
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && mem_id fld chase_root_fields
      && is_ptr_ty fty
  | _ => false
  end.

(* `t = o->header.gfx.throwMatrix` -- a By_value pointer load whose base
   chain is rooted at an already-tabled chase temp. *)
Definition is_chase_step_load (bc : body_census) (a : expr) : bool :=
  match a with
  | Efield a' _ fty =>
      is_ptr_ty fty
      && match chain_root_e a' with
         | Some t => mem_id t (bc_chase bc)
         | None => false
         end
  | _ => false
  end.

Lemma is_gms_load_shape :
  forall bc a, is_gms_load bc a = true ->
    a = Evar mario._gMarioState (tptr tyMS) /\
    mem_id mario._gMarioState (bc_globals bc) = true.
Proof.
  intros bc a H.
  destruct a as [ | | | | gid gty | | | | | | | | | ]; try discriminate H.
  unfold is_gms_load in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hp : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in Hp
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  subst. auto.
Qed.

Lemma is_chase_root_load_shape :
  forall bc a, is_chase_root_load bc a = true ->
    exists p fld fty,
      a = Efield (Ederef (Etempvar p (tptr tyMS)) tyMS) fld fty /\
      (p = bc_mptr bc \/ mem_id p (bc_gms bc) = true) /\
      mem_id fld chase_root_fields = true /\
      is_ptr_ty fty = true.
Proof.
  intros bc a H. destruct a; try discriminate H.
  destruct a; try discriminate H.
  destruct a; try discriminate H.
  unfold is_chase_root_load in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  match goal with Ho : (Pos.eqb ?p _ || _)%bool = true |- _ =>
    apply orb_true_iff in Ho;
    destruct Ho as [Ho | Ho]; [ apply Pos.eqb_eq in Ho | ] end;
  repeat match goal with
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end;
  subst; do 3 eexists; eauto 7.
Qed.

Lemma is_chase_step_load_shape :
  forall bc a, is_chase_step_load bc a = true ->
    exists a' fld fty t,
      a = Efield a' fld fty /\
      is_ptr_ty fty = true /\
      chain_root_e a' = Some t /\
      mem_id t (bc_chase bc) = true.
Proof.
  intros bc a H. destruct a; try discriminate H.
  unfold is_chase_step_load in H.
  apply andb_true_iff in H as [Hty Hr].
  destruct (chain_root_e a) as [t0|] eqn:Hc; [ | discriminate Hr ].
  do 4 eexists; eauto.
Qed.

(* the eight root fields all have a concrete (vm-checked) MarioState offset *)
Lemma chase_root_field_offset :
  forall fld, mem_id fld chase_root_fields = true ->
    exists delta,
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full).
Proof.
  intros fld H.
  change ((Pos.eqb fld mario._marioObj
           || (Pos.eqb fld mario._marioBodyState
               || (Pos.eqb fld mario._statusForCamera
                   || (Pos.eqb fld mario._heldObj
                       || (Pos.eqb fld mario._usedObj
                           || (Pos.eqb fld mario._riddenObj
                               || (Pos.eqb fld mario._animList
                                   || (Pos.eqb fld mario._interactObj
                                       || false))))))))%bool = true)
    in H.
  repeat (apply orb_true_iff in H; destruct H as [H | H]);
    try discriminate H; apply Pos.eqb_eq in H; subst fld.
  - exists 136. vm_compute. reflexivity.
  - exists 152. vm_compute. reflexivity.
  - exists 148. vm_compute. reflexivity.
  - exists 124. vm_compute. reflexivity.
  - exists 128. vm_compute. reflexivity.
  - exists 132. vm_compute. reflexivity.
  - exists 160. vm_compute. reflexivity.
  - exists 120. vm_compute. reflexivity.
Qed.

Lemma is_ptr_ty_access :
  forall ty, is_ptr_ty ty = true -> access_mode ty = By_value Mptr.
Proof. intros ty H; destruct ty; try discriminate H; reflexivity. Qed.

(* THE CHAIN BRICK: a successful pointer-valued evaluation of an offset
   chain lands in the block its root temp holds.  Structural induction on
   the expression; each step preserves the block (aggregate deref_loc hands
   back the address; Oadd on a pointer-ish operand shifts the offset only). *)
(* a pointer-valued Oadd with a pointer-ish left operand got the block
   from its left operand *)
Lemma sem_add_ptrish_block :
  forall cenv v1 t1 v2 t2 m b o,
    ptrish t1 = true ->
    sem_binary_operation cenv Oadd v1 t1 v2 t2 m = Some (Vptr b o) ->
    exists o1, v1 = Vptr b o1.
Proof.
  intros cenv v1 t1 v2 t2 m b o Hp Hsem.
  unfold sem_binary_operation, sem_add in Hsem.
  destruct (classify_add t1 t2) eqn:Hca.
  - (* pi *)
    unfold sem_add_ptr_int in Hsem.
    destruct v1; destruct v2; try discriminate Hsem;
      try (destruct Archi.ptr64; discriminate Hsem).
    inv Hsem. eauto.
  - (* pl *)
    unfold sem_add_ptr_long in Hsem.
    destruct v1; destruct v2; try discriminate Hsem;
      try (destruct Archi.ptr64; discriminate Hsem).
    inv Hsem. eauto.
  - (* ip: impossible, t1 is pointer-ish *)
    exfalso. unfold classify_add in Hca.
    destruct t1; try discriminate Hp; cbn in Hca;
      destruct (typeconv t2); discriminate Hca.
  - (* il: impossible, t1 is pointer-ish *)
    exfalso. unfold classify_add in Hca.
    destruct t1; try discriminate Hp; cbn in Hca;
      destruct (typeconv t2); discriminate Hca.
  - (* default: sem_binarith never yields Vptr *)
    exfalso. unfold sem_binarith in Hsem.
    destruct (sem_cast v1 t1 _ m); try discriminate Hsem.
    destruct (sem_cast v2 t2 _ m); try discriminate Hsem.
    destruct (classify_binarith t1 t2); cbn in Hsem;
      repeat match type of Hsem with
             | (match ?x with _ => _ end) = _ =>
                 destruct x; try discriminate Hsem
             end;
      try discriminate Hsem.
Qed.

Lemma chain_root_e_block :
  forall ge e le m a t b o,
    chain_root_e a = Some t ->
    eval_expr ge e le m a (Vptr b o) ->
    exists o0, le ! t = Some (Vptr b o0).
Proof.
  intros ge e le m a. induction a; intros troot vb vo Hc Hev; try discriminate Hc.
  - (* Etempvar *)
    cbn in Hc. destruct t; try discriminate Hc. inv Hc.
    apply eval_expr_Etempvar_val in Hev. eauto.
  - (* Ederef at aggregate type *)
    cbn in Hc. destruct (by_addr t) eqn:Hba; [ | discriminate Hc ].
    apply eval_expr_Ederef_load in Hev
      as (loc & ofs & bf & Hlv & Hderef).
    apply deref_loc_aggregate_eq in Hderef as [E1 E2].
    2:{ unfold by_addr in Hba.
        destruct (access_mode t) eqn:Hac; try discriminate Hba; auto. }
    subst loc ofs.
    apply eval_lvalue_Ederef_base in Hlv.
    exact (IHa _ _ _ Hc Hlv).
  - (* Ebinop Oadd with pointer-ish left operand *)
    cbn in Hc. destruct b; try discriminate Hc.
    destruct (ptrish (typeof a1)) eqn:Hp; [ | discriminate Hc ].
    inv Hev.
    2:{ match goal with
        Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end. }
    match goal with
    | Hsem : sem_binary_operation _ Oadd ?v1 _ ?v2 _ _ = Some _,
      Hev1 : eval_expr _ _ _ _ a1 ?v1 |- _ =>
        destruct (sem_add_ptrish_block _ _ _ _ _ _ _ _ Hp Hsem)
          as (o1 & ->);
        exact (IHa1 _ _ _ Hc Hev1)
    end.
  - (* Efield at aggregate type *)
    cbn in Hc. destruct (by_addr t) eqn:Hba; [ | discriminate Hc ].
    apply eval_expr_Efield_load in Hev
      as (loc & ofs & bf & Hlv & Hderef).
    apply deref_loc_aggregate_eq in Hderef as [E1 E2].
    2:{ unfold by_addr in Hba.
        destruct (access_mode t) eqn:Hac; try discriminate Hba; auto. }
    subst loc ofs.
    apply eval_lvalue_Efield_base in Hlv as (o0 & Hbase).
    exact (IHa _ _ _ Hc Hbase).
Qed.

Lemma chain_root_l_block :
  forall ge e le m a t loc ofs bf,
    chain_root_l a = Some t ->
    eval_lvalue ge e le m a loc ofs bf ->
    exists o0, le ! t = Some (Vptr loc o0).
Proof.
  intros ge e le m a t loc ofs bf Hc Hlv.
  destruct a; try discriminate Hc; cbn in Hc.
  - (* Ederef *)
    apply eval_lvalue_Ederef_base in Hlv.
    exact (chain_root_e_block _ _ _ _ _ _ _ _ Hc Hlv).
  - (* Efield *)
    apply eval_lvalue_Efield_base in Hlv as (o0 & Hbase).
    exact (chain_root_e_block _ _ _ _ _ _ _ _ Hc Hbase).
Qed.

(* ---- the cast bricks: what a censused chase store can put in memory ----
   A cast TO a small-int/float scalar never produces a pointer; a cast OF
   a Vint never produces a pointer; a successful cast of Vundef is Vundef
   (only the void cast passes it through).  These make the chase-store's
   written value provably non-Vptr, which is exactly what keeps the
   consumer MWF's pointer-load-conditional rows store-stable. *)
Definition nonptr_scalar (ty : type) : bool :=
  match ty with
  | Tint I8 _ _ | Tint I16 _ _ | Tint IBool _ _ => true
  | Tfloat _ _ => true
  | _ => false
  end.

Lemma sem_cast_to_nonptr_scalar :
  forall v2 ty2 ty m v,
    nonptr_scalar ty = true ->
    sem_cast v2 ty2 ty m = Some v ->
    forall bb oo, v <> Vptr bb oo.
Proof.
  intros v2 ty2 ty m v Hnp Hcast bb oo ->.
  unfold sem_cast in Hcast.
  destruct (classify_cast ty2 ty) eqn:Hcc;
    try (destruct ty as [ | sz sg at1 | sg at1 | fs at1 | | | | | ];
         try destruct sz; try destruct fs; try discriminate Hnp;
         destruct ty2 as [ | sz2 sg2 at2 | sg2 at2 | fs2 at2 | | | | | ];
         try destruct sz2; try destruct fs2;
         cbn in Hcc; discriminate Hcc);
    destruct v2; try discriminate Hcast;
    repeat match type of Hcast with
           | (if ?c then _ else _) = _ => destruct c; try discriminate Hcast
           | (match ?x with _ => _ end) = _ =>
               destruct x; try discriminate Hcast
           end;
    inv Hcast.
Qed.

Lemma sem_cast_vint_nonptr :
  forall vi ty2 ty m v,
    sem_cast (Vint vi) ty2 ty m = Some v ->
    forall bb oo, v <> Vptr bb oo.
Proof.
  intros vi ty2 ty m v Hcast bb oo ->.
  unfold sem_cast in Hcast.
  destruct (classify_cast ty2 ty); try discriminate Hcast;
    repeat match type of Hcast with
           | (if ?c then _ else _) = _ => destruct c; try discriminate Hcast
           | (match ?x with _ => _ end) = _ =>
               destruct x; try discriminate Hcast
           end;
    inv Hcast.
Qed.

Lemma sem_cast_vundef_inv :
  forall ty2 ty m v,
    sem_cast Vundef ty2 ty m = Some v -> v = Vundef.
Proof.
  intros ty2 ty m v Hcast.
  unfold sem_cast in Hcast.
  destruct (classify_cast ty2 ty); try discriminate Hcast;
    repeat match type of Hcast with
           | (if ?c then _ else _) = _ => destruct c; try discriminate Hcast
           | (match ?x with _ => _ end) = _ =>
               destruct x; try discriminate Hcast
           end;
    inv Hcast; reflexivity.
Qed.


(* ====================================================================== *)
(* The call census.  A censused call owes three things:                    *)
(*  - its result temp (if any) is NOT tabled (else TI breaks);             *)
(*  - marg: EITHER the head argument is the body's own Mario param          *)
(*    (class M -- TI pins its value to (bm,0), so the callee's marg_ok      *)
(*    follows), OR the callee ident is on the exempt whitelist (class E --  *)
(*    the lp definition behind that symbol is marg_exempt: its first        *)
(*    param is not MarioState*, so no marg obligation exists.  Per-symbol,  *)
(*    this is a RESIDUAL the consumer carries: provable via linkorder for   *)
(*    mario.prog-internal callees (e.g. vec3f_find_ceil), and from the      *)
(*    callee TU's generated AST once that TU enters the pipeline (e.g.      *)
(*    find_floor's first param is f32).                                     *)
(* The whitelist below is exactly the callee set appearing in the 17       *)
(* frame-reached internal bodies (docs/reachable-internal-graph.md) with    *)
(* a non-mptr head argument.                                                *)
(* ====================================================================== *)

(* NB (satisfiability): _level_trigger_warp and _stub_mario_step_1 are NOT
   on this list -- both take MarioState* as their FIRST param (their mario.prog
   External declarations carry tptr (Tstruct _MarioState)), so whitelisting
   them would make the consumer's WL_exempt residual UNSATISFIABLE once lp
   resolves them to their real Internal bodies. Their call sites pass the
   census via class M instead (their head argument IS the Mario param). *)
Definition exempt_callees : list ident :=
  mario._sqrtf :: mario._atan2s :: mario._print_text_fmt_int ::
  mario._set_camera_mode :: mario._vec3f_set :: mario._stop_cap_music ::
  mario._fadeout_cap_music :: mario._f32_find_wall_collision ::
  mario._find_floor :: mario._vec3f_copy :: mario._vec3f_find_ceil ::
  mario._find_ceil :: mario._find_poison_gas_level ::
  mario._find_water_level ::
  mario._play_sound :: mario._vec3s_copy :: nil.

(* the class-M callee whitelist: every callee ident a censused body calls
   WITH ITS MARIO PARAM as the head argument. The first eight are mario.prog
   INTERNALS (linkorder pins their lp resolution to the censused/bridged
   bodies); the last two are mario.prog Externals taking MarioState* (their
   lp resolutions are per-symbol residuals on the consumer's rest surface). *)
Definition mptr_callees : list ident :=
  mario._update_mario_button_inputs ::
  mario._update_mario_joystick_inputs ::
  mario._update_mario_geometry_inputs ::
  mario._debug_print_speed_action_normal ::
  mario._mario_get_terrain_sound_addend ::
  mario._mario_floor_is_slippery ::
  mario._mario_get_floor_class ::
  mario._update_and_return_cap_flags ::
  mario._stub_mario_step_1 :: mario._level_trigger_warp :: nil.

Definition call_optid_ok (bc : body_census) (optid : option ident) : bool :=
  match optid with
  | None => true
  | Some rid =>
      negb (Pos.eqb rid (bc_mptr bc))
      && negb (mem_id rid (bc_gates bc))
      && negb (mem_id rid (bc_disp bc))
      && negb (mem_id rid (bc_gms bc))
      && negb (mem_id rid (bc_chase bc))
  end.

Definition call_head_is_mptr (bc : body_census) (al : list expr) : bool :=
  match al with
  | Etempvar p pty :: _ =>
      Pos.eqb p (bc_mptr bc) && proj_sumbool (type_eq pty (tptr tyMS))
  | _ => false
  end.

(* both callee checks pin the callee to a FUNCTION-typed Evar of a TABLED
   ident: with the body's empty env (fn_vars = nil) the eval is forced
   through eval_Evar_global + deref_loc_reference, so the consumer can
   resolve the call per symbol (Hcall_resolves). *)
Definition callee_in_mptr (a : expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) => mem_id fid mptr_callees
  | _ => false
  end.

Definition call_callee_exempt (a : expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) => mem_id fid exempt_callees
  | _ => false
  end.

Lemma callee_in_mptr_shape :
  forall a, callee_in_mptr a = true ->
    exists fid tyl rty cc,
      a = Evar fid (Tfunction tyl rty cc) /\
      mem_id fid mptr_callees = true.
Proof.
  intros a H. destruct a; try discriminate H.
  destruct t; try discriminate H.
  do 4 eexists. split; [ reflexivity | exact H ].
Qed.

Lemma call_callee_exempt_shape :
  forall a, call_callee_exempt a = true ->
    exists fid tyl rty cc,
      a = Evar fid (Tfunction tyl rty cc) /\
      mem_id fid exempt_callees = true.
Proof.
  intros a H. destruct a; try discriminate H.
  destruct t; try discriminate H.
  do 4 eexists. split; [ reflexivity | exact H ].
Qed.

(* ====================================================================== *)
(* The store census, class F: a direct `m->field` store whose byte window  *)
(* avoids ALL the protected cells --                                       *)
(*   [2,4)     m->input           (input_a_clear's cell)                   *)
(*   [12,16)   m->action          (action_sat's cell)                      *)
(*   [124,128) m->heldObj         (chase root)                             *)
(*   [128,132) m->usedObj         (chase root)                             *)
(*   [132,136) m->riddenObj       (chase root)                             *)
(*   [136,140) m->marioObj        (chase root)                             *)
(*   [148,152) m->statusForCamera (chase root)                             *)
(*   [152,156) m->marioBodyState  (chase root)                             *)
(*   [156,160) m->controller      (ctl_a_clear's chase root)               *)
(*   [160,164) m->animList        (chase root)                             *)
(* heldObj..marioObj are contiguous: one [124,140) window conjunct;        *)
(* statusForCamera..animList likewise: one [148,164) window conjunct.      *)
(* The offset is computed in mario.prog's OWN cenv (cheap, concrete) and   *)
(* transferred to lp by linkorder (linkorder_field_offset_agree).  The     *)
(* bounds conjunct makes Ptrofs.unsigned (Ptrofs.repr delta) = delta.      *)
(* The rvalue is UNCONSTRAINED: whatever is written lands outside every    *)
(* protected window.  (m->input or-updates and off-bm stores are LATER     *)
(* classes.)                                                               *)
(* ====================================================================== *)

Definition store_window_ok (delta sz : Z) : bool :=
  (0 <? sz) && (0 <=? delta) && (delta + sz <=? Ptrofs.max_unsigned)
  && ((delta + sz <=? 2) || (4 <=? delta))
  && ((delta + sz <=? 12) || (16 <=? delta))
  && ((delta + sz <=? 120) || (140 <=? delta))
  && ((delta + sz <=? 148) || (164 <=? delta)).

(* the per-field geometry check, isolated so its soundness lemma has
   stable binder names. *)
Definition mfield_geom_chk (fld : ident) (fty : type) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (delta, Full) =>
      match access_mode fty with
      | By_value ch => store_window_ok delta (size_chunk ch)
      | _ => false
      end
  | _ => false
  end.

Lemma mfield_geom_chk_sound :
  forall fld fty, mfield_geom_chk fld fty = true ->
    exists delta ch,
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) /\
      access_mode fty = By_value ch /\
      store_window_ok delta (size_chunk ch) = true.
Proof.
  intros fld fty H. unfold mfield_geom_chk in H.
  destruct (field_offset (prog_comp_env mario.prog) fld mario_state_members)
    as [[delta bf]|] eqn:Hfo; try discriminate H.
  destruct bf; try discriminate H.
  destruct (access_mode fty) as [ch| | |] eqn:Hac; try discriminate H.
  exists delta, ch. auto.
Qed.

Definition safe_mfield_store (mptr : ident) (a1 : expr) : bool :=
  match a1 with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      Pos.eqb p mptr
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && mfield_geom_chk fld fty
  | _ => false
  end.

(* ---- store class I: the m->input A-clear write.  The clightgen idiom is
   `t = m->input; m->input = t | C` (or `m->input = 0`).  The or-temp is
   REQUIRED to be a TABLED GATE temp: the census's Sset rule then forces
   its only definition to be the canonical m->input load, and TI carries
   its bit-1-clear fact -- so the stored value provably keeps
   INPUT_A_PRESSED clear, and input_a_clear survives its own cell's
   update.  C itself must have bit 1 clear (checked by computation). ---- *)
Definition input_rhs_aclear (bc : body_census) (rhs : expr) : bool :=
  match rhs with
  | Econst_int c ty =>
      proj_sumbool (type_eq ty tint)
      && Int.eq (Int.and c (Int.repr 2)) Int.zero
  | Ebinop Oor (Etempvar t ty1) (Econst_int c ty2) ty3 =>
      mem_id t (bc_gates bc)
      && proj_sumbool (type_eq ty1 tushort)
      && proj_sumbool (type_eq ty2 tint)
      && proj_sumbool (type_eq ty3 tint)
      && Int.eq (Int.and c (Int.repr 2)) Int.zero
  | _ => false
  end.

Definition input_store_ok (bc : body_census) (a1 a2 : expr) : bool :=
  is_input_load_x (bc_mptr bc) a1 && input_rhs_aclear bc a2.

(* ---- store class G: a direct write to a whitelisted off-Mario GLOBAL.
   The body's bc_globals row of TI refutes local shadowing (the env row);
   the per-symbol residual (HG at the discharge) says the lp block behind
   the symbol is not bm and that MWF tolerates stores there -- provable
   once bm is grounded as gMarioStates' block (distinct global symbols get
   distinct blocks).  The rvalue is unconstrained. ---- *)
Definition stored_globals : list ident :=
  mario._gCameraMovementFlags ::
  (* the level_update warp-delay statics + saved-course global: the warp
     trigger writes all five (WarpSurface); each is a static data symbol
     whose block is bm/bc/SafeB-disjoint per Hglob_blk. *)
  level_update._sDelayedWarpOp ::
  level_update._sDelayedWarpArg ::
  level_update._sDelayedWarpTimer ::
  level_update._sSourceWarpNodeId ::
  level_update._gSavedCourseNum ::
  (* the special-floors statics (B7): the PSS slide flag (interaction),
     and the HUD timer pair written by level_control_timer. *)
  interaction._sPSSSlideStarted ::
  level_update._sTimerRunning ::
  level_update._gHudDisplay ::
  (* the mario_process_interactions statics (the Hpres_inter shell):
     four interaction.c static data bytes/halfwords written directly by
     the shell -- same Hglob_blk trust class as the rest. *)
  interaction._sDelayInvincTimer ::
  interaction._sInvulnerable ::
  interaction._sDisplayingDoorText ::
  interaction._sJustTeleported ::
  (* perform_ground_quarter_step's water-pseudo-floor patch (the pgqs
     special site, MarioStepSurface): the body stores the ADDRESS of the
     static Surface gWaterSurfacePseudoFloor into its stack-local _floor,
     reloads it, and stores floorHeight through it into the global's
     originOffset field -- a static data symbol in mario_step.prog /
     mario_actions_moving.prog, same Hglob_blk trust class as the rest. *)
  mario_step._gWaterSurfacePseudoFloor ::
  (* the swimming-strength static (mario_actions_submerged): the swimming
     leaves (act_breaststroke / act_swimming_end / act_flutter_kick) store
     sSwimStrength = MIN_SWIM_STRENGTH or sSwimStrength += 10 directly -- a
     static s16 data symbol, same Hglob_blk bm/bc/SafeB-disjoint trust class. *)
  mario_actions_submerged._sSwimStrength ::
  (* the bob-increment static (mario_actions_submerged): act_water_plunge stores
     sBobIncrement = 0 directly when the plunge resolves -- a static s16 data
     symbol, same Hglob_blk bm/bc/SafeB-disjoint trust class. *)
  mario_actions_submerged._sBobIncrement :: nil.

(* ---------------------------------------------------------------------- *)
(* The interaction-handler census (the Hpres_inter arc): the 28 DISTINCT   *)
(* functions whose addresses populate the sInteractionHandlers dispatch    *)
(* table (interact_bounce_top appears 3x among the 31 entries).  The       *)
(* MWFReal table row pins every handler-slot load to one of these          *)
(* symbols; the InterSurface indirect-call arm resolves them to their      *)
(* pinned internal bodies.                                                 *)
(* ---------------------------------------------------------------------- *)
Definition interaction_handler_ids : list ident :=
  interaction._interact_coin :: interaction._interact_water_ring
  :: interaction._interact_star_or_key :: interaction._interact_bbh_entrance
  :: interaction._interact_warp :: interaction._interact_warp_door
  :: interaction._interact_door :: interaction._interact_cannon_base
  :: interaction._interact_igloo_barrier :: interaction._interact_tornado
  :: interaction._interact_whirlpool :: interaction._interact_strong_wind
  :: interaction._interact_flame :: interaction._interact_snufit_bullet
  :: interaction._interact_clam_or_bubba :: interaction._interact_bully
  :: interaction._interact_shock :: interaction._interact_bounce_top
  :: interaction._interact_mr_blizzard :: interaction._interact_hit_from_below
  :: interaction._interact_damage :: interaction._interact_pole
  :: interaction._interact_hoot :: interaction._interact_breakable
  :: interaction._interact_koopa_shell :: interaction._interact_unknown_08
  :: interaction._interact_cap :: interaction._interact_grabbable
  :: interaction._interact_text :: nil.

(* NON-VACUITY pins: the census COVERS the real generated table (every
   Init_addrof in v_sInteractionHandlers is one of the 28), and every
   censused handler is an INTERNAL function of interaction.prog. *)
Example interaction_handler_ids_cover_table :
  forallb (fun ini =>
    match ini with
    | Init_addrof f _ => existsb (Pos.eqb f) interaction_handler_ids
    | Init_int32 _ => true
    | _ => false
    end) (gvar_init interaction.v_sInteractionHandlers) = true.
Proof. vm_compute. reflexivity. Qed.
Example interaction_handler_ids_internal :
  forallb (fun fid =>
    match (prog_defmap interaction.prog) ! fid with
    | Some (Gfun (Internal _)) => true
    | _ => false
    end) interaction_handler_ids = true.
Proof. vm_compute. reflexivity. Qed.

Definition global_store_ok (bc : body_census) (a1 : expr) : bool :=
  match a1 with
  | Evar gid gty =>
      mem_id gid (bc_globals bc)
      && mem_id gid stored_globals
      && match access_mode gty with By_value _ => true | _ => false end
  | _ => false
  end.

Lemma global_store_ok_shape :
  forall bc a1, global_store_ok bc a1 = true ->
    exists gid gty ch,
      a1 = Evar gid gty /\
      mem_id gid (bc_globals bc) = true /\
      mem_id gid stored_globals = true /\
      access_mode gty = By_value ch.
Proof.
  intros bc a1 H.
  destruct a1 as [ | | | | gid gty | | | | | | | | | ]; try discriminate H.
  unfold global_store_ok in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  match goal with
  | Ha : (match access_mode gty with _ => _ end) = true |- _ =>
      destruct (access_mode gty) as [ch| | |] eqn:Hac; try discriminate Ha
  end.
  exists gid, gty, ch. auto.
Qed.

(* ---- store class C: a store through a TABLED CHASE TEMP.  The lvalue is
   an offset chain rooted at the temp, so the written block is the temp's
   block -- SafeB by the TI chase row: off bm (action_sat survives) and
   MWF-tolerated (HMWFchase).  The written VALUE must be provably
   non-pointer (else it could plant a bogus pointer that a later chase
   load retrieves): float/small-int field types make ANY cast result
   non-Vptr; an I32 field additionally requires the rvalue be an int
   constant or a tabled disp temp (whose TI row is Vundef-or-Vint). ---- *)
Definition chase_rhs_ok (bc : body_census) (ty : type) (a2 : expr) : bool :=
  nonptr_scalar ty
  || match ty with
     | Tint I32 _ _ =>
         match a2 with
         | Econst_int _ _ => true
         | Etempvar t _ => mem_id t (bc_disp bc)
         | _ => false
         end
     | _ => false
     end.

Definition chase_store_ok (bc : body_census) (a1 a2 : expr) : bool :=
  match chain_root_l a1 with
  | Some t => mem_id t (bc_chase bc) && chase_rhs_ok bc (typeof a1) a2
  | None => false
  end.

Lemma input_rhs_aclear_shape :
  forall bc rhs, input_rhs_aclear bc rhs = true ->
    (exists c, rhs = Econst_int c tint /\
       Int.and c (Int.repr 2) = Int.zero) \/
    (exists t c,
       rhs = Ebinop Oor (Etempvar t tushort) (Econst_int c tint) tint /\
       mem_id t (bc_gates bc) = true /\
       Int.and c (Int.repr 2) = Int.zero).
Proof.
  intros bc rhs H.
  destruct rhs as [ c cty | | | | | | | | | op e1 e2 bty | | | | ];
    try discriminate H.
  - (* Econst_int *)
    unfold input_rhs_aclear in H.
    apply andb_true_iff in H as [Hty Hc].
    apply proj_sumbool_true in Hty. apply Int.same_if_eq in Hc. subst.
    left. eexists. split; [ reflexivity | assumption ].
  - (* Ebinop *)
    destruct op; try discriminate H.
    destruct e1 as [ | | | | | t1 t1ty | | | | | | | | ];
      try discriminate H.
    destruct e2 as [ c2 c2ty | | | | | | | | | | | | | ];
      try discriminate H.
    unfold input_rhs_aclear in H.
    repeat (apply andb_true_iff in H; destruct H as [H ?]).
    repeat match goal with
           | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
           | Hp : Int.eq _ Int.zero = true |- _ => apply Int.same_if_eq in Hp
           end.
    subst. right. do 2 eexists.
    split; [ reflexivity | split; assumption ].
Qed.

Lemma safe_mfield_store_shape :
  forall mptr a1, safe_mfield_store mptr a1 = true ->
    exists fld fty,
      a1 = Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) fld fty /\
      mfield_geom_chk fld fty = true.
Proof.
  intros mptr a1 H. destruct a1; try discriminate H.
  destruct a1; try discriminate H.
  destruct a1; try discriminate H.
  unfold safe_mfield_store in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hp : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in Hp
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  subst. do 2 eexists. split; [ reflexivity | assumption ].
Qed.

(* ====================================================================== *)
(* The census.                                                             *)
(*                                                                         *)
(* chk_ls    : the SELECTED-SUFFIX check -- mirrors chk over the            *)
(*             seq_of_labeled_statement concatenation (break-aware).        *)
(* chk_all_ls: the ordinary-switch census -- EVERY suffix is selectable,    *)
(*             so every suffix must pass chk_ls's head conjunct.            *)
(* chk_disp_ls: the dispatch census -- T-labeled suffixes are exempt        *)
(*             (action_sat not_tainted makes them unselectable).            *)
(* ====================================================================== *)

Fixpoint chk (bc : body_census) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn None => true
  | Sreturn (Some _) => true
  | Sset id a =>
      negb (Pos.eqb id (bc_mptr bc))
      && (negb (mem_id id (bc_gates bc)) || is_input_load_x (bc_mptr bc) a)
      && (negb (mem_id id (bc_disp bc)) || is_action_load_x (bc_mptr bc) a)
      && (negb (mem_id id (bc_gms bc)) || is_gms_load bc a)
      && (negb (mem_id id (bc_chase bc))
          || is_chase_root_load bc a || is_chase_step_load bc a)
  | Ssequence s1 s2 =>
      chk bc s1 && (chk bc s2 || ends_in_break s1)
  | Sifthenelse g s1 s2 =>
      if gate_if bc g then chk bc s2 else chk bc s1 && chk bc s2
  | Sloop s1 s2 => chk bc s1 && chk bc s2
  | Slabel _ s1 => chk bc s1
  | Sswitch a ls =>
      if disp_switch bc a then chk_disp_ls bc ls else chk_all_ls bc ls
  | Sassign a1 a2 =>
      safe_mfield_store (bc_mptr bc) a1 || input_store_ok bc a1 a2
      || global_store_ok bc a1 || chase_store_ok bc a1 a2
  | Scall optid a al =>
      call_optid_ok bc optid
      && (call_head_is_mptr bc al && callee_in_mptr a
          || call_callee_exempt a)
  | Sbuiltin _ _ _ _ => false
  | Sgoto _ => false
  end
with chk_ls (bc : body_census) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s rest => chk bc s && (chk_ls bc rest || ends_in_break s)
  end
with chk_all_ls (bc : body_census) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s rest =>
      (chk bc s && (chk_ls bc rest || ends_in_break s))
      && chk_all_ls bc rest
  end
with chk_disp_ls (bc : body_census) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons o s rest =>
      (match o with
       | Some c => if is_T_label c then true
                   else chk bc s && (chk_ls bc rest || ends_in_break s)
       | None => chk bc s && (chk_ls bc rest || ends_in_break s)
       end)
      && chk_disp_ls bc rest
  end.

(* chk over the seq_of concatenation IS chk_ls (definitional mirror). *)
Lemma chk_seq_of :
  forall bc ls, chk_ls bc ls = true ->
    chk bc (seq_of_labeled_statement ls) = true.
Proof.
  intros bc ls; induction ls as [| o s rest IH]; cbn; intros H.
  - reflexivity.
  - apply andb_true_iff in H as [Hs Hrest].
    apply andb_true_iff; split; [ exact Hs | ].
    apply orb_true_iff in Hrest as [Hr | Hb].
    + apply orb_true_iff; left. exact (IH Hr).
    + apply orb_true_iff; right. exact Hb.
Qed.

(* ---- ordinary switches: any selection is censused. ---- *)
Lemma chk_all_select_case :
  forall bc n ls res,
    chk_all_ls bc ls = true ->
    select_switch_case n ls = Some res ->
    chk_ls bc res = true.
Proof.
  intros bc n ls; induction ls as [| o s rest IH]; cbn; intros res Hd Hsel.
  - discriminate Hsel.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + destruct (zeq c n) as [E|NE].
      * inv Hsel. cbn. exact Hhead.
      * exact (IH res Hrest Hsel).
    + exact (IH res Hrest Hsel).
Qed.

Lemma chk_all_select_default :
  forall bc ls,
    chk_all_ls bc ls = true ->
    chk_ls bc (select_switch_default ls) = true.
Proof.
  intros bc ls; induction ls as [| o s rest IH]; cbn; intros Hd.
  - reflexivity.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + exact (IH Hrest).
    + cbn. exact Hhead.
Qed.

Lemma chk_all_select :
  forall bc n ls,
    chk_all_ls bc ls = true ->
    chk_ls bc (select_switch n ls) = true.
Proof.
  intros bc n ls Hd. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - exact (chk_all_select_case bc n ls l Hd E).
  - exact (chk_all_select_default bc ls Hd).
Qed.

(* ---- the dispatch: a non-T selection is censused. ---- *)
Lemma chk_disp_select_case :
  forall bc n ls res,
    chk_disp_ls bc ls = true ->
    is_T_label n = false ->
    select_switch_case n ls = Some res ->
    chk_ls bc res = true.
Proof.
  intros bc n ls; induction ls as [| o s rest IH]; cbn; intros res Hd Hn Hsel.
  - discriminate Hsel.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + destruct (zeq c n) as [E|NE].
      * inv Hsel. rewrite Hn in Hhead. cbn. exact Hhead.
      * exact (IH res Hrest Hn Hsel).
    + exact (IH res Hrest Hn Hsel).
Qed.

Lemma chk_disp_select_default :
  forall bc ls,
    chk_disp_ls bc ls = true ->
    chk_ls bc (select_switch_default ls) = true.
Proof.
  intros bc ls; induction ls as [| o s rest IH]; cbn; intros Hd.
  - reflexivity.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + exact (IH Hrest).
    + cbn. exact Hhead.
Qed.

Lemma chk_disp_select :
  forall bc n ls,
    chk_disp_ls bc ls = true ->
    is_T_label n = false ->
    chk_ls bc (select_switch n ls) = true.
Proof.
  intros bc n ls Hd Hn. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - exact (chk_disp_select_case bc n ls l Hd Hn E).
  - exact (chk_disp_select_default bc ls Hd).
Qed.

(* ====================================================================== *)
(* The engine-leaf discharges, over the abstract linked program.           *)
(* ====================================================================== *)

(* ---- HCseq1 / HCloop: pure projections. ---- *)
Lemma chk_seq1 :
  forall bc s1 s2, chk bc (Ssequence s1 s2) = true -> chk bc s1 = true.
Proof.
  intros bc s1 s2 H. cbn in H.
  apply andb_true_iff in H as [H1 _]. exact H1.
Qed.

Lemma chk_loop :
  forall bc s1 s2, chk bc (Sloop s1 s2) = true ->
    chk bc s1 = true /\ chk bc s2 = true.
Proof.
  intros bc s1 s2 H. cbn in H. apply andb_true_iff in H. exact H.
Qed.

(* sem_cast never CONSTRUCTS a pointer: a Vptr output is the input passed
   through identically (cast_case_pointer / cast_case_void / composites).
   This is what lets class-M call heads transfer TI's (bm,0) pin through
   the call-site cast regardless of the (unknown) signature type. *)
Lemma sem_cast_vptr_inv :
  forall v1 ty1 ty2 m b o,
    sem_cast v1 ty1 ty2 m = Some (Vptr b o) -> v1 = Vptr b o.
Proof.
  intros v1 ty1 ty2 m b o H.
  unfold sem_cast in H.
  destruct (classify_cast ty1 ty2); destruct v1; try discriminate H;
    repeat match type of H with
           | (if ?c then _ else _) = _ => destruct c; try discriminate H
           | (match ?x with _ => _ end) = _ => destruct x; try discriminate H
           end;
    inv H; reflexivity.
Qed.

Section CensusLeavesLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* The exempt-callee whitelist RESIDUAL: each whitelisted symbol's lp
     definition is marg_exempt -- its first param is not a MarioState
     pointer.  Per symbol: provable from linkorder for mario.prog
     internals; from the callee TU's generated AST for cross-TU symbols,
     once that TU enters the pipeline. *)
  Hypothesis WL_exempt :
    forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.

  (* ---- HCseq2: the tail census, given the head actually completed
     Out_normal -- a break-ended head refutes the premise. ---- *)
  Lemma chk_seq2 :
    forall bc e le m s1 s2 t1 le1 m1,
      chk bc (Ssequence s1 s2) = true ->
      exec_stmt function_entry2 (lp_ge lp) e le m s1 t1 le1 m1 Out_normal ->
      chk bc s2 = true.
  Proof.
    intros bc e le m s1 s2 t1 le1 m1 H Hexec. cbn in H.
    apply andb_true_iff in H as [_ H2].
    apply orb_true_iff in H2 as [H2 | Hb]; [ exact H2 | ].
    exfalso.
    exact (ends_in_break_not_normal lp _ _ _ _ _ _ _ _ Hb Hexec eq_refl).
  Qed.

  (* ---- HCif: the gate kill. At a censused input A-gate the guard
     provably evaluates to false (the gate temp's TI fact + the bit
     arithmetic), so only the ELSE census -- which is what chk carries --
     is ever demanded. Non-gate ifs carry both branches. ---- *)
  Lemma chk_if :
    forall Q bm SafeB bc e le m a s1 s2 v1 b,
      chk bc (Sifthenelse a s1 s2) = true ->
      TI_of Q bm SafeB bc e le ->
      eval_expr (lp_ge lp) e le m a v1 ->
      bool_val v1 (typeof a) m = Some b ->
      chk bc (if b then s1 else s2) = true.
  Proof.
    intros Q bm SafeB bc e le m a s1 s2 v1 b HC HTI Hev Hbv.
    change ((if gate_if bc a then chk bc s2 else chk bc s1 && chk bc s2)
            = true) in HC.
    (* destruct abstracts + reduces the occurrence in HC too *)
    destruct (gate_if bc a) eqn:Hg.
    - (* censused gate: THEN is dead.  HC : chk bc s2 = true *)
      unfold gate_if in Hg.
      destruct (input_guard_temp a) as [t|] eqn:Hgt; [ | discriminate Hg ].
      pose proof (input_guard_temp_shape _ _ Hgt) as Hshape. subst a.
      destruct (guard_temp_vint lp _ _ _ _ _ _ Hev) as (vi & Hlet & Hv1).
      destruct HTI as (_ & Hgate & _ & _ & _ & _).
      pose proof (Hgate t Hg vi Hlet) as Hclear.
      subst v1. cbn [typeof] in Hbv.
      pose proof (bool_val_and_zero _ _ _ _ Hclear Hbv) as Hb. subst b.
      exact HC.
    - (* ordinary if: both branches censused *)
      apply andb_true_iff in HC as [H1 H2]. destruct b; assumption.
  Qed.

  (* ---- HCsw: the dispatch kill. On a censused dispatch switch the
     scrutinee temp's TI fact (Q = not_tainted) means the selector never
     matches a T label, and the selected suffix is chk_disp_ls censused.
     Ordinary switches carry every suffix (chk_all_ls). ---- *)
  Lemma chk_sw :
    forall bm SafeB bc e le m a ls v n,
      chk bc (Sswitch a ls) = true ->
      TI_of not_tainted bm SafeB bc e le ->
      eval_expr (lp_ge lp) e le m a v ->
      sem_switch_arg v (typeof a) = Some n ->
      chk bc (seq_of_labeled_statement (select_switch n ls)) = true.
  Proof.
    intros bm SafeB bc e le m a ls v n HC HTI Hev Hsa.
    change ((if disp_switch bc a then chk_disp_ls bc ls else chk_all_ls bc ls)
            = true) in HC.
    (* destruct abstracts + reduces the occurrence in HC too *)
    destruct (disp_switch bc a) eqn:Hd.
    - (* censused dispatch.  HC : chk_disp_ls bc ls = true *)
      unfold disp_switch in Hd.
      destruct (disp_scrut_temp a) as [t|] eqn:Hdt; [ | discriminate Hd ].
      pose proof (disp_scrut_temp_shape _ _ Hdt) as Hshape. subst a.
      apply eval_expr_Etempvar_val in Hev.
      cbn [typeof] in Hsa.
      unfold sem_switch_arg in Hsa; cbn [classify_switch] in Hsa.
      destruct v; try discriminate Hsa. inv Hsa.
      destruct HTI as (_ & _ & Hdisp & _ & _ & _).
      destruct (Hdisp t Hd _ Hev) as [HU | (vi & Evi & Hnt)];
        [ discriminate HU | inv Evi ].
      apply chk_seq_of, (chk_disp_select bc _ _ HC).
      exact (not_tainted_not_T_label _ Hnt).
    - (* ordinary switch: every suffix censused *)
      apply chk_seq_of, (chk_all_select bc _ _ HC).
  Qed.

  (* ---- the m->field lvalue geometry over lp: the store target is the
     temp's block at temp-offset + the mario.prog-computed field offset.
     Mirrors eval_marioObj_off_bm_lp's first half (the genv-parametric
     inversion helpers + the two linkorder transfer bricks). ---- *)
  Lemma mfield_lvalue_geom_lp :
    forall e le m mid fld fty loc ofs bf delta b o,
      le ! mid = Some (Vptr b o) ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      eval_lvalue (lp_ge lp) e le m
        (Efield (Ederef (Etempvar mid (tptr tyMS)) tyMS) fld fty) loc ofs bf ->
      loc = b /\ ofs = Ptrofs.add o (Ptrofs.repr delta) /\ bf = Full.
  Proof.
    intros e le m mid fld fty loc ofs bf delta b o Hle Hfo Hlv.
    apply eval_lvalue_Efield_inv in Hlv
      as (o0 & id & att & co & delta' & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase
      as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?];
      [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    rewrite Hle in Hlvb. inv Hlvb.
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ];
      [ | cbn in Hty; discriminate ].
    cbn in Hty; inv Hty.
    change (genv_cenv (lp_ge lp)) with (prog_comp_env lp) in Hco, Hfo2.
    destruct mario_defines_MarioState as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState
                  co0 LO_mario Hmar) as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog fld (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite Hmm in Hfo. rewrite Hfo in Hfo2. inv Hfo2.
    auto.
  Qed.

  (* ---- HTI_set: the table maintenance. The census forbids Sset to the
     Mario param; an Sset to a tabled gate temp is the canonical input
     load (bit-1-clear under input_a_clear); to a tabled dispatch temp the
     canonical action load (Vundef-or-Q-Vint under HactVint + action_sat);
     to a tabled gms temp the gMarioState global load ((bm,0) under HPgms);
     to a tabled chase temp a canonical chase load (SafeB under
     HchaseRoot/HchaseStep). Everything else is gso. ---- *)
  Lemma chk_ti_set :
    forall (Q : int -> Prop) (MWF : mem -> Prop) bm (SafeB : block -> Prop)
           bc e le m id a v,
      (* HactVint: the action cell never holds a pointer *)
      (forall mm, MWF mm -> forall av, Mem.load Mint32 mm bm 12 = Some av ->
         av = Vundef \/ exists vi, av = Vint vi) ->
      (* HPgms: IF the gMarioState cell holds a pointer THEN it is (bm,0).
         CONDITIONAL on the load, not "exists gb, the load succeeds": a
         positive row would make MWF jointly unsatisfiable with the
         engine's free leaf (an adversarial free_list kills the load).
         The Sset execution supplies the load evidence, so the
         conditional form is all this proof ever needed. *)
      (forall mm gb b o, MWF mm ->
         Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
         Mem.loadv Mptr mm (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
         b = bm /\ o = Ptrofs.zero) ->
      (* HchaseRoot: the tabled MarioState chase cells hold SafeB pointers *)
      (forall fld delta mm b' o',
         mem_id fld chase_root_fields = true ->
         field_offset (prog_comp_env mario.prog) fld mario_state_members
           = OK (delta, Full) ->
         MWF mm ->
         Mem.loadv Mptr mm
           (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
           = Some (Vptr b' o') ->
         SafeB b') ->
      (* HchaseStep: pointer loads from SafeB blocks land in SafeB *)
      (forall mm b ofs b' o',
         MWF mm -> SafeB b ->
         Mem.loadv Mptr mm (Vptr b ofs) = Some (Vptr b' o') -> SafeB b') ->
      MWF m ->
      input_a_clear m bm ->
      action_sat Q m bm ->
      eval_expr (lp_ge lp) e le m a v ->
      TI_of Q bm SafeB bc e le ->
      chk bc (Sset id a) = true ->
      TI_of Q bm SafeB bc e (PTree.set id v le).
  Proof.
    intros Q MWF bm SafeB bc e le m id a v
           HactVint HPgms HchaseRoot HchaseStep HMWF Hinp Hsat Hev HTI HC.
    change ((negb (Pos.eqb id (bc_mptr bc))
             && (negb (mem_id id (bc_gates bc))
                 || is_input_load_x (bc_mptr bc) a)
             && (negb (mem_id id (bc_disp bc))
                 || is_action_load_x (bc_mptr bc) a)
             && (negb (mem_id id (bc_gms bc)) || is_gms_load bc a)
             && (negb (mem_id id (bc_chase bc))
                 || is_chase_root_load bc a || is_chase_step_load bc a))
            = true) in HC.
    apply andb_true_iff in HC as [HC Hchase_rule].
    apply andb_true_iff in HC as [HC Hgms_rule].
    apply andb_true_iff in HC as [HC Hdisp_rule].
    apply andb_true_iff in HC as [Hnm Hgate_rule].
    destruct HTI as (Hm & Hgate & Hdisp & Hglob & Hgms & Hch).
    refine (conj _ (conj _ (conj _ (conj Hglob (conj _ _))))).
    - (* the Mario param: never assigned (census) *)
      intros b o Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst id; rewrite Pos.eqb_refl in Hnm; discriminate Hnm).
      exact (Hm b o Hlk).
    - (* gate temps *)
      intros t Hmem vi Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hgate_rule. cbn [negb orb] in Hgate_rule.
        pose proof (is_input_load_x_shape _ _ Hgate_rule) as Hshape. subst a.
        destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev) as (pb & po & Hpm).
        destruct (Hm _ _ Hpm) as [E1 E2]. subst pb po.
        pose proof (eval_input_load_bm_lp lp LO_mario _ _ _ _ _ _ Hpm Hev)
          as Hload.
        exact (Hinp vi Hload).
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hgate t Hmem vi Hlk).
    - (* dispatch temps: Vundef-or-Q-Vint *)
      intros t Hmem v' Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hdisp_rule. cbn [negb orb] in Hdisp_rule.
        pose proof (is_action_load_x_shape _ _ Hdisp_rule) as Hshape. subst a.
        destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev) as (pb & po & Hpm).
        destruct (Hm _ _ Hpm) as [E1 E2]. subst pb po.
        pose proof (eval_action_load_bm_lp lp LO_mario _ _ _ _ _ _ Hpm Hev)
          as Hload.
        destruct (HactVint _ HMWF _ Hload) as [HU | (vi & Hvi)].
        * left; exact HU.
        * right. exists vi. split; [ exact Hvi | ].
          rewrite Hvi in Hload. exact (Hsat _ Hload).
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hdisp t Hmem v' Hlk).
    - (* gms temps: the gMarioState global load pins to (bm,0) *)
      intros t Hmem b o Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hgms_rule. cbn [negb orb] in Hgms_rule.
        destruct (is_gms_load_shape _ _ Hgms_rule) as [Hshape Hbcg]. subst a.
        (* Evar only evaluates through eval_Elvalue *)
        inv Hev.
        match goal with
        | Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl
        end.
        * (* local: refuted by the env row *)
          match goal with He0 : e ! _ = Some _ |- _ =>
            rewrite (Hglob _ Hbcg) in He0; discriminate He0 end.
        * (* global: the deref is the canonical gMarioState cell load *)
          match goal with
          | Hdl : deref_loc _ _ _ _ _ _ |- _ => inv Hdl
          end;
            try (match goal with
                 | Hac : access_mode _ = By_reference |- _ =>
                     cbn [typeof access_mode] in Hac; discriminate Hac
                 | Hac : access_mode _ = By_copy |- _ =>
                     cbn [typeof access_mode] in Hac; discriminate Hac
                 end).
          match goal with
          | Hac : access_mode _ = By_value _ |- _ =>
              cbn [typeof access_mode] in Hac; inv Hac
          end.
          match goal with
          | Hfs2 : Genv.find_symbol _ mario._gMarioState = Some ?l,
            Hldv : Mem.loadv Mptr _ (Vptr ?l Ptrofs.zero)
                     = Some (Vptr b o) |- _ =>
              destruct (HPgms _ _ _ _ HMWF Hfs2 Hldv) as [Eb Eo];
              subst b o; auto
          end.
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hgms t Hmem b o Hlk).
    - (* chase temps: root load (off bm) or step load (off a SafeB block) *)
      intros t Hmem b o Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hchase_rule. cbn [negb orb] in Hchase_rule.
        apply orb_true_iff in Hchase_rule as [Hroot | Hstep].
        * (* ROOT: m->fld or gmsTemp->fld *)
          destruct (is_chase_root_load_shape _ _ Hroot)
            as (p & fld & fty & Hshape & Hp & Hfldmem & Hptrty). subst a.
          destruct (chase_root_field_offset _ Hfldmem) as (delta & Hfo).
          destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev)
            as (pb & po & Hple).
          assert (Hbm0 : pb = bm /\ po = Ptrofs.zero).
          { destruct Hp as [-> | Hpg];
              [ exact (Hm _ _ Hple) | exact (Hgms _ Hpg _ _ Hple) ]. }
          destruct Hbm0 as [E1 E2]. subst pb po.
          apply eval_expr_Efield_load in Hev
            as (loc & ofs & bf & Hlv & Hderef).
          destruct (mfield_lvalue_geom_lp _ _ _ _ _ _ _ _ _ _ _ _
                      Hple Hfo Hlv) as (Hloc & Hofs & Hbf).
          subst loc ofs bf.
          pose proof (is_ptr_ty_access _ Hptrty) as Hacc.
          inv Hderef;
            try (match goal with Hac2 : access_mode fty = _ |- _ =>
                   rewrite Hacc in Hac2; discriminate Hac2 end).
          match goal with
          | Hac2 : access_mode fty = By_value ?ch,
            Hldv : Mem.loadv ?ch _ _ = Some (Vptr b o) |- _ =>
              rewrite Hacc in Hac2; inv Hac2;
              exact (HchaseRoot _ _ _ _ _ Hfldmem Hfo HMWF Hldv)
          end.
        * (* STEP: a chain rooted at an already-tabled chase temp *)
          destruct (is_chase_step_load_shape _ _ Hstep)
            as (a' & fld & fty & t0 & Hshape & Hptrty & Hcroot & Ht0mem).
          subst a.
          apply eval_expr_Efield_load in Hev
            as (loc & ofs & bf & Hlv & Hderef).
          assert (Hl : exists o0, le ! t0 = Some (Vptr loc o0)).
          { exact (chain_root_l_block _ _ _ _ (Efield a' fld fty) _ _ _ _
                     Hcroot Hlv). }
          destruct Hl as (o0 & Hlet0).
          pose proof (Hch _ Ht0mem _ _ Hlet0) as Hsafe_loc.
          pose proof (is_ptr_ty_access _ Hptrty) as Hacc.
          inv Hderef;
            try (match goal with Hac2 : access_mode fty = _ |- _ =>
                   rewrite Hacc in Hac2; discriminate Hac2 end);
            try (match goal with
                 Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
          match goal with
          | Hac2 : access_mode fty = By_value ?ch,
            Hldv : Mem.loadv ?ch _ _ = Some (Vptr b o) |- _ =>
              rewrite Hacc in Hac2; inv Hac2;
              exact (HchaseStep _ _ _ _ _ HMWF Hsafe_loc Hldv)
          end.
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hch t Hmem b o Hlk).
  Qed.

  (* ---- HTI_optc: a censused call's result temp is untabled, so TI is
     pure gso.  (The engine's non-bm-pointer fact about the result value
     is not even needed.) ---- *)
  Lemma chk_ti_optc :
    forall Q bm SafeB bc e optid a al v le,
      chk bc (Scall optid a al) = true ->
      TI_of Q bm SafeB bc e le ->
      TI_of Q bm SafeB bc e (set_opttemp optid v le).
  Proof.
    intros Q bm SafeB bc e optid a al v le HC HTI.
    change ((call_optid_ok bc optid
             && (call_head_is_mptr bc al && callee_in_mptr a
                 || call_callee_exempt a)) = true)
      in HC.
    apply andb_true_iff in HC as [Hopt _].
    destruct optid as [rid|]; cbn [set_opttemp]; [ | exact HTI ].
    change ((negb (Pos.eqb rid (bc_mptr bc))
             && negb (mem_id rid (bc_gates bc))
             && negb (mem_id rid (bc_disp bc))
             && negb (mem_id rid (bc_gms bc))
             && negb (mem_id rid (bc_chase bc))) = true) in Hopt.
    apply andb_true_iff in Hopt as [Hopt Hrch].
    apply andb_true_iff in Hopt as [Hopt Hrgm].
    apply andb_true_iff in Hopt as [Hopt Hrd].
    apply andb_true_iff in Hopt as [Hrm Hrg].
    destruct HTI as (Hm & Hg & Hd & Hgl & Hgm & Hch).
    refine (conj _ (conj _ (conj _ (conj Hgl (conj _ _))))).
    - intros b o Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst rid; rewrite Pos.eqb_refl in Hrm; discriminate Hrm).
      exact (Hm b o Hlk).
    - intros t Hmem vi Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst t; rewrite Hmem in Hrg; discriminate Hrg).
      exact (Hg t Hmem vi Hlk).
    - intros t Hmem v' Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst t; rewrite Hmem in Hrd; discriminate Hrd).
      exact (Hd t Hmem v' Hlk).
    - intros t Hmem b o Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst t; rewrite Hmem in Hrgm; discriminate Hrgm).
      exact (Hgm t Hmem b o Hlk).
    - intros t Hmem b o Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst t; rewrite Hmem in Hrch; discriminate Hrch).
      exact (Hch t Hmem b o Hlk).
  Qed.

  (* ---- Hcallmarg: a censused call's evaluated args satisfy the EXACT
     marg_ok whenever the callee is non-exempt.  Class M: the head is the
     body's Mario param -- its value pins to (bm,0) via TI, and sem_cast
     passes pointers through identically.  Class E: the whitelist residual
     says the callee IS exempt, contradicting the premise. ---- *)
  Lemma chk_call_marg :
    forall Q bm SafeB bc e le m optid a al tyargs vargs vf fd,
      TI_of Q bm SafeB bc e le ->
      chk bc (Scall optid a al) = true ->
      eval_expr (lp_ge lp) e le m a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = false ->
      eval_exprlist (lp_ge lp) e le m al tyargs vargs ->
      marg_ok bm vargs.
  Proof.
    intros Q bm SafeB bc e le m optid a al tyargs vargs vf fd
           HTI HC Hevf Hff Hnex Hargs.
    change ((call_optid_ok bc optid
             && (call_head_is_mptr bc al && callee_in_mptr a
                 || call_callee_exempt a)) = true)
      in HC.
    apply andb_true_iff in HC as [_ HC].
    apply orb_true_iff in HC as [HM | HE].
    - (* class M: head = Etempvar mptr *)
      apply andb_true_iff in HM as [HM _].
      unfold call_head_is_mptr in HM.
      destruct al as [| a0 al']; [ discriminate HM | ].
      destruct a0; try discriminate HM.
      apply andb_true_iff in HM as [Hp Hty].
      apply Pos.eqb_eq in Hp. apply proj_sumbool_true in Hty. subst.
      inv Hargs.
      match goal with
        Hv1 : eval_expr _ _ _ _ (Etempvar _ _) ?v1,
        Hcast : sem_cast ?v1 _ _ _ = Some ?v2 |- _ =>
          apply eval_expr_Etempvar_val in Hv1;
          destruct v2 as [ | | | | | b o ]; try exact I;
          apply sem_cast_vptr_inv in Hcast; subst v1;
          destruct HTI as (Hm & _ & _ & _ & _ & _);
          exact (Hm _ _ Hv1)
      end.
    - (* class E: the callee is whitelisted-exempt *)
      unfold call_callee_exempt in HE.
      destruct a; try discriminate HE.
      destruct t; try discriminate HE.
      rewrite (WL_exempt _ _ _ _ _ _ _ HE Hevf Hff) in Hnex.
      discriminate Hnex.
  Qed.

  (* ---- Hassign: a censused store preserves valid, action_sat, and --
     via the caller-supplied closure premises -- MWF.  Class F: window-
     checked m->field store (TI pins the base to (bm,0); the window keeps
     the bytes off every protected cell).  Class I: the m->input A-clear
     write.  Class G: whitelisted off-Mario global.  Class C: a store
     through a tabled chase temp -- the chain brick pins the written block
     to the temp's SafeB block (off bm; HMWFchase tolerates non-pointer
     stores there, and the census rhs classes make the written value
     provably non-Vptr). ---- *)
  Lemma chk_assign :
    forall (Q : int -> Prop) (MWF : mem -> Prop) bm (SafeB : block -> Prop)
           bc e le m a1 a2 loc ofs bf v2 v m',
      (forall mm mm' ch (delta : Z) vv,
         MWF mm ->
         store_window_ok delta (size_chunk ch) = true ->
         Mem.store ch mm bm delta vv = Some mm' -> MWF mm') ->
      (forall mm mm' vv,
         MWF mm ->
         Int.and vv (Int.repr 2) = Int.zero ->
         Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm') ->
      (forall gid, mem_id gid stored_globals = true ->
         forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
           bg <> bm /\
           (forall mm mm' ch0 (d : Z) vv,
              MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm')) ->
      (* HSafeNotBm: SafeB blocks are off-Mario *)
      (forall bsafe, SafeB bsafe -> bsafe <> bm) ->
      (* HMWFchase: MWF tolerates non-pointer stores into SafeB blocks *)
      (forall mm ch bsafe (d : Z) vv mm',
         MWF mm -> SafeB bsafe ->
         (forall bb oo, vv <> Vptr bb oo) ->
         Mem.store ch mm bsafe d vv = Some mm' -> MWF mm') ->
      eval_lvalue (lp_ge lp) e le m a1 loc ofs bf ->
      eval_expr (lp_ge lp) e le m a2 v2 ->
      sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
      assign_loc (lp_ge lp) (typeof a1) m loc ofs bf v m' ->
      TI_of Q bm SafeB bc e le ->
      chk bc (Sassign a1 a2) = true ->
      MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
      Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.
  Proof.
    intros Q MWF bm SafeB bc e le m a1 a2 loc ofs bf v2 v m'
           HMWFstore HMWFinp HG HSafeNotBm HMWFchase
           Hlv Hev2 Hcast Has HTI HC HMWF Hvb Hsat.
    change ((((safe_mfield_store (bc_mptr bc) a1
               || input_store_ok bc a1 a2)
              || global_store_ok bc a1)
             || chase_store_ok bc a1 a2) = true) in HC.
    apply orb_true_iff in HC as [HC | HCC].
    2:{ (* ---- class C: a store through a tabled chase temp ---- *)
      unfold chase_store_ok in HCC.
      destruct (chain_root_l a1) as [ct|] eqn:Hcr; [ | discriminate HCC ].
      apply andb_true_iff in HCC as [Hctmem Hrhs].
      destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv)
        as (o0 & Hlet).
      destruct HTI as (_ & _ & Hdisp & _ & _ & Hch).
      pose proof (Hch _ Hctmem _ _ Hlet) as Hsafe.
      pose proof (HSafeNotBm _ Hsafe) as Hneq.
      (* the written value is not a pointer *)
      assert (Hnp : forall bb oo, v <> Vptr bb oo).
      { unfold chase_rhs_ok in Hrhs.
        apply orb_true_iff in Hrhs as [Hsc | HI32].
        - exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hsc Hcast).
        - destruct (typeof a1) as [ | sz sg att | | | | | | | ];
            try discriminate HI32;
            destruct sz; try discriminate HI32;
            destruct a2; try discriminate HI32.
          + (* Econst_int rvalue *)
            inv Hev2.
            2:{ match goal with
                Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                  inv Hl end. }
            exact (sem_cast_vint_nonptr _ _ _ _ _ Hcast).
          + (* tabled disp-temp rvalue: Vundef-or-Vint *)
            apply eval_expr_Etempvar_val in Hev2.
            destruct (Hdisp _ HI32 _ Hev2) as [HU | (vi & Hvi & _)].
            * subst v2.
              pose proof (sem_cast_vundef_inv _ _ _ _ Hcast) as ->.
              intros bb oo E. discriminate E.
            * subst v2. exact (sem_cast_vint_nonptr _ _ _ _ _ Hcast). }
      (* the store lands in the SafeB block: chunk store or bitfield *)
      inv Has.
      - (* By_value *)
        match goal with
        | Hsv0 : Mem.storev _ _ _ _ = Some m' |- _ =>
            unfold Mem.storev in Hsv0
        end.
        match goal with Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (Hsat av Hload) | left; exact (not_eq_sym Hneq) ]
        | exact (HMWFchase _ _ _ _ _ _ HMWF Hsafe Hnp Hsv) ]
        end.
      - (* By_copy: impossible, the censused field types are By_value *)
        exfalso.
        unfold chase_rhs_ok in Hrhs.
        match goal with Hac0 : access_mode (typeof a1) = By_copy |- _ =>
          destruct (typeof a1) as [ | sz sg att | sg att | fs att | | | | | ];
            try discriminate Hrhs;
            try (destruct sz; try discriminate Hrhs);
            try (destruct fs);
            cbn in Hac0; try discriminate Hac0
        end.
        (* surviving I8/I16 cases carry signedness: still By_value *)
        all: match goal with Hac0 : _ = By_copy |- _ =>
               try (destruct sg; cbn in Hac0); discriminate Hac0 end.
      - (* bitfield: store_bitfield writes a Vint into the SafeB block *)
        match goal with
        | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb
        end.
        match goal with
        | Hsv0 : Mem.storev _ _ _ (Vint _) = Some m' |- _ =>
            unfold Mem.storev in Hsv0
        end.
        match goal with Hsv : Mem.store _ _ _ _ (Vint _) = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (Hsat av Hload) | left; exact (not_eq_sym Hneq) ]
        | refine (HMWFchase _ _ _ _ _ _ HMWF Hsafe _ Hsv);
          intros bb oo E; discriminate E ]
        end. }
    apply orb_true_iff in HC as [HC | HCG].
    2:{ (* ---- class G: whitelisted off-Mario global store ---- *)
      destruct (global_store_ok_shape _ _ HCG)
        as (gid & gty & ch & Hshape & Hbcg & Hsg & Hac).
      subst a1.
      destruct HTI as (_ & _ & _ & Hglob & _ & _).
      inv Hlv.
      - (* eval_Evar_local: refuted by the env row *)
        match goal with Hl : e ! gid = Some _ |- _ =>
          rewrite (Hglob gid Hbcg) in Hl; discriminate Hl end.
      - (* eval_Evar_global *)
        match goal with Hfs : Genv.find_symbol _ gid = Some ?bg0 |- _ =>
          destruct (HG gid Hsg _ Hfs) as [Hne HMWFg] end.
        cbn [typeof] in Has.
        inv Has;
          try (match goal with Hac2 : access_mode gty = _ |- _ =>
                 rewrite Hac in Hac2; discriminate Hac2 end).
        match goal with
        | Hsv0 : Mem.storev _ _ _ _ = Some m',
          Hac2 : access_mode gty = By_value _ |- _ =>
            rewrite Hac in Hac2; injection Hac2 as <-;
            unfold Mem.storev in Hsv0
        end.
        match goal with Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (Hsat av Hload) | left; exact (not_eq_sym Hne) ]
        | exact (HMWFg _ _ _ _ _ HMWF Hsv) ]
        end. }
    apply orb_true_iff in HC as [HC | HCI].
    2:{ (* ---- class I: the m->input A-clear write ---- *)
      apply andb_true_iff in HCI as [Hsh Hrhs].
      pose proof (is_input_load_x_shape _ _ Hsh) as Hshape. subst a1.
      assert (Hfo : field_offset (prog_comp_env mario.prog) mario._input
                      mario_state_members = OK (2, Full))
        by (vm_compute; reflexivity).
      assert (Hpin : exists pb po, le ! (bc_mptr bc) = Some (Vptr pb po)).
      { pose proof Hlv as Hlv0.
        apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hbase).
        apply eval_expr_Ederef_load in Hbase
          as (lb & ob & bfb & Hlvb & Hderefb).
        apply eval_lvalue_Ederef_base in Hlvb.
        apply eval_expr_Etempvar_val in Hlvb. eauto. }
      destruct Hpin as (pb & po & Hple).
      destruct HTI as (Hm & Hgate & _ & _ & _ & _).
      destruct (Hm _ _ Hple) as [E1 E2]. subst pb po.
      destruct (mfield_lvalue_geom_lp _ _ _ _ _ _ _ _ _ _ _ _ Hple Hfo Hlv)
        as (Hloc & Hofs & Hbf). subst loc ofs bf.
      rewrite Ptrofs.add_zero_l in Has.
      cbn [typeof] in Has.
      (* the written value has bit 1 clear *)
      assert (Hv : exists vv, v = Vint vv /\
                              Int.and vv (Int.repr 2) = Int.zero).
      { destruct (input_rhs_aclear_shape _ _ Hrhs)
          as [ (c & Hr & Hc) | (t & c & Hr & Hmemg & Hc) ]; subst a2.
        - (* constant write *)
          inv Hev2.
          2:{ match goal with
              Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                inv Hl end. }
          cbn in Hcast. inv Hcast.
          eexists. split; [ reflexivity | ].
          rewrite and2_zero_ext16. exact Hc.
        - (* gate-temp or-update *)
          rewrite <- (Int.repr_unsigned c) in Hev2.
          apply or_temp_vint in Hev2 as (vi & Hlet & ->).
          pose proof (Hgate _ Hmemg _ Hlet) as Hvi.
          cbn in Hcast. inv Hcast.
          eexists. split; [ reflexivity | ].
          rewrite and2_zero_ext16.
          apply and2_or_clear;
            [ exact Hvi | rewrite Int.repr_unsigned; exact Hc ]. }
      destruct Hv as (vv & Hveq & Hvbit). subst v.
      inv Has;
        try (match goal with Hac2 : access_mode tushort = _ |- _ =>
               cbn in Hac2; discriminate Hac2 end).
      match goal with
      | Hsv0 : Mem.storev _ _ _ _ = Some m',
        Hac2 : access_mode tushort = By_value _ |- _ =>
          cbn in Hac2; injection Hac2 as <-;
          unfold Mem.storev in Hsv0;
          change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in Hsv0;
          rename Hsv0 into Hsv
      end.
      split; [ eauto using Mem.store_valid_block_1 | split ].
      - intros av Hload.
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (Hsat av Hload) | right; cbn [size_chunk]; lia ].
      - exact (HMWFinp _ _ _ HMWF Hvbit Hsv). }
    (* ---- class F: the window-checked m->field store ---- *)
    destruct (safe_mfield_store_shape _ _ HC) as (fld & fty & Hshape & Hgeo).
    subst a1.
    destruct (mfield_geom_chk_sound _ _ Hgeo) as (delta & ch & Hfo & Hac & Hwin).
    (* the base temp holds a pointer (the lvalue derivation derefs it) *)
    assert (Hpin : exists pb po, le ! (bc_mptr bc) = Some (Vptr pb po)).
    { pose proof Hlv as Hlv0.
      apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hbase).
      apply eval_expr_Ederef_load in Hbase
        as (lb & ob & bfb & Hlvb & Hderefb).
      apply eval_lvalue_Ederef_base in Hlvb.
      apply eval_expr_Etempvar_val in Hlvb. eauto. }
    destruct Hpin as (pb & po & Hple).
    destruct HTI as (Hm & _ & _ & _ & _ & _).
    destruct (Hm _ _ Hple) as [E1 E2]. subst pb po.
    destruct (mfield_lvalue_geom_lp _ _ _ _ _ _ _ _ _ _ _ _ Hple Hfo Hlv)
      as (Hloc & Hofs & Hbf). subst loc ofs bf.
    rewrite Ptrofs.add_zero_l in Has.
    (* the store itself *)
    cbn [typeof] in Has. inv Has;
      try (match goal with Hac2 : access_mode fty = _ |- _ =>
             rewrite Hac in Hac2; discriminate Hac2 end).
    match goal with
    | Hsv : Mem.storev _ _ _ _ = Some m',
      Hac2 : access_mode fty = By_value ?ch2 |- _ =>
        rewrite Hac in Hac2; injection Hac2 as <-;
        unfold Mem.storev in Hsv;
        rewrite Ptrofs.unsigned_repr in Hsv
    end.
    2:{ (* delta in range, from the census bounds *)
        unfold store_window_ok in Hwin.
        repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
        match goal with
        | Hb1 : (0 <=? delta) = true, Hb2 : (delta + _ <=? _) = true,
          Hb3 : (0 <? _) = true |- _ =>
            apply Z.leb_le in Hb1; apply Z.leb_le in Hb2;
            apply Z.ltb_lt in Hb3; lia
        end. }
    match goal with Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
    split; [ eauto using Mem.store_valid_block_1 | split ];
    [ (* action_sat: the window misses [12,16) *)
      intros av Hload;
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
      [ exact (Hsat av Hload) | right ]
    | exact (HMWFstore _ _ _ _ _ HMWF Hwin Hsv) ]
    end.
    unfold store_window_ok in Hwin.
    repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
    match goal with
    | Hb : ((delta + _ <=? 12) || (16 <=? delta))%bool = true |- _ =>
        apply orb_true_iff in Hb as [Hb | Hb]; apply Z.leb_le in Hb;
        cbn [size_chunk]; lia
    end.
  Qed.

End CensusLeavesLp.

(* ====================================================================== *)
(* Entry seeding: function_entry2 + the EXACT marg_ok establish TI_of for *)
(* a single-MarioState*-param body.  Gate/dispatch temps are Vundef at     *)
(* entry (create_undef_temps), so their Vint-conditional facts hold        *)
(* vacuously; the mptr row comes straight from marg_ok's exact (bm,0).     *)
(* ====================================================================== *)

Lemma create_undef_temps_Vundef :
  forall l t v, (create_undef_temps l) ! t = Some v -> v = Vundef.
Proof.
  induction l as [| [id ty] l IH]; cbn; intros t v H.
  - rewrite PTree.gempty in H. discriminate.
  - destruct (Pos.eq_dec t id) as [E|NE].
    + subst t. rewrite PTree.gss in H. congruence.
    + rewrite PTree.gso in H by exact NE. eauto.
Qed.

(* membership reflection + the alloc_variables domain fact, for the env row *)
Lemma mem_id_false_notin :
  forall t l, mem_id t l = false -> ~ In t l.
Proof.
  intros t l H Hin. induction l as [| a l IH]; [ exact Hin | ].
  cbn in H. apply orb_false_iff in H as [Ha Hl].
  destruct Hin as [E | Hin].
  - subst a. rewrite Pos.eqb_refl in Ha. discriminate Ha.
  - exact (IH Hl Hin).
Qed.

Lemma alloc_variables_notin_none :
  forall ge vars e0 m e m',
    alloc_variables ge e0 m vars e m' ->
    forall id, e0 ! id = None -> ~ In id (var_names vars) -> e ! id = None.
Proof.
  induction 1; intros id0 He0 Hnin.
  - exact He0.
  - apply IHalloc_variables.
    + rewrite PTree.gso;
        [ exact He0 | intro E; subst id0; apply Hnin; left; reflexivity ].
    + intro Hin. apply Hnin. right. exact Hin.
Qed.

(* the trivial env-row side condition for bodies that store no globals *)
Lemma nil_globals_novars :
  forall bc f, bc_globals bc = nil ->
    forall gid, mem_id gid (bc_globals bc) = true ->
    mem_id gid (var_names (fn_vars f)) = false.
Proof. intros bc f Hn gid Hg. rewrite Hn in Hg. discriminate Hg. Qed.

Lemma entry_TI_v2 :
  forall (Q : int -> Prop) (bm : block) (SafeB : block -> Prop)
         (bc : body_census) ge f vargs m e le m1,
    function_entry2 ge f vargs m e le m1 ->
    fn_params f = (bc_mptr bc, tptr tyMS) :: nil ->
    mem_id (bc_mptr bc) (bc_gates bc) = false ->
    mem_id (bc_mptr bc) (bc_disp bc) = false ->
    mem_id (bc_mptr bc) (bc_gms bc) = false ->
    mem_id (bc_mptr bc) (bc_chase bc) = false ->
    (forall gid, mem_id gid (bc_globals bc) = true ->
       mem_id gid (var_names (fn_vars f)) = false) ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc e le.
Proof.
  intros Q bm SafeB bc ge f vargs m e le m1 Hentry Hparams
         Hng Hnd Hngm Hnch Hnvars Hmarg.
  inv Hentry.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    rewrite Hparams in Hb;
    destruct vargs as [| v0 [| v1 vs ]]; cbn in Hb; try discriminate Hb;
    inv Hb end.
  refine (conj _ (conj _ (conj _ (conj _ (conj _ _))))).
  - (* the mptr row: exact marg *)
    intros b o Hlk. rewrite PTree.gss in Hlk. inv Hlk.
    exact Hmarg.
  - (* gate temps: Vundef at entry *)
    intros t Hmem vi Hlk.
    destruct (Pos.eq_dec t (bc_mptr bc)) as [E|NE].
    + subst t. rewrite Hmem in Hng. discriminate Hng.
    + rewrite PTree.gso in Hlk by exact NE.
      apply create_undef_temps_Vundef in Hlk. discriminate Hlk.
  - (* dispatch temps: Vundef at entry (the Vundef disjunct) *)
    intros t Hmem v' Hlk.
    destruct (Pos.eq_dec t (bc_mptr bc)) as [E|NE].
    + subst t. rewrite Hmem in Hnd. discriminate Hnd.
    + rewrite PTree.gso in Hlk by exact NE.
      left. exact (create_undef_temps_Vundef _ _ _ Hlk).
  - (* env row: stored globals are not this body's locals *)
    intros gid Hg.
    match goal with Hav : alloc_variables _ empty_env _ _ _ _ |- _ =>
      refine (alloc_variables_notin_none _ _ _ _ _ _ Hav gid _ _) end.
    + apply PTree.gempty.
    + apply mem_id_false_notin. exact (Hnvars gid Hg).
  - (* gms temps: Vundef at entry *)
    intros t Hmem b o Hlk.
    destruct (Pos.eq_dec t (bc_mptr bc)) as [E|NE].
    + subst t. rewrite Hmem in Hngm. discriminate Hngm.
    + rewrite PTree.gso in Hlk by exact NE.
      apply create_undef_temps_Vundef in Hlk. discriminate Hlk.
  - (* chase temps: Vundef at entry *)
    intros t Hmem b o Hlk.
    destruct (Pos.eq_dec t (bc_mptr bc)) as [E|NE].
    + subst t. rewrite Hmem in Hnch. discriminate Hnch.
    + rewrite PTree.gso in Hlk by exact NE.
      apply create_undef_temps_Vundef in Hlk. discriminate Hlk.
Qed.

(* ====================================================================== *)
(* The first REAL per-body census instances -- checked by computation      *)
(* over the generated AST (PIPELINE-not-bespoke).  bc_m0 is the trivial    *)
(* table (the _m param row only; no gate/dispatch temps).  The two         *)
(* call-free, store-free pure readers among the 17 reached internals       *)
(* (docs/reachable-internal-graph.md) pass the strict census as-is.        *)
(* ====================================================================== *)

Definition bc_m0 : body_census :=
  {| bc_mptr := mario._m; bc_gates := nil; bc_disp := nil;
     bc_globals := nil; bc_gms := nil; bc_chase := nil |}.

Lemma bc_m0_gates_disjoint : mem_id (bc_mptr bc_m0) (bc_gates bc_m0) = false.
Proof. reflexivity. Qed.

Lemma bc_m0_disp_disjoint : mem_id (bc_mptr bc_m0) (bc_disp bc_m0) = false.
Proof. reflexivity. Qed.

Lemma chk_mario_get_floor_class :
  chk bc_m0 (fn_body mario.f_mario_get_floor_class) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_mario_get_terrain_sound_addend :
  chk bc_m0 (fn_body mario.f_mario_get_terrain_sound_addend) = true.
Proof. vm_compute. reflexivity. Qed.

(* call-bearing pure readers: their calls pass the call census (class M:
   head = _m, e.g. mario_get_floor_class(m); class E: whitelisted exempt
   callees, e.g. sqrtf/atan2s/print_text_fmt_int). *)
Lemma chk_mario_floor_is_slippery :
  chk bc_m0 (fn_body mario.f_mario_floor_is_slippery) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_debug_print_speed_action_normal :
  chk bc_m0 (fn_body mario.f_debug_print_speed_action_normal) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma params_mario_get_floor_class :
  fn_params mario.f_mario_get_floor_class = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_mario_get_terrain_sound_addend :
  fn_params mario.f_mario_get_terrain_sound_addend
  = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

(* input-writing bodies: their or-update temps are TABLED as gate rows --
   the census then forces each one's only definition to be the canonical
   m->input load, so TI carries its bit-1-clear fact into the write. *)
Definition bc_umji : body_census :=
  {| bc_mptr := mario._m; bc_gates := mario._t'4 :: nil; bc_disp := nil;
     bc_globals := nil; bc_gms := nil; bc_chase := nil |}.

Definition bc_ugeo : body_census :=
  {| bc_mptr := mario._m;
     bc_gates := mario._t'29 :: mario._t'21 :: mario._t'20
                 :: mario._t'17 :: mario._t'14 :: nil;
     bc_disp := nil; bc_globals := nil; bc_gms := nil; bc_chase := nil |}.

Lemma bc_umji_gates_disjoint : mem_id (bc_mptr bc_umji) (bc_gates bc_umji) = false.
Proof. reflexivity. Qed.
Lemma bc_umji_disp_disjoint : mem_id (bc_mptr bc_umji) (bc_disp bc_umji) = false.
Proof. reflexivity. Qed.
Lemma bc_ugeo_gates_disjoint : mem_id (bc_mptr bc_ugeo) (bc_gates bc_ugeo) = false.
Proof. reflexivity. Qed.
Lemma bc_ugeo_disp_disjoint : mem_id (bc_mptr bc_ugeo) (bc_disp bc_ugeo) = false.
Proof. reflexivity. Qed.

(* umi additionally stores the gCameraMovementFlags GLOBAL (class G), so
   its census tables the global in bc_globals -- TI's env row then refutes
   local shadowing at the store. *)
Definition bc_umi : body_census :=
  {| bc_mptr := mario._m;
     bc_gates := mario._t'13 :: mario._t'9 :: mario._t'7 :: nil;
     bc_disp := nil;
     bc_globals := mario._gCameraMovementFlags :: nil;
     bc_gms := nil; bc_chase := nil |}.

Lemma bc_umi_gates_disjoint : mem_id (bc_mptr bc_umi) (bc_gates bc_umi) = false.
Proof. reflexivity. Qed.
Lemma bc_umi_disp_disjoint : mem_id (bc_mptr bc_umi) (bc_disp bc_umi) = false.
Proof. reflexivity. Qed.

Lemma bc_umi_globals_novars :
  forall gid, mem_id gid (bc_globals bc_umi) = true ->
    mem_id gid (var_names (fn_vars mario.f_update_mario_inputs)) = false.
Proof.
  intros gid Hg.
  change ((Pos.eqb gid mario._gCameraMovementFlags || false) = true) in Hg.
  rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst gid.
  reflexivity.
Qed.

Lemma chk_update_mario_inputs :
  chk bc_umi (fn_body mario.f_update_mario_inputs) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_update_mario_joystick_inputs :
  chk bc_umji (fn_body mario.f_update_mario_joystick_inputs) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_update_mario_geometry_inputs :
  chk bc_ugeo (fn_body mario.f_update_mario_geometry_inputs) = true.
Proof. vm_compute. reflexivity. Qed.

(* class-F storers: every store is a window-checked m->field write
   (capTimer/flags, particleFlags, health/healCounter/hurtCounter). *)
Lemma chk_update_and_return_cap_flags :
  chk bc_m0 (fn_body mario.f_update_and_return_cap_flags) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_set_submerged_cam_preset_and_spawn_bubbles :
  chk bc_m0 (fn_body mario.f_set_submerged_cam_preset_and_spawn_bubbles) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_update_mario_health :
  chk bc_m0 (fn_body mario.f_update_mario_health) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma params_mario_floor_is_slippery :
  fn_params mario.f_mario_floor_is_slippery = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_debug_print_speed_action_normal :
  fn_params mario.f_debug_print_speed_action_normal
  = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_update_and_return_cap_flags :
  fn_params mario.f_update_and_return_cap_flags
  = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_set_submerged_cam_preset_and_spawn_bubbles :
  fn_params mario.f_set_submerged_cam_preset_and_spawn_bubbles
  = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_update_mario_health :
  fn_params mario.f_update_mario_health
  = (bc_mptr bc_m0, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_update_mario_joystick_inputs :
  fn_params mario.f_update_mario_joystick_inputs
  = (bc_mptr bc_umji, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_update_mario_inputs :
  fn_params mario.f_update_mario_inputs
  = (bc_mptr bc_umi, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_update_mario_geometry_inputs :
  fn_params mario.f_update_mario_geometry_inputs
  = (bc_mptr bc_ugeo, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

(* The per-body Hbody bricks: exactly the engine leaf's conclusion shape
   (an index whose table is seeded and whose body passes census). *)
Lemma body_TI_C_mario_get_floor_class :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_mario_get_floor_class vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_mario_get_floor_class) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_mario_get_floor_class bc_m0_gates_disjoint
             bc_m0_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_mario_get_floor_class.
Qed.

Lemma body_TI_C_mario_get_terrain_sound_addend :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_mario_get_terrain_sound_addend vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_mario_get_terrain_sound_addend) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_mario_get_terrain_sound_addend bc_m0_gates_disjoint
             bc_m0_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_mario_get_terrain_sound_addend.
Qed.

Lemma body_TI_C_mario_floor_is_slippery :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_mario_floor_is_slippery vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_mario_floor_is_slippery) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_mario_floor_is_slippery bc_m0_gates_disjoint
             bc_m0_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_mario_floor_is_slippery.
Qed.

Lemma body_TI_C_debug_print_speed_action_normal :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_debug_print_speed_action_normal vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_debug_print_speed_action_normal) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_debug_print_speed_action_normal bc_m0_gates_disjoint
             bc_m0_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_debug_print_speed_action_normal.
Qed.

Lemma body_TI_C_update_and_return_cap_flags :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_update_and_return_cap_flags vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_update_and_return_cap_flags) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_update_and_return_cap_flags bc_m0_gates_disjoint
             bc_m0_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_update_and_return_cap_flags.
Qed.

Lemma body_TI_C_set_submerged_cam_preset_and_spawn_bubbles :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_set_submerged_cam_preset_and_spawn_bubbles
      vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_set_submerged_cam_preset_and_spawn_bubbles)
      = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_set_submerged_cam_preset_and_spawn_bubbles
             bc_m0_gates_disjoint bc_m0_disp_disjoint eq_refl eq_refl
             (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_set_submerged_cam_preset_and_spawn_bubbles.
Qed.

Lemma body_TI_C_update_mario_health :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_health vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_update_mario_health) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_m0 ge _ vargs m e le m1 Hentry
             params_update_mario_health bc_m0_gates_disjoint
             bc_m0_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_update_mario_health.
Qed.

Lemma body_TI_C_update_mario_joystick_inputs :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_joystick_inputs vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_umji e le /\
    chk bc_umji (fn_body mario.f_update_mario_joystick_inputs) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_umji ge _ vargs m e le m1 Hentry
             params_update_mario_joystick_inputs bc_umji_gates_disjoint
             bc_umji_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_umji _ eq_refl) Hmarg).
  - exact chk_update_mario_joystick_inputs.
Qed.

Lemma body_TI_C_update_mario_inputs :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_inputs vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_umi e le /\
    chk bc_umi (fn_body mario.f_update_mario_inputs) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_umi ge _ vargs m e le m1 Hentry
             params_update_mario_inputs bc_umi_gates_disjoint
             bc_umi_disp_disjoint eq_refl eq_refl bc_umi_globals_novars
             Hmarg).
  - exact chk_update_mario_inputs.
Qed.

Lemma body_TI_C_update_mario_geometry_inputs :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_geometry_inputs vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_ugeo e le /\
    chk bc_ugeo (fn_body mario.f_update_mario_geometry_inputs) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_ugeo ge _ vargs m e le m1 Hentry
             params_update_mario_geometry_inputs bc_ugeo_gates_disjoint
             bc_ugeo_disp_disjoint eq_refl eq_refl (nil_globals_novars bc_ugeo _ eq_refl) Hmarg).
  - exact chk_update_mario_geometry_inputs.
Qed.

(* ====================================================================== *)
(* The CHASE-STORE bodies: stores through tabled chase-pointer temps      *)
(* (class C), plus -- for update_mario_info_for_cam -- action-mirror      *)
(* stores whose I32 rvalues are tabled disp temps, and -- for             *)
(* mario_update_hitbox_and_cap_model -- chase roots reached through       *)
(* gMarioState-loaded temps (the gms rows).                                *)
(* ====================================================================== *)

Definition bc_mrb : body_census :=
  {| bc_mptr := mario._m; bc_gates := nil; bc_disp := nil;
     bc_globals := nil; bc_gms := nil;
     bc_chase := mario._bodyState :: nil |}.

Definition bc_umifc : body_census :=
  {| bc_mptr := mario._m; bc_gates := nil;
     bc_disp := mario._t'7 :: mario._t'5 :: nil;
     bc_globals := nil; bc_gms := nil;
     bc_chase := mario._t'6 :: mario._t'4 :: mario._t'3 :: mario._t'2
                 :: nil |}.

Definition bc_squish : body_census :=
  {| bc_mptr := mario._m; bc_gates := nil; bc_disp := nil;
     bc_globals := nil; bc_gms := nil;
     bc_chase := mario._t'16 :: mario._t'12 :: mario._t'9 :: mario._t'7
                 :: mario._t'6 :: mario._t'4 :: nil |}.

Definition bc_smq : body_census :=
  {| bc_mptr := mario._m; bc_gates := nil; bc_disp := nil;
     bc_globals := nil; bc_gms := nil;
     bc_chase := mario._o :: mario._t'5 :: mario._t'4 :: mario._t'3
                 :: nil |}.

(* muhacm loads gMarioState into _t'12/_t'14 and chases marioObj through
   them; _gMarioState sits in bc_globals so TI's env row forces the
   global eval (it is NOT in stored_globals, so no store license). *)
Definition bc_muhacm : body_census :=
  {| bc_mptr := mario._m; bc_gates := nil; bc_disp := nil;
     bc_globals := mario._gMarioState :: nil;
     bc_gms := mario._t'12 :: mario._t'14 :: nil;
     bc_chase := mario._bodyState :: mario._t'13 :: mario._t'15
                 :: mario._t'11 :: mario._t'10 :: nil |}.

Lemma chk_mario_reset_bodystate :
  chk bc_mrb (fn_body mario.f_mario_reset_bodystate) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_update_mario_info_for_cam :
  chk bc_umifc (fn_body mario.f_update_mario_info_for_cam) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_squish_mario_model :
  chk bc_squish (fn_body mario.f_squish_mario_model) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_sink_mario_in_quicksand :
  chk bc_smq (fn_body mario.f_sink_mario_in_quicksand) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma chk_mario_update_hitbox_and_cap_model :
  chk bc_muhacm (fn_body mario.f_mario_update_hitbox_and_cap_model) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma params_mario_reset_bodystate :
  fn_params mario.f_mario_reset_bodystate
  = (bc_mptr bc_mrb, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_update_mario_info_for_cam :
  fn_params mario.f_update_mario_info_for_cam
  = (bc_mptr bc_umifc, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_squish_mario_model :
  fn_params mario.f_squish_mario_model
  = (bc_mptr bc_squish, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_sink_mario_in_quicksand :
  fn_params mario.f_sink_mario_in_quicksand
  = (bc_mptr bc_smq, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

Lemma params_mario_update_hitbox_and_cap_model :
  fn_params mario.f_mario_update_hitbox_and_cap_model
  = (bc_mptr bc_muhacm, tptr tyMS) :: nil.
Proof. reflexivity. Qed.

(* muhacm has no fn_vars, so its tabled global is trivially unshadowed *)
Lemma bc_muhacm_globals_novars :
  forall gid, mem_id gid (bc_globals bc_muhacm) = true ->
    mem_id gid
      (var_names (fn_vars mario.f_mario_update_hitbox_and_cap_model))
    = false.
Proof. intros gid _. reflexivity. Qed.

Lemma body_TI_C_mario_reset_bodystate :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_mario_reset_bodystate vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_mrb e le /\
    chk bc_mrb (fn_body mario.f_mario_reset_bodystate) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_mrb ge _ vargs m e le m1 Hentry
             params_mario_reset_bodystate eq_refl eq_refl eq_refl eq_refl
             (nil_globals_novars bc_mrb _ eq_refl) Hmarg).
  - exact chk_mario_reset_bodystate.
Qed.

Lemma body_TI_C_update_mario_info_for_cam :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_info_for_cam vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_umifc e le /\
    chk bc_umifc (fn_body mario.f_update_mario_info_for_cam) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_umifc ge _ vargs m e le m1 Hentry
             params_update_mario_info_for_cam eq_refl eq_refl eq_refl eq_refl
             (nil_globals_novars bc_umifc _ eq_refl) Hmarg).
  - exact chk_update_mario_info_for_cam.
Qed.

Lemma body_TI_C_squish_mario_model :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_squish_mario_model vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_squish e le /\
    chk bc_squish (fn_body mario.f_squish_mario_model) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_squish ge _ vargs m e le m1 Hentry
             params_squish_mario_model eq_refl eq_refl eq_refl eq_refl
             (nil_globals_novars bc_squish _ eq_refl) Hmarg).
  - exact chk_squish_mario_model.
Qed.

Lemma body_TI_C_sink_mario_in_quicksand :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_sink_mario_in_quicksand vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_smq e le /\
    chk bc_smq (fn_body mario.f_sink_mario_in_quicksand) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_smq ge _ vargs m e le m1 Hentry
             params_sink_mario_in_quicksand eq_refl eq_refl eq_refl eq_refl
             (nil_globals_novars bc_smq _ eq_refl) Hmarg).
  - exact chk_sink_mario_in_quicksand.
Qed.

Lemma body_TI_C_mario_update_hitbox_and_cap_model :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge vargs m e le m1,
    function_entry2 ge mario.f_mario_update_hitbox_and_cap_model
      vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm SafeB bc_muhacm e le /\
    chk bc_muhacm (fn_body mario.f_mario_update_hitbox_and_cap_model) = true.
Proof.
  intros Q bm SafeB ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm SafeB bc_muhacm ge _ vargs m e le m1 Hentry
             params_mario_update_hitbox_and_cap_model
             eq_refl eq_refl eq_refl eq_refl
             bc_muhacm_globals_novars Hmarg).
  - exact chk_mario_update_hitbox_and_cap_model.
Qed.

(* ====================================================================== *)
(* THE Hbody DISPATCHER (engine-v2 leaf A, assembled).                     *)
(*                                                                         *)
(* censused_body enumerates the 15 frame-reached mario.prog internal       *)
(* bodies the census covers -- exactly the 17 of                            *)
(* docs/reachable-internal-graph.md MINUS                                   *)
(*   - update_mario_button_inputs (BRIDGED: its controller A-gate needs    *)
(*     the 2-deep memory-dependent chain that a temp-only TI cannot        *)
(*     carry; discharged whole-funcall by                                   *)
(*     AGates.umbi_funcall_marg_preserves_lp), and                          *)
(*   - vec3f_find_ceil (EXEMPT: first param is f32[3], not MarioState ptr) *)
(*                                                                         *)
(* body_TI_C_dispatch is the exact shape of the v2 engine's Hbody leaf at  *)
(*   I  := body_census                                                      *)
(*   TI := TI_of Q bm SafeB                                                 *)
(*   C  := fun bc s => chk bc s = true                                      *)
(* -- the consumer derives `censused_body f` from its concrete Reached_fd  *)
(* (minus the writer/bridged/exempt cases the other leaves own) and gets   *)
(* the census index + entry invariant + body census in one step.           *)
(* ====================================================================== *)

Definition censused_body (f : Clight.function) : Prop :=
  f = mario.f_mario_get_floor_class \/
  f = mario.f_mario_get_terrain_sound_addend \/
  f = mario.f_mario_floor_is_slippery \/
  f = mario.f_debug_print_speed_action_normal \/
  f = mario.f_update_and_return_cap_flags \/
  f = mario.f_set_submerged_cam_preset_and_spawn_bubbles \/
  f = mario.f_update_mario_health \/
  f = mario.f_update_mario_joystick_inputs \/
  f = mario.f_update_mario_inputs \/
  f = mario.f_update_mario_geometry_inputs \/
  f = mario.f_mario_reset_bodystate \/
  f = mario.f_update_mario_info_for_cam \/
  f = mario.f_squish_mario_model \/
  f = mario.f_sink_mario_in_quicksand \/
  f = mario.f_mario_update_hitbox_and_cap_model.

Theorem body_TI_C_dispatch :
  forall (Q : int -> Prop) bm (SafeB : block -> Prop) ge f vargs m e le m1,
    censused_body f ->
    function_entry2 ge f vargs m e le m1 ->
    marg_ok bm vargs ->
    exists bc, TI_of Q bm SafeB bc e le /\ chk bc (fn_body f) = true.
Proof.
  intros Q bm SafeB ge f vargs m e le m1 HC Hentry Hmarg.
  destruct HC as
    [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | ->]]]]]]]]]]]]]].
  - exists bc_m0.
    exact (body_TI_C_mario_get_floor_class Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_m0.
    exact (body_TI_C_mario_get_terrain_sound_addend Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_m0.
    exact (body_TI_C_mario_floor_is_slippery Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_m0.
    exact (body_TI_C_debug_print_speed_action_normal Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_m0.
    exact (body_TI_C_update_and_return_cap_flags Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_m0.
    exact (body_TI_C_set_submerged_cam_preset_and_spawn_bubbles Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_m0.
    exact (body_TI_C_update_mario_health Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_umji.
    exact (body_TI_C_update_mario_joystick_inputs Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_umi.
    exact (body_TI_C_update_mario_inputs Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_ugeo.
    exact (body_TI_C_update_mario_geometry_inputs Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_mrb.
    exact (body_TI_C_mario_reset_bodystate Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_umifc.
    exact (body_TI_C_update_mario_info_for_cam Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_squish.
    exact (body_TI_C_squish_mario_model Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_smq.
    exact (body_TI_C_sink_mario_in_quicksand Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
  - exists bc_muhacm.
    exact (body_TI_C_mario_update_hitbox_and_cap_model Q bm SafeB ge vargs m e le m1 Hentry Hmarg).
Qed.

(* every censused body takes MarioState* first: the dispatcher serves      *)
(* exactly Hbody's marg_exempt = false case (so the consumer's marg        *)
(* premise is available, never vacuous).                                    *)
Lemma censused_body_nonexempt :
  forall f, censused_body f -> marg_exempt (Internal f) = false.
Proof.
  intros f HC.
  destruct HC as
    [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | ->]]]]]]]]]]]]]];
    reflexivity.
Qed.

(* The sargs channel (sub32i / sem_cast_sub32i_vint / sig_sub32 /         *)
(* sargs_ok) lives in ActionValueFrame.v: the v2 engine's Scall case      *)
(* discharges the gate from the exec_Scall type_of_fundef pin, so the     *)
(* funcall-leaf interfaces (Hbridged/Hexempt -> Hrest_pres -> body_pres_s *)
(* for spawn_wind_particles) carry Vint-pinned args instead of the        *)
(* forall-vargs phantom.                                                  *)
