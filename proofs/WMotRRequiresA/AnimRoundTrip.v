(* kept: tether of TRUST.md 2.2 (the NO_SEGMENTED_MEMORY address model,
   VIRTUAL_TO_PHYSICAL family row): the anim pointer set_mario_animation
   stores is read back by the anim-sample path, which now has an execution. *)

(* ======================================================================= *)
(* FOUND 2026-10-22 (vacuity).  segmented_to_virtual is the decomp's       *)
(* NO_SEGMENTED_MEMORY identity (memory.c, TRUST 2.2), but the model kept   *)
(* the N64 VIRTUAL_TO_PHYSICAL (p - 0x80000000).  set_mario_animation       *)
(* stored the shifted pointer, segmented_to_virtual did not shift it back,  *)
(* and every read of Mario's anim sample (find_mario_anim_flags_and_        *)
(* translation, update_mario_pos_for_anim, return_mario_anim_y_translation, *)
(* the top-of-pole handlers) loaded 2^31 bytes past the buffer: NO          *)
(* CompCert execution, so both capstones were silent about those frames.    *)
(* pipeline/proof_n64.h now takes the whole NO_SEGMENTED_MEMORY macro       *)
(* family (macros.h:73-75), consistent with segmented_to_virtual.           *)
(*                                                                          *)
(* 1. `reloc_rhs_*`, `reloc_eval`: the generated set_mario_animation /      *)
(*    set_mario_anim_with_accel store, in EVERY execution, exactly          *)
(*    targetAnim + offset (same block): the relocation is the identity on   *)
(*    the pointer.                                                          *)
(* 2. `anim_y_runs`: over every linked program, the real                    *)
(*    return_mario_anim_y_translation (-> find_mario_anim_flags_and_        *)
(*    translation -> geo_update_animation_frame, segmented_to_virtual,      *)
(*    retrieve_animation_index) RUNS on a memory whose anim has values /    *)
(*    index of exactly that relocated shape, and returns the y sample / 4.  *)
(*    No external call is made (empty oracle, no world hypothesis).         *)
(* ======================================================================= *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Values AST Memory Globalenvs
  Ctypes Cop Clight ClightBigstep Events Maps.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve.
From SM64.Proofs Require Generic.ClightDeterm.
Require SM64.Generated.mario.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.

(* ----------------------------------------------------------------------- *)
(* 1. The relocation store.                                                 *)
(* ----------------------------------------------------------------------- *)
Definition reloc_rhs (t : ident) (ty : type) : expr :=
  Ecast
    (Ecast
      (Ebinop Oadd
        (Ecast (Etempvar mario._targetAnim (tptr (Tstruct mario._Animation noattr)))
          (tptr tuchar))
        (Ecast (Etempvar t ty) tuint)
        (tptr tuchar)) tuint) (tptr tvoid).

(* every rhs stored into an Animation's values / index field *)
Fixpoint reloc_stores (s : statement) : list expr :=
  match s with
  | Sassign (Efield (Ederef _ (Tstruct sn _)) f _) r =>
      if Pos.eqb sn mario._Animation
         && (Pos.eqb f mario._values || Pos.eqb f mario._index)
      then [r] else []
  | Ssequence a b => reloc_stores a ++ reloc_stores b
  | Sifthenelse _ a b => reloc_stores a ++ reloc_stores b
  | Sloop a b => reloc_stores a ++ reloc_stores b
  | Slabel _ a => reloc_stores a
  | Sswitch _ ls => reloc_stores_ls ls
  | _ => []
  end
with reloc_stores_ls (ls : labeled_statements) : list expr :=
  match ls with
  | LSnil => []
  | LScons _ a r => reloc_stores a ++ reloc_stores_ls r
  end.

Lemma reloc_rhs_set_mario_animation :
  reloc_stores (fn_body mario.f_set_mario_animation)
  = [reloc_rhs mario._t'11 (tptr tshort); reloc_rhs mario._t'10 (tptr tushort)].
Proof. vm_compute. reflexivity. Qed.

Lemma reloc_rhs_set_mario_anim_with_accel :
  exists t1 t2,
  reloc_stores (fn_body mario.f_set_mario_anim_with_accel)
  = [reloc_rhs t1 (tptr tshort); reloc_rhs t2 (tptr tushort)].
Proof. do 2 eexists. vm_compute. reflexivity. Qed.

(* In every execution the stored value is targetAnim + off, in targetAnim's
   block: VIRTUAL_TO_PHYSICAL no longer moves it.  `off` is the raw offset
   the DMA'd header held (data, so a Vint). *)
Lemma reloc_eval : forall ge e le m t ty b o off v,
    le ! mario._targetAnim = Some (Vptr b o) ->
    le ! t = Some (Vint off) ->
    (exists ty' a, ty = Tpointer ty' a) ->
    eval_expr ge e le m (reloc_rhs t ty) v ->
    v = Vptr b (Ptrofs.add o (Ptrofs.of_intu off)).
Proof.
  intros ge e le m t ty b o off v Hta Ht (ty' & a & ->) Hv.
  assert (Hev : eval_expr ge e le m (reloc_rhs t (Tpointer ty' a))
                  (Vptr b (Ptrofs.add o (Ptrofs.of_intu off)))).
  { unfold reloc_rhs.
    econstructor; [ econstructor | ].
    - econstructor.
      + econstructor; [ econstructor; exact Hta | reflexivity ].
      + econstructor; [ econstructor; exact Ht | reflexivity ].
      + cbn. unfold sem_add, classify_add. cbn.
        f_equal. f_equal. f_equal.
        rewrite Ptrofs.mul_commut. apply Ptrofs.mul_one.
    - reflexivity.
    - reflexivity. }
  exact (ClightDeterm.eval_expr_determ ge e le m _ _ _ Hv Hev).
Qed.

(* ----------------------------------------------------------------------- *)
(* 2. The anim-sample path runs.                                            *)
(* ----------------------------------------------------------------------- *)
Definition no_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) := None.

Definition externs (i : ident) : option Z :=
  if Pos.eqb i (id "gSineTable") then Some (5120 * 4) else None.

(* The anim block, laid out as the DMA buffer is after set_mario_animation:
   header (struct Animation, 24 bytes; values @12, index @16), then the
   index table at 24 (x, y, z channels: (count 1, start 0 / 1 / 2)), then
   the values at 36 (x 0, y 400, z 0).  values / index are header + offset,
   the shape `reloc_eval` stores. *)
Definition ANIM_SZ : Z := 48.
Definition OFS_IDX : Z := 24.
Definition OFS_VAL : Z := 36.
Definition Y_SAMPLE : Z := 400.
Definition Y_TRANS : Z := 100.   (* 400 / 4.0f, stored to an s16 *)

Definition opt_add (a b : option Z) : option Z :=
  match a, b with Some x, Some y => Some (x + y) | _, _ => None end.

(* obj->header.gfx.animInfo.curAnim *)
Definition cur_anim_ofs (ge : genv) : option Z :=
  opt_add (off ge "Object" "header")
   (opt_add (off ge "ObjectNode" "gfx")
     (opt_add (off ge "GraphNodeObject" "animInfo") (off ge "AnimInfo" "curAnim"))).

Definition u16 (b : block) (o v : Z) : wr := W Mint16unsigned b o (Vint (Int.repr v)).

Definition build (ge : genv) (ast : AST.program (Ctypes.fundef function) type)
    : option (mem * block * block * block * Z * Z) :=
  match alloc_globs ge externs Mem.empty (AST.prog_defs ast) with
  | Some m0 =>
      match fresh m0 ANIM_SZ with
      | Some (m1, ba) =>
      match fresh m1 (ssize ge "Object") with
      | Some (m2, bo) =>
      match fresh m2 (ssize ge "MarioState") with
      | Some (m3, bm) =>
      match off ge "MarioState" "marioObj", cur_anim_ofs ge with
      | Some om, Some oc =>
          match apply_writes m3
                  [ W Mint32 ba 12 (Vptr ba (Ptrofs.repr OFS_VAL));
                    W Mint32 ba 16 (Vptr ba (Ptrofs.repr OFS_IDX));
                    u16 ba 24 1; u16 ba 26 0; u16 ba 28 1; u16 ba 30 1;
                    u16 ba 32 1; u16 ba 34 2;
                    W Mint16signed ba 36 (Vint (Int.repr 0));
                    W Mint16signed ba 38 (Vint (Int.repr Y_SAMPLE));
                    W Mint16signed ba 40 (Vint (Int.repr 0));
                    W Mint32 bo oc (Vptr ba Ptrofs.zero);
                    W Mint32 bm om (Vptr bo Ptrofs.zero) ] 0 with
          | inl m4 => Some (m4, bm, bo, ba, om, oc)
          | inr _ => None
          end
      | _, _ => None
      end
      | None => None end
      | None => None end
      | None => None end
  | None => None
  end.

Definition FUEL : nat := Z.to_nat 5000.

Definition is_ptr (v : option val) (b : block) (o : Z) : bool :=
  match v with
  | Some (Vptr b' o') => Pos.eqb b' b && Ptrofs.eq o' (Ptrofs.repr o)
  | _ => false
  end.

Definition check_gen (fuel : nat) (f : fundef) (ge : genv) (m : mem)
    (bm bo ba : block) (om oc : Z) : bool :=
  match ex_call ge no_world fuel m f [Vptr bm Ptrofs.zero] with
  | Done _ (_, _, Vint r) =>
      Int.eq r (Int.repr Y_TRANS)
      && is_ptr (CM.load Mint32 m bm om) bo 0
      && is_ptr (CM.load Mint32 m bo oc) ba 0
      && is_ptr (CM.load Mint32 m ba 12) ba OFS_VAL
      && is_ptr (CM.load Mint32 m ba 16) ba OFS_IDX
  | _ => false
  end.

Definition witness_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match build ge ast with
      | Some (m, bm, bo, ba, om, oc) =>
          check_gen FUEL (Internal SM64.Generated.mario.f_return_mario_anim_y_translation)
            ge m bm bo ba om oc
      | None => false
      end
  | _, _ => false
  end.

Definition witness_ok : bool := witness_gen ge12 ast12.

Lemma witness_ok_true : witness_ok = true.
Proof. vm_compute. reflexivity. Qed.

Lemma is_ptr_sound : forall v b o,
    is_ptr v b o = true -> v = Some (Vptr b (Ptrofs.repr o)).
Proof.
  intros [[| | | | | b' o']|] b o H; try discriminate.
  apply andb_prop in H as [Hb Ho]. apply Pos.eqb_eq in Hb.
  apply Ptrofs.same_if_eq in Ho. subst. reflexivity.
Qed.

Lemma check_gen_sound : forall fuel f (ge : genv) m bm bo ba om oc,
    check_gen fuel f ge m bm bo ba om oc = true ->
    Mem.load Mint32 m bm om = Some (Vptr bo (Ptrofs.repr 0)) /\
    Mem.load Mint32 m bo oc = Some (Vptr ba (Ptrofs.repr 0)) /\
    Mem.load Mint32 m ba 12 = Some (Vptr ba (Ptrofs.repr OFS_VAL)) /\
    Mem.load Mint32 m ba 16 = Some (Vptr ba (Ptrofs.repr OFS_IDX)) /\
    exists t m',
      eval_funcall function_entry2 ge m f [Vptr bm Ptrofs.zero] t m'
        (Vint (Int.repr Y_TRANS)).
Proof.
  intros fuel f ge m bm bo ba om oc H. unfold check_gen in H.
  destruct (ex_call ge no_world fuel m f _) as [[[t m'] res]| ? ? ?] eqn:Hrun;
    [ | discriminate].
  destruct res; try discriminate.
  apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3].
  apply andb_prop in H as [H H2]. apply andb_prop in H as [Hr H1].
  apply Int.same_if_eq in Hr. subst i.
  rewrite CM.load_eq in H1, H2, H3, H4.
  apply is_ptr_sound in H1, H2, H3, H4.
  split; [ exact H1 | split; [ exact H2 | split; [ exact H3 | split; [ exact H4 | ]]]].
  exists t, m'. eapply ex_call_sound; [ | exact Hrun ].
  intros ef args m0 t0 v m1 Hw. discriminate Hw.
Qed.

(* THE RUN: over every linked program, the real return_mario_anim_y_
   translation on a MarioState whose marioObj's curAnim is an anim with
   values / index = header + offset (the relocated shape) returns the y
   sample / 4.  Under the old VIRTUAL_TO_PHYSICAL the stored pointers were
   header + offset - 2^31 and this path had no execution. *)
Theorem anim_y_runs : forall lp,
    linked12 lp ->
    exists m bm bo ba om oc t m',
      Mem.load Mint32 m bm om = Some (Vptr bo (Ptrofs.repr 0)) /\
      Mem.load Mint32 m bo oc = Some (Vptr ba (Ptrofs.repr 0)) /\
      Mem.load Mint32 m ba 12 = Some (Vptr ba (Ptrofs.repr OFS_VAL)) /\
      Mem.load Mint32 m ba 16 = Some (Vptr ba (Ptrofs.repr OFS_IDX)) /\
      eval_funcall function_entry2 (globalenv lp) m
        (Internal SM64.Generated.mario.f_return_mario_anim_y_translation)
        [Vptr bm Ptrofs.zero] t m' (Vint (Int.repr Y_TRANS)).
Proof.
  intros lp Hlink.
  pose proof witness_ok_true as W. unfold witness_ok in W.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in W. unfold witness_gen in W.
  destruct (build (globalenv lp) (program_of_program lp))
    as [[[[[[m bm] bo] ba] om] oc]|]; [ | discriminate].
  destruct (check_gen_sound _ _ _ _ _ _ _ _ _ W) as (H1 & H2 & H3 & H4 & t & m' & Hev).
  exists m, bm, bo, ba, om, oc, t, m'. auto.
Qed.
