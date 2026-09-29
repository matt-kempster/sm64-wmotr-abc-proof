(* spine: GOAL 2's no-A action whitelist R_noA, made concrete.            *)
(* ======================================================================= *)
(* R_noA is the set of actions Mario can be in, in WMotR, when A is never   *)
(* pressed or held: the closure from level entry over every action write    *)
(* that is not A-gated (tools/goal2_action_sites.py, `R_reach`; method and   *)
(* cross-checks in docs/goal2-rnoa-census.md; 73 actions, 12 airborne).     *)
(* The census is a tool result, not a proof: if it missed an edge, the open *)
(* row HeightFrame.Hframe_stays_noA is false, which the symbolic walk       *)
(* (docs/goal2-value-walk-plan.md) is meant to decide.  Values are the      *)
(* ACT_* defines of include/sm64.h.                                         *)
(* ======================================================================= *)

From Coq Require Import ZArith List.
From compcert Require Import Integers.
From SM64.Proofs Require Import Taint HeightInvariant.
Import ListNotations.

Local Open Scope Z_scope.

Definition R_noA_list : list Z := [
    902 (* 0x00000386 ACT_STOMACH_SLIDE_STOP *);
    1091 (* 0x00000443 ACT_TURNING_AROUND *);
    1092 (* 0x00000444 ACT_FINISH_TURNING_AROUND *);
    1356 (* 0x0000054c ACT_LEDGE_CLIMB_SLOW_1 *);
    1357 (* 0x0000054d ACT_LEDGE_CLIMB_SLOW_2 *);
    1358 (* 0x0000054e ACT_LEDGE_CLIMB_DOWN *);
    1359 (* 0x0000054f ACT_LEDGE_CLIMB_FAST *);
    2215 (* 0x000008a7 ACT_AIR_HIT_WALL *);
    4872 (* 0x00001308 ACT_READING_SIGN *);
    4874 (* 0x0000130a ACT_WAITING_FOR_DIALOG *);
    4915 (* 0x00001333 ACT_SPAWN_NO_SPIN_LANDING *);
    4925 (* 0x0000133d ACT_PUTTING_ON_CAP *);
    4977 (* 0x00001371 ACT_IN_CANNON *);
    6450 (* 0x00001932 ACT_SPAWN_NO_SPIN_AIRBORNE *);
    131898 (* 0x0002033a ACT_HEAD_STUCK_IN_GROUND *);
    131899 (* 0x0002033b ACT_BUTT_STUCK_IN_GROUND *);
    131900 (* 0x0002033c ACT_FEET_STUCK_IN_GROUND *);
    132192 (* 0x00020460 ACT_HARD_BACKWARD_GROUND_KB *);
    132193 (* 0x00020461 ACT_HARD_FORWARD_GROUND_KB *);
    132194 (* 0x00020462 ACT_BACKWARD_GROUND_KB *);
    132195 (* 0x00020463 ACT_FORWARD_GROUND_KB *);
    132198 (* 0x00020466 ACT_GROUND_BONK *);
    135953 (* 0x00021311 ACT_STANDING_DEATH *);
    135957 (* 0x00021315 ACT_DEATH_ON_STOMACH *);
    135958 (* 0x00021316 ACT_DEATH_ON_BACK *);
    1049409 (* 0x00100341 ACT_GRAB_POLE_SLOW *);
    1049410 (* 0x00100342 ACT_GRAB_POLE_FAST *);
    1049411 (* 0x00100343 ACT_CLIMBING_POLE *);
    1049412 (* 0x00100344 ACT_TOP_OF_POLE_TRANSITION *);
    1049413 (* 0x00100345 ACT_TOP_OF_POLE *);
    8389180 (* 0x0080023c ACT_GROUND_POUND_LAND *);
    8389504 (* 0x00800380 ACT_PUNCHING *);
    8389719 (* 0x00800457 ACT_MOVE_PUNCHING *);
    8389722 (* 0x0080045a ACT_SLIDE_KICK_SLIDE *);
    8390825 (* 0x008008a9 ACT_GROUND_POUND *);
    8651858 (* 0x00840452 ACT_BUTT_SLIDE *);
    8914006 (* 0x00880456 ACT_DIVE_SLIDE *);
    9176147 (* 0x008c0453 ACT_STOMACH_SLIDE *);
    16779404 (* 0x0100088c ACT_FREEFALL *);
    16779430 (* 0x010008a6 ACT_FORWARD_ROLLOUT *);
    16779437 (* 0x010008ad ACT_BACKWARD_ROLLOUT *);
    16910512 (* 0x010208b0 ACT_BACKWARD_AIR_KB *);
    16910513 (* 0x010208b1 ACT_FORWARD_AIR_KB *);
    16910518 (* 0x010208b6 ACT_SOFT_BONK *);
    25168042 (* 0x018008aa ACT_SLIDE_KICK *);
    25692298 (* 0x0188088a ACT_DIVE *);
    50333838 (* 0x0300088e ACT_BUTT_SLIDE_AIR *);
    67109952 (* 0x04000440 ACT_WALKING *);
    67109957 (* 0x04000445 ACT_BRAKING *);
    67109962 (* 0x0400044a ACT_DECELERATING *);
    67110001 (* 0x04000471 ACT_FREEFALL_LAND *);
    67142728 (* 0x04008448 ACT_CRAWLING *);
    75531353 (* 0x04808459 ACT_CROUCH_SLIDE *);
    134218277 (* 0x08000225 ACT_SLIDE_KICK_SLIDE_STOP *);
    134218571 (* 0x0800034b ACT_LEDGE_GRAB *);
    135267136 (* 0x08100340 ACT_HOLDING_POLE *);
    201327107 (* 0x0c000203 ACT_SLEEPING *);
    201327108 (* 0x0c000204 ACT_WAKING_UP *);
    201327143 (* 0x0c000227 ACT_FIRST_PERSON *);
    201327154 (* 0x0c000232 ACT_FREEFALL_LAND_STOP *);
    201327165 (* 0x0c00023d ACT_BRAKING_STOP *);
    201327166 (* 0x0c00023e ACT_BUTT_SLIDE_STOP *);
    201359904 (* 0x0c008220 ACT_CROUCHING *);
    201359905 (* 0x0c008221 ACT_START_CROUCHING *);
    201359906 (* 0x0c008222 ACT_STOP_CROUCHING *);
    201359907 (* 0x0c008223 ACT_START_CRAWLING *);
    201359908 (* 0x0c008224 ACT_STOP_CRAWLING *);
    205521409 (* 0x0c400201 ACT_IDLE *);
    205521410 (* 0x0c400202 ACT_START_SLEEPING *);
    205521413 (* 0x0c400205 ACT_PANTING *);
    205521417 (* 0x0c400209 ACT_STANDING_AGAINST_WALL *);
    205521419 (* 0x0c40020b ACT_SHIVERING *);
    536875782 (* 0x20001306 ACT_READING_NPC_DIALOG *) ].

Definition R_noA (a : int) : Prop := In (Int.unsigned a) R_noA_list.

Lemma R_noA_list_length : length R_noA_list = 73%nat.
Proof. reflexivity. Qed.

(* the height invariant's special-credit actions are all in the whitelist *)
Lemma R_noA_has_credit_rows :
  forallb (fun a => existsb (Z.eqb (Int.unsigned a)) R_noA_list)
    [ACT_FREEFALL; ACT_BUTT_SLIDE_AIR; ACT_SLIDE_KICK; ACT_GROUND_POUND;
     ACT_SPAWN_NO_SPIN_AIRBORNE; ACT_LEDGE_GRAB] = true.
Proof. vm_compute. reflexivity. Qed.

(* GOAL 1's taint set T (flying, flying triple jump, shot from cannon;
   Taint.is_tainted) is disjoint from it *)
Lemma R_noA_list_untainted :
  forallb (fun z => negb (is_tainted (Int.repr z))) R_noA_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma R_noA_not_tainted : forall a, R_noA a -> not_tainted a.
Proof.
  intros a Ha. unfold R_noA in Ha. unfold not_tainted.
  pose proof R_noA_list_untainted as H. rewrite forallb_forall in H.
  specialize (H _ Ha). rewrite Int.repr_unsigned in H.
  destruct (is_tainted a); [ discriminate | reflexivity ].
Qed.
