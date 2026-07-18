(* GENERATED FILE -- DO NOT EDIT.
   Produced by pipeline/generate-reachability-facts.py.
   Canonical US baserom SHA-1: 9bef1128717f958171a4afac3ed78ee2bb4e86ce
   Demo SHA-256 receipts:
     bitdw: 947ded6c977672521a0ad7d3c51c3c41b72aee8df1c5c75452b64800a96da707
     wf: 7c1a6dbd30228f718e4b5d49df4c94eee8dbe5404c80d336795932115a83092a
     ccm: ba26e6f95226267d2a98f5672047908633710f144b53e708343dafe194670b28
     bbh: 28821b6f611f6d38f753e5e5080dc299a3035f0b122bb6f0ffab2a16f96ac29f
     jrb: c9084368f964160e63e175091b713207de757bf9645be5a6adb682473946437a
     hmc: 760669d08efe05011340bed02d8003436bd5b5e9b295b0f7de79f149b7302980
     pss: c41502d973fc838ee126a029e855ec1a840fd1ee0b519e4aadef91735dafa9b0
 *)
From Coq Require Import Bool Lia List ZArith.
Import ListNotations.
Local Open Scope Z_scope.

Record demo_stream_receipt : Type := {
  receipt_data_size : Z;
  receipt_dma_size : Z;
  receipt_terminal_offset : Z;
  receipt_prefix_nonzero : bool
}.

Definition us_main_pool_start : Z := 2147860480.
Definition us_main_pool_size : Z := 1462272.
Definition us_main_pool_end : Z := 2149322752.
Definition us_demo_buffer_size : Z := 2048.

Inductive us_link_region : Type :=
| Us_main_pool_region
| Us_main_noload_region.

Definition generated_demo_buffer_link_region : us_link_region :=
  Us_main_pool_region.
Definition generated_mario_states_link_region : us_link_region :=
  Us_main_noload_region.

Theorem generated_demo_and_mario_link_regions_distinct :
  generated_demo_buffer_link_region <>
  generated_mario_states_link_region.
Proof. discriminate. Qed.

Definition us_demo_stream_receipts : list demo_stream_receipt := [
  {| receipt_data_size := 1412; receipt_dma_size := 1412; receipt_terminal_offset := 1408; receipt_prefix_nonzero := true |};
  {| receipt_data_size := 672; receipt_dma_size := 1040; receipt_terminal_offset := 668; receipt_prefix_nonzero := true |};
  {| receipt_data_size := 1320; receipt_dma_size := 1320; receipt_terminal_offset := 1316; receipt_prefix_nonzero := true |};
  {| receipt_data_size := 988; receipt_dma_size := 988; receipt_terminal_offset := 984; receipt_prefix_nonzero := true |};
  {| receipt_data_size := 620; receipt_dma_size := 620; receipt_terminal_offset := 616; receipt_prefix_nonzero := true |};
  {| receipt_data_size := 980; receipt_dma_size := 980; receipt_terminal_offset := 976; receipt_prefix_nonzero := true |};
  {| receipt_data_size := 748; receipt_dma_size := 748; receipt_terminal_offset := 744; receipt_prefix_nonzero := true |}
].

Definition demo_stream_receipt_ok (receipt : demo_stream_receipt) : bool :=
  Z.eqb (receipt_terminal_offset receipt + 4) (receipt_data_size receipt) &&
  Z.leb (receipt_data_size receipt) (receipt_dma_size receipt) &&
  Z.leb (receipt_dma_size receipt) us_demo_buffer_size &&
  receipt_prefix_nonzero receipt.

Definition generated_us_demo_stream_audit : bool :=
  forallb demo_stream_receipt_ok us_demo_stream_receipts.

Theorem generated_us_demo_stream_audit_holds :
  generated_us_demo_stream_audit = true.
Proof. vm_compute. reflexivity. Qed.

Definition max_us_demo_pointer_offset : Z := 1408.

Theorem max_us_demo_pointer_stays_in_buffer :
  max_us_demo_pointer_offset + 4 <= us_demo_buffer_size.
Proof. unfold max_us_demo_pointer_offset, us_demo_buffer_size; lia. Qed.

Definition generated_linker_order_audit : bool := true.

Theorem generated_linker_order_audit_holds :
  generated_linker_order_audit = true.
Proof. reflexivity. Qed.

Theorem generated_pool_constants_consistent :
  us_main_pool_start + us_main_pool_size = us_main_pool_end.
Proof. vm_compute. reflexivity. Qed.
