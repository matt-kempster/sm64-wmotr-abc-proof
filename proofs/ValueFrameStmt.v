(* ValueFrameStmt.v -- THE STATEMENT-LEVEL BUNDLE FRAME (the assembly).
 *
 * ActionValueFrame.exec_stmt_value_preserves already threads {valid, action_sat}
 * through a whole statement (calls/loops/switch included), consuming a per-Sassign
 * obligation stmt_value_ok quantified `forall le m`. That obligation is FALSE for
 * chase stores `p->..f = rhs`: under an arbitrary le, p could point INTO Mario's
 * block bm. ValueFrameINV's engine fixed that by threading a temp-provenance
 * invariant tmps_off_bm at RUNTIME -- but that means the invariant must be threaded
 * THROUGH the statement induction, not assumed once. This file does that: a fresh
 * induction over exec_stmt carrying the 4-part bundle
 *
 *     Mem.valid_block m bm  /\  action_sat Q m bm
 *  /\ tmps_off_bm bm _m le  /\  mem_wf FS m bm
 *
 * (mem_wf = "the chased pointer fields FS all load off-bm in m" -- what re-creates
 * tmps_off_bm at each chase-LOAD Sset). The chase-store Sassign case drops in from
 * ValueFrameINV.rooted_store_*; the chase-load Sset case from tmps_off_bm_set_field;
 * direct stores from the value-ok / offset-disjoint route; control flow & calls
 * structurally (calls via reach-style callee assumptions, exactly as
 * ActionValueFrame.reach_value_preserves).
 *
 * THIS FILE grows the frame bottom-up; each commit is green + axiom-clean.
 * Stage 1a (here): mem_wf + the keystone -- a chase store leaves Mario's whole
 * block bm UNCHANGED (it lands off-bm), so it preserves action_sat AND mem_wf AND
 * validity at once, with le untouched (so tmps_off_bm survives trivially).
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Lia.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF ResetBodystate RootedLvalue ValueFrameINV.

(* Memory well-formedness for a SET of chased pointer fields: each field in FS
   loads, in m, a pointer into a block other than Mario's block bm. This is what
   the chase-LOAD Ssets consume (via field_loads_off_bm) to re-establish
   tmps_off_bm, so the frame must thread it forward across the body. *)
Definition mem_wf (FS : list ident) (m : mem) (bm : block) : Prop :=
  forall fid, In fid FS -> field_loads_off_bm m bm fid.

(* ================================================================== *)
(* THE KEYSTONE. A chase store (lvalue rooted at a non-Mario temp p)    *)
(* leaves Mario's WHOLE block bm unchanged: the store lands in p's       *)
(* block, which tmps_off_bm puts off bm. Phrased as Mem.unchanged_on     *)
(* (fun b _ => b = bm) so it drives BOTH preservation facts (action_sat  *)
(* at (bm,12); the chased-field loads at (bm,off)) in one stroke.        *)
(* Generalizes the action_sat-only ValueFrameINV.rooted_store_preserves  *)
(* by keeping the full unchanged_on rather than just the load at 12.     *)
(* ================================================================== *)
Lemma rooted_store_unchanged_bm :
  forall ge e le m p lhs rhs t le' m' out bm,
    tmps_off_bm bm mario._m le ->
    p <> mario._m ->
    rooted_lv p lhs = true ->
    exec_stmt function_entry2 ge e le m (Sassign lhs rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.unchanged_on (fun b _ => b = bm) m m'.
Proof.
  intros ge e le m p lhs rhs t le' m' out bm Hinv Hp Hroot Hexec.
  pose proof Hexec as Hc. inv Hc.
  match goal with Hlv : eval_lvalue _ _ _ _ lhs _ _ _ |- _ =>
    destruct (rooted_lv_root_value _ _ _ _ p _ _ _ _ Hlv Hroot) as (pb & po & Hlk) end.
  assert (Hpb : pb <> bm) by (eapply Hinv; [ exact Hp | exact Hlk ]).
  match goal with Hlv : eval_lvalue _ _ _ _ lhs ?loc ?ofs ?bf |- _ =>
    assert (Hloc : loc = pb) by (eapply eval_lvalue_rooted; [ exact Hlk | exact Hlv | exact Hroot ]);
    subst loc end.
  split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with Hass : assign_loc _ _ _ pb _ _ _ _ |- _ =>
    eapply assign_loc_unchanged_on; [ exact Hass | ] end.
  intros i _. exact Hpb.
Qed.

(* unchanged_on the whole bm block transports mem_wf forward (every chased
   field's load at (bm,off) is preserved). *)
Lemma unchanged_bm_preserves_mem_wf :
  forall FS m m' bm,
    Mem.unchanged_on (fun b _ => b = bm) m m' ->
    Mem.valid_block m bm ->
    mem_wf FS m bm ->
    mem_wf FS m' bm.
Proof.
  intros FS m m' bm Hu Hv Hwf fid Hin.
  destruct (Hwf fid Hin) as (off & b & ofs & Hfo & Hbound & Hld & Hboff).
  exists off, b, ofs.
  split; [ exact Hfo | split; [ exact Hbound | split; [ | exact Hboff ] ] ].
  assert (Heq : Mem.load Mptr m' bm off = Mem.load Mptr m bm off)
    by (eapply Mem.load_unchanged_on_1; [ exact Hu | exact Hv | intros i _; reflexivity ]).
  rewrite Heq. exact Hld.
Qed.

(* unchanged_on the whole bm block transports action_sat forward (the load at
   (bm,12) is within the block, hence preserved). *)
Lemma unchanged_bm_preserves_action_sat :
  forall (Q : int -> Prop) m m' bm,
    Mem.unchanged_on (fun b _ => b = bm) m m' ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros Q m m' bm Hu Hv Hsat.
  eapply action_sat_unchanged_on; [ | exact Hv | exact Hsat ].
  eapply Mem.unchanged_on_implies; [ exact Hu | ].
  intros b o [Hb _] _. exact Hb.
Qed.

(* ================================================================== *)
(* THE CHASE-STORE BUNDLE HELPER. A chase store preserves the ENTIRE     *)
(* 4-part bundle: validity, action_sat, tmps_off_bm (le untouched), and  *)
(* mem_wf. This is the Sassign-chase case of the statement induction.    *)
(* ================================================================== *)
Lemma chase_store_preserves_bundle :
  forall FS (Q : int -> Prop) e le m p lhs rhs t le' m' out bm,
    tmps_off_bm bm mario._m le ->
    p <> mario._m ->
    rooted_lv p lhs = true ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    mem_wf FS m bm ->
    exec_stmt function_entry2 mario_ge e le m (Sassign lhs rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\
    Mem.valid_block m' bm /\ action_sat Q m' bm /\
    tmps_off_bm bm mario._m le' /\ mem_wf FS m' bm.
Proof.
  intros FS Q e le m p lhs rhs t le' m' out bm Hinv Hp Hroot Hv Hsat Hwf Hexec.
  destruct (rooted_store_unchanged_bm _ _ _ _ _ _ _ _ _ _ _ _ Hinv Hp Hroot Hexec)
    as (Hle & Hout & Hu).
  subst le'.
  split; [ reflexivity | split; [ exact Hout | ] ].
  split; [ eapply Mem.valid_block_unchanged_on; [ exact Hu | exact Hv ] | ].
  split; [ eapply unchanged_bm_preserves_action_sat; [ exact Hu | exact Hv | exact Hsat ] | ].
  split; [ exact Hinv | ].
  eapply unchanged_bm_preserves_mem_wf; [ exact Hu | exact Hv | exact Hwf ].
Qed.
