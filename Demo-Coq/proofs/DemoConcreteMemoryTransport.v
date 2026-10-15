From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Coqlib Integers Memdata Memory Values.
From Demo.Proofs Require Import DemoSceneAddressView DemoNumericAddressExecution.
Import ListNotations.
Local Open Scope Z_scope.

(** An actual flat-RAM read for cached KSEG0 addresses. There is no source
    image decoder or arbitrary memory oracle here. The RAM block, its bytes,
    the selected image/epoch and native correspondence require separate facts.
    This definition does not alter ordinary Clight.step2 or Mem.load. *)
Definition demo_concrete_ram_address (address : int) : Z :=
 Int.unsigned address - 2147483648.
Definition demo_concrete_ram_load (ram : mem) (ram_block : block)
    (chunk : memory_chunk) (address : int) : option val :=
 if (2147483648 <=? Int.unsigned address) && (Int.unsigned address <? 2684354560)
 then Mem.load chunk ram ram_block (demo_concrete_ram_address address)
 else None.

Definition demo_scalar_memory_chunk (chunk : memory_chunk) : Prop :=
 In chunk [Mint8signed; Mint8unsigned; Mint16signed; Mint16unsigned; Mint32].

(** Pure bytes exclude symbolic Init_addrof fragments. This is a concrete
    equality of two actual whole-image memory reads, not a load oracle.
    The image is explicitly supplied; this predicate does not identify an
    active image or establish a loader epoch from a numerical address. *)
Definition demo_scalar_scene_image_bytes (source ram : mem) (ram_block : block)
    (image : demo_scene_address_image) (bytes : list Integers.Byte.int) : Prop :=
 Mem.loadbytes source (scene_address_block image) 0 (scene_address_length image) =
   Some (map Memdata.Byte bytes) /\
 Mem.loadbytes ram ram_block
   (scene_address_physical_base image + scene_address_start image)
   (scene_address_length image) = Some (map Memdata.Byte bytes).

Definition demo_scalar_byte_slice (bytes : list Integers.Byte.int) (offset length : Z)
    : list Integers.Byte.int :=
 firstn (Z.to_nat length) (skipn (Z.to_nat offset) bytes).

Lemma demo_concrete_ram_load_cached : forall ram ram_block chunk physical,
 0 <= physical < 536870912 ->
 demo_concrete_ram_load ram ram_block chunk (Int.repr (2147483648 + physical)) =
 Mem.load chunk ram ram_block physical.
Proof.
 intros ram ram_block chunk physical Hrange.
 unfold demo_concrete_ram_load, demo_concrete_ram_address.
 rewrite Int.unsigned_repr by (change (0 <= 2147483648 + physical <= 4294967295); lia).
 destruct (Z.leb_spec0 2147483648 (2147483648 + physical)); [|lia].
 destruct (Z.ltb_spec0 (2147483648 + physical) 2684354560); [|lia].
 replace (2147483648 + physical - 2147483648) with physical by lia. reflexivity.
Qed.

(** Extract a subrange from an actual whole-image read. Both the bounds and
    the bytes in the result come from Mem.loadbytes, not a decoder oracle. *)
Lemma demo_memory_loadbytes_slice : forall memory block base length bytes offset count,
 Mem.loadbytes memory block base length = Some bytes ->
 0 <= offset -> 0 <= count -> offset + count <= length ->
 Mem.loadbytes memory block (base + offset) count =
 Some (firstn (Z.to_nat count) (skipn (Z.to_nat offset) bytes)).
