(**
  Rank-1 PLAYER-list tail closure.

  The useful collision/query split needs Mario's raw Object coordinates to
  change after [copy_mario_state_to_object] and before the final floor query.
  One residual in the previous scheduler audit was a second PLAYER-list node
  reached after Mario.  This file closes the two immediate post-copy child
  families which made that residual concrete:

  - [bhvMario] selects list 0 (an existing separate census proves it is the
    only generated behavior-data script which does so);
  - Mario's post-copy particle spawns all select list 8; and
  - all three guarded debug spawns select list 4 or list 6.

  Therefore the ordinary post-copy children cannot become later PLAYER
  nodes.  A later PLAYER node may still have existed before Mario's callback
  or come from another callback, pointer forwarding, an alias/outside effect,
  or a list/slot lifecycle violation.  The file deliberately does not pretend
  that immediate-child exclusion is the missing linked traversal proof.
*)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_debug us_object_list_processor
  jp_behavior_data jp_debug jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module A1PLT_USData := us_behavior_data.
Module A1PLT_USDebug := us_debug.
Module A1PLT_USObjects := us_object_list_processor.
Module A1PLT_JPData := jp_behavior_data.
Module A1PLT_JPDebug := jp_debug.
Module A1PLT_JPObjects := jp_object_list_processor.

(** Decode the list selected by a behavior's leading BEGIN command.  This
    local decoder keeps the child receipt independent of the much larger
    Timer-131 execution modules. *)
Definition player_tail_behavior_begin_list_index
    (initializer : list init_data) : option Z :=
  match initializer with
  | Init_int32 command :: _ => Some (Int.unsigned command / 65536)
  | _ => None
  end.

(** Extract a literal global used at one fixed argument of every direct call
    to [callee].  This keeps all three debug behavior operands tied to their
    actual [spawn_object_relative] callsites. *)
Definition direct_call_evar_argument
    (callee : ident) (index : nat) (s : statement) : list ident :=
  match s with
  | Scall _ (Evar found_callee _) arguments =>
      if Pos.eqb found_callee callee then
        match nth_error arguments index with
        | Some (Evar found_argument _) => [found_argument]
        | _ => []
        end
      else []
  | _ => []
  end.

Fixpoint direct_call_evar_arguments_s
    (callee : ident) (index : nat) (s : statement) : list ident :=
  direct_call_evar_argument callee index s ++
  match s with
  | Ssequence first second | Sloop first second =>
      direct_call_evar_arguments_s callee index first ++
      direct_call_evar_arguments_s callee index second
  | Sifthenelse _ yes no =>
      direct_call_evar_arguments_s callee index yes ++
      direct_call_evar_arguments_s callee index no
  | Sswitch _ cases => direct_call_evar_arguments_ls callee index cases
  | Slabel _ body => direct_call_evar_arguments_s callee index body
  | _ => []
  end
