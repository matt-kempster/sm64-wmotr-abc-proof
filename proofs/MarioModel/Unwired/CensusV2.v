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
(*  - Sassign / Scall / Sbuiltin are STRICT placeholders (false) in this    *)
(*    first cut: only store-free, call-free fragments pass. Widening these   *)
(*    rules (store classes + call classes) is the next brick; keeping them   *)
(*    false is sound -- bodies simply do not pass census yet.               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario.
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
  bc_globals : list ident   (* the globals THIS body stores (class G) *)
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
   (alloc_variables domain) and passed through verbatim. *)
Definition TI_of (Q : int -> Prop) (bm : block) (bc : body_census)
    (e : env) (le : temp_env) : Prop :=
  (forall b o, le ! (bc_mptr bc) = Some (Vptr b o) ->
     b = bm /\ o = Ptrofs.zero) /\
  (forall t, mem_id t (bc_gates bc) = true ->
     forall vi, le ! t = Some (Vint vi) ->
       Int.and vi (Int.repr 2) = Int.zero) /\
  (forall t, mem_id t (bc_disp bc) = true ->
     forall vi, le ! t = Some (Vint vi) -> Q vi) /\
  (forall gid, mem_id gid (bc_globals bc) = true -> e ! gid = None).

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

Definition exempt_callees : list ident :=
  mario._sqrtf :: mario._atan2s :: mario._print_text_fmt_int ::
  mario._set_camera_mode :: mario._vec3f_set :: mario._stop_cap_music ::
  mario._fadeout_cap_music :: mario._f32_find_wall_collision ::
  mario._find_floor :: mario._vec3f_copy :: mario._vec3f_find_ceil ::
  mario._find_ceil :: mario._find_poison_gas_level ::
  mario._find_water_level :: mario._level_trigger_warp ::
  mario._play_sound :: mario._vec3s_copy :: mario._stub_mario_step_1 :: nil.

Definition call_optid_ok (bc : body_census) (optid : option ident) : bool :=
  match optid with
  | None => true
  | Some rid =>
      negb (Pos.eqb rid (bc_mptr bc))
      && negb (mem_id rid (bc_gates bc))
      && negb (mem_id rid (bc_disp bc))
  end.

Definition call_head_is_mptr (bc : body_census) (al : list expr) : bool :=
  match al with
  | Etempvar p pty :: _ =>
      Pos.eqb p (bc_mptr bc) && proj_sumbool (type_eq pty (tptr tyMS))
  | _ => false
  end.

Definition call_callee_exempt (a : expr) : bool :=
  match a with
  | Evar fid _ => mem_id fid exempt_callees
  | _ => false
  end.

