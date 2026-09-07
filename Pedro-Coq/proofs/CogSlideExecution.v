From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Ctypes Events Floats Globalenvs
  Integers Maps Memory Values.
From Pedro.Generated Require Import us_mario us_mario_step us_audio_external.
From Pedro.Proofs Require Import GameTypes TTCCogExecution SlideKickDustExecution
  SoundRequestExecution SlideKickAnimationExecution SlideKickHelperDischarge
  CogActionExecution CogReflectionExecution CogDustClearing.
Import ListNotations.
Open Scope Z_scope.

Definition cog_next_sound_index index := Int.zero_ext 8 (Int.add index Int.one).

Lemma cog_next_sound_index_bounded : forall index,
  0 <= Int.unsigned (cog_next_sound_index index) < 256.
Proof.
  intros index. unfold cog_next_sound_index.
  pose proof (Int.zero_ext_range 8 (Int.add index Int.one)
    ltac:(change (0 <= 8 < 32); lia)) as Hrange.
  change (0 <= Int.unsigned (Int.zero_ext 8 (Int.add index Int.one)) < 256) in Hrange.
  exact Hrange.
Qed.

Lemma cog_sound_count_after_stores : forall before q1 q2 after queue count index bits position,
  sound_request_stores before q1 q2 after queue count index bits position ->
  Mem.load Mint8unsigned after count 0 = Some (Vint (cog_next_sound_index index)).
Proof.
  intros before q1 q2 after queue count index bits position [_ [_ Hstore]].
  rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore).
  cbn -[Int.zero_ext Int.add]. rewrite Int.zero_ext_idem by lia. reflexivity.
Qed.

(** The only helper executions retained here are update_sliding and the full
    ground step. The subsequent reflection and transition, and both of their
    frame properties, are proved from their actual entry cells. *)
Definition cog_slide_two_helper_path version ge m0 m3 m4 mario : Prop :=
  Mem.load Mint16unsigned m0 mario 2 = Some (Vint (Int.repr 4)) /\
  (exists result,
    eval_funcall function_entry2 ge m0 (Internal (slide_update_function version))
      [Vptr mario Ptrofs.zero; Vsingle (Float32.of_bits (Int.repr 1065353216))]
      E0 m3 result) /\
  eval_funcall function_entry2 ge m3 (Internal (slide_ground_function version))
    [Vptr mario Ptrofs.zero] E0 m4 (Vint (Int.repr 2)) /\
  slide_anchor m3 mario = slide_anchor m0 mario /\
  slide_anchor m4 mario = slide_anchor m3 mario.

Definition cog_slide_entry_image memory mario object area floor speed flags : Prop :=
  cog_default_floor_image memory mario area floor /\
  Mem.load Mptr memory mario 96 = Some (Vint Int.zero) /\
  Mem.load Mptr memory mario 136 = Some (Vptr object Ptrofs.zero) /\
  Mem.load Mint16unsigned memory mario 2 = Some (Vint (Int.repr 4)) /\
  Mem.load Mint32 memory mario 4 = Some (Vint flags) /\
  Mem.load Mint32 memory mario 8 = Some (Vint Int.zero) /\
  Mem.load Mint32 memory mario 20 = Some (Vint (Int.repr 196608)) /\
  Mem.load Mfloat32 memory mario 84 = Some (Vsingle speed) /\
  Mem.load Mfloat32 memory mario 32 = Some (Vsingle Float32.zero) /\
  cog_kb_writable memory mario /\
  Mem.valid_access memory Mint32 mario 8 Writable.

