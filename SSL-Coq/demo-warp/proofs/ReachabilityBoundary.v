From compcert Require Import Coqlib AST Integers Memory Values.
From DemoWarp.Proofs Require Import GeneratedFacts LayoutFacts ByteStore.

Theorem separate_block_byte_store_preserves_mario_y :
  forall before after demo_block mario_block demo_offset value,
    demo_block <> mario_block ->
    Mem.store Mint8unsigned before demo_block demo_offset
      (Vint value) = Some after ->
    Mem.load Mint8unsigned after mario_block
      mario_y_first_byte_offset =
    Mem.load Mint8unsigned before mario_block
      mario_y_first_byte_offset.
Proof.
  intros before after demo_block mario_block demo_offset value
    Hseparate Hstore.
  eapply Mem.load_store_other; eauto.
Qed.

Definition separated_demo_pointer_safety_claim : Prop :=
  generated_direct_pointer_writer_claim /\
  forall before after demo_block mario_block demo_offset value,
    demo_block <> mario_block ->
    Mem.store Mint8unsigned before demo_block demo_offset
      (Vint value) = Some after ->
    Mem.load Mint8unsigned after mario_block
      mario_y_first_byte_offset =
    Mem.load Mint8unsigned before mario_block
      mario_y_first_byte_offset.

Theorem separated_demo_pointer_cannot_change_mario_y :
  separated_demo_pointer_safety_claim.
Proof.
  split.
  - apply generated_direct_pointer_writer_certificate.
  - apply separate_block_byte_store_preserves_mario_y.
Qed.

Theorem alias_is_necessary_for_demo_timer_mario_y_byte_change :
  forall before after demo_block mario_block demo_offset value,
    Mem.store Mint8unsigned before demo_block demo_offset
      (Vint value) = Some after ->
    Mem.load Mint8unsigned after mario_block
      mario_y_first_byte_offset <>
    Mem.load Mint8unsigned before mario_block
      mario_y_first_byte_offset ->
    demo_block = mario_block.
Proof.
  intros before after demo_block mario_block demo_offset value
    Hstore Hchanged.
  destruct (peq demo_block mario_block) as [Hequal | Hseparate].
  - exact Hequal.
  - exfalso.
    apply Hchanged.
    eapply separate_block_byte_store_preserves_mario_y; eauto.
Qed.
