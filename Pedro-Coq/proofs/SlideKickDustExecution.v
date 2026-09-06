From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import
  us_mario_actions_moving jp_mario_actions_moving
  us_mario jp_mario us_mario_step jp_mario_step
  us_audio_external jp_audio_external.
From Pedro.Proofs Require Import GameTypes ASTFacts TTCCogExecution.

Import ListNotations.
Open Scope Z_scope.
Module SK := us_mario_actions_moving.

(** This is a caller execution, not a reachable cog-Pedro witness. The seven
    helper executions below are residuals over the actual generated functions.
    In particular, the real collision query, sliding update, animation state,
    and complete frame still have to be supplied. No helper is replaced by a
    newly invented implementation. *)
Definition slide_kick_function (version : GameVersion) : function :=
  match version with
  | VersionUS => SK.f_act_slide_kick_slide
  | VersionJP => jp_mario_actions_moving.f_act_slide_kick_slide
  end.

Definition slide_animation_function (version : GameVersion) : function :=
  match version with VersionUS => us_mario.f_set_mario_animation
                   | VersionJP => jp_mario.f_set_mario_animation end.
Definition slide_animation_end_function (version : GameVersion) : function :=
  match version with VersionUS => us_mario.f_is_anim_at_end
                   | VersionJP => jp_mario.f_is_anim_at_end end.
Definition slide_update_function (version : GameVersion) : function :=
  match version with VersionUS => SK.f_update_sliding
                   | VersionJP => jp_mario_actions_moving.f_update_sliding end.
Definition slide_ground_function (version : GameVersion) : function :=
  match version with VersionUS => us_mario_step.f_perform_ground_step
                   | VersionJP => jp_mario_step.f_perform_ground_step end.
Definition slide_reflection_function (version : GameVersion) : function :=
  match version with VersionUS => us_mario_step.f_mario_bonk_reflection
                   | VersionJP => jp_mario_step.f_mario_bonk_reflection end.
Definition slide_action_function (version : GameVersion) : function :=
  match version with VersionUS => us_mario.f_set_mario_action
                   | VersionJP => jp_mario.f_set_mario_action end.
Definition slide_sound_function (version : GameVersion) : function :=
  match version with VersionUS => us_audio_external.f_play_sound
                   | VersionJP => jp_audio_external.f_play_sound end.

Theorem slide_kick_caller_identical_us_jp :
  SK.f_act_slide_kick_slide =
    jp_mario_actions_moving.f_act_slide_kick_slide.
Proof. reflexivity. Qed.

Record slide_caller_layout (ge : Clight.genv) : Type := {
  slide_mario_co : composite;
  slide_object_co : composite;
  slide_node_co : composite;
  slide_gfx_co : composite;
  slide_mario_layout : (genv_cenv ge) ! SK._MarioState = Some slide_mario_co;
  slide_input_offset : field_offset (genv_cenv ge) SK._input
    (co_members slide_mario_co) = OK (2, Full);
  slide_particles_offset : field_offset (genv_cenv ge) SK._particleFlags
    (co_members slide_mario_co) = OK (8, Full);
  slide_terrain_offset : field_offset (genv_cenv ge) SK._terrainSoundAddend
    (co_members slide_mario_co) = OK (20, Full);
  slide_object_offset : field_offset (genv_cenv ge) SK._marioObj
    (co_members slide_mario_co) = OK (136, Full);
  slide_position_offset : field_offset (genv_cenv ge) SK._pos
    (co_members slide_mario_co) = OK (60, Full);
  slide_floor_offset : field_offset (genv_cenv ge) SK._floor
    (co_members slide_mario_co) = OK (104, Full);
  slide_floor_height_offset : field_offset (genv_cenv ge) SK._floorHeight
    (co_members slide_mario_co) = OK (112, Full);
  slide_object_layout : (genv_cenv ge) ! SK._Object = Some slide_object_co;
  slide_header_offset : field_offset (genv_cenv ge) SK._header
    (co_members slide_object_co) = OK (0, Full);
  slide_node_layout : (genv_cenv ge) ! SK._ObjectNode = Some slide_node_co;
  slide_gfx_offset : field_offset (genv_cenv ge) SK._gfx
    (co_members slide_node_co) = OK (0, Full);
  slide_gfx_layout : (genv_cenv ge) ! SK._GraphNodeObject = Some slide_gfx_co;
  slide_camera_offset : field_offset (genv_cenv ge) SK._cameraToObject
    (co_members slide_gfx_co) = OK (84, Full)
}.

