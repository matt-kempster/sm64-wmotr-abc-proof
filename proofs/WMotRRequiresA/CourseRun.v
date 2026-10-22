(* ====================================================================== *)
(* CourseRun (GOAL 2): the course number WMotR's level load sets, by the   *)
(* REAL generated lvl_set_current_level.                                    *)
(*                                                                          *)
(* The real path: every level load runs the menu segment's                 *)
(* level_main_menu_entry_2 (levels/scripts.c:118, EXECUTE in the main      *)
(* loop), whose first command is CALL(0, lvl_set_current_level)           *)
(* (levels/menu/script.c:61) with the script register = the level being    *)
(* loaded (LEVEL_WMOTR = 31).  lvl_set_current_level (level_update.c:1273) *)
(* stores gCurrCourseNum = gLevelToCourseNumTable[levelNum - 1].           *)
(*                                                                          *)
(* Here: over every linked12 link, from Genv.init_mem itself, the generated *)
(* lvl_set_current_level(0, 31) runs to completion in the sound            *)
(* interpreter with NO external answered (every callee it reaches is       *)
(* linked: save_file_get_star_flags, disable_warp_checkpoint, and the    *)
(* empty nop_change_course of debug_course.c, the 37th TU), so            *)
(* the run is unconditional, and afterwards gCurrCourseNum = 23            *)
(* (COURSE_WMOTR, levels/course_defines.h: "(23) Wing Mario over the       *)
(* Rainbow").  StartSat's witness carries that value (course_tether).      *)
(* ====================================================================== *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Values AST Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.InitMemEq.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve.
Require SM64.Generated.level_update.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope string_scope.

Definition no_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) := None.

Definition LEVEL_WMOTR : Z := 31.
Definition COURSE_WMOTR : Z := 23.

Definition FUEL : nat := Z.to_nat 200000.

Definition lscl_args : list val := [Vint Int.zero; Vint (Int.repr LEVEL_WMOTR)].

Definition course_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match init_mem_c ast, Genv.find_symbol ge SM64.Generated.level_update._gCurrCourseNum with
      | Some m0, Some bC =>
          match ex_call ge no_world FUEL m0
                  (Internal SM64.Generated.level_update.f_lvl_set_current_level) lscl_args with
          | Done _ (_, m', _) =>
              match CM.load Mint16signed m' bC 0 with
              | Some (Vint i) => Int.eq i (Int.repr COURSE_WMOTR)
              | _ => false
              end
          | Stuck _ _ _ _ => false
          end
      | _, _ => false
      end
  | _, _ => false
  end.

Lemma course_ok_true : course_gen ge12 ast12 = true.
Proof. vm_compute. reflexivity. Qed.

(* THE RUN *)
Theorem course_runs : forall lp, linked12 lp ->
  exists m0 bC t m' v,
    Genv.init_mem lp = Some m0
    /\ Genv.find_symbol (globalenv lp) SM64.Generated.level_update._gCurrCourseNum = Some bC
    /\ eval_funcall function_entry2 (globalenv lp) m0
         (Internal SM64.Generated.level_update.f_lvl_set_current_level) lscl_args t m' v
    /\ Mem.load Mint16signed m' bC 0 = Some (Vint (Int.repr COURSE_WMOTR)).
Proof.
  intros lp Hlink.
  pose proof course_ok_true as W.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in W. unfold course_gen in W.
  destruct (init_mem_c (program_of_program lp)) as [m0|] eqn:Hm0; [ | discriminate ].
  destruct (Genv.find_symbol (globalenv lp) SM64.Generated.level_update._gCurrCourseNum)
    as [bC|] eqn:HbC; [ | discriminate ].
  destruct (ex_call _ no_world FUEL m0 _ lscl_args) as [[[t m'] v]| ? ? ?] eqn:R; [ | discriminate ].
  rewrite CM.load_eq in W.
  destruct (Mem.load Mint16signed m' bC 0) as [[| i | | | | ]|] eqn:Hl; try discriminate.
  apply Int.same_if_eq in W. subst i.
  rewrite init_mem_c_eq in Hm0.
  exists m0, bC, t, m', v. split; [ exact Hm0 | split; [ reflexivity | split; [ | exact Hl ] ] ].
  eapply ex_call_sound; [ | exact R ].
  intros ef args m1 t1 v1 m2 Hw. discriminate Hw.
Qed.
