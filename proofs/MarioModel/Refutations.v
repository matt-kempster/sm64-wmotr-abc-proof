(* kept: the refutation record of the 2026-10-22 sweep (rows and run
   hypotheses found FALSE; each repaired in place, see docs/TRUST.md
   "Refutation sweep 2026-10-22").  Nothing consumes it: it is the proof
   that the OLD statements were unsatisfiable, and that the repaired ones
   escape the counterexample. *)
(* ====================================================================== *)
(* Refutations.v                                                           *)
(*                                                                        *)
(* R1. THE EXTERNAL-ORACLE HYPOTHESES OF EVERY RUN WITNESS WERE FALSE.    *)
(*                                                                        *)
(* The interpreter runs (PositiveControl, PoleControl, BootRun,           *)
(* TerrainRun / StartTerrain / StartSat) answer the unlinked externals     *)
(* with an oracle `world` and take, as a hypothesis, that every answer is *)
(* a CompCert behavior:                                                    *)
(*                                                                        *)
(*   world_ok ge := forall ef args m t v m',                              *)
(*     world ef args m = Some (t, v, m') -> external_call ef ge args m t v m'*)
(*                                                                        *)
(* Each oracle matched `EF_external n _` and answered sqrtf with           *)
(* Vsingle (sqrt x) at EVERY signature.  CompCert's own axiom             *)
(* external_functions_properties gives ec_well_typed: a behavior's result *)
(* has the signature's result type.  At a signature returning Xint a       *)
(* Vsingle result is impossible, so world_ok was FALSE for every genv,     *)
(* and so was TerrainRun.sqrtf_ieee (forall sg, a Vsingle behavior        *)
(* exists).  Every theorem conditional on them held VACUOUSLY:             *)
(*   - PositiveControl.A_pressed_frame_reaches_flying (GOAL 1's positive  *)
(*     control: "the step relation can reach flying with A pressed");     *)
(*   - PoleControl's no-A pole frame runs;                                 *)
(*   - BootRun.boot_frames_run (from-boot frames);                         *)
(*   - TerrainRun's loader-output tether, and StartSat's terrain_loaded /  *)
(*     frame_runs / ifs_tether conjuncts of goal2_start_sat.               *)
(* (The audit's axiom check could not see it: the hypothesis is a premise *)
(* of an implication, not an axiom.)                                       *)
(*                                                                        *)
(* REPAIR: PositiveControl / PoleControl answer sqrtf only at a single-  *)
(* returning signature (every generated sqrtf is (float) -> float), here; *)
(* BootRun / TerrainRun / sqrtf_ieee are repaired on the parallel branch  *)
(* (FpuValue.sqrtf_value at the real signature).  The runs call the real  *)
(* declaration, so they still compute.                                    *)
(* ====================================================================== *)

From Coq Require Import String List.
From compcert Require Import Coqlib Integers Floats Values AST Memory Globalenvs
  Events Clight.
From SM64.Proofs Require PositiveControl PoleControl.
Import ListNotations.
Local Open Scope string_scope.

(* a signature with sqrtf's name but an int result *)
Definition sg_bad : signature := mksignature [Xsingle] Xint cc_default.

(* CompCert's axiom: no external behavior returns a single at an int result *)
Lemma sqrtf_single_at_int_impossible : forall ge vargs m t x m',
    ~ external_functions_sem "sqrtf" sg_bad ge vargs m t (Vsingle x) m'.
Proof.
  intros ge vargs m t x m' H.
  exact (ec_well_typed (external_functions_properties "sqrtf" sg_bad) _ _ _ _ _ _ H).
Qed.

Definition oracle : Type := external_function -> list val -> mem -> option (trace * val * mem).

Definition oracle_ok (w : oracle) (ge : Clight.genv) : Prop :=
  forall ef args m t v m', w ef args m = Some (t, v, m') -> external_call ef ge args m t v m'.

(* any oracle that answers sqrtf with a single at sg_bad is unsound *)
Lemma oracle_ok_refuted : forall (w : oracle) ge,
    (exists x m y, w (EF_external "sqrtf" sg_bad) [Vsingle x] m = Some (E0, Vsingle y, m)) ->
    ~ oracle_ok w ge.
Proof.
  intros w ge (x & m & y & Hw) H.
  exact (sqrtf_single_at_int_impossible _ _ _ _ _ _ (H _ _ _ _ _ _ Hw)).
Qed.

(* ---- the four OLD oracles, verbatim ---- *)
Definition old_boot_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef with
  | EF_external n _ =>
      if String.eqb n "sqrtf" then
        match args with [Vsingle x] => Some (E0, Vsingle (Float32.sqrt x), m) | _ => None end
      else if String.eqb n "play_sound" || String.eqb n "reset_red_coins_collected"
              || String.eqb n "play_infinite_stairs_music"
              || String.eqb n "set_sound_moving_speed"
      then Some (E0, Vundef, m)
      else None
  | _ => None
  end.

Definition old_terrain_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef, args with
  | EF_external n _, [Vsingle x] =>
      if String.eqb n "sqrtf" then Some (E0, Vsingle (Float32.sqrt x), m) else None
  | EF_external n _, [] =>
      if String.eqb n "reset_red_coins_collected" then Some (E0, Vundef, m) else None
  | _, _ => None
  end.

Definition old_flat_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef with
  | EF_external n _ =>
      if String.eqb n "sqrtf" then
        match args with [Vsingle x] => Some (E0, Vsingle (Float32.sqrt x), m) | _ => None end
      else if String.eqb n "play_sound" || String.eqb n "play_infinite_stairs_music"
      then Some (E0, Vundef, m)
      else None
  | _ => None
  end.

Definition old_pole_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef with
  | EF_external n _ =>
      if String.eqb n "sqrtf" then
        match args with [Vsingle x] => Some (E0, Vsingle (Float32.sqrt x), m) | _ => None end
      else if String.eqb n "play_sound" || String.eqb n "play_infinite_stairs_music"
              || String.eqb n "set_sound_moving_speed"
      then Some (E0, Vundef, m)
      else None
  | _ => None
  end.

Ltac old_hit := exists Float32.zero, Mem.empty, (Float32.sqrt Float32.zero); reflexivity.

Theorem old_boot_world_ok_refuted : forall ge, ~ oracle_ok old_boot_world ge.
Proof. intros ge. apply oracle_ok_refuted. old_hit. Qed.
Theorem old_terrain_world_ok_refuted : forall ge, ~ oracle_ok old_terrain_world ge.
Proof. intros ge. apply oracle_ok_refuted. old_hit. Qed.
Theorem old_flat_world_ok_refuted : forall ge, ~ oracle_ok old_flat_world ge.
Proof. intros ge. apply oracle_ok_refuted. old_hit. Qed.
Theorem old_pole_world_ok_refuted : forall ge, ~ oracle_ok old_pole_world ge.
Proof. intros ge. apply oracle_ok_refuted. old_hit. Qed.

(* the OLD sqrtf_ieee (TerrainRun, StartSat's terrain_loaded antecedent) *)
Definition old_sqrtf_ieee : Prop :=
  forall sg (ge : Senv.t) x m, exists m',
    external_functions_sem "sqrtf" sg ge [Vsingle x] m E0 (Vsingle (Float32.sqrt x)) m'.

Theorem old_sqrtf_ieee_refuted : ~ old_sqrtf_ieee.
Proof.
  intros H.
  destruct (H sg_bad (Genv.to_senv (Genv.empty_genv unit unit nil)) Float32.zero Mem.empty)
    as (m' & Hs).
  exact (sqrtf_single_at_int_impossible _ _ _ _ _ _ Hs).
Qed.

(* ---- the repaired oracles escape the counterexample (BootRun / TerrainRun
   are repaired on another branch: FpuValue.sqrtf_value at the real
   signature) ---- *)
Lemma flat_world_repaired :
  forall x m, PositiveControl.flat_world (EF_external "sqrtf" sg_bad) [Vsingle x] m = None.
Proof. intros; reflexivity. Qed.
Lemma pole_world_repaired :
  forall x m, PoleControl.pole_world (EF_external "sqrtf" sg_bad) [Vsingle x] m = None.
Proof. intros; reflexivity. Qed.
