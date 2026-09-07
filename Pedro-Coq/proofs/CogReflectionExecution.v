From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import us_mario jp_mario us_mario_step jp_mario_step
  us_audio_external us_math_util jp_math_util.
From Pedro.Proofs Require Import GameTypes TTCCogExecution SlideKickDustExecution
  SoundRequestExecution CogActionExecution.
Import ListNotations.
Open Scope Z_scope.
Module CR := us_mario.

Definition cog_speed_function version : function :=
  match version with VersionUS => CR.f_mario_set_forward_vel
                   | VersionJP => jp_mario.f_mario_set_forward_vel end.

Record cog_reflection_layout (ge : Clight.genv) (caller : slide_caller_layout ge) : Type := {
  reflection_face_offset : field_offset (genv_cenv ge) CR._faceAngle
    (co_members (slide_mario_co ge caller)) = OK (44, Full);
  reflection_velocity_offset : field_offset (genv_cenv ge) CR._vel
    (co_members (slide_mario_co ge caller)) = OK (72, Full);
  reflection_speed_offset : field_offset (genv_cenv ge) CR._forwardVel
    (co_members (slide_mario_co ge caller)) = OK (84, Full);
  reflection_slide_x_offset : field_offset (genv_cenv ge) CR._slideVelX
    (co_members (slide_mario_co ge caller)) = OK (88, Full);
  reflection_slide_z_offset : field_offset (genv_cenv ge) CR._slideVelZ
    (co_members (slide_mario_co ge caller)) = OK (92, Full);
  reflection_wall_offset : field_offset (genv_cenv ge) CR._wall
    (co_members (slide_mario_co ge caller)) = OK (96, Full)
}.

(** The generated cosine macro reads the same sine-table block, starting
    1024 float entries later. Keep the exact promoted signed shift. *)
Definition cog_trig_index yaw := Int.shr (Int.zero_ext 16 yaw) (Int.repr 4).
Definition cog_trig_offset base yaw :=
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr base)
    (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (cog_trig_index yaw)))).

Lemma cog_trig_index_bounded : forall yaw,
  0 <= Int.unsigned (cog_trig_index yaw) < 4096.
Proof.
  intros yaw.
  pose proof (Int.zero_ext_range 16 yaw ltac:(change (0 <= 16 < 32); lia)) as Hword.
  change (0 <= Int.unsigned (Int.zero_ext 16 yaw) < 65536) in Hword.
  unfold cog_trig_index. rewrite Int.shr_div_two_p.
  rewrite Int.signed_eq_unsigned by
    (change (Int.unsigned (Int.zero_ext 16 yaw) <= 2147483647); lia).
  assert (Hdivisor : two_p (Int.unsigned (Int.repr 4)) = 16) by reflexivity.
  rewrite Hdivisor.
  assert (Hquotient : 0 <= Int.unsigned (Int.zero_ext 16 yaw) / 16 < 4096).
  { split; [apply Z.div_pos; lia | apply Z.div_lt_upper_bound; lia]. }
  rewrite Int.unsigned_repr by
    (change (0 <= Int.unsigned (Int.zero_ext 16 yaw) / 16 <= 4294967295); lia).
  exact Hquotient.
Qed.

Lemma cog_trig_offset_exact : forall yaw base,
  0 <= base <= 4096 ->
  cog_trig_offset base yaw = base + 4 * Int.unsigned (cog_trig_index yaw).
Proof.
  intros yaw base Hbase. pose proof (cog_trig_index_bounded yaw) as Hindex.
  unfold cog_trig_offset, Ptrofs.add, Ptrofs.mul, Ptrofs.of_ints.
  rewrite Int.signed_eq_unsigned by
    (change (Int.unsigned (cog_trig_index yaw) <= 2147483647); lia).
  assert (Hmax : Ptrofs.max_unsigned = 4294967295) by reflexivity.
  rewrite (Ptrofs.unsigned_repr base) by (rewrite Hmax; lia).
  rewrite (Ptrofs.unsigned_repr 4) by (rewrite Hmax; lia).
  rewrite (Ptrofs.unsigned_repr (Int.unsigned (cog_trig_index yaw))) by (rewrite Hmax; lia).
  rewrite (Ptrofs.unsigned_repr (4 * Int.unsigned (cog_trig_index yaw))) by (rewrite Hmax; lia).
  rewrite Ptrofs.unsigned_repr by (rewrite Hmax; lia). reflexivity.