Definition cog_slide_two_helper_claim version : Prop :=
  forall ge m0 m3 m4 mario object area floor speed flags sine yaw sin_value cos_value
    animation animation_end sliding ground reflection action sound speed_code floor_code moving_code
    list target frame loop_end table source base entries entry_offset size cache_code
    queue count index (caller : slide_caller_layout ge),
    slide_bindings version ge animation animation_end sliding ground reflection action sound ->
    slide_animation_layout ge caller -> animation_cache_layout ge ->
    sound_request_layout ge -> cog_action_layout ge caller -> cog_reflection_layout ge caller ->
    Genv.find_symbol ge us_mario._load_patchable_table = Some cache_code ->
    Genv.find_funct_ptr ge cache_code = Some (Internal (animation_cache_function version)) ->
    Genv.find_symbol ge us_mario._gSineTable = Some sine ->
    Genv.find_symbol ge us_mario_step._mario_set_forward_vel = Some speed_code ->
    Genv.find_funct_ptr ge speed_code = Some (Internal (cog_speed_function version)) ->
    Genv.find_symbol ge us_mario._mario_get_floor_class = Some floor_code ->
    Genv.find_funct_ptr ge floor_code = Some (Internal (cog_floor_class_function version)) ->
    Genv.find_symbol ge us_mario._set_mario_action_moving = Some moving_code ->
    Genv.find_funct_ptr ge moving_code = Some (Internal (cog_moving_transition_function version)) ->
    Genv.find_symbol ge us_audio_external._sSoundRequests = Some queue ->
    Genv.find_symbol ge us_audio_external._sSoundRequestCount = Some count ->
    mario <> sine -> mario <> queue -> mario <> count ->
    area <> mario -> area <> queue -> area <> count ->
    floor <> mario -> floor <> queue -> floor <> count ->
    slide_animation_state_image m0 mario object list target frame loop_end ->
    slide_animation_cache_image m0 list table source base entries entry_offset size ->
    cog_slide_two_helper_path version ge m0 m3 m4 mario ->
    cog_slide_entry_image m4 mario object area floor speed flags ->
    cog_speed_image m4 mario sine yaw sin_value cos_value ->
    sound_request_memory_image m4 queue count index ->
    Mem.valid_access m4 Mint32 queue (sound_slot_offset (cog_next_sound_index index)) Writable ->
    Mem.valid_access m4 Mptr queue (sound_slot_offset (cog_next_sound_index index) + 4) Writable ->
    exists m5 m6 m7 m8 m9,
      eval_funcall function_entry2 ge m0 (Internal (slide_kick_function version))
        [Vptr mario Ptrofs.zero] E0 m9 (Vint Int.zero) /\
      Mem.load Mint32 m9 mario 8 = Some (Vint (Int.repr 3)) /\
      Mem.load Mint16unsigned m9 mario 2 = Some (Vint (Int.repr 4)) /\
      Mem.load Mint32 m9 mario 12 = Some (Vint (Int.repr 132194)) /\
      map (fun m => slide_anchor m mario) [m0;m0;m0;m3;m4;m5;m6;m7;m8;m9] =
        repeat (slide_anchor m0 mario) 10 /\
      (forall environment locals,
        locals ! DC._m = Some (Vptr mario Ptrofs.zero) ->
        locals ! DC._cancel = Some (Vint Int.zero) ->
        exists locals', exec_stmt function_entry2 ge environment locals m9
          (cog_dispatcher_dust_tail version) E0 locals' m9
          (Out_return (Some (Vint Int.zero, tint)))).

Theorem generated_cog_slide_with_two_helpers_us_jp :
  forall version, cog_slide_two_helper_claim version.
