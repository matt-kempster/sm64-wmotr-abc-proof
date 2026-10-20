(* ======================================================================= *)
(* FrameSplit: GOAL 2's frame rows, split at execute_mario_action's calls. *)
(*                                                                         *)
(* HeightFrame used to assume three whole-frame rows: one real             *)
(* execute_mario_action keeps the action in R_noA, keeps the WMotR world,  *)
(* and moves Mario's cells by a MoveChain.  The body of                    *)
(* execute_mario_action (generated/mario.v) is a fixed sequence of calls   *)
(* (FrameCalls.cl computes them: 17 `f(gMarioState)` calls, 5 others) and  *)
(* two stores to Mario's object.  This file proves the three frame facts   *)
(* from one row per call, and proves the two stores itself:                *)
(*   seg_call / seg_any   each call keeps the frame world (fworld) and      *)
(*                        moves the cells by a MoveChain                    *)
(*   mem_ok at each call  GOAL 1's per-call result (frame_call_ok_linked12) *)
(*   the two stores       proved here (flags, oInteractStatus = 0)          *)
(* The per-call rows are what later walks discharge one by one (the        *)
(* airborne dispatcher first: act_freefall is FfRun.ff_move).              *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario level_update.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld.
From SM64.Proofs Require Import Generic.ClosedMem.
Import ListNotations.

Definition tyMSp : type := tptr (Tstruct mario._MarioState noattr).

(* the obligations of the real body, computed from the generated AST *)
Definition ema_obls : list obl :=
  match cl mario._gMarioState tyMSp (fn_body mario.f_execute_mario_action) with
  | Some l => l
  | None => []
  end.

Lemma ema_cl : cl mario._gMarioState tyMSp (fn_body mario.f_execute_mario_action) = Some ema_obls.
Proof.
  unfold ema_obls.
  destruct (cl mario._gMarioState tyMSp (fn_body mario.f_execute_mario_action)) eqn:E.
  - reflexivity.
  - vm_compute in E. discriminate E.
Qed.

Definition ema_calls : list ident :=
  flat_map (fun o => match o with OCall f => [f] | _ => [] end) ema_obls.

Lemma ema_calls_root : forallb (fun f => mem_id f root_called_ids) ema_calls = true.
Proof. vm_compute. reflexivity. Qed.

Definition ema_anys : list (ident * type * list expr) :=
  flat_map (fun o => match o with OAny f fty al => [(f, fty, al)] | _ => [] end) ema_obls.

Definition ema_blks : list statement :=
  flat_map (fun o => match o with OBlk s => [s] | _ => [] end) ema_obls.

Definition not_ms_head (tl : list type) : bool :=
  match tl with
  | Tpointer (Tstruct sid _) _ :: _ => negb (Pos.eqb sid mario._MarioState)
  | _ => true
  end.

Definition any_chk (x : ident * type * list expr) : bool :=
  match x with
  | (f, fty, _) =>
      match classify_fun fty with
      | fun_case_f tl r c =>
          mem_id f root_called_ids && negb (is_wty (Tfunction tl r c)) && not_ms_head tl
      | _ => false
      end
  end.

Lemma ema_anys_ok : forallb any_chk ema_anys = true.
Proof. vm_compute. reflexivity. Qed.

Lemma marg_exempt_of : forall fd tl r c,
  type_of_fundef fd = Tfunction tl r c -> not_ms_head tl = true -> marg_exempt fd = true.
Proof.
  intros fd tl r c Ht Hn. destruct fd as [f | ef targs tres cc]; [| reflexivity].
  cbn in Ht. unfold type_of_function in Ht. injection Ht as Htl _ _. subst tl.
  unfold marg_exempt. destruct (fn_params f) as [| [id ty] ps]; [reflexivity |].
  cbn in Hn |- *. destruct ty as [| | | | t0 a0 | | | | ]; try reflexivity.
  destruct t0; try reflexivity. exact Hn.
Qed.

Lemma exprlist_sub32 : forall ge e le m al tl vargs,
  eval_exprlist ge e le m al tl vargs -> forallb sub32i tl = true ->
  Forall (fun v => exists n, v = Vint n) vargs.
Proof.
  intros ge e le m al tl vargs H. induction H; intros Hs; [constructor |].
  cbn in Hs. apply andb_prop in Hs. destruct Hs as (Ha & Hb).
  constructor; [| exact (IHeval_exprlist Hb)].
  match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => exact (sem_cast_sub32i_vint _ _ _ _ _ Ha Hc) end.
Qed.

(* ---- the body's two store blocks (the text of generated/mario.v, tied to
   the body by ema_blks_eq) ---- *)
Definition blk_flags_t : statement :=
  (Ssequence (Sset mario._t'48 (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))) (Ssequence (Sset mario._t'49 (Efield (Ederef (Etempvar mario._t'48 (tptr (Tstruct mario._MarioState noattr))) (Tstruct mario._MarioState noattr)) mario._marioObj (tptr (Tstruct mario._Object noattr)))) (Ssequence (Sset mario._t'50 (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))) (Ssequence (Sset mario._t'51 (Efield (Ederef (Etempvar mario._t'50 (tptr (Tstruct mario._MarioState noattr))) (Tstruct mario._MarioState noattr)) mario._marioObj (tptr (Tstruct mario._Object noattr)))) (Ssequence (Sset mario._t'52 (Efield (Efield (Efield (Efield (Ederef (Etempvar mario._t'51 (tptr (Tstruct mario._Object noattr))) (Tstruct mario._Object noattr)) mario._header (Tstruct mario._ObjectNode noattr)) mario._gfx (Tstruct mario._GraphNodeObject noattr)) mario._node (Tstruct mario._GraphNode noattr)) mario._flags tshort)) (Sassign (Efield (Efield (Efield (Efield (Ederef (Etempvar mario._t'49 (tptr (Tstruct mario._Object noattr))) (Tstruct mario._Object noattr)) mario._header (Tstruct mario._ObjectNode noattr)) mario._gfx (Tstruct mario._GraphNodeObject noattr)) mario._node (Tstruct mario._GraphNode noattr)) mario._flags tshort) (Ebinop Oand (Etempvar mario._t'52 tshort) (Eunop Onotint (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 4) tint) tint) tint) tint))))))).

Definition blk_status_t : statement :=
  (Ssequence (Sset mario._t'12 (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))) (Ssequence (Sset mario._t'13 (Efield (Ederef (Etempvar mario._t'12 (tptr (Tstruct mario._MarioState noattr))) (Tstruct mario._MarioState noattr)) mario._marioObj (tptr (Tstruct mario._Object noattr)))) (Sassign (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar mario._t'13 (tptr (Tstruct mario._Object noattr))) (Tstruct mario._Object noattr)) mario._rawData (Tunion mario.__764 noattr)) mario._asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint) (tptr tint)) tint) (Econst_int (Int.repr 0) tint)))).

Lemma ema_blks_eq : ema_blks = [blk_flags_t; blk_status_t].
Proof. vm_compute. reflexivity. Qed.

(* field offsets in mario.prog's own composite env: a small readback.
   Stated over an abstract env and instantiated, so no proof term ever
   reduces a concrete composite env (coq-perf trap). *)
Definition fo_of (env : composite_env) (sid f : ident) : option (Z * bitfield) :=
  match env ! sid with
  | Some co =>
      if complete_members env (co_members co) then
        match field_offset env f (co_members co) with
        | Errors.OK d => Some d | Errors.Error _ => None end
      else None
  | None => None
  end.

