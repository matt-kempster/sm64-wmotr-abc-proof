(**
  Direct retail-MIPS store-footprint certificate for the Timer-131 entry.

  The selected Clight target leaves [sqrtf], [stop_sounds_from_source], and
  [stop_sounds_in_continuous_banks] abstract.  This file closes their memory
  frame at the authenticated JP-machine boundary instead: the complete code
  scan in [InkTimer131RetailMipsCode] fixes every store/call PC, while the
  symbolic effects below follow the standard VR4300 address calculations.

  This is intentionally narrower than a whole-console semantics.  It assumes
  immutable authenticated code, ordinary calls/returns, and a valid entry
  stack.  ACE, DMA, interrupts that write RAM, forged return PCs, and execution
  after an invalid access remain outside this machine fragment.
*)

From Coq Require Import Bool Lia List ZArith.
From LessThanOneAPress.Proofs Require Import InkTimer131RetailMipsCode.

Import ListNotations.
Local Open Scope Z_scope.

Inductive JPMipsExternalRoot : Type :=
| JPMipsSqrtf
| JPMipsStopSoundsFromSource
| JPMipsStopSoundsContinuous.

Record JPMipsStoreShape : Type := {
  jp_store_shape_pc : Z;
  jp_store_shape_offset : Z;
  jp_store_shape_width : Z
}.

Definition jp_store_shape (pc offset width : Z) : JPMipsStoreShape :=
  {| jp_store_shape_pc := pc;
     jp_store_shape_offset := offset;
     jp_store_shape_width := width |}.

(** Offsets are relative to the root routine's entry stack pointer, including
    every transitive callee.  The deepest continuous-bank chain is
    [continuous -> bank -> update -> begin_fade -> fade helper]. *)
Definition jp_source_stack_shapes : list JPMipsStoreShape :=
  [jp_store_shape 2150762236 (-12) 4;
   jp_store_shape 2150762240 (-8) 4;
   jp_store_shape 2150762244 (-16) 4;
   jp_store_shape 2150762248 (-20) 4;
   jp_store_shape 2150762252 (-24) 4;
   jp_store_shape 2150762256 (-28) 4;
   jp_store_shape 2150762268 (-4) 4;
   jp_store_shape 2150762272 (-32) 4;
   jp_store_shape 2150762276 (-36) 4;
   jp_store_shape 2150752544 (-60) 4;
   jp_store_shape 2150752552 (-56) 4;
   jp_store_shape 2150752560 (-52) 4;
   jp_store_shape 2150760692 (-92) 4;
   jp_store_shape 2150760696 (-80) 4;
   jp_store_shape 2150760932 (-81) 1;
   jp_store_shape 2150760992 (-81) 1;
   jp_store_shape 2150750156 (-108) 4;
   jp_store_shape 2150750292 (-108) 4;
   jp_store_shape 2150750300 (-104) 4].

Definition jp_continuous_stack_shapes : list JPMipsStoreShape :=
  [jp_store_shape 2150762644 (-4) 4;
   jp_store_shape 2150762464 (-44) 4;
   jp_store_shape 2150762500 (-28) 4;
   jp_store_shape 2150762504 (-32) 4;
   jp_store_shape 2150762508 (-36) 4;
   jp_store_shape 2150762512 (-40) 4;
   jp_store_shape 2150762516 (-48) 4;
   jp_store_shape 2150762520 (-24) 4;
   jp_store_shape 2150752544 (-76) 4;
   jp_store_shape 2150752552 (-72) 4;
   jp_store_shape 2150752560 (-68) 4;
   jp_store_shape 2150760692 (-108) 4;
   jp_store_shape 2150760696 (-96) 4;
   jp_store_shape 2150760932 (-97) 1;
   jp_store_shape 2150760992 (-97) 1;
   jp_store_shape 2150750156 (-124) 4;
   jp_store_shape 2150750292 (-124) 4;
   jp_store_shape 2150750300 (-120) 4].

Definition jp_root_stack_shapes
    (root : JPMipsExternalRoot) : list JPMipsStoreShape :=
  match root with
  | JPMipsSqrtf => []
  | JPMipsStopSoundsFromSource => jp_source_stack_shapes
  | JPMipsStopSoundsContinuous => jp_continuous_stack_shapes
  end.

(** Sequence-player stores are all relative to player zero's fixed base
    [0x80222a18].  The offset/width list includes the two stores in
    [begin_background_music_fade] and every store in both leaf helpers. *)
Definition jp_sequence_store_shapes : list JPMipsStoreShape :=
  [jp_store_shape 2150760780 32 4;
   jp_store_shape 2150761004 32 4;
   jp_store_shape 2150750180 14 2;
   jp_store_shape 2150750192 24 4;
   jp_store_shape 2150750244 2 1;
   jp_store_shape 2150750248 14 2;
   jp_store_shape 2150750252 28 4;
   jp_store_shape 2150750328 14 2;
   jp_store_shape 2150750384 24 4;
   jp_store_shape 2150750480 2 1;
   jp_store_shape 2150750484 14 2;
   jp_store_shape 2150750488 28 4].

