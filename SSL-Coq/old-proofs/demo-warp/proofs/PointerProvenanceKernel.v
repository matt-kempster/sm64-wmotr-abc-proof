From Coq Require Import List.
From compcert Require Import AST Integers Memory Values.
From DemoWarp.Proofs Require Import
  GeneratedFacts TargetUseCensus HardwareContracts.

Definition safe_demo_pointer_value (demo_block : block) (v : val) : Prop :=
  v = Vint Int.zero \/ exists ofs, v = Vptr demo_block ofs.

Theorem null_is_safe_demo_pointer :
  forall demo_block, safe_demo_pointer_value demo_block (Vint Int.zero).
Proof. intros; left; reflexivity. Qed.

Theorem pointer_plus_one_preserves_demo_block :
  forall demo_block ofs,
    safe_demo_pointer_value demo_block
      (Val.add (Vptr demo_block ofs) (Vint Int.one)).
Proof.
  intros demo_block ofs.
  right.
  exists (Ptrofs.add ofs (Ptrofs.of_int Int.one)).
  reflexivity.
Qed.

Theorem pointer_add_int_preserves_demo_block :
  forall demo_block ofs amount,
    safe_demo_pointer_value demo_block
      (Val.add (Vptr demo_block ofs) (Vint amount)).
Proof.
  intros demo_block ofs amount.
  right.
  exists (Ptrofs.add ofs (Ptrofs.of_int amount)).
  reflexivity.
Qed.

Theorem storing_safe_pointer_establishes_safe_pointer_cell :
  forall before after cell_block cell_offset demo_block value,
    safe_demo_pointer_value demo_block value ->
    Mem.store Mptr before cell_block cell_offset value = Some after ->
    exists loaded,
      Mem.load Mptr after cell_block cell_offset = Some loaded /\
      safe_demo_pointer_value demo_block loaded.
Proof.
  intros before after cell_block cell_offset demo_block value Hsafe Hstore.
  exists (Val.load_result Mptr value).
  split.
  - eapply Mem.load_store_same; exact Hstore.
  - destruct Hsafe as [Hzero | [ofs Hptr]].
    + subst value. left. reflexivity.
    + subst value. right. exists ofs. reflexivity.
Qed.

Definition generated_pointer_provenance_kernel_claim : Prop :=
  generated_target_use_surface_claim /\
  generated_direct_pointer_writer_claim /\
  normal_n64_hardware_frame_claim /\
  (forall demo_block, safe_demo_pointer_value demo_block (Vint Int.zero)) /\
  (forall demo_block ofs,
    safe_demo_pointer_value demo_block
      (Val.add (Vptr demo_block ofs) (Vint Int.one))).

Theorem generated_pointer_provenance_kernel_certificate :
  generated_pointer_provenance_kernel_claim.
Proof.
  unfold generated_pointer_provenance_kernel_claim.
  exact (conj generated_target_use_surface_certificate
    (conj generated_direct_pointer_writer_certificate
      (conj normal_n64_hardware_frame_certificate
        (conj null_is_safe_demo_pointer
          pointer_plus_one_preserves_demo_block)))).
Qed.
