(* ====================================================================== *)
(* RetOk (GOAL 2): what an airborne handler's return value says.          *)
(*                                                                        *)
(* execute_mario_action loops while the action handler returns TRUE       *)
(* (mario.c: `while (inLoop) switch ... inLoop = handler(m)`), with no   *)
(* new floor refresh in between: the floor update_mario_inputs found is   *)
(* the one the next handler sees.  So a handler that returns nonzero must *)
(* leave Mario's height and floorHeight a floor refresh again.  The walk  *)
(* checks it syntactically on each outcome (ret_ok): the return value is  *)
(* the constant 0 (`return FALSE`), or pos[1] and floorHeight are the     *)
(* entry's cells, unchanged (`return set_mario_action(...)` before the    *)
(* air step).  ret_sound turns that into RET on the real memories.        *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant.
From SM64.Proofs.WMotRRequiresA Require Import AirMatch.
Import ListNotations.

(* an outcome's return value is FALSE, or its pos[1] and floorHeight cells
   are the entry's *)
Definition same_cell_ret (nbase : positive) (R0 : list (positive * Z))
    (kv : list (positive * Z * memory_chunk * sval)) (rM : positive) (g : gst) (o : Z) : bool :=
  match sload nbase R0 kv g rM o Mfloat32 with
  | Some a => sveqb a (init_cell kv rM o Mfloat32)
  | None => false
  end.

Definition ret_ok (nbase : positive) (R0 : list (positive * Z))
    (kv : list (positive * Z * memory_chunk * sval)) (rM : positive) (c : cpath) : bool :=
  match snd c with
  | Sconst (Vint i) => Int.eq i Int.zero
  | _ => false
  end
  || (same_cell_ret nbase R0 kv rM (fst c) oY && same_cell_ret nbase R0 kv rM (fst c) oF).

(* the handler returned FALSE, or kept Mario's height and floorHeight *)
Definition RET (bm : block) (m0 m' : mem) (vres : val) : Prop :=
  vres = Vint Int.zero
  \/ (Mem.load Mfloat32 m' bm OFS_POSY = Mem.load Mfloat32 m0 bm OFS_POSY
      /\ Mem.load Mfloat32 m' bm OFS_FLOORH = Mem.load Mfloat32 m0 bm OFS_FLOORH).

Section SOUND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM : positive) (E : senv) (m : mem) (g : gst).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HbM : e_base E rM = Ptrofs.zero.

Lemma same_cell_ret_sound : forall o, same_cell_ret nbase R0 kv rM g o = true ->
  Mem.load Mfloat32 m (e_blk E rM) o = Mem.load Mfloat32 m0 (e_blk E rM) o.
Proof.
  intros o H. unfold same_cell_ret in H.
  destruct (sload nbase R0 kv g rM o Mfloat32) as [a|] eqn:L; [| discriminate H].
  apply sveqb_eq in H. subst a.
  assert (AM : addr E rM o = o) by (unfold addr; rewrite HbM, Ptrofs.unsigned_zero; reflexivity).
  pose proof (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                       E m g rM o Mfloat32 _ MM L)) as S.
  destruct MM as (EO & _).
  pose proof (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E rM o Mfloat32 EO)) as I.
  rewrite AM in S, I. rewrite S, I. reflexivity.
Qed.

Theorem ret_sound : forall r vres,
  den ge m0 E r = Some vres -> ret_ok nbase R0 kv rM (g, r) = true ->
  RET (e_blk E rM) m0 m vres.
Proof.
  intros r vres D H. unfold ret_ok in H. cbn [fst snd] in H.
  apply orb_true_iff in H as [H | H].
  - left. destruct r as [v | | | | | | | | |]; try discriminate H.
    destruct v; try discriminate H. apply Int.same_if_eq in H. subst i.
    cbn [den] in D. injection D as <-. reflexivity.
  - right. apply andb_true_iff in H as [Y F].
    split; [exact (same_cell_ret_sound oY Y) | exact (same_cell_ret_sound oF F)].
Qed.
End SOUND.
