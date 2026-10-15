From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers Maps Memory Values.
From Demo.Generated Require Import us_geo_layout jp_geo_layout us_surface_load jp_surface_load.
From Demo.Proofs Require Import DemoSceneAddressBoundary DemoNativeAddressImages.
From Demo.Proofs Require Import DemoConcreteMemoryTransport.
From Demo.Proofs Require Import DemoConcreteExpression.
From Demo.Proofs Require Import DemoNativeAddressMachine.
Import ListNotations.
Local Open Scope Z_scope.
Module Fixture := DemoNativeAddressImages.
Module Native := DemoNativeAddressMachine.

(** These witnesses construct fresh LOCAL RAM with two stores. They do not
    derive a boot state, authentic asset activation, loader epoch, original
    Clight execution, native hardware trace or gameplay nonvacuity. Only the
    scalar value and instruction identities come from checked retail fixtures.
    All unmentioned newly allocated bytes remain uninitialized. *)
Definition demo_native_witness_ram_size : Z := 4194304.
Definition demo_native_witness_data_physical : Z := 4096.
Definition demo_native_witness_data_address : int := Int.repr (2147483648 + 4096).

Lemma demo_native_witness_two_stores : forall code_physical code chunk value,
 4100 <= code_physical -> code_physical + 4 <= demo_native_witness_ram_size ->
 (4 | code_physical) ->
 0 < size_chunk chunk <= 4 -> (align_chunk chunk | demo_native_witness_data_physical) ->
 Val.load_result chunk (Vint value) = Vint value ->
 exists allocated with_code ram ram_block,
 Mem.alloc Mem.empty 0 demo_native_witness_ram_size = (allocated, ram_block) /\
 Mem.store Mint32 allocated ram_block code_physical (Vint code) = Some with_code /\
 Mem.store chunk with_code ram_block demo_native_witness_data_physical (Vint value) = Some ram /\
 Mem.load Mint32 ram ram_block code_physical = Some (Vint code) /\
 Mem.load chunk ram ram_block demo_native_witness_data_physical = Some (Vint value).
Proof.
 intros code_physical code chunk value Haway Hcodebound Hcodealign Hsize Halign Hvalue.
 destruct (Mem.alloc Mem.empty 0 demo_native_witness_ram_size)
   as [allocated ram_block] eqn:Hallocate.
 assert (Hcodeaccess : Mem.valid_access allocated Mint32 ram_block code_physical Writable).
 { eapply Mem.valid_access_freeable_any. eapply Mem.valid_access_alloc_same;
     [exact Hallocate|lia|exact Hcodebound|exact Hcodealign]. }
 destruct (Mem.valid_access_store _ _ _ _ (Vint code) Hcodeaccess)
   as [with_code Hcodestore].
 assert (Hdataaccess : Mem.valid_access with_code chunk ram_block
    demo_native_witness_data_physical Writable).
 { eapply Mem.store_valid_access_1; [exact Hcodestore|].
   eapply Mem.valid_access_freeable_any. eapply Mem.valid_access_alloc_same;
     [exact Hallocate|unfold demo_native_witness_data_physical; lia|
      unfold demo_native_witness_data_physical, demo_native_witness_ram_size in *; lia|
      exact Halign]. }
 destruct (Mem.valid_access_store _ _ _ _ (Vint value) Hdataaccess)
   as [ram Hdatastore].
 exists allocated,with_code,ram,ram_block. repeat split; try assumption.
 - rewrite (Mem.load_store_other _ _ _ _ _ _ Hdatastore Mint32 ram_block code_physical).
   + exact (Mem.load_store_same _ _ _ _ _ _ Hcodestore).
   + right. right. unfold demo_native_witness_data_physical. lia.
 - rewrite (Mem.load_store_same _ _ _ _ _ _ Hdatastore),Hvalue. reflexivity.
Qed.

Definition demo_native_witness_context cenv temporary ram ram_block :=
 ConcreteExpressionContext cenv (PTree.empty int) (PTree.empty (int * type))
   (PTree.set temporary (Vint demo_native_witness_data_address) (PTree.empty val))
   ram ram_block.