Qed.

Definition cog_trig_table_bounds_claim : Prop :=
  (forall yaw, 0 <= cog_trig_offset 0 yaw /\ cog_trig_offset 0 yaw + 4 <= 20480 /\
    0 <= cog_trig_offset 4096 yaw /\ cog_trig_offset 4096 yaw + 4 <= 20480) /\
  gvar_info us_math_util.v_gSineTable = tarray tfloat 5120 /\
  gvar_info jp_math_util.v_gSineTable = tarray tfloat 5120 /\
  length (gvar_init us_math_util.v_gSineTable) = 5120%nat /\
  length (gvar_init jp_math_util.v_gSineTable) = 5120%nat.

Theorem cog_trig_table_bounds_generated_us_jp : cog_trig_table_bounds_claim.
Proof.
  split.
  - intros yaw. pose proof (cog_trig_index_bounded yaw).
    rewrite !cog_trig_offset_exact by lia. lia.
  - repeat split; vm_compute; reflexivity.
Qed.

Definition cog_speed_image memory mario sine yaw sin_value cos_value : Prop :=
  Mem.load Mint16signed memory mario 46 = Some (Vint yaw) /\
  Mem.load Mfloat32 memory sine (cog_trig_offset 0 yaw) = Some (Vsingle sin_value) /\
  Mem.load Mfloat32 memory sine (cog_trig_offset 4096 yaw) = Some (Vsingle cos_value) /\
  Mem.valid_access memory Mfloat32 mario 84 Writable /\
  Mem.valid_access memory Mfloat32 mario 88 Writable /\
  Mem.valid_access memory Mfloat32 mario 92 Writable /\
  Mem.valid_access memory Mfloat32 mario 72 Writable /\
  Mem.valid_access memory Mfloat32 mario 80 Writable.

Definition cog_speed_stores before m1 m2 m3 m4 after mario speed sin_value cos_value : Prop :=
  Mem.store Mfloat32 before mario 84 (Vsingle speed) = Some m1 /\
  Mem.store Mfloat32 m1 mario 88 (Vsingle (Float32.mul sin_value speed)) = Some m2 /\
  Mem.store Mfloat32 m2 mario 92 (Vsingle (Float32.mul cos_value speed)) = Some m3 /\
  Mem.store Mfloat32 m3 mario 72 (Vsingle (Float32.mul sin_value speed)) = Some m4 /\
  Mem.store Mfloat32 m4 mario 80 (Vsingle (Float32.mul cos_value speed)) = Some after.

Ltac reflection_reduce :=
  cbn -[Int.zero_ext Int.shr Int.and Int.or Int.not
    Ptrofs.repr Ptrofs.add Ptrofs.mul Ptrofs.of_ints Float32.mul Float32.neg].

Ltac reflection_load :=
  first [solve [eassumption] |
    solve [match goal with
      | H : Mem.load ?chunk ?before ?b ?offset = Some ?value |-
          Mem.load ?chunk ?after ?b ?actual = Some ?result =>
          unify result value;
          change (Mem.load chunk after b offset = Some value);
          repeat match goal with
          | S : Mem.store _ _ _ _ _ = Some ?m |- Mem.load _ ?m _ _ = _ =>
              rewrite (Mem.load_store_other _ _ _ _ _ _ S) by (left; congruence)
          end; exact H
      end] | timeout 1 cog_memory_load].

