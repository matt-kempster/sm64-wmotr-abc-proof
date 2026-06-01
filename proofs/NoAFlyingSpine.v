(* NoAFlyingSpine.v -- the SPINE: the middle layer of "no A => no flying", with
 * every "function in the middle" written down as an explicit, named hole.
 *
 * WHY THIS FILE EXISTS. FlyingStatement.v states the top theorem and leaves the
 * entire hard part as ONE opaque hypothesis, `Phi_preserved_noA` ("a no-A frame
 * preserves the invariant"). That hole hides the whole call tree. This file is the
 * Lean-style "big theorem with sorrys": it DECOMPOSES that one hole into the exact,
 * bounded list of obligations the development still owes, each named after the real
 * clightgen'd function it is about, and it PROVES the per-frame preservation by
 * composing them. The holes are Coq `Hypothesis`es of a Section -- so when the
 * section closes the theorem is simply PARAMETERIZED over them (no axioms; Print
 * Assumptions stays "Closed under the global context"). Discharging a hole = proving
 * the real lemma and deleting the corresponding Hypothesis.
 *
 * THE ENUMERATION (machine-anchored to Flying.v, which proved these sets EXACT).
 * The only functions that can make Mario's action field flying fall into 3 buckets:
 *
 *   BUCKET A -- functions that DO NOT write the action field (the vast majority:
 *     act_panting, mario_reset_bodystate, ...). Their stores hit other cells/blocks,
 *     so they preserve the action cell. This is ONE generic store-frame lemma, not
 *     one-per-function; mario_reset_bodystate (ResetBodystate.v) is the first real
 *     witness that the machinery survives genuine aliasing. Folded into `chokepoint`.
 *
 *   BUCKET B -- the raw action writers, enumerated EXACTLY in Flying.v
 *     (mario_action_writers per TU): set_mario_action, init_mario,
 *     init_mario_from_save_file (mario.c); act_air_throw (airborne);
 *     act_ledge_climb_slow (automatic); bounce_back_from_attack,
 *     check_kick_or_punch_wall (interaction). Flying.v proved NONE writes a flying
 *     constant (the no_raw_flying_action_write lemmas), and the 4 set_mario_action helpers do
 *     not fabricate flying (fabricates_flying = false). So the only way the field
 *     becomes flying is set_mario_action CALLED WITH a flying argument. Folded into
 *     `chokepoint`.
 *
 *   BUCKET C -- the 5 flying-setter SITES (Flying.flying_setters, the only callers
 *     that feed a flying constant to set_mario_action). These are the explicit
 *     per-site holes below. Flying.v also proved (the *_no_input lemmas) that NONE of
 *     them checks the A button locally: the A-dependence is TEMPORAL (the upstream
 *     jump chain), which is exactly why each site hole is an R3 obligation, not a
 *     local guard -- EXCEPT site 5 (the spawn hatch), which is no-A-reachable and is
 *     instead retired by the explicit no-spawn-flying precondition (WMotRStatement).
 *
 * WHAT IS PROVED HERE: `keeps_nonflying` (the per-frame preservation = the
 * FlyingStatement Phi_preserved_noA hole, with Phi := ~flying) and the run-level
 * `spine_noA_no_spawn_never_flying`, both by pure composition of the holes via
 * FrameTrace's harness. No Admitted.
 *
 * HOW THE HOLES GET DISCHARGED (the roadmap each name points at):
 *   chokepoint            <- ActionValueFrame + ResetBodystate (store-frame, bucket A)
 *                            + Flying.no_raw_flying_action_write_* (bucket B)
 *                            + ActionValueFrame.set_mario_action_body (passthrough).
 *   no_cannon/ftj/sjfl/stja_without_A  <- R3 temporal closure over the jump chain
 *                            (ActionGraph.v is the syntactic groundwork).
 *   no_spawn_without_flag <- WMotRStatement's spawn precondition (already the design).
 *)

From Coq Require Import List Bool.
Import ListNotations.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FrameTrace.

Section Spine.

(* The whole linked program and its Clight global environment. *)
Variable prog : program.
Let gw : genv := globalenv prog.

(* ---- grounded watched property (loads off the real program; kept local) ------- *)
(* Identical in spirit to FlyingStatement.flying_mem: the flying state is the ACTUAL
   action value loaded from Mario's struct, classified by Flying.is_flying_int. *)

Definition mario_block (m : mem) (bm : block) : Prop :=
  exists bg,
    Genv.find_symbol gw mario._gMarioState = Some bg /\
    Mem.load Mptr m bg 0 = Some (Vptr bm Ptrofs.zero).

Definition action_holds (m : mem) (v : int) : Prop :=
  exists bm, mario_block m bm /\ Mem.load Mint32 m bm 12 = Some (Vint v).

Definition flying_mem (m : mem) : Prop :=
  exists v, action_holds m v /\ is_flying_int v = true.

(* INPUT_A_PRESSED = 0x0002, a bit of m->input. *)
Definition INPUT_A_PRESSED : int := Int.repr 2.
Definition a_pressed (w : int) : bool :=
  negb (Int.eq (Int.and w INPUT_A_PRESSED) Int.zero).

(* ---- the per-frame engine (the model-faithfulness bridge, still abstract) ------ *)
(* `step i m m'` = one Mario action update on input word i. Instantiating it with the
   big-step eval_funcall of mario.f_execute_mario_action is FlyingStatement's
   mario_update / step_models_real bridge -- orthogonal to the decomposition here. *)
Variable step : int -> mem -> mem -> Prop.

(* Did THIS frame fire a MARIO_SPAWN_FLYING spawn (the class-3 hatch, site 5)? *)
Variable spawn_flying : int -> bool.

(* ================================================================== *)
(*  THE FIVE FLYING-SETTER SITES, as abstract "this site fired" events  *)
(*  (Flying.flying_setters). `fired_X i m m'` means: during the frame   *)
(*  i : m -> m', site X executed its set_mario_action(<flying>) call.   *)
(* ================================================================== *)
Variable fired_cannon : int -> mem -> mem -> Prop.  (* act_shot_from_cannon       *)
Variable fired_ftj    : int -> mem -> mem -> Prop.  (* act_flying_triple_jump     *)
Variable fired_sjfl   : int -> mem -> mem -> Prop.  (* set_jump_from_landing      *)
Variable fired_stja   : int -> mem -> mem -> Prop.  (* set_triple_jump_action     *)
Variable fired_spawn  : int -> mem -> mem -> Prop.  (* set_mario_initial_action   *)

(* ================================================================== *)
(*  HOLE 0 -- the CHOKE POINT (buckets A + B).                          *)
(*  If a frame takes a non-flying memory to a flying one, the new flying *)
(*  value can ONLY have entered through one of the five sites firing.    *)
(*  This is the semantic content of Flying.v's syntactic enumeration:    *)
(*    - bucket A bodies don't write the action cell (store-frame),       *)
(*    - bucket B raw writers write non-flying constants,                 *)
(*    - set_mario_action writes exactly its argument (no fabrication),   *)
(*  so a freshly-flying action implies a flying ARGUMENT was passed, i.e.*)
(*  one of the 5 sites fired. Discharged by ActionValueFrame/ResetBody-  *)
(*  state + Flying.no_raw_flying_action_write_* once `step` is the loop.  *)
(* ================================================================== *)
Hypothesis chokepoint :
  forall i m m',
    step i m m' ->
    ~ flying_mem m ->
    flying_mem m' ->
    fired_cannon i m m' \/ fired_ftj i m m' \/ fired_sjfl i m m'
    \/ fired_stja i m m' \/ fired_spawn i m m'.

(* ================================================================== *)
(*  HOLES 1-4 -- the four A-gated sites (BUCKET C, the R3 temporal      *)
(*  closure). Each says: with no A pressed this frame, this site cannot  *)
(*  fire. The honest content (Flying.v *_no_input): the site itself does *)
(*  NOT read the controller; it can only fire from a precursor action    *)
(*  (the jump -> double -> triple chain, or a cannon launch) whose entry  *)
(*  required an A press on an earlier frame. Turning that into a frame-   *)
(*  local statement is the job of the R3 invariant (a Phi tracking the    *)
(*  jump-chain action), which strengthens these to true frame steps.      *)
(* ================================================================== *)
Hypothesis no_cannon_without_A :
  forall i m m', a_pressed i = false -> ~ fired_cannon i m m'.
Hypothesis no_ftj_without_A :
  forall i m m', a_pressed i = false -> ~ fired_ftj i m m'.
Hypothesis no_sjfl_without_A :
  forall i m m', a_pressed i = false -> ~ fired_sjfl i m m'.
Hypothesis no_stja_without_A :
  forall i m m', a_pressed i = false -> ~ fired_stja i m m'.

(* ================================================================== *)
(*  HOLE 5 -- the spawn hatch (BUCKET C, site 5). This site IS reachable *)
(*  with no A press (Tower of the Wing Cap), so A does NOT block it; the  *)
(*  no-spawn-flying precondition does. With the spawn flag low this frame *)
(*  the hatch cannot fire. (This is the design already in WMotRStatement.)*)
(* ================================================================== *)
Hypothesis no_spawn_without_flag :
  forall i m m', spawn_flying i = false -> ~ fired_spawn i m m'.

(* ================================================================== *)
(*  THE MIDDLE, ASSEMBLED: a no-A, no-spawn frame preserves non-flying.  *)
(*  This is exactly the FlyingStatement `Phi_preserved_noA` hole with     *)
(*  Phi := (~ flying_mem) -- proved here by composing the holes above.    *)
(* ================================================================== *)
Lemma keeps_nonflying :
  forall i m m',
    a_pressed i = false ->
    spawn_flying i = false ->
    ~ flying_mem m ->
    step i m m' ->
    ~ flying_mem m'.
Proof.
  intros i m m' Ha Hs Hnf Hstep Hfly.
  destruct (chokepoint i m m' Hstep Hnf Hfly)
    as [Hc | [Hf | [Hj | [Ht | Hsp]]]].
  - eapply no_cannon_without_A; eauto.
  - eapply no_ftj_without_A;    eauto.
  - eapply no_sjfl_without_A;   eauto.
  - eapply no_stja_without_A;   eauto.
  - eapply no_spawn_without_flag; eauto.
Qed.

(* ---- the two run-level preconditions, as real Forall facts over frames -------- *)
Definition noA_run_real    (is : list int) : Prop := Forall (fun i => a_pressed i = false) is.
Definition no_spawn_run    (is : list int) : Prop := Forall (fun i => spawn_flying i = false) is.

(* Fold the two preconditions into FrameTrace's single "no dangerous frame" list
   (a frame is dangerous if it presses A OR spawn-flies). *)
Lemma combine_preconditions :
  forall is,
    noA_run_real is ->
    no_spawn_run is ->
    noA_run int (fun i => orb (a_pressed i) (spawn_flying i)) is.
Proof.
  unfold noA_run_real, no_spawn_run, noA_run.
  induction is as [| i rest IH]; intros HA HS.
  - constructor.
  - inversion HA; subst. inversion HS; subst.
    constructor.
    + apply orb_false_iff; split; assumption.
    + apply IH; assumption.
Qed.

(* ================================================================== *)
(*  THE SPINE THEOREM. A run of no-A, no-spawn frames starting non-      *)
(*  flying never reaches a flying action -- assembled from the per-frame *)
(*  preservation via FrameTrace's invariant-induction harness, with the  *)
(*  invariant taken to be (~ flying_mem) itself.                         *)
(* ================================================================== *)
Theorem spine_noA_no_spawn_never_flying :
  forall (m0 mN : mem) (is : list int),
    ~ flying_mem m0 ->
    noA_run_real is ->
    no_spawn_run is ->
    reachable mem int step m0 is mN ->
    ~ flying_mem mN.
Proof.
  intros m0 mN is H0 HA HS Hreach.
  eapply (noA_run_not_flying mem int
            (fun i => orb (a_pressed i) (spawn_flying i)) step
            flying_mem (fun m => ~ flying_mem m) m0).
  - (* base: start non-flying *) exact H0.
  - (* step: a non-dangerous frame preserves non-flying *)
    intros i s s' Hd Hphi Hst.
    apply orb_false_iff in Hd. destruct Hd as [Ha Hsp].
    eapply keeps_nonflying; eauto.
  - (* safety: the invariant IS ~flying *)
    intros s Hphi; exact Hphi.
  - (* the combined no-dangerous-frame run *)
    exact (combine_preconditions is HA HS).
  - (* the run itself *)
    exact Hreach.
Qed.

End Spine.
