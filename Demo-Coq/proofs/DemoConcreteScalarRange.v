From Coq Require Import Lia List ZArith.
From compcert Require Import AST Coqlib Integers Memdata Memory Values.
From Demo.Proofs Require Import DemoSceneAddressView DemoNumericAddressExecution.
From Demo.Proofs Require Import DemoConcreteMemoryTransport.
Import ListNotations.
Local Open Scope Z_scope.

(** A correspondence for only one selected scalar load. Other bytes in the
    surrounding source initializer may include symbolic pointer fragments.
    This predicate reads real memory and supplies no decoder/load oracle. *)
Definition demo_matching_scalar_read_range (source ram : mem) (ram_block source_block : block)
    (source_offset physical : Z) (chunk : memory_chunk) (bytes : list Integers.Byte.int) : Prop :=
 Mem.loadbytes source source_block source_offset (size_chunk chunk) =
   Some (map Memdata.Byte bytes) /\
 Mem.loadbytes ram ram_block physical (size_chunk chunk) = Some (map Memdata.Byte bytes).

(** Extents are explicit numerical bounds, not a claim about image ownership.
    The loadbytes premises establish actual readability of the selected range.
    Cached addressing cannot wrap under the physical bounds below. *)
Theorem demo_scalar_range_load_transport :
 forall source ram ram_block source_block source_offset source_extent physical ram_extent chunk bytes,
 demo_scalar_memory_chunk chunk ->
 0 <= source_offset -> source_offset + size_chunk chunk <= source_extent ->
 0 <= physical -> physical + size_chunk chunk <= ram_extent -> ram_extent <= 536870912 ->
 (align_chunk chunk | source_offset) -> (align_chunk chunk | physical) ->
 demo_matching_scalar_read_range source ram ram_block source_block source_offset physical chunk bytes ->
 Mem.load chunk source source_block source_offset = Some (demo_scalar_decoded_value chunk bytes) /\
 demo_concrete_ram_load ram ram_block chunk (Int.repr (2147483648 + physical)) =
   Some (demo_scalar_decoded_value chunk bytes).
Proof.
 intros source ram ram_block source_block source_offset source_extent physical ram_extent chunk bytes
   Hchunk Hsourceoffset Hsourceextent Hphysical Hramextent Hramlimit Halignsource Halignram
   [Hsourcebytes Hrambytes].
 pose proof (Mem.loadbytes_load chunk _ _ _ _ Hsourcebytes Halignsource) as Hsource.
 pose proof (Mem.loadbytes_load chunk _ _ _ _ Hrambytes Halignram) as Hram.
 rewrite (demo_pure_scalar_decode _ _ Hchunk) in Hsource,Hram.
 split; [exact Hsource |]. rewrite demo_concrete_ram_load_cached; [exact Hram |].
 pose proof (size_chunk_pos chunk). lia.
Qed.

(** The descriptor/native operand is already checked by the selected source
    inventory. No complete geometry or script image is required to be pure
    bytes: only the first selected opcode/type range is compared here.
    The supplied image still does not establish runtime activation or epoch. *)
Theorem demo_selected_scene_scalar_range_load :
 forall us descriptor is_geometry image native source ram ram_block chunk bytes,
 demo_scene_operand_view us descriptor is_geometry image native ->
 demo_scalar_memory_chunk chunk -> size_chunk chunk <= scene_address_length image ->
 (align_chunk chunk | scene_address_physical_base image + scene_address_start image) ->
 demo_matching_scalar_read_range source ram ram_block (scene_address_block image) 0
   (scene_address_physical_base image + scene_address_start image) chunk bytes ->
 Mem.load chunk source (scene_address_block image) 0 = Some (demo_scalar_decoded_value chunk bytes) /\
 demo_concrete_ram_load ram ram_block chunk
   (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native) =
   Some (demo_scalar_decoded_value chunk bytes).
Proof.
 intros us descriptor is_geometry image native source ram ram_block chunk bytes
   Hview Hchunk Hextent Halign Hbytes.
 destruct Hview as (Hsource & Hnative & Hstart & Hbounds).
 destruct Hbounds as (Hbase & Hnonnegative & Hlength & Hbound).
 destruct (demo_scalar_range_load_transport source ram ram_block (scene_address_block image) 0
   (scene_address_length image)
   (scene_address_physical_base image + scene_address_start image) 536870912 chunk bytes)
   as [Hsourceload Hramload].
 - exact Hchunk.
 - lia.
 - lia.
 - lia.
 - lia.
 - lia.
 - exists 0. lia.
 - exact Halign.
 - exact Hbytes.
 - split; [exact Hsourceload |].
   rewrite demo_scene_numeric_virtual_address by lia. rewrite <- Hstart.
   replace (2147483648 + scene_address_physical_base image + scene_address_start image)
     with (2147483648 + (scene_address_physical_base image + scene_address_start image)) by lia.
   exact Hramload.
Qed.

Definition demo_concrete_scalar_range_claim : Prop :=
 forall us descriptor is_geometry image native source ram ram_block chunk bytes,
 demo_scene_operand_view us descriptor is_geometry image native ->
 demo_scalar_memory_chunk chunk -> size_chunk chunk <= scene_address_length image ->
 (align_chunk chunk | scene_address_physical_base image + scene_address_start image) ->
 demo_matching_scalar_read_range source ram ram_block (scene_address_block image) 0
   (scene_address_physical_base image + scene_address_start image) chunk bytes ->
 Mem.load chunk source (scene_address_block image) 0 = Some (demo_scalar_decoded_value chunk bytes) /\
 demo_concrete_ram_load ram ram_block chunk
   (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native) =
   Some (demo_scalar_decoded_value chunk bytes).

Theorem checked_demo_concrete_scalar_range : demo_concrete_scalar_range_claim.
Proof. exact demo_selected_scene_scalar_range_load. Qed.
