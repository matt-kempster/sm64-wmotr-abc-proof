(* GravitySlice.v — the thin end-to-end slice of the GOAL-2 value walk.

   UNWIRED: a de-risking slice, not yet load-bearing.  It shows the whole
   route of docs/goal2-value-walk-plan.md §4 on the smallest real function:

     generated Clight  --[Interp/SymExec: sx_call, vm_computed]-->  paths
     paths             --[sx_call_sound]-->  every real run
     every real run    --[this file]-->      the catalog's float formula

   THEOREM [apply_gravity_freefall_noA]: in ANY program that links the twelve
   TUs, a call of the real (clightgen'd) [apply_gravity] on a Mario whose
   action is ACT_FREEFALL and whose input has neither A bit set leaves
   vel[1] = [gravity f4 V] (HeightFloatSteps; the S_air Move's formula,
   including the -75 terminal clamp) and changes no other byte of memory.

   Nothing here is hand-modelled: the branch structure (wing-cap flutter,
   the flags tests, the vel<0 test, the clamp) is read off the AST by the
   executor.  The no-A premise prunes the wing branch through the executor's
   known-zero bits; the action premise decides the action switch through its
   known-values.  18 paths come back; every one writes only vel[1], with one
   of the two values fixed by its recorded clamp condition. *)

From Coq Require Import List ZArith Bool Lia.
From compcert Require Import Coqlib AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario_step.
From SM64.Proofs Require Import Interp.SymExec LinkGenv LinkedTwelve HeightInvariant
  HeightFloatSteps.
Import ListNotations.

(* INPUT_A_PRESSED (0x2) | INPUT_A_DOWN (0x80) at m->input (offset 2) *)
Definition kz0 : list (positive * Z * memory_chunk * int) :=
  [(1%positive, 2, Mint16unsigned, Int.repr 130)].
(* m->action (offset 12) = ACT_FREEFALL *)
Definition kv0 : list (positive * Z * memory_chunk * val) :=
  [(1%positive, 12, Mint32, Vint ACT_FREEFALL)].

Definition FUEL : nat := 200.
Definition tfloat : type := Tfloat Ctypes.F32 noattr.
Definition tint : type := Tint Ctypes.I32 Ctypes.Signed noattr.

(* vel[1] - 4.0f, as the executor spells it, and the clamp test on it *)
Definition TSUB : sval :=
  Sldres Mfloat32 (Scast (Sbinop Cop.Osub (Sinit 1 76 Mfloat32) tfloat
                                           (Sconst (Vsingle f4)) tfloat) tfloat tfloat).
Definition CMP : sval := Sbinop Cop.Olt TSUB tfloat (Sconst (Vsingle fm75)) tfloat.

Definition has_cond (pc : spc) (b : bool) : bool :=
  existsb (fun '(c, t, b') => (if sval_eq c CMP then true else false)
                              && (if type_eq t tint then true else false)
                              && Bool.eqb b' b) pc.

Definition grav_path_ok (p : cpath) : bool :=
  match p with
  | ([(r, o, ch, X)], pc, _) =>
      Pos.eqb r 1 && Z.eqb o 76 && (if chunk_eq ch Mfloat32 then true else false)
      && (if sval_eq X (Sconst (Vsingle fm75)) then has_cond pc true
          else if sval_eq X TSUB then has_cond pc false else false)
  | _ => false
  end.

(* The executor run on the real AST (~10 s, dominated by building ge12).
   The check is written out inline rather than behind a [Definition]: the
   kernel, asked to unfold such a constant against an abstract genv, starts
   reducing the executor itself and never finishes. *)
Lemma grav_check_ge12 :
  match ge12 with
  | Some g =>
      match sx_call g kz0 kv0 FUEL nil nil (Internal mario_step.f_apply_gravity)
                    [Sptr 1 Ptrofs.zero] with
      | Some cps => forallb grav_path_ok cps
      | None => false
      end
  | None => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma grav_path_ok_spec : forall sm pc r, grav_path_ok (sm, pc, r) = true ->
  exists X b, sm = [(1%positive, 76, Mfloat32, X)] /\ In (CMP, tint, b) pc /\
    ((b = true /\ X = Sconst (Vsingle fm75)) \/ (b = false /\ X = TSUB)).
Proof.
  intros sm pc r H.
  destruct sm as [| [[[r1 o1] ch1] X] [| ? ?]]; try discriminate.
  cbn [grav_path_ok] in H.
  destruct (Pos.eqb_spec r1 1); [ | discriminate ].
  destruct (Z.eqb_spec o1 76); [ | discriminate ].
  destruct (chunk_eq ch1 Mfloat32); [ | discriminate ]. subst. cbn in H.
  assert (HC : forall b, has_cond pc b = true -> In (CMP, tint, b) pc).
  { intros b HB. apply existsb_exists in HB. destruct HB as [[[c t] b'] [IN E]].
    destruct (sval_eq c CMP); [ | discriminate ].
    destruct (type_eq t tint); [ | discriminate ].
    apply Bool.eqb_prop in E. subst. exact IN. }
  destruct (sval_eq X (Sconst (Vsingle fm75))) as [-> | _].
  - exists (Sconst (Vsingle fm75)), true. split; [ reflexivity | ]. split; auto.
  - destruct (sval_eq X TSUB) as [-> | _]; [ | discriminate ].
    exists TSUB, false. split; [ reflexivity | ]. split; auto.
Qed.

(* region 1 is Mario's block; everything else maps to itself *)
Definition swap1 (bm : block) (r : positive) : block :=
  if Pos.eqb r 1 then bm else if Pos.eqb r bm then 1%positive else r.

Lemma swap1_inj : forall bm r r', swap1 bm r = swap1 bm r' -> r = r'.
Proof.
  intros bm r r'. unfold swap1.
  destruct (Pos.eqb_spec r 1), (Pos.eqb_spec r' 1), (Pos.eqb_spec r bm), (Pos.eqb_spec r' bm);
    intros; subst; congruence.
Qed.

Section DEN.
  Variable g : genv.
  Variable sigma : positive -> block.
  Variable m0 : mem.
  Variable V : float32.
  Hypothesis HV : Mem.load Mfloat32 m0 (sigma 1%positive) 76 = Some (Vsingle V).

  Lemma den_TSUB : den g sigma m0 TSUB = Some (Vsingle (Float32.sub V f4)).
  Proof. cbn [den TSUB]. rewrite HV. reflexivity. Qed.

  Lemma den_CMP : den g sigma m0 CMP =
    Some (Val.of_bool (Float32.cmp Clt (Float32.sub V f4) fm75)).
  Proof. unfold CMP. cbn [den]. rewrite den_TSUB. reflexivity. Qed.
End DEN.

Lemma bool_val_of_bool : forall x b m,
  bool_val (Val.of_bool x) tint m = Some b -> x = b.
Proof. intros [] b m H; cbn in H; inv H; reflexivity. Qed.

(* Stated over an arbitrary option, so the kernel only ever matches the run
   syntactically and never reduces it on an abstract genv. *)
Lemma check_spec : forall (o : option (list cpath)),
  (match o with Some cps => forallb grav_path_ok cps | None => false end) = true ->
  exists cps, o = Some cps /\ forallb grav_path_ok cps = true.
Proof. intros [cps|] H; [ eauto | discriminate ]. Qed.

(* the per-run semantics, for any genv on which the executor succeeded *)
Lemma grav_run_sound : forall g cps,
  sx_call g kz0 kv0 FUEL nil nil (Internal mario_step.f_apply_gravity) [Sptr 1 Ptrofs.zero] = Some cps -> forallb grav_path_ok cps = true ->
  forall bm m inp V t m' vres,
    Mem.load Mint32 m bm 12 = Some (Vint ACT_FREEFALL) ->
    Mem.load Mint16unsigned m bm 2 = Some (Vint inp) ->
    Int.and inp (Int.repr 130) = Int.zero ->
    Mem.load Mfloat32 m bm 76 = Some (Vsingle V) ->
    eval_funcall function_entry2 g m (Internal mario_step.f_apply_gravity)
                 [Vptr bm Ptrofs.zero] t m' vres ->
    Mem.load Mfloat32 m' bm 76 = Some (Vsingle (gravity f4 V))
    /\ (forall b o ch, b <> bm \/ o + size_chunk ch <= 76 \/ 80 <= o ->
          Mem.load ch m' b o = Mem.load ch m b o).
Proof.
  intros g cps SX C bm m inp V t m' vres HA HI HNA HV EV.
  set (sigma := swap1 bm).
  assert (S1 : sigma 1%positive = bm) by reflexivity.
  assert (KZ : forall r o ch mask, In (r, o, ch, mask) kz0 ->
            exists i, Mem.load ch m (sigma r) o = Some (Vint i) /\ Int.and i mask = Int.zero).
  { intros r o ch mask IN. destruct IN as [E | []]. injection E as <- <- <- <-.
    rewrite S1. eauto. }
  assert (KV : forall r o ch v, In (r, o, ch, v) kv0 -> Mem.load ch m (sigma r) o = Some v).
  { intros r o ch v IN. destruct IN as [E | []]. injection E as <- <- <- <-.
    rewrite S1. exact HA. }
  assert (ARGS : Forall2 (fun a v => den g sigma m a = Some v)
                   [Sptr 1 Ptrofs.zero] [Vptr bm Ptrofs.zero]).
  { constructor; [ | constructor ]. cbn [den]. rewrite S1. reflexivity. }
  destruct (sx_call_sound g kz0 kv0 sigma (swap1_inj bm) m KZ KV
              FUEL nil nil _ _ cps m _ t m' vres SX ARGS (MM_init _ _ _) EV)
    as (sm' & pc' & r & IN & (MMt & Fr & _ & PC) & _).
  rewrite forallb_forall in C. apply C in IN.
  destruct (grav_path_ok_spec _ _ _ IN) as (X & b & -> & INC & HX).
  rewrite <- S1 in HV.
  pose proof (proj1 (Forall_forall _ _) PC _ INC) as (v & DV & BV).
  rewrite (den_CMP _ _ _ _ HV) in DV. injection DV as <-. apply bool_val_of_bool in BV.
  split.
  - rewrite <- S1, (MMt 1%positive 76 Mfloat32 X (or_introl eq_refl)).
    unfold gravity. rewrite BV.
    destruct HX as [[-> ->] | [-> ->]]; [ reflexivity | apply den_TSUB; exact HV ].
  - intros b0 o ch NO. apply Fr. intros r0 E.
    cbn [filter ovl]. unfold sigma, swap1 in E.
    destruct (r0 =? 1)%positive; [ | reflexivity ]. cbn [andb size_chunk].
    destruct NO as [NO | NO]; [ congruence | ].
    destruct (Z.ltb_spec o (76 + 4)), (Z.ltb_spec 76 (o + size_chunk ch)); try reflexivity.
    lia.
Qed.

Theorem apply_gravity_freefall_noA :
  forall lp, linked12 lp ->
  forall bm m inp V t m' vres,
    Mem.load Mint32 m bm 12 = Some (Vint ACT_FREEFALL) ->
    Mem.load Mint16unsigned m bm 2 = Some (Vint inp) ->
    Int.and inp (Int.repr 130) = Int.zero ->
    Mem.load Mfloat32 m bm 76 = Some (Vsingle V) ->
    eval_funcall function_entry2 (globalenv lp) m (Internal mario_step.f_apply_gravity)
                 [Vptr bm Ptrofs.zero] t m' vres ->
    Mem.load Mfloat32 m' bm 76 = Some (Vsingle (gravity f4 V))
    /\ (forall b o ch, b <> bm \/ o + size_chunk ch <= 76 \/ 80 <= o ->
          Mem.load ch m' b o = Mem.load ch m b o).
Proof.
  intros lp L.
  pose proof grav_check_ge12 as C. rewrite (ge12_ok lp L) in C.
  destruct (check_spec _ C) as (cps & SX & OK).
  exact (grav_run_sound _ cps SX OK).
Qed.
