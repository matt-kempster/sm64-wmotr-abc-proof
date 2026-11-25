(* ======================================================================= *)
(* LtwAudio (GOAL 2, 2026-11-15): level_trigger_warp keeps AudioInv.       *)
(*                                                                         *)
(* LtwFrame gives level_trigger_warp's footprint (ltw_frame) and its warp  *)
(* cells (ltw_warp_w).  The frame world also carries the audio state       *)
(* (FfWorld.aud_w = AudioInv.AudioInv): no load_sequence block holds a     *)
(* pointer out of the audio blocks.  level_trigger_warp's callees          *)
(* (play_transition, play_sound, fadeout_music, area_get_warp_node,        *)
(* music_changed_through_warp) never call load_sequence, so the keep is    *)
(* AudioWire's reflective walk over the real bodies: no audio contract is  *)
(* used.                                                                   *)
(* Consumer: NaSplit.sf_row (mario_handle_special_floors' death warp).     *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require audio_external sound_init level_update area mario.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface
  FloorsSurface MathBodies BullyBodies LinkedTwelve MtxfBody SaveFileBody
  ObjHelpersBodies ObjExtBodies AudioBodies.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame LsContract CapAudio AudioInv AudioWire.
From SM64.Proofs.WMotRRequiresA Require Import LtwFrame.

Import ListNotations.

Section LtwAi.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  Let afiw := afi lp ltw_ws.
  Let LOx := linked12_LO_audio_external lp H12.
  Let LOs := linked12_LO_sound_init lp H12.
  Let LOa := linked12_LO_area lp H12.
  Let LOl := linked12_LO_lvl lp H12.

  Ltac ids_ai :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg; cbn [mem_id existsb] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  Ltac ai_sym q LO f gt ids :=
    refine (afi_of_body lp ltw_ws q _ f LO _ _);
    [ vm_compute; reflexivity
    | apply (afi_body lp ltw_ws gt ids f); [ vm_compute; reflexivity | ids_ai ] ].

  Lemma la_rgb : afiw AR._set_warp_transition_rgb.
  Proof. ai_sym AR.prog LOa AR.f_set_warp_transition_rgb (@nil (ident * ident)) (@nil ident). Qed.
  Lemma la_pt : afiw AR._play_transition.
  Proof.
    pose proof la_rgb.
    ai_sym AR.prog LOa AR.f_play_transition (@nil (ident * ident)) [AR._set_warp_transition_rgb].
  Qed.
  Lemma la_agwn : afiw AR._area_get_warp_node.
  Proof. ai_sym AR.prog LOa AR.f_area_get_warp_node (@nil (ident * ident)) (@nil ident). Qed.
  Lemma la_ps : afiw AX._play_sound.
  Proof. ai_sym AX.prog LOx AX.f_play_sound (@nil (ident * ident)) (@nil ident). Qed.
  Lemma la_gcbm : afiw AX._get_current_background_music.
  Proof. ai_sym AX.prog LOx AX.f_get_current_background_music (@nil (ident * ident)) (@nil ident). Qed.
  Lemma la_mctw : afiw LU._music_changed_through_warp.
  Proof.
    pose proof la_agwn. pose proof la_gcbm.
    ai_sym LU.prog LOl LU.f_music_changed_through_warp (@nil (ident * ident))
      [AR._area_get_warp_node; AX._get_current_background_music].
  Qed.
  Lemma la_fade_to_zero : afiw AX._seq_player_fade_to_zero_volume.
  Proof. ai_sym AX.prog LOx AX.f_seq_player_fade_to_zero_volume gt_sp (@nil ident). Qed.
  Lemma la_fcvs : afiw AX._fade_channel_volume_scale.
  Proof. ai_sym AX.prog LOx AX.f_fade_channel_volume_scale gt_fcvs (@nil ident). Qed.
  Lemma la_803210D4 : afiw AX._func_803210D4.
  Proof.
    pose proof la_fcvs. pose proof la_fade_to_zero.
    ai_sym AX.prog LOx AX.f_func_803210D4 (@nil (ident * ident))
      [AX._fade_channel_volume_scale; AX._seq_player_fade_to_zero_volume].
  Qed.
  Lemma la_fadeout_music : afiw SI._fadeout_music.
  Proof.
    pose proof la_803210D4.
    ai_sym SI.prog LOs SI.f_fadeout_music (@nil (ident * ident)) [AX._func_803210D4].
  Qed.

  Variable bm : block.
  Hypothesis NLm : ~ gblk (lp_ge lp) ls_ids bm.

  (* level_trigger_warp keeps AudioInv *)
  Theorem ltw_ai : forall m w t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m (Internal LU.f_level_trigger_warp)
        [Vptr bm Ptrofs.zero; w] t m' vres ->
      AudioInv (lp_ge lp) m -> AudioInv (lp_ge lp) m'.
  Proof.
    intros m w t m' vres Hev A.
    pose proof la_pt. pose proof la_ps. pose proof la_fadeout_music. pose proof la_agwn.
    pose proof la_mctw.
    refine (proj2 (aim_body lp ltw_ws bm LU._m NLm nil ltw_callees
              LU.f_level_trigger_warp _ _ m _ t m' vres Hev _ A)).
    - vm_compute. reflexivity.
    - ids_ai.
    - intros le1 Hb b o' Hl. cbn in Hb. injection Hb as <-.
      rewrite PTree.gso in Hl by (intros E; discriminate E).
      rewrite PTree.gss in Hl. injection Hl as ->. reflexivity.
  Qed.

  (* play_sound keeps AudioInv (check_death_barrier's scream) *)
  Theorem ps_ai : forall b fd m vargs t m' vres,
      Genv.find_symbol (lp_ge lp) AX._play_sound = Some b ->
      Genv.find_funct_ptr (lp_ge lp) b = Some fd ->
      eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
      AudioInv (lp_ge lp) m -> Q2 (ak lp ltw_ws) m m' /\ AudioInv (lp_ge lp) m'.
  Proof.
    intros b fd m vargs t m' vres Hs Hf Hev A.
    exact (la_ps b fd Hs Hf m vargs t m' vres Hev A).
  Qed.
End LtwAi.