Proof.
 intros memory block base length bytes offset count Hwhole Hoffset Hcount Hextent.
 replace length with (offset + (length-offset)) in Hwhole by lia.
 destruct (Mem.loadbytes_split memory block base offset (length-offset) bytes Hwhole
   ltac:(lia) ltac:(lia)) as (prefix & suffix & Hprefix & Hsuffix & Hbytes).
 replace (length-offset) with (count + (length-offset-count)) in Hsuffix by lia.
 destruct (Mem.loadbytes_split memory block (base+offset) count (length-offset-count) suffix Hsuffix
   ltac:(lia) ltac:(lia)) as (middle & tail & Hmiddle & Htail & Hsuffixbytes).
 pose proof (Mem.loadbytes_length _ _ _ _ _ Hprefix) as Hprefixlength.
 pose proof (Mem.loadbytes_length _ _ _ _ _ Hmiddle) as Hmiddlelength.
 rewrite Hbytes, <- Hprefixlength, skipn_app, skipn_all, Nat.sub_diag. cbn.
 rewrite Hsuffixbytes, <- Hmiddlelength, firstn_app, firstn_all, Nat.sub_diag. cbn.
 rewrite app_nil_r. exact Hmiddle.
Qed.

Lemma demo_memory_pure_byte_slice : forall memory block base length bytes offset count,
 Mem.loadbytes memory block base length = Some (map Memdata.Byte bytes) ->
 0 <= offset -> 0 <= count -> offset + count <= length ->
 Mem.loadbytes memory block (base + offset) count =
 Some (map Memdata.Byte (demo_scalar_byte_slice bytes offset count)).
Proof.
 intros memory block base length bytes offset count Hwhole Hoffset Hcount Hextent.
 rewrite (demo_memory_loadbytes_slice _ _ _ _ _ _ _ Hwhole Hoffset Hcount Hextent).
 unfold demo_scalar_byte_slice. rewrite skipn_map, firstn_map. reflexivity.
Qed.

Definition demo_scalar_decoded_value chunk bytes : val :=
 match chunk with
 | Mint8signed => Vint (Int.sign_ext 8 (Int.repr (decode_int bytes)))
 | Mint8unsigned => Vint (Int.zero_ext 8 (Int.repr (decode_int bytes)))
 | Mint16signed => Vint (Int.sign_ext 16 (Int.repr (decode_int bytes)))
 | Mint16unsigned => Vint (Int.zero_ext 16 (Int.repr (decode_int bytes)))
 | Mint32 => Vint (Int.repr (decode_int bytes))
 | _ => Vundef
 end.

Lemma demo_pure_scalar_decode : forall chunk bytes,
 demo_scalar_memory_chunk chunk ->
 decode_val chunk (map Memdata.Byte bytes) = demo_scalar_decoded_value chunk bytes.
Proof.
 intros chunk bytes Hchunk.
 assert (Hbytes : proj_bytes (map Memdata.Byte bytes) = Some bytes).
 { change (proj_bytes (inj_bytes bytes) = Some bytes). apply proj_inj_bytes. }
 unfold decode_val. rewrite Hbytes. unfold demo_scalar_memory_chunk in Hchunk.
 repeat destruct Hchunk as [Hchunk|Hchunk]; try contradiction; subst chunk; reflexivity.
Qed.

(** The generated target is big endian. These equations expose the exact
    scalar-byte interpretation; pointer Fragment encodings are excluded. *)
Lemma demo_big_endian_byte_unsigned : forall byte,
 demo_scalar_decoded_value Mint8unsigned [byte] =
 Vint (Int.zero_ext 8 (Int.repr (Integers.Byte.unsigned byte))).
Proof.
 intros byte. assert (Hdecode : decode_int [byte] = Integers.Byte.unsigned byte).
 { change (Integers.Byte.unsigned byte + 0 * 256 = Integers.Byte.unsigned byte). ring. }
 unfold demo_scalar_decoded_value. rewrite Hdecode. reflexivity.
Qed.

Lemma demo_big_endian_halfword : forall first second,
 demo_scalar_decoded_value Mint16unsigned [first;second] =
 Vint (Int.zero_ext 16 (Int.repr
   (256 * Integers.Byte.unsigned first + Integers.Byte.unsigned second))).
Proof.
 intros first second.
 assert (Hdecode : decode_int [first;second] =
   256 * Integers.Byte.unsigned first + Integers.Byte.unsigned second).
 { change (Integers.Byte.unsigned second + (Integers.Byte.unsigned first + 0 * 256) * 256 =
     256 * Integers.Byte.unsigned first + Integers.Byte.unsigned second). ring. }
 unfold demo_scalar_decoded_value. rewrite Hdecode. reflexivity.
