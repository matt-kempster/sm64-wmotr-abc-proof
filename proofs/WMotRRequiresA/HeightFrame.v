(* spine-root: the GOAL-2 capstone -- a no-A run keeps Mario's height
   (MarioState.pos[1]) at or below YMAX, over the composed real game frame
   whose Mario-action segment is GOAL 1's proved frame on any twelve-TU link. *)
(* ======================================================================= *)
(* GOAL 2 on the spine: the HEIGHT FRAME.                                   *)
(* (promoted from playground/CompositionFrame.v, T0; plan =                 *)
(*  docs/goal2-real-frame-plan.md, strategy = docs/goal2-strategy-v2-*.md)  *)
(*                                                                          *)
(* WHAT IT SAYS.  One game frame is a composition of five segments:         *)
(*   seg_input    the controller poll (the player's input lands here),      *)
(*   seg_platform apply_mario_platform_displacement,                        *)
(*   seg_action   ONE real eval_funcall of execute_mario_action over lp     *)
(*                -- GOAL 1's step relation, verbatim,                      *)
(*   seg_level    the warp / level phase,                                   *)
(*   seg_rest     the rest of update_objects + gfx (non-Mario).             *)
(* For a height invariant Phi that implies pos[1] <= YMAX: a run that       *)
(* starts GOAL-1-well-formed and in Phi, with the controller's A bit clear  *)
(* after every poll, keeps Mario's height <= YMAX forever.                  *)
(*                                                                          *)
(* WHAT IS PROVED.  seg_action preserving GOAL 1's invariant is NOT         *)
(* assumed: it is NoAImpliesNoFlyTwelve.frame_ok_linked12, on exactly       *)
(* GOAL 1's assumed surface (copied into the last section).  The            *)
(* composition glue is proved.                                              *)
(*                                                                          *)
(* WHAT IS OPEN -- every row is meant to be TRUE of the real game (no       *)
(* forall over states the game never produces; see the comment on each):    *)
(*   Phi             the height invariant: strategy v2's                    *)
(*                   Phi = Phi_act /\ Phi_ground /\ Phi_air /\ Phi_special  *)
(*                   over Pot = y + ballistic(vel[1]) + windup.  A          *)
(*                   PARAMETER until T3 defines it from the real fields.    *)
(*   Hphi_y          Phi m -> pos[1] <= YMAX (immediate once Phi is         *)
(*                   defined: Pot >= y).                                    *)
(*   Hseg_action_phi THE CRUX (T3): one real execute_mario_action frame     *)
(*                   preserves Phi.                                         *)
(* and the flank SPECS are labeled trust: each states what that phase of    *)
(* the real game does -- y / action loads as the censuses found them, and   *)
(* that it carries GOAL 1's MWF and Phi.  (Stating the carries as separate  *)
(* forall-rows over every memory matching the load clauses would be FALSE: *)
(* an adversarial post-memory breaks MWF elsewhere.)                        *)
(*                                                                          *)
(* YMAX is a parameter.  Strategy v2 instantiates it as H* + Delta_pot      *)
(* (Delta_pot = 273); red coin #2 (y = 3140) is out of reach iff            *)
(* YMAX < 3140 - 160 (hitbox height).  Both numbers come from level data    *)
(* not yet in generated/.                                                   *)
(* ======================================================================= *)

From Coq Require Import ZArith List Reals.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame ReachableRun
  RealFrameValue RealFrameLinked AGates SymbolicLinking FieldNonInterference.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer.
From SM64.Proofs Require Import MWFReal RestSurface FloorsSurface
  OutParamSurface RetSurface StationaryLeafSurface MovingLeafSurface
  ObjectLeafSurface CutsceneLeafSurface WindSurface WarpSurface
  FloorsLeafSurface.
From SM64.Proofs Require Import LinkedTwelve SpawnInit InitMemSat.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked NoAImpliesNoFlyTwelve.
Import ListNotations.

(* ----------------------------------------------------------------------- *)
(* The tracked y cell, pinned against the generated AST: pos is at byte     *)
(* offset 60 of MarioState (vm-computed from mario.prog's own composite     *)
(* env, like GOAL 1's action @ 12), so pos[1] is at 64.                     *)
(* ----------------------------------------------------------------------- *)
Lemma mario_pos_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._pos mario_state_members
    = Errors.OK (60, Full).
Proof. vm_compute. reflexivity. Qed.

Definition POSY : Z := 64.   (* pos base 60 (pinned above) + 4 for index 1 *)

(* ACT_READING_NPC_DIALOG as clightgen emitted it: the literal 536875782 in
   f_set_mario_npc_dialog's guard (generated/mario_actions_cutscene.v), the
   same literal as its set_mario_action argument and the dispatch-table
   labels -- the only object-side write to Mario's action cell in WMotR
   (docs/goal2-wmotr-behavior-census.md). *)
Definition ACT_READING_NPC_DIALOG : int := Int.repr 536875782.

Lemma dialog_action_not_tainted : not_tainted ACT_READING_NPC_DIALOG.
Proof. vm_compute. reflexivity. Qed.

Section HeightFrame.
  Variable lp : Clight.program.
  Variable bm : block.           (* Mario's MarioState block *)
  Variable MWF : mem -> Prop.    (* GOAL 1's carried invariant *)
  Variable Phi : mem -> Prop.    (* the height invariant (T3 defines it) *)

  Notation mem_ok := (mem_ok_lp bm MWF).

  (* a phase CARRIES the two invariants *)
  Definition carries (m m' : mem) : Prop :=
    (MWF m -> MWF m') /\ (Phi m -> Phi m').

  (* ===================================================================== *)
  (* 1. THE SEGMENT SPECS.  Every flank leaves the action cell alone        *)
  (*    (or, for seg_rest, sets it to the one grounded non-tainted value),  *)
  (*    which is what makes GOAL 1 transfer through the composition.        *)
  (* ===================================================================== *)

  (* seg_input: the controller poll (read_controller_inputs, game_init.c)
     writes the controller structs only -- never Mario's y or action.
     MWF_real's controller conjunct IS the A-clear fact, so the MWF carry is
     conditional on the player not pressing A: this is where the no-A
     premise enters the frame. *)
  Definition seg_input_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm)
    /\ (a_pressed_real bm m' = false -> MWF m -> MWF m')
    /\ (Phi m -> Phi m').

  (* seg_platform: apply_mario_platform_displacement.  T1's widened spec
     (playground/PlatformInert.v): the y and action LOADS are unchanged --
     NULL platform is an early return, a ridden wing-cap box never moves so
     its displacement is identity. *)
  Definition seg_platform_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm)
    /\ carries m m'.

  (* seg_level: the warp / level phase.  None of its writers touches
     m->action (scout, docs/goal2-frame-boundary-scout.md).  Its y writes
     are the censused teleports (T4: expected EMPTY in WMotR), which the
     Phi carry covers. *)
  Definition seg_level_spec (m m' : mem) : Prop :=
    Mem.unchanged_on (action_cell bm) m m'
    /\ carries m m'.

  (* seg_rest: the non-Mario phase.  The WMotR object census found three
     object-side Mario writers (pole push: pos[0]/pos[2]; 1-up: numLives;
     bob-omb buddy: action := ACT_READING_NPC_DIALOG); none writes y. *)
  Definition seg_rest_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
        \/ Mem.load Mint32 m' bm 12 = Some (Vint ACT_READING_NPC_DIALOG))
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm)
    /\ carries m m'.

  (* ===================================================================== *)
  (* 2. THE FRAME.  The per-frame input i is the post-poll memory (GOAL 1's *)
  (*    convention: the input IS the memory the frame reads it from).       *)
  (* ===================================================================== *)
  Definition frame_step (i m m' : mem) : Prop :=
    exists m1 m2 m3,
      seg_input_spec m i
      /\ seg_platform_spec i m1
      /\ execute_mario_action_step_lp lp m1 m2
      /\ seg_level_spec m2 m3
      /\ seg_rest_spec m3 m'.

  Variable YMAX : R.

  Definition y_le (m : mem) : Prop :=
    forall v, Mem.load Mfloat32 m bm POSY = Some (Vsingle v) ->
              (B2R _ _ v <= YMAX)%R.

  (* ---- the rows ------------------------------------------------------- *)

  (* GOAL 1's frame (discharged in the twelve-TU section below by
     frame_ok_linked12 -- NOT open). *)
  Hypothesis Hframe_action :
    forall m m', mem_ok m -> execute_mario_action_step_lp lp m m' -> mem_ok m'.

  (* OPEN (T2 + T3, THE CRUX): one real execute_mario_action frame from a
     GOAL-1-well-formed state preserves the height invariant.  The
     ballistic value walk (paqs `pos[1] += vel[1]/4`, bounded by the Flocq
     brick T2; launches reset Pot to floor + budget; attach via the
     find_floor value contract). *)
  Hypothesis Hseg_action_phi :
    forall m m', mem_ok m -> Phi m -> execute_mario_action_step_lp lp m m' ->
                 Phi m'.

  (* OPEN (immediate once Phi is defined): the invariant bounds the height. *)
  Hypothesis Hphi_y : forall m, Phi m -> y_le m.

  (* ---- proved glue ------------------------------------------------------ *)

  Lemma action_sat_load_eq :
    forall Q m m',
      Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12 ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof. intros Q m m' Heq Hsat v Hl. apply Hsat. congruence. Qed.

  Lemma action_sat_load_eq_or_val :
    forall Q v0 m m',
      (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
       \/ Mem.load Mint32 m' bm 12 = Some (Vint v0)) ->
      Q v0 -> action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q v0 m m' [Heq | Heq] Hv0 Hsat v Hl.
    - apply Hsat. congruence.
    - rewrite Heq in Hl. injection Hl as Hveq. subst v. exact Hv0.
  Qed.

  (* an action-load-inert flank (input / platform) carries mem_ok *)
  Lemma inert_flank :
    forall m m',
      Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12 ->
      (Mem.valid_block m bm -> Mem.valid_block m' bm) ->
      (MWF m -> MWF m') ->
      mem_ok m -> mem_ok m'.
  Proof.
    intros m m' Ha Hv Hmwf (Hv0 & Hs0 & Hm0).
    split; [ exact (Hv Hv0) | split ].
    - exact (action_sat_load_eq not_tainted m m' Ha Hs0).
    - exact (Hmwf Hm0).
  Qed.

  (* ===================================================================== *)
  (* 3. ONE FRAME: an A-free frame preserves mem_ok AND Phi.                *)
  (* ===================================================================== *)
  Theorem frame_step_ok :
    forall i m m',
      a_pressed_real bm i = false ->
      mem_ok m /\ Phi m ->
      frame_step i m m' ->
      mem_ok m' /\ Phi m'.
  Proof.
    intros i m m' HA (Hok & Hphi)
           (m1 & m2 & m3 & Hin & Hplat & Hact & Hlvl & Hrest).
    (* input *)
    destruct Hin as (_ & Hai & Hvi & Hmi & Hpi).
    pose proof (inert_flank m i Hai Hvi (Hmi HA) Hok) as Hok0.
    pose proof (Hpi Hphi) as Hphi0.
    (* platform *)
    destruct Hplat as (_ & Hap & Hvp & Hmp & Hpp).
    pose proof (inert_flank i m1 Hap Hvp Hmp Hok0) as Hok1.
    pose proof (Hpp Hphi0) as Hphi1.
    (* the Mario action: GOAL 1's frame + the crux *)
    pose proof (Hseg_action_phi m1 m2 Hok1 Hphi1 Hact) as Hphi2.
    pose proof (Hframe_action m1 m2 Hok1 Hact) as (Hv2 & Hs2 & Hm2).
    (* level *)
    destruct Hlvl as (Hact3 & Hml & Hpl).
    assert (Hv3 : Mem.valid_block m3 bm)
      by (eapply Mem.valid_block_unchanged_on; eauto).
    assert (Hs3 : action_sat not_tainted m3 bm)
      by (eapply action_sat_unchanged_on; [ exact Hact3 | exact Hv2 | exact Hs2 ]).
    (* rest *)
    destruct Hrest as (_ & Har & Hvr & Hmr & Hpr).
    split.
    - split; [ exact (Hvr Hv3) | split ].
      + exact (action_sat_load_eq_or_val not_tainted ACT_READING_NPC_DIALOG
                 m3 m' Har dialog_action_not_tainted Hs3).
      + exact (Hmr (Hml Hm2)).
    - exact (Hpr (Hpl Hphi2)).
  Qed.

  (* ===================================================================== *)
  (* 4. THE RUN: a no-A run keeps y <= YMAX (and GOAL 1's invariant).       *)
  (* ===================================================================== *)
  Theorem noA_run_height_bound :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok init -> Phi init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      reachable mem mem frame_step init is m ->
      mem_ok m /\ y_le m.
  Proof.
    intros init is m Hok Hphi HA Hr.
    destruct (reachable_preserves_Phi mem mem (a_pressed_real bm) frame_step
                (fun s => mem_ok s /\ Phi s)
                (fun i s s' Ha Hs Hst => frame_step_ok i s s' Ha Hs Hst)
                init is m Hr (conj Hok Hphi) HA) as (Hok' & Hphi').
    exact (conj Hok' (Hphi_y m Hphi')).
  Qed.

End HeightFrame.

(* ======================================================================= *)
(* 5. THE TWELVE-TU CAPSTONE.  The seg_action row is DISCHARGED by GOAL 1:  *)
(* frame_ok_linked12, on GOAL 1's assumed surface -- copied verbatim from   *)
(* NoAImpliesNoFlyTwelve (same statements, same trust; see that file for   *)
(* the per-row commentary).  What GOAL 2 adds is only the flank rows and    *)
(* the y rows of the HeightFrame section.                                   *)
(* ======================================================================= *)
Section HeightLinked12.
  Variable lp : Clight.program.

  (* THE structural premise: lp is a link of the twelve generated TUs. *)
  Hypothesis H12 : linked12 lp.

  Variable bm : block.    (* Mario's MarioState block *)
  Variable bc : block.    (* the controller struct's block *)
  Variable oc0 : ptrofs.  (* the controller struct's offset within bc *)
  Variable SafeB : block -> Prop.  (* blocks the pointer chase can reach *)

  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* ---- the surviving assumed surface: identical statements to the
     real_mwf capstone's rows (see NoAImpliesNoFlyLinked.v for the
     per-row commentary); ONLY the 12 LO_* pins and Hrest_ext_only are
     absent -- those are now theorems of LinkedTwelve. ---- *)

  (* task #92 tail: Hbc_bm and Hbc_sym are no longer assumed here -- the
     real_mwf capstone DERIVES both internally from the faithful spawn
     condition (Hspawn), so they are absent from this consolidated surface. *)
  (* P5 SLICE 3: ONE consolidated SafeB honest-boundary row + the faithful
     spawn condition REPLACE the eight scattered SafeB rows (HSafeB_not_bm,
     HSafeB_not_bc, the five ~SafeB conjuncts of the *_blk rows, Hsfam_safe).
     The real_mwf capstone derives all eight internally (SpawnInit exports).
     HSafeB_sym_iff: the intersection of SafeB with the linked symbol table is
     exactly {sFloorAlignMatrix} (the object pool is external/runtime -- see
     docs/p5-safeb-design.md); non-vacuous via SpawnInit.safeb_wit_sat. *)
  Hypothesis HSafeB_sym_iff :
    forall id b,
      Genv.find_symbol (lp_ge lp) id = Some b ->
      (SafeB b <-> id = mario_actions_moving._sFloorAlignMatrix).
  (* task #92 slice 6: Hspawn is NO LONGER assumed.  The `exists init,
     init_mem lp = Some init` conjunct of spawn_ok is now a THEOREM for every
     twelve-TU link (InitMemSat.linked12_init_mem, the certificate-shaped
     analogue of linked12_inhabited).  What remains are the three FAITHFUL
     instantiation choices pinning bm/bc/oc0 to the gMarioStates / gControllers
     symbol blocks and offset zero -- each itself provable from linked12
     (SpawnInit.spawn_symbols_resolve) but supplied here because bm/bc/oc0 are
     the capstone's free run-blocks.  From them + linked12_init_mem, Hspawn is
     DERIVED as a Lemma below.  Net: the last dischargeable bucket-B residual
     (init_mem existence) is removed from the assumed surface. *)
  Hypothesis Hbm_sym :
    Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym :
    Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.

  (* P5 SLICE 4: Hglob_valid is DISCHARGED at the real_mwf capstone (from the
     R0 nextblock-bound conjunct via glob_valid_of_nextbound), so it is no
     longer an assumed row here either. *)
  Hypothesis Hocp_find_floor :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB mario._find_floor.
  Hypothesis Hocp_find_ceil :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_find_ceil.
  Hypothesis Hwolcp_fwc :
    call_pres_ext_wol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._f32_find_wall_collision.
  Hypothesis Hscp_v3f :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hscp_v3s :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3s_set.
  Hypothesis Hwlcp_v3f_real :
    call_pres_ext_wl lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.
  Hypothesis Hpres_sta_ext : forall fid,
      mem_id fid StationaryLeafSurface.sta_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hpres_mov_ext : forall fid,
      mem_id fid MovingLeafSurface.mov_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hcpx_approach_f32_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      mario_actions_airborne._approach_f32.
  Hypothesis Hw1cp_v3sset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario._vec3s_set.
  Hypothesis Hglob_obj_root :
    forall g gb m b o,
      mem_id g CutsceneLeafSurface.gobj_ids = true ->
      MWF m ->
      Genv.find_symbol (lp_ge lp) g = Some gb ->
      Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      SafeB b.
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hpres_cut_ext : forall fid,
      mem_id fid CutsceneLeafSurface.cut_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hxcp_fwl_real :
    call_pres_ext lp bm (NoA_real bm) MWF mario_step._find_water_level.
  Hypothesis Hscp_geo_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario._geo_update_animation_frame.
  Hypothesis Hocp_rai_real :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario._retrieve_animation_index.
  Hypothesis Hcpx_approach_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      mario_actions_automatic._approach_s32.
  Hypothesis Holcp_fwc_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      mario._find_wall_collisions.
  Hypothesis Hw1cp_v3f_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hwolcp_v3f_real :
    call_pres_ext_wol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hw1cp_v3fset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_set.
  Hypothesis Hscp_v3fset_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_set.
  Hypothesis Hpres_floors_ext : forall fid,
      mem_id fid floors_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hcp_spawn_real : call_pres_ext_sr lp bm (NoA_real bm) MWF SafeB
      behavior_actions._spawn_object.
  Hypothesis Hcp_savefile_real :
    call_pres_ext lp bm (NoA_real bm) MWF interaction._save_file_set_cap_pos.
  Hypothesis Hcpx_ibcd_real :
    call_pres_ext_wl lp bm (NoA_real bm) MWF SafeB
      interaction._init_bully_collision_data.
  Hypothesis Hcpx_tbs_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      interaction._transfer_bully_speed.
  Hypothesis Hpres_warp_ext : forall fid,
      mem_id fid warp_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* Hret_unsafe REMOVED (task #99): the v2 engine no longer consumes any
     return-value row (it was dead plumbing / a latent vacuity -- see
     NoAImpliesNoFlyLinked). *)
  Hypothesis Hext_action : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Hypothesis Hmwf_ext : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.

  (* ---- GOAL 2's own rows (see the HeightFrame section) ---- *)
  Variable Phi : mem -> Prop.
  Variable YMAX : R.

  Hypothesis Hseg_action_phi :
    forall m m', mem_ok_lp bm MWF m -> Phi m ->
                 execute_mario_action_step_lp lp m m' -> Phi m'.
  Hypothesis Hphi_y : forall m, Phi m -> y_le bm YMAX m.

  (* GOAL 1's proved frame, at this section's surface *)
  Lemma frame_action_linked12 :
    forall m m', mem_ok_lp bm MWF m ->
                 execute_mario_action_step_lp lp m m' -> mem_ok_lp bm MWF m'.
  Proof. intros m m'. eapply frame_ok_linked12; eassumption. Qed.

  (* ==================================================================== *)
  (* THE GOAL-2 CAPSTONE (height form): over any link of the twelve TUs,  *)
  (* a run of real game frames with the A bit clear after every poll,     *)
  (* started GOAL-1-well-formed and in the height invariant Phi, keeps    *)
  (* Mario's height <= YMAX.                                              *)
  (* ==================================================================== *)
  Theorem wmotr_noA_height_bound_linked12 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init -> Phi init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      reachable mem mem (frame_step lp bm MWF Phi) init is m ->
      y_le bm YMAX m.
  Proof.
    intros init is m Hok Hphi HA Hr.
    exact (proj2 (noA_run_height_bound lp bm MWF Phi YMAX
                    frame_action_linked12 Hseg_action_phi Hphi_y
                    init is m Hok Hphi HA Hr)).
  Qed.

End HeightLinked12.
