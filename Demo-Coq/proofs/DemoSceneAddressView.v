From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Ctypes Integers Memory Values.
From Demo.Generated Require Import us_memory jp_memory.
From Demo.Proofs Require Import DemoNumericAddressExecution DemoSceneSourceInventory.
Import ListNotations.
Local Open Scope Z_scope.

(** An explicit view between numeric scene addresses and supplied memory blocks.
    This is NOT a new Clight dereference rule or an execution simulation. The
    identity of the active image/epoch and its extent must be established by the loader/native
    correspondence. In particular, a numerical address never chooses its owner. *)
Record demo_scene_address_image := SceneAddressImage {
  scene_address_epoch : nat;
  scene_address_block : block;
  scene_address_physical_base : Z;
  scene_address_start : Z;
  scene_address_length : Z
}.

Definition demo_decode_scene_image image address : option val :=
  let relative := Int.unsigned address -
    (2147483648 + scene_address_physical_base image + scene_address_start image) in
  if (0 <=? relative) && (relative <? scene_address_length image)
  then Some (Vptr (scene_address_block image) (Ptrofs.repr relative)) else None.

Definition demo_scene_view_load image memory chunk address : option val :=
  match demo_decode_scene_image image address with
  | Some (Vptr b offset) => Mem.load chunk memory b (Ptrofs.unsigned offset)
  | _ => None
  end.

Definition demo_scene_address_image_bounds image : Prop :=
  0 <= scene_address_physical_base image /\
  0 <= scene_address_start image /\
  0 < scene_address_length image /\
  scene_address_physical_base image + scene_address_start image +
    scene_address_length image <= 536870912.

Lemma demo_scene_cached_address : forall low,
  0 <= low < 2147483648 ->
  Int.or (Int.repr low) (Int.repr (-2147483648)) =
    Int.repr (2147483648 + low).
Proof.
  intros low Hrange.
  assert (Hlow : Int.and (Int.repr low) (Int.repr 2147483647) = Int.repr low).
  { unfold Int.and.
    rewrite Int.unsigned_repr by (change (0 <= low <= 4294967295); lia).
    change (Int.repr (Z.land low (Z.ones 31)) = Int.repr low).
    rewrite Z.land_ones by lia.
    change (Int.repr (low mod 2147483648) = Int.repr low).
    rewrite Z.mod_small by lia. reflexivity. }
  assert (Hdisjoint : Int.and (Int.repr low) (Int.repr (-2147483648)) = Int.zero).
  { rewrite <- Hlow at 1. rewrite Int.and_assoc.
    change (Int.and (Int.repr low) Int.zero = Int.zero).
    apply Int.and_zero. }
  rewrite <- Int.add_is_or by exact Hdisjoint.
  unfold Int.add.
  rewrite Int.unsigned_repr by (change (0 <= low <= 4294967295); lia).
  change (Int.repr (low + 2147483648) = Int.repr (2147483648 + low)).
  f_equal. lia.
Qed.

Lemma demo_scene_numeric_virtual_address : forall base address,
  0 <= base ->
  base + Int.unsigned (demo_n64_segment_offset address) < 536870912 ->
  demo_n64_virtual_address (Int.repr base) address =
    Int.repr (2147483648 + base + Int.unsigned (demo_n64_segment_offset address)).
Proof.
  intros base address Hbase Hbound.
  pose proof (Int.unsigned_range (demo_n64_segment_offset address)) as Hoff.
  unfold demo_n64_virtual_address, Int.add.
  rewrite (Int.unsigned_repr base) by (change (0 <= base <= 4294967295); lia).
  rewrite demo_scene_cached_address by lia. f_equal. lia.
Qed.

Lemma demo_scene_decode_region_hit : forall image offset,
  demo_scene_address_image_bounds image ->
  0 <= offset < scene_address_length image ->
  demo_decode_scene_image image
    (Int.repr (2147483648 + scene_address_physical_base image +
      scene_address_start image + offset)) =
    Some (Vptr (scene_address_block image) (Ptrofs.repr offset)).
Proof.
  intros image offset (Hbase & Hstart & Hlength & Hbound) Hoffset.
  unfold demo_decode_scene_image.
  rewrite Int.unsigned_repr by
    (change (0 <= 2147483648 + scene_address_physical_base image +
      scene_address_start image + offset <= 4294967295); lia).
  replace (2147483648 + scene_address_physical_base image +
    scene_address_start image + offset -
    (2147483648 + scene_address_physical_base image + scene_address_start image))
    with offset by lia.
  destruct (Z.leb_spec0 0 offset); [|lia].
  destruct (Z.ltb_spec0 offset (scene_address_length image)); [reflexivity|lia].
Qed.

Definition demo_scene_address_helper (us : bool) :=
  if us then us_memory.f_segmented_to_virtual else jp_memory.f_segmented_to_virtual.