with direct_call_evar_arguments_ls
    (callee : ident) (index : nat) (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      direct_call_evar_arguments_s callee index body ++
      direct_call_evar_arguments_ls callee index rest
  end.

Definition us_mario_debug_spawn_behaviors :
    list (ident * globvar type) :=
  [(A1PLT_USData._bhvKoopaShell, A1PLT_USData.v_bhvKoopaShell);
   (A1PLT_USData._bhvJumpingBox, A1PLT_USData.v_bhvJumpingBox);
   (A1PLT_USData._bhvKoopaShellUnderwater,
      A1PLT_USData.v_bhvKoopaShellUnderwater)].

Definition jp_mario_debug_spawn_behaviors :
    list (ident * globvar type) :=
  [(A1PLT_JPData._bhvKoopaShell, A1PLT_JPData.v_bhvKoopaShell);
   (A1PLT_JPData._bhvJumpingBox, A1PLT_JPData.v_bhvJumpingBox);
   (A1PLT_JPData._bhvKoopaShellUnderwater,
      A1PLT_JPData.v_bhvKoopaShellUnderwater)].

(** Argument 6 is the seventh and final [behavior] operand of
    [spawn_object_relative].  Its three exact values select lists 6, 4, and 4.
    They may be enabled by debug controls, but none can extend PLAYER. *)
Definition mario_debug_children_are_nonplayer_source_claim : Prop :=
  direct_call_evar_arguments_s
    A1PLT_USDebug._spawn_object_relative 6
    (fn_body A1PLT_USDebug.f_try_do_mario_debug_object_spawn) =
      map fst us_mario_debug_spawn_behaviors /\
  map (fun entry => player_tail_behavior_begin_list_index (gvar_init (snd entry)))
    us_mario_debug_spawn_behaviors = [Some 6; Some 4; Some 4] /\
  direct_call_evar_arguments_s
    A1PLT_JPDebug._spawn_object_relative 6
    (fn_body A1PLT_JPDebug.f_try_do_mario_debug_object_spawn) =
      map fst jp_mario_debug_spawn_behaviors /\
  map (fun entry => player_tail_behavior_begin_list_index (gvar_init (snd entry)))
    jp_mario_debug_spawn_behaviors = [Some 6; Some 4; Some 4].

Theorem mario_debug_children_are_nonplayer_source_checked :
  mario_debug_children_are_nonplayer_source_claim.
Proof.
  unfold mario_debug_children_are_nonplayer_source_claim,
    us_mario_debug_spawn_behaviors, jp_mario_debug_spawn_behaviors,
    direct_call_evar_arguments_s, direct_call_evar_argument,
    player_tail_behavior_begin_list_index.
  vm_compute. repeat split; reflexivity.
Qed.

(** The exact non-null behavior entries in [sParticleTypes].  Keeping this
    small data list local avoids importing the much broader scheduler audit. *)
Definition us_player_tail_particle_behavior_entries :
    list (ident * globvar type) :=
  [(A1PLT_USData._bhvMistParticleSpawner,
      A1PLT_USData.v_bhvMistParticleSpawner);
   (A1PLT_USData._bhvVertStarParticleSpawner,
      A1PLT_USData.v_bhvVertStarParticleSpawner);
   (A1PLT_USData._bhvHorStarParticleSpawner,
      A1PLT_USData.v_bhvHorStarParticleSpawner);
   (A1PLT_USData._bhvSparkleParticleSpawner,
      A1PLT_USData.v_bhvSparkleParticleSpawner);
   (A1PLT_USData._bhvBubbleParticleSpawner,
      A1PLT_USData.v_bhvBubbleParticleSpawner);
   (A1PLT_USData._bhvWaterSplash, A1PLT_USData.v_bhvWaterSplash);
   (A1PLT_USData._bhvIdleWaterWave, A1PLT_USData.v_bhvIdleWaterWave);
   (A1PLT_USData._bhvPlungeBubble, A1PLT_USData.v_bhvPlungeBubble);
   (A1PLT_USData._bhvWaveTrail, A1PLT_USData.v_bhvWaveTrail);
   (A1PLT_USData._bhvFireParticleSpawner,
      A1PLT_USData.v_bhvFireParticleSpawner);
   (A1PLT_USData._bhvShallowWaterWave,
      A1PLT_USData.v_bhvShallowWaterWave);
   (A1PLT_USData._bhvShallowWaterSplash,
      A1PLT_USData.v_bhvShallowWaterSplash);
   (A1PLT_USData._bhvLeafParticleSpawner,
      A1PLT_USData.v_bhvLeafParticleSpawner);
   (A1PLT_USData._bhvSnowParticleSpawner,
      A1PLT_USData.v_bhvSnowParticleSpawner);
   (A1PLT_USData._bhvBreathParticleSpawner,
      A1PLT_USData.v_bhvBreathParticleSpawner);
   (A1PLT_USData._bhvDirtParticleSpawner,
      A1PLT_USData.v_bhvDirtParticleSpawner);
   (A1PLT_USData._bhvMistCircParticleSpawner,
      A1PLT_USData.v_bhvMistCircParticleSpawner);
   (A1PLT_USData._bhvTriangleParticleSpawner,
      A1PLT_USData.v_bhvTriangleParticleSpawner)].

Definition jp_player_tail_particle_behavior_entries :
    list (ident * globvar type) :=
  [(A1PLT_JPData._bhvMistParticleSpawner,
      A1PLT_JPData.v_bhvMistParticleSpawner);
   (A1PLT_JPData._bhvVertStarParticleSpawner,
      A1PLT_JPData.v_bhvVertStarParticleSpawner);
   (A1PLT_JPData._bhvHorStarParticleSpawner,
      A1PLT_JPData.v_bhvHorStarParticleSpawner);
   (A1PLT_JPData._bhvSparkleParticleSpawner,
      A1PLT_JPData.v_bhvSparkleParticleSpawner);
   (A1PLT_JPData._bhvBubbleParticleSpawner,
      A1PLT_JPData.v_bhvBubbleParticleSpawner);
   (A1PLT_JPData._bhvWaterSplash, A1PLT_JPData.v_bhvWaterSplash);
   (A1PLT_JPData._bhvIdleWaterWave, A1PLT_JPData.v_bhvIdleWaterWave);
   (A1PLT_JPData._bhvPlungeBubble, A1PLT_JPData.v_bhvPlungeBubble);
   (A1PLT_JPData._bhvWaveTrail, A1PLT_JPData.v_bhvWaveTrail);
   (A1PLT_JPData._bhvFireParticleSpawner,
      A1PLT_JPData.v_bhvFireParticleSpawner);
   (A1PLT_JPData._bhvShallowWaterWave,
      A1PLT_JPData.v_bhvShallowWaterWave);
   (A1PLT_JPData._bhvShallowWaterSplash,
      A1PLT_JPData.v_bhvShallowWaterSplash);
   (A1PLT_JPData._bhvLeafParticleSpawner,
      A1PLT_JPData.v_bhvLeafParticleSpawner);
   (A1PLT_JPData._bhvSnowParticleSpawner,
      A1PLT_JPData.v_bhvSnowParticleSpawner);
   (A1PLT_JPData._bhvBreathParticleSpawner,
      A1PLT_JPData.v_bhvBreathParticleSpawner);
   (A1PLT_JPData._bhvDirtParticleSpawner,
      A1PLT_JPData.v_bhvDirtParticleSpawner);
   (A1PLT_JPData._bhvMistCircParticleSpawner,
      A1PLT_JPData.v_bhvMistCircParticleSpawner);
   (A1PLT_JPData._bhvTriangleParticleSpawner,
      A1PLT_JPData.v_bhvTriangleParticleSpawner)].

(** The earlier table/dataflow receipt established which 18 non-null
    particle entries can flow to [spawn_particle].  This theorem records the
    stronger endpoint needed here: every one selects list 8. *)
Definition mario_particle_children_are_nonplayer_source_claim : Prop :=
  initializer_addrof_idents
    (gvar_init A1PLT_USObjects.v_sParticleTypes) =
      map fst us_player_tail_particle_behavior_entries /\
  initializer_addrof_idents
    (gvar_init A1PLT_JPObjects.v_sParticleTypes) =
      map fst jp_player_tail_particle_behavior_entries /\
  map (fun entry => player_tail_behavior_begin_list_index (gvar_init (snd entry)))
    us_player_tail_particle_behavior_entries = repeat (Some 8) 18 /\
  map (fun entry => player_tail_behavior_begin_list_index (gvar_init (snd entry)))
    jp_player_tail_particle_behavior_entries = repeat (Some 8) 18.

Theorem mario_particle_children_are_nonplayer_source_checked :
  mario_particle_children_are_nonplayer_source_claim.
Proof.
  unfold mario_particle_children_are_nonplayer_source_claim,
    us_player_tail_particle_behavior_entries,
    jp_player_tail_particle_behavior_entries,
    player_tail_behavior_begin_list_index.
  vm_compute. repeat split; reflexivity.
Qed.

(** One compact boundary for downstream scheduler work.  It closes both
    ordinary immediate post-copy child families and confirms Mario selects
    list 0, but leaves other node producers, pointer
    forwarding, aliases/outside effects, and list/slot lifecycle as linked
    residuals. *)
Definition Area1PlayerListTailCheckedBoundary : Prop :=
  player_tail_behavior_begin_list_index
    (gvar_init A1PLT_USData.v_bhvMario) = Some 0 /\
  player_tail_behavior_begin_list_index
    (gvar_init A1PLT_JPData.v_bhvMario) = Some 0 /\
  mario_particle_children_are_nonplayer_source_claim /\
  mario_debug_children_are_nonplayer_source_claim.

Theorem area1_player_list_tail_checked_boundary_holds :
  Area1PlayerListTailCheckedBoundary.
Proof.
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [exact mario_particle_children_are_nonplayer_source_checked |].
  exact mario_debug_children_are_nonplayer_source_checked.
Qed.