Definition jp_nonstack_store_shapes : list JPMipsStoreShape :=
  [jp_store_shape 2150762380 0 4;  (* source sound-bank node + 20 *)
   jp_store_shape 2150762596 0 4;  (* continuous sound-bank node + 20 *)
   jp_store_shape 2150752592 0 2]  (* background-music mask *)
  ++ jp_sequence_store_shapes.

Definition jp_all_symbolic_store_shapes : list JPMipsStoreShape :=
  jp_source_stack_shapes ++ jp_continuous_stack_shapes ++
  jp_nonstack_store_shapes.

Definition jp_mips_store_width (word : Z) : Z :=
  let opcode := jp_mips_opcode word in
  if opcode =? 40 then 1
  else if opcode =? 41 then 2
  else if (opcode =? 44) || (opcode =? 45) ||
          (opcode =? 60) || (opcode =? 61) ||
          (opcode =? 62) || (opcode =? 63) then 8
  else 4.

Definition jp_shape_matches_store
    (shape : JPMipsStoreShape) (entry : Z * Z) : bool :=
  (jp_store_shape_pc shape =? fst entry) &&
  (jp_store_shape_width shape =? jp_mips_store_width (snd entry)).

Definition jp_store_has_shape (entry : Z * Z) : bool :=
  existsb (fun shape => jp_shape_matches_store shape entry)
    jp_all_symbolic_store_shapes.

Definition jp_shape_has_store (shape : JPMipsStoreShape) : bool :=
  existsb (fun entry => jp_shape_matches_store shape entry)
    jp_expected_store_words.

Definition jp_retail_external_store_classification_claim : Prop :=
  forallb jp_store_has_shape jp_expected_store_words = true /\
  forallb jp_shape_has_store jp_all_symbolic_store_shapes = true /\
  length jp_expected_store_words = 42%nat.

Theorem jp_retail_external_store_classification_checked :
  jp_retail_external_store_classification_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Record JPMipsStoreEvent : Type := {
  jp_store_event_pc : Z;
  jp_store_event_address : Z;
  jp_store_event_width : Z
}.

Definition jp_store_event (pc address width : Z) : JPMipsStoreEvent :=
  {| jp_store_event_pc := pc;
     jp_store_event_address := address;
     jp_store_event_width := width |}.

Definition jp_object_pool_start : Z := 2150875416. (* 0x8033c118 *)
Definition jp_object_pool_end : Z := 2151021336.   (* 0x8035fb18 *)
Definition jp_audio_bank_base : Z := 2151025736.  (* 0x80360c48 *)
Definition jp_music_mask_address : Z := 2150834448. (* 0x80332110 *)
Definition jp_sequence_player_zero : Z := 2149722648. (* 0x80222a18 *)

Definition jp_timer131_flag_address : Z := 2150916292. (* 0x803460c4 *)
Definition jp_timer131_graph_offset_address : Z := 2150916372.

Definition jp_sound_root (root : JPMipsExternalRoot) : Prop :=
  root = JPMipsStopSoundsFromSource \/
  root = JPMipsStopSoundsContinuous.

(** Direct store projection of the authenticated routines.  The [lbu]
    instructions bound every list index to [0..255]; the source loop bounds
    its bank to [0..9], and the continuous wrapper supplies exactly banks
    [1], [4], and [6].  No constructor stores through the source-position
    argument: its pointer is used only for equality comparison in the code. *)
Inductive JPMipsExternalStoreEffect
    (root : JPMipsExternalRoot) (entry_sp : Z) : JPMipsStoreEvent -> Prop :=
| JPMipsStackStore : forall shape,
    In shape (jp_root_stack_shapes root) ->
    JPMipsExternalStoreEffect root entry_sp
      (jp_store_event
        (jp_store_shape_pc shape)
        (entry_sp + jp_store_shape_offset shape)
        (jp_store_shape_width shape))
| JPMipsSourceAudioStore : forall bank index,
    root = JPMipsStopSoundsFromSource ->
    0 <= bank < 10 ->
    0 <= index < 256 ->
    JPMipsExternalStoreEffect root entry_sp
      (jp_store_event 2150762380
        (jp_audio_bank_base + bank * 1120 + index * 28 + 20) 4)
| JPMipsContinuousAudioStore : forall bank index,
    root = JPMipsStopSoundsContinuous ->
    In bank [1; 4; 6] ->
    0 <= index < 256 ->
    JPMipsExternalStoreEffect root entry_sp
      (jp_store_event 2150762596
        (jp_audio_bank_base + bank * 1120 + index * 28 + 20) 4)
