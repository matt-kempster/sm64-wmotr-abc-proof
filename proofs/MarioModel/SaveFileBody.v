(* ====================================================================== *)
(* THE save_file_set_cap_pos ROW, PROVED FROM ITS REAL BODY                *)
(* (SPINE: premise sweep, 2026-10-21).                                     *)
(*                                                                        *)
(* save_file_set_cap_pos(x, y, z) (save_file.c:536) is interaction.c's     *)
(* cap-drop call.  It was a GOAL 1 capstone row (Hcp_savefile_real :      *)
(* call_pres_ext, any arguments).  save_file.c and buffers.c are linked   *)
(* (TUs 20 and 21), so the row is a lemma here, walked over the generated *)
(* body (save_file.f_save_file_set_cap_pos):                              *)
(*  - saveFile = &gSaveBuffer.files[gCurrSaveFileNum - 1][0] is a pointer *)
(*    into gSaveBuffer's block, whatever gCurrSaveFileNum holds: the       *)
(*    address chain is Oadd / aggregate Ederef / Efield from the global   *)
(*    (groot_e), never a load;                                            *)
(*  - its two stores (capLevel, capArea) go through the never-reassigned  *)
(*    saveFile, so they land in gSaveBuffer's block;                       *)
(*  - vec3s_set(saveFile->capPos, ..) is the real math_util body: it      *)
(*    saves dest in a stack shadow and stores through the reloaded        *)
(*    pointer (MtxfBody.sw_body_frame_T at pointee type tshort);          *)
(*  - save_file_set_flags(SAVE_FLAG_CAP_ON_GROUND) is the real save_file  *)
(*    body: it stores gSaveBuffer.files[..][0].flags and                   *)
(*    gSaveFileModified = TRUE, both global-rooted chains.                 *)
(* gSaveBuffer and gSaveFileModified are CensusV2.stored_globals, so the  *)
(* proved SpawnInit.glob_blk keeps their blocks off bm / bc / SafeB and   *)
(* MWFReal.mwf_real_glob says MWF survives any store into them.           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario math_util interaction save_file.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface
  FloorsSurface MathBodies BullyBodies LinkedTwelve MtxfBody.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. Global-rooted address chains.                                         *)
(* ---------------------------------------------------------------------- *)

(* CensusV2.chain_root_e with a GLOBAL root: an expression that evaluates
   to an address inside the block of the global it starts from.  Every step
   is address arithmetic (pointer + int, aggregate Ederef / Efield). *)
Fixpoint groot_e (a : expr) : option ident :=
  match a with
  | Evar g ty => if by_addr ty then Some g else None
  | Ebinop Oadd a1 a2 _ =>
      match classify_add (typeof a1) (typeof a2) with
      | add_case_pi _ _ => groot_e a1
      | _ => None
      end
  | Efield a' _ ty => if by_addr ty then groot_e a' else None
  | Ederef a' ty => if by_addr ty then groot_e a' else None
  | _ => None
  end.

Definition groot_l (a : expr) : option ident :=
  match a with
  | Evar g _ => Some g
  | Ederef a' _ => groot_e a'
  | Efield a' _ _ => groot_e a'
  | _ => None
  end.

(* an aggregate dereference hands back the address *)
Lemma deref_agg_val : forall ty m b ofs bf v,
    by_addr ty = true -> deref_loc ty m b ofs bf v -> v = Vptr b ofs.
Proof.
  intros ty m b ofs bf v Hba Hd. unfold by_addr in Hba.
  inv Hd; try reflexivity;
    try (match goal with Hm : access_mode _ = By_value _ |- _ =>
           rewrite Hm in Hba; discriminate Hba end).
  match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
  cbn in Hba.
  destruct sz, sg; cbn in Hba; try discriminate Hba;
    destruct (zlt _ _); discriminate Hba.
Qed.

Lemma evar_global_blk : forall (ge : genv) le m g ty loc ofs bf,
    eval_lvalue ge empty_env le m (Evar g ty) loc ofs bf ->
    Genv.find_symbol ge g = Some loc.
Proof.
  intros ge le m g ty loc ofs bf H. inv H.
  - match goal with Hn : empty_env ! _ = Some _ |- _ =>
      rewrite PTree.gempty in Hn; discriminate Hn end.
  - assumption.
Qed.

(* THE GLOBAL CHAIN BRICK: a global-rooted chain evaluates (in a function
   with no locals) to a pointer into its root global's block *)
Lemma groot_e_val : forall (ge : genv) le m a g v,
    groot_e a = Some g -> eval_expr ge empty_env le m a v ->
    exists b o, v = Vptr b o /\ Genv.find_symbol ge g = Some b.
Proof.
  intros ge le m a. induction a; intros gr v Hg Hev; try discriminate Hg;
    cbn [groot_e] in Hg.
  - (* Evar *)
    destruct (by_addr t) eqn:Hba; [ | discriminate Hg ]. injection Hg as <-.
    inv Hev.
    match goal with Hl : eval_lvalue _ _ _ _ _ ?loc ?ofs _,
                    Hd : deref_loc _ _ _ _ _ _ |- _ =>
      cbn [typeof] in Hd;
      rewrite (deref_agg_val _ _ _ _ _ _ Hba Hd);
      exists loc, ofs; split; [ reflexivity | exact (evar_global_blk _ _ _ _ _ _ _ _ Hl) ] end.
  - (* Ederef *)
    destruct (by_addr t) eqn:Hba; [ | discriminate Hg ].
    apply eval_expr_Ederef_load in Hev as (loc & ofs & bf & Hlv & Hd).
    rewrite (deref_agg_val _ _ _ _ _ _ Hba Hd).
    apply eval_lvalue_Ederef_base in Hlv.
    destruct (IHa _ _ Hg Hlv) as (b & o & E & Hs). injection E as -> ->.
    exists b, o. split; [ reflexivity | exact Hs ].
  - (* Ebinop Oadd, pointer + int *)
    destruct b; try discriminate Hg.
    destruct (classify_add (typeof a1) (typeof a2)) eqn:Hca; try discriminate Hg.
    inv Hev.
    2:{ match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end. }
    match goal with
    | Hsem : sem_binary_operation _ Oadd ?v1 _ ?v2 _ _ = Some _,
      Hev1 : eval_expr _ _ _ _ a1 ?v1 |- _ =>
        destruct (IHa1 _ _ Hg Hev1) as (b & o & -> & Hs);
        unfold sem_binary_operation, sem_add in Hsem; rewrite Hca in Hsem;
        unfold sem_add_ptr_int in Hsem;
        destruct v2; try discriminate Hsem; injection Hsem as <-
    end.
    eexists _, _. split; [ reflexivity | exact Hs ].
  - (* Efield *)
    destruct (by_addr t) eqn:Hba; [ | discriminate Hg ].
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hd).
    rewrite (deref_agg_val _ _ _ _ _ _ Hba Hd).
    apply eval_lvalue_Efield_base in Hlv as (o0 & Hbase).
    destruct (IHa _ _ Hg Hbase) as (b & o & E & Hs). injection E as -> ->.
    exists b, ofs. split; [ reflexivity | exact Hs ].
Qed.

Lemma groot_l_blk : forall (ge : genv) le m a g loc ofs bf,
    groot_l a = Some g -> eval_lvalue ge empty_env le m a loc ofs bf ->
    Genv.find_symbol ge g = Some loc.
Proof.
  intros ge le m a g loc ofs bf Hg Hl.
  destruct a; try discriminate Hg; cbn [groot_l] in Hg.
  - injection Hg as <-. exact (evar_global_blk _ _ _ _ _ _ _ _ Hl).
  - apply eval_lvalue_Ederef_base in Hl.
    destruct (groot_e_val _ _ _ _ _ _ Hg Hl) as (b & o & E & Hs).
    injection E as -> ->. exact Hs.
  - apply eval_lvalue_Efield_base in Hl as (o0 & Hb).
    destruct (groot_e_val _ _ _ _ _ _ Hg Hb) as (b & o & E & Hs).
    injection E as -> ->. exact Hs.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. A no-locals body walked with the frozen-temps walk, any store class.  *)
(* ---------------------------------------------------------------------- *)

Lemma nl_body_frame :
  forall (ge : genv) (MWF : mem -> Prop) bm (f : Clight.function) gs store_ok,
    fn_vars f = nil ->
    owf_chk gs store_ok (fun _ _ => false) (fn_body f) = true ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      (forall le1, bind_parameter_temps (fn_params f) vargs
                     (create_undef_temps (fn_temps f)) = Some le1 ->
         forall lv rhs le m0 t0 le' m0' out,
           store_ok lv = true -> frozen gs le1 le ->
           exec_stmt function_entry2 ge empty_env le m0 (Sassign lv rhs) t0 le' m0' out ->
           ow_facts bm MWF m0 -> ow_facts bm MWF m0') ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm f gs store_ok Hvars Hchk m vargs t m' vres Hevf Hst Hf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    pose proof (Hst LE Hb) as Hst';
    assert (Hca : forall optid a al le m0 t0 le' m0' out,
      (fun (_ : expr) (_ : list expr) => false) a al = true ->
      frozen gs LE le ->
      exec_stmt function_entry2 ge empty_env le m0 (Scall optid a al) t0 le' m0' out ->
      ow_facts bm MWF m0 -> ow_facts bm MWF m0')
    by (intros ? ? ? ? ? ? ? ? ? Hno; cbv beta in Hno; discriminate Hno)
  end.
  destruct (owf_walk ge empty_env bm MWF gs _ _ _ Hst' Hca
              _ _ _ _ _ _ _ _ Hbody eq_refl Hchk (fun _ _ => eq_refl) Hf) as (Hf1 & _).
  change (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-.
  exact Hf1.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The two callees: vec3s_set and save_file_set_flags.                   *)
(* ---------------------------------------------------------------------- *)

Definition v3s_dts : list ident := [math_util._t'3; math_util._t'2; math_util._t'1].

Lemma v3s_chk : sw_chk v3s_dts no_call tshort (sw_rest math_util.f_vec3s_set) = true.
Proof. vm_compute. reflexivity. Qed.

(* vec3s_set(dest, x, y, z): dest saved in a stack shadow, three tshort
   stores through the reloaded pointer *)
Lemma v3s_frame :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF -> blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal math_util.f_vec3s_set) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) -> Mem.valid_block m b_out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hbo.
  apply (sw_body_frame_T ge MWF bm b_out oo tshort math_util.f_vec3s_set
           [(math_util._x, tshort); (math_util._y, tshort); (math_util._z, tshort)]
           (sw_rest math_util.f_vec3s_set) v3s_dts no_call Hor eq_refl eq_refl).
  - cbn [var_names map fst]. intros H. repeat (destruct H as [H|H]; [discriminate H|]). exact H.
  - vm_compute. reflexivity.
  - reflexivity.
  - exact v3s_chk.
  - intros ? ? ? ? ? ? ? ? ? ? Hno. discriminate Hno.
  - exact Hbo.
Qed.

(* save_file_set_flags: every store is a global-rooted chain into a
   stored global (gSaveBuffer.files[..][0].flags, gSaveFileModified) *)
Definition gstore_ok (lv : expr) : bool :=
  match groot_l lv with
  | Some g => mem_id g stored_globals && is_byval (typeof lv)
  | None => false
  end.

(* NON-VACUITY: the recognizer accepts the REAL generated body *)
Lemma flags_chk :
  owf_chk nil gstore_ok (fun _ _ => false) (fn_body save_file.f_save_file_set_flags) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The caller: saveFile is a pointer into gSaveBuffer.                   *)
(* ---------------------------------------------------------------------- *)

Definition cap_init : statement :=
  match fn_body save_file.f_save_file_set_cap_pos with Ssequence s _ => s | s => s end.
Definition cap_rest : statement :=
  match fn_body save_file.f_save_file_set_cap_pos with Ssequence _ r => r | s => s end.

Lemma cap_body_split :
  fn_body save_file.f_save_file_set_cap_pos = Ssequence cap_init cap_rest.
Proof. reflexivity. Qed.

Lemma cap_init_exec : forall (ge : genv) le m t le' m' out,
    exec_stmt function_entry2 ge empty_env le m cap_init t le' m' out ->
    m' = m /\ out = Out_normal /\
    exists b o, le' ! save_file._saveFile = Some (Vptr b o) /\
                Genv.find_symbol ge save_file._gSaveBuffer = Some b.
Proof.
  intros ge le m t le' m' out H.
  unfold cap_init, save_file.f_save_file_set_cap_pos in H. cbn [fn_body] in H.
  inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _,
                    H2 : exec_stmt _ _ _ _ _ (Sset _ (Ebinop _ _ _ _)) _ _ _ _ |- _ =>
      inv H1; inv H2 end.
    split; [ reflexivity | split; [ reflexivity | ] ].
    match goal with Hx : eval_expr _ _ _ _ (Ebinop Oadd ?X ?Y ?T) ?v |- _ =>
      assert (Hg : groot_e (Ebinop Oadd X Y T) = Some save_file._gSaveBuffer)
        by (vm_compute; reflexivity);
      destruct (groot_e_val _ _ _ _ _ _ Hg Hx) as (b & o & -> & Hs)
    end.
    exists b, o. split; [ apply PTree.gss | exact Hs ].
  - match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o,
                    Hn : ?o <> Out_normal |- _ =>
      inv H1; exfalso; apply Hn; reflexivity
    end.
Qed.

Definition cap_gs : list ident := [save_file._saveFile].

(* vec3s_set's first argument: saveFile->capPos (an array field through the
   frozen saveFile), cast to a pointer parameter *)
Definition v3s_arg_ok (x : expr) (ta : type) : bool :=
  match x, ta with
  | Efield (Ederef (Etempvar t (Tpointer _ _)) (Tstruct _ _)) _ (Tarray _ _ _), Tpointer _ _ =>
      Pos.eqb t save_file._saveFile
  | _, _ => false
  end.

Definition cap_call_ok (a : expr) (al : list expr) : bool :=
  match a with
  | Evar f (Tfunction targs _ _) =>
      (Pos.eqb f save_file._vec3s_set &&
       match al, targs with
       | x :: _, ta :: _ => v3s_arg_ok x ta
       | _, _ => false
       end)
      || Pos.eqb f save_file._save_file_set_flags
  | _ => false
  end.

(* NON-VACUITY: the recognizer accepts the REAL generated body *)
Lemma cap_chk : owf_chk cap_gs (frozen_store_ok cap_gs) cap_call_ok cap_rest = true.
Proof. vm_compute. reflexivity. Qed.

Lemma v3s_arg_val : forall (ge : genv) le m x ta v1 v2 b o,
    v3s_arg_ok x ta = true -> le ! save_file._saveFile = Some (Vptr b o) ->
    eval_expr ge empty_env le m x v1 -> sem_cast v1 (typeof x) ta m = Some v2 ->
    exists o', v2 = Vptr b o'.
Proof.
  intros ge le m x ta v1 v2 b o Hok Hle Hx Hc.
  destruct x as [ | | | | | | | | | | | x1 fld fty | | ]; try discriminate Hok.
  destruct x1 as [ | | | | | | x2 sty | | | | | | | ]; try discriminate Hok.
  destruct x2 as [ | | | | | t pty | | | | | | | | ]; try discriminate Hok.
  destruct pty as [ | | | | p0 pa | | | | ]; try discriminate Hok.
  destruct sty as [ | | | | | | | sid sa | ]; try discriminate Hok.
  destruct fty as [ | | | | | ety n fa | | | ]; try discriminate Hok.
  destruct ta as [ | | | | tp tpa | | | | ]; try discriminate Hok.
  cbn [v3s_arg_ok] in Hok. apply Pos.eqb_eq in Hok. subst t.
  apply eval_expr_Efield_load in Hx as (loc & ofs & bf & Hlv & Hd).
  rewrite (deref_agg_val (Tarray ety n fa) _ _ _ _ _ eq_refl Hd) in Hc.
  apply eval_lvalue_Efield_base in Hlv as (o0 & Hb).
  destruct (chain_root_e_block _ _ _ _
              (Ederef (Etempvar save_file._saveFile (Tpointer p0 pa)) (Tstruct sid sa))
              save_file._saveFile _ _ eq_refl Hb) as (o1 & Hle').
  rewrite Hle in Hle'. injection Hle' as <- _.
  cbn in Hc. injection Hc as <-. eexists. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. The row, at the concrete MWF_real.                                    *)
(* ---------------------------------------------------------------------- *)

Lemma mu_dm_v3sset :
  (prog_defmap math_util.prog) ! save_file._vec3s_set
    = Some (Gfun (Internal math_util.f_vec3s_set)).
Proof. vm_compute. reflexivity. Qed.
Lemma sf_dm_flags :
  (prog_defmap save_file.prog) ! save_file._save_file_set_flags
    = Some (Gfun (Internal save_file.f_save_file_set_flags)).
Proof. vm_compute. reflexivity. Qed.
Lemma sf_dm_cap :
  (prog_defmap save_file.prog) ! interaction._save_file_set_cap_pos
    = Some (Gfun (Internal save_file.f_save_file_set_cap_pos)).
Proof. vm_compute. reflexivity. Qed.
Lemma sf_gsb_mem : mem_id save_file._gSaveBuffer stored_globals = true.
Proof. vm_compute. reflexivity. Qed.

Lemma save_resolves : forall lp, linkorder save_file.prog lp ->
    forall id fr, (prog_defmap save_file.prog) ! id = Some (Gfun (Internal fr)) ->
    resolves_to (lp_ge lp) id fr.
Proof.
  intros lp LO id fr Hdm bf f Hs Hf.
  destruct (linkorder_resolves_funct lp _ id fr LO Hdm) as (b' & Hs' & Hf').
  unfold lp_ge in Hs, Hf.
  rewrite Hs in Hs'. injection Hs' as <-.
  rewrite Genv.find_funct_find_funct_ptr in Hf'. congruence.
Qed.

Section SaveFileRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  (* the Twelve capstone's own facts *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma sf_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.
  Lemma sf_glob : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Proof. destruct Hspawn as (init & Hs). exact (glob_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.

  (* a stored global's block: any store keeps the carried facts *)
  Lemma sf_glob_pres : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      blk_pres not_tainted bm MWF bg.
  Proof.
    intros gid bg Hg Hfs.
    destruct (mwf_real_glob lp bm bc oc0 SafeB sf_Hbc_bm sf_glob gid Hg bg Hfs) as (Hne & Hst).
    intros ch o v m1 m2 Hs Hv Hsat HM.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hs | ].
      intros i _ [Hb _]. exact (Hne Hb).
    - exact (Hst _ _ _ _ _ HM Hs).
  Qed.

  Lemma flags_frame : forall m vargs t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m
        (Internal save_file.f_save_file_set_flags) vargs t m' vres ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros m vargs t m' vres Hevf Hf.
    refine (nl_body_frame (lp_ge lp) MWF bm save_file.f_save_file_set_flags nil gstore_ok
              eq_refl flags_chk
              _ _ _ _ _ Hevf _ Hf).
    intros le1 _ lv rhs le m0 t0 le' m0' out Hok _ Hx Hf0.
    unfold gstore_ok in Hok.
    destruct (groot_l lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hgm Hbv].
    apply (assign_blk_pres bm MWF (lp_ge lp) empty_env le m0 lv rhs t0 le' m0' out);
      [ | exact Hbv | exact Hx | exact Hf0 ].
    intros loc ofs bf Hl.
    exact (sf_glob_pres g loc Hgm (groot_l_blk _ _ _ _ _ _ _ _ Hg Hl)).
  Qed.

  Lemma cap_call : forall le1 bsb o,
      le1 ! save_file._saveFile = Some (Vptr bsb o) ->
      Genv.find_symbol (lp_ge lp) save_file._gSaveBuffer = Some bsb ->
      forall optid a al le m t le' m' out,
        cap_call_ok a al = true -> frozen cap_gs le1 le ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros le1 bsb o Hle1 Hfs optid a al le m t le' m' out Hok Hfr Hx Hf.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [cap_call_ok] in Hok.
    inv Hx.
    match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hcf; injection Hcf as <- <- <- end.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
      rewrite Genv.find_funct_find_funct_ptr in Hff end.
    apply orb_true_iff in Hok as [Hv3 | Hfl].
    - (* vec3s_set(saveFile->capPos, x, y, z) *)
      apply andb_prop in Hv3 as [Hid Hal]. apply Pos.eqb_eq in Hid. subst fid.
      destruct al as [| x0 al']; [ discriminate Hal | ].
      destruct targs as [| ta targs']; [ discriminate Hal | ].
      assert (Hsf : le ! save_file._saveFile = Some (Vptr bsb o))
        by (rewrite (Hfr save_file._saveFile ltac:(vm_compute; reflexivity)); exact Hle1).
      match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
        destruct (exprlist_nth _ _ _ _ _ _ _ Hel 0 _ _ eq_refl eq_refl)
          as (v1 & v2 & Hx1 & Hc1 & Hn0) end.
      destruct (v3s_arg_val _ _ _ _ _ _ _ _ _ Hal Hsf Hx1 Hc1) as (o' & ->).
      pose proof (nth0_hd _ _ Hn0) as Hhd.
      destruct Hf as (Hv & Hs & HM).
      assert (Hbv : Mem.valid_block m bsb)
        by exact (glob_valid_of_nextbound lp m (mwf_real_nextbound lp bm bc oc0 SafeB m HM)
                    _ _ Hfs).
      match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
        rewrite (math_resolves lp (linked12_LO_math lp H12) _ _ mu_dm_v3sset _ _ Hsy Hfp) in Hfc;
        exact (v3s_frame (lp_ge lp) MWF bm bsb o'
                 (sb_frame_oracles lp bm bc oc0 SafeB sf_Hbc_bm)
                 (sf_glob_pres _ _ sf_gsb_mem Hfs) _ _ _ _ _ Hfc Hhd Hbv
                 (conj Hv (conj Hs HM)))
      end.
    - (* save_file_set_flags(SAVE_FLAG_CAP_ON_GROUND) *)
      apply Pos.eqb_eq in Hfl. subst fid.
      match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
        rewrite (save_resolves lp (linked12_LO_save lp H12) _ _ sf_dm_flags _ _ Hsy Hfp) in Hfc;
        exact (flags_frame _ _ _ _ _ Hfc Hf)
      end.
  Qed.

  Lemma cap_body_frame : forall m vargs t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m
        (Internal save_file.f_save_file_set_cap_pos) vargs t m' vres ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros m vargs t m' vres Hevf Hf.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars save_file.f_save_file_set_cap_pos) with (@nil (ident * type)) in Ha;
      inv Ha end.
    rewrite cap_body_split in Hbody.
    inv Hbody.
    - match goal with H1 : exec_stmt _ _ _ _ _ cap_init _ _ _ _,
                      H2 : exec_stmt _ _ _ _ _ cap_rest _ _ _ _ |- _ =>
        destruct (cap_init_exec _ _ _ _ _ _ _ H1) as (-> & _ & bsb & o & Hle1 & Hfs);
        rename H2 into Hrest
      end.
      match goal with Hr : exec_stmt _ _ _ ?LE _ cap_rest _ _ _ _ |- _ =>
        assert (Hblk : forall t0 b0 o0, mem_id t0 cap_gs = true ->
                  LE ! t0 = Some (Vptr b0 o0) -> blk_pres not_tainted bm MWF b0)
      end.
      { intros t0 b0 o0 Ht0 Hl0.
        unfold cap_gs in Ht0. cbn [mem_id existsb] in Ht0.
        rewrite orb_false_r in Ht0. apply Pos.eqb_eq in Ht0. subst t0.
        rewrite Hle1 in Hl0. injection Hl0 as <- _.
        exact (sf_glob_pres _ _ sf_gsb_mem Hfs). }
      destruct (owf_walk (lp_ge lp) empty_env bm MWF cap_gs _ (frozen_store_ok cap_gs)
                  cap_call_ok
                  (frozen_store_pres (lp_ge lp) empty_env bm MWF cap_gs _ Hblk)
                  (cap_call _ bsb o Hle1 Hfs)
                  _ _ _ _ _ _ _ _ Hrest eq_refl cap_chk (fun _ _ => eq_refl) Hf)
        as (Hf2 & _).
      change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
      cbn [Mem.free_list] in Hfree. injection Hfree as <-. exact Hf2.
    - match goal with H1 : exec_stmt _ _ _ _ _ cap_init _ _ _ ?o,
                      Hn : ?o <> Out_normal |- _ =>
        destruct (cap_init_exec _ _ _ _ _ _ _ H1) as (_ & Eo & _);
        exfalso; exact (Hn Eo)
      end.
  Qed.

  (* THE ROW: save_file_set_cap_pos preserves the carried run facts --
     proved from its real body (any arguments, any gCurrSaveFileNum). *)
  Lemma Hcp_savefile_proved :
    call_pres_ext lp bm NoA MWF interaction._save_file_set_cap_pos.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ (linked12_LO_save lp H12) sf_dm_cap Hres) as ->.
    destruct (cap_body_frame _ _ _ _ _ Hevf (conj Hv (conj Hsat HM))) as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.
End SaveFileRows.
