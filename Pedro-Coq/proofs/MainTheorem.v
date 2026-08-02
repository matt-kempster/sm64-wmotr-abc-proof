From Coq Require Import List ZArith.
From Pedro.Proofs Require Import
  GameTypes PedroCollision LandingDust RNGAdvance InputSemantics TTCSpinners
  TTCSpinnerGeometry TTCSpinnerSchedule.

(** Initial source-and-arithmetic capstone. Every conjunct is tied either to a
    generated Clight AST or to CompCert's executable binary32 operations. This
    theorem does not assert gameplay reachability or repeatability. *)
Theorem checked_pedro_rng_mechanism_us_jp :
  forall version,
    pedro_collision_source_receipt version /\
    landing_dust_source_receipt version /\
    rng_source_chain_receipt version /\
    (forall class,
      flat_landing_tap_witness class (flat_tap_speed class)).
Proof.
  intro version.
  refine (conj (pedro_collision_source_receipt_supported version) _).
  refine (conj (landing_dust_source_receipt_supported version) _).
  refine (conj (rng_source_chain_receipt_supported version) _).
  exact every_flat_floor_class_has_landing_tap.
Qed.

(** TTC source reduction plus the concrete geometry and schedule model.
    Reachable entry, linked Clight execution, and a positive bounded-oscillation
    control witness remain explicit checklist obligations. *)
Theorem checked_ttc_spinner_source_reduction_us_jp :
  forall version,
    ttc_spinner_source_receipt version /\
    ttc_geometry_source_receipt version /\
    ttc_schedule_source_receipt version /\
    (forall pitch,
      15856 <= pitch <= 15951 ->
      spinner_geometry_certificate version (pitch_table_index pitch) = true) /\
    pedro_collision_source_receipt version /\
    landing_dust_source_receipt version /\
    rng_source_chain_receipt version.
Proof.
  intro version.
  refine (conj (ttc_spinner_source_receipt_supported version) _).
  refine (conj (ttc_geometry_source_receipt_supported version) _).
  refine (conj (ttc_schedule_source_receipt_supported version) _).
  refine (conj (concrete_ttc_spinner_pitch_interval version) _).
  refine (conj (pedro_collision_source_receipt_supported version) _).
  refine (conj (landing_dust_source_receipt_supported version) _).
  exact (rng_source_chain_receipt_supported version).
Qed.
