(* ====================================================================== *)
(* THE mtxf_align_terrain_triangle ROW, PROVED FROM ITS REAL BODY          *)
(* (SPINE: premise sweep, 2026-10-20).                                     *)
(*                                                                        *)
(* mtxf_align_terrain_triangle(mtx, pos, yaw, radius) (math_util.c) was a  *)
(* capstone row (Hscp_mtxf_real : call_pres_ext_sc, arg0 in a SafeB       *)
(* block).  math_util is linked, so the row is a lemma here, walked over   *)
(* the generated body (math_util.f_mtxf_align_terrain_triangle):          *)
(*  - its eight locals (sp74, point0..2, forward, xColumn, yColumn,       *)
(*    zColumn) are fresh stack blocks (local_blk), wholly store-safe;     *)
(*  - every other store is mtx[i][j] = <float>, through the frozen        *)
(*    parameter mtx: a NON-pointer store into the SafeB block the gate    *)
(*    gives (mwf_real_chase);                                             *)
(*  - its calls: find_floor(.., &sp74) three times (the real collision    *)
(*    body, out-param a local), and vec3f_set / find_vector_perpendicular_ *)
(*    to_plane / vec3f_normalize / vec3f_cross, each with its destination *)
(*    one of the local arrays.  The last three bodies are walked here      *)
(*    (sw_walk): each saves dest in a stack shadow, reloads it and stores  *)
(*    through the reloaded pointer.                                       *)
(*  - vec3f_normalize calls the external sqrtf BETWEEN two shadow reloads, *)
(*    so the proof needs sqrtf to leave memory unchanged: the FPU floor    *)
(*    FpuFloor.sqrtf_spec (TRUST 3.5; already a premise of HeightFrame).  *)
(*    This is the one premise beyond the Twelve capstone's own facts.      *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario math_util surface_collision mario_actions_moving.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface FloorsSurface
  MathBodies BullyBodies LinkedTwelve.
From SM64.Proofs Require Import FpuFloor.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 0. Generic bricks.                                                       *)
(* ---------------------------------------------------------------------- *)

Lemma mem_id_In : forall x l, mem_id x l = true -> In x l.
Proof.
  intros x l H. unfold mem_id in H. apply existsb_exists in H as (y & Hy & Heq).
  apply Pos.eqb_eq in Heq. subst y. exact Hy.
Qed.

Lemma mem_id_notin : forall x l, mem_id x l = false -> ~ In x l.
Proof.
  intros x l H Hin. unfold mem_id in H.
  assert (existsb (Pos.eqb x) l = true)
    by (apply existsb_exists; exists x; split; [ exact Hin | apply Pos.eqb_refl ]).
  congruence.
Qed.

Lemma create_undef_temps_get : forall l t v,
    (create_undef_temps l) ! t = Some v -> v = Vundef.
Proof.
  induction l as [| [id ty] l IH]; intros t v H; cbn in H.
  - rewrite PTree.gempty in H. discriminate H.
  - destruct (peq t id) as [-> | Hne].
    + rewrite PTree.gss in H. injection H as <-. reflexivity.
    + rewrite PTree.gso in H by exact Hne. exact (IH _ _ H).
Qed.

Lemma alloc_variables_valid_fwd : forall ge e m vars e' m',
    alloc_variables ge e m vars e' m' ->
    forall b, Mem.valid_block m b -> Mem.valid_block m' b.
Proof.
  intros ge e m vars e' m' H.
  induction H as [| e0 m0 id ty vars0 m1 b1 m2 e2 Hal Hrest IH]; intros b Hv; [ exact Hv | ].
  apply IH. eapply Mem.valid_block_alloc; eauto.
Qed.

Lemma free_list_valid_fwd : forall l m m',
    Mem.free_list m l = Some m' ->
    forall b, Mem.valid_block m b -> Mem.valid_block m' b.
Proof.
  induction l as [| [[b0 lo] hi] l IH]; intros m m' H b Hv; cbn in H.
  - injection H as <-. exact Hv.
  - destruct (Mem.free m b0 lo hi) as [m1|] eqn:F; [ | discriminate H ].
    eapply IH; [ exact H | ]. eapply Mem.valid_block_free_1; eauto.
Qed.