Qed.

Lemma demo_big_endian_word : forall first second third fourth,
 demo_scalar_decoded_value Mint32 [first;second;third;fourth] =
 Vint (Int.repr (16777216 * Integers.Byte.unsigned first +
   65536 * Integers.Byte.unsigned second + 256 * Integers.Byte.unsigned third +
   Integers.Byte.unsigned fourth)).
Proof.
 intros first second third fourth.
 assert (Hdecode : decode_int [first;second;third;fourth] =
   16777216 * Integers.Byte.unsigned first + 65536 * Integers.Byte.unsigned second +
   256 * Integers.Byte.unsigned third + Integers.Byte.unsigned fourth).
 { change (Integers.Byte.unsigned fourth + (Integers.Byte.unsigned third +
     (Integers.Byte.unsigned second + (Integers.Byte.unsigned first + 0 * 256) * 256) * 256) * 256 =
     16777216 * Integers.Byte.unsigned first + 65536 * Integers.Byte.unsigned second +
     256 * Integers.Byte.unsigned third + Integers.Byte.unsigned fourth). ring. }
 unfold demo_scalar_decoded_value. rewrite Hdecode. reflexivity.
Qed.

Theorem demo_scalar_scene_load_transport :
 forall source ram ram_block image bytes chunk offset,
 demo_scene_address_image_bounds image ->
 demo_scalar_scene_image_bytes source ram ram_block image bytes ->
 demo_scalar_memory_chunk chunk ->
 0 <= offset -> offset + size_chunk chunk <= scene_address_length image ->
 (align_chunk chunk | offset) ->
 (align_chunk chunk | scene_address_physical_base image + scene_address_start image + offset) ->
 let value := demo_scalar_decoded_value chunk
   (demo_scalar_byte_slice bytes offset (size_chunk chunk)) in
 Mem.load chunk source (scene_address_block image) offset = Some value /\
 demo_concrete_ram_load ram ram_block chunk
   (Int.repr (2147483648 + scene_address_physical_base image + scene_address_start image + offset)) = Some value.
Proof.
 intros source ram ram_block image bytes chunk offset Hbounds [Hsource Hram]
   Hchunk Hoffset Hextent Halignsource Halignram.
 pose proof (size_chunk_pos chunk) as Hsize.
 pose proof (demo_memory_pure_byte_slice source (scene_address_block image) 0
   (scene_address_length image) bytes offset (size_chunk chunk) Hsource Hoffset ltac:(lia) Hextent)
   as Hsourcebytes.
 pose proof (demo_memory_pure_byte_slice ram ram_block
   (scene_address_physical_base image + scene_address_start image)
   (scene_address_length image) bytes offset (size_chunk chunk) Hram Hoffset ltac:(lia) Hextent)
   as Hrambytes.
 replace (0 + offset) with offset in Hsourcebytes by lia.
 pose proof (Mem.loadbytes_load chunk _ _ _ _ Hsourcebytes Halignsource) as Hsourceload.
 pose proof (Mem.loadbytes_load chunk _ _ _ _ Hrambytes Halignram) as Hramload.
 rewrite (demo_pure_scalar_decode _ _ Hchunk) in Hsourceload,Hramload.
 split; [exact Hsourceload |].
 replace (2147483648 + scene_address_physical_base image + scene_address_start image + offset)
   with (2147483648 + (scene_address_physical_base image + scene_address_start image + offset)) by lia.
 rewrite demo_concrete_ram_load_cached; [exact Hramload |].
 destruct Hbounds as (Hbase & Hstart & Hlength & Hbound). lia.
Qed.

(** The numerical address is the actual helper result for a checked selected
    AREA/TERRAIN operand, followed by the bounded offset arithmetic used by
    generated readers. The explicitly supplied image is not selected from
    address equality, nor certified active by this theorem. *)
