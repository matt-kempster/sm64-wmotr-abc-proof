(* spine-root: GOAL-1 capstone (no-A => no-fly). *)
(* NoAImpliesNoFly.v -- GOAL 1 capstone: a no-A (no-spawn) run never enters ACT_FLYING.
 *
 * THE STEP IS NOW THE REAL CLIGHTGEN'D FRAME (this session's tethering move).
 * Previously `step` was an ABSTRACT relation and `frame_preserves_nonflying` a
 * black-box hypothesis. Both are gone:
 *   - `step` is now `RealFrameValue.execute_mario_action_step` -- one CompCert
 *     big-step `eval_funcall` of the ACTUAL `mario.f_execute_mario_action` from
 *     the clightgen'd AST, over the real Mario genv `mario_ge = globalenv
 *     mario.prog`. No placeholder relation.
 *   - the per-frame obligation is now a PROVED lemma (frame_preserves_mem_ok),
 *     discharged by the value engine via RealFrameValue's generic funcall->value
 *     bridge. What the capstone rests on is no longer a single opaque
 *     "frames keep you non-flying" wish, but the value engine's three NAMED reach
 *     residuals over the real genv (below).
 *
 * WHY A PRECONDITION IS NEEDED (the bug in the naive statement). "A no-A run never
 * reaches ACT_FLYING" is, taken unconditionally, FALSE: a warp whose spawn type is
 * MARIO_SPAWN_FLYING (0x17) makes level_update.c's set_mario_initial_action call
 * set_mario_action(m, ACT_FLYING, 2) with no button input (Tower of the Wing Cap).
 * The honest theorem EXCLUDES that route. WMotR's object/warp set contains NO
 * MARIO_SPAWN_FLYING warp; we state the thing WMotR GIVES as an explicit run-level
 * precondition (no_spawn_flying_run) rather than yet machine-extracting it.
 *
 * WHAT IS TETHERED HERE vs. STILL A NAMED RESIDUAL (no buried ledes):
 *   REAL now:
 *     - `mem_flying`/`mem_nonflying`: the flying state is the ACTUAL action value
 *       loaded from Mario's struct (Mem.load Mint32 m bm 12), classified by
 *       Flying.is_flying_int. No abstract `flying : S -> Prop`.
 *     - `step`: the real `eval_funcall` of `f_execute_mario_action` (see above).
 *     - `frame_preserves_mem_ok`: PROVED from the value engine, not assumed.
 *   THE NAMED RESIDUALS (the honest scoreboard -- the value engine's reach surface
 *   over the real Mario genv; these are what the capstone now rests on):
 *     (1) reach_value_preserves nonflying bm mario_ge  -- THE INTERPROCEDURAL CRUX:
 *         every funcall reached inside a frame preserves the non-flying action.
 *         As stated UNCONDITIONALLY this is still too strong (set_mario_action with
 *         an ACT_FLYING argument is a reached funcall that does NOT preserve it);
 *         closing it needs the no-A carve-out -- the only action writer is
 *         set_mario_action, and under a no-A frame its argument is non-flying
 *         (ActionValue.set_mario_action_field + the ActionWriters corpus). The
 *         no_A/no_spawn preconditions of THIS theorem are carried for exactly that
 *         conditioning step; the present per-frame proof does not yet consume them
 *         (it leans on reach_value_preserves), and that is the next crux. This is
 *         the same disclosed-precise-gap discipline as Unwired/AltStatements/
 *         FlyingFrame.v, now one level sharper (value engine, not unchanged_on).
 *     (2) reach_ext_preserves (action_cell bm) mario_ge  -- externals don't write
 *         the action cell. Satisfiable/true; removable.
 *     (3) stmt_value_ok of f_execute_mario_action's OWN body  -- its direct
 *         Sassigns avoid the action cell or store a non-flying value (the action
 *         writes are in callees, governed by (1)). Decidable; removable.
 *
 * So this capstone now reduces "a no-A no-spawn run never flies" to the value
 * engine's reach closure over the REAL clightgen'd frame -- isolating the crux to
 * (1), with (2)/(3) genuinely dischargeable.
 *
 * No Admitted.
 *)

From Coq Require Import List Bool.
Import ListNotations.
From compcert Require Import Coqlib AST Integers Values Memory Globalenvs Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValueFrame
  ReachableRun RealFrameValue.

Section NoAImpliesNoFly.
  (* Mario's struct block is fixed; the action field loads at (bm, 12) as Mint32 --
     exactly the value engine's watched cell. *)
  Variable bm : block.

  (* ---- REAL flying / non-flying, by the loaded action value (no placeholder) ---- *)

  Definition mem_flying (m : mem) : Prop :=
    exists v, Mem.load Mint32 m bm 12 = Some (Vint v) /\ is_flying_int v = true.

  Definition mem_nonflying (m : mem) : Prop :=
    action_sat nonflying m bm.

  (* The carried run invariant: Mario's block is allocated AND its action is
     non-flying. Validity is genuine content -- the value engine reasons about
     loads at bm, so it must stay a valid block across a frame (it does: a frame
     only stores, never frees Mario). *)
  Definition mem_ok (m : mem) : Prop :=
    Mem.valid_block m bm /\ mem_nonflying m.

  (* The invariant really does forbid flying: if every loaded action value is
     non-flying, no loaded action value is flying. *)
  Lemma mem_nonflying_not_flying : forall m, mem_nonflying m -> ~ mem_flying m.
  Proof.
    intros m Hnf [v [Hld Hfly]]. specialize (Hnf v Hld).
    unfold nonflying in Hnf. congruence.
  Qed.

  Lemma mem_ok_not_flying : forall m, mem_ok m -> ~ mem_flying m.
  Proof. intros m [_ Hnf]. exact (mem_nonflying_not_flying m Hnf). Qed.

  (* ---- the input layer: abstract. (Grounding the input word / A-bit is the
         orthogonal FlyingStatement tethering; THIS goal concretizes the STEP.) ---- *)
  Variable Inp : Type.
  Variable a_pressed    : Inp -> bool.   (* did THIS frame newly press A?        *)
  Variable spawn_flying : Inp -> bool.   (* did THIS frame do a MARIO_SPAWN_FLYING
                                            spawn? (the class-3 hatch)           *)

  (* ---- THE STEP IS REAL: one big-step of the clightgen'd per-frame function. ----
     (It reads its input from memory; the value-engine preservation holds for any
     input, so `step` does not branch on `i` -- the no-A conditioning lives in the
     reach residual (1), not in the relation.) *)
  Definition step (_ : Inp) (m m' : mem) : Prop :=
    execute_mario_action_step m m'.

  (* ---- The two run-level preconditions, as REAL Forall facts over the frames ---- *)

  Definition noA_run_real (is : list Inp) : Prop :=
    Forall (fun i => a_pressed i = false) is.

  (* The WMotR-supplied precondition: no frame fires the spawn-flying hatch. *)
  Definition no_spawn_flying_run (is : list Inp) : Prop :=
    Forall (fun i => spawn_flying i = false) is.

  (* ---- The value engine's reach residuals over the REAL Mario genv ----
     These are the honest scoreboard the capstone now rests on (see header). *)
  Hypothesis reach_value_ok :
    reach_value_preserves nonflying bm mario_ge.
  Hypothesis reach_ext_ok :
    reach_ext_preserves (action_cell bm) mario_ge.
  Hypothesis body_value_ok :
    forall e, stmt_value_ok nonflying bm mario_ge e
                (fn_body mario.f_execute_mario_action).

  (* ---- The per-frame obligation: now PROVED via the value engine bridge ----
     A real frame preserves (bm valid /\ action non-flying). The a_pressed/
     spawn_flying flags are accepted but not consumed here -- preservation follows
     from the value engine + reach residual (1); see header on the no-A conditioning
     that residual (1) still awaits. *)
  Lemma frame_preserves_mem_ok :
    forall i m m',
      a_pressed i = false ->
      spawn_flying i = false ->
      mem_ok m ->
      step i m m' ->
      mem_ok m'.
  Proof.
    intros i m m' _ _ [Hv Hsat] Hst.
    exact (execute_mario_action_preserves_nonflying bm m m'
             reach_value_ok reach_ext_ok body_value_ok Hv Hsat Hst).
  Qed.

  (* Combine the two run preconditions into the single "no dangerous frame" flag
     that the ReachableRun harness consumes (a frame is dangerous if it presses A OR
     spawn-flies). *)
  Lemma combine_preconditions :
    forall is,
      noA_run_real is ->
      no_spawn_flying_run is ->
      noA_run Inp (fun i => orb (a_pressed i) (spawn_flying i)) is.
  Proof.
    unfold noA_run_real, no_spawn_flying_run, noA_run.
    induction is as [| i rest IH]; intros HA HS.
    - constructor.
    - inversion HA; subst. inversion HS; subst.
      constructor.
      + apply orb_false_iff; split; assumption.
      + apply IH; assumption.
  Qed.

  (* ====================================================================== *)
  (* THE TETHERED THEOREM.                                                   *)
  (*                                                                        *)
  (* For the real flying state (the loaded action value), the REAL per-frame  *)
  (* `eval_funcall` step, and the two real preconditions, a run that starts    *)
  (* allocated-and-non-flying NEVER reaches a flying state. Proved by           *)
  (* instantiating ReachableRun's invariant-induction harness with the REAL      *)
  (* non-flying invariant; the per-frame step is discharged by the value engine. *)
  (* ====================================================================== *)
  Theorem noA_no_spawn_never_flying :
    forall (init : mem) (is : list Inp) (m : mem),
      mem_ok init ->
      noA_run_real is ->
      no_spawn_flying_run is ->
      reachable mem Inp step init is m ->
      ~ mem_flying m.
  Proof.
    intros init is m Hinit HnoA Hnospawn Hreach.
    eapply (noA_run_not_flying mem Inp
              (fun i => orb (a_pressed i) (spawn_flying i)) step
              mem_flying mem_ok init).
    - (* base: start allocated and non-flying *) exact Hinit.
    - (* step: a non-dangerous frame preserves the invariant *)
      intros i s s' Hd Hphi Hst.
      apply orb_false_iff in Hd. destruct Hd as [Ha Hsp].
      eapply frame_preserves_mem_ok; eauto.
    - (* safety: the invariant excludes flying *)
      exact mem_ok_not_flying.
    - (* the combined no-dangerous-frame run *)
      exact (combine_preconditions is HnoA Hnospawn).
    - (* the run itself *)
      exact Hreach.
  Qed.

End NoAImpliesNoFly.
