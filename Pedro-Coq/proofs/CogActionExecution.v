From Coq Require Import Lia List ZArith.
From compcert Require Import Archi AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import us_mario jp_mario.
From Pedro.Proofs Require Import GameTypes TTCCogExecution SlideKickDustExecution.
Import ListNotations.
Open Scope Z_scope.
Module CA := us_mario.

Definition cog_floor_class_function version : function :=
  match version with VersionUS => CA.f_mario_get_floor_class
                   | VersionJP => jp_mario.f_mario_get_floor_class end.
Definition cog_moving_transition_function version : function :=
  match version with VersionUS => CA.f_set_mario_action_moving
                   | VersionJP => jp_mario.f_set_mario_action_moving end.
Definition cog_terrain_function version : function :=
  match version with VersionUS => CA.f_mario_get_terrain_sound_addend
                   | VersionJP => jp_mario.f_mario_get_terrain_sound_addend end.

Record cog_action_layout (ge : Clight.genv) (caller : slide_caller_layout ge) : Type := {
  action_area_co : composite;
  action_surface_co : composite;
  action_area_lookup : (genv_cenv ge) ! CA._Area = Some action_area_co;
  action_surface_lookup : (genv_cenv ge) ! CA._Surface = Some action_surface_co;
  action_area_offset : field_offset (genv_cenv ge) CA._area
    (co_members (slide_mario_co ge caller)) = OK (144, Full);
  action_flags_offset : field_offset (genv_cenv ge) CA._flags
    (co_members (slide_mario_co ge caller)) = OK (4, Full);
  action_action_offset : field_offset (genv_cenv ge) CA._action
    (co_members (slide_mario_co ge caller)) = OK (12, Full);
  action_prev_offset : field_offset (genv_cenv ge) CA._prevAction
    (co_members (slide_mario_co ge caller)) = OK (16, Full);
  action_state_offset : field_offset (genv_cenv ge) CA._actionState
    (co_members (slide_mario_co ge caller)) = OK (24, Full);
  action_timer_offset : field_offset (genv_cenv ge) CA._actionTimer
    (co_members (slide_mario_co ge caller)) = OK (26, Full);
  action_arg_offset : field_offset (genv_cenv ge) CA._actionArg
    (co_members (slide_mario_co ge caller)) = OK (28, Full);
  action_mag_offset : field_offset (genv_cenv ge) CA._intendedMag
    (co_members (slide_mario_co ge caller)) = OK (32, Full);
  action_speed_offset : field_offset (genv_cenv ge) CA._forwardVel
    (co_members (slide_mario_co ge caller)) = OK (84, Full);
  action_water_offset : field_offset (genv_cenv ge) CA._waterLevel
    (co_members (slide_mario_co ge caller)) = OK (118, Full);
  action_terrain_type_offset : field_offset (genv_cenv ge) CA._terrainType
    (co_members action_area_co) = OK (2, Full);
  action_surface_type_offset : field_offset (genv_cenv ge) CA._type
    (co_members action_surface_co) = OK (0, Full)
}.

(** Ordinary TTC terrain and retained default floor. This is an entry memory
    image, not a reachability or collision-selection assertion. *)
Definition cog_default_floor_image memory mario area floor : Prop :=
  Mem.load Mptr memory mario 144 = Some (Vptr area Ptrofs.zero) /\
  Mem.load Mint16unsigned memory area 2 = Some (Vint Int.one) /\
  Mem.load Mptr memory mario 104 = Some (Vptr floor Ptrofs.zero) /\
  Mem.load Mint16signed memory floor 0 = Some (Vint Int.zero) /\
  Mem.load Mint32 memory mario 12 = Some (Vint (Int.repr 8389722)).

Lemma cog_readable_floor_is_valid : forall memory floor value,
  Mem.load Mint16signed memory floor 0 = Some value ->
  Mem.weak_valid_pointer memory floor 0 = true.
Proof.
  intros memory floor value Hload.
  pose proof (Mem.load_valid_access _ _ _ _ _ Hload) as [Hrange Halign].
  apply Mem.valid_pointer_implies. apply Mem.valid_pointer_nonempty_perm.
  eapply Mem.perm_implies; [apply Hrange; cbn; lia | constructor].
Qed.

Lemma cog_surface_nonnull : forall ce memory b,
  Mem.weak_valid_pointer memory b 0 = true ->
  sem_binary_operation ce One (Vptr b Ptrofs.zero)
    (tptr (Tstruct CA._Surface noattr)) (Vint Int.zero) (tptr tvoid) memory =
    Some (Vint Int.one).
