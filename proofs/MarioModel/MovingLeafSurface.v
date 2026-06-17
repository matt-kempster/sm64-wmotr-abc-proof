(* ====================================================================== *)
(* THE MOVING-FAMILY LEAF SURFACE                                          *)
(* (SPINE: moving_leaf_callees_pres shrinks the capstone's                 *)
(*  Hpres_mov_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* MovingSurface.moving_pres walks the 39-arm dispatcher and reduces it to *)
(* ONE residual: body_pres for every leaf callee in moving_callee_ids (39  *)
(* ids).  Here we discharge those leaves one cluster at a time, mirroring  *)
(* StationaryLeafSurface.v.                                                *)
(*                                                                         *)
(* SLICE M1 (this file's first cut): the KNOCKBACK cluster -- the 7        *)
(* ground-knockback leaves (act_{,soft_,hard_}{backward,forward}_ground_kb *)
(* + act_ground_bonk).  All bottom out in common_ground_knockback_action   *)
(* (consts all untainted) + the shared ground-physics helper subtree       *)
(* (apply_landing_accel / apply_slope_accel / mario_floor_is_slope /       *)
(* mario_get_floor_class / mario_set_forward_vel / mario_update_moving_sand *)
(* / mario_update_windy_ground) + perform_ground_step + audio externals.   *)
(* The remaining 32 leaves stay under the rest premise moving_rest_ids.    *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step
  mario_actions_airborne mario_actions_moving
  mario_actions_object interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface MovingSurface.
From SM64.Proofs Require Import MWFReal LandingBricks StationaryLeafSurface.
From SM64.Proofs Require Import LocalVarsSurface.

Import ListNotations.

(* alias + MarioState* notation for the landing-keystone leaf machinery *)
Module M := mario_actions_moving.
Local Notation tyMSp := (tptr (Tstruct M._MarioState noattr)).

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* set_mario_action with a vm-checkably untainted constant 2nd arg *)
Definition mov_sids : list ident := mario._set_mario_action :: nil.

(* the moving family's pure audio externals -- EF_external in every linked
   TU, write no Mario state: the honest model-boundary class (like the
   stationary sta_ext_ids / the obj_ext audio rows). *)
Definition mov_ext_ids : list ident :=
  mario_actions_moving._play_mario_heavy_landing_sound_once
    :: mario_actions_moving._play_sound_if_no_flag
    :: mario_actions_moving._play_mario_landing_sound_once
    :: mario_actions_moving._play_mario_landing_sound
    (* the float `approach` math builtin: EF_external in every TU, 4
       tfloat args, no Mario pointer -- the SAME honest pure-math model
       boundary as approach_s32 / sqrtf / atan2s. *)
    :: mario_actions_moving._approach_f32
    (* mtxf_align_terrain_triangle: EF_external in every TU (align_with_floor's
       terrain-matrix builtin).  Writes only the SafeB sFloorAlignMatrix global
       (floats, never a pointer) and reads m->pos -- touches NO bm/MWF-relevant
       state, so it is the SAME honest terminal-external boundary class.  Its
       call_pres_ext is consumed by align_with_floor_pres below. *)
    :: mario_actions_moving._mtxf_align_terrain_triangle :: nil.

(* set_mario_animation's chase temps + its load_patchable_table external *)
Definition mov_sma_cact : list ident :=
  mario._o :: mario._t'13 :: mario._t'12 :: mario._targetAnim :: nil.
Definition mov_sma_xids : list ident := mario._load_patchable_table :: nil.

(* apply_slope_accel's internal helper ids + its sqrtf external *)
Definition mov_asa_ids : list ident :=
  mario._mario_floor_is_slope :: mario._mario_get_floor_class
    :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground :: nil.
Definition mov_asa_xids : list ident := mario._sqrtf :: nil.

(* apply_landing_accel's internal helper ids *)
Definition mov_ala_ids : list ident :=
  mario_actions_moving._apply_slope_accel
    :: mario._mario_floor_is_slope :: mario._mario_set_forward_vel :: nil.

(* common_ground_knockback_action's internal ids + audio xids *)
Definition mov_cgka_ids : list ident :=
  mario_actions_moving._apply_landing_accel
    :: mario._is_anim_at_end :: mario._mario_set_forward_vel
    :: mario_step._perform_ground_step :: mario._set_mario_animation :: nil.
Definition mov_cgka_xids : list ident :=
  mario_actions_moving._play_mario_heavy_landing_sound_once
    :: mario_actions_moving._play_sound_if_no_flag :: nil.

(* each knockback leaf calls common_ground_knockback_action (call_pres) *)
Definition mov_cgka_only : list ident :=
  mario_actions_moving._common_ground_knockback_action :: nil.
Definition mov_hard_back_xids : list ident :=
  mario_actions_moving._play_mario_landing_sound_once :: mario._play_sound :: nil.
Definition mov_gbonk_xids : list ident :=
  mario_actions_moving._play_mario_landing_sound :: nil.

(* SLICE M2: act_death_exit_land -- the ONE landing-family leaf that does
   NOT route through common_landing_cancels (the AGates-blocked FTJ gate).
   Its callees are all already-proven rows: apply_landing_accel (mov_ala_row)
   + set_mario_animation (mov_sma_row) + is_anim_at_end (mov_iae_row), audio
   (play_sound obj_ext + play_mario_{heavy_,}landing_sound mov_ext), and
   set_mario_action with an untainted const (205521409 = ACT_DEATH_EXIT_LAND;
   the engine's wact_const gate confirms non-flying). *)
Definition mov_del_ids : list ident :=
  mario_actions_moving._apply_landing_accel
    :: mario._set_mario_animation :: mario._is_anim_at_end :: nil.
Definition mov_del_xids : list ident :=
  mario._play_sound
    :: mario_actions_moving._play_mario_heavy_landing_sound_once
    :: mario_actions_moving._play_mario_landing_sound :: nil.

(* SLICE M3: act_finish_turning_around -- the FIRST walking-cluster leaf.
   KEY: set_jumping_action is call_pres_act (it threads its _action arg to
   set_mario_action), NOT a param-action blocker -- so the leaf supplies an
   untainted const and set_jumping_action sits in the sids channel.  The
   set_jumping_action arc (mario_floor_is_steep -> mario_facing_downhill +
   mario_get_floor_class; set_steep_jump_action -> sqrtf/atan2s + drop_and_set
   _mario_action) is replicated from StationaryLeafSurface's sta_sja arc.
   update_walking_speed = window stores + approach_s32(ext) + apply_slope_accel.
   The leaf's one store is a NON-ptr chase store marioObj->header.gfx.angle[i]
   (cact=[_t'5] absorbs it). *)
Definition mov_mfist_ids : list ident :=
  mario._mario_facing_downhill :: mario._mario_get_floor_class :: nil.
Definition mov_sssja_cact : list ident := mario._t'10 :: nil.
Definition mov_sssja_xids : list ident :=
  mario._sqrtf :: mario._atan2s :: nil.
Definition mov_sssja_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.
Definition mov_sja_ids : list ident :=
  mario._mario_floor_is_steep :: mario._set_steep_jump_action :: nil.
Definition mov_uws_ids : list ident :=
  mario_actions_moving._apply_slope_accel :: nil.
Definition mov_uws_xids : list ident :=
  mario_actions_object._approach_s32 :: nil.
Definition mov_ftn_ids : list ident :=
  mario_actions_moving._update_walking_speed :: mario._set_mario_animation
    :: mario._is_anim_at_end :: mario_step._perform_ground_step :: nil.
Definition mov_ftn_cact : list ident := mario_actions_moving._t'5 :: nil.
Definition mov_ftn_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action :: nil.

(* SLICE M4: check_common_moving_cancels -- the moving dispatcher's common
   cancel gate (callee #1).  0 stores; calls drop_and_set_mario_action (sids ->
   Hdasma) + set_water_plunge_action (sets ACT_WATER_PLUNGE, untainted; window
   stores + set_camera_mode/vec3s_set externals, BOTH in obj_ext_ids).  REUSES
   the StationaryLeafSurface SLICE-16 set_water_plunge_action recipe verbatim. *)
Definition mov_swpa_xids : list ident :=
  mario._set_camera_mode :: mario._vec3s_set :: nil.
Definition mov_ccmc_ids : list ident :=
  mario._set_water_plunge_action :: nil.
Definition mov_ccmc_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.

(* SLICE M5: act_hold_walking + the SHARED walk/decel anim-audio subtree.
   anim_and_audio_for_hold_walk calls set_mario_anim_with_accel (the np3
   class: 3rd arg val0C = (s32)(speed*0x10000), a float-cast non-Vptr) inside
   a while/switch loop -- walked via the NEW call_pres_of_wwalk_nids producer
   (nids=[val0C], np3_ids=[smawa]).  smawa's np3 row reuses ActWriterSurface's
   call_pres_np3_of_wwalk (cact=[_o;_t'14;_t'13;_targetAnim], xids=[load_
   patchable_table]).  The anim/audio helpers (smawa / is_anim_past_frame /
   play_sound_and_spawn_particles / play_step_sound) are SHARED infrastructure
   -- reused by hold_heavy_walking / burning_ground / hold_decelerating. *)
Definition mov_smawa_cact : list ident :=
  mario._o :: mario._t'14 :: mario._t'13 :: mario._targetAnim :: nil.
Definition mov_smawa_xids : list ident := mario._load_patchable_table :: nil.
Definition mov_pssp_xids : list ident := mario._play_sound :: nil.
Definition mov_pss_ids : list ident :=
  mario._is_anim_past_frame :: mario._play_sound_and_spawn_particles :: nil.
Definition mov_aahw_ids : list ident :=
  mario_actions_moving._play_step_sound :: nil.
Definition mov_aahw_nids : list ident := mario_actions_moving._val0C :: nil.
Definition mov_aahw_np3 : list ident := mario._set_mario_anim_with_accel :: nil.
Definition mov_sbs_ids : list ident := mario._mario_facing_downhill :: nil.
Definition mov_ahw_ids : list ident :=
  mario_actions_moving._anim_and_audio_for_hold_walk
    :: mario._mario_set_forward_vel
    :: mario_step._perform_ground_step
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._update_walking_speed :: nil.
Definition mov_ahw_xids : list ident := interaction._segmented_to_virtual :: nil.
Definition mov_ahw_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action
    :: mario._drop_and_set_mario_action :: nil.

(* SLICE M6: act_hold_heavy_walking -- the heavy-object twin of M5.  REUSES
   the whole anim/audio np3 subtree; its only new helper is anim_and_audio_
   for_heavy_walk (no loop; nids=[val04], np3_ids=[smawa], ids=[play_step_
   sound]).  The leaf has no segmented_to_virtual / set_jumping_action. *)
Definition mov_aahh_nids : list ident := mario_actions_moving._val04 :: nil.
Definition mov_ahhw_ids : list ident :=
  mario_actions_moving._anim_and_audio_for_heavy_walk
    :: mario._mario_set_forward_vel
    :: mario_step._perform_ground_step
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._update_walking_speed :: nil.
Definition mov_ahhw_sids : list ident :=
  mario._set_mario_action :: mario._drop_and_set_mario_action :: nil.

(* the walked leaves (this slice) and the shrinking rest *)
Definition mov_walked_ids : list ident :=
  mario_actions_moving._check_common_moving_cancels
    :: mario_actions_moving._act_hold_walking
    :: mario_actions_moving._act_hold_heavy_walking
    :: mario_actions_moving._act_backward_ground_kb
    :: mario_actions_moving._act_forward_ground_kb
    :: mario_actions_moving._act_soft_backward_ground_kb
    :: mario_actions_moving._act_soft_forward_ground_kb
    :: mario_actions_moving._act_hard_backward_ground_kb
    :: mario_actions_moving._act_hard_forward_ground_kb
    :: mario_actions_moving._act_ground_bonk
    :: mario_actions_moving._act_death_exit_land
    :: mario_actions_moving._act_finish_turning_around
    :: mario_actions_moving._act_slide_kick_slide
    :: mario_actions_moving._act_hold_decelerating
    :: mario_actions_moving._act_turning_around
    (* LANDING KEYSTONE: the 3 clean common_landing_cancels leaves *)
    :: mario_actions_moving._act_jump_land
    :: mario_actions_moving._act_freefall_land
    :: mario_actions_moving._act_double_jump_land
    (* LANDING KEYSTONE part 2: the HOLD leaves (leading drop-object block) *)
    :: mario_actions_moving._act_hold_jump_land
    :: mario_actions_moving._act_hold_freefall_land
    (* LANDING KEYSTONE part 3: the INPUT-STORE leaves (input clear + sound) *)
    :: mario_actions_moving._act_triple_jump_land
    :: mario_actions_moving._act_backflip_land
    :: mario_actions_moving._act_long_jump_land
    (* LANDING KEYSTONE part 4: the object-angle chase-store leaf *)
    :: mario_actions_moving._act_side_flip_land
    (* QUICKSAND KEYSTONE: the two quicksand_jump_land_action wrappers *)
    :: mario_actions_moving._act_quicksand_jump_land
    :: mario_actions_moving._act_hold_quicksand_jump_land
    (* act_burning_ground: a clean nids-engine walk (np3 smawa via nsrc_chk) *)
    :: mario_actions_moving._act_burning_ground
    (* act_braking: twl-style hybrid (slide_bonk switch site) *)
    :: mario_actions_moving._act_braking
    (* act_decelerating: A-gated np3 hybrid (set_jump_from_landing kill) *)
    :: mario_actions_moving._act_decelerating
    (* act_move_punching: clean engine walk (all 6 helpers have rows;
       mario_update_punch_sequence via ObjectLeafSurface.mups_row) *)
    :: mario_actions_moving._act_move_punching
    (* act_crawling: nids-engine consumer of the align_with_floor keystone
       (the gchase store C through marioObj->gfx.throwMatrix) *)
    :: mario_actions_moving._act_crawling
    (* act_stomach_slide: csa/ssa keystone (common_slide_action +
       stomach_slide_action multi-action-param lifts) *)
    :: mario_actions_moving._act_stomach_slide
    (* act_butt_slide: csaj keystone (common_slide_action_with_jump) +
       tilt_body_butt_slide chase-store row *)
    :: mario_actions_moving._act_butt_slide
    (* the HOLD- pair: shared HOLD-FRONT (held-object drop_and_set early
       return) ;; ssa-REST (stomach) / csaj-REST + tilt (butt) *)
    :: mario_actions_moving._act_hold_stomach_slide
    :: mario_actions_moving._act_hold_butt_slide :: nil.
Definition mov_rest_ids : list ident :=
  filter (fun id => negb (mem_id id mov_walked_ids)) moving_callee_ids.

(* ---------------------------------------------------------------------- *)
(* SLICE M7: the slide helper subtree + act_slide_kick_slide.             *)
(* mario_bonk_reflection / update_sliding / update_sliding_angle are all  *)
(* clean window-store-only helpers (no np3, no param-action, no AGates).  *)
(* ---------------------------------------------------------------------- *)

(* mario_bonk_reflection (mario_step.prog): faceAngle[1] window store +
   atan2s/play_sound ext + mario_set_forward_vel. *)
Definition mov_mbr_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition mov_mbr_xids : list ident :=
  interaction._atan2s :: mario._play_sound :: nil.

(* update_sliding_angle: slideVel/faceAngle window stores + atan2s/sqrtf ext
   + mario_update_moving_sand / mario_update_windy_ground. *)
Definition mov_usa_ids : list ident :=
  mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground :: nil.
Definition mov_usa_xids : list ident := interaction._atan2s :: mario._sqrtf :: nil.

(* update_sliding: forwardVel window store + sqrtf ext + floor helpers. *)
Definition mov_usl_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._update_sliding_angle
    :: mario._mario_floor_is_slope
    :: mario._mario_set_forward_vel :: nil.
Definition mov_usl_xids : list ident := mario._sqrtf :: nil.

(* act_slide_kick_slide leaf: const-action sids + the slide helper subtree. *)
Definition mov_sks_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario_actions_moving._update_sliding
    :: mario_step._perform_ground_step
    :: mario_step._mario_bonk_reflection :: nil.
Definition mov_sks_sids : list ident :=
  mario._set_jumping_action :: mario._set_mario_action :: nil.
Definition mov_sks_xids : list ident := mario._play_sound :: nil.

(* ---------------------------------------------------------------------- *)
(* SLICE M8: the val0C np3 leaf act_hold_decelerating.                     *)
(* The new engine arm (recursive/copy/literal nsrc_chk) lets the nids      *)
(* channel certify the `val0C = (int)(int)(fv*0x10000); if(...) val0C=...` *)
(* idiom; the np3 channel then carries set_mario_anim_with_accel.  Two new *)
(* clean helper rows: update_decelerating_speed (approach_f32 ext +        *)
(* window/sand/wind) and adjust_sound_for_speed (set_sound_moving_speed    *)
(* obj_ext).                                                               *)
(* ---------------------------------------------------------------------- *)

(* update_decelerating_speed: m->forwardVel = approach_f32(..) window store
   + mario_set_forward_vel + mario_update_moving_sand/windy_ground. *)
Definition mov_uds_ids : list ident :=
  mario._mario_set_forward_vel
    :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground :: nil.
Definition mov_uds_xids : list ident := mario_actions_moving._approach_f32 :: nil.

(* adjust_sound_for_speed (mario.prog, the Internal one): read-only +
   set_sound_moving_speed (obj_ext). *)
Definition mov_asfs_xids : list ident := mario._set_sound_moving_speed :: nil.

(* act_hold_decelerating leaf (body_pres, np3 channel). *)
Definition mov_ahd_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._update_decelerating_speed
    :: mario_step._perform_ground_step
    :: mario_step._mario_bonk_reflection
    :: mario._mario_set_forward_vel
    :: mario._set_mario_animation
    :: mario._adjust_sound_for_speed
    :: mario_actions_moving._play_step_sound :: nil.
Definition mov_ahd_sids : list ident :=
  mario._set_mario_action
    :: mario._set_jumping_action
    :: mario._drop_and_set_mario_action :: nil.
Definition mov_ahd_xids : list ident := mario._play_sound :: nil.
Definition mov_ahd_nids : list ident :=
  mario_actions_moving._t'12 :: mario_actions_moving._val0C :: nil.
Definition mov_ahd_np3 : list ident := mario._set_mario_anim_with_accel :: nil.

(* ====================================================================== *)
(* SLICE M-DEC: act_decelerating -- an A-gated np3 hybrid.                 *)
(*                                                                         *)
(* act_decelerating is act_hold_decelerating's engine census + np3 leaf    *)
(* (set_mario_anim_with_accel, val0C) PLUS ONE non-engine site: the        *)
(* `input & 2 -> set_jump_from_landing` A-gate (set_jump_from_landing      *)
(* ALWAYS taints, no param), provably DEAD on a no-A run.  We mirror the    *)
(* B14 cannon gated hybrid (AutomaticLeafSurface cnn family), generic       *)
(* subtrees going to the np3-aware engine wwalk_pres (not wwalk_pres0),     *)
(* the gate going to input_a_gate_takes_else_lp (THEN unreached).  The one  *)
(* new helper is check_ground_dive_or_punch (pure engine body + an unused   *)
(* _filler stack local -> call_pres_of_lwalk, lids=nil).                   *)
(* ====================================================================== *)

(* dec census: mov_ahd's helpers + check_ground_dive_or_punch *)
Definition dec_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._check_ground_dive_or_punch
    :: mario_actions_moving._update_decelerating_speed
    :: mario_step._perform_ground_step
    :: mario_step._mario_bonk_reflection
    :: mario._mario_set_forward_vel
    :: mario._set_mario_animation
    :: mario._adjust_sound_for_speed
    :: mario_actions_moving._play_step_sound :: nil.
Definition dec_sids : list ident := mario._set_mario_action :: nil.
Definition dec_xids : list ident := mario._play_sound :: nil.
Definition dec_nids : list ident :=
  mario_actions_moving._val0C :: mario_actions_moving._t'11 :: nil.
Definition dec_np3 : list ident := mario._set_mario_anim_with_accel :: nil.
Definition dec_cact : list ident := @nil ident.

(* the generic engine arm (np3-aware: nids/np3_ids carried) *)
Definition dec_gen (s : statement) : bool :=
  wwalk_chk' nil nil nil nil dec_nids dec_np3 false nil dec_ids nil dec_cact
    dec_xids dec_sids nil s.

(* STRICT gate recognizers: the EXACT canonical shape input_a_gate_takes_
   else_lp consumes (the same as the cnn gate). *)
Definition dec_input_src (src : expr) : bool :=
  match src with
  | Efield (Ederef (Etempvar p pty) sty) fld faty =>
      Pos.eqb p mario_actions_airborne._m
      && proj_sumbool
           (type_eq pty (tptr (Tstruct mario._MarioState noattr)))
      && proj_sumbool (type_eq sty (Tstruct mario._MarioState noattr))
      && Pos.eqb fld mario._input
      && proj_sumbool (type_eq faty tushort)
  | _ => false
  end.

Definition dec_a_guard (t6 : ident) (g : expr) : bool :=
  match g with
  | Ebinop Oand (Etempvar q qty) (Econst_int c cty) gty =>
      Pos.eqb q t6
      && proj_sumbool (type_eq qty tushort)
      && proj_sumbool (Int.eq_dec c (Int.repr 2))
      && proj_sumbool (type_eq cty tint)
      && proj_sumbool (type_eq gty tint)
  | _ => false
  end.

Definition dec_gate_chk (s : statement) : bool :=
  match s with
  | Ssequence (Sset t6 src) (Sifthenelse g _ sELSE) =>
      dec_input_src src
      && dec_a_guard t6 g
      && negb (Pos.eqb t6 mario_actions_airborne._m)
      && negb (mem_id t6 dec_cact)
      && dec_gen sELSE
  | _ => false
  end.

(* the hybrid recognizer: generic census everywhere, descending through
   Ssequence/Sifthenelse/Sswitch, with the A-gate special. *)
Fixpoint dec_chk (s : statement) : bool :=
  dec_gen s
  || match s with
     | Ssequence s1 s2 => dec_gate_chk s || (dec_chk s1 && dec_chk s2)
     | Sifthenelse _ s1 s2 => dec_chk s1 && dec_chk s2
     | Sswitch _ ls => dec_chk_ls ls
     | _ => false
     end
with dec_chk_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s rest => dec_chk s && dec_chk_ls rest
  end.

(* ---- switch-selection transfer (mirror of the cnn switch lemmas) ---- *)
Lemma dec_chk_ls_seq : forall sl,
    dec_chk_ls sl = true ->
    dec_chk (seq_of_labeled_statement sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn in H. apply andb_prop in H as [H1 H2].
    cbn [seq_of_labeled_statement dec_chk].
    apply orb_true_iff. right.
    apply orb_true_iff. right.
    rewrite H1, (IH H2). reflexivity.
Qed.

Lemma dec_chk_ls_case : forall n sl sl',
    dec_chk_ls sl = true ->
    select_switch_case n sl = Some sl' ->
    dec_chk_ls sl' = true.
Proof.
  intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma dec_chk_ls_default : forall sl,
    dec_chk_ls sl = true ->
    dec_chk_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn.
    + exact (IH H2).
    + rewrite H1, H2. reflexivity.
Qed.

Lemma dec_chk_select : forall n sl,
    dec_chk_ls sl = true ->
    dec_chk (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros n sl H. apply dec_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (dec_chk_ls_case _ _ _ H E).
  - exact (dec_chk_ls_default _ H).
Qed.

(* ---- the gate decode: recover the kill lemma's EXACT shape ---- *)
Lemma dec_gate_shape :
  forall s1 s2,
    dec_gate_chk (Ssequence s1 s2) = true ->
    exists t6 sTHEN sELSE,
      s1 = Sset t6 (Efield (Ederef (Etempvar mario_actions_airborne._m
                              (tptr (Tstruct mario._MarioState noattr)))
                      (Tstruct mario._MarioState noattr))
              mario._input tushort) /\
      s2 = Sifthenelse (Ebinop Oand (Etempvar t6 tushort)
                          (Econst_int (Int.repr 2) tint) tint)
             sTHEN sELSE /\
      Pos.eqb t6 mario_actions_airborne._m = false /\
      mem_id t6 dec_cact = false /\
      dec_gen sELSE = true.
Proof.
  intros s1 s2 H. unfold dec_gate_chk in H.
  destruct s1 as [ | e1 e2 | t6 src | oi ef alq | oi2 ef2 tyl alq2
                 | sa sb | ga sa sb | sla slb | | | oret | swa swl
                 | lid ls | gid ];
    try discriminate H.
  destruct s2 as [ | f1 f2 | u6 src2 | oj eg alr | oj2 eg2 tyl2 alr2
                 | ta tb | g sTHEN sELSE | tla tlb | | | oret2 | swa2 swl2
                 | lid2 ls2 | gid2 ];
    try discriminate H.
  apply andb_prop in H as [H HgenE].
  apply andb_prop in H as [H Hnmem].
  apply andb_prop in H as [H Hneq].
  apply andb_prop in H as [Hsrc Hguard].
  unfold dec_input_src in Hsrc.
  destruct src as [ | | | | | | | | | | | e0 fld faty | | ];
    try discriminate Hsrc.
  destruct e0 as [ | | | | | | e3 sty | | | | | | | ];
    try discriminate Hsrc.
  destruct e3 as [ | | | | | p pty | | | | | | | | ];
    try discriminate Hsrc.
  apply andb_prop in Hsrc as [Hsrc Hfaty].
  apply andb_prop in Hsrc as [Hsrc Hfld].
  apply andb_prop in Hsrc as [Hsrc Hsty].
  apply andb_prop in Hsrc as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  apply Pos.eqb_eq in Hfld. subst fld.
  destruct (type_eq pty (tptr (Tstruct mario._MarioState noattr)));
    [ subst pty | discriminate Hpty ].
  destruct (type_eq sty (Tstruct mario._MarioState noattr));
    [ subst sty | discriminate Hsty ].
  destruct (type_eq faty tushort); [ subst faty | discriminate Hfaty ].
  unfold dec_a_guard in Hguard.
  destruct g as [ | | | | | | | | | op b1 b2 gty | | | | ];
    try discriminate Hguard.
  destruct op; try discriminate Hguard.
  destruct b1 as [ | | | | | q qty | | | | | | | | ];
    try discriminate Hguard.
  destruct b2 as [ c cty | | | | | | | | | | | | | ];
    try discriminate Hguard.
  apply andb_prop in Hguard as [Hguard Hgty].
  apply andb_prop in Hguard as [Hguard Hcty].
  apply andb_prop in Hguard as [Hguard Hc].
  apply andb_prop in Hguard as [Hq Hqty].
  apply Pos.eqb_eq in Hq. subst q.
  destruct (type_eq qty tushort); [ subst qty | discriminate Hqty ].
  destruct (Int.eq_dec c (Int.repr 2)); [ subst c | discriminate Hc ].
  destruct (type_eq cty tint); [ subst cty | discriminate Hcty ].
  destruct (type_eq gty tint); [ subst gty | discriminate Hgty ].
  apply negb_true_iff in Hneq.
  apply negb_true_iff in Hnmem.
  exists t6, sTHEN, sELSE.
  split; [ reflexivity | ].
  split; [ reflexivity | ].
  split; [ exact Hneq | ].
  split; [ exact Hnmem | exact HgenE ].
Qed.

(* ---------------------------------------------------------------------- *)
(* SLICE M9: the param-action leaf act_turning_around.                     *)
(* begin_walking_action(m, <float forwardVel>, ACT_X, 0) is an act3-class  *)
(* call whose action arg (args[1]) is an untainted const and whose arg[0]  *)
(* (forwardVel) is a FLOAT -- value-irrelevant for call_pres_act3.  The    *)
(* generalized act3_call_chk arm (relaxed arg0, routed to                   *)
(* kit_scall3_anim_pres) recognizes it; the 4-param position-3 producer     *)
(* call_pres_act3_of_wwalk_p4 discharges begin_walking_action's own body    *)
(* (it threads its _action PARAM through wact into set_mario_action).  Two  *)
(* new clean helper rows: analog_stick_held_back (read-only) and            *)
(* apply_slope_decel (floor-class + approach_f32 ext + apply_slope_accel,   *)
(* the last already proved as mov_asa_row).                                 *)
(* ---------------------------------------------------------------------- *)

(* apply_slope_decel: mario_get_floor_class + apply_slope_accel (ids) +
   approach_f32 (ext); switch sets _decel; m->forwardVel window store. *)
Definition mov_asd_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._apply_slope_accel :: nil.
Definition mov_asd_xids : list ident := mario_actions_moving._approach_f32 :: nil.

(* ---------------------------------------------------------------------- *)
(* common_landing_action: the LANDING-family helper EVERY _land leaf       *)
(* calls after common_landing_cancels.  It writes m->action only at its    *)
(* switch-case-0 set_mario_action(m, airAction, 0) -- airAction is the 3rd *)
(* PARAM, the UNTAINTED const each leaf passes (16779404, ...).  So it is  *)
(* NOT a generic call_pres (false for a tainted airAction); the engine     *)
(* threads _airAction through wact and the leaf supplies untainted_scalar. *)
(* Its non-action callees all have rows already: perform_ground_step (Hcp_ *)
(* pgs), apply_landing_accel (mov_ala_row), apply_slope_decel (mov_asd_    *)
(* row), set_mario_animation (mov_sma_row); play_mario_landing_sound_once  *)
(* is an mov_ext external; set_mario_action is the sids keystone.          *)
Definition cla_ids : list ident :=
  mario_step._perform_ground_step :: mario_actions_moving._apply_landing_accel
    :: mario_actions_moving._apply_slope_decel :: mario._set_mario_animation
    :: nil.
Definition cla_xids : list ident :=
  mario_actions_moving._play_mario_landing_sound_once :: nil.
Definition cla_sids : list ident := mario._set_mario_action :: nil.

(* QUICKSAND keystone (quicksand_jump_land_action): TWO param-action seeds
   (_endAction, _airAction), both written via set_mario_action (sids); the
   non-action callees perform_ground_step / apply_landing_accel /
   set_mario_animation / play_mario_jump_sound all have rows.  No externals,
   no chase stores -- only actionTimer/quicksandDepth window stores. *)
Definition qjla_wact : list ident :=
  mario_actions_moving._endAction :: mario_actions_moving._airAction :: nil.
Definition qjla_ids : list ident :=
  mario_step._perform_ground_step :: mario_actions_moving._apply_landing_accel
    :: mario._set_mario_animation :: mario._play_mario_jump_sound :: nil.
Definition qjla_sids : list ident := mario._set_mario_action :: nil.

(* SLIDE_BONK keystone: slide_bonk(m, fastAction, slowAction) -- TWO param-
   action seeds, fastAction via drop_and_set_mario_action and slowAction via
   set_mario_action; the only other callees (mario_bonk_reflection /
   mario_set_forward_vel) have rows; no direct stores. *)
Definition sb_wact : list ident :=
  mario_actions_moving._fastAction :: mario_actions_moving._slowAction :: nil.
Definition sb_ids : list ident :=
  mario_step._mario_bonk_reflection :: mario._mario_set_forward_vel :: nil.
Definition sb_sids : list ident :=
  mario._drop_and_set_mario_action :: mario._set_mario_action :: nil.

(* act_burning_ground: a CLEAN engine walk (wwalk_chk via _nids) -- all action
   args are untainted consts (sids=set_mario_action), the callees all have rows,
   the stores are window/indexed-window/chase (marioObj asS32[34] + marioBodyState
   eyeState).  cact = the marioObj/marioBodyState chase temps.  smawa is the np3
   leaf: its 3rd arg is an INLINE `(int)(forwardVel/2 * 0x10000)` -- nsrc_chk
   certifies it non-pointer (float->int cast), so np3_ids carries it (nids=nil). *)
Definition abg_ids : list ident :=
  mario_actions_moving._apply_slope_accel :: mario_step._perform_ground_step
    :: mario_actions_moving._play_step_sound :: nil.
Definition abg_np3 : list ident := mario._set_mario_anim_with_accel :: nil.
Definition abg_xids : list ident :=
  mario._play_sound :: mario_actions_moving._approach_f32
    :: mario_actions_object._approach_s32 :: nil.
Definition abg_sids : list ident := mario._set_mario_action :: nil.
Definition abg_cact : list ident :=
  mario_actions_moving._t'25 :: mario_actions_moving._t'26
    :: mario_actions_moving._t'23 :: mario_actions_moving._t'22
    :: mario_actions_moving._t'10 :: mario_actions_moving._t'7 :: nil.

(* act_move_punching: all calls are internal call_pres helpers (no externals,
   no chase temps); the 4 window stores are non-pointer m->field writes. *)
Definition mp_ids : list ident :=
  mario_actions_moving._should_begin_sliding
    :: mario_actions_object._mario_update_punch_sequence
    :: mario_actions_moving._apply_slope_decel
    :: mario_actions_moving._apply_slope_accel
    :: mario_step._perform_ground_step :: nil.
Definition mp_sids : list ident := mario._set_mario_action :: nil.

(* ====================================================================== *)
(* align_with_floor keystone: the global-pointer-chase store.             *)
(* The body stores `&sFloorAlignMatrix[t'2]` (a global float-matrix array  *)
(* element address) THROUGH marioObj->header.gfx.throwMatrix (a censused   *)
(* chase cell).  This is the ONE store no engine arm recognises, so        *)
(* align_with_floor is walked bespoke: the engine (wwalk_pres0) handles    *)
(* the seven other statements (5 loads + the m->pos[1] window store + the  *)
(* mtxf external), and gchase_assign_pres handles store C.                 *)
(* ====================================================================== *)
Definition awf_cact : list ident := mario_actions_moving._t'1 :: nil.
Definition awf_xids : list ident :=
  mario_actions_moving._mtxf_align_terrain_triangle :: nil.

(* the throwMatrix store target lvalue (chain rooted at _t'1 = m->marioObj) *)
Definition awf_a1 :=
  (Efield
    (Efield
      (Efield
        (Ederef (Etempvar mario_actions_moving._t'1
                   (tptr (Tstruct mario_actions_moving._Object noattr)))
          (Tstruct mario_actions_moving._Object noattr))
        mario_actions_moving._header
        (Tstruct mario_actions_moving._ObjectNode noattr))
      mario_actions_moving._gfx
      (Tstruct mario_actions_moving._GraphNodeObject noattr))
    mario_actions_moving._throwMatrix
    (tptr (tarray (tarray tfloat 4) 4))).

(* the stored value: &sFloorAlignMatrix[t'2], a global array element address *)
Definition awf_a2 :=
  (Ebinop Oadd
    (Evar mario_actions_moving._sFloorAlignMatrix
       (tarray (tarray (tarray tfloat 4) 4) 2))
    (Etempvar mario_actions_moving._t'2 tushort)
    (tptr (tarray (tarray tfloat 4) 4))).

(* act_crawling: the cheapest consumer of align_with_floor.  All callees
   have rows; the ONLY Sassign is the m->intendedMag window store; nids
   carries the val04 non-pointer temp; np3 carries set_mario_anim_with_accel. *)
Definition cr_ids : list ident :=
  mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._check_ground_dive_or_punch
    :: mario_actions_moving._update_walking_speed
    :: mario_step._perform_ground_step
    :: mario._mario_set_forward_vel
    :: mario_actions_moving._play_step_sound
    :: mario_actions_moving._align_with_floor :: nil.
Definition cr_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action :: nil.
Definition cr_nids : list ident := mario_actions_moving._val04 :: nil.
Definition cr_np3 : list ident := mario._set_mario_anim_with_accel :: nil.

(* begin_walking_action producer: wact threads the _action PARAM + the
   set_mario_action result temp _t'1; ids = mario_set_forward_vel;
   wids = set_mario_action.  Output: call_pres_act3. *)
Definition mov_bwa_wact : list ident :=
  mario_actions_moving._action :: mario_actions_moving._t'1 :: nil.
Definition mov_bwa_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition mov_bwa_wids : list ident := mario._set_mario_action :: nil.

(* act_turning_around leaf (body_pres, tids/act3 channel). *)
Definition mov_ata_ids : list ident :=
  mario_actions_moving._analog_stick_held_back
    :: mario_actions_moving._apply_slope_decel
    :: mario_step._perform_ground_step
    :: mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario._adjust_sound_for_speed :: nil.
Definition mov_ata_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action :: nil.
Definition mov_ata_tids : list ident :=
  mario_actions_moving._begin_walking_action :: nil.
Definition mov_ata_xids : list ident := mario._play_sound :: nil.

(* ====================================================================== *)
(* Shape pins (vm_compute reflexivity over the real AST).                 *)
(* ====================================================================== *)

Definition mov_pok (f : function) : bool :=
  match fn_params f with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end.

(* ---- shared mario.prog / mario_step.prog helpers ---- *)
Example mov_mgfc_pin :
  (prog_defmap mario.prog) ! mario._mario_get_floor_class
  = Some (Gfun (Internal mario.f_mario_get_floor_class)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mgfc_vars : fn_vars mario.f_mario_get_floor_class = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mgfc_pok : mov_pok mario.f_mario_get_floor_class = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mgfc_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_get_floor_class) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_mfis_pin :
  (prog_defmap mario.prog) ! mario._mario_floor_is_slope
  = Some (Gfun (Internal mario.f_mario_floor_is_slope)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mfis_vars : fn_vars mario.f_mario_floor_is_slope = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfis_pok : mov_pok mario.f_mario_floor_is_slope = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfis_walk :
  wwalk_chk false nil (mario._mario_get_floor_class :: nil) nil nil nil nil nil
    (fn_body mario.f_mario_floor_is_slope) = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfisl_pin :
  (prog_defmap mario.prog) ! mario._mario_floor_is_slippery
  = Some (Gfun (Internal mario.f_mario_floor_is_slippery)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mfisl_vars : fn_vars mario.f_mario_floor_is_slippery = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfisl_pok : mov_pok mario.f_mario_floor_is_slippery = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfisl_walk :
  wwalk_chk false nil (mario._mario_get_floor_class :: nil) nil nil nil nil nil
    (fn_body mario.f_mario_floor_is_slippery) = true.
Proof. vm_compute. reflexivity. Qed.


Example mov_msfv_pin :
  (prog_defmap mario.prog) ! mario._mario_set_forward_vel
  = Some (Gfun (Internal mario.f_mario_set_forward_vel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_msfv_vars : fn_vars mario.f_mario_set_forward_vel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_msfv_pok : mov_pok mario.f_mario_set_forward_vel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_msfv_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_set_forward_vel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_iae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Example mov_iae_vars : fn_vars mario.f_is_anim_at_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_iae_pok : mov_pok mario.f_is_anim_at_end = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_iae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sma_pin :
  (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_vars : fn_vars mario.f_set_mario_animation = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_pok : mov_pok mario.f_set_mario_animation = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario.f_set_mario_animation)))) mov_sma_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_walk :
  wwalk_chk false nil nil nil mov_sma_cact mov_sma_xids nil nil
    (fn_body mario.f_set_mario_animation) = true.
Proof. vm_compute. reflexivity. Qed.
(* ---- tilt_body_butt_slide (cact chase-store row, used by act_butt_slide) ---- *)
Definition mov_tbbs_cact : list ident :=
  mario_actions_moving._t'4 :: mario_actions_moving._t'1 :: nil.
Example mov_tbbs_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._tilt_body_butt_slide
  = Some (Gfun (Internal mario_actions_moving.f_tilt_body_butt_slide)).
Proof. vm_compute. reflexivity. Qed.
Example mov_tbbs_vars : fn_vars mario_actions_moving.f_tilt_body_butt_slide = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_tbbs_pok : mov_pok mario_actions_moving.f_tilt_body_butt_slide = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_tbbs_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_moving.f_tilt_body_butt_slide)))) mov_tbbs_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_tbbs_walk :
  wwalk_chk false nil nil nil mov_tbbs_cact nil nil nil
    (fn_body mario_actions_moving.f_tilt_body_butt_slide) = true.
Proof. vm_compute. reflexivity. Qed.


Example mov_mums_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_moving_sand
  = Some (Gfun (Internal mario_step.f_mario_update_moving_sand)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mums_vars : fn_vars mario_step.f_mario_update_moving_sand = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mums_pok : mov_pok mario_step.f_mario_update_moving_sand = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mums_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_moving_sand) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_muwg_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_windy_ground
  = Some (Gfun (Internal mario_step.f_mario_update_windy_ground)).
Proof. vm_compute. reflexivity. Qed.
Example mov_muwg_vars : fn_vars mario_step.f_mario_update_windy_ground = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_muwg_pok : mov_pok mario_step.f_mario_update_windy_ground = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_muwg_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_windy_ground) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- moving.prog physics helpers ---- *)
Example mov_asa_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._apply_slope_accel
  = Some (Gfun (Internal mario_actions_moving.f_apply_slope_accel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_asa_vars : fn_vars mario_actions_moving.f_apply_slope_accel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_asa_pok : mov_pok mario_actions_moving.f_apply_slope_accel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_asa_walk :
  wwalk_chk false nil mov_asa_ids nil nil mov_asa_xids nil nil
    (fn_body mario_actions_moving.f_apply_slope_accel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ala_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._apply_landing_accel
  = Some (Gfun (Internal mario_actions_moving.f_apply_landing_accel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ala_vars : fn_vars mario_actions_moving.f_apply_landing_accel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ala_pok : mov_pok mario_actions_moving.f_apply_landing_accel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ala_walk :
  wwalk_chk false nil mov_ala_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_apply_landing_accel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_cgka_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._common_ground_knockback_action
  = Some (Gfun (Internal mario_actions_moving.f_common_ground_knockback_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_cgka_vars :
  fn_vars mario_actions_moving.f_common_ground_knockback_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_cgka_pok :
  mov_pok mario_actions_moving.f_common_ground_knockback_action = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_cgka_walk :
  wwalk_chk false nil mov_cgka_ids nil nil mov_cgka_xids mov_sids nil
    (fn_body mario_actions_moving.f_common_ground_knockback_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the 7 knockback leaves ---- *)
Example mov_bkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_backward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_backward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_bkb_vars : fn_vars mario_actions_moving.f_act_backward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_bkb_pok : mov_pok mario_actions_moving.f_act_backward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_bkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_backward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_fkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_forward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_forward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_fkb_vars : fn_vars mario_actions_moving.f_act_forward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_fkb_pok : mov_pok mario_actions_moving.f_act_forward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_fkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_forward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sbkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_soft_backward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_soft_backward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sbkb_vars : fn_vars mario_actions_moving.f_act_soft_backward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbkb_pok : mov_pok mario_actions_moving.f_act_soft_backward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_soft_backward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sfkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_soft_forward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_soft_forward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sfkb_vars : fn_vars mario_actions_moving.f_act_soft_forward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sfkb_pok : mov_pok mario_actions_moving.f_act_soft_forward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sfkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_soft_forward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_hbkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hard_backward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_hard_backward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_hbkb_vars : fn_vars mario_actions_moving.f_act_hard_backward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_hbkb_pok : mov_pok mario_actions_moving.f_act_hard_backward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_hbkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil mov_hard_back_xids mov_sids nil
    (fn_body mario_actions_moving.f_act_hard_backward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_hfkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hard_forward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_hard_forward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_hfkb_vars : fn_vars mario_actions_moving.f_act_hard_forward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_hfkb_pok : mov_pok mario_actions_moving.f_act_hard_forward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_hfkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil mov_sids nil
    (fn_body mario_actions_moving.f_act_hard_forward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_gbonk_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_ground_bonk
  = Some (Gfun (Internal mario_actions_moving.f_act_ground_bonk)).
Proof. vm_compute. reflexivity. Qed.
Example mov_gbonk_vars : fn_vars mario_actions_moving.f_act_ground_bonk = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_gbonk_pok : mov_pok mario_actions_moving.f_act_ground_bonk = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_gbonk_walk :
  wwalk_chk false nil mov_cgka_only nil nil mov_gbonk_xids nil nil
    (fn_body mario_actions_moving.f_act_ground_bonk) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M2: act_death_exit_land ---- *)
Example mov_del_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_death_exit_land
  = Some (Gfun (Internal mario_actions_moving.f_act_death_exit_land)).
Proof. vm_compute. reflexivity. Qed.
Example mov_del_vars : fn_vars mario_actions_moving.f_act_death_exit_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_del_pok : mov_pok mario_actions_moving.f_act_death_exit_land = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_del_walk :
  wwalk_chk false nil mov_del_ids nil nil mov_del_xids
    (mario._set_mario_action :: nil) nil
    (fn_body mario_actions_moving.f_act_death_exit_land) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M3 pins ---- *)
Example mov_mfist_pin :
  (prog_defmap mario.prog) ! mario._mario_floor_is_steep
  = Some (Gfun (Internal mario.f_mario_floor_is_steep)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mfist_vars : fn_vars mario.f_mario_floor_is_steep = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfist_pok : mov_pok mario.f_mario_floor_is_steep = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfist_walk :
  wwalk_chk false nil mov_mfist_ids nil nil nil nil nil
    (fn_body mario.f_mario_floor_is_steep) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sssja_pin :
  (prog_defmap mario.prog) ! mario._set_steep_jump_action
  = Some (Gfun (Internal mario.f_set_steep_jump_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_vars : fn_vars mario.f_set_steep_jump_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_pok : mov_pok mario.f_set_steep_jump_action = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params mario.f_set_steep_jump_action))))
    mov_sssja_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_walk :
  wwalk_chk false nil nil nil mov_sssja_cact mov_sssja_xids mov_sssja_sids nil
    (fn_body mario.f_set_steep_jump_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sja_pin :
  (prog_defmap mario.prog) ! mario._set_jumping_action
  = Some (Gfun (Internal mario.f_set_jumping_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_vars : fn_vars mario.f_set_jumping_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_params : fn_params mario.f_set_jumping_action = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_ret : i32_ty (fn_return mario.f_set_jumping_action) = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_walk :
  wwalk_chk true
    (mario._action :: mario._t'1 :: mario._t'2 :: nil)
    mov_sja_ids mov_sids nil nil mov_sids nil
    (fn_body mario.f_set_jumping_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_uws_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_walking_speed
  = Some (Gfun (Internal mario_actions_moving.f_update_walking_speed)).
Proof. vm_compute. reflexivity. Qed.
Example mov_uws_vars : fn_vars mario_actions_moving.f_update_walking_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_uws_pok : mov_pok mario_actions_moving.f_update_walking_speed = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_uws_walk :
  wwalk_chk false nil mov_uws_ids nil nil mov_uws_xids nil nil
    (fn_body mario_actions_moving.f_update_walking_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ftn_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_finish_turning_around
  = Some (Gfun (Internal mario_actions_moving.f_act_finish_turning_around)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_vars : fn_vars mario_actions_moving.f_act_finish_turning_around = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_pok : mov_pok mario_actions_moving.f_act_finish_turning_around = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params mario_actions_moving.f_act_finish_turning_around))))
    mov_ftn_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_walk :
  wwalk_chk false nil mov_ftn_ids nil mov_ftn_cact nil mov_ftn_sids nil
    (fn_body mario_actions_moving.f_act_finish_turning_around) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M4 pins ---- *)
Example mov_swpa_pin :
  (prog_defmap mario.prog) ! mario._set_water_plunge_action
  = Some (Gfun (Internal mario.f_set_water_plunge_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_swpa_vars : fn_vars mario.f_set_water_plunge_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_swpa_pok : mov_pok mario.f_set_water_plunge_action = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_swpa_walk :
  wwalk_chk false nil nil nil nil mov_swpa_xids mov_sids nil
    (fn_body mario.f_set_water_plunge_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ccmc_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._check_common_moving_cancels
  = Some (Gfun (Internal mario_actions_moving.f_check_common_moving_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ccmc_vars :
  fn_vars mario_actions_moving.f_check_common_moving_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ccmc_pok :
  mov_pok mario_actions_moving.f_check_common_moving_cancels = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ccmc_walk :
  wwalk_chk false nil mov_ccmc_ids nil nil nil mov_ccmc_sids nil
    (fn_body mario_actions_moving.f_check_common_moving_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M5 pins ---- *)
(* set_mario_anim_with_accel: the np3 leaf (reuses call_pres_np3_of_wwalk) *)
Example mov_smawa_pin :
  (prog_defmap mario.prog) ! mario._set_mario_anim_with_accel
  = Some (Gfun (Internal mario.f_set_mario_anim_with_accel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_vars : fn_vars mario.f_set_mario_anim_with_accel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_params : fn_params mario.f_set_mario_anim_with_accel = np3_params.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_cm : mem_id mario_actions_airborne._m mov_smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_canim : mem_id mario._targetAnimID mov_smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_cacc : mem_id mario._accel mov_smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_walk :
  wwalk_chk' nil nil nil nil (mario._accel :: nil) nil false
    nil nil nil mov_smawa_cact mov_smawa_xids nil nil
    (fn_body mario.f_set_mario_anim_with_accel) = true.
Proof. vm_compute. reflexivity. Qed.

(* is_anim_past_frame: pure read-only (no callees, no stores) *)
Example mov_iapf_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_frame
  = Some (Gfun (Internal mario.f_is_anim_past_frame)).
Proof. vm_compute. reflexivity. Qed.
Example mov_iapf_vars : fn_vars mario.f_is_anim_past_frame = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_iapf_pok : mov_pok mario.f_is_anim_past_frame = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_iapf_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_frame) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_sound_and_spawn_particles: window stores + play_sound external *)
Example mov_pssp_pin :
  (prog_defmap mario.prog) ! mario._play_sound_and_spawn_particles
  = Some (Gfun (Internal mario.f_play_sound_and_spawn_particles)).
Proof. vm_compute. reflexivity. Qed.
Example mov_pssp_vars : fn_vars mario.f_play_sound_and_spawn_particles = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_pssp_pok : mov_pok mario.f_play_sound_and_spawn_particles = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_pssp_walk :
  wwalk_chk false nil nil nil nil mov_pssp_xids nil nil
    (fn_body mario.f_play_sound_and_spawn_particles) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_step_sound: is_anim_past_frame + play_sound_and_spawn_particles + play_sound *)
Example mov_pss_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._play_step_sound
  = Some (Gfun (Internal mario_actions_moving.f_play_step_sound)).
Proof. vm_compute. reflexivity. Qed.
Example mov_pss_vars : fn_vars mario_actions_moving.f_play_step_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_pss_pok : mov_pok mario_actions_moving.f_play_step_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_pss_walk :
  wwalk_chk false nil mov_pss_ids nil nil mov_pssp_xids nil nil
    (fn_body mario_actions_moving.f_play_step_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* anim_and_audio_for_hold_walk: the np3 caller (loop+switch; nids=[val0C]) *)
Example mov_aahw_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._anim_and_audio_for_hold_walk
  = Some (Gfun (Internal mario_actions_moving.f_anim_and_audio_for_hold_walk)).
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_vars :
  fn_vars mario_actions_moving.f_anim_and_audio_for_hold_walk = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_pok :
  mov_pok mario_actions_moving.f_anim_and_audio_for_hold_walk = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_moving.f_anim_and_audio_for_hold_walk))))
    mov_aahw_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_walk :
  wwalk_chk' nil nil nil nil mov_aahw_nids mov_aahw_np3 false
    nil mov_aahw_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_anim_and_audio_for_hold_walk) = true.
Proof. vm_compute. reflexivity. Qed.

(* should_begin_sliding: mario_facing_downhill (read-only) *)
Example mov_sbs_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._should_begin_sliding
  = Some (Gfun (Internal mario_actions_moving.f_should_begin_sliding)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sbs_vars : fn_vars mario_actions_moving.f_should_begin_sliding = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbs_pok : mov_pok mario_actions_moving.f_should_begin_sliding = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbs_walk :
  wwalk_chk false nil mov_sbs_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_should_begin_sliding) = true.
Proof. vm_compute. reflexivity. Qed.

(* the leaf: act_hold_walking *)
Example mov_ahw_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_walking
  = Some (Gfun (Internal mario_actions_moving.f_act_hold_walking)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ahw_vars : fn_vars mario_actions_moving.f_act_hold_walking = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahw_pok : mov_pok mario_actions_moving.f_act_hold_walking = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahw_walk :
  wwalk_chk false nil mov_ahw_ids nil nil mov_ahw_xids mov_ahw_sids nil
    (fn_body mario_actions_moving.f_act_hold_walking) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M6 pins ---- *)
Example mov_aahh_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._anim_and_audio_for_heavy_walk
  = Some (Gfun (Internal mario_actions_moving.f_anim_and_audio_for_heavy_walk)).
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_vars :
  fn_vars mario_actions_moving.f_anim_and_audio_for_heavy_walk = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_pok :
  mov_pok mario_actions_moving.f_anim_and_audio_for_heavy_walk = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_moving.f_anim_and_audio_for_heavy_walk))))
    mov_aahh_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_walk :
  wwalk_chk' nil nil nil nil mov_aahh_nids mov_aahw_np3 false
    nil mov_aahw_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_anim_and_audio_for_heavy_walk) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ahhw_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_heavy_walking
  = Some (Gfun (Internal mario_actions_moving.f_act_hold_heavy_walking)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ahhw_vars : fn_vars mario_actions_moving.f_act_hold_heavy_walking = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahhw_pok : mov_pok mario_actions_moving.f_act_hold_heavy_walking = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahhw_walk :
  wwalk_chk false nil mov_ahhw_ids nil nil nil mov_ahhw_sids nil
    (fn_body mario_actions_moving.f_act_hold_heavy_walking) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M7 pins ---- *)
Example mov_mbr_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_bonk_reflection
  = Some (Gfun (Internal mario_step.f_mario_bonk_reflection)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mbr_vars : fn_vars mario_step.f_mario_bonk_reflection = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mbr_pok : mov_pok mario_step.f_mario_bonk_reflection = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mbr_walk :
  wwalk_chk false nil mov_mbr_ids nil nil mov_mbr_xids nil nil
    (fn_body mario_step.f_mario_bonk_reflection) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_usa_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_sliding_angle
  = Some (Gfun (Internal mario_actions_moving.f_update_sliding_angle)).
Proof. vm_compute. reflexivity. Qed.
Example mov_usa_vars : fn_vars mario_actions_moving.f_update_sliding_angle = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_usa_pok : mov_pok mario_actions_moving.f_update_sliding_angle = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_usa_walk :
  wwalk_chk false nil mov_usa_ids nil nil mov_usa_xids nil nil
    (fn_body mario_actions_moving.f_update_sliding_angle) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_usl_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_sliding
  = Some (Gfun (Internal mario_actions_moving.f_update_sliding)).
Proof. vm_compute. reflexivity. Qed.
Example mov_usl_vars : fn_vars mario_actions_moving.f_update_sliding = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_usl_pok : mov_pok mario_actions_moving.f_update_sliding = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_usl_walk :
  wwalk_chk false nil mov_usl_ids nil nil mov_usl_xids nil nil
    (fn_body mario_actions_moving.f_update_sliding) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sks_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_slide_kick_slide
  = Some (Gfun (Internal mario_actions_moving.f_act_slide_kick_slide)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sks_vars : fn_vars mario_actions_moving.f_act_slide_kick_slide = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sks_pok : mov_pok mario_actions_moving.f_act_slide_kick_slide = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sks_walk :
  wwalk_chk false nil mov_sks_ids nil nil mov_sks_xids mov_sks_sids nil
    (fn_body mario_actions_moving.f_act_slide_kick_slide) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M8 pins/walks ---- *)
Example mov_uds_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_decelerating_speed
  = Some (Gfun (Internal mario_actions_moving.f_update_decelerating_speed)).
Proof. vm_compute. reflexivity. Qed.
Example mov_uds_vars : fn_vars mario_actions_moving.f_update_decelerating_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_uds_pok : mov_pok mario_actions_moving.f_update_decelerating_speed = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_uds_walk :
  wwalk_chk false nil mov_uds_ids nil nil mov_uds_xids nil nil
    (fn_body mario_actions_moving.f_update_decelerating_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_asfs_pin :
  (prog_defmap mario.prog) ! mario._adjust_sound_for_speed
  = Some (Gfun (Internal mario.f_adjust_sound_for_speed)).
Proof. vm_compute. reflexivity. Qed.
Example mov_asfs_vars : fn_vars mario.f_adjust_sound_for_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_asfs_pok : mov_pok mario.f_adjust_sound_for_speed = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_asfs_walk :
  wwalk_chk false nil nil nil nil mov_asfs_xids nil nil
    (fn_body mario.f_adjust_sound_for_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ahd_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_decelerating
  = Some (Gfun (Internal mario_actions_moving.f_act_hold_decelerating)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_vars : fn_vars mario_actions_moving.f_act_hold_decelerating = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_pok : mov_pok mario_actions_moving.f_act_hold_decelerating = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_moving.f_act_hold_decelerating))))
    mov_ahd_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_walk :
  wwalk_chk' nil nil nil nil mov_ahd_nids mov_ahd_np3 false
    nil mov_ahd_ids nil nil mov_ahd_xids mov_ahd_sids nil
    (fn_body mario_actions_moving.f_act_hold_decelerating) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M-DEC pins/walks ---- *)
Example mov_dec_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_decelerating
  = Some (Gfun (Internal mario_actions_moving.f_act_decelerating)).
Proof. vm_compute. reflexivity. Qed.
Example mov_dec_vars : fn_vars mario_actions_moving.f_act_decelerating = nil.
Proof. vm_compute. reflexivity. Qed.
(* the gate-aware non-vacuity gate: ALL decel action consts are untainted
   EXCEPT the A-gated set_jump_from_landing (provably dead). *)
Example dec_walk :
  dec_chk (fn_body mario_actions_moving.f_act_decelerating) = true.
Proof. vm_compute. reflexivity. Qed.

(* check_ground_dive_or_punch: a pure-engine body (smact arm handles its 2
   inline untainted set_mario_action consts; the controller load + vel[1]
   indexed window store need no census) with ONE unused stack local _filler
   -> call_pres_of_lwalk (lids=nil). *)
Example mov_cgdop_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._check_ground_dive_or_punch
  = Some (Gfun (Internal mario_actions_moving.f_check_ground_dive_or_punch)).
Proof. vm_compute. reflexivity. Qed.
Example mov_cgdop_params :
  match fn_params mario_actions_moving.f_check_ground_dive_or_punch with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example cgdop_walk :
  wwalk_chk false nil nil nil nil nil (mario._set_mario_action :: nil) nil
    (fn_body mario_actions_moving.f_check_ground_dive_or_punch) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M9 pins/walks ---- *)
Example mov_ashb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._analog_stick_held_back
  = Some (Gfun (Internal mario_actions_moving.f_analog_stick_held_back)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ashb_vars : fn_vars mario_actions_moving.f_analog_stick_held_back = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ashb_pok : mov_pok mario_actions_moving.f_analog_stick_held_back = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ashb_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_actions_moving.f_analog_stick_held_back) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_asd_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._apply_slope_decel
  = Some (Gfun (Internal mario_actions_moving.f_apply_slope_decel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_asd_vars : fn_vars mario_actions_moving.f_apply_slope_decel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_asd_pok : mov_pok mario_actions_moving.f_apply_slope_decel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_asd_walk :
  wwalk_chk false nil mov_asd_ids nil nil mov_asd_xids nil nil
    (fn_body mario_actions_moving.f_apply_slope_decel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_bwa_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._begin_walking_action
  = Some (Gfun (Internal mario_actions_moving.f_begin_walking_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_vars : fn_vars mario_actions_moving.f_begin_walking_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_params :
  fn_params mario_actions_moving.f_begin_walking_action
  = (mario_actions_airborne._m, tyMSp)
      :: (mario_actions_moving._forwardVel, tfloat)
      :: (mario_actions_moving._action, tuint)
      :: (mario_actions_moving._actionArg, tuint) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_aid_m :
  mario_actions_moving._forwardVel <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example mov_bwa_eid_m :
  mario_actions_moving._action <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example mov_bwa_harg_m :
  mario_actions_moving._actionArg <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example mov_bwa_wa : mem_id mario_actions_moving._action mov_bwa_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_wm : mem_id mario_actions_airborne._m mov_bwa_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_wanim :
  mem_id mario_actions_moving._forwardVel mov_bwa_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_wharg :
  mem_id mario_actions_moving._actionArg mov_bwa_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_walk :
  wwalk_chk false mov_bwa_wact mov_bwa_ids mov_bwa_wids nil nil nil nil
    (fn_body mario_actions_moving.f_begin_walking_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ata_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_turning_around
  = Some (Gfun (Internal mario_actions_moving.f_act_turning_around)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ata_vars : fn_vars mario_actions_moving.f_act_turning_around = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ata_pok : mov_pok mario_actions_moving.f_act_turning_around = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ata_walk :
  wwalk_chk false nil mov_ata_ids nil nil mov_ata_xids mov_ata_sids mov_ata_tids
    (fn_body mario_actions_moving.f_act_turning_around) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows + the rest-split (one section, the full 12-hyp MWF kit).      *)
(* ====================================================================== *)

Section MovingLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.
  (* SLICE M3: the interaction TU linkorder (dasma's drop-held-object subtree
     reaches interaction helpers); supplied by the capstone (it already pins
     interaction.prog as part of the linked program lp). *)
  Hypothesis LO_int : linkorder interaction.prog lp.
  (* SLICE M-PUNCH: act_move_punching calls mario_update_punch_sequence, which
     is Internal in mario_actions_object.prog (External in this TU).  Its row
     (ObjectLeafSurface.mups_row) needs the object-TU linkorder; the capstone
     already pins linkorder mario_actions_object.prog lp (object family). *)
  Hypothesis LO_obj : linkorder mario_actions_object.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.

  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* ALIGN-WITH-FLOOR keystone: sFloorAlignMatrix's block is SafeB.  It is a
     static f32[2][4][4] global whose address Mario's gfx legitimately holds
     (marioObj->gfx.throwMatrix = &sFloorAlignMatrix[i]), so it is part of the
     SafeB reach closure -- a per-symbol POSITIVE SafeB constraint, the dual
     of the capstone's gMarioState ~SafeB hyp.  Discharged at the capstone
     (consistent with HSafeNotBm / the named ~SafeB globals: sFloorAlignMatrix
     is none of bm/bc/gMarioState/gtimer/table/ktab). *)
  Hypothesis Hsfam_safe : forall gb,
      Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix
        = Some gb -> SafeB gb.

  (* obj_ext externals the knockback subtree bottoms out in *)
  Hypothesis Hcpx_sqrtf :
    call_pres_ext lp bm NoA MWF mario._sqrtf.
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_lpt :
    call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  (* the moving family's pure audio externals (mov_ext_ids) -- the honest
     model boundary; discharged at the capstone. *)
  Hypothesis Hpres_mov_ext : forall fid,
      mem_id fid mov_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.
  (* perform_ground_step: discharged at the capstone (MarioStepSurface) *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.
  (* SLICE M3: the obj_ext boundary (atan2s + approach_s32 + the dasma trio
     segmented_to_virtual / stop_shell_music / obj_set_held_state).  ALL in
     obj_ext_ids; the capstone supplies its own Hpres_obj_ext verbatim. *)
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.

  (* LANDING KEYSTONE kit (clc walk).  An Mint32 load from a knockback_table_ids
     block is an untainted scalar (the LandingAction globals were folded into
     knockback_table_ids); the carried MWF pins Mario's input halfword A-clear.
     Both discharged at the capstone via MWFReal.mwf_real_ktab / mwf_real_inp --
     NO new trust. *)
  Hypothesis HMWF_ktab : forall m gid kb (ofs : Z) v,
      MWF m -> mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      Mem.load Mint32 m kb ofs = Some v ->
      v = Vundef \/ exists vi, v = Vint vi /\ not_tainted vi.
  Hypothesis HMWF_inp : forall m, MWF m -> input_a_clear m bm.
  (* the input-store MWF preservation: storing an A-clear halfword at the input
     cell [2,4) keeps MWF (store_window_ok EXCLUDES [2,4), so HMWF_window does
     not cover this -- a separate row, discharged at the capstone via
     MWFReal.mwf_real_input; NO new trust). *)
  Hypothesis HMWF_input : forall mm mm' vv,
      MWF mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm'.

  (* SLICE M-DEC: the stack-frame MWF rows for the local-vars arc (the only
     consumer in this file is check_ground_dive_or_punch's unused _filler
     local).  Both discharge from MWFReal at the capstone (mwf_real_alloc /
     mwf_real_free) -- NO new trust. *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.

  (* the set_mario_action keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* SLICE M3: drop_and_set_mario_action -- REUSED from ObjectLeafSurface
     .dasma_row (the dasma trio externals routed through Hpres_obj_ext). *)
  Let Hdasma : call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    dasma_row lp LO_mario LO_mario_step LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl).

  (* play_sound_if_no_flag -- REUSED from ObjectLeafSurface.psinf_row (its
     internal walk routes the only external, mario._play_sound, through
     Hcpx_psound).  The landing leaves' optional sound site. *)
  Let Hpsinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag :=
    ObjectLeafSurface.psinf_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.

  (* play_mario_jump_sound -- REUSED from ObjectLeafSurface.pmjs_row (its walk
     routes the only external mario._play_sound through Hcpx_psound).  The
     quicksand keystone's audio site. *)
  Let Hpmjs : call_pres lp bm NoA MWF mario._play_mario_jump_sound :=
    ObjectLeafSurface.pmjs_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.

  Lemma mov_sids_rows : forall fid, mem_id fid mov_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma mov_sma_xids_rows : forall fid, mem_id fid mov_sma_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sma_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma mov_asa_xids_rows : forall fid, mem_id fid mov_asa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma mov_cgka_xids_rows : forall fid, mem_id fid mov_cgka_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_cgka_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_hard_back_xids_rows : forall fid, mem_id fid mov_hard_back_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_hard_back_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_gbonk_xids_rows : forall fid, mem_id fid mov_gbonk_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_gbonk_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  (* ---- the shared mario.prog / mario_step.prog helper rows ---- *)
  Lemma mov_mgfc_row : call_pres lp bm NoA MWF mario._mario_get_floor_class.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_get_floor_class mario.f_mario_get_floor_class
             nil nil nil nil LO_mario mov_mgfc_pin mov_mgfc_vars mov_mgfc_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mgfc_walk.
  Qed.

  Lemma mov_mfis_ids_rows : forall fid,
      mem_id fid (mario._mario_get_floor_class :: nil) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    discriminate H.
  Qed.

  Lemma mov_mfis_row : call_pres lp bm NoA MWF mario._mario_floor_is_slope.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_floor_is_slope mario.f_mario_floor_is_slope
             (mario._mario_get_floor_class :: nil) nil nil nil
             LO_mario mov_mfis_pin mov_mfis_vars mov_mfis_pok).
    - exact mov_mfis_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mfis_walk.
  Qed.

  Lemma mov_msfv_row : call_pres lp bm NoA MWF mario._mario_set_forward_vel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_set_forward_vel mario.f_mario_set_forward_vel
             nil nil nil nil LO_mario mov_msfv_pin mov_msfv_vars mov_msfv_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_msfv_walk.
  Qed.

  Lemma mov_iae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_at_end mario.f_is_anim_at_end
             nil nil nil nil LO_mario mov_iae_pin mov_iae_vars mov_iae_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_iae_walk.
  Qed.

  Lemma mov_sma_row : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation mario.f_set_mario_animation
             nil nil mov_sma_cact mov_sma_xids nil
             LO_mario mov_sma_pin mov_sma_vars mov_sma_pok mov_sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sma_walk.
  Qed.

  Lemma mov_mums_row :
    call_pres lp bm NoA MWF mario_step._mario_update_moving_sand.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_moving_sand
             mario_step.f_mario_update_moving_sand
             nil nil nil nil LO_mario_step mov_mums_pin mov_mums_vars mov_mums_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mums_walk.
  Qed.

  Lemma mov_muwg_row :
    call_pres lp bm NoA MWF mario_step._mario_update_windy_ground.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_windy_ground
             mario_step.f_mario_update_windy_ground
             nil nil nil nil LO_mario_step mov_muwg_pin mov_muwg_vars mov_muwg_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_muwg_walk.
  Qed.

  (* ---- apply_slope_accel: ids = floor helpers + moving_sand/windy_ground ---- *)
  Lemma mov_asa_ids_rows : forall fid, mem_id fid mov_asa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_muwg_row | ].
    discriminate H.
  Qed.

  Lemma mov_asa_row : call_pres lp bm NoA MWF mario_actions_moving._apply_slope_accel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._apply_slope_accel
             mario_actions_moving.f_apply_slope_accel
             mov_asa_ids nil mov_asa_xids nil
             LO_mov mov_asa_pin mov_asa_vars mov_asa_pok).
    - exact mov_asa_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asa_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asa_walk.
  Qed.

  (* ---- apply_landing_accel: ids = apply_slope_accel + floor + set_fwd_vel ---- *)
  Lemma mov_ala_ids_rows : forall fid, mem_id fid mov_ala_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ala_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_ala_row : call_pres lp bm NoA MWF mario_actions_moving._apply_landing_accel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._apply_landing_accel
             mario_actions_moving.f_apply_landing_accel
             mov_ala_ids nil nil nil
             LO_mov mov_ala_pin mov_ala_vars mov_ala_pok).
    - exact mov_ala_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ala_walk.
  Qed.

  (* ---- common_ground_knockback_action: the cluster keystone ---- *)
  Lemma mov_cgka_ids_rows : forall fid, mem_id fid mov_cgka_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_cgka_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_ala_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    discriminate H.
  Qed.

  Lemma mov_cgka_row :
    call_pres lp bm NoA MWF mario_actions_moving._common_ground_knockback_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._common_ground_knockback_action
             mario_actions_moving.f_common_ground_knockback_action
             mov_cgka_ids nil mov_cgka_xids mov_sids
             LO_mov mov_cgka_pin mov_cgka_vars mov_cgka_pok).
    - exact mov_cgka_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_cgka_xids_rows.
    - exact mov_sids_rows.
    - exact mov_cgka_walk.
  Qed.

  (* the leaves' ids = common_ground_knockback_action (call_pres) *)
  Lemma mov_cgka_only_rows : forall fid, mem_id fid mov_cgka_only = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_cgka_only in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_cgka_row | ].
    discriminate H.
  Qed.

  (* ---- the 7 knockback leaves (body_pres) ---- *)
  Lemma mov_bkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_backward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_backward_ground_kb
             mov_cgka_only nil nil nil nil mov_bkb_vars mov_bkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_bkb_walk.
  Qed.

  Lemma mov_fkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_forward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_forward_ground_kb
             mov_cgka_only nil nil nil nil mov_fkb_vars mov_fkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_fkb_walk.
  Qed.

  Lemma mov_sbkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_soft_backward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_soft_backward_ground_kb
             mov_cgka_only nil nil nil nil mov_sbkb_vars mov_sbkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sbkb_walk.
  Qed.

  Lemma mov_sfkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_soft_forward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_soft_forward_ground_kb
             mov_cgka_only nil nil nil nil mov_sfkb_vars mov_sfkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sfkb_walk.
  Qed.

  Lemma mov_hbkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hard_backward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hard_backward_ground_kb
             mov_cgka_only nil mov_hard_back_xids mov_sids nil
             mov_hbkb_vars mov_hbkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - exact mov_hard_back_xids_rows.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_hbkb_walk.
  Qed.

  Lemma mov_hfkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hard_forward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hard_forward_ground_kb
             mov_cgka_only nil nil mov_sids nil
             mov_hfkb_vars mov_hfkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_hfkb_walk.
  Qed.

  Lemma mov_gbonk_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_ground_bonk.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_ground_bonk
             mov_cgka_only nil mov_gbonk_xids nil nil
             mov_gbonk_vars mov_gbonk_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - exact mov_gbonk_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_gbonk_walk.
  Qed.

  (* ---- SLICE M2: act_death_exit_land (body_pres) ---- *)
  Lemma mov_del_ids_rows : forall fid, mem_id fid mov_del_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_del_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_ala_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    discriminate H.
  Qed.

  Lemma mov_del_xids_rows : forall fid, mem_id fid mov_del_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_del_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_del_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_death_exit_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_death_exit_land
             mov_del_ids nil mov_del_xids mov_sids nil
             mov_del_vars mov_del_pok).
    - exact mov_del_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_del_xids_rows.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_del_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE M3: the set_jumping_action arc + act_finish_turning_around.  *)
  (* ================================================================== *)

  (* mario_floor_is_steep: mario_facing_downhill + mario_get_floor_class
     (the two generic ActWriterSurface rows). *)
  Lemma mov_mfist_ids_rows : forall fid, mem_id fid mov_mfist_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_mfist_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (mfd_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                 HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    discriminate H.
  Qed.

  Lemma mov_mfist_row : call_pres lp bm NoA MWF mario._mario_floor_is_steep.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_floor_is_steep mario.f_mario_floor_is_steep
             mov_mfist_ids nil nil nil
             LO_mario mov_mfist_pin mov_mfist_vars mov_mfist_pok).
    - exact mov_mfist_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mfist_walk.
  Qed.

  (* set_steep_jump_action: marioObj chase store (cact=[_t'10]) + sqrtf/atan2s
     + drop_and_set_mario_action (Hdasma). *)
  Lemma mov_sssja_xids_rows : forall fid, mem_id fid mov_sssja_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sssja_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._atan2s eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_sssja_sids_rows : forall fid, mem_id fid mov_sssja_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sssja_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_sssja_row : call_pres lp bm NoA MWF mario._set_steep_jump_action.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_steep_jump_action mario.f_set_steep_jump_action
             nil nil mov_sssja_cact mov_sssja_xids mov_sssja_sids
             LO_mario mov_sssja_pin mov_sssja_vars mov_sssja_pok mov_sssja_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sssja_xids_rows.
    - exact mov_sssja_sids_rows.
    - exact mov_sssja_walk.
  Qed.

  (* set_jumping_action: call_pres_act (threads _action to set_mario_action). *)
  Lemma mov_sja_ids_rows : forall fid, mem_id fid mov_sja_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sja_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfist_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sssja_row | ].
    discriminate H.
  Qed.

  Lemma mov_sja_row : call_pres_act lp bm NoA MWF mario._set_jumping_action.
  Proof.
    apply (call_pres_act_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_jumping_action mario.f_set_jumping_action
             (mario._action :: mario._t'1 :: mario._t'2 :: nil)
             mov_sja_ids mov_sids nil nil mov_sids
             LO_mario mov_sja_pin mov_sja_vars mov_sja_params mov_sja_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact mov_sja_ids_rows.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sids_rows.
    - exact mov_sja_walk.
  Qed.

  (* update_walking_speed: apply_slope_accel + approach_s32(ext) + window. *)
  Lemma mov_uws_ids_rows : forall fid, mem_id fid mov_uws_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uws_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    discriminate H.
  Qed.

  Lemma mov_uws_xids_rows : forall fid, mem_id fid mov_uws_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uws_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario_actions_object._approach_s32 eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_uws_row : call_pres lp bm NoA MWF mario_actions_moving._update_walking_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_walking_speed
             mario_actions_moving.f_update_walking_speed
             mov_uws_ids nil mov_uws_xids nil
             LO_mov mov_uws_pin mov_uws_vars mov_uws_pok).
    - exact mov_uws_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uws_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uws_walk.
  Qed.

  (* the leaf: ids + the marioObj non-ptr chase store (cact=[_t'5]) +
     sids = set_mario_action + set_jumping_action. *)
  Lemma mov_ftn_ids_rows : forall fid, mem_id fid mov_ftn_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ftn_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uws_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma mov_ftn_sids_rows : forall fid, mem_id fid mov_ftn_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ftn_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    discriminate H.
  Qed.

  Lemma mov_ftn_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_finish_turning_around.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_finish_turning_around
             mov_ftn_ids nil mov_ftn_cact nil mov_ftn_sids nil
             mov_ftn_vars mov_ftn_pok mov_ftn_nonparam).
    - exact mov_ftn_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ftn_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ftn_walk.
  Qed.

  (* ---- SLICE M4: check_common_moving_cancels (the common cancel gate) ---- *)
  Lemma mov_swpa_xids_rows : forall fid, mem_id fid mov_swpa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_swpa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._set_camera_mode eq_refl) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._vec3s_set eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_swpa_row : call_pres lp bm NoA MWF mario._set_water_plunge_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_water_plunge_action mario.f_set_water_plunge_action
             nil nil mov_swpa_xids mov_sids
             LO_mario mov_swpa_pin mov_swpa_vars mov_swpa_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_swpa_xids_rows.
    - exact mov_sids_rows.
    - exact mov_swpa_walk.
  Qed.

  Lemma mov_ccmc_ids_rows : forall fid, mem_id fid mov_ccmc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ccmc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_swpa_row | ].
    discriminate H.
  Qed.

  Lemma mov_ccmc_sids_rows : forall fid, mem_id fid mov_ccmc_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ccmc_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ccmc_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_check_common_moving_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_check_common_moving_cancels
             mov_ccmc_ids nil nil mov_ccmc_sids nil mov_ccmc_vars mov_ccmc_pok).
    - exact mov_ccmc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ccmc_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ccmc_walk.
  Qed.

  (* ---- SLICE M5: act_hold_walking + the shared anim/audio np3 subtree ---- *)
  (* set_mario_anim_with_accel: the np3 leaf (val0C 3rd arg = float-cast). *)
  Lemma mov_smawa_xids_rows : forall fid, mem_id fid mov_smawa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_smawa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma mov_smawa_row :
    call_pres_np3 lp bm NoA MWF mario._set_mario_anim_with_accel.
  Proof.
    apply (call_pres_np3_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_anim_with_accel
             mario.f_set_mario_anim_with_accel
             nil nil mov_smawa_cact mov_smawa_xids nil
             LO_mario mov_smawa_pin mov_smawa_vars mov_smawa_params
             mov_smawa_cm mov_smawa_canim mov_smawa_cacc).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_smawa_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_smawa_walk.
  Qed.

  (* play_sound_and_spawn_particles: window stores + play_sound external. *)
  Lemma mov_pssp_xids_rows : forall fid, mem_id fid mov_pssp_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_pssp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_pssp_row :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_and_spawn_particles
             mario.f_play_sound_and_spawn_particles
             nil nil mov_pssp_xids nil
             LO_mario mov_pssp_pin mov_pssp_vars mov_pssp_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_pssp_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_pssp_walk.
  Qed.

  Lemma mov_iapf_row : call_pres lp bm NoA MWF mario._is_anim_past_frame.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_frame mario.f_is_anim_past_frame
             nil nil nil nil LO_mario mov_iapf_pin mov_iapf_vars mov_iapf_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_iapf_walk.
  Qed.

  (* play_step_sound: is_anim_past_frame + play_sound_and_spawn_particles + play_sound. *)
  Lemma mov_pss_ids_rows : forall fid, mem_id fid mov_pss_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_pss_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iapf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pssp_row | ].
    discriminate H.
  Qed.

  Lemma mov_pss_row :
    call_pres lp bm NoA MWF mario_actions_moving._play_step_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._play_step_sound
             mario_actions_moving.f_play_step_sound
             mov_pss_ids nil mov_pssp_xids nil
             LO_mov mov_pss_pin mov_pss_vars mov_pss_pok).
    - exact mov_pss_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_pssp_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_pss_walk.
  Qed.

  (* should_begin_sliding: mario_facing_downhill (read-only). *)
  Lemma mov_sbs_ids_rows : forall fid, mem_id fid mov_sbs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sbs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (mfd_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                 HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    discriminate H.
  Qed.

  Lemma mov_sbs_row :
    call_pres lp bm NoA MWF mario_actions_moving._should_begin_sliding.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._should_begin_sliding
             mario_actions_moving.f_should_begin_sliding
             mov_sbs_ids nil nil nil
             LO_mov mov_sbs_pin mov_sbs_vars mov_sbs_pok).
    - exact mov_sbs_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sbs_walk.
  Qed.

  (* anim_and_audio_for_hold_walk: the np3 caller via call_pres_of_wwalk_nids. *)
  Lemma mov_aahw_ids_rows : forall fid, mem_id fid mov_aahw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_aahw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pss_row | ].
    discriminate H.
  Qed.

  Lemma mov_aahw_np3_rows : forall fid, mem_id fid mov_aahw_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_aahw_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_smawa_row | ].
    discriminate H.
  Qed.

  Lemma mov_aahw_row :
    call_pres lp bm NoA MWF mario_actions_moving._anim_and_audio_for_hold_walk.
  Proof.
    apply (call_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._anim_and_audio_for_hold_walk
             mario_actions_moving.f_anim_and_audio_for_hold_walk
             mov_aahw_ids nil nil nil nil nil mov_aahw_nids mov_aahw_np3
             LO_mov mov_aahw_pin mov_aahw_vars mov_aahw_pok
             eq_refl mov_aahw_nonparam_n).
    - exact mov_aahw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_aahw_np3_rows.
    - exact mov_aahw_walk.
  Qed.

  (* the leaf: act_hold_walking. *)
  Lemma mov_ahw_ids_rows : forall fid, mem_id fid mov_ahw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_aahw_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uws_row | ].
    discriminate H.
  Qed.

  Lemma mov_ahw_xids_rows : forall fid, mem_id fid mov_ahw_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahw_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext interaction._segmented_to_virtual eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_ahw_sids_rows : forall fid, mem_id fid mov_ahw_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahw_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ahw_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hold_walking.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hold_walking
             mov_ahw_ids nil mov_ahw_xids mov_ahw_sids nil
             mov_ahw_vars mov_ahw_pok).
    - exact mov_ahw_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahw_xids_rows.
    - exact mov_ahw_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahw_walk.
  Qed.

  (* ---- SLICE M6: act_hold_heavy_walking (reuses the M5 subtree) ---- *)
  Lemma mov_aahh_row :
    call_pres lp bm NoA MWF mario_actions_moving._anim_and_audio_for_heavy_walk.
  Proof.
    apply (call_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._anim_and_audio_for_heavy_walk
             mario_actions_moving.f_anim_and_audio_for_heavy_walk
             mov_aahw_ids nil nil nil nil nil mov_aahh_nids mov_aahw_np3
             LO_mov mov_aahh_pin mov_aahh_vars mov_aahh_pok
             eq_refl mov_aahh_nonparam_n).
    - exact mov_aahw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_aahw_np3_rows.
    - exact mov_aahh_walk.
  Qed.

  Lemma mov_ahhw_ids_rows : forall fid, mem_id fid mov_ahhw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahhw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_aahh_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uws_row | ].
    discriminate H.
  Qed.

  Lemma mov_ahhw_sids_rows : forall fid, mem_id fid mov_ahhw_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahhw_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ahhw_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hold_heavy_walking.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hold_heavy_walking
             mov_ahhw_ids nil nil mov_ahhw_sids nil
             mov_ahhw_vars mov_ahhw_pok).
    - exact mov_ahhw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ahhw_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahhw_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE M7: the slide helper subtree + act_slide_kick_slide.         *)
  (* ================================================================== *)

  (* mario_bonk_reflection: faceAngle[1] window store + atan2s/play_sound ext
     + mario_set_forward_vel (mario_step.prog). *)
  Lemma mov_mbr_ids_rows : forall fid, mem_id fid mov_mbr_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_mbr_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_mbr_xids_rows : forall fid, mem_id fid mov_mbr_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_mbr_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_obj_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_mbr_row :
    call_pres lp bm NoA MWF mario_step._mario_bonk_reflection.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_bonk_reflection
             mario_step.f_mario_bonk_reflection
             mov_mbr_ids nil mov_mbr_xids nil
             LO_mario_step mov_mbr_pin mov_mbr_vars mov_mbr_pok).
    - exact mov_mbr_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_mbr_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_mbr_walk.
  Qed.

  (* update_sliding_angle: window stores + atan2s/sqrtf ext + sand/wind. *)
  Lemma mov_usa_ids_rows : forall fid, mem_id fid mov_usa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_muwg_row | ].
    discriminate H.
  Qed.

  Lemma mov_usa_xids_rows : forall fid, mem_id fid mov_usa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_obj_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma mov_usa_row :
    call_pres lp bm NoA MWF mario_actions_moving._update_sliding_angle.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_sliding_angle
             mario_actions_moving.f_update_sliding_angle
             mov_usa_ids nil mov_usa_xids nil
             LO_mov mov_usa_pin mov_usa_vars mov_usa_pok).
    - exact mov_usa_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usa_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usa_walk.
  Qed.

  (* update_sliding: forwardVel window store + sqrtf ext + floor helpers
     + update_sliding_angle. *)
  Lemma mov_usl_ids_rows : forall fid, mem_id fid mov_usl_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_usa_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_usl_xids_rows : forall fid, mem_id fid mov_usl_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usl_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma mov_usl_row :
    call_pres lp bm NoA MWF mario_actions_moving._update_sliding.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_sliding
             mario_actions_moving.f_update_sliding
             mov_usl_ids nil mov_usl_xids nil
             LO_mov mov_usl_pin mov_usl_vars mov_usl_pok).
    - exact mov_usl_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usl_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usl_walk.
  Qed.

  (* act_slide_kick_slide leaf (body_pres): const-action sids + slide subtree. *)
  Lemma mov_sks_ids_rows : forall fid, mem_id fid mov_sks_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sks_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_usl_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mbr_row | ].
    discriminate H.
  Qed.

  Lemma mov_sks_sids_rows : forall fid, mem_id fid mov_sks_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sks_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma mov_sks_xids_rows : forall fid, mem_id fid mov_sks_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sks_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_sks_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_slide_kick_slide.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_slide_kick_slide
             mov_sks_ids nil mov_sks_xids mov_sks_sids nil
             mov_sks_vars mov_sks_pok).
    - exact mov_sks_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sks_xids_rows.
    - exact mov_sks_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sks_walk.
  Qed.

  (* ---- SLICE M8: update_decelerating_speed + adjust_sound_for_speed
     + act_hold_decelerating (the val0C np3 leaf). ---- *)
  Lemma mov_uds_ids_rows : forall fid, mem_id fid mov_uds_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uds_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_muwg_row | ].
    discriminate H.
  Qed.

  Lemma mov_uds_xids_rows : forall fid, mem_id fid mov_uds_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uds_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_uds_row :
    call_pres lp bm NoA MWF mario_actions_moving._update_decelerating_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_decelerating_speed
             mario_actions_moving.f_update_decelerating_speed
             mov_uds_ids nil mov_uds_xids nil
             LO_mov mov_uds_pin mov_uds_vars mov_uds_pok).
    - exact mov_uds_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uds_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uds_walk.
  Qed.

  Lemma mov_asfs_xids_rows : forall fid, mem_id fid mov_asfs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asfs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_obj_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_asfs_row :
    call_pres lp bm NoA MWF mario._adjust_sound_for_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._adjust_sound_for_speed
             mario.f_adjust_sound_for_speed
             nil nil mov_asfs_xids nil
             LO_mario mov_asfs_pin mov_asfs_vars mov_asfs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_asfs_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asfs_walk.
  Qed.

  Lemma mov_ahd_ids_rows : forall fid, mem_id fid mov_ahd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uds_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mbr_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pss_row | ].
    discriminate H.
  Qed.

  Lemma mov_ahd_sids_rows : forall fid, mem_id fid mov_ahd_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahd_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ahd_xids_rows : forall fid, mem_id fid mov_ahd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_ahd_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hold_decelerating.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hold_decelerating
             mov_ahd_ids nil nil mov_ahd_xids mov_ahd_sids nil
             mov_ahd_nids mov_ahd_np3
             mov_ahd_vars mov_ahd_pok eq_refl mov_ahd_nonparam_n).
    - exact mov_ahd_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahd_xids_rows.
    - exact mov_ahd_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_aahw_np3_rows.
    - exact mov_ahd_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE M-DEC: act_decelerating (A-gated np3 hybrid).                   *)
  (* ==================================================================== *)

  (* the one new helper: check_ground_dive_or_punch -- an engine body
     (sids = set_mario_action: its 2 inline action consts are untainted but
     one has actionArg=1, so they route through the sids channel) with an
     unused _filler stack local (call_pres_of_lwalk, lids=nil). *)
  Lemma mov_cgdop_row :
    call_pres lp bm NoA MWF mario_actions_moving._check_ground_dive_or_punch.
  Proof.
    apply (call_pres_of_lwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             HMWF_alloc HMWF_free
             mario_actions_moving.prog
             mario_actions_moving._check_ground_dive_or_punch
             mario_actions_moving.f_check_ground_dive_or_punch
             nil nil nil (mario._set_mario_action :: nil)
             LO_mov mov_cgdop_pin mov_cgdop_params).
    - intros g Hg HIn. vm_compute in HIn.
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg. discriminate Hg.
    - intros g Hg. discriminate Hg.
    - intros g Hg. discriminate Hg.
    - intros g Hg HIn. vm_compute in HIn.
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intro HIn. vm_compute in HIn. destruct HIn as [E | []]. discriminate E.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H. cbn [map fst existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - exact cgdop_walk.
  Qed.

  Lemma dec_ids_rows : forall fid, mem_id fid dec_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dec_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_cgdop_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uds_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mbr_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pss_row | ].
    discriminate H.
  Qed.

  Lemma dec_sids_rows : forall fid, mem_id fid dec_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dec_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma dec_xids_rows : forall fid, mem_id fid dec_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dec_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma dec_np3_rows : forall fid, mem_id fid dec_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dec_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_smawa_row | ].
    discriminate H.
  Qed.

  (* the generic-subtree discharger: ONE wwalk_pres call (np3-aware), dec
     census; threads nptr_inv (dec_nids). *)
  Lemma dec_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g dec_ids = true -> e ! g = None) ->
      (forall g, mem_id g dec_xids = true -> e ! g = None) ->
      (forall g, mem_id g dec_sids = true -> e ! g = None) ->
      (forall g, mem_id g dec_np3 = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      dec_gen s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB dec_cact le ->
      nptr_inv dec_nids le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB dec_cact le' /\ nptr_inv dec_nids le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
           Hchk Htat Hact Hch Hnp HN HM HV HS Hexec.
    unfold dec_gen in Hchk.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil dec_ids nil dec_cact dec_xids dec_sids nil
                nil nil nil nil dec_nids dec_np3
                dec_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                dec_xids_rows
                dec_sids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                dec_np3_rows
                _ _ _ _ _ _ _ _
                (fun Hne => match Hne eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x Hub_s
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_n3 Hubgt
                Hchk Htat Hact Hch Hnp HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & Hnp' & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' (conj Hch' Hnp'))))))).
  Qed.

  (* THE KILL CONSUMPTION: the canonical A-gate under the carried MWF
     (input_a_clear via HMWF_inp) provably takes ELSE; the tainted
     set_jump_from_landing in THEN is DEAD CODE on a no-A run. *)
  Lemma dec_gate_pres :
    forall t6 sTHEN sELSE e le m0 tr le' m' out,
      Pos.eqb t6 mario_actions_airborne._m = false ->
      mem_id t6 dec_cact = false ->
      dec_gen sELSE = true ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Ssequence
           (Sset t6 (Efield (Ederef (Etempvar mario_actions_airborne._m
                               (tptr (Tstruct mario._MarioState noattr)))
                       (Tstruct mario._MarioState noattr))
               mario._input tushort))
           (Sifthenelse (Ebinop Oand (Etempvar t6 tushort)
               (Econst_int (Int.repr 2) tint) tint) sTHEN sELSE))
        tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g dec_ids = true -> e ! g = None) ->
      (forall g, mem_id g dec_xids = true -> e ! g = None) ->
      (forall g, mem_id g dec_sids = true -> e ! g = None) ->
      (forall g, mem_id g dec_np3 = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB dec_cact le ->
      nptr_inv dec_nids le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB dec_cact le' /\ nptr_inv dec_nids le'.
  Proof.
    intros t6 sTHEN sELSE e le m0 tr le' m' out Hneq Hnmem HgenE Hexec
           Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt Htat Hact Hch Hnp HN HM HV HS.
    assert (Hle_m : le ! mario_actions_airborne._m
                    = Some (Vptr bm Ptrofs.zero)).
    { inv Hexec.
      - match goal with
        | H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ Out_normal |- _ => inv H1
        end.
        match goal with
        | Hev : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
            destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev)
              as (bc0 & oc0 & Hle0)
        end.
        destruct (Htat _ _ Hle0) as [-> ->]. exact Hle0.
      - match goal with
        | H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ => destruct (Hne eq_refl)
        end. }
    destruct (input_a_gate_takes_else_lp lp LO_mario
                mario_actions_airborne._m t6 sTHEN sELSE
                _ _ _ _ _ _ _ _ Hle_m (HMWF_inp _ HM) Hexec)
      as (vi & Hload & Hmask & Helse).
    assert (Htat' : forall b o,
        (PTree.set t6 (Vint vi) le) ! mario_actions_airborne._m
        = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg'.
      rewrite PTree.gso in Hg'
        by (intro EE; rewrite <- EE in Hneq; vm_compute in Hneq;
            discriminate Hneq).
      exact (Htat _ _ Hg'). }
    assert (Hact' : act_inv nil (PTree.set t6 (Vint vi) le))
      by (intros t' Hmem' x Hg'; discriminate Hmem').
    assert (Hch' : chase_inv SafeB dec_cact (PTree.set t6 (Vint vi) le)).
    { intros t' Hmem' b o Hg'.
      rewrite PTree.gso in Hg'
        by (intro EE; rewrite EE in Hmem'; rewrite Hmem' in Hnmem;
            discriminate Hnmem).
      exact (Hch _ Hmem' _ _ Hg'). }
    assert (Hnp' : nptr_inv dec_nids (PTree.set t6 (Vint vi) le)).
    { intros t' Hmem' v' Hg'.
      destruct (Pos.eq_dec t' t6) as [-> | Hne].
      - rewrite PTree.gss in Hg'. injection Hg' as <-.
        intros bb oo E; discriminate E.
      - rewrite PTree.gso in Hg' by exact Hne.
        exact (Hnp _ Hmem' _ Hg'). }
    exact (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
             HgenE Htat' Hact' Hch' Hnp' HN HM HV HS Helse).
  Qed.

  (* the hybrid walk prover: exec-derivation induction; generic subtrees go
     to dec_generic; the A-gate goes to dec_gate_pres (the KILL). *)
  Lemma dec_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g dec_ids = true -> e ! g = None) ->
      (forall g, mem_id g dec_xids = true -> e ! g = None) ->
      (forall g, mem_id g dec_sids = true -> e ! g = None) ->
      (forall g, mem_id g dec_np3 = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      dec_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB dec_cact le ->
      nptr_inv dec_nids le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB dec_cact le' /\ nptr_inv dec_nids le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
             Hchk Htat Hact Hch Hnp HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch Hnp))))))).
    - (* Sassign *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
                Hg Htat Hact Hch Hnp HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
                Hg Htat Hact Hch Hnp HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
                Hg Htat Hact Hch Hnp HN HM HV HS);
        eapply exec_Scall; eauto.
    - (* Sbuiltin *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ unfold dec_gen in Hg; cbn [wwalk_chk'] in Hg; discriminate Hg
        | discriminate Hsp ].
    - (* Sseq_1: generic, THE A-GATE, or recurse *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest].
      { eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3
                  Hubgt Hg Htat Hact Hch Hnp HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply orb_true_iff in Hrest as [Hgate | Hand].
      + destruct (dec_gate_shape _ _ Hgate)
          as (t6 & sTHEN & sELSE & -> & -> & Hneq & Hnmem & HgenE).
        eapply dec_gate_pres; try eassumption.
        eapply exec_Sseq_1; eauto.
      + apply andb_prop in Hand as [H1 H2].
        destruct (IHHexec1 Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt H1
                    Htat Hact Hch Hnp HN HM HV HS)
          as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1 & Hnp1).
        exact (IHHexec2 Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt H2
                 Htat1 Hact1 Hch1 Hnp1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest].
      { eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3
                  Hubgt Hg Htat Hact Hch Hnp HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply orb_true_iff in Hrest as [Hgate | Hand].
      + exfalso.
        destruct (dec_gate_shape _ _ Hgate)
          as (t6 & sTHEN & sELSE & -> & -> & _ & _ & _).
        match goal with
        | H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ => exact (Hne eq_refl)
        end.
      + apply andb_prop in Hand as [H1 _].
        exact (IHHexec Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt H1
                 Htat Hact Hch Hnp HN HM HV HS).
    - (* Sifthenelse *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3
                  Hubgt Hg Htat Hact Hch Hnp HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch Hnp))))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch Hnp))))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch Hnp))))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact (conj Hch Hnp))))))).
    - (* Sloop stop1 *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
                Hg Htat Hact Hch Hnp HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2 *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
                Hg Htat Hact Hch Hnp HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
                Hg Htat Hact Hch Hnp HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic, or the case-selection descent *)
      cbn [dec_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hls].
      { eapply (dec_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hub_n3
                  Hubgt Hg Htat Hact Hch Hnp HN HM HV HS);
          eapply exec_Sswitch; eauto. }
      exact (IHHexec Hub_g Hub_i Hub_x Hub_s Hub_n3 Hubgt
               (dec_chk_select _ _ Hls) Htat Hact Hch Hnp HN HM HV HS).
  Qed.

  (* THE LEAF: fn_vars = nil, 1 param _m; the body goes to dec_pres. *)
  Lemma mov_dec_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_decelerating.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hmargf Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    match goal with
    | Hb : exec_stmt _ _ ?E _ _ _ _ _ _ _ |- _ => set (eloc := E) in *
    end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    destruct Hca as (HVa & HSa & HMa & HNa).
    assert (Hps : match fn_params mario_actions_moving.f_act_decelerating
                  with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpn : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params
                             mario_actions_moving.f_act_decelerating))))
              dec_nids = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params mario_actions_moving.f_act_decelerating)
      as [| [i ty] ps ] eqn:Eps; [ discriminate Hps | ].
    apply andb_prop in Hps as [Hps Hnm].
    apply andb_prop in Hps as [Hi Hty].
    apply Pos.eqb_eq in Hi. subst i.
    destruct (type_eq ty tyMSp); [ subst ty | discriminate Hty ].
    apply negb_true_iff in Hnm.
    destruct vargs0 as [| v0 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    match goal with
    | Hbind' : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
        assert (Htat0 : forall b o,
                   le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero)
          by (intros b o Hg;
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnm) in Hg;
              rewrite PTree.gss in Hg; injection Hg as ->;
              cbn in Hmarg; exact Hmarg);
        assert (Hact0 : act_inv nil le1)
          by (intros t' Hmem' x Hg'; discriminate Hmem');
        assert (Hch0 : chase_inv SafeB dec_cact le1)
          by (intros t' Hmem' b o Hg'; discriminate Hmem');
        assert (Hnp0 : nptr_inv dec_nids le1)
          by (intros t' Hmem' v' Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpn Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              rewrite EE; intros bb oo E2; discriminate E2)
    end.
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_i : forall g, mem_id g dec_ids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_x : forall g, mem_id g dec_xids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_s : forall g, mem_id g dec_sids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_n3 : forall g, mem_id g dec_np3 = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_gt : eloc ! interaction._gGlobalTimer = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._gGlobalTimer)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    destruct (dec_pres _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_x Hub_s Hub_n3 Hub_gt
                dec_walk Htat0 Hact0 Hch0 Hnp0 HNa HMa HVa HSa)
      as (HVb & HSb & HMb & HNb & _ & _ & _ & _).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* ---- SLICE M9: the param-action leaf act_turning_around ---- *)

  (* analog_stick_held_back: pure read-only (reads intendedYaw/faceAngle[1]) *)
  Lemma mov_ashb_row :
    call_pres lp bm NoA MWF mario_actions_moving._analog_stick_held_back.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._analog_stick_held_back
             mario_actions_moving.f_analog_stick_held_back
             nil nil nil nil LO_mov mov_ashb_pin mov_ashb_vars mov_ashb_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ashb_walk.
  Qed.

  (* apply_slope_decel: mario_get_floor_class + apply_slope_accel + approach_f32 *)
  Lemma mov_asd_ids_rows : forall fid, mem_id fid mov_asd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    discriminate H.
  Qed.

  Lemma mov_asd_xids_rows : forall fid, mem_id fid mov_asd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_asd_row :
    call_pres lp bm NoA MWF mario_actions_moving._apply_slope_decel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._apply_slope_decel
             mario_actions_moving.f_apply_slope_decel
             mov_asd_ids nil mov_asd_xids nil
             LO_mov mov_asd_pin mov_asd_vars mov_asd_pok).
    - exact mov_asd_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asd_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asd_walk.
  Qed.

  (* ================================================================== *)
  (* common_landing_action: the bespoke funcall lift (airAction = an     *)
  (* untainted const).  Its body walks under the wwalk engine with        *)
  (* _airAction in wact; the non-action callees route through the rows    *)
  (* above.  NOT a generic call_pres -- it is keyed to untainted aval.    *)
  (* ================================================================== *)
  Lemma cla_ids_rows : forall fid, mem_id fid cla_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cla_ids in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [Hm | H];
            [ apply Pos.eqb_eq in Hm; subst fid | ]).
    - exact Hcp_pgs.
    - exact mov_ala_row.
    - exact mov_asd_row.
    - exact mov_sma_row.
    - discriminate H.
  Qed.

  Lemma cla_xids_rows : forall fid, mem_id fid cla_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cla_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid
      | discriminate H ].
    exact (Hpres_mov_ext mario_actions_moving._play_mario_landing_sound_once
             eq_refl).
  Qed.

  Lemma cla_sids_rows : forall fid, mem_id fid cla_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cla_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  (* MARG form: first arg via tat0, so a non-pointer m is handled vacuously
     by the engine (wwalk_pres0's tat precondition is itself marg-shaped). *)
  Lemma cla_funcall_pres :
    forall fd m0 v0 vanim av t0 m1 vres0,
      resolves_lp lp mario_actions_moving._common_landing_action fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: vanim :: Vint av :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint av) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 vanim av t0 m1 vres0 Hres Hevf Htat Huav HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._common_landing_action
                  mario_actions_moving.f_common_landing_action fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_common_landing_action)
        with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params mario_actions_moving.f_common_landing_action)
      with ((mario_actions_moving._m,
             tptr (Tstruct mario_actions_moving._MarioState noattr)) ::
            (mario_actions_moving._animation, tshort) ::
            (mario_actions_moving._airAction, tuint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_common_landing_action)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._airAction (Vint av)
          (PTree.set mario_actions_moving._animation vanim
             (PTree.set mario_actions_moving._m v0 base)))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as Hg. exact (Htat b o Hg). }
    assert (Hact0 : act_inv (mario_actions_moving._airAction :: nil)
       (PTree.set mario_actions_moving._airAction (Vint av)
          (PTree.set mario_actions_moving._animation vanim
             (PTree.set mario_actions_moving._m v0 base)))).
    { intros t' Hmem' x Hg'.
      cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hf]; [ | discriminate Hf ].
      apply Pos.eqb_eq in Ht; subst t'.
      rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huav. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._airAction (Vint av)
          (PTree.set mario_actions_moving._animation vanim
             (PTree.set mario_actions_moving._m v0 base))))
      by (intros t' Hmem'; discriminate Hmem').
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false (mario_actions_moving._airAction :: nil) cla_ids nil nil
                cla_xids cla_sids nil
                cla_ids_rows ltac:(intros fid HH; discriminate HH)
                cla_xids_rows cla_sids_rows ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) ltac:(vm_compute; reflexivity) Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ================================================================== *)
  (* QUICKSAND KEYSTONE: quicksand_jump_land_action(m,a1,a2,endA,airA).    *)
  (* TWO param-action seeds, both written via set_mario_action; the rest   *)
  (* are window stores + already-rowed helper calls.                       *)
  (* ================================================================== *)
  Lemma qjla_ids_rows : forall fid, mem_id fid qjla_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold qjla_ids in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [Hm | H];
            [ apply Pos.eqb_eq in Hm; subst fid | ]).
    - exact Hcp_pgs.
    - exact mov_ala_row.
    - exact mov_sma_row.
    - exact Hpmjs.
    - discriminate H.
  Qed.

  Lemma qjla_sids_rows : forall fid, mem_id fid qjla_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold qjla_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  Lemma qjla_funcall_pres :
    forall fd m0 v0 va1 va2 endA airA t0 m1 vres0,
      resolves_lp lp mario_actions_moving._quicksand_jump_land_action fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: va1 :: va2 :: Vint endA :: Vint airA :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint endA) -> untainted_scalar (Vint airA) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 va1 va2 endA airA t0 m1 vres0 Hres Hevf Htat Huea Huaa
           HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._quicksand_jump_land_action
                  mario_actions_moving.f_quicksand_jump_land_action fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_quicksand_jump_land_action)
        with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params mario_actions_moving.f_quicksand_jump_land_action)
      with ((mario_actions_moving._m,
             tptr (Tstruct mario_actions_moving._MarioState noattr)) ::
            (mario_actions_moving._animation1, tint) ::
            (mario_actions_moving._animation2, tint) ::
            (mario_actions_moving._endAction, tuint) ::
            (mario_actions_moving._airAction, tuint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_quicksand_jump_land_action)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._airAction (Vint airA)
          (PTree.set mario_actions_moving._endAction (Vint endA)
             (PTree.set mario_actions_moving._animation2 va2
                (PTree.set mario_actions_moving._animation1 va1
                   (PTree.set mario_actions_moving._m v0 base)))))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as Hg. exact (Htat b o Hg). }
    assert (Hact0 : act_inv qjla_wact
       (PTree.set mario_actions_moving._airAction (Vint airA)
          (PTree.set mario_actions_moving._endAction (Vint endA)
             (PTree.set mario_actions_moving._animation2 va2
                (PTree.set mario_actions_moving._animation1 va1
                   (PTree.set mario_actions_moving._m v0 base)))))).
    { intros t' Hmem' x Hg'.
      unfold qjla_wact in Hmem'. cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      - apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huea.
      - apply orb_true_iff in Hmem' as [Ht | Hf]; [ | discriminate Hf ].
        apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huaa. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._airAction (Vint airA)
          (PTree.set mario_actions_moving._endAction (Vint endA)
             (PTree.set mario_actions_moving._animation2 va2
                (PTree.set mario_actions_moving._animation1 va1
                   (PTree.set mario_actions_moving._m v0 base))))))
      by (intros t' Hmem'; discriminate Hmem').
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false qjla_wact qjla_ids nil nil nil qjla_sids nil
                qjla_ids_rows ltac:(intros fid HH; discriminate HH)
                ltac:(intros fid HH; discriminate HH) qjla_sids_rows
                ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) ltac:(vm_compute; reflexivity) Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* the quicksand leaf call site: Scall (Some tcap) of quicksand_jump_land_
     action with (Etempvar _m, Econst a1, Econst a2, Econst endA, Econst airA),
     both endA and airA vm-checkably untainted.  Preserves + restores the _m
     tat (the captured result is a fresh temp). *)
  Lemma qjla_capture_site_pres :
    forall tcap a1 a2 endA airA le m tr le' m' out,
      tcap <> M._m ->
      wact_const (Int.repr endA) = true ->
      wact_const (Int.repr airA) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some tcap)
           (Evar M._quicksand_jump_land_action
              (Tfunction (tyMSp :: tint :: tint :: tuint :: tuint :: nil)
                 tint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr a1) tint
            :: Econst_int (Int.repr a2) tint
            :: Econst_int (Int.repr endA) tint
            :: Econst_int (Int.repr airA) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tcap a1 a2 endA airA le m tr le' m' out Hcap Hea Haa Htat Hexec
           HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._quicksand_jump_land_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    (* a1 (arbitrary cast -> va1) *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    (* a2 (arbitrary cast -> va2) *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    (* endA (cast tint->tuint pinned to Vint endA) *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr endA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    (* airA (cast tint->tuint pinned to Vint airA) *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr airA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (qjla_funcall_pres _ _ _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hea) (wact_const_sound _ Haa)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hcap (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* ================================================================== *)
  (* SLIDE_BONK keystone: slide_bonk(m, fastAction, slowAction).          *)
  (* TWO param-action seeds (fastAction via drop_and_set_mario_action,    *)
  (* slowAction via set_mario_action); no direct stores.                  *)
  (* ================================================================== *)
  Lemma sb_ids_rows : forall fid, mem_id fid sb_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sb_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mbr_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | discriminate H ].
  Qed.

  Lemma sb_sids_rows : forall fid, mem_id fid sb_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sb_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  Lemma sbonk_funcall_pres :
    forall fd m0 v0 fastA slowA t0 m1 vres0,
      resolves_lp lp mario_actions_moving._slide_bonk fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: Vint fastA :: Vint slowA :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint fastA) -> untainted_scalar (Vint slowA) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 fastA slowA t0 m1 vres0 Hres Hevf Htat Hufa Husa
           HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._slide_bonk
                  mario_actions_moving.f_slide_bonk fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_slide_bonk)
        with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params mario_actions_moving.f_slide_bonk)
      with ((mario_actions_moving._m,
             tptr (Tstruct mario_actions_moving._MarioState noattr)) ::
            (mario_actions_moving._fastAction, tuint) ::
            (mario_actions_moving._slowAction, tuint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_slide_bonk)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._slowAction (Vint slowA)
          (PTree.set mario_actions_moving._fastAction (Vint fastA)
             (PTree.set mario_actions_moving._m v0 base)))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as Hg. exact (Htat b o Hg). }
    assert (Hact0 : act_inv sb_wact
       (PTree.set mario_actions_moving._slowAction (Vint slowA)
          (PTree.set mario_actions_moving._fastAction (Vint fastA)
             (PTree.set mario_actions_moving._m v0 base)))).
    { intros t' Hmem' x Hg'.
      unfold sb_wact in Hmem'. cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      - apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Hufa.
      - apply orb_true_iff in Hmem' as [Ht | Hf]; [ | discriminate Hf ].
        apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Husa. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._slowAction (Vint slowA)
          (PTree.set mario_actions_moving._fastAction (Vint fastA)
             (PTree.set mario_actions_moving._m v0 base))))
      by (intros t' Hmem'; discriminate Hmem').
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false sb_wact sb_ids nil nil nil sb_sids nil
                sb_ids_rows ltac:(intros fid HH; discriminate HH)
                ltac:(intros fid HH; discriminate HH) sb_sids_rows
                ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) ltac:(vm_compute; reflexivity) Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* the slide_bonk call site: Scall None of slide_bonk with args
     (Etempvar _m, Econst fastA, Econst slowA), both fastA/slowA untainted. *)
  Lemma sbonk_site_pres :
    forall (c2 c3 : int) e le m tr le' m' out,
      e ! M._slide_bonk = None ->
      wact_const c2 = true ->
      wact_const c3 = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Scall None
           (Evar M._slide_bonk
              (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int c2 tint
            :: Econst_int c3 tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros c2 c3 e le m tr le' m' out Hsbn Hfa Hsa Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ Hsbn Hv) as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._slide_bonk fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint c2) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint c3) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (sbonk_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hfa) (wact_const_sound _ Hsa)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat b o Hg).
  Qed.

  (* ================================================================== *)
  (* act_burning_ground: a CLEAN basic-engine walk (chase cact = the      *)
  (* marioObj asS32 temps + the marioBodyState eyeState temp).            *)
  (* ================================================================== *)
  Lemma abg_ids_rows : forall fid, mem_id fid abg_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold abg_ids in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [Hm | H];
            [ apply Pos.eqb_eq in Hm; subst fid | ]).
    - exact mov_asa_row.
    - exact Hcp_pgs.
    - exact mov_pss_row.
    - discriminate H.
  Qed.

  Lemma abg_np3_rows : forall fid, mem_id fid abg_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold abg_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_smawa_row
      | discriminate H ].
  Qed.

  Lemma abg_xids_rows : forall fid, mem_id fid abg_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold abg_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario_actions_object._approach_s32 eq_refl) | ].
    discriminate H.
  Qed.

  Lemma abg_sids_rows : forall fid, mem_id fid abg_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold abg_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  (* ================================================================== *)
  (* act_braking (190L): a twl-style induction HYBRID.  The body is a    *)
  (* right-nested Ssequence of 5 blocks; everything is PURE-ENGINE        *)
  (* (window store m->particleFlags, marioObj chase-load t'8 for          *)
  (* play_sound, censused helper calls) EXCEPT one site: a switch case-2  *)
  (* `slide_bonk(m, 132194, 201327165)` (Scall None, two untainted const  *)
  (* action params -- fits no engine channel; the sbonk keystone covers   *)
  (* it).  bk_chk recurses the engine generic arm into Ssequence/Sif/     *)
  (* Sswitch and accepts the slide_bonk leaf via bk_sp_chk; bk_pres is an  *)
  (* exec_stmt induction that sends generic subtrees to bk_generic         *)
  (* (wwalk_pres0 wholesale) and the slide_bonk site to sbonk_site_pres.   *)
  (* ================================================================== *)

  (* check_common_action_exits: cross-file reuse of the stationary row. *)
  Let Hccae : call_pres lp bm NoA MWF mario._check_common_action_exits :=
    StationaryLeafSurface.sta_ccae_row lp LO_mario LO_mario_step bm NoA MWF
      HNoA_of_MWF HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  Definition bk_ids : list ident :=
    M._check_common_action_exits :: M._apply_slope_decel
      :: M._perform_ground_step :: M._adjust_sound_for_speed
      :: M._set_mario_animation :: nil.
  Definition bk_sids : list ident := M._set_mario_action :: nil.
  Definition bk_xids : list ident := M._play_sound :: nil.
  Definition bk_cact : list ident := M._t'8 :: nil.

  Lemma bk_ids_rows : forall fid, mem_id fid bk_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bk_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hccae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | discriminate H ].
  Qed.

  Lemma bk_xids_rows : forall fid, mem_id fid bk_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bk_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.

  Lemma bk_sids_rows : forall fid, mem_id fid bk_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bk_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  (* the slide_bonk site recognizer: Scall None of slide_bonk with args
     (Etempvar _m, Econst c2, Econst c3), both c2/c3 untainted; the full
     function/arg type shape pinned so the inversion is concrete. *)
  Definition bk_sp_chk (fid : ident) (fty : type) (al : list expr) : bool :=
    Pos.eqb fid M._slide_bonk
    && proj_sumbool
         (type_eq fty (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default))
    && match al with
       | Etempvar p pty :: Econst_int c2 ct2 :: Econst_int c3 ct3 :: nil =>
           Pos.eqb p M._m
           && proj_sumbool (type_eq pty tyMSp)
           && proj_sumbool (type_eq ct2 tint)
           && proj_sumbool (type_eq ct3 tint)
           && wact_const c2 && wact_const c3
       | _ => false
       end.

  Fixpoint bk_chk (s : statement) : bool :=
    wwalk_chk false nil bk_ids nil bk_cact bk_xids bk_sids nil s
    || match s with
       | Ssequence s1 s2 => bk_chk s1 && bk_chk s2
       | Sifthenelse _ s1 s2 => bk_chk s1 && bk_chk s2
       | Sswitch _ sl => bk_chk_ls sl
       | Scall None (Evar fid fty) al => bk_sp_chk fid fty al
       | _ => false
       end
  with bk_chk_ls (sl : labeled_statements) : bool :=
    match sl with
    | LSnil => true
    | LScons _ s sl' => bk_chk s && bk_chk_ls sl'
    end.

  (* ---- the switch-selection transfer (mirror of the engine's) ---- *)
  Lemma bk_chk_ls_seq : forall sl,
      bk_chk_ls sl = true -> bk_chk (seq_of_labeled_statement sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H.
    - reflexivity.
    - cbn [seq_of_labeled_statement]. cbn [bk_chk_ls] in H.
      apply andb_prop in H as [H1 H2].
      cbn [bk_chk]. apply orb_true_iff. right.
      rewrite H1, (IH H2). reflexivity.
  Qed.

  Lemma bk_chk_ls_case : forall n sl sl',
      bk_chk_ls sl = true ->
      select_switch_case n sl = Some sl' ->
      bk_chk_ls sl' = true.
  Proof.
    intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
    - discriminate Hsel.
    - cbn [bk_chk_ls] in H. apply andb_prop in H as [H1 H2].
      destruct o as [c|]; cbn [select_switch_case] in Hsel.
      + destruct (zeq c n).
        * injection Hsel as <-. cbn [bk_chk_ls]. rewrite H1, H2. reflexivity.
        * exact (IH sl' H2 Hsel).
      + exact (IH sl' H2 Hsel).
  Qed.

  Lemma bk_chk_ls_default : forall sl,
      bk_chk_ls sl = true -> bk_chk_ls (select_switch_default sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H.
    - exact H.
    - cbn [bk_chk_ls] in H. apply andb_prop in H as [H1 H2].
      destruct o as [c|]; cbn [select_switch_default].
      + exact (IH H2).
      + cbn [bk_chk_ls]. rewrite H1, H2. reflexivity.
  Qed.

  Lemma bk_chk_select : forall n sl,
      bk_chk_ls sl = true ->
      bk_chk (seq_of_labeled_statement (select_switch n sl)) = true.
  Proof.
    intros n sl H. apply bk_chk_ls_seq.
    unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - exact (bk_chk_ls_case _ _ _ H E).
    - exact (bk_chk_ls_default _ H).
  Qed.

  (* Scall inversion: either the generic engine accepts it, or it is the
     slide_bonk site (concrete shape). *)
  Lemma bk_chk_scall_inv : forall optid a al,
      bk_chk (Scall optid a al) = true ->
      wwalk_chk false nil bk_ids nil bk_cact bk_xids bk_sids nil
        (Scall optid a al) = true
      \/ (optid = None /\ exists fid fty,
            a = Evar fid fty /\ bk_sp_chk fid fty al = true).
  Proof.
    intros optid a al H. cbn [bk_chk] in H.
    apply orb_true_iff in H as [Hg | Hsp]; [ left; exact Hg | right ].
    destruct optid as [t'|]; [ discriminate Hsp | ].
    destruct a as [ i0 t0 | f0 t0 | f0 t0 | i0 t0 | fid fty | id0 t0
                  | a0 t0 | a0 t0 | op a0 t0 | op a1 a2 t0 | a0 t0
                  | a0 f0 t0 | t1 t0 | t1 t0 ]; try discriminate Hsp.
    split; [ reflexivity | ]. exists fid, fty. split; [ reflexivity | exact Hsp ].
  Qed.

  Lemma bk_sp_chk_shape : forall fid fty al,
      bk_sp_chk fid fty al = true ->
      exists c2 c3,
        fid = M._slide_bonk /\
        fty = Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default /\
        al = Etempvar M._m tyMSp :: Econst_int c2 tint :: Econst_int c3 tint :: nil
        /\ wact_const c2 = true /\ wact_const c3 = true.
  Proof.
    intros fid fty al H. unfold bk_sp_chk in H.
    apply andb_prop in H as [H Hal].
    apply andb_prop in H as [Hfid Hfty].
    apply Pos.eqb_eq in Hfid. subst fid.
    destruct (type_eq fty (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default));
      [ subst fty | discriminate Hfty ].
    destruct al as [| a0 al0]; [ discriminate Hal | ].
    destruct a0 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hal.
    destruct al0 as [| a1 al1]; [ discriminate Hal | ].
    destruct a1 as [ c2 ct2 | | | | | | | | | | | | | ]; try discriminate Hal.
    destruct al1 as [| a2 al2]; [ discriminate Hal | ].
    destruct a2 as [ c3 ct3 | | | | | | | | | | | | | ]; try discriminate Hal.
    destruct al2 as [| a3 al3]; [ | discriminate Hal ].
    apply andb_prop in Hal as [Hal Hc3].
    apply andb_prop in Hal as [Hal Hc2].
    apply andb_prop in Hal as [Hal Hct3].
    apply andb_prop in Hal as [Hal Hct2].
    apply andb_prop in Hal as [Hp Hpty].
    apply Pos.eqb_eq in Hp. subst p.
    destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
    destruct (type_eq ct2 tint); [ subst ct2 | discriminate Hct2 ].
    destruct (type_eq ct3 tint); [ subst ct3 | discriminate Hct3 ].
    exists c2, c3. repeat split; assumption.
  Qed.

  (* the generic engine wrapper: wwalk_pres0 wholesale for a subtree the
     pure census accepts. *)
  Lemma bk_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g bk_ids = true -> e ! g = None) ->
      (forall g, mem_id g bk_xids = true -> e ! g = None) ->
      (forall g, mem_id g bk_sids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk false nil bk_ids nil bk_cact bk_xids bk_sids nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB bk_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv nil le' /\ chase_inv SafeB bk_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hub_s Hubgt Hchk
           Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil bk_ids nil bk_cact bk_xids bk_sids nil
                bk_ids_rows ltac:(intros fid HH; discriminate HH)
                bk_xids_rows bk_sids_rows ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hexec
                Hub_g Hub_i ltac:(intros g HH; discriminate HH) Hub_x Hub_s
                ltac:(intros g HH; discriminate HH) Hubgt
                Hchk Htat Hact Hch HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* THE HYBRID WALK: exec-derivation induction.  Generic subtrees go to
     bk_generic; the slide_bonk site to sbonk_site_pres. *)
  Lemma bk_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g bk_ids = true -> e ! g = None) ->
      (forall g, mem_id g bk_xids = true -> e ! g = None) ->
      (forall g, mem_id g bk_sids = true -> e ! g = None) ->
      e ! M._slide_bonk = None ->
      e ! interaction._gGlobalTimer = None ->
      bk_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB bk_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv nil le' /\ chase_inv SafeB bk_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic censused arm, or the slide_bonk site *)
      destruct (bk_chk_scall_inv _ _ _ Hchk)
        as [Hg | (-> & fid & fty & -> & Hsp)].
      { eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (bk_sp_chk_shape _ _ _ Hsp) as (c2 & c3 & -> & -> & -> & Hc2 & Hc3).
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall None
                         (Evar M._slide_bonk
                            (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid
                               cc_default))
                         (Etempvar M._m tyMSp :: Econst_int c2 tint
                          :: Econst_int c3 tint :: nil))
                      t (set_opttemp None vres le) m' Out_normal)
        by (eapply exec_Scall; eauto).
      destruct (sbonk_site_pres c2 c3 e le m _ _ _ _ Hsbn Hc2 Hc3 Htat Hex
                  HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & _).
      cbn [set_opttemp].
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (conj Htat (conj Hact Hch)))))).
    - (* Sbuiltin: rejected by both arms *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk wwalk_chk'] in Hg; discriminate Hg | discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt H1 Htat Hact Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt H2 Htat1 Hact1 Hch1
               HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt H1 Htat Hact Hch
               HN HM HV HS).
    - (* Sifthenelse *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sloop stop1: generic only *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic, or the slide_bonk-bearing labeled body *)
      cbn [bk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (bk_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sswitch; eauto. }
      apply IHHexec; try assumption.
      apply bk_chk_select. exact Hsp.
  Qed.

  Lemma bk_walk : bk_chk (fn_body M.f_act_braking) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma mov_bk_pres : body_pres lp NoA MWF bm M.f_act_braking.
  Proof.
    intros m0 vargs t0 mF vres0 Hmargf Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_braking) with (@nil (ident * type)) in Ha;
      inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params M.f_act_braking)
      with ((M._m, tptr (Tstruct M._MarioState noattr)) :: nil) in Hbind.
    assert (Hmarg : marg_ok bm vargs) by (apply Hmargf; vm_compute; reflexivity).
    destruct vargs as [| v0 vrest]; cbn [bind_parameter_temps] in Hbind;
      [ discriminate Hbind | ].
    destruct vrest as [| v1 vrest']; cbn [bind_parameter_temps] in Hbind;
      [ | discriminate Hbind ].
    injection Hbind as <-.
    set (base := create_undef_temps (fn_temps M.f_act_braking)) in *.
    assert (Htat0 : forall b o,
       (PTree.set M._m v0 base) ! mario_actions_airborne._m = Some (Vptr b o)
       -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hact0 : act_inv nil (PTree.set M._m v0 base))
      by (intros t' Hmem'; discriminate Hmem').
    assert (Hch0 : chase_inv SafeB bk_cact (PTree.set M._m v0 base)).
    { intros t' Hmem' b o Hg'. unfold bk_cact in Hmem'.
      cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hf]; [ | discriminate Hf ].
      apply Pos.eqb_eq in Ht; subst t'.
      rewrite PTree.gso in Hg' by (vm_compute; congruence).
      pose proof (create_undef_temps_val _ _ _ Hg') as EE; discriminate EE. }
    destruct (bk_pres _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (PTree.gempty _ _) (PTree.gempty _ _)
                bk_walk Htat0 Hact0 Hch0 HN HM HV HS)
      as (HVb & HSb & HMb & _ & _ & _ & _).
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z))
      in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HVb (conj HSb HMb)).
  Qed.

  Example mov_bk_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_braking
    = Some (Gfun (Internal mario_actions_moving.f_act_braking)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma mov_abg_pres : body_pres lp NoA MWF bm M.f_act_burning_ground.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             M.f_act_burning_ground abg_ids nil abg_cact abg_xids abg_sids nil
             nil abg_np3
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             abg_ids_rows ltac:(intros fid HH; discriminate HH)
             abg_xids_rows abg_sids_rows ltac:(intros fid HH; discriminate HH)
             abg_np3_rows ltac:(vm_compute; reflexivity)).
  Qed.

  Example mov_abg_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_burning_ground
    = Some (Gfun (Internal mario_actions_moving.f_act_burning_ground)).
  Proof. vm_compute. reflexivity. Qed.

  (* ================================================================== *)
  (* SLICE M-PUNCH: act_move_punching -- a clean engine walk.             *)
  (* All five callees are call_pres helpers with existing rows:           *)
  (*  should_begin_sliding (mov_sbs_row), apply_slope_decel (mov_asd_row), *)
  (*  apply_slope_accel (mov_asa_row), perform_ground_step (Hcp_pgs), and  *)
  (*  mario_update_punch_sequence (ObjectLeafSurface.mups_row, Internal in *)
  (*  mario_actions_object.prog).  set_mario_action via sids (Hsmact).     *)
  (* The four window stores (actionState/forwardVel x2/particleFlags) are  *)
  (* non-pointer m->field writes the engine recognizes structurally.       *)
  (* ================================================================== *)
  Let Hmups : call_pres lp bm NoA MWF
                mario_actions_object._mario_update_punch_sequence :=
    ObjectLeafSurface.mups_row lp LO_mario LO_mario_step LO_int LO_obj bm
      NoA MWF HNoA_of_MWF HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm
      HchaseRoot HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_psound
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl)
      Hcpx_lpt
      (Hpres_obj_ext interaction._atan2s eq_refl)
      (Hpres_obj_ext interaction._virtual_to_segmented eq_refl).

  Lemma mp_ids_rows : forall fid, mem_id fid mp_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmups | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma mp_sids_rows : forall fid, mem_id fid mp_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mp_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma mov_mp_pres : body_pres lp NoA MWF bm M.f_act_move_punching.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             M.f_act_move_punching mp_ids nil nil nil mp_sids nil nil nil
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             mp_ids_rows ltac:(intros fid HH; discriminate HH)
             ltac:(intros fid HH; discriminate HH) mp_sids_rows
             ltac:(intros fid HH; discriminate HH)
             ltac:(intros fid HH; discriminate HH)
             ltac:(vm_compute; reflexivity)).
  Qed.

  Example mov_mp_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_move_punching
    = Some (Gfun (Internal mario_actions_moving.f_act_move_punching)).
  Proof. vm_compute. reflexivity. Qed.

  (* ================================================================== *)
  (* align_with_floor: the bespoke straightline walk (store C = gchase). *)
  (* ================================================================== *)

  (* the global-address VALUE evaluates to a Vptr in sFloorAlignMatrix's
     block (separate lemma to avoid focus nesting in the store proof) *)
  Lemma awf_a2_block :
    forall e le m v,
      e ! mario_actions_moving._sFloorAlignMatrix = None ->
      eval_expr (lp_ge lp) e le m awf_a2 v ->
      forall bb oo, v = Vptr bb oo ->
        Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix
          = Some bb.
  Proof.
    intros e le m v He Hev bb oo Evv.
    unfold awf_a2 in Hev. inv Hev.
    2:{ match goal with
        | Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv
        end. }
    match goal with
    | Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hs; rename Hs into Hsem
    end.
    match goal with
    | Hx : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hx
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; rename Hd into Hdl
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end.
    1:{ match goal with
        | Hl : e ! _ = Some _ |- _ => rewrite He in Hl; discriminate Hl
        end. }
    inv Hdl;
      try (match goal with
           | Hacc : access_mode _ = _ |- _ =>
               cbn in Hacc; discriminate Hacc
           end).
    unfold sem_binary_operation, sem_add, sem_add_ptr_int in Hsem.
    cbn in Hsem.
    match type of Hsem with
    | match ?vi with _ => _ end = _ => destruct vi; try discriminate Hsem
    end.
    all: congruence.
  Qed.

  (* store C: storing &sFloorAlignMatrix[t'2] through the censused chase cell
     marioObj->...->throwMatrix preserves the run facts (the stored value is
     SafeB-if-pointer by Hsfam_safe; HMWF_chase_safe absorbs the store). *)
  Lemma awf_gchase_pres :
    forall e le m0 tr le' m' out,
      mem_id mario_actions_moving._t'1 awf_cact = true ->
      ActWriterSurface.chase_inv SafeB awf_cact le ->
      e ! mario_actions_moving._sFloorAlignMatrix = None ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign awf_a1 awf_a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros e le m0 tr le' m' out Hctm Hch He Hexec HM HV HS.
    inv Hexec.
    assert (Hcr : chain_root_l awf_a1 = Some mario_actions_moving._t'1)
      by reflexivity.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ awf_a1 _ _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv) as (o0 & Hlet)
    end.
    pose proof (Hch _ Hctm _ _ Hlet) as Hsafe.
    pose proof (HSafeNotBm _ Hsafe) as Hneq.
    match goal with
    | Hev2 : eval_expr _ _ _ _ awf_a2 ?vv2 |- _ =>
        assert (Hv2sp : forall bb oo, vv2 = Vptr bb oo -> SafeB bb)
          by (intros bb oo Evv;
              exact (Hsfam_safe _ (awf_a2_block _ _ _ _ He Hev2 _ _ Evv)))
    end.
    match goal with
    | Hcast0 : sem_cast _ _ _ _ = Some ?vw |- _ =>
        assert (Hsp : forall bb oo, vw = Vptr bb oo -> SafeB bb)
          by (intros bb oo Evw; rewrite Evw in Hcast0;
              apply sem_cast_vptr_inv in Hcast0;
              exact (Hv2sp _ _ Hcast0))
    end.
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has
    end.
    - match goal with
      | Hsv0 : Mem.storev _ _ _ _ = Some m' |- _ =>
          unfold Mem.storev in Hsv0
      end.
      match goal with
      | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
          split; [ eauto using Mem.store_valid_block_1 | split ];
          [ intros av Hload;
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
            [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
          | split;
            [ exact (HMWF_chase_safe _ _ _ _ _ _ HM Hsafe Hsp Hsv)
            | split; reflexivity ] ]
      end.
    - match goal with
      | Hac : access_mode (typeof awf_a1) = By_copy |- _ =>
          cbn [typeof access_mode] in Hac; discriminate Hac
      end.
    - match goal with
      | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb
      end.
  Qed.

  (* the generic engine arm: one wwalk_pres0 call over the empty env (mtxf is
     routed through Hpres_mov_ext, its honest terminal-external boundary) *)
  Lemma awf_gen :
    forall s le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0 s tr le' m' out ->
      wwalk_chk false nil nil nil awf_cact awf_xids nil nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      ActWriterSurface.chase_inv SafeB awf_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      ActWriterSurface.chase_inv SafeB awf_cact le'.
  Proof.
    intros s le m0 tr le' m' out Hexec Hchk Htat Hch HN HM HV HS.
    assert (Hxr : forall fid, mem_id fid awf_xids = true ->
                  call_pres_ext lp bm NoA MWF fid).
    { intros fid Hm. unfold awf_xids, mem_id in Hm. cbn [existsb] in Hm.
      apply orb_true_iff in Hm as [He | Hf]; [ | discriminate Hf ].
      apply Pos.eqb_eq in He. subst fid.
      apply Hpres_mov_ext. vm_compute. reflexivity. }
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil nil nil awf_cact awf_xids nil nil
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                Hxr
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                s empty_env le m0 tr le' m' out Hexec
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (PTree.gempty _ _)
                Hchk Htat
                (fun t HH => match Bool.diff_false_true HH with end)
                Hch HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Htat' Hch'))))).
  Qed.

  (* one Ssequence peel: walk the generic prefix s1, hand off s2 *)
  Lemma awf_seq2 :
    forall s1 s2 le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0
        (Ssequence s1 s2) tr le' m' out ->
      wwalk_chk false nil nil nil awf_cact awf_xids nil nil s1 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      ActWriterSurface.chase_inv SafeB awf_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      (exists le1 m1 tr1,
          NoA m1 /\ MWF m1 /\ Mem.valid_block m1 bm /\
          action_sat not_tainted m1 bm /\
          (forall b o, le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
                       b = bm /\ o = Ptrofs.zero) /\
          ActWriterSurface.chase_inv SafeB awf_cact le1 /\
          exec_stmt function_entry2 (lp_ge lp) empty_env le1 m1 s2 tr1
            le' m' out)
      \/ (Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
          NoA m').
  Proof.
    intros s1 s2 le m0 tr le' m' out Hexec Hchk Htat Hch HN HM HV HS.
    inv Hexec.
    - match goal with
      | H1 : exec_stmt _ _ _ _ _ s1 _ ?le1 ?m1 Out_normal,
        H2 : exec_stmt _ _ _ _ _ s2 ?tr2 _ _ _ |- _ =>
          destruct (awf_gen s1 le m0 _ le1 m1 Out_normal H1 Hchk Htat Hch
                      HN HM HV HS)
            as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hch1);
          left; exists le1, m1, tr2;
          exact (conj HN1 (conj HM1 (conj HV1 (conj HS1
                   (conj Htat1 (conj Hch1 H2))))))
      end.
    - match goal with
      | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ _ |- _ =>
          destruct (awf_gen s1 le m0 _ le' m' out H1 Hchk Htat Hch
                      HN HM HV HS)
            as (HV1 & HS1 & HM1 & HN1 & _);
          right; exact (conj HV1 (conj HS1 (conj HM1 HN1)))
      end.
  Qed.

  Lemma align_with_floor_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_align_with_floor.
  Proof.
    intros m0 vargs t0 mF vres Hmargf Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs)
      by (apply Hmargf; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_align_with_floor)
        with (@nil (ident * type)) in Ha;
      inv Ha end.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z))
      in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    assert (Hps : match fn_params mario_actions_moving.f_align_with_floor with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params mario_actions_moving.f_align_with_floor))))
              awf_cact = true) by (vm_compute; reflexivity).
    destruct (fn_params mario_actions_moving.f_align_with_floor)
      as [| [i ty] ps ] eqn:Eps; [ discriminate Hps | ].
    apply andb_prop in Hps as [Hps Hnm].
    apply andb_prop in Hps as [Hi Hty].
    apply Pos.eqb_eq in Hi. subst i.
    destruct (type_eq ty tyMSp); [ subst ty | discriminate Hty ].
    apply negb_true_iff in Hnm.
    destruct vargs as [| v0 vrest];
      cbn [bind_parameter_temps] in *; [ discriminate | ].
    match goal with
    | Hbind' : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
        assert (Htat0 : forall b o,
                   le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero)
          by (intros b o Hg;
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnm) in Hg;
              rewrite PTree.gss in Hg; injection Hg as ->;
              cbn in Hmarg; exact Hmarg);
        assert (Hch0 : ActWriterSurface.chase_inv SafeB awf_cact le1)
          by (intros t' Hmem' b o Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpc Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              discriminate EE)
    end.
    destruct (awf_seq2 _ _ _ _ _ _ _ _ Hbody
                ltac:(vm_compute; reflexivity) Htat0 Hch0 HN HM HV HS)
      as [ (lA & mA & trA & HNA & HMA & HVA & HSA & HtatA & HchA & HbA)
         | Hfin ];
      [ | exact (conj (proj1 Hfin) (conj (proj1 (proj2 Hfin))
                        (proj1 (proj2 (proj2 Hfin))))) ].
    destruct (awf_seq2 _ _ _ _ _ _ _ _ HbA
                ltac:(vm_compute; reflexivity) HtatA HchA HNA HMA HVA HSA)
      as [ (lB & mB & trB & HNB & HMB & HVB & HSB & HtatB & HchB & HbB)
         | Hfin ];
      [ | exact (conj (proj1 Hfin) (conj (proj1 (proj2 Hfin))
                        (proj1 (proj2 (proj2 Hfin))))) ].
    destruct (awf_seq2 _ _ _ _ _ _ _ _ HbB
                ltac:(vm_compute; reflexivity) HtatB HchB HNB HMB HVB HSB)
      as [ (lC & mC & trC & HNC & HMC & HVC0 & HSC0 & HtatC & HchC & HbC)
         | Hfin ];
      [ | exact (conj (proj1 Hfin) (conj (proj1 (proj2 Hfin))
                        (proj1 (proj2 (proj2 Hfin))))) ].
    destruct (awf_seq2 _ _ _ _ _ _ _ _ HbC
                ltac:(vm_compute; reflexivity) HtatC HchC HNC HMC HVC0 HSC0)
      as [ (lD & mD & trD & HND & HMD & HVD & HSD & HtatD & HchD & HbD)
         | Hfin ];
      [ | exact (conj (proj1 Hfin) (conj (proj1 (proj2 Hfin))
                        (proj1 (proj2 (proj2 Hfin))))) ].
    destruct (awf_gchase_pres empty_env lD mD _ _ _ _
                ltac:(vm_compute; reflexivity) HchD (PTree.gempty _ _) HbD
                HMD HVD HSD)
      as (HVc & HSc & HMc & _ & _).
    exact (conj HVc (conj HSc HMc)).
  Qed.

  (* lift align_with_floor's body_pres to a call_pres for the act_crawling
     census (align_with_floor is Internal in mario_actions_moving.prog) *)
  Let mov_awf_cp :
    call_pres lp bm NoA MWF mario_actions_moving._align_with_floor :=
    call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario_actions_moving.prog
      mario_actions_moving._align_with_floor
      mario_actions_moving.f_align_with_floor
      LO_mov ltac:(vm_compute; reflexivity) align_with_floor_pres.

  (* ================================================================== *)
  (* act_crawling: the clean nids-engine consumer of align_with_floor.   *)
  (* ================================================================== *)
  Lemma cr_ids_rows : forall fid, mem_id fid cr_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cr_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_cgdop_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uws_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pss_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_awf_cp | ].
    discriminate H.
  Qed.

  Lemma cr_sids_rows : forall fid, mem_id fid cr_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cr_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    discriminate H.
  Qed.

  Lemma cr_np3_rows : forall fid, mem_id fid cr_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cr_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_smawa_row | ].
    discriminate H.
  Qed.

  Lemma mov_cr_pres : body_pres lp NoA MWF bm M.f_act_crawling.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             M.f_act_crawling cr_ids nil nil nil cr_sids nil cr_nids cr_np3
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             cr_ids_rows ltac:(intros fid HH; discriminate HH)
             ltac:(intros fid HH; discriminate HH) cr_sids_rows
             ltac:(intros fid HH; discriminate HH) cr_np3_rows
             ltac:(vm_compute; reflexivity)).
  Qed.

  Example mov_cr_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_crawling
    = Some (Gfun (Internal mario_actions_moving.f_act_crawling)).
  Proof. vm_compute. reflexivity. Qed.
  (* ================================================================== *)
  (* COMMON_SLIDE_ACTION / STOMACH_SLIDE_ACTION keystone (csa + ssa).     *)
  (* Multi-action-param hybrid lift: the slide_bonk param-action site +   *)
  (* _pos out-param lwalk frame + engine-generic for everything else.     *)
  (* Ported from the validated scratch; consumed-row hypotheses replaced  *)
  (* by the real section lemmas (mov_asfs_row/Hcp_pgs/mov_sma_row/        *)
  (* mov_awf_cp/mov_mfisl_row/Hsmact/obj_ext/Hcpx_*/sbonk_funcall_pres/   *)
  (* mov_usl_row/Hdasma).                                                 *)
  (* ================================================================== *)
