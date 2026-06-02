(* FlyingStatement.v -- the HIGH-LEVEL "you must press A to fly" theorem, stated.
 *
 * PURPOSE (per the user's request): write the top-level statement of the flying
 * impossibility -- the spine of "Wing Mario over the Rainbow needs A" -- and make
 * sure it is HONEST: every predicate in the CONCLUSION is grounded in real loads
 * off the real clightgen'd program (mario.prog), so there is no "Definitionslop"
 * (a slippery definition that secretly encodes the answer). The genuinely hard
 * content (R3, the trace induction) is isolated into NAMED hypotheses, not buried
 * in definitions -- "only proofslop, no Definitionslop."
 *
 * WHAT IS GROUNDED (audit these -- they have nowhere to hide):
 *   - flying_mem m  := read gMarioState's pointer from the genv, load the `action`
 *                      field (offset 12, Mint32) of the pointee, check is_flying_int
 *                      (the action constants pinned in Flying.v, INCLUDING the
 *                      stale-header correction 0x10808899).
 *   - a_pressed_int := test the INPUT_A_PRESSED bit (0x0002) of a frame's input.
 *   - input_holds   := load the `input` field (offset 2, Mint16unsigned) of the
 *                      same pointee.
 *   - mario_update  := one real Mario action update = a CompCert big-step
 *                      eval_funcall of the ACTUAL f_execute_mario_action from
 *                      mario.prog, with this frame's input latched in memory.
 *  All offsets are the real composite-env offsets (verified by vm_compute probe:
 *  action@12/Full/Mint32, input@2/Full/Mint16unsigned; Archi.ptr64=true).
 *
 * WHAT IS A NAMED HYPOTHESIS (the honest boundary, NOT hidden in a Definition):
 *   - step / step_models_real: the trace model `step` is abstract, tethered to
 *     reality by `step_models_real : every real mario_update IS a step` (the SOUND
 *     over-approximation direction -- ruling out flying for step-runs rules it out
 *     for the real Mario update). The eventual closure instantiates step :=
 *     mario_update (see real_frames_need_A below, where step_models_real becomes
 *     trivial and is load-bearing).
 *   - Phi (the strengthening invariant) is an abstract Variable, so NO concrete
 *     invariant can smuggle the conclusion (FrameTrace.v's proof-internal-Phi
 *     discipline). Its two dynamic obligations -- Phi_excludes_flying (R1/R2 shape:
 *     the invariant rules out flying) and Phi_preserved_noA (R3: a no-A frame keeps
 *     it) -- are explicit hypotheses. Discharging them with a concrete Phi over the
 *     jump-chain is the remaining R3 work; THAT is the "proofslop"/admit surface.
 *
 * KNOWN SCOPE / leaks (named, Havoc-style; same as the rest of the development):
 *   - mario_update models the Mario-update PORTION of a game tick. That a whole
 *     tick cannot otherwise reach a flying action is the separately-mechanized
 *     no_behavior_is_a_flying_setter (behaviors) + the ActionWriters/Flying
 *     no-raw-writer corpus; whole-frame faithfulness is the model-review item.
 *   - single TU (mario.prog): cross-TU set_mario_action linkage is leak #3.
 *   - indirect calls (set_triple_jump_action via function pointer) = leak #2.
 *
 * This file is a STATEMENT artifact: flying_needs_A and real_frames_need_A are
 * proved (Qed) FROM the named hypotheses via FrameTrace's harness -- so the
 * statement is shown to reduce to exactly those honest obligations, with no Phi
 * and no fake definitions in between. No Admitted here; the admits live wherever
 * the three hypotheses get discharged.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs Ctypes Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FrameTrace.

Section FlyingStatement.

(* The whole program and its Clight global environment. *)
Variable prog : program.
Let gw : genv := globalenv prog.

(* ---- grounded world predicates (loads off the real program/memory) ---- *)

(* The MarioState struct block = wherever the gMarioState global pointer points. *)
Definition mario_struct_block (m : mem) (bm : block) : Prop :=
  exists bg,
    Genv.find_symbol gw mario._gMarioState = Some bg /\
    Mem.load Mptr m bg 0 = Some (Vptr bm Ptrofs.zero).

(* m holds action value v: load MarioState.action @ offset 12 (Mint32). *)
Definition action_holds (m : mem) (v : int) : Prop :=
  exists bm, mario_struct_block m bm /\
             Mem.load Mint32 m bm 12 = Some (Vint v).

(* THE watched property: Mario's action is a flying value. is_flying_int is
   Flying.v's pinned ACT_FLYING (0x10808899, header-comment-corrected) /
   ACT_FLYING_TRIPLE_JUMP (0x03000894) test. *)
Definition flying_mem (m : mem) : Prop :=
  exists v, action_holds m v /\ is_flying_int v = true.

(* m holds input word w: load MarioState.input @ offset 2 (Mint16unsigned). *)
Definition input_holds (m : mem) (w : int) : Prop :=
  exists bm, mario_struct_block m bm /\
             Mem.load Mint16unsigned m bm 2 = Some (Vint w).

(* INPUT_A_PRESSED = 0x0002. a frame's input "presses A" iff that bit is set. *)
Definition INPUT_A_PRESSED : int := Int.repr 2.
Definition a_pressed_int (w : int) : bool :=
  negb (Int.eq (Int.and w INPUT_A_PRESSED) Int.zero).

(* ---- one real Mario action update (a CompCert big-step of the real fn) ---- *)
(* execute_mario_action(struct Object *o) -- the per-frame Mario action dispatch;
   it reads gMarioState internally (hence the action/input loads above go through
   the global). `i` is the frame's input, required to be the word latched in
   m->input at frame start, so a_pressed_int i is exactly "A pressed this frame". *)
Definition mario_update (i : int) (m m' : mem) : Prop :=
  input_holds m i /\
  exists (b_o : block) (t : trace) (res : val),
    eval_funcall function_entry2 gw m
      (Internal mario.f_execute_mario_action)
      (Vptr b_o Ptrofs.zero :: nil) t m' res.

(* ---- the abstract trace model, tethered to reality by a NAMED hypothesis ---- *)
Variable step : int -> mem -> mem -> Prop.

(* Faithfulness (the honest boundary): every real Mario update is a modeled step.
   This is the SOUND/over-approximation direction -- ruling out flying for all
   step-runs rules it out for the real Mario update. (Instantiated trivially when
   step := mario_update; see real_frames_need_A.) *)
Hypothesis step_models_real :
  forall i m m', mario_update i m m' -> step i m m'.

(* ---- the strengthening invariant: ABSTRACT, so it cannot smuggle anything ---- *)
Variable Phi : mem -> Prop.

(* Obligation 1 (R1/R2 shape): the invariant rules out a flying action. *)
Hypothesis Phi_excludes_flying : forall m, Phi m -> ~ flying_mem m.

(* Obligation 2 (R3, the hard trace step): a no-A frame preserves the invariant. *)
Hypothesis Phi_preserved_noA :
  forall i m m', a_pressed_int i = false -> Phi m -> step i m m' -> Phi m'.

(* ================================================================== *)
(* THE STATEMENT. A run of modeled frames in which NO frame presses A, *)
(* starting from any state satisfying the invariant, never reaches a   *)
(* flying action. Conclusion mentions only the grounded flying_mem /   *)
(* a_pressed_int / step -- no Phi. Proved from the named obligations    *)
(* via FrameTrace's Phi-isolated harness.                              *)
(* ================================================================== *)
Theorem flying_needs_A :
  forall (m0 mN : mem) (is : list int),
    Phi m0 ->
    noA_run int a_pressed_int is ->
    reachable mem int step m0 is mN ->
    ~ flying_mem mN.
Proof.
  intros m0 mN is Hbase Hnoa Hreach.
  exact (noA_run_not_flying mem int a_pressed_int step
           flying_mem Phi m0 Hbase Phi_preserved_noA Phi_excludes_flying
           is mN Hnoa Hreach).
Qed.

(* A run of REAL Mario-update frames is a run of modeled steps (step_models_real
   is exactly load-bearing here), so the same conclusion holds for the real
   per-frame Mario action update. *)
Lemma mario_run_is_step_run :
  forall s is s', reachable mem int mario_update s is s' ->
                  reachable mem int step s is s'.
Proof.
  intros s is s' H. induction H.
  - apply reach_nil.
  - eapply reach_cons; [ apply step_models_real; eassumption | exact IHreachable ].
Qed.

Corollary real_frames_need_A :
  forall (m0 mN : mem) (is : list int),
    Phi m0 ->
    noA_run int a_pressed_int is ->
    reachable mem int mario_update m0 is mN ->
    ~ flying_mem mN.
Proof.
  intros m0 mN is Hbase Hnoa Hreach.
  eapply flying_needs_A; [ exact Hbase | exact Hnoa | ].
  apply mario_run_is_step_run; exact Hreach.
Qed.

End FlyingStatement.
