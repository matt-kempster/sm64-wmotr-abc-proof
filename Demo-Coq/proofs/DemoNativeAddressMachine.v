From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers Maps Memory Values.
From Demo.Proofs Require Import DemoConcreteMemoryTransport.
From Demo.Proofs Require Import DemoConcreteExpression.
From Demo.Proofs Require Import DemoSceneAddressBoundary.
Import ListNotations.
Local Open Scope Z_scope.

(** A small native LOAD-instruction projection, not a whole VR4300 semantics
    or a Clight.step rule. GPRs are 64 bits, word results are sign-extended,
    effective addresses add a sign-extended immediate in 64 bits, register zero
    is hardwired, and instruction/data fetches use the SAME actual Mem RAM.
    The scope is big-endian 32-bit kernel cached RAM with coherent caches and
    no intervening exception/interrupt/DMA event. Establishing these conditions,
    code/image loading, initial registers, and hardware refinement is separate.
    Unsupported instructions or noncanonical/non-KSEG0 addresses return None.
    NEC VR4300 manual U10504EJ7V0UMJ1, pp134,137,440,450,458: load operations,
    and KSEG0 translation, not a new game-specific transition system. *)

Definition demo_native_word_gpr (word : int) : int64 :=
 Int64.ofwords (if Int.lt word Int.zero then Int.mone else Int.zero) word.

Lemma demo_native_word_gpr_low : forall word,
 Int64.loword (demo_native_word_gpr word) = word.
Proof. intros. unfold demo_native_word_gpr. apply Int64.lo_ofwords. Qed.

Record demo_native_load_instruction := NativeLoadInstruction {
 native_load_chunk : memory_chunk;
 native_load_base : Z;
 native_load_target : Z;
 native_load_immediate : int
}.

Definition demo_native_decode_load (word : int) : option demo_native_load_instruction :=
 let bits := Int.unsigned word in
 let opcode := Z.shiftr bits 26 in
 let chunk := if opcode =? 36 then Some Mint8unsigned
              else if opcode =? 33 then Some Mint16signed
              else if opcode =? 35 then Some Mint32 else None in
 match chunk with
 | Some chunk => Some (NativeLoadInstruction chunk
     (Z.land (Z.shiftr bits 21) 31) (Z.land (Z.shiftr bits 16) 31)
     (Int.sign_ext 16 (Int.repr (Z.land bits 65535))))
 | None => None
 end.

Record demo_native_load_state := NativeLoadState {
 native_load_pc : int;
 native_load_next_pc : int;
 native_load_registers : Z -> int64;
 native_load_memory : mem
}.

Definition demo_native_get state register : int64 :=
 if register =? 0 then Int64.zero else native_load_registers state register.

Definition demo_native_effective_address instruction state : int64 :=
 Int64.add (demo_native_get state (native_load_base instruction))
   (demo_native_word_gpr (native_load_immediate instruction)).

Definition demo_native_ram_load64 memory ram_block chunk address : option val :=
 let low := Int64.loword address in
 if Int64.eq address (demo_native_word_gpr low)
 then demo_concrete_ram_load memory ram_block chunk low else None.

Definition demo_native_load_write state target value : demo_native_load_state :=
 NativeLoadState (native_load_next_pc state)
   (Int.add (native_load_next_pc state) (Int.repr 4))
   (fun register => if (register =? target) && negb (register =? 0)
     then demo_native_word_gpr value else native_load_registers state register)
   (native_load_memory state).

(** A deliberately restricted successful-address domain: a canonical word
    base and no signed32 overflow in base+offset. This is not a claim to cover
    every hardware addressing mode. Both selected authentic reads use offset0. *)
Definition demo_native_load_address_domain instruction state : bool :=
 let base := demo_native_get state (native_load_base instruction) in
 let low := Int64.loword base in
 let sum := Int.signed low + Int.signed (native_load_immediate instruction) in
 Int64.eq base (demo_native_word_gpr low) &&
 (Int.min_signed <=? sum) && (sum <=? Int.max_signed).

Definition demo_native_execute_load ram_block instruction state
    : option demo_native_load_state :=
 if demo_native_load_address_domain instruction state then
 match demo_native_ram_load64 (native_load_memory state) ram_block
     (native_load_chunk instruction) (demo_native_effective_address instruction state) with
 | Some (Vint value) => Some (demo_native_load_write state (native_load_target instruction) value)
 | _ => None
 end else None.

