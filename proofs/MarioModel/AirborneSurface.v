(* ====================================================================== *)
(* THE AIRBORNE SURFACE: Hpres_air DISCHARGED DOWN TO ITS LEAF CALLEES     *)
(* (SPINE: consumed by the MWF-grounded capstone).                         *)
(*                                                                        *)
(* RestSurface left Hpres_air -- whole-funcall preservation for the REAL   *)
(* 628-line f_mario_execute_airborne_action -- as one opaque residual.     *)
(* This file PROVES that body's walk, consuming the proved dispatch kill   *)
(* (AGates.airborne_dispatch_kill_lp): under action_sat not_tainted the    *)
(* switch provably selects a NON-TAINTED arm, so the three T handlers      *)
(* (act_flying, act_flying_triple_jump, act_shot_from_cannon) are dead     *)
(* code, and every statement the body actually executes is either pure     *)
(* (Sset/Sbreak/Sreturn/Sskip) or a call to one of 43 NAMED leaf callees   *)
(* (41 non-T act handlers + the 2 prologue helpers), each pinned to its    *)
(* real generated body by LO_air.                                          *)
(*                                                                        *)
(* The residual that remains (Hpres_callees) is the finite-enumeration     *)
(* form the proof discipline asks for: ONE per-symbol-keyed hypothesis     *)
(* over the CONCRETE census list airborne_callee_ids, whose instances are  *)
(* body_pres facts about the small leaf bodies -- dischargeable one id at  *)
(* a time (peel a row off the census, prove that act's walk).              *)
(*                                                                        *)
(* PIPELINE: the case table, the arm shapes and the callee censuses are    *)
(* all PROJECTED from the generated AST and checked by vm_compute          *)
(* reflexivity -- never hand-written.                                      *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface.

Import ListNotations.

(* ====================================================================== *)
(* The leaf-callee census (top-level: no lp).                              *)
(* ====================================================================== *)

(* the 41 non-T act handlers reachable from the dispatch switch, plus the
   two prologue helpers.  Every Scall the body can actually execute under
   action_sat not_tainted targets one of these idents (checked by the
   vm_compute censuses below); the three T handlers are NOT here -- their
   arms are dead under the dispatch kill. *)
Definition airborne_callee_ids : list ident :=
  mario_actions_airborne._check_common_airborne_cancels ::
  mario_actions_airborne._play_far_fall_sound ::
  mario_actions_airborne._act_jump ::
  mario_actions_airborne._act_double_jump ::
  mario_actions_airborne._act_freefall ::
  mario_actions_airborne._act_hold_jump ::
  mario_actions_airborne._act_hold_freefall ::
  mario_actions_airborne._act_side_flip ::
  mario_actions_airborne._act_wall_kick_air ::
  mario_actions_airborne._act_twirling ::
  mario_actions_airborne._act_water_jump ::
  mario_actions_airborne._act_hold_water_jump ::
  mario_actions_airborne._act_steep_jump ::
  mario_actions_airborne._act_burning_jump ::
  mario_actions_airborne._act_burning_fall ::
  mario_actions_airborne._act_triple_jump ::
  mario_actions_airborne._act_backflip ::
  mario_actions_airborne._act_long_jump ::
  mario_actions_airborne._act_riding_shell_air ::
  mario_actions_airborne._act_dive ::
  mario_actions_airborne._act_air_throw ::
  mario_actions_airborne._act_backward_air_kb ::
  mario_actions_airborne._act_forward_air_kb ::
  mario_actions_airborne._act_hard_backward_air_kb ::
  mario_actions_airborne._act_hard_forward_air_kb ::
  mario_actions_airborne._act_butt_slide_air ::
  mario_actions_airborne._act_hold_butt_slide_air ::
  mario_actions_airborne._act_lava_boost ::
  mario_actions_airborne._act_getting_blown ::
  mario_actions_airborne._act_air_hit_wall ::
  mario_actions_airborne._act_forward_rollout ::
  mario_actions_airborne._act_backward_rollout ::
  mario_actions_airborne._act_crazy_box_bounce ::
  mario_actions_airborne._act_special_triple_jump ::
  mario_actions_airborne._act_ground_pound ::
  mario_actions_airborne._act_thrown_forward ::
  mario_actions_airborne._act_thrown_backward ::
  mario_actions_airborne._act_soft_bonk ::
  mario_actions_airborne._act_jump_kick ::
  mario_actions_airborne._act_riding_hoot ::
  mario_actions_airborne._act_top_of_pole_jump ::
  mario_actions_airborne._act_vertical_wind ::
  mario_actions_airborne._act_slide_kick :: nil.

(* the uniform Mario-arg leaf-call type, as generated *)
Definition tyMSp : type :=
  tptr (Tstruct mario_actions_airborne._MarioState noattr).
Definition tyAct : type := Tfunction (tyMSp :: nil) tint cc_default.

(* ---- the uniform arm shape, recognized by PROJECTION. A dispatch arm is
   `t'N := act_X(m); cancel := t'N; break` -- arm_split extracts (t'N, X)
   and checks every fixed piece (param temp, cancel temp, callee type). ---- *)
Definition arm_split (s : statement) : option (ident * ident) :=
  match s with
  | Ssequence
      (Ssequence
         (Scall (Some tmp) (Evar fid fty) (Etempvar pm pty :: nil))
         (Sset cid (Etempvar tmp2 tty)))
      Sbreak =>
      if Pos.eqb pm mario_actions_airborne._m
         && Pos.eqb cid mario_actions_airborne._cancel
         && Pos.eqb tmp tmp2
         && proj_sumbool (type_eq fty tyAct)
         && proj_sumbool (type_eq pty tyMSp)
         && proj_sumbool (type_eq tty tint)
      then Some (tmp, fid) else None
  | _ => None
  end.

Lemma arm_split_shape :
  forall s tmp fid,
    arm_split s = Some (tmp, fid) ->
    s = Ssequence
          (Ssequence
             (Scall (Some tmp) (Evar fid tyAct)
                (Etempvar mario_actions_airborne._m tyMSp :: nil))
             (Sset mario_actions_airborne._cancel (Etempvar tmp tint)))
          Sbreak.
Proof.
  intros s tmp fid H. unfold arm_split in H.
  destruct s; try discriminate H.
  destruct s1; try discriminate H.
  destruct s1_1; try discriminate H.
  destruct o; try discriminate H.
  destruct e; try discriminate H.
  destruct l; try discriminate H.
  destruct e; try discriminate H.
  destruct l; try discriminate H.
  destruct s1_2; try discriminate H.
  destruct e; try discriminate H.
  destruct s2; try discriminate H.
  destruct (Pos.eqb i1 mario_actions_airborne._m) eqn:Hpm;
    [ | cbn in H; discriminate H ].
  destruct (Pos.eqb i2 mario_actions_airborne._cancel) eqn:Hcid;
    [ | cbn in H; discriminate H ].
  destruct (Pos.eqb i i3) eqn:Htmp; [ | cbn in H; discriminate H ].
  destruct (type_eq t tyAct) as [-> | ];
    [ | cbn in H; discriminate H ].
  destruct (type_eq t0 tyMSp) as [-> | ];
    [ | cbn in H; discriminate H ].
  destruct (type_eq t1 tint) as [-> | ];
    [ | cbn in H; discriminate H ].
  cbn in H. injection H as <- <-.
  apply Pos.eqb_eq in Hpm. apply Pos.eqb_eq in Hcid. apply Pos.eqb_eq in Htmp.
  subst. reflexivity.
Qed.

(* ---- the arm census: every suffix of the case table a NON-TAINTED
   selector can land on resolves (through C fall-through skips) to either
   nothing at all or to a uniform arm whose callee is on the census list. ---- *)
Definition arm_tabled (s : statement) : bool :=
  match arm_split s with
  | Some (_, fid) => mem_id fid airborne_callee_ids
  | None => false
  end.

Definition suffix_tabled (sl : labeled_statements) : bool :=
  match drop_skips sl with
  | LSnil => true
  | LScons _ s _ => arm_tabled s
  end.

Lemma suffix_tabled_LSnil : suffix_tabled LSnil = true.
Proof. reflexivity. Qed.

Example airborne_arms_tabled :
  nonT_suffixes_ok suffix_tabled airborne_cases = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the census is not vacuous -- an empty table fails it. *)
Example airborne_arms_census_not_vacuous :
  nonT_suffixes_ok
    (fun sl => match drop_skips sl with
               | LSnil => true
               | LScons _ s _ => match arm_split s with
                                 | Some _ => false | None => false
                                 end
               end)
    airborne_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the defmap census: every censused callee ident is defined as an
   INTERNAL function by the airborne TU itself (so LO_air pins its lp
   resolution to that real body). `internal_in` takes the defmap as an
   argument so vm_compute builds the TU defmap ONCE for the whole list. ---- *)
Definition internal_in (dm : PTree.t (globdef Clight.fundef type))
    (fid : ident) : bool :=
  match dm ! fid with
  | Some (Gfun (Internal _)) => true
  | _ => false
  end.

Example airborne_callees_internal :
  forallb (internal_in (prog_defmap mario_actions_airborne.prog))
    airborne_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* split out with dm a VARIABLE: destructing the applied defmap lookup in a
   heavy proof context grinds (the occurrence abstraction unfolds the TU);
   here the destruct is purely symbolic. *)
Lemma internal_in_spec :
  forall dm fid, internal_in dm fid = true ->
    exists g, dm ! fid = Some (Gfun (Internal g)).
Proof.
  intros dm fid H. unfold internal_in in H.
  destruct (dm ! fid) as [gd | ]; [ | discriminate H ].
  destruct gd as [fd0 | ]; [ | discriminate H ].
  destruct fd0 as [g | ]; [ | discriminate H ].
  eauto.
Qed.

Lemma forallb_mem_id :
  forall (p : ident -> bool) (l : list ident) (fid : ident),
    forallb p l = true -> mem_id fid l = true -> p fid = true.
Proof.
  intros p l fid Hall Hmem. unfold mem_id in Hmem.
  induction l as [| a l IH]; cbn in *; [ discriminate Hmem | ].
  apply andb_prop in Hall as [Hpa Hall].
  apply orb_true_iff in Hmem as [Heq | Hmem].
  - apply Pos.eqb_eq in Heq. subst. exact Hpa.
  - exact (IH Hall Hmem).
Qed.

(* ---- the whole-body shape, by projection (prologue / dispatch / return). ---- *)
Example airborne_body_shape :
  fn_body mario_actions_airborne.f_mario_execute_airborne_action =
  Ssequence
    (Ssequence
       (Scall (Some mario_actions_airborne._t'1)
          (Evar mario_actions_airborne._check_common_airborne_cancels tyAct)
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Sifthenelse (Etempvar mario_actions_airborne._t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
    (Ssequence
       (Scall None
          (Evar mario_actions_airborne._play_far_fall_sound
             (Tfunction (tyMSp :: nil) tvoid cc_default))
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Ssequence
          airborne_dispatch_stmt
          (Sreturn (Some (Etempvar mario_actions_airborne._cancel tuint))))).
Proof. vm_compute. reflexivity. Qed.

(* a pointer-to-pointer sem_cast is the identity on the values that pass it *)
Lemma sem_cast_ptr_ptr_id :
  forall v t1 a1 t2 a2 mm v',
    sem_cast v (Tpointer t1 a1) (Tpointer t2 a2) mm = Some v' -> v' = v.
Proof.
  intros v t1 a1 t2 a2 mm v' H.
  unfold sem_cast in H. cbn in H.
  destruct v; try discriminate H; injection H as <-; reflexivity.
Qed.

(* ====================================================================== *)
(* The walk.                                                               *)
(* ====================================================================== *)

Section AirborneSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_air : linkorder mario_actions_airborne.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  (* NoA is a projection of the run invariant (at the capstone instantiation
     MWF := MWF_real this is the proved mwf_real_ctl). *)
  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.

  (* THE RESIDUAL: per-leaf-callee preservation, keyed by the census list.
     Each instance is a body_pres fact about ONE concrete generated body
     (vm_compute the defmap lookup to expose it); discharging proceeds id
     by id.  This replaces the capstone's whole-dispatcher Hpres_air. *)
  Hypothesis Hpres_callees : forall fid f,
      mem_id fid airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.

  (* ---- a pinned symbol's lp resolution IS its real generated fundef
     (the fd-general form of RestSurface.resolves_pin). ---- *)
  Lemma resolve_pin_fd :
    forall (q : Clight.program) (fid : ident) (f_real : Clight.function)
           (fd : Clight.fundef),
      linkorder q lp ->
      (prog_defmap q) ! fid = Some (Gfun (Internal f_real)) ->
      resolves_lp lp fid fd ->
      fd = Internal f_real.
  Proof.
    intros q fid f_real fd LOq Hdm Hres.
    destruct Hres as (b & Hsym & Hff).
    destruct (linkorder_resolves_funct lp q fid f_real LOq Hdm)
      as (b' & Hsym' & Hff').
    unfold lp_ge in Hsym, Hff.
    rewrite Hsym in Hsym'. injection Hsym' as <-.
    rewrite Hff in Hff'. injection Hff' as <-. reflexivity.
  Qed.

  (* ---- a censused callee funcall preserves the carried state. ---- *)
  Lemma tabled_call_pres :
    forall fid fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      mem_id fid airborne_callee_ids = true ->
      resolves_lp lp fid fd ->
      marg_ok bm vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.
  Proof.
    intros fid fd m0 vargs0 t0 m1 vres0 Hevf Hmem Hres Hmarg HN HM HV HS.
    pose proof (forallb_mem_id _ _ _ airborne_callees_internal Hmem) as Hint.
    destruct (internal_in_spec _ _ Hint) as (g & Hdm).
    pose proof (resolve_pin_fd _ _ _ _ LO_air Hdm Hres) as ->.
    destruct (Hpres_callees fid g Hmem Hdm m0 vargs0 t0 m1 vres0
                (fun _ => Hmarg) Hevf HN HM HV HS) as (HV' & HS' & HM').
    repeat split; [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* ---- the uniform call-site step: executing `Scall optid (Evar fid ty)
     [m]` at the empty env, where fid is censused and the _m temp carries
     only Mario's pointer (if any), preserves the carried state and yields
     Out_normal with the expected temp update. ---- *)
  Lemma tabled_scall_pres :
    forall optid fid rty cc le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSp :: nil) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp :: nil))
        tr le1 m1 out0 ->
      mem_id fid airborne_callee_ids = true ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid rty cc le0 m0 tr le1 m1 out0 Hexec Hmem Htat HN HM HV HS.
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
    | Ha : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl
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
    | Hv1' : le0 ! _ = Some ?vv |- _ =>
        assert (Hmarg : marg_ok bm (vv :: nil))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: nil) _ _ _ |- _ =>
        destruct (tabled_call_pres _ _ _ _ _ _ _ Hevf Hmem Hres Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* ---- the dispatch execution forces the _m temp to hold a pointer
     (its Sset loads m->action through it). ---- *)
  Lemma dispatch_m_is_ptr :
    forall le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0
        airborne_dispatch_stmt tr le' m' out ->
      exists l o, le ! mario_actions_airborne._m = Some (Vptr l o).
  Proof.
    intros le m0 tr le' m' out Hexec.
    rewrite airborne_dispatch_shape in Hexec.
    assert (Hset : exists v,
               eval_expr (lp_ge lp) empty_env le m0
                 (Efield (Ederef
                            (Etempvar mario_actions_airborne._m
                               (tptr (Tstruct mario._MarioState noattr)))
                            (Tstruct mario._MarioState noattr))
                    mario._action tuint) v).
    { inv Hexec;
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs
        end;
        eexists; eassumption. }
    destruct Hset as (v & Hev).
    apply eval_expr_Efield_load in Hev.
    destruct Hev as (loc & ofs & bf & Hlv & _).
    apply eval_lvalue_Efield_inv in Hlv.
    destruct Hlv as (o0 & id & att & co & delta & Hbase & _).
    apply eval_expr_Ederef_load in Hbase.
    destruct Hbase as (l2 & o2 & bf2 & Hlv2 & _).
    apply eval_lvalue_Ederef_base in Hlv2.
    apply eval_expr_Etempvar_val in Hlv2.
    eauto.
  Qed.

  (* ================================================================== *)
  (* THE DISPATCH WALK: under the carried invariant, executing the real  *)
  (* dispatch fragment preserves the state and falls through normally -- *)
  (* the selected arm is one censused leaf call (or no arm runs at all). *)
  (* ================================================================== *)
  Lemma airborne_dispatch_pres :
    forall le m0 tr le' m' out,
      le ! mario_actions_airborne._m = Some (Vptr bm Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0
        airborne_dispatch_stmt tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\
      MWF m' /\ NoA m' /\ out = Out_normal.
  Proof.
    intros le m0 tr le' m' out Hle HN HM HV HS Hexec.
    destruct (airborne_dispatch_kill_lp lp LO_mario empty_env le m0 bm
                tr le' m' out Hle HS Hexec)
      as (v & out1 & Hload & Hnt & Hlab & _ & Hout & Hrun).
    pose proof (select_switch_nonT_ok suffix_tabled (Int.unsigned v)
                  airborne_cases airborne_arms_tabled Hlab
                  suffix_tabled_LSnil) as Htab.
    apply exec_seq_drop_skips in Hrun.
    unfold suffix_tabled in Htab.
    destruct (drop_skips (select_switch (Int.unsigned v) airborne_cases))
      as [| o s_arm tail] eqn:E.
    - (* no real arm: the switch is a no-op *)
      cbn [seq_of_labeled_statement] in Hrun. inv Hrun. try subst out.
      cbn [outcome_switch].
      repeat split; try assumption; reflexivity.
    - (* exactly one censused arm *)
      unfold arm_tabled in Htab.
      destruct (arm_split s_arm) as [[tmp fid] | ] eqn:Esplit;
        [ | discriminate Htab ].
      apply arm_split_shape in Esplit. subst s_arm.
      cbn [seq_of_labeled_statement] in Hrun.
      inv Hrun.
      + (* the arm finished Out_normal: impossible, it ends in Sbreak *)
        exfalso.
        match goal with
        | Hs : exec_stmt _ _ _ ?le0 _ (Ssequence ?s1 Sbreak) _ _ _ Out_normal |- _ =>
            exact (ends_in_break_not_normal lp _ _ _ (Ssequence s1 Sbreak)
                     _ _ _ _ eq_refl Hs eq_refl)
        end.
      + (* only the arm ran; the textual tail is dead *)
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Ssequence _ Sbreak) _ _ _ _ |- _ =>
            rename Hs into Harm
        end.
        inv Harm.
        * (* inner normal, then Sbreak *)
          match goal with
          | Hb : exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ => inv Hb
          end.
          match goal with
          | Hi : exec_stmt _ _ _ _ _ (Ssequence _ (Sset _ _)) _ _ _ _ |- _ =>
              rename Hi into Hinner
          end.
          inv Hinner.
          -- (* the call, then the cancel Sset *)
             match goal with
             | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs
             end.
             match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
                 rename Hc into Hcall
             end.
             assert (Htat2 : forall b' o',
                        (PTree.set mario_actions_airborne._t'46 (Vint v) le)
                          ! mario_actions_airborne._m = Some (Vptr b' o') ->
                        b' = bm /\ o' = Ptrofs.zero).
             { intros b' o' Hg.
               rewrite PTree.gso in Hg
                 by (intro HH; vm_compute in HH; discriminate HH).
               rewrite Hle in Hg. injection Hg as Hg1 Hg2. subst.
               split; reflexivity. }
             destruct (tabled_scall_pres _ _ _ _ _ _ _ _ _ _ Hcall
                         Htab Htat2 HN HM HV HS)
               as (HV' & HS' & HM' & HN' & _ & _).
             try subst out.
             cbn [outcome_switch].
             repeat split; try assumption; reflexivity.
          -- (* the call alone ended non-normally: Scall is Out_normal *)
             exfalso.
             match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ ?o,
               Hn : ?o <> Out_normal |- _ => inv Hc; congruence
             end.
        * (* the arm itself ended non-normally before Sbreak: the inner
             call+set sequence is always Out_normal *)
          exfalso.
          match goal with
          | Hi : exec_stmt _ _ _ _ _ (Ssequence _ (Sset _ _)) _ _ _ ?o,
            Hn : ?o <> Out_normal |- _ => rename Hi into Hinner
          end.
          inv Hinner;
            [ match goal with
              | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
                  inv Hs; congruence
              end
            | match goal with
              | Hc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
                  inv Hc; congruence
              end ].
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_air itself, PROVED from the per-leaf residuals.   *)
  (* ================================================================== *)
  Theorem airborne_pres :
    body_pres lp NoA MWF bm
      mario_actions_airborne.f_mario_execute_airborne_action.
  Proof.
    intros m vargs t m' vres Hmargp Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs).
    { apply Hmargp. vm_compute. reflexivity. }
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
        change (fn_vars mario_actions_airborne.f_mario_execute_airborne_action)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params mario_actions_airborne.f_mario_execute_airborne_action)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite airborne_body_shape in Hbody.
    set (base := create_undef_temps
                   (fn_temps mario_actions_airborne.f_mario_execute_airborne_action))
      in *.
    (* the param temp's exact provenance (if it is a pointer, it is Mario) *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hmem1 : mem_id mario_actions_airborne._check_common_airborne_cancels
                      airborne_callee_ids = true)
      by (vm_compute; reflexivity).
    assert (Hmem2 : mem_id mario_actions_airborne._play_far_fall_sound
                      airborne_callee_ids = true)
      by (vm_compute; reflexivity).
    inv Hbody.
    - (* prologue normal: no early cancel; the frame continues *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ Out_normal |- _ => rename H1 into HS1
      end.
      match goal with
      | H2 : exec_stmt _ _ _ _ _ (Ssequence (Scall None _ _) _) _ _ _ _ |- _ =>
          rename H2 into Hrest2
      end.
      inv HS1.
      + (* the cancel-check call, then the (not-taken) if *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (tabled_scall_pres _ _ _ _ _ _ _ _ _ _ Hcall1
                    Hmem1 Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        cbn [set_opttemp] in *.
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ Out_normal |- _ =>
            destruct b; [ inv Hbr | ]
        end.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ Out_normal |- _ => inv Hbr
        end.
        (* the far-fall-sound call, then dispatch + return *)
        inv Hrest2.
        * match goal with
          | Hc : exec_stmt _ _ _ _ _ (Scall None _ _) _ _ _ _ |- _ =>
              rename Hc into Hcall2
          end.
          match goal with
          | Hr : exec_stmt _ _ _ _ _ (Ssequence airborne_dispatch_stmt _)
                   _ _ _ _ |- _ => rename Hr into Hrest3
          end.
          assert (Htat1 : forall b o,
                     (PTree.set mario_actions_airborne._t'1 vr1
                        (PTree.set mario_actions_airborne._m v0 base))
                       ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero).
          { intros b o Hg.
            rewrite PTree.gso in Hg
              by (intro HH; vm_compute in HH; discriminate HH).
            exact (Htat0 _ _ Hg). }
          destruct (tabled_scall_pres _ _ _ _ _ _ _ _ _ _ Hcall2
                      Hmem2 Htat1 HN1 HM1 HV1 HS1')
            as (HV2 & HS2 & HM2 & HN2 & _ & (vr2 & ->)).
          cbn [set_opttemp] in *.
          inv Hrest3.
          -- (* dispatch, then the return *)
             match goal with
             | Hd : exec_stmt _ _ _ _ _ airborne_dispatch_stmt _ _ _ _ |- _ =>
                 rename Hd into Hdisp
             end.
             match goal with
             | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
                 rename Hr into Hret
             end.
             destruct (dispatch_m_is_ptr _ _ _ _ _ _ Hdisp) as (l & o & Hlm).
             pose proof (Htat1 _ _ Hlm) as [-> ->].
             destruct (airborne_dispatch_pres _ _ _ _ _ _ Hlm
                         HN2 HM2 HV2 HS2 Hdisp)
               as (HV3 & HS3 & HM3 & HN3 & _).
             inv Hret.
             repeat split; assumption.
          -- (* dispatch ended non-normally: refuted by the dispatch walk *)
             exfalso.
             match goal with
             | Hd : exec_stmt _ _ _ _ _ airborne_dispatch_stmt _ _ _ ?oo,
               Hn : ?oo <> Out_normal |- _ => rename Hd into Hdisp
             end.
             destruct (dispatch_m_is_ptr _ _ _ _ _ _ Hdisp) as (l & o & Hlm).
             pose proof (Htat1 _ _ Hlm) as [-> ->].
             destruct (airborne_dispatch_pres _ _ _ _ _ _ Hlm
                         HN2 HM2 HV2 HS2 Hdisp)
               as (_ & _ & _ & _ & Hnorm).
             congruence.
        * (* the sound call ended non-normally: Scall is Out_normal *)
          exfalso.
          match goal with
          | Hc : exec_stmt _ _ _ _ _ (Scall None _ _) _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
          end.
      + (* the cancel-check call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
    - (* prologue non-normal: the early `return 1` cancel path *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ _ |- _ => rename H1 into HS1
      end.
      inv HS1.
      + (* call normal; the if returns *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (tabled_scall_pres _ _ _ _ _ _ _ _ _ _ Hcall1
                    Hmem1 Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
            destruct b
        end.
        * (* return 1: memory is the post-call memory *)
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hbr
          end.
          repeat split; assumption.
        * (* skip is Out_normal: contradicts the non-normal outcome *)
          exfalso.
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => inv Hbr; congruence
          end.
      + (* the call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
  Qed.

End AirborneSurface.
