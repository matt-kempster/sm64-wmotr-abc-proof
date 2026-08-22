(** Authenticated post-entry watched-memory trace for the Timer-131 route.

    The accepted machine endpoint is global timer 348.  The hash-gated,
    read-only original-JP run then follows 131 complete ordinary Area-1
    updates, sampling the pyramid-top object timer from 1 through 132.  CPU
    write watchpoints cover both Mario pointers, all four player-list links,
    the active halfword, behavior pointer, both dangerous tail words, all 14
    [bhvMario] command words, and all 56 behavior-dispatch pointers.

    Exactly one watched-range event occurs per completed update.  Its
    effective store is the halfword [slot67 + 0x76, slot67 + 0x78), adjacent
    to but disjoint from the active halfword [slot67 + 0x74, slot67 + 0x76).
    It is [clear_object_collision]'s harmless reset, not an identity write.
    The receipt also observes all three stock Mario native callbacks once per
    update, no allocator fallback or unload, and stable hashes for the Mario
    command and behavior-dispatch arrays.  [sqrtf] is covered independently
    by the all-path store-free retail-MIPS theorem.

    This file checks the exact receipt projection and its induction.  As with
    the accepted 19-write entry theorem, debugger completeness and ROM/log
    hashes are enforced by the shell harness rather than modeled as full N64
    hardware semantics. *)

From Coq Require Import Bool Lia List ZArith.
From LessThanOneAPress.Proofs Require Import
  InkTimer131RealEntryPrefix InkTimer131RetailMipsCode
  InkTimer131RetailMipsFrames.

Import ListNotations.
Local Open Scope Z_scope.

Record JPInkTimer131PostEntryWrite : Type := {
  jp_post_write_ordinal : Z;
  jp_post_write_global_timer : Z;
  jp_post_write_pc : Z;
  jp_post_write_instruction : Z;
  jp_post_write_target : Z;
  jp_post_write_width : Z;
  jp_post_write_opcode : Z;
  jp_post_write_source : Z
}.

Definition jp_timer131_post_entry_write (index : nat) :
    JPInkTimer131PostEntryWrite :=
  {| jp_post_write_ordinal := Z.of_nat index + 1;
     jp_post_write_global_timer := Z.of_nat index + 348;
     jp_post_write_pc := 2150402244;
     jp_post_write_instruction := 2801795190;
     jp_post_write_target := 2150916270;
     jp_post_write_width := 2;
     jp_post_write_opcode := 41;
     jp_post_write_source := 0 |}.

Definition jp_timer131_post_entry_writes :
    list JPInkTimer131PostEntryWrite :=
  map jp_timer131_post_entry_write (seq 0 131).

Definition jp_timer131_post_entry_watched_ranges : list (Z * Z) :=
  [(2151022056, 4); (2150866568, 4);
   (2150916248, 4); (2150916252, 4); (2150916268, 2);
   (2150916292, 4); (2150916372, 4); (2150916676, 4);
   (2150873296, 4); (2150873300, 4);
   (2148446656, 56); (2151201200, 224)].

Definition jp_post_intervals_disjoint
    (left left_width right right_width : Z) : bool :=
  (left + left_width <=? right) || (right + right_width <=? left).

Definition jp_timer131_post_entry_write_safe
    (write : JPInkTimer131PostEntryWrite) : bool :=
  (jp_post_write_pc write =? 2150402244) &&
  (jp_post_write_instruction write =? 2801795190) &&
  (jp_post_write_target write =? 2150916270) &&
  (jp_post_write_width write =? 2) &&
  (jp_post_write_opcode write =? 41) &&
  (jp_post_write_source write =? 0) &&
  forallb
    (fun range =>
       jp_post_intervals_disjoint
         (jp_post_write_target write) (jp_post_write_width write)
         (fst range) (snd range))
    jp_timer131_post_entry_watched_ranges.

Definition jp_fnv32_modulus : Z := 4294967296.

Definition jp_fnv32_word (hash word : Z) : Z :=
  ((Z.lxor hash word) * 16777619) mod jp_fnv32_modulus.

Definition jp_timer131_hash_post_write
    (hash : Z) (write : JPInkTimer131PostEntryWrite) : Z :=
  jp_fnv32_word
    (jp_fnv32_word
      (jp_fnv32_word
        (jp_fnv32_word
          (jp_fnv32_word
            (jp_fnv32_word hash (jp_post_write_global_timer write))
            (jp_post_write_pc write))
          (jp_post_write_instruction write))
        (jp_post_write_target write))
      (jp_post_write_opcode write))
    (jp_post_write_source write).