| JPMipsMusicMaskStore :
    jp_sound_root root ->
    JPMipsExternalStoreEffect root entry_sp
      (jp_store_event 2150752592 jp_music_mask_address 2)
| JPMipsSequencePlayerStore : forall shape,
    jp_sound_root root ->
    In shape jp_sequence_store_shapes ->
    JPMipsExternalStoreEffect root entry_sp
      (jp_store_event
        (jp_store_shape_pc shape)
        (jp_sequence_player_zero + jp_store_shape_offset shape)
        (jp_store_shape_width shape)).

Definition jp_store_event_misses_object_pool
    (event : JPMipsStoreEvent) : Prop :=
  jp_store_event_address event + jp_store_event_width event <=
      jp_object_pool_start \/
  jp_object_pool_end <= jp_store_event_address event.

Definition jp_entry_stack_envelope_misses_object_pool (entry_sp : Z) : Prop :=
  entry_sp <= jp_object_pool_start \/
  jp_object_pool_end <= entry_sp - 128.

Lemma jp_root_stack_shape_bounds :
  forall root shape,
    In shape (jp_root_stack_shapes root) ->
    -128 <= jp_store_shape_offset shape /\
    0 < jp_store_shape_width shape /\
    jp_store_shape_offset shape + jp_store_shape_width shape <= 0.
Proof.
  intros root shape Hshape. destruct root; simpl in Hshape.
  - contradiction.
  - repeat (destruct Hshape as [Hshape | Hshape];
      [subst shape; cbn; lia |]). contradiction.
  - repeat (destruct Hshape as [Hshape | Hshape];
      [subst shape; cbn; lia |]). contradiction.
Qed.

Lemma jp_sequence_store_shape_bounds :
  forall shape,
    In shape jp_sequence_store_shapes ->
    0 <= jp_store_shape_offset shape /\
    0 < jp_store_shape_width shape /\
    jp_store_shape_offset shape + jp_store_shape_width shape <= 36.
Proof.
  intros shape Hshape. unfold jp_sequence_store_shapes in Hshape.
  repeat (destruct Hshape as [Hshape | Hshape];
    [subst shape; cbn; lia |]). contradiction.
Qed.

(** All paths through either sound root are covered.  List contents can be
    arbitrary bytes and the list may even cycle: every store that occurs
    still lands in the audio region, fixed music state, fixed sequence-player
    state, or the bounded stack envelope.  Termination is not required. *)
Theorem jp_retail_external_store_effect_misses_object_pool :
  forall root entry_sp event,
    jp_entry_stack_envelope_misses_object_pool entry_sp ->
    JPMipsExternalStoreEffect root entry_sp event ->
    jp_store_event_misses_object_pool event.
Proof.
  intros root entry_sp event Hstack Heffect.
  destruct Heffect as
    [shape Hshape
    |bank index Hroot Hbank Hindex
    |bank index Hroot Hbank Hindex
    |Hroot
    |shape Hroot Hshape].
  - pose proof (jp_root_stack_shape_bounds root shape Hshape)
      as [Hlower [Hwidth Hupper]].
    change
      (entry_sp + jp_store_shape_offset shape +
         jp_store_shape_width shape <= jp_object_pool_start \/
       jp_object_pool_end <= entry_sp + jp_store_shape_offset shape).
    unfold jp_entry_stack_envelope_misses_object_pool in Hstack.
    destruct Hstack as [Hbelow | Habove].
    + left. lia.
    + right. lia.
  - change
      (jp_audio_bank_base + bank * 1120 + index * 28 + 20 + 4 <=
         jp_object_pool_start \/
       jp_object_pool_end <=
         jp_audio_bank_base + bank * 1120 + index * 28 + 20).
    assert (Hbank_term : 0 <= bank * 1120).
    { apply Z.mul_nonneg_nonneg; lia. }
    assert (Hindex_term : 0 <= index * 28).
    { apply Z.mul_nonneg_nonneg; lia. }
    right. unfold jp_audio_bank_base, jp_object_pool_end. lia.
  - change
      (jp_audio_bank_base + bank * 1120 + index * 28 + 20 + 4 <=
         jp_object_pool_start \/
       jp_object_pool_end <=
         jp_audio_bank_base + bank * 1120 + index * 28 + 20).
    destruct Hbank as [Hbank | [Hbank | [Hbank | Hbank]]];
      try contradiction; subst bank;
      assert (Hindex_term : 0 <= index * 28) by
        (apply Z.mul_nonneg_nonneg; lia);
      right; unfold jp_audio_bank_base, jp_object_pool_end; lia.
  - change
      (jp_music_mask_address + 2 <= jp_object_pool_start \/
       jp_object_pool_end <= jp_music_mask_address).
    left. unfold jp_music_mask_address, jp_object_pool_start. lia.
  - pose proof (jp_sequence_store_shape_bounds shape Hshape)
      as [Hlower [Hwidth Hupper]].
    change
      (jp_sequence_player_zero + jp_store_shape_offset shape +
         jp_store_shape_width shape <= jp_object_pool_start \/
       jp_object_pool_end <=
         jp_sequence_player_zero + jp_store_shape_offset shape).
    left. unfold jp_sequence_player_zero, jp_object_pool_start. lia.