Definition ufo_of (env : composite_env) (sid f : ident) : option (Z * bitfield) :=
  match env ! sid with
  | Some co =>
      if complete_members env (co_members co) then
        match union_field_offset env f (co_members co) with
        | Errors.OK d => Some d | Errors.Error _ => None end
      else None
  | None => None
  end.

Lemma fo_of_ext : forall (envm envl : composite_env) sid f co d,
  (forall id c, envm ! id = Some c -> envl ! id = Some c) ->
  fo_of envm sid f = Some d -> envl ! sid = Some co ->
  field_offset envl f (co_members co) = Errors.OK d.
Proof.
  intros envm envl sid f co d Hext Hm Hco. unfold fo_of in Hm.
  destruct (envm ! sid) as [co0|] eqn:E; [| discriminate Hm].
  destruct (complete_members envm (co_members co0)) eqn:Ec; [| discriminate Hm].
  destruct (field_offset envm f (co_members co0)) eqn:Ef; [| discriminate Hm].
  injection Hm as <-.
  rewrite (Hext _ _ E) in Hco. injection Hco as <-.
  rewrite (field_offset_stable envm envl Hext f _ Ec). exact Ef.
Qed.

Lemma ufo_of_ext : forall (envm envl : composite_env) sid f co d,
  (forall id c, envm ! id = Some c -> envl ! id = Some c) ->
  ufo_of envm sid f = Some d -> envl ! sid = Some co ->
  union_field_offset envl f (co_members co) = Errors.OK d.
Proof.
  intros envm envl sid f co d Hext Hm Hco. unfold ufo_of in Hm.
  destruct (envm ! sid) as [co0|] eqn:E; [| discriminate Hm].
  destruct (complete_members envm (co_members co0)) eqn:Ec; [| discriminate Hm].
  destruct (union_field_offset envm f (co_members co0)) eqn:Ef; [| discriminate Hm].
  injection Hm as <-.
  rewrite (Hext _ _ E) in Hco. injection Hco as <-.
  rewrite (union_field_offset_stable envm envl Hext f _ Ec). exact Ef.
Qed.

Notation mario_fo := (fo_of (prog_comp_env mario.prog)).
Notation mario_ufo := (ufo_of (prog_comp_env mario.prog)).

Lemma mario_offsets :
  mario_fo mario._Object mario._header = Some (0, Full)
  /\ mario_fo mario._ObjectNode mario._gfx = Some (0, Full)
  /\ mario_fo mario._GraphNodeObject mario._node = Some (0, Full)
  /\ mario_fo mario._GraphNode mario._flags = Some (2, Full)
  /\ mario_fo mario._Object mario._rawData = Some (136, Full)
  /\ mario_ufo mario.__764 mario._asS32 = Some (0, Full).
Proof. vm_compute. repeat split. Qed.