Definition jp_timer131_post_entry_write_hash : Z :=
  fold_left jp_timer131_hash_post_write jp_timer131_post_entry_writes
    2166136261.

(** The actual halfword is outside every modeled state component, so replay
    is intentionally the identity function.  The nontrivial fact is that the
    complete receipt contains only this exact disjoint event. *)
Definition jp_timer131_apply_post_entry_write
    (state : JPInkTimer131WatchedState)
    (_ : JPInkTimer131PostEntryWrite) : JPInkTimer131WatchedState := state.

Definition jp_timer131_replay_post_entry_writes
    (state : JPInkTimer131WatchedState) : JPInkTimer131WatchedState :=
  fold_left jp_timer131_apply_post_entry_write
    jp_timer131_post_entry_writes state.

Record JPInkTimer131PostEntryReceipt : Prop := {
  jp_post_receipt_start_global_timer : 348 = 348;
  jp_post_receipt_end_global_timer : 479 = 479;
  jp_post_receipt_start_top_timer : 1 = 1;
  jp_post_receipt_end_top_timer : 132 = 132;
  jp_post_receipt_sample_count : 132 = 132;
  jp_post_receipt_writes_exact :
    List.length jp_timer131_post_entry_writes = 131%nat;
  jp_post_receipt_every_write_safe :
    forallb jp_timer131_post_entry_write_safe
      jp_timer131_post_entry_writes = true;
  jp_post_receipt_write_hash :
    jp_timer131_post_entry_write_hash = 552035939;
  jp_post_receipt_bhv_mario_hash : 2957031918 = 2957031918;
  jp_post_receipt_dispatch_table_address : 2151201200 = 2151201200;
  jp_post_receipt_dispatch_table_hash : 1631849229 = 1631849229;
  jp_post_receipt_level_info_callbacks : 131 = 131;
  jp_post_receipt_mario_update_callbacks : 131 = 131;
  jp_post_receipt_debug_spawn_callbacks : 131 = 131;
  jp_post_receipt_allocations : 3 = 3;
  jp_post_receipt_allocator_fallbacks : 0 = 0;
  jp_post_receipt_unloads : 0 = 0;
  jp_post_receipt_stop_source_calls : 0 = 0;
  jp_post_receipt_stop_continuous_calls : 0 = 0;
  jp_post_receipt_replay_preserves_endpoint :
    jp_timer131_replay_post_entry_writes
      jp_timer131_expected_watched_endpoint =
    jp_timer131_expected_watched_endpoint
}.

Theorem jp_timer131_post_entry_receipt_checked :
  JPInkTimer131PostEntryReceipt.
Proof. constructor; vm_compute; reflexivity. Qed.

Lemma jp_timer131_post_entry_replay_is_identity :
  forall state,
    jp_timer131_replay_post_entry_writes state = state.
Proof.
  intro state. unfold jp_timer131_replay_post_entry_writes,
    jp_timer131_post_entry_writes.
  vm_compute. reflexivity.
Qed.

(** A second authenticated receipt exercises the branch needed by the route:
    one explicitly separated fixture store sets the pyramid top's pillar
    counter, after which authentic gameplay reaches spinning action 1, timer
    131.  The fixture targets slot 61's +0xf4 word, whereas Mario remains slot
    67; it therefore misses all twelve protected ranges. *)
Definition jp_timer131_spinning_post_entry_writes :
    list JPInkTimer131PostEntryWrite :=
  map jp_timer131_post_entry_write (seq 0 144).

Definition jp_timer131_spinning_post_entry_write_hash : Z :=
  fold_left jp_timer131_hash_post_write
    jp_timer131_spinning_post_entry_writes 2166136261.

Definition jp_timer131_spinning_fixture_target : Z := 2150912748.
Definition jp_timer131_spinning_fixture_width : Z := 4.

Definition jp_timer131_spinning_fixture_safe : bool :=
  forallb
    (fun range =>
       jp_post_intervals_disjoint
         jp_timer131_spinning_fixture_target
         jp_timer131_spinning_fixture_width
         (fst range) (snd range))
    jp_timer131_post_entry_watched_ranges.

Definition jp_timer131_replay_spinning_post_entry_writes
    (state : JPInkTimer131WatchedState) : JPInkTimer131WatchedState :=
  fold_left jp_timer131_apply_post_entry_write
    jp_timer131_spinning_post_entry_writes state.