Proof.
  intros version ge m0 m3 m4 mario object area floor speed flags sine yaw sin_value cos_value
    animation animation_end sliding ground reflection action sound speed_code floor_code moving_code
    list target frame loop_end table source base entries entry_offset size cache_code queue count index
    caller Hbindings Hanimation_layout Hcache_layout Hsound_layout Haction_layout Hreflection_layout
    Hcache_symbol Hcache_code Hsine Hspeed_symbol Hspeed_code Hfloor_symbol Hfloor_code
    Hmoving_symbol Hmoving_code Hqueue Hcount Hmsine Hmqueue Hmcount Ha_m Ha_q Ha_c Hf_m Hf_q Hf_c
    Hanimation_image Hcache_image Htwo Himage Hspeed_image Hsound_image Hnext_bits Hnext_pos.
  destruct Himage as [Hfloor_image [Hwall [Hobject [Hinput4 [Hflags [Hparticles
    [Hterrain [Hspeed [Hmag [Hwkb Hwparticles]]]]]]]]]].
  pose proof Hbindings as [_ [_ [_ [_ [_ [_ [_ [_ [_ [_ [_ [_ [Hsound_symbol Hsound_code]]]]]]]]]]]]].
  destruct (generated_cog_no_wall_reflection_executes_us_jp version ge m4 mario object sine
    queue count index yaw speed sin_value cos_value sound speed_code caller Hreflection_layout
    Hsound_layout Hsine Hqueue Hcount Hsound_symbol Hsound_code Hspeed_symbol Hspeed_code Hmsine
    Hmqueue Hmcount Hwall Hobject Hspeed Hspeed_image Hsound_image)
    as [q1 [q2 [audio [a1 [a2 [a3 [a4 [m5 [Hqstores [Hvstores [Hreflection
      [Href_anchor [Hspeed5 Href_frame]]]]]]]]]]]]].
  pose proof Hqstores as [Hq1 [Hq2 Hq3]].
  pose proof Hvstores as [Hv1 [Hv2 [Hv3 [Hv4 Hv5]]]].
  destruct (Mem.valid_access_store m5 Mint32 mario 8 (Vint (Int.repr 2))
    ltac:(cog_memory_access)) as [m6 Hstars].
  assert (Hprefix_frame : forall chunk b offset,
    cog_reflection_untouched mario queue count b chunk offset ->
    (b <> mario \/ offset + size_chunk chunk <= 8 \/ 12 <= offset) ->
    Mem.load chunk m6 b offset = Mem.load chunk m4 b offset).
  { intros chunk b offset Hsafe Hstar_safe.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hstars) by (cbn; intuition lia).
    apply Href_frame. exact Hsafe. }
  assert (Hfloor6 : cog_default_floor_image m6 mario area floor).
  { destruct Hfloor_image as [Ha [Ht [Hf [Hft Hact]]]].
    unfold cog_default_floor_image. repeat apply conj;
      rewrite Hprefix_frame by
        (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia);
      assumption. }
  assert (Hflags6 : Mem.load Mint32 m6 mario 4 = Some (Vint flags)).
  { rewrite Hprefix_frame by
      (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia). exact Hflags. }
  assert (Hmag6 : Mem.load Mfloat32 m6 mario 32 = Some (Vsingle Float32.zero)).
  { rewrite Hprefix_frame by
      (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia). exact Hmag. }
  assert (Hspeed6 : Mem.load Mfloat32 m6 mario 84 = Some (Vsingle (Float32.neg speed))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstars) by (right; right; cbn; lia). exact Hspeed5. }
  assert (Hwkb6 : cog_kb_writable m6 mario).
  { destruct Hwkb as [Hw1 [Hw2 [Hw3 [Hw4 [Hw5 Hw6]]]]].
    unfold cog_kb_writable. repeat first [solve [cog_memory_access] | apply conj]. }
  destruct (generated_cog_kb_transition_executes_and_frames_us_jp version ge m6 mario area floor
    (Float32.neg speed) flags floor_code moving_code caller Haction_layout Hfloor6 Hspeed6 Hmag6 Hflags6
    Hwkb6 Hfloor_symbol Hfloor_code Hmoving_symbol Hmoving_code)
    as (k1 & k2 & k3 & k4 & k5 & k6 & m7 & Hkstores & Haction & Haction_anchor &
      Hact7 & Hprev7 & Harg7 & Hstate7 & Htimer7 & Haction_frame).
  pose proof Hkstores as [Hk1 [Hk2 [Hk3 [Hk4 [Hk5 [Hk6 Hk7]]]]]].
  assert (Hcount5 : Mem.load Mint8unsigned m5 count 0 = Some (Vint (cog_next_sound_index index))).
  { rewrite (cog_speed_store_frame _ _ _ _ _ _ _ _ _ _ Hvstores) by
      (unfold cog_speed_untouched; auto).
    eapply cog_sound_count_after_stores. exact Hqstores. }
  assert (Hsound7 : sound_request_memory_image m7 queue count (cog_next_sound_index index)).
  { pose proof Hsound_image as [_ [_ [_ [_ Hwcount]]]].
    unfold sound_request_memory_image. split; [apply cog_next_sound_index_bounded |].
    split.
    - rewrite Haction_frame by (unfold cog_kb_untouched; auto).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hstars) by (left; congruence). exact Hcount5.
    - repeat first [solve [cog_memory_access] | apply conj]. }
  assert (Hparticles5 : Mem.load Mint32 m5 mario 8 = Some (Vint Int.zero)).
  { rewrite Href_frame by
      (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia). exact Hparticles. }
  assert (Hparticles7 : Mem.load Mint32 m7 mario 8 = Some (Vint (Int.repr 2))).
  { rewrite Haction_frame by (unfold cog_kb_untouched; cbn; intuition lia).
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstars). reflexivity. }
  assert (Hterrain7 : Mem.load Mint32 m7 mario 20 = Some (Vint (Int.repr 196608))).
  { rewrite Haction_frame by (unfold cog_kb_untouched; cbn; intuition lia).
    rewrite Hprefix_frame by
      (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia). exact Hterrain. }
  assert (Hobject7 : Mem.load Mptr m7 mario 136 = Some (Vptr object Ptrofs.zero)).
  { rewrite Haction_frame by (unfold cog_kb_untouched; cbn; intuition lia).
    rewrite Hprefix_frame by
      (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia). exact Hobject. }
  assert (Hinput7 : Mem.load Mint16unsigned m7 mario 2 = Some (Vint (Int.repr 4))).
  { rewrite Haction_frame by (unfold cog_kb_untouched; cbn; intuition lia).
    rewrite Hprefix_frame by
      (unfold cog_reflection_untouched, cog_speed_untouched; cbn; intuition lia). exact Hinput4. }
  destruct Htwo as [Hinput0 [Hsliding [Hground [Hanchor3 Hanchor4]]]].
  assert (Hfour : slide_four_helper_path version ge m0 m3 m4 m5 m6 m7 mario object).
  { unfold slide_four_helper_path. repeat first [assumption | solve [cog_memory_access] | apply conj]. }
  assert (Hfour_anchors : slide_four_helpers_preserve_anchor mario m0 m3 m4 m5 m6 m7).
  { unfold slide_four_helpers_preserve_anchor. repeat apply conj; assumption. }
  destruct (generated_slide_kick_with_animation_and_sound_discharged_us_jp version ge
    m0 m3 m4 m5 m6 m7 mario object animation animation_end sliding ground reflection action sound
    list target frame loop_end table source base entries entry_offset size cache_code queue count
    (cog_next_sound_index index) caller Hbindings Hanimation_layout Hcache_layout Hsound_layout
    Hcache_symbol Hcache_code Hqueue Hcount Hmqueue Hmcount Hanimation_image Hcache_image Hsound7
    Hfour Hfour_anchors) as (m8 & m9 & Hcall & Hparticles9 & Hanchors & Hsound_frame & Hdust).
  assert (Hinput9 : Mem.load Mint16unsigned m9 mario 2 = Some (Vint (Int.repr 4))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hdust) by (right; left; cbn; lia).
    rewrite Hsound_frame by congruence. exact Hinput7. }
  exists m5, m6, m7, m8, m9. split; [exact Hcall |]. split; [exact Hparticles9 |].
  split; [exact Hinput9 |]. split.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hdust) by (right; right; cbn; lia).
    rewrite Hsound_frame by congruence. exact Hact7.
  - split; [exact Hanchors |]. intros environment locals Hm Hcancel.
    eapply generated_cog_dry_dispatcher_tail_us_jp; eassumption.
Qed.