Definition demo_scene_operand_view us descriptor is_geometry image address : Prop :=
  scene_source_area_checked us descriptor /\
  scene_source_native_operand us descriptor is_geometry = Some address /\
  scene_address_start image = Int.unsigned (demo_n64_segment_offset address) /\
  demo_scene_address_image_bounds image.

Theorem demo_scene_numeric_operand_decodes_to_supplied_image :
  forall us descriptor is_geometry image address,
  demo_scene_operand_view us descriptor is_geometry image address ->
  demo_decode_scene_image image
    (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) address) =
    Some (Vptr (scene_address_block image) Ptrofs.zero).
Proof.
  intros us descriptor is_geometry image address
    (Hsource & Hnative & Hstart & Hbounds).
  destruct Hbounds as (Hbase & Hnonnegative & Hlength & Hbound).
  rewrite demo_scene_numeric_virtual_address by lia.
  rewrite <- Hstart.
  replace (2147483648 + scene_address_physical_base image + scene_address_start image)
    with (2147483648 + scene_address_physical_base image + scene_address_start image + 0) by lia.
  apply demo_scene_decode_region_hit; [repeat split; assumption|lia].
Qed.

(** The first half is an actual call of the unchanged generated helper. The
    second half is an explicit view, not its caller's next Clight step. *)
Theorem demo_scene_helper_result_has_explicit_source_view :
  forall us descriptor is_geometry image address (ge : Clight.genv) memory table,
  demo_scene_operand_view us descriptor is_geometry image address ->
  Globalenvs.Genv.find_symbol ge N._sSegmentTable = Some table ->
  Mem.load Mint32 memory table (demo_n64_table_offset address) =
    Some (Vint (Int.repr (scene_address_physical_base image))) ->
  eval_funcall function_entry2 ge memory (Internal (demo_scene_address_helper us))
    [Vint address] Events.E0 memory
    (Vint (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) address)) /\
  demo_decode_scene_image image
    (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) address) =
    Some (Vptr (scene_address_block image) Ptrofs.zero).
Proof.
  intros us descriptor is_geometry image address ge memory table Hview Hsymbol Hload.
  split.
  - destruct us; exact (generated_demo_numeric_segment_executes ge memory table address
      (Int.repr (scene_address_physical_base image)) Hsymbol Hload).
  - eapply demo_scene_numeric_operand_decodes_to_supplied_image. exact Hview.
Qed.

Theorem demo_scene_view_load_at_native_operand :
  forall us descriptor is_geometry image address memory chunk,
  demo_scene_operand_view us descriptor is_geometry image address ->
  demo_scene_view_load image memory chunk
    (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) address) =
    Mem.load chunk memory (scene_address_block image) 0.
Proof.
  intros us descriptor is_geometry image address memory chunk Hview.
  unfold demo_scene_view_load.
  rewrite (demo_scene_numeric_operand_decodes_to_supplied_image _ _ _ _ _ Hview).
  reflexivity.
Qed.

(** Explicit local inhabitation of the address view. It neither chooses the
    active block nor establishes a loader epoch, authentic memory or gameplay. *)
Theorem demo_scene_address_view_local_witness :
  forall us descriptor is_geometry address epoch b,
  scene_source_area_checked us descriptor ->
  scene_source_native_operand us descriptor is_geometry = Some address ->
  Int.unsigned (demo_n64_segment_offset address) < 536870912 ->
  exists image, scene_address_epoch image = epoch /\ scene_address_block image = b /\
    demo_scene_operand_view us descriptor is_geometry image address.
Proof.
  intros us descriptor is_geometry address epoch b Hsource Hnative Hbound.
  exists (SceneAddressImage epoch b 0 (Int.unsigned (demo_n64_segment_offset address)) 1).
  split; [reflexivity|]. split; [reflexivity|].
  split; [exact Hsource|]. split; [exact Hnative|]. split; [reflexivity|].
  change (0 <= 0 /\ 0 <= Int.unsigned (demo_n64_segment_offset address) /\
    0 < 1 /\ 0 + Int.unsigned (demo_n64_segment_offset address) + 1 <= 536870912).
  pose proof (Int.unsigned_range (demo_n64_segment_offset address)).
  repeat split; lia.
Qed.

Definition demo_scene_address_view_claim : Prop :=
  forall us descriptor is_geometry image address (ge : Clight.genv) memory table,
  demo_scene_operand_view us descriptor is_geometry image address ->
  Globalenvs.Genv.find_symbol ge N._sSegmentTable = Some table ->
  Mem.load Mint32 memory table (demo_n64_table_offset address) =
    Some (Vint (Int.repr (scene_address_physical_base image))) ->
  eval_funcall function_entry2 ge memory (Internal (demo_scene_address_helper us))
    [Vint address] Events.E0 memory
    (Vint (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) address)) /\
  demo_decode_scene_image image
    (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) address) =
    Some (Vptr (scene_address_block image) Ptrofs.zero).

Theorem checked_demo_scene_address_view : demo_scene_address_view_claim.
Proof. exact demo_scene_helper_result_has_explicit_source_view. Qed.
