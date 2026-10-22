(* ====================================================================== *)
(* ExtInert (unwired, GOAL 2): the externals act_freefall reaches.        *)
(*                                                                        *)
(* Three calls under act_freefall leave the linked C: play_sound (audio), *)
(* set_camera_shake_from_hit (camera) and sqrtf (the FPU).  None of them  *)
(* has a body in the 15 linked TUs, so CompCert's external_functions_sem  *)
(* says nothing about them.  What the walk needs is that such a call      *)
(* changes no block of the modeled memory and returns a non-pointer:      *)
(*                                                                        *)
(*   ext_inert name                                                       *)
(*                                                                        *)
(* - audio_inert, camera_inert: LABELED OPEN PREMISES (audio and camera   *)
(*   are deferred, by decision).  audio_inert also covers                 *)
(*   set_sound_moving_speed (act_holding_pole, 2026-10-22).               *)
(*   play_sound queues a request in the                                   *)
(*   audio TUs' own globals and set_camera_shake_from_hit writes camera.c *)
(*   globals; no linked TU declares those, so they are outside the        *)
(*   modeled memory.  Both are void.                                      *)
(* - sqrtf: the FPU floor (FpuFloor.sqrtf_spec, memory unchanged) plus    *)
(*   sqrtf_float: the sqrt.s instruction writes an FPU register, so the   *)
(*   result is a float, never a pointer (TRUST 3.5).                      *)
(*                                                                        *)
(* ext_fresh_sound: under its premise, the fresh-value contract describes *)
(* each of these calls on the real link.                                  *)
(* ====================================================================== *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events Globalenvs Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs Require Import Interp.SymExec2 MarioModel.LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor FpWalk.
Import ListNotations.

Definition ext_inert (name : string) : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem name sg ge vargs m t vres m' ->
    Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m' /\ (forall b o, vres <> Vptr b o).

(* the labeled open premises.  audio: play_sound and (since 2026-10-22, for
   act_holding_pole) set_sound_moving_speed, which writes the audio TUs'
   per-bank moving-speed table; its entry is shaped exactly like
   play_sound's *)
Definition audio_inert : Prop := ext_inert "play_sound" /\ ext_inert "set_sound_moving_speed".
Lemma audio_ps : audio_inert -> ext_inert "play_sound".
Proof. intros [H _]. exact H. Qed.
Lemma audio_ssms : audio_inert -> ext_inert "set_sound_moving_speed".
Proof. intros [_ H]. exact H. Qed.
Definition camera_inert : Prop := ext_inert "set_camera_shake_from_hit".

(* the FPU floor's second half *)
Definition sqrtf_float : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "sqrtf" sg ge vargs m t vres m' -> forall b o, vres <> Vptr b o.

Lemma sqrtf_inert : sqrtf_spec -> sqrtf_float -> ext_inert "sqrtf".
Proof.
  intros Hs Hf sg ge vargs m t vres m' H. split; [| exact (Hf _ _ _ _ _ _ _ H)].
  rewrite (Hs _ _ _ _ _ _ _ H). apply Mem.unchanged_on_refl.
Qed.

Module AIR := mario_actions_airborne.

Lemma ps_named : ext_named ((prog_defmap AIR.prog) ! AIR._play_sound) "play_sound" = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ps_ni : no_internal_all [AIR._play_sound] = true.
Proof. vm_compute. reflexivity. Qed.
Lemma csh_named : ext_named ((prog_defmap AIR.prog) ! AIR._set_camera_shake_from_hit)
  "set_camera_shake_from_hit" = true.
Proof. vm_compute. reflexivity. Qed.
Lemma csh_ni : no_internal_all [AIR._set_camera_shake_from_hit] = true.
Proof. vm_compute. reflexivity. Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

(* the same, for an external declared in any linked TU q *)
Theorem ext_fresh_sound_q : forall (q : Clight.program), Linking.linkorder q lp -> forall id name,
  ext_named ((prog_defmap q) ! id) name = true -> no_internal_all [id] = true ->
  ext_inert name ->
  forall nbase R0 gtab kv m0 uf gp,
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  forall args g cps fd E m vargs t m' vres,
  xc_fresh args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G nbase R0 gtab kv m0 uf gp E m g ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros q LOq id name Hn Hni HI nbase R0 gtab kv m0 uf gp GPO args g cps fd E m vargs t m' vres Hc Hl MM Hev.
  unfold sfun_lookup in Hl.
  destruct (Genv.find_symbol (genv_genv G) id) as [b|] eqn:Hs; [| discriminate Hl].
  assert (Hf : Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd)
    by (rewrite Genv.find_funct_find_funct_ptr; exact Hl).
  destruct (ext_resolve lp q id [id] name b fd H12 LOq
              ltac:(cbn; rewrite Pos.eqb_refl; reflexivity) Hni Hn Hs Hf)
    as (sg & targs & tres & cc & ->).
  inv Hev. match goal with H : external_call _ _ _ _ _ _ _ |- _ => destruct (HI _ _ _ _ _ _ _ H) as [U NP] end.
  eapply (xc_fresh_unch_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp GPO);
    [exact Hc | exact MM | exact U |].
  destruct vres; cbn; auto. exfalso. exact (NP _ _ eq_refl).
Qed.

Theorem ext_fresh_sound : forall id name,
  ext_named ((prog_defmap AIR.prog) ! id) name = true -> no_internal_all [id] = true ->
  ext_inert name ->
  forall nbase R0 gtab kv m0 uf gp,
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  forall args g cps fd E m vargs t m' vres,
  xc_fresh args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G nbase R0 gtab kv m0 uf gp E m g ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id name Hn Hni HI nbase R0 gtab kv m0 uf gp GPO args g cps fd E m vargs t m' vres Hc Hl MM Hev.
  unfold sfun_lookup in Hl.
  destruct (Genv.find_symbol (genv_genv G) id) as [b|] eqn:Hs; [| discriminate Hl].
  assert (Hf : Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd)
    by (rewrite Genv.find_funct_find_funct_ptr; exact Hl).
  destruct (ext_resolve lp AIR.prog id [id] name b fd H12 (linked12_LO_air lp H12)
              ltac:(cbn; rewrite Pos.eqb_refl; reflexivity) Hni Hn Hs Hf)
    as (sg & targs & tres & cc & ->).
  inv Hev. match goal with H : external_call _ _ _ _ _ _ _ |- _ => destruct (HI _ _ _ _ _ _ _ H) as [U NP] end.
  eapply (xc_fresh_unch_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp GPO);
    [exact Hc | exact MM | exact U |].
  destruct vres; cbn; auto. exfalso. exact (NP _ _ eq_refl).
Qed.
End LP.
