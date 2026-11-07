(* ====================================================================== *)
(* DebugKeep (GOAL 2): the real debug calls of update_objects keep the    *)
(* object phase's invariant (ClearKeep.Pc), 2026-11-07.                   *)
(*                                                                        *)
(* The walk of generated/debug.v:                                         *)
(*   reset_debug_objectinfo   six int stores into debug counters, two     *)
(*                            set_print_state_info calls (six s16 stores  *)
(*                            into gDebugPrintState1 / 2), and           *)
(*                            update_debug_dpadmask (int stores into     *)
(*                            sDebugInfoDPadUpdID / sDebugInfoDPadMask);  *)
(*   stub_debug_5             the empty body;                             *)
(*   try_print_debug_mario_object_info  no store: sDebugPage is 0 (the    *)
(*                            page switch takes its default), and every   *)
(*                            print helper it calls tests                 *)
(*                            gDebugInfoFlags & DEBUG_INFO_FLAG_DPRINT,   *)
(*                            which is clear.                             *)
(* The two pins are ObjWorld.ow_debug (obj_w, start-checked by ow_chk on  *)
(* the boot witness).  dlsc_keeps: the only generated store of            *)
(* gDebugInfoFlags (debug_unknown_level_select_check, from clear_objects) *)
(* keeps its bit 0 clear.                                                  *)
(* PHANTOM CHECK: the only premise is Pc.                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require debug object_list_processor level_update mario.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjLoop ObjPhase ClearKeep CollWalk.
From SM64.Proofs Require Generic.GlobalSeparation.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module DB := debug.
Module OLP := object_list_processor.

(* ---------------------------------------------------------------------- *)
(* 1. Generic facts.                                                       *)
(* ---------------------------------------------------------------------- *)
Lemma cast_short : forall v t m v', sem_cast v t tshort m = Some v' -> t = tint \/ t = tshort ->
  exists i, v' = Vint i.
Proof.
  intros v t m v' H Ht. destruct Ht as [-> | ->]; destruct v; cbn in H; try discriminate H;
    injection H as <-; eauto.
Qed.

Lemma cast_c : forall i ty m v, sem_cast (Vint i) tint ty m = Some v ->
  ty = tint \/ ty = tuint \/ ty = tshort \/ ty = tschar -> exists j, v = Vint j.
Proof.
  intros i ty m v H Ht. destruct Ht as [-> | [-> | [-> | ->]]]; cbn in H; injection H as <-; eauto.
Qed.

Lemma oand_int : forall (ge : genv) m v1 v2 v, sem_binary_operation ge Oand v1 tushort v2 tint m = Some v ->
  exists i, v = Vint i.
Proof.
  intros ge m v1 v2 v H. destruct v1, v2; cbn in H; try discriminate H; injection H as <-; eauto.
Qed.

Lemma op_shl_c : forall (ge : genv) m a b, Int.ltu b Int.iwordsize = true ->
  sem_binary_operation ge Oshl (Vint a) tint (Vint b) tint m = Some (Vint (Int.shl a b)).
Proof. intros ge m a b H. unfold sem_binary_operation, sem_shift. cbn. rewrite H. reflexivity. Qed.

Lemma op_shl_v : forall (ge : genv) m a b v,
  sem_binary_operation ge Oshl (Vint a) tint (Vint b) tint m = Some v ->
  Int.ltu b Int.iwordsize = true -> v = Vint (Int.shl a b).
Proof. intros ge m a b v H Hl. rewrite (op_shl_c ge m a b Hl) in H. injection H as <-. reflexivity. Qed.

(* the value assign_loc stores, by value *)
Lemma sbv : forall (ge : genv) ty m b o bf v m', assign_loc ge ty m b o bf v m' -> bf = Full ->
  forall ch, access_mode ty = By_value ch -> Mem.store ch m b (Ptrofs.unsigned o) v = Some m'.
Proof. intros ge ty m b o bf v m' H Hb ch Ha. exact (store_by_value ge ty m b o bf v m' ch Ha Hb H). Qed.

(* e->f, e a global struct *)
Lemma lv_gfld : forall (ge : genv) le m id S f ty b o bf,
  eval_lvalue ge empty_env le m (Efield (Evar id (Tstruct S noattr)) f ty) b o bf ->
  Genv.find_symbol ge id = Some b.
Proof.
  intros ge le m id S f ty b o bf H.
  inversion H; subst; cbn [typeof] in *; try discriminate.
  all: match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inversion He; subst end.
  all: match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inversion Hl; subst end.
  all: try (match goal with Hn : empty_env ! _ = Some _ |- _ => rewrite PTree.gempty in Hn; discriminate Hn end).
  all: match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inversion Hd; subst end.
  all: try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end).
  all: assumption.