Theorem demo_selected_scene_scalar_load_transport :
 forall us descriptor is_geometry image native source ram ram_block bytes chunk offset,
 demo_scene_operand_view us descriptor is_geometry image native ->
 demo_scalar_scene_image_bytes source ram ram_block image bytes ->
 demo_scalar_memory_chunk chunk ->
 0 <= offset -> offset + size_chunk chunk <= scene_address_length image ->
 (align_chunk chunk | offset) ->
 (align_chunk chunk | scene_address_physical_base image + scene_address_start image + offset) ->
 let value := demo_scalar_decoded_value chunk
   (demo_scalar_byte_slice bytes offset (size_chunk chunk)) in
 Mem.load chunk source (scene_address_block image) offset = Some value /\
 demo_concrete_ram_load ram ram_block chunk
   (Int.add (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)
     (Int.repr offset)) = Some value.
Proof.
 intros us descriptor is_geometry image native source ram ram_block bytes chunk offset
   Hview Hbytes Hchunk Hoffset Hextent Halignsource Halignram.
 destruct Hview as (Hsource & Hnative & Hstart & Hbounds).
 destruct (demo_scalar_scene_load_transport source ram ram_block image bytes chunk offset
   Hbounds Hbytes Hchunk Hoffset Hextent Halignsource Halignram) as [Hsourceload Hramload].
 split; [exact Hsourceload |].
 destruct Hbounds as (Hbase & Hnonnegative & Hlength & Hbound).
 pose proof (size_chunk_pos chunk) as Hsize.
 rewrite demo_scene_numeric_virtual_address by lia. rewrite <- Hstart.
 assert (Hsum : Int.add
   (Int.repr (2147483648 + scene_address_physical_base image + scene_address_start image))
   (Int.repr offset) =
   Int.repr (2147483648 + scene_address_physical_base image + scene_address_start image + offset)).
 { unfold Int.add.
   rewrite Int.unsigned_repr by
     (change (0 <= 2147483648 + scene_address_physical_base image + scene_address_start image <= 4294967295); lia).
   rewrite Int.unsigned_repr by (change (0 <= offset <= 4294967295); lia).
   reflexivity. }
 rewrite Hsum. exact Hramload.
Qed.

(** A source pointer relocation is represented by Fragment values, rather
    than the native scalar bytes encoding its address. The scalar byte-image
    premise above deliberately cannot silently provide that missing bridge. *)
Theorem demo_pointer_encoding_is_not_pure_scalar_bytes : forall block offset bytes,
 encode_val Mint32 (Vptr block offset) <> map Memdata.Byte bytes.
Proof.
 intros block offset bytes Hencoding.
 assert (Hnone : proj_bytes (encode_val Mint32 (Vptr block offset)) = None).
 { change (proj_bytes (inj_value Q32 (Vptr block offset)) = None).
   apply proj_bytes_inj_value. }
 assert (Hsome : proj_bytes (map Memdata.Byte bytes) = Some bytes).
 { change (proj_bytes (inj_bytes bytes) = Some bytes). apply proj_inj_bytes. }
 rewrite Hencoding,Hsome in Hnone. discriminate.
Qed.

Definition demo_concrete_memory_transport_claim : Prop :=
 (forall source ram ram_block image bytes chunk offset,
   demo_scene_address_image_bounds image ->
   demo_scalar_scene_image_bytes source ram ram_block image bytes ->
   demo_scalar_memory_chunk chunk ->
   0 <= offset -> offset + size_chunk chunk <= scene_address_length image ->
   (align_chunk chunk | offset) ->
   (align_chunk chunk | scene_address_physical_base image + scene_address_start image + offset) ->
   let value := demo_scalar_decoded_value chunk
     (demo_scalar_byte_slice bytes offset (size_chunk chunk)) in
   Mem.load chunk source (scene_address_block image) offset = Some value /\
   demo_concrete_ram_load ram ram_block chunk
     (Int.repr (2147483648 + scene_address_physical_base image + scene_address_start image + offset)) = Some value) /\
 (forall block offset bytes, encode_val Mint32 (Vptr block offset) <> map Memdata.Byte bytes).

Theorem checked_demo_concrete_memory_transport : demo_concrete_memory_transport_claim.
Proof. split; [exact demo_scalar_scene_load_transport | exact demo_pointer_encoding_is_not_pure_scalar_bytes]. Qed.
