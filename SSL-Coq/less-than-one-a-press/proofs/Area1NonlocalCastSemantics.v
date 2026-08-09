(** Route-relevant classification of SSL Area-1 nonlocal terrain queries.

    This module separates three cases which C source prose can otherwise
    conflate:

    - a binary32 value which CompCert converts to a local signed word;
    - a successful word conversion whose later signed-halfword narrowing is
      nonlocal or aliases a local terrain coordinate; and
    - a failed word conversion (NaN, infinity, or signed-word overflow for the
      concrete samples below).

    The target VR4300 enables the Invalid Operation exception, while a NaN
    conversion is also a trapping unimplemented-operation case.  The small
    target-prefix model below collapses those causes to a trap before [mfc1]
    and the halfword store.  The authenticated ROM opcodes and FPCSR
    setup are external receipts documented beside this file; a full MIPS
    small-step refinement and whole-execution preservation of the enable bit
    remain explicit obligations.

    Finite signed-word aliases are different: they really do reach the later
    signed-halfword narrowing.  The final section gives a conditional
    State-first capability at Y = 1778 + 65536.  It numerically selects the
    already checked timer-131 midpoint without using Graphics fallback.  It
    does not provide the clean pre-collision writer, live surface traversal,
    or post-copy lifecycle needed for a retail route. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import GameTypes RouteEvidence.

Import ListNotations.
Local Open Scope Z_scope.

(** The source cast is binary32 -> signed word -> signed halfword. *)
Definition terrain_s16_from_word (word : Int.int) : Z :=
  Int.signed (Int.sign_ext 16 word).

Definition terrain_s16_from_float (value : float32) : option Z :=
  match Float32.to_int value with
  | Some word => Some (terrain_s16_from_word word)
  | None => None
  end.

Inductive CompCertTerrainCastCase (value : float32) : Type :=
| CompCertCastLocal :
    forall word,
      Float32.to_int value = Some word ->
      legacy_pu_local_coordinate (Int.signed word) ->
      CompCertTerrainCastCase value
| CompCertCastSuccessfulNonlocal :
    forall word,
      Float32.to_int value = Some word ->
      ~ legacy_pu_local_coordinate (Int.signed word) ->
      CompCertTerrainCastCase value
| CompCertCastFailed :
    Float32.to_int value = None ->
    CompCertTerrainCastCase value.

Theorem compcert_terrain_cast_case_total :
  forall value, CompCertTerrainCastCase value.
Proof.
  intros value.
  destruct (Float32.to_int value) as [word |] eqn:Hcast.
  - destruct (Z_le_dec legacy_pu_local_min (Int.signed word)) as [Hmin | Hmin].
    + destruct (Z_le_dec (Int.signed word) legacy_pu_local_max)
        as [Hmax | Hmax].
      * apply (CompCertCastLocal value word Hcast).
        unfold legacy_pu_local_coordinate. lia.
      * apply (CompCertCastSuccessfulNonlocal value word Hcast).
        unfold legacy_pu_local_coordinate. lia.
    + apply (CompCertCastSuccessfulNonlocal value word Hcast).
      unfold legacy_pu_local_coordinate. lia.
  - exact (CompCertCastFailed value Hcast).
Qed.

Definition SuccessfulLocalTerrainAlias (value : float32) : Prop :=
  exists word,
    Float32.to_int value = Some word /\
    ~ legacy_pu_local_coordinate (Int.signed word) /\
    legacy_pu_local_coordinate (terrain_s16_from_word word).

(** [find_floor] rejects horizontal X/Z coordinates at or beyond 8192 only
    after the signed-halfword narrowing.  This is distinct from the smaller
    route-local SSL mesh envelope used above; Y has no corresponding boundary
    test.  The split below is arithmetic only.  Connecting it to the generated
    branch and to a non-[NULL] floor still needs Clight/list execution. *)
Definition engine_horizontal_lookup_coordinate (coordinate : Z) : Prop :=
  -8192 < coordinate < 8192.

Inductive CompCertHorizontalTerrainCastCase (value : float32) : Type :=
| CompCertHorizontalCastEligible :
    forall word,
      Float32.to_int value = Some word ->
      engine_horizontal_lookup_coordinate (terrain_s16_from_word word) ->
      CompCertHorizontalTerrainCastCase value
| CompCertHorizontalCastBoundaryRejected :
    forall word,
      Float32.to_int value = Some word ->
      ~ engine_horizontal_lookup_coordinate (terrain_s16_from_word word) ->
      CompCertHorizontalTerrainCastCase value
| CompCertHorizontalCastFailed :
    Float32.to_int value = None ->
    CompCertHorizontalTerrainCastCase value.

Theorem compcert_horizontal_terrain_cast_case_total :
  forall value, CompCertHorizontalTerrainCastCase value.
Proof.
  intros value.
  destruct (Float32.to_int value) as [word |] eqn:Hcast.
  - destruct (Z_lt_dec (-8192) (terrain_s16_from_word word))
      as [Hlower | Hlower].
    + destruct (Z_lt_dec (terrain_s16_from_word word) 8192)
        as [Hupper | Hupper].
      * apply (CompCertHorizontalCastEligible value word Hcast).
        unfold engine_horizontal_lookup_coordinate. lia.
      * apply (CompCertHorizontalCastBoundaryRejected value word Hcast).
        unfold engine_horizontal_lookup_coordinate. lia.
    + apply (CompCertHorizontalCastBoundaryRejected value word Hcast).
      unfold engine_horizontal_lookup_coordinate. lia.
  - exact (CompCertHorizontalCastFailed value Hcast).
Qed.

(** Concrete target-prefix semantics.  [TargetCastMaskedInvalid] is left
    deliberately uninterpreted because neither target runs this prefix with
    Invalid disabled. *)
Inductive TargetTerrainCastResult : Type :=
| TargetCastCoordinate (coordinate : Z)
| TargetCastTrap
| TargetCastMaskedInvalid.

Definition target_terrain_cast_prefix
    (invalid_exception_enabled : bool)
    (value : float32) : TargetTerrainCastResult :=
  match Float32.to_int value with
  | Some word => TargetCastCoordinate (terrain_s16_from_word word)
  | None =>
      if invalid_exception_enabled
      then TargetCastTrap
      else TargetCastMaskedInvalid
  end.

Definition fpcsr_flush_subnormals_bit : Z := 16777216. (* 0x01000000 *)
Definition fpcsr_invalid_enable_bit : Z := 2048.       (* 0x00000800 *)
Definition retail_initial_fpcsr : Z := 16779264.       (* 0x01000800 *)

Definition fpcsr_invalid_enabled (control : Z) : bool :=
  negb (Z.eqb (Z.land control fpcsr_invalid_enable_bit) 0).

Theorem retail_initial_fpcsr_has_invalid_enabled :
  retail_initial_fpcsr =
    Z.lor fpcsr_flush_subnormals_bit fpcsr_invalid_enable_bit /\
  fpcsr_invalid_enabled retail_initial_fpcsr = true.
Proof. vm_compute. split; reflexivity. Qed.

(** The canonical ROM byte receipts for the three instructions which build
    [0x01000800] and call [__osSetFpcCsr].  They are data receipts rather than
    a ROM parser or MIPS execution theorem. *)
Definition jp_fpcsr_initialization_words : list Z :=
  [1006895360; 202153452; 881068032].
  (* 3c040100; 0c0c9dec; 34840800 *)

Definition us_fpcsr_initialization_words : list Z :=
  [1006895360; 202154444; 881068032].
  (* 3c040100; 0c0ca1cc; 34840800 *)

Definition fpcsr_initialization_word_receipt_claim : Prop :=
  jp_fpcsr_initialization_words =
    [1006895360; 202153452; 881068032] /\
  us_fpcsr_initialization_words =
    [1006895360; 202154444; 881068032].

Theorem fpcsr_initialization_word_receipt_checked :
  fpcsr_initialization_word_receipt_claim.
Proof. vm_compute. split; reflexivity. Qed.

Theorem enabled_failed_cast_traps_before_terrain_coordinate :
  forall value,
    Float32.to_int value = None ->
    target_terrain_cast_prefix true value = TargetCastTrap.
Proof.
  intros value Hfailed.
  unfold target_terrain_cast_prefix.
  rewrite Hfailed. reflexivity.
Qed.

Theorem enabled_failed_cast_cannot_produce_coordinate :
  forall value coordinate,
    Float32.to_int value = None ->
    target_terrain_cast_prefix true value <>
      TargetCastCoordinate coordinate.
Proof.
  intros value coordinate Hfailed Heq.
  rewrite (enabled_failed_cast_traps_before_terrain_coordinate value Hfailed)
    in Heq.
  discriminate.
Qed.

(** Representative failed and boundary inputs. *)
Definition cast_qnan : float32 := f32_bits 2143289344.       (* 0x7fc00000 *)
Definition cast_positive_infinity : float32 :=
  f32_bits 2139095040.                                      (* 0x7f800000 *)
Definition cast_negative_infinity : float32 :=
  f32_bits 4286578688.                                      (* 0xff800000 *)
Definition cast_positive_two_to_31 : float32 :=
  f32_bits 1325400064.                                      (* 0x4f000000 *)
Definition cast_below_negative_two_to_31 : float32 :=
  f32_bits 3472883713.                                      (* 0xcf000001 *)
Definition cast_largest_positive_word_float : float32 :=
  f32_bits 1325400063.                                      (* 0x4effffff *)
Definition cast_negative_two_to_31 : float32 :=
  f32_bits 3472883712.                                      (* 0xcf000000 *)

(** The architecture/manual boundary makes NaN, infinity, and signed-word
    overflow trapping conversion inputs (Invalid, or the VR4300's trapping
    unimplemented-operation case for NaN).  Connecting those concrete bit
    patterns to CompCert's [None] result is kept separate so this generic
    semantics module remains cheap to check. *)
Definition RepresentativeFailedCastClassificationObligation : Prop :=
  Float32.to_int cast_qnan = None /\
  Float32.to_int cast_positive_infinity = None /\
  Float32.to_int cast_negative_infinity = None /\
  Float32.to_int cast_positive_two_to_31 = None /\
  Float32.to_int cast_below_negative_two_to_31 = None.

Theorem representative_failed_casts_trap_if_classified :
  RepresentativeFailedCastClassificationObligation ->
  target_terrain_cast_prefix true cast_qnan = TargetCastTrap /\
  target_terrain_cast_prefix true cast_positive_infinity = TargetCastTrap /\
  target_terrain_cast_prefix true cast_negative_infinity = TargetCastTrap /\
  target_terrain_cast_prefix true cast_positive_two_to_31 = TargetCastTrap /\
  target_terrain_cast_prefix true cast_below_negative_two_to_31 =
    TargetCastTrap.
Proof.
  intros (Hnan & Hposinf & Hneginf & Hhigh & Hlow).
  repeat split; apply enabled_failed_cast_traps_before_terrain_coordinate;
    assumption.
Qed.

(** These are the remaining execution bridges.  They are definitions, not
    assumptions used by any theorem above. *)
(** A retail execution relation must have no outcome other than the modeled
    one.  The soundness direction is intentional: merely admitting the
    modeled result would not exclude an additional coordinate result.  A
    concrete inhabitant must make [TargetCastTrap] terminal for this prefix,
    including the exception-handler path, rather than resume at [mfc1]. *)
Definition RetailInvalidCastExecutionRefinementObligation
    (executes_target_prefix :
      Z -> float32 -> TargetTerrainCastResult -> Prop) : Prop :=
  forall control value result,
    fpcsr_invalid_enabled control = true ->
    executes_target_prefix control value result ->
    result = target_terrain_cast_prefix true value.

Definition RetailInvalidEnablePreservationObligation
    (reachable_cast_control : Z -> Prop) : Prop :=
  forall control,
    reachable_cast_control control ->
    fpcsr_invalid_enabled control = true.

(** This names the separate handler/continuation fact needed by a concrete
    target execution.  It is a schema, not an assumption used below. *)
Definition RetailInvalidTrapContinuationExclusionSchema
    (resumes_at_coordinate_store_after_trap : float32 -> Prop) : Prop :=
  forall value,
    Float32.to_int value = None ->
    ~ resumes_at_coordinate_store_after_trap value.

Definition Area1NonlocalCastCheckedBoundary : Prop :=
  fpcsr_initialization_word_receipt_claim /\
  fpcsr_invalid_enabled retail_initial_fpcsr = true /\
  (forall value,
    Float32.to_int value = None ->
    target_terrain_cast_prefix true value = TargetCastTrap).

Theorem area1_nonlocal_cast_checked_boundary :
  Area1NonlocalCastCheckedBoundary.
Proof.
  unfold Area1NonlocalCastCheckedBoundary.
  split; [exact fpcsr_initialization_word_receipt_checked |].
  split; [exact (proj2 retail_initial_fpcsr_has_invalid_enabled) |].
  exact enabled_failed_cast_traps_before_terrain_coordinate.
Qed.
