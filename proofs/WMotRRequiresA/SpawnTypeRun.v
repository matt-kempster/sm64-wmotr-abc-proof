(* spine-root: GOAL 2's entry spawn type is RUN by the real area.c code --
   over every 30-TU link (behavior_data.c linked), the generated
   get_mario_spawn_type, given an object whose behavior is &bhvAirborneWarp
   (the object WMotR's warp node 0x0A spawns), returns 0x12
   (MARIO_SPAWN_AIRBORNE).  Before behavior_data.c was linked this lookup had
   no CompCert execution (WMotREntry.cmp_size0_stuck): its first compare
   was between size-0 extern blocks. *)

(* WMotREntry reads the same answer off the generated tables
   (spawn_lookup_shape, airborne_warp_index, spawn_type_at_7).  Here the
   real body runs: virtual_to_segmented (the NO_SEGMENTED_MEMORY identity,
   memory.c, TRUST 2.2), then the loop over sWarpBhvSpawnTable, whose first
   seven pointer compares (against seven other scripts, each now a block
   with its real length) are false and the eighth true.  The run uses
   PositiveControl's method (interpreter + LinkGenv + MemBuild); it calls no
   external function, so the oracle is empty and soundness needs no world
   hypothesis.  Still NOT run (TRUST 0.4): the level script that spawns the
   object, init_mario_after_warp itself. *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Values AST Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve.
Require SM64.Generated.area.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope string_scope.

Definition no_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) := None.

Definition externs (i : ident) : option Z :=
  if Pos.eqb i (id "gSineTable") then Some (5120 * 4) else None.

Definition MARIO_SPAWN_AIRBORNE : Z := 18.   (* 0x12 *)

(* Object.behavior @524 (the offset PoleControl pins over ge12) *)
Definition build (ge : genv) (ast : AST.program (Ctypes.fundef function) type)
    : option (mem * block * block) :=
  match alloc_globs ge externs Mem.empty (AST.prog_defs ast) with
  | Some m0 =>
      match sym ge "bhvAirborneWarp", fresh m0 (ssize ge "Object") with
      | Some bw, Some (m1, bo) =>
          match apply_writes m1 [W Mint32 bo 524 (Vptr bw Ptrofs.zero)] 0 with
          | inl m2 => Some (m2, bo, bw)
          | inr _ => None
          end
      | _, _ => None
      end
  | None => None
  end.

Definition FUEL : nat := Z.to_nat 5000.

Definition check_gen (fuel : nat) (f : fundef) (ge : genv) (m : mem) (bo bw : block) : bool :=
  match ex_call ge no_world fuel m f [Vptr bo Ptrofs.zero] with
  | Done _ (_, _, Vint r) =>
      Int.eq r (Int.repr MARIO_SPAWN_AIRBORNE)
      && match CM.load Mint32 m bo 524, Genv.find_symbol ge (id "bhvAirborneWarp") with
         | Some (Vptr b o), Some b' => Pos.eqb b bw && Pos.eqb b' bw && Ptrofs.eq o Ptrofs.zero
         | _, _ => false
         end
  | _ => false
  end.

(* matching on the option arguments, not on the constant ge12 (WithGe) *)
Definition witness_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match build ge ast with
      | Some (m, bo, bw) =>
          check_gen FUEL (Internal SM64.Generated.area.f_get_mario_spawn_type) ge m bo bw
      | None => false
      end
  | _, _ => false
  end.

Definition witness_ok : bool := witness_gen ge12 ast12.

Lemma witness_ok_true : witness_ok = true.
Proof. vm_compute. reflexivity. Qed.

Lemma check_gen_sound : forall fuel f (ge : genv) m bo bw,
    check_gen fuel f ge m bo bw = true ->
    Genv.find_symbol ge (id "bhvAirborneWarp") = Some bw /\
    Mem.load Mint32 m bo 524 = Some (Vptr bw Ptrofs.zero) /\
    exists t m',
      eval_funcall function_entry2 ge m f [Vptr bo Ptrofs.zero] t m'
        (Vint (Int.repr MARIO_SPAWN_AIRBORNE)).
Proof.
  intros fuel f ge m bo bw H. unfold check_gen in H.
  destruct (ex_call ge no_world fuel m f _) as [[[t m'] res]| ? ? ?] eqn:Hrun;
    [ | discriminate].
  destruct res; try discriminate.
  apply andb_prop in H as [Hr H]. apply Int.same_if_eq in Hr. subst i.
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bo 524) as [[| | | | | b o]|]; try discriminate.
  destruct (Genv.find_symbol ge (id "bhvAirborneWarp")) as [b'|]; try discriminate.
  apply andb_prop in H as [H Ho]. apply andb_prop in H as [Hb Hb'].
  apply Pos.eqb_eq in Hb. apply Pos.eqb_eq in Hb'. apply Ptrofs.same_if_eq in Ho. subst.
  split; [ reflexivity | split; [ reflexivity | ] ].
  exists t, m'. eapply ex_call_sound; [ | exact Hrun ].
  intros ef args m0 t0 v m1 Hw. discriminate Hw.
Qed.

(* THE RUN: the real get_mario_spawn_type on an airborne-warp object
   returns MARIO_SPAWN_AIRBORNE, over every 30-TU link. *)
Theorem spawn_type_runs : forall lp,
    linked12 lp ->
    exists m bo bw t m',
      Genv.find_symbol (globalenv lp) (id "bhvAirborneWarp") = Some bw /\
      Mem.load Mint32 m bo 524 = Some (Vptr bw Ptrofs.zero) /\
      eval_funcall function_entry2 (globalenv lp) m
        (Internal SM64.Generated.area.f_get_mario_spawn_type) [Vptr bo Ptrofs.zero] t m'
        (Vint (Int.repr MARIO_SPAWN_AIRBORNE)).
Proof.
  intros lp Hlink.
  pose proof witness_ok_true as W. unfold witness_ok in W.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in W. unfold witness_gen in W.
  destruct (build (globalenv lp) (program_of_program lp)) as [[[m bo] bw]|];
    [ | discriminate].
  destruct (check_gen_sound _ _ _ _ _ _ W) as (Hs & Hl & t & m' & Hev).
  exists m, bo, bw, t, m'. auto.
Qed.
