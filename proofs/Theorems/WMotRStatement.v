(* WMotRStatement.v -- tethering the "no A => no flying" theorem to REAL terms.
 *
 * FrameTrace.noA_run_not_flying is the proved-but-ABSTRACT harness: S/Inp/step/
 * flying/a_pressed are all placeholders. This file begins replacing those
 * placeholders with the real game's notions, and -- crucially -- it makes the
 * statement TRUE by carving out the spawn-flying escape hatch.
 *
 * WHY A PRECONDITION IS NEEDED (the bug in the naive statement). "A no-A run never
 * reaches ACT_FLYING" is, taken unconditionally, FALSE. SM64 has a non-A route into
 * flying: a warp whose spawn type is MARIO_SPAWN_FLYING (0x17) makes
 * level_update.c's set_mario_initial_action call set_mario_action(m, ACT_FLYING, 2)
 * with no button input at all (this is how Tower of the Wing Cap starts you
 * airborne). So the honest theorem must EXCLUDE that route.
 *
 * THE WMotR ANGLE (docs/must-press-a-to-fly.md). We only care about the level
 * "Wing Mario over the Rainbow". WMotR's object/warp set contains NO
 * MARIO_SPAWN_FLYING warp, so in WMotR that hatch never fires. We are NOT yet able
 * to machine-extract the level's object table (clightgen rejects
 * levels/wmotr/script.c: "initializer element is not a compile-time constant"), so
 * we do not yet PROVE "WMotR loaded => the hatch never fires". Instead we state the
 * thing WMotR GIVES us as an explicit run-level precondition:
 *
 *     no_spawn_flying_run is  :=  no frame in the run performs a MARIO_SPAWN_FLYING
 *                                 spawn.
 *
 * and prove: no-A AND no-spawn-flying  =>  the run never reaches a flying state.
 * Discharging "WMotR loaded => no_spawn_flying_run" from the (eventually extracted)
 * WMotR object table is deferred, named, and is the only gap between this and an
 * unconditional WMotR statement.
 *
 * WHAT IS TETHERED HERE vs. STILL A PLACEHOLDER (no buried ledes):
 *   REAL now:
 *     - `mem_flying` / `mem_nonflying`: the flying state is the ACTUAL action value
 *       loaded from Mario's struct (Mem.load Mint32 m bm 12), classified by
 *       Flying.is_flying_int. No abstract `flying : S -> Prop`.
 *     - the non-flying invariant is ActionValueFrame.action_sat -- the very thing
 *       this session's value-frame engine carries forward.
 *     - both preconditions are concrete Forall facts over the real frame list.
 *   STILL THE BRIDGE (honest placeholders, the deferred work):
 *     - `step`: one frame of the engine (execute_mario_action against mario.v) is
 *       still an abstract relation. Instantiating it with the clightgen'd loop is
 *       the model-faithfulness bridge.
 *     - `frame_preserves_nonflying`: the per-frame obligation "a no-A, no-spawn
 *       frame keeps the action non-flying" is a HYPOTHESIS here. It is exactly what
 *       ActionValueFrame.exec_stmt_value_preserves + the P3 reach discharge will
 *       prove once `step` is the real loop.
 *
 * So this file converts FrameTrace's fully-abstract harness into a statement whose
 * SAFETY PROPERTY and PRECONDITIONS are real game terms, leaving only the engine
 * frame and its per-frame preservation as the named remaining bridge.
 *
 * No Admitted.
 *)

From Coq Require Import List Bool.
Import ListNotations.
From compcert Require Import Coqlib AST Integers Values Memory.
From SM64.Proofs Require Import Flying ActionValueFrame FrameTrace.

Section WMotR.
  (* Mario's struct block is fixed; the world state relevant to flight is memory.
     The action field loads at (bm, 12) as Mint32 -- exactly ActionValueFrame's cell. *)
  Variable bm : block.

  (* ---- REAL flying / non-flying, by the loaded action value (no placeholder) ---- *)

  Definition mem_flying (m : mem) : Prop :=
    exists v, Mem.load Mint32 m bm 12 = Some (Vint v) /\ is_flying_int v = true.

  Definition mem_nonflying (m : mem) : Prop :=
    action_sat (fun v => is_flying_int v = false) m bm.

  (* The invariant really does forbid flying: if every loaded action value is
     non-flying, no loaded action value is flying. *)
  Lemma mem_nonflying_not_flying : forall m, mem_nonflying m -> ~ mem_flying m.
  Proof.
    intros m Hnf [v [Hld Hfly]]. specialize (Hnf v Hld). congruence.
  Qed.

  (* ---- The frame model: still the deferred bridge ---- *)

  Variable Inp : Type.
  Variable a_pressed    : Inp -> bool.   (* did THIS frame newly press A?        *)
  Variable spawn_flying : Inp -> bool.   (* did THIS frame do a MARIO_SPAWN_FLYING
                                            spawn? (the class-3 hatch)           *)
  Variable step : Inp -> mem -> mem -> Prop.

  (* ---- The two run-level preconditions, as REAL Forall facts over the frames ---- *)

  Definition noA_run_real (is : list Inp) : Prop :=
    Forall (fun i => a_pressed i = false) is.

  (* The WMotR-supplied precondition: no frame fires the spawn-flying hatch. *)
  Definition no_spawn_flying_run (is : list Inp) : Prop :=
    Forall (fun i => spawn_flying i = false) is.

  (* ---- The per-frame obligation: the bridge content, stated in real terms ---- *)
  (* A frame that neither presses A nor spawn-flies keeps the action non-flying.
     This is precisely what ActionValueFrame.exec_stmt_value_preserves discharges
     once `step` is the real per-frame loop and the P3 reach invariant is in hand. *)
  Hypothesis frame_preserves_nonflying :
    forall i m m',
      a_pressed i = false ->
      spawn_flying i = false ->
      mem_nonflying m ->
      step i m m' ->
      mem_nonflying m'.

  (* Combine the two run preconditions into the single "no dangerous frame" flag
     that the FrameTrace harness consumes (a frame is dangerous if it presses A OR
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
  (* For the real flying state (the loaded action value) and the two real    *)
  (* preconditions (no A pressed this run, AND no spawn-flying this run), a    *)
  (* run that starts non-flying NEVER reaches a flying state. Proved by        *)
  (* instantiating FrameTrace's invariant-induction harness with the REAL      *)
  (* non-flying invariant; the spawn precondition is what makes the statement   *)
  (* true rather than false.                                                   *)
  (* ====================================================================== *)
  Theorem wmotr_noA_no_spawn_never_flying :
    forall (init : mem) (is : list Inp) (m : mem),
      mem_nonflying init ->
      noA_run_real is ->
      no_spawn_flying_run is ->
      reachable mem Inp step init is m ->
      ~ mem_flying m.
  Proof.
    intros init is m Hinit HnoA Hnospawn Hreach.
    eapply (noA_run_not_flying mem Inp
              (fun i => orb (a_pressed i) (spawn_flying i)) step
              mem_flying mem_nonflying init).
    - (* base: start non-flying *) exact Hinit.
    - (* step: a non-dangerous frame preserves non-flying *)
      intros i s s' Hd Hphi Hst.
      apply orb_false_iff in Hd. destruct Hd as [Ha Hsp].
      eapply frame_preserves_nonflying; eauto.
    - (* safety: non-flying excludes flying *)
      exact mem_nonflying_not_flying.
    - (* the combined no-dangerous-frame run *)
      exact (combine_preconditions is HnoA Hnospawn).
    - (* the run itself *)
      exact Hreach.
  Qed.

End WMotR.
