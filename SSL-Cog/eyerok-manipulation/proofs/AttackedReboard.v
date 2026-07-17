From Coq Require Import Bool Lia List ZArith.
From SSLEyerok.Proofs Require Import HeightMilestones MarioHandContact.

Import ListNotations.
Local Open Scope Z_scope.

(** Exact integer arithmetic for the source-audited attack/reboard schedules.
    Heights are relative to the hand's home Y unless a theorem says
    [absolute].  This module proves the timing, floor-buffer, and interior
    witness arithmetic; the source audit supplies the update order, mesh
    writes, animation length, and interaction branches. *)

Definition reboard_floor_eligible (mario_y floor_y : Z) : Prop :=
  0 <= floor_y - mario_y <= floor_query_vertical_buffer.

Definition nonlethal_positive_origin_trace : list Z :=
  [26; 48; 66; 80; 90; 96; 98].

Definition nonlethal_complete_origin_trace : list Z :=
  [26; 48; 66; 80; 90; 96; 98; 96; 90; 80; 66; 48; 26; 0; 0].

(** Mario's position after the automatic second bounce and each subsequent
    air step, ending at the entry position of the frame where ATTACKED changes
    to RECOVER and installs the closed mesh. *)
Definition nonlethal_second_bounce_mario_trace : list Z :=
  [180; 206; 228; 246; 260; 270; 276; 278; 276; 270; 260].

(** Every frame from the lethal response through the first grounded frame.
    At the second automatic bounce we use the smaller, more favorable
    post-bounce gap 357 even though the frame's actual floor query occurred
    earlier with a larger gap. *)
Definition lethal_airborne_floor_gaps : list Z :=
  [347; 367; 387; 407; 427; 447; 357; 345; 333; 321; 309; 297; 285;
   273; 261; 249; 237; 225; 213; 201; 189; 177; 165; 153; 191].

Definition grounded_open_top_y : Z := 507.
Definition maximum_automatic_bounce_y : Z := 278.

Definition eyerok_home_y : Z := -1534.
Definition closed_reboard_relative_y : Z := 306.
Definition nonlethal_reboard_mario_query_y : Z := 260.
Definition nonlethal_reboard_gap : Z :=
  closed_reboard_relative_y - nonlethal_reboard_mario_query_y.

Lemma nonlethal_attack_origin_peak_is_98 :
  Forall (fun y => y <= 98) nonlethal_positive_origin_trace /\
  In 98 nonlethal_positive_origin_trace.
Proof.
  split.
  - repeat constructor; lia.
  - cbn. tauto.
Qed.

Lemma nonlethal_attack_returns_to_home_before_reboard :
  last nonlethal_complete_origin_trace 0 = 0.
Proof. reflexivity. Qed.

Lemma open_mesh_rejects_entire_second_bounce_arc :
  Forall
    (fun mario_y => ~ reboard_floor_eligible mario_y open_hand_top_offset)
    nonlethal_second_bounce_mario_trace.
Proof.
  unfold nonlethal_second_bounce_mario_trace, reboard_floor_eligible,
    open_hand_top_offset, floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

Lemma recover_mesh_swap_accepts_closed_top :
  nonlethal_reboard_gap = 46 /\
  reboard_floor_eligible
    nonlethal_reboard_mario_query_y closed_reboard_relative_y.
Proof.
  unfold nonlethal_reboard_gap, nonlethal_reboard_mario_query_y,
    closed_reboard_relative_y, reboard_floor_eligible,
    floor_query_vertical_buffer. lia.
Qed.

Lemma nonlethal_reboard_is_at_ordinary_grounded_height :
  eyerok_home_y + closed_reboard_relative_y = -1228.
Proof. reflexivity. Qed.

Lemma lethal_airborne_open_mesh_never_passes_floor_buffer :
  Forall (fun gap => floor_query_vertical_buffer < gap)
    lethal_airborne_floor_gaps.
Proof.
  unfold lethal_airborne_floor_gaps, floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

Lemma lethal_grounded_open_mesh_never_passes_floor_buffer :
  floor_query_vertical_buffer <
    grounded_open_top_y - maximum_automatic_bounce_y.
Proof. reflexivity. Qed.

(** A doubled-coordinate certificate for the interior X/Z witness described
    by the source audit.  At local (0,100), the scaled radial distance is 150.
    It lies inside the combined 262-unit interaction radius, 73.5 units clear
    of the open wall (greater than Mario's 50-unit wall radius), and 70.5
    units inside the later closed top.  Doubling represents the half units. *)
Definition witness_scaled_radius : Z := 150.
Definition combined_interaction_radius : Z := 262.
Definition open_wall_clearance_twice : Z := 147.
Definition mario_wall_radius_twice : Z := 100.
Definition closed_top_margin_twice : Z := 141.

Lemma ordinary_interior_reboard_witness :
  witness_scaled_radius < combined_interaction_radius /\
  mario_wall_radius_twice < open_wall_clearance_twice /\
  0 < closed_top_margin_twice.
Proof. repeat split; reflexivity. Qed.

Definition automatic_top_hit_reads_a : bool := false.

Lemma automatic_top_hit_needs_no_a_press :
  automatic_top_hit_reads_a = false /\
  (forall schedule frame,
    always_released_a schedule -> ~ a_press_edge schedule frame) /\
  (forall schedule frame,
    continuously_held_a schedule -> ~ a_press_edge schedule frame).
Proof.
  split.
  - reflexivity.
  - split.
    + exact always_released_has_no_press_edge.
    + exact continuously_held_has_no_press_edge.
Qed.

Definition attacked_reboard_certificate : Prop :=
  Forall (fun y => y <= 98) nonlethal_positive_origin_trace /\
  In 98 nonlethal_positive_origin_trace /\
  last nonlethal_complete_origin_trace 0 = 0 /\
  Forall
    (fun mario_y => ~ reboard_floor_eligible mario_y open_hand_top_offset)
    nonlethal_second_bounce_mario_trace /\
  nonlethal_reboard_gap = 46 /\
  reboard_floor_eligible
    nonlethal_reboard_mario_query_y closed_reboard_relative_y /\
  eyerok_home_y + closed_reboard_relative_y = -1228 /\
  Forall (fun gap => floor_query_vertical_buffer < gap)
    lethal_airborne_floor_gaps /\
  floor_query_vertical_buffer <
    grounded_open_top_y - maximum_automatic_bounce_y /\
  witness_scaled_radius < combined_interaction_radius /\
  mario_wall_radius_twice < open_wall_clearance_twice /\
  0 < closed_top_margin_twice /\
  automatic_top_hit_reads_a = false.

Theorem attacked_reboard_certificate_holds :
  attacked_reboard_certificate.
Proof.
  unfold attacked_reboard_certificate.
  refine (conj (proj1 nonlethal_attack_origin_peak_is_98) _).
  refine (conj (proj2 nonlethal_attack_origin_peak_is_98) _).
  refine (conj nonlethal_attack_returns_to_home_before_reboard _).
  refine (conj open_mesh_rejects_entire_second_bounce_arc _).
  refine (conj (proj1 recover_mesh_swap_accepts_closed_top) _).
  refine (conj (proj2 recover_mesh_swap_accepts_closed_top) _).
  refine (conj nonlethal_reboard_is_at_ordinary_grounded_height _).
  refine (conj lethal_airborne_open_mesh_never_passes_floor_buffer _).
  refine (conj lethal_grounded_open_mesh_never_passes_floor_buffer _).
  destruct ordinary_interior_reboard_witness as (Hradius & Hwall & Hmargin).
  repeat split; assumption || reflexivity.
Qed.