Qed.

(* *(p + k), p a temp *)
Lemma lv_ps : forall (ge : genv) le m x k b o bf b0 o0,
  eval_lvalue ge empty_env le m
    (Ederef (Ebinop Oadd (Etempvar x (tptr tshort)) (Econst_int k tint) (tptr tshort)) tshort) b o bf ->
  le ! x = Some (Vptr b0 o0) -> b = b0 /\ bf = Full.
Proof.
  intros ge le m x k b o bf b0 o0 H Hx. inversion H; subst.
  match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in He; destruct He as (v1 & v2 & E1 & E2 & Hop) end.
  apply ev_temp in E1. apply ev_const in E2. subst v2. rewrite Hx in E1. injection E1 as <-.
  cbn in Hop. injection Hop; intros; subst. auto.
Qed.

Lemma sw_inv : forall (ge : genv) e le m a sl t le' m' out,
  exec_stmt function_entry2 ge e le m (Sswitch a sl) t le' m' out ->
  exists v n out1, eval_expr ge e le m a v /\ sem_switch_arg v (typeof a) = Some n /\
    exec_stmt function_entry2 ge e le m (seq_of_labeled_statement (select_switch n sl)) t le' m' out1 /\
    out = outcome_switch out1.
Proof. intros. inv H. eauto 10. Qed.

(* the DPRINT test of the print helpers: if (gDebugInfoFlags & (1 << 0)) *)
Lemma flag_test : forall (ge : genv) le m x n v b,
  le ! x = Some (Vint n) -> Int.and n Int.one = Int.zero ->
  eval_expr ge empty_env le m
    (Ebinop Oand (Etempvar x tint)
       (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 0) tint) tint) tint) v ->
  bool_val v tint m = Some b -> b = false.
Proof.
  intros ge le m x n v b Hx Hn E Hb.
  apply ev_binop in E as (v1 & v2 & E1 & E2 & Hop).
  apply ev_temp in E1. rewrite Hx in E1. injection E1 as <-.
  apply ev_binop in E2 as (w1 & w2 & F1 & F2 & Hop2).
  apply ev_const in F1. apply ev_const in F2. subst w1 w2. cbn [typeof] in Hop, Hop2.
  apply op_shl_v in Hop2; [ subst v2 | reflexivity ].
  rewrite op_and in Hop. injection Hop as <-.
  assert (E1 : Int.shl (Int.repr 1) (Int.repr 0) = Int.one) by reflexivity.
  rewrite E1, Hn in Hb.
  assert (B : bool_val (Vint Int.zero) tint m = Some false) by reflexivity.
  rewrite B in Hb. injection Hb as <-. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The walks.                                                           *)