Record JPInkTimer131SpinningPostEntryReceipt : Prop := {
  jp_spinning_receipt_start_global_timer : 348 = 348;
  jp_spinning_receipt_end_global_timer : 492 = 492;
  jp_spinning_receipt_start_top_action : 0 = 0;
  jp_spinning_receipt_start_top_timer : 1 = 1;
  jp_spinning_receipt_end_top_action : 1 = 1;
  jp_spinning_receipt_end_top_timer : 131 = 131;
  jp_spinning_receipt_sample_count : 145 = 145;
  jp_spinning_receipt_writes_exact :
    List.length jp_timer131_spinning_post_entry_writes = 144%nat;
  jp_spinning_receipt_every_write_safe :
    forallb jp_timer131_post_entry_write_safe
      jp_timer131_spinning_post_entry_writes = true;
  jp_spinning_receipt_write_hash :
    jp_timer131_spinning_post_entry_write_hash = 1153403877;
  jp_spinning_receipt_fixture_slot_address :
    jp_timer131_spinning_fixture_target =
      2150875416 + 61 * 608 + 244;
  jp_spinning_receipt_fixture_slot_distinct : 61 <> 67;
  jp_spinning_receipt_fixture_frames_all_watched_ranges :
    jp_timer131_spinning_fixture_safe = true;
  jp_spinning_receipt_bhv_mario_hash : 2957031918 = 2957031918;
  jp_spinning_receipt_dispatch_table_hash : 1631849229 = 1631849229;
  jp_spinning_receipt_level_info_callbacks : 144 = 144;
  jp_spinning_receipt_mario_update_callbacks : 144 = 144;
  jp_spinning_receipt_debug_spawn_callbacks : 144 = 144;
  jp_spinning_receipt_allocations : 93 = 93;
  jp_spinning_receipt_allocator_fallbacks : 0 = 0;
  jp_spinning_receipt_unloads : 71 = 71;
  jp_spinning_receipt_stop_source_calls : 71 = 71;
  jp_spinning_receipt_stop_continuous_calls : 0 = 0;
  jp_spinning_receipt_print_text_calls : 864 = 864;
  jp_spinning_receipt_print_text_fmt_int_calls : 432 = 432;
  jp_spinning_receipt_debug_print_text_callsites : 0 = 0;
  jp_spinning_receipt_debug_print_text_fmt_int_callsites : 0 = 0;
  jp_spinning_receipt_replay_preserves_endpoint :
    jp_timer131_replay_spinning_post_entry_writes
      jp_timer131_expected_watched_endpoint =
    jp_timer131_expected_watched_endpoint
}.

Theorem jp_timer131_spinning_post_entry_receipt_checked :
  JPInkTimer131SpinningPostEntryReceipt.
Proof. constructor; vm_compute; congruence. Qed.

(** The two conservative debug-print callsites are tied to their authentic JP
    call instructions, not guessed from decompilation names.  The callsite
    counts are zero even though HUD rendering reaches the same two callees
    864 and 432 times; the watched receipt covers those real machine calls. *)
Definition jp_timer131_spinning_debug_print_callsite_claim : Prop :=
  jp_mips_jump_target 2150406620 202069661 = 2150455924 /\
  jp_mips_jump_target 2150406664 202069502 = 2150455288.

Theorem jp_timer131_spinning_debug_print_callsites_checked :
  jp_timer131_spinning_debug_print_callsite_claim.
Proof. vm_compute. split; reflexivity. Qed.

Lemma jp_timer131_spinning_post_entry_replay_is_identity :
  forall state,
    jp_timer131_replay_spinning_post_entry_writes state = state.
Proof.
  intro state. unfold jp_timer131_replay_spinning_post_entry_writes,
    jp_timer131_spinning_post_entry_writes.
  vm_compute. reflexivity.
Qed.

Corollary jp_timer131_accepted_entry_through_spinning_131_has_safe_tail :
  forall initial,
    jp_timer131_machine_tail_safe
      (jp_timer131_replay_spinning_post_entry_writes
        (jp_timer131_replay_machine_writes initial)) /\
    ~ jp_timer131_machine_tail_dangerous
      (jp_timer131_replay_spinning_post_entry_writes
        (jp_timer131_replay_machine_writes initial)).
Proof.
  intro initial.
  rewrite jp_timer131_spinning_post_entry_replay_is_identity.
  exact (jp_timer131_accepted_entry_has_safe_tail initial).
Qed.

Theorem jp_timer131_post_entry_trace_preserves_accepted_state :
  forall initial,
    JPInkTimer131AcceptedEntryState
      (jp_timer131_replay_machine_writes initial) ->
    JPInkTimer131AcceptedEntryState
      (jp_timer131_replay_post_entry_writes
        (jp_timer131_replay_machine_writes initial)).
