From Coq Require Import Bool List ZArith.
From Pedro.Proofs Require Import GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

(** A finite receipt for the [sqrtf] leaf in the authenticated clean US and
    JP retail images.  The source images have SHA-256 digests
    [17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91]
    and [9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317],
    respectively.  Hash authentication and map lookup happen outside Coq;
    the theorem checks the resulting finite transcription.  In particular,
    this module does not identify CompCert's [EF_external "sqrtf"] with a
    MIPS execution or prove a general external-function refinement. *)

Record RetailSqrtfImage : Type := {
  sqrtf_virtual_address : Z;
  sqrtf_rom_offset : Z;
  sqrtf_bytes : list Z
}.

(** Big-endian bytes for
      [03e00008 46006004 00000000 00000000]. *)
Definition retail_sqrtf_bytes : list Z :=
  [3; 224; 0; 8;
   70; 0; 96; 4;
   0; 0; 0; 0;
   0; 0; 0; 0].

Definition us_retail_sqrtf_image : RetailSqrtfImage :=
  {| sqrtf_virtual_address := 2150775376;  (* 0x80323a50 *)
     sqrtf_rom_offset := 911952;            (* 0x000dea50 *)
     sqrtf_bytes := retail_sqrtf_bytes |}.

Definition jp_retail_sqrtf_image : RetailSqrtfImage :=
  {| sqrtf_virtual_address := 2150771488;  (* 0x80322b20 *)
     sqrtf_rom_offset := 908064;            (* 0x000ddb20 *)
     sqrtf_bytes := retail_sqrtf_bytes |}.

Definition retail_sqrtf_image (version : GameVersion) : RetailSqrtfImage :=
  match version with
  | VersionUS => us_retail_sqrtf_image
  | VersionJP => jp_retail_sqrtf_image
  end.

(** Pack four big-endian bytes into one unsigned 32-bit instruction word. *)
Definition mips_word_be (b0 b1 b2 b3 : Z) : Z :=
  Z.shiftl b0 24 + Z.shiftl b1 16 + Z.shiftl b2 8 + b3.

Fixpoint mips_words_be (bytes : list Z) : list Z :=
  match bytes with
  | b0 :: b1 :: b2 :: b3 :: rest =>
      mips_word_be b0 b1 b2 b3 :: mips_words_be rest
  | _ => []
  end.

Definition retail_sqrtf_words (version : GameVersion) : list Z :=
  mips_words_be (sqrtf_bytes (retail_sqrtf_image version)).

Definition mips_opcode (word : Z) : Z := Z.land (Z.shiftr word 26) 63.
Definition mips_rt (word : Z) : Z := Z.land (Z.shiftr word 16) 31.
Definition mips_funct (word : Z) : Z := Z.land word 63.

(** Conservative call recognition for the stock VR4300 instruction set:
    direct [jal], register [jalr], and all four REGIMM branch-and-link forms. *)
Definition mips_maybe_call (word : Z) : bool :=
  (mips_opcode word =? 3) ||
  ((mips_opcode word =? 0) && (mips_funct word =? 9)) ||
  ((mips_opcode word =? 1) &&
   ((16 <=? mips_rt word) && (mips_rt word <=? 19))).

(** Conservative memory-store recognition.  It includes integer stores
    [0x28..0x2f] (classifying [cache] as store-like) and the conditional,
    coprocessor, and doubleword store opcodes [0x38..0x3f]. *)
Definition mips_maybe_store (word : Z) : bool :=
  ((40 <=? mips_opcode word) && (mips_opcode word <=? 47)) ||
  ((56 <=? mips_opcode word) && (mips_opcode word <=? 63)).

Definition retail_sqrtf_calls (version : GameVersion) : list Z :=
  filter mips_maybe_call (retail_sqrtf_words version).

Definition retail_sqrtf_stores (version : GameVersion) : list Z :=
  filter mips_maybe_store (retail_sqrtf_words version).

Definition mips_is_jr_ra (word : Z) : bool := word =? 65011720.
Definition mips_is_sqrt_s_f0_f12 (word : Z) : bool := word =? 1174429700.
Definition mips_is_nop (word : Z) : bool := word =? 0.

(** The clean-map locations share the same code-segment VA/ROM delta, and the
    transcribed image is exactly sixteen bytes in either supported version. *)
Definition retail_sqrtf_map_and_bytes_claim : Prop :=
  sqrtf_virtual_address us_retail_sqrtf_image = 2150775376 /\
  sqrtf_rom_offset us_retail_sqrtf_image = 911952 /\
  sqrtf_virtual_address jp_retail_sqrtf_image = 2150771488 /\
  sqrtf_rom_offset jp_retail_sqrtf_image = 908064 /\
  sqrtf_virtual_address us_retail_sqrtf_image -
    sqrtf_rom_offset us_retail_sqrtf_image = 2149863424 /\
  sqrtf_virtual_address jp_retail_sqrtf_image -
    sqrtf_rom_offset jp_retail_sqrtf_image = 2149863424 /\
  sqrtf_bytes us_retail_sqrtf_image = retail_sqrtf_bytes /\
  sqrtf_bytes jp_retail_sqrtf_image = retail_sqrtf_bytes /\
  length retail_sqrtf_bytes = 16%nat.

Theorem retail_sqrtf_map_and_bytes_checked :
  retail_sqrtf_map_and_bytes_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The complete four-word leaf is [jr ra], [sqrt.s f0,f12] in its delay
    slot, followed by two zero padding words. *)
Theorem retail_sqrtf_instruction_shape_checked :
  forall version,
    retail_sqrtf_words version =
      [65011720; 1174429700; 0; 0] /\
    mips_is_jr_ra (nth 0 (retail_sqrtf_words version) 0) = true /\
    mips_is_sqrt_s_f0_f12 (nth 1 (retail_sqrtf_words version) 0) = true /\
    mips_is_nop (nth 2 (retail_sqrtf_words version) 1) = true /\
    mips_is_nop (nth 3 (retail_sqrtf_words version) 1) = true.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

(** Since the only control transfer is the non-linking [jr ra], the leaf has
    no nested call.  No word is classified as any conservative store form. *)
Theorem retail_sqrtf_is_call_and_store_free :
  forall version,
    retail_sqrtf_calls version = [] /\
    retail_sqrtf_stores version = [].
Proof. intros []; vm_compute; split; reflexivity. Qed.

(** This capstone deliberately remains a retail-instruction receipt.  It can
    discharge a static "does this concrete leaf contain a call or store?"
    question, but it is not an [EF_external] semantic refinement theorem. *)
Definition RetailSqrtfInstructionReceipt : Prop :=
  retail_sqrtf_map_and_bytes_claim /\
  (forall version,
      retail_sqrtf_words version = [65011720; 1174429700; 0; 0]) /\
  (forall version,
      retail_sqrtf_calls version = [] /\
      retail_sqrtf_stores version = []).

Theorem retail_sqrtf_instruction_receipt_checked :
  RetailSqrtfInstructionReceipt.
Proof.
  split.
  - exact retail_sqrtf_map_and_bytes_checked.
  - split.
    + intros version.
      exact (proj1 (retail_sqrtf_instruction_shape_checked version)).
    + exact retail_sqrtf_is_call_and_store_free.
Qed.
