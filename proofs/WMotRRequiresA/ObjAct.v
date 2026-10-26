(* spine-root: OBJECTS phase S3 -- cur_obj_call_action_function's FRAME
   (ObjFrame's open premise Hopen2) for the three action tables the WMotR
   object closure passes it, under the named read-only premise RO_tab,
   which holds at boot (the real Genv.init_mem).  Keeping RO_tab across
   the run is the later spine-wide step (SKILL open items). *)
(* ====================================================================== *)
(* ObjAct.v                                                               *)
(*                                                                        *)
(* 1. THE SIZE (vm): of RoCensus's 35 action tables only 3 are passed     *)
(*    from an xotab body (sJumpingBoxActions, sOpenedCannonActions,       *)
(*    sExclamationBoxActions); their 15 entries are none of xotab's       *)
(*    bodies; the call closure of the 15 is 90 functions, 21 outside      *)
(*    xotab (the 15, four helpers, play_sound, sqrtf).  The respawner     *)
(*    (RoCensus's one union-cell escape) is not in the closure.           *)
(* 2. THE WALK: the 15 action bodies + 4 helpers + the 69 closure bodies  *)
(*    of xotab, re-checked by ObjWalk (one vm sweep), WITHOUT             *)
(*    cur_obj_call_action_function as a leaf (no action body calls it).   *)
(* 3. RO_tab m: a pointer loaded from a live table's block is one of its  *)
(*    initializer's Init_addrof targets.  ro_tab_boot: it holds in the    *)
(*    real Genv.init_mem of the link.                                     *)
(* 4. caf_frame: cur_obj_call_action_function(&tbl), tbl one of the 3,    *)
(*    from a memory with RO_tab, keeps UInv and has the frame (FR, XS).   *)
(*    UB-COVERAGE POINT (TRUST row 3.2): there is no action-index         *)
(*    premise only because an out-of-bounds table load has no Clight      *)
(*    execution.  That EXCLUDES such runs; it does not prove they never   *)
(*    happen (on the N64 the read returns adjacent memory).  Open (S2):   *)
(*    act_in_range as an obj_w clause, carried from act_stores_census     *)
(*    (the oAction stores of the 15 bodies are constants in range of      *)
(*    their own table) plus the spawn / init writes.                      *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require object_helpers obj_behaviors behavior_actions audio_external
  mario_actions_cutscene math_util.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve UcKit
  SpawnInit MWFReal FpuFloor BootMWF CensusV2.
From SM64.Proofs Require AGates AudioBodies NpcDialogBody.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable ObjKit ObjWalk ObjFrame RoCensus
  LsContract NpcFrame.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. The size.                                                             *)
(* ---------------------------------------------------------------------- *)

Definition CAF : ident := object_helpers._cur_obj_call_action_function.

Definition xids : list ident := map (fun e => let '(f, _, _) := e in f) xotab.

(* the tables passed to cur_obj_call_action_function from an xotab body *)
Definition live_tables : list ident :=
  inodup (flat_map (fun e => let '(fid, i, _) := e in
    match s_body fid i with
    | Some (_, f) => flat_map (flat_map evars) (calls_to CAF (fn_body f))
    | None => []
    end) xotab).

(* a table's initializer, from the first TU that defines it *)
Definition tinit (t : ident) : list init_data :=
  match find (fun (p : Clight.program) =>
                match (prog_defmap p) ! t with Some (Gvar _) => true | _ => false end) lprogs with
  | Some p => match (prog_defmap p) ! t with Some (Gvar v) => gvar_init v | _ => [] end
  | None => []
  end.

Definition tentries (t : ident) : list ident :=
  flat_map (fun d => match d with Init_addrof g _ => [g] | _ => [] end) (tinit t).

Definition act_callees : list ident := inodup (flat_map tentries live_tables).

Fixpoint dcalls (s : statement) : list ident :=
  match s with
  | Scall _ (Evar h _) _ => [h]
  | Scall _ _ _ => [1%positive]
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => dcalls s1 ++ dcalls s2
  | Slabel _ s1 => dcalls s1
  | Sswitch _ sl => dcalls_ls sl
  | _ => []
  end
with dcalls_ls (sl : labeled_statements) : list ident :=
  match sl with LSnil => [] | LScons _ s sl' => dcalls s ++ dcalls_ls sl' end.

Definition fbody (g : ident) : option function :=
  match fn_tab ! g with Some (_, f) => Some f | None => None end.
Definition fidx (g : ident) : nat := match fn_tab ! g with Some (i, _) => i | None => 0%nat end.

Fixpoint clos (n : nat) (l : list ident) : list ident :=
  match n with
  | O => l
  | S n' => clos n' (inodup (l ++ flat_map (fun g =>
              match fbody g with Some f => dcalls (fn_body f) | None => [] end) l))
  end.

Definition act_clos : list ident := clos 20 act_callees.

Lemma act_size :
  List.length live_tables = 3%nat
  /\ List.length act_callees = 15%nat
  /\ List.length (filter (fun g => memi g xids) act_callees) = 0%nat
  /\ List.length act_clos = 90%nat
  /\ List.length (filter (fun g => negb (memi g xids)) act_clos) = 21%nat
  /\ memi 1%positive act_clos = false          (* no indirect call *)
  /\ memi CAF act_clos = false.               (* no nested action call *)
Proof. vm_compute. repeat split; reflexivity. Qed.

Local Open Scope string_scope.
Lemma live_tables_value : map string_of_ident live_tables =
  ["sJumpingBoxActions"; "sOpenedCannonActions"; "sExclamationBoxActions"].
Proof. vm_compute. reflexivity. Qed.

(* RoCensus's one union-cell escape (create_respawner's rawData slot 29)
   and its reader are not in the object closure, nor live natives *)
Lemma respawner_not_live :
  existsb (fun x => String.eqb (string_of_ident x) "create_respawner"
                    || String.eqb (string_of_ident x) "bhv_respawner_loop")
    (xids ++ act_clos ++ BehaviorScripts.wmotr_live_natives) = false.
Proof. vm_compute. reflexivity. Qed.
Local Close Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* 2. The walk.                                                             *)
(* ---------------------------------------------------------------------- *)

Definition act_helpers : list (ident * usig) :=
  [ (object_helpers._cur_obj_unhide, ([], kA, false));
    (object_helpers._cur_obj_was_attacked_or_ground_pounded, ([], kN, false));
    (behavior_actions._exclamation_box_spawn_contents, ([kS; kN], kA, false));
    (object_helpers._cur_obj_is_mario_ground_pounding_platform, ([], kN, false)) ].

Definition act_sig : usig := ([], kA, false).

Definition atab : list (ident * nat * usig) :=
  map (fun g => (g, fidx g, act_sig)) act_callees
  ++ map (fun h => (fst h, fidx (fst h), snd h)) act_helpers
  ++ filter (fun e => let '(f, _, _) := e in memi f act_clos) xotab.

(* the leaves: xleaf without cur_obj_call_action_function *)
Definition aleaf : utab := [
  sq_leaf; ps_leaf;
  (audio_external._load_sequence, ([kN; kN; kN], kA, true));
  (mario_actions_cutscene._set_mario_npc_dialog, ([kN], kA, true)) ].

Lemma act_walk_ok : forallb (xt_ent_ok mcells obj_gs (tab_ut atab ++ aleaf)) atab = true.
Proof. vm_compute. reflexivity. Qed.

(* every entry of a live table is walked at the action signature *)
Lemma tentries_sig : forallb (fun t => forallb (fun g =>
    match ut_find g (tab_ut atab ++ aleaf) with
    | Some s => match s with ([], kA, false) => true | _ => false end
    | None => false end) (tentries t)) live_tables = true.
Proof. vm_compute. reflexivity. Qed.

(* the 15 bodies' oAction stores (rawData.asS32[49] through a
   gCurrentObject temp): every one a constant inside its own table *)
Fixpoint oact_stores (s : statement) : list (option Z) :=
  match s with
  | Sassign (Ederef (Ebinop Oadd (Efield (Efield (Ederef _ _) fr _) fa _)
                      (Econst_int k _) _) _) r =>
      if Pos.eqb fr object_helpers._rawData && Pos.eqb fa object_helpers._asS32
         && Z.eqb (Int.unsigned k) 49
      then [match r with Econst_int c _ => Some (Int.signed c) | _ => None end] else []
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => oact_stores s1 ++ oact_stores s2
  | Slabel _ s1 => oact_stores s1
  | Sswitch _ sl => oact_stores_ls sl
  | _ => []
  end
with oact_stores_ls (sl : labeled_statements) : list (option Z) :=
  match sl with LSnil => [] | LScons _ s sl' => oact_stores s ++ oact_stores_ls sl' end.

Definition act_stores_ok (t : ident) : bool :=
  let n := Z.of_nat (List.length (tinit t)) in
  forallb (fun g => match fbody g with
    | Some f => forallb (fun o => match o with Some c => (0 <=? c) && (c <? n) | None => false end)
                  (oact_stores (fn_body f))
    | None => false end) (tentries t).

Lemma act_stores_census : forallb act_stores_ok live_tables = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. RO_tab, and its boot.                                                 *)
(* ---------------------------------------------------------------------- *)

Definition RO_tab (ge : genv) (m : mem) : Prop :=
  forall t bt ofs b' o', In t live_tables -> Genv.find_symbol ge t = Some bt ->
    Mem.load Mint32 m bt ofs = Some (Vptr b' o') ->
    exists g, In (Init_addrof g o') (tinit t) /\ Genv.find_symbol ge g = Some b'.

(* a live table's definition in the link carries the TU's initializer *)
Lemma tinit_shape : forallb (fun t =>
    match tinit t with [] => false | [Init_space _] => false | _ => true end) live_tables = true.
Proof. vm_compute. reflexivity. Qed.

Lemma tinit_def : forall t, In t live_tables ->
    exists i p v, nth_error lprogs i = Some p /\ (prog_defmap p) ! t = Some (Gvar v)
                  /\ gvar_init v = tinit t.
Proof.
  intros t Ht.
  pose proof (proj1 (forallb_forall _ _) tinit_shape t Ht) as Hs. cbv beta in Hs.
  unfold tinit in Hs |- *.
  destruct (find _ lprogs) as [p|] eqn:Ef; [ | discriminate Hs ].
  pose proof (find_some _ _ Ef) as (Hin & HP). cbv beta in HP.
  destruct ((prog_defmap p) ! t) as [[f|v]|] eqn:Ed; try discriminate HP.
  destruct (In_nth_error _ _ Hin) as (i & Hi).
  exists i, p, v. split; [ exact Hi | split; [ exact Ed | reflexivity ] ].
Qed.

Section LINK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Let ge := lp_ge lp.

  Lemma tinit_lp : forall t, In t live_tables ->
      exists v', (prog_defmap lp) ! t = Some (Gvar v') /\ gvar_init v' = tinit t.
  Proof.
    intros t Ht.
    destruct (tinit_def t Ht) as (i & p & v & Hi & Hd & Hv).
    pose proof (oLO lp H12 i p Hi) as LO.
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LO.
    destruct LO as [LOast _].
    destruct (prog_defmap_linkorder _ _ _ _ LOast Hd) as (gd' & Hgd' & Hlo).
    inv Hlo. match goal with H : linkorder v _ |- _ => inv H end.
    exists (mkglobvar info2 i2 ro vo). split; [ exact Hgd' | ]. cbn.
    match goal with H : linkorder _ i2 |- _ => inv H end; cbn in Hv; [ exact Hv | | ].
    - exfalso. pose proof (proj1 (forallb_forall _ _) tinit_shape t Ht) as Hs.
      cbv beta in Hs. rewrite <- Hv in Hs. discriminate Hs.
    - exfalso. pose proof (proj1 (forallb_forall _ _) tinit_shape t Ht) as Hs.
      cbv beta in Hs. rewrite <- Hv in Hs. discriminate Hs.
  Qed.

  (* THE BOOT: RO_tab holds in the real initial memory of the link *)
  Theorem ro_tab_boot : forall m0, Genv.init_mem lp = Some m0 -> RO_tab ge m0.
  Proof.
    intros m0 Hinit t bt ofs b' o' Ht Hs Hld.
    destruct (tinit_lp t Ht) as (v' & Hd & Hv).
    destruct (init_mem_load_ptr lp m0 t bt v' Mint32 ofs b' o' Hinit Hs Hd Hld) as (g & Hin & Hg).
    exists g. rewrite <- Hv. split; [ exact Hin | exact Hg ].
  Qed.
End LINK.

(* the live oAction stores the census saw (non-vacuity of act_stores_census) *)
Lemma act_stores_count :
  List.length (flat_map (fun t => flat_map (fun g =>
     match fbody g with Some f => oact_stores (fn_body f) | None => [] end) (tentries t)) live_tables)
  = 14%nat.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. cur_obj_call_action_function's frame.                                 *)
(* ---------------------------------------------------------------------- *)

Lemma dm_caf : (prog_defmap object_helpers.prog) ! CAF
               = Some (Gfun (Internal object_helpers.f_cur_obj_call_action_function)).
Proof. vm_compute. reflexivity. Qed.

Lemma tentries_in : forall t g o, In (Init_addrof g o) (tinit t) -> In g (tentries t).
Proof.
  intros t g o H. unfold tentries. apply in_flat_map. exists (Init_addrof g o).
  split; [ exact H | left; reflexivity ].
Qed.

(* three temp assignments: memory and outcome unchanged *)
Lemma sets3 : forall ge e le m id1 a1 id2 a2 id3 a3 t le' m' out,
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset id1 a1) (Ssequence (Sset id2 a2) (Sset id3 a3))) t le' m' out ->
    m' = m /\ out = Out_normal /\
    exists v1 v2 v3, eval_expr ge e (PTree.set id2 v2 (PTree.set id1 v1 le)) m a3 v3
                /\ le' = PTree.set id3 v3 (PTree.set id2 v2 (PTree.set id1 v1 le)).
Proof.
  intros ge e le m id1 a1 id2 a2 id3 a3 t le' m' out H.
  inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _,
                    H2 : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H1; inv H2 end.
    + match goal with H1 : exec_stmt _ _ _ _ _ (Sset id2 _) _ _ _ _,
                      H2 : exec_stmt _ _ _ _ _ (Sset id3 _) _ _ _ _ |- _ => inv H1; inv H2 end.
      split; [ reflexivity | split; [ reflexivity | ] ].
      do 3 eexists. split; [ eassumption | reflexivity ].
    + match goal with H1 : exec_stmt _ _ _ _ _ (Sset id2 _) _ _ _ _ |- _ => inv H1 end.
      exfalso. match goal with Hn : Out_normal <> Out_normal |- _ => exact (Hn eq_refl) end.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1 end.
    exfalso. match goal with Hn : Out_normal <> Out_normal |- _ => exact (Hn eq_refl) end.
Qed.

Section CAF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Let ge := lp_ge lp.
  (* the FPU floor (TRUST 3.5) *)
  Hypothesis Hsq : sqrtf_spec.
  Hypothesis Hgs : forall x b, mem_id x obj_gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  (* the labeled audio premise (TRUST 4.1), as in ObjFrame.obj_body_frame *)
  Hypothesis Hlsc : ls_contract lp bm (fun m => AGates.ctl_a_clear m bm) (MWF_real lp bm bc oc0 SafeB).
  Variable MC : Z -> Prop.
  Hypothesis HMC : forall ofs, in_mcells mcells ofs -> MC ofs.
  Hypothesis HMCn : forall ofs, in_mcells npc_cells ofs -> MC ofs.
  Variable nl : block.
  Hypothesis HNL : HnB lp bm SafeB nl.

  Lemma aleaf_ok : forall fid s b fd, ut_find fid aleaf = Some s ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      xspec lp bm bc oc0 SafeB nl MC fd s.
  Proof.
    intros fid s b fd Hf Hs Hff.
    unfold ut_find, aleaf, sq_leaf, ps_leaf in Hf. cbn [find fst] in Hf.
    destruct (Pos.eqb math_util._sqrtf fid) eqn:E1.
    { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
      exact (xleaf_sqrtf lp H12 bm bc oc0 SafeB Hsq nl MC b fd Hs Hff). }
    destruct (Pos.eqb audio_external._play_sound fid) eqn:E2.
    { apply Pos.eqb_eq in E2. subst fid. cbv beta iota in Hf; injection Hf as <-.
      exact (xleaf_play_sound lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn nl HNL MC b fd Hs Hff). }
    destruct (Pos.eqb audio_external._load_sequence fid) eqn:E3.
    { apply Pos.eqb_eq in E3. subst fid. cbv beta iota in Hf; injection Hf as <-.
      exact (xleaf_dirty lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hlsc MC HMCn nl HNL _ b fd _
               (AudioBodies.sp_ls lp bm bc oc0 SafeB (proj1 Hlsc)) (or_introl eq_refl) Hs Hff). }
    destruct (Pos.eqb mario_actions_cutscene._set_mario_npc_dialog fid) eqn:E4.
    { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
      exact (xleaf_dirty lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hlsc MC HMCn nl HNL _ b fd _
               (NpcDialogBody.sp_npc_dialog lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn)
               (or_intror eq_refl) Hs Hff). }
    discriminate Hf.
  Qed.

  (* every action-table entry meets the walk's spec *)
  Lemma act_xspec : forall fid s b fd, ut_find fid (tab_ut atab ++ aleaf) = Some s ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      xspec lp bm bc oc0 SafeB nl MC fd s.
  Proof.
    exact (tab_xspec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hgs nl HNL MC mcells HMC
             atab aleaf act_walk_ok aleaf_ok).
  Qed.

  (* THE FRAME of cur_obj_call_action_function(&tbl), tbl a live table, from
     a memory where the live tables still hold their initializers' pointers
     (RO_tab; ro_tab_boot at boot): UInv kept, memory changes only in the
     frame FR (SafeB / fresh / non-MWF globals / Mario cells in MC), and
     the XS pointer discipline -- ObjFrame's xspec at ([kS], kA, true),
     with the argument pinned to a live table *)
  Theorem caf_frame : forall t bt bf fd nb0 m t0 m' vres,
      In t live_tables -> Genv.find_symbol ge t = Some bt ->
      Genv.find_symbol ge CAF = Some bf -> Genv.find_funct ge (Vptr bf Ptrofs.zero) = Some fd ->
      Hn nl nb0 ->
      eval_funcall function_entry2 ge m fd [Vptr bt Ptrofs.zero] t0 m' vres ->
      UInv lp bm bc oc0 SafeB nl true nb0 m -> RO_tab ge m ->
      UInv lp bm bc oc0 SafeB nl true nb0 m' /\ FR lp bm SafeB nl MC m m' /\ XS SafeB nl nb0 m m'.
  Proof.
    intros t bt bf fd nb0 m t0 m' vres Ht Hbt Hbf Hff HN Hev Hi Hro.
    destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_object_helpers lp H12) dm_caf)
      as (b' & Hs' & Hff').
    unfold ge, lp_ge in Hbf, Hff. rewrite Hbf in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in Hb; injection Hb as Hle end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => cbn in Hfl; injection Hfl as Hm' end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      cbn [fn_body object_helpers.f_cur_obj_call_action_function] in Hx; inv Hx end.
    2: { match goal with H1 : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) _) _ _ _ _,
                         Hn : _ <> Out_normal |- _ =>
           destruct (sets3 _ _ _ _ _ _ _ _ _ _ _ _ _ _ H1) as (_ & E & _); exact (False_ind _ (Hn E)) end. }
    match goal with H1 : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) _) _ _ _ _ |- _ =>
      destruct (sets3 _ _ _ _ _ _ _ _ _ _ _ _ _ _ H1) as (-> & _ & v1 & v2 & v3 & Hv3 & ->) end.
    match goal with H2 : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv H2 end.
    (* the callee value is the action-table load *)
    match goal with Hc : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      inv Hc; [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ] end.
    match goal with Hg : (PTree.set ?x _ _) ! ?x = Some _ |- _ => rewrite PTree.gss in Hg; injection Hg as <- end.
    (* v3 = *(actionFunctions + t'2): a load from the table block *)
    inv Hv3.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      inv Hb; [ | match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end ] end.
    match goal with Ha : eval_expr _ _ _ _ (Etempvar object_helpers._actionFunctions _) _ |- _ =>
      inv Ha; [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ] end.
    match goal with Hg : (PTree.set _ _ (PTree.set _ _ _)) ! object_helpers._actionFunctions = Some _ |- _ =>
      rewrite PTree.gso in Hg by discriminate; rewrite PTree.gso in Hg by discriminate;
      rewrite PTree.gss in Hg; injection Hg as <- end.
    match goal with Hs : sem_binary_operation _ Oadd (Vptr bt _) _ _ _ _ = Some (Vptr ?l ?o) |- _ =>
      assert (El : l = bt)
        by (cbn in Hs; unfold sem_add in Hs; cbn in Hs;
            match type of Hs with context [match ?v with _ => _ end] => destruct v end;
            try discriminate Hs; injection Hs as <- _; reflexivity);
      subst l end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      try (match goal with Ha : access_mode _ = By_reference |- _ => cbn in Ha; discriminate Ha end);
      try (match goal with Ha : access_mode _ = By_copy |- _ => cbn in Ha; discriminate Ha end).
    match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
    match goal with Hl : Mem.loadv _ _ _ = Some v3 |- _ => cbn in Hl; rename Hl into Hld end.
    (* the callee is a table entry *)
    match goal with Hf : Genv.find_funct _ v3 = Some _ |- _ => rename Hf into Hf3 end.
    destruct v3 as [| | | | | b3 o3]; try discriminate Hf3.
    assert (Eo3 : o3 = Ptrofs.zero)
      by (unfold Genv.find_funct in Hf3; destruct (Ptrofs.eq_dec o3 Ptrofs.zero); [ assumption | discriminate Hf3 ]).
    subst o3.
    destruct (Hro t bt _ b3 Ptrofs.zero Ht Hbt Hld) as (g & Hin & Hg).
    pose proof (proj1 (forallb_forall _ _) tentries_sig t Ht) as Hsig. cbv beta in Hsig.
    pose proof (proj1 (forallb_forall _ _) Hsig g (tentries_in _ _ _ Hin)) as Hsg. cbv beta in Hsg.
    destruct (ut_find g (tab_ut atab ++ aleaf)) as [[[pcs rc] dme]|] eqn:Eg; [ | discriminate Hsg ].
    destruct pcs; [ | discriminate Hsg ]. destruct rc; try discriminate Hsg.
    destruct dme; [ discriminate Hsg | ].
    pose proof (act_xspec g _ b3 _ Eg Hg Hf3) as Hsp.
    match goal with Hx : eval_exprlist _ _ _ _ [] _ _ |- _ => inv Hx end.
    (* restart the callee at the caller's nextblock *)
    pose proof Hi as (Hof & Hnb & _).
    set (nb1 := Mem.nextblock m1).
    assert (HN1 : Hn nl nb1) by exact (Hn_mono nl nb0 nb1 HN Hnb).
    assert (Hu1 : UInv lp bm bc oc0 SafeB nl false nb1 m1)
      by (split; [ exact Hof | split; [ apply Ple_refl | intros _; exact (rl_fresh lp SafeB nl nb1 m1 eq_refl) ] ]).
    match goal with Hc : eval_funcall _ _ m1 _ [] _ m' _ |- _ =>
      destruct (Hsp nb1 HN1 m1 [] _ m' _ Hc (Forall2_nil _) Hu1) as ((Hof' & Hnb' & _) & _ & HF & HX) end.
    split; [ | split; [ exact HF | exact (XS_mono SafeB nl nb0 nb1 m1 m' Hnb HX) ] ].
    split; [ exact Hof' | split; [ exact (Ple_trans _ _ _ Hnb Hnb') | intros E; discriminate E ] ].
  Qed.
End CAF.