Definition slide_bindings (version : GameVersion) (ge : Clight.genv)
    (animation animation_end sliding ground reflection action sound : block)
    : Prop :=
  Genv.find_symbol ge SK._set_mario_animation = Some animation /\
  Genv.find_funct_ptr ge animation = Some (Internal (slide_animation_function version)) /\
  Genv.find_symbol ge SK._is_anim_at_end = Some animation_end /\
  Genv.find_funct_ptr ge animation_end = Some (Internal (slide_animation_end_function version)) /\
  Genv.find_symbol ge SK._update_sliding = Some sliding /\
  Genv.find_funct_ptr ge sliding = Some (Internal (slide_update_function version)) /\
  Genv.find_symbol ge SK._perform_ground_step = Some ground /\
  Genv.find_funct_ptr ge ground = Some (Internal (slide_ground_function version)) /\
  Genv.find_symbol ge SK._mario_bonk_reflection = Some reflection /\
  Genv.find_funct_ptr ge reflection = Some (Internal (slide_reflection_function version)) /\
  Genv.find_symbol ge SK._set_mario_action = Some action /\
  Genv.find_funct_ptr ge action = Some (Internal (slide_action_function version)) /\
  Genv.find_symbol ge SK._play_sound = Some sound /\
  Genv.find_funct_ptr ge sound = Some (Internal (slide_sound_function version)).

(** The intermediate memories are ordered exactly as the generated caller.
    m6 and m9 are its own star/dust assignments; the other changes belong to
    the named callees, whose executions remain explicit. INPUT_OFF_FLOOR=4
    is present at entry. This does not assume that the landing-dust body ran. *)
Definition slide_helper_path (version : GameVersion) (ge : Clight.genv)
    (m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 : mem) (mario object : block) : Prop :=
  Mem.load Mint16unsigned m0 mario 2 = Some (Vint (Int.repr 4)) /\
  (exists animation_result,
    eval_funcall function_entry2 ge m0 (Internal (slide_animation_function version))
      [Vptr mario Ptrofs.zero; Vint (Int.repr 140)] E0 m1 animation_result) /\
  eval_funcall function_entry2 ge m1 (Internal (slide_animation_end_function version))
    [Vptr mario Ptrofs.zero] E0 m2 (Vint Int.zero) /\
  (exists sliding_result,
    eval_funcall function_entry2 ge m2 (Internal (slide_update_function version))
      [Vptr mario Ptrofs.zero; Vsingle (Float32.of_bits (Int.repr 1065353216))]
      E0 m3 sliding_result) /\
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
  eval_funcall function_entry2 ge m7 (Internal (slide_sound_function version))
    [Vint (Int.repr 335544321); Vptr object (Ptrofs.repr 84)] E0 m8 Vundef /\
  Mem.load Mint32 m8 mario 8 = Some (Vint (Int.repr 2)) /\
  Mem.store Mint32 m8 mario 8 (Vint (Int.repr 3)) = Some m9.

Ltac slide_expr :=
  first [solve [cog_expr] |
    match goal with |- ?G => idtac "SLIDE EXPRESSION:" G end; fail 100].
Ltac slide_check tac :=
  first [solve [tac] |
    match goal with |- ?G => idtac "SLIDE ATOMIC:" G end; fail 100].

