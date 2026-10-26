(* ======================================================================= *)
(* NaSplit (GOAL 2): HeightFrame's per-call row Hseg_call_na, split per    *)
(* call (2026-10-23).                                                      *)
(*                                                                         *)
(* AutoSplit.seg_call_rows_naFA asks every `f(gMarioState)` call of the    *)
(* real execute_mario_action other than the airborne and the automatic     *)
(* dispatchers to keep the frame world (FrameSplit.fworld), move Phi's     *)
(* cells by a MoveChain and meet its post_of.  Read off the generated body *)
(* (ema_calls_eq, computed) those are 15 calls:                            *)
(*   mario_reset_bodystate, update_mario_inputs,                           *)
(*   mario_handle_special_floors, mario_process_interactions,              *)
(*   the stationary / moving / submerged / cutscene / object dispatchers,  *)
(*   sink_mario_in_quicksand, squish_mario_model,                          *)
(*   set_submerged_cam_preset_and_spawn_bubbles, update_mario_health,      *)
(*   update_mario_info_for_cam, mario_update_hitbox_and_cap_model.         *)
(* This file proves seg_call_rows_naFA from one row per call: the calls in *)
(* na_open stay assumed (na_open_rows, HeightFrame.Hseg_na_open), the      *)
(* others are PROVED here from the generated bodies:                       *)
(*   - set_submerged_cam_preset_and_spawn_bubbles: its whole body sits     *)
(*     under (m->action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED, and no   *)
(*     action of R_noA is submerged (R_noA_not_sub, computed), so memory   *)
(*     is unchanged;                                                       *)
(*   - mario_execute_submerged_action: since 2026-10-23 a dispatcher's row *)
(*     assumes the action is in its own group (FrameSplit.grp_ok, proved   *)
(*     at the real switch), so this row is vacuous: no R_noA action is in  *)
(*     group 0xC0.  Before, the row ranged over every action (phantom      *)
(*     forall: the real submerged dispatcher on a walking Mario).          *)
(*   - update_mario_health: a walk of the real body (AudioBodies.         *)
(*     lw_body_frame) whose every store is m->health, m->hurtCounter or    *)
(*     m->healCounter (bytes 174..179 of Mario's state) and whose one call *)
(*     is the real play_sound (SndXc.ps_walk: sSoundRequests and its       *)
(*     count).  No conjunct of the frame world, Phi's cells or the floor   *)
(*     refresh reads those bytes or blocks (ProRows' hole lemmas, widened  *)
(*     from m->flags to bytes 4..7 and 174..183).  This holds on EVERY     *)
(*     path, whatever health / counters / action the memory holds, so the *)
(*     row needs no new world fact.                                        *)
(*   - mario_reset_bodystate and update_mario_info_for_cam (2026-10-24):   *)
(*     walks of the real bodies whose stores go to Mario's own fields      *)
(*     (none read by the world, ProRows.hz) or through a temp that holds   *)
(*     m->marioBodyState or m->statusForCamera.  Since 2026-10-24 ffw      *)
(*     pins m->marioBodyState = &gBodyStates[0] (FfWorld, load at 152;     *)
(*     gBodyStates is ff_rl region RBS, proved at boot in StartSat and     *)
(*     kept by every proved row), and m->statusForCamera =                 *)
(*     &gPlayerCameraState was already pinned, so every store lands in     *)
(*     one of the two hole globals (ProRows.XIDS).  info_for_cam's callees *)
(*     vec3s_copy / vec3f_copy are walked too (BodyFrame.v3_frame): they   *)
(*     change only the dest block, plus their own freed `dest` frame       *)
(*     (BodyFrame.Q2 lets memory grow by permission-less blocks).          *)
(*   - squish_mario_model (2026-10-24): a walk of the real body whose      *)
(*     stores are m->squishTimer (in the hole) or                          *)
(*     m->marioObj->header.gfx.scale[i], i < 3, and whose calls are the    *)
(*     real vec3f_set(m->marioObj->header.gfx.scale, ...) (BodyFrame.      *)
(*     v3set_frame, walked).  The Object* temps are loaded from            *)
(*     m->marioObj, which ffw pins to Mario's object (offset 136, Object   *)
(*     in bounds), so every write lands in bytes 44..55 of that object:    *)
(*     ProRows' third, optional hole (ob, oz).  No world conjunct, Phi     *)
(*     cell (gfx.pos[1] is at 36) or floor refresh reads those bytes.      *)
(*   - sink_mario_in_quicksand (2026-10-24): a walk of the real body       *)
(*     (qs_row).  Since 2026-10-24 ffw pins Mario's object's               *)
(*     gfx.throwMatrix (offset 80) to NULL or a pointer into               *)
(*     sFloorAlignMatrix, which is ff_rl region RFA, so the store          *)
(*     ( *throwMatrix )[3][1] -= quicksandDepth lands in a hole global      *)
(*     (ProRows.XIDS).  The other store writes gfx.pos[1] (Phi's gfx cell, *)
(*     offset 36) := pos[1] - quicksandDepth; wmotr_world pins             *)
(*     quicksandDepth to +0 and budget_ok makes the cell finite, so it     *)
(*     writes back its own value (f32_sub_zero_r).  ProRows' object window *)
(*     is generic (ow, wl): here bytes 36..39, with hole_cells told that   *)
(*     the gfx cell kept its value.                                        *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario math_util camera mario_actions_moving.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface AirborneSurface.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AirSplit AutoSplit ProRows BodyFrame.
From SM64.Proofs.WMotRRequiresA Require AnimWorld AnimKeep LsContract CapAudio HitboxFrame HoleX.
From SM64.Proofs Require Import MarioModel.AudioBodies MarioModel.LinkedTwelve.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The calls, computed.                                                *)
(* ---------------------------------------------------------------------- *)

Lemma ema_calls_eq : ema_calls =
  [mario._mario_reset_bodystate; mario._update_mario_inputs;
   mario._mario_handle_special_floors; mario._mario_process_interactions;
   mario._mario_execute_stationary_action; mario._mario_execute_moving_action;
   mario._mario_execute_airborne_action; mario._mario_execute_submerged_action;
   mario._mario_execute_cutscene_action; mario._mario_execute_automatic_action;
   mario._mario_execute_object_action;
   mario._sink_mario_in_quicksand; mario._squish_mario_model;
   mario._set_submerged_cam_preset_and_spawn_bubbles; mario._update_mario_health;
   mario._update_mario_info_for_cam; mario._mario_update_hitbox_and_cap_model].
Proof. vm_compute. reflexivity. Qed.

(* the calls whose rows stay assumed *)
Definition na_open : list ident :=
  [mario._update_mario_inputs;
   mario._mario_handle_special_floors; mario._mario_process_interactions;
   mario._mario_execute_stationary_action; mario._mario_execute_moving_action;
   mario._mario_execute_cutscene_action; mario._mario_execute_object_action].

(* ---------------------------------------------------------------------- *)
(* 2. No R_noA action is submerged.                                       *)
(* ---------------------------------------------------------------------- *)

Lemma R_noA_grp_chk :
  forallb (fun z => negb (Z.eqb (Int.unsigned (Int.and (Int.repr z) (Int.repr 448))) 192)) R_noA_list
  = true.
Proof. vm_compute. reflexivity. Qed.

Lemma R_noA_not_sub : forall a, R_noA a -> Int.unsigned (Int.and a (Int.repr 448)) <> 192.
Proof.
  intros a Ha E. pose proof R_noA_grp_chk as C. rewrite forallb_forall in C.
  specialize (C _ Ha). rewrite Int.repr_unsigned, E in C. discriminate C.
Qed.

Lemma R_noA_eq_sub : forall a, R_noA a -> Int.eq (Int.and a (Int.repr 448)) (Int.repr 192) = false.
Proof.
  intros a Ha. destruct (Int.eq _ _) eqn:E; [| reflexivity].
  apply Int.same_if_eq in E. exfalso. apply (R_noA_not_sub a Ha). rewrite E. reflexivity.
Qed.

Lemma disp_grp_sub : disp_grp mario._mario_execute_submerged_action = 192.
Proof. vm_compute. reflexivity. Qed.

Lemma sb_eq_ui : forall (ce : composite_env) a b m,
  sem_binary_operation ce Oeq (Vint a) tuint (Vint b) tint m = Some (Val.of_bool (Int.eq a b)).
Proof. reflexivity. Qed.

Lemma sb_shl_3_6 : forall (ce : composite_env) m,
  sem_binary_operation ce Oshl (Vint (Int.repr 3)) tint (Vint (Int.repr 6)) tint m
  = Some (Vint (Int.repr 192)).
Proof. reflexivity. Qed.

Lemma ssc_is : is_umi mario._set_submerged_cam_preset_and_spawn_bubbles = false
  /\ is_fk mario._set_submerged_cam_preset_and_spawn_bubbles = false
  /\ is_disp mario._set_submerged_cam_preset_and_spawn_bubbles = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma sub_is : is_fk mario._mario_execute_submerged_action = false
  /\ is_disp mario._mario_execute_submerged_action = true.
Proof. vm_compute. split; reflexivity. Qed.

Lemma dm_ssc : (prog_defmap mario.prog) ! mario._set_submerged_cam_preset_and_spawn_bubbles
  = Some (Gfun (Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. update_mario_health's walk: every store is m->health, m->hurtCounter *)
(*    or m->healCounter (in ProRows' hole), the one call play_sound.       *)
(* ---------------------------------------------------------------------- *)

Definition hole_in (d s : Z) : bool :=
  ((4 <=? d) && (d + s <=? 8)) || ((174 <=? d) && (d + s <=? 184)).

Lemma hole_in_spec : forall d s, hole_in d s = true ->
  (4 <= d /\ d + s <= 8) \/ (174 <= d /\ d + s <= 184).
Proof.
  intros d s H. unfold hole_in in H. apply orb_true_iff in H as [H | H];
    apply andb_true_iff in H as [H1 H2]; apply Z.leb_le in H1; apply Z.leb_le in H2; [left | right]; lia.
Qed.

(* a by-value field of Mario's state whose bytes lie in the hole *)
Definition fld_ok (f : ident) (ty : type) : bool :=
  match access_mode ty with
  | By_value ch =>
      match mario_fo mario._MarioState f with
      | Some (d, Full) => hole_in d (size_chunk ch)
      | _ => false
      end
  | _ => false
  end.

Lemma fld_ok_spec : forall f ty, fld_ok f ty = true ->
  exists ch d, access_mode ty = By_value ch /\ mario_fo mario._MarioState f = Some (d, Full)
    /\ hole_in d (size_chunk ch) = true.
Proof.
  intros f ty H. unfold fld_ok in H.
  (* no discriminate on the unreduced match: its hnf computes mario_fo *)
  destruct (access_mode ty) as [ch | | |] eqn:E1; [| exact (False_ind _ (diff_false_true H))
    | exact (False_ind _ (diff_false_true H)) | exact (False_ind _ (diff_false_true H))].
  destruct (mario_fo mario._MarioState f) as [[d bf] |] eqn:E2;
    [| exact (False_ind _ (diff_false_true H))].
  destruct bf as [| sz sg pos w]; [| exact (False_ind _ (diff_false_true H))].
  exists ch, d. split; [reflexivity |]. split; [reflexivity | exact H].
Qed.

(* `pm->f = ...` with pm the MarioState parameter *)
Definition fld_store_ok (pm : ident) (lv rhs : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) (Tstruct sid (mk_attr false None))) f ty =>
      Pos.eqb x pm && Pos.eqb sid mario._MarioState && fld_ok f ty
  | _ => false
  end.

Lemma hl_chk : lw_chk (fun id _ => negb (Pos.eqb id mario._m)) (fld_store_ok mario._m) pffs_call_ok
                 (fn_body mario.f_update_mario_health) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma health_is : is_umi mario._update_mario_health = false
  /\ is_fk mario._update_mario_health = false
  /\ is_disp mario._update_mario_health = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma dm_health : (prog_defmap mario.prog) ! mario._update_mario_health
  = Some (Gfun (Internal mario.f_update_mario_health)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. mario_reset_bodystate / update_mario_info_for_cam: every store is   *)
(*    m->flags (in the hole) or through a temp loaded from                *)
(*    m->marioBodyState / m->statusForCamera (FfWorld.ffw: &gBodyStates[0] *)
(*    and &gPlayerCameraState[0], two ffw regions); the calls are the real *)
(*    vec3s_copy / vec3f_copy into the latter (BodyFrame.v3_frame).       *)
(* ---------------------------------------------------------------------- *)
Definition TPS : list ident := [mario._bodyState; mario._t'6; mario._t'4; mario._t'3; mario._t'2].

Lemma m_notin_TPS : ~ In mario._m TPS.
Proof. intros H. vm_compute in H. repeat (destruct H as [H | H]; [discriminate H |]). exact H. Qed.

Definition tp_ok (x1 x2 : block) (le : temp_env) : Prop :=
  forall x p, In x TPS -> le ! x = Some p -> p = Vptr x1 Ptrofs.zero \/ p = Vptr x2 Ptrofs.zero \/ p = Vundef.

Definition tp_src (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar x (Tpointer (Tstruct s1 (mk_attr false None)) (mk_attr false None)))
                   (Tstruct s2 (mk_attr false None))) f (Tpointer _ _) =>
      Pos.eqb x mario._m && Pos.eqb s1 mario._MarioState && Pos.eqb s2 mario._MarioState
      && (Pos.eqb f mario._marioBodyState || Pos.eqb f mario._statusForCamera)
  | _ => false
  end.

Definition tp_set_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id mario._m) && (negb (existsb (Pos.eqb id) TPS) || tp_src a).

Definition tp_store_ok (lv : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) _) _ _ => existsb (Pos.eqb x) TPS
  | _ => false
  end.

Definition bs_store_ok (lv rhs : expr) : bool := fld_store_ok mario._m lv rhs || tp_store_ok lv.

Definition v3_call (optid : option ident) (a : expr) (al : list expr) : bool :=
  match optid, a, al with
  | None, Evar f (Tfunction (Tpointer _ _ :: _) _ _),
    Efield (Ederef (Etempvar x _) _) _ (Tarray _ _ _) :: _ :: nil =>
      (Pos.eqb f mario._vec3s_copy || Pos.eqb f mario._vec3f_copy) && existsb (Pos.eqb x) TPS
  | _, _, _ => false
  end.

Lemma reset_chk : lw_chk tp_set_ok bs_store_ok no_call (fn_body mario.f_mario_reset_bodystate) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma cam_chk : lw_chk tp_set_ok bs_store_ok v3_call (fn_body mario.f_update_mario_info_for_cam) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma body_fo : mario_fo mario._MarioState mario._marioBodyState = Some (152, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma pcs_fo : mario_fo mario._MarioState mario._statusForCamera = Some (148, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_reset : (prog_defmap mario.prog) ! mario._mario_reset_bodystate
  = Some (Gfun (Internal mario.f_mario_reset_bodystate)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cam : (prog_defmap mario.prog) ! mario._update_mario_info_for_cam
  = Some (Gfun (Internal mario.f_update_mario_info_for_cam)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_v3s : (prog_defmap math_util.prog) ! mario._vec3s_copy
  = Some (Gfun (Internal math_util.f_vec3s_copy)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_v3f : (prog_defmap math_util.prog) ! mario._vec3f_copy
  = Some (Gfun (Internal math_util.f_vec3f_copy)).
Proof. vm_compute. reflexivity. Qed.

Lemma reset_is : is_umi mario._mario_reset_bodystate = false
  /\ is_fk mario._mario_reset_bodystate = false
  /\ is_disp mario._mario_reset_bodystate = false.
Proof. vm_compute. repeat split; reflexivity. Qed.
Lemma cam_is : is_umi mario._update_mario_info_for_cam = false
  /\ is_fk mario._update_mario_info_for_cam = false
  /\ is_disp mario._update_mario_info_for_cam = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma tp_init : forall v f x1 x2 le1,
  fn_params f = [(mario._m, tyMSp)] ->
  bind_parameter_temps (fn_params f) [v] (create_undef_temps (fn_temps f)) = Some le1 ->
  le1 ! mario._m = Some v /\ tp_ok x1 x2 le1.
Proof.
  intros v f x1 x2 le1 Hp Hb. rewrite Hp in Hb. cbn [bind_parameter_temps] in Hb. injection Hb as <-.
  split; [apply PTree.gss |].
  intros x p Hin Hx. right; right.
  rewrite PTree.gso in Hx by (intros ->; exact (m_notin_TPS Hin)).
  exact (cut_undef _ _ _ Hx).
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. squish_mario_model: every store is m->squishTimer (in the hole) or  *)
(*    m->marioObj->header.gfx.scale[i], i < 3; the calls are the real     *)
(*    vec3f_set(m->marioObj->header.gfx.scale, ...) (BodyFrame.           *)
(*    v3set_frame).  The temps that hold an Object* are loaded from       *)
(*    m->marioObj (ffw: &Mario's object, offset 136).                     *)
(* ---------------------------------------------------------------------- *)
Definition OT : list ident :=
  [mario._t'16; mario._t'12; mario._t'9; mario._t'7; mario._t'6; mario._t'4].

Lemma m_notin_OT : ~ In mario._m OT.
Proof. intros H. vm_compute in H. repeat (destruct H as [H | H]; [discriminate H |]). exact H. Qed.

(* m->marioObj *)
Definition mo_src (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar x (Tpointer (Tstruct s1 (mk_attr false None)) (mk_attr false None)))
                   (Tstruct s2 (mk_attr false None))) f (Tpointer _ _) =>
      Pos.eqb x mario._m && Pos.eqb s1 mario._MarioState && Pos.eqb s2 mario._MarioState
      && Pos.eqb f mario._marioObj
  | _ => false
  end.

Definition sq_set_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id mario._m) && (negb (existsb (Pos.eqb id) OT) || mo_src a).

(* t->header.gfx.scale, t one of OT *)
Definition sc_lv (a : expr) : bool :=
  match a with
  | Efield (Efield (Efield (Ederef (Etempvar x _) (Tstruct s1 (mk_attr false None))) f1
                           (Tstruct s2 (mk_attr false None))) f2
                   (Tstruct s3 (mk_attr false None))) f3 (Tarray (Tfloat Ctypes.F32 _) _ _) =>
      existsb (Pos.eqb x) OT && Pos.eqb s1 mario._Object && Pos.eqb f1 mario._header
      && Pos.eqb s2 mario._ObjectNode && Pos.eqb f2 mario._gfx
      && Pos.eqb s3 mario._GraphNodeObject && Pos.eqb f3 mario._scale
  | _ => false
  end.

(* t->header.gfx.scale[i] = ..., i < 3 *)
Definition sc_store_ok (lv : expr) : bool :=
  match lv with
  | Ederef (Ebinop Oadd a (Econst_int i (Tint _ _ _)) _) (Tfloat Ctypes.F32 _) =>
      sc_lv a && (Int.unsigned i <? 3)
  | _ => false
  end.

Definition sq_store_ok (lv rhs : expr) : bool := fld_store_ok mario._m lv rhs || sc_store_ok lv.

Definition sc_call (optid : option ident) (a : expr) (al : list expr) : bool :=
  match optid, a, al with
  | None, Evar f (Tfunction (Tpointer _ _ :: _) _ _), a1 :: _ =>
      Pos.eqb f mario._vec3f_set && sc_lv a1
  | _, _, _ => false
  end.

Lemma sq_chk : lw_chk sq_set_ok sq_store_ok sc_call (fn_body mario.f_squish_mario_model) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma mobj_fo : mario_fo mario._MarioState mario._marioObj = Some (136, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hdr_fo : mario_fo mario._Object mario._header = Some (0, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma gfx_fo : mario_fo mario._ObjectNode mario._gfx = Some (0, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma scale_fo : mario_fo mario._GraphNodeObject mario._scale = Some (44, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_squish : (prog_defmap mario.prog) ! mario._squish_mario_model
  = Some (Gfun (Internal mario.f_squish_mario_model)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_v3set : (prog_defmap math_util.prog) ! mario._vec3f_set
  = Some (Gfun (Internal math_util.f_vec3f_set)).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_hitbox : (prog_defmap mario.prog) ! mario._mario_update_hitbox_and_cap_model
  = Some (Gfun (Internal mario.f_mario_update_hitbox_and_cap_model)).
Proof. vm_compute. reflexivity. Qed.

Lemma hitbox_is : is_umi mario._mario_update_hitbox_and_cap_model = false
  /\ is_fk mario._mario_update_hitbox_and_cap_model = false
  /\ is_disp mario._mario_update_hitbox_and_cap_model = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma squish_is : is_umi mario._squish_mario_model = false
  /\ is_fk mario._squish_mario_model = false
  /\ is_disp mario._squish_mario_model = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition ot_ok (bo : block) (oo : ptrofs) (le : temp_env) : Prop :=
  forall x p, In x OT -> le ! x = Some p -> p = Vptr bo oo \/ p = Vundef.

Lemma ot_init : forall v f bo oo le1,
  fn_params f = [(mario._m, tyMSp)] ->
  bind_parameter_temps (fn_params f) [v] (create_undef_temps (fn_temps f)) = Some le1 ->
  le1 ! mario._m = Some v /\ ot_ok bo oo le1.
Proof.
  intros v f bo oo le1 Hp Hb. rewrite Hp in Hb. cbn [bind_parameter_temps] in Hb. injection Hb as <-.
  split; [apply PTree.gss |].
  intros x p Hin Hx. right.
  rewrite PTree.gso in Hx by (intros ->; exact (m_notin_OT Hin)).
  exact (cut_undef _ _ _ Hx).
Qed.

(* ---------------------------------------------------------------------- *)
(* 6. sink_mario_in_quicksand: its stores are                             *)
(*    ( *throwMatrix )[3][1] (into sFloorAlignMatrix: ffw pins Mario's      *)
(*    throwMatrix to NULL or that block) and o->header.gfx.pos[1] :=      *)
(*    pos[1] - m->quicksandDepth, which rewrites Phi's gfx cell with its  *)
(*    own value (quicksandDepth is +0 in WMotR, wmotr_world, and x - 0 =  *)
(*    x on a finite binary32).                                            *)
(* ---------------------------------------------------------------------- *)
Definition QT : list ident := [mario._t'3; mario._t'4; mario._t'5].

(* o->header.gfx.<f> with a type matched by the caller *)
Definition og_fld (a : expr) : bool :=
  match a with
  | Efield (Efield (Ederef (Etempvar x _) (Tstruct s1 (mk_attr false None))) f1
                   (Tstruct s2 (mk_attr false None))) f2
           (Tstruct s3 (mk_attr false None)) =>
      Pos.eqb x mario._o && Pos.eqb s1 mario._Object && Pos.eqb f1 mario._header
      && Pos.eqb s2 mario._ObjectNode && Pos.eqb f2 mario._gfx
      && Pos.eqb s3 mario._GraphNodeObject
  | _ => false
  end.

(* o->header.gfx.throwMatrix *)
Definition tm_src (a : expr) : bool :=
  match a with
  | Efield g f (Tpointer _ _) => Pos.eqb f mario._throwMatrix && og_fld g
  | _ => false
  end.

(* &o->header.gfx.pos[1], and its cell *)
Definition gy_x (a : expr) : bool :=
  match a with
  | Ebinop Oadd (Efield g f (Tarray (Tfloat Ctypes.F32 _) _ _)) (Econst_int i (Tint _ _ _)) _ =>
      Pos.eqb f mario._pos && og_fld g && Int.eq i Int.one
  | _ => false
  end.
Definition gy_lv (a : expr) : bool :=
  match a with
  | Ederef x (Tfloat Ctypes.F32 _) => gy_x x
  | _ => false
  end.

(* m->quicksandDepth *)
Definition qd_src (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar x (Tpointer (Tstruct s1 (mk_attr false None)) (mk_attr false None)))
                   (Tstruct s2 (mk_attr false None))) f (Tfloat Ctypes.F32 _) =>
      Pos.eqb x mario._m && Pos.eqb s1 mario._MarioState && Pos.eqb s2 mario._MarioState
      && Pos.eqb f mario._quicksandDepth
  | _ => false
  end.

Definition qs_set_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id mario._m) &&
  (if Pos.eqb id mario._o then mo_src a
   else if existsb (Pos.eqb id) QT then tm_src a
   else if Pos.eqb id mario._t'1 then gy_lv a
   else if Pos.eqb id mario._t'2 then qd_src a
   else true).

(* ( *t )[i][j], t one of QT *)
Definition tm_store (lv : expr) : bool :=
  match lv with
  | Ederef (Ebinop Oadd (Ederef (Ebinop Oadd (Ederef (Etempvar x _) (Tarray _ _ _))
                                        (Econst_int _ (Tint _ _ _)) _) (Tarray _ _ _))
                  (Econst_int _ (Tint _ _ _)) _) (Tfloat Ctypes.F32 _) =>
      existsb (Pos.eqb x) QT
  | _ => false
  end.

(* pos[1] = t'1 - t'2 *)
Definition gy_store (lv rhs : expr) : bool :=
  gy_lv lv &&
  match rhs with
  | Ebinop Osub (Etempvar x1 (Tfloat Ctypes.F32 _)) (Etempvar x2 (Tfloat Ctypes.F32 _)) (Tfloat Ctypes.F32 _) =>
      Pos.eqb x1 mario._t'1 && Pos.eqb x2 mario._t'2
  | _ => false
  end.

Definition qs_store_ok (lv rhs : expr) : bool := tm_store lv || gy_store lv rhs.

Definition qs_call (optid : option ident) (a : expr) (al : list expr) : bool := false.

Lemma qs_chk : lw_chk qs_set_ok qs_store_ok qs_call (fn_body mario.f_sink_mario_in_quicksand) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma throw_fo : mario_fo mario._GraphNodeObject mario._throwMatrix = Some (80, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma pos_fo : mario_fo mario._GraphNodeObject mario._pos = Some (32, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma qsd_fo : mario_fo mario._MarioState mario._quicksandDepth = Some (192, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_qs : (prog_defmap mario.prog) ! mario._sink_mario_in_quicksand
  = Some (Gfun (Internal mario.f_sink_mario_in_quicksand)).
Proof. vm_compute. reflexivity. Qed.

Lemma qs_is : is_umi mario._sink_mario_in_quicksand = false
  /\ is_fk mario._sink_mario_in_quicksand = false
  /\ is_disp mario._sink_mario_in_quicksand = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(* x - (+0) = x on a finite binary32 *)
Lemma f32_sub_zero_r : forall x, F32 x = true -> Float32.sub x Float32.zero = x.
Proof.
  intros [s | s | s pl Hpl | s mx ex Hx] Fx; try discriminate Fx; [destruct s |]; reflexivity.
Qed.

(* pointer + int keeps the block *)
Lemma add_blk : forall (ce : composite_env) b o t k a1 n sz sg a' mm v,
  sem_binary_operation ce Oadd (Vptr b o) (Tarray t k a1) (Vint n) (Tint sz sg a') mm = Some v ->
  exists o', v = Vptr b o'.
Proof. intros. destruct sz; cbn in H; injection H as <-; eexists; reflexivity. Qed.

Definition qt_ok (bfa : block) (le : temp_env) : Prop :=
  forall x p, In x QT -> le ! x = Some p -> p = Vint Int.zero \/ (exists o, p = Vptr bfa o) \/ p = Vundef.

Definition qs_P (v : val) (bo : block) (oo : ptrofs) (bfa : block) (gy : float32) (le : temp_env) : Prop :=
  le ! mario._m = Some v
  /\ (forall p, le ! mario._o = Some p -> p = Vptr bo oo \/ p = Vundef)
  /\ qt_ok bfa le
  /\ (forall p, le ! mario._t'1 = Some p -> p = Vsingle gy \/ p = Vundef)
  /\ (forall p, le ! mario._t'2 = Some p -> p = Vsingle Float32.zero \/ p = Vundef).

Section NA.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Variable MWF : mem -> Prop.
  Hypothesis Hgms : forall m, MWF m -> gms_cond_lp lp m bm.
  (* load_sequence's footprint (LsContract.ls_frame, part of the labeled
     audio premise, TRUST 4.1): the hitbox row's cap music path *)
  Hypothesis Hlsf : LsContract.ls_frame lp.

  Notation ge := (lp_ge lp).

  (* ==================================================================== *)
  (* THE ROWS THAT STAY ASSUMED                                           *)
  (* ==================================================================== *)
  Definition na_open_rows : Prop :=
    forall f fd v, In f na_open -> resolves lp f fd ->
      seg_okR lp bm MWF fd [v] (pre_of lp bm f v) (post_of bm f).

  Lemma marg_of_gms : forall v m, mem_ok_lp bm MWF m -> gms_val lp v m -> marg_ok bm [v].
  Proof.
    intros v m Hok Hgv. destruct v; cbn; try exact I. destruct Hgv as (gb & Hg & Hl).
    exact (Hgms m (proj2 (proj2 Hok)) gb b i Hg Hl).
  Qed.

  (* ==================================================================== *)
  (* set_submerged_cam_preset_and_spawn_bubbles: memory unchanged.        *)
  (* ==================================================================== *)
  Lemma ssc_mem : forall v m t m' vr, marg_ok bm [v] -> action_sat R_noA m bm ->
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles) [v] t m' vr ->
    m' = m.
  Proof.
    intros v m t m' vr Hmarg Hsat Hev.
    destruct (fc_entry ge m mario.f_set_submerged_cam_preset_and_spawn_bubbles [v] t m' vr eq_refl Hev)
      as (le0 & le' & t' & out & Hbind & H).
    assert (Hle : le0 ! mario._m = Some v).
    { change (fn_params mario.f_set_submerged_cam_preset_and_spawn_bubbles) with [(mario._m, tyMSp)] in Hbind.
      cbn [bind_parameter_temps] in Hbind. injection Hbind as <-. apply PTree.gss. }
    unfold mario.f_set_submerged_cam_preset_and_spawn_bubbles in H. cbn [fn_body] in H.
    apply (seq_set_inv lp) in H as (va & Ea & H).
    destruct (ev_fld lp H12 bm mario._m le0 m v mario._action tuint Mint32 12 va Hle Hmarg
                action_fo ltac:(lia) eq_refl Ea) as (-> & La).
    apply x_if in H as (vc & bc & Ec & Bc & H).
    apply eval_expr_Ebinop_inv in Ec as (v1 & v2 & E1 & E2 & S1).
    apply eval_expr_Ebinop_inv in E1 as (v3 & v4 & E3 & E4 & S3).
    apply eval_expr_Etempvar_val in E3. rewrite PTree.gss in E3. injection E3 as <-.
    apply eval_expr_Econst_int_val in E4. subst v4.
    cbn [typeof] in S3. destruct (sw_and_448 _ _ _ _ S3) as (a & -> & ->).
    apply eval_expr_Ebinop_inv in E2 as (v5 & v6 & E5 & E6 & S5).
    apply eval_expr_Econst_int_val in E5. apply eval_expr_Econst_int_val in E6. subst v5 v6.
    cbn [typeof] in S5. rewrite sb_shl_3_6 in S5. injection S5 as <-.
    cbn [typeof] in S1, Bc. rewrite sb_eq_ui in S1. injection S1 as <-.
    apply bv_of_bool in Bc. subst bc.
    rewrite (R_noA_eq_sub a (Hsat a La)) in H. cbv iota in H.
    apply x_skip in H as (_ & -> & _). reflexivity.
  Qed.

  Lemma ssc_row : forall fd v,
    resolves lp mario._set_submerged_cam_preset_and_spawn_bubbles fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._set_submerged_cam_preset_and_spawn_bubbles v)
      (post_of bm mario._set_submerged_cam_preset_and_spawn_bubbles).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_ssc Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    rewrite (ssc_mem v m t m' vr (marg_of_gms v m Hok Hgv) (proj1 Hw) Hev).
    split; [exact Hw |]. split; [exists c; split; [exact Hc | apply rt_refl] |].
    destruct ssc_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* mario_execute_submerged_action: no R_noA action is in its group.     *)
  (* ==================================================================== *)
  Lemma sub_row : forall fd v,
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._mario_execute_submerged_action v)
      (post_of bm mario._mario_execute_submerged_action).
  Proof.
    intros fd v m t m' vr c Hok Hw (Hgv & Hx) Hok' Hc Hb Hev.
    destruct sub_is as (Ik & Id).
    unfold xpre in Hx. rewrite Ik, Id in Hx. destruct Hx as (_ & a & La & Ga).
    exfalso. apply (R_noA_not_sub a (proj1 Hw a La)). rewrite Ga. exact disp_grp_sub.
  Qed.

  (* ==================================================================== *)
  (* update_mario_health: a change in m->health / hurtCounter /           *)
  (* healCounter (ProRows' hole, bytes 174..183) and in play_sound's two  *)
  (* queue globals keeps the frame world and the cells.                   *)
  (* ==================================================================== *)
  Lemma fld_store : forall v lv rhs le m0 m1 t le' m2 out bsr bsrc,
    fld_store_ok mario._m lv rhs = true -> le ! mario._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Qrel bm bsr bsrc m0 m1 -> Qrel bm bsr bsrc m0 m2.
  Proof.
    intros v lv rhs le m0 m1 t le' m2 out bsr bsrc Hok Hle Hmarg Hx (U & N & P).
    unfold fld_store_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Pos.eqb_eq in E1, E2. subst.
    destruct (fld_ok_spec _ _ E3) as (ch & d & Eam & Efo & Hh).
    apply hole_in_spec in Hh.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl Efo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->].
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode (typeof _) = _ |- _ =>
        cbn [typeof] in Hm; rewrite Eam in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as Hch; subst chunk end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst. rewrite Ptrofs.add_zero_l in Hst.
    rewrite Ptrofs.unsigned_repr in Hst
      by (change Ptrofs.max_unsigned with 4294967295; pose proof (size_chunk_pos ch) as Hsz; clear - Hh Hsz; lia).
    split; [| split].
    - eapply Mem.unchanged_on_trans; [exact U |].
      eapply Mem.store_unchanged_on; [exact Hst |].
      intros j Hj (_ & _ & Hn). apply Hn. split; [reflexivity |]. clear - Hj Hh. lia.
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact N.
    - intros b o k p. rewrite <- P. split.
      + intros Hp. exact (Mem.perm_store_2 _ _ _ _ _ _ Hst _ _ _ _ Hp).
      + intros Hp. exact (Mem.perm_store_1 _ _ _ _ _ _ Hst _ _ _ _ Hp).
  Qed.

  Lemma health_row : forall fd v,
    resolves lp mario._update_mario_health fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._update_mario_health v)
      (post_of bm mario._update_mario_health).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_health Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    pose proof Hw as (_ & _ & _ & _ & _ & Hf & _ & Haw & _).
    pose proof Hf as (Hgn & EX & _).
    ffw_unpack EX.
    assert (HQ : Qrel bm bsr bsrc m m').
    { refine (lw_body_frame ge (Qrel bm bsr bsrc m) mario.f_update_mario_health
                (fun le => le ! mario._m = Some v)
                (fun id _ => negb (Pos.eqb id mario._m)) (fld_store_ok mario._m) pffs_call_ok eq_refl hl_chk
                _ _ _ m [v] t m' vr Hev _ _).
      - intros id a le m1 v1 Hs Hp _ _. cbv beta in *.
        rewrite PTree.gso; [exact Hp |]. intros E. rewrite E, Pos.eqb_refl in Hs. discriminate Hs.
      - intros lv rhs le m1 t1 le1 m2 out Hs Hp Hx HQ1.
        exact (fld_store v lv rhs le m m1 t1 le1 m2 out bsr bsrc Hs Hp Hmarg Hx HQ1).
      - intros optid a al le m1 t1 le1 m2 out Hs Hp Hx HQ1.
        exact (pffs_call lp H12 bm v optid a al le m m1 t1 le1 m2 out bsr bsrc SR SRC Hs Hp Hx HQ1).
      - intros le1 Hb1. change (fn_params mario.f_update_mario_health) with [(mario._m, tyMSp)] in Hb1.
        cbn [bind_parameter_temps] in Hb1. injection Hb1 as <-. apply PTree.gss.
      - split; [apply Mem.unchanged_on_refl | split; [reflexivity | tauto]]. }
    destruct HQ as (U & N & P).
    assert (NB : Mem.nextblock m' = Mem.nextblock m) by exact N.
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p)
      by (intros b o k p Hp; exact (proj2 (P b o k p) Hp)).
    assert (LD : forall ch b z, b <> bsr -> b <> bsrc -> (b <> bm \/ hz z (size_chunk ch)) ->
               Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z N1 N2 Hz.
      destruct (plt b (Mem.nextblock m)) as [V | V].
      - eapply Mem.load_unchanged_on_1; [exact U | exact V |].
        intros i Hi. split; [exact N1 | split; [exact N2 |]].
        intros (-> & Hi'). destruct Hz as [Hz | Hz]; [exact (Hz eq_refl) |].
        unfold hz in Hz. clear - Hi Hi' Hz. lia.
      - rewrite (load_invalid m ch b z V). apply load_invalid.
        unfold Mem.valid_block. rewrite N. exact V. }
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    pose proof Haw as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & _).
    pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                     & _ & _ & _ & _ & _ & _ & _ & _ & Hbm0).
    assert (NBR : bm <> bsr) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SR eq_refl).
    assert (NBRC : bm <> bsrc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SRC eq_refl).
    assert (XR : xsym lp bsr) by (exists AX._sSoundRequests; split; [left; reflexivity | exact SR]).
    assert (XRC : xsym lp bsrc) by (exists AX._sSoundRequestCount; split; [right; left; reflexivity | exact SRC]).
    assert (NBle : Ple (Mem.nextblock m) (Mem.nextblock m')) by (rewrite NB; apply Ple_refl).
    split; [eapply hole2_fworld with (bsr := bsr) (bsrc := bsrc); eassumption |].
    split; [exists c; split; [eapply hole2_cells with (bsr := bsr) (bsrc := bsrc); eassumption | apply rt_refl] |].
    destruct health_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* mario_reset_bodystate, update_mario_info_for_cam: Q2 over the hole,  *)
  (* gBodyStates and gPlayerCameraState (BodyFrame).                      *)
  (* ==================================================================== *)
  Lemma fld_step : forall v lv rhs le m1 t le' m2 out x1 x2,
    fld_store_ok mario._m lv rhs = true -> le ! mario._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Q2 (PH bm x1 x2) m1 m2.
  Proof.
    intros v lv rhs le m1 t le' m2 out x1 x2 Hok Hle Hmarg Hx.
    unfold fld_store_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Pos.eqb_eq in E1, E2. subst.
    destruct (fld_ok_spec _ _ E3) as (ch & d & Eam & Efo & Hh).
    apply hole_in_spec in Hh.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl Efo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->].
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode (typeof _) = _ |- _ =>
        cbn [typeof] in Hm; rewrite Eam in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as Hch; subst chunk end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst. rewrite Ptrofs.add_zero_l in Hst.
    rewrite Ptrofs.unsigned_repr in Hst
      by (change Ptrofs.max_unsigned with 4294967295; pose proof (size_chunk_pos ch) as Hsz; clear - Hh Hsz; lia).
    apply (st_q2 _ _ _ _ _ _ _ Hst).
    intros j Hj (_ & _ & Hn). apply Hn. split; [reflexivity |]. clear - Hj Hh. lia.
  Qed.

  Lemma tp_step : forall x1 x2 lv rhs le m1 t le' m2 out,
    tp_store_ok lv = true -> tp_ok x1 x2 le ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Q2 (PH bm x1 x2) m1 m2.
  Proof.
    intros x1 x2 lv rhs le m1 t le' m2 out Hok Htp Hx.
    unfold tp_store_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    apply existsb_exists in Hok as (x' & Hin & Ex). apply Pos.eqb_eq in Ex. subst x'.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    apply eval_lvalue_Efield_inv in L1 as (o0 & sid & att & co & delta & Hb & _ & _ & Hcase).
    match type of Hb with eval_expr _ _ _ _ ?a0 _ =>
      assert (Am : access_mode (typeof a0) = By_copy)
        by (destruct Hcase as [(Ht & _) | (Ht & _)]; rewrite Ht; reflexivity) end.
    destruct (ex_agg lp _ _ _ _ _ Hb (or_intror Am) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => apply (al_q2 _ _ _ _ _ _ _ _ _ Ha) end.
    intros j (A & B & _).
    destruct (Htp _ _ Hin L0) as [E | [E | E]]; try discriminate E; injection E as -> _;
      first [exact (A eq_refl) | exact (B eq_refl)].
  Qed.

  Lemma tp_set : forall v bbs bpc m0 id a le m1 v1,
    tp_set_ok id a = true -> le ! mario._m = Some v /\ tp_ok bbs bpc le ->
    Q2 (PH bm bbs bpc) m0 m1 -> marg_ok bm [v] ->
    Mem.load Mint32 m0 bm 152 = Some (Vptr bbs Ptrofs.zero) ->
    Mem.load Mint32 m0 bm 148 = Some (Vptr bpc Ptrofs.zero) ->
    bm <> bbs -> bm <> bpc ->
    eval_expr ge empty_env le m1 a v1 ->
    (PTree.set id v1 le) ! mario._m = Some v /\ tp_ok bbs bpc (PTree.set id v1 le).
  Proof.
    intros v bbs bpc m0 id a le m1 v1 Hs (Hm & Htp) HQ Hmarg LB LP N1 N2 Ea.
    unfold tp_set_ok in Hs. apply andb_true_iff in Hs as (Hs1 & Hs2).
    apply negb_true_iff, Pos.eqb_neq in Hs1.
    split; [rewrite PTree.gso by congruence; exact Hm |].
    intros x p Hin Hx.
    destruct (peq x id) as [-> | Nx].
    2: { rewrite PTree.gso in Hx by exact Nx. exact (Htp x p Hin Hx). }
    rewrite PTree.gss in Hx. injection Hx as <-.
    assert (T : existsb (Pos.eqb id) TPS = true)
      by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
    rewrite T in Hs2. cbn [negb orb] in Hs2.
    unfold tp_src in Hs2.
    repeat match type of Hs2 with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
    end.
    repeat rewrite andb_true_iff in Hs2. destruct Hs2 as (((E1 & E2) & E3) & E4).
    apply Pos.eqb_eq in E1, E2, E3. subst.
    assert (HL : forall d, d + 4 <= 174 -> 8 <= d ->
               Mem.load Mint32 m1 bm d = Mem.load Mint32 m0 bm d).
    { intros d D2 D3. apply (Q2_load _ _ _ HQ). intros z Hi. cbn [size_chunk] in Hi.
      split; [exact N1 | split; [exact N2 |]]. intros (_ & H). lia. }
    apply orb_true_iff in E4 as [E4 | E4]; apply Pos.eqb_eq in E4; subst.
    - match type of Ea with eval_expr _ _ _ _ (Efield _ _ ?ty) _ =>
        destruct (ev_fld lp H12 bm mario._m le m1 v mario._marioBodyState ty Mint32 152 v1 Hm Hmarg
                    body_fo ltac:(lia) eq_refl Ea) as (_ & L1) end.
      rewrite (HL 152 ltac:(lia) ltac:(lia)), LB in L1. injection L1 as <-. left. reflexivity.
    - match type of Ea with eval_expr _ _ _ _ (Efield _ _ ?ty) _ =>
        destruct (ev_fld lp H12 bm mario._m le m1 v mario._statusForCamera ty Mint32 148 v1 Hm Hmarg
                    pcs_fo ltac:(lia) eq_refl Ea) as (_ & L1) end.
      rewrite (HL 148 ltac:(lia) ltac:(lia)), LP in L1. injection L1 as <-. right; left. reflexivity.
  Qed.

  Lemma v3_step : forall x1 x2 optid a al le m1 t le' m2 out,
    v3_call optid a al = true -> tp_ok x1 x2 le ->
    Plt x1 (Mem.nextblock m1) -> Plt x2 (Mem.nextblock m1) ->
    exec_stmt function_entry2 ge empty_env le m1 (Scall optid a al) t le' m2 out ->
    Q2 (PH bm x1 x2) m1 m2 /\ le' = le.
  Proof.
    intros x1 x2 optid a al le m1 t le' m2 out Hok Htp V1 V2 Hx.
    unfold v3_call in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    apply andb_true_iff in Hok as (Hf & Hin).
    apply existsb_exists in Hin as (x' & Hin & Ex). apply Pos.eqb_eq in Ex. subst x'.
    inv Hx.
    match goal with Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hc; injection Hc as <- <- <- end.
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (ev_fun _ _ _ _ _ _ _ _ He) as (b & Hs & ->) end.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _ |- _ => inv Hl end.
    match goal with Ea : eval_expr _ _ _ _ (Efield _ _ (Tarray _ _ _)) _ |- _ =>
      destruct (ev_arr ge _ _ _ _ _ _ _ _ _ Ea) as (loc & ofs & bf & L1 & ->) end.
    apply eval_lvalue_Efield_inv in L1 as (o0 & sid & att & co & delta & Hb & _ & _ & Hcase).
    match type of Hb with eval_expr _ _ _ _ ?a0 _ =>
      assert (Am : access_mode (typeof a0) = By_copy)
        by (destruct Hcase as [(Ht & _) | (Ht & _)]; rewrite Ht; reflexivity) end.
    destruct (ex_agg lp _ _ _ _ _ Hb (or_intror Am) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    assert (Hloc : loc = x1 \/ loc = x2).
    { destruct (Htp _ _ Hin L0) as [E | [E | E]]; try discriminate E; injection E as -> _;
        [left | right]; reflexivity. }
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn [typeof] in Hc; apply cast_ap in Hc; subst end.
    assert (Vl : Mem.valid_block m1 loc) by (destruct Hloc as [-> | ->]; assumption).
    match goal with Hff : Genv.find_funct _ _ = Some ?fd, Hev : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
      rename Hev into Hcall; rename Hff into Hff0 end.
    assert (HQ : Q2 (fun b _ => b <> loc) m1 m2).
    { apply orb_true_iff in Hf as [Hf | Hf]; apply Pos.eqb_eq in Hf; subst.
      - pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) dm_v3s (ex_intro _ b (conj Hs Hff0))) as Efd.
        rewrite Efd in Hcall.
        exact (v3_frame ge _ m1 loc ofs _ _ m2 _ (or_introl eq_refl) Hcall Vl).
      - pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) dm_v3f (ex_intro _ b (conj Hs Hff0))) as Efd.
        rewrite Efd in Hcall.
        exact (v3_frame ge _ m1 loc ofs _ _ m2 _ (or_intror eq_refl) Hcall Vl). }
    split; [| reflexivity].
    apply (Q2_mono (fun b _ => b <> loc)); [| exact HQ].
    intros b' z0 (A & B & _) E. subst b'.
    destruct Hloc as [-> | ->]; [exact (A eq_refl) | exact (B eq_refl)].
  Qed.

  (* the end of both rows: the hole lemmas over gBodyStates / gPlayerCameraState *)
  Lemma q2_end : forall f v m t m' vr c bbs bpc,
    fworld lp bm m -> marg_ok bm [v] -> read_cells bm m c ->
    Genv.find_symbol ge mario._gBodyStates = Some bbs ->
    Genv.find_symbol ge camera._gPlayerCameraState = Some bpc ->
    bm <> bbs -> bm <> bpc ->
    eval_funcall function_entry2 ge m (Internal f) [v] t m' vr ->
    Q2 (PH bm bbs bpc) m m' ->
    fworld lp bm m' /\ read_cells bm m' c.
  Proof.
    intros f v m t m' vr c bbs bpc Hw Hmarg Hc SBS SP NB1 NB2 Hev HQ.
    pose proof Hw as (_ & _ & _ & _ & _ & Hf & _ & _ & _).
    assert (LD : forall ch b z, b <> bbs -> b <> bpc -> (b <> bm \/ hz z (size_chunk ch)) ->
               Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z N1 N2 Hz. apply (Q2_load _ _ _ HQ). intros j Hi.
      split; [exact N1 | split; [exact N2 |]].
      intros (-> & Hi'). destruct Hz as [Hz | Hz]; [exact (Hz eq_refl) |].
      unfold hz in Hz. clear - Hi Hi' Hz. lia. }
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p) by exact (Q2_perm _ _ _ HQ).
    assert (NBle : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact (proj1 (proj2 HQ)).
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    assert (XB : xsym lp bbs)
      by (exists mario._gBodyStates; split; [right; right; left; reflexivity | exact SBS]).
    assert (XP : xsym lp bpc)
      by (exists camera._gPlayerCameraState; split; [right; right; right; left; reflexivity | exact SP]).
    split; [eapply hole2_fworld with (bsr := bbs) (bsrc := bpc); eassumption |].
    eapply hole2_cells with (bsr := bbs) (bsrc := bpc); eassumption.
  Qed.

  Ltac ffw_open Hw :=
    let Hf := fresh "Hf" in let Haw := fresh "Haw" in
    pose proof Hw as (_ & _ & _ & _ & _ & Hf & _ & Haw & _);
    pose proof Hf as (Hgn & EX & _);
    ffw_unpack EX;
    pose proof Haw as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & _);
    pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                     & _ & _ & _ & _ & _ & _ & _ & _ & Hbm0).

  Lemma reset_row : forall fd v,
    resolves lp mario._mario_reset_bodystate fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._mario_reset_bodystate v)
      (post_of bm mario._mario_reset_bodystate).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_reset Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    ffw_open Hw.
    assert (NB1 : bm <> bbs) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SBS eq_refl).
    assert (NB2 : bm <> bpc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SP eq_refl).
    assert (HQ : Q2 (PH bm bbs bpc) m m').
    { refine (lw_body_frame ge (Q2 (PH bm bbs bpc) m) mario.f_mario_reset_bodystate
                (fun le => le ! mario._m = Some v /\ tp_ok bbs bpc le)
                tp_set_ok bs_store_ok no_call eq_refl reset_chk
                _ _ _ m [v] t m' vr Hev _ (Q2_refl _ m)).
      - intros id a le m1 v1 Hs Hp HQ1 Ea.
        exact (tp_set v bbs bpc m id a le m1 v1 Hs Hp HQ1 Hmarg LBS LPC NB1 NB2 Ea).
      - intros lv rhs le m1 t1 le1 m2 out Hs (Hp & Ht) Hx HQ1.
        apply (Q2_trans _ _ _ _ HQ1).
        apply orb_true_iff in Hs as [Hs | Hs].
        + exact (fld_step v lv rhs le m1 t1 le1 m2 out bbs bpc Hs Hp Hmarg Hx).
        + exact (tp_step bbs bpc lv rhs le m1 t1 le1 m2 out Hs Ht Hx).
      - intros optid a al le m1 t1 le1 m2 out Hs. exact (False_ind _ (diff_false_true Hs)).
      - intros le1 Hb1. exact (tp_init v mario.f_mario_reset_bodystate bbs bpc le1 eq_refl Hb1). }
    destruct (q2_end _ v m t m' vr c bbs bpc Hw Hmarg Hc SBS SP NB1 NB2 Hev HQ) as (Hw' & Hc').
    split; [exact Hw' |]. split; [exists c; split; [exact Hc' | apply rt_refl] |].
    destruct reset_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  Lemma cam_row : forall fd v,
    resolves lp mario._update_mario_info_for_cam fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._update_mario_info_for_cam v)
      (post_of bm mario._update_mario_info_for_cam).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_cam Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    ffw_open Hw.
    assert (NB1 : bm <> bbs) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SBS eq_refl).
    assert (NB2 : bm <> bpc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SP eq_refl).
    assert (Vbs : Plt bbs (Mem.nextblock m))
      by exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ SBS) Hgn).
    assert (Vpc : Plt bpc (Mem.nextblock m))
      by exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ SP) Hgn).
    assert (HQ : Q2 (PH bm bbs bpc) m m').
    { refine (lw_body_frame ge (Q2 (PH bm bbs bpc) m) mario.f_update_mario_info_for_cam
                (fun le => le ! mario._m = Some v /\ tp_ok bbs bpc le)
                tp_set_ok bs_store_ok v3_call eq_refl cam_chk
                _ _ _ m [v] t m' vr Hev _ (Q2_refl _ m)).
      - intros id a le m1 v1 Hs Hp HQ1 Ea.
        exact (tp_set v bbs bpc m id a le m1 v1 Hs Hp HQ1 Hmarg LBS LPC NB1 NB2 Ea).
      - intros lv rhs le m1 t1 le1 m2 out Hs (Hp & Ht) Hx HQ1.
        apply (Q2_trans _ _ _ _ HQ1).
        apply orb_true_iff in Hs as [Hs | Hs].
        + exact (fld_step v lv rhs le m1 t1 le1 m2 out bbs bpc Hs Hp Hmarg Hx).
        + exact (tp_step bbs bpc lv rhs le m1 t1 le1 m2 out Hs Ht Hx).
      - intros optid a al le m1 t1 le1 m2 out Hs (Hp & Ht) Hx HQ1.
        assert (Nle : Ple (Mem.nextblock m) (Mem.nextblock m1)) by exact (proj1 (proj2 HQ1)).
        destruct (v3_step bbs bpc optid a al le m1 t1 le1 m2 out Hs Ht
                    (Plt_Ple_trans _ _ _ Vbs Nle) (Plt_Ple_trans _ _ _ Vpc Nle) Hx) as (HQ2 & ->).
        split; [exact (Q2_trans _ _ _ _ HQ1 HQ2) | exact (conj Hp Ht)].
      - intros le1 Hb1. exact (tp_init v mario.f_update_mario_info_for_cam bbs bpc le1 eq_refl Hb1). }
    destruct (q2_end _ v m t m' vr c bbs bpc Hw Hmarg Hc SBS SP NB1 NB2 Hev HQ) as (Hw' & Hc').
    split; [exact Hw' |]. split; [exists c; split; [exact Hc' | apply rt_refl] |].
    destruct cam_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* squish_mario_model: Q2 over the hole and Mario's object's gfx.scale. *)
  (* ==================================================================== *)
  Lemma sc_addr : forall le m1 a v bo oo,
    sc_lv a = true -> ot_ok bo oo le -> Ptrofs.unsigned oo + 56 <= Ptrofs.modulus ->
    eval_expr ge empty_env le m1 a v ->
    exists o', v = Vptr bo o' /\ Ptrofs.unsigned o' = Ptrofs.unsigned oo + 44.
  Proof.
    intros le m1 a v bo oo Hs Ht Hb Ea.
    unfold sc_lv in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    repeat match goal with H : _ && _ = true |- _ => apply andb_true_iff in H as (? & ?) end.
    repeat match goal with H : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in H; subst end.
    match goal with H : existsb _ OT = true |- _ =>
      apply existsb_exists in H as (x' & Hin & Ex); apply Pos.eqb_eq in Ex; subst x' end.
    destruct (ev_arr ge _ _ _ _ _ _ _ _ _ Ea) as (loc & ofs & bf & L3 & ->).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L3 eq_refl scale_fo)
      as (o0 & E0 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L2).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L2 eq_refl gfx_fo)
      as (o1 & E1 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E1 (or_intror eq_refl) I) as (bf1 & L1).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl hdr_fo)
      as (o2 & E2 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E2 (or_intror eq_refl) I) as (bf2 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    destruct (Ht _ _ Hin L0) as [E | E]; [injection E as -> -> | discriminate E].
    eexists; split; [reflexivity |]. cbn [fst].
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero.
    pose proof (Ptrofs.unsigned_range oo) as Ro.
    rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr 44) by (change Ptrofs.max_unsigned with 4294967295; lia).
    apply Ptrofs.unsigned_repr. unfold Ptrofs.max_unsigned. lia.
  Qed.

  Definition PHo (bo : block) (oo : ptrofs) (b : block) (z : Z) : Prop :=
    ~ (b = bo /\ Ptrofs.unsigned oo + 44 <= z < Ptrofs.unsigned oo + 56).

  Lemma sc_step : forall bo oo lv rhs le m1 t le' m2 out,
    sc_store_ok lv = true -> ot_ok bo oo le -> Ptrofs.unsigned oo + 56 <= Ptrofs.modulus ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Q2 (PHo bo oo) m1 m2.
  Proof.
    intros bo oo lv rhs le m1 t le' m2 out Hs Ht Hb Hx.
    unfold sc_store_ok in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    apply andb_true_iff in Hs as (Hs & Hi). apply Z.ltb_lt in Hi.
    inv Hx.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    match goal with L : eval_lvalue _ _ _ _ (Ederef _ _) _ _ ?bf |- _ =>
      assert (Ebf : bf = Full) by (inv L; reflexivity); subst bf;
      apply eval_lvalue_Ederef_base in L; apply eval_expr_Ebinop_inv in L as (w1 & w2 & E1 & E2 & Sb) end.
    apply eval_expr_Econst_int_val in E2. subst w2.
    destruct (sc_addr _ _ _ _ _ _ Hs Ht Hb E1) as (o' & -> & Eo').
    cbn [typeof] in Sb.
    match type of Sb with sem_binary_operation _ _ _ ?t1 _ _ _ = _ =>
      let T := fresh "T" in
      assert (T : exists a k a1, t1 = Tarray (Tfloat Ctypes.F32 a) k a1)
        by (unfold sc_lv in Hs;
            repeat match type of Hs with
            | match ?x with _ => _ end = true => destruct x; try discriminate Hs
            end; cbn [typeof]; eauto);
      destruct T as (aa0 & kk0 & aa1 & ET); rewrite ET in Sb end.
    destruct (add_af _ _ _ _ _ _ _ _ _ _ _ _ _ Sb Hi ltac:(lia)) as (-> & Eo).
    inv Hal;
      match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
    apply (st_q2 _ _ _ _ _ _ _ Hst).
    intros z Hz Hn. apply Hn. rewrite Eo, Eo' in Hz. cbn [size_chunk] in Hz.
    pose proof (Int.unsigned_range i). split; [reflexivity | lia].
  Qed.

  Lemma sc_callstep : forall bo oo optid a al le m1 t le' m2 out,
    sc_call optid a al = true -> ot_ok bo oo le -> Ptrofs.unsigned oo + 56 <= Ptrofs.modulus ->
    Plt bo (Mem.nextblock m1) ->
    exec_stmt function_entry2 ge empty_env le m1 (Scall optid a al) t le' m2 out ->
    Q2 (PHo bo oo) m1 m2 /\ le' = le.
  Proof.
    intros bo oo optid a al le m1 t le' m2 out Hok Ht Hb Vb Hx.
    unfold sc_call in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    apply andb_true_iff in Hok as (Hf & Hs). apply Pos.eqb_eq in Hf. subst.
    inv Hx.
    match goal with Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hc; injection Hc as <- <- <- end.
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (ev_fun _ _ _ _ _ _ _ _ He) as (b & Hsy & ->) end.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _ |- _ => inv Hl end.
    match goal with Hc : sem_cast _ (typeof ?a1) _ _ = Some _ |- _ => rename Hc into Hca end.
    match goal with Ea : eval_expr _ _ _ _ ?a1 _, Hc : sem_cast _ (typeof ?a1) _ _ = Some _ |- _ =>
      rename Ea into Ea1 end.
    destruct (sc_addr _ _ _ _ _ _ Hs Ht Hb Ea1) as (o' & -> & Eo').
    match type of Hca with sem_cast _ (typeof ?a1) _ _ = _ =>
      assert (T : exists tt0 nn0 at0, typeof a1 = Tarray tt0 nn0 at0)
        by (unfold sc_lv in Hs;
            repeat match type of Hs with
            | match ?x with _ => _ end = true => destruct x; try discriminate Hs
            end; cbn; eauto) end.
    destruct T as (tt0 & nn0 & at0 & ET). rewrite ET in Hca. apply cast_ap in Hca. subst.
    match goal with Hff : Genv.find_funct _ _ = Some ?fd, Hev : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
      rename Hev into Hcall; rename Hff into Hff0 end.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) dm_v3set (ex_intro _ b (conj Hsy Hff0))) as Efd.
    rewrite Efd in Hcall.
    split; [| reflexivity].
    refine (Q2_mono _ _ _ _ _ (v3set_frame ge _ _ _ _ _ _ _ Hcall Vb ltac:(lia))).
    intros b' z H (E & R). apply H. split; [exact E | lia].
  Qed.

  Lemma sq_set : forall (Kx : block -> Z -> Prop) v bo oo m0 id a le m1 v1,
    sq_set_ok id a = true -> le ! mario._m = Some v /\ ot_ok bo oo le ->
    Q2 Kx m0 m1 -> (forall z, 136 <= z < 140 -> Kx bm z) -> marg_ok bm [v] ->
    Mem.load Mint32 m0 bm 136 = Some (Vptr bo oo) ->
    eval_expr ge empty_env le m1 a v1 ->
    (PTree.set id v1 le) ! mario._m = Some v /\ ot_ok bo oo (PTree.set id v1 le).
  Proof.
    intros Kx v bo oo m0 id a le m1 v1 Hs (Hm & Htp) HQ Hk Hmarg LO Ea.
    unfold sq_set_ok in Hs. apply andb_true_iff in Hs as (Hs1 & Hs2).
    apply negb_true_iff, Pos.eqb_neq in Hs1.
    split; [rewrite PTree.gso by congruence; exact Hm |].
    intros x p Hin Hx.
    destruct (peq x id) as [-> | Nx].
    2: { rewrite PTree.gso in Hx by exact Nx. exact (Htp x p Hin Hx). }
    rewrite PTree.gss in Hx. injection Hx as <-.
    assert (T : existsb (Pos.eqb id) OT = true)
      by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
    rewrite T in Hs2. cbn [negb orb] in Hs2.
    unfold mo_src in Hs2.
    repeat match type of Hs2 with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
    end.
    repeat rewrite andb_true_iff in Hs2. destruct Hs2 as (((E1 & E2) & E3) & E4).
    apply Pos.eqb_eq in E1, E2, E3, E4. subst.
    match type of Ea with eval_expr _ _ _ _ (Efield _ _ ?ty) _ =>
      destruct (ev_fld lp H12 bm mario._m le m1 v mario._marioObj ty Mint32 136 v1 Hm Hmarg
                  mobj_fo ltac:(lia) eq_refl Ea) as (_ & L1) end.
    rewrite (Q2_load _ _ _ HQ) in L1.
    - rewrite LO in L1. injection L1 as <-. left. reflexivity.
    - intros z Hi. cbn [size_chunk] in Hi. apply Hk. lia.
  Qed.

  Lemma squish_row : forall fd v,
    resolves lp mario._squish_mario_model fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._squish_mario_model v)
      (post_of bm mario._squish_mario_model).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_squish Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    ffw_open Hw.
    assert (NB1 : bm <> bbs) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SBS eq_refl).
    assert (NB2 : bm <> bpc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SP eq_refl).
    assert (NBO : bm <> bo) by exact (not_eq_sym D1).
    assert (LO : Mem.load Mint32 m bm 136 = Some (Vptr bo oo)) by exact Lo.
    assert (Hb56 : Ptrofs.unsigned oo + 56 <= Ptrofs.modulus) by (unfold SZ_OBJECT in Soo; lia).
    assert (Vbo : Plt bo (Mem.nextblock m)).
    { destruct Hc as (_ & _ & _ & _ & _ & _ & bo' & oo' & H7 & H8).
      assert (H7' : Mem.load Mint32 m bm 136 = Some (Vptr bo' oo')) by exact H7.
      rewrite LO in H7'. injection H7' as <- <-.
      exact (Mem.valid_access_valid_block _ _ _ _
               (Mem.valid_access_implies _ _ _ _ _ _ (Mem.load_valid_access _ _ _ _ _ H8) (perm_any_N _))). }
    set (K := fun b z => PH bm bbs bpc b z /\ PHo bo oo b z).
    assert (HQ : Q2 K m m').
    { refine (lw_body_frame ge (Q2 K m) mario.f_squish_mario_model
                (fun le => le ! mario._m = Some v /\ ot_ok bo oo le)
                sq_set_ok sq_store_ok sc_call eq_refl sq_chk
                _ _ _ m [v] t m' vr Hev _ (Q2_refl _ m)).
      - intros id a le m1 v1 Hs Hp HQ1 Ea.
        refine (sq_set K v bo oo m id a le m1 v1 Hs Hp HQ1 _ Hmarg LO Ea).
        intros z Hz. split.
        + split; [exact NB1 | split; [exact NB2 |]]. intros (_ & H). lia.
        + intros (E & _). exact (NBO E).
      - intros lv rhs le m1 t1 le1 m2 out Hs (Hp & Ht) Hx HQ1.
        apply (Q2_trans _ _ _ _ HQ1).
        apply orb_true_iff in Hs as [Hs | Hs].
        + apply (Q2_mono (PH bm bbs bpc)); [intros b z (KA & _); exact KA |].
          exact (fld_step v lv rhs le m1 t1 le1 m2 out bbs bpc Hs Hp Hmarg Hx).
        + apply (Q2_mono (PHo bo oo)); [intros b z (_ & KB); exact KB |].
          exact (sc_step bo oo lv rhs le m1 t1 le1 m2 out Hs Ht Hb56 Hx).
      - intros optid a al le m1 t1 le1 m2 out Hs (Hp & Ht) Hx HQ1.
        assert (Nle : Ple (Mem.nextblock m) (Mem.nextblock m1)) by exact (proj1 (proj2 HQ1)).
        destruct (sc_callstep bo oo optid a al le m1 t1 le1 m2 out Hs Ht Hb56
                    (Plt_Ple_trans _ _ _ Vbo Nle) Hx) as (HQ2 & ->).
        split; [| exact (conj Hp Ht)].
        apply (Q2_trans _ _ _ _ HQ1).
        apply (Q2_mono (PHo bo oo)); [intros b z (_ & KB); exact KB | exact HQ2].
      - intros le1 Hb1. exact (ot_init v mario.f_squish_mario_model bo oo le1 eq_refl Hb1). }
    assert (LD : forall ch b z, b <> bbs -> b <> bpc -> (b <> bm \/ hz z (size_chunk ch)) ->
               (b <> bo \/ z + size_chunk ch <= Ptrofs.unsigned oo + 44 \/ Ptrofs.unsigned oo + 44 + 12 <= z) ->
               Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z N1 N2 Hz Ho. apply (Q2_load _ _ _ HQ). intros j Hi.
      split; [split; [exact N1 | split; [exact N2 |]] |].
      - intros (-> & Hi'). destruct Hz as [Hz | Hz]; [exact (Hz eq_refl) |].
        unfold hz in Hz. clear - Hi Hi' Hz. lia.
      - intros (-> & Hj). destruct Ho as [Ho | Ho]; [exact (Ho eq_refl) | clear - Hi Hj Ho; lia]. }
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p) by exact (Q2_perm _ _ _ HQ).
    assert (NBle : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact (proj1 (proj2 HQ)).
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    assert (XB : xsym lp bbs)
      by (exists mario._gBodyStates; split; [right; right; left; reflexivity | exact SBS]).
    assert (XP : xsym lp bpc)
      by (exists camera._gPlayerCameraState; split; [right; right; right; left; reflexivity | exact SP]).
    assert (OBJ : bo = bbs \/ exists oo', Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo')
                                          /\ Ptrofs.unsigned oo + 44 = Ptrofs.unsigned oo' + 44)
      by (right; exists oo; split; [exact LO | reflexivity]).
    assert (OWL : 36 <= 44 /\ 0 <= 12 /\ 44 + 12 <= 56) by lia.
    assert (HG40 : 40 <= 44) by lia.
    split; [eapply hole_fworld with (m := m) (m' := m') (bsr := bbs) (bsrc := bpc) (ob := bo)
                                    (oz := Ptrofs.unsigned oo + 44) (ow := 44) (wl := 12); eassumption |].
    split; [exists c; split; [eapply hole_cells with (m := m) (m' := m') (bsr := bbs) (bsrc := bpc) (ob := bo)
                                    (oz := Ptrofs.unsigned oo + 44) (ow := 44) (wl := 12);
                              first [exact (or_introl HG40) | eassumption] | apply rt_refl] |].
    destruct squish_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.


  (* ==================================================================== *)
  (* sink_mario_in_quicksand: Q2 over sFloorAlignMatrix and Phi's gfx     *)
  (* cell, which the body rewrites with its own value.                    *)
  (* ==================================================================== *)
  Ltac nid := let E := fresh "E" in intro E; cbv in E; discriminate E.

  Lemma add_u : forall oo d, 0 <= d -> Ptrofs.unsigned oo + d <= Ptrofs.max_unsigned ->
    Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr d)) = Ptrofs.unsigned oo + d.
  Proof.
    intros oo d H0 H1. pose proof (Ptrofs.unsigned_range oo) as Ro.
    unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr d) by lia. apply Ptrofs.unsigned_repr. lia.
  Qed.

  Lemma ev_pfld : forall le m a f t a1 v,
    eval_expr ge empty_env le m (Efield a f (Tpointer t a1)) v ->
    exists loc ofs, eval_lvalue ge empty_env le m (Efield a f (Tpointer t a1)) loc ofs Full
      /\ Mem.load Mint32 m loc (Ptrofs.unsigned ofs) = Some v.
  Proof.
    intros le m a f t a1 v H. inv H.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      try match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end;
      try match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
    do 2 eexists. split; [eassumption | assumption].
  Qed.

  Lemma ev_fderef : forall le m a a1 v,
    eval_expr ge empty_env le m (Ederef a (Tfloat Ctypes.F32 a1)) v ->
    exists loc ofs, eval_expr ge empty_env le m a (Vptr loc ofs)
      /\ Mem.load Mfloat32 m loc (Ptrofs.unsigned ofs) = Some v.
  Proof.
    intros le m a a1 v H. inv H.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      try match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end;
      try match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
      apply eval_lvalue_Ederef_base in Hl end.
    do 2 eexists. split; [eassumption | assumption].
  Qed.

  Lemma ev_aderef : forall le m a t n a1 v,
    eval_expr ge empty_env le m (Ederef a (Tarray t n a1)) v ->
    exists loc ofs, eval_expr ge empty_env le m a (Vptr loc ofs) /\ v = Vptr loc ofs.
  Proof.
    intros le m a t n a1 v H. inv H.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      try match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end;
      try match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
      apply eval_lvalue_Ederef_base in Hl end.
    do 2 eexists. split; [eassumption | reflexivity].
  Qed.

  (* o->header.gfx.<f>, o = Mario's object *)
  Lemma og_addr : forall le m g f ty loc ofs bf dz dbf bo oo,
    og_fld g = true -> (forall p, le ! mario._o = Some p -> p = Vptr bo oo \/ p = Vundef) ->
    mario_fo mario._GraphNodeObject f = Some (dz, dbf) ->
    eval_lvalue ge empty_env le m (Efield g f ty) loc ofs bf ->
    loc = bo /\ ofs = Ptrofs.add oo (Ptrofs.repr dz) /\ bf = dbf.
  Proof.
    intros le m g f ty loc ofs bf dz dbf bo oo Hg Ho Hd L3.
    unfold og_fld in Hg.
    repeat match type of Hg with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hg
    end.
    repeat match goal with H : _ && _ = true |- _ => apply andb_true_iff in H as (? & ?) end.
    repeat match goal with H : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in H; subst end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L3 eq_refl Hd)
      as (o0 & E0 & -> & ->).
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L2).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L2 eq_refl gfx_fo)
      as (o1 & E1 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E1 (or_intror eq_refl) I) as (bf1 & L1).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl hdr_fo)
      as (o2 & E2 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E2 (or_intror eq_refl) I) as (bf2 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    destruct (Ho _ L0) as [E | E]; [injection E as -> -> | discriminate E].
    split; [reflexivity |]. split; [| reflexivity]. cbn [fst].
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero. reflexivity.
  Qed.

  (* o->header.gfx.throwMatrix's value is Mario's object's cell 80 *)
  Lemma tm_val : forall le m a v bo oo,
    tm_src a = true -> (forall p, le ! mario._o = Some p -> p = Vptr bo oo \/ p = Vundef) ->
    Ptrofs.unsigned oo + 84 <= Ptrofs.modulus ->
    eval_expr ge empty_env le m a v -> Mem.load Mint32 m bo (Ptrofs.unsigned oo + 80) = Some v.
  Proof.
    intros le m a v bo oo Hs Ho Hb Ea.
    unfold tm_src in Hs. destruct a; try discriminate Hs. destruct t; try discriminate Hs.
    apply andb_true_iff in Hs as (Hf & Hg). apply Pos.eqb_eq in Hf. subst.
    destruct (ev_pfld _ _ _ _ _ _ _ Ea) as (loc & ofs & L & Hl).
    destruct (og_addr _ _ _ _ _ _ _ _ _ _ _ _ Hg Ho throw_fo L) as (-> & -> & _).
    rewrite add_u in Hl by (try lia; change Ptrofs.max_unsigned with 4294967295; change Ptrofs.modulus with 4294967296 in Hb; lia).
    exact Hl.
  Qed.

  Lemma gy_shape : forall lv, gy_lv lv = true -> exists X a, lv = Ederef X (Tfloat Ctypes.F32 a) /\ gy_x X = true.
  Proof.
    intros lv H. unfold gy_lv in H.
    repeat match type of H with
    | match ?x with _ => _ end = true => destruct x; try discriminate H
    end.
    eauto.
  Qed.

  (* &o->header.gfx.pos[1] is Mario's object's cell 36 (OFS_GFXY) *)
  Lemma gy_addr : forall le m X loc ofs bo oo,
    gy_x X = true -> (forall p, le ! mario._o = Some p -> p = Vptr bo oo \/ p = Vundef) ->
    Ptrofs.unsigned oo + 44 <= Ptrofs.modulus ->
    eval_expr ge empty_env le m X (Vptr loc ofs) ->
    loc = bo /\ Ptrofs.unsigned ofs = Ptrofs.unsigned oo + 36.
  Proof.
    intros le m X loc ofs bo oo Hs Ho Hb HX.
    unfold gy_x in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    repeat match goal with H : _ && _ = true |- _ => apply andb_true_iff in H as (? & ?) end.
    match goal with H : Pos.eqb _ mario._pos = true |- _ => apply Pos.eqb_eq in H; subst end.
    match goal with H : Int.eq _ _ = true |- _ => apply Int.same_if_eq in H; subst end.
    apply eval_expr_Ebinop_inv in HX as (w1 & w2 & E1 & E2 & Sb).
    apply eval_expr_Econst_int_val in E2. subst w2.
    destruct (ev_arr ge _ _ _ _ _ _ _ _ _ E1) as (l1 & o1 & bf1 & L3 & ->).
    match goal with Hg : og_fld _ = true |- _ =>
      destruct (og_addr _ _ _ _ _ _ _ _ _ _ _ _ Hg Ho pos_fo L3) as (-> & -> & _) end.
    cbn [typeof] in Sb.
    assert (U : Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 32)) = Ptrofs.unsigned oo + 32)
      by (apply add_u; [lia | change Ptrofs.max_unsigned with 4294967295;
                              change Ptrofs.modulus with 4294967296 in Hb; lia]).
    destruct (add_af _ _ _ _ _ _ _ _ _ _ _ _ _ Sb ltac:(vm_compute; reflexivity) ltac:(rewrite U; lia)) as (-> & Eo).
    split; [reflexivity |]. rewrite Eo, U, Int.unsigned_one. lia.
  Qed.

  (* ( *t )[i][j], t one of QT: an address in sFloorAlignMatrix *)
  Lemma tm_shape : forall lv, tm_store lv = true -> exists X a, lv = Ederef X (Tfloat Ctypes.F32 a).
  Proof.
    intros lv H. unfold tm_store in H.
    repeat match type of H with
    | match ?x with _ => _ end = true => destruct x; try discriminate H
    end.
    eauto.
  Qed.

  Lemma tm_blk : forall le m lv loc ofs bf bfa,
    tm_store lv = true -> qt_ok bfa le -> eval_lvalue ge empty_env le m lv loc ofs bf -> loc = bfa.
  Proof.
    intros le m lv loc ofs bf bfa Hs Hq L.
    unfold tm_store in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    apply eval_lvalue_Ederef_base, eval_expr_Ebinop_inv in L as (w1 & w2 & E1 & E2 & Sb).
    apply eval_expr_Econst_int_val in E2. subst w2.
    destruct (ev_aderef _ _ _ _ _ _ _ E1) as (l1 & o1 & E1' & ->).
    cbn [typeof] in Sb. destruct (add_blk _ _ _ _ _ _ _ _ _ _ _ _ Sb) as (o' & E).
    injection E; intros; subst.
    apply eval_expr_Ebinop_inv in E1' as (u1 & u2 & F1 & F2 & Sb2).
    apply eval_expr_Econst_int_val in F2. subst u2.
    destruct (ev_aderef _ _ _ _ _ _ _ F1) as (l2 & o2 & F1' & ->).
    cbn [typeof] in Sb2. destruct (add_blk _ _ _ _ _ _ _ _ _ _ _ _ Sb2) as (o'' & E').
    injection E'; intros; subst.
    apply eval_expr_Etempvar_val in F1'.
    apply existsb_exists in Hs as (x' & Hin & Ex). apply Pos.eqb_eq in Ex. subst x'.
    destruct (Hq _ _ Hin F1') as [E2 | [(o3 & E2) | E2]]; try discriminate E2.
    injection E2; intros; subst. reflexivity.
  Qed.

  Lemma qs_set : forall (K : block -> Z -> Prop) v bo oo bfa gy m0 id a le m1 v1,
    qs_set_ok id a = true -> qs_P v bo oo bfa gy le ->
    Q2 K m0 m1 -> Mem.load Mfloat32 m1 bo (Ptrofs.unsigned oo + 36) = Some (Vsingle gy) ->
    (forall z, (136 <= z < 140 \/ 192 <= z < 196) -> K bm z) ->
    (forall z, Ptrofs.unsigned oo + 80 <= z < Ptrofs.unsigned oo + 84 -> K bo z) ->
    marg_ok bm [v] ->
    Mem.load Mint32 m0 bm 136 = Some (Vptr bo oo) ->
    Mem.load Mfloat32 m0 bm 192 = Some (Vsingle Float32.zero) ->
    (Mem.load Mint32 m0 bo (Ptrofs.unsigned oo + 80) = Some (Vint Int.zero)
      \/ exists o, Mem.load Mint32 m0 bo (Ptrofs.unsigned oo + 80) = Some (Vptr bfa o)) ->
    Ptrofs.unsigned oo + 84 <= Ptrofs.modulus ->
    eval_expr ge empty_env le m1 a v1 ->
    qs_P v bo oo bfa gy (PTree.set id v1 le).
  Proof.
    intros K v bo oo bfa gy m0 id a le m1 v1 Hs (Hm & Ho & Hq & H1 & H2) HQ Hgy Kbm Kbo Hmarg LO LQ LT Hb Ea.
    unfold qs_set_ok in Hs. apply andb_true_iff in Hs as (Hs1 & Hs2).
    apply negb_true_iff, Pos.eqb_neq in Hs1.
    split; [rewrite PTree.gso by congruence; exact Hm |].
    split; [| split; [| split]].
    - intros p Hp. destruct (peq id mario._o) as [-> | N].
      2: { rewrite PTree.gso in Hp by congruence. exact (Ho p Hp). }
      rewrite PTree.gss in Hp. injection Hp as <-. change (mo_src a = true) in Hs2.
      unfold mo_src in Hs2.
      repeat match type of Hs2 with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
      end.
      repeat rewrite andb_true_iff in Hs2. destruct Hs2 as (((E1 & E2) & E3) & E4).
      apply Pos.eqb_eq in E1, E2, E3, E4. subst.
      match type of Ea with eval_expr _ _ _ _ (Efield _ _ ?ty) _ =>
        destruct (ev_fld lp H12 bm mario._m le m1 v mario._marioObj ty Mint32 136 v1 Hm Hmarg
                    mobj_fo ltac:(lia) eq_refl Ea) as (_ & L1) end.
      rewrite (Q2_load _ _ _ HQ) in L1 by (intros z Hz; apply Kbm; cbn [size_chunk] in Hz; lia).
      rewrite LO in L1. injection L1 as <-. left. reflexivity.
    - intros x p Hin Hx. destruct (peq id x) as [<- | N].
      2: { rewrite PTree.gso in Hx by congruence. exact (Hq x p Hin Hx). }
      rewrite PTree.gss in Hx. injection Hx as <-.
      assert (T : existsb (Pos.eqb id) QT = true)
        by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
      assert (No : Pos.eqb id mario._o = false)
        by (destruct Hin as [<- | [<- | [<- | []]]]; reflexivity).
      rewrite No, T in Hs2. change (tm_src a = true) in Hs2.
      pose proof (tm_val _ _ _ _ _ _ Hs2 Ho Hb Ea) as L1.
      rewrite (Q2_load _ _ _ HQ) in L1 by (intros z Hz; apply Kbo; cbn [size_chunk] in Hz; lia).
      destruct LT as [L | (o & L)]; rewrite L in L1; injection L1 as <-; [left; reflexivity | right; left; eauto].
    - intros p Hp. destruct (peq id mario._t'1) as [-> | N].
      2: { rewrite PTree.gso in Hp by congruence. exact (H1 p Hp). }
      rewrite PTree.gss in Hp. injection Hp as <-.
      change (gy_lv a = true) in Hs2.
      destruct (gy_shape _ Hs2) as (X & a1 & -> & Hx).
      destruct (ev_fderef _ _ _ _ _ Ea) as (loc & ofs & EX & L1).
      destruct (gy_addr _ _ _ _ _ _ _ Hx Ho ltac:(lia) EX) as (-> & Eo).
      rewrite Eo, Hgy in L1. injection L1 as <-. left. reflexivity.
    - intros p Hp. destruct (peq id mario._t'2) as [-> | N].
      2: { rewrite PTree.gso in Hp by congruence. exact (H2 p Hp). }
      rewrite PTree.gss in Hp. injection Hp as <-.
      change (qd_src a = true) in Hs2.
      unfold qd_src in Hs2.
      repeat match type of Hs2 with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
      end.
      repeat rewrite andb_true_iff in Hs2. destruct Hs2 as (((E1 & E2) & E3) & E4).
      apply Pos.eqb_eq in E1, E2, E3, E4. subst.
      match type of Ea with eval_expr _ _ _ _ (Efield _ _ ?ty) _ =>
        destruct (ev_fld lp H12 bm mario._m le m1 v mario._quicksandDepth ty Mfloat32 192 v1 Hm Hmarg
                    qsd_fo ltac:(lia) eq_refl Ea) as (_ & L1) end.
      rewrite (Q2_load _ _ _ HQ) in L1 by (intros z Hz; apply Kbm; cbn [size_chunk] in Hz; lia).
      rewrite LQ in L1. injection L1 as <-. left. reflexivity.
  Qed.

  Lemma qs_store : forall (K : block -> Z -> Prop) v bo oo bfa gy m0 lv rhs le m1 t le' m2 out,
    qs_store_ok lv rhs = true -> qs_P v bo oo bfa gy le ->
    (forall b z, K b z -> b <> bfa /\ ~ (b = bo /\ Ptrofs.unsigned oo + 36 <= z < Ptrofs.unsigned oo + 40)) ->
    bo <> bfa -> F32 gy = true -> Ptrofs.unsigned oo + 44 <= Ptrofs.modulus ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Q2 K m0 m1 -> Mem.load Mfloat32 m1 bo (Ptrofs.unsigned oo + 36) = Some (Vsingle gy) ->
    Q2 K m0 m2 /\ Mem.load Mfloat32 m2 bo (Ptrofs.unsigned oo + 36) = Some (Vsingle gy).
  Proof.
    intros K v bo oo bfa gy m0 lv rhs le m1 t le' m2 out Hs (Hm & Ho & Hq & H1 & H2) HK Nbo Fg Hb Hx HQ Hgy.
    apply orb_true_iff in Hs as [Hs | Hs].
    - destruct (tm_shape _ Hs) as (X & a & ->).
      inv Hx.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
      match goal with L : eval_lvalue _ _ _ _ (Ederef _ _) _ _ ?bf |- _ =>
        assert (Ebf : bf = Full) by (inv L; reflexivity); subst bf;
        pose proof (tm_blk _ _ _ _ _ _ _ Hs Hq L) as -> end.
      inv Hal;
        match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
      match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
        injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
      split.
      + apply (Q2_trans _ _ _ _ HQ). apply (st_q2 _ _ _ _ _ _ _ Hst).
        intros i _ Hk. exact (proj1 (HK _ _ Hk) eq_refl).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) by (left; exact Nbo). exact Hgy.
    - unfold gy_store in Hs. apply andb_true_iff in Hs as (Hl & Hr).
      destruct (gy_shape _ Hl) as (X & a & -> & Hx').
      repeat match type of Hr with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hr
      end.
      apply andb_true_iff in Hr as (R1 & R2). apply Pos.eqb_eq in R1, R2. subst.
      inv Hx.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
      match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => rename Hc into Hca end.
      match goal with L : eval_lvalue _ _ _ _ (Ederef _ _) _ _ ?bf |- _ =>
        assert (Ebf : bf = Full) by (inv L; reflexivity); subst bf;
        apply eval_lvalue_Ederef_base in L;
        destruct (gy_addr _ _ _ _ _ _ _ Hx' Ho Hb L) as (-> & Eo) end.
      match goal with Er : eval_expr _ _ _ _ (Ebinop Osub _ _ _) _ |- _ =>
        apply eval_expr_Ebinop_inv in Er as (w1 & w2 & E1 & E2 & Sb) end.
      apply eval_expr_Etempvar_val in E1, E2.
      destruct (H1 _ E1) as [-> | ->]; [| cbn in Sb; discriminate Sb].
      destruct (H2 _ E2) as [-> | ->]; [| cbn in Sb; discriminate Sb].
      cbn -[Float32.sub] in Sb. injection Sb as <-.
      rewrite (f32_sub_zero_r gy Fg) in Hca.
      cbn in Hca. injection Hca as <-.
      inv Hal;
        match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
      match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
        injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
      rewrite Eo in Hst.
      split.
      + apply (Q2_trans _ _ _ _ HQ). apply (st_q2 _ _ _ _ _ _ _ Hst).
        intros i Hi Hk. apply (proj2 (HK _ _ Hk)). cbn [size_chunk] in Hi. split; [reflexivity | lia].
      + rewrite (Mem.load_store_same _ _ _ _ _ _ Hst). reflexivity.
  Qed.

  Lemma qs_init : forall v bo oo bfa gy le1,
    bind_parameter_temps (fn_params mario.f_sink_mario_in_quicksand) [v]
      (create_undef_temps (fn_temps mario.f_sink_mario_in_quicksand)) = Some le1 ->
    qs_P v bo oo bfa gy le1.
  Proof.
    intros v bo oo bfa gy le1 Hb. cbn [fn_params mario.f_sink_mario_in_quicksand bind_parameter_temps] in Hb.
    injection Hb as <-.
    split; [apply PTree.gss |].
    split; [| split; [| split]].
    - intros p Hp. rewrite PTree.gso in Hp by nid. right. exact (cut_undef (fn_temps mario.f_sink_mario_in_quicksand) _ _ Hp).
    - intros x p Hin Hx. right. right.
      rewrite PTree.gso in Hx by (destruct Hin as [<- | [<- | [<- | []]]]; nid).
      exact (cut_undef (fn_temps mario.f_sink_mario_in_quicksand) _ _ Hx).
    - intros p Hp. rewrite PTree.gso in Hp by nid. right. exact (cut_undef (fn_temps mario.f_sink_mario_in_quicksand) _ _ Hp).
    - intros p Hp. rewrite PTree.gso in Hp by nid. right. exact (cut_undef (fn_temps mario.f_sink_mario_in_quicksand) _ _ Hp).
  Qed.

  Lemma qs_row : forall fd v,
    resolves lp mario._sink_mario_in_quicksand fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._sink_mario_in_quicksand v)
      (post_of bm mario._sink_mario_in_quicksand).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_qs Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    ffw_open Hw.
    pose proof Hw as (_ & (_ & _ & _ & _ & _ & LQ & _) & _).
    assert (NBO : bm <> bo) by exact (not_eq_sym D1).
    assert (NFA : bm <> bfa) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SFA eq_refl).
    assert (OFA : bo <> bfa)
      by (destruct (D4 bfa ltac:(left; cbn; auto 20)) as (Of & _); exact (not_eq_sym Of)).
    assert (LO : Mem.load Mint32 m bm 136 = Some (Vptr bo oo)) by exact Lo.
    assert (Hb84 : Ptrofs.unsigned oo + 84 <= Ptrofs.modulus) by (unfold SZ_OBJECT in Soo; lia).
    assert (Hb44 : Ptrofs.unsigned oo + 44 <= Ptrofs.modulus) by lia.
    assert (LT : Mem.load Mint32 m bo (Ptrofs.unsigned oo + 80) = Some (Vint Int.zero)
                 \/ exists o, Mem.load Mint32 m bo (Ptrofs.unsigned oo + 80) = Some (Vptr bfa o))
      by exact LTM.
    pose proof Hc as (_ & _ & _ & _ & _ & _ & bo' & oo' & H7 & H8).
    assert (H7' : Mem.load Mint32 m bm 136 = Some (Vptr bo' oo')) by exact H7.
    rewrite LO in H7'. injection H7' as <- <-.
    assert (H8' : Mem.load Mfloat32 m bo (Ptrofs.unsigned oo + 36) = Some (Vsingle (c_gfxy c))) by exact H8.
    destruct Hb as ((_ & _ & Fg & _) & _).
    set (K := fun b z => b <> bfa /\ ~ (b = bo /\ Ptrofs.unsigned oo + 36 <= z < Ptrofs.unsigned oo + 40)).
    assert (HQ : Q2 K m m' /\ Mem.load Mfloat32 m' bo (Ptrofs.unsigned oo + 36) = Some (Vsingle (c_gfxy c))).
    { refine (lw_body_frame ge
                (fun m1 => Q2 K m m1 /\ Mem.load Mfloat32 m1 bo (Ptrofs.unsigned oo + 36) = Some (Vsingle (c_gfxy c)))
                mario.f_sink_mario_in_quicksand (qs_P v bo oo bfa (c_gfxy c))
                qs_set_ok qs_store_ok qs_call eq_refl qs_chk
                _ _ _ m [v] t m' vr Hev _ (conj (Q2_refl _ m) H8')).
      - intros id a le m1 v1 Hs Hp (HQ1 & Hg1) Ea.
        refine (qs_set K v bo oo bfa (c_gfxy c) m id a le m1 v1 Hs Hp HQ1 Hg1 _ _ Hmarg LO LQ LT Hb84 Ea).
        + intros z Hz. split; [exact NFA |]. intros (E & _). exact (NBO E).
        + intros z Hz. split; [exact OFA |]. intros (_ & Hz'). lia.
      - intros lv rhs le m1 t1 le1 m2 out Hs Hp Hx (HQ1 & Hg1).
        refine (qs_store K v bo oo bfa (c_gfxy c) m lv rhs le m1 t1 le1 m2 out Hs Hp _ OFA Fg Hb44 Hx HQ1 Hg1).
        intros b z Hk. exact Hk.
      - intros optid a al le m1 t1 le1 m2 out Hs. discriminate Hs.
      - intros le1 Hb1. exact (qs_init v bo oo bfa (c_gfxy c) le1 Hb1). }
    destruct HQ as (HQ & Hg').
    assert (LD : forall ch b z, b <> bfa -> b <> bfa -> (b <> bm \/ hz z (size_chunk ch)) ->
               (b <> bo \/ z + size_chunk ch <= Ptrofs.unsigned oo + 36 \/ Ptrofs.unsigned oo + 36 + 4 <= z) ->
               Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z N1 _ _ Ho. apply (Q2_load _ _ _ HQ). intros j Hi.
      split; [exact N1 |].
      intros (-> & Hj). destruct Ho as [Ho | Ho]; [exact (Ho eq_refl) | clear - Hi Hj Ho; lia]. }
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p) by exact (Q2_perm _ _ _ HQ).
    assert (NBle : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact (proj1 (proj2 HQ)).
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    assert (XF : xsym lp bfa)
      by (exists mario_actions_moving._sFloorAlignMatrix;
          split; [right; right; right; right; left; reflexivity | exact SFA]).
    assert (OBJ : bo = bfa \/ exists oo', Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo')
                                          /\ Ptrofs.unsigned oo + 36 = Ptrofs.unsigned oo' + 36)
      by (right; exists oo; split; [exact LO | reflexivity]).
    assert (OWL : 36 <= 36 /\ 0 <= 4 /\ 36 + 4 <= 56) by lia.
    assert (HG : 40 <= 36 \/ forall mb mo, Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo) ->
               Mem.load Mfloat32 m' mb (Ptrofs.unsigned mo + OFS_GFXY)
               = Mem.load Mfloat32 m mb (Ptrofs.unsigned mo + OFS_GFXY)).
    { right. intros mb mo Hl. change MARIOOBJ_OFF with 136 in Hl. rewrite LO in Hl.
      injection Hl as <- <-. change OFS_GFXY with 36. rewrite Hg', H8'. reflexivity. }
    split; [eapply hole_fworld with (m := m) (m' := m') (bsr := bfa) (bsrc := bfa) (ob := bo)
                                    (oz := Ptrofs.unsigned oo + 36) (ow := 36) (wl := 4); eassumption |].
    split; [exists c; split; [eapply hole_cells with (m := m) (m' := m') (bsr := bfa) (bsrc := bfa) (ob := bo)
                                    (oz := Ptrofs.unsigned oo + 36) (ow := 36) (wl := 4); eassumption | apply rt_refl] |].
    destruct qs_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* mario_update_hitbox_and_cap_model (2026-10-25): HitboxFrame's frame  *)
  (* (the cap music globals CapAudio.cap_ids, gBodyStates, Mario's hole,  *)
  (* gfx.node.flags and hitboxHeight of his object; load_sequence through *)
  (* its labeled footprint LsContract.ls_frame, TRUST 4.1), and HoleX keeps *)
  (* the frame world and the cells around it.                             *)
  (* ==================================================================== *)
  Lemma not_in_ids : forall id ids, existsb (Pos.eqb id) ids = false -> ~ In id ids.
  Proof.
    intros id ids N Hin.
    assert (T : existsb (Pos.eqb id) ids = true)
      by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
    rewrite T in N. discriminate N.
  Qed.

  Lemma hitbox_row : forall fd v,
    resolves lp mario._mario_update_hitbox_and_cap_model fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._mario_update_hitbox_and_cap_model v)
      (post_of bm mario._mario_update_hitbox_and_cap_model).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_hitbox Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    ffw_open Hw.
    destruct Hgv as (bg & Hbg & _).
    assert (HLG : forall b o, Mem.load Mint32 m bg 0 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero)
      by (intros b o Hl; exact (Hgms m (proj2 (proj2 Hok)) bg b o Hbg Hl)).
    assert (HLO : forall b o, Mem.load Mint32 m bm 136 = Some (Vptr b o) -> b = bo /\ o = oo).
    { intros b o Hl. change 136 with FFW_OBJ in Hl. rewrite Lo in Hl. injection Hl as <- <-. split; reflexivity. }
    assert (HLB : forall b o, Mem.load Mint32 m bm 152 = Some (Vptr b o) -> b = bbs).
    { intros b o Hl. change 152 with FFW_BODY in Hl. rewrite LBS in Hl. injection Hl as <- _. reflexivity. }
    assert (NGm : ~ LsContract.gblk ge CapAudio.cap_ids bm).
    { intros (g & Hin & Hg).
      assert (g = level_update._gMarioStates) by (eapply Genv.genv_vars_inj; [exact Hg | exact Hbm0]).
      subst g. refine (not_in_ids level_update._gMarioStates CapAudio.cap_ids _ Hin). vm_compute. reflexivity. }
    assert (Nmb : bm <> bbs) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SBS eq_refl).
    assert (Nmo : bm <> bo) by exact (not_eq_sym D1).
    assert (Ngb : bg <> bbs) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbg SBS eq_refl).
    assert (Ngo : bg <> bo) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbg Spool eq_refl).
    assert (Hoo : Ptrofs.unsigned oo + 512 <= Ptrofs.modulus) by (unfold SZ_OBJECT in Soo; lia).
    assert (Nbo : bbs <> bo) by exact (proj1 (D4 bbs ltac:(left; cbn; auto 20))).
    assert (HQH : Q2 (HitboxFrame.K2 lp bm bbs bo oo) m m' /\ HitboxFrame.HH bo oo m')
      by (eapply HitboxFrame.hitbox_hh; eassumption).
    destruct HQH as (HQ & HH0).
    (* the body leaves Mario's hitboxHeight 100.0f or 160.0f: ffw's ff_HH *)
    assert (HHX : ffw_hh m' bo oo) by exact HH0.
    assert (XB : xsym lp bbs)
      by (exists mario._gBodyStates; split; [right; right; left; reflexivity | exact SBS]).
    assert (LD : forall ch b z, ~ HoleX.chg lp CapAudio.cap_ids b -> (b <> bm \/ hz z (size_chunk ch)) ->
               HoleX.ozx bo oo 56 0 b z (size_chunk ch) -> Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Hcg Hz Ho. apply (Q2_load _ _ _ HQ). intros j Hj.
      unfold HitboxFrame.K2, HitboxFrame.K1.
      split; [split |]; [| | split].
      - intros G. apply Hcg. right. exact G.
      - intros (-> & Hm). destruct Hz as [N | Hz]; [exact (N eq_refl) |].
        unfold hz in Hz. unfold HitboxFrame.mhole in Hm. clear - Hj Hz Hm. lia.
      - intros ->. apply Hcg. left. exact XB.
      - intros (-> & Hm). destruct Ho as [N | Ho]; [exact (N eq_refl) |].
        unfold HoleX.ohz in Ho. clear - Hj Ho Hm. lia. }
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p) by exact (Q2_perm _ _ _ HQ).
    assert (NBle : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact (proj1 (proj2 HQ)).
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    assert (XGok : forallb (fun id => negb (existsb (Pos.eqb id) HoleX.safe_ids)) CapAudio.cap_ids = true)
      by (vm_compute; reflexivity).
    assert (LO : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
    assert (OWL : 36 <= 56 /\ 0 <= 0 /\ 56 + 0 <= 56) by lia.
    assert (HG : 40 <= 56 \/ 56 + 0 <= 36) by lia.
    split; [eapply HoleX.hx_fworld with (XG := CapAudio.cap_ids) (m := m) (m' := m') (ob := bo) (oo0 := oo)
                                       (ow := 56) (wl := 0); eassumption |].
    split; [exists c; split; [eapply HoleX.hx_cells with (XG := CapAudio.cap_ids) (m := m) (m' := m') (ob := bo)
                                (oo0 := oo) (ow := 56) (wl := 0); eassumption | apply rt_refl] |].
    destruct hitbox_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* THE SPLIT                                                             *)
  (* ==================================================================== *)
  Ltac in_lit := solve [repeat (first [left; reflexivity | right])].

  Theorem naFA_of_open : na_open_rows -> seg_call_rows_naFA lp bm MWF.
  Proof.
    intros Hop f fd v Hin Hna Hnu Hr.
    assert (Hc : In f ema_calls).
    { (* explicit instance: unifying against the computed call list hangs *)
      pose proof (proj2 (in_flat_map (fun o => match o with OCall f => [f] | _ => [] end)
                           ema_obls f)) as I.
      unfold ema_calls. apply I. clear I.
      exists (OCall f). split; [exact Hin | left; reflexivity]. }
    rewrite ema_calls_eq in Hc.
    repeat match goal with Hc : In _ (_ :: _) |- _ => destruct Hc as [<- | Hc] end;
      [.. | destruct Hc].
    all: first
      [ exfalso; exact (Hna eq_refl)
      | exfalso; exact (Hnu eq_refl)
      | exact (ssc_row fd v Hr)
      | exact (health_row fd v Hr)
      | exact (reset_row fd v Hr)
      | exact (cam_row fd v Hr)
      | exact (squish_row fd v Hr)
      | exact (qs_row fd v Hr)
      | exact (hitbox_row fd v Hr)
      | exact (sub_row fd v)
      | (apply (Hop _ fd v); [unfold na_open; in_lit | exact Hr]) ].
  Qed.
End NA.
