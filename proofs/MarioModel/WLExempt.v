(* ====================================================================== *)
(* WLExempt.v -- the exempt-callee whitelist row WL_exempt (SPINE,          *)
(* 2026-10-22, GOAL 1 premise sweep).                                      *)
(*                                                                        *)
(* FOUND FALSE.  Every GOAL 1 capstone (and GOAL 2's HeightFrame, which    *)
(* copies GOAL 1's surface) assumed                                        *)
(*                                                                        *)
(*   WL_exempt : forall e le m fid fty vf fd,                              *)
(*     mem_id fid exempt_callees = true ->                                 *)
(*     eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->                    *)
(*     Genv.find_funct (lp_ge lp) vf = Some fd -> marg_exempt fd = true.   *)
(*                                                                        *)
(* The environment e and the type fty are universally quantified, so a     *)
(* local env that binds `sqrtf` to set_mario_action's function block       *)
(* evaluates the Evar to set_mario_action, whose first parameter IS a      *)
(* MarioState pointer: marg_exempt = false.  wl_exempt_old_refuted below   *)
(* proves the row false for EVERY twelve-TU link, so the capstones that    *)
(* took it were VACUOUS (a phantom forall over environments the program    *)
(* never builds; LinkedTwelve.v's header had noted the forall e, but not   *)
(* that it is refutable).                                                  *)
(*                                                                        *)
(* REPAIR.  Its only consumer (CensusV2.chk_call_marg) uses it at a        *)
(* censused body, whose env is empty_env (every censused body has          *)
(* fn_vars = nil; the engine's TI carries e = empty_env), and at a         *)
(* FUNCTION-typed Evar (call_callee_exempt).  Restated there               *)
(* (CensusV2.wl_exempt_ok), it is a THEOREM of the link                    *)
(* (wl_exempt_linked12): the Evar evaluates to the symbol's own block, and *)
(* each exempt id resolves either to an External (linked12_ext_pin) or to  *)
(* one of the eleven lifted real bodies, whose first parameter is not a    *)
(* MarioState pointer (computed from the generated AST).                   *)
(* ====================================================================== *)

From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Clight Linking.
From SM64.Generated Require mario surface_collision math_util camera.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame RealFrameLinked
  CensusV2 EngineV2Consumer RestSurface LinkedTwelve.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The old statement is false for every twelve-TU link.                 *)
(* ---------------------------------------------------------------------- *)

Lemma mario_defmap_sma :
  (prog_defmap mario.prog) ! mario._set_mario_action
    = Some (Gfun (Internal mario.f_set_mario_action)).
Proof. vm_compute. reflexivity. Qed.

Lemma sma_not_exempt : marg_exempt (Internal mario.f_set_mario_action) = false.
Proof. vm_compute. reflexivity. Qed.

Lemma sqrtf_in_exempt : mem_id mario._sqrtf exempt_callees = true.
Proof. vm_compute. reflexivity. Qed.

Theorem wl_exempt_old_refuted : forall lp, linked12 lp ->
  ~ (forall e le m fid fty vf fd,
       mem_id fid exempt_callees = true ->
       eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
       Genv.find_funct (lp_ge lp) vf = Some fd ->
       marg_exempt fd = true).
Proof.
  intros lp H12 Hrow.
  destruct (linkorder_resolves_funct lp mario.prog mario._set_mario_action
              mario.f_set_mario_action (linked12_LO_mario lp H12) mario_defmap_sma)
    as (b & _ & Hff).
  set (fty := Tfunction nil Tvoid cc_default).
  set (e := PTree.set mario._sqrtf (b, fty) empty_env).
  assert (Hev : forall (le : temp_env) (m : mem),
             eval_expr (lp_ge lp) e le m (Evar mario._sqrtf fty) (Vptr b Ptrofs.zero)).
  { intros le m. eapply eval_Elvalue.
    - apply eval_Evar_local. unfold e. apply PTree.gss.
    - apply deref_loc_reference. reflexivity. }
  pose proof (Hrow e (PTree.empty val) Mem.empty mario._sqrtf fty _ _
                sqrtf_in_exempt (Hev _ _) Hff) as Hex.
  rewrite sma_not_exempt in Hex. discriminate Hex.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The restated row holds for every twelve-TU link.                     *)
(* ---------------------------------------------------------------------- *)

Lemma lifted_marg_exempt :
  forallb (fun fd => marg_exempt fd)
    [ Internal mario.f_vec3f_find_ceil;
      Internal surface_collision.f_f32_find_wall_collision;
      Internal surface_collision.f_find_floor;
      Internal surface_collision.f_find_ceil;
      Internal surface_collision.f_find_poison_gas_level;
      Internal surface_collision.f_find_water_level;
      Internal math_util.f_vec3f_set;
      Internal math_util.f_vec3f_copy;
      Internal math_util.f_vec3s_copy;
      Internal math_util.f_atan2s;
      Internal camera.f_set_camera_mode ] = true.
Proof. vm_compute. reflexivity. Qed.

Theorem wl_exempt_linked12 : forall lp, linked12 lp -> wl_exempt_ok lp.
Proof.
  intros lp H12 le m fid tyl rty cc vf fd Hmem Hev Hff.
  destruct (eval_Evar_funct_empty lp le m fid tyl rty cc vf Hev) as (b & Hs & ->).
  assert (Hres : resolves_lp lp fid fd) by (exists b; split; [ exact Hs | exact Hff ]).
  destruct fd as [f | ef targs tres tcc]; [ | reflexivity ].
  pose proof lifted_marg_exempt as Hl.
  cbn [forallb] in Hl.
  repeat (apply andb_prop in Hl as [? Hl]).
  destruct (exempt_split _ Hmem) as [Hlift | Hext].
  - unfold mem_id, lifted_ids in Hlift. cbn [existsb] in Hlift.
    repeat (apply orb_true_iff in Hlift; destruct Hlift as [Hq | Hlift]);
      try discriminate Hlift; apply Pos.eqb_eq in Hq; subst fid.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) mario_defmap_vfc Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_surf lp H12) surf_defmap_ffwc Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_surf lp H12) surf_defmap_ff Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_surf lp H12) surf_defmap_fc Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_surf lp H12) surf_defmap_fp Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_surf lp H12) surf_defmap_fw Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) math_defmap_v3fset Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) math_defmap_v3fcopy Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) math_defmap_v3scopy Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_math lp H12) math_defmap_atan2s Hres).
      assumption.
    + rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_camera lp H12) camera_defmap_scm Hres).
      assumption.
  - exfalso. exact (linked12_ext_pin lp H12 fid f (or_introl Hext) Hres).
Qed.