(* ====================================================================== *)
(* TOP-LEVEL: the csa hybrid recognizer (slide_bonk site special).        *)
(* ====================================================================== *)
Definition csa_wact : list ident := M._airAction :: M._endAction :: nil.
Definition csa_ids : list ident :=
  M._adjust_sound_for_speed :: mario_step._perform_ground_step ::
  mario._set_mario_animation :: M._align_with_floor ::
  mario._mario_floor_is_slippery :: nil.
Definition csa_sids : list ident := mario._set_mario_action :: nil.
Definition csa_xids : list ident :=
  M._vec3f_copy :: mario._play_sound :: interaction._atan2s :: mario._sqrtf :: nil.

Definition csa_sp_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  Pos.eqb fid M._slide_bonk
  && proj_sumbool
       (type_eq fty (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default))
  && match al with
     | Etempvar p pty :: Econst_int c2 ct2 :: Etempvar t3 t3ty :: nil =>
         Pos.eqb p M._m
         && proj_sumbool (type_eq pty tyMSp)
         && proj_sumbool (type_eq ct2 tint)
         && wact_const c2
         && mem_id t3 csa_wact
         && proj_sumbool (type_eq t3ty tuint)
     | _ => false
     end.

Fixpoint csa_chk (s : statement) : bool :=
  wwalk_chk false csa_wact csa_ids nil nil csa_xids csa_sids nil s
  || match s with
     | Ssequence s1 s2 => csa_chk s1 && csa_chk s2
     | Sifthenelse _ s1 s2 => csa_chk s1 && csa_chk s2
     | Sswitch _ sl => csa_chk_ls sl
     | Scall None (Evar fid fty) al => csa_sp_chk fid fty al
     | _ => false
     end
