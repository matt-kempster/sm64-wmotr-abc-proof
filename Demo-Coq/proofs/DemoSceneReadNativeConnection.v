From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Integers Maps Memdata Memory Values.
From Demo.Proofs Require Import DemoSceneAddressView DemoSceneAddressBoundary
 DemoSceneSourceInventory DemoNumericAddressExecution DemoNativeAddressImages.
From Demo.Proofs Require Import DemoConcreteMemoryTransport.
From Demo.Proofs Require Import DemoConcreteScalarRange.
From Demo.Proofs Require Import DemoConcreteExpression.
From Demo.Proofs Require Import DemoNativeAddressMachine.
Import ListNotations.
Local Open Scope Z_scope.
Module F := DemoNativeAddressImages.
Module N := DemoNativeAddressMachine.

(** This connection concerns one selected generated scalar read and one native
    LOAD projection. Actual source/RAM bytes are compared only at that read.
    The supplied scene image and instruction-fetch premises do not establish
    runtime image activation, ownership, a reachable constructor state, or
    ordinary-Clight/native refinement. Pending next-PC is explicitly supplied;
    this theorem handles the sequential fixture occurrence, not control flow. *)

Definition demo_selected_geometry_read_expression (us : bool) : option expr :=
 match scene_geometry_opcode_statement (fn_body (scene_geometry_function us)) with
 | Sset _ expression => Some expression | _ => None
 end.
Definition demo_selected_terrain_read_expression (us : bool) : option expr :=
 match scene_terrain_type_statement (fn_body (scene_terrain_function us)) with
 | Sset _ expression => Some expression | _ => None
 end.

Lemma demo_selected_geometry_read_is_actual_us_jp : forall us,
 demo_selected_geometry_read_expression us = Some scene_geometry_opcode_expression.
Proof. intros us. unfold demo_selected_geometry_read_expression.
 rewrite generated_scene_geometry_opcode_us_jp. reflexivity. Qed.
Lemma demo_selected_terrain_read_is_actual_us_jp : forall us,
 demo_selected_terrain_read_expression us = Some scene_terrain_type_expression.
Proof. intros us. unfold demo_selected_terrain_read_expression.
 rewrite generated_scene_terrain_type_read_us_jp. reflexivity. Qed.

(** The code fetch reads the same RAM used for the scalar data. The fixture
    authenticates the stated PC/word externally; memory presence remains an
    explicit premise here, rather than being inferred from a scalar constant. *)
Definition demo_scene_geometry_scalar_native_connection_claim : Prop :=
 forall us descriptor image native source context state ram_block bytes,
 demo_scene_operand_view us descriptor true image native ->
 1 <= scene_address_length image ->
 demo_matching_scalar_read_range source (N.native_load_memory state) ram_block
   (scene_address_block image) 0
   (scene_address_physical_base image + scene_address_start image) Mint8unsigned bytes ->
 concrete_expression_memory context = N.native_load_memory state ->
 concrete_expression_ram_block context = ram_block ->
 (concrete_expression_temps context) ! SG._t'3 =
   Some (Vint (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)) ->
 N.native_load_pc state = Int.repr F.demo_native_geometry_load_pc ->
 N.native_load_next_pc state = Int.repr (F.demo_native_geometry_load_pc + 4) ->
 demo_concrete_ram_load (N.native_load_memory state) ram_block Mint32
   (Int.repr F.demo_native_geometry_load_pc) =
   Some (Vint (Int.repr F.demo_native_geometry_load_word)) ->
 N.demo_native_get state F.demo_native_geometry_load_base_gpr =
   N.demo_native_word_gpr
     (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native) ->
 exists expression value,
 demo_selected_geometry_read_expression us = Some expression /\
 Mem.load Mint8unsigned source (scene_address_block image) 0 = Some (Vint value) /\
 demo_concrete_eval_expr context expression = Some (Vint value) /\
 N.demo_native_load_step ram_block state =
   Some (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr value) /\
 Int64.loword (N.demo_native_get
   (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr value)
   F.demo_native_geometry_load_destination_gpr) = value /\
 N.native_load_pc (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr value) =
   Int.repr (F.demo_native_geometry_load_pc + 4) /\
 N.native_load_memory (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr value) =
   N.native_load_memory state.
