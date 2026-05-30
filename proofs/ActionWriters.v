(* ActionWriters.v -- whole-(game-)program enumeration of MarioState.action
 * writers, extending Flying.v's per-TU analysis toward closing leak #3 for the
 * action field. See docs/whole-program-action-writers.md.
 *
 * WHY THIS FILE EXISTS. Flying.v established, over 6 TUs (mario, the airborne /
 * moving action sets, level_update, behavior_actions, mario_actions_automatic,
 * interaction), the complete set of functions that directly assign
 * MarioState.action, and that NONE assigns a flying constant. Those are not the
 * only TUs that touch Mario's action. This file adds the remaining
 * high-probability Mario-action / Mario-step TUs and re-runs the SAME verified
 * analyses (Flying.mario_action_writers / Flying.flying_action_writers) on them.
 *
 * THE GREP-IS-INSUFFICIENT POINT (made concrete in Flying.v): a whole-tree
 * `grep "->action ="` misses mario.c:1840 (a multi-line gMarioState->action
 * assignment in init_mario), which the Clight analysis catches (mario's writer
 * count is 3, not 2). So we enumerate by kernel-checked reflexivity over the real
 * AST, not by text search.
 *
 * RESULT FOR THIS BATCH. None of the six TUs here contains ANY direct write to
 * MarioState.action (every mario_action_writers list is empty). I.e. these TUs
 * change Mario's action *only* by calling set_mario_action -- they never raw-poke
 * the field. That is exactly the choke-point picture R1b wanted, now extended.
 * (Non-vacuity: the SAME mario_action_writers definition returns the non-empty
 * sets in Flying.v -- mario=3, interaction=2, etc. -- so an empty result here is
 * a real "no writer", not a broken analysis.)
 *
 * AXIOM NOTE. Every lemma here is "Closed under the global context" (Print
 * Assumptions, via pipeline/assumptions.sh) -- like Flying.v's per-TU lemmas.
 * We intentionally do NOT bundle them into one `/\` theorem: any such conjunction
 * reports CompCert's 4 standard float axioms (Flocq), because its TYPE mentions
 * the prog float constants and Print Assumptions traverses the type. See the
 * comment at the end of this file. The fully-closed artifact is the lemma list.
 *
 * SCOPE / leaks still open (named, per the standing honesty rule):
 *   - These are src/game Mario-facing TUs; src/engine and the rest of src/game
 *     are not yet all scanned (the doc's full IN list). This file is the next
 *     batch, not the closure.
 *   - Indirect / aliased writes (memcpy, union punning, pointer arithmetic into
 *     gMarioState) are invisible to a field-write syntactic scan = leak #1.
 *   - "Writers across the whole program" remains a CONJUNCTION of per-TU facts
 *     until CompCert Linking fuses the TUs into one prog = leak #3 proper. *)

From Coq Require Import List ZArith PArith.BinPos.
Import ListNotations.
Local Open Scope Z_scope.
From compcert Require Import AST Integers Ctypes Cop Clight.
From SM64.Proofs Require Import Reach Flying.
From SM64.Generated Require mario_actions_submerged mario_actions_stationary
  mario_actions_cutscene mario_actions_object mario_step mario_misc.

(* ======================================================================
   Per-TU action-writer enumeration for the new batch.
   Every one is EMPTY: no direct MarioState.action field write in any of them.
   ====================================================================== *)

Example submerged_action_writers_empty :
  mario_action_writers mario_actions_submerged._MarioState
    mario_actions_submerged._action mario_actions_submerged.prog = [].
Proof. reflexivity. Qed.

Example stationary_action_writers_empty :
  mario_action_writers mario_actions_stationary._MarioState
    mario_actions_stationary._action mario_actions_stationary.prog = [].
Proof. reflexivity. Qed.

Example cutscene_action_writers_empty :
  mario_action_writers mario_actions_cutscene._MarioState
    mario_actions_cutscene._action mario_actions_cutscene.prog = [].
Proof. reflexivity. Qed.

Example object_action_writers_empty :
  mario_action_writers mario_actions_object._MarioState
    mario_actions_object._action mario_actions_object.prog = [].
Proof. reflexivity. Qed.

Example step_action_writers_empty :
  mario_action_writers mario_step._MarioState
    mario_step._action mario_step.prog = [].
Proof. reflexivity. Qed.

Example misc_action_writers_empty :
  mario_action_writers mario_misc._MarioState
    mario_misc._action mario_misc.prog = [].
Proof. reflexivity. Qed.

(* ======================================================================
   A fortiori: no TU writes a flying constant to MarioState.action.
   (Implied by the lists above being empty, but stated directly -- it is the
   property we actually care about, and it is independently reflexivity-checked.)
   ====================================================================== *)

Example no_raw_flying_action_write_submerged :
  flying_action_writers mario_actions_submerged._MarioState
    mario_actions_submerged._action mario_actions_submerged.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_stationary :
  flying_action_writers mario_actions_stationary._MarioState
    mario_actions_stationary._action mario_actions_stationary.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_cutscene :
  flying_action_writers mario_actions_cutscene._MarioState
    mario_actions_cutscene._action mario_actions_cutscene.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_object :
  flying_action_writers mario_actions_object._MarioState
    mario_actions_object._action mario_actions_object.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_step :
  flying_action_writers mario_step._MarioState
    mario_step._action mario_step.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_misc :
  flying_action_writers mario_misc._MarioState
    mario_misc._action mario_misc.prog = [].
Proof. reflexivity. Qed.

(* CONSOLIDATED STATEMENT -- deliberately NOT a single bundled `/\` theorem.
   Across all six newly-scanned TUs there is no direct writer of MarioState.action
   at all (the twelve Examples above), so in particular none raw-assigns a flying
   constant. Combined with Flying.v's six TUs, the only route to a flying action
   remains set_mario_action called with a flying argument (the five R1 sites).

   We keep the twelve individual lemmas rather than a bundled conjunction ON
   PURPOSE. Each individual lemma is "Closed under the global context" (Print
   Assumptions). But ANY conjunction of them -- however proved, including by
   `exact (conj closed1 (conj closed2 ...))` from the already-closed lemmas --
   reports CompCert's 4 standard float axioms (Classical_Prop.classic,
   FunctionalExtensionality, two ClassicalDedekindReals = the Flocq base). The
   reason is that the conjunction's TYPE contains the six `prog` terms with their
   float constants, and Print Assumptions traverses the type, not just the proof.
   Verified empirically (pipeline/assumptions.sh). So the honest, fully-closed
   artifact is the list of per-TU lemmas, not a headline conjunction. *)