with csa_chk_ls (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => csa_chk s && csa_chk_ls sl'
  end.

Lemma csa_chk_ls_seq : forall sl,
    csa_chk_ls sl = true -> csa_chk (seq_of_labeled_statement sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn [seq_of_labeled_statement]. cbn [csa_chk_ls] in H.
    apply andb_prop in H as [H1 H2].
    cbn [csa_chk]. apply orb_true_iff. right.
    rewrite H1, (IH H2). reflexivity.
Qed.

Lemma csa_chk_ls_case : forall n sl sl',
    csa_chk_ls sl = true ->
    select_switch_case n sl = Some sl' ->
    csa_chk_ls sl' = true.
Proof.
  intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn [csa_chk_ls] in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn [select_switch_case] in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn [csa_chk_ls]. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma csa_chk_ls_default : forall sl,
    csa_chk_ls sl = true -> csa_chk_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn [csa_chk_ls] in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn [select_switch_default].
    + exact (IH H2).
    + cbn [csa_chk_ls]. rewrite H1, H2. reflexivity.
Qed.

Lemma csa_chk_select : forall n sl,
    csa_chk_ls sl = true ->
    csa_chk (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros n sl H. apply csa_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (csa_chk_ls_case _ _ _ H E).
  - exact (csa_chk_ls_default _ H).
Qed.

Lemma csa_chk_scall_inv : forall optid a al,
    csa_chk (Scall optid a al) = true ->
    wwalk_chk false csa_wact csa_ids nil nil csa_xids csa_sids nil
      (Scall optid a al) = true
    \/ (optid = None /\ exists fid fty,
          a = Evar fid fty /\ csa_sp_chk fid fty al = true).
Proof.
  intros optid a al H. cbn [csa_chk] in H.
  apply orb_true_iff in H as [Hg | Hsp]; [ left; exact Hg | right ].
  destruct optid as [t'|]; [ discriminate Hsp | ].
  destruct a as [ i0 t0 | f0 t0 | f0 t0 | i0 t0 | fid fty | id0 t0
                | a0 t0 | a0 t0 | op a0 t0 | op a1 a2 t0 | a0 t0
                | a0 f0 t0 | t1 t0 | t1 t0 ]; try discriminate Hsp.
  split; [ reflexivity | ]. exists fid, fty. split; [ reflexivity | exact Hsp ].
Qed.

Lemma csa_sp_chk_shape : forall fid fty al,
    csa_sp_chk fid fty al = true ->
    exists c2 t3,
      fid = M._slide_bonk /\
      fty = Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default /\
      al = Etempvar M._m tyMSp :: Econst_int c2 tint :: Etempvar t3 tuint :: nil
      /\ wact_const c2 = true /\ mem_id t3 csa_wact = true.
Proof.
  intros fid fty al H. unfold csa_sp_chk in H.
  apply andb_prop in H as [H Hal].
  apply andb_prop in H as [Hfid Hfty].
  apply Pos.eqb_eq in Hfid. subst fid.
  destruct (type_eq fty (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default));
    [ subst fty | discriminate Hfty ].
  destruct al as [| a0 al0]; [ discriminate Hal | ].
  destruct a0 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hal.
  destruct al0 as [| a1 al1]; [ discriminate Hal | ].
  destruct a1 as [ c2 ct2 | | | | | | | | | | | | | ]; try discriminate Hal.
  destruct al1 as [| a2 al2]; [ discriminate Hal | ].
  destruct a2 as [ | | | | | t3 t3ty | | | | | | | | ]; try discriminate Hal.
  destruct al2 as [| a3 al3]; [ | discriminate Hal ].
  apply andb_prop in Hal as [Hal Ht3ty].
  apply andb_prop in Hal as [Hal Ht3mem].
  apply andb_prop in Hal as [Hal Hc2].
  apply andb_prop in Hal as [Hal Hct2].
  apply andb_prop in Hal as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
  destruct (type_eq ct2 tint); [ subst ct2 | discriminate Hct2 ].
  destruct (type_eq t3ty tuint); [ subst t3ty | discriminate Ht3ty ].
  exists c2, t3. repeat split; assumption.
Qed.

(* the recognizer-passes facts (the real AST). *)
Example csa_walk : csa_chk (fn_body M.f_common_slide_action) = true.
Proof. vm_compute. reflexivity. Qed.
(* ====================================================================== *)
(* The common_slide_action CALL SITE (shared by ssa / csaj).              *)
(* 4 args (m, stopA, airA, anim): stopA/airA censused wact temps, anim    *)
(* arbitrary.  Maps to csa_funcall_pres (endAction <- stopA, etc.).       *)
(* ====================================================================== *)
Definition csa_site_chk (wact : list ident) (fid : ident) (fty : type)
    (al : list expr) : bool :=
  Pos.eqb fid M._common_slide_action
  && proj_sumbool
       (type_eq fty (Tfunction (tyMSp :: tuint :: tuint :: tint :: nil) tvoid cc_default))
  && match al with
     | Etempvar p pty :: Etempvar t2 t2ty :: Etempvar t3 t3ty :: a4 :: nil =>
         Pos.eqb p M._m
         && proj_sumbool (type_eq pty tyMSp)
         && mem_id t2 wact && proj_sumbool (type_eq t2ty tuint)
         && mem_id t3 wact && proj_sumbool (type_eq t3ty tuint)
     | _ => false
     end.

Lemma csa_site_chk_shape : forall wact fid fty al,
    csa_site_chk wact fid fty al = true ->
    exists t2 t3 a4,
      fid = M._common_slide_action /\
      fty = Tfunction (tyMSp :: tuint :: tuint :: tint :: nil) tvoid cc_default /\
      al = Etempvar M._m tyMSp :: Etempvar t2 tuint :: Etempvar t3 tuint :: a4 :: nil
      /\ mem_id t2 wact = true /\ mem_id t3 wact = true.
Proof.
  intros wact fid fty al H. unfold csa_site_chk in H.
  apply andb_prop in H as [H Hal].
  apply andb_prop in H as [Hfid Hfty].
  apply Pos.eqb_eq in Hfid. subst fid.
  destruct (type_eq fty (Tfunction (tyMSp :: tuint :: tuint :: tint :: nil) tvoid cc_default));
    [ subst fty | discriminate Hfty ].
  destruct al as [| a0 al0]; [ discriminate Hal | ].
  destruct a0 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hal.
  destruct al0 as [| a1 al1]; [ discriminate Hal | ].
  destruct a1 as [ | | | | | t2 t2ty | | | | | | | | ]; try discriminate Hal.
  destruct al1 as [| a2 al2]; [ discriminate Hal | ].
  destruct a2 as [ | | | | | t3 t3ty | | | | | | | | ]; try discriminate Hal.
  destruct al2 as [| a3 al3]; [ discriminate Hal | ].
  destruct al3 as [| a4 al4]; [ | discriminate Hal ].
  apply andb_prop in Hal as [Hal Ht3ty].
  apply andb_prop in Hal as [Hal Ht3mem].
  apply andb_prop in Hal as [Hal Ht2ty].
  apply andb_prop in Hal as [Hal Ht2mem].
  apply andb_prop in Hal as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
  destruct (type_eq t2ty tuint); [ subst t2ty | discriminate Ht2ty ].
  destruct (type_eq t3ty tuint); [ subst t3ty | discriminate Ht3ty ].
  exists t2, t3, a3. repeat split; assumption.
Qed.

(* ssa hybrid recognizer (stomach_slide_action). *)
Definition ssa_wact : list ident :=
  M._stopAction :: M._airAction :: M._t'1 :: M._t'2 :: M._t'4 :: nil.
Definition ssa_ids : list ident := M._update_sliding :: nil.
Definition ssa_wids : list ident :=
  mario._drop_and_set_mario_action :: mario._set_mario_action :: nil.

Fixpoint ssa_chk (s : statement) : bool :=
  wwalk_chk true ssa_wact ssa_ids ssa_wids nil nil nil nil s
  || match s with
     | Ssequence s1 s2 => ssa_chk s1 && ssa_chk s2
     | Sifthenelse _ s1 s2 => ssa_chk s1 && ssa_chk s2
     | Sswitch _ sl => ssa_chk_ls sl
     | Scall None (Evar fid fty) al => csa_site_chk ssa_wact fid fty al
     | _ => false
     end
with ssa_chk_ls (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => ssa_chk s && ssa_chk_ls sl'
  end.

Lemma ssa_chk_ls_seq : forall sl,
    ssa_chk_ls sl = true -> ssa_chk (seq_of_labeled_statement sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn [seq_of_labeled_statement]. cbn [ssa_chk_ls] in H.
    apply andb_prop in H as [H1 H2].
    cbn [ssa_chk]. apply orb_true_iff. right.
    rewrite H1, (IH H2). reflexivity.
Qed.

Lemma ssa_chk_ls_case : forall n sl sl',
    ssa_chk_ls sl = true ->
    select_switch_case n sl = Some sl' ->
    ssa_chk_ls sl' = true.
Proof.
  intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn [ssa_chk_ls] in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn [select_switch_case] in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn [ssa_chk_ls]. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma ssa_chk_ls_default : forall sl,
    ssa_chk_ls sl = true -> ssa_chk_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn [ssa_chk_ls] in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn [select_switch_default].
    + exact (IH H2).
    + cbn [ssa_chk_ls]. rewrite H1, H2. reflexivity.
Qed.

Lemma ssa_chk_select : forall n sl,
    ssa_chk_ls sl = true ->
    ssa_chk (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros n sl H. apply ssa_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (ssa_chk_ls_case _ _ _ H E).
  - exact (ssa_chk_ls_default _ H).
Qed.

Lemma ssa_chk_scall_inv : forall optid a al,
    ssa_chk (Scall optid a al) = true ->
    wwalk_chk true ssa_wact ssa_ids ssa_wids nil nil nil nil
      (Scall optid a al) = true
    \/ (optid = None /\ exists fid fty,
          a = Evar fid fty /\ csa_site_chk ssa_wact fid fty al = true).
Proof.
  intros optid a al H. cbn [ssa_chk] in H.
  apply orb_true_iff in H as [Hg | Hsp]; [ left; exact Hg | right ].
  destruct optid as [t'|]; [ discriminate Hsp | ].
  destruct a as [ i0 t0 | f0 t0 | f0 t0 | i0 t0 | fid fty | id0 t0
                | a0 t0 | a0 t0 | op a0 t0 | op a1 a2 t0 | a0 t0
                | a0 f0 t0 | t1 t0 | t1 t0 ]; try discriminate Hsp.
  split; [ reflexivity | ]. exists fid, fty. split; [ reflexivity | exact Hsp ].
Qed.

Example ssa_walk : ssa_chk (fn_body M.f_stomach_slide_action) = true.
Proof. vm_compute. reflexivity. Qed.

  (* mario_floor_is_slippery: clean read-only engine body (ids=[mgfc]),
     reuses the shared mov_mfis_ids_rows. *)
  Lemma mov_mfisl_row : call_pres lp bm NoA MWF mario._mario_floor_is_slippery.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_floor_is_slippery mario.f_mario_floor_is_slippery
             (mario._mario_get_floor_class :: nil) nil nil nil
             LO_mario mov_mfisl_pin mov_mfisl_vars mov_mfisl_pok).
    - exact mov_mfis_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mfisl_walk.
  Qed.
  (* ---- the census rows ---- *)
  Lemma csa_ids_rows : forall fid, mem_id fid csa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold csa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_awf_cp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfisl_row | discriminate H ].
  Qed.

  Lemma csa_sids_rows : forall fid, mem_id fid csa_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold csa_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  Lemma csa_xids_rows : forall fid, mem_id fid csa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold csa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact (Hpres_obj_ext M._vec3f_copy eq_refl) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact (Hpres_obj_ext interaction._atan2s eq_refl) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | discriminate H ].
  Qed.

  (* ---- the slide_bonk call site (3rd arg = a wact temp endAction) ---- *)
  Lemma csa_sbonk_site_pres :
    forall (c2 : int) t3 e le m tr le' m' out,
      e ! M._slide_bonk = None ->
      wact_const c2 = true ->
      mem_id t3 csa_wact = true ->
      act_inv csa_wact le ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Scall None
           (Evar M._slide_bonk
              (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int c2 tint
            :: Etempvar t3 tuint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros c2 t3 e le m tr le' m' out Hsbn Hc2 Ht3 Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ Hsbn Hv) as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._slide_bonk fd)
        by (exists fb; split; assumption) end.
    (* arg0: m *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    (* arg1: const c2 *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint c2) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    (* arg2: Etempvar t3, untainted from act_inv *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv3 end.
    pose proof (Hact _ Ht3 _ Hv3) as Hu3.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hc; rename Hc into Hcast3 end.
    destruct Hu3 as [Eu | (w & Eu & Hntw)]; subst.
    { exfalso. cbn in Hcast3. discriminate Hcast3. }
    cbn in Hcast3. injection Hcast3 as <-.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (sbonk_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hc2)
                    (or_intror (ex_intro _ w (conj eq_refl Hntw)))
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat b o Hg).
  Qed.

  (* ---- the generic engine wrapper ---- *)
  Lemma csa_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g csa_ids = true -> e ! g = None) ->
      (forall g, mem_id g csa_xids = true -> e ! g = None) ->
      (forall g, mem_id g csa_sids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk false csa_wact csa_ids nil nil csa_xids csa_sids nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv csa_wact le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv csa_wact le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hub_s Hubgt Hchk
           Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false csa_wact csa_ids nil nil csa_xids csa_sids nil
                csa_ids_rows ltac:(intros fid HH; discriminate HH)
                csa_xids_rows csa_sids_rows ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hexec
                Hub_g Hub_i ltac:(intros g HH; discriminate HH) Hub_x Hub_s
                ltac:(intros g HH; discriminate HH) Hubgt
                Hchk Htat Hact Hch HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* ---- THE HYBRID WALK ---- *)
  Lemma csa_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g csa_ids = true -> e ! g = None) ->
      (forall g, mem_id g csa_xids = true -> e ! g = None) ->
      (forall g, mem_id g csa_sids = true -> e ! g = None) ->
      e ! M._slide_bonk = None ->
      e ! interaction._gGlobalTimer = None ->
      csa_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv csa_wact le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv csa_wact le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic, or the slide_bonk site *)
      destruct (csa_chk_scall_inv _ _ _ Hchk)
        as [Hg | (-> & fid & fty & -> & Hsp)].
      { eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (csa_sp_chk_shape _ _ _ Hsp) as (c2 & t3 & -> & -> & -> & Hc2 & Ht3).
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall None
                         (Evar M._slide_bonk
                            (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid
                               cc_default))
                         (Etempvar M._m tyMSp :: Econst_int c2 tint
                          :: Etempvar t3 tuint :: nil))
                      t (set_opttemp None vres le) m' Out_normal)
        by (eapply exec_Scall; eauto).
      destruct (csa_sbonk_site_pres c2 t3 e le m _ _ _ _ Hsbn Hc2 Ht3 Hact Htat Hex
                  HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & _).
      cbn [set_opttemp].
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (conj Htat (conj Hact Hch)))))).
    - (* Sbuiltin: rejected *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk wwalk_chk'] in Hg; discriminate Hg | discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt H1 Htat Hact Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt H2 Htat1 Hact1 Hch1
               HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_x Hub_s Hsbn Hubgt H1 Htat Hact Hch
               HN HM HV HS).
    - (* Sifthenelse *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sloop stop1 *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2 *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch *)
      cbn [csa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sswitch; eauto. }
      apply IHHexec; try assumption.
      apply csa_chk_select. exact Hsp.
  Qed.

  (* ---- the multi-action-param funcall lift (with lwalk frame) ---- *)
  Lemma csa_funcall_pres :
    forall fd m0 v0 endA airA anim t0 m1 vres0,
      resolves_lp lp M._common_slide_action fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: Vint endA :: Vint airA :: anim :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint endA) -> untainted_scalar (Vint airA) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 endA airA anim t0 m1 vres0 Hres Hevf Htat Huea Huaa
           HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._common_slide_action
                  mario_actions_moving.f_common_slide_action fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    match goal with
    | Hb : exec_stmt _ _ ?E _ _ _ _ _ _ _ |- _ => set (eloc := E) in *
    end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV
         | split; [ exact HS | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    destruct Hca as (HVa & HSa & HMa & HNa).
    (* the bound env: le1 = set _animation (set _airAction (set _endAction (set _m v0 base))) *)
    change (fn_params mario_actions_moving.f_common_slide_action)
      with ((mario_actions_moving._m, tyMSp) ::
            (mario_actions_moving._endAction, tuint) ::
            (mario_actions_moving._airAction, tuint) ::
            (mario_actions_moving._animation, tint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_common_slide_action)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._endAction (Vint endA)
                (PTree.set mario_actions_moving._m v0 base))))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as ->. exact (Htat _ _ eq_refl). }
    assert (Hact0 : act_inv csa_wact
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._endAction (Vint endA)
                (PTree.set mario_actions_moving._m v0 base))))).
    { intros t' Hmem' x Hg'.
      unfold csa_wact in Hmem'. cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      - apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huaa.
      - apply orb_true_iff in Hmem' as [Ht | Hf]; [ | discriminate Hf ].
        apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huea. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._endAction (Vint endA)
                (PTree.set mario_actions_moving._m v0 base)))))
      by (intros t' Hmem'; discriminate Hmem').
    (* the e!g=None premises (each census id <> _pos) *)
    assert (Hub_g : forall g, mem_id g stored_globals = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars mario_actions_moving.f_common_slide_action)
                 empty_env _ _ Halloc g).
      - apply PTree.gempty.
      - vm_compute in Hg |- *. intro HIn.
        repeat (destruct HIn as [HE | HIn]; [ subst g; discriminate Hg | ]).
        exact HIn. }
    assert (Hub_i : forall g, mem_id g csa_ids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars mario_actions_moving.f_common_slide_action)
                 empty_env _ _ Halloc g).
      - apply PTree.gempty.
      - vm_compute in Hg |- *. intro HIn.
        destruct HIn as [HE | []]. subst g. discriminate Hg. }
    assert (Hub_x : forall g, mem_id g csa_xids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars mario_actions_moving.f_common_slide_action)
                 empty_env _ _ Halloc g).
      - apply PTree.gempty.
      - vm_compute in Hg |- *. intro HIn.
        destruct HIn as [HE | []]. subst g. discriminate Hg. }
    assert (Hub_s : forall g, mem_id g csa_sids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars mario_actions_moving.f_common_slide_action)
                 empty_env _ _ Halloc g).
      - apply PTree.gempty.
      - vm_compute in Hg |- *. intro HIn.
        destruct HIn as [HE | []]. subst g. discriminate Hg. }
    assert (Hub_sb : eloc ! M._slide_bonk = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars mario_actions_moving.f_common_slide_action)
                 empty_env _ _ Halloc M._slide_bonk).
      - apply PTree.gempty.
      - vm_compute. intro HIn. destruct HIn as [HE | []]. discriminate HE. }
    assert (Hub_gt : eloc ! interaction._gGlobalTimer = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars mario_actions_moving.f_common_slide_action)
                 empty_env _ _ Halloc interaction._gGlobalTimer).
      - apply PTree.gempty.
      - vm_compute. intro HIn. destruct HIn as [HE | []]. discriminate HE. }
    destruct (csa_pres _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_x Hub_s Hub_sb Hub_gt
                csa_walk Htat0 Hact0 Hch0 HNa HMa HVa HSa)
      as (HVb & HSb & HMb & HNb & _ & _ & _).
    pose proof (blocks_of_env_bm lp bm m0
                  (fn_vars mario_actions_moving.f_common_slide_action) eloc _
                  Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ m1
                  Hforall Hfree (conj HVb (conj HSb (conj HMb HNb)))) as Hcf.
    destruct Hcf as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf (conj HMf HNf))).
  Qed.
  Lemma csa_call_site_pres :
    forall wact t2 t3 a4 e le m tr le' m' out,
      e ! M._common_slide_action = None ->
      mem_id t2 wact = true -> mem_id t3 wact = true ->
      act_inv wact le ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Scall None
           (Evar M._common_slide_action
              (Tfunction (tyMSp :: tuint :: tuint :: tint :: nil) tvoid cc_default))
           (Etempvar M._m tyMSp :: Etempvar t2 tuint :: Etempvar t3 tuint
            :: a4 :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros wact t2 t3 a4 e le m tr le' m' out Hcsn Ht2 Ht3 Hact Htat Hexec
           HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ Hcsn Hv) as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_slide_action fd)
        by (exists fb; split; assumption) end.
    (* arg0: m *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    (* arg1: Etempvar t2, untainted from act_inv *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv2 end.
    pose proof (Hact _ Ht2 _ Hv2) as Hu2.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hc; rename Hc into Hcast2 end.
    destruct Hu2 as [Eu | (w2 & Eu & Hntw2)]; subst.
    { exfalso. cbn in Hcast2. discriminate Hcast2. }
    cbn in Hcast2. injection Hcast2 as <-.
    (* arg2: Etempvar t3, untainted from act_inv *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv3 end.
    pose proof (Hact _ Ht3 _ Hv3) as Hu3.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hc; rename Hc into Hcast3 end.
    destruct Hu3 as [Eu | (w3 & Eu & Hntw3)]; subst.
    { exfalso. cbn in Hcast3. discriminate Hcast3. }
    cbn in Hcast3. injection Hcast3 as <-.
    (* arg3: a4 arbitrary -> some value anim *)
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (csa_funcall_pres _ _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (or_intror (ex_intro _ w2 (conj eq_refl Hntw2)))
                    (or_intror (ex_intro _ w3 (conj eq_refl Hntw3)))
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat b o Hg).
  Qed.

  (* ---- ssa census rows ---- *)
  Lemma ssa_ids_rows : forall fid, mem_id fid ssa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ssa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_usl_row | discriminate H ].
  Qed.

  Lemma ssa_wids_rows : forall fid, mem_id fid ssa_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ssa_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  (* ---- ssa generic engine wrapper (rt=true, wids) ---- *)
  Lemma ssa_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g ssa_ids = true -> e ! g = None) ->
      (forall g, mem_id g ssa_wids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk true ssa_wact ssa_ids ssa_wids nil nil nil nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv ssa_wact le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv ssa_wact le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_w Hubgt Hchk
           Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                true ssa_wact ssa_ids ssa_wids nil nil nil nil
                ssa_ids_rows ssa_wids_rows ltac:(intros fid HH; discriminate HH)
                ltac:(intros fid HH; discriminate HH) ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hexec
                Hub_g Hub_i Hub_w ltac:(intros g HH; discriminate HH)
                ltac:(intros g HH; discriminate HH) ltac:(intros g HH; discriminate HH) Hubgt
                Hchk Htat Hact Hch HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* ---- THE ssa HYBRID WALK ---- *)
  Lemma ssa_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g ssa_ids = true -> e ! g = None) ->
      (forall g, mem_id g ssa_wids = true -> e ! g = None) ->
      e ! M._common_slide_action = None ->
      e ! interaction._gGlobalTimer = None ->
      ssa_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv ssa_wact le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv ssa_wact le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_w Hcsn Hubgt Hchk Htat Hact Hch HN HM HV HS.
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - destruct (ssa_chk_scall_inv _ _ _ Hchk)
        as [Hg | (-> & fid & fty & -> & Hsp)].
      { eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (csa_site_chk_shape _ _ _ _ Hsp) as (t2 & t3 & a4 & -> & -> & -> & Ht2 & Ht3).
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall None
                         (Evar M._common_slide_action
                            (Tfunction (tyMSp :: tuint :: tuint :: tint :: nil)
                               tvoid cc_default))
                         (Etempvar M._m tyMSp :: Etempvar t2 tuint
                          :: Etempvar t3 tuint :: a4 :: nil))
                      t (set_opttemp None vres le) m' Out_normal)
        by (eapply exec_Scall; eauto).
      destruct (csa_call_site_pres ssa_wact t2 t3 a4 e le m _ _ _ _
                  Hcsn Ht2 Ht3 Hact Htat Hex HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & _).
      cbn [set_opttemp].
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (conj Htat (conj Hact Hch)))))).
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk wwalk_chk'] in Hg; discriminate Hg | discriminate Hsp ].
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_w Hcsn Hubgt H1 Htat Hact Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_w Hcsn Hubgt H2 Htat1 Hact1 Hch1
               HN1 HM1 HV1 HS1).
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_w Hcsn Hubgt H1 Htat Hact Hch
               HN HM HV HS).
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - cbn [ssa_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (ssa_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sswitch; eauto. }
      apply IHHexec; try assumption.
      apply ssa_chk_select. exact Hsp.
  Qed.

  (* ---- ssa multi-action-param funcall lift (no locals) ---- *)
  Lemma ssa_funcall_pres :
    forall fd m0 v0 stopA airA anim t0 m1 vres0,
      resolves_lp lp M._stomach_slide_action fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: Vint stopA :: Vint airA :: anim :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint stopA) -> untainted_scalar (Vint airA) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 stopA airA anim t0 m1 vres0 Hres Hevf Htat Husa Huaa
           HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._stomach_slide_action
                  mario_actions_moving.f_stomach_slide_action fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_stomach_slide_action)
        with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params mario_actions_moving.f_stomach_slide_action)
      with ((mario_actions_moving._m, tyMSp) ::
            (mario_actions_moving._stopAction, tuint) ::
            (mario_actions_moving._airAction, tuint) ::
            (mario_actions_moving._animation, tint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_stomach_slide_action)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._stopAction (Vint stopA)
                (PTree.set mario_actions_moving._m v0 base))))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as ->. exact (Htat _ _ eq_refl). }
    assert (Hact0 : act_inv ssa_wact
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._stopAction (Vint stopA)
                (PTree.set mario_actions_moving._m v0 base))))).
    { intros t' Hmem' x Hg'.
      unfold ssa_wact in Hmem'. cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      { apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Husa. }
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      { apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huaa. }
      (* the three undef temps *)
      assert (Hund : forall x0,
          (PTree.set mario_actions_moving._animation anim
            (PTree.set mario_actions_moving._airAction (Vint airA)
               (PTree.set mario_actions_moving._stopAction (Vint stopA)
                  (PTree.set mario_actions_moving._m v0 base)))) ! t' = Some x0 ->
          t' <> mario_actions_moving._animation ->
          t' <> mario_actions_moving._airAction ->
          t' <> mario_actions_moving._stopAction ->
          t' <> mario_actions_moving._m ->
          x0 = Vundef).
      { intros x0 Hx0 HA HB HC HD.
        rewrite PTree.gso in Hx0 by exact HA.
        rewrite PTree.gso in Hx0 by exact HB.
        rewrite PTree.gso in Hx0 by exact HC.
        rewrite PTree.gso in Hx0 by exact HD.
        exact (create_undef_temps_val _ _ _ Hx0). }
      repeat (apply orb_true_iff in Hmem' as [Ht | Hmem'];
              [ apply Pos.eqb_eq in Ht; subst t';
                rewrite (Hund _ Hg'); try (vm_compute; congruence);
                left; reflexivity | ]).
      discriminate Hmem'. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._stopAction (Vint stopA)
                (PTree.set mario_actions_moving._m v0 base)))))
      by (intros t' Hmem'; discriminate Hmem').
    destruct (ssa_pres _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) (PTree.gempty _ _)
                ssa_walk Htat0 Hact0 Hch0 HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the const-arg capture site (for the leaf wrappers) ---- *)
  Lemma ssa_capture_site_pres :
    forall tcap stopA airA anim le m tr le' m' out,
      tcap <> M._m ->
      wact_const (Int.repr stopA) = true ->
      wact_const (Int.repr airA) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some tcap)
           (Evar M._stomach_slide_action
              (Tfunction (tyMSp :: tuint :: tuint :: tint :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr stopA) tint
            :: Econst_int (Int.repr airA) tint
            :: Econst_int (Int.repr anim) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tcap stopA airA anim le m tr le' m' out Hcap Hsa Haa Htat Hexec
           HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._stomach_slide_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr stopA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr airA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (ssa_funcall_pres _ _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hsa) (wact_const_sound _ Haa)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hcap (eq_sym e))).
    exact (Htat b o Hg).
  Qed.


  (* ================================================================== *)
  (* LANDING KEYSTONE: the 3 CLEAN _land leaves (jump/freefall/double).   *)
  (* Each body = clc(m,&sXLandAction,setX); if(t'1) return 1;             *)
  (*             cla(m,anim,UNTAINTED); return 0.                          *)
  (* clc lifted by LandingBricks.clc_funcall_pres_marg (the knockback-     *)
  (* global landingAction walk); cla by the marg-form cla_funcall_pres.    *)
  (* ================================================================== *)
  Let clc_marg := LandingBricks.clc_funcall_pres_marg lp LO_mario
    LO_mario_step LO_mov bm NoA MWF HNoA_of_MWF HMWF_window HMWF_glob
    HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root HMWF_sglob
    HchaseStep HMWF_chase_safe HMWF_ktab HMWF_inp.

  (* local clean exec_stmt inversion helpers (lnd_-prefixed: AGates and
     LandingBricks each have a section-local exec_seq_cases). *)
  Lemma lnd_exec_seq_cases :
    forall e le m s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Ssequence s1 s2) tr le' m' out ->
      (exists tr1 le1 m1 tr2,
          exec_stmt function_entry2 (lp_ge lp) e le m s1 tr1 le1 m1 Out_normal /\
          exec_stmt function_entry2 (lp_ge lp) e le1 m1 s2 tr2 le' m' out)
      \/ (exec_stmt function_entry2 (lp_ge lp) e le m s1 tr le' m' out /\
          out <> Out_normal).
  Proof.
    intros e le m s1 s2 tr le' m' out H; inv H.
    - left; do 4 eexists; split; eassumption.
    - right; split; assumption.
  Qed.

  Lemma lnd_exec_if_inv :
    forall e le m c s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sifthenelse c s1 s2) tr le' m' out ->
      exists b, exec_stmt function_entry2 (lp_ge lp) e le m (if b : bool then s1 else s2)
                  tr le' m' out.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           eexists; eassumption. Qed.

  Lemma lnd_exec_skip_inv :
    forall e le m tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m Sskip tr le' m' out ->
      le' = le /\ m' = m /\ out = Out_normal.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end; auto. Qed.

  Lemma lnd_exec_return_inv :
    forall e le m a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sreturn a) tr le' m' out ->
      le' = le /\ m' = m /\ out <> Out_normal.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           (split; [ reflexivity | split; [ reflexivity | discriminate ] ]). Qed.

  Lemma lnd_exec_set_inv :
    forall e le m id a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sset id a) tr le' m' out ->
      m' = m /\ out = Out_normal /\ exists v, le' = PTree.set id v le.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           (split; [ reflexivity | split; [ reflexivity | eexists; reflexivity ] ]). Qed.

  (* the clean clc call site: Scall (Some _t'1) of common_landing_cancels with
     args (Etempvar _m, &gid, Evar sap).  gid in knockback_table_ids; sap the
     (arbitrary, used vacuously) setAPressAction.  Preserves + reads off le!_m. *)
  Lemma clc_site_pres :
    forall dst gid sap le m tr le' m' out,
      dst <> M._m ->
      mem_id gid knockback_table_ids = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some dst)
           (Evar M._common_landing_cancels
              (Tfunction (tyMSp :: tptr (Tstruct M._LandingAction noattr)
                          :: tptr (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default)
                          :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Eaddrof (Evar gid (Tstruct M._LandingAction noattr))
                 (tptr (Tstruct M._LandingAction noattr))
            :: Evar sap
                 (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default)
            :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros dst gid sap le m tr le' m' out Hdst Hgid Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_cancels fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv Hv;
      [ | match goal with Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hlv end ] end.
    match goal with Hlv : eval_lvalue _ _ _ _ (Evar gid _) _ _ _ |- _ =>
      apply eval_lvalue_Evar_global_loc in Hlv as [Hfs Hofs]; [ subst | apply PTree.gempty ] end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (clc_marg _ _ _ _ _ _ _ _ _ Hgid Hfs Hres Hevf Htat1 HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hdst (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* the cla call site: Scall None of common_landing_action with args
     (Etempvar _m, Econst_int anim, Econst_int 16779404).  Preserves. *)
  Lemma cla_site_pres :
    forall anim act le m tr le' m' out,
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None
           (Evar M._common_landing_action
              (Tfunction (tyMSp :: tshort :: tuint :: nil) tuint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr anim) tint
            :: Econst_int (Int.repr act) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'.
  Proof.
    intros anim act le m tr le' m' out Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr act)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (cla_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hact)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ================================================================== *)
  (* LANDING KEYSTONE, part 3: the INPUT-STORE leaves (triple_jump,       *)
  (* backflip, long_jump).  Each opens with an input-clear store          *)
  (*   m->input &= ~INPUT_B_PRESSED;   (some guarded by !(input&0x4000))   *)
  (* then the clc/if template, then an OPTIONAL play_sound_if_no_flag      *)
  (* (gated on !(input&1)), then cla (long_jump's anim is a chase-derived  *)
  (* temp instead of a const).                                            *)
  (* ================================================================== *)

  Lemma inp_field_off :
    field_offset (prog_comp_env mario.prog) M._input mario_state_members
      = OK (2, Full).
  Proof. vm_compute. reflexivity. Qed.

  (* set-inversion that EXPOSES the rhs eval_expr (needed for the input load). *)
  Lemma p_exec_set_inv :
    forall e le m id a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sset id a) tr le' m' out ->
      exists v, eval_expr (lp_ge lp) e le m a v /\ m' = m /\
                le' = PTree.set id v le /\ out = Out_normal.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           eauto. Qed.

  (* the m->input &= mask pair: Sset t (m->input); m->input = t & mask.
     mask of type tint, arbitrary; the loaded input is A-clear (HMWF_inp), so
     the masked store keeps INPUT_A_PRESSED clear (and2_and_left) and the
     offset-2 store misses both the action cell [12,16) and never forges a
     pointer -- preserving the carried run facts + the _m tat. *)
  Lemma inp_aclear_pair_pres :
    forall t mexpr le m tr le' m' out,
      t <> M._m ->
      typeof mexpr = tint ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset t (Efield (Ederef (Etempvar M._m tyMSp)
                      (Tstruct M._MarioState noattr)) M._input tushort))
           (Sassign (Efield (Ederef (Etempvar M._m tyMSp)
                       (Tstruct M._MarioState noattr)) M._input tushort)
              (Ebinop Oand (Etempvar t tushort) mexpr tint)))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros t mexpr le m tr le' m' out Hne Htype Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & HSet & HAsn) | (HSet & Hnn) ].
    2:{ apply lnd_exec_set_inv in HSet as (_ & Ho & _). congruence. }
    apply p_exec_set_inv in HSet as (v & Hevset & -> & -> & _).
    (* ---- load half: extract le!_m = (bm,0) and HldInput ---- *)
    destruct (eval_expr_Efield_load _ _ _ _ _ _ _ _ Hevset)
      as (loc & ofs & bf & Hlv & Hd).
    pose proof Hlv as Hbase0.
    apply eval_lvalue_Efield_base in Hbase0. destruct Hbase0 as (oo0 & Hbase).
    apply eval_expr_Ederef_load in Hbase. destruct Hbase as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb. apply eval_expr_Etempvar_val in Hlvb.
    pose proof Hlvb as Hle_m.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                loc ofs bf _ _ _ Hlvb inp_field_off Hlv) as (E3 & E4 & E5).
    subst loc ofs bf. clear Hlv.
    inv Hd.
    2:{ match goal with Hac : access_mode _ = By_reference |- _ =>
          cbn in Hac; discriminate Hac end. }
    2:{ match goal with Hac : access_mode _ = By_copy |- _ =>
          cbn in Hac; discriminate Hac end. }
    match goal with Hac : access_mode _ = By_value _ |- _ =>
      cbn in Hac; injection Hac as <- end.
    match goal with Hldv : Mem.loadv _ _ _ = Some _ |- _ =>
      unfold Mem.loadv in Hldv;
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 2))) with 2 in Hldv;
      rename Hldv into HldInput end.
    (* ---- store half ---- *)
    inv HAsn.
    match goal with Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      pose proof Hlv2 as Hbase2; apply eval_lvalue_Efield_base in Hbase2;
      destruct Hbase2 as (oo2 & Hbase2'); apply eval_expr_Ederef_load in Hbase2';
      destruct Hbase2' as (lb2 & ob2 & bfb2 & Hlvb2 & _);
      apply eval_lvalue_Ederef_base in Hlvb2; apply eval_expr_Etempvar_val in Hlvb2 end.
    pose proof Hlvb2 as Hm0.
    rewrite PTree.gso in Hm0 by (exact (fun e => Hne (eq_sym e))).
    destruct (Htat _ _ Hm0) as [F1 F2]. subst lb2 ob2.
    match goal with Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc2 ?ofs2 ?bf2 |- _ =>
      destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                  loc2 ofs2 bf2 _ _ _ Hlvb2 inp_field_off Hlv2) as (F3 & F4 & F5);
      subst loc2 ofs2 bf2 end.
    (* rhs: t & mexpr -> Vint (vi & mv) with le1!t = Vint vi *)
    match goal with Hev2 : eval_expr _ _ _ _ (Ebinop Oand _ _ _) _ |- _ =>
      assert (HH := Hev2) end.
    destruct (and_temp_form lp _ _ _ _ _ _ Htype HH) as (vi & mv & Hlet & ->). clear HH.
    rewrite PTree.gss in Hlet. injection Hlet as Hv. subst v.
    pose proof (HMWF_inp _ HM _ HldInput) as Hvi2.
    (* cast i32 -> u16 = zero_ext 16 *)
    match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hcast; unfold sem_cast in Hcast;
      cbn [classify_cast cast_int_int] in Hcast; injection Hcast as <- end.
    (* the store at (bm,2) *)
    match goal with Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has end;
      try (match goal with Hac : access_mode _ = By_copy |- _ =>
             cbn in Hac; discriminate Hac end).
    match goal with Hac : access_mode _ = By_value _ |- _ => cbn in Hac; injection Hac as <- end.
    match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
      unfold Mem.storev in Hsv;
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 2))) with 2 in Hsv;
      rename Hsv into Hst end.
    assert (Hst2 : Int.and (Int.zero_ext 16 (Int.and vi mv)) (Int.repr 2) = Int.zero)
      by (rewrite and2_zero_ext16; apply and2_and_left; exact Hvi2).
    split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hst _ HV) | ].
    split;
      [ intros av Hload;
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
        [ exact (HS av Hload) | right; right; cbn; lia ] | ].
    split; [ exact (HMWF_input _ _ _ HM Hst2 Hst) | ].
    split; [ exact (HNoA_of_MWF _ (HMWF_input _ _ _ HM Hst2 Hst)) | ].
    split; [ reflexivity | ].
    intros b o Hg. rewrite PTree.gso in Hg by (exact (fun e => Hne (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* the guarded form: Sset tg (m->input); if cond { input pair on tw } else skip.
     (backflip/long_jump guard the input clear on !(input & 0x4000).) *)
  Lemma guarded_input_pres :
    forall tg tw cond le m tr le' m' out,
      tg <> M._m -> tw <> M._m ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset tg (Efield (Ederef (Etempvar M._m tyMSp)
                      (Tstruct M._MarioState noattr)) M._input tushort))
           (Sifthenelse cond
              (Ssequence
                 (Sset tw (Efield (Ederef (Etempvar M._m tyMSp)
                            (Tstruct M._MarioState noattr)) M._input tushort))
                 (Sassign (Efield (Ederef (Etempvar M._m tyMSp)
                             (Tstruct M._MarioState noattr)) M._input tushort)
                    (Ebinop Oand (Etempvar tw tushort)
                       (Eunop Onotint (Econst_int (Int.repr 2) tint) tint) tint)))
              Sskip))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tg tw cond le m tr le' m' out Hg Hw Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hset & Hif) | (Hset & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hset as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
    assert (Htatg : forall b o,
       (PTree.set tg vg le) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hgg. rewrite PTree.gso in Hgg by (exact (fun e => Hg (eq_sym e))).
      exact (Htat b o Hgg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - destruct (inp_aclear_pair_pres tw
                  (Eunop Onotint (Econst_int (Int.repr 2) tint) tint)
                  _ _ _ _ _ _ Hw eq_refl Htatg Hif HN HM HV HS)
        as (HV' & HS' & HM' & HN' & Ho & Htat').
      exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Ho Htat'))))).
    - apply lnd_exec_skip_inv in Hif as (-> & -> & ->).
      exact (conj HV (conj HS (conj HM (conj HN (conj eq_refl Htatg))))).
  Qed.

  (* n-ary Mario-head call at the empty env: the TAIL is arbitrary (marg_ok
     constrains only the head; eval_exprlist is pure).  Mirrors
     ActWriterSurface.kit_scalln_pres but instantiated for this section. *)
  Lemma mhead_scall_pres :
    forall optid fid tys rty cc args le0 m0 tr le1 m1 out0,
      call_pres lp bm NoA MWF fid ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSp :: tys) rty cc))
           (Etempvar M._m tyMSp :: args))
        tr le1 m1 out0 ->
      (forall b o, le0 ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid tys rty cc args le0 m0 tr le1 m1 out0 Hcp Hexec Htat HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp fid fd) by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with
    | Hv1' : le0 ! _ = Some ?vv, Hevf : eval_funcall _ _ _ _ (?vv :: ?vrest) _ _ _ |- _ =>
        assert (Hmarg : marg_ok bm (vv :: vrest))
          by (unfold marg_ok; destruct vv as [| | | | | bb oo]; auto;
              exact (Htat _ _ Hv1')) end.
    match goal with Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _ |- _ =>
      destruct (Hcp _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
        as (HV' & HS' & HM' & HN') end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* the optional play_sound block: Sset tg (m->input); if cond { psinf(...) }.
     The middle play-sound argument is arbitrary (the big OR flag expr). *)
  Lemma psinf_block_pres :
    forall tg cond arg le m tr le' m' out,
      tg <> M._m ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset tg (Efield (Ederef (Etempvar M._m tyMSp)
                      (Tstruct M._MarioState noattr)) M._input tushort))
           (Sifthenelse cond
              (Scall None
                 (Evar M._play_sound_if_no_flag
                    (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default))
                 (Etempvar M._m tyMSp :: arg
                  :: Econst_int (Int.repr 131072) tint :: nil))
              Sskip))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tg cond arg le m tr le' m' out Hg Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hset & Hif) | (Hset & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hset as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
    assert (Htatg : forall b o,
       (PTree.set tg vg le) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hgg. rewrite PTree.gso in Hgg by (exact (fun e => Hg (eq_sym e))).
      exact (Htat b o Hgg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - destruct (mhead_scall_pres None M._play_sound_if_no_flag
                  (tuint :: tuint :: nil) tvoid cc_default
                  (arg :: Econst_int (Int.repr 131072) tint :: nil)
                  _ _ _ _ _ _ Hpsinf Hif Htatg HN HM HV HS)
        as (HV' & HS' & HM' & HN' & Ho & vr & Hle).
      cbn [set_opttemp] in Hle. subst le'.
      exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Ho Htatg))))).
    - apply lnd_exec_skip_inv in Hif as (-> & -> & ->).
      exact (conj HV (conj HS (conj HM (conj HN (conj eq_refl Htatg))))).
  Qed.

  (* cla with an ARBITRARY anim expression (long_jump's anim is the chase-
     derived temp _t'2, not a const).  Only the 3rd arg (the action const)
     is constrained -- untainted. *)
  Lemma cla_site_pres_e :
    forall animexpr act le m tr le' m' out,
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None
           (Evar M._common_landing_action
              (Tfunction (tyMSp :: tshort :: tuint :: nil) tuint cc_default))
           (Etempvar M._m tyMSp :: animexpr
            :: Econst_int (Int.repr act) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'.
  Proof.
    intros animexpr act le m tr le' m' out Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (Etempvar _ _ :: _) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (animexpr :: _) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ (Econst_int _ _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr act)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (cla_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hact) HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* long_jump's animation-select block: 3 temp sets (marioObj chase-load of
     rawData.asS32[34], then anim := 17/18) -- NO memory write.  Preserves. *)
  Lemma animsel_pres :
    forall e3 e4 e2t e2f cond le m tr le' m' out,
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence (Sset M._t'3 e3)
          (Ssequence (Sset M._t'4 e4)
            (Sifthenelse cond (Sset M._t'2 e2t) (Sset M._t'2 e2f))))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros e3 e4 e2t e2f cond le m tr le' m' out Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hs3 & Hr) | (Hs3 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs3 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs3 as (-> & _ & v3 & ->).
    apply lnd_exec_seq_cases in Hr
      as [ (tr3 & le2 & m2 & tr4 & Hs4 & Hif) | (Hs4 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs4 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs4 as (-> & _ & v4 & ->).
    assert (Htat2 : forall b o,
       (PTree.set M._t'4 v4 (PTree.set M._t'3 v3 le)) ! M._m = Some (Vptr b o) ->
       b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence). exact (Htat b o Hg). }
    apply lnd_exec_if_inv in Hif as [bb Hif]; destruct bb;
      apply lnd_exec_set_inv in Hif as (-> & -> & v2 & ->);
      (refine (conj HV (conj HS (conj HM (conj HN (conj eq_refl _)))));
       intros b o Hg; rewrite PTree.gso in Hg by (vm_compute; congruence);
       exact (Htat2 b o Hg)).
  Qed.

  (* ================================================================== *)
  (* LANDING KEYSTONE, part 4: act_side_flip_land -- the only landing     *)
  (* leaf with a chase STORE (m->marioObj->header.gfx.angle[1] += 0x8000) *)
  (* plus a captured cla result.  clc/if; then cla->_t'2; if(t'2!=2) the  *)
  (* object-angle store block; return 0.                                 *)
  (* ================================================================== *)

  (* a chase store of a NON-pointer through a SafeB chase temp ct.  The
     chain brick pins the written block to ct's (SafeB) value; the cast to
     the sub-word field forces the written value non-Vptr; HMWF_chase keeps
     MWF and load_store_other keeps the run facts. *)
  Lemma sfl_chase_store_pres :
    forall ct a1 a2 le m tr le' m' out,
      chain_root_l a1 = Some ct ->
      nonptr_scalar (typeof a1) = true ->
      (forall b o, le ! ct = Some (Vptr b o) -> SafeB b) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2)
        tr le' m' out ->
      MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros ct a1 a2 le m tr le' m' out Hcr Hnps Hch Hexec HM HV HS.
    inv Hexec.
    match goal with Hlv : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
      destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv) as (o0 & Hlet) end.
    pose proof (Hch _ _ Hlet) as Hsafe.
    pose proof (HSafeNotBm _ Hsafe) as Hneq.
    match goal with Hcast0 : sem_cast _ _ _ _ = Some ?vw |- _ =>
      assert (Hnp : forall bb oo, vw <> Vptr bb oo)
        by (exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hnps Hcast0)) end.
    match goal with Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has end.
    - match goal with Hsv0 : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv0 end.
      match goal with Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
        | split;
          [ exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnp Hsv)
          | split; reflexivity ] ] end.
    - exfalso. exact (Hnp _ _ eq_refl).
    - match goal with Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb end.
      match goal with Hsv0 : Mem.storev _ _ _ (Vint _) = Some m' |- _ =>
        unfold Mem.storev in Hsv0 end.
      match goal with Hsv : Mem.store _ _ _ _ (Vint _) = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
        | split;
          [ refine (HMWF_chase _ _ _ _ _ _ HM Hsafe _ Hsv);
            intros bb oo E; discriminate E
          | split; reflexivity ] ] end.
  Qed.

  (* cla that CAPTURES its result into a temp tcap (side_flip's t'2 != 2 test).
     Same preservation as cla_site_pres; the captured temp (!= _m) keeps the tat. *)
  Lemma cla_capture_site_pres :
    forall tcap anim act le m tr le' m' out,
      tcap <> M._m ->
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some tcap)
           (Evar M._common_landing_action
              (Tfunction (tyMSp :: tshort :: tuint :: nil) tuint cc_default))
           (Etempvar M._m tyMSp :: Econst_int (Int.repr anim) tint
            :: Econst_int (Int.repr act) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tcap anim act le m tr le' m' out Hcap Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr act)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (cla_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hact) HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hcap (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* side_flip's object-angle store block: t'3=m->marioObj; t'4=m->marioObj;
     t'5=t'4->...angle[1]; t'3->...angle[1] = t'5 + 0x8000.  Only e3 (=the
     marioObj chase-root load) needs recognizing -- it pins t'3's block SafeB;
     the store target chains to t'3, value is a sub-word field (nonptr). *)
  Lemma sfl_objstore_pres :
    forall e3 e4 e5 a1 a2 le m tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence (Sset M._t'3 e3)
          (Ssequence (Sset M._t'4 e4)
            (Ssequence (Sset M._t'5 e5)
              (Sassign a1 a2))))
        tr le' m' out ->
      chase_root_chk e3 = true ->
      chain_root_l a1 = Some M._t'3 ->
      nonptr_scalar (typeof a1) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'.
  Proof.
    intros e3 e4 e5 a1 a2 le m tr le' m' out Hexec Hck Hcr Hnps Htat HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hs3 & Hr) | (Hs3 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs3 as (_ & -> & _). reflexivity. }
    apply p_exec_set_inv in Hs3 as (v3 & Hev3 & -> & -> & _).
    assert (Hsafe3 : forall b o, v3 = Vptr b o -> SafeB b)
      by (intros b o E; exact (chase_root_set_sound lp LO_mario bm MWF HMWF_window
                                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_root
                                 e3 empty_env le m v3 Hck Htat HM Hev3 b o E)).
    apply lnd_exec_seq_cases in Hr
      as [ (tr3 & le2 & m2 & tr4 & Hs4 & Hr2) | (Hs4 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs4 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs4 as (-> & _ & v4 & ->).
    apply lnd_exec_seq_cases in Hr2
      as [ (tr5 & le3 & m3 & tr6 & Hs5 & Hst) | (Hs5 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs5 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs5 as (-> & _ & v5 & ->).
    assert (Hch : forall b o,
       (PTree.set M._t'5 v5 (PTree.set M._t'4 v4 (PTree.set M._t'3 v3 le)))
         ! M._t'3 = Some (Vptr b o) -> SafeB b).
    { intros b o Hg. rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as Hg3. exact (Hsafe3 _ _ Hg3). }
    destruct (sfl_chase_store_pres M._t'3 a1 a2 _ _ _ _ _ _ Hcr Hnps Hch Hst HM HV HS)
      as (HV' & HS' & HM' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))).
  Qed.

  Example mov_jland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_ffland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_freefall_land
    = Some (Gfun (Internal mario_actions_moving.f_act_freefall_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_djland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_double_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_double_jump_land)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma mov_jland_pres : body_pres lp NoA MWF bm M.f_act_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hsecond
          as [ (trC & leC & mC & trD & Hcla_c & Hret) | (Hcla_c & Hne2) ].
        * destruct (cla_site_pres 78 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVc (conj HSc HMc)).
        * destruct (cla_site_pres 78 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          exact (conj HVc (conj HSc HMc)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  Lemma mov_ffland_pres : body_pres lp NoA MWF bm M.f_act_freefall_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_freefall_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_freefall_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_freefall_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_freefall_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sFreefallLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hsecond
          as [ (trC & leC & mC & trD & Hcla_c & Hret) | (Hcla_c & Hne2) ].
        * destruct (cla_site_pres 87 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVc (conj HSc HMc)).
        * destruct (cla_site_pres 87 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          exact (conj HVc (conj HSc HMc)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sFreefallLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  Lemma mov_djland_pres : body_pres lp NoA MWF bm M.f_act_double_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_double_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_double_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_double_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_double_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sDoubleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hsecond
          as [ (trC & leC & mC & trD & Hcla_c & Hret) | (Hcla_c & Hne2) ].
        * destruct (cla_site_pres 75 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVc (conj HSc HMc)).
        * destruct (cla_site_pres 75 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          exact (conj HVc (conj HSc HMc)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sDoubleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* ================================================================== *)
  (* LANDING KEYSTONE, part 2: the HOLD _land leaves (hold_jump,         *)
  (* hold_freefall).  Each opens with a leading drop-held-object block   *)
  (*   t3 = m->marioObj; t4 = t3->oInteractStatus;                       *)
  (*   if (t4 & INT_STATUS_MARIO_DROP_OBJECT)                            *)
  (*       return drop_and_set_mario_action(m, ACT_*_LAND_STOP, 0);      *)
  (* (a chase-temp READ pair -- m unchanged -- + an UNTAINTED drop call  *)
  (*  lifted by Hdasma), then the same clc/cla template as the clean     *)
  (* leaves (clc result temp is _t'2 here, not _t'1).                    *)
  (* ================================================================== *)

  (* drop_and_set_mario_action(m, UNTAINTED_CONST, 0) -> _t'1. *)
  Lemma dasma_site_pres :
    forall dconst le m tr le' m' out,
      wact_const (Int.repr dconst) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some M._t'1)
           (Evar M._drop_and_set_mario_action
              (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr dconst) tint
            :: Econst_int (Int.repr 0) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros dconst le m tr le' m' out Hdconst Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._drop_and_set_mario_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr dconst)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr 0)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Hmarg : marg_ok bm (v1 :: Vint (Int.repr dconst) :: Vint (Int.repr 0) :: nil))
        by (unfold marg_ok; destruct v1 as [| | | | | b o]; auto; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hdasma _ _ _ _ _ _ _ _ Hevf Hres Hmarg
                    (wact_const_sound _ Hdconst) HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _)
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (vm_compute; congruence).
    exact (Htat b o Hg).
  Qed.

  (* the hold_*_land leading drop-block (shared, parametric over dconst and
     the two opaque Sset rvalues + the if-condition).  Preserves the carried
     run facts and the _m tat across BOTH exits (drop-return + fall-through). *)
  Lemma hold_lead_pres :
    forall dconst a3 a4 cond le m tr le' m' out,
      wact_const (Int.repr dconst) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence (Sset M._t'3 a3)
          (Ssequence (Sset M._t'4 a4)
            (Sifthenelse cond
              (Ssequence
                 (Scall (Some M._t'1)
                    (Evar M._drop_and_set_mario_action
                       (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default))
                    (Etempvar M._m tyMSp
                     :: Econst_int (Int.repr dconst) tint
                     :: Econst_int (Int.repr 0) tint :: nil))
                 (Sreturn (Some (Etempvar M._t'1 tint))))
              Sskip)))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros dconst a3 a4 cond le m tr le' m' out Hdconst Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hs3 & Hrest) | (Hs3 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs3 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs3 as (-> & _ & v3 & ->).
    apply lnd_exec_seq_cases in Hrest
      as [ (tr3 & le2 & m2 & tr4 & Hs4 & Hif) | (Hs4 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs4 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs4 as (-> & _ & v4 & ->).
    assert (Htat2 : forall b o,
       (PTree.set M._t'4 v4 (PTree.set M._t'3 v3 le)) ! M._m = Some (Vptr b o) ->
       b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      exact (Htat b o Hg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - apply lnd_exec_seq_cases in Hif
        as [ (tr5 & le3 & m3 & tr6 & Hcall & Hret) | (Hcall & Hne) ].
      2:{ exfalso. apply Hne. inv Hcall. reflexivity. }
      destruct (dasma_site_pres _ _ _ _ _ _ _ Hdconst Htat2 Hcall HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & Htat3).
      apply lnd_exec_return_inv in Hret as (-> & -> & _).
      exact (conj HV' (conj HS' (conj HM' (conj HN' Htat3)))).
    - apply lnd_exec_skip_inv in Hif as (-> & -> & _).
      exact (conj HV (conj HS (conj HM (conj HN Htat2)))).
  Qed.

  Example mov_hjland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_hold_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_hfland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_freefall_land
    = Some (Gfun (Internal mario_actions_moving.f_act_hold_freefall_land)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma mov_hjland_pres : body_pres lp NoA MWF bm M.f_act_hold_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hlead & Hmain) | (Hlead & Hne) ].
    - destruct (hold_lead_pres 201327152 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      apply lnd_exec_seq_cases in Hmain
        as [ (trA & leA & mA & trB & Hclcblk & Hcla_blk) | (Hclcblk & Hne) ].
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldJumpLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & Htat_a).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
        * apply lnd_exec_skip_inv in Hif as (-> & -> & _).
          apply lnd_exec_seq_cases in Hcla_blk
            as [ (trE & leE & mE & trG & Hcla_c & Hret) | (Hcla_c & Hne2) ].
          -- destruct (cla_site_pres 64 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 64 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldJumpLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & _).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & -> & _).
          exact (conj HVa (conj HSa HMa)).
        * apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
    - destruct (hold_lead_pres 201327152 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      exact (conj HVl (conj HSl HMl)).
  Qed.

  Lemma mov_hfland_pres : body_pres lp NoA MWF bm M.f_act_hold_freefall_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_freefall_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_freefall_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_freefall_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_freefall_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hlead & Hmain) | (Hlead & Hne) ].
    - destruct (hold_lead_pres 201327154 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      apply lnd_exec_seq_cases in Hmain
        as [ (trA & leA & mA & trB & Hclcblk & Hcla_blk) | (Hclcblk & Hne) ].
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldFreefallLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & Htat_a).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
        * apply lnd_exec_skip_inv in Hif as (-> & -> & _).
          apply lnd_exec_seq_cases in Hcla_blk
            as [ (trE & leE & mE & trG & Hcla_c & Hret) | (Hcla_c & Hne2) ].
          -- destruct (cla_site_pres 66 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 66 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldFreefallLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & _).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & -> & _).
          exact (conj HVa (conj HSa HMa)).
        * apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
    - destruct (hold_lead_pres 201327154 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      exact (conj HVl (conj HSl HMl)).
  Qed.

  Example mov_tjland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_triple_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_triple_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_bfland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_backflip_land
    = Some (Gfun (Internal mario_actions_moving.f_act_backflip_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_ljland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_long_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_long_jump_land)).
  Proof. vm_compute. reflexivity. Qed.

  (* triple_jump_land: UNCONDITIONAL input clear, then clc/if, then optional
     play_sound, then cla(192, UNTAINTED). *)
  Lemma mov_tjland_pres : body_pres lp NoA MWF bm M.f_act_triple_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_triple_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_triple_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_triple_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_triple_jump_land in Hbody; cbn [fn_body] in Hbody.
    (* ---- input pair ---- *)
    apply lnd_exec_seq_cases in Hbody
      as [ (tr0 & le0 & m0 & trR & Hinp & Hrest1) | (Hinp & Hne) ].
    2:{ exfalso. apply Hne.
        destruct (inp_aclear_pair_pres M._t'3
                    (Eunop Onotint (Econst_int (Int.repr 2) tint) tint)
                    _ _ _ _ _ _ ltac:(vm_compute; congruence) eq_refl Htat Hinp HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). exact Ho. }
    destruct (inp_aclear_pair_pres M._t'3
                (Eunop Onotint (Econst_int (Int.repr 2) tint) tint)
                _ _ _ _ _ _ ltac:(vm_compute; congruence) eq_refl Htat Hinp HN HM HV HS)
      as (HVi & HSi & HMi & HNi & _ & Htati).
    (* ---- clc block ---- *)
    apply lnd_exec_seq_cases in Hrest1
      as [ (trA & leA & mA & trB & Hclcblk & Hrest2) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sTripleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        (* ---- optional play_sound block ---- *)
        apply lnd_exec_seq_cases in Hrest2
          as [ (trE & leE & mE & trG & Hpsblk & Hclablk) | (Hpsblk & Hne3) ].
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (HVp & HSp & HMp & HNp & _ & Htat_p).
          apply lnd_exec_seq_cases in Hclablk
            as [ (trH & leH & mH & trI & Hcla_c & Hret) | (Hcla_c & Hne4) ].
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sTripleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* backflip_land: GUARDED input clear (on !(input&0x4000)), then the same
     clc/if + optional play_sound + cla(192, UNTAINTED) template. *)
  Lemma mov_bfland_pres : body_pres lp NoA MWF bm M.f_act_backflip_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_backflip_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_backflip_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_backflip_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_backflip_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (tr0 & le0 & m0 & trR & Hinp & Hrest1) | (Hinp & Hne) ].
    2:{ exfalso. apply Hne.
        destruct (guarded_input_pres M._t'3 M._t'4 _ _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                    Htat Hinp HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). exact Ho. }
    destruct (guarded_input_pres M._t'3 M._t'4 _ _ _ _ _ _ _
                ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                Htat Hinp HN HM HV HS)
      as (HVi & HSi & HMi & HNi & _ & Htati).
    apply lnd_exec_seq_cases in Hrest1
      as [ (trA & leA & mA & trB & Hclcblk & Hrest2) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sBackflipLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hrest2
          as [ (trE & leE & mE & trG & Hpsblk & Hclablk) | (Hpsblk & Hne3) ].
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (HVp & HSp & HMp & HNp & _ & Htat_p).
          apply lnd_exec_seq_cases in Hclablk
            as [ (trH & leH & mH & trI & Hcla_c & Hret) | (Hcla_c & Hne4) ].
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sBackflipLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* long_jump_land: GUARDED input clear, then clc/if, then optional play_sound,
     then an anim-SELECT block (3 temp sets, NO write), then cla(_t'2, UNTAINTED). *)
  Lemma mov_ljland_pres : body_pres lp NoA MWF bm M.f_act_long_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_long_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_long_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_long_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_long_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (tr0 & le0 & m0 & trR & Hinp & Hrest1) | (Hinp & Hne) ].
    2:{ exfalso. apply Hne.
        destruct (guarded_input_pres M._t'6 M._t'7 _ _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                    Htat Hinp HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). exact Ho. }
    destruct (guarded_input_pres M._t'6 M._t'7 _ _ _ _ _ _ _
                ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                Htat Hinp HN HM HV HS)
      as (HVi & HSi & HMi & HNi & _ & Htati).
    apply lnd_exec_seq_cases in Hrest1
      as [ (trA & leA & mA & trB & Hclcblk & Hrest2) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sLongJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hrest2
          as [ (trE & leE & mE & trG & Hpsblk & Hclablk) | (Hpsblk & Hne3) ].
        * destruct (psinf_block_pres M._t'5 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (HVp & HSp & HMp & HNp & _ & Htat_p).
          (* ---- anim-select + cla ---- *)
          apply lnd_exec_seq_cases in Hclablk
            as [ (trH & leH & mH & trI & Hanimcla & Hret) | (Hanimcla & Hne4) ].
          -- apply lnd_exec_seq_cases in Hanimcla
               as [ (trJ & leJ & mJ & trK & Hanimsel & Hcla) | (Hanimsel & Hne5) ].
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (HVan & HSan & HMan & HNan & _ & Htat_an).
                destruct (cla_site_pres_e (Etempvar M._t'2 tint) 16779404 _ _ _ _ _ _
                            ltac:(vm_compute; reflexivity) Htat_an Hcla HNan HMan HVan HSan)
                  as (HVc & HSc & HMc & HNc).
                apply lnd_exec_return_inv in Hret as (_ & -> & _).
                exact (conj HVc (conj HSc HMc)).
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (_ & _ & _ & _ & Ho & _). congruence.
          -- apply lnd_exec_seq_cases in Hanimcla
               as [ (trJ & leJ & mJ & trK & Hanimsel & Hcla) | (Hanimsel & Hne5) ].
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (HVan & HSan & HMan & HNan & _ & Htat_an).
                destruct (cla_site_pres_e (Etempvar M._t'2 tint) 16779404 _ _ _ _ _ _
                            ltac:(vm_compute; reflexivity) Htat_an Hcla HNan HMan HVan HSan)
                  as (HVc & HSc & HMc & HNc).
                exact (conj HVc (conj HSc HMc)).
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (_ & _ & _ & _ & Ho & _). congruence.
        * destruct (psinf_block_pres M._t'5 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sLongJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  Example mov_sfland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_side_flip_land
    = Some (Gfun (Internal mario_actions_moving.f_act_side_flip_land)).
  Proof. vm_compute. reflexivity. Qed.

  (* side_flip_land: clc/if; cla->_t'2; if (t'2 != 2) { object-angle store }; ret. *)
  Lemma mov_sfland_pres : body_pres lp NoA MWF bm M.f_act_side_flip_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_side_flip_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_side_flip_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_side_flip_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_side_flip_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hclcblk & Hrest) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sSideFlipLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hrest
          as [ (trE & leE & mE & trG & Hclablk2 & Hret) | (Hclablk2 & Hne3) ].
        * apply lnd_exec_seq_cases in Hclablk2
            as [ (trH & leH & mH & trI & Hcla & Hifobj) | (Hcla & Hne4) ].
          -- destruct (cla_capture_site_pres M._t'2 190 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                         Htat_a Hcla HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc & _ & Htat_c).
             apply lnd_exec_if_inv in Hifobj as [bb2 Hifobj].
             destruct bb2.
             ++ destruct (sfl_objstore_pres _ _ _ _ _ _ _ _ _ _ _ Hifobj
                            ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                            ltac:(vm_compute; reflexivity) Htat_c HNc HMc HVc HSc)
                  as (HVo & HSo & HMo & HNo).
                apply lnd_exec_return_inv in Hret as (_ & -> & _).
                exact (conj HVo (conj HSo HMo)).
             ++ apply lnd_exec_skip_inv in Hifobj as (-> & -> & _).
                apply lnd_exec_return_inv in Hret as (_ & -> & _).
                exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_capture_site_pres M._t'2 190 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                         Htat_a Hcla HNa HMa HVa HSa)
               as (_ & _ & _ & _ & Ho & _). congruence.
        * apply lnd_exec_seq_cases in Hclablk2
            as [ (trH & leH & mH & trI & Hcla & Hifobj) | (Hcla & Hne4) ].
          -- destruct (cla_capture_site_pres M._t'2 190 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                         Htat_a Hcla HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc & _ & Htat_c).
             apply lnd_exec_if_inv in Hifobj as [bb2 Hifobj].
             destruct bb2.
             ++ destruct (sfl_objstore_pres _ _ _ _ _ _ _ _ _ _ _ Hifobj
                            ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                            ltac:(vm_compute; reflexivity) Htat_c HNc HMc HVc HSc)
                  as (HVo & HSo & HMo & HNo).
                exact (conj HVo (conj HSo HMo)).
             ++ apply lnd_exec_skip_inv in Hifobj as (-> & -> & _).
                exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_capture_site_pres M._t'2 190 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                         Htat_a Hcla HNa HMa HVa HSa)
               as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sSideFlipLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* ============== QUICKSAND leaves: trivial wrappers over the keystone ==== *)
  Example mov_qjland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_quicksand_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_quicksand_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_hqjland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_quicksand_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_hold_quicksand_jump_land)).
  Proof. vm_compute. reflexivity. Qed.

  (* body = { t'1 = qjla(m, a1, a2, endA, airA); cancel = t'1; return cancel } *)
  Lemma mov_qjland_pres : body_pres lp NoA MWF bm M.f_act_quicksand_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_quicksand_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_quicksand_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_quicksand_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_quicksand_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      2:{ destruct (qjla_capture_site_pres M._t'1 77 78 201327152 16779404 _ _ _ _ _ _
                      ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                      ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
            as (_ & _ & _ & _ & Ho & _). congruence. }
      destruct (qjla_capture_site_pres M._t'1 77 78 201327152 16779404 _ _ _ _ _ _
                  ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                  ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
      apply lnd_exec_return_inv in Hsecond as (_ & -> & _).
      exact (conj HVa (conj HSa HMa)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      + apply lnd_exec_set_inv in Hset as (_ & Ho & _). congruence.
      + destruct (qjla_capture_site_pres M._t'1 77 78 201327152 16779404 _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                    ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). congruence.
  Qed.

  Lemma mov_hqjland_pres : body_pres lp NoA MWF bm M.f_act_hold_quicksand_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_quicksand_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_quicksand_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_quicksand_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_quicksand_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      2:{ destruct (qjla_capture_site_pres M._t'1 65 64 134218292 16779425 _ _ _ _ _ _
                      ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                      ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
            as (_ & _ & _ & _ & Ho & _). congruence. }
      destruct (qjla_capture_site_pres M._t'1 65 64 134218292 16779425 _ _ _ _ _ _
                  ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                  ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
      apply lnd_exec_return_inv in Hsecond as (_ & -> & _).
      exact (conj HVa (conj HSa HMa)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      + apply lnd_exec_set_inv in Hset as (_ & Ho & _). congruence.
      + destruct (qjla_capture_site_pres M._t'1 65 64 134218292 16779425 _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                    ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). congruence.
  Qed.
  Example mov_assl_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_stomach_slide
    = Some (Gfun (Internal mario_actions_moving.f_act_stomach_slide)).
  Proof. vm_compute. reflexivity. Qed.

  (* body = { t'1 = stomach_slide_action(m, 902, 16779404, 137); cancel = t'1;
     return cancel } -- same trivial-wrapper shape as the quicksand leaves,
     lifted through ssa_capture_site_pres (the const-arg capture site). *)
  Lemma mov_assl_pres : body_pres lp NoA MWF bm M.f_act_stomach_slide.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_stomach_slide) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_stomach_slide) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_stomach_slide)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_stomach_slide in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      2:{ destruct (ssa_capture_site_pres M._t'1 902 16779404 137 _ _ _ _ _ _
                      ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                      ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
            as (_ & _ & _ & _ & Ho & _). congruence. }
      destruct (ssa_capture_site_pres M._t'1 902 16779404 137 _ _ _ _ _ _
                  ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                  ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
      apply lnd_exec_return_inv in Hsecond as (_ & -> & _).
      exact (conj HVa (conj HSa HMa)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      + apply lnd_exec_set_inv in Hset as (_ & Ho & _). congruence.
      + destruct (ssa_capture_site_pres M._t'1 902 16779404 137 _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                    ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). congruence.
  Qed.
  (* ================================================================== *)
  (* COMMON_SLIDE_ACTION_WITH_JUMP (csaj) keystone + act_butt_slide.      *)
  (* 3-action-param sibling of ssa; reuses csa_call_site_pres for the     *)
  (* inner common_slide_action site; tilt_body_butt_slide via mov_tbbs_row.*)
  (* Consumed-row hyps replaced: mov_sja_row/Hsmact/mov_usl_row/          *)
  (* mov_tbbs_row/csa_call_site_pres; abs_* inversions -> lnd_*.           *)
  (* ================================================================== *)
Definition csaj_wact : list ident :=
  M._stopAction :: M._jumpAction :: M._airAction :: M._t'1 :: M._t'2 :: nil.
Definition csaj_ids : list ident := M._update_sliding :: nil.
Definition csaj_wids : list ident :=
  mario._set_jumping_action :: mario._set_mario_action :: nil.

Fixpoint csaj_chk (s : statement) : bool :=
  wwalk_chk true csaj_wact csaj_ids csaj_wids nil nil nil nil s
  || match s with
     | Ssequence s1 s2 => csaj_chk s1 && csaj_chk s2
     | Sifthenelse _ s1 s2 => csaj_chk s1 && csaj_chk s2
     | Sswitch _ sl => csaj_chk_ls sl
     | Scall None (Evar fid fty) al => csa_site_chk csaj_wact fid fty al
     | _ => false
     end
with csaj_chk_ls (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => csaj_chk s && csaj_chk_ls sl'
  end.

Lemma csaj_chk_ls_seq : forall sl,
    csaj_chk_ls sl = true -> csaj_chk (seq_of_labeled_statement sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn [seq_of_labeled_statement]. cbn [csaj_chk_ls] in H.
    apply andb_prop in H as [H1 H2].
    cbn [csaj_chk]. apply orb_true_iff. right.
    rewrite H1, (IH H2). reflexivity.
Qed.

Lemma csaj_chk_ls_case : forall n sl sl',
    csaj_chk_ls sl = true ->
    select_switch_case n sl = Some sl' ->
    csaj_chk_ls sl' = true.
Proof.
  intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn [csaj_chk_ls] in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn [select_switch_case] in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn [csaj_chk_ls]. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma csaj_chk_ls_default : forall sl,
    csaj_chk_ls sl = true -> csaj_chk_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn [csaj_chk_ls] in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn [select_switch_default].
    + exact (IH H2).
    + cbn [csaj_chk_ls]. rewrite H1, H2. reflexivity.
Qed.

Lemma csaj_chk_select : forall n sl,
    csaj_chk_ls sl = true ->
    csaj_chk (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros n sl H. apply csaj_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (csaj_chk_ls_case _ _ _ H E).
  - exact (csaj_chk_ls_default _ H).
Qed.

Lemma csaj_chk_scall_inv : forall optid a al,
    csaj_chk (Scall optid a al) = true ->
    wwalk_chk true csaj_wact csaj_ids csaj_wids nil nil nil nil
      (Scall optid a al) = true
    \/ (optid = None /\ exists fid fty,
          a = Evar fid fty /\ csa_site_chk csaj_wact fid fty al = true).
Proof.
  intros optid a al H. cbn [csaj_chk] in H.
  apply orb_true_iff in H as [Hg | Hsp]; [ left; exact Hg | right ].
  destruct optid as [t'|]; [ discriminate Hsp | ].
  destruct a as [ i0 t0 | f0 t0 | f0 t0 | i0 t0 | fid fty | id0 t0
                | a0 t0 | a0 t0 | op a0 t0 | op a1 a2 t0 | a0 t0
                | a0 f0 t0 | t1 t0 | t1 t0 ]; try discriminate Hsp.
  split; [ reflexivity | ]. exists fid, fty. split; [ reflexivity | exact Hsp ].
Qed.

Example csaj_walk : csaj_chk (fn_body M.f_common_slide_action_with_jump) = true.
Proof. vm_compute. reflexivity. Qed.
Example csaj_pin :
  (prog_defmap mario_actions_moving.prog) ! M._common_slide_action_with_jump
  = Some (Gfun (Internal M.f_common_slide_action_with_jump)).
Proof. vm_compute. reflexivity. Qed.

Example abs_pin :
  (prog_defmap mario_actions_moving.prog) ! M._act_butt_slide
  = Some (Gfun (Internal M.f_act_butt_slide)).
Proof. vm_compute. reflexivity. Qed.

  (* tilt_body_butt_slide: clean chase-store body (writes untainted scalars
     through m->marioBodyState->torsoAngle[i]); cact=[t'4,t'1]. *)
  Lemma mov_tbbs_row : call_pres lp bm NoA MWF M._tilt_body_butt_slide.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog M._tilt_body_butt_slide
             mario_actions_moving.f_tilt_body_butt_slide
             nil nil mov_tbbs_cact nil nil
             LO_mov mov_tbbs_pin mov_tbbs_vars mov_tbbs_pok mov_tbbs_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_tbbs_walk.
  Qed.
  Lemma csaj_ids_rows : forall fid, mem_id fid csaj_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold csaj_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_usl_row | discriminate H ].
  Qed.

  Lemma csaj_wids_rows : forall fid, mem_id fid csaj_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold csaj_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  (* ---- csaj generic engine wrapper (rt=true, wids) ---- *)
  Lemma csaj_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g csaj_ids = true -> e ! g = None) ->
      (forall g, mem_id g csaj_wids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk true csaj_wact csaj_ids csaj_wids nil nil nil nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv csaj_wact le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv csaj_wact le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_w Hubgt Hchk
           Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                true csaj_wact csaj_ids csaj_wids nil nil nil nil
                csaj_ids_rows csaj_wids_rows ltac:(intros fid HH; discriminate HH)
                ltac:(intros fid HH; discriminate HH) ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hexec
                Hub_g Hub_i Hub_w ltac:(intros g HH; discriminate HH)
                ltac:(intros g HH; discriminate HH) ltac:(intros g HH; discriminate HH) Hubgt
                Hchk Htat Hact Hch HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* ---- THE csaj HYBRID WALK ---- *)
  Lemma csaj_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g csaj_ids = true -> e ! g = None) ->
      (forall g, mem_id g csaj_wids = true -> e ! g = None) ->
      e ! M._common_slide_action = None ->
      e ! interaction._gGlobalTimer = None ->
      csaj_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv csaj_wact le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                      b = bm /\ o = Ptrofs.zero)
      /\ act_inv csaj_wact le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_w Hcsn Hubgt Hchk Htat Hact Hch HN HM HV HS.
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - destruct (csaj_chk_scall_inv _ _ _ Hchk)
        as [Hg | (-> & fid & fty & -> & Hsp)].
      { eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (csa_site_chk_shape _ _ _ _ Hsp) as (t2 & t3 & a4 & -> & -> & -> & Ht2 & Ht3).
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall None
                         (Evar M._common_slide_action
                            (Tfunction (tyMSp :: tuint :: tuint :: tint :: nil)
                               tvoid cc_default))
                         (Etempvar M._m tyMSp :: Etempvar t2 tuint
                          :: Etempvar t3 tuint :: a4 :: nil))
                      t (set_opttemp None vres le) m' Out_normal)
        by (eapply exec_Scall; eauto).
      destruct (csa_call_site_pres csaj_wact t2 t3 a4 e le m _ _ _ _
                  Hcsn Ht2 Ht3 Hact Htat Hex HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & _).
      cbn [set_opttemp].
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (conj Htat (conj Hact Hch)))))).
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk wwalk_chk'] in Hg; discriminate Hg | discriminate Hsp ].
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_w Hcsn Hubgt H1 Htat Hact Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_w Hcsn Hubgt H2 Htat1 Hact1 Hch1
               HN1 HM1 HV1 HS1).
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_w Hcsn Hubgt H1 Htat Hact Hch
               HN HM HV HS).
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - cbn [csaj_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (csaj_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_w Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sswitch; eauto. }
      apply IHHexec; try assumption.
      apply csaj_chk_select. exact Hsp.
  Qed.

  (* ---- csaj multi-action-param funcall lift (3 action params, no locals) ---- *)
  Lemma csaj_funcall_pres :
    forall fd m0 v0 stopA jumpA airA anim t0 m1 vres0,
      resolves_lp lp M._common_slide_action_with_jump fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: Vint stopA :: Vint jumpA :: Vint airA :: anim :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint stopA) -> untainted_scalar (Vint jumpA) ->
      untainted_scalar (Vint airA) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 stopA jumpA airA anim t0 m1 vres0 Hres Hevf Htat Husa Huja Huaa
           HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._common_slide_action_with_jump
                  mario_actions_moving.f_common_slide_action_with_jump fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_common_slide_action_with_jump)
        with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params mario_actions_moving.f_common_slide_action_with_jump)
      with ((mario_actions_moving._m, tyMSp) ::
            (mario_actions_moving._stopAction, tuint) ::
            (mario_actions_moving._jumpAction, tuint) ::
            (mario_actions_moving._airAction, tuint) ::
            (mario_actions_moving._animation, tint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_common_slide_action_with_jump)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._jumpAction (Vint jumpA)
                (PTree.set mario_actions_moving._stopAction (Vint stopA)
                   (PTree.set mario_actions_moving._m v0 base)))))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as ->. exact (Htat _ _ eq_refl). }
    assert (Hact0 : act_inv csaj_wact
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._jumpAction (Vint jumpA)
                (PTree.set mario_actions_moving._stopAction (Vint stopA)
                   (PTree.set mario_actions_moving._m v0 base)))))).
    { intros t' Hmem' x Hg'.
      unfold csaj_wact in Hmem'. cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      { apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Husa. }
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      { apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huja. }
      apply orb_true_iff in Hmem' as [Ht | Hmem'].
      { apply Pos.eqb_eq in Ht; subst t'.
        rewrite PTree.gso in Hg' by (vm_compute; congruence).
        rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huaa. }
      (* the two undef temps t'1, t'2 *)
      assert (Hund : forall x0,
          (PTree.set mario_actions_moving._animation anim
            (PTree.set mario_actions_moving._airAction (Vint airA)
               (PTree.set mario_actions_moving._jumpAction (Vint jumpA)
                  (PTree.set mario_actions_moving._stopAction (Vint stopA)
                     (PTree.set mario_actions_moving._m v0 base))))) ! t' = Some x0 ->
          t' <> mario_actions_moving._animation ->
          t' <> mario_actions_moving._airAction ->
          t' <> mario_actions_moving._jumpAction ->
          t' <> mario_actions_moving._stopAction ->
          t' <> mario_actions_moving._m ->
          x0 = Vundef).
      { intros x0 Hx0 HA HB HC HD HE.
        rewrite PTree.gso in Hx0 by exact HA.
        rewrite PTree.gso in Hx0 by exact HB.
        rewrite PTree.gso in Hx0 by exact HC.
        rewrite PTree.gso in Hx0 by exact HD.
        rewrite PTree.gso in Hx0 by exact HE.
        exact (create_undef_temps_val _ _ _ Hx0). }
      repeat (apply orb_true_iff in Hmem' as [Ht | Hmem'];
              [ apply Pos.eqb_eq in Ht; subst t';
                rewrite (Hund _ Hg'); try (vm_compute; congruence);
                left; reflexivity | ]).
      discriminate Hmem'. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._animation anim
          (PTree.set mario_actions_moving._airAction (Vint airA)
             (PTree.set mario_actions_moving._jumpAction (Vint jumpA)
                (PTree.set mario_actions_moving._stopAction (Vint stopA)
                   (PTree.set mario_actions_moving._m v0 base))))))
      by (intros t' Hmem'; discriminate Hmem').
    destruct (csaj_pres _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) (PTree.gempty _ _)
                csaj_walk Htat0 Hact0 Hch0 HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the const-arg capture site (for the leaf wrappers) ---- *)
  Lemma csaj_capture_site_pres :
    forall tcap stopA jumpA airA anim le m tr le' m' out,
      tcap <> M._m ->
      wact_const (Int.repr stopA) = true ->
      wact_const (Int.repr jumpA) = true ->
      wact_const (Int.repr airA) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some tcap)
           (Evar M._common_slide_action_with_jump
              (Tfunction (tyMSp :: tuint :: tuint :: tuint :: tint :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr stopA) tint
            :: Econst_int (Int.repr jumpA) tint
            :: Econst_int (Int.repr airA) tint
            :: Econst_int (Int.repr anim) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tcap stopA jumpA airA anim le m tr le' m' out Hcap Hsa Hja Haa Htat Hexec
           HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_slide_action_with_jump fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr stopA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr jumpA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr airA)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (csaj_funcall_pres _ _ _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hsa) (wact_const_sound _ Hja)
                    (wact_const_sound _ Haa)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hcap (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* ---- the trailing tilt_body_butt_slide(m) void call site ---- *)
  Lemma tilt_void_site_pres :
    forall e le m tr le' m' out,
      e ! M._tilt_body_butt_slide = None ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Scall None
           (Evar M._tilt_body_butt_slide
              (Tfunction (tyMSp :: nil) tvoid cc_default))
           (Etempvar M._m tyMSp :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros e le m tr le' m' out Htn Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ Htn Hv) as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._tilt_body_butt_slide fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Hmarg : marg_ok bm (v1 :: nil)) by
        (destruct v1 as [ | | | | | bb oo ]; cbn; try exact I;
         exact (Htat bb oo Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (mov_tbbs_row _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg. exact (Htat b o Hg).
  Qed.

  (* ---- act_butt_slide leaf wrapper ----
     body = { t'1 = csaj(m,201327166,50333824,50333838,145); cancel = t'1;
              tilt_body_butt_slide(m); return cancel } *)
  Lemma mov_abs_pres : body_pres lp NoA MWF bm M.f_act_butt_slide.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_butt_slide) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_butt_slide) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_butt_slide)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_butt_slide in Hbody; cbn [fn_body] in Hbody.
    (* outer seq: (capture; set) ;; (tilt; return) *)
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - (* first block (capture;set) ran to Out_normal *)
      apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      2:{ destruct (csaj_capture_site_pres M._t'1 201327166 50333824 50333838 145
                      _ _ _ _ _ _ ltac:(vm_compute; congruence)
                      ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                      ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
            as (_ & _ & _ & _ & Ho & _). congruence. }
      destruct (csaj_capture_site_pres M._t'1 201327166 50333824 50333838 145
                  _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                  ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
        as (HVc & HSc & HMc & HNc & _ & Htatc).
      apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
      (* now the (tilt; return) block in leC' = set cancel vg leC, mem mC *)
      assert (Htatc' : forall b o,
         (PTree.set M._cancel vg leC) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { intros b o Hg. rewrite PTree.gso in Hg by (vm_compute; congruence).
        exact (Htatc b o Hg). }
      apply lnd_exec_seq_cases in Hsecond
        as [ (trE & leE & mE & trF & Htilt' & Hret) | (Htilt' & Hne1) ].
      + destruct (tilt_void_site_pres _ _ _ _ _ _ _
                    ltac:(apply PTree.gempty) Htatc' Htilt' HNc HMc HVc HSc)
          as (HVt & HSt & HMt & HNt & _ & _).
        apply lnd_exec_return_inv in Hret as (_ & -> & _).
        exact (conj HVt (conj HSt HMt)).
      + destruct (tilt_void_site_pres _ _ _ _ _ _ _
                    ltac:(apply PTree.gempty) Htatc' Htilt' HNc HMc HVc HSc)
          as (_ & _ & _ & _ & Ho & _). congruence.
    - (* first block exited abnormally: impossible (set ends Out_normal) *)
      apply lnd_exec_seq_cases in Hfirst
        as [ (trC & leC & mC & trD & Hcall & Hset) | (Hcall & Hne0) ].
      + apply lnd_exec_set_inv in Hset as (_ & Ho & _). congruence.
      + destruct (csaj_capture_site_pres M._t'1 201327166 50333824 50333838 145
                    _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                    ltac:(vm_compute; reflexivity) Htat Hcall HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). congruence.
  Qed.

  (* ================================================================== *)
  (* THE HOLD- PAIR: act_hold_stomach_slide + act_hold_butt_slide.        *)
  (* Each body = HOLD-FRONT ;; REST.  HOLD-FRONT loads the held-object    *)
  (* flag (t'3 = m->marioObj; t'4 = t'3->rawData.asS32[43]) and, if the   *)
  (* HOLDING bit is set, drop_and_set_mario_action(m, CONST, 0) + early   *)
  (* return.  REST is the corresponding non-hold slide body (ssa-capture  *)
  (* for stomach / csaj-capture + tilt for butt).  The two leading Ssets  *)
  (* touch only non-m temps (mem & le!_m unchanged); the drop_and_set     *)
  (* capture sets an UNTAINTED const action (Hdasma = call_pres_act).      *)
  (* ================================================================== *)

  (* the drop_and_set_mario_action(m, CONST, 0) capture site: action const
     at position 2 (untainted), threaded by Hdasma (call_pres_act).  Pins
     le!_m and returns Out_normal (mirrors ssa_capture_site_pres, but with
     one const action arg consumed by call_pres_act rather than a lift). *)
  Lemma dasma_capture_site_pres :
    forall tcap act arg2 le m tr le' m' out,
      tcap <> M._m ->
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some tcap)
           (Evar M._drop_and_set_mario_action
              (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr act) tint
            :: Econst_int (Int.repr arg2) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tcap act arg2 le m tr le' m' out Hcap Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._drop_and_set_mario_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr act)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr arg2)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Hmarg : marg_ok bm (v1 :: Vint (Int.repr act) :: Vint (Int.repr arg2) :: nil))
        by (unfold marg_ok; destruct v1 as [| | | | | bb oo]; auto; exact (Htat _ _ Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hdasma _ _ _ _ _ _ _ _ Hevf Hres Hmarg
                    (wact_const_sound _ Hact) HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _)
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hcap (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* the shared HOLD-FRONT block (generic over the two chase-load RHS a3/a4
     and the if condition): two non-m Ssets + a guarded drop_and_set early
     return.  Preserves the carried run facts; pins le!_m on fall-through
     (the if's Out_normal SKIP branch), vacuously on early return. *)
  Lemma hold_front_pres :
    forall a3 a4 cond act arg2 le m tr le' m' out,
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset M._t'3 a3)
           (Ssequence
              (Sset M._t'4 a4)
              (Sifthenelse cond
                 (Ssequence
                    (Scall (Some M._t'1)
                       (Evar M._drop_and_set_mario_action
                          (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default))
                       (Etempvar M._m tyMSp
                        :: Econst_int (Int.repr act) tint
                        :: Econst_int (Int.repr arg2) tint :: nil))
                    (Sreturn (Some (Etempvar M._t'1 tint))))
                 Sskip)))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (out = Out_normal ->
          (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero)).
  Proof.
    intros a3 a4 cond act arg2 le m tr le' m' out Hact Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hs3 & Hrest) | (Hs3 & Hne) ].
    2:{ apply lnd_exec_set_inv in Hs3 as (_ & Ho & _). congruence. }
    apply lnd_exec_set_inv in Hs3 as (-> & _ & v3 & ->).
    apply lnd_exec_seq_cases in Hrest
      as [ (tr1' & le2 & m2 & tr2' & Hs4 & Hif) | (Hs4 & Hne) ].
    2:{ apply lnd_exec_set_inv in Hs4 as (_ & Ho & _). congruence. }
    apply lnd_exec_set_inv in Hs4 as (-> & _ & v4 & ->).
    assert (Htat2 : forall b o,
       (PTree.set M._t'4 v4 (PTree.set M._t'3 v3 le)) ! M._m = Some (Vptr b o)
       -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      exact (Htat b o Hg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - (* then: drop_and_set capture + early return *)
      apply lnd_exec_seq_cases in Hif
        as [ (trX & leX & mX & trY & Hcall & Hret) | (Hcall & Hne0) ].
      + destruct (dasma_capture_site_pres M._t'1 act arg2 _ _ _ _ _ _
                    ltac:(vm_compute; congruence) Hact Htat2 Hcall HN HM HV HS)
          as (HVc & HSc & HMc & HNc & _ & _).
        apply lnd_exec_return_inv in Hret as (_ & -> & Hout).
        refine (conj HVc (conj HSc (conj HMc (conj HNc _)))).
        intros Hc; exfalso; apply Hout; exact Hc.
      + destruct (dasma_capture_site_pres M._t'1 act arg2 _ _ _ _ _ _
                    ltac:(vm_compute; congruence) Hact Htat2 Hcall HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). congruence.
    - (* else: skip -> fall-through, le!_m still pinned *)
      apply lnd_exec_skip_inv in Hif as (-> & -> & ->).
      refine (conj HV (conj HS (conj HM (conj HN _)))).
      intros _. exact Htat2.
  Qed.

  Example ahss_pin :
    (prog_defmap mario_actions_moving.prog) ! M._act_hold_stomach_slide
    = Some (Gfun (Internal M.f_act_hold_stomach_slide)).
  Proof. vm_compute. reflexivity. Qed.

  Example ahbs_pin :
    (prog_defmap mario_actions_moving.prog) ! M._act_hold_butt_slide
    = Some (Gfun (Internal M.f_act_hold_butt_slide)).
  Proof. vm_compute. reflexivity. Qed.

  (* act_hold_stomach_slide = HOLD-FRONT(9176147) ;; ssa-REST(901,16779425,137) *)
  Lemma mov_ahss_pres : body_pres lp NoA MWF bm M.f_act_hold_stomach_slide.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_stomach_slide) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_stomach_slide) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_stomach_slide)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_stomach_slide in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hhf & Hrest) | (Hhf & Hne) ].
    - destruct (hold_front_pres _ _ _ 9176147 0 _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hhf HN HM HV HS)
        as (HVa & HSa & HMa & HNa & Htatpin).
      specialize (Htatpin eq_refl).
      apply lnd_exec_seq_cases in Hrest
        as [ (trC & leC & mC & trD & Hfst & Hsnd) | (Hfst & Hne0) ].
      + apply lnd_exec_seq_cases in Hfst
          as [ (trE & leE & mE & trF & Hcall & Hset) | (Hcall & Hne1) ].
        2:{ destruct (ssa_capture_site_pres M._t'2 901 16779425 137 _ _ _ _ _ _
                        ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                        ltac:(vm_compute; reflexivity) Htatpin Hcall HNa HMa HVa HSa)
              as (_ & _ & _ & _ & Ho & _). congruence. }
        destruct (ssa_capture_site_pres M._t'2 901 16779425 137 _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                    ltac:(vm_compute; reflexivity) Htatpin Hcall HNa HMa HVa HSa)
          as (HVb & HSb & HMb & HNb & _ & _).
        apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
        apply lnd_exec_return_inv in Hsnd as (_ & -> & _).
        exact (conj HVb (conj HSb HMb)).
      + apply lnd_exec_seq_cases in Hfst
          as [ (trE & leE & mE & trF & Hcall & Hset) | (Hcall & Hne1) ].
        * apply lnd_exec_set_inv in Hset as (_ & Ho & _). congruence.
        * destruct (ssa_capture_site_pres M._t'2 901 16779425 137 _ _ _ _ _ _
                      ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                      ltac:(vm_compute; reflexivity) Htatpin Hcall HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - destruct (hold_front_pres _ _ _ 9176147 0 _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hhf HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _).
      exact (conj HVa (conj HSa HMa)).
  Qed.

  (* act_hold_butt_slide = HOLD-FRONT(8651858)
                           ;; csaj-REST(134218815,50333856,16779426,69) + tilt *)
  Lemma mov_ahbs_pres : body_pres lp NoA MWF bm M.f_act_hold_butt_slide.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_butt_slide) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_butt_slide) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_butt_slide)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_butt_slide in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trA & leA & mA & trB & Hhf & Hrest) | (Hhf & Hne) ].
    - destruct (hold_front_pres _ _ _ 8651858 0 _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hhf HN HM HV HS)
        as (HVa & HSa & HMa & HNa & Htatpin).
      specialize (Htatpin eq_refl).
      apply lnd_exec_seq_cases in Hrest
        as [ (trC & leC & mC & trD & Hfst & Hsnd) | (Hfst & Hne0) ].
      + apply lnd_exec_seq_cases in Hfst
          as [ (trE & leE & mE & trF & Hcall & Hset) | (Hcall & Hne1) ].
        2:{ destruct (csaj_capture_site_pres M._t'2 134218815 50333856 16779426 69
                        _ _ _ _ _ _ ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                        ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                        Htatpin Hcall HNa HMa HVa HSa)
              as (_ & _ & _ & _ & Ho & _). congruence. }
        destruct (csaj_capture_site_pres M._t'2 134218815 50333856 16779426 69
                    _ _ _ _ _ _ ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                    ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                    Htatpin Hcall HNa HMa HVa HSa)
          as (HVc & HSc & HMc & HNc & _ & Htatc).
        apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
        assert (Htatc' : forall b o,
           (PTree.set M._cancel vg leE) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
        { intros b o Hg. rewrite PTree.gso in Hg by (vm_compute; congruence).
          exact (Htatc b o Hg). }
        apply lnd_exec_seq_cases in Hsnd
          as [ (trG & leG & mG & trH & Htilt' & Hret) | (Htilt' & Hne2) ].
        * destruct (tilt_void_site_pres _ _ _ _ _ _ _
                      ltac:(apply PTree.gempty) Htatc' Htilt' HNc HMc HVc HSc)
            as (HVt & HSt & HMt & HNt & _ & _).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVt (conj HSt HMt)).
        * destruct (tilt_void_site_pres _ _ _ _ _ _ _
                      ltac:(apply PTree.gempty) Htatc' Htilt' HNc HMc HVc HSc)
            as (_ & _ & _ & _ & Ho & _). congruence.
      + apply lnd_exec_seq_cases in Hfst
          as [ (trE & leE & mE & trF & Hcall & Hset) | (Hcall & Hne1) ].
        * apply lnd_exec_set_inv in Hset as (_ & Ho & _). congruence.
        * destruct (csaj_capture_site_pres M._t'2 134218815 50333856 16779426 69
                      _ _ _ _ _ _ ltac:(vm_compute; congruence) ltac:(vm_compute; reflexivity)
                      ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                      Htatpin Hcall HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - destruct (hold_front_pres _ _ _ 8651858 0 _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hhf HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _).
      exact (conj HVa (conj HSa HMa)).
  Qed.



  Lemma mov_bwa_ids_rows : forall fid, mem_id fid mov_bwa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_bwa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_bwa_wids_rows : forall fid, mem_id fid mov_bwa_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_bwa_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* begin_walking_action: the PARAM-action producer.  Its _action param is
     threaded through wact into set_mario_action(m, _action, _actionArg);
     the call_pres_act3 obligation (untainted aval) discharges its body. *)
  Lemma mov_bwa_row :
    call_pres_act3 lp bm NoA MWF mario_actions_moving._begin_walking_action.
  Proof.
    apply (call_pres_act3_of_wwalk_p4 lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._begin_walking_action
             mario_actions_moving.f_begin_walking_action
             mov_bwa_wact mov_bwa_ids mov_bwa_wids nil nil nil
             mario_actions_moving._forwardVel mario_actions_moving._action
             mario_actions_moving._actionArg tfloat tuint
             LO_mov mov_bwa_pin mov_bwa_vars mov_bwa_params
             mov_bwa_aid_m mov_bwa_eid_m mov_bwa_harg_m
             mov_bwa_wa mov_bwa_wm mov_bwa_wanim mov_bwa_wharg
             eq_refl eq_refl eq_refl eq_refl).
    - exact mov_bwa_ids_rows.
    - exact mov_bwa_wids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_bwa_walk.
  Qed.

  Lemma mov_ata_ids_rows : forall fid, mem_id fid mov_ata_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_ashb_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    discriminate H.
  Qed.

  Lemma mov_ata_sids_rows : forall fid, mem_id fid mov_ata_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    discriminate H.
  Qed.

  Lemma mov_ata_xids_rows : forall fid, mem_id fid mov_ata_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_ata_tids_rows : forall fid, mem_id fid mov_ata_tids = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_bwa_row | ].
    discriminate H.
  Qed.

  Lemma mov_ata_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_turning_around.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_turning_around
             mov_ata_ids nil mov_ata_xids mov_ata_sids mov_ata_tids
             mov_ata_vars mov_ata_pok).
    - exact mov_ata_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ata_xids_rows.
    - exact mov_ata_sids_rows.
    - exact mov_ata_tids_rows.
    - exact mov_ata_walk.
  Qed.

  (* ================================================================== *)
  (* THE REST-SPLIT: the capstone's Hpres_mov_callees from the walked   *)
  (* leaves + the shrinking mov_rest_ids residual.                      *)
  (* ================================================================== *)
  Lemma moving_leaf_callees_pres :
    (forall fid f, mem_id fid mov_rest_ids = true ->
       (prog_defmap mario_actions_moving.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid moving_callee_ids = true ->
      (prog_defmap mario_actions_moving.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    unfold moving_callee_ids in H. cbn [mem_id existsb] in H.
    (* 1: check_common_moving_cancels -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ccmc_pin in Hdm. injection Hdm as <-. exact mov_ccmc_pres. }
    (* 2: act_walking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 3: act_hold_walking -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ahw_pin in Hdm. injection Hdm as <-. exact mov_ahw_pres. }
    (* 4: act_hold_heavy_walking -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ahhw_pin in Hdm. injection Hdm as <-. exact mov_ahhw_pres. }
    (* 5: act_turning_around -- WALKED (param-action / begin_walking_action) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ata_pin in Hdm. injection Hdm as <-. exact mov_ata_pres. }
    (* 6: act_finish_turning_around -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ftn_pin in Hdm. injection Hdm as <-. exact mov_ftn_pres. }
    (* 7: act_braking -- WALKED (twl-style hybrid: slide_bonk switch site) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_bk_pin in Hdm. injection Hdm as <-. exact mov_bk_pres. }
    (* 8: act_riding_shell_ground -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 9: act_crawling -- WALKED (nids-engine; align_with_floor gchase store) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_cr_pin in Hdm. injection Hdm as <-. exact mov_cr_pres. }
    (* 10: act_burning_ground -- WALKED (nids-engine; np3 smawa via nsrc_chk) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_abg_pin in Hdm. injection Hdm as <-. exact mov_abg_pres. }
    (* 11: act_decelerating -- WALKED (A-gated np3 hybrid) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_dec_pin in Hdm. injection Hdm as <-. exact mov_dec_pres. }
    (* 12: act_hold_decelerating -- WALKED (val0C np3 leaf) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ahd_pin in Hdm. injection Hdm as <-. exact mov_ahd_pres. }
    (* 13: act_butt_slide -- WALKED (csaj keystone + tilt_body_butt_slide) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite abs_pin in Hdm. injection Hdm as <-. exact mov_abs_pres. }
    (* 14: act_stomach_slide -- WALKED (csa/ssa keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_assl_pin in Hdm. injection Hdm as <-. exact mov_assl_pres. }
    (* 15: act_hold_butt_slide -- WALKED (HOLD-FRONT + csaj-REST + tilt) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite ahbs_pin in Hdm. injection Hdm as <-. exact mov_ahbs_pres. }
    (* 16: act_hold_stomach_slide -- WALKED (HOLD-FRONT + ssa-REST) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite ahss_pin in Hdm. injection Hdm as <-. exact mov_ahss_pres. }
    (* 17: act_dive_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 18: act_move_punching -- WALKED (clean engine walk) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_mp_pin in Hdm. injection Hdm as <-. exact mov_mp_pres. }
    (* 19: act_crouch_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 20: act_slide_kick_slide -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sks_pin in Hdm. injection Hdm as <-. exact mov_sks_pres. }
    (* 21: act_hard_backward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hbkb_pin in Hdm. injection Hdm as <-. exact mov_hbkb_pres. }
    (* 22: act_hard_forward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hfkb_pin in Hdm. injection Hdm as <-. exact mov_hfkb_pres. }
    (* 23: act_backward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_bkb_pin in Hdm. injection Hdm as <-. exact mov_bkb_pres. }
    (* 24: act_forward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_fkb_pin in Hdm. injection Hdm as <-. exact mov_fkb_pres. }
    (* 25: act_soft_backward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sbkb_pin in Hdm. injection Hdm as <-. exact mov_sbkb_pres. }
    (* 26: act_soft_forward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sfkb_pin in Hdm. injection Hdm as <-. exact mov_sfkb_pres. }
    (* 27: act_ground_bonk -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_gbonk_pin in Hdm. injection Hdm as <-. exact mov_gbonk_pres. }
    (* 28: act_death_exit_land -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_del_pin in Hdm. injection Hdm as <-. exact mov_del_pres. }
    (* 29: act_jump_land -- WALKED (landing keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_jland_pin in Hdm. injection Hdm as <-. exact mov_jland_pres. }
    (* 30: act_freefall_land -- WALKED (landing keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ffland_pin in Hdm. injection Hdm as <-. exact mov_ffland_pres. }
    (* 31: act_double_jump_land -- WALKED (landing keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_djland_pin in Hdm. injection Hdm as <-. exact mov_djland_pres. }
    (* 32: act_side_flip_land -- WALKED (landing keystone part 4) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sfland_pin in Hdm. injection Hdm as <-. exact mov_sfland_pres. }
    (* 33: act_hold_jump_land -- WALKED (landing keystone part 2) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hjland_pin in Hdm. injection Hdm as <-. exact mov_hjland_pres. }
    (* 34: act_hold_freefall_land -- WALKED (landing keystone part 2) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hfland_pin in Hdm. injection Hdm as <-. exact mov_hfland_pres. }
    (* 35: act_triple_jump_land -- WALKED (landing keystone part 3) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_tjland_pin in Hdm. injection Hdm as <-. exact mov_tjland_pres. }
    (* 36: act_backflip_land -- WALKED (landing keystone part 3) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_bfland_pin in Hdm. injection Hdm as <-. exact mov_bfland_pres. }
    (* 37: act_quicksand_jump_land -- WALKED (quicksand keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_qjland_pin in Hdm. injection Hdm as <-. exact mov_qjland_pres. }
    (* 38: act_hold_quicksand_jump_land -- WALKED (quicksand keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hqjland_pin in Hdm. injection Hdm as <-. exact mov_hqjland_pres. }
    (* 39: act_long_jump_land -- WALKED (landing keystone part 3) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ljland_pin in Hdm. injection Hdm as <-. exact mov_ljland_pres. }
    discriminate H.
  Qed.

End MovingLeafRows.