(* ====================================================================== *)
(* The store census, class F: a direct `m->field` store whose byte window  *)
(* avoids ALL the protected cells --                                       *)
(*   [2,4)     m->input      (input_a_clear's cell)                        *)
(*   [12,16)   m->action     (action_sat's cell)                           *)
(*   [156,160) m->controller (ctl_a_clear's chase root)                    *)
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
  && ((delta + sz <=? 156) || (160 <=? delta)).

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
  mario._gCameraMovementFlags :: nil.

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
      || global_store_ok bc a1
  | Scall optid a al =>
      call_optid_ok bc optid
      && (call_head_is_mptr bc al || call_callee_exempt a)
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
    forall Q bm bc e le m a s1 s2 v1 b,
      chk bc (Sifthenelse a s1 s2) = true ->
      TI_of Q bm bc e le ->
      eval_expr (lp_ge lp) e le m a v1 ->
      bool_val v1 (typeof a) m = Some b ->
      chk bc (if b then s1 else s2) = true.
  Proof.
    intros Q bm bc e le m a s1 s2 v1 b HC HTI Hev Hbv.
    change ((if gate_if bc a then chk bc s2 else chk bc s1 && chk bc s2)
            = true) in HC.
    (* destruct abstracts + reduces the occurrence in HC too *)
    destruct (gate_if bc a) eqn:Hg.
    - (* censused gate: THEN is dead.  HC : chk bc s2 = true *)
      unfold gate_if in Hg.
      destruct (input_guard_temp a) as [t|] eqn:Hgt; [ | discriminate Hg ].
      pose proof (input_guard_temp_shape _ _ Hgt) as Hshape. subst a.
      destruct (guard_temp_vint lp _ _ _ _ _ _ Hev) as (vi & Hlet & Hv1).
      destruct HTI as (_ & Hgate & _ & _).
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
    forall bm bc e le m a ls v n,
      chk bc (Sswitch a ls) = true ->
      TI_of not_tainted bm bc e le ->
      eval_expr (lp_ge lp) e le m a v ->
      sem_switch_arg v (typeof a) = Some n ->
      chk bc (seq_of_labeled_statement (select_switch n ls)) = true.
  Proof.
    intros bm bc e le m a ls v n HC HTI Hev Hsa.
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
      destruct HTI as (_ & _ & Hdisp & _).
      pose proof (Hdisp t Hd i Hev) as Hnt.
      apply chk_seq_of, (chk_disp_select bc _ _ HC).
      exact (not_tainted_not_T_label _ Hnt).
    - (* ordinary switch: every suffix censused *)
      apply chk_seq_of, (chk_all_select bc _ _ HC).
  Qed.

  (* ---- HTI_set: the table maintenance. The census forbids Sset to the
     Mario param; an Sset to a tabled gate temp is the canonical input
     load, whose value is bit-1-clear under input_a_clear; an Sset to a
     tabled dispatch temp is the canonical action load, whose value
     satisfies Q under action_sat. Everything else is gso. ---- *)
  Lemma chk_ti_set :
    forall Q bm bc e le m id a v,
      input_a_clear m bm ->
      action_sat Q m bm ->
      eval_expr (lp_ge lp) e le m a v ->
      TI_of Q bm bc e le ->
      chk bc (Sset id a) = true ->
      TI_of Q bm bc e (PTree.set id v le).
  Proof.
    intros Q bm bc e le m id a v Hinp Hsat Hev HTI HC.
    change ((negb (Pos.eqb id (bc_mptr bc))
             && (negb (mem_id id (bc_gates bc))
                 || is_input_load_x (bc_mptr bc) a)
             && (negb (mem_id id (bc_disp bc))
                 || is_action_load_x (bc_mptr bc) a)) = true) in HC.
    apply andb_true_iff in HC as [HC Hdisp_rule].
    apply andb_true_iff in HC as [Hnm Hgate_rule].
    destruct HTI as (Hm & Hgate & Hdisp & Hglob).
    split; [ | split; [ | split ] ]; [ | | | exact Hglob ].
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
    - (* dispatch temps *)
      intros t Hmem vi Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hdisp_rule. cbn [negb orb] in Hdisp_rule.
        pose proof (is_action_load_x_shape _ _ Hdisp_rule) as Hshape. subst a.
        destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev) as (pb & po & Hpm).
        destruct (Hm _ _ Hpm) as [E1 E2]. subst pb po.
        pose proof (eval_action_load_bm_lp lp LO_mario _ _ _ _ _ _ Hpm Hev)
          as Hload.
        exact (Hsat vi Hload).
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hdisp t Hmem vi Hlk).
  Qed.

  (* ---- HTI_optc: a censused call's result temp is untabled, so TI is
     pure gso.  (The engine's non-bm-pointer fact about the result value
     is not even needed.) ---- *)
  Lemma chk_ti_optc :
    forall Q bm bc e optid a al v le,
      chk bc (Scall optid a al) = true ->
      TI_of Q bm bc e le ->
      TI_of Q bm bc e (set_opttemp optid v le).
  Proof.
    intros Q bm bc e optid a al v le HC HTI.
    change ((call_optid_ok bc optid
             && (call_head_is_mptr bc al || call_callee_exempt a)) = true)
      in HC.
    apply andb_true_iff in HC as [Hopt _].
    destruct optid as [rid|]; cbn [set_opttemp]; [ | exact HTI ].
    change ((negb (Pos.eqb rid (bc_mptr bc))
             && negb (mem_id rid (bc_gates bc))
             && negb (mem_id rid (bc_disp bc))) = true) in Hopt.
    apply andb_true_iff in Hopt as [Hopt Hrd].
    apply andb_true_iff in Hopt as [Hrm Hrg].
    destruct HTI as (Hm & Hg & Hd & Hgl).
    split; [ | split; [ | split ] ]; [ | | | exact Hgl ].
    - intros b o Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst rid; rewrite Pos.eqb_refl in Hrm; discriminate Hrm).
      exact (Hm b o Hlk).
    - intros t Hmem vi Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst t; rewrite Hmem in Hrg; discriminate Hrg).
      exact (Hg t Hmem vi Hlk).
    - intros t Hmem vi Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst t; rewrite Hmem in Hrd; discriminate Hrd).
      exact (Hd t Hmem vi Hlk).
  Qed.

  (* ---- Hcallmarg: a censused call's evaluated args satisfy the EXACT
     marg_ok whenever the callee is non-exempt.  Class M: the head is the
     body's Mario param -- its value pins to (bm,0) via TI, and sem_cast
     passes pointers through identically.  Class E: the whitelist residual
     says the callee IS exempt, contradicting the premise. ---- *)
  Lemma chk_call_marg :
    forall Q bm bc e le m optid a al tyargs vargs vf fd,
      TI_of Q bm bc e le ->
      chk bc (Scall optid a al) = true ->
      eval_expr (lp_ge lp) e le m a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = false ->
      eval_exprlist (lp_ge lp) e le m al tyargs vargs ->
      marg_ok bm vargs.
  Proof.
    intros Q bm bc e le m optid a al tyargs vargs vf fd
           HTI HC Hevf Hff Hnex Hargs.
    change ((call_optid_ok bc optid
             && (call_head_is_mptr bc al || call_callee_exempt a)) = true)
      in HC.
    apply andb_true_iff in HC as [_ HC].
    apply orb_true_iff in HC as [HM | HE].
    - (* class M: head = Etempvar mptr *)
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
          destruct HTI as (Hm & _ & _ & _);
          exact (Hm _ _ Hv1)
      end.
    - (* class E: the callee is whitelisted-exempt *)
      unfold call_callee_exempt in HE.
      destruct a; try discriminate HE.
      rewrite (WL_exempt _ _ _ _ _ _ _ HE Hevf Hff) in Hnex.
      discriminate Hnex.
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

  (* ---- Hassign (class F): a censused m->field store preserves valid,
     action_sat, and -- via the caller-supplied window-closure -- MWF.
     The TI mptr row pins the base to (bm,0); the census window keeps the
     written bytes off the action cell entirely. ---- *)
  Lemma chk_assign :
    forall (Q : int -> Prop) (MWF : mem -> Prop) bm bc
           e le m a1 a2 loc ofs bf v2 v m',
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
      eval_lvalue (lp_ge lp) e le m a1 loc ofs bf ->
      eval_expr (lp_ge lp) e le m a2 v2 ->
      sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
      assign_loc (lp_ge lp) (typeof a1) m loc ofs bf v m' ->
      TI_of Q bm bc e le ->
      chk bc (Sassign a1 a2) = true ->
      MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
      Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.
  Proof.
    intros Q MWF bm bc e le m a1 a2 loc ofs bf v2 v m'
           HMWFstore HMWFinp HG Hlv Hev2 Hcast Has HTI HC HMWF Hvb Hsat.
    change (((safe_mfield_store (bc_mptr bc) a1
              || input_store_ok bc a1 a2)
             || global_store_ok bc a1) = true) in HC.
    apply orb_true_iff in HC as [HC | HCG].
    2:{ (* ---- class G: whitelisted off-Mario global store ---- *)
      destruct (global_store_ok_shape _ _ HCG)
        as (gid & gty & ch & Hshape & Hbcg & Hsg & Hac).
      subst a1.
      destruct HTI as (_ & _ & _ & Hglob).
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
      destruct HTI as (Hm & Hgate & _ & _).
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
    destruct HTI as (Hm & _ & _ & _).
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
  forall (Q : int -> Prop) (bm : block) (bc : body_census)
         ge f vargs m e le m1,
    function_entry2 ge f vargs m e le m1 ->
    fn_params f = (bc_mptr bc, tptr tyMS) :: nil ->
    mem_id (bc_mptr bc) (bc_gates bc) = false ->
    mem_id (bc_mptr bc) (bc_disp bc) = false ->
    (forall gid, mem_id gid (bc_globals bc) = true ->
       mem_id gid (var_names (fn_vars f)) = false) ->
    marg_ok bm vargs ->
    TI_of Q bm bc e le.
Proof.
  intros Q bm bc ge f vargs m e le m1 Hentry Hparams Hng Hnd Hnvars Hmarg.
  inv Hentry.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    rewrite Hparams in Hb;
    destruct vargs as [| v0 [| v1 vs ]]; cbn in Hb; try discriminate Hb;
    inv Hb end.
  split; [ | split; [ | split ] ].
  - (* the mptr row: exact marg *)
    intros b o Hlk. rewrite PTree.gss in Hlk. inv Hlk.
    exact Hmarg.
  - (* gate temps: Vundef at entry *)
    intros t Hmem vi Hlk.
    destruct (Pos.eq_dec t (bc_mptr bc)) as [E|NE].
    + subst t. rewrite Hmem in Hng. discriminate Hng.
    + rewrite PTree.gso in Hlk by exact NE.
      apply create_undef_temps_Vundef in Hlk. discriminate Hlk.
  - (* dispatch temps: Vundef at entry *)
    intros t Hmem vi Hlk.
    destruct (Pos.eq_dec t (bc_mptr bc)) as [E|NE].
    + subst t. rewrite Hmem in Hnd. discriminate Hnd.
    + rewrite PTree.gso in Hlk by exact NE.
      apply create_undef_temps_Vundef in Hlk. discriminate Hlk.
  - (* env row: stored globals are not this body's locals *)
    intros gid Hg.
    match goal with Hav : alloc_variables _ empty_env _ _ _ _ |- _ =>
      refine (alloc_variables_notin_none _ _ _ _ _ _ Hav gid _ _) end.
    + apply PTree.gempty.
    + apply mem_id_false_notin. exact (Hnvars gid Hg).
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
     bc_globals := nil |}.

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
     bc_globals := nil |}.

Definition bc_ugeo : body_census :=
  {| bc_mptr := mario._m;
     bc_gates := mario._t'29 :: mario._t'21 :: mario._t'20
                 :: mario._t'17 :: mario._t'14 :: nil;
     bc_disp := nil; bc_globals := nil |}.

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
     bc_globals := mario._gCameraMovementFlags :: nil |}.

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
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_mario_get_floor_class vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_mario_get_floor_class) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_mario_get_floor_class bc_m0_gates_disjoint
             bc_m0_disp_disjoint (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_mario_get_floor_class.
Qed.

Lemma body_TI_C_mario_get_terrain_sound_addend :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_mario_get_terrain_sound_addend vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_mario_get_terrain_sound_addend) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_mario_get_terrain_sound_addend bc_m0_gates_disjoint
             bc_m0_disp_disjoint (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_mario_get_terrain_sound_addend.
Qed.

Lemma body_TI_C_mario_floor_is_slippery :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_mario_floor_is_slippery vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_mario_floor_is_slippery) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_mario_floor_is_slippery bc_m0_gates_disjoint
             bc_m0_disp_disjoint (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_mario_floor_is_slippery.
Qed.

Lemma body_TI_C_debug_print_speed_action_normal :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_debug_print_speed_action_normal vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_debug_print_speed_action_normal) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_debug_print_speed_action_normal bc_m0_gates_disjoint
             bc_m0_disp_disjoint (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_debug_print_speed_action_normal.
Qed.

Lemma body_TI_C_update_and_return_cap_flags :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_update_and_return_cap_flags vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_update_and_return_cap_flags) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_update_and_return_cap_flags bc_m0_gates_disjoint
             bc_m0_disp_disjoint (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_update_and_return_cap_flags.
Qed.

Lemma body_TI_C_set_submerged_cam_preset_and_spawn_bubbles :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_set_submerged_cam_preset_and_spawn_bubbles
      vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_set_submerged_cam_preset_and_spawn_bubbles)
      = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_set_submerged_cam_preset_and_spawn_bubbles
             bc_m0_gates_disjoint bc_m0_disp_disjoint
             (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_set_submerged_cam_preset_and_spawn_bubbles.
Qed.

Lemma body_TI_C_update_mario_health :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_health vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_m0 e le /\
    chk bc_m0 (fn_body mario.f_update_mario_health) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_m0 ge _ vargs m e le m1 Hentry
             params_update_mario_health bc_m0_gates_disjoint
             bc_m0_disp_disjoint (nil_globals_novars bc_m0 _ eq_refl) Hmarg).
  - exact chk_update_mario_health.
