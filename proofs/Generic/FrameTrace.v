(* FrameTrace.v -- the temporal scaffolding for R3 ("you cannot enter ACT_FLYING
 * without pressing A"). See docs/the-frame.md and docs/trust-model.md.
 *
 * This is the trace-invariant HARNESS, abstract over the eventual frame model:
 *
 *   - S          a world (the Mario-relevant state)
 *   - Inp        one frame's input
 *   - a_pressed  did THIS frame newly press A? (concretely: INPUT_A_PRESSED, bit 1
 *                of m->input -- set, per docs/the-frame.md, iff A_BUTTON is on the
 *                controller's rising edge that frame)
 *   - step       one frame: execute_mario_action, abstracted. A RELATION, not a
 *                function, so un-modeled subsystems may move the state arbitrarily
 *                -- a sound over-approximation (anything we don't model is allowed
 *                to do anything, and we still prove safety).
 *   - flying     the state's action is a flying value (ACT_FLYING / ..._TRIPLE_JUMP)
 *
 * The point of this file is twofold:
 *
 *  (1) Prove the invariant-induction lemma `noA_run_not_flying`: a frame-local
 *      invariant Phi that (a) holds at the start, (b) survives any no-A frame, and
 *      (c) rules out flying, lifts to a whole-run safety property. This is the
 *      shape R3 will take; the remaining work is to instantiate S/Inp/step with the
 *      real frame model and DISCHARGE the three obligations (R1 bounds the case
 *      split; R2 says the gate is upstream so Phi must track the jump sequence; R4
 *      gives the base case for WMotR).
 *
 *  (2) Demonstrate, concretely, the trust-model claim (docs/trust-model.md): the
 *      strengthening invariant Phi is PROOF-INTERNAL. It appears only among the
 *      hypotheses of `noA_run_not_flying`; the CONCLUSION names only step / flying /
 *      a_pressed. A wrong Phi cannot mislead -- it just fails to prove. The concrete
 *      control below instantiates Phi away entirely, leaving a theorem in which Phi
 *      does not occur, and ALSO ships the non-vacuity witness (flying is reachable
 *      WITH A), so the no-A hypothesis is provably load-bearing, not vacuous.
 *
 * No CompCert dependency yet: this is the harness. The bridge to the clightgen'd
 * mario.v (instantiating `step` with the real per-frame action loop) is future work
 * and is where the model-faithfulness review lives.
 *)

From Coq Require Import List.
Import ListNotations.

Section Trace.
  Variable S : Type.
  Variable Inp : Type.
  Variable a_pressed : Inp -> bool.
  Variable step : Inp -> S -> S -> Prop.

  (* A run: fold `step` over a list of per-frame inputs, head = earliest frame. *)
  Inductive reachable : S -> list Inp -> S -> Prop :=
  | reach_nil  : forall s, reachable s [] s
  | reach_cons : forall i is s s' s'',
      step i s s' -> reachable s' is s'' -> reachable s (i :: is) s''.

  (* A no-A run: every frame's input fails to press A. *)
  Definition noA_run (is : list Inp) : Prop :=
    Forall (fun i => a_pressed i = false) is.

  (* Phi is preserved across an entire no-A run. (Phi is a PARAMETER here -- it is
     not fixed by this file, and it never escapes into a conclusion below.) *)
  Lemma reachable_preserves_Phi
    (Phi : S -> Prop)
    (Hstep : forall i s s', a_pressed i = false -> Phi s -> step i s s' -> Phi s') :
    forall s0 is s, reachable s0 is s -> Phi s0 -> noA_run is -> Phi s.
  Proof.
    intros s0 is s Hreach.
    induction Hreach as [s | i is s s' s'' Hst Hr IH]; intros Hphi Hnoa.
    - exact Hphi.
    - inversion Hnoa as [| i0 is0 Ha Hrest [Heqi Heqis]]; subst.
      apply IH; [ eapply Hstep; eauto | exact Hrest ].
  Qed.

  (* THE HARNESS. Note the conclusion mentions only step/flying/a_pressed via
     `reachable`, `noA_run`, and `flying` -- NOT Phi. Phi is purely a hypothesis. *)
  Theorem noA_run_not_flying
    (flying : S -> Prop)
    (Phi : S -> Prop) (init : S)
    (Hbase : Phi init)
    (Hstep : forall i s s', a_pressed i = false -> Phi s -> step i s s' -> Phi s')
    (Hsafe : forall s, Phi s -> ~ flying s) :
    forall is s, noA_run is -> reachable init is s -> ~ flying s.
  Proof.
    intros is s Hnoa Hreach Hfly.
    apply (Hsafe s); [ | exact Hfly ].
    eapply reachable_preserves_Phi; eauto.
  Qed.
End Trace.

(* ======================================================================
   Non-vacuity control: a minimal concrete model, to show
     (a) the harness instantiates to a Phi-free safety theorem, and
     (b) without the no-A hypothesis that theorem would be FALSE
         (flying is reachable WITH A) -- so the harness is not vacuous.
   This is the temporal analogue of the positive controls in Flying.v / Escape.v.
   ====================================================================== *)

Inductive Act := AGround | AFlying.

Definition cflying (s : Act) : Prop := s = AFlying.

(* A's effect: from the ground, pressing A flies; otherwise you stay grounded.
   (A one-step caricature of the jump-sequence chain -- enough to exercise the
   harness and witness non-vacuity.) *)
Definition cstep (i : bool) (s s' : Act) : Prop :=
  match s with
  | AGround => if i then s' = AFlying else s' = AGround
  | AFlying => s' = AFlying
  end.

(* (a) The harness specializes to a theorem with NO Phi in sight: a no-A run from
   the ground never reaches flying. Phi := (= AGround) is supplied and discharged. *)
Theorem control_noA_never_flies :
  forall is s,
    noA_run bool (fun b => b) is ->
    reachable Act bool cstep AGround is s ->
    ~ cflying s.
Proof.
  apply (noA_run_not_flying Act bool (fun b => b) cstep
           cflying (fun s => s = AGround) AGround).
  - reflexivity.
  - intros i s s' Ha Hphi Hst. subst s. destruct i.
    + discriminate Ha.
    + simpl in Hst. exact Hst.
  - intros s Hphi. subst s. discriminate.
Qed.

(* (b) ...but flying IS reachable when A is pressed -- so dropping `noA_run` makes
   the conclusion false. The no-A hypothesis is doing real work; not vacuous. *)
Example control_A_does_fly :
  reachable Act bool cstep AGround [true] AFlying.
Proof.
  eapply reach_cons; [ reflexivity | apply reach_nil ].
Qed.
