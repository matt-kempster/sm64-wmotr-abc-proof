From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Integers.
From Pedro.Generated Require Import us_object_list_processor jp_object_list_processor.
From Pedro.Proofs Require Import GameTypes.
Import ListNotations.
Open Scope Z_scope.
Module PC := us_object_list_processor.

Record MarioParticleRow := {
  particle_request_mask : Z;
  particle_active_mask : Z;
  particle_model : Z;
  particle_behavior : ident
}.

(** Decode the complete initializer, including its sole terminal sentinel.
    Malformed rows, a missing sentinel, trailing words, and nonzero pointer
    offsets fail. This receipt does not execute the mutable runtime table. *)
Fixpoint decode_particle_table (words : list init_data)
    : option (list MarioParticleRow) :=
  match words with
  | [Init_int32 request; Init_int32 active; Init_int8 model;
     Init_space padding; Init_int32 pointer] =>
      if Int.eq request Int.zero && Int.eq active Int.zero &&
         Int.eq model Int.zero && Z.eqb padding 3 && Int.eq pointer Int.zero
      then Some [] else None
  | Init_int32 request :: Init_int32 active :: Init_int8 model ::
    Init_space padding :: Init_addrof behavior offset :: rest =>
      if negb (Int.eq request Int.zero) && Z.eqb padding 3 &&
         Ptrofs.eq offset Ptrofs.zero
      then match decode_particle_table rest with
        | Some rows => Some ({| particle_request_mask := Int.unsigned request;
                               particle_active_mask := Int.unsigned active;
                               particle_model := Int.unsigned model;
                               particle_behavior := behavior |} :: rows)
        | None => None end
      else None
  | _ => None
  end.

Definition mario_particle_initializer version : list init_data :=
  gvar_init (match version with VersionUS => PC.v_sParticleTypes
                | VersionJP => jp_object_list_processor.v_sParticleTypes end).

Definition particle_row request active model behavior : MarioParticleRow :=
  {| particle_request_mask := request; particle_active_mask := active;
     particle_model := model; particle_behavior := behavior |}.

Definition expected_mario_particle_rows : list MarioParticleRow :=
  [particle_row 1 1 142 PC._bhvMistParticleSpawner;
   particle_row 2 262144 0 PC._bhvVertStarParticleSpawner;
   particle_row 16 16 0 PC._bhvHorStarParticleSpawner;
   particle_row 8 8 149 PC._bhvSparkleParticleSpawner;
   particle_row 32 32 168 PC._bhvBubbleParticleSpawner;
   particle_row 64 64 167 PC._bhvWaterSplash;
   particle_row 128 128 166 PC._bhvIdleWaterWave;
   particle_row 512 512 164 PC._bhvPlungeBubble;
   particle_row 1024 1024 163 PC._bhvWaveTrail;
   particle_row 2048 2048 144 PC._bhvFireParticleSpawner;
   particle_row 256 256 0 PC._bhvShallowWaterWave;
   particle_row 4096 4096 0 PC._bhvShallowWaterSplash;
   particle_row 8192 8192 0 PC._bhvLeafParticleSpawner;
   particle_row 16384 65536 0 PC._bhvSnowParticleSpawner;
   particle_row 131072 131072 0 PC._bhvBreathParticleSpawner;
   particle_row 32768 16384 0 PC._bhvDirtParticleSpawner;
   particle_row 65536 32768 0 PC._bhvMistCircParticleSpawner;
   particle_row 262144 524288 0 PC._bhvTriangleParticleSpawner].

Theorem generated_mario_particle_table_us_jp :
  forall version, decode_particle_table (mario_particle_initializer version) =
    Some expected_mario_particle_rows.
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem generated_mario_particle_table_member_coverage_us_jp :
  forall version rows row,
    decode_particle_table (mario_particle_initializer version) = Some rows ->
    In row rows -> In row expected_mario_particle_rows.
Proof.
  intros version rows row Hdecode Hin.
  rewrite generated_mario_particle_table_us_jp in Hdecode.
  inversion Hdecode; subst; assumption.
Qed.

(** All masks, including computed combinations, use this same finite table.
    Membership is a source selection bound, not a spawn/allocation theorem. *)
Definition selected_particle_behaviors (flags : int) (rows : list MarioParticleRow)
    : list ident :=
  map particle_behavior (filter (fun row => negb (Int.eq
    (Int.and flags (Int.repr (particle_request_mask row))) Int.zero)) rows).

Theorem generated_particle_mask_selection_coverage_us_jp :
  forall version rows flags behavior,
    decode_particle_table (mario_particle_initializer version) = Some rows ->
    In behavior (selected_particle_behaviors flags rows) ->
    In behavior (map particle_behavior expected_mario_particle_rows).
Proof.
  intros version rows flags behavior Hdecode Hin.
  unfold selected_particle_behaviors in Hin.
  apply in_map_iff in Hin. destruct Hin as [row [Heq Hin]].
  apply filter_In in Hin. destruct Hin as [Hin _].
  apply in_map_iff. exists row. split; [exact Heq |].
  eapply generated_mario_particle_table_member_coverage_us_jp; eauto.
Qed.

Definition mario_particle_catalogue_claim : Prop :=
  (forall version, decode_particle_table (mario_particle_initializer version) =
    Some expected_mario_particle_rows) /\
  (forall version rows flags behavior,
    decode_particle_table (mario_particle_initializer version) = Some rows ->
    In behavior (selected_particle_behaviors flags rows) ->
    In behavior (map particle_behavior expected_mario_particle_rows)).

Theorem checked_mario_particle_catalogue_us_jp : mario_particle_catalogue_claim.
Proof. exact (conj generated_mario_particle_table_us_jp
  generated_particle_mask_selection_coverage_us_jp). Qed.
