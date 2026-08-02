From Coq Require Import List ZArith.
From Pedro.Proofs Require Import
  GameTypes PedroCollision LandingDust RNGAdvance InputSemantics TTCSpinners
  TTCSpinnerGeometry TTCSpinnerSchedule DustPool DustRuntime.

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

(** Linked-symbol and source-derived execution projection for the dust episode.
    [pool] is the isolated reserve available to the three dust allocations;
    the theorem does not derive that reserve, the initially clear bit, or a
    dust-producing tap from a reachable retail TTC state. *)
Theorem checked_dust_source_projection_us_jp :
  forall version tap_frame pool,
    (3 <= usable_reserve pool)%nat ->
    dust_runtime_projection_claim version tap_frame pool false.
Proof.
  intros version tap_frame pool Hreserve.
  apply checked_dust_runtime_projection_us_jp.
  - exact Hreserve.
  - reflexivity.
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
