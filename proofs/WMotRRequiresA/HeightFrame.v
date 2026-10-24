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
(*     Hframe_keeps_world  the frame keeps the WMotR world (WMotRWorld.v),  *)
(*                     which the run carries next to Phi (PhiW)             *)
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
  interaction behavior_actions level_update mario_step camera audio_external.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame ReachableRun
  RealFrameValue RealFrameLinked AGates SymbolicLinking FieldNonInterference.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer.
From SM64.Proofs Require Import MWFReal RestSurface FloorsSurface
  OutParamSurface RetSurface StationaryLeafSurface MovingLeafSurface
  ObjectLeafSurface CutsceneLeafSurface WindSurface WarpSurface
  FloorsLeafSurface.
From SM64.Proofs Require Import LinkedTwelve SpawnInit InitMemSat.
From SM64.Proofs Require SpawnBodies CameraBodies.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked NoAImpliesNoFlyTwelve.
From SM64.Proofs Require Import FrameCalls FrameSplit AirSplit AutoSplit.
From SM64.Proofs.WMotRRequiresA Require Import ProRows NaSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld FfRow AhwRow KbRow FpuFloor ExtInert.
From SM64.Proofs.WMotRRequiresA Require PoleXc PoleCasesT.
From SM64.Proofs.WMotRRequiresA Require RenderFlank RenderKeep AnimWorld PlatformKeep.
From SM64.Proofs Require OsDmaFloor LptBody ObjExtBodies UpdateCameraBody.
From SM64.Proofs Require Import HeightInvariant HeightBudgetArith HeightMoveCatalog WMotRLevel
  WMotRWorld NoAActions.
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
     premise enters the frame.  It writes no object and not gMarioPlatform,
     so it keeps PlatformKeep.plat_still (2026-10-24). *)
  Definition seg_input_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm)
    /\ (a_pressed_real bm m' = false -> MWF m -> MWF m')
    /\ (Phi m -> Phi m')
    /\ (PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp m').

  (* seg_platform: ONE real eval_funcall of platform_displacement.c's
     apply_mario_platform_displacement over lp (2026-10-23, the TU linked as
     the 45th; PlatformKeep.plat_call).  Its carries of mem_ok, Phi and the
     A-held bit are PROVED from the walked body (PlatformKeep, discharging
     Hplat_ok / Hplat_phi / Hplat_ad below).  What the step states besides
     the call (labeled trust): Mario's surfaces are not in D_8032FEC0's
     block (RenderKeep.surf_apart, as for the render step).
     The carries need PlatformKeep.plat_still at the call: gMarioPlatform is
     NULL or an object with zero angle velocity (a rotating platform moves
     Mario's y).  Since 2026-10-24 that is no longer a premise of this step.
     The run carries it at frame boundaries (frame_step_ok): it holds at the
     boot witness (StartSat, proved: gMarioPlatform boots NULL), the object
     phase re-establishes it (seg_rest_spec, part of the labeled objects
     spec), and the poll keeps it (seg_input_spec). *)
  Definition seg_platform_spec (m m' : mem) : Prop :=
    PlatformKeep.plat_call lp m m'
    /\ RenderKeep.surf_apart lp bm PlatformKeep.plat_gvars m.

  (* seg_level: the warp / level phase.  None of its writers touches
     m->action (scout, docs/goal2-frame-boundary-scout.md).  Its y writes
     are the censused teleports (T4: expected EMPTY in WMotR), which the
     Phi carry covers.  The spec is claimed only from memories where the
     warp code cannot fire (2026-10-24, FOUND phantom forall): Phi's lvl_w
     now carries FfWorld.warp_w (in PLAY_MODE_NORMAL sWarpDest.type is
     NOT_WARPING, so warp_area's init_mario_after_warp does not run; no
     demo, no credits; a pending delayed warp has source node F0 / F1 /
     F3), proved at the boot witness and kept by every proved row.  The
     instant and painting warps need floor types WMotR does not have. *)
  Definition seg_level_spec (m m' : mem) : Prop :=
    Mem.unchanged_on (action_cell bm) m m'
    /\ carries m m'.

  (* seg_rest: the non-Mario phase.  The WMotR object census found three
     object-side Mario writers (pole push: pos[0]/pos[2]; 1-up: numLives;
     bob-omb buddy: action := ACT_READING_NPC_DIALOG); none writes y.
     It ends with the platform fact (2026-10-24, part of this labeled
     objects spec): gMarioPlatform is NULL or an object with zero angle
     velocity (PlatformKeep.plat_still).  In the game update_mario_platform
     (the last step of update_objects) sets it to NULL or to the object of
     Mario's floor.  WMotR's only objects with surfaces are the ! boxes and
     the cannon lids (WMotRLevel.collision_of, TRUST 0.8).  Their scripts
     set no angle velocity and no function they run writes one
     (AngleVelCensus); rawData is zeroed at allocation.  The one stale-slot
     path (a lid deactivates in the frame it last loads its surfaces) needs
     Mario on the lid while it opens, and he is then frozen in the buddy's
     dialog, over 400 units away (TRUST 0.7 details).  The render tail writes
     no object field and not gMarioPlatform. *)
  Definition seg_rest_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
        \/ Mem.load Mint32 m' bm 12 = Some (Vint ACT_READING_NPC_DIALOG))
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm)
    /\ carries m m'
    /\ PlatformKeep.plat_still lp m'.

  (* seg_render: the render step on Mario's node (2026-10-22,
     rendering_graph_node.c linked as TU 35).  geo_process_object calls the
     real geo_set_animation_globals on &marioObj->header.gfx.animInfo
     (RenderFlank.render_call), which advances Mario's animFrame through
     graph_node.c's geo_update_animation_frame.  The left disjunct is a frame
     where Mario's node is not drawn.  GOAL 1's mem_ok carry through it is
     PROVED from its walked footprint (RenderFlank.render_mem_ok,
     discharging Hrender_ok below), and so is the Phi carry (2026-10-23,
     RenderKeep.render_keeps_phiw, discharging Hrender_phi below).  It is no
     longer an assumed carry; what the step states instead is narrower
     (RenderKeep.render_surf_apart, labeled trust): Mario's wall / ceiling /
     floor surfaces are not in one of the six gCurrAnim* globals' blocks the
     call writes.  In the game they are surface-pool surfaces; the frame
     world keeps them off the walk's regions but not off every global. *)
  Definition seg_render_spec (m m' : mem) : Prop :=
    m' = m \/ (RenderFlank.render_call lp bm m m' /\ RenderKeep.render_surf_apart lp bm m).

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
  (* The non-Mario tail is rest (object updates, then the render walk up
     to Mario's node) ; Mario's render call ; rest (the remaining walk). *)
  Definition mario_frame_step (i m m' : mem) : Prop :=
    exists m1 m2 m3 m4 m5,
      seg_input_spec m i
      /\ seg_platform_spec i m1
      /\ execute_mario_action_step_lp lp m1 m2
      /\ seg_level_spec m2 m3
      /\ seg_rest_spec m3 m4
      /\ seg_render_spec m4 m5
      /\ seg_rest_spec m5 m'
      /\ in_wmotr m'.

  (* A frame that updates Mario ZERO times (2026-10-24): a paused frame
     (play_mode_paused: no object update), a change-level frame, a frame in
     time stop with TIME_STOP_MARIO_AND_DOORS (update_objects skips Mario;
     apply_mario_platform_displacement returns early while time stop is
     active, but may still be called).  The poll runs; then either nothing
     else changes memory, or the flanks run (an optional platform call, the
     level phase, the object / render tail) with no execute_mario_action.
     Before this, a real no-A run that paused was not a frame_step run, so
     the capstone said nothing about it. *)
  Definition idle_frame_step (i m m' : mem) : Prop :=
    seg_input_spec m i
    /\ (m' = i
        \/ exists m1 m3 m4 m5,
             (m1 = i \/ seg_platform_spec i m1)
             /\ seg_level_spec m1 m3
             /\ seg_rest_spec m3 m4
             /\ seg_render_spec m4 m5
             /\ seg_rest_spec m5 m'
             /\ in_wmotr m').

  Definition frame_step (i m m' : mem) : Prop :=
    mario_frame_step i m m' \/ idle_frame_step i m m'.

  Variable YMAX : R.

  Definition y_le (m : mem) : Prop :=
    forall v, Mem.load Mfloat32 m bm POSY = Some (Vsingle v) ->
              (B2R _ _ v <= YMAX)%R.

  (* ---- the rows ------------------------------------------------------- *)

  (* GOAL 1's frame (discharged in the twelve-TU section below by
     frame_ok_linked12 -- NOT open). *)
  Hypothesis Hframe_action :
    forall m m', mem_ok m -> execute_mario_action_step_lp lp m m' -> mem_ok m'.

  (* the render call carries GOAL 1's mem_ok (discharged in the twelve-TU
     section below by RenderFlank.render_mem_ok -- NOT open). *)
  Hypothesis Hrender_ok :
    forall m m', mem_ok m -> RenderFlank.render_call lp bm m m' -> mem_ok m'.

  (* the render call carries Phi, given the step's surface premise
     (discharged in the twelve-TU section below by
     RenderKeep.render_keeps_phiw -- NOT open). *)
  Hypothesis Hrender_phi :
    forall m m', Phi m -> RenderFlank.render_call lp bm m m' ->
                 RenderKeep.render_surf_apart lp bm m -> Phi m'.

  (* the platform step carries mem_ok, the A-held bit and Phi (discharged
     in the twelve-TU section below by PlatformKeep -- NOT open). *)
  Hypothesis Hplat_ok :
    forall m m', mem_ok m -> PlatformKeep.plat_still lp m -> seg_platform_spec m m' -> mem_ok m'.
  Hypothesis Hplat_ad :
    forall m m', mem_ok m -> PlatformKeep.plat_still lp m -> seg_platform_spec m m' ->
                 a_down_real bm m' = a_down_real bm m.
  Hypothesis Hplat_phi :
    forall m m', Phi m -> PlatformKeep.plat_still lp m -> seg_platform_spec m m' -> Phi m'.

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

  (* a seg_rest phase carries mem_ok *)
  Lemma rest_ok : forall m m', seg_rest_spec m m' -> mem_ok m -> mem_ok m'.
  Proof.
    intros m m' (_ & Har & Hvr & (Hmr & _) & _) (Hv & Hs & Hm).
    split; [ exact (Hvr Hv) | split ].
    - exact (action_sat_load_eq_or_val not_tainted ACT_READING_NPC_DIALOG
               m m' Har dialog_action_not_tainted Hs).
    - exact (Hmr Hm).
  Qed.

  (* ===================================================================== *)
  (* 3. ONE FRAME: an A-free frame preserves mem_ok AND Phi (and, at the    *)
  (*    frame boundary, the platform fact PlatformKeep.plat_still).          *)
  (* ===================================================================== *)
  Definition fb_ok (m : mem) : Prop :=
    mem_ok m /\ Phi m /\ PlatformKeep.plat_still lp m.

  (* the poll: an A-free poll keeps the boundary facts, and A is not held *)
  Lemma input_ok : forall i m,
      a_used_real bm i = false -> fb_ok m -> seg_input_spec m i ->
      fb_ok i /\ a_down_real bm i = false.
  Proof.
    intros i m HU (Hok & Hphi & Hst) (_ & Hai & Hvi & Hmi & Hpi & Hsti).
    destruct (a_used_real_false bm i HU) as (HA & HD).
    exact (conj (conj (inert_flank m i Hai Hvi (Hmi HA) Hok) (conj (Hpi Hphi) (Hsti Hst))) HD).
  Qed.

  (* the platform call *)
  Lemma platform_ok : forall i m1,
      fb_ok i -> a_down_real bm i = false -> seg_platform_spec i m1 ->
      mem_ok m1 /\ Phi m1 /\ a_down_real bm m1 = false.
  Proof.
    intros i m1 (Hok0 & Hphi0 & Hst0) HD Hplat.
    split; [ exact (Hplat_ok i m1 Hok0 Hst0 Hplat) | split ].
    - exact (Hplat_phi i m1 Hphi0 Hst0 Hplat).
    - rewrite (Hplat_ad i m1 Hok0 Hst0 Hplat). exact HD.
  Qed.

  (* the tail: level phase, rest, Mario's render call, rest *)
  Lemma tail_ok : forall m2 m3 m4 m5 m',
      mem_ok m2 -> Phi m2 ->
      seg_level_spec m2 m3 -> seg_rest_spec m3 m4 -> seg_render_spec m4 m5 ->
      seg_rest_spec m5 m' -> fb_ok m'.
  Proof.
    intros m2 m3 m4 m5 m' (Hv2 & Hs2 & Hm2) Hphi2 Hlvl Hrest Hrnd Hrest2.
    destruct Hlvl as (Hact3 & Hml & Hpl).
    assert (Hv3 : Mem.valid_block m3 bm)
      by (eapply Mem.valid_block_unchanged_on; eauto).
    assert (Hs3 : action_sat not_tainted m3 bm)
      by (eapply action_sat_unchanged_on; [ exact Hact3 | exact Hv2 | exact Hs2 ]).
    pose proof (Hpl Hphi2) as Hphi3.
    assert (Hok3 : mem_ok m3) by exact (conj Hv3 (conj Hs3 (Hml Hm2))).
    (* rest, Mario's render call, rest *)
    pose proof (rest_ok m3 m4 Hrest Hok3) as Hok4.
    pose proof (proj2 (proj1 (proj2 (proj2 (proj2 Hrest)))) Hphi3) as Hphi4.
    assert (Hok5 : mem_ok m5 /\ Phi m5)
      by (destruct Hrnd as [-> | (Hrc & Hsa)];
          [ exact (conj Hok4 Hphi4)
          | exact (conj (Hrender_ok m4 m5 Hok4 Hrc) (Hrender_phi m4 m5 Hphi4 Hrc Hsa)) ]).
    destruct Hok5 as (Hok5 & Hphi5).
    split; [ | split ].
    - exact (rest_ok m5 m' Hrest2 Hok5).
    - exact (proj2 (proj1 (proj2 (proj2 (proj2 Hrest2)))) Hphi5).
    - exact (proj2 (proj2 (proj2 (proj2 Hrest2)))).
  Qed.

  Theorem frame_step_ok :
    forall i m m',
      a_used_real bm i = false ->
      fb_ok m ->
      frame_step i m m' ->
      fb_ok m'.
  Proof.
    intros i m m' HU Hfb [ (m1 & m2 & m3 & m4 & m5 & Hin & Hplat & Hact & Hlvl & Hrest & Hrnd & Hrest2 & _)
                         | (Hin & [ -> | (m1 & m3 & m4 & m5 & Hpl & Hlvl & Hrest & Hrnd & Hrest2 & _) ]) ].
    - (* a frame with Mario's update *)
      destruct (input_ok i m HU Hfb Hin) as (Hfi & HD).
      destruct (platform_ok i m1 Hfi HD Hplat) as (Hok1 & Hphi1 & HD1).
      (* the Mario action: GOAL 1's frame + the crux *)
      pose proof (Hseg_action_phi m1 m2 Hok1 Hphi1 HD1 Hact) as Hphi2.
      pose proof (Hframe_action m1 m2 Hok1 Hact) as Hok2.
      exact (tail_ok m2 m3 m4 m5 m' Hok2 Hphi2 Hlvl Hrest Hrnd Hrest2).
    - (* an idle frame: only the poll *)
      exact (proj1 (input_ok i m HU Hfb Hin)).
    - (* an idle frame: the flanks, no Mario update *)
      destruct (input_ok i m HU Hfb Hin) as (Hfi & HD).
      assert (H1 : mem_ok m1 /\ Phi m1).
      { destruct Hpl as [ <- | Hplat ].
        - exact (conj (proj1 Hfi) (proj1 (proj2 Hfi))).
        - destruct (platform_ok i m1 Hfi HD Hplat) as (A & B & _). exact (conj A B). }
      exact (tail_ok m1 m3 m4 m5 m' (proj1 H1) (proj2 H1) Hlvl Hrest Hrnd Hrest2).
  Qed.

  (* ===================================================================== *)
  (* 4. THE RUN: a no-A run keeps y <= YMAX (and GOAL 1's invariant).       *)
  (* ===================================================================== *)
  Theorem noA_run_height_bound :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok init -> Phi init -> PlatformKeep.plat_still lp init ->
      Forall (fun i => a_used_real bm i = false) is ->
      reachable mem mem frame_step init is m ->
      mem_ok m /\ y_le m.
  Proof.
    intros init is m Hok Hphi Hst HA Hr.
    destruct (reachable_preserves_Phi mem mem (a_used_real bm) frame_step fb_ok
                (fun i s s' Ha Hs Hst => frame_step_ok i s s' Ha Hs Hst)
                init is m Hr (conj Hok (conj Hphi Hst)) HA) as (Hok' & Hphi' & _).
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
     HSafeB_syms (SpawnInit.SafeB_syms_ok): on the linked symbol table SafeB
     avoids SpawnInit.non_safeb_syms (gMarioStates, gControllers, gMarioState,
     gGlobalTimer, the handler / knockback tables, the stored globals) and
     contains sFloorAlignMatrix.  REPAIRED 2026-10-19: it was an iff pinning
     the symbol part to {sFloorAlignMatrix}, which made MWF false of every real
     post-init memory (init_mario_from_save_file stores &gMarioAnimsBuf,
     &gBodyStates[0], &gPlayerCameraState[0] into chase roots; objects point at
     behavior scripts).  Non-vacuous via SpawnInit.safeb_wit_sat. *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
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
  (* the dst-gated writer rows (dg): see NoAImpliesNoFlyLinked *)
  (* Hscp_mtxf_real: PROVED inside NoAImpliesNoFlyTwelve from the real
     mtxf_align_terrain_triangle body (MtxfBody), on Hsqrtf below. *)
  (* Hcsp_omfd_real / Hcsp_scale_real / Hcsp_osh_real: PROVED inside
     NoAImpliesNoFlyTwelve from the real object_helpers.c bodies
     (ObjHelpersBodies), no longer rows. *)
  (* Hcsp_scm_real (set_camera_mode's arg0-gated call row) is DERIVED in
     NoAImpliesNoFlyTwelve from Hscm_body_real (2026-10-22): the call
     resolves to the real camera.c body and cs_gate's arg0 gate is wgate's
     T_scm arm.  No longer a row here.
     set_camera_mode reached from mario.c is a pinned rest case; its gated
     body row Hscm_body_real is PROVED in NoAImpliesNoFlyTwelve from the
     real camera.c body (CameraModeBody, 2026-10-23).  No longer a row. *)
  (* THE ONE OPEN AUDIO PREMISE of GOAL 1's surface (labeled, TRUST 4.1; the
     audio link, 2026-10-23): load_sequence (audio/load.c, not linked) keeps
     the carried facts.  GOAL 1's audio rows (Hpres_sta_ext, Hsss, the audio
     entries of the obj / cut / warp / floors lists) are PROVED from the real
     audio/external.c and sound_init.c bodies (AudioBodies). *)
  Hypothesis Hls :
    call_pres_ext lp bm (NoA_real bm) MWF audio_external._load_sequence.
  (* load_patchable_table: PROVED from its real memory.c body and dma_read's
     (LptBody), down to the libultra DMA calls, whose effect is the
     hardware/OS floor spec (OsDmaFloor, TRUST 3.5). *)
  Hypothesis Hdma_floor : OsDmaFloor.os_dma_floor.
  Lemma Hsma_real :
    DispatchKit.call_pres lp bm (NoA_real bm) MWF mario._set_mario_animation.
  Proof.
    exact (LptBody.sma_row_linked12 lp bm bc oc0 SafeB H12 HSafeB_syms
             (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) Hdma_floor).
  Qed.
  Lemma Hsmawa_real :
    ActWriterSurface.call_pres_np3 lp bm (NoA_real bm) MWF mario._set_mario_anim_with_accel.
  Proof.
    exact (LptBody.smawa_row_linked12 lp bm bc oc0 SafeB H12 HSafeB_syms
             (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) Hdma_floor).
  Qed.
  (* WL_exempt: PROVED 2026-10-22 (was a row, FALSE as stated: GOAL 1's
     WLExempt.wl_exempt_old_refuted); GOAL 1's export no longer takes it. *)
  (* Hpres_sta_ext and Hsss: PROVED 2026-10-23 (AudioBodies), no longer rows. *)
  (* memory.c's segment converters and the seven linked save_file.c /
     bhv_spawn_star entries are PROVED (NoAImpliesNoFlyTwelve.obj_ext_open_of2) *)
  (* Hpres_obj_ext_open2: GONE 2026-10-23 (random_float is walked since
     behavior_script.c joined the link, MenuBodies) *)
  (* Hpres_cut_ext_open2: GONE 2026-10-23 -- every any-argument cutscene
     entry is a linked body, walked (NoAImpliesNoFlyTwelve.cut_ext_open_of2;
     the seven ingame_menu.c entries in MenuBodies) *)
  (* Hgeo_real / Hocp_rai_real: PROVED inside NoAImpliesNoFlyTwelve from the
     real graph_node.c bodies (GraphNodeBodies), no longer rows. *)
  (* Hpres_floors_ext_open: GONE 2026-10-23 (raise_background_noise by
     AudioBodies; spawn_default_star by SpawnStarBody, obj_behaviors.c linked) *)
  (* Hcp_savefile_real: PROVED inside NoAImpliesNoFlyTwelve from the real
     save_file.c body (SaveFileBody), no longer a row. *)
  (* Hpres_warp_ext_open: GONE 2026-10-23 -- its list was empty since the
     audio link (NoAImpliesNoFlyTwelve.warp_ext_open_nil) *)
  (* Hret_unsafe REMOVED (task #99): the v2 engine no longer consumes any
     return-value row (it was dead plumbing / a latent vacuity -- see
     NoAImpliesNoFlyLinked). *)
  (* 2026-10-23 (the print link): the two print_text_fmt_int engine rows
     (Hext_action_ptfi / Hmwf_ext_ptfi) are GONE: print.c is linked and the
     body is proved (NoAImpliesNoFlyTwelve.Hptfi_body_real, PrintBodies). *)

  (* ---- GOAL 2's own rows.  Phi is CONCRETE (HeightInvariant.v): the height
     budget over real MarioState cells (+ gfx.pos[1]), K = 2424, A = 372.
     Hphi_y is a THEOREM (height_invariant_y).  The old crux row
     Hseg_action_phi ("one real execute_mario_action keeps Phi") is now a
     LEMMA (seg_action_phi below), from: the budget arithmetic of every
     move, PROVED (HeightMoveCatalog.chain_keeps_budget), the WMotR level data,
     PROVED (WMotRLevel.v), and
     two rows about what the real frame does. ---- *)
  (* R_noA is CONCRETE: the census whitelist (NoAActions.v, 73 actions) *)
  (* The run carries the height invariant AND the WMotR world invariant
     (WMotRWorld.v): without the world the rows below are false over
     phantom worlds (a BURNING floor, a quicksand depth, a held object). *)
  (* The animation DMA buffer stays off the world (2026-10-19).  Every frame
     that changes Mario's animation DMAs into gMarioAnimsBuf.bufTarget
     (set_mario_animation -> load_patchable_table -> dma_read).  GOAL 1's MWF
     carries the Mario half (R13: the buffer is not the block of m->marioObj,
     so not gfx.pos[1] -- and in the real game not any object, all of which
     live in gObjectPool).  This is the world half: the buffer is not the
     block of the wall / ceiling / floor surface or of a collided object, so
     the DMA cannot rewrite a surface type or a pole's oPosY.  In the game the
     buffer is its own main_pool_alloc (game_init.c:627), apart from
     sSurfacePool and gObjectPool.  Without it the two frame rows below were
     FALSE over memories where the buffer aliases those blocks. *)
  (* anim_apart now lives in FrameSplit (anim_apart lp bm).  Mario's
     object stays off the world too (FrameSplit.mobj_apart, 2026-10-20):
     no surface lives in its block and a collided object is Mario's own or a
     whole Object away -- needed for the frame's own two stores to Mario's
     object (gfx flags, oInteractStatus), which FrameSplit PROVES.
     FOUND 2026-10-21: m->usedObj was unconstrained, so a HOLDING_POLE
     memory whose usedObj is a HIGH pole met every premise and
     set_pole_position put Mario above YMAX (same for IN_CANNON's seat).
     used_ok (WMotRWorld) carries: in a pole action usedObj is a low WMotR
     pole apart from Mario's object and vel[1] <= 0; in IN_CANNON it is a
     cannon base.  Outside those actions it says nothing. *)
  Definition PhiW (m : mem) : Prop :=
    height_invariant bm R_noA m /\ wmotr_world bm m /\ anim_apart lp bm m /\ mobj_apart bm m
    /\ ffw (lp_ge lp) bm m /\ used_ok bm m
    (* the animation world (AnimWorld, 2026-10-23): the DMA table, gMarioAnims,
       the buffer, and in a pole action after the grab the animation state --
       what the real set_mario_animation reads on the pole *)
    /\ AnimWorld.anim_w (lp_ge lp) bm m
    (* the level cells (FfWorld.lvl_w, 2026-10-23): gCurrLevelNum = WMotR
       and sPlayingInfiniteStairs = 0 -- what play_infinite_stairs_music
       reads *)
    /\ lvl_w (lp_ge lp) m.
  Notation Phi := PhiW.

  (* LEVEL DATA -- now DEFINED from generated/ and PROVED (WMotRLevel.v):
     wmotr_floor / wmotr_pole / wmotr_cannon are read off WMotR's
     clightgen'd terrain, macro objects, level script and behavior scripts;
     no floor height lies in the moat (K, K + 622), every pole is low or out
     of reach, and both cannons seat Mario below K.  What remains
     trusted about them (find_floor returns heights of exactly these
     surfaces; which behaviors load collision) is TRUST.md 0.8 and lives
     in Hframe_is_move_chain, whose MoveChain mentions them. *)

  (* ---- THE FRAME ROWS, split at execute_mario_action's calls (2026-10-20).
     They used to be three whole-frame rows (Hframe_stays_noA,
     Hframe_keeps_world, Hframe_is_move_chain).  FrameSplit reads the real
     body (FrameCalls.cl over generated/mario.v: 17 `f(gMarioState)` calls,
     5 other calls, 2 stores to Mario's object) and PROVES the frame from:
       - GOAL 1's per-call mem_ok (frame_call_ok_linked12),
       - the two stores (gfx flags, oInteractStatus = 0), proved,
       - one row per call: the call keeps the frame world (FrameSplit.fworld:
         action in R_noA, the WMotR world, anim_apart, mobj_apart, A not
         held) and moves Phi's cells by a MoveChain.
     The rows are what the value walk discharges call by call (the airborne
     dispatcher first: act_freefall is FfRun.ff_move).

     OPEN (the action arm) inside each row: GOAL 1's engine at Qv := R_noA;
     target list docs/goal2-rnoa-census.md.  The A-not-held premise is
     load-bearing: with A held act_punching / act_move_punching enter
     ACT_JUMP_KICK (mario_actions_object.c:156, _moving.c:845), not in the
     whitelist.
     OPEN (the value walk): each call's effect on Phi's cells is a chain of
     HeightMoveCatalog moves.  Moves NOT modelled, so a row is false if they
     fire: hanging (A-gated), water, wind, shells, objects that grab or
     throw (absent in WMotR; E1/E3).
     OPEN (the world): every surface a call stores into m->wall/ceil/floor
     comes from WMotR's surfaces; nothing picks up or rides an object; the
     anim DMA stays in its own buffer.  Tethered by the write watch (TRUST.md
     5.4). ---- *)
  (* the f(gMarioState) calls other than the airborne dispatcher, STAGED
     (2026-10-21, FrameSplit.frame_stage): the dispatch's floor refresh is
     threaded through the body in order.  update_mario_inputs leaves the
     floor fresh (FfWorld.fresh: floorHeight is -11000 or a WMotR floor
     height within 241 of Mario's y); mario_handle_special_floors and
     mario_process_interactions keep it; each dispatcher, called with the
     floor fresh when the action is airborne (fresh_at), returns 0 (the
     loop ends) or leaves it fresh-when-airborne (the loop goes on with no
     new refresh).  These are claims of the rows (pre_of / post_of).
     Since 2026-10-21 BOTH dispatchers are apart (AutoSplit.
     seg_call_rows_naFA): the automatic dispatcher's row is PROVED
     (AutoSplit.aut_seg) from its prologue (Hair_pro), the store
     m->quicksandDepth = 0 (proved to keep mem_ok, the frame world, Phi's
     cells and fresh_at) and the per-case rows Hauto_case below.
     Since 2026-10-23 the row is SPLIT PER CALL (NaSplit.naFA_of_open):
     NaSplit.ema_calls_eq lists the 15 calls it covered; the ones in
     NaSplit.na_open stay assumed here, the others are PROVED from the
     generated bodies (NaSplit: set_submerged_cam_preset_and_spawn_bubbles,
     memory unchanged under R_noA; mario_execute_submerged_action, vacuous
     since each dispatcher's row now assumes the action is in its own
     group, FrameSplit.grp_ok, proved at the real switch; update_mario_health;
     since 2026-10-24 mario_reset_bodystate and update_mario_info_for_cam,
     with m->marioBodyState pinned to &gBodyStates[0] in FfWorld.ffw). *)
  Hypothesis Hseg_na_open : na_open_rows lp bm MWF.
  (* the body's other calls, PATH-SENSITIVE since 2026-10-23 (FrameSplit.clw):
     only play_infinite_stairs_music() (unlinked, no arguments) is left
     (FrameSplit.ema_live_anys, computed).  FOUND (phantom forall): the row
     used to cover the linked spawn_wind_particles with ANY arguments from
     ANY fworld memory; its spawn_object pops gFreeObjectList, which fworld
     does not constrain, so a free-list head at the pole in usedObj let one
     call overwrite the pole's oPosY -- FALSE as stated.  Both wind blocks
     sit under `m->floor->type == 44 / 56` and wmotr_world's floor type is
     one of WMotR's ([5;10;21;55;0]): FrameSplit.guard_mem PROVES them dead
     (memory unchanged), so their four calls (spawn_wind_particles,
     play_sound, twice) carry no row. *)
  (* PROVED since 2026-10-23 (ProRows.seg_any_rows_proved): the real
     play_infinite_stairs_music, linked, only READS memory under lvl_w
     (gCurrLevelNum = LEVEL_WMOTR is not LEVEL_CASTLE, so shouldPlay = 0,
     and sPlayingInfiniteStairs = 0 already).  FOUND (phantom forall): the
     row quantified over every fworld memory, including ones with
     sPlayingInfiniteStairs = 1 (or the castle level), where the call
     stores the flag and enters the sequence player -- FALSE as stated.
     lvl_w is now carried by fworld and PhiW (from boot: StartSat). *)
  (* the airborne dispatcher, split per case (AirSplit, 2026-10-20): its two
     prologue calls, and each no-A action's handler called with the action
     cell = its label (11 cases: freefall, dive, the two air knockbacks, soft
     bonk, air-hit-wall, the two rollouts, butt-slide air, ground pound,
     slide kick).  The other 30 cases are dead under action_sat R_noA. *)
  (* the prologue keeps fresh_at (AirSplit.air_pro_rows); since 2026-10-21
     it also covers the automatic dispatcher's prologue call,
     check_common_automatic_cancels (same shape of claim) *)
  (* PROVED since 2026-10-23 (ProRows.air_pro_rows_proved): the real
     check_common_airborne_cancels / check_common_automatic_cancels (the
     water-plunge, squish and vertical-wind tests are false; then
     quicksandDepth = 0) and play_far_fall_sound (it writes only m->flags
     and play_sound's two queue globals).  FOUND (phantom forall): fresh_at
     did not pin m->waterLevel or INPUT_SQUISHED, so a memory with the
     water above Mario sent the cancels to ACT_WATER_PLUNGE (not in R_noA)
     -- FALSE as stated.  fresh / fresh_at now carry FfWorld.inputs_ok
     (waterLevel = -11000, no squish bit), which update_mario_inputs leaves
     and every row keeps. *)
  (* the automatic dispatcher, split per case (AutoSplit, 2026-10-21): each
     no-A action's handler called with the action cell = its label and the
     floor fresh, returning FALSE or leaving the floor fresh.  12 live cases
     (computed, AutoSplit.aut_case_list_eq): the six pole actions
     (GRAB_POLE_SLOW / FAST, CLIMBING_POLE, TOP_OF_POLE_TRANSITION,
     TOP_OF_POLE, HOLDING_POLE), the five ledge cases (LEDGE_GRAB,
     LEDGE_CLIMB_SLOW_1 / 2, LEDGE_CLIMB_DOWN, LEDGE_CLIMB_FAST) and
     IN_CANNON.  The other 5 cases (3 hangs, GRABBED, TORNADO_TWIRLING) are
     dead under action_sat R_noA.  A NEW hypothesis (27 -> 28) that is
     strictly narrower than what it replaces: the automatic dispatcher's
     whole row used to sit inside Hseg_call_na; now its prologue and store
     are proved and only these 12 handler calls stay assumed.
     Since 2026-10-22 GRAB_POLE_SLOW and GRAB_POLE_FAST are PROVED (PoleRow.
     pole_row: the real act_grab_pole_slow / _fast walked on the link,
     every outcome a RangedMove keeping the frame world and usedObj's pole
     facts); LEDGE_GRAB and LEDGE_CLIMB_DOWN are PROVED (LedgeRow.
     ledge_row: the real act_ledge_grab / _climb_down walked on the link,
     every outcome a RangedMove keeping the frame world, returning FALSE
     with the cells kept or letting go of the ledge into SOFT_BONK with
     the floor still fresh, FfWorld.fresh's slack); HOLDING_POLE is
     PROVED (PoleHold.holdcheck12; set_sound_moving_speed is its real
     body since 2026-10-23, SndXc).  Since 2026-10-22 LEDGE_CLIMB_SLOW_1 /
     _2 and LEDGE_CLIMB_FAST are PROVED (LedgeRow.aut_case_rest_ledge_climb:
     the real act_ledge_climb_slow / _fast walked on the link; their
     update_ledge_climb_camera stores land in the now-real
     gPlayerCameraState, the frame world's statusForCamera conjunct).
     Since 2026-10-22 IN_CANNON and CLIMBING_POLE are PROVED (CannonRow.
     aut_case_rest_climb_top: the real act_in_cannon walked once per WMotR
     cannon, Mario staying seated at y or at the seat oPosY + 350, with
     used_ok's cannon clause placing usedObj (cannon_pos_ok); the real
     act_climbing_pole walked with the pole kit, its climb polePos +
     stickY / 8.0f made finite by the path's find_ceil cast).
     Since 2026-10-23 ALL TWELVE cases are PROVED (PoleCasesT.
     aut_case_rows_T): the six pole actions are re-walked with Mario's REAL
     animation data (PoleRunT: set_mario_animation inline, the DMA table and
     gMarioAnims read, return_mario_anim_y_translation walked per frame), so
     TOP_OF_POLE_TRANSITION and TOP_OF_POLE -- whose set_pole_position adds
     the handstand animation's y translation -- are proved too; the frame
     world carries the animation state (AnimWorld.anim_w, in Phi / fworld)
     that those walks start from.  The premise this needs is below. *)
  (* TRUST 0.8(f), APPROVED: the PI DMA copies the ROM bytes of
     gMarioAnims into the animation buffer (OsDmaFloor.pi_dma_anim_spec;
     it replaced the hypothesis Hauto_rest, the two top-of-pole cases) *)
  Hypothesis Hdma_anim : OsDmaFloor.pi_dma_anim_spec.
  (* (find_ceil's height: formerly the open premise Hceil, which was FALSE
     as stated -- it allowed a dangling *pceil; now PROVED,
     CeilHeight.fc_height, from the walker's live-local pceil) *)
  (* the freefall case (FfRow, 2026-10-20): PROVED from the real
     act_freefall (FfRow.ff_row: the call keeps the frame world and moves
     Phi's cells by a MoveChain, from FfWorld.ffw, which PhiW / fworld
     carry).  The air-hit-wall case (AhwRow, 2026-10-20): PROVED from the
     real act_air_hit_wall (AhwRow.ahw_row: no A, so no wall kick; it stays,
     or bonks / knocks back with Phi's cells kept).  The soft-bonk and
     both air-knockback cases (KbRow, 2026-10-20): PROVED from the real
     handlers (common_air_knockback_step: an air step, a landing, or a wall
     bonk keeping the action).  The ground-pound case (GpRun, 2026-10-20):
     PROVED from the real act_ground_pound (the windup rise, or the fall's
     air step and its landing / wall).  The dive case (KbDv, 2026-10-20):
     PROVED from the real act_dive (the same air-step summary).  Both
     rollouts (RlRun, 2026-10-20): PROVED from the real handlers (the launch,
     then the air step).  Butt-slide air (BsRun, 2026-10-21): PROVED from
     the real act_butt_slide_air at ANY state (the bounce's stale
     floorHeight is refreshed by update_mario_inputs before the next
     dispatch; the case gets the fresh floor from frame_stage).  Slide kick
     (SkRun, 2026-10-21): PROVED from the real act_slide_kick at ANY state
     (the timer tick, then the FREEFALL gate or the air step at gravity 2:
     a landing, the bounce, a wall; past the bounce the step is
     S_sk_bounced, its vel gravity's exactly, AirMatch.vel_exc).  Every
     proved case also returns FALSE or leaves y / floorHeight untouched
     (RetOk.ret_ok, checked on each walk), so the floor stays fresh.  No
     other no-A case is left (KbRow.air_case_fns_in, computed). *)
  (* the walk's floor: the FPU floor (TRUST 3.5).  The audio premise
     Haudio is gone since 2026-10-23: play_sound and set_sound_moving_speed
     are the real audio/external.c bodies (SndXc). *)
  Hypothesis Hsqrtf : sqrtf_spec.
  Hypothesis Hsqrtf_float : sqrtf_float.

  (* ---- update_camera(gCurrentArea->camera) (camera.c:3011), for the
     level phase's camera call: the REAL call keeps GOAL 1's carried facts
     (UpdateCameraBody: 506 walked bodies, the CameraEvent / transition
     tables by type certificate).  Its two premises are used ONLY by
     update_camera_ok_linked12, not by the capstone below. ---- *)
  (* LABELED (TRUST 4.1, hud.c not linked): set_hud_camera_status changes
     no linked memory (its body stores the hud.c static sCameraHUDStatus) *)
  Hypothesis Hhud_memid : forall b fd m vargs t m' vres,
      Genv.find_symbol (lp_ge lp) camera._set_hud_camera_status = Some b ->
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres -> m' = m.
  (* OPEN ROW (linked body, not yet walked): set_mario_npc_dialog
     (mario_actions_cutscene.c:345), reached from the dialog cutscenes *)
  Hypothesis Hnpc_pres :
    ObjExtBodies.sym_pres lp bm bc oc0 SafeB mario_actions_cutscene._set_mario_npc_dialog.

  Lemma update_camera_ok_linked12 : forall b fd m c t m' vres,
      Genv.find_symbol (lp_ge lp) camera._update_camera = Some b ->
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 (lp_ge lp) m fd [c] t m' vres ->
      (forall bb oo, c = Vptr bb oo -> SafeB bb) ->
      mem_ok_lp bm MWF m -> mem_ok_lp bm MWF m'.
  Proof.
    intros b fd m c t m' vres Hs Hff Hev Hc Hok.
    exact (UpdateCameraBody.update_camera_pres lp H12 bm bc oc0 SafeB HSafeB_syms
             (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0)
             Hsqrtf Hdma_floor Hls Hhud_memid Hnpc_pres b fd m c t m' vres Hs Hff Hev Hc Hok).
  Qed.

  (* the automatic dispatcher's cases: all twelve proved *)
  Lemma Hauto_case : aut_case_rows lp bm MWF.
  Proof.
    exact (PoleCasesT.aut_case_rows_T lp H12 Hdma_floor Hdma_anim bm Hbm_sym MWF).
  Qed.

  Lemma Hair_case : air_case_rows lp bm MWF.
  Proof.
    exact (air_case_rows_ff8 lp H12 Hdma_floor Hsqrtf Hsqrtf_float bm Hbm_sym MWF).
  Qed.

  Lemma call_facts :
    (forall m m', mem_ok_lp bm MWF m -> execute_mario_action_step_lp lp m m' ->
                  mem_ok_lp bm MWF m')
    /\ reach_value_preserves_reached_g not_tainted bm (lp_ge lp) (NoA_real bm) MWF
         (call_gate bm SafeB) (reached_v2 lp)
    /\ (forall m, MWF m -> gms_cond_lp lp m bm)
    /\ chase_safe_stmt bm SafeB MWF /\ store_safe_stmt lp bm SafeB MWF.
  Proof.
    exact (frame_call_ok_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0
             Hsqrtf Hls Hdma_floor).
  Qed.

  Lemma air_leaves :
    forall fid f, mem_id fid AirborneSurface.airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof.
    exact (air_leaves_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0
             Hsqrtf Hls Hdma_floor).
  Qed.

  Lemma auto_leaves :
    forall fid f, mem_id fid AutomaticSurface.automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof.
    exact (auto_leaves_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0
             Hsqrtf Hls Hdma_floor).
  Qed.

  (* the per-call row, from NaSplit *)
  Lemma Hseg_call_na : seg_call_rows_naFA lp bm MWF.
  Proof.
    destruct call_facts as (_ & _ & Hgms & _).
    exact (naFA_of_open lp H12 bm MWF Hgms Hseg_na_open).
  Qed.

  (* the automatic dispatcher's row, from AutoSplit *)
  Lemma Hseg_call_naF : seg_call_rows_naF lp bm MWF.
  Proof.
    destruct call_facts as (_ & _ & Hgms & _).
    exact (seg_call_rows_naF_of_auto lp (linked12_LO_mario lp H12) (linked12_LO_aut lp H12) bm MWF
             (fun m0 HM => mwf_real_ctl lp bm bc oc0 SafeB m0 HM)
             (mwf_window_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0)
             auto_leaves Hgms Hseg_call_na (air_pro_rows_proved lp H12 bm MWF) Hauto_case).
  Qed.

  Lemma Hseg_call : seg_call_rows_fr lp bm MWF.
  Proof.
    destruct call_facts as (_ & _ & Hgms & _).
    exact (seg_call_rows_of_air lp (linked12_LO_mario lp H12) (linked12_LO_air lp H12) bm MWF
             (fun m0 HM => mwf_real_ctl lp bm bc oc0 SafeB m0 HM) air_leaves Hgms
             Hseg_call_naF (air_pro_rows_proved lp H12 bm MWF) Hair_case).
  Qed.

  Lemma frame_FS : forall c0 m m',
    budget_ok c0 -> FS lp bm MWF c0 m -> execute_mario_action_step_lp lp m m' ->
    FS lp bm MWF c0 m'.
  Proof.
    intros c0 m m' Hb HF (b_o & t & res & Hev).
    destruct call_facts as (_ & Hcall & Hgms & Hchase & Hstore).
    refine (frame_stage lp (linked12_LO_mario lp H12) bm SafeB MWF Hcall Hgms
              (fun m0 HM => mwf_real_ctl lp bm bc oc0 SafeB m0 HM)
              Hchase Hstore
              (safeb_of_nonfam_sym lp SafeB HSafeB_syms _ _ Hbm_sym eq_refl)
              (fun ab Hab => safeb_of_nonfam_sym lp SafeB HSafeB_syms _ _ Hab eq_refl)
              _ c0 m _ t m' res Hseg_call (seg_any_rows_proved lp H12 bm MWF) Hb HF Hev).
    intros m0 bc' oc HM Hl.
    destruct HM as (_ & _ & R2 & _). destruct (R2 _ _ Hl) as [-> _].
    exact (safeb_of_nonfam_sym lp SafeB HSafeB_syms _ _ Hbc_sym eq_refl).
  Qed.

  Lemma frame_FS_start : forall m c,
    mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
    read_cells bm m c -> FS lp bm MWF c m.
  Proof.
    intros m c Hok ((Ha & _) & Hw & Han & Hmo & Hf & Hu & Haw & Hl) HD Hc.
    split; [exact Hok |].
    split; [exact (conj Ha (conj Hw (conj Han (conj Hmo (conj HD (conj Hf (conj Hu (conj Haw Hl)))))))) |].
    exists c. split; [exact Hc | apply Relation_Operators.rt_refl].
  Qed.

  (* the three old whole-frame rows, now LEMMAS *)
  Lemma Hframe_stays_noA :
    forall m m', mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                 execute_mario_action_step_lp lp m m' -> action_sat R_noA m' bm.
  Proof.
    intros m m' Hok Hphi HD Hst. pose proof Hphi as ((_ & c & Hc & Hb) & _).
    destruct (frame_FS c m m' Hb (frame_FS_start m c Hok Hphi HD Hc) Hst) as (_ & (Ha & _) & _).
    exact Ha.
  Qed.

  Lemma Hframe_keeps_world :
    forall m m', mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                 execute_mario_action_step_lp lp m m' ->
                 wmotr_world bm m' /\ anim_apart lp bm m' /\ mobj_apart bm m'
                 /\ ffw (lp_ge lp) bm m' /\ used_ok bm m' /\ AnimWorld.anim_w (lp_ge lp) bm m'
                 /\ lvl_w (lp_ge lp) m'.
  Proof.
    intros m m' Hok Hphi HD Hst. pose proof Hphi as ((_ & c & Hc & Hb) & _).
    destruct (frame_FS c m m' Hb (frame_FS_start m c Hok Hphi HD Hc) Hst)
      as (_ & (_ & Hw & Han & Hmo & _ & Hf & Hu & Haw & Hl) & _).
    exact (conj Hw (conj Han (conj Hmo (conj Hf (conj Hu (conj Haw Hl)))))).
  Qed.

  Lemma Hframe_is_move_chain :
    forall m m' c, mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                   execute_mario_action_step_lp lp m m' ->
                   read_cells bm m c -> budget_ok c ->
                   exists c', read_cells bm m' c' /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c c'.
  Proof.
    intros m m' c Hok Hphi HD Hst Hc Hb.
    destruct (frame_FS c m m' Hb (frame_FS_start m c Hok Hphi HD Hc) Hst) as (_ & _ & H).
    exact H.
  Qed.

  (* THE CRUX, now derived *)
  Lemma seg_action_phi :
    forall m m', mem_ok_lp bm MWF m -> Phi m -> a_down_real bm m = false ->
                 execute_mario_action_step_lp lp m m' -> Phi m'.
  Proof.
    intros m m' Hok Hphi HD Hst.
    pose proof Hphi as ((_ & c & Hcells & Hc) & _).
    split; [ | exact (Hframe_keeps_world m m' Hok Hphi HD Hst) ].
    split; [ exact (Hframe_stays_noA m m' Hok Hphi HD Hst) | ].
    destruct (Hframe_is_move_chain m m' c Hok Hphi HD Hst Hcells Hc) as (c' & Hc' & Hmv).
    exists c'. split; [ exact Hc' | ].
    exact (chain_keeps_budget wmotr_floor wmotr_gap_proved wmotr_pole wmotr_poles_proved
             wmotr_cannon wmotr_cannons_proved
             c c' Hc Hmv).
  Qed.

  Lemma Hphi_y : forall m, Phi m -> y_le bm PHI_YMAX m.
  Proof. intros m Hphi v Hl. exact (height_invariant_y bm R_noA m (proj1 Hphi) v Hl). Qed.

  (* GOAL 1's proved frame, at this section's surface *)
  Lemma frame_action_linked12 :
    forall m m', mem_ok_lp bm MWF m ->
                 execute_mario_action_step_lp lp m m' -> mem_ok_lp bm MWF m'.
  Proof. exact (proj1 call_facts). Qed.

  (* the render call carries mem_ok, on the link (RenderFlank) *)
  Lemma render_ok_linked12 :
    forall m m', mem_ok_lp bm MWF m ->
                 RenderFlank.render_call lp bm m m' -> mem_ok_lp bm MWF m'.
  Proof.
    exact (RenderFlank.render_mem_ok lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0).
  Qed.

  (* the render call carries PhiW, on the link (RenderKeep): its footprint
     is Mario's animFrame / animTimer / accelAssist and the six render
     globals, apart from every cell PhiW reads but the animFrame, which the
     real geo_update_animation_frame keeps in [-1, loopEnd] *)
  Lemma render_phi_linked12 :
    forall m m', Phi m -> RenderFlank.render_call lp bm m m' ->
                 RenderKeep.render_surf_apart lp bm m -> Phi m'.
  Proof. exact (RenderKeep.render_keeps_phiw lp H12 bm). Qed.

  (* the platform step carries mem_ok, the A-held bit and PhiW, on the link
     (PlatformKeep): its walked footprint is D_8032FEC0, Mario's pos[0] /
     pos[2] and pos[1] written back unchanged *)
  Lemma plat_ok_linked12 :
    forall m m', mem_ok_lp bm MWF m -> PlatformKeep.plat_still lp m ->
                 seg_platform_spec lp bm m m' -> mem_ok_lp bm MWF m'.
  Proof.
    intros m m' Hok Hst (Hc & _).
    exact (PlatformKeep.plat_mem_ok lp H12 bm Hbm_sym bc oc0 SafeB HSafeB_syms Hbc_sym Hoc0 m m' Hok Hc Hst).
  Qed.

  Lemma plat_ad_linked12 :
    forall m m', mem_ok_lp bm MWF m -> PlatformKeep.plat_still lp m ->
                 seg_platform_spec lp bm m m' -> a_down_real bm m' = a_down_real bm m.
  Proof.
    intros m m' Hok Hst (Hc & _).
    exact (PlatformKeep.plat_a_down lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 m m' Hok Hc Hst).
  Qed.

  Lemma plat_phi_linked12 :
    forall m m', Phi m -> PlatformKeep.plat_still lp m -> seg_platform_spec lp bm m m' -> Phi m'.
  Proof.
    intros m m' Hphi Hst (Hc & Hsa).
    exact (PlatformKeep.plat_keeps_phiw lp H12 bm Hbm_sym m m' Hphi Hc Hst Hsa).
  Qed.

  (* ==================================================================== *)
  (* THE GOAL-2 CAPSTONE (height form): over any link of the twelve TUs,  *)
  (* a run of real game frames with A neither pressed nor held after     *)
  (* every poll,                                                          *)
  (* started GOAL-1-well-formed, in the height invariant Phi and with      *)
  (* gMarioPlatform NULL or still (StartSat: all three hold at the boot    *)
  (* witness), keeps Mario's height <= PHI_YMAX = 2796 (coin #2 needs     *)
  (* >= 2980).                                                            *)
  (* ==================================================================== *)
  Theorem wmotr_noA_height_bound_linked12 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init -> Phi init -> PlatformKeep.plat_still lp init ->
      Forall (fun i => a_used_real bm i = false) is ->
      reachable mem mem (frame_step lp bm MWF Phi) init is m ->
      y_le bm PHI_YMAX m.
  Proof.
    intros init is m Hok Hphi Hst HA Hr.
    exact (proj2 (noA_run_height_bound lp bm MWF Phi PHI_YMAX
                    frame_action_linked12 render_ok_linked12 render_phi_linked12
                    plat_ok_linked12 plat_ad_linked12 plat_phi_linked12 seg_action_phi Hphi_y
                    init is m Hok Hphi Hst HA Hr)).
  Qed.

End HeightLinked12.