(* every execution keeps every valid block valid *)
Lemma exec_funcall_valid : forall (ge : genv),
  (forall e le m s t le' m' out,
     exec_stmt function_entry2 ge e le m s t le' m' out ->
     forall b, Mem.valid_block m b -> Mem.valid_block m' b) /\
  (forall m fd vargs t m' vres,
     eval_funcall function_entry2 ge m fd vargs t m' vres ->
     forall b, Mem.valid_block m b -> Mem.valid_block m' b).
Proof.
  intros ge.
  apply (exec_stmt_funcall_ind function_entry2 ge
    (fun e le m s t le' m' out => forall b, Mem.valid_block m b -> Mem.valid_block m' b)
    (fun m fd vargs t m' vres => forall b, Mem.valid_block m b -> Mem.valid_block m' b));
    intros; eauto.
  - eapply assign_loc_valid_block; eauto.
  - eapply external_call_valid_block; eauto.
  - match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    eapply free_list_valid_fwd; [ eassumption | ].
    match goal with IH : forall b, Mem.valid_block _ b -> Mem.valid_block _ b |- _ => apply IH end.
    eapply alloc_variables_valid_fwd; eassumption.
  - eapply external_call_valid_block; eauto.
Qed.

Lemma av_valid_bound : forall ge e m vars e' m',
    alloc_variables ge e m vars e' m' ->
    forall x b ty, e' ! x = Some (b, ty) -> e ! x = Some (b, ty) \/ Mem.valid_block m' b.
Proof.
  intros ge e m vars e' m' Hav.
  induction Hav as [e0 m0 | e0 m0 id ty0 vars0 m1 b1 m2 e2 Hal Hrest IH];
    intros x b ty Hx; [ left; exact Hx | ].
  destruct (IH x b ty Hx) as [Hs | Hv]; [ | right; exact Hv ].
  destruct (peq x id) as [-> | Hne].
  - rewrite PTree.gss in Hs. injection Hs as Eb _. subst b. right.
    eapply alloc_variables_valid_fwd; [ exact Hrest | eapply Mem.valid_new_block; exact Hal ].
  - rewrite PTree.gso in Hs by exact Hne. left. exact Hs.
Qed.

Lemma av_facts : forall bm (MWF : mem -> Prop) ge e m vars e' m',
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    alloc_variables ge e m vars e' m' -> ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros bm MWF ge e m vars e' m' Halloc Hav.
  induction Hav as [e0 m0 | e0 m0 id ty vars0 m1 b1 m2 e2 Hal Hrest IH];
    intros Hf; [ exact Hf | ].
  apply IH. destruct Hf as (Hv & Hs & Hm).
  split; [ eapply Mem.valid_block_alloc; eauto | split ].
  - eapply action_sat_unchanged_on;
      [ eapply Mem.alloc_unchanged_on; exact Hal | exact Hv | exact Hs ].
  - eapply Halloc; eauto.
Qed.

Lemma assign_loc_load_other : forall ce ty m loc ofs bf v m' ch b z,
    assign_loc ce ty m loc ofs bf v m' -> b <> loc ->
    Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros ce ty m loc ofs bf v m' ch b z Ha Hne. inv Ha.
  - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs;
      eapply Mem.load_store_other; [ exact Hs | left; exact Hne ] end.
  - match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
      eapply Mem.load_storebytes_other; [ exact Hs | left; exact Hne ] end.
  - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs;
      eapply Mem.load_store_other; [ exact Hs | left; exact Hne ] end.
Qed.

Definition is_byval (ty : type) : bool :=
  match access_mode ty with By_value _ => true | _ => false end.

(* a by-value store whose every possible target block is wholly store-safe *)
Lemma assign_blk_pres : forall bm (MWF : mem -> Prop) (ge : genv) e le m lv rhs t le' m' out,
    (forall loc ofs bf, eval_lvalue ge e le m lv loc ofs bf ->
       blk_pres not_tainted bm MWF loc) ->
    is_byval (typeof lv) = true ->
    exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
    ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros bm MWF ge e le m lv rhs t le' m' out Hblk Hbv Hx (Hv & Hs & Hm).
  inv Hx.
  match goal with Hl : eval_lvalue _ _ _ _ lv _ _ _ |- _ => pose proof (Hblk _ _ _ Hl) as Hbp end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
  - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hst;
      exact (Hbp _ _ _ _ _ Hst Hv Hs Hm) end.
  - unfold is_byval in Hbv.
    match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
  - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hst;
      exact (Hbp _ _ _ _ _ Hst Hv Hs Hm) end.
Qed.

(* the non-pointer variant: target blocks take any NON-pointer store, and the
   store's type is a scalar (so the cast value is never a pointer) *)
Definition blk_pres_np (bm : block) (MWF : mem -> Prop) (b : block) : Prop :=
  forall ch z, cell_pres_np not_tainted bm MWF ch b z.

Lemma nonptr_scalar_not_copy : forall ty,
    nonptr_scalar ty = true -> access_mode ty <> By_copy.
Proof.
  intros ty H E.
  destruct ty as [ | i s a | s a | f a | | | | | ]; try discriminate H;
    [ destruct i, s | destruct f ]; cbn in H, E; try discriminate H; discriminate E.
Qed.

Lemma assign_np_pres : forall bm (MWF : mem -> Prop) (ge : genv) e le m lv rhs t le' m' out,
    (forall loc ofs bf, eval_lvalue ge e le m lv loc ofs bf -> blk_pres_np bm MWF loc) ->
    nonptr_scalar (typeof lv) = true ->
    exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
    ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros bm MWF ge e le m lv rhs t le' m' out Hblk Hnp Hx (Hv & Hs & Hm).
  inv Hx.
  match goal with Hl : eval_lvalue _ _ _ _ lv _ _ _ |- _ => pose proof (Hblk _ _ _ Hl) as Hbp end.
  match goal with Hc : sem_cast _ _ (typeof lv) _ = Some _ |- _ =>
    pose proof (sem_cast_to_nonptr_scalar _ _ _ _ _ Hnp Hc) as Hvnp end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
  - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hst;
      exact (Hbp _ _ _ _ _ Hvnp Hst Hv Hs Hm) end.
  - match goal with Hc : access_mode _ = By_copy |- _ =>
      exact (False_ind _ (nonptr_scalar_not_copy _ Hnp Hc)) end.
  - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hst;
      refine (Hbp _ _ _ _ _ _ Hst Hv Hs Hm); intros bb oo; discriminate end.
Qed.

(* the value of a local array name, and the block of `arr[i]` *)
Lemma evar_arr_val : forall ge e le m x ety n a b ty v,
    eval_expr ge e le m (Evar x (Tarray ety n a)) v -> e ! x = Some (b, ty) ->
    v = Vptr b Ptrofs.zero.
Proof.
  intros ge e le m x ety n a b ty v H He. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; [ | congruence ].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn in *; try discriminate; congruence.
Qed.

Lemma arr_lvalue_blk : forall ge e le m x ety n a ii pty T loc ofs bf b ty,
    eval_lvalue ge e le m
      (Ederef (Ebinop Oadd (Evar x (Tarray ety n a)) (Econst_int ii tint) pty) T) loc ofs bf ->
    e ! x = Some (b, ty) -> loc = b.
Proof.
  intros ge e le m x ety n a ii pty T loc ofs bf b ty H He. inv H.
  match goal with Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp end;
    [ | match goal with Hl2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl2 end ].
  match goal with Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv Hi end;
    [ | match goal with Hl3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl3 end ].
  match goal with Ha : eval_expr _ _ _ _ (Evar _ _) ?v1 |- _ =>
    pose proof (evar_arr_val _ _ _ _ _ _ _ _ _ _ _ Ha He) as Ev; subst v1 end.
  match goal with Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
    cbn in Hsem; injection Hsem as Hbl _ end.
  congruence.
Qed.

(* ---------------------------------------------------------------------- *)
(* 1. sqrtf: an External of the link, whose call (the FPU floor) keeps     *)
(*    memory identical.                                                     *)
(* ---------------------------------------------------------------------- *)

Definition xnamed (o : option (globdef Clight.fundef type)) (n : String.string) : bool :=
  match o with
  | Some (Gfun (External (EF_external n' _) _ _ _)) => String.eqb n' n
  | _ => false
  end.

Lemma xnamed_ok : forall o n, xnamed o n = true ->
  exists sg targs tres cc, o = Some (Gfun (External (EF_external n sg) targs tres cc)).
Proof.
  intros o n H. destruct o as [[[f | ef targs tres cc] | v] |]; try discriminate.
  destruct ef; try discriminate. cbn in H. apply String.eqb_eq in H. subst. eauto.
Qed.

Definition no_internal_all12 (ids : list ident) : bool :=
  forallb (fun p => no_internal_ids p ids) (mario.prog :: tu_rest).

Lemma xresolve : forall lp q fid ids n b fd,
  linked12 lp -> linkorder q lp ->
  mem_id fid ids = true -> no_internal_all12 ids = true ->
  xnamed ((prog_defmap q) ! fid) n = true ->
  Genv.find_symbol (globalenv lp) fid = Some b ->
  Genv.find_funct (globalenv lp) (Vptr b Ptrofs.zero) = Some fd ->
  exists sg targs tres cc, fd = External (EF_external n sg) targs tres cc.
Proof.
  intros lp q fid ids n b fd Hlink LOq Hid Hall Hn Hs Hf.
  destruct (xnamed_ok _ _ Hn) as (sg & targs & tres & cc & Hdm).
  assert (Hdm' : (prog_defmap lp) ! fid = Some (Gfun fd)).
  { apply resolves_defmap. exists b. split; assumption. }
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & Hlo).
  change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
  rewrite Hdm' in Hgd'. injection Hgd' as <-.
  inv Hlo.
  match goal with H : linkorder _ _ |- _ => inv H end.
  - do 4 eexists. reflexivity.
  - exfalso. unfold no_internal_all12 in Hall. rewrite forallb_forall in Hall.
    destruct (link_chain_internal_origin _ _ _ _ _ Hlink Hdm') as [Hbase | (q' & Hq & Hqdm)].
    + exact (no_internal_ids_correct _ _ _ _ (Hall _ (or_introl eq_refl)) Hid Hbase).
    + exact (no_internal_ids_correct _ _ _ _ (Hall _ (or_intror Hq)) Hid Hqdm).
Qed.

Lemma sqrtf_named : xnamed ((prog_defmap math_util.prog) ! math_util._sqrtf) "sqrtf" = true.
Proof. vm_compute. reflexivity. Qed.
Lemma sqrtf_ni : no_internal_all12 [math_util._sqrtf] = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sqrtf_memid : forall lp, linked12 lp -> sqrtf_spec ->
    forall b fd m vargs t m' vres,
      Genv.find_symbol (lp_ge lp) math_util._sqrtf = Some b ->
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres -> m' = m.
Proof.
  intros lp H12 Hsq b fd m vargs t m' vres Hs Hf Hev.
  destruct (xresolve lp math_util.prog math_util._sqrtf [math_util._sqrtf] "sqrtf" b fd
              H12 (linked12_LO_math lp H12) ltac:(vm_compute; reflexivity) sqrtf_ni
              sqrtf_named Hs Hf) as (sg & targs & tres & cc & ->).
  inv Hev.
  match goal with He : external_call _ _ _ _ _ _ _ |- _ => exact (Hsq _ _ _ _ _ _ _ He) end.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The shadow-dest walk: the math_util writers that save dest in a      *)
(*    stack shadow (AVOID_UB), reload it into a temp, store through it.    *)
(* ---------------------------------------------------------------------- *)

Section SW.
  Variable ge : genv.
  Variable e : env.
  Variable bm : block.
  Variable MWF : mem -> Prop.
  Variables (bd b_out : block) (oo : ptrofs).
  Variable dts : list ident.     (* the temps reloaded from the shadow *)
  Variable call_ok : expr -> list expr -> bool.
  Variable T : type.             (* dest's pointee type (tfloat, tshort, ..) *)

  Hypothesis He_dest : e ! math_util._dest = Some (bd, tptr T).
  Hypothesis Hbo : blk_pres not_tainted bm MWF b_out.
  Hypothesis Hne : b_out <> bd.
  Hypothesis Hcall : forall optid a al le m t le' m' out,
      call_ok a al = true ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out -> m' = m.

  Definition sw_inv (le : temp_env) (m : mem) : Prop :=
    ow_facts bm MWF m /\ Mem.load Mptr m bd 0 = Some (Vptr b_out oo) /\
    (forall t b o, mem_id t dts = true -> le ! t = Some (Vptr b o) -> b = b_out).

  Definition sw_set_ok (id : ident) (a : expr) : bool :=
    negb (mem_id id dts) ||
    match a with
    | Evar x ty => Pos.eqb x math_util._dest && proj_sumbool (type_eq ty (tptr T))
    | _ => false
    end.

  Fixpoint sw_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn _ => true
    | Sset id a => sw_set_ok id a
    | Sassign lv _ =>
        match chain_root_l lv with
        | Some t => mem_id t dts && is_byval (typeof lv)
        | None => false
        end
    | Scall optid a al =>
        call_ok a al && match optid with Some ti => negb (mem_id ti dts) | None => true end
    | Ssequence s1 s2 => sw_chk s1 && sw_chk s2
    | _ => false
    end.

  Lemma sw_walk : forall e0 le m s t le' m' out,
      exec_stmt function_entry2 ge e0 le m s t le' m' out -> e0 = e ->
      sw_chk s = true -> sw_inv le m -> sw_inv le' m'.
  Proof.
    intros e0 le m s t le' m' out Hexec.
    induction Hexec; intros He Hchk Hi; subst; cbn [sw_chk] in Hchk; try discriminate Hchk.
    - exact Hi.
    - (* Sassign through a reloaded temp *)
      destruct (chain_root_l a1) as [tr|] eqn:Hcr; [ | discriminate Hchk ].
      apply andb_prop in Hchk as [Ht Hac].
      destruct Hi as (Hf & Hsh & Hj).
      lazymatch goal with Hl : eval_lvalue _ _ _ _ a1 ?loc _ _ |- _ =>
        destruct (CensusV2.chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hl) as (o0 & Hle);
        pose proof (Hj _ _ _ Ht Hle) as Hloc; subst loc end.
      assert (Hx : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      destruct Hf as (Hv0 & Hs0 & Hm0).
      destruct (gate_assign_pres_B MWF not_tainted bm b_out o0 tr a1 a2 ge e le m E0 le m'
                  Out_normal Hbo Hcr Hac Hle Hx Hv0 Hs0 Hm0) as (Hv1 & Hs1 & Hm1 & _).
      split; [ exact (conj Hv1 (conj Hs1 Hm1)) | split; [ | exact Hj ] ].
      lazymatch goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        rewrite (assign_loc_load_other _ _ _ _ _ _ _ _ Mptr bd 0 Ha (not_eq_sym Hne));
        exact Hsh end.
    - (* Sset *)
      unfold sw_set_ok in Hchk. destruct Hi as (Hf & Hsh & Hj).
      split; [ exact Hf | split; [ exact Hsh | ] ].
      intros t0 b o Ht0 Hle.
      destruct (peq t0 id) as [-> | Hneq].
      + rewrite Ht0 in Hchk. cbn [negb orb] in Hchk.
        destruct a as [ | | | | x ty | | | | | | | | | ]; try discriminate Hchk.
        apply andb_prop in Hchk as [Hx Hty]. apply Pos.eqb_eq in Hx. subst x.
        destruct (type_eq ty (tptr T)); [ subst ty | discriminate Hty ].
        assert (Hx : exec_stmt function_entry2 ge e le m
                       (Sset id (Evar math_util._dest (tptr T))) E0
                       (PTree.set id v le) m Out_normal)
          by (eapply exec_Sset; eassumption).
        destruct (sset_shadow_reads _ _ _ _ _ _ _ _ _ _ _ _ _ He_dest Hsh Hx)
          as (_ & _ & Hid).
        rewrite Hle in Hid. injection Hid as Hb _. exact Hb.
      + rewrite PTree.gso in Hle by exact Hneq. exact (Hj _ _ _ Ht0 Hle).
    - (* Scall: memory unchanged *)
      apply andb_prop in Hchk as [Hc Ho].
      destruct Hi as (Hf & Hsh & Hj).
      lazymatch goal with Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 ge e le m (Scall optid a al) tt
                       (set_opttemp optid vr le) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      pose proof (Hcall _ _ _ _ _ _ _ _ _ Hc Hx) as Em. subst.
      split; [ exact Hf | split; [ exact Hsh | ] ].
      intros t0 b o Ht0 Hle.
      destruct optid as [ti|]; cbn [set_opttemp] in Hle; [ | exact (Hj _ _ _ Ht0 Hle) ].
      rewrite PTree.gso in Hle; [ exact (Hj _ _ _ Ht0 Hle) | ].
      intro E; subst; rewrite Ht0 in Ho; discriminate Ho.
    - apply andb_prop in Hchk as [H1 H2].
      exact (IHHexec2 eq_refl H2 (IHHexec1 eq_refl H1 Hi)).
    - apply andb_prop in Hchk as [H1 _]. exact (IHHexec eq_refl H1 Hi).
    - exact Hi.
    - exact Hi.
    - exact Hi.
    - exact Hi.
  Qed.
End SW.

Lemma dts_ok_spec : forall (dts ps : list ident),
    forallb (fun t => negb (mem_id t ps)) dts = true ->
    forall t, mem_id t dts = true -> ~ In t ps.
Proof.
  intros dts ps H t Ht Hin. rewrite forallb_forall in H.
  pose proof (H t (mem_id_In _ _ Ht)) as Hn.
  assert (mem_id t ps = true)
    by (unfold mem_id; apply existsb_exists; exists t; split; [ exact Hin | apply Pos.eqb_refl ]).
  rewrite H0 in Hn. discriminate Hn.
Qed.

(* the body frame of a shadow-dest writer whose destination is a wholly
   store-safe block that was valid at the call.  Generic in dest's pointee
   type T (tfloat for the vec3f writers, tshort for vec3s_set). *)
Lemma sw_body_frame_T :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs)
         (T : type) (f : Clight.function) ps rest dts call_ok,
    frame_oracles bm MWF ->
    fn_vars f = (math_util._dest, tptr T) :: nil ->
    fn_params f = (math_util._dest, tptr T) :: ps ->
    ~ In math_util._dest (var_names ps) ->
    forallb (fun t => negb (mem_id t (var_names (fn_params f)))) dts = true ->
    fn_body f = Ssequence (Sassign (Evar math_util._dest (tptr T))
                                   (Etempvar math_util._dest (tptr T))) rest ->
    sw_chk dts call_ok T rest = true ->
    (forall bd optid a al le m t le' m' out, call_ok a al = true ->
       exec_stmt function_entry2 ge (PTree.set math_util._dest (bd, tptr T) empty_env)
         le m (Scall optid a al) t le' m' out -> m' = m) ->
    blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) -> Mem.valid_block m b_out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm b_out oo T f ps rest dts call_ok Hor Hvars Hpar Hni Hdts Hbody Hchk
         Hcall Hbo m vargs t m' vres Hevf Hhd Hbov (Hv & Hsat & Hmwf).
  pose proof (dts_ok_spec _ _ Hdts) as Hdts'.
  destruct Hor as (Halloc & Hfree & HallocB).
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbd end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hvars in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HbdB : blk_pres not_tainted bm MWF bb) by (eapply HallocB; eassumption);
    assert (Hbd_bo : b_out <> bb)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ]);
    rename bb into bd
  end.
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    rename Hbp into Hbpt;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (rewrite Hpar in Hbpt; exact (bind_parameter_temps_head _ _ _ _ _ _ _ Hni Hbpt))
  end.
  rewrite Hbody in Hbd.
  inv Hbd.
  2:{ match goal with Hs : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
        inv Hs; exfalso; apply Hn; reflexivity end. }
  match goal with
  | HA : exec_stmt _ _ _ ?l0 _ (Sassign (Evar _ _) _) _ ?l1 _ _,
    HR : exec_stmt _ _ _ ?l1 _ rest _ _ _ _ |- _ =>
      destruct (vec_shadow_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ HbdB (PTree.gss _ _ _)
                  Hled I HA HvA HsatA HmwfA) as (Hv1 & Hs1 & Hm1 & Hload1);
      assert (Ele : l1 = l0) by (inv HA; reflexivity);
      rename HR into HRest
  end.
  subst.
  match goal with HR : exec_stmt _ _ _ ?l1 ?mB rest _ _ _ _ |- _ =>
    assert (Hi0 : sw_inv bm MWF bd b_out oo dts l1 mB) end.
  { split; [ exact (conj Hv1 (conj Hs1 Hm1)) | split; [ exact Hload1 | ] ].
    intros t0 b o Ht0 Hle.
    rewrite (bind_parameter_temps_gso _ _ _ _ _ Hbpt (Hdts' _ Ht0)) in Hle.
    apply create_undef_temps_get in Hle. discriminate Hle. }
  destruct (sw_walk ge _ bm MWF bd b_out oo dts call_ok T (PTree.gss _ _ _) Hbo Hbd_bo
              (Hcall bd) _ _ _ _ _ _ _ _ HRest eq_refl Hchk Hi0) as ((Hv2 & Hs2 & Hm2) & _ & _).
  rewrite blocks_of_env_mu_dest in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((bd, 0, sizeof ge (tptr T)) :: nil))
    by (constructor; [ exact Hbd_bm | constructor ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv2 Hs2) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm2 ].
Qed.

(* the float instance (the vec3f writers below) *)
Definition sw_body_frame := fun ge MWF bm b_out oo => sw_body_frame_T ge MWF bm b_out oo tfloat.

(* the three walked writers *)
Definition sw_rest (f : Clight.function) : statement :=
  match fn_body f with Ssequence _ r => r | s => s end.

Definition fvptp_dts : list ident := [math_util._t'19; math_util._t'10; math_util._t'1].
Definition cross_dts : list ident := [math_util._t'11; math_util._t'6; math_util._t'1].
Definition norm_dts : list ident := [math_util._t'8; math_util._t'5; math_util._t'2].

Definition no_call (_ : expr) (_ : list expr) : bool := false.
Definition sq_call_ok (a : expr) (_ : list expr) : bool :=
  match a with
  | Evar f (Tfunction _ _ _) => Pos.eqb f math_util._sqrtf
  | _ => false
  end.

Lemma fvptp_chk :
  sw_chk fvptp_dts no_call tfloat (sw_rest math_util.f_find_vector_perpendicular_to_plane) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma cross_chk : sw_chk cross_dts no_call tfloat (sw_rest math_util.f_vec3f_cross) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma norm_chk : sw_chk norm_dts sq_call_ok tfloat (sw_rest math_util.f_vec3f_normalize) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma nth0_hd : forall (l : list val) v, nth_error l 0 = Some v -> hd_error l = Some v.
Proof. intros [| x l] v H; cbn in *; congruence. Qed.

Lemma fvptp_frame :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF -> blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_find_vector_perpendicular_to_plane) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) -> Mem.valid_block m b_out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hbo.
  apply (sw_body_frame ge MWF bm b_out oo math_util.f_find_vector_perpendicular_to_plane
           [(math_util._a, tptr tfloat); (math_util._b, tptr tfloat); (math_util._c, tptr tfloat)]
           (sw_rest math_util.f_find_vector_perpendicular_to_plane) fvptp_dts no_call
           Hor eq_refl eq_refl).
  - cbn [var_names map fst]. intros H. repeat (destruct H as [H|H]; [discriminate H|]). exact H.
  - vm_compute. reflexivity.
  - reflexivity.
  - exact fvptp_chk.
  - intros ? ? ? ? ? ? ? ? ? ? Hno. discriminate Hno.
  - exact Hbo.
Qed.

Lemma cross_frame :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF -> blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal math_util.f_vec3f_cross) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) -> Mem.valid_block m b_out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor Hbo.
  apply (sw_body_frame ge MWF bm b_out oo math_util.f_vec3f_cross
           [(math_util._a, tptr tfloat); (math_util._b, tptr tfloat)]
           (sw_rest math_util.f_vec3f_cross) cross_dts no_call Hor eq_refl eq_refl).
  - cbn [var_names map fst]. intros H. repeat (destruct H as [H|H]; [discriminate H|]). exact H.
  - vm_compute. reflexivity.
  - reflexivity.
  - exact cross_chk.
  - intros ? ? ? ? ? ? ? ? ? ? Hno. discriminate Hno.
  - exact Hbo.
Qed.

Lemma sq_call_memid : forall lp, linked12 lp -> sqrtf_spec ->
  forall bd optid a al le m t le' m' out, sq_call_ok a al = true ->
  exec_stmt function_entry2 (lp_ge lp) (PTree.set math_util._dest (bd, tptr tfloat) empty_env)
    le m (Scall optid a al) t le' m' out -> m' = m.
Proof.
  intros lp H12 Hsq bd optid a al le m t le' m' out Hok Hx.
  destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
  destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
  cbn [sq_call_ok] in Hok. apply Pos.eqb_eq in Hok. subst fid.
  assert (Hn : (PTree.set math_util._dest (bd, tptr tfloat) empty_env) ! math_util._sqrtf = None)
    by (rewrite PTree.gso by (intro E; vm_compute in E; discriminate E); apply PTree.gempty).
  inv Hx.
  match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
    destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee Hn) as (lf & Hsy & ->) end.
  match goal with Hff : Genv.find_funct _ _ = Some ?fd, Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
    exact (sqrtf_memid lp H12 Hsq _ _ _ _ _ _ _ Hsy Hff Hfc) end.
Qed.

Lemma norm_frame : forall lp, linked12 lp -> sqrtf_spec ->
  forall (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF -> blk_pres not_tainted bm MWF b_out ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m (Internal math_util.f_vec3f_normalize)
        vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) -> Mem.valid_block m b_out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros lp H12 Hsq MWF bm b_out oo Hor Hbo.
  apply (sw_body_frame (lp_ge lp) MWF bm b_out oo math_util.f_vec3f_normalize nil
           (sw_rest math_util.f_vec3f_normalize) norm_dts sq_call_ok Hor eq_refl eq_refl).
  - intros [].
  - vm_compute. reflexivity.
  - reflexivity.
  - exact norm_chk.
  - exact (sq_call_memid lp H12 Hsq).
  - exact Hbo.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The mtxf_align_terrain_triangle walk.                                *)