Theorem demo_scene_geometry_scalar_native_connection_us_jp :
 demo_scene_geometry_scalar_native_connection_claim.
Proof.
 unfold demo_scene_geometry_scalar_native_connection_claim.
 intros us descriptor image native source context state ram_block bytes
   Hview Hextent Hbytes Hmemory Hram Htemp Hpc Hnext Hfetch Hbase.
 destruct (demo_selected_scene_scalar_range_load us descriptor true image native source
   (N.native_load_memory state) ram_block Mint8unsigned bytes Hview)
   as [Hsourceload Hload].
 - unfold demo_scalar_memory_chunk. cbn. tauto.
 - exact Hextent.
 - cbn [align_chunk]. apply Z.divide_1_l.
 - exact Hbytes.
 - cbn [demo_scalar_decoded_value] in Hsourceload,Hload.
   rewrite <- Hpc in Hfetch.
   destruct (N.demo_native_generated_geometry_read_correspondence context state ram_block
     (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)
     (Int.zero_ext 8 (Int.repr (decode_int bytes)))
     Hmemory Hram Htemp Hfetch Hbase Hload) as (Hexpression & Hstep & Hvalue & Hframe).
   exists scene_geometry_opcode_expression, (Int.zero_ext 8 (Int.repr (decode_int bytes))).
   split; [apply demo_selected_geometry_read_is_actual_us_jp |].
   split; [exact Hsourceload |]. split; [exact Hexpression |].
   split; [exact Hstep |]. split; [exact Hvalue |].
   split; [exact Hnext | exact Hframe].
Qed.

Definition demo_scene_terrain_scalar_native_connection_claim : Prop :=
 forall us descriptor image native source context state ram_block bytes,
 demo_scene_operand_view us descriptor false image native ->
 2 <= scene_address_length image ->
 (2 | scene_address_physical_base image + scene_address_start image) ->
 demo_matching_scalar_read_range source (N.native_load_memory state) ram_block
   (scene_address_block image) 0
   (scene_address_physical_base image + scene_address_start image) Mint16signed bytes ->
 concrete_expression_memory context = N.native_load_memory state ->
 concrete_expression_ram_block context = ram_block ->
 (concrete_expression_temps context) ! ST._t'10 =
   Some (Vint (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)) ->
 N.native_load_pc state = Int.repr F.demo_native_terrain_load_pc ->
 N.native_load_next_pc state = Int.repr (F.demo_native_terrain_load_pc + 4) ->
 demo_concrete_ram_load (N.native_load_memory state) ram_block Mint32
   (Int.repr F.demo_native_terrain_load_pc) =
   Some (Vint (Int.repr F.demo_native_terrain_load_word)) ->
 N.demo_native_get state F.demo_native_terrain_load_base_gpr =
   N.demo_native_word_gpr
     (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native) ->
 exists expression value,
 demo_selected_terrain_read_expression us = Some expression /\
 Mem.load Mint16signed source (scene_address_block image) 0 = Some (Vint value) /\
 demo_concrete_eval_expr context expression = Some (Vint value) /\
 N.demo_native_load_step ram_block state =
   Some (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr value) /\
 Int64.loword (N.demo_native_get
   (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr value)
   F.demo_native_terrain_load_destination_gpr) = value /\
 N.native_load_pc (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr value) =
   Int.repr (F.demo_native_terrain_load_pc + 4) /\
 N.native_load_memory (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr value) =
   N.native_load_memory state.
Theorem demo_scene_terrain_scalar_native_connection_us_jp :
 demo_scene_terrain_scalar_native_connection_claim.