Ltac reflection_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar; reflection_reduce; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [reflection_expr | reflection_expr | reflection_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [reflection_expr | reflection_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [reflection_expr | reflection_reduce; reflexivity]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [reflection_lvalue |
       first [eapply deref_loc_value; [reflexivity | reflection_reduce; action_check reflection_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with reflection_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; reflection_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [reflection_expr | reflexivity | eassumption | eassumption]
  end.
Ltac reflection_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [reflection_expr | cbn; reflexivity | reflection_arguments]].
Ltac reflection_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [reflection_stmt | reflection_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset ?id _) _ _ _ _ =>
      eapply exec_Sset; reflection_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [reflection_lvalue | reflection_expr | cbn; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [reflection_expr | cbn; reflexivity | cog_reduce_statement; reflection_stmt]
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | reflection_expr | reflection_arguments |
       eapply cog_find_funct_zero; eassumption | reflexivity | eassumption]
  end.

Theorem generated_cog_speed_setter_with_stores_us_jp :
  forall version ge before m1 m2 m3 m4 after mario sine yaw speed sin_value cos_value
      (caller : slide_caller_layout ge),
    cog_reflection_layout ge caller ->
    Genv.find_symbol ge CR._gSineTable = Some sine ->
    mario <> sine ->
    cog_speed_image before mario sine yaw sin_value cos_value ->
    cog_speed_stores before m1 m2 m3 m4 after mario speed sin_value cos_value ->
    eval_funcall function_entry2 ge before (Internal (cog_speed_function version))
      [Vptr mario Ptrofs.zero; Vsingle speed] E0 after Vundef.
Proof.
  intros version ge before m1 m2 m3 m4 after mario sine yaw speed sin_value cos_value
    caller Hlayout Hsine Hsep Himage Hstores.
  destruct Himage as [Hyaw [Hsin [Hcos [Hw1 [Hw2 [Hw3 [Hw4 Hw5]]]]]]].
  destruct Hstores as [Hs1 [Hs2 [Hs3 [Hs4 Hs5]]]].
  destruct Hlayout; destruct caller.
  destruct version; cbn [cog_speed_function].
  all: eapply eval_funcall_internal;
    [action_entry | simpl fn_body; timeout 15 reflection_stmt | cbn; reflexivity | cbn; reflexivity].
Qed.

Definition cog_speed_untouched (mario b : block) chunk offset : Prop :=
  b <> mario \/ offset + size_chunk chunk <= 72 \/ 96 <= offset \/
  (76 <= offset /\ offset + size_chunk chunk <= 80).

Lemma cog_speed_store_frame :
  forall before m1 m2 m3 m4 after mario speed sin_value cos_value,
    cog_speed_stores before m1 m2 m3 m4 after mario speed sin_value cos_value ->
    forall chunk b offset, cog_speed_untouched mario b chunk offset ->
      Mem.load chunk after b offset = Mem.load chunk before b offset.
Proof.
  intros before m1 m2 m3 m4 after mario speed sin_value cos_value
    [Hs1 [Hs2 [Hs3 [Hs4 Hs5]]]] chunk b offset Hsafe.
  unfold cog_speed_untouched in Hsafe.
  repeat match goal with
  | H : Mem.store _ _ _ _ _ = Some ?out |- Mem.load _ ?out _ _ = _ =>
      rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (cbn; intuition lia)
  end. reflexivity.
Qed.

Theorem generated_cog_speed_setter_executes_us_jp :
  forall version ge before mario sine yaw speed sin_value cos_value
      (caller : slide_caller_layout ge),
    cog_reflection_layout ge caller ->
    Genv.find_symbol ge CR._gSineTable = Some sine ->
    mario <> sine ->
    cog_speed_image before mario sine yaw sin_value cos_value ->
    exists m1 m2 m3 m4 after,
      cog_speed_stores before m1 m2 m3 m4 after mario speed sin_value cos_value /\
      eval_funcall function_entry2 ge before (Internal (cog_speed_function version))
        [Vptr mario Ptrofs.zero; Vsingle speed] E0 after Vundef /\
      (forall chunk b offset, cog_speed_untouched mario b chunk offset ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros version ge before mario sine yaw speed sin_value cos_value caller Hlayout Hsine Hsep Himage.
  pose proof Himage as [Hyaw [Hsin [Hcos [Hw1 [Hw2 [Hw3 [Hw4 Hw5]]]]]]].
  destruct (Mem.valid_access_store before Mfloat32 mario 84 (Vsingle speed)
    ltac:(cog_memory_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mfloat32 mario 88 (Vsingle (Float32.mul sin_value speed))
    ltac:(cog_memory_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mfloat32 mario 92 (Vsingle (Float32.mul cos_value speed))
    ltac:(cog_memory_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mfloat32 mario 72 (Vsingle (Float32.mul sin_value speed))
    ltac:(cog_memory_access)) as [m4 Hs4].
  destruct (Mem.valid_access_store m4 Mfloat32 mario 80 (Vsingle (Float32.mul cos_value speed))
    ltac:(cog_memory_access)) as [after Hs5].
  assert (Hstores : cog_speed_stores before m1 m2 m3 m4 after mario speed sin_value cos_value)
    by (repeat split; assumption).
  exists m1, m2, m3, m4, after. split; [exact Hstores |].
  split; [eapply generated_cog_speed_setter_with_stores_us_jp; eassumption |].
  exact (cog_speed_store_frame _ _ _ _ _ _ _ _ _ _ Hstores).
Qed.

Definition cog_reflection_untouched mario queue count b chunk offset : Prop :=
  b <> queue /\ b <> count /\ cog_speed_untouched mario b chunk offset.

(** The close-gap ground return may have no wall surface. On that branch the
    unchanged generated reflection queues HIT and calls the unchanged velocity
    setter. Both executions are constructed here, rather than assumed. *)
Theorem generated_cog_no_wall_reflection_executes_us_jp :
  forall version ge before mario object sine queue count index yaw speed sin_value cos_value
      sound_code speed_code (caller : slide_caller_layout ge),
    cog_reflection_layout ge caller -> sound_request_layout ge ->
    Genv.find_symbol ge CR._gSineTable = Some sine ->
    Genv.find_symbol ge us_audio_external._sSoundRequests = Some queue ->
    Genv.find_symbol ge us_audio_external._sSoundRequestCount = Some count ->
    Genv.find_symbol ge us_mario_step._play_sound = Some sound_code ->
    Genv.find_funct_ptr ge sound_code = Some (Internal (sound_request_function version)) ->
    Genv.find_symbol ge us_mario_step._mario_set_forward_vel = Some speed_code ->
    Genv.find_funct_ptr ge speed_code = Some (Internal (cog_speed_function version)) ->
    mario <> sine -> mario <> queue -> mario <> count ->
    Mem.load Mptr before mario 96 = Some (Vint Int.zero) ->
    Mem.load Mptr before mario 136 = Some (Vptr object Ptrofs.zero) ->
    Mem.load Mfloat32 before mario 84 = Some (Vsingle speed) ->
    cog_speed_image before mario sine yaw sin_value cos_value ->
    sound_request_memory_image before queue count index ->
    exists q1 q2 audio a1 a2 a3 a4 after,
      sound_request_stores before q1 q2 audio queue count index (Int.repr 71614593)
        (Vptr object (Ptrofs.repr 84)) /\
      cog_speed_stores audio a1 a2 a3 a4 after mario (Float32.neg speed) sin_value cos_value /\
      eval_funcall function_entry2 ge before (Internal (slide_reflection_function version))
        [Vptr mario Ptrofs.zero; Vint Int.one] E0 after Vundef /\
      slide_anchor after mario = slide_anchor before mario /\
      Mem.load Mfloat32 after mario 84 = Some (Vsingle (Float32.neg speed)) /\
      (forall chunk b offset, cog_reflection_untouched mario queue count b chunk offset ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros version ge before mario object sine queue count index yaw speed sin_value cos_value
    sound_code speed_code caller Hlayout Hsound_layout Hsine Hqueue Hcount Hsound_symbol Hsound_code
    Hspeed_symbol Hspeed_code Hmsine Hmqueue Hmcount Hwall Hobject Hspeed Himage Hsound_image.
  assert (Hsqueue : sine <> queue).
  { eapply Genv.global_addresses_distinct; [|exact Hsine|exact Hqueue]. discriminate. }
  assert (Hscount : sine <> count).
  { eapply Genv.global_addresses_distinct; [|exact Hsine|exact Hcount]. discriminate. }
  destruct (generated_sound_request_executes_and_frames_us_jp version ge before queue count index
    (Int.repr 71614593) object (Ptrofs.repr 84) Hsound_layout Hqueue Hcount Hsound_image)
    as [q1 [q2 [audio [Hqstores [Hsound Hsound_frame]]]]].
  pose proof Hqstores as [Hq1 [Hq2 Hq3]].
  assert (Hspeed_image : cog_speed_image audio mario sine yaw sin_value cos_value).
  { destruct Himage as [Hyaw [Hsin [Hcos [Hw1 [Hw2 [Hw3 [Hw4 Hw5]]]]]]].
    unfold cog_speed_image.
    repeat first [solve [rewrite Hsound_frame by congruence; assumption] |
      solve [cog_memory_access] | apply conj]. }
  assert (Hspeed_audio : Mem.load Mfloat32 audio mario 84 = Some (Vsingle speed)).
  { rewrite Hsound_frame by congruence. exact Hspeed. }
  destruct (generated_cog_speed_setter_executes_us_jp version ge audio mario sine yaw
    (Float32.neg speed) sin_value cos_value caller Hlayout Hsine Hmsine Hspeed_image)
    as [a1 [a2 [a3 [a4 [after [Hvstores [Hvelocity Hvelocity_frame]]]]]]].
  assert (Hcall : eval_funcall function_entry2 ge before
    (Internal (slide_reflection_function version))
    [Vptr mario Ptrofs.zero; Vint Int.one] E0 after Vundef).
  { destruct Hlayout; destruct caller.
    destruct version; cbn [slide_reflection_function].
    all: eapply eval_funcall_internal;
      [action_entry | simpl fn_body; timeout 15 reflection_stmt | cbn; reflexivity | cbn; reflexivity]. }
  exists q1, q2, audio, a1, a2, a3, a4, after.
  split; [exact Hqstores |]. split; [exact Hvstores |]. split; [exact Hcall |].
  split.
  { unfold slide_anchor.
    repeat rewrite Hvelocity_frame by (unfold cog_speed_untouched; cbn; intuition lia).
    repeat rewrite Hsound_frame by congruence. reflexivity. }
  split.
  { destruct Hvstores as [Hv1 [Hv2 [Hv3 [Hv4 Hv5]]]]. cog_memory_load. }
  intros chunk b offset [Hbq [Hbc Hsafe]].
  rewrite Hvelocity_frame by exact Hsafe. apply Hsound_frame; assumption.
Qed.

Definition cog_reflection_layout_receipt : Prop :=
  forall version,
  let ce := prog_comp_env
    (match version with VersionUS => CR.prog | VersionJP => jp_mario.prog end) in
  map (fun field => field_offset ce field
    (match ce ! CR._MarioState with Some co => co_members co | None => [] end))
    [CR._faceAngle; CR._vel; CR._forwardVel; CR._slideVelX; CR._slideVelZ; CR._wall] =
    map (fun offset => OK (offset, Full)) [44;72;84;88;92;96].

Theorem cog_reflection_layout_generated_us_jp : cog_reflection_layout_receipt.
Proof. intros []; vm_compute; reflexivity. Qed.