(* ---------------------------------------------------------------------- *)

Lemma mu_dm_mtxf :
  (prog_defmap math_util.prog) ! mario_actions_moving._mtxf_align_terrain_triangle
    = Some (Gfun (Internal math_util.f_mtxf_align_terrain_triangle)).
Proof. vm_compute. reflexivity. Qed.
Lemma mu_dm_v3fset :
  (prog_defmap math_util.prog) ! math_util._vec3f_set
    = Some (Gfun (Internal math_util.f_vec3f_set)).
Proof. vm_compute. reflexivity. Qed.
Lemma mu_dm_fvptp :
  (prog_defmap math_util.prog) ! math_util._find_vector_perpendicular_to_plane
    = Some (Gfun (Internal math_util.f_find_vector_perpendicular_to_plane)).
Proof. vm_compute. reflexivity. Qed.
Lemma mu_dm_norm :
  (prog_defmap math_util.prog) ! math_util._vec3f_normalize
    = Some (Gfun (Internal math_util.f_vec3f_normalize)).
Proof. vm_compute. reflexivity. Qed.
Lemma mu_dm_cross :
  (prog_defmap math_util.prog) ! math_util._vec3f_cross
    = Some (Gfun (Internal math_util.f_vec3f_cross)).
Proof. vm_compute. reflexivity. Qed.
Lemma surf_dm_ff2 :
  (prog_defmap surface_collision.prog) ! math_util._find_floor
    = Some (Gfun (Internal surface_collision.f_find_floor)).