(* ---------------------------------------------------------------------- *)
Section DK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  Lemma fun_db : forall id f, (prog_defmap DB.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b -> Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f Hdm. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_debug lp H12) Hdm). Qed.

  Lemma dm_reset : (prog_defmap DB.prog) ! DB._reset_debug_objectinfo
                   = Some (Gfun (Internal DB.f_reset_debug_objectinfo)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_sps : (prog_defmap DB.prog) ! DB._set_print_state_info
                 = Some (Gfun (Internal DB.f_set_print_state_info)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_dpad : (prog_defmap DB.prog) ! DB._update_debug_dpadmask
                  = Some (Gfun (Internal DB.f_update_debug_dpadmask)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_stub5 : (prog_defmap DB.prog) ! DB._stub_debug_5 = Some (Gfun (Internal DB.f_stub_debug_5)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_tp : (prog_defmap DB.prog) ! DB._try_print_debug_mario_object_info
                = Some (Gfun (Internal DB.f_try_print_debug_mario_object_info)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_map : (prog_defmap DB.prog) ! DB._print_debug_top_down_mapinfo
                 = Some (Gfun (Internal DB.f_print_debug_top_down_mapinfo)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_bot : (prog_defmap DB.prog) ! DB._print_debug_bottom_up
                 = Some (Gfun (Internal DB.f_print_debug_bottom_up)).
  Proof. vm_compute. reflexivity. Qed.

  (* f(args), f a debug.c function *)
  Lemma callk : forall le m fid f tys al t le' m' out,
    (prog_defmap DB.prog) ! fid = Some (Gfun (Internal f)) ->
    exec_stmt function_entry2 G empty_env le m (Scall None (Evar fid (Tfunction tys tvoid cc_default)) al)
      t le' m' out ->
    exists vargs t' vr, eval_exprlist G empty_env le m al tys vargs
      /\ eval_funcall function_entry2 G m (Internal f) vargs t' m' vr.
  Proof.
    intros le m fid f tys al t le' m' out Hdm H.
    apply call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & _ & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (CollWalk.evf G m le _ _ vf Evf eq_refl) as (bf & Hsy & ->).
    rewrite (fun_db _ _ Hdm bf fd Hsy Hff) in Hcall.
    exists vargs, t, vres. exact (conj Eal Hcall).
  Qed.

  (* a store of an int into a global no clause reads *)
  Ltac gkeep Hs St HP :=
    let HP1 := fresh "HP" in
    pose proof (ClearKeep.gstore_keep lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 _ _ _ _ _ _ _ Hs
                  ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
                  St HP) as HP1;
    clear HP; rename HP1 into HP.

  (* g = <int expression>, g a global int: a constant, a temp holding an
     int, or temp + constant *)
  Ltac gasg H HP :=
    let b := fresh "b" in let o := fresh "o" in let bf := fresh "bf" in
    let v2 := fresh "v2" in let v := fresh "v" in let Hl := fresh "Hl" in
    let Ev := fresh "Ev" in let Hc := fresh "Hc" in let Ha := fresh "Ha" in
    let Hs := fresh "Hs" in let j := fresh "j" in let St := fresh "St" in let Hv := fresh "Hv" in
    apply assign_inv in H; destruct H as (b & o & bf & v2 & v & Hl & Ev & Hc & Ha & -> & _);
    apply lv_gvar in Hl; [ | apply PTree.gempty ]; destruct Hl as (Hs & -> & ->);
    cbn [typeof] in Hc, Ha;
    assert (Hv : exists j, v = Vint j)
      by first
         [ apply ev_const in Ev; subst v2; exact (cast_c _ _ _ _ Hc ltac:(auto))
         | apply ev_temp in Ev; getnorm Ev; injection Ev as <-; apply cast_tint_id in Hc; subst v; eauto
         | let E2 := fresh "E2" in let Hop := fresh "Hop" in
           apply ev_binop in Ev; destruct Ev as (? & ? & _ & E2 & Hop); apply ev_const in E2; rewrite E2 in Hop;
           cbn [typeof] in Hop; destruct (op_int _ _ _ _ _ _ (or_introl eq_refl) Hop) as (j & ->);
           apply cast_tint_id in Hc; subst v; eauto ];
    destruct Hv as (j & ->);
    pose proof (sbv _ _ _ _ _ _ _ _ Ha eq_refl _ eq_refl) as St;
    gkeep Hs St HP.

  (* the walk: sequences, sets, skips, ifs (both branches), stores *)
  Ltac wk H HP :=
    lazymatch type of H with
    | exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
        let H1 := fresh "H" in let H2 := fresh "H" in let Hn := fresh "Hn" in
        apply seq_inv in H; destruct H as [(? & ? & ? & ? & H1 & H2) | (H1 & Hn)];
        [ wk H1 HP; wk H2 HP | wk H1 HP ]
    | exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
        let v := fresh "v" in let Ev := fresh "Ev" in
        apply set_inv in H; destruct H as (v & Ev & -> & -> & _)
    | exec_stmt _ _ _ _ _ Sskip _ _ _ _ =>
        apply skip_inv in H; destruct H as (-> & -> & _)
    | exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
        let c := fresh "c" in
        apply if_inv in H; destruct H as (? & c & ? & ? & H); destruct c; cbv beta iota in H; wk H HP
    | exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ => gasg H HP
    end.

  (* ---- update_debug_dpadmask ---- *)
  Lemma dpad_ok : forall m vargs t m' vr,
    eval_funcall function_entry2 G m (Internal DB.f_update_debug_dpadmask) vargs t m' vr -> Pc m -> Pc m'.
  Proof.
    intros m vargs t m' vr Hev HP.
    destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
    unfold DB.f_update_debug_dpadmask in H; cbn [fn_body] in H.
    (* the mask: dPadMask = buttonDown & 0xF00, an int *)
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H) | (H1 & Hn)].
    2: { rewrite (CollWalk.pure_mem _ _ _ _ _ _ _ _ _ H1 eq_refl). exact HP. }
    apply seq_inv in H1 as [(ta & lea & ma & tb & Ha & Hb) | (Ha & Hn)].
    2: { apply set_inv in Ha as (_ & _ & _ & _ & E). exfalso. exact (Hn E). }
    apply set_inv in Ha as (va & _ & -> & -> & _).
    apply seq_inv in Hb as [(tc & lec & mc & td & Hc & Hd) | (Hc & Hn)].
    2: { apply set_inv in Hc as (_ & _ & _ & _ & E). exfalso. exact (Hn E). }
    apply set_inv in Hc as (vb & _ & -> & -> & _).
    apply set_inv in Hd as (vc & Ec & -> & -> & _).
    apply ev_binop in Ec as (x1 & x2 & _ & _ & Hop). cbn [typeof] in Hop.
    destruct (oand_int _ _ _ _ _ Hop) as (d & ->). clear Hop.
    wk H HP.
    all: exact HP.
  Qed.

  (* ---- set_print_state_info(&gDebugPrintStateN, ...) ---- *)
  Ltac ps_asg H HP K Hx :=
    let b := fresh "b" in let o := fresh "o" in let bf := fresh "bf" in
    let v2 := fresh "v2" in let v := fresh "v" in let Hl := fresh "Hl" in
    let Hc := fresh "Hc" in let Ha := fresh "Ha" in let i := fresh "i" in let St := fresh "St" in
    let HP1 := fresh "HP" in
    apply assign_inv in H; destruct H as (b & o & bf & v2 & v & Hl & _ & Hc & Ha & -> & _);
    destruct (lv_ps _ _ _ _ _ _ _ _ _ _ Hl Hx) as (-> & ->);
    cbn [typeof] in Hc, Ha;
    destruct (cast_short _ _ _ _ Hc ltac:(auto)) as (i & ->);
    pose proof (sbv _ _ _ _ _ _ _ _ Ha eq_refl _ eq_refl) as St;
    pose proof (K _ _ _ _ _ St HP) as HP1; clear HP; rename HP1 into HP.
  Ltac ps_seq H HP K Hx :=
    let H1 := fresh "H" in let Hn := fresh "Hn" in
    apply seq_inv in H; destruct H as [(? & ? & ? & ? & H1 & H) | (H1 & Hn)];
    [ ps_asg H1 HP K Hx
    | exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ H1 ltac:(vm_compute; reflexivity))) ].

  Lemma sps_ok : forall id bg m rest t m' vr,
    In id [DB._gDebugPrintState1; DB._gDebugPrintState2] -> Genv.find_symbol G id = Some bg ->
    eval_funcall function_entry2 G m (Internal DB.f_set_print_state_info) (Vptr bg Ptrofs.zero :: rest) t m' vr ->
    Pc m -> Pc m'.
  Proof.
    intros id bg m rest t m' vr Hin Hs Hev HP.
    assert (K : forall ch z i m1 m2, Mem.store ch m1 bg z (Vint i) = Some m2 -> Pc m1 -> Pc m2).
    { intros ch z i m1 m2 St P1.
      destruct Hin as [<- | [<- | []]]; gkeep Hs St P1; exact P1. }
    destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    assert (Hx : le ! DB._printState = Some (Vptr bg Ptrofs.zero)).
    { destruct rest as [| a1 [| a2 [| a3 [| a4 [| a5 [| a6 r]]]]]]; cbn in Hbd; try discriminate Hbd.
      injection Hbd as <-. reflexivity. }
    clear Hbd. unfold DB.f_set_print_state_info in H; cbn [fn_body] in H.
    ps_seq H HP K Hx. ps_seq H HP K Hx. ps_seq H HP K Hx. ps_seq H HP K Hx. ps_seq H HP K Hx.
    ps_asg H HP K Hx. exact HP.
  Qed.

  (* the call: its first argument is &gDebugPrintStateN *)
  Lemma sps_call : forall id le m al t le' m' out,
    In id [DB._gDebugPrintState1; DB._gDebugPrintState2] ->
    exec_stmt function_entry2 G empty_env le m
      (Scall None (Evar DB._set_print_state_info
                     (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: tshort :: tshort :: nil) tvoid
                        cc_default))
         (Evar id (tarray tshort 6) :: al)) t le' m' out ->
    Pc m -> Pc m'.
  Proof.
    intros id le m al t le' m' out Hin H HP.
    destruct (callk _ _ _ _ _ _ _ _ _ _ dm_sps H) as (vargs & t' & vr & Eal & Hcall).
    inversion Eal as [ | a bl ty tyl v1 v2 vl He Hc Hrest E1 E2 E3 ]. rewrite <- E3 in Hcall.
    destruct (CollWalk.evf G m le _ _ _ He eq_refl) as (bg & Hs & ->).
    cbn in Hc. injection Hc as <-.
    exact (sps_ok id bg m _ _ _ _ Hin Hs Hcall HP).
  Qed.

  (* ---- reset_debug_objectinfo ---- *)
  Ltac rs_seq H HP :=
    let H1 := fresh "H" in let Hn := fresh "Hn" in
    apply seq_inv in H; destruct H as [(? & ? & ? & ? & H1 & H) | (H1 & Hn)];
    [ gasg H1 HP
    | exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ H1 ltac:(vm_compute; reflexivity))) ].

  Lemma reset_ok : forall m vargs t m' vr,
    eval_funcall function_entry2 G m (Internal DB.f_reset_debug_objectinfo) vargs t m' vr -> Pc m -> Pc m'.
  Proof.
    intros m vargs t m' vr Hev HP.
    destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
    unfold DB.f_reset_debug_objectinfo in H; cbn [fn_body] in H.
    rs_seq H HP. rs_seq H HP. rs_seq H HP. rs_seq H HP. rs_seq H HP. rs_seq H HP.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H) | (H1 & Hn)].
    2: { exact (sps_call _ _ _ _ _ _ _ _ (or_introl eq_refl) H1 HP). }
    pose proof (sps_call _ _ _ _ _ _ _ _ (or_introl eq_refl) H1 HP) as HP1. clear HP H1.
    apply seq_inv in H as [(t3 & le2 & m2 & t4 & H1 & H) | (H1 & Hn)].
    2: { exact (sps_call _ _ _ _ _ _ _ _ (or_intror (or_introl eq_refl)) H1 HP1). }
    pose proof (sps_call _ _ _ _ _ _ _ _ (or_intror (or_introl eq_refl)) H1 HP1) as HP2. clear HP1 H1.
    destruct (callk _ _ _ _ _ _ _ _ _ _ dm_dpad H) as (vargs' & t5 & vr' & _ & Hcall).
    exact (dpad_ok _ _ _ _ _ Hcall HP2).
  Qed.

  (* ---- the print helpers, under the flag pin: no store ---- *)
  Lemma mapinfo_id : forall m vargs t m' vr, OW.dflags_ok G m ->
    eval_funcall function_entry2 G m (Internal DB.f_print_debug_top_down_mapinfo) vargs t m' vr -> m' = m.
  Proof.
    intros m vargs t m' vr D Hev.
    destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
    unfold DB.f_print_debug_top_down_mapinfo in H; cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H) | (H1 & _)].
    2: { exact (CollWalk.pure_mem _ _ _ _ _ _ _ _ _ H1 eq_refl). }
    rewrite (CollWalk.pure_mem _ _ _ _ _ _ _ _ _ H1 eq_refl) in H. clear H1.
    apply seq_inv in H as [(t3 & le2 & m2 & t4 & H1 & H) | (H1 & Hn)].
    2: { apply set_inv in H1 as (_ & _ & _ & _ & E). exfalso. exact (Hn E). }
    apply set_inv in H1 as (v & Ev & -> & -> & _).
    destruct (CollWalk.evg G m le1 _ _ _ _ Ev eq_refl) as (bf & Hs & Hl).
    destruct (D bf Hs) as (n & Ln & Hn). cbn [Mem.loadv] in Hl.
    rewrite Ptrofs.unsigned_zero, Ln in Hl. injection Hl as <-.
    apply if_inv in H as (vt & c & Et & Hb & H).
    rewrite (flag_test _ _ _ _ _ _ _ (PTree.gss _ _ _) Hn Et Hb) in H.
    apply skip_inv in H as (-> & _). reflexivity.
  Qed.

  Lemma bottom_id : forall m vargs t m' vr, OW.dflags_ok G m ->
    eval_funcall function_entry2 G m (Internal DB.f_print_debug_bottom_up) vargs t m' vr -> m' = m.
  Proof.
    intros m vargs t m' vr D Hev.
    destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
    unfold DB.f_print_debug_bottom_up in H; cbn [fn_body] in H.
    apply seq_inv in H as [(t3 & le2 & m2 & t4 & H1 & H) | (H1 & Hn)].
    2: { apply set_inv in H1 as (_ & _ & _ & _ & E). exfalso. exact (Hn E). }
    apply set_inv in H1 as (v & Ev & -> & -> & _).
    destruct (CollWalk.evg G m le _ _ _ _ Ev eq_refl) as (bf & Hs & Hl).
    destruct (D bf Hs) as (n & Ln & Hn). cbn [Mem.loadv] in Hl.
    rewrite Ptrofs.unsigned_zero, Ln in Hl. injection Hl as <-.
    apply if_inv in H as (vt & c & Et & Hb & H).
    rewrite (flag_test _ _ _ _ _ _ _ (PTree.gss _ _ _) Hn Et Hb) in H.
    apply skip_inv in H as (-> & _). reflexivity.
  Qed.

  (* ---- try_print_debug_mario_object_info ---- *)
  Definition pins (m : mem) : Prop :=
    (forall b, Genv.find_symbol G DB._sDebugPage = Some b -> Mem.load Mint8signed m b 0 = Some (Vint Int.zero))
    /\ OW.dflags_ok G m.

  Lemma pins_of : forall m, Pc m -> pins m.
  Proof.
    intros m (_ & _ & _ & _ & (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C)).
    destruct (OW.ow_debug _ _ _ _ _ _ _ _ _ _ _ _ C) as (D1 & D2).
    split; [ intros b Sb; rewrite S6 in Sb; injection Sb as <-; exact D1 | exact D2 ].
  Qed.

  (* a statement that keeps the memory under the pins *)
  Definition idS (s : statement) : Prop :=
    forall le m t le' m' out, pins m -> exec_stmt function_entry2 G empty_env le m s t le' m' out -> m' = m.

  Lemma idS_pure : forall s, CollWalk.pure s = true -> idS s.
  Proof. intros s Hp le m t le' m' out _ H. exact (CollWalk.pure_mem _ _ _ _ _ _ _ _ _ H Hp). Qed.

  Lemma idS_seq : forall s1 s2, idS s1 -> idS s2 -> idS (Ssequence s1 s2).
  Proof.
    intros s1 s2 I1 I2 le m t le' m' out Hp H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & _)].
    - pose proof (I1 _ _ _ _ _ _ Hp H1) as ->. exact (I2 _ _ _ _ _ _ Hp H2).
    - exact (I1 _ _ _ _ _ _ Hp H1).
  Qed.

  Lemma idS_if : forall a s1 s2, idS s1 -> idS s2 -> idS (Sifthenelse a s1 s2).
  Proof.
    intros a s1 s2 I1 I2 le m t le' m' out Hp H.
    apply if_inv in H as (v & c & _ & _ & H). destruct c; [ exact (I1 _ _ _ _ _ _ Hp H) | exact (I2 _ _ _ _ _ _ Hp H) ].
  Qed.

  Lemma idS_map : forall al,
    idS (Scall None (Evar DB._print_debug_top_down_mapinfo
                       (Tfunction (tptr tuchar :: tint :: nil) tvoid cc_default)) al).
  Proof.
    intros al le m t le' m' out Hp H.
    destruct (callk _ _ _ _ _ _ _ _ _ _ dm_map H) as (vargs & t' & vr & _ & Hcall).
    exact (mapinfo_id _ _ _ _ _ (proj2 Hp) Hcall).
  Qed.

  Lemma idS_bot : forall al,
    idS (Scall None (Evar DB._print_debug_bottom_up
                       (Tfunction (tptr tuchar :: tint :: nil) tvoid cc_default)) al).
  Proof.
    intros al le m t le' m' out Hp H.
    destruct (callk _ _ _ _ _ _ _ _ _ _ dm_bot H) as (vargs & t' & vr & _ & Hcall).
    exact (bottom_id _ _ _ _ _ (proj2 Hp) Hcall).
  Qed.

  (* the page switch: sDebugPage is 0, the default case breaks *)
  Lemma idS_page : forall sl,
    select_switch 0 sl = LScons None Sbreak LSnil ->
    idS (Ssequence (Sset DB._t'7 (Evar DB._sDebugPage tschar)) (Sswitch (Etempvar DB._t'7 tschar) sl)).
  Proof.
    intros sl Hsel le m t le' m' out Hp H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H) | (H1 & _)].
    2: { apply set_inv in H1 as (_ & _ & _ & -> & _). reflexivity. }
    apply set_inv in H1 as (v & Ev & -> & -> & _).
    destruct (CollWalk.evg G m le _ _ _ _ Ev eq_refl) as (bp & Hs & Hl).
    cbn [Mem.loadv] in Hl. rewrite Ptrofs.unsigned_zero, (proj1 Hp bp Hs) in Hl. injection Hl as <-.
    apply sw_inv in H as (v & n & out1 & Ev2 & Hw & Hx & _).
    apply ev_temp in Ev2. rewrite PTree.gss in Ev2. injection Ev2 as <-.
    cbn in Hw. injection Hw as Hn.
    assert (En : n = 0) by (rewrite <- Hn; reflexivity). rewrite En in Hx.
    rewrite Hsel in Hx. exact (CollWalk.pure_mem _ _ _ _ _ _ _ _ _ Hx eq_refl).
  Qed.

  Lemma tp_id : forall m vargs t m' vr, pins m ->
    eval_funcall function_entry2 G m (Internal DB.f_try_print_debug_mario_object_info) vargs t m' vr -> m' = m.
  Proof.
    intros m vargs t m' vr Hp Hev.
    destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
    unfold DB.f_try_print_debug_mario_object_info in H; cbn [fn_body] in H.
    apply (fun I : idS _ => I _ _ _ _ _ _ Hp H).
    repeat first [ apply idS_page; reflexivity | apply idS_pure; reflexivity
                 | apply idS_map | apply idS_bot | apply idS_seq | apply idS_if ].
  Qed.

  (* ---- THE ROWS: the three debug calls keep Pc ---- *)
  Theorem debug_keeps :
    ObjPhase.call_keeps G Pc OLP._reset_debug_objectinfo
    /\ ObjPhase.call_keeps G Pc OLP._stub_debug_5
    /\ ObjPhase.call_keeps G Pc OLP._try_print_debug_mario_object_info.
  Proof.
    split; [ | split ]; intros bf fd m vargs t m' vr Hs Hf HP Hev.
    - rewrite (fun_db _ _ dm_reset bf fd Hs Hf) in Hev. exact (reset_ok _ _ _ _ _ Hev HP).
    - rewrite (fun_db _ _ dm_stub5 bf fd Hs Hf) in Hev.
      destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
      cbn [DB.f_stub_debug_5 fn_body] in H. apply skip_inv in H as (-> & _). exact HP.
    - rewrite (fun_db _ _ dm_tp bf fd Hs Hf) in Hev.
      rewrite (tp_id _ _ _ _ _ (pins_of m HP) Hev). exact HP.
  Qed.