Definition demo_native_witness_state pc base ram :=
 NativeLoadState (Int.repr pc) (Int.repr (pc + 4))
   (fun register => if register =? base
    then demo_native_word_gpr demo_native_witness_data_address else Int64.zero) ram.

Definition demo_native_witness_geometry_cenv (us : bool) :=
 if us then prog_comp_env us_geo_layout.prog else prog_comp_env jp_geo_layout.prog.
Definition demo_native_witness_terrain_cenv (us : bool) :=
 if us then prog_comp_env us_surface_load.prog else prog_comp_env jp_surface_load.prog.

Lemma demo_native_witness_words_match_fixtures :
 Native.demo_native_geometry_load_word = Int.repr Fixture.demo_native_geometry_load_word /\
 Native.demo_native_terrain_load_word = Int.repr Fixture.demo_native_terrain_load_word.
Proof. split; reflexivity. Qed.

Theorem demo_native_geometry_local_ram_witness : forall us,
 exists allocated with_code ram ram_block context state after,
 Mem.alloc Mem.empty 0 demo_native_witness_ram_size = (allocated, ram_block) /\
 Mem.store Mint32 allocated ram_block (Fixture.demo_native_geometry_load_pc - 2147483648)
   (Vint (Int.repr Fixture.demo_native_geometry_load_word)) = Some with_code /\
 Mem.store Mint8unsigned with_code ram_block demo_native_witness_data_physical
   (Vint (Int.repr 8)) = Some ram /\
 context = demo_native_witness_context (demo_native_witness_geometry_cenv us) SG._t'3 ram ram_block /\
 state = demo_native_witness_state Fixture.demo_native_geometry_load_pc 11 ram /\
 demo_concrete_ram_load ram ram_block Mint32 (native_load_pc state) =
   Some (Vint (Int.repr Fixture.demo_native_geometry_load_word)) /\
 demo_concrete_ram_load ram ram_block Mint8unsigned demo_native_witness_data_address =
   Some (Vint (Int.repr 8)) /\
 (match scene_geometry_opcode_statement (fn_body (scene_geometry_function us)) with
  | Sset _ operand => demo_concrete_eval_expr context operand | _ => None end) =
   Some (Vint (Int.repr 8)) /\
 demo_native_load_step ram_block state = Some after /\
 demo_native_get after 12 = demo_native_word_gpr (Int.repr 8) /\
 native_load_memory after = ram.
