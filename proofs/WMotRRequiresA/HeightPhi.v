(* ======================================================================= *)
(* GOAL 2: the height invariant Phi, over real MarioState fields.           *)
(* (design + numbers: docs/goal2-phi.md, tools/goal2_budget.py)             *)
(*                                                                          *)
(* Phi m says: Mario's action is in the no-A whitelist R_noA, and           *)
(*     pos[1] + credit(action, actionState, actionTimer, vel[1]) <= K + A   *)
(* where credit >= 0 is the height the current mode can still gain:         *)
(* ballistic headroom, the ground-pound reserve / windup left, or -- for    *)
(* grounded and anchored modes -- the whole budget A (so y <= K there).     *)
(* Plus the side facts the bounces and the ledge need.                      *)
(*                                                                          *)
(*   K = H* = 2372   the floor-ladder fixpoint (tools/goal2_ladder.py,      *)
(*                   entry-seeded; level data, not yet in generated/)       *)
(*   A = 372         the no-A budget: slide-kick bounce apex 370.5625 in    *)
(*                   the energy form, plus the binary32 rounding allowance  *)
(*                   EPS per remaining ascent frame (0.89 at the bounce)    *)
(*                                                                          *)
(* K and A are plain numbers in a DEFINITION.  They carry no trust by       *)
(* themselves: a wrong number makes Hseg_action_phi (preservation) false,   *)
(* never the capstone unsound.  Hphi_y (Phi => y <= K + A) is PROVED here.  *)
(* ======================================================================= *)

From Coq Require Import ZArith List Reals Lra Lia.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Ctypes Clight.
From SM64.Generated Require mario mario_actions_airborne mario_actions_cutscene
  mario_actions_automatic.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame.
Import ListNotations.

(* ----------------------------------------------------------------------- *)
(* 1. Field offsets, pinned against mario.prog's own composite env.         *)
(*    (types.h comments: actionState 0x18, actionTimer 0x1A, vel 0x48,       *)
(*    floorHeight 0x70; pos 0x3C is pinned in HeightFrame.v.)               *)
(* ----------------------------------------------------------------------- *)
Lemma mario_actionState_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._actionState mario_state_members
    = Errors.OK (24, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_actionTimer_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._actionTimer mario_state_members
    = Errors.OK (26, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_vel_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._vel mario_state_members
    = Errors.OK (72, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_floorHeight_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._floorHeight mario_state_members
    = Errors.OK (112, Full).
Proof. vm_compute. reflexivity. Qed.

Definition OFS_ACTION : Z := 12.
Definition OFS_ASTATE : Z := 24.
Definition OFS_ATIMER : Z := 26.
Definition OFS_POSY   : Z := 64.    (* pos 60 + 4 *)
Definition OFS_VELY   : Z := 76.    (* vel 72 + 4 *)
Definition OFS_FLOORH : Z := 112.

(* ----------------------------------------------------------------------- *)
(* 2. Action constants, pinned to the real dispatch tables: each literal is *)
(*    the switch label whose case calls the named handler.  (Header         *)
(*    comments can be stale -- Flying.v found one -- so the AST decides.)   *)
(* ----------------------------------------------------------------------- *)
Fixpoint first_call (s : statement) : option ident :=
  match s with
  | Scall _ (Evar id _) _ => Some id
  | Ssequence a b =>
      match first_call a with Some x => Some x | None => first_call b end
  | _ => None
  end.

Fixpoint case_target (ls : labeled_statements) (n : Z) : option ident :=
  match ls with
  | LSnil => None
  | LScons (Some k) s rest =>
      if Z.eqb k n then first_call s else case_target rest n
  | LScons None _ rest => case_target rest n
  end.

Fixpoint switch_target (s : statement) (n : Z) : option ident :=
  match s with
  | Sswitch _ ls => case_target ls n
  | Ssequence a b | Sifthenelse _ a b | Sloop a b =>
      match switch_target a n with Some x => Some x | None => switch_target b n end
  | Slabel _ a => switch_target a n
  | _ => None
  end.

Definition ACT_FREEFALL       : int := Int.repr 16779404.   (* 0x0100088C *)
Definition ACT_BUTT_SLIDE_AIR : int := Int.repr 50333838.   (* 0x0300088E *)
Definition ACT_SLIDE_KICK     : int := Int.repr 25168042.   (* 0x018008AA *)
Definition ACT_GROUND_POUND   : int := Int.repr 8390825.    (* 0x008008A9 *)
Definition ACT_SPAWN_NO_SPIN_AIRBORNE : int := Int.repr 6450. (* 0x00001932 *)
Definition ACT_LEDGE_GRAB     : int := Int.repr 134218571.  (* 0x0800034B *)

Lemma freefall_dispatch :
  switch_target (fn_body mario_actions_airborne.f_mario_execute_airborne_action)
    16779404 = Some mario_actions_airborne._act_freefall.
Proof. vm_compute. reflexivity. Qed.

Lemma butt_slide_air_dispatch :
  switch_target (fn_body mario_actions_airborne.f_mario_execute_airborne_action)
    50333838 = Some mario_actions_airborne._act_butt_slide_air.
Proof. vm_compute. reflexivity. Qed.

Lemma slide_kick_dispatch :
  switch_target (fn_body mario_actions_airborne.f_mario_execute_airborne_action)
    25168042 = Some mario_actions_airborne._act_slide_kick.
Proof. vm_compute. reflexivity. Qed.

Lemma ground_pound_dispatch :
  switch_target (fn_body mario_actions_airborne.f_mario_execute_airborne_action)
    8390825 = Some mario_actions_airborne._act_ground_pound.
Proof. vm_compute. reflexivity. Qed.

Lemma spawn_airborne_dispatch :
  switch_target (fn_body mario_actions_cutscene.f_mario_execute_cutscene_action)
    6450 = Some mario_actions_cutscene._act_spawn_no_spin_airborne.
Proof. vm_compute. reflexivity. Qed.

Lemma ledge_grab_dispatch :
  switch_target (fn_body mario_actions_automatic.f_mario_execute_automatic_action)
    134218571 = Some mario_actions_automatic._act_ledge_grab.
Proof. vm_compute. reflexivity. Qed.

(* ACT_FLAG_AIR = 1 << 11 (sm64.h:151); set in every airborne action id,
   including ACT_SPAWN_NO_SPIN_AIRBORNE; clear in ACT_LEDGE_GRAB. *)
Definition is_air (a : int) : bool :=
  negb (Int.eq (Int.and a (Int.repr 2048)) Int.zero).

Lemma air_flag_facts :
  is_air ACT_FREEFALL = true /\ is_air ACT_SPAWN_NO_SPIN_AIRBORNE = true
  /\ is_air ACT_LEDGE_GRAB = false.
Proof. vm_compute. auto. Qed.

(* ----------------------------------------------------------------------- *)
(* 3. The budget.                                                           *)
(* ----------------------------------------------------------------------- *)
Local Open Scope R_scope.

Definition PHI_K : R := 2372.
Definition PHI_A : R := 372.
Definition PHI_YMAX : R := PHI_K + PHI_A.    (* 2744 < 3140 - 160 = 2980 *)

(* energy_g v = (v + g/2)^2 / (2g): exactly conserved by a frame
   y += v; v -= g   (energy g (v - g) = energy g v - v). *)
Definition energy (g v : R) : R := (v + g / 2) ^ 2 / (2 * g).

(* Rounding allowance.  Real arithmetic conserves y + energy exactly, but
   each binary32 frame (4 roundings of pos += vel/4, one of vel -= g) can add
   up to ~1/128 while Mario rises.  A per-frame invariant cannot absorb that
   repeatedly, so the credit carries EPS for every frame of ascent left
   (v/g + 1).  Descending frames round DOWN-safely (y' <= y exactly), so they
   need no allowance.  (Unwired/HeightBallistic.v proves the frame lemma.) *)
Definition EPS : R := 1 / 64.

(* ballistic headroom: energy plus allowance while rising, 0 once descending *)
Definition bal (g v : R) : R :=
  if Rle_dec v 0 then 0 else energy g v + EPS * (v / g + 1).

(* post-bounce slide kick: the SIGNED energy (it must stay informative on the
   way down), with the allowance counted until the -75 clamp *)
Definition sk1_credit (v : R) : R :=
  energy 2 v + EPS * Rmax 0 ((v + 75) / 2 + 1).

(* ground-pound windup still to come: sum_{t=tm}^{9} (20 - 2t) = n(n+1),
   n = 10 - tm (act_ground_pound, mario_actions_airborne.c:925-929) *)
Definition windup_left (tm : Z) : R :=
  if Z.leb 10 tm then 0 else IZR ((10 - tm) * (11 - tm)).

Definition GP_RESERVE : R := 110.

Definition credit (a : int) (st tm : Z) (v : R) : R :=
  if Int.eq a ACT_FREEFALL then bal 4 v + GP_RESERVE
  else if Int.eq a ACT_BUTT_SLIDE_AIR then bal 4 v + GP_RESERVE
  else if Int.eq a ACT_SLIDE_KICK then
         (if Z.eqb st 0 then bal 2 v + GP_RESERVE else sk1_credit v)
  else if Int.eq a ACT_GROUND_POUND then
         (if Z.eqb st 0 then windup_left tm else 0)
  else if is_air a then bal 4 v
  else PHI_A.                      (* grounded / anchored: y <= K *)

(* ----------------------------------------------------------------------- *)
(* 4. Phi.                                                                  *)
(* ----------------------------------------------------------------------- *)
Section Phi.
  Variable bm : block.            (* Mario's MarioState block *)
  (* The no-A action whitelist (docs/goal2-phi.md §3.1).  A PARAMETER:
     E3's airborne node table + the ground/automatic census, not yet
     written down.  Hseg_action_phi is false without it (phantom forall). *)
  Variable R_noA : int -> Prop.

  Definition Phi_wmotr (m : mem) : Prop :=
    action_sat R_noA m bm /\
    exists a st tm y v fh,
      Mem.load Mint32 m bm OFS_ACTION = Some (Vint a)
      /\ Mem.load Mint16unsigned m bm OFS_ASTATE = Some (Vint st)
      /\ Mem.load Mint16unsigned m bm OFS_ATIMER = Some (Vint tm)
      /\ Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle y)
      /\ Mem.load Mfloat32 m bm OFS_VELY = Some (Vsingle v)
      /\ Mem.load Mfloat32 m bm OFS_FLOORH = Some (Vsingle fh)
      /\ is_finite _ _ y = true /\ is_finite _ _ v = true
      (* the budget *)
      /\ B2R _ _ y + credit a (Int.unsigned st) (Int.unsigned tm) (B2R _ _ v)
           <= PHI_K + PHI_A
      (* terminal velocity (apply_gravity clamps at -75): bounds the bounces *)
      /\ -75 <= B2R _ _ v
      (* post-bounce slide kick: vel falls 2 per actionTimer tick from <= 37.5,
         so its ->FREEFALL edge (timer > 30) fires descending *)
      /\ (a = ACT_SLIDE_KICK -> Int.unsigned st <> 0%Z ->
            B2R _ _ v + 2 * IZR (Int.unsigned tm) <= 37.5)
      (* a grabbed ledge is a laddered floor *)
      /\ (a = ACT_LEDGE_GRAB -> B2R _ _ fh <= PHI_K).

  (* ---- Hphi_y: the invariant bounds the height ------------------------- *)

  Lemma energy_nonneg : forall g v, 0 < g -> 0 <= energy g v.
  Proof.
    intros g v Hg. unfold energy, Rdiv.
    apply Rmult_le_pos; [ apply pow2_ge_0 | ].
    left. apply Rinv_0_lt_compat. lra.
  Qed.

  Lemma bal_nonneg : forall g v, 0 < g -> 0 <= bal g v.
  Proof.
    intros g v Hg. unfold bal. destruct (Rle_dec v 0); [ lra | ].
    pose proof (energy_nonneg g v Hg).
    assert (0 <= v / g)
      by (unfold Rdiv; apply Rmult_le_pos; [ lra | left; apply Rinv_0_lt_compat; lra ]).
    unfold EPS. nra.
  Qed.

  Lemma sk1_credit_nonneg : forall v, 0 <= sk1_credit v.
  Proof.
    intros v. unfold sk1_credit.
    pose proof (energy_nonneg 2 v ltac:(lra)).
    pose proof (Rmax_l 0 ((v + 75) / 2 + 1)).
    unfold EPS. nra.
  Qed.

  Lemma windup_left_nonneg : forall tm, 0 <= windup_left tm.
  Proof.
    intros tm. unfold windup_left. destruct (Z.leb_spec 10 tm); [ lra | ].
    apply IZR_le. apply Z.mul_nonneg_nonneg; lia.
  Qed.

  Lemma credit_nonneg : forall a st tm v, 0 <= credit a st tm v.
  Proof.
    intros a st tm v.
    assert (H4 : 0 <= bal 4 v) by (apply bal_nonneg; lra).
    assert (H2 : 0 <= bal 2 v) by (apply bal_nonneg; lra).
    pose proof (sk1_credit_nonneg v) as E2.
    pose proof (windup_left_nonneg tm) as HW.
    unfold credit, GP_RESERVE, PHI_A.
    destruct (Int.eq a ACT_FREEFALL); [ lra | ].
    destruct (Int.eq a ACT_BUTT_SLIDE_AIR); [ lra | ].
    destruct (Int.eq a ACT_SLIDE_KICK); [ destruct (Z.eqb st 0); lra | ].
    destruct (Int.eq a ACT_GROUND_POUND); [ destruct (Z.eqb st 0); lra | ].
    destruct (is_air a); lra.
  Qed.

  Theorem Phi_wmotr_y :
    forall m, Phi_wmotr m ->
      forall v, Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle v) ->
                (B2R _ _ v <= PHI_YMAX)%R.
  Proof.
    intros m (_ & a & st & tm & y & vy & fh & _ & _ & _ & Hy & _ & _ & _ & _
              & Hbud & _) v Hl.
    rewrite Hy in Hl. injection Hl as <-.
    pose proof (credit_nonneg a (Int.unsigned st) (Int.unsigned tm) (B2R _ _ vy)).
    unfold PHI_YMAX. lra.
  Qed.
End Phi.