Proof.
 unfold demo_scene_terrain_scalar_native_connection_claim.
 intros us descriptor image native source context state ram_block bytes
   Hview Hextent Halign Hbytes Hmemory Hram Htemp Hpc Hnext Hfetch Hbase.
 destruct (demo_selected_scene_scalar_range_load us descriptor false image native source
   (N.native_load_memory state) ram_block Mint16signed bytes Hview)
   as [Hsourceload Hload].
 - unfold demo_scalar_memory_chunk. cbn. tauto.
 - exact Hextent.
 - exact Halign.
 - exact Hbytes.
 - cbn [demo_scalar_decoded_value] in Hsourceload,Hload.
   rewrite <- Hpc in Hfetch.
   destruct (N.demo_native_generated_terrain_read_correspondence context state ram_block
     (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)
     (Int.sign_ext 16 (Int.repr (decode_int bytes)))
     Hmemory Hram Htemp Hfetch Hbase Hload) as (Hexpression & Hstep & Hvalue & Hframe).
   exists scene_terrain_type_expression, (Int.sign_ext 16 (Int.repr (decode_int bytes))).
   split; [apply demo_selected_terrain_read_is_actual_us_jp |].
   split; [exact Hsourceload |]. split; [exact Hexpression |].
   split; [exact Hstep |]. split; [exact Hvalue |].
   split; [exact Hnext | exact Hframe].
Qed.

(** Finite agreement of the nine checked source descriptors with the native
    fixture's numeric operands. This is independent of actual RAM loading,
    first-byte values, runtime placement, and constructor execution. *)
Definition demo_source_descriptor_native_fixture_agreement us descriptor : Prop :=
 exists row,
 F.demo_native_scene_first_values_for us (scene_source_owner descriptor)
   (scene_source_index descriptor) = Some row /\
 scene_source_native_operand us descriptor true = Some (Int.repr (F.demo_native_scene_geo_operand row)) /\
 scene_source_native_operand us descriptor false = Some (Int.repr (F.demo_native_scene_terrain_operand row)) /\
 F.demo_native_scene_geo_first_byte row = 8 /\
 F.demo_native_scene_terrain_first_halfword row = 64.

Theorem demo_expected_source_descriptors_match_native_fixture_us_jp : forall us,
 Forall (demo_source_descriptor_native_fixture_agreement us) scene_expected_source_areas.
Proof.
 intros []; unfold scene_expected_source_areas;
 repeat (apply Forall_cons; [unfold demo_source_descriptor_native_fixture_agreement;
   eexists; split; [reflexivity |]; repeat split; reflexivity |]); apply Forall_nil.
Qed.

(** The known first scalar values are connected only under actual selected
    source/RAM byte-read premises for those prefixes. Their fixture constants
    alone never establish memory contents or runtime placement. *)