Proof.
  intros ce memory b Hvalid.
  assert (H32 : Archi.ptr64 = false) by reflexivity.
  assert (Hzero : Ptrofs.unsigned Ptrofs.zero = 0) by reflexivity.
  cbn. unfold cmp_ptr. rewrite H32. cbn [Val.cmpu_bool].
  rewrite H32, Int.eq_true. cbn.
  rewrite Hzero. fold (Mem.weak_valid_pointer memory b 0).
  rewrite Hvalid. reflexivity.
Qed.

Lemma cog_dry_floor_comparison : forall ce memory height water,
  Float32.cmp Clt height (Float32.of_int (Int.sub water (Int.repr 10))) = false ->
  sem_binary_operation ce Olt (Vsingle height) tfloat
    (Vint (Int.sub water (Int.repr 10))) tint memory = Some (Vint Int.zero).
Proof.
  intros ce memory height water Hdry.
  change (Some (Val.of_bool
    (Float32.cmp Clt height (Float32.of_int (Int.sub water (Int.repr 10))))) =
    Some (Vint Int.zero)).
  rewrite Hdry. reflexivity.
Qed.

Ltac action_normalize :=
  first [solve [eapply cog_surface_nonnull; eassumption] |
    solve [eapply cog_dry_floor_comparison; eassumption] |
    solve [cbn; reflexivity] |
    match goal with |- ?G => idtac "ACTION OPERATION" G end; fail 100].
Ltac action_check tac :=
  first [solve [tac] | match goal with |- ?G => idtac "ACTION ATOMIC" G end; fail 100].