(** The pending next PC is consumed unchanged, including a load in a branch
    delay slot. No control instruction or invented callee is handled here. *)
Definition demo_native_load_step ram_block state : option demo_native_load_state :=
 match demo_concrete_ram_load (native_load_memory state) ram_block Mint32 (native_load_pc state) with
 | Some (Vint word) =>
   match demo_native_decode_load word with
   | Some instruction => demo_native_execute_load ram_block instruction state
   | None => None
   end
 | _ => None
 end.

Lemma demo_native_ram_load_word_address : forall memory ram_block chunk address,
 demo_native_ram_load64 memory ram_block chunk (demo_native_word_gpr address) =
 demo_concrete_ram_load memory ram_block chunk address.
Proof.
 intros. unfold demo_native_ram_load64. rewrite demo_native_word_gpr_low.
 rewrite Int64.eq_true. reflexivity.
Qed.

Lemma demo_native_zero_immediate :
 demo_native_word_gpr Int.zero = Int64.zero.
Proof. reflexivity. Qed.

Lemma demo_native_zero_offset_address : forall instruction state address,
 native_load_immediate instruction = Int.zero ->
 demo_native_get state (native_load_base instruction) = demo_native_word_gpr address ->
 demo_native_effective_address instruction state = demo_native_word_gpr address.
Proof.
 intros instruction state address Himm Hbase.
 unfold demo_native_effective_address. rewrite Himm,Hbase,demo_native_zero_immediate.
 apply Int64.add_zero.
Qed.

Lemma demo_native_zero_offset_domain : forall instruction state address,
 native_load_immediate instruction = Int.zero ->
 demo_native_get state (native_load_base instruction) = demo_native_word_gpr address ->
 demo_native_load_address_domain instruction state = true.
Proof.
 intros instruction state address Himm Hbase.
 unfold demo_native_load_address_domain. rewrite Himm,Hbase,demo_native_word_gpr_low.
 rewrite Int64.eq_true,Int.signed_zero,Z.add_0_r.
 pose proof (Int.signed_range address) as Hrange.
 apply andb_true_iff. split; [apply andb_true_iff; split; [reflexivity|]|];
 apply Z.leb_le; change Int.min_signed with (-2147483648) in *;
 change Int.max_signed with 2147483647 in *;
 change Int.half_modulus with 2147483648 in Hrange; lia.
Qed.

Theorem demo_native_loaded_word_result : forall state target value,
 target <> 0 ->
 Int64.loword (demo_native_get (demo_native_load_write state target value) target) = value /\
 native_load_memory (demo_native_load_write state target value) = native_load_memory state /\
 native_load_pc (demo_native_load_write state target value) = native_load_next_pc state /\
 (forall register, register <> target ->
   demo_native_get (demo_native_load_write state target value) register = demo_native_get state register).
Proof.
 intros state target value Htarget.
 assert (target =? 0 = false) as Hnz by (apply Z.eqb_neq; assumption).
 unfold demo_native_get, demo_native_load_write; cbn.
 rewrite Hnz,Z.eqb_refl. cbn. rewrite demo_native_word_gpr_low.
 repeat split; try reflexivity. intros register Hregister.
 destruct (register =? 0) eqn:Ezero; [reflexivity|].
 assert (register =? target = false) as Hne by (apply Z.eqb_neq; exact Hregister).
 rewrite Hne. reflexivity.
Qed.

Theorem demo_native_zero_offset_load_executes :
 forall ram_block state instruction word address value,
 demo_concrete_ram_load (native_load_memory state) ram_block Mint32
   (native_load_pc state) = Some (Vint word) ->
 demo_native_decode_load word = Some instruction ->
 native_load_immediate instruction = Int.zero ->
 demo_native_get state (native_load_base instruction) = demo_native_word_gpr address ->
 demo_concrete_ram_load (native_load_memory state) ram_block
   (native_load_chunk instruction) address = Some (Vint value) ->
 demo_native_load_step ram_block state =
   Some (demo_native_load_write state (native_load_target instruction) value).