Qed.

Lemma body_TI_C_update_mario_joystick_inputs :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_joystick_inputs vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_umji e le /\
    chk bc_umji (fn_body mario.f_update_mario_joystick_inputs) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_umji ge _ vargs m e le m1 Hentry
             params_update_mario_joystick_inputs bc_umji_gates_disjoint
             bc_umji_disp_disjoint (nil_globals_novars bc_umji _ eq_refl) Hmarg).
  - exact chk_update_mario_joystick_inputs.
Qed.

Lemma body_TI_C_update_mario_inputs :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_inputs vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_umi e le /\
    chk bc_umi (fn_body mario.f_update_mario_inputs) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_umi ge _ vargs m e le m1 Hentry
             params_update_mario_inputs bc_umi_gates_disjoint
             bc_umi_disp_disjoint bc_umi_globals_novars Hmarg).
  - exact chk_update_mario_inputs.
Qed.

Lemma body_TI_C_update_mario_geometry_inputs :
  forall (Q : int -> Prop) bm ge vargs m e le m1,
    function_entry2 ge mario.f_update_mario_geometry_inputs vargs m e le m1 ->
    marg_ok bm vargs ->
    TI_of Q bm bc_ugeo e le /\
    chk bc_ugeo (fn_body mario.f_update_mario_geometry_inputs) = true.
Proof.
  intros Q bm ge vargs m e le m1 Hentry Hmarg.
  split.
  - exact (entry_TI_v2 Q bm bc_ugeo ge _ vargs m e le m1 Hentry
             params_update_mario_geometry_inputs bc_ugeo_gates_disjoint
             bc_ugeo_disp_disjoint (nil_globals_novars bc_ugeo _ eq_refl) Hmarg).
  - exact chk_update_mario_geometry_inputs.
Qed.
