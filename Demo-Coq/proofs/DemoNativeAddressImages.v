(** Mechanically generated native-address scalar fixtures.
    Full US/JP retail routine/asset authentication happens externally.
    This file asserts no native execution, runtime activation, or
    Clight/native refinement. Do not edit the finite transcription. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST.
Import ListNotations.
Local Open Scope Z_scope.

Definition demo_native_geometry_load_pc : Z := 2151145808.
Definition demo_native_geometry_load_word : Z := 2439774208.
Definition demo_native_geometry_load_base_gpr : Z := 11.
Definition demo_native_geometry_load_destination_gpr : Z := 12.
Definition demo_native_geometry_load_displacement : Z := 0.
Definition demo_native_geometry_load_chunk : memory_chunk := Mint8unsigned.

Definition demo_native_terrain_load_pc : Z := 2151166972.
Definition demo_native_terrain_load_word : Z := 2244935680.
Definition demo_native_terrain_load_base_gpr : Z := 14.
Definition demo_native_terrain_load_destination_gpr : Z := 15.
Definition demo_native_terrain_load_displacement : Z := 0.
Definition demo_native_terrain_load_chunk : memory_chunk := Mint16signed.

Record demo_native_scene_first_values : Type := DemoNativeSceneFirstValues {
 demo_native_scene_owner : Z;
 demo_native_scene_index : Z;
 demo_native_scene_geo_operand : Z;
 demo_native_scene_geo_first_byte : Z;
 demo_native_scene_terrain_operand : Z;
 demo_native_scene_terrain_first_halfword : Z
}.

Definition demo_native_scene_first_values_us : list demo_native_scene_first_values :=
 [DemoNativeSceneFirstValues 4 1 234884864 8 117573536 64;
  DemoNativeSceneFirstValues 5 1 234882348 8 117520616 64;
  DemoNativeSceneFirstValues 5 2 234882552 8 117573760 64;
  DemoNativeSceneFirstValues 7 1 234883984 8 117593492 64;
  DemoNativeSceneFirstValues 12 1 234883608 8 117485656 64;
  DemoNativeSceneFirstValues 12 2 234883836 8 117507512 64;
  DemoNativeSceneFirstValues 24 1 234884088 8 117506776 64;
  DemoNativeSceneFirstValues 27 1 234881280 8 117499024 64;
  DemoNativeSceneFirstValues 30 1 234881232 8 117450808 64].

Definition demo_native_scene_first_values_jp : list demo_native_scene_first_values :=
 [DemoNativeSceneFirstValues 4 1 234884864 8 117573536 64;
  DemoNativeSceneFirstValues 5 1 234882332 8 117520616 64;
  DemoNativeSceneFirstValues 5 2 234882536 8 117573760 64;
  DemoNativeSceneFirstValues 7 1 234883984 8 117593492 64;
  DemoNativeSceneFirstValues 12 1 234883608 8 117485656 64;
  DemoNativeSceneFirstValues 12 2 234883836 8 117507512 64;
  DemoNativeSceneFirstValues 24 1 234884088 8 117506776 64;
  DemoNativeSceneFirstValues 27 1 234881280 8 117499024 64;
  DemoNativeSceneFirstValues 30 1 234881232 8 117450808 64].

Definition demo_native_scene_first_values_version (us : bool) : list demo_native_scene_first_values :=
 if us then demo_native_scene_first_values_us else demo_native_scene_first_values_jp.
Fixpoint demo_native_scene_first_values_lookup (owner index : Z)
 (rows : list demo_native_scene_first_values) : option demo_native_scene_first_values :=
 match rows with
 | [] => None
 | row :: rest =>
   if (demo_native_scene_owner row =? owner) && (demo_native_scene_index row =? index)
   then Some row else demo_native_scene_first_values_lookup owner index rest
 end.
Definition demo_native_scene_first_values_for (us : bool) (owner index : Z)
 : option demo_native_scene_first_values :=
 demo_native_scene_first_values_lookup owner index (demo_native_scene_first_values_version us).

Definition demo_native_load_encoding (word opcode base target displacement : Z) : bool :=
 (Z.shiftr word 26 =? opcode) && (Z.land (Z.shiftr word 21) 31 =? base) &&
 (Z.land (Z.shiftr word 16) 31 =? target) && (Z.land word 65535 =? displacement).

Definition demo_native_first_scalar_fixture_claim : Prop :=
 demo_native_geometry_load_chunk = Mint8unsigned /\
 demo_native_terrain_load_chunk = Mint16signed /\
 demo_native_load_encoding demo_native_geometry_load_word 36
   demo_native_geometry_load_base_gpr demo_native_geometry_load_destination_gpr
   demo_native_geometry_load_displacement = true /\
 demo_native_load_encoding demo_native_terrain_load_word 33
   demo_native_terrain_load_base_gpr demo_native_terrain_load_destination_gpr
   demo_native_terrain_load_displacement = true /\
 (forall us, length (demo_native_scene_first_values_version us) = 9%nat) /\
 (forall us, Forall (fun row => demo_native_scene_geo_first_byte row = 8 /\
   demo_native_scene_terrain_first_halfword row = 64)
   (demo_native_scene_first_values_version us)).
Theorem generated_demo_native_first_scalar_fixture_checked : demo_native_first_scalar_fixture_claim.
Proof. split; [reflexivity|]. split; [reflexivity|].
 split; [reflexivity|]. split; [reflexivity|].
 split; intros []; vm_compute; repeat constructor. Qed.
