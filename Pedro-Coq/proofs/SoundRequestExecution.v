From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import us_audio_external jp_audio_external us_behavior_script.
From Pedro.Proofs Require Import GameTypes TTCCogExecution SlideKickDustExecution.
Import ListNotations.
Open Scope Z_scope.
Module SQ := us_audio_external.

Definition sound_request_function version : function :=
  match version with VersionUS => SQ.f_play_sound
                   | VersionJP => jp_audio_external.f_play_sound end.

Record sound_request_layout (ge : Clight.genv) : Type := {
  sound_request_composite : composite;
  sound_request_lookup : (genv_cenv ge) ! SQ._Sound = Some sound_request_composite;
  sound_request_size : co_sizeof sound_request_composite = 8;
  sound_request_bits_offset : field_offset (genv_cenv ge) SQ._soundBits
    (co_members sound_request_composite) = OK (0, Full);
  sound_request_position_offset : field_offset (genv_cenv ge) SQ._position
    (co_members sound_request_composite) = OK (4, Full)
}.

Definition sound_slot_offset (index : int) : Z := 8 * Int.unsigned index.

Lemma sound_queue_offset : forall index field,
  0 <= Int.unsigned index < 256 -> 0 <= field <= 4 ->
  Ptrofs.unsigned (Ptrofs.add
    (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr 8) (Ptrofs.of_ints index)))
    (Ptrofs.repr field)) = sound_slot_offset index + field.
Proof.
  intros index field Hindex Hfield.
  rewrite Ptrofs.add_zero_l.
  unfold Ptrofs.add, Ptrofs.mul, Ptrofs.of_ints, sound_slot_offset.
  rewrite Int.signed_eq_unsigned by (change (Int.unsigned index <= 2147483647); lia).
  assert (Hmax : Ptrofs.max_unsigned = 4294967295) by reflexivity.
  rewrite (Ptrofs.unsigned_repr 8) by (rewrite Hmax; lia).
  rewrite (Ptrofs.unsigned_repr (Int.unsigned index)) by (rewrite Hmax; lia).
  rewrite (Ptrofs.unsigned_repr field) by (rewrite Hmax; lia).
  rewrite (Ptrofs.unsigned_repr (8 * Int.unsigned index)) by (rewrite Hmax; lia).
  rewrite Ptrofs.unsigned_repr by (rewrite Hmax; lia).
  reflexivity.
Qed.

Definition sound_request_memory_image (memory : mem) (queue count : block)
    (index : int) : Prop :=
  0 <= Int.unsigned index < 256 /\
  Mem.load Mint8unsigned memory count 0 = Some (Vint index) /\
  Mem.valid_access memory Mint32 queue (sound_slot_offset index) Writable /\
  Mem.valid_access memory Mptr queue (sound_slot_offset index + 4) Writable /\
  Mem.valid_access memory Mint8unsigned count 0 Writable.

Definition sound_request_stores before first second after queue count index bits position : Prop :=
  Mem.store Mint32 before queue (sound_slot_offset index) (Vint bits) = Some first /\
  Mem.store Mptr first queue (sound_slot_offset index + 4) position = Some second /\
  Mem.store Mint8unsigned second count 0
    (Vint (Int.zero_ext 8 (Int.add index Int.one))) = Some after.

Ltac sound_normalize :=
  cbn;
  repeat match goal with
  | H : (genv_cenv _) ! _ = Some _ |- _ => progress rewrite H
  | H : co_sizeof _ = _ |- _ => progress rewrite H
  end;
  cbn;
  first [reflexivity | eassumption |
    match goal with |- ?G => idtac "SOUND NORMALIZE" G end; fail 100].

Ltac sound_load :=
  first [cog_memory_load |
    match goal with |- ?G => idtac "SOUND LOAD" G end; fail 100].

Ltac sound_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [sound_expr | sound_expr | sound_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [sound_expr | sound_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [sound_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; sound_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with sound_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; sound_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct; [sound_expr | reflexivity | eassumption | eassumption]
  end.

Ltac sound_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [sound_stmt | sound_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; sound_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [sound_lvalue | sound_expr | sound_normalize |
       eapply assign_loc_value;
       [reflexivity | cbn;
        repeat match goal with
        | H : (genv_cenv _) ! _ = Some _ |- _ => progress rewrite H
        | H : co_sizeof _ = _ |- _ => progress rewrite H
        end;
        try rewrite sound_queue_offset by (first [assumption | lia]);
        try rewrite Z.add_0_r;
        first [eassumption | match goal with |- ?G => idtac "SOUND STORE" G end; fail 100]]]
  end.

(** Exact three-store generated caller; no callee execution or RNG contract
    is assumed. The bounded queue index and valid stores describe ordinary
    queue use. They do not assert a particular whole-frame sound schedule. *)
Theorem generated_sound_request_with_stores_us_jp :
  forall version (ge : Clight.genv) before first second after queue count index bits position_block position_offset,
    sound_request_layout ge ->
    Genv.find_symbol ge SQ._sSoundRequests = Some queue ->
    Genv.find_symbol ge SQ._sSoundRequestCount = Some count ->
    0 <= Int.unsigned index < 256 ->
    Mem.load Mint8unsigned before count 0 = Some (Vint index) ->
    sound_request_stores before first second after queue count index bits
      (Vptr position_block position_offset) ->
    eval_funcall function_entry2 ge before (Internal (sound_request_function version))
      [Vint bits; Vptr position_block position_offset] E0 after Vundef.
Proof.
  intros version ge before first second after queue count index bits position_block position_offset
    Hlayout Hqueue Hcount Hbound Hload Hstores.
  destruct Hlayout as [co Hco Hsize Hbits Hposition].
  destruct Hstores as [Hfirst [Hsecond Hafter]].
  assert (Hdifferent : count <> queue).
  { eapply Genv.global_addresses_distinct; [| exact Hcount | exact Hqueue].
    discriminate. }
  assert (Hfunction : sound_request_function version = SQ.f_play_sound)
    by (destruct version; reflexivity).
  rewrite Hfunction. eapply eval_funcall_internal.
  - eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
     cbn; apply alloc_variables_nil | cbn; reflexivity].
  - simpl fn_body; sound_stmt.
  - cbn; reflexivity.
  - cbn; reflexivity.
Qed.

Lemma sound_request_stores_preserve_other_blocks :
  forall before first second after queue count index bits position,
    sound_request_stores before first second after queue count index bits position ->
    forall chunk b offset,
      b <> queue -> b <> count ->
      Mem.load chunk after b offset = Mem.load chunk before b offset.
Proof.
  intros before first second after queue count index bits position
    [Hfirst [Hsecond Hafter]] chunk b offset Hqueue Hcount.
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hafter) by (left; congruence).
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hsecond) by (left; congruence).
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hfirst) by (left; congruence).
  reflexivity.