Definition demo_scene_geometry_fixture_prefix_connection_claim : Prop :=
 forall us descriptor image native source context state ram_block,
 In descriptor scene_expected_source_areas ->
 demo_scene_operand_view us descriptor true image native ->
 1 <= scene_address_length image ->
 demo_matching_scalar_read_range source (N.native_load_memory state) ram_block
   (scene_address_block image) 0
   (scene_address_physical_base image + scene_address_start image) Mint8unsigned [Byte.repr 8] ->
 concrete_expression_memory context = N.native_load_memory state ->
 concrete_expression_ram_block context = ram_block ->
 (concrete_expression_temps context) ! SG._t'3 =
   Some (Vint (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)) ->
 N.native_load_pc state = Int.repr F.demo_native_geometry_load_pc ->
 N.native_load_next_pc state = Int.repr (F.demo_native_geometry_load_pc + 4) ->
 demo_concrete_ram_load (N.native_load_memory state) ram_block Mint32
   (Int.repr F.demo_native_geometry_load_pc) =
   Some (Vint (Int.repr F.demo_native_geometry_load_word)) ->
 N.demo_native_get state F.demo_native_geometry_load_base_gpr =
   N.demo_native_word_gpr
     (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native) ->
 exists expression,
 demo_source_descriptor_native_fixture_agreement us descriptor /\
 demo_selected_geometry_read_expression us = Some expression /\
 Mem.load Mint8unsigned source (scene_address_block image) 0 = Some (Vint (Int.repr 8)) /\
 demo_concrete_eval_expr context expression = Some (Vint (Int.repr 8)) /\
 N.demo_native_load_step ram_block state =
   Some (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr (Int.repr 8)) /\
 Int64.loword (N.demo_native_get
   (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr (Int.repr 8))
   F.demo_native_geometry_load_destination_gpr) = (Int.repr 8) /\
 N.native_load_pc (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr (Int.repr 8)) =
   Int.repr (F.demo_native_geometry_load_pc + 4) /\
 N.native_load_memory (N.demo_native_load_write state F.demo_native_geometry_load_destination_gpr (Int.repr 8)) =
   N.native_load_memory state.
Theorem demo_scene_geometry_fixture_prefix_connection_us_jp :
 demo_scene_geometry_fixture_prefix_connection_claim.
Proof.
 unfold demo_scene_geometry_fixture_prefix_connection_claim.
 intros us descriptor image native source context state ram_block Hin
   Hview Hextent Hbytes Hmemory Hram Htemp Hpc Hnext Hfetch Hbase.
 destruct (demo_scene_geometry_scalar_native_connection_us_jp us descriptor image native source
   context state ram_block [Byte.repr 8] Hview Hextent Hbytes Hmemory Hram Htemp Hpc Hnext Hfetch Hbase)
   as (expression & value & Hselected & Hload & Hexpression & Hstep & Hvalue & Hresultpc & Hframe).
 destruct Hbytes as [Hsourcebytes Hrambytes].
 pose proof (Mem.loadbytes_load Mint8unsigned source (scene_address_block image) 0 _
   Hsourcebytes ltac:(exists 0; lia)) as Hexpected.
 change (Mem.load Mint8unsigned source (scene_address_block image) 0 = Some (Vint (Int.repr 8)))
   in Hexpected.
 rewrite Hload in Hexpected. injection Hexpected as Hvalueexact. subst value.
 pose proof (demo_expected_source_descriptors_match_native_fixture_us_jp us) as Hfixtures.
 rewrite Forall_forall in Hfixtures.
 exists expression. split; [exact (Hfixtures descriptor Hin) |].
 repeat split; assumption.
Qed.

Definition demo_scene_terrain_fixture_prefix_connection_claim : Prop :=
 forall us descriptor image native source context state ram_block,
 In descriptor scene_expected_source_areas ->
 demo_scene_operand_view us descriptor false image native ->
 2 <= scene_address_length image ->
 (2 | scene_address_physical_base image + scene_address_start image) ->
 demo_matching_scalar_read_range source (N.native_load_memory state) ram_block
   (scene_address_block image) 0
   (scene_address_physical_base image + scene_address_start image) Mint16signed [Byte.repr 0;Byte.repr 64] ->
 concrete_expression_memory context = N.native_load_memory state ->
 concrete_expression_ram_block context = ram_block ->
 (concrete_expression_temps context) ! ST._t'10 =
   Some (Vint (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native)) ->
 N.native_load_pc state = Int.repr F.demo_native_terrain_load_pc ->
 N.native_load_next_pc state = Int.repr (F.demo_native_terrain_load_pc + 4) ->
 demo_concrete_ram_load (N.native_load_memory state) ram_block Mint32
   (Int.repr F.demo_native_terrain_load_pc) =
   Some (Vint (Int.repr F.demo_native_terrain_load_word)) ->
 N.demo_native_get state F.demo_native_terrain_load_base_gpr =
   N.demo_native_word_gpr
     (demo_n64_virtual_address (Int.repr (scene_address_physical_base image)) native) ->
 exists expression,
 demo_source_descriptor_native_fixture_agreement us descriptor /\
 demo_selected_terrain_read_expression us = Some expression /\
 Mem.load Mint16signed source (scene_address_block image) 0 = Some (Vint (Int.repr 64)) /\
 demo_concrete_eval_expr context expression = Some (Vint (Int.repr 64)) /\
 N.demo_native_load_step ram_block state =
   Some (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr (Int.repr 64)) /\
 Int64.loword (N.demo_native_get
   (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr (Int.repr 64))
   F.demo_native_terrain_load_destination_gpr) = (Int.repr 64) /\
 N.native_load_pc (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr (Int.repr 64)) =
   Int.repr (F.demo_native_terrain_load_pc + 4) /\
 N.native_load_memory (N.demo_native_load_write state F.demo_native_terrain_load_destination_gpr (Int.repr 64)) =
   N.native_load_memory state.
