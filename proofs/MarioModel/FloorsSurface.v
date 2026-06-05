(* ====================================================================== *)
(* THE SPECIAL-FLOORS SURFACE: Hpres_floors DISCHARGED DOWN TO ITS LEAF   *)
(* CALLEES (SPINE: consumed by the MWF-grounded capstone).                *)
(*                                                                        *)
(* f_mario_handle_special_floors contains NO store at all: it reads       *)
(* m->action / m->floor / floor->type, branches, and calls five leaves    *)
(* (check_death_barrier / pss_begin_slide / pss_end_slide /               *)
(* check_lava_boost in interaction.prog, level_trigger_warp in            *)
(* level_update.prog -- the SAME body the capstone already carries as     *)
(* Hpres_warp, so that leaf is SHARED, not a new residual).               *)
(*                                                                        *)
(* The discharge introduces the generic WALKER (walk_chk / walk_pres):    *)
(* an induction over the exec derivation covering Sskip/Sbreak/Scontinue/ *)
(* Sreturn-None/Sset(non-_m)/window-Sassign/censused 1-2-arg Mario calls/ *)
(* Ssequence/Sifthenelse/Sswitch-on-anything.  ONE vm_compute body pin    *)
(* replaces all per-fragment shape pins.  Reusable for the remaining      *)
(* store-free-or-window-only real bodies (per-leaf act handlers).         *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_airborne interaction level_update.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit.

Import ListNotations.

(* ====================================================================== *)
(* The generic walker recognizer (top-level: no lp).                      *)
(* ====================================================================== *)

Definition opt_ne_m (optid : option ident) : bool :=
  match optid with
  | Some t => negb (Pos.eqb t mario_actions_airborne._m)
  | None => true
  end.

Fixpoint walk_chk (ids : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn None => true
  | Sset id _ => negb (Pos.eqb id mario_actions_airborne._m)
  | Sassign a1 _ => safe_mfield_store mario_actions_airborne._m a1
  | Scall optid a al =>
      match a with
      | Evar fid fty =>
          opt_ne_m optid
          && match fty, al with
             | Tfunction (ty1 :: nil) rty cc,
               Etempvar p pty :: nil =>
                 Pos.eqb p mario_actions_airborne._m
                 && mem_id fid ids
                 && proj_sumbool (type_eq ty1 tyMSp)
                 && proj_sumbool (type_eq pty tyMSp)
             | Tfunction (ty1 :: ty2 :: nil) rty cc,
               Etempvar p pty :: a2 :: nil =>
                 Pos.eqb p mario_actions_airborne._m
                 && mem_id fid ids
                 && proj_sumbool (type_eq ty1 tyMSp)
                 && proj_sumbool (type_eq pty tyMSp)
             | _, _ => false
             end
      | _ => false
      end
  | Ssequence s1 s2 => walk_chk ids s1 && walk_chk ids s2
  | Sifthenelse _ s1 s2 => walk_chk ids s1 && walk_chk ids s2
  | Sswitch _ sl => walk_chk_ls ids sl
  | _ => false
  end
with walk_chk_ls (ids : list ident) (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => walk_chk ids s && walk_chk_ls ids sl'
  end.

(* ---- the switch-selection transfer: every suffix checked => the
   selected suffix's sequence checked. ---- *)

Lemma walk_chk_ls_seq : forall ids sl,
    walk_chk_ls ids sl = true ->
    walk_chk ids (seq_of_labeled_statement sl) = true.
Proof.
  intros ids sl; induction sl as [| o s sl0 IH]; intros H.
  - reflexivity.
  - cbn in H. apply andb_prop in H as [H1 H2].
    cbn. rewrite H1. cbn. exact (IH H2).
Qed.

Lemma walk_chk_ls_case : forall ids n sl sl',
    walk_chk_ls ids sl = true ->
    select_switch_case n sl = Some sl' ->
    walk_chk_ls ids sl' = true.
Proof.
  intros ids n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
  - discriminate Hsel.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    + destruct (zeq c n).
      * injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      * exact (IH sl' H2 Hsel).
    + exact (IH sl' H2 Hsel).
Qed.

Lemma walk_chk_ls_default : forall ids sl,
    walk_chk_ls ids sl = true ->
    walk_chk_ls ids (select_switch_default sl) = true.
Proof.
  intros ids sl; induction sl as [| o s sl0 IH]; intros H.
  - exact H.
  - cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn.
    + exact (IH H2).
    + rewrite H1, H2. reflexivity.
Qed.

Lemma walk_chk_select : forall ids n sl,
    walk_chk_ls ids sl = true ->
    walk_chk ids (seq_of_labeled_statement (select_switch n sl)) = true.
Proof.
  intros ids n sl H. apply walk_chk_ls_seq.
  unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (walk_chk_ls_case _ _ _ _ H E).
  - exact (walk_chk_ls_default _ _ H).
Qed.

(* ====================================================================== *)
(* The special-floors censuses.                                           *)
(* ====================================================================== *)

(* the four leaves defined by interaction.prog itself *)
Definition floors_int_ids : list ident :=
  interaction._check_death_barrier ::
  interaction._pss_begin_slide ::
  interaction._pss_end_slide ::
  interaction._check_lava_boost :: nil.

(* + the warp trigger (level_update.prog; the capstone's Hpres_warp body) *)
Definition floors_callee_ids : list ident :=
  level_update._level_trigger_warp :: floors_int_ids.

(* THE BODY PIN: the whole 125-line body passes the walker recognizer. *)
Example floors_body_ok :
  walk_chk floors_callee_ids
    (fn_body interaction.f_mario_handle_special_floors) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: with an empty census the body FAILS the recognizer
   (the call sites are real obligations, not vacuously passed). *)
Example floors_body_census_not_vacuous :
  walk_chk nil (fn_body interaction.f_mario_handle_special_floors) = false.
Proof. vm_compute. reflexivity. Qed.

(* the four interaction leaves are Internal in interaction.prog *)
Example floors_int_internal :
  forallb (internal_in (prog_defmap interaction.prog)) floors_int_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* the warp trigger resolves to THE real level_update body *)
Example floors_warp_internal :
  (prog_defmap level_update.prog) ! level_update._level_trigger_warp
  = Some (Gfun (Internal level_update.f_level_trigger_warp)).
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section FloorsSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_lvl : linkorder level_update.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  (* THE RESIDUAL: the four interaction leaves, keyed by the census. *)
  Hypothesis Hpres_callees : forall fid f,
      mem_id fid floors_int_ids = true ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  (* the warp leaf is the capstone's EXISTING Hpres_warp body: shared. *)
  Hypothesis Hpres_warp : body_pres lp NoA MWF bm
      level_update.f_level_trigger_warp.

  Lemma floors_call_pres :
    forall fid, mem_id fid floors_callee_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid Hmem.
    unfold floors_callee_ids in Hmem. cbn [mem_id existsb] in Hmem.
    apply orb_true_iff in Hmem as [Hw | Hrest].
    - apply Pos.eqb_eq in Hw. subst fid.
      exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
               level_update.prog level_update._level_trigger_warp
               level_update.f_level_trigger_warp
               LO_lvl floors_warp_internal Hpres_warp).
    - exact (call_pres_of_census lp bm NoA MWF HNoA_of_MWF
               interaction.prog floors_int_ids LO_int
               floors_int_internal Hpres_callees fid Hrest).
  Qed.

  (* ================================================================== *)
  (* THE GENERIC WALKER: any walk_chk-passing statement preserves the   *)
  (* carried run facts and the _m provenance, whatever its outcome.     *)
  (* (Induction over the EXEC DERIVATION: the switch case needs the IH  *)
  (* on the selected suffix, which statement induction cannot supply.)  *)
  (* ================================================================== *)
  Lemma walk_pres :
    forall (ids : list ident),
      (forall fid, mem_id fid ids = true -> call_pres lp bm NoA MWF fid) ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        e = empty_env ->
        walk_chk ids s = true ->
        (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
        action_sat not_tainted m0 bm ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
        NoA m' /\
        (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero).
  Proof.
    intros ids Hcp s e le m0 tr le' m' out Hexec.
    induction Hexec; intros He Hchk Htat HN HM HV HS.
    - (* Sskip *) exact (conj HV (conj HS (conj HM (conj HN Htat)))).
    - (* Sassign: the window-store brick *)
      cbn [walk_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                  a1 a2 _ _ _ _ _ _ _ Hchk Htat Hex HM HV HS)
        as (HV' & HS' & HM' & _ & _).
      exact (conj HV' (conj HS' (conj HM'
               (conj (HNoA_of_MWF _ HM') Htat)))).
    - (* Sset: memory unchanged; gso on the non-_m temp *)
      cbn [walk_chk] in Hchk.
      refine (conj HV (conj HS (conj HM (conj HN _)))).
      intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; rewrite <- EE in Hchk; cbn in Hchk;
            discriminate Hchk).
      exact (Htat _ _ Hg).
    - (* Scall: the censused Mario-arg call sites *)
      subst e.
      destruct a as [ ci cty | cf cty | cs cty | cl cty | cid fty | tv tvy
                    | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                    | f1 f2 f3 | s1' s2' | g1 g2 ];
        try discriminate Hchk.
      cbn [walk_chk] in Hchk.
      apply andb_prop in Hchk as [Hopt Hchk].
      destruct fty as [ | i1 i2 i3 | l1' l2' | r1 r2 | p1 p2 | ar1 ar2 ar3
                      | params res cc | st1 st2 | un1 un2 ];
        try discriminate Hchk.
      destruct params as [| ty1 l1]; try discriminate Hchk.
      destruct l1 as [| ty2 l2].
      + (* 1-arg site *)
        destruct al as [| a1 al1]; try discriminate Hchk.
        destruct a1 as [ xa xb | xa xb | xa xb | xa xb | xa xb | p pty
                       | xa xb | xa xb | xa xb xc | xa xb xc xd | xa xb
                       | xa xb xc | xa xb | xa xb ];
          try discriminate Hchk.
        destruct al1; try discriminate Hchk.
        cbn [walk_chk] in Hchk.
        apply andb_prop in Hchk as [Hchk Hpty].
        apply andb_prop in Hchk as [Hchk Hty1].
        apply andb_prop in Hchk as [Hp Hfid].
        apply Pos.eqb_eq in Hp. subst p.
        destruct (type_eq ty1 tyMSp); [ subst ty1 | discriminate Hty1 ].
        destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                        (Scall optid
                           (Evar cid (Tfunction (tyMSp :: nil) res cc))
                           (Etempvar mario_actions_airborne._m tyMSp :: nil))
                        t (set_opttemp optid vres le) m' Out_normal)
          by (econstructor; eauto).
        destruct (kit_scall_pres lp bm NoA MWF
                    _ _ _ _ _ _ _ _ _ _ Hex (Hcp _ Hfid) Htat HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        refine (conj HV' (conj HS' (conj HM' (conj HN' _)))).
        intros b o Hg.
        destruct optid as [t'|]; cbn [set_opttemp] in Hg.
        * rewrite PTree.gso in Hg
            by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                discriminate Hopt).
          exact (Htat _ _ Hg).
        * exact (Htat _ _ Hg).
      + (* 2-arg site *)
        destruct l2; try discriminate Hchk.
        destruct al as [| a1 al1]; try discriminate Hchk.
        destruct a1 as [ xa xb | xa xb | xa xb | xa xb | xa xb | p pty
                       | xa xb | xa xb | xa xb xc | xa xb xc xd | xa xb
                       | xa xb xc | xa xb | xa xb ];
          try discriminate Hchk.
        destruct al1 as [| a2 al2]; try discriminate Hchk.
        destruct al2; try discriminate Hchk.
        cbn [walk_chk] in Hchk.
        apply andb_prop in Hchk as [Hchk Hpty].
        apply andb_prop in Hchk as [Hchk Hty1].
        apply andb_prop in Hchk as [Hp Hfid].
        apply Pos.eqb_eq in Hp. subst p.
        destruct (type_eq ty1 tyMSp); [ subst ty1 | discriminate Hty1 ].
        destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                        (Scall optid
                           (Evar cid (Tfunction (tyMSp :: ty2 :: nil) res cc))
                           (Etempvar mario_actions_airborne._m tyMSp
                              :: a2 :: nil))
                        t (set_opttemp optid vres le) m' Out_normal)
          by (econstructor; eauto).
        destruct (kit_scall2_pres lp bm NoA MWF
                    _ _ _ _ _ _ _ _ _ _ _ _ Hex (Hcp _ Hfid) Htat HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        refine (conj HV' (conj HS' (conj HM' (conj HN' _)))).
        intros b o Hg.
        destruct optid as [t'|]; cbn [set_opttemp] in Hg.
        * rewrite PTree.gso in Hg
            by (intro EE; rewrite <- EE in Hopt; cbn in Hopt;
                discriminate Hopt).
          exact (Htat _ _ Hg).
        * exact (Htat _ _ Hg).
    - (* Sbuiltin: excluded by the recognizer *)
      cbn [walk_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [walk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Htat HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1).
      exact (IHHexec2 He H2 Htat1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [walk_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec He H1 Htat HN HM HV HS).
    - (* Sifthenelse *)
      cbn [walk_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN Htat)))).
    - (* Sreturn (Some _): excluded *) cbn [walk_chk] in Hchk. discriminate Hchk.
    - (* Sbreak *) exact (conj HV (conj HS (conj HM (conj HN Htat)))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN Htat)))).
    - (* Sloop stop1: excluded *) cbn [walk_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: excluded *) cbn [walk_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: excluded *) cbn [walk_chk] in Hchk. discriminate Hchk.
    - (* Sswitch *)
      cbn [walk_chk] in Hchk.
      apply IHHexec; try assumption.
      exact (walk_chk_select _ n _ Hchk).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_floors itself, PROVED from the per-leaf          *)
  (* residuals + the SHARED warp residual.                              *)
  (* ================================================================== *)
  Theorem floors_pres :
    body_pres lp NoA MWF bm interaction.f_mario_handle_special_floors.
  Proof.
    intros m vargs t m' vres Hmargp Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs).
    { apply Hmargp. vm_compute. reflexivity. }
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars interaction.f_mario_handle_special_floors)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params interaction.f_mario_handle_special_floors)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps interaction.f_mario_handle_special_floors))
      in *.
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    destruct (walk_pres floors_callee_ids floors_call_pres
                _ _ _ _ _ _ _ _ Hbody eq_refl floors_body_ok
                Htat0 HN HM HV HS)
      as (HV' & HS' & HM' & _ & _).
    repeat split; assumption.
  Qed.

End FloorsSurface.
