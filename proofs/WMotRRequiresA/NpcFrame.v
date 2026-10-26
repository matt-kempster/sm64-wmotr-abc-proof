(* spine (via ObjFrame): OBJECTS S3 -- the frame of set_mario_npc_dialog, walked over the
   real generated bodies of its whole call tree (ObjFrame's Hnpc_fr). *)
(* ====================================================================== *)
(* NpcFrame.v -- what set_mario_npc_dialog may write.                     *)
(*                                                                        *)
(* GOAL 1's smact_pres row says the npc call keeps MWF; ObjFrame also     *)
(* needs its FRAME: which cells it may change.  This file walks the real  *)
(* bodies of the call tree                                                *)
(*                                                                        *)
(*   set_mario_npc_dialog -> mario_ready_to_speak (pure), set_mario_action *)
(*   set_mario_action -> set_mario_action_{moving,airborne,submerged,     *)
(*                        cutscene}                                       *)
(*   _moving    -> mario_get_floor_class, mario_facing_downhill (pure)    *)
(*   _airborne  -> set_mario_y_vel_based_on_fspeed                        *)
(*                   -> get_additive_y_vel_for_jumps (pure)               *)
(*   _cutscene  -> mario_set_forward_vel                                  *)
(*                                                                        *)
(* with one fixed reference memory m0 (where MWF holds) and the frame     *)
(*   NF m = Mem.unchanged_on (not FPn) m0 m,                              *)
(*   FPn b ofs = SafeB b \/ (b = bm /\ ofs in npc_cells).                 *)
(* The temp invariant: Mario temps (the gMarioState load, or the _m       *)
(* parameter) hold (bm, 0); marioObj temps (m->marioObj) hold a SafeB     *)
(* pointer.  Both loads are read in m0 through NF (neither cell is in the *)
(* frame) and pinned by MWF there (mwf_real_pgms / mwf_real_chase_root).  *)
(* Store arms: a field or array element of *m inside npc_cells, or any    *)
(* address rooted at a marioObj temp (a SafeB block).                     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step mario_actions_cutscene level_update.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit MathBodies
  LinkedTwelve LocalVarsSurface SpawnBodies MathGeomGated UcKit ObjWalk.
From SM64.Proofs Require MtxfBody ObjHelpersBodies NpcDialogBody MarioStepSurface
  UpdateCameraBody SaveFileBody.

Import ListNotations.
Local Open Scope Z_scope.

Module C := mario_actions_cutscene.

(* ---------------------------------------------------------------------- *)
(* 1. The cells and the checks.                                           *)
(* ---------------------------------------------------------------------- *)

Definition npc_cells : list (Z * Z) :=
  [(mfo mario._flags, 4); (mfo mario._prevAction, 4); (mfo mario._action, 4);
   (mfo mario._actionArg, 4); (mfo mario._actionState, 2); (mfo mario._actionTimer, 2);
   (mfo mario._forwardVel, 4); (mfo mario._slideVelX, 4); (mfo mario._slideVelZ, 4);
   (mfo mario._vel, 12); (mfo mario._faceAngle, 6); (mfo mario._wallKickTimer, 1);
   (mfo mario._peakHeight, 4); (mfo mario._usedObj, 4)].

(* flags, prevAction, action, actionArg, actionState, actionTimer, forwardVel,
   slideVelX, slideVelZ, vel[0..2], faceAngle[0..2], wallKickTimer, peakHeight,
   usedObj -- and NOT marioObj (136) *)
Lemma npc_cells_value : npc_cells =
  [(4, 4); (16, 4); (12, 4); (28, 4); (24, 2); (26, 2); (84, 4); (88, 4); (92, 4);
   (72, 12); (44, 6); (42, 1); (188, 4); (128, 4)].
Proof. vm_compute. reflexivity. Qed.

Lemma marioObj_off :
  field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members = OK (136, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma marioObj_root : mem_id mario._marioObj chase_root_fields = true.
Proof. vm_compute. reflexivity. Qed.

Lemma marioObj_out : forall i, 136 <= i < 136 + 4 -> ~ in_mcells npc_cells i.
Proof.
  intros i Hi (c & Hc & Hr). rewrite npc_cells_value in Hc.
  repeat (destruct Hc as [<- | Hc]; [ cbn in Hr; lia | ]). destruct Hc.
Qed.

(* m->marioObj *)
Definition mobj_shape (mts : list ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld (Tpointer _ _) =>
      mem_id p mts && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS) && Pos.eqb fld mario._marioObj
  | _ => false
  end.

Fixpoint mobj_temps (mts : list ident) (s : statement) : list ident :=
  match s with
  | Sset id a => if mobj_shape mts a then [id] else []
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => mobj_temps mts s1 ++ mobj_temps mts s2
  | Sswitch _ sl => mobj_temps_ls mts sl
  | _ => []
  end
with mobj_temps_ls (mts : list ident) (sl : labeled_statements) : list ident :=
  match sl with
  | LSnil => []
  | LScons _ s sl' => mobj_temps mts s ++ mobj_temps_ls mts sl'
  end.

Definition nset (mts ots : list ident) (id : ident) (a : expr) : bool :=
  if mem_id id mts then negb (mem_id id ots) && gms_shape a
  else if mem_id id ots then mobj_shape mts a
  else true.

(* an address rooted at a temp: temp, then aggregate steps / pointer + int *)
Fixpoint troot_e (a : expr) : option ident :=
  match a with
  | Etempvar t _ => Some t
  | Ebinop Oadd a1 a2 _ =>
      match classify_add (typeof a1) (typeof a2) with
      | add_case_pi _ _ => troot_e a1
      | _ => None
      end
  | Efield a' _ ty => if by_addr ty then troot_e a' else None
  | Ederef a' ty => if by_addr ty then troot_e a' else None
  | _ => None
  end.

Definition troot_l (a : expr) : option ident :=
  match a with
  | Ederef a' _ => troot_e a'
  | Efield a' _ _ => troot_e a'
  | _ => None
  end.

(* store arm 0: into the block of a marioObj temp *)
Definition nst0 (ots : list ident) (l : expr) : bool :=
  match troot_l l with Some t => mem_id t ots | None => false end.

(* store arm 1: m->fld, inside npc_cells *)
Definition fcell (fld : ident) (fty : type) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (d, Full) =>
      match access_mode fty with
      | By_value ch => (0 <=? d) && (d + size_chunk ch <=? Ptrofs.max_unsigned)
                       && cell_cover npc_cells d (size_chunk ch)
      | _ => false
      end
  | _ => false
  end.

Definition nst1 (mts : list ident) (l : expr) : bool :=
  match l with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      mem_id p mts && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS) && fcell fld fty
  | _ => false
  end.

(* store arm 2: m->fld[k], inside npc_cells *)
Definition esz (ty : type) : Z :=
  match ty with
  | Tint I16 _ _ => 2
  | Tfloat F32 _ => 4
  | _ => 0
  end.

Definition acell (fld : ident) (ety : type) (k : int) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (d, Full) =>
      match access_mode ety with
      | By_value ch =>
          (0 <? esz ety) && (size_chunk ch =? esz ety) && (0 <=? d) && (0 <=? Int.signed k)
          && (d + esz ety * Int.signed k + esz ety <=? Ptrofs.max_unsigned)
          && cell_cover npc_cells (d + esz ety * Int.signed k) (esz ety)
      | _ => false
      end
  | _ => false
  end.

Definition nst2 (mts : list ident) (l : expr) : bool :=
  match l with
  | Ederef (Ebinop Oadd (Efield (Ederef (Etempvar p pty) sty) fld (Tarray ety n att))
                        (Econst_int k kt) pt) ety' =>
      mem_id p mts && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS) && proj_sumbool (type_eq ety' ety)
      && proj_sumbool (type_eq kt tint) && acell fld ety k
  | _ => false
  end.

Definition nstore (mts ots : list ident) (l r : expr) : bool :=
  nst0 ots l || nst1 mts l || nst2 mts l.

(* the store-free leaves *)
Definition pure_ids : list ident :=
  [C._mario_ready_to_speak; mario._mario_get_floor_class; mario._mario_facing_downhill;
   mario_step._get_additive_y_vel_for_jumps].

Definition ncall (mts ots fl : list ident) (optid : option ident) (a : expr) (al : list expr) : bool :=
  match optid with Some id => negb (mem_id id mts) && negb (mem_id id ots) | None => true end
  && match a with
     | Evar fid (Tfunction _ _ _) =>
         mem_id fid pure_ids
         || (mem_id fid fl && match al with Etempvar p _ :: _ => mem_id p mts | _ => false end)
     | _ => false
     end.

(* params: only the first may be a Mario temp; none a marioObj temp *)
Definition pchk (mts ots : list ident) (names : list ident) : bool :=
  match names with
  | [] => true
  | x :: rest => negb (mem_id x ots)
                 && forallb (fun p => negb (mem_id p mts) && negb (mem_id p ots)) rest
  end.

Definition fchk (mts fl : list ident) (f : Clight.function) : bool :=
  let ots := mobj_temps mts (fn_body f) in
  SpawnBodies.sw_chk (nset mts ots) (nstore mts ots) (ncall mts ots fl) (fun _ => true) (fn_body f)
  && pchk mts ots (map fst (fn_params f))
  && match fn_vars f with [] => true | _ => false end.

Definition mts_m : list ident := [mario._m].

(* ---- the pinned facts about the real tree (NON-VACUITY: the bodies pass) ---- *)

Lemma dm_yvel : (prog_defmap mario.prog) ! mario._set_mario_y_vel_based_on_fspeed
  = Some (Gfun (Internal mario.f_set_mario_y_vel_based_on_fspeed)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fwd : (prog_defmap mario.prog) ! mario._mario_set_forward_vel
  = Some (Gfun (Internal mario.f_mario_set_forward_vel)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_sub : (prog_defmap mario.prog) ! mario._set_mario_action_submerged
  = Some (Gfun (Internal mario.f_set_mario_action_submerged)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cut : (prog_defmap mario.prog) ! mario._set_mario_action_cutscene
  = Some (Gfun (Internal mario.f_set_mario_action_cutscene)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_mov : (prog_defmap mario.prog) ! mario._set_mario_action_moving
  = Some (Gfun (Internal mario.f_set_mario_action_moving)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_air : (prog_defmap mario.prog) ! mario._set_mario_action_airborne
  = Some (Gfun (Internal mario.f_set_mario_action_airborne)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_sma : (prog_defmap mario.prog) ! mario._set_mario_action
  = Some (Gfun (Internal mario.f_set_mario_action)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_floor : (prog_defmap mario.prog) ! mario._mario_get_floor_class
  = Some (Gfun (Internal mario.f_mario_get_floor_class)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_down : (prog_defmap mario.prog) ! mario._mario_facing_downhill
  = Some (Gfun (Internal mario.f_mario_facing_downhill)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_addy : (prog_defmap mario_step.prog) ! mario_step._get_additive_y_vel_for_jumps
  = Some (Gfun (Internal mario_step.f_get_additive_y_vel_for_jumps)).
Proof. vm_compute. reflexivity. Qed.

Lemma pure_floor : fn_vars mario.f_mario_get_floor_class = nil
  /\ MarioStepSurface.pure_chk (fn_body mario.f_mario_get_floor_class) = true.
Proof. split; vm_compute; reflexivity. Qed.
Lemma pure_down : fn_vars mario.f_mario_facing_downhill = nil
  /\ MarioStepSurface.pure_chk (fn_body mario.f_mario_facing_downhill) = true.
Proof. split; vm_compute; reflexivity. Qed.
Lemma pure_addy : fn_vars mario_step.f_get_additive_y_vel_for_jumps = nil
  /\ MarioStepSurface.pure_chk (fn_body mario_step.f_get_additive_y_vel_for_jumps) = true.
Proof. split; vm_compute; reflexivity. Qed.

Lemma chk_yvel : fchk mts_m [] mario.f_set_mario_y_vel_based_on_fspeed = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_fwd : fchk mts_m [] mario.f_mario_set_forward_vel = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_sub : fchk mts_m [] mario.f_set_mario_action_submerged = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cut : fchk mts_m [mario._mario_set_forward_vel] mario.f_set_mario_action_cutscene = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_mov : fchk mts_m [] mario.f_set_mario_action_moving = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_air : fchk mts_m [mario._set_mario_y_vel_based_on_fspeed; mario._mario_set_forward_vel] mario.f_set_mario_action_airborne = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_sma : fchk mts_m [mario._set_mario_action_moving; mario._set_mario_action_airborne;
                            mario._set_mario_action_submerged; mario._set_mario_action_cutscene]
                  mario.f_set_mario_action = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_npc : fchk NpcDialogBody.npc_mt [mario._set_mario_action] C.f_set_mario_npc_dialog = true.
Proof. vm_compute. reflexivity. Qed.


Lemma gms_ne : mario._gMarioState <> level_update._gMarioStates.
Proof. intro E. vm_compute in E. discriminate E. Qed.

Lemma mobj_ofs : Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136)) = 136.
Proof. reflexivity. Qed.

Lemma size_mptr : size_chunk Mptr = 4.
Proof. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Generic bricks.                                                     *)
(* ---------------------------------------------------------------------- *)

(* a temp-rooted address lies in the block the temp points into *)
Lemma troot_e_val : forall (ge : genv) e le m a t b o,
    troot_e a = Some t -> eval_expr ge e le m a (Vptr b o) ->
    exists o', le ! t = Some (Vptr b o').
Proof.
  intros ge e le m a. induction a; intros tr b0 o0 Hg Hev; try discriminate Hg;
    cbn [troot_e] in Hg.
  - (* Etempvar *)
    injection Hg as <-. exists o0. exact (eval_expr_Etempvar_val _ _ _ _ _ _ _ Hev).
  - (* Ederef *)
    destruct (by_addr t) eqn:Hba; [ | discriminate Hg ].
    apply eval_expr_Ederef_load in Hev as (loc & ofs & bf & Hlv & Hd).
    apply eval_lvalue_Ederef_base in Hlv.
    pose proof (SaveFileBody.deref_agg_val _ _ _ _ _ _ Hba Hd) as E.
    injection E as -> ->.
    exact (IHa _ _ _ Hg Hlv).
  - (* Ebinop Oadd, pointer + int *)
    destruct b; try discriminate Hg.
    destruct (classify_add (typeof a1) (typeof a2)) eqn:Hca; try discriminate Hg.
    inv Hev.
    2:{ match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end. }
    match goal with
    | Hsem : sem_binary_operation _ Oadd ?v1 _ ?v2 _ _ = Some _,
      Hev1 : eval_expr _ _ _ _ a1 ?v1 |- _ =>
        unfold sem_binary_operation, sem_add in Hsem; rewrite Hca in Hsem;
        unfold sem_add_ptr_int in Hsem;
        destruct v1; destruct v2; try discriminate Hsem;
        try (destruct Archi.ptr64; discriminate Hsem);
        injection Hsem as E1 _; subst; exact (IHa1 _ _ _ Hg Hev1)
    end.
  - (* Efield *)
    destruct (by_addr t) eqn:Hba; [ | discriminate Hg ].
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hd).
    pose proof (SaveFileBody.deref_agg_val _ _ _ _ _ _ Hba Hd) as E.
    injection E as -> ->.
    apply eval_lvalue_Efield_base in Hlv as (o1 & Hbase).
    exact (IHa _ _ _ Hg Hbase).
Qed.

Lemma troot_l_blk : forall (ge : genv) e le m a t loc ofs bf,
    troot_l a = Some t -> eval_lvalue ge e le m a loc ofs bf ->
    exists o', le ! t = Some (Vptr loc o').
Proof.
  intros ge e le m a t loc ofs bf Hg Hl.
  destruct a; try discriminate Hg; cbn [troot_l] in Hg.
  - apply eval_lvalue_Ederef_base in Hl. exact (troot_e_val _ _ _ _ _ _ _ _ Hg Hl).
  - apply eval_lvalue_Efield_base in Hl as (o0 & Hb). exact (troot_e_val _ _ _ _ _ _ _ _ Hg Hb).
Qed.

Lemma nst2_inv : forall mts l, nst2 mts l = true ->
    exists p fld ety n att k pt,
      l = Ederef (Ebinop Oadd (Efield (Ederef (Etempvar p (tptr tyMS)) tyMS) fld (Tarray ety n att))
                         (Econst_int k tint) pt) ety
      /\ mem_id p mts = true /\ acell fld ety k = true.
Proof.
  intros mts l H. unfold nst2 in H.
  repeat match type of H with
         | context [match ?x with _ => _ end] => destruct x; try discriminate H
         end.
  apply andb_prop in H as [H Hac]. apply andb_prop in H as [H Hkt].
  apply andb_prop in H as [H Hety]. apply andb_prop in H as [H Hsty].
  apply andb_prop in H as [Hmp Hpty].
  apply proj_sumbool_true in Hpty. apply proj_sumbool_true in Hsty.
  apply proj_sumbool_true in Hety. apply proj_sumbool_true in Hkt. subst.
  do 7 eexists. split; [ reflexivity | split; eassumption ].
Qed.

Lemma sizeof_esz :forall ce ty, 0 < esz ty -> sizeof ce ty = esz ty.
Proof.
  intros ce ty H.
  destruct ty as [ | i s a | s a | f a | t a | t z a | tl t c | i a | i a ];
    cbn in H |- *; try lia; [ destruct i | destruct f ]; cbn in H |- *; lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The frame walk.                                                     *)
(* ---------------------------------------------------------------------- *)

Section NpcF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.

  (* the store-free leaves leave memory identical *)
  Definition Psym (fid : ident) : Prop :=
    forall b fd, Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres -> m' = m.

  Lemma psym_of : forall q fid f, linkorder q lp ->
      (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil -> MarioStepSurface.pure_chk (fn_body f) = true -> Psym fid.
  Proof.
    intros q fid f LO Hdm Hv Hp b fd Hs Hf m vargs t m' vres Hev.
    destruct (linkorder_resolves_funct lp q fid f LO Hdm) as (b' & Hs' & Hf').
    unfold ge, lp_ge in Hs, Hf. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Hf' in Hf. injection Hf as <-.
    exact (NpcDialogBody.pure_funcall_memid _ _ _ _ _ _ _ Hv Hp Hev).
  Qed.

  Lemma pure_all : forall fid, mem_id fid pure_ids = true -> Psym fid.
  Proof.
    intros fid H. unfold pure_ids, mem_id in H. cbn [existsb] in H.
    apply orb_true_iff in H as [H | H].
    { apply Pos.eqb_eq in H. subst fid.
      exact (psym_of _ _ _ (linked12_LO_cut lp H12) NpcDialogBody.rts_dm
               NpcDialogBody.rts_vars NpcDialogBody.rts_pure). }
    apply orb_true_iff in H as [H | H].
    { apply Pos.eqb_eq in H. subst fid.
      exact (psym_of _ _ _ (linked12_LO_mario lp H12) dm_floor (proj1 pure_floor) (proj2 pure_floor)). }
    apply orb_true_iff in H as [H | H].
    { apply Pos.eqb_eq in H. subst fid.
      exact (psym_of _ _ _ (linked12_LO_mario lp H12) dm_down (proj1 pure_down) (proj2 pure_down)). }
    apply orb_true_iff in H as [H | H].
    { apply Pos.eqb_eq in H. subst fid.
      exact (psym_of _ _ _ (linked12_LO_stp lp H12) dm_addy (proj1 pure_addy) (proj2 pure_addy)). }
    discriminate H.
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

  (* the m->fld[k] lvalue *)
  Lemma arr_geom : forall e le m p fld ety n att k pt d loc ofs bf,
      (forall b o, le ! p = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members = OK (d, Full) ->
      0 < esz ety -> 0 <= d -> 0 <= Int.signed k ->
      d + esz ety * Int.signed k + esz ety <= Ptrofs.max_unsigned ->
      eval_lvalue ge e le m
        (Ederef (Ebinop Oadd (Efield (Ederef (Etempvar p (tptr tyMS)) tyMS) fld (Tarray ety n att))
                        (Econst_int k tint) pt) ety) loc ofs bf ->
      loc = bm /\ Ptrofs.unsigned ofs = d + esz ety * Int.signed k /\ bf = Full.
  Proof.
    intros e le m p fld ety n att k pt d loc ofs bf HP Hfo Hpos Hd0 Hk0 Hb Hlv.
    inv Hlv.
    match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => rename He into Hadd end.
    inv Hadd;
      [ | match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end ].
    match goal with Hc : eval_expr _ _ _ _ (Econst_int k _) _ |- _ =>
      inv Hc; [ | match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end ] end.
    match goal with Ha : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => rename Ha into Hfe end.
    apply eval_expr_Efield_load in Hfe as (lf & of & bff & Hfl & Hd).
    pose proof (SaveFileBody.deref_agg_val (Tarray ety n att) _ _ _ _ _ eq_refl Hd) as Ev1. subst.
    pose proof Hfl as Hfl0.
    apply eval_lvalue_Efield_base in Hfl0 as (o0 & Hb0).
    apply eval_expr_Ederef_load in Hb0 as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (HP _ _ Hlvb) as [-> ->].
    destruct (mfield_lvalue_geom_lp lp (linked12_LO_mario lp H12)
                _ _ _ _ _ _ _ _ _ _ _ _ Hlvb Hfo Hfl) as (-> & -> & ->).
    match goal with
      | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
          cbn in Hsem; injection Hsem as <- <-
    end.
    split; [ reflexivity | split; [ | reflexivity ] ].
    rewrite (sizeof_esz _ ety Hpos).
    set (E := esz ety) in *.
    rewrite Ptrofs.add_zero_l.
    unfold Ptrofs.of_ints, Ptrofs.mul.
    rewrite (Ptrofs.unsigned_repr E) by nia.
    rewrite (Ptrofs.unsigned_repr (Int.signed k)) by nia.
    unfold Ptrofs.add.
    rewrite (Ptrofs.unsigned_repr d) by nia.
    rewrite (Ptrofs.unsigned_repr (E * Int.signed k)) by nia.
    apply Ptrofs.unsigned_repr. nia.
  Qed.

  Section Walk.
    Variable m0 : mem.
    Hypothesis Hm0 : ow_facts bm MWF m0.

    Definition FPn (b : block) (ofs : Z) : Prop :=
      SafeB b \/ (b = bm /\ in_mcells npc_cells ofs).
    Definition NF (m : mem) : Prop := Mem.unchanged_on (fun b ofs => ~ FPn b ofs) m0 m.

    Definition NP (mts ots : list ident) (le : temp_env) : Prop :=
      (forall t b o, mem_id t mts = true -> le ! t = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero)
      /\ (forall t b o, mem_id t ots = true -> le ! t = Some (Vptr b o) -> SafeB b).

    Definition marg (vs : list val) : Prop :=
      match vs with
      | v0 :: _ => forall bb oo, v0 = Vptr bb oo -> bb = bm /\ oo = Ptrofs.zero
      | [] => True
      end.

    Definition Fsym (fid : ident) : Prop :=
      forall b fd, Genv.find_symbol ge fid = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres ->
        marg vargs -> NF m -> NF m'.

    Let HnB0 := UpdateCameraBody.uc_HnB lp bm bc oc0 SafeB m0 Hm0.
    Let Hns_bm : ~ SafeB bm :=
      fun H => uk_not_bm lp bm bc oc0 SafeB HSafeB_syms Hspawn bm H eq_refl.

    Lemma nf_load : forall m ch b ofs, NF m -> Plt b (Mem.nextblock m0) -> ~ SafeB b ->
        (b = bm -> forall i, ofs <= i < ofs + size_chunk ch -> ~ in_mcells npc_cells i) ->
        Mem.load ch m b ofs = Mem.load ch m0 b ofs.
    Proof.
      intros m ch b ofs HN Hp Hs Hc.
      apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ HN Hp).
      intros i Hi [H | (E & H)]; [ exact (Hs H) | exact (Hc E i Hi H) ].
    Qed.

    Lemma nf_set : forall mts ots id a le m v,
        nset mts ots id a = true -> NP mts ots le -> NF m ->
        eval_expr ge empty_env le m a v -> NP mts ots (PTree.set id v le).
    Proof.
      intros mts ots id a le m v Hok (Hp1 & Hp2) HN Hev.
      pose proof Hm0 as (Hv0 & _ & HM0).
      pose proof HnB0 as (_ & _ & Hgl).
      unfold nset in Hok. destruct (mem_id id mts) eqn:Em.
      - (* a Mario temp: the gMarioState load *)
        apply andb_prop in Hok as [Hno Hg]. apply negb_true_iff in Hno.
        destruct a as [ | | | | x [ | | | | pt pa | | | | ] | | | | | | | | | ]; try discriminate Hg.
        unfold gms_shape in Hg. apply Pos.eqb_eq in Hg. subst x.
        destruct (gload _ _ _ _ _ _ Hev) as (gb & Hs & Hld).
        assert (Hgb : gb <> bm)
          by (eapply Genv.global_addresses_distinct; [ exact gms_ne | exact Hs | exact (x_gms_bm lp bm bc oc0 Hspawn) ]).
        assert (Hns : ~ SafeB gb) by exact (safeb_of_nonfam_sym lp SafeB HSafeB_syms _ _ Hs eq_refl).
        assert (Hld0 : Mem.loadv Mptr m0 (Vptr gb Ptrofs.zero) = Some v).
        { unfold Mem.loadv in *.
          rewrite <- (nf_load m Mptr gb _ HN (Hgl _ _ Hs) Hns (fun E => False_rect _ (Hgb E))).
          exact Hld. }
        split.
        + intros t b o Ht Hg'. rewrite PTree.gsspec in Hg'.
          destruct (peq t id) as [-> | Hne].
          * injection Hg' as ->. exact (mwf_real_pgms lp bm bc oc0 SafeB m0 gb b o HM0 Hs Hld0).
          * exact (Hp1 t b o Ht Hg').
        + intros t b o Ht Hg'. rewrite PTree.gsspec in Hg'.
          destruct (peq t id) as [-> | Hne];
            [ rewrite Ht in Hno; discriminate Hno | exact (Hp2 t b o Ht Hg') ].
      - destruct (mem_id id ots) eqn:Eo.
        + (* a marioObj temp: m->marioObj *)
          destruct a as [ | | | | | | | | | | | a0 fld fty | | ]; try discriminate Hok.
          destruct a0 as [ | | | | | | a1 sty | | | | | | | ]; try discriminate Hok.
          destruct a1 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hok.
          destruct fty as [ | | | | fpt fpa | | | | ]; try discriminate Hok.
          unfold mobj_shape in Hok.
          apply andb_prop in Hok as [Hok Hf]. apply andb_prop in Hok as [Hok Hsty].
          apply andb_prop in Hok as [Hmp Hpty].
          apply proj_sumbool_true in Hpty. apply proj_sumbool_true in Hsty. subst pty sty.
          apply Pos.eqb_eq in Hf. subst fld.
          apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hd).
          pose proof Hlv as Hlv0.
          apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hb0).
          apply eval_expr_Ederef_load in Hb0 as (lb & ob & bfb & Hlvb & _).
          apply eval_lvalue_Ederef_base in Hlvb.
          apply eval_expr_Etempvar_val in Hlvb.
          destruct (Hp1 _ _ _ Hmp Hlvb) as [-> ->].
          destruct (mfield_lvalue_geom_lp lp (linked12_LO_mario lp H12)
                      _ _ _ _ _ _ _ _ _ _ _ _ Hlvb marioObj_off Hlv) as (-> & -> & ->).
          inv Hd; try (match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; discriminate Hm end).
          match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; injection Hm as <- end.
          match goal with Hl : Mem.loadv _ _ _ = Some v |- _ => rename Hl into Hld end.
          assert (Hld0 : Mem.loadv Mptr m0 (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))) = Some v).
          { unfold Mem.loadv in *. rewrite mobj_ofs in *.
            rewrite <- (nf_load m Mptr bm _ HN Hv0 Hns_bm).
            - exact Hld.
            - intros _ i Hi. apply marioObj_out. rewrite size_mptr in Hi. exact Hi. }
          split.
          * intros t b o Ht Hg'. rewrite PTree.gsspec in Hg'.
            destruct (peq t id) as [-> | Hne];
              [ rewrite Ht in Em; discriminate Em | exact (Hp1 t b o Ht Hg') ].
          * intros t b o Ht Hg'. rewrite PTree.gsspec in Hg'.
            destruct (peq t id) as [-> | Hne]; [ | exact (Hp2 t b o Ht Hg') ].
            injection Hg' as ->.
            exact (mwf_real_chase_root lp bm bc oc0 SafeB _ 136 m0 b o
                     marioObj_root marioObj_off HM0 Hld0).
        + (* any other temp *)
          split.
          * intros t b o Ht Hg'. rewrite PTree.gsspec in Hg'.
            destruct (peq t id) as [-> | Hne];
              [ rewrite Ht in Em; discriminate Em | exact (Hp1 t b o Ht Hg') ].
          * intros t b o Ht Hg'. rewrite PTree.gsspec in Hg'.
            destruct (peq t id) as [-> | Hne];
              [ rewrite Ht in Eo; discriminate Eo | exact (Hp2 t b o Ht Hg') ].
    Qed.

    Lemma nf_store : forall mts ots l r le m t le' m' out,
        nstore mts ots l r = true -> NP mts ots le ->
        exec_stmt function_entry2 ge empty_env le m (Sassign l r) t le' m' out ->
        NF m -> NF m'.
    Proof.
      intros mts ots l r le m t le' m' out Hok (Hp1 & Hp2) Hx HN.
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ l _ _ _ |- _ => rename Hl into Hlv end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
      apply (Mem.unchanged_on_trans _ _ _ _ HN).
      unfold nstore in Hok.
      apply orb_true_iff in Hok as [Hok | Ha2]; [ apply orb_true_iff in Hok as [Ha0 | Ha1] | ].
      - (* into the block of a marioObj temp *)
        unfold nst0 in Ha0. destruct (troot_l l) as [t0|] eqn:Hr; [ | discriminate Ha0 ].
        destruct (troot_l_blk _ _ _ _ _ _ _ _ _ Hr Hlv) as (o' & Hle).
        pose proof (Hp2 _ _ _ Ha0 Hle) as Hs.
        apply (assign_loc_unch _ _ _ _ _ _ _ _ _ Hal).
        intros i Hn. apply Hn. left. exact Hs.
      - (* m->fld *)
        destruct l as [ | | | | | | | | | | | a0 fld fty | | ]; try discriminate Ha1.
        destruct a0 as [ | | | | | | a1 sty | | | | | | | ]; try discriminate Ha1.
        destruct a1 as [ | | | | | p pty | | | | | | | | ]; try discriminate Ha1.
        unfold nst1 in Ha1.
        apply andb_prop in Ha1 as [Ha1 Hfc]. apply andb_prop in Ha1 as [Ha1 Hsty].
        apply andb_prop in Ha1 as [Hmp Hpty].
        apply proj_sumbool_true in Hpty. apply proj_sumbool_true in Hsty. subst pty sty.
        unfold fcell in Hfc.
        destruct (field_offset (prog_comp_env mario.prog) fld mario_state_members)
          as [[d [|]]|] eqn:Hfo; try discriminate Hfc.
        destruct (access_mode fty) as [ch | | | ] eqn:Hac; try discriminate Hfc.
        apply andb_prop in Hfc as [Hfc Hcov]. apply andb_prop in Hfc as [Hd0 Hd1].
        apply Z.leb_le in Hd0. apply Z.leb_le in Hd1.
        pose proof Hlv as Hlv0.
        apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hb0).
        apply eval_expr_Ederef_load in Hb0 as (lb & ob & bfb & Hlvb & _).
        apply eval_lvalue_Ederef_base in Hlvb.
        apply eval_expr_Etempvar_val in Hlvb.
        destruct (Hp1 _ _ _ Hmp Hlvb) as [-> ->].
        destruct (mfield_lvalue_geom_lp lp (linked12_LO_mario lp H12)
                    _ _ _ _ _ _ _ _ _ _ _ _ Hlvb Hfo Hlv) as (-> & -> & ->).
        inv Hal; try (match goal with Hm : access_mode _ = By_copy |- _ =>
                        cbn [typeof] in Hm; rewrite Hac in Hm; discriminate Hm end).
        match goal with Hm : access_mode (typeof _) = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
          cbn [typeof] in Hm; rewrite Hac in Hm; injection Hm as <-; rename Hs into Hst end.
        cbn [Mem.storev] in Hst.
        rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in Hst
          by (pose proof (size_chunk_pos ch); lia).
        eapply Mem.store_unchanged_on; [ exact Hst | ].
        intros i Hi Hn. apply Hn. right. split; [ reflexivity | exact (cell_cover_sound _ _ _ Hcov i Hi) ].
      - (* m->fld[k] *)
        destruct (nst2_inv _ _ Ha2) as (p & fld & ety & n & att & k & pt & -> & Hmp & Hac0).
        unfold acell in Hac0.
        destruct (field_offset (prog_comp_env mario.prog) fld mario_state_members)
          as [[d [|]]|] eqn:Hfo; try discriminate Hac0.
        destruct (access_mode ety) as [ch | | | ] eqn:Hac; try discriminate Hac0.
        apply andb_prop in Hac0 as [Hac0 Hcov]. apply andb_prop in Hac0 as [Hac0 Hbd].
        apply andb_prop in Hac0 as [Hac0 Hk0]. apply andb_prop in Hac0 as [Hac0 Hd0].
        apply andb_prop in Hac0 as [Hpos Hsz].
        apply Z.ltb_lt in Hpos. apply Z.eqb_eq in Hsz. apply Z.leb_le in Hbd.
        apply Z.leb_le in Hk0. apply Z.leb_le in Hd0.
        destruct (arr_geom _ _ _ _ _ _ _ _ _ _ _ _ _ _ (fun b o H => Hp1 p b o Hmp H) Hfo Hpos Hd0 Hk0 Hbd Hlv)
          as (-> & Hofs & ->).
        inv Hal; try (match goal with Hm : access_mode _ = By_copy |- _ =>
                        cbn [typeof] in Hm; rewrite Hac in Hm; discriminate Hm end).
        match goal with Hm : access_mode (typeof _) = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
          cbn [typeof] in Hm; rewrite Hac in Hm; injection Hm as <-; rename Hs into Hst end.
        cbn [Mem.storev] in Hst. rewrite Hofs in Hst.
        eapply Mem.store_unchanged_on; [ exact Hst | ].
        intros i Hi Hn. apply Hn. right. split; [ reflexivity | ].
        rewrite Hsz in Hi. exact (cell_cover_sound _ _ _ Hcov i Hi).
    Qed.

    Lemma nf_call : forall mts ots fl, (forall fid, mem_id fid fl = true -> Fsym fid) ->
        forall optid a al le m t le' m' out,
        ncall mts ots fl optid a al = true -> NP mts ots le ->
        exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
        NF m -> NF m' /\ NP mts ots le'.
    Proof.
      intros mts ots fl HF optid a al le m t le' m' out Hok Hp Hx HN.
      unfold ncall in Hok. apply andb_prop in Hok as [Hopt Hok].
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
      inv Hx.
      match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
        destruct (MathGeomGated.evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _))
          as (lf & Hsy & ->) end.
      match goal with H : Genv.find_funct _ _ = Some _ |- _ => rename H into Hff end.
      match goal with H : eval_funcall _ _ _ _ _ _ _ _ |- _ => rename H into Hfc end.
      match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => rename H into Hargs end.
      split.
      - apply orb_true_iff in Hok as [Hpure | Hfl].
        + rewrite (pure_all fid Hpure lf _ Hsy Hff _ _ _ _ _ Hfc). exact HN.
        + apply andb_prop in Hfl as [Hin Harg].
          destruct al as [ | a1 al ]; [ discriminate Harg | ].
          destruct a1 as [ | | | | | p pty | | | | | | | | ]; try discriminate Harg.
          apply (HF fid Hin lf _ Hsy Hff _ _ _ _ _ Hfc); [ | exact HN ].
          inv Hargs.
          match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in He; rename He into Hlep end.
          cbn [marg]. intros bb oo E. subst.
          match goal with Hc : sem_cast _ _ _ _ = Some (Vptr _ _) |- _ =>
            apply sem_cast_ptr_result_inv in Hc; subst end.
          exact (proj1 Hp _ _ _ Harg Hlep).
      - destruct optid as [ti|]; cbn [set_opttemp]; [ | exact Hp ].
        apply andb_prop in Hopt as [Ho1 Ho2].
        apply negb_true_iff in Ho1. apply negb_true_iff in Ho2.
        destruct Hp as (Hp1 & Hp2). split.
        + intros t0 b o Ht Hg. rewrite PTree.gsspec in Hg.
          destruct (peq t0 ti) as [-> | Hne];
            [ rewrite Ht in Ho1; discriminate Ho1 | exact (Hp1 t0 b o Ht Hg) ].
        + intros t0 b o Ht Hg. rewrite PTree.gsspec in Hg.
          destruct (peq t0 ti) as [-> | Hne];
            [ rewrite Ht in Ho2; discriminate Ho2 | exact (Hp2 t0 b o Ht Hg) ].
    Qed.

    (* THE BODY: any no-locals function passing fchk keeps the frame *)
    Lemma nf_body : forall mts fl f, (forall fid, mem_id fid fl = true -> Fsym fid) ->
        fchk mts fl f = true ->
        forall m vargs t m' vres,
        eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
        (forall x rest, map fst (fn_params f) = x :: rest -> mem_id x mts = true -> marg vargs) ->
        NF m -> NF m'.
    Proof.
      intros mts fl f HF Hchk m vargs t m' vres Hevf Hma HN.
      unfold fchk in Hchk. set (ots := mobj_temps mts (fn_body f)) in Hchk.
      apply andb_prop in Hchk as [Hchk Hvars]. apply andb_prop in Hchk as [Hchk Hpar].
      assert (Hv : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hvars ]).
      inv Hevf.
      match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
      match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hv in Ha; inv Ha end.
      match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
        rename Hb into Hbind; rename L into le0 end.
      match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
      match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
      replace (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree by reflexivity.
      cbn [Mem.free_list] in Hfree. injection Hfree as <-.
      assert (Hp0 : NP mts ots le0).
      { split.
        - intros t0 b o Hm Hg.
          destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbind Hg) as [Hu | (i & Hi & Hvi)].
          + apply MtxfBody.create_undef_temps_get in Hu. discriminate Hu.
          + revert Hpar Hi Hma. destruct (map fst (fn_params f)) as [ | x rest ] eqn:En;
              intros Hpar Hi Hma; [ destruct i; discriminate Hi | ].
            destruct i as [ | i ].
            * cbn in Hi. injection Hi as <-.
              specialize (Hma _ _ eq_refl Hm).
              destruct vargs as [ | v0 vs ]; [ discriminate Hvi | ].
              cbn in Hvi. injection Hvi as ->. exact (Hma _ _ eq_refl).
            * exfalso. cbn in Hi. apply nth_error_In in Hi.
              unfold pchk in Hpar. apply andb_prop in Hpar as [_ Hr].
              pose proof (proj1 (forallb_forall _ _) Hr t0 Hi) as Hn. cbv beta in Hn.
              rewrite Hm in Hn. discriminate Hn.
        - intros t0 b o Hm Hg.
          destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbind Hg) as [Hu | (i & Hi & Hvi)].
          + apply MtxfBody.create_undef_temps_get in Hu. discriminate Hu.
          + exfalso. revert Hpar Hi. destruct (map fst (fn_params f)) as [ | x rest ] eqn:En;
              intros Hpar Hi; [ destruct i; discriminate Hi | ].
            unfold pchk in Hpar. apply andb_prop in Hpar as [Hx Hr].
            destruct i as [ | i ].
            * cbn in Hi. injection Hi as <-. rewrite Hm in Hx. discriminate Hx.
            * cbn in Hi. apply nth_error_In in Hi.
              pose proof (proj1 (forallb_forall _ _) Hr t0 Hi) as Hn. cbv beta in Hn.
              rewrite Hm, andb_false_r in Hn. discriminate Hn. }
      exact (proj1 (SpawnBodies.sw_walk ge empty_env NF (NP mts ots) (fun _ => True)
                      (nset mts ots) (nstore mts ots) (ncall mts ots fl) (fun _ => true)
                      (nf_set mts ots) (nf_store mts ots) (nf_call mts ots fl HF)
                      (fun _ _ _ _ _ _ _ _ => I)
                      _ _ _ _ _ _ _ _ Hbody eq_refl Hchk Hp0 HN)).
    Qed.

    Lemma fsym_of : forall q fid f fl, linkorder q lp ->
        (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
        (forall g, mem_id g fl = true -> Fsym g) -> fchk mts_m fl f = true -> Fsym fid.
    Proof.
      intros q fid f fl LO Hdm HF Hchk b fd Hs Hf m vargs t m' vres Hev Hmarg HN.
      destruct (linkorder_resolves_funct lp q fid f LO Hdm) as (b' & Hs' & Hf').
      unfold ge, lp_ge in Hs, Hf. rewrite Hs in Hs'. injection Hs' as <-.
      rewrite Hf' in Hf. injection Hf as <-.
      apply (nf_body mts_m fl f HF Hchk m vargs t m' vres Hev); [ | exact HN ].
      intros _ _ _ _. exact Hmarg.
    Qed.

    Lemma fl_nil : forall g, mem_id g [] = true -> Fsym g.
    Proof. intros g H. discriminate H. Qed.

    Lemma fl_cons : forall x fl, Fsym x -> (forall g, mem_id g fl = true -> Fsym g) ->
        forall g, mem_id g (x :: fl) = true -> Fsym g.
    Proof.
      intros x fl Hx Hf g H. unfold mem_id in H. cbn [existsb] in H.
      apply orb_true_iff in H as [H | H]; [ apply Pos.eqb_eq in H; subst g; exact Hx | exact (Hf g H) ].
    Qed.

    (* the tree, bottom-up *)
    Lemma fs_yvel : Fsym mario._set_mario_y_vel_based_on_fspeed.
    Proof. exact (fsym_of _ _ _ [] (linked12_LO_mario lp H12) dm_yvel fl_nil chk_yvel). Qed.
    Lemma fs_fwd : Fsym mario._mario_set_forward_vel.
    Proof. exact (fsym_of _ _ _ [] (linked12_LO_mario lp H12) dm_fwd fl_nil chk_fwd). Qed.
    Lemma fs_sub : Fsym mario._set_mario_action_submerged.
    Proof. exact (fsym_of _ _ _ [] (linked12_LO_mario lp H12) dm_sub fl_nil chk_sub). Qed.
    Lemma fs_mov : Fsym mario._set_mario_action_moving.
    Proof. exact (fsym_of _ _ _ [] (linked12_LO_mario lp H12) dm_mov fl_nil chk_mov). Qed.
    Lemma fs_cut : Fsym mario._set_mario_action_cutscene.
    Proof.
      exact (fsym_of _ _ _ _ (linked12_LO_mario lp H12) dm_cut
               (fl_cons _ _ fs_fwd fl_nil) chk_cut).
    Qed.
    Lemma fs_air : Fsym mario._set_mario_action_airborne.
    Proof.
      exact (fsym_of _ _ _ _ (linked12_LO_mario lp H12) dm_air
               (fl_cons _ _ fs_yvel (fl_cons _ _ fs_fwd fl_nil)) chk_air).
    Qed.
    Lemma fs_sma : Fsym mario._set_mario_action.
    Proof.
      exact (fsym_of _ _ _ _ (linked12_LO_mario lp H12) dm_sma
               (fl_cons _ _ fs_mov (fl_cons _ _ fs_air (fl_cons _ _ fs_sub
                 (fl_cons _ _ fs_cut fl_nil)))) chk_sma).
    Qed.

    Lemma npc_nf : forall b fd,
        Genv.find_symbol ge C._set_mario_npc_dialog = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        forall vargs t m' vres, eval_funcall function_entry2 ge m0 fd vargs t m' vres -> NF m'.
    Proof.
      intros b fd Hs Hf vargs t m' vres Hev.
      destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_cut lp H12) NpcDialogBody.npc_dm)
        as (b' & Hs' & Hf').
      unfold ge, lp_ge in Hs, Hf. rewrite Hs in Hs'. injection Hs' as <-.
      rewrite Hf' in Hf. injection Hf as <-.
      apply (nf_body NpcDialogBody.npc_mt [mario._set_mario_action] _ (fl_cons _ _ fs_sma fl_nil)
               chk_npc m0 vargs t m' vres Hev); [ | exact (Mem.unchanged_on_refl _ m0) ].
      intros x rest E Hx. exfalso.
      change (map fst (fn_params C.f_set_mario_npc_dialog)) with [C._actionArg] in E.
      injection E as <- _. vm_compute in Hx. discriminate Hx.
    Qed.
  End Walk.

  (* ObjFrame's Hnpc_fr: the frame of the real set_mario_npc_dialog *)
  Theorem npc_dialog_frame : forall MC, (forall ofs, in_mcells npc_cells ofs -> MC ofs) ->
      forall b fd, Genv.find_symbol (lp_ge lp) mario_actions_cutscene._set_mario_npc_dialog = Some b ->
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd ->
      forall m vargs t m' vres, eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
      ow_facts bm (MWF_real lp bm bc oc0 SafeB) m -> FR lp bm SafeB (Mem.nextblock m) MC m m'.
  Proof.
    intros MC HMC b fd Hs Hf m vargs t m' vres Hev Hof.
    pose proof (npc_nf m Hof b fd Hs Hf vargs t m' vres Hev) as HN.
    unfold FR. eapply Mem.unchanged_on_implies; [ exact HN | ].
    intros b0 ofs Hn _ Hfp. apply Hn. unfold FP.
    destruct Hfp as [Hs0 | (-> & Hc)];
      [ left; exact Hs0 | right; right; right; split; [ reflexivity | exact (HMC ofs Hc) ] ].
  Qed.
End NpcF.
