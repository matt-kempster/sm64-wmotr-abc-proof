(* spine-root: OBJECTS phase S3 -- the PROTECTED-SLOT frame with spawns.
   ObjSelf's own-slot frame forbids every write to another pool slot, so a
   body that spawns (46 of the 57 live natives kSelf misses) is out.  This
   file walks those bodies against a weaker, still useful frame: the pool
   cells of a fixed set P of PROTECTED slots (S2 picks P: the pole, the
   cannon, Mario's object), minus the list / graph link cells, are
   unchanged.  The one spawn entry point, spawn_object_at_origin, is a leaf
   under the named open row Hspawn_fr (below).  Consumed by S2's obj_w. *)
(* ====================================================================== *)
(* ObjSpawn.v                                                             *)
(*                                                                        *)
(* 1. Pc P ofs: byte ofs of gObjectPool lies in a slot of P (slot =       *)
(*    ofs / sizeof(struct Object)) and outside the slot's LINK cells:      *)
(*    header.gfx.node.{prev,next,parent,children} = [4,20) and             *)
(*    header.{next,prev} = [96,104) (link_offsets pins them against the    *)
(*    composite env).                                                     *)
(* 2. Hspawn_fr (OPEN ROW, not a TRUST row): every call of                *)
(*    spawn_object_at_origin changes the pool only in the running slot,   *)
(*    in slots outside P and in link cells, leaves gCurrentObject's cell  *)
(*    alone, and returns the running slot or a pointer to a slot with no   *)
(*    protected byte.  What it hides (the spec for its discharge, SKILL):  *)
(*      - the free list holds no P slot (a chain from gFreeObjectList     *)
(*        through header.next, every member inactive, so not in P);       *)
(*      - when the free list is empty, the head of the unimportant list   *)
(*        is not in P (ACTIVE_FLAG_UNIMPORTANT chain);                     *)
(*      - every slot's link cells point to pool slots or the sentinels    *)
(*        (gObjectLists, gFreeObjectList, gObjParentGraphNode);           *)
(*      - the slot's graph parent is gObjParentGraphNode.                 *)
(*    NOTE (stale pointers, ObjStoreCensus "spiny adoption"): Hspawn_fr  *)
(*    is about the spawn itself.  A write through a STORED object pointer *)
(*    is never assumed to hit its intended object; those writes are not   *)
(*    walked here (a loaded pointer is KAny: no store through it).        *)
(* 3. THE WALK: spawn_tab, a fixpoint over xotab with ObjSelf.s_fun3,     *)
(*    fresh-returning set spawn_rft; leaves sqrtf and                     *)
(*    spawn_object_at_origin.  obj_body_spawn_frame: every entry keeps    *)
(*    the protected cells and gCurrentObject's cell, and an entry of      *)
(*    spawn_rft returns a writable slot pointer.                          *)
(* 4. Coverage: spawn_live_count.                                         *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require math_util object_helpers.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 MWFReal SpawnInit MathBodies LinkedTwelve
  UcKit FpuFloor.
From SM64.Proofs Require MtxfBody.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable ObjKit ObjWalk ObjSelf ObjFrame.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. Protected cells.                                                      *)
(* ---------------------------------------------------------------------- *)

Definition oce : composite_env := prog_comp_env object_helpers.prog.
Definition fo (s f : ident) : option Z :=
  match oce ! s with
  | Some co => match field_offset oce f (co_members co) with OK (x, _) => Some x | _ => None end
  | None => None
  end.

(* the link fields, from the composite env *)
Lemma link_offsets :
  (fo object_helpers._Object object_helpers._header, fo object_helpers._ObjectNode object_helpers._gfx,
   fo object_helpers._GraphNodeObject object_helpers._node,
   fo object_helpers._GraphNode object_helpers._prev, fo object_helpers._GraphNode object_helpers._next,
   fo object_helpers._GraphNode object_helpers._parent, fo object_helpers._GraphNode object_helpers._children,
   fo object_helpers._ObjectNode object_helpers._next, fo object_helpers._ObjectNode object_helpers._prev)
  = (Some 0, Some 0, Some 0, Some 4, Some 8, Some 12, Some 16, Some 96, Some 100).
Proof. vm_compute. reflexivity. Qed.

Definition link_rel (r : Z) : bool := ((4 <=? r) && (r <? 20)) || ((96 <=? r) && (r <? 104)).

Definition Pc (P : Z -> Prop) (ofs : Z) : Prop := P (ofs / OSZ) /\ link_rel (ofs mod OSZ) = false.

(* ---------------------------------------------------------------------- *)
(* 3. The walk.                                                             *)
(* ---------------------------------------------------------------------- *)

Definition SPAWN : ident := object_helpers._spawn_object_at_origin.

Definition p_leaves : stab :=
  [(math_util._sqrtf, [KAny]); (SPAWN, [KAny; KAny; KAny; KAny])].

Definition p_tab_of (l : list s_cand) : stab :=
  map (fun c => let '(g, _, ks) := c in (g, ks)) l ++ p_leaves.

Lemma p_tab_of_split : forall l f ks, st_find f (p_tab_of l) = Some ks ->
    (exists i, In (f, i, ks) l) \/ st_find f p_leaves = Some ks.
Proof. intros l f ks H. exact (st_find_split l p_leaves f ks H). Qed.

(* the fresh-returning functions: return struct Object *, and assign the
   result of a fresh-returning call (untrusted; s_fun3 re-checks) *)
Definition ret_obj (f : Clight.function) : bool :=
  match fn_return f with
  | Tpointer (Tstruct id _) _ => Pos.eqb id object_helpers._Object
  | _ => false
  end.

Definition rft_step (rft : list ident) : list ident :=
  rft ++ flat_map (fun e => let '(fid, i, _) := e in
    if mem_i fid rft then [] else
    match s_body fid i with
    | Some (_, f) =>
        if ret_obj f && existsb (fun c => mem_i (snd c) rft) (t_calls (fn_body f)) then [fid] else []
    | None => []
    end) xotab.

Fixpoint rft_iter (n : nat) (rft : list ident) : list ident :=
  match n with O => rft | S n' => rft_iter n' (rft_step rft) end.

Definition spawn_rft : list ident := rft_iter 6 [SPAWN].

Definition to_fresh (ks : list skind) : list skind :=
  map (fun k => match k with KSelf => KFresh | k => k end) ks.

Definition p_ent_ok (tab : stab) (c : s_cand) : bool :=
  let '(fid, i, ks) := c in
  match s_body fid i with
  | Some (ce, f) => s_fun3 ce OSZ tab spawn_rft (mem_i fid spawn_rft) ks f
  | None => false
  end.

Definition p_round (st : list s_cand) : list s_cand :=
  let tab := p_tab_of st in
  flat_map (fun c => let '(fid, i, _) := c in
    match s_body fid i with
    | Some (ce, f) =>
        let ok := fun ks => s_fun3 ce OSZ tab spawn_rft (mem_i fid spawn_rft) ks f in
        let k1 := to_fresh (smart_kinds object_helpers._Object tab f) in
        let k2 := smart_kinds object_helpers._Object tab f in
        let k3 := to_fresh (typed_kinds object_helpers._Object f) in
        let k4 := typed_kinds object_helpers._Object f in
        if ok k1 then [(fid, i, k1)] else if ok k2 then [(fid, i, k2)]
        else if ok k3 then [(fid, i, k3)] else if ok k4 then [(fid, i, k4)] else []
    | None => []
    end) st.

Fixpoint p_rounds (n : nat) (st : list s_cand) : list s_cand :=
  match n with O => st | S n' => p_rounds n' (p_round st) end.

Definition p_start : list s_cand :=
  flat_map (fun e => let '(fid, i) := e in
    match s_body fid i with Some (_, f) => [(fid, i, any_kinds f)] | None => [] end)
    (filter (fun e => negb (Pos.eqb (fst e) SPAWN))
       (map (fun e => let '(fid, i, _) := e in (fid, i)) xotab) ++ [s_ps]).

Definition spawn_tab : list s_cand := p_rounds 40 p_start.

(* THE WALK: every entry is clean against the final table *)
Lemma spawn_walk_ok : forallb (p_ent_ok (p_tab_of spawn_tab)) spawn_tab = true.
Proof. vm_compute. reflexivity. Qed.

Section SPAWNF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Let ge := lp_ge lp.
  Hypothesis Hsq : sqrtf_spec.
  Variables pool gB : block.
  Variable oc : ptrofs.
  Hypothesis Hpool : Genv.find_symbol ge POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge GCO = Some gB.
  Hypothesis Hoc : Ptrofs.unsigned oc + OSZ <= Ptrofs.max_unsigned.
  Variable P : Z -> Prop.

  (* THE OPEN ROW (see the header): the spawn keeps the protected cells *)
  Definition spawn_fr : Prop :=
    forall b fd m vargs t m' vres,
      Genv.find_symbol ge SPAWN = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      SI pool gB oc m -> GV pool gB m ->
      PFR pool gB oc OSZ (Pc P) m m' /\ FVv pool oc OSZ (Pc P) vres.
  Hypothesis Hspawn_fr : spawn_fr.

  Definition sLeafP (fd : Clight.fundef) (ks : list skind) (rf : bool) : Prop :=
    (exists b, Genv.find_symbol ge math_util._sqrtf = Some b /\
               Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd /\ ks = [KAny] /\ rf = false)
    \/ (exists b, Genv.find_symbol ge SPAWN = Some b /\
               Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd /\ rf = true).

  Lemma p_leaf_ok : forall fd ks rf, sLeafP fd ks rf ->
      forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 (karg3 pool gB oc OSZ (Pc P)) ks vargs -> SI pool gB oc m -> GV pool gB m ->
      PFR pool gB oc OSZ (Pc P) m m' /\ (rf = true -> FVv pool oc OSZ (Pc P) vres).
  Proof.
    intros fd ks rf [(b & Hs & Hff & _ & ->) | (b & Hs & Hff & ->)] m vargs t m' vres Hev _ Hsi Hgv.
    - rewrite (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hev).
      split; [ apply Mem.unchanged_on_refl | discriminate ].
    - destruct (Hspawn_fr b fd m vargs t m' vres Hs Hff Hev Hsi Hgv) as (HF & Hv).
      split; [ exact HF | intros _; exact Hv ].
  Qed.

  Lemma p_in_good : forall f i ks, In (f, i, ks) spawn_tab ->
      forall b fd, Genv.find_symbol ge f = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      sGood3 ge OSZ (p_tab_of spawn_tab) spawn_rft sLeafP fd ks (mem_i f spawn_rft).
  Proof.
    intros f i ks Hin b fd Hs Hff.
    pose proof (proj1 (forallb_forall _ _) spawn_walk_ok _ Hin) as Hc.
    unfold p_ent_ok, s_body in Hc.
    destruct (nth_error lprogs i) as [p|] eqn:Hn; [ | discriminate Hc ].
    destruct ((prog_defmap p) ! f) as [[[fn|ef]|v]|] eqn:Edm; try discriminate Hc.
    left. exists fn, (prog_comp_env p). split; [ | split; [ | exact Hc ] ].
    - destruct (linkorder_resolves_funct lp _ _ _ (oLO lp H12 i p Hn) Edm) as (b' & Hs' & Hff').
      unfold ge, lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-. reflexivity.
    - intros id co Hco. exact (linkorder_comp_env_extends lp p id co (oLO lp H12 i p Hn) Hco).
  Qed.

  Lemma spawn_in_rft : mem_i SPAWN spawn_rft = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sqrtf_not_rft : mem_i math_util._sqrtf spawn_rft = false.
  Proof. vm_compute. reflexivity. Qed.

  Lemma p_tab_good : forall f ks, st_find f (p_tab_of spawn_tab) = Some ks ->
      forall b fd, Genv.find_symbol ge f = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      sGood3 ge OSZ (p_tab_of spawn_tab) spawn_rft sLeafP fd ks (mem_i f spawn_rft).
  Proof.
    intros f ks Hf b fd Hs Hff.
    destruct (p_tab_of_split spawn_tab f ks Hf) as [(i & Hin) | Hl].
    - exact (p_in_good f i ks Hin b fd Hs Hff).
    - right. unfold st_find, p_leaves in Hl. cbn in Hl.
      destruct (Pos.eqb math_util._sqrtf f) eqn:E.
      + apply Pos.eqb_eq in E. subst f. injection Hl as <-. left.
        exists b. split; [ exact Hs | split; [ exact Hff | split; [ reflexivity | exact sqrtf_not_rft ] ] ].
      + destruct (Pos.eqb SPAWN f) eqn:E2; [ | discriminate Hl ].
        apply Pos.eqb_eq in E2. subst f. right.
        exists b. split; [ exact Hs | split; [ exact Hff | exact spawn_in_rft ] ].
  Qed.

  (* THE PROTECTED-SLOT FRAME: a walked body, entered with gCurrentObject =
     &pool[oc] and arguments of its kinds, keeps every protected cell (a
     byte of a P slot outside its link cells, outside the running slot) and
     gCurrentObject's cell; a fresh-returning entry returns the running slot
     or a slot with no protected byte.  Open: Hspawn_fr. *)
  Theorem obj_body_spawn_frame : forall fid i ks b fd m vargs t m' vres,
      In (fid, i, ks) spawn_tab ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 (karg3 pool gB oc OSZ (Pc P)) ks vargs -> SI pool gB oc m -> GV pool gB m ->
      PFR pool gB oc OSZ (Pc P) m m' /\ (mem_i fid spawn_rft = true -> FVv pool oc OSZ (Pc P) vres).
  Proof.
    intros fid i ks b fd m vargs t m' vres Hin Hs Hff Hev Hva Hsi Hgv.
    exact (s_fun_frame3 ge pool gB oc OSZ Hpool HgB Hoc (p_tab_of spawn_tab) (Pc P) spawn_rft sLeafP
             p_leaf_ok p_tab_good ks (mem_i fid spawn_rft) fd m vargs t m' vres
             (p_in_good fid i ks Hin b fd Hs Hff) Hev Hva Hsi Hgv).
  Qed.
End SPAWNF.

(* ---------------------------------------------------------------------- *)
(* 4. Coverage.                                                             *)
(* ---------------------------------------------------------------------- *)

Definition spawn_names : list ident := map (fun c => let '(f, _, _) := c in f) spawn_tab.
Definition spawn_live : list ident :=
  filter (fun x => mem_id x spawn_names) BehaviorScripts.wmotr_live_natives.
Definition spawn_uncovered : list ident :=
  filter (fun x => negb (mem_id x spawn_names)) BehaviorScripts.wmotr_live_natives.

(* 243 of xotab's entries walk under the protected-slot frame, plus
   play_sound (kSelf's 200 included) *)
Lemma spawn_tab_count : List.length spawn_tab = 244%nat.
Proof. vm_compute. reflexivity. Qed.

(* 62 of the 107 live natives (kSelf: 46).  The 45 left: create_object's
   own callers (spawn_object_relative, via obj_build_relative_transform /
   obj_translate_local: stores at a VARIABLE rawData index, which the walk
   does not decode), the physics movers (object_step, coin_step,
   cur_obj_move_standard), the cross-object stores (1up_loop, end_toad,
   idle_water_wave, 1up_hidden_in_pole_trigger), unlock_door_star,
   load_object_collision_model, the debug printers, and singles. *)
Lemma spawn_live_count : List.length spawn_live = 62%nat.
Proof. vm_compute. reflexivity. Qed.
Lemma spawn_uncovered_count : List.length spawn_uncovered = 45%nat.
Proof. vm_compute. reflexivity. Qed.