Proof.
 intros us.
 destruct (demo_native_witness_two_stores
   (Fixture.demo_native_geometry_load_pc - 2147483648)
   (Int.repr Fixture.demo_native_geometry_load_word) Mint8unsigned (Int.repr 8)
   ltac:(unfold Fixture.demo_native_geometry_load_pc; lia)
   ltac:(unfold Fixture.demo_native_geometry_load_pc,demo_native_witness_ram_size; lia)
   ltac:(unfold Fixture.demo_native_geometry_load_pc; exists 915540; reflexivity)
   ltac:(cbn; lia) ltac:(exists 4096; reflexivity) eq_refl)
   as (allocated & with_code & ram & ram_block & Halloc & Hcode & Hdata & Hfetch & Hread).
 set (context := demo_native_witness_context (demo_native_witness_geometry_cenv us) SG._t'3 ram ram_block).
 set (state := demo_native_witness_state Fixture.demo_native_geometry_load_pc 11 ram).
 assert (Hnativefetch : demo_concrete_ram_load ram ram_block Mint32 (native_load_pc state) =
     Some (Vint Native.demo_native_geometry_load_word)).
 { unfold state,demo_native_witness_state; cbn [native_load_pc].
   replace Fixture.demo_native_geometry_load_pc with
     (2147483648 + (Fixture.demo_native_geometry_load_pc - 2147483648)) by lia.
   rewrite demo_concrete_ram_load_cached by (unfold Fixture.demo_native_geometry_load_pc; lia).
   exact Hfetch. }
 assert (Hnativeread : demo_concrete_ram_load ram ram_block Mint8unsigned
    demo_native_witness_data_address = Some (Vint (Int.repr 8))).
 { unfold demo_native_witness_data_address.
   rewrite demo_concrete_ram_load_cached by lia. exact Hread. }
 assert (Htemp : (concrete_expression_temps context) ! SG._t'3 =
    Some (Vint demo_native_witness_data_address)).
 { unfold context,demo_native_witness_context. cbn. apply PTree.gss. }
 pose proof (demo_native_generated_geometry_read_correspondence context state ram_block
   demo_native_witness_data_address (Int.repr 8) eq_refl eq_refl Htemp Hnativefetch
   eq_refl Hnativeread) as (Hexpression & Hstep & Hword & Hmemory).
 exists allocated,with_code,ram,ram_block,context,state,
   (demo_native_load_write state 12 (Int.repr 8)).
 repeat split; try assumption; try reflexivity.
 - rewrite generated_scene_geometry_opcode_us_jp. exact Hexpression.
Qed.

Theorem demo_native_terrain_local_ram_witness : forall us,
 exists allocated with_code ram ram_block context state after,
 Mem.alloc Mem.empty 0 demo_native_witness_ram_size = (allocated, ram_block) /\
 Mem.store Mint32 allocated ram_block (Fixture.demo_native_terrain_load_pc - 2147483648)
   (Vint (Int.repr Fixture.demo_native_terrain_load_word)) = Some with_code /\
 Mem.store Mint16signed with_code ram_block demo_native_witness_data_physical
   (Vint (Int.repr 64)) = Some ram /\
 context = demo_native_witness_context (demo_native_witness_terrain_cenv us) ST._t'10 ram ram_block /\
 state = demo_native_witness_state Fixture.demo_native_terrain_load_pc 14 ram /\
 demo_concrete_ram_load ram ram_block Mint32 (native_load_pc state) =
   Some (Vint (Int.repr Fixture.demo_native_terrain_load_word)) /\
 demo_concrete_ram_load ram ram_block Mint16signed demo_native_witness_data_address =
   Some (Vint (Int.repr 64)) /\
 (match scene_terrain_type_statement (fn_body (scene_terrain_function us)) with
  | Sset _ operand => demo_concrete_eval_expr context operand | _ => None end) =
   Some (Vint (Int.repr 64)) /\
 demo_native_load_step ram_block state = Some after /\
 demo_native_get after 15 = demo_native_word_gpr (Int.repr 64) /\
 native_load_memory after = ram.
Proof.
 intros us.
 destruct (demo_native_witness_two_stores
   (Fixture.demo_native_terrain_load_pc - 2147483648)
   (Int.repr Fixture.demo_native_terrain_load_word) Mint16signed (Int.repr 64)
   ltac:(unfold Fixture.demo_native_terrain_load_pc; lia)
   ltac:(unfold Fixture.demo_native_terrain_load_pc,demo_native_witness_ram_size; lia)
   ltac:(unfold Fixture.demo_native_terrain_load_pc; exists 920831; reflexivity)
   ltac:(cbn; lia) ltac:(exists 2048; reflexivity) eq_refl)
   as (allocated & with_code & ram & ram_block & Halloc & Hcode & Hdata & Hfetch & Hread).
 set (context := demo_native_witness_context (demo_native_witness_terrain_cenv us) ST._t'10 ram ram_block).
 set (state := demo_native_witness_state Fixture.demo_native_terrain_load_pc 14 ram).
 assert (Hnativefetch : demo_concrete_ram_load ram ram_block Mint32 (native_load_pc state) =
     Some (Vint Native.demo_native_terrain_load_word)).
 { unfold state,demo_native_witness_state; cbn [native_load_pc].
   replace Fixture.demo_native_terrain_load_pc with
     (2147483648 + (Fixture.demo_native_terrain_load_pc - 2147483648)) by lia.
   rewrite demo_concrete_ram_load_cached by (unfold Fixture.demo_native_terrain_load_pc; lia).
   exact Hfetch. }
 assert (Hnativeread : demo_concrete_ram_load ram ram_block Mint16signed
    demo_native_witness_data_address = Some (Vint (Int.repr 64))).
 { unfold demo_native_witness_data_address.
   rewrite demo_concrete_ram_load_cached by lia. exact Hread. }
 assert (Htemp : (concrete_expression_temps context) ! ST._t'10 =
    Some (Vint demo_native_witness_data_address)).
 { unfold context,demo_native_witness_context. cbn. apply PTree.gss. }
 pose proof (demo_native_generated_terrain_read_correspondence context state ram_block
   demo_native_witness_data_address (Int.repr 64) eq_refl eq_refl Htemp Hnativefetch
   eq_refl Hnativeread) as (Hexpression & Hstep & Hword & Hmemory).
 exists allocated,with_code,ram,ram_block,context,state,
   (demo_native_load_write state 15 (Int.repr 64)).
 repeat split; try assumption; try reflexivity.
 - rewrite generated_scene_terrain_type_read_us_jp. exact Hexpression.
Qed.

(** Local premise inhabitation, including actual successful instruction and
    data reads, for both authentic selected instructions and both source
    versions. This claim does NOT assert normal-boot/gameplay reachability. *)
Definition demo_native_local_read_inhabitation_claim : Prop :=
 forall (us is_geometry : bool), exists ram_block context state after,
 concrete_expression_cenv context =
   (if is_geometry then demo_native_witness_geometry_cenv us
    else demo_native_witness_terrain_cenv us) /\
 concrete_expression_memory context = native_load_memory state /\
 concrete_expression_ram_block context = ram_block /\
 native_load_pc state = Int.repr
   (if is_geometry then Fixture.demo_native_geometry_load_pc
    else Fixture.demo_native_terrain_load_pc) /\
 demo_concrete_ram_load (native_load_memory state) ram_block Mint32
   (native_load_pc state) = Some (Vint (Int.repr
     (if is_geometry then Fixture.demo_native_geometry_load_word
      else Fixture.demo_native_terrain_load_word))) /\
 demo_concrete_ram_load (native_load_memory state) ram_block
   (if is_geometry then Mint8unsigned else Mint16signed)
   demo_native_witness_data_address =
   Some (Vint (Int.repr (if is_geometry then 8 else 64))) /\
 (match (if is_geometry
   then scene_geometry_opcode_statement (fn_body (scene_geometry_function us))
   else scene_terrain_type_statement (fn_body (scene_terrain_function us))) with
  | Sset _ operand => demo_concrete_eval_expr context operand | _ => None end) =
   Some (Vint (Int.repr (if is_geometry then 8 else 64))) /\
 demo_native_load_step ram_block state = Some after /\
 demo_native_get after (if is_geometry then 12 else 15) =
   demo_native_word_gpr (Int.repr (if is_geometry then 8 else 64)) /\
 native_load_memory after = native_load_memory state.

Theorem checked_demo_native_local_read_inhabitation :
 demo_native_local_read_inhabitation_claim.
Proof.
 unfold demo_native_local_read_inhabitation_claim. intros us [].
 - destruct (demo_native_geometry_local_ram_witness us) as
   (allocated & with_code & ram & ram_block & context & state & after &
    Halloc & Hcode & Hdata & Hcontext & Hstate & Hfetch & Hread & Hexpression & Hstep & Hget & Hmemory).
   exists ram_block,context,state,after. subst context state.
   repeat split; try assumption; reflexivity.
 - destruct (demo_native_terrain_local_ram_witness us) as
   (allocated & with_code & ram & ram_block & context & state & after &
    Halloc & Hcode & Hdata & Hcontext & Hstate & Hfetch & Hread & Hexpression & Hstep & Hget & Hmemory).
   exists ram_block,context,state,after. subst context state.
   repeat split; try assumption; reflexivity.
Qed.
