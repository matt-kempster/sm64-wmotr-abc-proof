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
(* starts GOAL-1-well-formed and in Phi, with A neither pressed nor held    *)
(* after every poll (a_used_real: holding A counts as using it), keeps      *)
(* Mario's height <= YMAX forever.                                          *)
(*                                                                          *)
(* WHAT IS PROVED.  seg_action preserving GOAL 1's invariant is NOT         *)
(* assumed: it is NoAImpliesNoFlyTwelve.frame_ok_linked12, on exactly       *)
(* GOAL 1's assumed surface (copied into the last section).  The            *)
(* composition glue is proved.                                              *)
(*                                                                          *)
(* WHAT IS OPEN -- every row is meant to be TRUE of the real game (no       *)
(* forall over states the game never produces; see the comment on each):    *)
(*   Phi             CONCRETE (HeightInvariant.height_invariant): the height budget *)
(*                   y + credit <= 2424 + 372 over real MarioState cells    *)
(*                   and gfx.pos[1].  Its whitelist R_noA is a parameter.   *)
(*                   Hphi_y is PROVED, YMAX = 2796.                         *)
(*   the crux        "one real execute_mario_action keeps Phi" is a LEMMA   *)
(*                   (seg_action_phi): every move's budget arithmetic is    *)
(*                   PROVED in binary32 (HeightMoveCatalog.chain_keeps_budget); open: *)
(*     Hframe_stays_noA  the frame keeps the action in R_noA,               *)
(*     Hframe_is_move_chain     the frame's effect on the cells is a chain of *)
(*                     HeightMoveCatalog moves (the T3 value walk),         *)
(*     (the level data -- floor gap, poles -- is PROVED, WMotRLevel.v)      *)
(* and the flank SPECS are labeled trust: each states what that phase of    *)
(* the real game does -- y / action loads as the censuses found them, and   *)
(* that it carries GOAL 1's MWF and Phi.  (Stating the carries as separate  *)
(* forall-rows over every memory matching the load clauses would be FALSE:  *)
(* an adversarial post-memory breaks MWF elsewhere.)                        *)
(*                                                                          *)
(* YMAX is a parameter.  docs/goal2-phi.md instantiates it as H* + 372      *)
(* (slide-kick bounce apex; E3's 273 was wrong); red coin #2 (y = 3140) is  *)
(* out of reach iff                                                         *)
(* YMAX < 3140 - 160 (hitbox height).  K = H* = 2424 is the wing-cap box    *)
(* top (2320 + 2 * 52, the box's x2 scale), from WMotRLevel's data.         *)
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
From SM64.Proofs Require Import HeightInvariant HeightBudgetArith HeightMoveCatalog WMotRLevel.
Import ListNotations.

(* -----------------------------------------------------------------------  *)
(* The tracked y cell, pinned against the generated AST: pos is at byte     *)
(* offset 60 of MarioState (vm-computed from mario.prog's own composite     *)
(* env, like GOAL 1's action @ 12), so pos[1] is at 64.                     *)
(* -----------------------------------------------------------------------  *)
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
    /\ a_down_real bm m' = a_down_real bm m   (* no controller write *)
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

  (* The game is still in WMotR: gCurrLevelNum (level_update.c, set only by
     the warp code from sWarpDest, :477/:502) holds LEVEL_WMOTR (pinned from
     the level's own script, WMotRLevel.level_wmotr_self_warp). *)
  Definition in_wmotr (m : mem) : Prop :=
    exists b, Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some b
              /\ Mem.load Mint16signed m b 0 = Some (Vint (Int.repr LEVEL_WMOTR)).

  (* ===================================================================== *)
  (* 2. THE FRAME.  The per-frame input i is the post-poll memory (GOAL 1's *)
  (*    convention: the input IS the memory the frame reads it from).       *)
  (*    A frame that ends in another level is not a step: the run is ONE    *)
  (*    WMotR visit.  Leaving re-inits Mario elsewhere (the real game,      *)
  (*    experiments/oracle/ywatch.py: falling off sends Mario to the castle *)
  (*    grounds at y = 4500), and a new visit starts again at the entry     *)
  (*    warp, with the red coins and the star counter reloaded (TRUST 0.3). *)
  (* ===================================================================== *)
  Definition frame_step (i m m' : mem) : Prop :=
    exists m1 m2 m3,
      seg_input_spec m i
      /\ seg_platform_spec i m1
      /\ execute_mario_action_step_lp lp m1 m2
      /\ seg_level_spec m2 m3
      /\ seg_rest_spec m3 m'
      /\ in_wmotr m'.

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
    forall m m', mem_ok m -> Phi m -> a_down_real bm m = false ->
                 execute_mario_action_step_lp lp m m' -> Phi m'.

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
      a_used_real bm i = false ->
      mem_ok m /\ Phi m ->
      frame_step i m m' ->
      mem_ok m' /\ Phi m'.
  Proof.
    intros i m m' HU (Hok & Hphi)
           (m1 & m2 & m3 & Hin & Hplat & Hact & Hlvl & Hrest & _).
    destruct (a_used_real_false bm i HU) as (HA & HD).
    (* input *)
    destruct Hin as (_ & Hai & Hvi & Hmi & Hpi).
    pose proof (inert_flank m i Hai Hvi (Hmi HA) Hok) as Hok0.
    pose proof (Hpi Hphi) as Hphi0.
    (* platform *)
    destruct Hplat as (_ & Hap & Hvp & Hdp & Hmp & Hpp).
    assert (HD1 : a_down_real bm m1 = false) by congruence.
    pose proof (inert_flank i m1 Hap Hvp Hmp Hok0) as Hok1.
    pose proof (Hpp Hphi0) as Hphi1.
    (* the Mario action: GOAL 1's frame + the crux *)
    pose proof (Hseg_action_phi m1 m2 Hok1 Hphi1 HD1 Hact) as Hphi2.
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
      Forall (fun i => a_used_real bm i = false) is ->
      reachable mem mem frame_step init is m ->
      mem_ok m /\ y_le m.
  Proof.
    intros init is m Hok Hphi HA Hr.
    destruct (reachable_preserves_Phi mem mem (a_used_real bm) frame_step
                (fun s => mem_ok s /\ Phi s)
                (fun i s s' Ha Hs Hst => frame_step_ok i s s' Ha Hs Hst)
                init is m Hr (conj Hok Hphi) HA) as (Hok' & Hphi').
    exact (conj Hok' (Hphi_y m Hphi')).
  Qed.

End HeightFrame.

(* ======================================================================= *)
(* 5. THE TWELVE-TU CAPSTONE.  The seg_action row is DISCHARGED by GOAL 1:  *)
(* frame_ok_linked12, on GOAL 1's assumed surface -- copied verbatim from   *)
(* NoAImpliesNoFlyTwelve (same statements, same trust; see that file for    *)
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

  (* ---- GOAL 2's own rows.  Phi is CONCRETE (HeightInvariant.v): the height
     budget over real MarioState cells (+ gfx.pos[1]), K = 2424, A = 372.
     Hphi_y is a THEOREM (height_invariant_y).  The old crux row
     Hseg_action_phi ("one real execute_mario_action keeps Phi") is now a
     LEMMA (seg_action_phi below), from: the budget arithmetic of every
     move, PROVED (HeightMoveCatalog.chain_keeps_budget), the WMotR level data,
     PROVED (WMotRLevel.v), and
     two rows about what the real frame does. ---- *)
  Variable R_noA : int -> Prop.
  Notation Phi := (height_invariant bm R_noA).

  (* LEVEL DATA -- now DEFINED from generated/ and PROVED (WMotRLevel.v):
     wmotr_floor / wmotr_pole / wmotr_cannon are read off WMotR's
     clightgen'd terrain, macro objects, level script and behavior scripts;
     no floor height lies in the moat (K, K + 622), every pole is low or out
     of reach, and both cannons seat Mario below K.  What remains
     trusted about them (find_floor returns heights of exactly these
     surfaces; which behaviors load collision) is TRUST.md 0.8 and lives
     in Hframe_is_move_chain, whose MoveChain mentions them. *)

  (* OPEN (the action arm): one real frame keeps the action in the no-A
     whitelist.  GOAL 1's engine at Qv := R_noA
     (execute_mario_action_preserves_real_reached_lp); target list
     docs/goal2-rnoa-census.md.  The a_down premise is load-bearing: with
     A held (never pressed) act_punching / act_move_punching enter
     ACT_JUMP_KICK (mario_actions_object.c:156, _moving.c:845), which is not
     in the census whitelist, so without it this row would be FALSE. *)
  Hypothesis Hframe_stays_noA :
    forall m m', mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                 execute_mario_action_step_lp lp m m' -> action_sat R_noA m' bm.

  (* OPEN (the value walk): what one real execute_mario_action does to
     Phi's cells is a chain of HeightMoveCatalog moves -- the air step, gravity,
     windup, the E3 switches, attach, floor refresh, OOB recovery -- each
     landing in range.  This is a claim about the generated Clight only;
     all budget arithmetic is in chain_keeps_budget.  Moves NOT modelled, so this
     row is false if they fire: hanging (A-gated), water, wind, shells,
     objects that grab or throw (absent in WMotR; E1/E3).  The cannon
     entry (pos := cannon.y + 350, reachable with B only: the buddy talks
     on B, cannon_probe.py) was such a move until the attach case
     wmotr_cannon was added. *)
  Hypothesis Hframe_is_move_chain :
    forall m m' c, mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                   execute_mario_action_step_lp lp m m' ->
                   read_cells bm m c -> budget_ok c ->
                   exists c', read_cells bm m' c' /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c c'.

  (* THE CRUX, now derived *)
  Lemma seg_action_phi :
    forall m m', mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                 execute_mario_action_step_lp lp m m' -> Phi m'.
  Proof.
    intros m m' Hok Hphi HD Hst.
    pose proof Hphi as (_ & c & Hcells & Hc).
    split; [ exact (Hframe_stays_noA m m' Hok Hphi HD Hst) | ].
    destruct (Hframe_is_move_chain m m' c Hok Hphi HD Hst Hcells Hc) as (c' & Hc' & Hmv).
    exists c'. split; [ exact Hc' | ].
    exact (chain_keeps_budget wmotr_floor wmotr_gap_proved wmotr_pole wmotr_poles_proved
             wmotr_cannon wmotr_cannons_proved
             c c' Hc Hmv).
  Qed.

  Lemma Hphi_y : forall m, Phi m -> y_le bm PHI_YMAX m.
  Proof. intros m Hphi v Hl. exact (height_invariant_y bm R_noA m Hphi v Hl). Qed.

  (* GOAL 1's proved frame, at this section's surface *)
  Lemma frame_action_linked12 :
    forall m m', mem_ok_lp bm MWF m ->
                 execute_mario_action_step_lp lp m m' -> mem_ok_lp bm MWF m'.
  Proof. intros m m'. eapply frame_ok_linked12; eassumption. Qed.

  (* ==================================================================== *)
  (* THE GOAL-2 CAPSTONE (height form): over any link of the twelve TUs,  *)
  (* a run of real game frames with A neither pressed nor held after     *)
  (* every poll,                                                          *)
  (* started GOAL-1-well-formed and in the height invariant Phi, keeps    *)
  (* Mario's height <= PHI_YMAX = 2796 (coin #2 needs >= 2980).           *)
  (* ==================================================================== *)
  Theorem wmotr_noA_height_bound_linked12 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init -> Phi init ->
      Forall (fun i => a_used_real bm i = false) is ->
      reachable mem mem (frame_step lp bm MWF Phi) init is m ->
      y_le bm PHI_YMAX m.
  Proof.
    intros init is m Hok Hphi HA Hr.
    exact (proj2 (noA_run_height_bound lp bm MWF Phi PHI_YMAX
                    frame_action_linked12 seg_action_phi Hphi_y
                    init is m Hok Hphi HA Hr)).
  Qed.

End HeightLinked12.