Ltac action_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [action_expr | action_expr | action_normalize]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [action_expr | action_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [action_expr | action_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [action_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; action_check cog_memory_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with action_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; action_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct; [action_expr | reflexivity | eassumption | eassumption]
  end.
Ltac action_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [action_expr | cbn; reflexivity | action_arguments]].
Ltac action_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [action_stmt | action_stmt]
            |eapply exec_Sseq_2; [action_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; action_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [action_lvalue | action_expr | cbn; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [action_expr | action_check ltac:(cbn; reflexivity) | cog_reduce_statement; action_stmt]
  | |- exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ =>
      first [eapply exec_Sswitch with (out := Out_normal);
        [action_expr | cbn; reflexivity | cog_reduce_statement; action_stmt] |
        eapply exec_Sswitch with (out := Out_break);
        [action_expr | cbn; reflexivity | cog_reduce_statement; action_stmt]]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; action_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | action_expr | action_arguments |
       eapply cog_find_funct_zero; eassumption | reflexivity | eassumption]
  end.
Ltac action_entry :=
  eapply function_entry2_intro;
  [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
   vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
   cbn; apply alloc_variables_nil | cbn; reflexivity].

Theorem generated_cog_default_floor_class_us_jp :
  forall version ge memory mario area floor (caller : slide_caller_layout ge),
    cog_action_layout ge caller ->
    cog_default_floor_image memory mario area floor ->
    eval_funcall function_entry2 ge memory (Internal (cog_floor_class_function version))
      [Vptr mario Ptrofs.zero] E0 memory (Vint Int.zero).
Proof.
  intros version ge memory mario area floor caller Hlayout Himage.
  destruct Hlayout; destruct caller; cbn in *.
  destruct Himage as [Ha [Ht [Hf [Hft Hact]]]].
  pose proof (cog_readable_floor_is_valid _ _ _ Hft) as Hvalid.
  destruct version; cbn [cog_floor_class_function]; eapply eval_funcall_internal;
    [action_entry | simpl fn_body; timeout 10 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity |
     action_entry | simpl fn_body; timeout 10 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity].
Qed.

Theorem generated_cog_moving_kb_transition_us_jp :
  forall version ge memory mario area floor speed floor_code (caller : slide_caller_layout ge),
    cog_action_layout ge caller ->
    cog_default_floor_image memory mario area floor ->
    Mem.load Mfloat32 memory mario 84 = Some (Vsingle speed) ->
    Mem.load Mfloat32 memory mario 32 = Some (Vsingle Float32.zero) ->
    Genv.find_symbol ge CA._mario_get_floor_class = Some floor_code ->
    Genv.find_funct_ptr ge floor_code = Some (Internal (cog_floor_class_function version)) ->
    eval_funcall function_entry2 ge memory (Internal (cog_moving_transition_function version))
      [Vptr mario Ptrofs.zero; Vint (Int.repr 132194); Vint Int.zero]
      E0 memory (Vint (Int.repr 132194)).
Proof.
  intros version ge memory mario area floor speed floor_code caller Hlayout Himage
    Hspeed Hmag Hsymbol Hcode.
  pose proof (generated_cog_default_floor_class_us_jp version ge memory mario area floor
    caller Hlayout Himage) as Hfloor.
  destruct Hlayout; destruct caller; cbn in *.
  destruct version; cbn [cog_moving_transition_function]; eapply eval_funcall_internal;
    [action_entry | simpl fn_body; timeout 10 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity |
     action_entry | simpl fn_body; timeout 10 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity].
Qed.

Definition kb_sound_flags flags : int :=
  Int.and flags (Int.not (Int.or (Int.repr 65536) (Int.repr 131072))).
Definition kb_entry_flags flags : int :=
  Int.and (kb_sound_flags flags) (Int.not (Int.repr 262144)).

Definition cog_kb_transition_stores before m1 m2 m3 m4 m5 m6 after mario flags : Prop :=
  Mem.store Mint32 before mario 4 (Vint (kb_sound_flags flags)) = Some m1 /\
  Mem.store Mint32 m1 mario 4 (Vint (kb_entry_flags flags)) = Some m2 /\
  Mem.store Mint32 m2 mario 16 (Vint (Int.repr 8389722)) = Some m3 /\
  Mem.store Mint32 m3 mario 12 (Vint (Int.repr 132194)) = Some m4 /\
  Mem.store Mint32 m4 mario 28 (Vint Int.zero) = Some m5 /\
  Mem.store Mint16unsigned m5 mario 24 (Vint Int.zero) = Some m6 /\
  Mem.store Mint16unsigned m6 mario 26 (Vint Int.zero) = Some after.

Definition cog_kb_writable memory mario : Prop :=
  Mem.valid_access memory Mint32 mario 4 Writable /\
  Mem.valid_access memory Mint32 mario 16 Writable /\
  Mem.valid_access memory Mint32 mario 12 Writable /\
  Mem.valid_access memory Mint32 mario 28 Writable /\
  Mem.valid_access memory Mint16unsigned mario 24 Writable /\
  Mem.valid_access memory Mint16unsigned mario 26 Writable.

(** Executes both real nested helpers and all seven stores of set_mario_action.
    Neither a callee execution nor a position/floor preservation equation is
    an input to this theorem. *)
Theorem generated_cog_kb_transition_with_stores_us_jp :
  forall version ge before m1 m2 m3 m4 m5 m6 after mario area floor speed flags
      floor_code moving_code (caller : slide_caller_layout ge),
    cog_action_layout ge caller ->
    cog_default_floor_image before mario area floor ->
    Mem.load Mfloat32 before mario 84 = Some (Vsingle speed) ->
    Mem.load Mfloat32 before mario 32 = Some (Vsingle Float32.zero) ->
    Mem.load Mint32 before mario 4 = Some (Vint flags) ->
    Genv.find_symbol ge CA._mario_get_floor_class = Some floor_code ->
    Genv.find_funct_ptr ge floor_code = Some (Internal (cog_floor_class_function version)) ->
    Genv.find_symbol ge CA._set_mario_action_moving = Some moving_code ->
    Genv.find_funct_ptr ge moving_code = Some (Internal (cog_moving_transition_function version)) ->
    cog_kb_transition_stores before m1 m2 m3 m4 m5 m6 after mario flags ->
    eval_funcall function_entry2 ge before (Internal (slide_action_function version))
      [Vptr mario Ptrofs.zero; Vint (Int.repr 132194); Vint Int.zero]
      E0 after (Vint Int.one).
Proof.
  intros version ge before m1 m2 m3 m4 m5 m6 after mario area floor speed flags
    floor_code moving_code caller Hlayout Himage Hspeed Hmag Hflags Hfloor_symbol Hfloor_code
    Hmoving_symbol Hmoving_code Hstores.
  pose proof (generated_cog_moving_kb_transition_us_jp version ge before mario area floor
    speed floor_code caller Hlayout Himage Hspeed Hmag Hfloor_symbol Hfloor_code) as Hmoving.
  destruct Himage as [Ha [Ht [Hf [Hft Hact]]]].
  destruct Hstores as [Hs1 [Hs2 [Hs3 [Hs4 [Hs5 [Hs6 Hs7]]]]]].
  destruct Hlayout; destruct caller; cbn in *.
  destruct version; cbn [slide_action_function]; eapply eval_funcall_internal;
    [action_entry | simpl fn_body; timeout 15 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity |
     action_entry | simpl fn_body; timeout 15 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity].
Qed.

Definition cog_kb_untouched (mario b : block) chunk offset : Prop :=
  b <> mario \/ offset + size_chunk chunk <= 4 \/ 32 <= offset \/
  (8 <= offset /\ offset + size_chunk chunk <= 12) \/
  (20 <= offset /\ offset + size_chunk chunk <= 24).

Lemma cog_kb_transition_frame :
  forall before m1 m2 m3 m4 m5 m6 after mario flags,
    cog_kb_transition_stores before m1 m2 m3 m4 m5 m6 after mario flags ->
    forall chunk b offset, cog_kb_untouched mario b chunk offset ->
      Mem.load chunk after b offset = Mem.load chunk before b offset.
Proof.
  intros before m1 m2 m3 m4 m5 m6 after mario flags
    [Hs1 [Hs2 [Hs3 [Hs4 [Hs5 [Hs6 Hs7]]]]]] chunk b offset Hsafe.
  unfold cog_kb_untouched in Hsafe.
  repeat match goal with
  | H : Mem.store _ _ _ _ _ = Some ?out |- Mem.load _ ?out _ _ = _ =>
      rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (cbn; intuition lia)
  end. reflexivity.
Qed.

Lemma cog_kb_transition_anchor :
  forall before m1 m2 m3 m4 m5 m6 after mario flags,
    cog_kb_transition_stores before m1 m2 m3 m4 m5 m6 after mario flags ->
    slide_anchor after mario = slide_anchor before mario.
Proof.
  intros before m1 m2 m3 m4 m5 m6 after mario flags Hstores.
  unfold slide_anchor.
  repeat rewrite (cog_kb_transition_frame _ _ _ _ _ _ _ _ _ _ Hstores)
    by (unfold cog_kb_untouched; cbn; intuition lia).
  reflexivity.
Qed.

Theorem generated_cog_kb_transition_executes_and_frames_us_jp :
  forall version ge before mario area floor speed flags floor_code moving_code
      (caller : slide_caller_layout ge),
    cog_action_layout ge caller ->
    cog_default_floor_image before mario area floor ->
    Mem.load Mfloat32 before mario 84 = Some (Vsingle speed) ->
    Mem.load Mfloat32 before mario 32 = Some (Vsingle Float32.zero) ->
    Mem.load Mint32 before mario 4 = Some (Vint flags) ->
    cog_kb_writable before mario ->
    Genv.find_symbol ge CA._mario_get_floor_class = Some floor_code ->
    Genv.find_funct_ptr ge floor_code = Some (Internal (cog_floor_class_function version)) ->
    Genv.find_symbol ge CA._set_mario_action_moving = Some moving_code ->
    Genv.find_funct_ptr ge moving_code = Some (Internal (cog_moving_transition_function version)) ->
    exists m1 m2 m3 m4 m5 m6 after,
      cog_kb_transition_stores before m1 m2 m3 m4 m5 m6 after mario flags /\
      eval_funcall function_entry2 ge before (Internal (slide_action_function version))
        [Vptr mario Ptrofs.zero; Vint (Int.repr 132194); Vint Int.zero]
        E0 after (Vint Int.one) /\
      slide_anchor after mario = slide_anchor before mario /\
      Mem.load Mint32 after mario 12 = Some (Vint (Int.repr 132194)) /\
      Mem.load Mint32 after mario 16 = Some (Vint (Int.repr 8389722)) /\
      Mem.load Mint32 after mario 28 = Some (Vint Int.zero) /\
      Mem.load Mint16unsigned after mario 24 = Some (Vint Int.zero) /\
      Mem.load Mint16unsigned after mario 26 = Some (Vint Int.zero) /\
      (forall chunk b offset, cog_kb_untouched mario b chunk offset ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros version ge before mario area floor speed flags floor_code moving_code caller
    Hlayout Himage Hspeed Hmag Hflags Hwrite Hfs Hfc Hms Hmc.
  destruct Hwrite as [Hw1 [Hw2 [Hw3 [Hw4 [Hw5 Hw6]]]]].
  destruct (Mem.valid_access_store before Mint32 mario 4 (Vint (kb_sound_flags flags))
    ltac:(cog_memory_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint32 mario 4 (Vint (kb_entry_flags flags))
    ltac:(cog_memory_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint32 mario 16 (Vint (Int.repr 8389722))
    ltac:(cog_memory_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint32 mario 12 (Vint (Int.repr 132194))
    ltac:(cog_memory_access)) as [m4 Hs4].
  destruct (Mem.valid_access_store m4 Mint32 mario 28 (Vint Int.zero)
    ltac:(cog_memory_access)) as [m5 Hs5].
  destruct (Mem.valid_access_store m5 Mint16unsigned mario 24 (Vint Int.zero)
    ltac:(cog_memory_access)) as [m6 Hs6].
  destruct (Mem.valid_access_store m6 Mint16unsigned mario 26 (Vint Int.zero)
    ltac:(cog_memory_access)) as [after Hs7].
  assert (Hstores : cog_kb_transition_stores before m1 m2 m3 m4 m5 m6 after mario flags)
    by (repeat split; assumption).
  exists m1, m2, m3, m4, m5, m6, after. split; [exact Hstores |].
  split; [eapply generated_cog_kb_transition_with_stores_us_jp; eassumption |].
  split; [eapply cog_kb_transition_anchor; eassumption |].
  repeat apply conj; try solve [cog_memory_load].
  exact (cog_kb_transition_frame _ _ _ _ _ _ _ _ _ _ Hstores).
Qed.

(** Dry TTC/default-floor branch: TERRAIN_STONE is terrain row 1, but the
    row's default sound is SOUND_TERRAIN_STONE = 3, not 0 or 1. *)
Definition cog_terrain_execution_claim version : Prop :=
  forall ge memory mario area floor level table height water
      (caller : slide_caller_layout ge),
    cog_action_layout ge caller ->
    cog_default_floor_image memory mario area floor ->
    Genv.find_symbol ge CA._gCurrLevelNum = Some level ->
    Genv.find_symbol ge CA._sTerrainSounds = Some table ->
    Mem.load Mint16signed memory level 0 = Some (Vint (Int.repr 14)) ->
    Mem.load Mfloat32 memory mario 112 = Some (Vsingle height) ->
    Mem.load Mint16signed memory mario 118 = Some (Vint water) ->
    Float32.cmp Clt height (Float32.of_int (Int.sub water (Int.repr 10))) = false ->
    Mem.load Mint8signed memory table 6 = Some (Vint (Int.repr 3)) ->
    eval_funcall function_entry2 ge memory (Internal (cog_terrain_function version))
      [Vptr mario Ptrofs.zero] E0 memory (Vint (Int.repr 196608)).

Theorem generated_cog_stone_terrain_addend_us_jp :
  forall version, cog_terrain_execution_claim version.
Proof.
  intros version ge memory mario area floor level table height water caller Hlayout
    Himage Hlevel Htable Hlevel_load Hheight Hwater Hdry Hsound.
  destruct Himage as [Ha [Ht [Hf [Hft Hact]]]].
  pose proof (cog_readable_floor_is_valid _ _ _ Hft) as Hvalid.
  destruct Hlayout; destruct caller; cbn in *.
  destruct version; cbn [cog_terrain_function]; eapply eval_funcall_internal;
    [action_entry | simpl fn_body; timeout 15 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity |
     action_entry | simpl fn_body; timeout 15 action_stmt |
     cbn; split; [discriminate | reflexivity] | cbn; reflexivity].
Qed.

Definition cog_action_layout_offsets version :=
  let ce := prog_comp_env
    (match version with VersionUS => CA.prog | VersionJP => jp_mario.prog end) in
  map (fun item => field_offset ce (snd item)
    (match ce ! (fst item) with Some co => co_members co | None => [] end))
    [(CA._MarioState,CA._area); (CA._MarioState,CA._flags);
     (CA._MarioState,CA._action); (CA._MarioState,CA._prevAction);
     (CA._MarioState,CA._actionState); (CA._MarioState,CA._actionTimer);
     (CA._MarioState,CA._actionArg); (CA._MarioState,CA._intendedMag);
     (CA._MarioState,CA._forwardVel); (CA._MarioState,CA._waterLevel);
     (CA._Area,CA._terrainType); (CA._Surface,CA._type)].

Definition cog_action_layout_receipt : Prop :=
  (forall version, cog_action_layout_offsets version =
    map (fun offset => OK (offset, Full)) [144;4;12;16;24;26;28;32;84;118;2;0]) /\
  nth_error (gvar_init CA.v_sTerrainSounds) 6 = Some (Init_int8 (Int.repr 3)) /\
  nth_error (gvar_init jp_mario.v_sTerrainSounds) 6 = Some (Init_int8 (Int.repr 3)).

Theorem cog_action_layout_generated_us_jp : cog_action_layout_receipt.
Proof.
  split; [intros []; vm_compute; reflexivity | split; reflexivity].
Qed.
