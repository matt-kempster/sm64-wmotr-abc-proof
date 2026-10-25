(* ====================================================================== *)
(* NpcDialogBody.v -- set_mario_npc_dialog (mario_actions_cutscene.c:345) *)
(* keeps GOAL 1's carried facts, from its REAL generated body (SPINE via  *)
(* UpdateCameraBody: the dialog cutscenes reach it through                *)
(* cutscene_common_set_dialog_state).                                     *)
(*                                                                        *)
(* The body names Mario only through the global gMarioState (no `m`      *)
(* parameter, so GOAL 1's m-param walkers do not apply).  A small        *)
(* SpawnBodies.sw_walk instance carries two temp facts:                  *)
(*   - every temp loaded from gMarioState holds (bm, 0) if a pointer      *)
(*     (MWF's gMarioState pin, mwf_real_pgms);                            *)
(*   - the temp loaded from gCurrentObject is SafeB if a pointer (the     *)
(*     global is SafeB, SafeB_syms_ok (c); MWF's R7 chase row).          *)
(* Its stores and calls:                                                  *)
(*   m->actionState = t + 1      a window store (mwf_real_window)         *)
(*   m->usedObj = gCurrentObject a SafeB chase-root store                 *)
(*                               (mwf_real_root_store)                    *)
(*   mario_ready_to_speak()      a store-free body: memory unchanged      *)
(*   set_mario_action(m, ACT_READING_NPC_DIALOG, arg)                     *)
(*                               GOAL 1's keystone row smact_pres; the    *)
(*                               action constant is untainted (vm).       *)
(* ZERO new trust.                                                        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 MWFReal SpawnInit MathBodies LinkedTwelve
  RealFrameValue.
From SM64.Proofs Require ObjExtBodies SpawnBodies MarioStepSurface ActWriterSurface
  MathGeomGated.

Import ListNotations.
Local Open Scope Z_scope.

Module C := mario_actions_cutscene.

(* ---------------------------------------------------------------------- *)
(* 1. The pinned facts (vm, on the generated AST).                         *)
(* ---------------------------------------------------------------------- *)

Lemma npc_dm :
  (prog_defmap C.prog) ! C._set_mario_npc_dialog
  = Some (Gfun (Internal C.f_set_mario_npc_dialog)).
Proof. vm_compute. reflexivity. Qed.

Lemma rts_dm :
  (prog_defmap C.prog) ! C._mario_ready_to_speak
  = Some (Gfun (Internal C.f_mario_ready_to_speak)).
Proof. vm_compute. reflexivity. Qed.

Lemma rts_pure : MarioStepSurface.pure_chk (fn_body C.f_mario_ready_to_speak) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma rts_vars : fn_vars C.f_mario_ready_to_speak = nil.
Proof. reflexivity. Qed.

Lemma npc_vars : fn_vars C.f_set_mario_npc_dialog = nil.
Proof. reflexivity. Qed.

(* the temps the body loads gMarioState into *)
Definition npc_mt : list ident :=
  [C._t'3; C._t'13; C._t'8; C._t'10; C._t'11; C._t'6; C._t'5].

(* the param is none of the tracked temps *)
Lemma npc_params_ok :
  forallb (fun t => negb (mem_id t (var_names (fn_params C.f_set_mario_npc_dialog))))
    (C._t'7 :: npc_mt) = true.
Proof. vm_compute. reflexivity. Qed.

Definition npc_set_ok (id : ident) (a : expr) : bool :=
  if mem_id id npc_mt then
    match a with
    | Evar x (Tpointer _ _) => Pos.eqb x mario._gMarioState
    | _ => false end
  else if Pos.eqb id C._t'7 then
    match a with
    | Evar x (Tpointer _ _) => Pos.eqb x C._gCurrentObject
    | _ => false end
  else true.

(* the two store shapes: a window field of *m, or the chase-root pointer
   field m->usedObj given the gCurrentObject temp *)
Definition npc_store_ok (l r : expr) : bool :=
  match l with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      mem_id p npc_mt
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && (mfield_geom_chk fld fty
          || (Pos.eqb fld mario._usedObj
              && match fty with Tpointer _ _ => true | _ => false end
              && match r with Etempvar t _ => Pos.eqb t C._t'7 | _ => false end))
  | _ => false
  end.

Definition npc_call_ok (optid : option ident) (a : expr) (al : list expr) : bool :=
  match a with
  | Evar fid (Tfunction targs _ _) =>
      (Pos.eqb fid C._mario_ready_to_speak
       && match optid with
          | Some t => negb (mem_id t npc_mt) && negb (Pos.eqb t C._t'7)
          | None => true end)
      || (Pos.eqb fid mario._set_mario_action
          && match optid with None => true | Some _ => false end
          && match targs, al with
             | ty1 :: ty2 :: _, Etempvar p pty :: Econst_int c cty :: _ =>
                 mem_id p npc_mt
                 && proj_sumbool (type_eq pty (tptr tyMS))
                 && proj_sumbool (type_eq ty1 (tptr tyMS))
                 && proj_sumbool (type_eq cty tint)
                 && proj_sumbool (type_eq ty2 tuint)
                 && ActWriterSurface.wact_const c
             | _, _ => false end)
  | _ => false
  end.

(* NON-VACUITY: the real body passes *)
Lemma npc_walk_ok :
  SpawnBodies.sw_chk npc_set_ok npc_store_ok npc_call_ok (fun _ => true)
    (fn_body C.f_set_mario_npc_dialog) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Generic bricks.                                                      *)
(* ---------------------------------------------------------------------- *)

(* a store-free body with no locals leaves memory identical *)
Lemma pure_funcall_memid : forall (ge : genv) f m vargs t m' vres,
    fn_vars f = nil -> MarioStepSurface.pure_chk (fn_body f) = true ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres -> m' = m.
Proof.
  intros ge f m vargs t m' vres Hv Hp Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hv in Ha; inv Ha end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    pose proof (MarioStepSurface.pure_walk _ _ _ _ _ _ _ _ _ Hx Hp) as Em end.
  subst.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
    replace (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hf by reflexivity;
    cbn [Mem.free_list] in Hf; injection Hf as <- end.
  reflexivity.
Qed.

Lemma actionState_off :
  field_offset (prog_comp_env mario.prog) mario._actionState mario_state_members
    = Errors.OK (24, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma usedObj_off :
  field_offset (prog_comp_env mario.prog) mario._usedObj mario_state_members
    = Errors.OK (128, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma usedObj_root : mem_id mario._usedObj chase_root_fields = true.
Proof. vm_compute. reflexivity. Qed.

Lemma usedObj_ne : mario._usedObj <> mario._marioObj.
Proof. intros E. pose proof (f_equal (fun x => Pos.eqb x mario._marioObj) E) as F.
  vm_compute in F. discriminate F. Qed.

Lemma gco_safe_sym : mem_id C._gCurrentObject safe_ptr_syms = true.
Proof. vm_compute. reflexivity. Qed.

Lemma t7_not_mt : mem_id C._t'7 npc_mt = false.
Proof. vm_compute. reflexivity. Qed.

Lemma win_bounds : forall d n,
    store_window_ok d n = true ->
    0 <= d /\ d + n <= Ptrofs.max_unsigned /\ (d + n <= 12 \/ 16 <= d).
Proof.
  intros d n H. unfold store_window_ok in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hb : (_ || _) = true |- _ => apply orb_true_iff in Hb
         end.
  repeat match goal with
         | Hb : (_ <=? _) = true |- _ => apply Z.leb_le in Hb
         | Hb : (_ <=? _) = true \/ (_ <=? _) = true |- _ =>
             destruct Hb as [Hb | Hb]; apply Z.leb_le in Hb
         end.
  all: lia.
Qed.

(* a store at bm outside [12,16) keeps the action cell *)
Lemma store_keeps_act : forall ch m bm d v m',
    Mem.store ch m bm d v = Some m' ->
    (d + size_chunk ch <= 12 \/ 16 <= d) ->
    Mem.valid_block m bm -> action_sat not_tainted m bm ->
    Mem.valid_block m' bm /\ action_sat not_tainted m' bm.
Proof.
  intros ch m bm d v m' Hs Hd Hv Hsat.
  split; [ eauto using Mem.store_valid_block_1 | ].
  eapply action_sat_unchanged_on with (m := m); [ | exact Hv | exact Hsat ].
  eapply Mem.store_unchanged_on; [ exact Hs | ].
  intros i Hi (_ & Hc). cbn in Hc. lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The proof, at the concrete MWF_real.                                 *)
(* ---------------------------------------------------------------------- *)

Section Npc.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Let Hbc_bm := ObjExtBodies.ox_Hbc_bm lp bm bc oc0 Hspawn.
  Let Hnot_bm := ObjExtBodies.ox_not_bm lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hnot_bc := ObjExtBodies.ox_not_bc lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hgms := ObjExtBodies.ox_gms lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hgt := ObjExtBodies.ox_gtimer lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Htb := ObjExtBodies.ox_table lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hkt := ObjExtBodies.ox_ktab lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hglob := ObjExtBodies.ox_glob lp bm bc oc0 SafeB HSafeB_syms Hspawn.

  (* GOAL 1's keystone row, at the concrete MWF *)
  Lemma npc_smact : ActWriterSurface.call_pres_act lp bm NoA MWF mario._set_mario_action.
  Proof.
    exact (ActWriterSurface.smact_pres lp (linked12_LO_mario lp H12) (linked12_LO_stp lp H12)
             bm NoA MWF
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hgms Hgt Htb Hkt)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hgms Hgt Htb Hkt)
             SafeB Hnot_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hnot_bc Hgms Hgt Htb Hkt)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hgms Hgt Htb Hkt)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hnot_bc Hgms Hgt Htb Hkt)).
  Qed.

  (* the temp invariant *)
  Definition NP (le : temp_env) : Prop :=
    (forall t b o, mem_id t npc_mt = true -> le ! t = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero)
    /\ (forall b o, le ! C._t'7 = Some (Vptr b o) -> SafeB b).

  Let OW := ow_facts bm MWF.

  Lemma np_set_other : forall le t v,
      NP le -> mem_id t npc_mt = false -> Pos.eqb t C._t'7 = false ->
      NP (PTree.set t v le).
  Proof.
    intros le t v (H1 & H2) Hm H7. split.
    - intros t' b o Hm' Hg. rewrite PTree.gsspec in Hg.
      destruct (peq t' t) as [-> | Hne]; [ congruence | exact (H1 t' b o Hm' Hg) ].
    - intros b o Hg. rewrite PTree.gsspec in Hg.
      destruct (peq C._t'7 t) as [E | Hne];
        [ subst t; rewrite Pos.eqb_refl in H7; discriminate H7 | exact (H2 b o Hg) ].
  Qed.

  (* a pointer-typed global load in the empty env *)
  Lemma gload : forall le m x ty att v,
      eval_expr ge empty_env le m (Evar x (Tpointer ty att)) v ->
      exists gb, Genv.find_symbol ge x = Some gb /\ Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some v.
  Proof.
    intros le m x ty att v Hev.
    apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hlv & Hd).
    inv Hlv; [ match goal with Hn : empty_env ! _ = Some _ |- _ =>
                 rewrite PTree.gempty in Hn; discriminate Hn end | ].
    exists loc. split; [ assumption | ].
    inv Hd; try (match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; discriminate Hm end).
    match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; injection Hm as <- end.
    assumption.
  Qed.

  Lemma npc_set : forall id a le m v,
      npc_set_ok id a = true -> NP le -> OW m ->
      eval_expr ge empty_env le m a v -> NP (PTree.set id v le).
  Proof.
    intros id a le m v Hok (Hp1 & Hp7) (_ & _ & HM) Hev.
    unfold npc_set_ok in Hok.
    destruct (mem_id id npc_mt) eqn:Em.
    - destruct a as [ | | | | x [ | | | | pt pa | | | | ] | | | | | | | | | ];
        try discriminate Hok.
      apply Pos.eqb_eq in Hok. subst x.
      destruct (gload _ _ _ _ _ _ Hev) as (gb & Hs & Hld).
      split.
      + intros t' b o Hm' Hg. rewrite PTree.gsspec in Hg.
        destruct (peq t' id) as [-> | Hne].
        * injection Hg as ->.
          exact (mwf_real_pgms lp bm bc oc0 SafeB m gb b o HM Hs Hld).
        * exact (Hp1 t' b o Hm' Hg).
      + intros b o Hg. rewrite PTree.gsspec in Hg.
        destruct (peq C._t'7 id) as [E | Hne].
        * rewrite <- E, t7_not_mt in Em. discriminate Em.
        * exact (Hp7 b o Hg).
    - destruct (Pos.eqb id C._t'7) eqn:E7.
      + apply Pos.eqb_eq in E7. subst id.
        destruct a as [ | | | | x [ | | | | pt pa | | | | ] | | | | | | | | | ];
          try discriminate Hok.
        apply Pos.eqb_eq in Hok. subst x.
        destruct (gload _ _ _ _ _ _ Hev) as (gb & Hs & Hld).
        assert (Hsg : SafeB gb).
        { pose proof HSafeB_syms as (_ & _ & Hc). exact (Hc _ gb gco_safe_sym Hs). }
        split.
        * intros t' b o Hm' Hg. rewrite PTree.gsspec in Hg.
          destruct (peq t' C._t'7) as [-> | Hne];
            [ rewrite t7_not_mt in Hm'; discriminate Hm' | exact (Hp1 t' b o Hm' Hg) ].
        * intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
          exact (mwf_real_chase_step lp bm bc oc0 SafeB m gb Ptrofs.zero b o HM Hsg Hld).
      + exact (np_set_other le id v (conj Hp1 Hp7) Em E7).
  Qed.

  Lemma npc_store : forall lv rhs le m t le' m' out,
      npc_store_ok lv rhs = true -> NP le ->
      exec_stmt function_entry2 ge empty_env le m (Sassign lv rhs) t le' m' out ->
      OW m -> OW m'.
  Proof.
    intros lv rhs le m t le' m' out Hok (Hp1 & Hp7) Hx (Hv & Hsat & HM).
    destruct lv as [ | | | | | | | | | | | a0 fld fty | | ]; try discriminate Hok.
    destruct a0 as [ | | | | | | a1 sty | | | | | | | ]; try discriminate Hok.
    destruct a1 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hok.
    unfold npc_store_ok in Hok.
    apply andb_prop in Hok as [Hok Hfld].
    apply andb_prop in Hok as [Hok Hsty]. apply andb_prop in Hok as [Hmp Hpty].
    apply proj_sumbool_true in Hpty. apply proj_sumbool_true in Hsty. subst pty sty.
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename Hl into Hlv end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => rename Hc into Hcast end.
    pose proof Hlv as Hlv0.
    apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hb0).
    apply eval_expr_Ederef_load in Hb0 as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (Hp1 _ _ _ Hmp Hlvb) as [-> ->].
    apply orb_prop in Hfld as [Hg | Hu].
    - (* a window store *)
      destruct (mfield_geom_chk_sound _ _ Hg) as (delta & ch & Hfo & Hac & Hw).
      destruct (mfield_lvalue_geom_lp lp (linked12_LO_mario lp H12)
                  _ _ _ _ _ _ _ _ _ _ _ _ Hlvb Hfo Hlv) as (-> & -> & ->).
      destruct (win_bounds _ _ Hw) as (Hd0 & Hd1 & Hd2).
      inv Hal; try (match goal with Hm : access_mode _ = By_copy |- _ =>
                      cbn [typeof] in Hm; rewrite Hac in Hm; discriminate Hm end).
      + match goal with Hm : access_mode (typeof _) = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
          cbn [typeof] in Hm; rewrite Hac in Hm; injection Hm as <-; rename Hs into Hst end.
        cbn [Mem.storev] in Hst.
        rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in Hst
          by (pose proof (size_chunk_pos ch); lia).
        destruct (store_keeps_act _ _ _ _ _ _ Hst Hd2 Hv Hsat) as (Hv' & Hsat').
        split; [ exact Hv' | split; [ exact Hsat' | ] ].
        exact (mwf_real_window lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hgms Hgt Htb Hkt
                 _ _ _ _ _ HM Hw Hst).
    - (* m->usedObj = the gCurrentObject temp *)
      apply andb_prop in Hu as [Hu Hr]. apply andb_prop in Hu as [Hu Hpt].
      apply Pos.eqb_eq in Hu. subst fld.
      destruct (mfield_lvalue_geom_lp lp (linked12_LO_mario lp H12)
                  _ _ _ _ _ _ _ _ _ _ _ _ Hlvb usedObj_off Hlv) as (-> & -> & ->).
      destruct rhs as [ | | | | | t7 t7ty | | | | | | | | ]; try discriminate Hr.
      apply Pos.eqb_eq in Hr. subst t7.
      match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in He; rename He into Hle7 end.
      destruct fty as [ | | | | fpt fpa | | | | ]; try discriminate Hpt.
      inv Hal; try (match goal with Hm : access_mode _ = By_copy |- _ =>
                      cbn in Hm; discriminate Hm end).
      + match goal with Hm : access_mode _ = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
          cbn in Hm; injection Hm as <-; rename Hs into Hst end.
        cbn [Mem.storev] in Hst.
        rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in Hst
          by (unfold Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize;
              destruct Archi.ptr64; cbn; lia).
        destruct (store_keeps_act _ _ _ _ _ _ Hst ltac:(right; lia) Hv Hsat) as (Hv' & Hsat').
        split; [ exact Hv' | split; [ exact Hsat' | ] ].
        refine (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hgms Hgt Htb Hkt
                  _ _ _ _ _ usedObj_root usedObj_ne usedObj_off _ HM Hst).
        intros bb oo E. subst.
        apply sem_cast_ptr_result_inv in Hcast. subst.
        exact (Hp7 bb oo Hle7).
  Qed.

  Lemma npc_call : forall optid a al le m t le' m' out,
      npc_call_ok optid a al = true -> NP le ->
      exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
      OW m -> OW m' /\ NP le'.
  Proof.
    intros optid a al le m t le' m' out Hok Hp Hx Hf.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [npc_call_ok] in Hok.
    inv Hx.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (MathGeomGated.evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _))
        as (lf & Hsy & ->) end.
    match goal with H : Genv.find_funct _ _ = Some _ |- _ => rename H into Hff end.
    match goal with H : eval_funcall _ _ _ _ _ _ _ _ |- _ => rename H into Hfc end.
    match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => rename H into Hargs end.
    apply orb_prop in Hok as [Hok | Hok].
    - (* mario_ready_to_speak: a store-free body *)
      apply andb_prop in Hok as [Hid Hopt]. apply Pos.eqb_eq in Hid. subst fid.
      destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_cut lp H12) rts_dm)
        as (b' & Hs' & Hff').
      unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-.
      rewrite (pure_funcall_memid _ _ _ _ _ _ _ rts_vars rts_pure Hfc).
      split; [ exact Hf | ].
      destruct optid as [t0|]; cbn [set_opttemp]; [ | exact Hp ].
      apply andb_prop in Hopt as [Ho1 Ho2]. apply negb_true_iff in Ho1. apply negb_true_iff in Ho2.
      exact (np_set_other _ _ _ Hp Ho1 Ho2).
    - (* set_mario_action(m, ACT_READING_NPC_DIALOG, arg): GOAL 1's row *)
      apply andb_prop in Hok as [Hok Hsh]. apply andb_prop in Hok as [Hid Hopt].
      apply Pos.eqb_eq in Hid. subst fid.
      destruct optid as [t0|]; [ discriminate Hopt | ].
      destruct targs as [ | ty1 [ | ty2 tys ] ]; try discriminate Hsh.
      destruct al as [ | a1 al ]; [ discriminate Hsh | ].
      destruct a1 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hsh.
      destruct al as [ | a2 al ]; [ discriminate Hsh | ].
      destruct a2 as [ c cty | | | | | | | | | | | | | ]; try discriminate Hsh.
      cbv beta iota in Hsh.
      repeat (apply andb_prop in Hsh as [Hsh ?]).
      repeat match goal with Hb : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hb end.
      subst.
      match goal with Hcl : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcl; injection Hcl as E1 E2 E3; subst end.
      inv Hargs.
      match goal with Ha : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Ha end.
      match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in He; rename He into Hlep end.
      match goal with He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv He; try (match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end) end.
      match goal with Hc : sem_cast (Vint c) _ _ _ = Some _ |- _ =>
        cbn in Hc; injection Hc as <- end.
      destruct Hf as (Hv & Hsat & HM).
      match goal with H : eval_funcall _ _ _ _ ?va _ _ _ |- _ => assert (Hmarg : marg_ok bm va) end.
      { destruct Hp as (Hp1 & _).
        match goal with Hc : sem_cast ?v1 _ _ _ = Some ?v1' |- marg_ok _ (?v1' :: _) =>
          destruct v1' as [ | | | | | b0 o0 ] eqn:Ev1; cbn; try exact I;
          apply sem_cast_ptr_result_inv in Hc; subst v1; exact (Hp1 _ _ _ Hsh Hlep) end. }
      destruct (npc_smact _ _ _ _ _ _ _ _ Hfc
                  (ex_intro _ lf (conj Hsy Hff))
                  Hmarg
                  (ActWriterSurface.wact_const_sound c ltac:(assumption))
                  (mwf_real_ctl lp bm bc oc0 SafeB m HM) HM Hv Hsat)
        as (Hv' & Hsat' & HM' & _ & _).
      split; [ exact (conj Hv' (conj Hsat' HM')) | exact Hp ].
  Qed.

  (* THE BODY: for any function shaped like set_mario_npc_dialog *)
  Lemma npc_body_gen : forall f,
      fn_vars f = nil ->
      SpawnBodies.sw_chk npc_set_ok npc_store_ok npc_call_ok (fun _ => true) (fn_body f) = true ->
      forallb (fun t => negb (mem_id t (var_names (fn_params f)))) (C._t'7 :: npc_mt) = true ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
        OW m -> OW m'.
  Proof.
    intros f Hvars Hchk Hpar m vargs t m' vres Hevf Hf.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hvars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
      rename Hb into Hbind; rename L into le0 end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    replace (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree by reflexivity.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    assert (Hnp : forall t0, In t0 (C._t'7 :: npc_mt) -> ~ In t0 (var_names (fn_params f))).
    { intros t0 Ht0 Hin.
      pose proof (proj1 (forallb_forall _ _) Hpar t0 Ht0) as Hn. cbv beta in Hn.
      assert (Hm : mem_id t0 (var_names (fn_params f)) = true).
      { apply existsb_exists. exists t0. split; [ exact Hin | apply Pos.eqb_refl ]. }
      rewrite Hm in Hn. discriminate Hn. }
    assert (Hin_mt : forall t0, mem_id t0 npc_mt = true -> In t0 (C._t'7 :: npc_mt)).
    { intros t0 Hm. apply existsb_exists in Hm as (x & Hx & Hq).
      apply Pos.eqb_eq in Hq. subst x. right. exact Hx. }
    assert (Hp0 : NP le0).
    { split.
      - intros t0 b o Hm Hg.
        rewrite (bind_parameter_temps_other _ _ _ _ _ Hbind (Hnp t0 (Hin_mt t0 Hm))) in Hg.
        apply create_undef_temps_Vundef in Hg. discriminate Hg.
      - intros b o Hg.
        rewrite (bind_parameter_temps_other _ _ _ _ _ Hbind (Hnp _ (or_introl eq_refl))) in Hg.
        apply create_undef_temps_Vundef in Hg. discriminate Hg. }
    exact (proj1 (SpawnBodies.sw_walk ge empty_env OW NP (fun _ => True)
                    npc_set_ok npc_store_ok npc_call_ok (fun _ => true)
                    npc_set npc_store npc_call (fun _ _ _ _ _ _ _ _ => I)
                    _ _ _ _ _ _ _ _ Hbody eq_refl Hchk Hp0 Hf)).
  Qed.

  (* THE RESULT: the real set_mario_npc_dialog keeps the carried facts *)
  Theorem sp_npc_dialog :
    ObjExtBodies.sym_pres lp bm bc oc0 SafeB C._set_mario_npc_dialog.
  Proof.
    apply (ObjExtBodies.sym_pres_of_body lp bm bc oc0 SafeB C.prog _ _
             (linked12_LO_cut lp H12) npc_dm).
    exact (npc_body_gen _ npc_vars npc_walk_ok npc_params_ok).
  Qed.
End Npc.
