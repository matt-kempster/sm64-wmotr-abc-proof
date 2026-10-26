(* ====================================================================== *)
(* FootWalk (GOAL 2): the FOOTPRINT twin of SaveDoSaveBody's walker       *)
(* (2026-10-26, for the controller poll's carries).                       *)
(*                                                                        *)
(* SaveDoSaveBody walks the libultra SI / message-queue call trees for    *)
(* GOAL 1's carried facts: every store lands in a block those facts never *)
(* read.  For GOAL 2's world (PhiW, the object world, gMarioPlatform's    *)
(* fact) that is not enough: those read globals the harm class allows.    *)
(* This walk proves the sharper fact: the call changes memory only in the *)
(* blocks of a LISTED set of globals FP (and in blocks born during the    *)
(* call: stack locals).  The recognizers are SaveDoSaveBody's with the    *)
(* census list stored_globals replaced by FP, and the q_side queues        *)
(* restricted to those whose queue and side buffers are in FP:            *)
(*   - a pointer in a tracked temp points into an FP global or a block     *)
(*     not valid at the walk's start (FP-or-fresh);                       *)
(*   - every store is through an FP-or-fresh lvalue;                       *)
(*   - the floor calls (OsDmaFloor, TRUST 3.5) change their queue, side    *)
(*     buffers, message cell and PIF image only: FP-or-fresh by the        *)
(*     argument classes.                                                   *)
(* The result (fpF): Mem.unchanged_on outside the FP blocks, over the     *)
(* blocks valid at the start.                                             *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool Classical_Prop.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require memory libultra_osEepromWrite libultra_osSiCreateAccessQueue
  libultra_osCreateMesgQueue libultra_osContStartReadData save_file.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve OsDmaFloor CensusV2.
From SM64.Proofs Require MtxfBody ActWriterSurface LocalVarsSurface RetSurface LptBody
  SaveDoSaveBody.
From SM64.Proofs.WMotRRequiresA Require PollFlank.
Import ListNotations.
Local Open Scope Z_scope.

Module SDB := SaveDoSaveBody.

(* ---------------------------------------------------------------------- *)
(* 1. The recognizers, over the footprint list FP.                         *)
(* ---------------------------------------------------------------------- *)
Section REC.
  Variable FP : list ident.

  Definition hlv_var (lv : list ident) (x : ident) : bool :=
    mem_id x lv || mem_id x FP.

  Fixpoint hx (lv fl : list ident) (a : expr) : bool :=
    match a with
    | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => true
    | Esizeof _ _ | Ealignof _ _ => true
    | Etempvar t _ => negb (mem_id t fl)
    | Eunop _ _ _ => true
    | Ecast a1 _ => hx lv fl a1
    | Ebinop Oadd a1 a2 _ => hx lv fl a1 && hx lv fl a2
                             || ptrish (typeof a1) && hx lv fl a1
    | Ebinop Osub a1 _ _ => hx lv fl a1
    | Ebinop op _ _ _ => SDB.cmp_op op || ActWriterSurface.nonptr_binop_head a
    | Evar x ty => SDB.rv_chk ty (hlv_var lv x)
    | Ederef a1 ty => SDB.rv_chk ty (hx lv fl a1)
    | Efield a1 _ ty => SDB.rv_chk ty (hx lv fl a1)
    | Eaddrof a1 _ =>
        match a1 with
        | Evar x _ => hlv_var lv x
        | Ederef a2 _ | Efield a2 _ _ => hx lv fl a2
        | _ => false
        end
    end.

  Definition hlv (lv fl : list ident) (a : expr) : bool :=
    match a with
    | Evar x _ => hlv_var lv x
    | Ederef a1 _ | Efield a1 _ _ => hx lv fl a1
    | _ => false
    end.

  Lemma hx_addrof : forall lv fl a ty, hx lv fl (Eaddrof a ty) = hlv lv fl a.
  Proof. intros lv fl a ty. destruct a; reflexivity. Qed.

  (* a q_side queue whose queue and side buffers are footprint globals *)
  Definition is_q (q : ident) : bool :=
    match q_side q with
    | Some side => mem_id q FP && forallb (fun s => mem_id s FP) side
    | None => false
    end.

  Definition hq (lv qa : list ident) (a : expr) : bool :=
    match a with
    | Etempvar t _ => mem_id t qa
    | Eaddrof (Evar q _) _ => negb (mem_id q lv) && is_q q
    | _ => false
    end.

  Definition set_ok (lv fl qa : list ident) (id : ident) (a : expr) : bool :=
    (mem_id id fl || hx lv fl a) && (negb (mem_id id qa) || hq lv qa a).

  Definition store_ok (lv fl : list ident) (a : expr) : bool := hlv lv fl a.

  Fixpoint args_ok (lv fl qa fl' qa' : list ident) (ps : list (ident * type))
      (al : list expr) : bool :=
    match ps, al with
    | [], [] => true
    | p :: ps', a :: al' =>
        (mem_id (fst p) fl' || hx lv fl a) && (negb (mem_id (fst p) qa') || hq lv qa a)
        && args_ok lv fl qa fl' qa' ps' al'
    | _, _ => false
    end.

  (* the floor calls of the SI trees: osRecvMesg, osSendMesg, __osSiRawStartDma *)
  Definition floor_ok (lv fl qa : list ident) (fid : ident) (al : list expr) : bool :=
    if Pos.eqb fid memory._osRecvMesg then
      match al with [aq; ac; _] => hq lv qa aq && hx lv fl ac | _ => false end
    else if Pos.eqb fid libultra_osSiCreateAccessQueue._osSendMesg then
      match al with [aq; _; _] => hq lv qa aq | _ => false end
    else if Pos.eqb fid libultra_osEepromWrite.___osSiRawStartDma then
      match al with [_; ap] => hx lv fl ap | _ => false end
    else false.

  Definition call_ok (lv fl qa : list ident) (c : SDB.ctab) (o : option ident) (a : expr)
      (al : list expr) : bool :=
    match a with
    | Evar fid (Tfunction _ _ _) =>
        negb (mem_id fid lv) && SDB.opt_ok fl qa o &&
        match SDB.find_ct fid c with
        | Some (f, (fl', qa')) => args_ok lv fl qa fl' qa' (fn_params f) al
        | None => floor_ok lv fl qa fid al
        end
    | _ => false
    end.

  Definition body_chk (f : Clight.function) (fl qa : list ident) (c : SDB.ctab) : bool :=
    let lv := map fst (fn_vars f) in
    SDB.hw_chk (set_ok lv fl qa) (store_ok lv fl) (call_ok lv fl qa c) (fn_body f).
End REC.

(* ---------------------------------------------------------------------- *)
(* 2. Soundness, on the link.                                              *)
(* ---------------------------------------------------------------------- *)
Section FW.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Variable FP : list ident.
  (* the memory at the walk's start: blocks valid there are watched *)
  Variable m0 : mem.

  Notation ge := (lp_ge lp).

  (* a footprint global's block *)
  Definition Fb (b : block) : Prop := exists id, In id FP /\ Genv.find_symbol ge id = Some b.
  (* footprint-or-fresh *)
  Definition HB (b : block) : Prop := Fb b \/ ~ Mem.valid_block m0 b.
  (* what stays unchanged *)
  Definition Q (b : block) (z : Z) : Prop := ~ Fb b /\ Mem.valid_block m0 b.

  Lemma HB_notQ : forall b z, HB b -> ~ Q b z.
  Proof. intros b z [H | H] (N & V); [ exact (N H) | exact (H V) ]. Qed.

  Lemma fb_glob : forall id b, mem_id id FP = true -> Genv.find_symbol ge id = Some b -> HB b.
  Proof. intros id b Hm Hs. left. exists id. split; [ exact (MtxfBody.mem_id_In _ _ Hm) | exact Hs ]. Qed.

  Definition HPv (v : val) : Prop := forall b o, v = Vptr b o -> HB b.
  Definition AQ (v : val) : Prop := forall b o, v = Vptr b o ->
      exists q side, q_side q = Some side /\ mem_id q FP = true
        /\ (forall s, In s side -> mem_id s FP = true) /\ Genv.find_symbol ge q = Some b.

  Definition Pt (fl qa : list ident) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v ->
      (mem_id t fl = false -> HPv v) /\ (mem_id t qa = true -> AQ v).

  Definition Env (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> HB b)
    /\ (forall x, mem_id x lv = false -> e ! x = None)
    /\ (forall x, mem_id x lv = true -> e ! x <> None).

  Section Expr.
    Variables (lv fl qa : list ident) (e : env) (le : temp_env) (m : mem).
    Hypothesis HE : Env lv e.
    Hypothesis HP : Pt fl qa le.

    Lemma hlv_var_sound : forall x ty loc ofs bf,
        eval_lvalue ge e le m (Evar x ty) loc ofs bf -> hlv_var FP lv x = true -> HB loc.
    Proof.
      intros x ty loc ofs bf Hl Hok. destruct HE as (Eh & En & Es).
      inv Hl.
      - match goal with H : e ! x = Some _ |- _ => exact (Eh _ _ _ H) end.
      - unfold hlv_var in Hok. apply orb_true_iff in Hok as [Hl | Hg].
        + exfalso. apply (Es x Hl). assumption.
        + match goal with H : Genv.find_symbol _ x = Some _ |- _ => exact (fb_glob x loc Hg H) end.
    Qed.

    Lemma hx_sound : forall a,
        (forall v, eval_expr ge e le m a v -> hx FP lv fl a = true -> HPv v)
        /\ (forall loc ofs bf, eval_lvalue ge e le m a loc ofs bf ->
              hlv FP lv fl a = true -> HB loc).
    Proof.
      induction a as [ i ty | f ty | f ty | i ty | x ty | t ty | a1 IH1 ty | a1 IH1 ty
                     | op a1 IH1 ty | op a1 IH1 a2 IH2 ty | a1 IH1 ty | a1 IH1 fld ty
                     | ty0 ty | ty0 ty ];
        (split; [ intros v Hev Hok | intros loc ofs bf Hev Hok ]); cbn [hx hlv] in Hok;
        try discriminate Hok.
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev. cbn [typeof] in *.
        match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) ?l ?of ?bf,
                        Hd : deref_loc _ _ ?l ?of ?bf _ |- _ =>
          unfold SDB.rv_chk in Hok; destruct (access_mode ty) as [ch| | |] eqn:Am;
          [ exact (False_ind _ (SDB.deref_small_nonptr _ _ _ _ _ _ _ Hd Am Hok b o eq_refl))
          | | | ];
          inv Hd; try congruence;
          try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end);
          exact (hlv_var_sound _ _ _ _ _ Hl Hok) end.
      - exact (hlv_var_sound _ _ _ _ _ Hev Hok).
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end).
        apply negb_true_iff in Hok.
        match goal with H : le ! t = Some _ |- _ => exact (proj1 (HP _ _ H) Hok b o eq_refl) end.
      - intros b o ->. inv Hev. cbn [typeof] in *.
        match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) ?l ?of ?bf,
                        Hd : deref_loc _ _ ?l ?of ?bf _ |- _ =>
          unfold SDB.rv_chk in Hok; destruct (access_mode ty) as [ch| | |] eqn:Am;
          [ exact (False_ind _ (SDB.deref_small_nonptr _ _ _ _ _ _ _ Hd Am Hok b o eq_refl))
          | | | ];
          inv Hd; try congruence;
          try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end);
          inv Hl; exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl) end.
      - inv Hev. exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv H end).
        change (hlv FP lv fl a1 = true) in Hok.
        match goal with Hl : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
          exact (proj2 IH1 _ _ _ Hl Hok) end.
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv H end).
        match goal with H : sem_unary_operation _ _ _ _ = Some _ |- _ =>
          exfalso; exact (ActWriterSurface.sem_unop_nonptr _ _ _ _ _ H b o eq_refl) end.
      - intros b o ->.
        destruct op; cbn in Hok;
          first
            [ exfalso; refine (ActWriterSurface.eval_nonptr_binop_head _ _ _ _ _ _ _ _ _
                                _ Hev b o eq_refl); reflexivity
            | inv Hev;
              try (match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end);
              match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
                cbn [sem_binary_operation] in Hs end ].
        + apply orb_true_iff in Hok as [Hb | Hp].
          * apply andb_prop in Hb as [Ha1 Ha2].
            destruct (SDB.sem_add_vptr_src _ _ _ _ _ _ _ _ ltac:(eassumption)) as [(o1 & E1) | (o2 & E2)].
            -- subst. exact (proj1 IH1 _ ltac:(eassumption) Ha1 _ _ eq_refl).
            -- subst. exact (proj1 IH2 _ ltac:(eassumption) Ha2 _ _ eq_refl).
          * apply andb_prop in Hp as [Hpt Ha1].
            destruct (sem_add_ptrish_block _ _ _ _ _ _ _ _ Hpt ltac:(eassumption)) as (o1 & E1).
            subst. exact (proj1 IH1 _ ltac:(eassumption) Ha1 _ _ eq_refl).
        + destruct (SDB.sem_sub_vptr_src _ _ _ _ _ _ _ _ ltac:(eassumption)) as (o1 & E1).
          subst. exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv H end).
        match goal with Hc : sem_cast _ _ _ _ = Some (Vptr b o) |- _ =>
          pose proof (sem_cast_vptr_inv _ _ _ _ _ _ Hc) as Ev; subst end.
        exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
      - intros b o ->. inv Hev. cbn [typeof] in *.
        match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) ?l ?of ?bf,
                        Hd : deref_loc _ _ ?l ?of ?bf _ |- _ =>
          unfold SDB.rv_chk in Hok; destruct (access_mode ty) as [ch| | |] eqn:Am;
          [ exact (False_ind _ (SDB.deref_small_nonptr _ _ _ _ _ _ _ Hd Am Hok b o eq_refl))
          | | | ];
          inv Hd; try congruence;
          try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end);
          inv Hl; exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl) end.
      - inv Hev; exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
          unfold Vptrofs in *; destruct Archi.ptr64; discriminate.
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
          unfold Vptrofs in *; destruct Archi.ptr64; discriminate.
    Qed.

    Lemma hq_sound : forall a v,
        eval_expr ge e le m a v -> hq FP lv qa a = true -> AQ v.
    Proof.
      intros a v Hev Hok. destruct HE as (Eh & En & Es).
      destruct a as [ | | | | | t ty | | a1 ty | | | | | | ]; try discriminate Hok.
      - cbn [hq] in Hok. inv Hev;
          [ | match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end ].
        match goal with H : le ! t = Some _ |- _ => exact (proj2 (HP _ _ H) Hok) end.
      - destruct a1 as [ | | | | q qty | | | | | | | | | ]; try discriminate Hok.
        cbn [hq] in Hok. apply andb_prop in Hok as [Hnl Hq].
        apply negb_true_iff in Hnl.
        unfold is_q in Hq. destruct (q_side q) as [side|] eqn:Hqs; [ | discriminate Hq ].
        apply andb_prop in Hq as [Hq1 Hq2].
        inv Hev; [ | match goal with H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv H end ].
        match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
        + match goal with H : e ! q = Some _ |- _ => rewrite (En q Hnl) in H; discriminate H end.
        + intros b o E. injection E as <- _. exists q, side.
          split; [ exact Hqs | split; [ exact Hq1 | split; [ | assumption ] ] ].
          intros s Hs. exact (proj1 (forallb_forall _ _) Hq2 s Hs).
    Qed.

    Lemma exprlist_cls : forall al tyl vl,
        eval_exprlist ge e le m al tyl vl ->
        Forall2 (fun a v => (hx FP lv fl a = true -> HPv v) /\ (hq FP lv qa a = true -> AQ v)) al vl.
    Proof.
      intros al tyl vl H. induction H as [ | a bl ty tyl v1 v2 vl Ha Hc Hbl IH ];
        constructor; [ | exact IH ].
      split.
      - intros Hok b o ->. apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v1.
        exact (proj1 (hx_sound a) _ Ha Hok b o eq_refl).
      - intros Hok b o ->. apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v1.
        exact (hq_sound a _ Ha Hok b o eq_refl).
    Qed.
  End Expr.

  Definition Cp (fl qa : list ident) (p : ident * type) (v : val) : Prop :=
    (mem_id (fst p) fl = false -> HPv v) /\ (mem_id (fst p) qa = true -> AQ v).

  Lemma bind_cls : forall fl qa ps vl te le,
      bind_parameter_temps ps vl te = Some le ->
      Forall2 (Cp fl qa) ps vl -> Pt fl qa te -> Pt fl qa le.
  Proof.
    intros fl qa ps. induction ps as [ | [id ty] ps IH ];
      intros vl te le Hb Hf Ht; destruct vl as [ | v0 vr ]; cbn in Hb; try discriminate Hb.
    - injection Hb as <-. exact Ht.
    - inv Hf. apply (IH vr _ _ Hb); [ assumption | ].
      intros t v Hg. destruct (peq t id) as [-> | Hne].
      + rewrite PTree.gss in Hg. injection Hg as <-. assumption.
      + rewrite PTree.gso in Hg by exact Hne. exact (Ht _ _ Hg).
  Qed.

  Lemma undef_Pt : forall fl qa l, Pt fl qa (create_undef_temps l).
  Proof.
    intros fl qa l t v Hg. apply MtxfBody.create_undef_temps_get in Hg. subst v.
    split; intros _ b o E; discriminate E.
  Qed.

  Lemma args_cls : forall lv fl qa fl' qa' e le m ps al tyl vl,
      Env lv e -> Pt fl qa le ->
      eval_exprlist ge e le m al tyl vl ->
      args_ok FP lv fl qa fl' qa' ps al = true -> Forall2 (Cp fl' qa') ps vl.
  Proof.
    intros lv fl qa fl' qa' e le m ps al tyl vl HE HP Hel Hok.
    pose proof (exprlist_cls lv fl qa e le m HE HP al tyl vl Hel) as Hc.
    clear Hel. revert al vl Hc Hok.
    induction ps as [ | p ps IH ]; intros al vl Hc Hok; destruct al as [ | a al ];
      cbn [args_ok] in Hok; try discriminate Hok.
    - inv Hc. constructor.
    - inv Hc. apply andb_prop in Hok as [Hok Hrest]. apply andb_prop in Hok as [Hh Hq].
      constructor; [ | exact (IH _ _ ltac:(eassumption) Hrest) ].
      match goal with H : (_ -> HPv ?v) /\ (_ -> AQ ?v) |- Cp _ _ _ ?v =>
        destruct H as [Hhv Hqv] end.
      split.
      + intros Hn. rewrite Hn in Hh. exact (Hhv Hh).
      + intros Hy. rewrite Hy in Hq. exact (Hqv Hq).
  Qed.

  (* ---- the invariant and the function contract ---- *)
  Definition Inv (mE m : mem) : Prop := Mem.unchanged_on Q mE m.

  Definition fpF (f : Clight.function) (fl qa : list ident) : Prop :=
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      (forall le, bind_parameter_temps (fn_params f) vargs
                    (create_undef_temps (fn_temps f)) = Some le -> Pt fl qa le) ->
      Ple (Mem.nextblock m0) (Mem.nextblock m) ->
      Mem.unchanged_on Q m m'.

  Definition ctab_ok (c : SDB.ctab) : Prop :=
    forall fid f fl' qa', SDB.find_ct fid c = Some (f, (fl', qa')) ->
      SDB.resolved lp fid f /\ fpF f fl' qa'.

  Lemma opt_Pt : forall fl qa optid v le,
      SDB.opt_ok fl qa optid = true -> Pt fl qa le -> Pt fl qa (set_opttemp optid v le).
  Proof.
    intros fl qa optid v le Hok HP. destruct optid as [id|]; cbn [set_opttemp]; [ | exact HP ].
    cbn [SDB.opt_ok] in Hok. apply andb_prop in Hok as [Hf Hq]. apply negb_true_iff in Hq.
    intros t w Hg. destruct (peq t id) as [-> | Hne].
    - split; intros H; congruence.
    - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
  Qed.

  Lemma floor_ids3 : MtxfBody.no_internal_all12 SDB.floor_ids = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma floor_ext : forall q fid n b fd m vargs t m' vres,
      linkorder q lp -> mem_id fid SDB.floor_ids = true ->
      MtxfBody.xnamed ((prog_defmap q) ! fid) n = true ->
      Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      exists sg, external_functions_sem n sg (Genv.to_senv ge) vargs m t vres m'.
  Proof.
    intros q fid n b fd m vargs t m' vres LO Hid Hn Hs Hf Hev.
    destruct (MtxfBody.xresolve lp q fid SDB.floor_ids n b fd H12 LO Hid floor_ids3 Hn Hs Hf)
      as (sg & targs & tres & cc & ->).
    inv Hev. exists sg.
    match goal with Hx : external_call _ _ _ _ _ _ _ |- _ => exact Hx end.
  Qed.

  (* the side buffers of an FP queue are FP blocks *)
  Lemma side_fb : forall side b0, (forall s, In s side -> mem_id s FP = true) ->
      Fb b0 \/ not_side (Genv.to_senv ge) side b0.
  Proof.
    intros side b0 Hs.
    destruct (classic (Fb b0)) as [Hf | Hn]; [ left; exact Hf | right ].
    intros s Hin E. apply Hn. exists s. split; [ exact (MtxfBody.mem_id_In _ _ (Hs s Hin)) | exact E ].
  Qed.

  Lemma floor_call : forall lv fl qa e le m optid fid fty al t le' m' out,
      Env lv e -> Pt fl qa le ->
      floor_ok FP lv fl qa fid al = true -> SDB.opt_ok fl qa optid = true ->
      mem_id fid lv = false -> access_mode fty = By_reference ->
      exec_stmt function_entry2 ge e le m (Scall optid (Evar fid fty) al) t le' m' out ->
      Mem.unchanged_on Q m m' /\ Pt fl qa le'.
  Proof.
    intros lv fl qa e le m optid fid fty al t le' m' out HE HP Hok Hopt Hnl Am Hx.
    pose proof HE as (Eh & En & Es).
    destruct (LptBody.scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ Hx (En fid Hnl) Am)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & _ & Hel & Hev & -> & _).
    split; [ | exact (opt_Pt fl qa optid vres le Hopt HP) ].
    pose proof (exprlist_cls lv fl qa e le m HE HP _ _ _ Hel) as Hc.
    destruct Hfloor as (_ & _ & Hrv & Hsd & _ & Hsi & _).
    unfold floor_ok in Hok.
    destruct (Pos.eqb fid memory._osRecvMesg) eqn:E1.
    { apply Pos.eqb_eq in E1. subst fid.
      destruct (floor_ext memory.prog memory._osRecvMesg "osRecvMesg" _ _ _ _ _ _ _ (linked12_LO_memory lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hrv _ _ _ _ _ _ _ Hx') as (bq & oq & cell & f0 & -> & _ & _ & UOq).
      destruct al as [ | aq [ | ac [ | af [ | ] ] ] ]; try discriminate Hok.
      apply andb_prop in Hok as [Hq Hcx].
      inversion Hc as [ | ? ? ? ? (_ & Cq) Hc1 ]; subst.
      inversion Hc1 as [ | ? ? ? ? (Cc & _) _ ]; subst.
      destruct (Cq Hq bq oq eq_refl) as (q0 & side & Hqs & Hq0 & Hsd0 & Hfs).
      eapply Mem.unchanged_on_implies; [ exact (UOq q0 side Hqs Hfs) | ].
      intros b0 z (Nf & V) _.
      split; [ left; intro E; subst b0; apply Nf; exists q0; split;
               [ exact (MtxfBody.mem_id_In _ _ Hq0) | exact Hfs ] | ].
      split.
      - destruct cell as [ | | | | | bk ok ]; cbn [cell_out]; try exact I.
        left. intro E; subst b0. exact (HB_notQ bk z (Cc Hcx bk ok eq_refl) (conj Nf V)).
      - destruct (side_fb side b0 Hsd0) as [F | N]; [ exfalso; exact (Nf F) | exact N ]. }
    destruct (Pos.eqb fid libultra_osSiCreateAccessQueue._osSendMesg) eqn:E2.
    { apply Pos.eqb_eq in E2. subst fid.
      destruct (floor_ext libultra_osSiCreateAccessQueue.prog libultra_osSiCreateAccessQueue._osSendMesg "osSendMesg" _ _ _ _ _ _ _
                  (linked12_LO_ultra_si lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hsd _ _ _ _ _ _ _ Hx') as (bq & oq & msg & f0 & -> & _ & UOq).
      destruct al as [ | aq [ | am [ | af [ | ] ] ] ]; try discriminate Hok.
      inversion Hc as [ | ? ? ? ? (_ & Cq) _ ]; subst.
      destruct (Cq Hok bq oq eq_refl) as (q0 & side & Hqs & Hq0 & Hsd0 & Hfs).
      eapply Mem.unchanged_on_implies; [ exact (UOq q0 side Hqs Hfs) | ].
      intros b0 z (Nf & V) _.
      split; [ left; intro E; subst b0; apply Nf; exists q0; split;
               [ exact (MtxfBody.mem_id_In _ _ Hq0) | exact Hfs ] | ].
      destruct (side_fb side b0 Hsd0) as [F | N]; [ exfalso; exact (Nf F) | exact N ]. }
    destruct (Pos.eqb fid libultra_osEepromWrite.___osSiRawStartDma) eqn:E4.
    { apply Pos.eqb_eq in E4. subst fid.
      destruct (floor_ext libultra_osEepromWrite.prog libultra_osEepromWrite.___osSiRawStartDma "__osSiRawStartDma" _ _ _ _ _ _ _
                  (linked12_LO_ultra_ew lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hsi _ _ _ _ _ _ _ Hx') as (dir & bp & op & -> & UOp & _ & _).
      destruct al as [ | ad [ | ap [ | ] ] ]; try discriminate Hok.
      inversion Hc as [ | ? ? ? ? _ Hc1 ]; subst.
      inversion Hc1 as [ | ? ? ? ? (Cp0 & _) _ ]; subst.
      eapply Mem.unchanged_on_implies; [ exact UOp | ].
      intros b0 z HQ _. left. intro E; subst b0. exact (HB_notQ bp z (Cp0 Hok bp op eq_refl) HQ). }
    discriminate Hok.
  Qed.

  Lemma int_call : forall lv fl qa c e le m optid fid fty al t le' m' out f fl' qa',
      Env lv e -> Pt fl qa le -> ctab_ok c ->
      SDB.find_ct fid c = Some (f, (fl', qa')) ->
      args_ok FP lv fl qa fl' qa' (fn_params f) al = true -> SDB.opt_ok fl qa optid = true ->
      mem_id fid lv = false -> access_mode fty = By_reference ->
      Ple (Mem.nextblock m0) (Mem.nextblock m) ->
      exec_stmt function_entry2 ge e le m (Scall optid (Evar fid fty) al) t le' m' out ->
      Mem.unchanged_on Q m m' /\ Pt fl qa le'.
  Proof.
    intros lv fl qa c e le m optid fid fty al t le' m' out f fl' qa'
           HE HP Hct Hfind Hargs Hopt Hnl Am Hnb Hx.
    pose proof HE as (Eh & En & Es).
    destruct (LptBody.scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ Hx (En fid Hnl) Am)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & _ & Hel & Hev & -> & _).
    split; [ | exact (opt_Pt fl qa optid vres le Hopt HP) ].
    destruct (Hct _ _ _ _ Hfind) as ((b' & Hs' & Hf') & Hfp).
    rewrite Hs in Hs'. injection Hs' as <-. rewrite Hf in Hf'. injection Hf' as ->.
    apply (Hfp _ _ _ _ _ Hev); [ | exact Hnb ].
    intros le0 Hb.
    exact (bind_cls fl' qa' _ _ _ _ Hb (args_cls lv fl qa fl' qa' e le m _ _ _ _ HE HP Hel Hargs)
             (undef_Pt fl' qa' _)).
  Qed.

  (* the walk's state: unchanged since the body's start, and past m0 *)
  Definition WI (mE m : mem) : Prop :=
    Mem.unchanged_on Q mE m /\ Ple (Mem.nextblock m0) (Mem.nextblock m).

  Lemma WI_step : forall mE m m', WI mE m -> Mem.unchanged_on Q m m' -> WI mE m'.
  Proof.
    intros mE m m' (U & N) U'. split; [ exact (Mem.unchanged_on_trans _ _ _ _ U U') | ].
    eapply Ple_trans; [ exact N | exact (Mem.unchanged_on_nextblock _ _ _ U') ].
  Qed.

  Lemma call_sound : forall lv fl qa c e le m optid a al t le' m' out mE,
      Env lv e -> Pt fl qa le -> ctab_ok c ->
      call_ok FP lv fl qa c optid a al = true ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      WI mE m -> WI mE m' /\ Pt fl qa le'.
  Proof.
    intros lv fl qa c e le m optid a al t le' m' out mE HE HP Hct Hok Hx Hw.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [call_ok] in Hok.
    apply andb_prop in Hok as [Hok Hd]. apply andb_prop in Hok as [Hnl Hopt].
    apply negb_true_iff in Hnl.
    destruct (SDB.find_ct fid c) as [[f [fl' qa']]|] eqn:Hfind.
    - destruct (int_call lv fl qa c e le m optid fid (Tfunction targs tres tcc) al t le' m' out f fl' qa'
               HE HP Hct Hfind Hd Hopt Hnl eq_refl (proj2 Hw) Hx) as (U & HP').
      exact (conj (WI_step mE m m' Hw U) HP').
    - destruct (floor_call lv fl qa e le m optid fid (Tfunction targs tres tcc) al t le' m' out
                  HE HP Hd Hopt Hnl eq_refl Hx) as (U & HP').
      exact (conj (WI_step mE m m' Hw U) HP').
  Qed.

  Lemma set_sound : forall lv fl qa e id a le m v,
      Env lv e -> set_ok FP lv fl qa id a = true -> Pt fl qa le ->
      eval_expr ge e le m a v -> Pt fl qa (PTree.set id v le).
  Proof.
    intros lv fl qa e id a le m v HE Hok HP Hev t w Hg.
    destruct (peq t id) as [-> | Hne].
    - rewrite PTree.gss in Hg. injection Hg as <-.
      apply andb_prop in Hok as [Hh Hq].
      split.
      + intros Hn. rewrite Hn in Hh. exact (proj1 (hx_sound lv fl qa e le m HE HP a) _ Hev Hh).
      + intros Hy. rewrite Hy in Hq. exact (hq_sound lv fl qa e le m HE HP a _ Hev Hq).
    - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
  Qed.

  Lemma assign_unch : forall ty m loc ofs bf v m',
      assign_loc ge ty m loc ofs bf v m' -> HB loc -> Mem.unchanged_on Q m m'.
  Proof.
    intros ty m loc ofs bf v m' Ha Hh.
    inv Ha.
    - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => cbn in Hs;
        eapply Mem.store_unchanged_on; [ exact Hs | ];
        intros i _; exact (HB_notQ loc i Hh) end.
    - match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
        eapply Mem.storebytes_unchanged_on; [ exact Hs | ];
        intros i _; exact (HB_notQ loc i Hh) end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => cbn in Hs;
        eapply Mem.store_unchanged_on; [ exact Hs | ];
        intros i _; exact (HB_notQ loc i Hh) end.
  Qed.

  Lemma store_sound : forall lv fl qa e lvx rhs le m t le' m' out mE,
      Env lv e -> store_ok FP lv fl lvx = true -> Pt fl qa le ->
      exec_stmt function_entry2 ge e le m (Sassign lvx rhs) t le' m' out ->
      WI mE m -> WI mE m'.
  Proof.
    intros lv fl qa e lvx rhs le m t le' m' out mE HE Hok HP Hx Hw.
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lvx ?loc _ _ |- _ =>
      pose proof (proj2 (hx_sound lv fl qa e _ m HE HP lvx) _ _ _ Hl Hok) as Hh end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      exact (WI_step mE m m' Hw (assign_unch _ _ _ _ _ _ _ Ha Hh)) end.
  Qed.

  (* ---- entry / exit ---- *)
  Lemma alloc_unch : forall e0 m vars e1 m1,
      alloc_variables ge e0 m vars e1 m1 -> Mem.unchanged_on Q m m1.
  Proof.
    intros e0 m vars e1 m1 Hav.
    induction Hav as [ | e0 m id ty vars0 m1 b1 m2 e2 Ha Hrest IH ]; [ apply Mem.unchanged_on_refl | ].
    eapply Mem.unchanged_on_trans; [ | exact IH ].
    exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Ha).
  Qed.

  Lemma entry_env : forall m vars e m1,
      alloc_variables ge empty_env m vars e m1 -> Ple (Mem.nextblock m0) (Mem.nextblock m) ->
      Env (map fst vars) e.
  Proof.
    intros m vars e m1 Hav Hnb.
    split; [ | split ].
    - intros x b ty He.
      destruct (LocalVarsSurface.alloc_variables_not_valid _ _ _ _ _ _ Hav _ _ _ He)
        as [(ty0 & H0) | Hnv].
      + rewrite PTree.gempty in H0. discriminate H0.
      + right. intros V. apply Hnv. unfold Mem.valid_block in *. eapply Plt_Ple_trans; eassumption.
    - intros x Hx.
      rewrite (LocalVarsSurface.alloc_variables_unbound _ _ _ _ _ _ Hav x
                 (MtxfBody.mem_id_notin _ _ Hx)).
      apply PTree.gempty.
    - intros x Hx.
      destruct (LocalVarsSurface.alloc_variables_in_bound _ _ _ _ _ _ Hav x
                  (MtxfBody.mem_id_In _ _ Hx)) as (b & ty & H).
      congruence.
  Qed.

  Lemma body_fpF : forall f fl qa c,
      body_chk FP f fl qa c = true -> ctab_ok c -> fpF f fl qa.
  Proof.
    intros f fl qa c Hchk Hct m vargs t m' vres Hev Hb Hnb.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with
    | Hav : alloc_variables _ _ _ _ ?E ?M1,
      Hbd : bind_parameter_temps _ _ _ = Some ?LE,
      Hbody : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _,
      Hfree : Mem.free_list ?M2 _ = Some _ |- _ =>
      pose proof (entry_env _ _ _ _ Hav Hnb) as HE;
      pose proof (alloc_unch _ _ _ _ _ Hav) as U1;
      assert (W1 : WI m M1) by
        (split; [ exact U1 | eapply Ple_trans; [ exact Hnb | exact (Mem.unchanged_on_nextblock _ _ _ U1) ] ]);
      destruct (SDB.hw_walk ge E (WI m) (Pt fl qa) (set_ok FP (map fst (fn_vars f)) fl qa)
                  (store_ok FP (map fst (fn_vars f)) fl) (call_ok FP (map fst (fn_vars f)) fl qa c)
                  (fun id a le0 m1 v Hok HP _ Hv => set_sound _ fl qa E id a le0 m1 v HE Hok HP Hv)
                  (fun lvx rhs le0 m1 t0 le0' m1' out0 Hok HP Hx Hf0 =>
                     store_sound _ fl qa E lvx rhs le0 m1 t0 le0' m1' out0 m HE Hok HP Hx Hf0)
                  (fun optid a al le0 m1 t0 le0' m1' out0 Hok HP Hx Hf0 =>
                     call_sound _ fl qa c E le0 m1 optid a al t0 le0' m1' out0 m HE HP Hct Hok Hx Hf0)
                  _ _ _ _ _ _ _ _ Hbody eq_refl Hchk (Hb _ Hbd) W1) as ((U2 & _) & _);
      eapply Mem.unchanged_on_trans; [ exact U2 | ];
      apply (PollFlank.free_env_unch ge E M2 _ Q Hfree);
      intros id b ty Hid z; exact (HB_notQ b z (proj1 HE id b ty Hid))
    end.
  Qed.
End FW.
