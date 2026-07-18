From Coq Require Import Lia List ZArith.

Import ListNotations.
Local Open Scope Z_scope.

(** This module checks one source-audited, positive-velocity DOUBLE_POUND
    approach.  Its boundary premises are that the samples occur at the floor
    queries, both hands use the audited closed mesh and 1.5 scale, relative Y
    compares their origins, and the trace stays at relative Z = 0 with
    relative X expressed on the sibling closed mesh's axis.  The listed
    free-flight trace extends the ballistic calculation through the sibling's
    conservative Z = 0 X envelope.

    This is a phase-local trace fact.  It does not assume, state, or prove a
    global minimum separation between the two hands. *)
Definition hand_relative_point : Type := (Z * Z)%type.

Definition relative_x (point : hand_relative_point) : Z := fst point.
Definition relative_y (point : hand_relative_point) : Z := snd point.
Definition double_pound_trace_relative_z : Z := 0.
(** This 360-unit value is only the audited simultaneous setup for this
    positive approach.  It is not a global hand-separation invariant. *)
Definition double_pound_setup_separation_min : Z := 360.

(** Pinned closed-hand mesh geometry and the runtime hand scale.  At relative
    Z = 0, interpolation along the sloped left edge puts the scaled boundary
    near -107.7; [-108,102] is the audited conservative integer envelope for
    that slice.  The local maximum Y is 204 and the object scale is 3/2. *)
Definition closed_top_z0_x_min : Z := -108.
Definition closed_top_z0_x_max : Z := 102.
Definition closed_top_local_y : Z := 204.
Definition hand_scale_numerator : Z := 3.
Definition hand_scale_denominator : Z := 2.
Definition closed_top_scaled_y : Z := 306.
Definition eyerok_floor_query_buffer : Z := 78.
Definition closed_top_query_relative_y_min : Z :=
  closed_top_scaled_y - eyerok_floor_query_buffer.

Lemma double_pound_geometry_values :
  hand_scale_denominator * closed_top_scaled_y =
    hand_scale_numerator * closed_top_local_y /\
  closed_top_query_relative_y_min = 228.
Proof. split; reflexivity. Qed.

(** A necessary, intentionally incomplete horizontal test for the audited
    relative-Z-zero trace.  It grants every integer X in the conservative
    slice envelope; actual triangle containment can only reject more queries. *)
Definition inside_closed_top_x_envelope
    (point : hand_relative_point) : Prop :=
  closed_top_z0_x_min <= relative_x point /\
  relative_x point <= closed_top_z0_x_max.

(** The closed top is 306 units above the sibling origin.  The floor lookup
    can accept it only when it is at most 78 units above the moving hand's
    query, equivalently when relative Y is at least 228. *)
Definition closed_top_vertically_queryable
    (point : hand_relative_point) : Prop :=
  closed_top_scaled_y <=
    relative_y point + eyerok_floor_query_buffer.

Definition sibling_closed_top_floor_candidate
    (point : hand_relative_point) : Prop :=
  inside_closed_top_x_envelope point /\
  closed_top_vertically_queryable point.

(** Exact integer relative positions for the dangerous positive episode.
    The +85,+70,+55,+40,+25,+10 increments are followed by -5; once velocity
    is nonpositive the controller installs gravity -20, producing
    -25,-45,-65,... .  The X approach advances 30 units per listed tick.

    The prefix ends at the last vertically eligible query.  The suffix starts
    at the first sample inside the necessary closed-top X envelope. *)
Definition double_pound_trace_through_last_vertical
    : list hand_relative_point :=
  [(-360, 0); (-330, 85); (-300, 155); (-270, 210); (-240, 250);
   (-210, 275); (-180, 285); (-150, 280); (-120, 255)].

Definition double_pound_trace_from_first_horizontal
    : list hand_relative_point :=
  [(-90, 210); (-60, 145); (-30, 60); (0, -45); (30, -170);
   (60, -315); (90, -480); (120, -665)].

Definition double_pound_positive_approach_trace
    : list hand_relative_point :=
  double_pound_trace_through_last_vertical ++
  double_pound_trace_from_first_horizontal.

Lemma double_pound_trace_setup_values :
  double_pound_setup_separation_min = 360 /\
  hd_error double_pound_positive_approach_trace = Some (-360, 0).
Proof. split; reflexivity. Qed.