End DK.

(* ---------------------------------------------------------------------- *)
(* 3. The writer of the flag: debug_unknown_level_select_check (from       *)
(*    clear_objects) stores 0 << 0 or 1 << 1, so bit 0 stays clear.        *)
(* ---------------------------------------------------------------------- *)
Definition fcell (bfl : block) (m : mem) : Prop :=
  exists n, Mem.load Mint32 m bfl 0 = Some (Vint n) /\ Int.and n Int.one = Int.zero.

(* a store into another global's block keeps the flag cell *)
Ltac dasg H HP Sfl :=
  let b := fresh "b" in let o := fresh "o" in let bf := fresh "bf" in
  let v2 := fresh "v2" in let v := fresh "v" in let Hl := fresh "Hl" in
  let Ev := fresh "Ev" in let Hc := fresh "Hc" in let Ha := fresh "Ha" in let Hs := fresh "Hs" in
  let Hne := fresh "Hne" in let n := fresh "n" in let Ln := fresh "Ln" in let Hn := fresh "Hn" in
  let St := fresh "St" in
  apply assign_inv in H; destruct H as (b & o & bf & v2 & v & Hl & Ev & Hc & Ha & -> & _);
  first
    [ apply lv_gfld in Hl;
      assert (Hne := ClearKeep.symne_b _ _ _ _ _ Hl Sfl ltac:(vm_compute; reflexivity));
      destruct HP as (n & Ln & Hn); exists n; split; [ | exact Hn ];
      rewrite (Generic.GlobalSeparation.assign_loc_load_other _ _ _ _ _ _ _ _ Ha _ _ _ Hne); exact Ln
    | apply lv_gvar in Hl; [ | apply PTree.gempty ]; destruct Hl as (Hs & -> & ->);
      first
        [ assert (Hne := ClearKeep.symne_b _ _ _ _ _ Hs Sfl ltac:(vm_compute; reflexivity));
          destruct HP as (n & Ln & Hn); exists n; split; [ | exact Hn ];
          rewrite (Generic.GlobalSeparation.assign_loc_load_other _ _ _ _ _ _ _ _ Ha _ _ _ Hne); exact Ln
        | rewrite Sfl in Hs; injection Hs as <-;
          let E1 := fresh "E1" in let E2 := fresh "E2" in let Hop := fresh "Hop" in
          apply ev_binop in Ev; destruct Ev as (? & ? & E1 & E2 & Hop);
          apply ev_const in E1; apply ev_const in E2; rewrite E1, E2 in Hop;
          cbn [typeof] in Hop, Hc, Ha; apply op_shl_v in Hop; [ subst v2 | reflexivity ];
          apply cast_tint_id in Hc; subst v;
          pose proof (sbv _ _ _ _ _ _ _ _ Ha eq_refl _ eq_refl) as St;
          rewrite Ptrofs.unsigned_zero in St;
          clear HP; eexists; split;
            [ rewrite (Mem.load_store_same _ _ _ _ _ _ St); reflexivity
            | apply Int.same_if_eq; vm_compute; reflexivity ] ] ].

Ltac dwk H HP Sfl :=
  lazymatch type of H with
  | exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      let H1 := fresh "H" in let H2 := fresh "H" in let Hn := fresh "Hn" in
      apply seq_inv in H; destruct H as [(? & ? & ? & ? & H1 & H2) | (H1 & Hn)];
      [ dwk H1 HP Sfl; dwk H2 HP Sfl | dwk H1 HP Sfl ]
  | exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      let v := fresh "v" in let Ev := fresh "Ev" in
      apply set_inv in H; destruct H as (v & Ev & -> & -> & _)
  | exec_stmt _ _ _ _ _ Sskip _ _ _ _ =>
      apply skip_inv in H; destruct H as (-> & -> & _)
  | exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      let c := fresh "c" in
      apply if_inv in H; destruct H as (? & c & ? & ? & H); destruct c; cbv beta iota in H; dwk H HP Sfl
  | exec_stmt _ _ _ _ _ (Sassign _ _) _ _ ?m2 _ =>
      lazymatch type of Sfl with Genv.find_symbol _ _ = Some ?bfl =>
        let HP1 := fresh "HP" in
        assert (HP1 : fcell bfl m2) by (unfold fcell in HP |- *; dasg H HP Sfl);
        clear HP; rename HP1 into HP
      end
  end.

Lemma dlsc_keeps : forall (G : genv) m vargs t m' vr,
  OW.dflags_ok G m ->
  eval_funcall function_entry2 G m (Internal DB.f_debug_unknown_level_select_check) vargs t m' vr ->
  OW.dflags_ok G m'.
Proof.
  intros G m vargs t m' vr D Hev bfl Sfl.
  assert (HP : fcell bfl m) by exact (D bfl Sfl). clear D.
  destruct (CollWalk.fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & _ & H).
  unfold DB.f_debug_unknown_level_select_check in H; cbn [fn_body] in H.
  dwk H HP Sfl.
  all: exact HP.
Qed.