Section FrameSplit.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Variable bm : block.
  Variable SafeB : block -> Prop.
  Variable MWF : mem -> Prop.

  Notation ge := (lp_ge lp).
  Notation mem_ok := (mem_ok_lp bm MWF).

  (* ---- GOAL 1's per-call facts (NoAImpliesNoFlyTwelve.frame_call_ok_linked12) *)
  Hypothesis Hcall : reach_value_preserves_reached_g not_tainted bm ge (NoA_real bm) MWF
                       (call_gate bm SafeB) (reached_v2 lp).
  Hypothesis Hgms : forall m, MWF m -> gms_cond_lp lp m bm.
  Hypothesis Hnoa : forall m, MWF m -> NoA_real bm m.

  (* ---- the world the frame keeps ---- *)

  (* the animation DMA buffer stays off the world (moved from HeightFrame) *)
  Definition anim_apart (m : mem) : Prop :=
    forall ab bt ot,
      Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab ->
      Mem.load Mptr m ab 8 = Some (Vptr bt ot) ->
      (forall off sb so, (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
         Mem.load Mint32 m bm off = Some (Vptr sb so) -> bt <> sb)
      /\ (forall mb mo i cb co,
         Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo) -> 0 <= i < 4 ->
         Mem.load Mint32 m mb (Ptrofs.unsigned mo + COLL_OFF + 4 * i) = Some (Vptr cb co) ->
         bt <> cb).

  (* Mario's object stays off the world: no surface lives in its block, and
     a collided object is Mario's own or a whole Object away.  In the game
     surfaces are in sSurfacePool and objects are distinct gObjectPool slots
     (OBJ_SIZE = sizeof(struct Object)).  Needed for the frame's own stores
     to Mario's object (flags, oInteractStatus). *)
  Definition OBJ_SIZE : Z := 608.

  Definition mobj_apart (m : mem) : Prop :=
    forall mb mo,
      Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo) ->
      Ptrofs.unsigned mo + OBJ_SIZE <= Ptrofs.modulus
      /\ (forall off sb so, (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
         Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> mb)
      /\ (forall i cb co, 0 <= i < 4 ->
         Mem.load Mint32 m mb (Ptrofs.unsigned mo + COLL_OFF + 4 * i) = Some (Vptr cb co) ->
         cb <> mb \/ co = mo
         \/ Ptrofs.unsigned co + OBJ_SIZE <= Ptrofs.unsigned mo
         \/ Ptrofs.unsigned mo + OBJ_SIZE <= Ptrofs.unsigned co).

  (* what holds at every call boundary of the frame, besides GOAL 1's mem_ok *)
  Definition fworld (m : mem) : Prop :=
    action_sat R_noA m bm /\ wmotr_world bm m /\ anim_apart m /\ mobj_apart m
    /\ a_down_real bm m = false /\ ffw ge bm m.

  Notation MC := (MoveChain wmotr_floor wmotr_pole wmotr_cannon).

  (* the frame's state relative to its start cells c0 *)
  Definition FS (c0 : cells) (m : mem) : Prop :=
    mem_ok m /\ fworld m /\ exists c, read_cells bm m c /\ MC c0 c.

  (* ---- THE ROW SHAPE: one call keeps the frame world and moves the cells
     by a MoveChain.  It may assume GOAL 1's mem_ok before and after. ---- *)
  Definition seg_ok (fd : Clight.fundef) (vargs : list val) (pre : mem -> Prop) : Prop :=
    forall m t m' vr c,
      mem_ok m -> fworld m -> pre m -> mem_ok m' ->
      read_cells bm m c -> budget_ok c ->
      eval_funcall function_entry2 ge m fd vargs t m' vr ->
      fworld m' /\ exists c', read_cells bm m' c' /\ MC c c'.

  (* the argument of an `f(gMarioState)` call is the global's value *)
  Definition gms_val (v : val) (m : mem) : Prop :=
    exists gb, Genv.find_symbol ge mario._gMarioState = Some gb
               /\ Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some v.

  Definition resolves (f : ident) (fd : Clight.fundef) : Prop :=
    exists b, Genv.find_symbol ge f = Some b /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd.

  (* ---- generic plumbing ---- *)
  Lemma eval_Evar_fn : forall le m f tyl rt cc b,
    Genv.find_symbol ge f = Some b ->
    eval_expr ge empty_env le m (Evar f (Tfunction tyl rt cc)) (Vptr b Ptrofs.zero).
  Proof.
    intros. eapply eval_Elvalue.
    - apply eval_Evar_global; [apply PTree.gempty | exact H].
    - apply deref_loc_reference. reflexivity.
  Qed.

  Lemma eval_gms : forall le m v,
    eval_expr ge empty_env le m (Evar mario._gMarioState tyMSp) v -> gms_val v m.
  Proof.
    intros le m v H. inv H;
      match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end.
    - match goal with He : empty_env ! _ = Some _ |- _ =>
        rewrite PTree.gempty in He; discriminate He end.
    - match goal with Hs : Genv.find_symbol _ _ = Some ?l, Hd : deref_loc _ _ _ _ _ _ |- _ =>
        exists l; split; [exact Hs |]; inv Hd end;
      match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; try discriminate Ha end.
      injection H as <-. assumption.
  Qed.

  Lemma mem_ok_call : forall f fd m t m' vr vargs tyargs rt cc,
    mem_id f root_called_ids = true ->
    resolves f fd ->
    type_of_fundef fd = Tfunction tyargs rt cc ->
    is_wty (Tfunction tyargs rt cc) = false ->
    (marg_exempt fd = false -> marg_ok bm vargs) ->
    sargs_ok fd vargs ->
    mem_ok m -> eval_funcall function_entry2 ge m fd vargs t m' vr -> mem_ok m'.
  Proof.
    intros f fd m t m' vr vargs tyargs rt cc Hr (b & Hb & Hff) Hty Hw Hmarg Hs
           (Hv & Hnt & HM) Hev.
    assert (Hreach : reached_v2 lp fd).
    { eapply (root_call_resolves lp LO_mario None (Evar f (Tfunction tyargs rt cc)) nil
                (PTree.empty val) m); [ | apply eval_Evar_fn; exact Hb | exact Hff ].
      cbn. unfold root_RID. exact Hr. }
    assert (HG : call_gate bm SafeB fd vargs).
    { unfold call_gate. rewrite Hty. exact (wgate_nonwriter bm SafeB _ vargs Hw). }
    destruct (Hcall m fd vargs t m' vr Hreach (Hnoa m HM) HM Hmarg Hs HG Hev Hv Hnt)
      as (Hv' & Hnt' & HM').
    exact (conj Hv' (conj Hnt' HM')).
  Qed.

  Lemma chain_step : forall c0 m m' (Hstep : forall c, read_cells bm m c -> budget_ok c ->
                         fworld m' /\ exists c', read_cells bm m' c' /\ MC c c'),
    budget_ok c0 -> FS c0 m -> mem_ok m' -> FS c0 m'.
  Proof.
    intros c0 m m' Hstep Hb (Hok & Hw & c & Hc & Hmc) Hok'.
    pose proof (chain_keeps_budget wmotr_floor wmotr_gap_proved wmotr_pole wmotr_poles_proved
                  wmotr_cannon wmotr_cannons_proved c0 c Hb Hmc) as Hbc.
    destruct (Hstep c Hc Hbc) as (Hw' & c' & Hc' & Hmc').
    refine (conj Hok' (conj Hw' (ex_intro _ c' (conj Hc' _)))).
    exact (rt_trans _ _ _ _ _ Hmc Hmc').
  Qed.

  Lemma is_wty_ms : forall rt cc, is_wty (Tfunction [tyMSp] rt cc) = false.
  Proof.
    intros rt cc. unfold is_wty, T_ffc, T_f32w, T_v3fcopy, T_v3fset, T_v3scopy, T_vfc.
    repeat (destruct (type_eq _ _) as [E|]; [inversion E |]). reflexivity.
  Qed.

  Lemma in_calls : forall f, In (OCall f) ema_obls -> mem_id f root_called_ids = true.
  Proof.
    intros f H. pose proof ema_calls_root as R. rewrite forallb_forall in R. apply R.
    unfold ema_calls. apply in_flat_map. exists (OCall f). split; [exact H | left; reflexivity].
  Qed.

  Lemma ocall_ok : forall c0 f,
    budget_ok c0 -> In (OCall f) ema_obls ->
    (forall fd v, resolves f fd -> seg_ok fd [v] (gms_val v)) ->
    obl_ok ge mario._gMarioState tyMSp (FS c0) (OCall f).
  Proof.
    intros c0 f Hb Hin Hrow. cbn [obl_ok].
    intros le bf fd m v v' rt cc t m' vr Hev Hc Hbf Hff Hty HP Hf.
    assert (v' = v) as ->.
    { unfold tyMSp, tptr, sem_cast in Hc. cbn in Hc.
      destruct v; try discriminate Hc; injection Hc as <-; reflexivity. }
    pose proof (eval_gms _ _ _ Hev) as Hgv.
    destruct HP as (Hok & Hw & Hcells).
    assert (Hok' : mem_ok m').
    { eapply (mem_ok_call f fd m t m' vr [v] [tyMSp] rt cc (in_calls f Hin)
                (ex_intro _ bf (conj Hbf Hff)) Hty (is_wty_ms rt cc)); [ | | exact Hok | exact Hf ].
      - intros _. destruct v; cbn; try exact I.
        destruct Hgv as (gb & Hg & Hl).
        exact (Hgms m (proj2 (proj2 Hok)) gb b i Hg Hl).
      - unfold sargs_ok, sig_sub32. rewrite Hty. cbn. discriminate. }
    apply (chain_step c0 m m'); [ | exact Hb | exact (conj Hok (conj Hw Hcells)) | exact Hok' ].
    intros c Hrc Hbc.
    exact (Hrow fd v (ex_intro _ bf (conj Hbf Hff)) m t m' vr c Hok Hw Hgv Hok' Hrc Hbc Hf).
  Qed.

  Lemma oany_ok : forall c0 f fty al,
    budget_ok c0 -> In (OAny f fty al) ema_obls ->
    (forall fd vargs, resolves f fd -> seg_ok fd vargs (fun _ => True)) ->
    obl_ok ge mario._gMarioState tyMSp (FS c0) (OAny f fty al).
  Proof.
    intros c0 f fty al Hb Hin Hrow. cbn [obl_ok].
    intros le bf fd m tyargs tyres cc vargs t m' vr Hcl Hbf Hff Hty Hel HP Hf.
    assert (Hchk : any_chk (f, fty, al) = true).
    { pose proof ema_anys_ok as R. rewrite forallb_forall in R. apply R.
      unfold ema_anys. apply in_flat_map. exists (OAny f fty al).
      split; [exact Hin | left; reflexivity]. }
    unfold any_chk in Hchk. rewrite Hcl in Hchk.
    apply andb_prop in Hchk. destruct Hchk as (Hchk & Hnm).
    apply andb_prop in Hchk. destruct Hchk as (Hr & Hw).
    apply negb_true_iff in Hw.
    destruct HP as (Hok & Hwd & Hcells).
    assert (Hok' : mem_ok m').
    { eapply (mem_ok_call f fd m t m' vr vargs tyargs tyres cc Hr
                (ex_intro _ bf (conj Hbf Hff)) Hty Hw); [ | | exact Hok | exact Hf ].
      - intros He. rewrite (marg_exempt_of fd tyargs tyres cc Hty Hnm) in He. discriminate He.
      - intros Hs. unfold sig_sub32 in Hs. rewrite Hty in Hs.
        exact (exprlist_sub32 _ _ _ _ _ _ _ Hel Hs). }
    apply (chain_step c0 m m'); [ | exact Hb | exact (conj Hok (conj Hwd Hcells)) | exact Hok' ].
    intros c Hrc Hbc.
    exact (Hrow fd vargs (ex_intro _ bf (conj Hbf Hff)) m t m' vr c Hok Hwd I Hok' Hrc Hbc Hf).
  Qed.

  (* linking keeps those offsets *)
  Lemma lp_cenv_ext : forall id c,
    (prog_comp_env mario.prog) ! id = Some c -> (genv_cenv ge) ! id = Some c.
  Proof. intros id c H. exact (linkorder_comp_env_extends lp mario.prog id c LO_mario H). Qed.

  Lemma lp_fo : forall sid f co d,
    (genv_cenv ge) ! sid = Some co -> mario_fo sid f = Some d ->
    field_offset (genv_cenv ge) f (co_members co) = Errors.OK d.
  Proof.
    intros sid f co d Hco Hm.
    exact (fo_of_ext (prog_comp_env mario.prog) (genv_cenv ge) sid f co d lp_cenv_ext Hm Hco).
  Qed.

  Lemma lp_ufo : forall sid f co d,
    (genv_cenv ge) ! sid = Some co -> mario_ufo sid f = Some d ->
    union_field_offset (genv_cenv ge) f (co_members co) = Errors.OK d.
  Proof.
    intros sid f co d Hco Hm.
    exact (ufo_of_ext (prog_comp_env mario.prog) (genv_cenv ge) sid f co d lp_cenv_ext Hm Hco).
  Qed.

  (* ---- reading the two store blocks ---- *)
  Lemma seq_set_inv : forall le m x a s t le' m' out,
    exec_stmt function_entry2 ge empty_env le m (Ssequence (Sset x a) s) t le' m' out ->
    exists v, eval_expr ge empty_env le m a v
      /\ exec_stmt function_entry2 ge empty_env (PTree.set x v le) m s t le' m' out.
  Proof.
    intros le m x a s t le' m' out H. inv H;
      match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1 end.
    - eexists; split; eassumption.
    - congruence.
  Qed.

  Lemma lv_field : forall le m a sid f ty loc ofs bf d,
    eval_lvalue ge empty_env le m (Efield a f ty) loc ofs bf ->
    typeof a = Tstruct sid noattr -> mario_fo sid f = Some d ->
    exists o0, eval_expr ge empty_env le m a (Vptr loc o0)
      /\ ofs = Ptrofs.add o0 (Ptrofs.repr (fst d)) /\ bf = snd d.
  Proof.
    intros le m a sid f ty loc ofs bf [dz dbf] H Ht Hd.
    apply eval_lvalue_Efield_inv in H as (o0 & id & att & co & delta & Hb & Hco & Hofs & Hcase).
    rewrite Ht in Hcase.
    destruct Hcase as [(Hty & Hfo) | (Hty & Hfo)]; [| discriminate Hty].
    injection Hty as <- <-.
    rewrite (lp_fo _ _ _ _ Hco Hd) in Hfo. injection Hfo as <- <-.
    exists o0. cbn [fst snd]. auto.
  Qed.

  Lemma lv_ufield : forall le m a sid f ty loc ofs bf d,
    eval_lvalue ge empty_env le m (Efield a f ty) loc ofs bf ->
    typeof a = Tunion sid noattr -> mario_ufo sid f = Some d ->
    exists o0, eval_expr ge empty_env le m a (Vptr loc o0)
      /\ ofs = Ptrofs.add o0 (Ptrofs.repr (fst d)) /\ bf = snd d.
  Proof.
    intros le m a sid f ty loc ofs bf [dz dbf] H Ht Hd.
    apply eval_lvalue_Efield_inv in H as (o0 & id & att & co & delta & Hb & Hco & Hofs & Hcase).
    rewrite Ht in Hcase.
    destruct Hcase as [(Hty & Hfo) | (Hty & Hfo)]; [discriminate Hty |].
    injection Hty as <- <-.
    rewrite (lp_ufo _ _ _ _ Hco Hd) in Hfo. injection Hfo as <- <-.
    exists o0. cbn [fst snd]. auto.
  Qed.

  (* an aggregate-typed field or deref evaluates to its own address *)
  Lemma ex_agg : forall le m a loc o,
    eval_expr ge empty_env le m a (Vptr loc o) ->
    (access_mode (typeof a) = By_reference \/ access_mode (typeof a) = By_copy) ->
    (match a with Efield _ _ _ | Ederef _ _ => True | _ => False end) ->
    exists bf, eval_lvalue ge empty_env le m a loc o bf.
  Proof.
    intros le m a loc o H Hm Ha.
    destruct a; try contradiction; inv H;
      match goal with
      | Hl : eval_lvalue _ _ _ _ _ ?l ?of ?b, Hd : deref_loc _ _ _ _ _ _ |- _ =>
          apply deref_loc_aggregate_eq in Hd as [-> ->]; [eexists; exact Hl | exact Hm]
      end.
  Qed.

  Lemma mobj_of_tmp : forall x le m v48 v49 loc o0,
    MWF m ->
    eval_expr ge empty_env le m (Evar mario._gMarioState tyMSp) v48 ->
    eval_expr ge empty_env (PTree.set x v48 le) m
      (Efield (Ederef (Etempvar x tyMSp) (Tstruct mario._MarioState noattr))
              mario._marioObj (tptr (Tstruct mario._Object noattr))) v49 ->
    v49 = Vptr loc o0 ->
    Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr loc o0).
  Proof.
    intros x le m v48 v49 loc o0 HM E48 E49 ->.
    pose proof (eval_gms _ _ _ E48) as (gb & Hg & Hl).
    assert (Ht : forall b o', (PTree.set x v48 le) ! x = Some (Vptr b o') ->
                              b = bm /\ o' = Ptrofs.zero).
    { intros b o' Hb. rewrite PTree.gss in Hb. injection Hb as ->.
      exact (Hgms m HM gb b o' Hg Hl). }
    exact (RealFrameLinked.eval_marioObj_load_lp lp LO_mario x empty_env _ m bm loc o0
             Ht E49).
  Qed.

  (* ---- a store into Mario's object at the flags or interact-status cell
     keeps the frame world and the cells ---- *)
  Section ObjStore.
    Variables (m m' : mem) (ch : memory_chunk) (lo : Z) (v : val) (mb : block) (mo : ptrofs).
    Hypothesis Hst : Mem.store ch m mb lo v = Some m'.
    Hypothesis Hmo : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo).
    Hypothesis Hmb : mb <> bm.
    Hypothesis Hlo : (lo = Ptrofs.unsigned mo + 2 /\ ch = Mint16signed)
                     \/ (lo = Ptrofs.unsigned mo + O_INTERACT_STATUS /\ ch = Mint32).
    Hypothesis Hstat : exists s', Mem.load Mint32 m' mb (Ptrofs.unsigned mo + O_INTERACT_STATUS)
                                  = Some (Vint s') /\ Int.and s' (Int.repr STOMP_BITS) = Int.zero.
    Hypothesis Hab : forall ab, Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab -> ab <> mb.
    Hypothesis Hbc : forall bc oc, Mem.load Mptr m bm 156 = Some (Vptr bc oc) -> bc <> mb.

    Lemma LD : forall ch' b' o',
      b' <> mb \/ o' + size_chunk ch' <= lo \/ lo + size_chunk ch <= o' ->
      Mem.load ch' m' b' o' = Mem.load ch' m b' o'.
    Proof. intros ch' b' o' H. exact (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ H). Qed.

    Lemma LDbm : forall ch' o', Mem.load ch' m' bm o' = Mem.load ch' m bm o'.
    Proof. intros ch' o'. apply LD. left. congruence. Qed.

    Lemma LDo : forall ch' o', 0 <= Ptrofs.unsigned mo ->
      (Ptrofs.unsigned mo + 4 <= o' /\ o' + size_chunk ch' <= Ptrofs.unsigned mo + O_INTERACT_STATUS)
      \/ Ptrofs.unsigned mo + O_INTERACT_STATUS + 4 <= o'
      \/ o' + size_chunk ch' <= Ptrofs.unsigned mo + 2 ->
      Mem.load ch' m' mb o' = Mem.load ch' m mb o'.
    Proof.
      intros ch' o' Hp H. apply LD. right.
      unfold O_INTERACT_STATUS, RAW_OFF in *.
      destruct Hlo as [[-> ->] | [-> ->]]; cbn [size_chunk]; lia.
    Qed.

    Lemma surface_keep : forall sv, surface_ok m sv ->
      (forall sb so, sv = Vptr sb so -> sb <> mb) -> surface_ok m' sv.
    Proof.
      intros sv [Hn | (b & o & t & -> & Hl & Hin)] Hne; [left; exact Hn |].
      right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
      rewrite LD; [exact Hl | left; exact (Hne b o eq_refl)].
    Qed.

    Lemma surface_nn_keep : forall sv, surface_nonnull_ok m sv ->
      (forall sb so, sv = Vptr sb so -> sb <> mb) -> surface_nonnull_ok m' sv.
    Proof.
      intros sv (b & o & t & -> & Hl & Hin) Hne.
      exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
      rewrite LD; [exact Hl | left; exact (Hne b o eq_refl)].
    Qed.

    Lemma mo_range : 0 <= Ptrofs.unsigned mo.
    Proof. apply Ptrofs.unsigned_range. Qed.

    (* a load of at most 4 bytes in the gaps around the two written cells is unchanged *)
    Lemma LDk : forall ch' o', size_chunk ch' <= 4 ->
      (Ptrofs.unsigned mo + 4 <= o' /\ o' + 4 <= Ptrofs.unsigned mo + O_INTERACT_STATUS)
      \/ Ptrofs.unsigned mo + O_INTERACT_STATUS + 4 <= o' ->
      Mem.load ch' m' mb o' = Mem.load ch' m mb o'.
    Proof.
      intros ch' o' Hs Hk. apply LDo; [exact mo_range |].
      unfold O_INTERACT_STATUS, RAW_OFF in *. lia.
    Qed.

    (* a collided object's fields avoid the two written cells *)
    Lemma coll_keep : forall cv, coll_obj_ok m cv ->
      (forall cb co, cv = Vptr cb co ->
         cb <> mb \/ co = mo
         \/ Ptrofs.unsigned co + OBJ_SIZE <= Ptrofs.unsigned mo
         \/ Ptrofs.unsigned mo + OBJ_SIZE <= Ptrofs.unsigned co) ->
      coll_obj_ok m' cv.
    Proof.
      intros cv (b & o & t & -> & Hl & Hin & Hpole & Hcan) Hap.
      pose proof (Ptrofs.unsigned_range o) as Ro. pose proof mo_range as Rmo.
      assert (K : forall ch' k, size_chunk ch' = 4 ->
                  k = O_POSY \/ k = O_INTERACT_TYPE \/ k = HITBOX_H_OFF \/ k = HITBOX_DOWN_OFF ->
                  Mem.load ch' m' b (Ptrofs.unsigned o + k) = Mem.load ch' m b (Ptrofs.unsigned o + k)).
      { intros ch' k Hs Hk. apply LD. rewrite Hs.
        unfold O_POSY, O_INTERACT_TYPE, HITBOX_H_OFF, HITBOX_DOWN_OFF, RAW_OFF in Hk.
        destruct (Hap b o eq_refl) as [Hne | [-> | [Ha | Ha]]]; [left; exact Hne | | |];
          right; unfold OBJ_SIZE in *;
          destruct Hlo as [[-> ->] | [-> ->]]; cbn [size_chunk];
          unfold O_INTERACT_STATUS, RAW_OFF; lia. }
      exists b, o, t. split; [reflexivity |].
      split; [rewrite K; [exact Hl | reflexivity | right; left; reflexivity] |].
      split; [exact Hin |]. split.
      - intros Ht. destruct (Hpole Ht) as (base & top & Hb & H1 & H2 & H3).
        exists base, top. split; [exact Hb |].
        rewrite !K by (reflexivity || tauto). tauto.
      - intros Ht. destruct (Hcan Ht) as (y & Hy & H1).
        exists y. split; [exact Hy |]. rewrite K by (reflexivity || tauto). exact H1.
    Qed.

    Lemma obj_store_mobj : mobj_apart m -> mobj_apart m'.
    Proof.
      intros Hap mb' mo' Hl'. rewrite LDbm in Hl'.
      destruct (Hap mb' mo' Hl') as (Hmod & Hs & Hc).
      rewrite Hmo in Hl'. injection Hl' as E1 E2. subst mb' mo'.
      split; [exact Hmod |]. split.
      - intros off sb so Hoff Hl2. rewrite LDbm in Hl2. exact (Hs off sb so Hoff Hl2).
      - intros i cb co Hi Hl2.
                rewrite LDk in Hl2; [| cbn; lia | pose proof mo_range; unfold COLL_OFF, O_INTERACT_STATUS, RAW_OFF in *; lia].
        exact (Hc i cb co Hi Hl2).
    Qed.

    Lemma obj_store_anim : anim_apart m -> anim_apart m'.
    Proof.
      intros Hap ab bt ot Hab' Hl. rewrite LD in Hl by (left; exact (Hab ab Hab')).
      destruct (Hap ab bt ot Hab' Hl) as [Hs Hc]. split.
      - intros off sb so Hoff Hl2. rewrite LDbm in Hl2. exact (Hs off sb so Hoff Hl2).
      - intros mb' mo' i cb co Hl1 Hi Hl2. rewrite LDbm in Hl1.
        rewrite Hmo in Hl1. injection Hl1 as E1 E2. subst mb' mo'.
        rewrite LDk in Hl2 by (pose proof mo_range; cbn [size_chunk]; unfold COLL_OFF, O_INTERACT_STATUS, RAW_OFF in *; lia).
        exact (Hc mb mo i cb co Hmo Hi Hl2).
    Qed.

    Lemma obj_store_world : mobj_apart m -> wmotr_world bm m -> wmotr_world bm m'.
    Proof.
      intros Hap (Hw & Hc & Hf & Hh & Hr & Hq & Ho).
      destruct (Hap mb mo Hmo) as (_ & Hsurf & Hcoll).
      assert (Hne : forall off, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
                forall v1, Mem.load Mint32 m bm off = Some v1 ->
                forall sb so, v1 = Vptr sb so -> sb <> mb).
      { intros off Hoff v1 Hl sb so ->. exact (Hsurf off sb so Hoff Hl). }
      repeat split; rewrite ?LDbm.
      - intros v1 Hl. apply surface_keep; [exact (Hw v1 Hl) |].
        exact (Hne WALL_OFF (or_introl eq_refl) v1 Hl).
      - intros v1 Hl. apply surface_keep; [exact (Hc v1 Hl) |].
        exact (Hne CEIL_OFF (or_intror (or_introl eq_refl)) v1 Hl).
      - intros v1 Hl. apply surface_nn_keep; [exact (Hf v1 Hl) |].
        exact (Hne FLOOR_OFF (or_intror (or_intror eq_refl)) v1 Hl).
      - exact Hh.
      - exact Hr.
      - exact Hq.
      - destruct Ho as (mb' & mo' & s0 & n & Hl & _ & _ & Hn & Hn4 & Hall).
        rewrite Hmo in Hl. injection Hl as E1 E2. subst mb' mo'.
        destruct Hstat as (s' & Hs' & Hz).
        exists mb, mo, s', n. split; [rewrite LDbm; exact Hmo |].
        split; [exact Hs' |]. split; [exact Hz |].
        split; [rewrite LDk by (pose proof mo_range; cbn [size_chunk]; unfold NUMCOLL_OFF, O_INTERACT_STATUS, RAW_OFF; lia); exact Hn |].
        split; [exact Hn4 |].
        intros i v0 Hi Hl2.
        rewrite LDk in Hl2 by (pose proof mo_range; cbn [size_chunk]; unfold COLL_OFF, O_INTERACT_STATUS, RAW_OFF in *; lia).
        apply coll_keep; [exact (Hall i v0 Hi Hl2) |].
        intros cb co ->. exact (Hcoll i cb co (ltac:(lia)) Hl2).
    Qed.

    Lemma obj_store_adown : a_down_real bm m' = a_down_real bm m.
    Proof.
      unfold a_down_real. rewrite LDbm.
      destruct (Mem.load Mptr m bm 156) as [[] |] eqn:E; try reflexivity.
      rewrite LD; [reflexivity | left; exact (Hbc _ _ eq_refl)].
    Qed.

    (* the walk's world (FfWorld.ffw): the store is inside Mario's object *)
    Lemma obj_store_ffw : ffw ge bm m -> ffw ge bm m'.
    Proof.
      intros Hf.
      assert (HC' : forall gp, closed_by gp m -> gp mb = Some (mb, 0) -> closed_by gp m').
      { intros gp HC Hg. apply (store_closed gp m m' ch mb lo v Hst HC Hg).
        destruct Hlo as [(_ & ->) | (-> & ->)]; [left; reflexivity |].
        right. intros b' o' ->. destruct Hstat as (s' & Hs' & _).
        rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hs'. cbn in Hs'. discriminate Hs'. }
      refine (ffw_keep ge bm m m' mb mo (Mem.nextblock_store _ _ _ _ _ _ Hst)
                (fun b ofs k p => Mem.perm_store_1 _ _ _ _ _ _ Hst b ofs k p)
                (fun ch' b z Hb => LD ch' b z (or_introl Hb)) _ Hmo Hmb Hab HC' Hf).
      intros i Hi. apply LDk; [cbn; lia |].
      pose proof mo_range. unfold FFW_COLL, O_INTERACT_STATUS, RAW_OFF. lia.
    Qed.

    Lemma obj_store_fworld : fworld m -> fworld m'.
    Proof.
      intros (Ha & Hw & Han & Hmob & Hd & Hf).
      split; [intros v1 Hl; unfold action_sat in Ha; rewrite LDbm in Hl; exact (Ha v1 Hl) |].
      split; [exact (obj_store_world Hmob Hw) |].
      split; [exact (obj_store_anim Han) |].
      split; [exact (obj_store_mobj Hmob) |].
      split; [rewrite obj_store_adown; exact Hd |].
      exact (obj_store_ffw Hf).
    Qed.

    Lemma obj_store_cells : forall c, read_cells bm m c -> read_cells bm m' c.
    Proof.
      intros c (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8).
      rewrite <- !LDbm in H1, H2, H3, H4, H5, H6.
      repeat split; try assumption.
      exists bo, oo. split; [rewrite LDbm; exact H7 |].
      assert (E : Mem.load Mint32 m bm OFS_MARIOOBJ = Some (Vptr bo oo)) by exact H7.
      unfold OFS_MARIOOBJ in E. fold MARIOOBJ_OFF in E. rewrite Hmo in E.
      injection E as E1 E2. subst bo oo. rewrite LDk; [exact H8 | cbn; lia |].
      pose proof mo_range. unfold OFS_GFXY, O_INTERACT_STATUS, RAW_OFF. lia.
    Qed.
  End ObjStore.

  Lemma gso_t : forall (x y : ident) (v : val) le, x <> y -> (PTree.set y v le) ! x = le ! x.
  Proof. intros. apply PTree.gso. assumption. Qed.

  Lemma gro_t : forall (i j : ident) (le : temp_env), i <> j ->
    (PTree.remove j le) ! i = le ! i.
  Proof. intros. apply PTree.gro. assumption. Qed.

  Ltac ids_ne := apply Pos.eqb_neq; vm_compute; reflexivity.

  Lemma add_small : forall mo k, 0 <= k ->
    Ptrofs.unsigned mo + k < Ptrofs.modulus ->
    Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr k)) = Ptrofs.unsigned mo + k.
  Proof.
    intros mo k Hk Hm. pose proof (Ptrofs.unsigned_range mo).
    rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr k)
      by (unfold Ptrofs.max_unsigned; lia).
    apply Ptrofs.unsigned_repr. unfold Ptrofs.max_unsigned. lia.
  Qed.

  (* the flags block: one 16-bit store into Mario's object at offset 2 *)
  Lemma blk_flags_eff : forall le m t le' m' out,
    MWF m -> exec_stmt function_entry2 ge empty_env le m blk_flags_t t le' m' out ->
    exists mb mo vv le5 a1 a2,
      Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo)
      /\ Mem.store Mint16signed m mb (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 2))) vv = Some m'
      /\ le5 ! mario._t'49 = Some (Vptr mb mo)
      /\ (forall i, In i (temps_of a1 ++ temps_of a2) -> i <> mario._t'13)
      /\ RealFrameValue.prov_ok (Sassign a1 a2)
      /\ exec_stmt function_entry2 ge empty_env le5 m (Sassign a1 a2) t le' m' out.
  Proof.
    intros le m t le' m' out HM H. unfold blk_flags_t in H.
    apply seq_set_inv in H as (v48 & E48 & H).
    apply seq_set_inv in H as (v49 & E49 & H).
    apply seq_set_inv in H as (v50 & E50 & H).
    apply seq_set_inv in H as (v51 & E51 & H).
    apply seq_set_inv in H as (v52 & E52 & H).
    pose proof H as Hx. inv H.
    destruct mario_offsets as (O1 & O2 & O3 & O4 & O5 & O6).
    match goal with Hl : eval_lvalue _ _ _ _ _ ?loc ?ofs ?bf, Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      rename Hl into L4; rename Ha into HA end.
    destruct (lv_field _ _ _ _ _ _ _ _ _ _ L4 eq_refl O4) as (o3 & E3 & -> & ->).
    destruct (ex_agg _ _ _ _ _ E3 (or_intror eq_refl) I) as (bf3 & L3).
    destruct (lv_field _ _ _ _ _ _ _ _ _ _ L3 eq_refl O3) as (o2 & E2 & -> & _).
    destruct (ex_agg _ _ _ _ _ E2 (or_intror eq_refl) I) as (bf2 & L2).
    destruct (lv_field _ _ _ _ _ _ _ _ _ _ L2 eq_refl O2) as (o1 & E1 & -> & _).
    destruct (ex_agg _ _ _ _ _ E1 (or_intror eq_refl) I) as (bf1 & L1).
    destruct (lv_field _ _ _ _ _ _ _ _ _ _ L1 eq_refl O1) as (o0 & E0 & -> & _).
    destruct (ex_agg _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof L0 as H49.
    rewrite !gso_t in L0 by ids_ne. rewrite PTree.gss in L0. injection L0 as Hv49.
    pose proof (mobj_of_tmp _ _ _ _ _ _ _ HM E48 E49 Hv49) as Hmo.
    cbn [fst snd] in *.
    inv HA; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    change (Ptrofs.repr 0) with Ptrofs.zero in *. rewrite !Ptrofs.add_zero in *.
    do 6 eexists. split; [exact Hmo |]. split; [eassumption |]. split; [exact H49 |].
    split; [| split; [left; split; reflexivity | exact Hx]].
    cbn [temps_of app]. intros i [<- | [<- | []]]; ids_ne.
  Qed.

  (* the status block: oInteractStatus = 0, a 32-bit store at rawData + 4*43 *)
  Lemma blk_status_eff : forall le m t le' m' out,
    MWF m -> exec_stmt function_entry2 ge empty_env le m blk_status_t t le' m' out ->
    exists mb mo le5 a1 a2,
      Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo)
      /\ Mem.store Mint32 m mb
           (Ptrofs.unsigned (Ptrofs.add (Ptrofs.add mo (Ptrofs.repr 136))
                                        (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 43)))))
           (Vint Int.zero) = Some m'
      /\ le5 ! mario._t'13 = Some (Vptr mb mo)
      /\ (forall i, In i (temps_of a1 ++ temps_of a2) -> i <> mario._t'49)
      /\ RealFrameValue.prov_ok (Sassign a1 a2)
      /\ exec_stmt function_entry2 ge empty_env le5 m (Sassign a1 a2) t le' m' out.
  Proof.
    intros le m t le' m' out HM H. unfold blk_status_t in H.
    apply seq_set_inv in H as (v12 & E12 & H).
    apply seq_set_inv in H as (v13 & E13 & H).
    pose proof H as Hx. inv H.
    destruct mario_offsets as (O1 & O2 & O3 & O4 & O5 & O6).
    match goal with Hl : eval_lvalue _ _ _ _ _ ?loc ?ofs ?bf, Ha : assign_loc _ _ _ _ _ _ _ _,
                    Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      rename Hl into LD0; rename Ha into HA; rename Hc into HC end.
    inv LD0.
    match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv He end;
      [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
    repeat match goal with Hc : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hc; try match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                    solve [inv Hl] end end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) ?va |- _ => rename He into EA end.
    apply eval_expr_Efield_load in EA as (la & oa & bfa & LA & DA).
    destruct (lv_ufield _ _ _ _ _ _ _ _ _ _ LA eq_refl O6) as (o5 & E5 & Ho5 & Hbfa).
    cbn [snd] in Hbfa. subst bfa.
    inv DA; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    destruct (ex_agg _ _ _ _ _ E5 (or_intror eq_refl) I) as (bf5 & L5).
    destruct (lv_field _ _ _ _ _ _ _ _ _ _ L5 eq_refl O5) as (o0 & E0 & Ho0 & _).
    destruct (ex_agg _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof L0 as H13.
    rewrite PTree.gss in L0. injection L0 as Hv13.
    pose proof (mobj_of_tmp _ _ _ _ _ _ _ HM E12 E13 Hv13) as Hmo.
    cbn [fst snd] in *. subst.
    match goal with Hop : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
      cbn in Hop; injection Hop as <- <- end.
    cbn in HC. injection HC as <-.
    inv HA; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    change (Ptrofs.repr 0) with Ptrofs.zero in *. rewrite !Ptrofs.add_zero in *.
    do 5 eexists. split; [exact Hmo |]. split; [eassumption |]. split; [exact H13 |].
    split; [| split; [right; split; reflexivity | exact Hx]].
    cbn [temps_of app]. intros i [<- | []]; ids_ne.
  Qed.

  (* ---- the two store blocks keep the frame state ---- *)
  (* GOAL 1's statement-level facts (frame_call_ok_linked12) and the SafeB
     facts the twelve-TU capstone derives from SafeB_syms_ok *)
  Hypothesis Hchase : chase_safe_stmt bm SafeB MWF.
  Hypothesis Hstore : store_safe_stmt lp bm SafeB MWF.
  Hypothesis HnsBM : ~ SafeB bm.
  Hypothesis HnsAB : forall ab, Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab -> ~ SafeB ab.
  Hypothesis HnsBC : forall m bc oc, MWF m -> Mem.load Mptr m bm 156 = Some (Vptr bc oc) -> ~ SafeB bc.

  Lemma mobj_safe : forall m mb mo, MWF m ->
    Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo) -> SafeB mb.
  Proof.
    intros m mb mo HM Hmo.
    assert (Hlv : Mem.loadv Mptr m (Vptr bm (Ptrofs.repr 136)) = Some (Vptr mb mo)) by exact Hmo.
    exact (Hchase 136 m mb mo marioObj_offset_mario HM Hlv).
  Qed.

  Lemma obj_store_FS : forall c0 m m' ch lo v mb mo,
    budget_ok c0 -> FS c0 m -> mem_ok m' ->
    Mem.store ch m mb lo v = Some m' ->
    Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo) ->
    (lo = Ptrofs.unsigned mo + 2 /\ ch = Mint16signed)
      \/ (lo = Ptrofs.unsigned mo + O_INTERACT_STATUS /\ ch = Mint32) ->
    (exists s', Mem.load Mint32 m' mb (Ptrofs.unsigned mo + O_INTERACT_STATUS) = Some (Vint s')
                /\ Int.and s' (Int.repr STOMP_BITS) = Int.zero) ->
    FS c0 m'.
  Proof.
    intros c0 m m' ch lo v mb mo Hb HF Hok' Hst Hmo Hlo Hstat.
    destruct HF as (Hok & Hw & Hcells).
    pose proof (proj2 (proj2 Hok)) as HM.
    pose proof (mobj_safe m mb mo HM Hmo) as Hsafe.
    assert (Hmb : mb <> bm) by (intros ->; exact (HnsBM Hsafe)).
    assert (Hab : forall ab, Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab -> ab <> mb)
      by (intros ab Hab ->; exact (HnsAB mb Hab Hsafe)).
    assert (Hbc : forall bc oc, Mem.load Mptr m bm 156 = Some (Vptr bc oc) -> bc <> mb)
      by (intros bc oc Hl ->; exact (HnsBC m mb oc HM Hl Hsafe)).
    apply (chain_step c0 m m'); [ | exact Hb | exact (conj Hok (conj Hw Hcells)) | exact Hok' ].
    intros c Hrc _. split.
    - exact (obj_store_fworld m m' ch lo v mb mo Hst Hmo Hmb Hlo Hstat Hab Hbc Hw).
    - exists c. split; [exact (obj_store_cells m m' ch lo v mb mo Hst Hmo Hmb Hlo c Hrc) |].
      apply rt_refl.
  Qed.

  Lemma store_mem_ok : forall m m' ch lo v mb a1 a2 le0 t out,
    mem_ok m -> Mem.store ch m mb lo v = Some m' -> mb <> bm ->
    RealFrameValue.prov_ok (Sassign a1 a2) ->
    (forall b o, le0 ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
    (forall b o, le0 ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
    exec_stmt function_entry2 ge empty_env le0 m (Sassign a1 a2) t le0 m' out ->
    mem_ok m'.
  Proof.
    intros m m' ch lo v mb a1 a2 le0 t out (Hv & Hnt & HM) Hst Hmb Hprov H49 H13 Hx.
    destruct (Hstore empty_env le0 m a1 a2 t le0 m' out (Hnoa m HM) HM Hprov H49 H13 Hx)
      as (_ & HM').
    split; [exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hst _ Hv) |].
    split; [| exact HM'].
    intros v1 Hl. apply Hnt.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hl; [exact Hl | left; congruence].
  Qed.

  Lemma oblk_flags_ok : forall c0, budget_ok c0 ->
    obl_ok ge mario._gMarioState tyMSp (FS c0) (OBlk blk_flags_t).
  Proof.
    intros c0 Hb. cbn [obl_ok]. intros le m t le' m' out HF Hx.
    pose proof HF as (Hok & (_ & Hw & _ & Hmob & _) & _).
    pose proof (proj2 (proj2 Hok)) as HM.
    destruct (blk_flags_eff le m t le' m' out HM Hx)
      as (mb & mo & vv & le5 & a1 & a2 & Hmo & Hst & H49 & Ht & Hprov & Hasg).
    pose proof (mobj_safe m mb mo HM Hmo) as Hsafe.
    destruct (Hmob mb mo Hmo) as (Hmod & _ & _).
    rewrite add_small in Hst by (unfold OBJ_SIZE in Hmod; lia).
    pose proof (exec_assign_agree _ _ (PTree.remove mario._t'13 le5) _ _ _ _ _ _ _ Hasg
                  (fun i Hi => gro_t _ _ _ (Ht i Hi))) as Hasg0.
    assert (Hok' : mem_ok m').
    { refine (store_mem_ok m m' _ _ _ mb a1 a2 _ _ _ Hok Hst _ Hprov _ _ Hasg0).
      - intros ->. exact (HnsBM Hsafe).
      - intros b o Hl. rewrite PTree.gro in Hl by ids_ne. rewrite H49 in Hl.
        injection Hl as <- _. exact Hsafe.
      - intros b o Hl. rewrite PTree.grs in Hl. discriminate Hl. }
    refine (obj_store_FS c0 m m' _ _ _ mb mo Hb HF Hok' Hst Hmo (or_introl (conj eq_refl eq_refl)) _).
    destruct Hw as (_ & _ & _ & _ & _ & _ & mb' & mo' & s0 & n & Hl & Hs & Hz & _).
    rewrite Hmo in Hl. injection Hl as E1 E2. subst mb' mo'.
    exists s0. split; [| exact Hz].
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hst); [exact Hs |].
    right. right. cbn [size_chunk]. unfold O_INTERACT_STATUS, RAW_OFF. lia.
  Qed.

  Lemma oblk_status_ok : forall c0, budget_ok c0 ->
    obl_ok ge mario._gMarioState tyMSp (FS c0) (OBlk blk_status_t).
  Proof.
    intros c0 Hb. cbn [obl_ok]. intros le m t le' m' out HF Hx.
    pose proof HF as (Hok & (_ & _ & _ & Hmob & _) & _).
    pose proof (proj2 (proj2 Hok)) as HM.
    destruct (blk_status_eff le m t le' m' out HM Hx)
      as (mb & mo & le5 & a1 & a2 & Hmo & Hst & H13 & Ht & Hprov & Hasg).
    pose proof (mobj_safe m mb mo HM Hmo) as Hsafe.
    destruct (Hmob mb mo Hmo) as (Hmod & _ & _).
    assert (E172 : Ptrofs.unsigned (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 43))) = 172)
      by (vm_compute; reflexivity).
    assert (Hoff : Ptrofs.unsigned (Ptrofs.add (Ptrofs.add mo (Ptrofs.repr 136))
                     (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 43))))
                   = Ptrofs.unsigned mo + O_INTERACT_STATUS).
    { pose proof (Ptrofs.unsigned_range mo).
      rewrite Ptrofs.add_unsigned, E172, add_small by (unfold OBJ_SIZE in Hmod; lia).
      rewrite Ptrofs.unsigned_repr; [unfold O_INTERACT_STATUS, RAW_OFF; lia |].
      unfold Ptrofs.max_unsigned, OBJ_SIZE in *. lia. }
    rewrite Hoff in Hst.
    pose proof (exec_assign_agree _ _ (PTree.remove mario._t'49 le5) _ _ _ _ _ _ _ Hasg
                  (fun i Hi => gro_t _ _ _ (Ht i Hi))) as Hasg0.
    assert (Hok' : mem_ok m').
    { refine (store_mem_ok m m' _ _ _ mb a1 a2 _ _ _ Hok Hst _ Hprov _ _ Hasg0).
      - intros ->. exact (HnsBM Hsafe).
      - intros b o Hl. rewrite PTree.grs in Hl. discriminate Hl.
      - intros b o Hl. rewrite PTree.gro in Hl by ids_ne. rewrite H13 in Hl.
        injection Hl as <- _. exact Hsafe. }
    refine (obj_store_FS c0 m m' _ _ _ mb mo Hb HF Hok' Hst Hmo (or_intror (conj eq_refl eq_refl)) _).
    exists Int.zero. split; [exact (Mem.load_store_same _ _ _ _ _ _ Hst) |].
    apply Int.and_zero_l.
  Qed.

  (* ======================================================================= *)
  (* THE SPLIT: one real execute_mario_action keeps the frame state when     *)
  (* every call in its body does (the two store blocks are proved above).    *)
  (* ======================================================================= *)
  Definition seg_call_rows : Prop :=
    forall f fd v, In (OCall f) ema_obls -> resolves f fd -> seg_ok fd [v] (gms_val v).

  Definition seg_any_rows : Prop :=
    forall f fty al fd vargs, In (OAny f fty al) ema_obls -> resolves f fd ->
      seg_ok fd vargs (fun _ => True).

  Theorem frame_split : forall c0 m vargs t m' vr,
    seg_call_rows -> seg_any_rows ->
    budget_ok c0 -> FS c0 m ->
    eval_funcall function_entry2 ge m (Internal mario.f_execute_mario_action) vargs t m' vr ->
    FS c0 m'.
  Proof.
    intros c0 m vargs t m' vr Hrc Hra Hb HF Hev.
    refine (funcall_safe ge mario._gMarioState tyMSp (FS c0) mario.f_execute_mario_action
              ema_obls vargs m t m' vr eq_refl ema_cl _ HF Hev).
    apply Forall_forall. intros [f | f fty al | st] Hin.
    - exact (ocall_ok c0 f Hb Hin (fun fd v Hr => Hrc f fd v Hin Hr)).
    - exact (oany_ok c0 f fty al Hb Hin (fun fd vargs' Hr => Hra f fty al fd vargs' Hin Hr)).
    - assert (Hs : In st ema_blks).
      { unfold ema_blks. apply in_flat_map. exists (OBlk st). split; [exact Hin | left; reflexivity]. }
      rewrite ema_blks_eq in Hs. destruct Hs as [<- | [<- | []]].
      + exact (oblk_flags_ok c0 Hb).
      + exact (oblk_status_ok c0 Hb).
  Qed.

End FrameSplit.