Ltac slide_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
             [slide_stmt | slide_stmt]
            |eapply exec_Sseq_2; [slide_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; slide_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [cog_lvalue | slide_expr | cbn; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [slide_expr | cbn; reflexivity | cog_reduce_statement; slide_stmt]
  | |- exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ =>
      eapply exec_Sswitch with (out := Out_break) (n := 2);
      [slide_expr | cbn; reflexivity | cog_reduce_statement; slide_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; slide_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | slide_expr | slide_check cog_arguments |
       slide_check ltac:(eapply cog_find_funct_zero; eassumption) |
       reflexivity | slide_check ltac:(eassumption)]
  end.

Definition slide_kick_blocked_caller_claim (version : GameVersion) : Prop :=
  forall (ge : Clight.genv) m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object
      animation animation_end sliding ground reflection action sound,
    slide_caller_layout ge ->
    slide_bindings version ge animation animation_end sliding ground reflection action sound ->
    slide_helper_path version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object ->
    eval_funcall function_entry2 ge m0 (Internal (slide_kick_function version))
      [Vptr mario Ptrofs.zero] E0 m9 (Vint Int.zero) /\
    Mem.load Mint32 m9 mario 8 = Some (Vint (Int.repr 3)).

Theorem generated_slide_kick_blocked_caller_requests_dust_us_jp :
  forall version, slide_kick_blocked_caller_claim version.
Proof.
  intros version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object
    animation animation_end sliding ground reflection action sound Hlayout Hbindings Hpath.
  destruct Hlayout.
  unfold slide_bindings in Hbindings. destruct Hbindings as
    [Ha [Haf [He [Hef [Hu [Huf [Hg [Hgf [Hr [Hrf [Hac [Hacf [Hs Hsf]]]]]]]]]]]]].
  unfold slide_helper_path in Hpath. destruct Hpath as
    [Hinput [Hanimation [Hend [Hupdate [Hground [Hreflection [Hflags
     [Hstars [Haction [Hterrain [Hobject [Hsound [Hstars_after Hdust]]]]]]]]]]]]].
  destruct Hanimation as [animation_result Hanimation].
  destruct Hupdate as [sliding_result Hupdate].
  split.
  - destruct version;
      cbn [slide_kick_function slide_animation_function slide_animation_end_function
        slide_update_function slide_ground_function slide_reflection_function
        slide_action_function slide_sound_function] in *.
    all: eapply eval_funcall_internal.
    1,5: eapply function_entry2_intro;
      [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
       vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
       cbn; apply alloc_variables_nil | cbn; reflexivity].
    1,4: simpl fn_body; slide_stmt.
    1,3: cbn; split; [discriminate | reflexivity].
    all: cbn; reflexivity.
  - rewrite (Mem.load_store_same _ _ _ _ _ _ Hdust). reflexivity.
Qed.

(** The numeric field offsets used above are checked against the generated
    composite environment, independently in US and JP. *)
Definition slide_generated_cenv (version : GameVersion) : composite_env :=
  prog_comp_env
    (match version with VersionUS => SK.prog
                        | VersionJP => jp_mario_actions_moving.prog end).

Definition slide_layout_offsets (version : GameVersion) : list (res (Z * bitfield)) :=
  let ce := slide_generated_cenv version in
  map (fun item => field_offset ce (snd item)
    (match ce ! (fst item) with Some co => co_members co | None => [] end))
    [(SK._MarioState,SK._input); (SK._MarioState,SK._particleFlags);
     (SK._MarioState,SK._terrainSoundAddend); (SK._MarioState,SK._marioObj);
     (SK._Object,SK._header); (SK._ObjectNode,SK._gfx);
     (SK._GraphNodeObject,SK._cameraToObject);
     (SK._MarioState,SK._pos); (SK._MarioState,SK._floor);
     (SK._MarioState,SK._floorHeight)].

Definition slide_layout_receipt : Prop :=
  forall version, slide_layout_offsets version =
    map (fun offset => OK (offset, Full)) [2;8;20;136;0;0;84;60;104;112].

Theorem slide_caller_and_anchor_offsets_generated_us_jp : slide_layout_receipt.
Proof. intros []; vm_compute; reflexivity. Qed.

Definition slide_anchor (memory : mem) (mario : block) : list (option val) :=
  [Mem.load Mfloat32 memory mario 60;
   Mem.load Mfloat32 memory mario 64;
   Mem.load Mfloat32 memory mario 68;
   Mem.load Mptr memory mario 104;
   Mem.load Mfloat32 memory mario 112].

Lemma slide_particle_store_preserves_anchor :
  forall before after mario flags,
    Mem.store Mint32 before mario 8 (Vint flags) = Some after ->
    slide_anchor after mario = slide_anchor before mario.
Proof.
  intros before after mario flags Hstore. unfold slide_anchor.
  repeat rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore)
    by (right; right; cbn; lia).
  reflexivity.
Qed.

(** This conditional frame rule covers the caller's seven callee boundaries
    and its two own stores. It does not assert preservation INSIDE the
    callee executions or across another game update. *)
Definition slide_helpers_preserve_anchor mario m0 m1 m2 m3 m4 m5 m6 m7 m8 : Prop :=
  slide_anchor m1 mario = slide_anchor m0 mario /\
  slide_anchor m2 mario = slide_anchor m1 mario /\
  slide_anchor m3 mario = slide_anchor m2 mario /\
  slide_anchor m4 mario = slide_anchor m3 mario /\
  slide_anchor m5 mario = slide_anchor m4 mario /\
  slide_anchor m7 mario = slide_anchor m6 mario /\
  slide_anchor m8 mario = slide_anchor m7 mario.

Theorem slide_caller_own_stores_do_not_displace_mario :
  forall version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object,
    slide_helper_path version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object ->
    slide_helpers_preserve_anchor mario m0 m1 m2 m3 m4 m5 m6 m7 m8 ->
    map (fun m => slide_anchor m mario) [m0;m1;m2;m3;m4;m5;m6;m7;m8;m9] =
      repeat (slide_anchor m0 mario) 10.
Proof.
  intros version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object Hpath Hpreserve.
  unfold slide_helper_path in Hpath. destruct Hpath as
    [_ [_ [_ [_ [_ [_ [_ [Hstars [_ [_ [_ [_ [_ Hdust]]]]]]]]]]]]].
  pose proof (slide_particle_store_preserves_anchor _ _ _ _ Hstars) as H6.
  pose proof (slide_particle_store_preserves_anchor _ _ _ _ Hdust) as H9.
  unfold slide_helpers_preserve_anchor in Hpreserve.
  destruct Hpreserve as [H1 [H2 [H3 [H4 [H5 [H7 H8]]]]]].
  cbn [map repeat]. congruence.
Qed.

Definition slide_kick_framed_caller_claim (version : GameVersion) : Prop :=
  forall (ge : Clight.genv) m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object
      animation animation_end sliding ground reflection action sound,
    slide_caller_layout ge ->
    slide_bindings version ge animation animation_end sliding ground reflection action sound ->
    slide_helper_path version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object ->
    slide_helpers_preserve_anchor mario m0 m1 m2 m3 m4 m5 m6 m7 m8 ->
    eval_funcall function_entry2 ge m0 (Internal (slide_kick_function version))
      [Vptr mario Ptrofs.zero] E0 m9 (Vint Int.zero) /\
    Mem.load Mint32 m9 mario 8 = Some (Vint (Int.repr 3)) /\
    map (fun m => slide_anchor m mario) [m0;m1;m2;m3;m4;m5;m6;m7;m8;m9] =
      repeat (slide_anchor m0 mario) 10.

Theorem generated_slide_kick_dust_caller_with_anchor_boundaries_us_jp :
  forall version, slide_kick_framed_caller_claim version.
Proof.
  intros version ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object
    animation animation_end sliding ground reflection action sound
    Hlayout Hbindings Hpath Hanchors.
  destruct (generated_slide_kick_blocked_caller_requests_dust_us_jp version
    ge m0 m1 m2 m3 m4 m5 m6 m7 m8 m9 mario object
    animation animation_end sliding ground reflection action sound
    Hlayout Hbindings Hpath) as [Hcall Hflags].
  refine (conj Hcall (conj Hflags _)).
  eapply slide_caller_own_stores_do_not_displace_mario;
    [exact Hpath | exact Hanchors].
Qed.