Qed.

Definition sound_request_execution_claim version : Prop :=
  forall (ge : Clight.genv) before queue count index bits position_block position_offset,
    sound_request_layout ge ->
    Genv.find_symbol ge SQ._sSoundRequests = Some queue ->
    Genv.find_symbol ge SQ._sSoundRequestCount = Some count ->
    sound_request_memory_image before queue count index ->
    exists first second after,
      sound_request_stores before first second after queue count index bits
        (Vptr position_block position_offset) /\
      eval_funcall function_entry2 ge before (Internal (sound_request_function version))
        [Vint bits; Vptr position_block position_offset] E0 after Vundef /\
      (forall chunk b offset, b <> queue -> b <> count ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).

(** All three writes exist from the entry permissions; they are no longer
    assumed as successful stores or a helper-execution premise. Every load
    outside the queue and counter is preserved, including the gameplay seed
    when its distinct global binding is supplied. *)
Theorem generated_sound_request_executes_and_frames_us_jp :
  forall version, sound_request_execution_claim version.
Proof.
  intros version ge before queue count index bits position_block position_offset
    Hlayout Hqueue Hcount [Hbound [Hload [Hbits [Hposition Hcounter]]]].
  destruct (Mem.valid_access_store before Mint32 queue (sound_slot_offset index)
    (Vint bits) Hbits) as [first Hfirst].
  destruct (Mem.valid_access_store first Mptr queue (sound_slot_offset index + 4)
    (Vptr position_block position_offset) ltac:(cog_memory_access)) as [second Hsecond].
  destruct (Mem.valid_access_store second Mint8unsigned count 0
    (Vint (Int.zero_ext 8 (Int.add index Int.one))) ltac:(cog_memory_access))
    as [after Hafter].
  assert (Hstores : sound_request_stores before first second after queue count index bits
    (Vptr position_block position_offset)) by (repeat split; assumption).
  exists first, second, after. split; [exact Hstores | split].
  - eapply generated_sound_request_with_stores_us_jp; eassumption.
  - eapply sound_request_stores_preserve_other_blocks; exact Hstores.
Qed.

Lemma sound_request_stores_preserve_anchor :
  forall before first second after queue count index bits position mario,
    sound_request_stores before first second after queue count index bits position ->
    mario <> queue -> mario <> count ->
    slide_anchor after mario = slide_anchor before mario.
Proof.
  intros before first second after queue count index bits position mario Hstores Hqueue Hcount.
  unfold slide_anchor.
  repeat rewrite (sound_request_stores_preserve_other_blocks
    _ _ _ _ _ _ _ _ _ Hstores) by assumption.
  reflexivity.
Qed.

Theorem sound_request_stores_preserve_gameplay_rng :
  forall (ge : Clight.genv) before first second after queue count seed index bits position,
    Genv.find_symbol ge SQ._sSoundRequests = Some queue ->
    Genv.find_symbol ge SQ._sSoundRequestCount = Some count ->
    Genv.find_symbol ge us_behavior_script._gRandomSeed16 = Some seed ->
    sound_request_stores before first second after queue count index bits position ->
    Mem.load Mint16unsigned after seed 0 = Mem.load Mint16unsigned before seed 0.
Proof.
  intros ge before first second after queue count seed index bits position
    Hqueue Hcount Hseed Hstores.
  eapply sound_request_stores_preserve_other_blocks; [exact Hstores | |].
  - eapply Genv.global_addresses_distinct; [|exact Hseed|exact Hqueue]. discriminate.
  - eapply Genv.global_addresses_distinct; [|exact Hseed|exact Hcount]. discriminate.
Qed.

Definition sound_layout_receipt : Prop :=
  forall version,
    let ce := prog_comp_env (match version with
      VersionUS => SQ.prog | VersionJP => jp_audio_external.prog end) in
    match ce ! SQ._Sound with
    | Some co => co_sizeof co = 8 /\
        field_offset ce SQ._soundBits (co_members co) = OK (0, Full) /\
        field_offset ce SQ._position (co_members co) = OK (4, Full)
    | None => False
    end.

Theorem sound_layout_generated_us_jp : sound_layout_receipt.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem sound_queue_has_256_entries_us_jp :
  forall version,
    let queue := match version with VersionUS => SQ.v_sSoundRequests
                     | VersionJP => jp_audio_external.v_sSoundRequests end in
    gvar_info queue = tarray (Tstruct SQ._Sound noattr) 256 /\
    gvar_init queue = [Init_space 2048] /\
    gvar_readonly queue = false.
Proof. intros []; repeat split; reflexivity. Qed.