Proof.
 intros ram_block state instruction word address value Hfetch Hdecode Himm Hbase Hload.
 unfold demo_native_load_step. rewrite Hfetch,Hdecode.
 unfold demo_native_execute_load.
 rewrite (demo_native_zero_offset_domain _ _ _ Himm Hbase).
 rewrite (demo_native_zero_offset_address _ _ _ Himm Hbase).
 rewrite demo_native_ram_load_word_address,Hload. reflexivity.
Qed.

(** Actual process_geo_layout first-opcode instruction, independently checked
    against the clean US and JP retail images by the native fixture pipeline. *)
Definition demo_native_geometry_load_word : int := Int.repr 2439774208.

Lemma demo_native_geometry_load_decodes :
 demo_native_decode_load demo_native_geometry_load_word =
 Some (NativeLoadInstruction Mint8unsigned 11 12 Int.zero).
Proof. reflexivity. Qed.

Theorem demo_native_generated_geometry_read_correspondence :
 forall context state ram_block address value,
 concrete_expression_memory context = native_load_memory state ->
 concrete_expression_ram_block context = ram_block ->
 (concrete_expression_temps context) ! SG._t'3 = Some (Vint address) ->
 demo_concrete_ram_load (native_load_memory state) ram_block Mint32
   (native_load_pc state) = Some (Vint demo_native_geometry_load_word) ->
 demo_native_get state 11 = demo_native_word_gpr address ->
 demo_concrete_ram_load (native_load_memory state) ram_block Mint8unsigned address = Some (Vint value) ->
 demo_concrete_eval_expr context scene_geometry_opcode_expression = Some (Vint value) /\
 demo_native_load_step ram_block state = Some (demo_native_load_write state 12 value) /\
 Int64.loword (demo_native_get (demo_native_load_write state 12 value) 12) = value /\
 native_load_memory (demo_native_load_write state 12 value) = native_load_memory state.
Proof.
 intros context state ram_block address value Hmemory Hram Htemp Hfetch Hbase Hload.
 split.
 - rewrite (demo_concrete_geometry_opcode_load _ _ Htemp),Hmemory,Hram. exact Hload.
 - split.
   + exact (demo_native_zero_offset_load_executes ram_block state
       (NativeLoadInstruction Mint8unsigned 11 12 Int.zero)
       demo_native_geometry_load_word address value Hfetch
       demo_native_geometry_load_decodes eq_refl Hbase Hload).
   + destruct (demo_native_loaded_word_result state 12 value ltac:(lia)) as (Hvalue & Hframe & _).
     auto.
Qed.

Definition demo_native_terrain_load_word : int := Int.repr 2244935680.

Lemma demo_native_terrain_load_decodes :
 demo_native_decode_load demo_native_terrain_load_word =
 Some (NativeLoadInstruction Mint16signed 14 15 Int.zero).
Proof. reflexivity. Qed.

Theorem demo_native_generated_terrain_read_correspondence :
 forall context state ram_block address value,
 concrete_expression_memory context = native_load_memory state ->
 concrete_expression_ram_block context = ram_block ->
 (concrete_expression_temps context) ! ST._t'10 = Some (Vint address) ->
 demo_concrete_ram_load (native_load_memory state) ram_block Mint32
   (native_load_pc state) = Some (Vint demo_native_terrain_load_word) ->
 demo_native_get state 14 = demo_native_word_gpr address ->
 demo_concrete_ram_load (native_load_memory state) ram_block Mint16signed address = Some (Vint value) ->
 demo_concrete_eval_expr context scene_terrain_type_expression = Some (Vint value) /\
 demo_native_load_step ram_block state = Some (demo_native_load_write state 15 value) /\
 Int64.loword (demo_native_get (demo_native_load_write state 15 value) 15) = value /\
 native_load_memory (demo_native_load_write state 15 value) = native_load_memory state.
Proof.
 intros context state ram_block address value Hmemory Hram Htemp Hfetch Hbase Hload.
 split.
 - rewrite (demo_concrete_terrain_type_load _ _ Htemp),Hmemory,Hram. exact Hload.
 - split.
   + exact (demo_native_zero_offset_load_executes ram_block state
       (NativeLoadInstruction Mint16signed 14 15 Int.zero)
       demo_native_terrain_load_word address value Hfetch
       demo_native_terrain_load_decodes eq_refl Hbase Hload).
   + destruct (demo_native_loaded_word_result state 15 value ltac:(lia)) as (Hvalue & Hframe & _).
     auto.
Qed.
