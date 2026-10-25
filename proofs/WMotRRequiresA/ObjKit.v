(* spine-root: OBJECTS phase S3 -- the class walk of the code a non-Mario
   object slot runs in WMotR (the behavior VM's command functions, the live
   natives and their direct callees), proved from the generated Clight with
   UcKit's recursive two-mode class walker.  Consumed by S2's obj_w / PhiW. *)
(* ====================================================================== *)
(* ObjKit.v -- every walked object body keeps GOAL 1's carried facts      *)
(* (mem_ok = ow_facts).                                                   *)
(*                                                                        *)
(* The walk: ObjTable's 387 bodies (object_helpers 91, obj_behaviors 83, *)
(* behavior_actions 72, behavior_script 59, surface_load 14, math_util   *)
(* 11, audio_external 8, debug 8, spawn_object 7, save_file 7,           *)
(* surface_collision 6, print 5, graph_node 4, spawn_sound 3, memory 3,  *)
(* camera 2, mario_actions_cutscene 2, object_list_processor 1,          *)
(* obj_behaviors_2 1), every one re-checked against the generated AST by *)
(* one vm sweep (ot_walk_ok).  The SafeB-classified globals are every     *)
(* linked variable outside non_safeb_syms (premise Hgs; any SafeB_wit-    *)
(* shaped SafeB meets it, obj_gs_safe_wit).                               *)
(*                                                                        *)
(* The leaves (section 3):                                                *)
(*   PROVED   sqrtf (FPU floor), play_sound (AudioBodies),                *)
(*            load_sequence (the labeled audio premise Hls, TRUST 4.1),   *)
(*            set_mario_npc_dialog (NpcDialogBody, GOAL 1's smact_pres)   *)
(*   OPEN     (premise Hopen, each a named sub-contract to discharge):    *)
(*     cur_obj_push_mario_away   stores Mario's pos[0] / pos[2] (gMarioStates) *)
(*     bhv_1up_interact          stores gMarioState->numLives (via gMarioState) *)
(*     start_object_cutscene     stores the object into gCutsceneFocus      *)
(*                               (a stored global, pointer-valued)          *)
(*     cur_obj_update_floor      stores o->oFloor from a local out cell     *)
(*                               (the class walk sees a kW local pointer)   *)
(*     cur_obj_call_action_function  the indirect call through a writable  *)
(*                               action table (o->oAction indexes it)       *)
(* NOT walked: cur_obj_update itself (its command dispatch is an indirect  *)
(* call through the writable BehaviorCmdTable) and bhv_cmd_call_native (an *)
(* indirect call through the script pointer): both need a content row on   *)
(* the slot's script pointer, S2's obj_w.                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario audio_external math_util mario_actions_cutscene camera
  object_helpers obj_behaviors behavior_script.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 MWFReal SpawnInit MathBodies LinkedTwelve
  UcKit FpuFloor.
From SM64.Proofs Require MtxfBody AudioBodies ObjExtBodies OsDmaFloor FloorsSurface
  NpcDialogBody UpdateCameraBody.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. THE WALK (vm, against the generated AST).                            *)
(* ---------------------------------------------------------------------- *)

Lemma ot_walk_ok : forallb (ot_ent_ok obj_gs out) otab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma otab_count : List.length otab = 387%nat.
Proof. reflexivity. Qed.

Lemma ut_find_otab : forall (l : list (ident * nat * usig)) fid s,
    ut_find fid (map (fun e => let '(fid, _, s) := e in (fid, s)) l) = Some s ->
    exists i, In (fid, i, s) l.
Proof.
  induction l as [| [[f t] s'] l IH]; intros fid s H; [ discriminate H | ].
  unfold ut_find in H. simpl in H.
  destruct (Pos.eqb f fid) eqn:E.
  - apply Pos.eqb_eq in E. subst f. simpl in H. injection H as <-. exists t. left. reflexivity.
  - destruct (IH fid s H) as (i & Hin). exists i. right. exact Hin.
Qed.

(* the SafeB-classified globals are SafeB in every SafeB_wit-shaped SafeB
   whose permitted symbols are those outside non_safeb_syms (BootMWF's
   SafeB_boot, StartSat's SB1 / SBw) *)
Lemma obj_gs_safe_wit : forall lp objblks x b,
    mem_id x obj_gs = true -> Genv.find_symbol (lp_ge lp) x = Some b ->
    SafeB_wit lp objblks (fun id => mem_id id non_safeb_syms = false) b.
Proof.
  intros lp objblks x b Hx Hs. right. exists x. split; [ left; exact (obj_gs_not_nonsafe _ Hx) | exact Hs ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The leaves that stay open.                                            *)
(* ---------------------------------------------------------------------- *)

Definition open_leaf : utab := [
  (camera._start_object_cutscene, ([kN; kS], kA, false));
  (object_helpers._cur_obj_update_floor, ([], kA, false));
  (object_helpers._cur_obj_call_action_function, ([kS], kA, true));
  (obj_behaviors._bhv_1up_interact, ([], kA, false));
  (object_helpers._cur_obj_push_mario_away, ([kN], kA, false)) ].

(* ---------------------------------------------------------------------- *)
(* 3. The section.                                                          *)
(* ---------------------------------------------------------------------- *)

Section OK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.

  (* the FPU floor (TRUST 3.5) *)
  Hypothesis Hsq : sqrtf_spec.
  (* the labeled audio premise (TRUST 4.1), as GOAL 1 carries it *)
  Hypothesis Hls : FloorsSurface.call_pres_ext lp bm (fun m => AGates.ctl_a_clear m bm) MWF
                     audio_external._load_sequence.
  (* every linked variable outside non_safeb_syms is a SafeB block
     (obj_gs_safe_wit: any SafeB_wit-shaped SafeB) *)
  Hypothesis Hgs : forall x b, mem_id x obj_gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  (* THE OPEN LEAVES (section header): each keeps the carried facts at its
     signature *)
  Hypothesis Hopen : forall nl, HnB lp bm SafeB nl ->
      forall fid s b fd, ut_find fid open_leaf = Some s ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      uspec lp bm bc oc0 SafeB nl fd s.

  Definition oLeaf (fd : Clight.fundef) (s : usig) : Prop :=
    exists fid b, ut_find fid oleaf = Some s /\ Genv.find_symbol ge fid = Some b /\
                  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd.

  Section Leaves.
    Variable nl : block.
    Hypothesis HNL : HnB lp bm SafeB nl.

    Lemma o_leaf_ok : forall fd s, oLeaf fd s -> uspec lp bm bc oc0 SafeB nl fd s.
    Proof.
      intros fd s (fid & b & Hf & Hs & Hff).
      unfold ut_find, oleaf in Hf. cbn [find fst] in Hf.
      destruct (Pos.eqb math_util._sqrtf fid) eqn:E1.
      { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
        apply UpdateCameraBody.leaf_memid. intros m vargs t m' vres Hevf.
        exact (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hevf). }
      destruct (Pos.eqb audio_external._play_sound fid) eqn:E2.
      { apply Pos.eqb_eq in E2. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (UpdateCameraBody.leaf_play_sound lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn
                 nl HNL b fd Hs Hff). }
      destruct (Pos.eqb audio_external._load_sequence fid) eqn:E3.
      { apply Pos.eqb_eq in E3. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (UpdateCameraBody.leaf_dirty lp bm bc oc0 SafeB nl _ b fd _
                 (AudioBodies.sp_ls lp bm bc oc0 SafeB Hls) Hs Hff). }
      destruct (Pos.eqb mario_actions_cutscene._set_mario_npc_dialog fid) eqn:E4.
      { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (UpdateCameraBody.leaf_dirty lp bm bc oc0 SafeB nl _ b fd _
                 (NpcDialogBody.sp_npc_dialog lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn) Hs Hff). }
      (* the rest are the open leaves *)
      apply (Hopen nl HNL fid s b fd); [ | exact Hs | exact Hff ].
      unfold ut_find, open_leaf. cbn [find fst].
      exact Hf.
    Qed.
  End Leaves.

  Lemma oLO : forall i p, nth_error lprogs i = Some p -> linkorder p lp.
  Proof.
    intros i p Hn. pose proof (nth_error_In _ _ Hn) as Hin.
    unfold lprogs in Hin. destruct Hin as [<- | Hin].
    - exact (linked12_LO_mario lp H12).
    - exact (link_chain_linkorder_in _ _ _ _ Hin H12).
  Qed.

  Lemma o_tab_good : TabGood lp obj_gs out oit oLeaf.
  Proof.
    intros fid s Hf b fd Hs Hff.
    unfold out in Hf. destruct (UpdateCameraBody.ut_find_app _ _ _ _ Hf) as [Hw | Hl].
    - destruct (ut_find_otab _ _ _ Hw) as (i & Hin).
      pose proof (proj1 (forallb_forall _ _) ot_walk_ok _ Hin) as Hc.
      unfold ot_ent_ok in Hc.
      destruct (nth_error lprogs i) as [p|] eqn:Hn; [ | discriminate Hc ].
      destruct ((prog_defmap p) ! fid) as [[[f|ef]|v]|] eqn:Edm; try discriminate Hc.
      left. exists f. split; [ | exact Hc ].
      destruct (linkorder_resolves_funct lp _ _ _ (oLO i p Hn) Edm) as (b' & Hs' & Hff').
      unfold ge, lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-. reflexivity.
    - right. exists fid, b. split; [ exact Hl | split; [ exact Hs | exact Hff ] ].
  Qed.

  Lemma o_it_good : ItGood lp obj_gs out oit oLeaf.
  Proof. intros ty s Hf. discriminate Hf. Qed.

  (* ==================================================================== *)
  (* 4. THE RESULT.  Every walked body with no parameters (the live       *)
  (*    natives, the behavior command functions, ...) called on a memory  *)
  (*    that satisfies GOAL 1's carried facts returns in one that still   *)
  (*    satisfies them.                                                    *)
  (* ==================================================================== *)
  Theorem obj_body_pres : forall fid rc dm b fd m t m' vres,
      ut_find fid out = Some (nil, rc, dm) ->
      Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd nil t m' vres ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros fid rc dm b fd m t m' vres Hf Hs Hff Hevf Hof.
    set (nl := Mem.nextblock m).
    pose proof (UpdateCameraBody.uc_HnB lp bm bc oc0 SafeB m Hof) as HNL.
    pose proof (good_spec lp bm bc oc0 SafeB HSafeB_syms Hspawn nl HNL obj_gs Hgs
                  out oit oLeaf (o_leaf_ok nl HNL) o_tab_good o_it_good fd _
                  (o_tab_good _ _ Hf b fd Hs Hff)) as Hsp.
    assert (Hi : UInv lp bm bc oc0 SafeB nl dm nl m).
    { split; [ exact Hof | split; [ apply Ple_refl | intros _; exact (rl_fresh lp SafeB nl nl m eq_refl) ] ]. }
    destruct (Hsp nl (Ple_refl _) m nil t m' vres Hevf (Forall2_nil _) Hi) as ((Hof' & _) & _).
    exact Hof'.
  Qed.
End OK.

(* ---------------------------------------------------------------------- *)
(* 5. NON-VACUITY: which live natives obj_body_pres covers.                *)
(* ---------------------------------------------------------------------- *)

Definition nullary_walked (x : ident) : bool :=
  match ut_find x out with Some (nil, _, _) => true | _ => false end.

(* 104 of the 107 live natives are walked at a nullary signature *)
Lemma natives_walked_count :
  List.length (filter nullary_walked BehaviorScripts.wmotr_live_natives) = 104%nat.
Proof. vm_compute. reflexivity. Qed.

(* the other three: Mario's own update (the frame the capstones walk) and the
   two mario_misc.c natives with no linked body (BehaviorScripts'
   wmotr_live_natives_unlinked, a census over-approximation) *)
Lemma natives_not_walked :
  map string_of_ident (filter (fun x => negb (nullary_walked x)) BehaviorScripts.wmotr_live_natives)
  = ["bhv_mario_update"; "bhv_unlock_door_star_init"; "bhv_unlock_door_star_loop"]%string.
Proof. vm_compute. reflexivity. Qed.