Lemma trace_prefix_is_outside_closed_top_x :
  Forall (fun point => ~ inside_closed_top_x_envelope point)
    double_pound_trace_through_last_vertical.
Proof.
  unfold double_pound_trace_through_last_vertical,
    inside_closed_top_x_envelope, relative_x,
    closed_top_z0_x_min, closed_top_z0_x_max.
  repeat (apply Forall_cons; [cbn; lia |]).
  apply Forall_nil.
Qed.

Lemma trace_suffix_is_below_closed_top_query_threshold :
  Forall (fun point => ~ closed_top_vertically_queryable point)
    double_pound_trace_from_first_horizontal.
Proof.
  unfold double_pound_trace_from_first_horizontal,
    closed_top_vertically_queryable, relative_y,
    closed_top_scaled_y, eyerok_floor_query_buffer.
  repeat (apply Forall_cons; [cbn; lia |]).
  apply Forall_nil.
Qed.

Lemma last_vertically_queryable_trace_point :
  last double_pound_trace_through_last_vertical (0, 0) = (-120, 255) /\
  closed_top_vertically_queryable (-120, 255) /\
  ~ inside_closed_top_x_envelope (-120, 255).
Proof.
  split; [reflexivity |].
  split.
  - unfold closed_top_vertically_queryable, closed_top_scaled_y,
      eyerok_floor_query_buffer, relative_y. cbn. lia.
  - unfold inside_closed_top_x_envelope, closed_top_z0_x_min,
      closed_top_z0_x_max, relative_x. cbn. lia.
Qed.

Lemma first_horizontally_eligible_trace_point :
  hd_error double_pound_trace_from_first_horizontal = Some (-90, 210) /\
  inside_closed_top_x_envelope (-90, 210) /\
  ~ closed_top_vertically_queryable (-90, 210) /\
  closed_top_query_relative_y_min - relative_y (-90, 210) = 18.
Proof.
  split; [reflexivity |].
  split.
  - unfold inside_closed_top_x_envelope, closed_top_z0_x_min,
      closed_top_z0_x_max, relative_x. cbn. lia.
  - split.
    + unfold closed_top_vertically_queryable, closed_top_scaled_y,
      eyerok_floor_query_buffer, relative_y. cbn. lia.
    + reflexivity.
Qed.

Theorem no_sibling_closed_top_floor_selection_along_trace :
  Forall (fun point => ~ sibling_closed_top_floor_candidate point)
    double_pound_positive_approach_trace.
Proof.
  unfold double_pound_positive_approach_trace.
  apply Forall_app. split.
  - induction trace_prefix_is_outside_closed_top_x as [|point rest Hx _ IH].
    + constructor.
    + constructor.
      * intros (Hinside & _). exact (Hx Hinside).
      * exact IH.
  - induction trace_suffix_is_below_closed_top_query_threshold
      as [|point rest Hy _ IH].
    + constructor.
    + constructor.
      * intros (_ & Hvertical). exact (Hy Hvertical).
      * exact IH.
Qed.

Definition double_pound_trace_certificate : Prop :=
  double_pound_trace_relative_z = 0 /\
  double_pound_setup_separation_min = 360 /\
  hd_error double_pound_positive_approach_trace = Some (-360, 0) /\
  closed_top_query_relative_y_min = 228 /\
  last double_pound_trace_through_last_vertical (0, 0) = (-120, 255) /\
  hd_error double_pound_trace_from_first_horizontal = Some (-90, 210) /\
  closed_top_query_relative_y_min - relative_y (-90, 210) = 18 /\
  Forall (fun point => ~ sibling_closed_top_floor_candidate point)
    double_pound_positive_approach_trace.

Theorem double_pound_trace_certificate_holds :
  double_pound_trace_certificate.
Proof.
  unfold double_pound_trace_certificate.
  refine (conj eq_refl _).
  refine (conj (proj1 double_pound_trace_setup_values) _).
  refine (conj (proj2 double_pound_trace_setup_values) _).
  refine (conj (proj2 double_pound_geometry_values) _).
  refine (conj (proj1 last_vertically_queryable_trace_point) _).
  refine (conj (proj1 first_horizontally_eligible_trace_point) _).
  refine (conj
    (proj2 (proj2 (proj2 first_horizontally_eligible_trace_point))) _).
  exact no_sibling_closed_top_floor_selection_along_trace.
Qed.