Proof. vm_compute. reflexivity. Qed.

Definition mtxf_locals : list ident :=
  map fst (fn_vars math_util.f_mtxf_align_terrain_triangle).
Definition mtxf_helpers : list ident :=
  [math_util._vec3f_set; math_util._find_vector_perpendicular_to_plane;
   math_util._vec3f_normalize; math_util._vec3f_cross].
Definition mtxf_gs : list ident := [math_util._mtx].

(* mtx[i][j] = <scalar>: chain root the frozen parameter mtx *)
Definition mtx_store_ok (lv : expr) : bool :=
  match chain_root_l lv with
  | Some t => Pos.eqb t math_util._mtx && nonptr_scalar (typeof lv)
  | None => false
  end.

(* local[i] = <any>: a store into one of the body's own arrays *)
Definition loc_store_ok (lv : expr) : bool :=
  match lv with
  | Ederef (Ebinop Oadd (Evar x (Tarray _ _ _)) (Econst_int _ ity) _) T =>
      mem_id x mtxf_locals && proj_sumbool (type_eq ity tint) && is_byval T
  | _ => false
  end.

Definition mtxf_store_ok (lv : expr) : bool := mtx_store_ok lv || loc_store_ok lv.

(* find_floor(.., &sp74) *)
Definition ff_call_ok (al : list expr) (targs : list type) : bool :=
  match nth_error al 3, nth_error targs 3 with
  | Some (Eaddrof (Evar x _) aty), Some ta =>
      Pos.eqb x math_util._sp74 && is_ptr_ty aty && is_ptr_ty ta
  | _, _ => false
  end.

(* helper(local, ..) *)
Definition hl_call_ok (al : list expr) (targs : list type) : bool :=
  match nth_error al 0, nth_error targs 0 with
  | Some (Evar x (Tarray _ _ _)), Some ta => mem_id x mtxf_locals && is_ptr_ty ta
  | _, _ => false
  end.

Definition mtxf_call_ok (a : expr) (al : list expr) : bool :=
  match a with
  | Evar f (Tfunction targs _ _) =>
      negb (mem_id f mtxf_locals) &&
      ((Pos.eqb f math_util._find_floor && ff_call_ok al targs)
       || (mem_id f mtxf_helpers && hl_call_ok al targs))
  | _ => false
  end.

(* NON-VACUITY: the recognizer accepts the REAL generated body *)
Lemma mtxf_owf_chk :
  owf_chk mtxf_gs mtxf_store_ok mtxf_call_ok
    (fn_body math_util.f_mtxf_align_terrain_triangle) = true.
Proof. vm_compute. reflexivity. Qed.

Definition locs_valid (e : env) (m : mem) : Prop :=
  forall x b ty, e ! x = Some (b, ty) -> Mem.valid_block m b.

Section MtxfRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  (* the Twelve capstone's own facts *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  (* the FPU floor (TRUST 3.5): sqrtf leaves memory unchanged *)
  Hypothesis Hsq : sqrtf_spec.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma mt_LO_math : linkorder math_util.prog lp.
  Proof. exact (linked12_LO_math lp H12). Qed.
  Lemma mt_LO_surf : linkorder surface_collision.prog lp.
  Proof. exact (linked12_LO_surf lp H12). Qed.
  Lemma mt_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.
  Lemma mt_Hbc_sym : exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_sym lp init bm bc oc0 Hs). Qed.
  Lemma mt_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma mt_not_bc : ~ SafeB bc.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bc lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma mt_gms : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma mt_glob : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Proof. destruct Hspawn as (init & Hs). exact (glob_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma mt_gtimer : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma mt_table : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Proof. destruct Hspawn as (init & Hs). exact (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma mt_ktab : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
  Proof. destruct Hspawn as (init & Hs). exact (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.

  Lemma mt_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe -> (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Proof.
    exact (mwf_real_chase lp bm bc oc0 SafeB mt_Hbc_bm mt_not_bm mt_not_bc mt_gms
             mt_gtimer mt_table mt_ktab).
  Qed.

  (* the matrix block: any non-pointer store keeps the carried facts *)
  Lemma mt_safe_np : forall b, SafeB b -> blk_pres_np bm MWF b.
  Proof.
    intros b Hs ch z v m1 m2 Hnp Hst Hv Hsat Hmwf.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (mt_not_bm b Hs Hb).
    - exact (mt_chase _ _ _ _ _ _ Hmwf Hs Hnp Hst).
  Qed.

  (* a stack local: wholly store-safe *)
  Lemma mt_local_pres : forall b, local_blk lp bm SafeB b ->
      blk_pres not_tainted bm MWF b.
  Proof.
    intros b Hl.
    apply (blk_pres_local bm MWF (local_blk lp bm SafeB)).
    - intros b0 (Hb0 & _). exact Hb0.
    - intros m ch b0 d v m' (Hb0 & HnS & Hgl) Hst HM0.
      destruct mt_Hbc_sym as (gid & Hsy).
      eapply mwf_real_local_store; eauto using mt_Hbc_bm.
    - exact Hl.
  Qed.

  (* the walk's carried facts: MWF plus every local block still valid *)
  Definition mt_W (e : env) (m : mem) : Prop := MWF m /\ locs_valid e m.

  Lemma mt_store :
    forall e bmtx omtx le0,
      (forall x b ty, e ! x = Some (b, ty) -> local_blk lp bm SafeB b) ->
      (forall x, mem_id x mtxf_locals = true -> exists b ty, e ! x = Some (b, ty)) ->
      le0 ! math_util._mtx = Some (Vptr bmtx omtx) -> SafeB bmtx ->
      forall lv rhs le m t le' m' out,
        mtxf_store_ok lv = true -> frozen mtxf_gs le0 le ->
        exec_stmt function_entry2 (lp_ge lp) e le m (Sassign lv rhs) t le' m' out ->
        ow_facts bm (mt_W e) m -> ow_facts bm (mt_W e) m'.
  Proof.
    intros e bmtx omtx le0 He_loc He_some Hle0 Hsafe lv rhs le m t le' m' out Hok Hfr Hx
           (Hv & Hs & HM & Hlv).
    assert (Hlv' : locs_valid e m')
      by (intros x b ty Hxb;
          exact (proj1 (exec_funcall_valid _) _ _ _ _ _ _ _ _ Hx _ (Hlv _ _ _ Hxb))).
    enough (Hf : ow_facts bm MWF m')
      by (destruct Hf as (Hv' & Hs' & HM'); exact (conj Hv' (conj Hs' (conj HM' Hlv')))).
    unfold mtxf_store_ok in Hok. apply orb_true_iff in Hok as [Hm | Hl].
    - unfold mtx_store_ok in Hm.
      destruct (chain_root_l lv) as [tr|] eqn:Hcr; [ | discriminate Hm ].
      apply andb_prop in Hm as [Ht Hnp]. apply Pos.eqb_eq in Ht. subst tr.
      apply (assign_np_pres bm MWF (lp_ge lp) e le m lv rhs t le' m' out);
        [ | exact Hnp | exact Hx | exact (conj Hv (conj Hs HM)) ].
      intros loc ofs bf Hl.
      destruct (CensusV2.chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hl) as (o0 & Hle).
      rewrite (Hfr math_util._mtx ltac:(vm_compute; reflexivity)), Hle0 in Hle.
      injection Hle as Eb _. subst loc.
      exact (mt_safe_np bmtx Hsafe).
    - destruct lv as [ | | | | | | lv0 T | | | | | | | ]; try discriminate Hl.
      destruct lv0 as [ | | | | | | | | | op x1 x2 bty | | | | ]; try discriminate Hl.
      destruct op; try discriminate Hl.
      destruct x1 as [ | | | | lx lty | | | | | | | | | ]; try discriminate Hl.
      destruct lty as [ | | | | | ety n lat | | | ]; try discriminate Hl.
      destruct x2 as [ ii ity | | | | | | | | | | | | | ]; try discriminate Hl.
      cbn [loc_store_ok] in Hl.
      apply andb_prop in Hl as [Hl Hbv]. apply andb_prop in Hl as [Hlx Hity].
      destruct (type_eq ity tint); [ subst ity | discriminate Hity ].
      destruct (He_some _ Hlx) as (bx & tx & Hex).
      apply (assign_blk_pres bm MWF (lp_ge lp) e le m (Ederef (Ebinop Oadd (Evar lx (Tarray ety n lat)) (Econst_int ii tint) bty) T) rhs t le' m' out);
        [ | exact Hbv | exact Hx | exact (conj Hv (conj Hs HM)) ].
      intros loc ofs bf Hlv0.
      rewrite (arr_lvalue_blk _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hlv0 Hex).
      exact (mt_local_pres bx (He_loc _ _ _ Hex)).
  Qed.

  Lemma mt_call :
    forall e,
      (forall x b ty, e ! x = Some (b, ty) -> local_blk lp bm SafeB b) ->
      (forall x, mem_id x mtxf_locals = true -> exists b ty, e ! x = Some (b, ty)) ->
      (forall f, mem_id f mtxf_locals = false -> e ! f = None) ->
      forall le0 optid a al le m t le' m' out,
        mtxf_call_ok a al = true -> frozen mtxf_gs le0 le ->
        exec_stmt function_entry2 (lp_ge lp) e le m (Scall optid a al) t le' m' out ->
        ow_facts bm (mt_W e) m -> ow_facts bm (mt_W e) m'.
  Proof.
    intros e He_loc He_some He_none le0 optid a al le m t le' m' out Hok _ Hx
           (Hv & Hs & HM & Hlv).
    assert (Hlv' : locs_valid e m')
      by (intros x b ty Hxb;
          exact (proj1 (exec_funcall_valid _) _ _ _ _ _ _ _ _ Hx _ (Hlv _ _ _ Hxb))).
    enough (Hf : ow_facts bm MWF m')
      by (destruct Hf as (Hv' & Hs' & HM'); exact (conj Hv' (conj Hs' (conj HM' Hlv')))).
    pose proof (sb_frame_oracles lp bm bc oc0 SafeB mt_Hbc_bm) as Hor.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [mtxf_call_ok] in Hok.
    apply andb_prop in Hok as [Hnl Hok]. apply negb_true_iff in Hnl.
    inv Hx.
    match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hcf; injection Hcf as <- <- <- end.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (He_none _ Hnl)) as (lf & Hsy & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
      rewrite Genv.find_funct_find_funct_ptr in Hff end.
    apply orb_true_iff in Hok as [Hffl | Hhl].
    - (* find_floor(.., &sp74) *)
      apply andb_prop in Hffl as [Hf Hal]. apply Pos.eqb_eq in Hf. subst fid.
      unfold ff_call_ok in Hal.
      destruct (nth_error al 3) as [x3|] eqn:Ha3; [ | discriminate Hal ].
      destruct x3 as [ | | | | | | | x3' aty | | | | | | ]; try discriminate Hal.
      destruct x3' as [ | | | | sx sty | | | | | | | | | ]; try discriminate Hal.
      destruct (nth_error targs 3) as [ta|] eqn:Ht3; [ | discriminate Hal ].
      apply andb_prop in Hal as [Hal Hta]. apply andb_prop in Hal as [Hsx Haty].
      apply Pos.eqb_eq in Hsx. subst sx.
      destruct (He_some math_util._sp74 ltac:(vm_compute; reflexivity)) as (bsp & tsp & Hesp).
      match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
        destruct (exprlist_nth _ _ _ _ _ _ _ Hel 3 _ _ Ha3 Ht3) as (v1 & v2 & Hx1 & Hc1 & Hn3) end.
      assert (Ev1 : v1 = Vptr bsp Ptrofs.zero).
      { inv Hx1;
          [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
        match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
          congruence. }
      subst v1. cbn [typeof] in Hc1.
      rewrite (cast_ptr_ptr _ _ _ _ _ _ Haty Hta Hc1) in Hn3.
      pose proof (mt_local_pres bsp (He_loc _ _ _ Hesp)) as Hbp.
      match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
        rewrite (sb_resolves lp mt_LO_surf _ _ surf_dm_ff2 _ _ Hsy Hfp) in Hfc;
        exact (find_floor_body_frame_pinned (lp_ge lp) MWF bm bsp Ptrofs.zero Hor
                 (sb_statics lp bm bc oc0 SafeB mt_Hbc_bm mt_glob)
                 (sb_resolves lp mt_LO_surf _ _ surf_dm_ffl)
                 _ _ _ _ _ Hfc Hn3 (fun ch _ => Hbp ch _) Hv Hs HM) end.
    - (* a math_util writer, dest a local array *)
      apply andb_prop in Hhl as [Hmem Hal].
      unfold hl_call_ok in Hal.
      destruct (nth_error al 0) as [x0|] eqn:Ha0; [ | discriminate Hal ].
      destruct x0 as [ | | | | lx lty | | | | | | | | | ]; try discriminate Hal.
      destruct lty as [ | | | | | ety n lat | | | ]; try discriminate Hal.
      destruct (nth_error targs 0) as [ta|] eqn:Ht0; [ | discriminate Hal ].
      apply andb_prop in Hal as [Hlx Hta].
      destruct (He_some _ Hlx) as (bx & tx & Hex).
      match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
        destruct (exprlist_nth _ _ _ _ _ _ _ Hel 0 _ _ Ha0 Ht0) as (v1 & v2 & Hx1 & Hc1 & Hn0) end.
      rewrite (evar_arr_val _ _ _ _ _ _ _ _ _ _ _ Hx1 Hex) in Hc1.
      destruct ta; try discriminate Hta. cbn in Hc1. injection Hc1 as <-.
      pose proof (nth0_hd _ _ Hn0) as Hhd.
      pose proof (mt_local_pres bx (He_loc _ _ _ Hex)) as Hbp.
      pose proof (Hlv _ _ _ Hex) as Hbxv.
      apply mem_id_In in Hmem. unfold mtxf_helpers in Hmem.
      match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
        destruct Hmem as [<- | [<- | [<- | [<- | []]]]];
        [ rewrite (math_resolves lp mt_LO_math _ _ mu_dm_v3fset _ _ Hsy Hfp) in Hfc;
          exact (vec3f_set_body_frame_B (lp_ge lp) MWF bm bx Ptrofs.zero Hor _ _ _ _ _ Hfc Hhd
                   (vec_out_of_blk bm MWF Mfloat32 bx Ptrofs.zero Hbp) Hbxv Hv Hs HM)
        | rewrite (math_resolves lp mt_LO_math _ _ mu_dm_fvptp _ _ Hsy Hfp) in Hfc;
          exact (fvptp_frame (lp_ge lp) MWF bm bx Ptrofs.zero Hor Hbp _ _ _ _ _ Hfc Hhd Hbxv
                   (conj Hv (conj Hs HM)))
        | rewrite (math_resolves lp mt_LO_math _ _ mu_dm_norm _ _ Hsy Hfp) in Hfc;
          exact (norm_frame lp H12 Hsq MWF bm bx Ptrofs.zero Hor Hbp _ _ _ _ _ Hfc Hhd Hbxv
                   (conj Hv (conj Hs HM)))
        | rewrite (math_resolves lp mt_LO_math _ _ mu_dm_cross _ _ Hsy Hfp) in Hfc;
          exact (cross_frame (lp_ge lp) MWF bm bx Ptrofs.zero Hor Hbp _ _ _ _ _ Hfc Hhd Hbxv
                   (conj Hv (conj Hs HM))) ]
      end.
  Qed.

  Lemma mtxf_body_frame : forall m vargs t m' vres bmtx omtx rest,
      eval_funcall function_entry2 (lp_ge lp) m
        (Internal math_util.f_mtxf_align_terrain_triangle) vargs t m' vres ->
      vargs = Vptr bmtx omtx :: rest -> SafeB bmtx ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros m vargs t m' vres bmtx omtx rest Hevf -> Hsafe (Hv & Hs & HM).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hbp : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hbp into Hbpt end.
    destruct (av_facts bm MWF _ _ _ _ _ _ (mwf_real_alloc lp bm bc oc0 SafeB mt_Hbc_bm) Hav
                (conj Hv (conj Hs HM))) as (Hv1 & Hs1 & HM1).
    assert (HGv : forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg)
      by (apply glob_valid_of_nextbound; exact (mwf_real_nextbound lp bm bc oc0 SafeB m HM)).
    change (fn_params math_util.f_mtxf_align_terrain_triangle)
      with ((math_util._mtx, tptr (tarray tfloat 4)) :: (math_util._pos, tptr tfloat)
            :: (math_util._yaw, tshort) :: (math_util._radius, tfloat) :: nil) in Hbpt.
    assert (Hni : ~ In math_util._mtx
                    (var_names ((math_util._pos, tptr tfloat) :: (math_util._yaw, tshort)
                                :: (math_util._radius, tfloat) :: nil)))
      by (cbn [var_names map fst]; intros Hin; repeat (destruct Hin as [Hin|Hin]; [discriminate Hin|]);
          exact Hin).
    pose proof (bind_parameter_temps_head _ _ _ _ _ _ _ Hni Hbpt) as Hled.
    assert (He_loc : forall x b ty, e ! x = Some (b, ty) -> local_blk lp bm SafeB b).
    { intros x b ty Hx.
      exact (alloc_variables_local_blk lp bm SafeB _ _ _ _ Hav Hv
               (mwf_real_safe_valid lp bm bc oc0 SafeB m HM) HGv x b ty Hx). }
    assert (He_some : forall x, mem_id x mtxf_locals = true -> exists b ty, e ! x = Some (b, ty)).
    { intros x Hx. exact (alloc_variables_in_bound _ _ _ _ _ _ Hav x (mem_id_In _ _ Hx)). }
    assert (He_none : forall f, mem_id f mtxf_locals = false -> e ! f = None).
    { intros g Hg. rewrite (alloc_variables_unbound _ _ _ _ _ _ Hav g (mem_id_notin _ _ Hg)).
      apply PTree.gempty. }
    assert (Hlv1 : locs_valid e m1).
    { intros x b ty Hx. destruct (av_valid_bound _ _ _ _ _ _ Hav x b ty Hx) as [Hz | Hz].
      - rewrite PTree.gempty in Hz. discriminate Hz.
      - exact Hz. }
    match goal with Hb : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _ |- _ =>
      destruct (owf_walk (lp_ge lp) E bm (mt_W E) mtxf_gs LE mtxf_store_ok mtxf_call_ok
                  (mt_store E bmtx omtx LE He_loc He_some Hled Hsafe)
                  (mt_call E He_loc He_some He_none LE)
                  _ _ _ _ _ _ _ _ Hb eq_refl mtxf_owf_chk (fun _ _ => eq_refl)
                  (conj Hv1 (conj Hs1 (conj HM1 Hlv1)))) as ((Hv2 & Hs2 & HM2 & _) & _)
    end.
    assert (Hfa : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                    (blocks_of_env (lp_ge lp) e)).
    { eapply Forall_impl; [ | exact (blocks_of_env_bm lp bm _ _ _ _ Hav Hv) ].
      intros [[b lo] hi] Hq. exact Hq. }
    destruct (vfc_free_list_frame not_tainted bm _ _ _ Hfa Hfl Hv2 Hs2) as (Hvf & Hsf).
    exact (conj Hvf (conj Hsf (mwf_real_free lp bm bc oc0 SafeB mt_Hbc_bm _ _ _ Hfl HM2))).
  Qed.

  (* THE ROW: mtxf_align_terrain_triangle with arg0 (the matrix) in a SafeB
     block preserves the carried run facts -- proved from its real body. *)
  Lemma Hscp_mtxf_proved :
    call_pres_ext_sc lp bm NoA MWF SafeB mario_actions_moving._mtxf_align_terrain_triangle.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ mt_LO_math mu_dm_mtxf Hres) as ->.
    destruct Harg as (b & o & rest & -> & Hsb).
    destruct (mtxf_body_frame _ _ _ _ _ b o rest Hevf eq_refl Hsb (conj Hv (conj Hsat HM)))
      as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.
End MtxfRows.