Theorem demo_scene_terrain_fixture_prefix_connection_us_jp :
 demo_scene_terrain_fixture_prefix_connection_claim.
Proof.
 unfold demo_scene_terrain_fixture_prefix_connection_claim.
 intros us descriptor image native source context state ram_block Hin
   Hview Hextent Halign Hbytes Hmemory Hram Htemp Hpc Hnext Hfetch Hbase.
 destruct (demo_scene_terrain_scalar_native_connection_us_jp us descriptor image native source
   context state ram_block [Byte.repr 0;Byte.repr 64] Hview Hextent Halign Hbytes Hmemory Hram Htemp
   Hpc Hnext Hfetch Hbase)
   as (expression & value & Hselected & Hload & Hexpression & Hstep & Hvalue & Hresultpc & Hframe).
 destruct Hbytes as [Hsourcebytes Hrambytes].
 pose proof (Mem.loadbytes_load Mint16signed source (scene_address_block image) 0 _
   Hsourcebytes ltac:(exists 0; lia)) as Hexpected.
 change (Mem.load Mint16signed source (scene_address_block image) 0 = Some (Vint (Int.repr 64)))
   in Hexpected.
 rewrite Hload in Hexpected. injection Hexpected as Hvalueexact. subst value.
 pose proof (demo_expected_source_descriptors_match_native_fixture_us_jp us) as Hfixtures.
 rewrite Forall_forall in Hfixtures.
 exists expression. split; [exact (Hfixtures descriptor Hin) |].
 repeat split; assumption.
Qed.

Definition demo_scene_read_native_connection_claim : Prop :=
 demo_scene_geometry_fixture_prefix_connection_claim /\
 demo_scene_terrain_fixture_prefix_connection_claim /\
 demo_scene_geometry_scalar_native_connection_claim /\
 demo_scene_terrain_scalar_native_connection_claim /\
 (forall us, demo_selected_geometry_read_expression us = Some scene_geometry_opcode_expression) /\
 (forall us, demo_selected_terrain_read_expression us = Some scene_terrain_type_expression) /\
 (forall us, Forall (demo_source_descriptor_native_fixture_agreement us) scene_expected_source_areas).

Theorem checked_demo_scene_read_native_connection : demo_scene_read_native_connection_claim.
Proof.
 split; [exact demo_scene_geometry_fixture_prefix_connection_us_jp |].
 split; [exact demo_scene_terrain_fixture_prefix_connection_us_jp |].
 split; [exact demo_scene_geometry_scalar_native_connection_us_jp |].
 split; [exact demo_scene_terrain_scalar_native_connection_us_jp |].
 split; [exact demo_selected_geometry_read_is_actual_us_jp |].
 split; [exact demo_selected_terrain_read_is_actual_us_jp |].
 exact demo_expected_source_descriptors_match_native_fixture_us_jp.
Qed.
