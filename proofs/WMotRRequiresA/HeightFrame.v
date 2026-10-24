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
(* starts GOAL-1-well-formed and in Phi, in which the controller hardware's *)
(* reply shows A on no live port every frame (PollFlank.pif_a_real; the     *)
(* real poll, walked, turns that into A neither pressed nor held), keeps    *)
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
From SM64.Proofs.WMotRRequiresA Require Import ProRows.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld FfRow AhwRow KbRow FpuFloor ExtInert.
From SM64.Proofs.WMotRRequiresA Require PoleXc PoleCasesT.
From SM64.Proofs.WMotRRequiresA Require RenderFlank AnimWorld PollFlank.
From SM64.Proofs Require OsDmaFloor LptBody.
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

  (* seg_input: the controller poll, the REAL code (2026-10-23, PollFlank):
     game_init.c's loop runs osContStartReadData(&gSIEventMesgQueue) when a
     controller is plugged in (left disjunct: it is not), then
     read_controller_inputs().  i is the memory after the SI request: its
     PIF image holds the reply bytes the HARDWARE delivered
     (OsDmaFloor.si_raw_dma_spec), which is what the no-A premise reads
     (PollFlank.pif_a_real); m0 is the post-poll memory.  Both calls are
     walked (Hsrd_ok / Hpoll_ok below, discharged on the link).
     LABELED (TRUST 0.7): the two calls are adjacent (the game runs
     audio_game_loop_tick and select_gfx_pool in between, assumed not to
     touch the PIF image), and the Phi carries, the poll's conditional on
     the controller cells it PROVABLY re-establishes (ctl_w). *)
  Definition seg_input_spec (m i m0 : mem) : Prop :=
    (i = m \/ PollFlank.srd_call lp m i)
    /\ (Phi m -> Phi i)
    /\ PollFlank.rci_call lp i m0
    /\ (Phi i -> ctl_w (lp_ge lp) m0 -> Phi m0).

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

  (* seg_render: the render step on Mario's node (2026-10-22,
     rendering_graph_node.c linked as TU 35).  geo_process_object calls the
     real geo_set_animation_globals on &marioObj->header.gfx.animInfo
     (RenderFlank.render_call), which advances Mario's animFrame through
     graph_node.c's geo_update_animation_frame.  The left disjunct is a frame
     where Mario's node is not drawn.  GOAL 1's mem_ok carry through it is
     PROVED from its walked footprint (RenderFlank.render_mem_ok,
     discharging Hrender_ok below); the Phi carry is assumed like every other
     flank's (it was inside seg_rest's before). *)
  Definition seg_render_spec (m m' : mem) : Prop :=
    (m' = m \/ RenderFlank.render_call lp bm m m')
    /\ (Phi m -> Phi m').

  (* The game is still in WMotR: gCurrLevelNum (level_update.c, set only by
     the warp code from sWarpDest, :477/:502) holds LEVEL_WMOTR (pinned from
     the level's own script, WMotRLevel.level_wmotr_self_warp). *)
  Definition in_wmotr (m : mem) : Prop :=
    exists b, Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some b
              /\ Mem.load Mint16signed m b 0 = Some (Vint (Int.repr LEVEL_WMOTR)).

  (* ===================================================================== *)
  (* 2. THE FRAME.  The per-frame input i is the memory after the SI       *)
  (*    request, whose PIF image holds the hardware's reply (GOAL 1's      *)
  (*    convention: the input IS the memory the frame reads it from).       *)
  (*    A frame that ends in another level is not a step: the run is ONE    *)
  (*    WMotR visit.  Leaving re-inits Mario elsewhere (the real game,      *)
  (*    experiments/oracle/ywatch.py: falling off sends Mario to the castle *)
  (*    grounds at y = 4500), and a new visit starts again at the entry     *)
  (*    warp, with the red coins and the star counter reloaded (TRUST 0.3). *)
  (* ===================================================================== *)
  (* The non-Mario tail is rest (object updates, then the render walk up
     to Mario's node) ; Mario's render call ; rest (the remaining walk). *)
  Definition frame_step (i m m' : mem) : Prop :=
    exists m0 m1 m2 m3 m4 m5,
      seg_input_spec m i m0
      /\ seg_platform_spec m0 m1
      /\ execute_mario_action_step_lp lp m1 m2
      /\ seg_level_spec m2 m3
      /\ seg_rest_spec m3 m4
      /\ seg_render_spec m4 m5
      /\ seg_rest_spec m5 m'
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

  (* the render call carries GOAL 1's mem_ok (discharged in the twelve-TU
     section below by RenderFlank.render_mem_ok -- NOT open). *)
  Hypothesis Hrender_ok :
    forall m m', mem_ok m -> RenderFlank.render_call lp bm m m' -> mem_ok m'.

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

  (* the controller poll's two real calls carry GOAL 1's mem_ok, and the
     poll leaves Mario's controller A-free when the hardware's reply shows A
     on no live port (discharged in the twelve-TU section below by
     PollFlank.srd_ok / PollFlank.poll_ok -- NOT open). *)
  Hypothesis Hsrd_ok :
    forall m i, mem_ok m -> PollFlank.srd_call lp m i -> mem_ok i.
  Hypothesis Hpoll_ok :
    forall i m0, mem_ok i -> Phi i -> PollFlank.pif_a_real (lp_ge lp) i = false ->
      PollFlank.rci_call lp i m0 ->
      mem_ok m0 /\ a_used_real bm m0 = false /\ ctl_w (lp_ge lp) m0.

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
    intros m m' (_ & Har & Hvr & Hmr & _) (Hv & Hs & Hm).
    split; [ exact (Hvr Hv) | split ].
    - exact (action_sat_load_eq_or_val not_tainted ACT_READING_NPC_DIALOG
               m m' Har dialog_action_not_tainted Hs).
    - exact (Hmr Hm).
  Qed.

  (* ===================================================================== *)
  (* 3. ONE FRAME: an A-free frame preserves mem_ok AND Phi.                *)
  (* ===================================================================== *)
  Theorem frame_step_ok :
    forall i m m',
      PollFlank.pif_a_real (lp_ge lp) i = false ->
      mem_ok m /\ Phi m ->
      frame_step i m m' ->
      mem_ok m' /\ Phi m'.
  Proof.
    intros i m m' HP (Hok & Hphi)
           (m0 & m1 & m2 & m3 & m4 & m5 & Hin & Hplat & Hact & Hlvl & Hrest & Hrnd & Hrest2 & _).
    (* input: the real poll *)
    destruct Hin as (Hsrd & Hpi & Hrci & Hp0).
    assert (Hoki : mem_ok i)
      by (destruct Hsrd as [-> | Hsrd]; [ exact Hok | exact (Hsrd_ok m i Hok Hsrd) ]).
    pose proof (Hpi Hphi) as Hphii.
    destruct (Hpoll_ok i m0 Hoki Hphii HP Hrci) as (Hok0 & HU & Hcw).
    destruct (a_used_real_false bm m0 HU) as (_ & HD).
    pose proof (Hp0 Hphii Hcw) as Hphi0.
    (* platform *)
    destruct Hplat as (_ & Hap & Hvp & Hdp & Hmp & Hpp).
    assert (HD1 : a_down_real bm m1 = false) by congruence.
    pose proof (inert_flank m0 m1 Hap Hvp Hmp Hok0) as Hok1.
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
    pose proof (Hpl Hphi2) as Hphi3.
    assert (Hok3 : mem_ok m3) by exact (conj Hv3 (conj Hs3 (Hml Hm2))).
    (* rest, Mario's render call, rest *)
    pose proof (rest_ok m3 m4 Hrest Hok3) as Hok4.
    pose proof (proj2 (proj2 (proj2 (proj2 Hrest))) Hphi3) as Hphi4.
    destruct Hrnd as (Hrc & Hpr).
    assert (Hok5 : mem_ok m5)
      by (destruct Hrc as [-> | Hrc]; [ exact Hok4 | exact (Hrender_ok m4 m5 Hok4 Hrc) ]).
    pose proof (Hpr Hphi4) as Hphi5.
    split.
    - exact (rest_ok m5 m' Hrest2 Hok5).
    - exact (proj2 (proj2 (proj2 (proj2 Hrest2))) Hphi5).
  Qed.

  (* ===================================================================== *)
  (* 4. THE RUN: a no-A run keeps y <= YMAX (and GOAL 1's invariant).       *)
  (* ===================================================================== *)
  Theorem noA_run_height_bound :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok init -> Phi init ->
      Forall (fun i => PollFlank.pif_a_real (lp_ge lp) i = false) is ->
      reachable mem mem frame_step init is m ->
      mem_ok m /\ y_le m.
  Proof.
    intros init is m Hok Hphi HA Hr.
    destruct (reachable_preserves_Phi mem mem (PollFlank.pif_a_real (lp_ge lp)) frame_step
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
     set_camera_mode reached from mario.c is a pinned rest case owing this
     gated residual over the real camera.c body (LABELED OPEN PREMISE:
     camera, deferred; GOAL 1's Hscm_body_real, docs/TRUST.md 4.1). *)
  Hypothesis Hscm_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB camera.f_set_camera_mode.
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
     cells and fresh_at) and the per-case rows Hauto_case below. *)
  Hypothesis Hseg_call_na : seg_call_rows_naFA lp bm MWF.
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
             Hsqrtf Hscm_body_real Hls Hdma_floor).
  Qed.

  Lemma air_leaves :
    forall fid f, mem_id fid AirborneSurface.airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof.
    exact (air_leaves_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0
             Hsqrtf Hscm_body_real Hls Hdma_floor).
  Qed.

  Lemma auto_leaves :
    forall fid f, mem_id fid AutomaticSurface.automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof.
    exact (auto_leaves_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0
             Hsqrtf Hscm_body_real Hls Hdma_floor).
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

  (* the controller poll, on the link (PollFlank): the real
     osContStartReadData and read_controller_inputs (osRecvMesg,
     osContGetReadData, run_demo_inputs, adjust_analog_stick), walked down to
     the SI / message-queue floor (OsDmaFloor, TRUST 3.5) and sqrtf
     (FpuFloor) *)
  Lemma srd_ok_linked12 :
    forall m i, mem_ok_lp bm MWF m -> PollFlank.srd_call lp m i -> mem_ok_lp bm MWF i.
  Proof.
    intros m i Hm Hs.
    pose proof (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as Hsp.
    exact (PollFlank.srd_ok lp H12 bm bc oc0 SafeB HSafeB_syms Hsp Hdma_floor m i Hm Hs).
  Qed.

  Lemma poll_ok_linked12 :
    forall i m0, mem_ok_lp bm MWF i -> Phi i -> PollFlank.pif_a_real (lp_ge lp) i = false ->
      PollFlank.rci_call lp i m0 ->
      mem_ok_lp bm MWF m0 /\ a_used_real bm m0 = false /\ ctl_w (lp_ge lp) m0.
  Proof.
    intros i m0 Hm (_ & _ & _ & _ & Hf & _ & _ & (_ & _ & Hcw)) HP Hr.
    pose proof (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as Hsp.
    exact (PollFlank.poll_ok lp H12 Hdma_floor Hsqrtf bm bc oc0 SafeB HSafeB_syms Hsp i m0 Hm Hf Hcw HP Hr).
  Qed.

  (* ==================================================================== *)
  (* THE GOAL-2 CAPSTONE (height form): over any link of the twelve TUs,  *)
  (* a run of real game frames in which the controller hardware's reply  *)
  (* shows A on no live port, every frame (PollFlank.pif_a_real: the PIF *)
  (* reply bytes; the real poll turns them into A neither pressed nor    *)
  (* held),                                                               *)
  (* started GOAL-1-well-formed and in the height invariant Phi, keeps    *)
  (* Mario's height <= PHI_YMAX = 2796 (coin #2 needs >= 2980).           *)
  (* ==================================================================== *)
  Theorem wmotr_noA_height_bound_linked12 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init -> Phi init ->
      Forall (fun i => PollFlank.pif_a_real (lp_ge lp) i = false) is ->
      reachable mem mem (frame_step lp bm MWF Phi) init is m ->
      y_le bm PHI_YMAX m.
  Proof.
    intros init is m Hok Hphi HA Hr.
    exact (proj2 (noA_run_height_bound lp bm MWF Phi PHI_YMAX
                    frame_action_linked12 render_ok_linked12 seg_action_phi Hphi_y
                    srd_ok_linked12 poll_ok_linked12
                    init is m Hok Hphi HA Hr)).
  Qed.

End HeightLinked12.
