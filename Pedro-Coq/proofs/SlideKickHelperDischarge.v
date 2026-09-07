From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Ctypes Events Floats Globalenvs
  Integers Memory Values.
From Pedro.Generated Require Import us_mario us_audio_external.
From Pedro.Proofs Require Import GameTypes TTCCogExecution SlideKickDustExecution
  SoundRequestExecution SlideKickAnimationExecution.
Import ListNotations.
Open Scope Z_scope.

(** Only four actual helper executions remain: sliding, ground step,
    reflection, and action transition. The animation cache and sound request
    are executed below. These four executions and their preservation facts
    are still premises, so this is not a reachable or sustained cog witness. *)
Definition slide_four_helper_path version ge m0 m3 m4 m5 m6 m7 mario object : Prop :=
  Mem.load Mint16unsigned m0 mario 2 = Some (Vint (Int.repr 4)) /\
  (exists result,
    eval_funcall function_entry2 ge m0 (Internal (slide_update_function version))
      [Vptr mario Ptrofs.zero; Vsingle (Float32.of_bits (Int.repr 1065353216))]
      E0 m3 result) /\
  eval_funcall function_entry2 ge m3 (Internal (slide_ground_function version))
    [Vptr mario Ptrofs.zero] E0 m4 (Vint (Int.repr 2)) /\
  eval_funcall function_entry2 ge m4 (Internal (slide_reflection_function version))
    [Vptr mario Ptrofs.zero; Vint Int.one] E0 m5 Vundef /\
  Mem.load Mint32 m5 mario 8 = Some (Vint Int.zero) /\
  Mem.store Mint32 m5 mario 8 (Vint (Int.repr 2)) = Some m6 /\
  eval_funcall function_entry2 ge m6 (Internal (slide_action_function version))
    [Vptr mario Ptrofs.zero; Vint (Int.repr 132194); Vint Int.zero]
    E0 m7 (Vint Int.one) /\
  Mem.load Mint32 m7 mario 20 = Some (Vint Int.zero) /\
  Mem.load Mptr m7 mario 136 = Some (Vptr object Ptrofs.zero) /\
  Mem.load Mint32 m7 mario 8 = Some (Vint (Int.repr 2)) /\
  Mem.valid_access m7 Mint32 mario 8 Writable.

Definition slide_four_helpers_preserve_anchor mario m0 m3 m4 m5 m6 m7 : Prop :=
  slide_anchor m3 mario = slide_anchor m0 mario /\
  slide_anchor m4 mario = slide_anchor m3 mario /\
  slide_anchor m5 mario = slide_anchor m4 mario /\
  slide_anchor m7 mario = slide_anchor m6 mario.

Definition slide_discharged_caller_claim version : Prop :=
  forall (ge : Clight.genv) m0 m3 m4 m5 m6 m7 mario object
    animation animation_end sliding ground reflection action sound
    list target frame loop_end table source base entries entry_offset size cache_code
    queue count index (caller : slide_caller_layout ge),
    slide_bindings version ge animation animation_end sliding ground reflection action sound ->
    slide_animation_layout ge caller ->
    animation_cache_layout ge ->
    sound_request_layout ge ->
    Genv.find_symbol ge us_mario._load_patchable_table = Some cache_code ->
    Genv.find_funct_ptr ge cache_code = Some (Internal (animation_cache_function version)) ->
    Genv.find_symbol ge us_audio_external._sSoundRequests = Some queue ->
    Genv.find_symbol ge us_audio_external._sSoundRequestCount = Some count ->
    mario <> queue -> mario <> count ->
    slide_animation_state_image m0 mario object list target frame loop_end ->
    slide_animation_cache_image m0 list table source base entries entry_offset size ->
    sound_request_memory_image m7 queue count index ->
    slide_four_helper_path version ge m0 m3 m4 m5 m6 m7 mario object ->
    slide_four_helpers_preserve_anchor mario m0 m3 m4 m5 m6 m7 ->
    exists m8 m9,
      eval_funcall function_entry2 ge m0 (Internal (slide_kick_function version))
        [Vptr mario Ptrofs.zero] E0 m9 (Vint Int.zero) /\
      Mem.load Mint32 m9 mario 8 = Some (Vint (Int.repr 3)) /\
      map (fun m => slide_anchor m mario) [m0;m0;m0;m3;m4;m5;m6;m7;m8;m9] =
        repeat (slide_anchor m0 mario) 10 /\
      (forall chunk b offset, b <> queue -> b <> count ->
        Mem.load chunk m8 b offset = Mem.load chunk m7 b offset).

Theorem generated_slide_kick_with_animation_and_sound_discharged_us_jp :
  forall version, slide_discharged_caller_claim version.
Proof.
  intros version ge m0 m3 m4 m5 m6 m7 mario object animation animation_end sliding ground
    reflection action sound list target frame loop_end table source base entries entry_offset
    size cache_code queue count index caller Hbindings Hanimation_layout Hcache_layout
    Hsound_layout Hcache_symbol Hcache_code Hqueue Hcount Hmario_queue Hmario_count
    Hanimation_image Hcache_image Hsound_image Hfour Hfour_anchors.
  pose proof (generated_slide_animation_setter_cache_hit_us_jp version ge m0 mario object
    list target frame loop_end table source base entries entry_offset size cache_code caller
    Hanimation_layout Hcache_layout Hcache_symbol Hcache_code Hanimation_image Hcache_image)
    as Hanimation.
  pose proof (generated_slide_animation_not_at_end_us_jp version ge m0 mario object
    list target frame loop_end caller Hanimation_layout Hanimation_image) as Hend.
  destruct (generated_sound_request_executes_and_frames_us_jp version ge m7 queue count index
    (Int.repr 335544321) object (Ptrofs.repr 84) Hsound_layout Hqueue Hcount Hsound_image)
    as [q1 [q2 [m8 [Hstores [Hsound Hsound_frame]]]]].
  destruct Hfour as [Hinput [Hsliding [Hground [Hreflection [Hflags [Hstars [Haction
    [Hterrain [Hobject [Hstars_m7 Hwrite]]]]]]]]]].
  pose proof Hstores as [Hq1 [Hq2 Hq3]].
  destruct (Mem.valid_access_store m8 Mint32 mario 8 (Vint (Int.repr 3))
    ltac:(cog_memory_access)) as [m9 Hdust].
  assert (Hstars_m8 : Mem.load Mint32 m8 mario 8 = Some (Vint (Int.repr 2))).
  { rewrite Hsound_frame by assumption. exact Hstars_m7. }
  assert (Hpath : slide_helper_path version ge m0 m0 m0 m3 m4 m5 m6 m7 m8 m9 mario object).
  { unfold slide_helper_path. repeat apply conj; try assumption.
    eexists. exact Hanimation. }
  assert (Hanchors : slide_helpers_preserve_anchor mario m0 m0 m0 m3 m4 m5 m6 m7 m8).
  { destruct Hfour_anchors as [H3 [H4 [H5 H7]]].
    unfold slide_helpers_preserve_anchor. repeat apply conj; try reflexivity; try assumption.
    eapply sound_request_stores_preserve_anchor; eassumption. }
  destruct (generated_slide_kick_dust_caller_with_anchor_boundaries_us_jp version
    ge m0 m0 m0 m3 m4 m5 m6 m7 m8 m9 mario object animation animation_end sliding ground
    reflection action sound caller Hbindings Hpath Hanchors) as [Hcall [Hparticles Hanchor]].
  exists m8, m9. repeat apply conj; assumption.
Qed.
