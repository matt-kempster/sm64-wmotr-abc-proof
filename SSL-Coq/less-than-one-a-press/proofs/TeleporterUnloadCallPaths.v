(** The bounded stopping point requested by the user: distinguish the later
    ordinary warp-area unload choice from the earlier instant-area-change
    path. Skipping the former is not a proof of skipping every unload. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_level_update jp_level_update.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts
  ObjectContactNecessity ReadOnlyClightPaths TeleporterObjectLifetime
  TeleporterEarlierAreaChange.
Import ListNotations.
Local Open Scope Z_scope.
Module TUC := us_level_update.

Definition tuc_warp_body version := fn_body (match version with
| VersionUS => us_level_update.f_warp_area
| VersionJP => jp_level_update.f_warp_area end).
Definition tuc_type_two_guard := Ebinop Oeq (Etempvar TUC._t'2 tuchar)
  (Econst_int (Int.repr 2) tint) tint.
Definition tuc_area_choice version := match tuc_warp_body version with
| Ssequence _ (Sifthenelse _ (Ssequence (Ssequence _ choice) _) _) => choice
| _ => Sskip end.
Definition tuc_area_effects version := match tuc_area_choice version with
| Sifthenelse _ yes _ => yes | _ => Sskip end.
Definition tuc_unload_call := Scall None
  (Evar TUC._unload_mario_area (Tfunction [] tvoid cc_default)) [].
Definition tuc_timer_call := Scall None
  (Evar TUC._level_control_timer (Tfunction [tint] tushort cc_default))
  [Econst_int (Int.repr 3) tint].
Definition tuc_load_area := Scall None
  (Evar TUC._load_area (Tfunction [tint] tvoid cc_default))
  [Etempvar TUC._t'3 tuchar].

Definition TUCGeneratedCallPaths : Prop := forall version,
  tuc_area_choice version = Sifthenelse tuc_type_two_guard
    (tuc_area_effects version) Sskip /\
  tuc_area_effects version = Ssequence tuc_timer_call
    (Ssequence tuc_unload_call (Ssequence
      (Sset TUC._t'3 (Efield (Evar TUC._sWarpDest
        (Tstruct TUC._WarpDest noattr)) TUC._areaIdx tuchar)) tuc_load_area)) /\
  calls_ident_s us_area._change_area (fn_body (match version with
    | VersionUS => us_level_update.f_check_instant_warp
    | VersionJP => jp_level_update.f_check_instant_warp end)) = true.
Theorem tuc_generated_call_paths_checked : TUCGeneratedCallPaths.
Proof. intros []; repeat split; reflexivity. Qed.

Lemma tuc_type_three_choice_is_readonly : forall version ge e le before,
  le ! TUC._t'2 = Some (Vint (Int.repr 3)) ->
  readonly_path ge e before le (tuc_area_choice version) le.
Proof.
  intros version ge e le before Htype.
  rewrite (proj1 (tuc_generated_call_paths_checked version)).
  eapply ro_if with (v := Vint Int.zero) (choice := false).
  - unfold tuc_type_two_guard. eapply eval_Ebinop;
      [apply eval_Etempvar; exact Htype|constructor|reflexivity].
  - reflexivity.
  - apply ro_skip.
Qed.

Definition TUCTypeThreeChoiceSkipsUnload : Prop := forall version ge e le before,
  le ! TUC._t'2 = Some (Vint (Int.repr 3)) ->
  ocn_exec ge e le before (tuc_area_choice version) E0 le before Out_normal /\
  forall tr last after out,
    ocn_exec ge e le before (tuc_area_choice version) tr last after out ->
    tr = E0 /\ last = le /\ after = before /\ out = Out_normal.
Theorem tuc_type_three_choice_skips_unload : TUCTypeThreeChoiceSkipsUnload.
Proof.
  intros version ge e le before Htype.
  pose proof (tuc_type_three_choice_is_readonly version ge e le before Htype) as Hpath.
  split.
  - apply readonly_path_executes. exact Hpath.
  - intros. eapply readonly_path_forces_every_execution; eassumption.
Qed.

Definition TeleporterUnloadCallPathsBoundary : Prop :=
  TUCGeneratedCallPaths /\ TUCTypeThreeChoiceSkipsUnload /\
  TOLAreaUnloadSource /\ TEAChangedBranchUnloadBeforeLoad.
Theorem teleporter_unload_call_paths_checked : TeleporterUnloadCallPathsBoundary.
Proof.
  split; [exact tuc_generated_call_paths_checked|].
  split; [exact tuc_type_three_choice_skips_unload|].
  split; [exact tol_area_unload_source_checked|].
  exact tea_changed_branch_unloads_before_loading.
Qed.
