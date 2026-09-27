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

(* -----------------------------------------------------------------------  *)
(* 1. Field offsets, pinned against mario.prog's own composite env.         *)
(*    (types.h comments: actionState 0x18, actionTimer 0x1A, vel 0x48,      *)
(*    floorHeight 0x70; pos 0x3C is pinned in HeightFrame.v.)               *)
(* -----------------------------------------------------------------------  *)
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

(* MarioState.marioObj (a struct Object * ) @ 136, and inside struct Object
   header.gfx.pos @ 0 + 0 + 32, so gfx.pos[1] @ 36.  gfx.pos is the position
   the OOB recovery copies back into pos (mario.c:1328); every air / ground
   step and set_pole_position re-sync it from pos. *)
Lemma mario_marioObj_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
    = Errors.OK (136, Full).
Proof. vm_compute. reflexivity. Qed.

Definition members_of (id : ident) : members :=
  match (prog_comp_env mario.prog) ! id with Some co => co_members co | None => nil end.

Lemma gfx_pos_offsets_concrete :
  field_offset (prog_comp_env mario.prog) mario._header (members_of mario._Object)
    = Errors.OK (0, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._gfx (members_of mario._ObjectNode)
    = Errors.OK (0, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._pos (members_of mario._GraphNodeObject)
    = Errors.OK (32, Full).
Proof. vm_compute. auto. Qed.

Definition OFS_MARIOOBJ : Z := 136.
Definition OFS_GFXY     : Z := 36.     (* header 0 + gfx 0 + pos 32 + 4 *)

(* -----------------------------------------------------------------------  *)
(* 2. Action constants, pinned to the real dispatch tables: each literal is *)
(*    the switch label whose case calls the named handler.  (Header         *)
(*    comments can be stale -- Flying.v found one -- so the AST decides.)   *)
(* -----------------------------------------------------------------------  *)
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

(* -----------------------------------------------------------------------  *)
(* 3. The budget.                                                           *)
(* -----------------------------------------------------------------------  *)
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
   need no allowance.  (Unwired/HeightFloatSteps.v proves the frame lemma.) *)
Definition EPS : R := 1 / 64.

(* ballistic headroom: energy plus allowance while rising, 0 once descending *)
Definition rise_credit (g v : R) : R :=
  if Rle_dec v 0 then 0 else energy g v + EPS * (v / g + 1).

(* post-bounce slide kick: the SIGNED energy (it must stay informative on the
   way down), with the allowance counted until the -75 clamp, plus 1/4 while
   v > -1: a ceiling bonk at 0 <= v < 2 zeroes vel (mario_step.c:446-452),
   and gravity then gives v' = -2, whose signed energy 1/4 the old v may not
   have carried (energy 2 v - v = (v-1)^2/4). *)
Definition SK_BONK : R := 1 / 4.
Definition sk_bounced_credit (v : R) : R :=
  energy 2 v + EPS * Rmax 0 ((v + 75) / 2 + 1)
  + (if Rle_dec v (-1) then 0 else SK_BONK).

(* ground-pound windup still to come: sum_{t=tm}^{9} (20 - 2t) = n(n+1),
   n = 10 - tm (act_ground_pound, mario_actions_airborne.c:925-929), plus EPS
   per windup frame left: each frame rounds pos[1] += yOffset in binary32. *)
Definition windup_left (tm : Z) : R :=
  if Z.leb 10 tm then 0 else IZR ((10 - tm) * (11 - tm)) + EPS * IZR (10 - tm).

(* the Z -> ground-pound reserve: windup_left 0 = 110 + 10/64 <= 111        *)
Definition GP_RESERVE : R := 111.

Definition credit (a : int) (st tm : Z) (v : R) : R :=
  if Int.eq a ACT_FREEFALL then rise_credit 4 v + GP_RESERVE
  else if Int.eq a ACT_BUTT_SLIDE_AIR then rise_credit 4 v + GP_RESERVE
  else if Int.eq a ACT_SLIDE_KICK then
         (if Z.eqb st 0 then rise_credit 2 v + GP_RESERVE else sk_bounced_credit v)
  else if Int.eq a ACT_GROUND_POUND then
         (if Z.eqb st 0 then windup_left tm else 0)
  else if is_air a then rise_credit 4 v
  else PHI_A.                      (* grounded / anchored: y <= K *)

(* ---- nonnegativity: every credit is headroom, never debt -------------   *)

Lemma energy_nonneg : forall g v, 0 < g -> 0 <= energy g v.
Proof.
  intros g v Hg. unfold energy, Rdiv.
  apply Rmult_le_pos; [ apply pow2_ge_0 | ].
  left. apply Rinv_0_lt_compat. lra.
Qed.

Lemma rise_credit_nonneg : forall g v, 0 < g -> 0 <= rise_credit g v.
Proof.
  intros g v Hg. unfold rise_credit. destruct (Rle_dec v 0); [ lra | ].
  pose proof (energy_nonneg g v Hg).
  assert (0 <= v / g)
    by (unfold Rdiv; apply Rmult_le_pos; [ lra | left; apply Rinv_0_lt_compat; lra ]).
  unfold EPS. nra.
Qed.

Lemma sk_bounced_credit_nonneg : forall v, 0 <= sk_bounced_credit v.
Proof.
  intros v. unfold sk_bounced_credit, SK_BONK.
  pose proof (energy_nonneg 2 v ltac:(lra)).
  pose proof (Rmax_l 0 ((v + 75) / 2 + 1)).
  destruct (Rle_dec v (-1)); unfold EPS; nra.
Qed.

Lemma windup_left_nonneg : forall tm, 0 <= windup_left tm.
Proof.
  intros tm. unfold windup_left. destruct (Z.leb_spec 10 tm); [ lra | ].
  assert (0 <= IZR ((10 - tm) * (11 - tm))) by (apply IZR_le; apply Z.mul_nonneg_nonneg; lia).
  assert (0 <= IZR (10 - tm)) by (apply IZR_le; lia).
  unfold EPS. nra.
Qed.

Lemma credit_nonneg : forall a st tm v, 0 <= credit a st tm v.
Proof.
  intros a st tm v.
  assert (H4 : 0 <= rise_credit 4 v) by (apply rise_credit_nonneg; lra).
  assert (H2 : 0 <= rise_credit 2 v) by (apply rise_credit_nonneg; lra).
  pose proof (sk_bounced_credit_nonneg v) as E2.
  pose proof (windup_left_nonneg tm) as HW.
  unfold credit, GP_RESERVE, PHI_A.
  destruct (Int.eq a ACT_FREEFALL); [ lra | ].
  destruct (Int.eq a ACT_BUTT_SLIDE_AIR); [ lra | ].
  destruct (Int.eq a ACT_SLIDE_KICK); [ destruct (Z.eqb st 0); lra | ].
  destruct (Int.eq a ACT_GROUND_POUND); [ destruct (Z.eqb st 0); lra | ].
  destruct (is_air a); lra.
Qed.

(* -----------------------------------------------------------------------  *)
(* 4. The cells Phi reads, and Phi's numeric part over them (pure).         *)
(* -----------------------------------------------------------------------  *)
Notation R2 := (Binary.B2R 24 128).
Notation F32 := (Binary.is_finite 24 128).

Record cells := mkCells {
  c_action  : int;        (* action          @ 12,  Mint32 *)
  c_state : int;        (* actionState     @ 24,  u16    *)
  c_timer : int;        (* actionTimer     @ 26,  u16    *)
  c_posy  : float32;    (* pos[1]          @ 64          *)
  c_vely  : float32;    (* vel[1]          @ 76          *)
  c_floorh : float32;    (* floorHeight     @ 112         *)
  c_gfxy : float32     (* marioObj->header.gfx.pos[1]   *)
}.

Definition state_of (c : cells) : Z := Int.unsigned (c_state c).
Definition timer_of (c : cells) : Z := Int.unsigned (c_timer c).
Definition credit_of (c : cells) : R := credit (c_action c) (state_of c) (timer_of c) (R2 (c_vely c)).

(* the ranges: finiteness, the death plane (collision.inc.c: -8191, and
   steps clamp pos to floorHeight), terminal / launch velocity
   (docs/goal2-vel-y-bounds.md: -75 <= vel[1] <= 100 under no-A in WMotR) *)
Definition InRange (c : cells) : Prop :=
  F32 (c_posy c) = true /\ F32 (c_vely c) = true /\ F32 (c_gfxy c) = true
  /\ -8192 <= R2 (c_posy c) /\ -8192 <= R2 (c_gfxy c)
  /\ -75 <= R2 (c_vely c) <= 128.

Definition budget_ok (c : cells) : Prop :=
  InRange c
  (* the budget, at pos and at the gfx position OOB recovery restores *)
  /\ R2 (c_posy c) + credit_of c <= PHI_K + PHI_A
  /\ R2 (c_gfxy c) + credit_of c <= PHI_K + PHI_A
  (* slide kick: vel falls 2 per actionTimer tick from <= 37.5 (launch 12,
     bounce <= 37.5, both reset the timer), up to binary32 rounding, until
     the -75 clamp; so its ->FREEFALL edge (timer > 30) fires descending *)
  /\ (c_action c = ACT_SLIDE_KICK ->
        R2 (c_vely c) + 2 * IZR (timer_of c) <= 37.5 + IZR (timer_of c) / 1024
        \/ R2 (c_vely c) <= -73)
  (* ground pound past the windup falls (state 0 sets vel -50 each frame) *)
  /\ (c_action c = ACT_GROUND_POUND -> state_of c <> 0%Z -> R2 (c_vely c) <= 0)
  (* a grabbed ledge is a laddered floor *)
  /\ (c_action c = ACT_LEDGE_GRAB -> R2 (c_floorh c) <= PHI_K).

Lemma budget_ok_y : forall c, budget_ok c -> R2 (c_posy c) <= PHI_YMAX.
Proof.
  intros c (_ & Hb & _). unfold credit_of in Hb.
  pose proof (credit_nonneg (c_action c) (state_of c) (timer_of c) (R2 (c_vely c))).
  unfold PHI_YMAX. lra.
Qed.

(* -----------------------------------------------------------------------  *)
(* 5. Phi over memory.                                                      *)
(* -----------------------------------------------------------------------  *)
Section Phi.
  Variable bm : block.            (* Mario's MarioState block *)
  (* The no-A action whitelist (docs/goal2-rnoa-census.md: 73 actions, 12
     airborne).  A PARAMETER of the capstone; the frame rows say one real
     frame keeps the action in it. *)
  Variable R_noA : int -> Prop.

  Definition read_cells (m : mem) (c : cells) : Prop :=
    Mem.load Mint32 m bm OFS_ACTION = Some (Vint (c_action c))
    /\ Mem.load Mint16unsigned m bm OFS_ASTATE = Some (Vint (c_state c))
    /\ Mem.load Mint16unsigned m bm OFS_ATIMER = Some (Vint (c_timer c))
    /\ Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle (c_posy c))
    /\ Mem.load Mfloat32 m bm OFS_VELY = Some (Vsingle (c_vely c))
    /\ Mem.load Mfloat32 m bm OFS_FLOORH = Some (Vsingle (c_floorh c))
    /\ exists bo oo,
         Mem.load Mptr m bm OFS_MARIOOBJ = Some (Vptr bo oo)
         /\ Mem.load Mfloat32 m bo (Ptrofs.unsigned oo + OFS_GFXY)
              = Some (Vsingle (c_gfxy c)).

  Definition height_invariant (m : mem) : Prop :=
    action_sat R_noA m bm /\ exists c, read_cells m c /\ budget_ok c.

  (* ---- Hphi_y: the invariant bounds the height ------------------------- *)
  Theorem height_invariant_y :
    forall m, height_invariant m ->
      forall v, Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle v) ->
                (B2R _ _ v <= PHI_YMAX)%R.
  Proof.
    intros m (_ & c & (_ & _ & _ & Hy & _) & Hc) v Hl.
    rewrite Hy in Hl. injection Hl as <-. exact (budget_ok_y c Hc).
  Qed.
End Phi.
