From compcert Require Import AST Ctypes Clight Integers Memory Values.
From DemoWarp.Proofs Require Import GeneratedFacts LayoutFacts ByteStore.

Theorem demo_timer_mario_y_counterexample_capstone :
  event_subsequenceb expected_timer_decrement_trace
    (demo_events_s (fn_body G.f_run_demo_inputs)) = true /\
  timer_store_count (demo_events_s (fn_body G.f_run_demo_inputs)) = 1%nat /\
  generated_layout_claim /\
  access_mode (Tint I8 Unsigned noattr) = By_value Mint8unsigned /\
  Int.sub byte_c5 Int.one = byte_c4 /\
  Int.eq byte_c4 Int.zero = false /\
  (exists target_block before after,
    Mem.load Mint8unsigned before target_block
      mario_y_first_byte_offset = Some (Vint byte_c5) /\
    Mem.store Mint8unsigned before target_block
      mario_y_first_byte_offset (Vint byte_c4) = Some after /\
    Mem.load Mint8unsigned after target_block
      mario_y_first_byte_offset = Some (Vint byte_c4) /\
    (forall other_block other_offset,
      outside_y_byte target_block mario_y_first_byte_offset
        other_block other_offset ->
      Mem.load Mint8unsigned after other_block other_offset =
      Mem.load Mint8unsigned before other_block other_offset)) /\
  generated_direct_pointer_writer_claim.
Proof.
  split; [apply generated_run_demo_inputs_has_decrement_trace |].
  split; [apply generated_run_demo_inputs_has_one_timer_store |].
  split; [apply generated_layout_certificate |].
  split; [apply generated_timer_type_uses_unsigned_byte_access |].
  split; [apply decrement_c5_is_c4 |].
  split; [apply c4_is_nonzero |].
  split; [apply c5_to_c4_unsigned_byte_store_witness |].
  apply generated_direct_pointer_writer_certificate.
Qed.

Corollary unconditional_no_matching_byte_store_is_false :
  ~ (forall target_block before after,
      Mem.load Mint8unsigned before target_block
        mario_y_first_byte_offset = Some (Vint byte_c5) ->
      Mem.store Mint8unsigned before target_block
        mario_y_first_byte_offset (Vint byte_c4) <> Some after).
Proof.
  intros Himpossible.
  destruct c5_to_c4_unsigned_byte_store_witness as
    (target_block & before & after & Hload & Hstore & _).
  exact (Himpossible target_block before after Hload Hstore).
Qed.