Qed.

Definition JPMipsExternalStoreTrace
    (root : JPMipsExternalRoot) (entry_sp : Z)
    (trace : list JPMipsStoreEvent) : Prop :=
  Forall (JPMipsExternalStoreEffect root entry_sp) trace.

Theorem jp_retail_external_store_trace_misses_object_pool :
  forall root entry_sp trace,
    jp_entry_stack_envelope_misses_object_pool entry_sp ->
    JPMipsExternalStoreTrace root entry_sp trace ->
    Forall jp_store_event_misses_object_pool trace.
Proof.
  intros root entry_sp trace Hstack Htrace.
  induction Htrace; constructor; eauto using
    jp_retail_external_store_effect_misses_object_pool.
Qed.

Definition jp_store_event_misses_timer131_cells
    (event : JPMipsStoreEvent) : Prop :=
  (jp_store_event_address event + jp_store_event_width event <=
      jp_timer131_flag_address \/
   jp_timer131_flag_address + 4 <= jp_store_event_address event) /\
  (jp_store_event_address event + jp_store_event_width event <=
      jp_timer131_graph_offset_address \/
   jp_timer131_graph_offset_address + 4 <= jp_store_event_address event).

Theorem jp_object_pool_frame_implies_timer131_cell_frame :
  forall event,
    jp_store_event_misses_object_pool event ->
    jp_store_event_misses_timer131_cells event.
Proof.
  intros event Hframe.
  unfold jp_store_event_misses_object_pool in Hframe.
  unfold jp_store_event_misses_timer131_cells.
  unfold jp_object_pool_start, jp_object_pool_end,
    jp_timer131_flag_address, jp_timer131_graph_offset_address in *.
  destruct Hframe; split; lia.
Qed.

(** The first reached continuous-bank entry in the authenticated prefix has
    SP [0x80207128].  Its full 128-byte conservative nested stack envelope is
    far below the object pool, so the live call discharges the stack premise. *)
Definition jp_timer131_continuous_entry_sp : Z := 2149609768.

Theorem jp_timer131_continuous_entry_stack_is_safe :
  jp_entry_stack_envelope_misses_object_pool
    jp_timer131_continuous_entry_sp.
Proof. unfold jp_entry_stack_envelope_misses_object_pool,
  jp_timer131_continuous_entry_sp, jp_object_pool_start, jp_object_pool_end;
  lia. Qed.

Theorem jp_timer131_live_continuous_trace_preserves_protected_cells :
  forall trace,
    JPMipsExternalStoreTrace JPMipsStopSoundsContinuous
      jp_timer131_continuous_entry_sp trace ->
    Forall jp_store_event_misses_timer131_cells trace.
Proof.
  intros trace Htrace.
  apply Forall_impl with (P := jp_store_event_misses_object_pool).
  - intros event Hframe.
    exact (jp_object_pool_frame_implies_timer131_cell_frame event Hframe).
  - apply jp_retail_external_store_trace_misses_object_pool with
      (root := JPMipsStopSoundsContinuous)
      (entry_sp := jp_timer131_continuous_entry_sp).
    + exact jp_timer131_continuous_entry_stack_is_safe.
    + exact Htrace.
Qed.

Definition InkTimer131RetailMipsExternalFrameCheckedBoundary : Prop :=
  jp_retail_external_code_manifest_claim /\
  jp_retail_external_store_classification_claim /\
  (forall root entry_sp trace,
    jp_entry_stack_envelope_misses_object_pool entry_sp ->
    JPMipsExternalStoreTrace root entry_sp trace ->
    Forall jp_store_event_misses_object_pool trace) /\
  jp_entry_stack_envelope_misses_object_pool
    jp_timer131_continuous_entry_sp.

Theorem ink_timer131_retail_mips_external_frame_checked_boundary_holds :
  InkTimer131RetailMipsExternalFrameCheckedBoundary.
Proof.
  unfold InkTimer131RetailMipsExternalFrameCheckedBoundary.
  split; [exact jp_retail_external_code_manifest_checked |].
  split; [exact jp_retail_external_store_classification_checked |].
  split.
  - exact jp_retail_external_store_trace_misses_object_pool.
  - exact jp_timer131_continuous_entry_stack_is_safe.
Qed.