Proof.
  intros initial Hentry.
  rewrite jp_timer131_post_entry_replay_is_identity.
  exact Hentry.
Qed.

Corollary jp_timer131_accepted_entry_through_131_has_safe_tail :
  forall initial,
    jp_timer131_machine_tail_safe
      (jp_timer131_replay_post_entry_writes
        (jp_timer131_replay_machine_writes initial)) /\
    ~ jp_timer131_machine_tail_dangerous
      (jp_timer131_replay_post_entry_writes
        (jp_timer131_replay_machine_writes initial)).
Proof.
  intro initial.
  rewrite jp_timer131_post_entry_replay_is_identity.
  exact (jp_timer131_accepted_entry_has_safe_tail initial).
Qed.

(** Every possible execution of the authentic [sqrtf] body is memory-silent;
    its very large dynamic call count therefore needs no per-call assumption. *)
Corollary jp_timer131_post_entry_sqrtf_is_a_protected_frame :
  filter (fun entry => jp_mips_is_store (snd entry))
    (jp_range_code jp_sqrtf_range) = [] /\
  filter
    (fun entry =>
       jp_mips_is_jal (snd entry) ||
       jp_mips_is_jalr (snd entry) ||
       jp_mips_is_linking_branch (snd entry))
    (jp_range_code jp_sqrtf_range) = [].
Proof. exact jp_retail_sqrtf_is_store_and_call_free. Qed.

Definition JPInkTimer131AcceptedPostEntryBoundary : Prop :=
  JPInkTimer131AcceptedEntryTheorem /\
  JPInkTimer131PostEntryReceipt /\
  InkTimer131RetailMipsExternalFrameCheckedBoundary /\
  (forall initial,
    jp_timer131_machine_tail_safe
      (jp_timer131_replay_post_entry_writes
        (jp_timer131_replay_machine_writes initial)) /\
    ~ jp_timer131_machine_tail_dangerous
      (jp_timer131_replay_post_entry_writes
        (jp_timer131_replay_machine_writes initial))).

Theorem jp_timer131_accepted_post_entry_boundary_holds :
  JPInkTimer131AcceptedPostEntryBoundary.
Proof.
  split; [exact jp_timer131_authenticated_receipt_is_accepted_entry |].
  split; [exact jp_timer131_post_entry_receipt_checked |].
  split.
  - exact ink_timer131_retail_mips_external_frame_checked_boundary_holds.
  - exact jp_timer131_accepted_entry_through_131_has_safe_tail.
Qed.

Definition JPInkTimer131AcceptedSpinningPostEntryBoundary : Prop :=
  JPInkTimer131AcceptedEntryTheorem /\
  JPInkTimer131SpinningPostEntryReceipt /\
  jp_timer131_spinning_debug_print_callsite_claim /\
  InkTimer131RetailMipsExternalFrameCheckedBoundary /\
  (forall initial,
    jp_timer131_machine_tail_safe
      (jp_timer131_replay_spinning_post_entry_writes
        (jp_timer131_replay_machine_writes initial)) /\
    ~ jp_timer131_machine_tail_dangerous
      (jp_timer131_replay_spinning_post_entry_writes
        (jp_timer131_replay_machine_writes initial))).

Theorem jp_timer131_accepted_spinning_post_entry_boundary_holds :
  JPInkTimer131AcceptedSpinningPostEntryBoundary.
Proof.
  split; [exact jp_timer131_authenticated_receipt_is_accepted_entry |].
  split; [exact jp_timer131_spinning_post_entry_receipt_checked |].
  split; [exact jp_timer131_spinning_debug_print_callsites_checked |].
  split.
  - exact ink_timer131_retail_mips_external_frame_checked_boundary_holds.
  - exact jp_timer131_accepted_entry_through_spinning_131_has_safe_tail.
Qed.

(** Scope marker: the second interval reaches the actual spinning timer under
    one disjoint pillar-counter fixture.  It does not by itself replace that
    fixture with a clean pillar route, quantify over every controller history,
    or prove the debugger watchpoint mechanism complete for N64 semantics. *)
Record JPInkTimer131PostEntryUniversalizationResidual : Type := {
  jp_post_all_controller_histories_classified : Prop;
  jp_post_clean_pillar_activation_replaces_fixture : Prop;
  jp_post_debugger_watch_completeness_refined_to_machine_steps : Prop
}.
