From Coq Require Import Lia ZArith.
From compcert Require Import Coqlib AST Ctypes Clight Integers Memory Values.
From DemoWarp.Proofs Require Import LayoutFacts.

Local Open Scope Z_scope.

Definition byte_c5 : int := Int.repr 197.
Definition byte_c4 : int := Int.repr 196.

Theorem generated_timer_type_uses_unsigned_byte_access :
  access_mode (Tint I8 Unsigned noattr) = By_value Mint8unsigned.
Proof. reflexivity. Qed.

Lemma assign_loc_tuchar_is_unsigned_byte_store :
  forall ce memory target_block target_offset value memory',
    assign_loc ce (Tint I8 Unsigned noattr)
      memory target_block target_offset Full
      (Vint value) memory' ->
    Mem.store Mint8unsigned memory target_block
      (Ptrofs.unsigned target_offset) (Vint value) = Some memory'.
Proof.
  intros ce memory target_block target_offset value memory' Hassign.
  inv Hassign.
  match goal with
  | Hmode : access_mode _ = By_value ?chunk,
    Hstore : Mem.storev ?chunk _ _ _ = Some _ |- _ =>
      simpl in Hmode;
      inversion Hmode;
      subst chunk;
      unfold Mem.storev in Hstore;
      exact Hstore
  end.
Qed.

Definition outside_y_byte
    (watched_block : block) (watched_offset : Z)
    (other_block : block) (other_offset : Z) : Prop :=
  other_block <> watched_block \/
  other_offset + 1 <= watched_offset \/
  watched_offset + 1 <= other_offset.

Theorem c5_to_c4_unsigned_byte_store_witness :
  exists target_block before after,
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
      Mem.load Mint8unsigned before other_block other_offset).
Proof.
  remember (Mem.alloc Mem.empty 0 200) as allocation eqn:Halloc.
  destruct allocation as [allocated target_block].
  assert (Hfreeable :
      Mem.valid_access allocated Mint8unsigned target_block
        mario_y_first_byte_offset Freeable).
  { eapply Mem.valid_access_alloc_same; eauto.
    - unfold mario_y_first_byte_offset. lia.
    - unfold mario_y_first_byte_offset. simpl. lia.
    - unfold mario_y_first_byte_offset. simpl. exists 64. lia. }
  assert (Hwritable :
      Mem.valid_access allocated Mint8unsigned target_block
        mario_y_first_byte_offset Writable).
  { eapply Mem.valid_access_implies; eauto.
    apply perm_F_any. }
  destruct (Mem.valid_access_store allocated Mint8unsigned target_block
    mario_y_first_byte_offset (Vint byte_c5) Hwritable)
    as [before Hbefore].
  assert (Hwritable_before :
      Mem.valid_access before Mint8unsigned target_block
        mario_y_first_byte_offset Writable).
  { eapply Mem.store_valid_access_1; eauto. }
  destruct (Mem.valid_access_store before Mint8unsigned target_block
    mario_y_first_byte_offset (Vint byte_c4) Hwritable_before)
    as [after Hafter].
  exists target_block, before, after.
  repeat split.
  - erewrite Mem.load_store_same by exact Hbefore.
    vm_compute. reflexivity.
  - exact Hafter.
  - erewrite Mem.load_store_same by exact Hafter.
    vm_compute. reflexivity.
  - intros other_block other_offset Houtside.
    eapply Mem.load_store_other; eauto.
Qed.

Theorem decrement_c5_is_c4 :
  Int.sub byte_c5 Int.one = byte_c4.
Proof. vm_compute. reflexivity. Qed.

Theorem c4_is_nonzero : Int.eq byte_c4 Int.zero = false.
Proof. vm_compute. reflexivity. Qed.
