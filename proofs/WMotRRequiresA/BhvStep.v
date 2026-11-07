(* spine-root: B3 (iii), the cur_obj_update stepper's control layer -- the
   VM successor relation BhvVM.succs (obj_w's ow_vm census) tied to the
   generated handler bodies of the ten control opcodes. *)
(* ======================================================================= *)
(* BhvStep.v -- the behavior-script VM, run by its real handlers           *)
(*                                                                         *)
(* BhvVM computes the 741 reachable states (script, word, stack) from the *)
(* MACRO layouts of the commands; ow_vm says every live slot's cells are  *)
(* one of them.  Until now nothing tied a VM step to the C: the census    *)
(* was a model.  Here each control opcode's generated handler             *)
(* (behavior_script.c: CALL 0x02, RETURN 0x03, GOTO 0x04, BEGIN_REPEAT    *)
(* 0x05, END_REPEAT 0x06, END_REPEAT_CONTINUE 0x07, BEGIN_LOOP 0x08,      *)
(* END_LOOP 0x09, BREAK 0x0A, BREAK_UNUSED 0x0B) is run in Clight, in the *)
(* linked program (cur_obj_bhv_stack_push / _pop and                      *)
(* segmented_to_virtual's real bodies included), from a reachable state   *)
(* whose cells (gCurBhvCommand; the slot's bhvStackIndex / bhvStack) hold *)
(* it: the run lands on one of BhvVM.succs's successors, returns the      *)
(* handler's code (0 = keep dispatching, 1 = end the frame), and writes   *)
(* nothing outside gCurBhvCommand and the slot's stack cells (ctl_step).  *)
(*                                                                         *)
(* PHANTOM / TRUTH CHECK.  The state ranges over vm_tab only (the         *)
(* reachable states, not all states), and the cells are the real slot's   *)
(* (vmc: the same shape as ObjWorld.vm_ok, with gCurBhvCommand for the    *)
(* slot's curBhvCommand, as cur_obj_update copies it before the loop).    *)
(* The premises are facts the object world carries or the link gives:     *)
(*  - scr_ok: the reachable scripts' blocks hold their initializers.  The *)
(*    scripts are writable globals in C, so this is a premise here; it is *)
(*    obj_w's clause ow_scr (ObjWorld 3d, 2026-11-03, boot vm check);  *)
(*  - gCurrentObject = the slot; the slot pool is not a script block and  *)
(*    not gCurBhvCommand (distinct symbols in the link).                  *)
(* Every handler result is an existential over the VM's own successor     *)
(* list, so the VM's two-way branches (END_REPEAT: back to the loop head  *)
(* or past it) are each witnessed by the C's branch, not assumed.         *)
(* Mario's pos[0] / pos[2] (the death-plane carry, goal item 4): none of  *)
(* these handlers writes them (Pfr: they write only gCurBhvCommand and    *)
(* the slot's stack index / stack / delay timer cells).                   *)
(*                                                                         *)
(* DELAY (0x01) is in ctl_step too (2026-11-02).                          *)
(*                                                                         *)
(* THE DISPATCH LOOP (dloop / dloop_ctl): cur_obj_update's real loop      *)
(* (dloop_is_real: DLOOP is the first loop of the generated body) reads   *)
(* the word, indexes BehaviorCmdTable (obj_w's cmdtab_ok), calls the     *)
(* handler, and repeats while it returns 0.  From a reachable state whose *)
(* cells hold it, under an invariant INV (carrying scr_ok + cmdtab_ok),   *)
(* it ends at a reachable state whose cells hold it -- given one row per  *)
(* opcode (cmd_row_op).  ctl_rows DISCHARGES the rows of the 11 control   *)
(* opcodes (INV stable under the control handlers' footprint Pfr, and    *)
(* carrying gCurrentObject); the open rows are the other opcodes          *)
(* (dloop_ctl's premise).                                                 *)
(* OPEN (the rest of B3 iii): the advancing commands (cmd += cmd_len),    *)
(* DELAY_VAR, DEACTIVATE, CALL_NATIVE's callees; the dispatch           *)
(* loop of cur_obj_update; then narrowing                               *)
(* Hobj_step_rest by it.                                                  *)
(* ======================================================================= *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require behavior_script memory behavior_data object_helpers
  object_list_processor area behavior_actions graph_node surface_collision.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM BehaviorScripts.
From SM64.Proofs.MarioModel Require SpawnBodies.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjWorld ObjPhase ObjLoop ObjCensus PlatformWalk BoxCensus
  ObjSelf ObjFrame FpuFloor ObjAlloc.
From SM64.Proofs.WMotRRequiresA Require ObjCreate ObjMake ObjGeo ObjOrigin ObjCopy ObjChild ObjDroplet ObjAnimate FloorList ObjFloorH EnvSwap ObjFamily.
Import ListNotations.
Local Open Scope Z_scope.

Module BS := SM64.Generated.behavior_script.
Module OW := ObjWorld.
Module RA := RenderAnim.
Module OH := SM64.Generated.object_helpers.

(* ---- 1. VM bookkeeping ---- *)
Lemma frame_eqb_eq : forall a b, frame_eqb a b = true -> a = b.
Proof.
  intros [s i|] [s' i'|] H; cbn in H; try discriminate; [ | reflexivity ].
  apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. apply Nat.eqb_eq in H2. subst. reflexivity.
Qed.
Lemma stk_eqb_eq : forall a b, stk_eqb a b = true -> a = b.
Proof.
  induction a as [| x a IH]; intros [| y b] H; cbn in H; try discriminate; [ reflexivity | ].
  apply andb_prop in H as [H1 H2]. rewrite (frame_eqb_eq _ _ H1), (IH _ H2). reflexivity.
Qed.
Lemma vst_eqb_eq : forall a b, vst_eqb a b = true -> a = b.
Proof.
  intros [s i k] [s' i' k'] H. unfold vst_eqb in H. cbn in H.
  apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply Pos.eqb_eq in H1. apply Nat.eqb_eq in H2. rewrite (stk_eqb_eq _ _ H3). subst. reflexivity.
Qed.
Lemma memv_in : forall x l, memv x l = true -> In x l.
Proof.
  intros x l H. unfold memv in H. apply existsb_exists in H as (y & Hy & E).
  rewrite (vst_eqb_eq _ _ E). exact Hy.
Qed.

Lemma vm_succ_in : forall st l st', In st vm_tab -> succs st = Some l -> In st' l -> In st' vm_tab.
Proof.
  intros st l st' Hst Hs Hin. pose proof vm_tab_closed as C.
  rewrite forallb_forall in C. specialize (C st Hst). rewrite Hs in C.
  rewrite forallb_forall in C. exact (memv_in _ _ (C st' Hin)).
Qed.

(* ---- 2. the script content (ObjWorld.scr_ok, obj_w's ow_scr since
   2026-11-03: the script blocks hold their initializers) and the VM
   cells ---- *)
Notation init_val := OW.init_val (only parsing).
Notation scr_ok := OW.scr_ok (only parsing).
Section Cells.
  Variable G : genv.

  Variables bc pool : block.
  Variable oc : Z.

  (* the VM state st, while cur_obj_update dispatches: the command pointer
     is the global gCurBhvCommand, the stack is the slot's *)
  Definition vmc (m : mem) (st : vst) : Prop :=
    (exists b, Genv.find_symbol G (v_s st) = Some b
       /\ Mem.load Mint32 m bc 0 = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st)))))
    /\ Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr (Z.of_nat (List.length (v_k st)))))
    /\ forall n f, nth_error (v_k st) n = Some f ->
         OW.frame_ok G f (Mem.load Mint32 m pool
                            (oc + OW.O_STK + 4 * (Z.of_nat (List.length (v_k st)) - 1 - Z.of_nat n))).
End Cells.

(* ---- 2b. scr_ok as a checkable clause: MOVED to ObjWorld (3d) on
   2026-11-03, where it is obj_w's clause ow_scr, vm-checked at boot
   inside ow_chk; the names here are kept as notations ---- *)
Notation sdedup := OW.sdedup (only parsing).
Notation sdedup_in := OW.sdedup_in (only parsing).
Notation cell_b := OW.scell_b (only parsing).
Notation cells_b := OW.scells_b (only parsing).
Notation scr_b_l := OW.scr_b_l (only parsing).
Notation cell_b_sound := OW.scell_b_sound (only parsing).
Notation cells_b_sound := OW.scells_b_sound (only parsing).
Notation scr_b_l_sound := OW.scr_b_l_sound (only parsing).
Notation scr_b_sound := OW.scr_b_sound (only parsing).

(* ---- 3. function entry for a body without locals ---- *)
Lemma fcall_inv : forall (G : genv) f m vargs t m' vr, fn_vars f = [] ->
  eval_funcall function_entry2 G m (Internal f) vargs t m' vr ->
  exists le le' out, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le
    /\ exec_stmt function_entry2 G empty_env le m (fn_body f) t le' m' out
    /\ outcome_result_value out (fn_return f) vr m'.
Proof.
  intros G f m vargs t m' vr Hv H.
  remember (Internal f) as fd eqn:Efd.
  destruct H as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
    [ injection Efd as <- | discriminate Efd ].
  destruct Hfe as [_ _ _ Hav Hb]. rewrite Hv in Hav. inversion Hav; subst.
  cbn in Hfr. injection Hfr as <-.
  exists lea, leb, oo. auto.
Qed.

(* ---- 4. small expression facts ---- *)
Section EV.
  Variable ge : genv.
  Variable e : env.
  Variable m : mem.

  (* p->arr, p a temp, arr an array field: its address *)
  Lemma ev_fld_arr : forall le x S f ty n v d,
    (forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full)) ->
    eval_expr ge e le m (Efield (Ederef (Etempvar x (tptr (Tstruct S noattr))) (Tstruct S noattr)) f (tarray ty n)) v ->
    exists b o, le ! x = Some (Vptr b o) /\ v = Vptr b (Ptrofs.add o (Ptrofs.repr d)).
  Proof.
    intros le x S f ty n v d Hfo H.
    inv H. match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
    all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
      rewrite (Hfo _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    cbn [typeof] in *.
    match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
      cbn in *; try discriminate.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    match goal with Hd : deref_loc (tarray _ _) _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
    eauto.
  Qed.

  (* *a as an lvalue *)
  Lemma lv_deref : forall le a ty b o bf, eval_lvalue ge e le m (Ederef a ty) b o bf ->
    eval_expr ge e le m a (Vptr b o) /\ bf = Full.
  Proof. intros le a ty b o bf H. inv H. auto. Qed.

  Lemma ev_deref : forall le a ty ch v, access_mode ty = By_value ch ->
    eval_expr ge e le m (Ederef a ty) v ->
    exists b o, eval_expr ge e le m a (Vptr b o) /\ Mem.loadv ch m (Vptr b o) = Some v.
  Proof.
    intros le a ty ch v Ham H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn [typeof] in *; try congruence.
    repeat match goal with H1 : access_mode _ = By_value ?c |- _ =>
      tryif constr_eq H1 Ham then fail else (rewrite Ham in H1; injection H1; intros; subst; clear H1) end.
    eauto.
  Qed.

  (* a.f, a of struct type, as an lvalue *)
  Lemma lv_sfld : forall le a S f ty b o bf d,
    eval_lvalue ge e le m (Efield a f ty) b o bf -> typeof a = Tstruct S noattr ->
    (forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full)) ->
    exists o0, eval_expr ge e le m a (Vptr b o0) /\ o = Ptrofs.add o0 (Ptrofs.repr d) /\ bf = Full.
  Proof.
    intros le a S f ty b o bf d H Ht Hfo. inv H.
    - match goal with Ht' : typeof a = Tstruct _ _ |- _ => rewrite Ht in Ht'; injection Ht'; intros; subst end.
      match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
        rewrite (Hfo _ Hc) in Hf; injection Hf; intros; subst end.
      eauto.
    - match goal with Ht' : typeof a = Tunion _ _ |- _ => rewrite Ht in Ht'; discriminate Ht' end.
  Qed.

  (* a struct-typed a.f as an rvalue is its address *)
  Lemma ev_sfld : forall le a f S v, eval_expr ge e le m (Efield a f (Tstruct S noattr)) v ->
    exists b o, v = Vptr b o /\ eval_lvalue ge e le m (Efield a f (Tstruct S noattr)) b o Full.
  Proof.
    intros le a f S v H. inv H.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
      try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
    eauto.
  Qed.

  Lemma ev_lv_fld : forall le a f ty v, eval_expr ge e le m (Efield a f ty) v ->
    exists b o bf, eval_lvalue ge e le m (Efield a f ty) b o bf /\ deref_loc ty m b o bf v.
  Proof. intros le a f ty v H. inv H. eauto. Qed.

  Lemma deref_full : forall ty b o v ch, access_mode ty = By_value ch ->
    deref_loc ty m b o Full v -> Mem.loadv ch m (Vptr b o) = Some v.
  Proof. intros ty b o v ch Ha H. inv H; congruence. Qed.

  Lemma ev_unop : forall le op a ty v, eval_expr ge e le m (Eunop op a ty) v ->
    exists v1, eval_expr ge e le m a v1 /\ sem_unary_operation op v1 (typeof a) m = Some v.
  Proof.
    intros le op a ty v H. inv H; [ eauto | ].
    match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end.
  Qed.
End EV.

(* the offset of the (only) Ptrofs.repr in H, normalized to v *)
Ltac norm_off H v := match type of H with context [Ptrofs.repr ?X] => replace X with v in H by lia end.

Ltac kill_sq H1 Hn := exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ H1 eq_refl)).

Lemma uadd : forall a b, 0 <= a -> 0 <= b -> a + b <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr b)) = a + b.
Proof.
  intros a b Ha Hb H. rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr a), (Ptrofs.unsigned_repr b) by lia.
  apply Ptrofs.unsigned_repr. lia.
Qed.

Lemma maxu : Ptrofs.max_unsigned = 4294967295.
Proof. reflexivity. Qed.

(* ---- 5. the VM side: per-state facts and each control opcode's successors ---- *)
Lemma vm_aux : forallb (fun st => Nat.ltb (List.length (words (v_s st))) 4096
                                  && negb (Pos.eqb (v_s st) BS._gCurBhvCommand)) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma st_facts : forall st, In st vm_tab ->
  (List.length (words (v_s st)) < 4096)%nat /\ v_s st <> BS._gCurBhvCommand
  /\ (List.length (v_k st) <= 8)%nat
  /\ exists l, succs st = Some l /\ forall st', In st' l -> In st' vm_tab.
Proof.
  intros st Hst. pose proof vm_aux as A. rewrite forallb_forall in A. specialize (A st Hst).
  apply andb_prop in A as [A1 A2]. apply Nat.ltb_lt in A1. apply negb_true_iff, Pos.eqb_neq in A2.
  pose proof vm_tab_depth as D. rewrite forallb_forall in D. specialize (D st Hst).
  unfold ok_depth in D. apply Nat.leb_le in D.
  pose proof vm_tab_closed as C. rewrite forallb_forall in C. specialize (C st Hst).
  destruct (succs st) as [l|] eqn:Es; [ | discriminate C ].
  refine (conj A1 (conj A2 (conj D (ex_intro _ l (conj eq_refl _))))).
  intros st' Hin. exact (vm_succ_in st l st' Hst Es Hin).
Qed.

(* ---- 5a. the CALL_NATIVE split (2026-11-03) ----
   SPECIAL behaviors: the ones some obj_w clause reads MORE of the slot for
   (act_ok's oAction: the jumping / exclamation boxes and the cannon;
   red_ok's counter: the hidden red-coin star; kind_ok's pole / cannon pins
   and the collision objects' angle velocities: the pole, the cannon and
   its lid), and Mario's (his natives run on his own object).  sp_scripts:
   every script a VM state reachable from a special behavior's entries
   runs in.  A CALL_NATIVE at a state OUTSIDE sp_scripts whose callee is
   in nat_bulk is discharged by the precise frame (ObjFrame 5b) plus one
   keep (sfr_keep); every other one is the named residual (native_res). *)
Definition sp_bhvs : list ident :=
  [behavior_data._bhvPoleGrabbing; behavior_data._bhvCannon; behavior_data._bhvJumpingBox;
   behavior_data._bhvExclamationBox; behavior_data._bhvCannonClosed;
   behavior_data._bhvHiddenRedCoinStar; behavior_data._bhvMario].
Definition sp_states : list vst := opt_list (explore 100000 (flat_map entries sp_bhvs) []).
Definition sp_scripts : list ident := map v_s sp_states.

Definition cn_st (st : vst) : list ident :=
  if opc st =? 12 then
    match nth_error (words (v_s st)) (v_i st + 1) with Some (Init_addrof t _) => [t] | _ => [] end
  else [].
Fixpoint idd (l : list ident) : list ident :=
  match l with [] => [] | x :: l' => if existsb (Pos.eqb x) l' then idd l' else x :: idd l' end.

(* the natives the generic states call, and the nullary SFR'-clean ones *)
Definition cn_gen : list ident :=
  idd (flat_map cn_st (filter (fun st => negb (existsb (Pos.eqb (v_s st)) sp_scripts)) vm_tab)).
Definition cn_sp : list ident := idd (flat_map cn_st sp_states).
Definition has_null (x : ident) (t : list ObjFrame.s_cand) : bool :=
  existsb (fun c => let '(f, _, ks) := c in Pos.eqb f x && match ks with [] => true | _ => false end) t.
Definition nat_bulk : list ident := filter (fun x => has_null x ObjFrame.self_tab_n) cn_gen.
Definition nat_res_gen : list ident := filter (fun x => negb (has_null x ObjFrame.self_tab_n)) cn_gen.

Lemma has_null_in : forall x t, has_null x t = true -> exists i, In (x, i, @nil ObjSelf.skind) t.
Proof.
  intros x t H. unfold has_null in H. apply existsb_exists in H as ([[f i] ks] & Hin & E).
  apply andb_prop in E as [E1 E2]. apply Pos.eqb_eq in E1. subst f.
  destruct ks; [ exists i; exact Hin | discriminate E2 ].
Qed.

(* the census: 107 live natives = 94 called from generic states (35 bulk,
   59 residual) + 13 from special states (residual), disjoint *)
Lemma cn_census : (List.length cn_gen, List.length nat_bulk, List.length nat_res_gen, List.length cn_sp,
                   forallb (fun x => negb (existsb (Pos.eqb x) cn_sp)) cn_gen)
                  = (94%nat, 35%nat, 59%nat, 13%nat, true).
Proof. vm_compute. reflexivity. Qed.

Lemma bc_not_allow : existsb (Pos.eqb BS._gCurBhvCommand) ObjFrame.allow_n = false.
Proof. vm_compute. reflexivity. Qed.

Lemma tgt_ok : forall s i t j, target_at s i = Some (t, j) ->
  exists o, nth_error (words s) i = Some (Init_addrof t o) /\ o = Ptrofs.repr (4 * Z.of_nat j).
Proof.
  intros s i t j H. unfold target_at in H.
  destruct (nth_error (words s) i) as [d|]; [ | discriminate H ].
  destruct d as [ | | | | | | | tt o ]; try discriminate H.
  destruct ((Ptrofs.unsigned o mod 4 =? 0) && negb (Nat.eqb (List.length (words tt)) 0)) eqn:Ec;
    [ | discriminate H ].
  injection H as <- <-. exists o. split; [ reflexivity | ].
  apply andb_prop in Ec as [Ec _]. apply Z.eqb_eq in Ec.
  pose proof (Ptrofs.unsigned_range o) as R.
  rewrite Z2Nat.id by (apply Z.div_pos; lia).
  rewrite <- (Z_div_exact_full_2 (Ptrofs.unsigned o) 4) by (lia || exact Ec).
  symmetry. apply Ptrofs.repr_unsigned.
Qed.

Definition at_ (st : vst) (s : ident) (i : nat) (k : list frame) : vst :=
  {| v_s := s; v_i := i; v_k := k |}.

Lemma succs_goto : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 4 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    match target_at (v_s st) (v_i st + 1) with
    | Some (t, j) => Some [at_ st t j (v_k st)] | None => None end.
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_call : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 2 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    match target_at (v_s st) (v_i st + 1) with
    | Some (t, j) => Some [at_ st t j (FAddr (v_s st) (v_i st + 2) :: v_k st)] | None => None end.
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_return : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 3 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    match v_k st with FAddr t j :: k' => Some [at_ st t j k'] | _ => None end.
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_begin_loop : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 8 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (FAddr (v_s st) (v_i st + 1) :: v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_end_loop : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 9 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    match v_k st with FAddr t j :: k' => Some [at_ st t j (FAddr t j :: k')] | _ => None end.
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_begin_repeat : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 5 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (FCount :: FAddr (v_s st) (v_i st + 1) :: v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_end_repeat : forall st w, word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 6 \/ Z.shiftr w 24 = 7 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    match v_k st with
    | FCount :: FAddr t j :: k' =>
        Some [at_ st t j (FCount :: FAddr t j :: k'); at_ st (v_s st) (v_i st + 1) k']
    | _ => None
    end.
Proof. intros st w Hw [Ho | Ho]; unfold succs; cbv zeta; rewrite Hw, Ho; reflexivity. Qed.

Lemma succs_break : forall st w, word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 10 \/ Z.shiftr w 24 = 11 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else Some [st].
Proof. intros st w Hw [Ho | Ho]; unfold succs; cbv zeta; rewrite Hw, Ho; reflexivity. Qed.

Lemma succs_deact : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 29 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else Some [st].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_delay : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 1 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [st; at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_delay_var : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 37 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [st; at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_add_int : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 15 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_add_float : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 13 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_or_int : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 17 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_set_int : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 16 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_set_float : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 14 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* the field byte of a field command, as the handler computes it *)
Lemma fld_eq : forall n,
  Int.signed (Int.zero_ext 8 (Int.zero_ext 8 (Int.and (Int.shru n (Int.repr 16)) (Int.repr 255))))
  = byte2 (Int.unsigned n).
Proof.
  intros n.
  assert (E : Int.and (Int.shru n (Int.repr 16)) (Int.repr 255) = Int.zero_ext 8 (Int.shru n (Int.repr 16)))
    by (rewrite Int.zero_ext_and by lia; reflexivity).
  rewrite E, !Int.zero_ext_idem by lia.
  assert (U : Int.unsigned (Int.zero_ext 8 (Int.shru n (Int.repr 16))) = byte2 (Int.unsigned n)).
  { rewrite Int.zero_ext_mod by (cbn; lia). rewrite Int.shru_div_two_p.
    change (Int.unsigned (Int.repr 16)) with 16. change (two_p 16) with 65536. change (two_p 8) with 256.
    pose proof (Int.unsigned_range n) as R. change Int.modulus with 4294967296 in R.
    rewrite Int.unsigned_repr by (cbn; split; [ apply Z.div_pos | apply Z.div_le_upper_bound ]; lia).
    unfold byte2. rewrite Z.shiftr_div_pow2 by lia. change (2 ^ 16) with 65536.
    change 255 with (Z.ones 8). rewrite Z.land_ones by lia. reflexivity. }
  rewrite Int.signed_eq_unsigned; [ exact U | ].
  rewrite Int.zero_ext_mod by (cbn; lia). change (two_p 8) with 256.
  pose proof (Z.mod_pos_bound (Int.unsigned (Int.shru n (Int.repr 16))) 256 ltac:(lia)). cbn. lia.
Qed.

(* the field byte of a reachable field command indexes rawData[0x50] *)
Lemma fld_lt80 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  In (Z.shiftr w 24) field_ops -> 0 <= byte2 w < 80.
Proof.
  intros st w Hst Hw Hf. pose proof vm_fields_in_rawdata as A. rewrite forallb_forall in A.
  specialize (A st Hst). unfold fields_of, opc, w0 in A. rewrite Hw in A.
  assert (Ef : existsb (Z.eqb (Z.shiftr w 24)) field_ops = true)
    by (apply existsb_exists; exists (Z.shiftr w 24); split; [ exact Hf | apply Z.eqb_refl ]).
  rewrite Ef in A. cbn [forallb] in A. rewrite andb_true_r in A.
  apply andb_prop in A as [A1 A2]. apply Z.leb_le in A1. apply Z.ltb_lt in A2. lia.
Qed.

Lemma succs_sum_float : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 31 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* the three field bytes of a reachable SUM_FLOAT / SUM_INT index rawData[0x50] *)
Lemma sum_lt80 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 31 -> 0 <= byte2 w < 80 /\ 0 <= byte3 w < 80 /\ 0 <= byte4 w < 80.
Proof.
  intros st w Hst Hw Ho. pose proof vm_fields_in_rawdata as A. rewrite forallb_forall in A.
  specialize (A st Hst). unfold fields_of, opc, w0 in A. rewrite Hw in A. cbv beta iota zeta in A.
  rewrite Ho in A.
  change (existsb (Z.eqb 31) field_ops) with false in A.
  change ((31 =? 31) || (31 =? 32)) with true in A. cbv beta iota in A.
  assert (G : forall f, In f [byte2 w; byte3 w; byte4 w] -> 0 <= f < 80).
  { intros f Hf. rewrite forallb_forall in A. specialize (A f Hf). cbv beta in A.
    apply andb_prop in A as [A1 A2]. apply Z.leb_le in A1. apply Z.ltb_lt in A2. lia. }
  split; [ apply G; left; reflexivity | split; [ apply G; right; left; reflexivity | apply G; right; right; left; reflexivity ] ].
Qed.

Lemma succs_sit : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 47 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* SET_INTERACT_TYPE's argument, computed over the reachable states: the
   word after the command is an int in wmotr_interact_types -- EXCEPT
   bhvKoopaShellFlame's SET_INTERACT_TYPE(INTERACT_FLAME) (0x40000).
   FOUND (2026-11-03): the reachable VM table holds bhvKoopaShellFlame and
   INTERACT_FLAME is not in wmotr_interact_types, so obj_w's KIND clause
   would break if a flame slot ever runs; either the set grows, or the
   flame is shown absent from WMotR (the table over-approximates the spawn
   graph).  The only reachable SET_INTERACT_TYPEs (all47 in the playground
   probe): bhvBobombBuddyOpensCannon (0x800000) and this flame.
   RESOLVED (same day): BoxCensus resolves WMotR's 7 exclamation boxes from
   their real macro bparams (6 wing-cap, 1 one-up) and shows the shell and
   its flame outside the narrowed spawn closure (flame_unreached); sit_kind
   below is the KIND fact on that domain.
   PERF TRAP: stated inline (no named bool constant over vm_tab) *)
Lemma chk47_ok :
  forallb (fun st => if opc st =? 47 then
                       match word_at (v_s st) (v_i st + 1) with
                       | Some z => existsb (Z.eqb z) SM64.Proofs.WMotRRequiresA.WMotRWorld.wmotr_interact_types
                                   || (Pos.eqb (v_s st) SM64.Generated.behavior_data._bhvKoopaShellFlame
                                       && (z =? 262144))
                       | None => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sit_arg : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 47 ->
  exists z, word_at (v_s st) (v_i st + 1) = Some z
    /\ (In z SM64.Proofs.WMotRRequiresA.WMotRWorld.wmotr_interact_types
        \/ v_s st = SM64.Generated.behavior_data._bhvKoopaShellFlame /\ z = 262144).
Proof.
  intros st w Hst Hw Ho. pose proof chk47_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
  cbv beta iota in A. rewrite Ho in A. change (47 =? 47) with true in A. cbv beta iota in A.
  destruct (word_at (v_s st) (v_i st + 1)) as [z|]; [ | discriminate A ].
  exists z. split; [ reflexivity | ].
  apply orb_prop in A as [A | A].
  - left. apply existsb_exists in A as (z' & Hz' & E). apply Z.eqb_eq in E. subst z'. exact Hz'.
  - right. apply andb_prop in A as [A1 A2]. apply Pos.eqb_eq in A1. apply Z.eqb_eq in A2. split; assumption.
Qed.

(* ... and in WMotR's real spawn graph (the box contents resolved from
   the boxes' bparams, BoxCensus.wmotr_closure_b) the flame never comes
   into being, so a script of that graph sets a KIND type *)
Lemma sit_kind : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 47 ->
  In (v_s st) BoxCensus.wmotr_closure_b ->
  exists z, word_at (v_s st) (v_i st + 1) = Some z
    /\ In z SM64.Proofs.WMotRRequiresA.WMotRWorld.wmotr_interact_types.
Proof.
  intros st w Hst Hw Ho Hb. destruct (sit_arg st w Hst Hw Ho) as (z & Hz & [Hk | (Ef & _)]).
  - exists z. split; assumption.
  - exfalso. pose proof BoxCensus.flame_unreached as F. rewrite Ef in Hb.
    assert (T : existsb (Pos.eqb SM64.Generated.behavior_data._bhvKoopaShellFlame) BoxCensus.wmotr_closure_b = true)
      by (apply existsb_exists; exists SM64.Generated.behavior_data._bhvKoopaShellFlame;
          split; [ exact Hb | apply Pos.eqb_refl ]).
    rewrite T in F. discriminate F.
Qed.

(* any cast to u16 that succeeds gives a 16-bit int *)
Lemma cast_u16 : forall v t m r, sem_cast v t tushort m = Some r ->
  exists n, r = Vint n /\ 0 <= Int.unsigned n < 65536.
Proof.
  intros v t m r H.
  assert (Z : forall x, 0 <= Int.unsigned (Int.zero_ext 16 x) < 65536).
  { intros x. pose proof (Int.zero_ext_range 16 x ltac:(cbn; lia)) as R. exact R. }
  pose proof (cast_val_is_casted _ _ _ _ _ H) as C.
  inversion C; subst.
  exists n. split; [ reflexivity | ]. cbn in H2. rewrite <- H2. apply Z.
Qed.


Lemma succs_rand : forall st w, word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 19 \/ Z.shiftr w 24 = 20 \/ Z.shiftr w 24 = 21 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw [Ho | [Ho | Ho]]; unfold succs; cbv zeta; rewrite Hw, Ho; reflexivity. Qed.

(* the random setters' second word is an int at every reachable state.
   PERF TRAP: inline (no named bool over vm_tab) *)
Lemma rand_w1_ok :
  forallb (fun st => if (opc st =? 19) || (opc st =? 20) || (opc st =? 21) then
                       match word_at (v_s st) (v_i st + 1) with Some _ => true | None => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma rand_w1 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 19 \/ Z.shiftr w 24 = 20 \/ Z.shiftr w 24 = 21 ->
  exists z, word_at (v_s st) (v_i st + 1) = Some z.
Proof.
  intros st w Hst Hw Ho. pose proof rand_w1_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
  cbv beta iota in A.
  assert (E : ((Z.shiftr w 24 =? 19) || (Z.shiftr w 24 =? 20) || (Z.shiftr w 24 =? 21))%bool = true)
    by (destruct Ho as [-> | [-> | ->]]; reflexivity).
  rewrite E in A. destruct (word_at (v_s st) (v_i st + 1)) as [z|]; [ exists z; reflexivity | discriminate A ].
Qed.

(* PARENT_BIT_CLEAR (0x33) moves the cursor by 2 *)
Lemma succs_pbc : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 51 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* ANIMATE_TEXTURE (0x34) moves the cursor by 1 *)
Lemma succs_atex : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 52 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* BILLBOARD (0x21) / DISABLE_RENDERING (0x35) move the cursor by 1 *)
Lemma succs_gfl : forall st w, word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 33 \/ Z.shiftr w 24 = 53 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw [Ho | Ho]; unfold succs; cbv zeta; rewrite Hw, Ho; reflexivity. Qed.

(* SET_HITBOX (0x23) moves the cursor by 2, SET_HITBOX_WITH_OFFSET (0x2B) by 3 *)
Lemma succs_hb : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 35 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma succs_hbo : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 43 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 3) then None else
    Some [at_ st (v_s st) (v_i st + 3) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* SET_HOME (0x2D) moves the cursor by 1 *)
Lemma succs_home : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 45 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* SET_OBJ_PHYSICS (0x30) moves the cursor by 5 *)
Lemma succs_phys : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 48 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 5) then None else
    Some [at_ st (v_s st) (v_i st + 5) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* its argument words 1-3 are there.  PERF TRAP: inline *)
Lemma phys_w_ok :
  forallb (fun st => if opc st =? 48 then
                       match word_at (v_s st) (v_i st + 1), word_at (v_s st) (v_i st + 2),
                             word_at (v_s st) (v_i st + 3) with
                       | Some _, Some _, Some _ => true | _, _, _ => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma phys_w : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 48 -> exists z1 z2 z3, word_at (v_s st) (v_i st + 1) = Some z1
    /\ word_at (v_s st) (v_i st + 2) = Some z2 /\ word_at (v_s st) (v_i st + 3) = Some z3.
Proof.
  intros st w Hst Hw Ho. pose proof phys_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw, Ho in A.
  cbv beta iota in A. cbn in A.
  destruct (word_at (v_s st) (v_i st + 1)) as [z1|]; [ | discriminate A ].
  destruct (word_at (v_s st) (v_i st + 2)) as [z2|]; [ | discriminate A ].
  destruct (word_at (v_s st) (v_i st + 3)) as [z3|]; [ | discriminate A ].
  exists z1, z2, z3. split; [ reflexivity | split; reflexivity ].
Qed.

(* LOAD_ANIMATIONS (0x27) / LOAD_COLLISION_DATA (0x2A) move the cursor by 2 *)
Lemma succs_la : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 39 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.
Lemma succs_lcd : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 42 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* their argument word is a symbol address (computed: the five anim tables,
   the two collision meshes).  PERF TRAP: inline *)
Lemma la_w_ok :
  forallb (fun st => if (opc st =? 39) || (opc st =? 42) then
                       match nth_error (words (v_s st)) (v_i st + 1) with
                       | Some (Init_addrof _ _) => true | _ => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma la_w : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 39 \/ Z.shiftr w 24 = 42 ->
  exists t o, nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof t o).
Proof.
  intros st w Hst Hw Ho. pose proof la_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
  destruct Ho as [Ho | Ho]; rewrite Ho in A; cbv beta iota in A; cbn in A;
  (destruct (nth_error (words (v_s st)) (v_i st + 1)) as [d|]; [ | discriminate A ]);
  (destruct d as [ x | x | x | x | x | x | x | t o ]; try discriminate A);
  exists t, o; reflexivity.
Qed.

(* SCALE (0x32) moves the cursor by 1 *)
Lemma succs_scale : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 50 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* BEGIN (0x00) moves the cursor by 1 *)
Lemma succs_begin : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 0 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* CALL_NATIVE (0x0C) moves the cursor by 2; its word 1 is the native's
   address (computed: an Init_addrof at offset 0 in every reachable state) *)
Lemma succs_cn : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 12 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma cn_w_ok :
  forallb (fun st => if opc st =? 12 then
                       match nth_error (words (v_s st)) (v_i st + 1) with
                       | Some (Init_addrof _ o) => Z.eqb (Ptrofs.unsigned o) 0 | _ => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cn_w : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 12 ->
  exists t, nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof t Ptrofs.zero).
Proof.
  intros st w Hst Hw Ho. pose proof cn_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw, Ho in A.
  cbv beta iota in A. cbn in A.
  destruct (nth_error (words (v_s st)) (v_i st + 1)) as [d|]; [ | discriminate A ].
  destruct d as [ x | x | x | x | x | x | x | t o ]; try discriminate A.
  apply Z.eqb_eq in A. exists t.
  assert (Eo : o = Ptrofs.zero)
    by (rewrite <- (Ptrofs.repr_unsigned o), A; reflexivity).
  rewrite Eo. reflexivity.
Qed.

(* SPAWN_CHILD (0x1C) moves the cursor by 3; its word 2 is the child's
   script (computed: six reachable 0x1C states -- the three / ten coin
   spawners, the bubble and mist particle spawners, the cannon -- spawning
   bhvSingleCoinGetsSpawned (list 6), bhvSmallWaterWave / bhvWhitePuff2
   (list 12), bhvCannonBarrel / bhvWhitePuff1 (list 8).  Every child script
   is itself reachable (so scr_ok covers its first word), and its list is
   below 13 and none of 4 / 5 / 10, the lists whose create_object snaps the
   new object to the floor).  PERF TRAP: inline *)
Lemma succs_sc : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 28 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 3) then None else
    Some [at_ st (v_s st) (v_i st + 3) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma sc_w_ok :
  forallb (fun st => if opc st =? 28 then
                       match nth_error (words (v_s st)) (v_i st + 2) with
                       | Some (Init_addrof c o) =>
                           Z.eqb (Ptrofs.unsigned o) 0 && existsb (Pos.eqb c) (map v_s vm_tab)
                           && match nth_error (words c) 0 with
                              | Some (Init_int32 n) =>
                                  (ObjMake.bhv_list n <? 13) && negb (ObjMake.bhv_list n =? 4)
                                  && negb (ObjMake.bhv_list n =? 5) && negb (ObjMake.bhv_list n =? 10)
                              | _ => false end
                       | _ => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sc_w : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 28 ->
  exists c n, nth_error (words (v_s st)) (v_i st + 2) = Some (Init_addrof c Ptrofs.zero)
    /\ In c (map v_s vm_tab) /\ nth_error (words c) 0 = Some (Init_int32 n)
    /\ ObjMake.bhv_list n < 13 /\ ObjMake.bhv_list n <> 4 /\ ObjMake.bhv_list n <> 5
    /\ ObjMake.bhv_list n <> 10.
Proof.
  intros st w Hst Hw Ho. pose proof sc_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
  cbv beta iota in A. rewrite Ho, Z.eqb_refl in A. cbv beta iota in A.
  destruct (nth_error (words (v_s st)) (v_i st + 2)) as [d|] eqn:E2; [ | discriminate A ].
  destruct d as [ x | x | x | x | x | x | x | c o ]; try discriminate A.
  apply andb_prop in A as [A A3]. apply andb_prop in A as [A1 A2].
  apply Z.eqb_eq in A1. apply existsb_exists in A2 as (c' & Hc' & Ec). apply Pos.eqb_eq in Ec. subst c'.
  destruct (nth_error (words c) 0) as [d|] eqn:Ed; [ | discriminate A3 ].
  destruct d as [ x | x | n | x | x | x | x | x y ]; try discriminate A3.
  apply andb_prop in A3 as [A3 B10]. apply andb_prop in A3 as [A3 B5]. apply andb_prop in A3 as [B13 B4].
  apply Z.ltb_lt in B13. apply negb_true_iff, Z.eqb_neq in B4. apply negb_true_iff, Z.eqb_neq in B5.
  apply negb_true_iff, Z.eqb_neq in B10.
  assert (Eo : o = Ptrofs.zero) by (rewrite <- (Ptrofs.repr_unsigned o), A1; reflexivity). subst o.
  exists c, n. exact (conj eq_refl (conj Hc' (conj Ed (conj B13 (conj B4 (conj B5 B10)))))).
Qed.

Lemma padd_repr : forall a c, Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr c) = Ptrofs.repr (a + c).
Proof.
  intros a c. rewrite Ptrofs.add_unsigned. apply Ptrofs.eqm_samerepr. apply Ptrofs.eqm_add;
    apply Ptrofs.eqm_sym; apply Ptrofs.eqm_unsigned_repr.
Qed.

(* ANIMATE (opcode 0x28 = 40): one word *)
Lemma succs_an : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 40 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

(* DROP_TO_FLOOR (0x1E) moves the cursor by 1 *)
Lemma succs_dtf : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 30 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Lemma dm_ffh : (prog_defmap surface_collision.prog) ! BS._find_floor_height
  = Some (Gfun (Internal surface_collision.f_find_floor_height)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ff0 : (prog_defmap surface_collision.prog) ! surface_collision._find_floor
  = Some (Gfun (Internal surface_collision.f_find_floor)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ffl0 : (prog_defmap surface_collision.prog) ! surface_collision._find_floor_from_list
  = Some (Gfun (Internal surface_collision.f_find_floor_from_list)).
Proof. vm_compute. reflexivity. Qed.

(* 200.0f *)
Definition c200 : float32 := Float32.of_bits (Int.repr 1128792064).

Lemma aio_eq : forall oc d, 0 <= oc <= 145312 -> 0 <= d <= 16 ->
  ObjAnimate.AIo (Ptrofs.add (Ptrofs.add (Ptrofs.repr oc) (Ptrofs.repr 0)) (Ptrofs.repr 0)) d = oc + 56 + d.
Proof.
  intros oc d Ho Hd. unfold ObjAnimate.AIo. rewrite !padd_repr.
  rewrite Ptrofs.unsigned_repr by (rewrite maxu; lia). lia.
Qed.

Lemma nd_app_disj : forall (l1 l2 : list Z) x, NoDup (l1 ++ l2) -> In x l1 -> In x l2 -> False.
Proof.
  induction l1 as [| a l1 IH]; intros l2 x Hn H1 H2; [ destruct H1 | ].
  cbn in Hn. apply NoDup_cons_iff in Hn as (Ha & Hn).
  destruct H1 as [-> | H1]; [ apply Ha; apply in_or_app; right; exact H2 | exact (IH l2 x Hn H1 H2) ].
Qed.

(* SPAWN_WATER_DROPLET (opcode 0x37 = 55): two words; word 1 is &params,
   one of the two reachable WaterDropletParams (bhvShallowWaterSplash /
   bhvShallowWaterWave), and the droplet's script bhvWaterDroplet is a
   reachable script whose list is below 13 and none of 4 / 5 / 10.
   PERF TRAP: inline *)
Lemma succs_wd : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 55 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 2) then None else
    Some [at_ st (v_s st) (v_i st + 2) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

Definition dparams : list ident :=
  [behavior_data._gShallowWaterSplashDropletParams; behavior_data._gShallowWaterWaveDropletParams].

Lemma wd_w_ok :
  forallb (fun st => if opc st =? 55 then
                       match nth_error (words (v_s st)) (v_i st + 1) with
                       | Some (Init_addrof p o) =>
                           Z.eqb (Ptrofs.unsigned o) 0 && existsb (Pos.eqb p) dparams
                       | _ => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma wd_w : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 55 ->
  exists p, nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof p Ptrofs.zero) /\ In p dparams.
Proof.
  intros st w Hst Hw Ho. pose proof wd_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
  cbv beta iota in A. rewrite Ho, Z.eqb_refl in A. cbv beta iota in A.
  destruct (nth_error (words (v_s st)) (v_i st + 1)) as [d|] eqn:E2; [ | discriminate A ].
  destruct d as [ x | x | x | x | x | x | x | p o ]; try discriminate A.
  apply andb_prop in A as [A1 A2].
  apply Z.eqb_eq in A1. apply existsb_exists in A2 as (p' & Hp' & Ep). apply Pos.eqb_eq in Ep. subst p'.
  assert (Eo : o = Ptrofs.zero) by (rewrite <- (Ptrofs.repr_unsigned o), A1; reflexivity). subst o.
  exists p. exact (conj eq_refl Hp').
Qed.

Lemma wd_child_ok :
  existsb (Pos.eqb behavior_data._bhvWaterDroplet) (map v_s vm_tab)
  && match nth_error (words behavior_data._bhvWaterDroplet) 0 with
     | Some (Init_int32 n) =>
         (ObjMake.bhv_list n <? 13) && negb (ObjMake.bhv_list n =? 4)
         && negb (ObjMake.bhv_list n =? 5) && negb (ObjMake.bhv_list n =? 10)
     | _ => false end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma wd_child : exists n,
  In behavior_data._bhvWaterDroplet (map v_s vm_tab)
  /\ nth_error (words behavior_data._bhvWaterDroplet) 0 = Some (Init_int32 n)
  /\ ObjMake.bhv_list n < 13 /\ ObjMake.bhv_list n <> 4 /\ ObjMake.bhv_list n <> 5
  /\ ObjMake.bhv_list n <> 10.
Proof.
  pose proof wd_child_ok as A. apply andb_prop in A as [A1 A3].
  apply existsb_exists in A1 as (c' & Hc' & Ec). apply Pos.eqb_eq in Ec. subst c'.
  destruct (nth_error (words behavior_data._bhvWaterDroplet) 0) as [d|] eqn:Ed; [ | discriminate A3 ].
  destruct d as [ x | x | n | x | x | x | x | x y ]; try discriminate A3.
  apply andb_prop in A3 as [A3 B10]. apply andb_prop in A3 as [A3 B5]. apply andb_prop in A3 as [B13 B4].
  apply Z.ltb_lt in B13. apply negb_true_iff, Z.eqb_neq in B4. apply negb_true_iff, Z.eqb_neq in B5.
  apply negb_true_iff, Z.eqb_neq in B10.
  exists n. exact (conj Hc' (conj eq_refl (conj B13 (conj B4 (conj B5 B10))))).
Qed.

(* the truth behind the dparams_ok pin (wd_dp below): both params'
   initializers hold &bhvWaterDroplet at byte 4 (two s16 before it) *)
Lemma dparams_init :
  nth_error (gvar_init behavior_actions.v_gShallowWaterSplashDropletParams) 2
    = Some (Init_addrof behavior_data._bhvWaterDroplet Ptrofs.zero)
  /\ nth_error (gvar_init behavior_actions.v_gShallowWaterWaveDropletParams) 2
    = Some (Init_addrof behavior_data._bhvWaterDroplet Ptrofs.zero)
  /\ firstn 2 (gvar_init behavior_actions.v_gShallowWaterSplashDropletParams)
    = [Init_int16 (Int.repr 34); Init_int16 (Int.repr 164)]
  /\ firstn 2 (gvar_init behavior_actions.v_gShallowWaterWaveDropletParams)
    = [Init_int16 (Int.repr 98); Init_int16 (Int.repr 164)].
Proof. vm_compute. auto. Qed.

(* their argument words are there at every reachable state.  PERF TRAP: inline *)
Lemma hb_w_ok :
  forallb (fun st => if (opc st =? 35) || (opc st =? 43) then
                       match word_at (v_s st) (v_i st + 1) with Some _ => true | None => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma hbo_w_ok :
  forallb (fun st => if opc st =? 43 then
                       match word_at (v_s st) (v_i st + 2) with Some _ => true | None => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma hb_w1 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 35 \/ Z.shiftr w 24 = 43 -> exists z, word_at (v_s st) (v_i st + 1) = Some z.
Proof.
  intros st w Hst Hw Ho. pose proof hb_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
  assert (E : ((Z.shiftr w 24 =? 35) || (Z.shiftr w 24 =? 43))%bool = true)
    by (destruct Ho as [-> | ->]; reflexivity).
  cbv beta iota in A. rewrite E in A.
  destruct (word_at (v_s st) (v_i st + 1)) as [z|]; [ exists z; reflexivity | discriminate A ].
Qed.

Lemma hbo_w2 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 43 -> exists z, word_at (v_s st) (v_i st + 2) = Some z.
Proof.
  intros st w Hst Hw Ho. pose proof hbo_w_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw, Ho in A.
  cbv beta iota in A. cbn in A.
  destruct (word_at (v_s st) (v_i st + 2)) as [z|]; [ exists z; reflexivity | discriminate A ].
Qed.

(* its mask word is there at every reachable state.  PERF TRAP: inline *)
Lemma pbc_w1_ok :
  forallb (fun st => if opc st =? 51 then
                       match word_at (v_s st) (v_i st + 1) with Some _ => true | None => false end
                     else true) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma pbc_w1 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  Z.shiftr w 24 = 51 -> exists z, word_at (v_s st) (v_i st + 1) = Some z.
Proof.
  intros st w Hst Hw Ho. pose proof pbc_w1_ok as A.
  rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw, Ho in A.
  cbv beta iota in A. cbn in A.
  destruct (word_at (v_s st) (v_i st + 1)) as [z|]; [ exists z; reflexivity | discriminate A ].
Qed.




(* the unsigned field bytes, as SUM_FLOAT computes them (tuint temps cast to tuchar) *)
Lemma zx8_and : forall x, Int.unsigned (Int.zero_ext 8 (Int.and x (Int.repr 255))) = Z.land (Int.unsigned x) 255.
Proof.
  intros x.
  assert (E : Int.and x (Int.repr 255) = Int.zero_ext 8 x) by (rewrite Int.zero_ext_and by lia; reflexivity).
  rewrite E, Int.zero_ext_idem by lia. rewrite Int.zero_ext_mod by (cbn; lia). change (two_p 8) with 256.
  change 255 with (Z.ones 8). rewrite Z.land_ones by lia. reflexivity.
Qed.

Lemma shru_u : forall n k, 0 <= k < 32 -> Int.unsigned (Int.shru n (Int.repr k)) = Z.shiftr (Int.unsigned n) k.
Proof.
  intros n k Hk. rewrite Int.shru_div_two_p. rewrite (Int.unsigned_repr k) by (change Int.max_unsigned with 4294967295; lia).
  pose proof (Int.unsigned_range n) as R. change Int.modulus with 4294967296 in R.
  rewrite Z.shiftr_div_pow2 by lia. rewrite two_p_equiv.
  assert (P : 0 < 2 ^ k) by (apply Z.pow_pos_nonneg; lia).
  apply Int.unsigned_repr. change Int.max_unsigned with 4294967295. split; [ apply Z.div_pos; lia | ].
  apply Z.le_trans with (Int.unsigned n); [ | lia ]. apply Z.div_le_upper_bound; [ lia | nia ].
Qed.

Lemma b2_eq : forall n, Int.unsigned (Int.zero_ext 8 (Int.and (Int.shru n (Int.repr 16)) (Int.repr 255))) = byte2 (Int.unsigned n).
Proof. intros n. rewrite zx8_and, shru_u by lia. reflexivity. Qed.
Lemma b3_eq : forall n, Int.unsigned (Int.zero_ext 8 (Int.and (Int.shru n (Int.repr 8)) (Int.repr 255))) = byte3 (Int.unsigned n).
Proof. intros n. rewrite zx8_and, shru_u by lia. reflexivity. Qed.
Lemma b4_eq : forall n, Int.unsigned (Int.zero_ext 8 (Int.and n (Int.repr 255))) = byte4 (Int.unsigned n).
Proof. intros n. rewrite zx8_and. reflexivity. Qed.

(* END_REPEAT and END_REPEAT_CONTINUE: one body, two return codes *)
Definition er_body (rc : Z) : statement :=
  match fn_body BS.f_bhv_cmd_end_repeat with
  | Ssequence a (Ssequence b (Ssequence c _)) =>
      Ssequence a (Ssequence b (Ssequence c (Sreturn (Some (Econst_int (Int.repr rc) tint)))))
  | s => s
  end.
Lemma er_1 : fn_body BS.f_bhv_cmd_end_repeat = er_body 1.
Proof. reflexivity. Qed.
Lemma er_0 : fn_body BS.f_bhv_cmd_end_repeat_continue = er_body 0.
Proof. reflexivity. Qed.

Lemma cast_short : forall x m c, sem_cast x tuint tshort m = Some c -> exists n, c = Vint n.
Proof. intros x m c H. destruct x; cbn in H; try discriminate H; injection H as <-; eauto. Qed.
Lemma cast_iu : forall n m, sem_cast (Vint n) tint tuint m = Some (Vint n).
Proof. reflexivity. Qed.
Lemma sub_ui : forall (ce : composite_env) c n m,
  sem_binary_operation ce Osub (Vint c) tuint (Vint n) tint m = Some (Vint (Int.sub c n)).
Proof. reflexivity. Qed.

Lemma ptr_inc : forall a k, -1000 <= k <= 1000 ->
  Ptrofs.add (Ptrofs.repr a) (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr k)))
  = Ptrofs.repr (a + 4 * k).
Proof.
  intros a k Hk. unfold Ptrofs.of_ints. rewrite Int.signed_repr by (cbn; lia).
  unfold Ptrofs.add, Ptrofs.mul. apply Ptrofs.eqm_samerepr.
  apply Ptrofs.eqm_add; [ apply Ptrofs.eqm_sym, Ptrofs.eqm_unsigned_repr | ].
  eapply Ptrofs.eqm_trans; [ apply Ptrofs.eqm_sym, Ptrofs.eqm_unsigned_repr | ].
  apply Ptrofs.eqm_mult; apply Ptrofs.eqm_sym, Ptrofs.eqm_unsigned_repr.
Qed.

(* p + n, p : u32 *, n : int (the handlers' gCurBhvCommand + k) *)
Lemma add_pi : forall (ce : composite_env) b o n m,
  sem_binary_operation ce Oadd (Vptr b o) (tptr tuint) (Vint n) tint m
  = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints n)))).
Proof. reflexivity. Qed.

(* two valid pointers into different blocks compare unequal *)
Lemma cmp_ne : forall (ce : composite_env) m bb ob bs, bb <> bs ->
  Mem.valid_pointer m bb (Ptrofs.unsigned ob) = true -> Mem.valid_pointer m bs 0 = true ->
  sem_binary_operation ce Oeq (Vptr bb ob) (tptr tuint) (Vptr bs Ptrofs.zero) (tptr tvoid) m
  = Some (Vint Int.zero).
Proof.
  intros ce m bb ob bs Hne H1 H2.
  unfold sem_binary_operation, sem_cmp. cbn.
  unfold cmp_ptr, Val.cmpu_bool. cbn.
  destruct (eq_block bb bs) as [E | _]; [ contradiction | ].
  rewrite H1. cbn. rewrite ?Ptrofs.unsigned_zero. rewrite H2. reflexivity.
Qed.

(* pointer-to-pointer casts (and through u32: ILP32) keep the pointer *)
Lemma cast_pp : forall b o t1 t2 m, sem_cast (Vptr b o) (tptr t1) (tptr t2) m = Some (Vptr b o).
Proof. reflexivity. Qed.
Lemma cast_pu : forall b o t1 m, sem_cast (Vptr b o) (tptr t1) tuint m = Some (Vptr b o).
Proof. reflexivity. Qed.
Lemma cast_up : forall b o t1 m, sem_cast (Vptr b o) tuint (tptr t1) m = Some (Vptr b o).
Proof. reflexivity. Qed.
Lemma cast_uu : forall v m, (exists b o, v = Vptr b o) \/ (exists n, v = Vint n) ->
  sem_cast v tuint tuint m = Some v.
Proof. intros v m [(b & o & ->) | (n & ->)]; reflexivity. Qed.

(* ---- 6. the dispatch's side facts ---- *)
Lemma word_int : forall s i w, word_at s i = Some w ->
  exists n, nth_error (words s) i = Some (Init_int32 n) /\ w = Int.unsigned n.
Proof.
  intros s i w H. unfold word_at in H. destruct (nth_error (words s) i) as [d|]; [ | discriminate H ].
  destruct d; cbn in H; try discriminate H. injection H as <-. eauto.
Qed.

Lemma succs_word : forall st l, succs st = Some l -> exists w, word_at (v_s st) (v_i st) = Some w.
Proof.
  intros st l H. unfold succs in H. cbv zeta in H.
  destruct (word_at (v_s st) (v_i st)) as [w|]; [ exists w; reflexivity | discriminate H ].
Qed.

(* every reachable opcode indexes BehaviorCmdTable[56] *)
Lemma vm_op : forallb (fun st => (0 <=? opc st) && (opc st <? 56)) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma op_range : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  0 <= Z.shiftr w 24 < 56.
Proof.
  intros st w Hst Hw. pose proof vm_op as A. rewrite forallb_forall in A. specialize (A st Hst).
  unfold opc, w0 in A. rewrite Hw in A. apply andb_prop in A as [A1 A2].
  apply Z.leb_le in A1. apply Z.ltb_lt in A2. lia.
Qed.

(* the opcodes the reachable VM actually executes (vm-checked over vm_tab):
   39 of the 56; 11 (BREAK_UNUSED) and 16 others never occur *)
Definition used_ops : list Z :=
  [0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 12; 13; 14; 15; 16; 17; 19; 20; 21; 28; 29;
   30; 31; 33; 35; 37; 39; 40; 42; 43; 45; 47; 48; 50; 51; 52; 53; 55].

Lemma vm_used : forallb (fun st => existsb (Z.eqb (opc st)) used_ops) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma op_used : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  In (Z.shiftr w 24) used_ops.
Proof.
  intros st w Hst Hw. pose proof vm_used as A. rewrite forallb_forall in A. specialize (A st Hst).
  unfold opc, w0 in A. rewrite Hw in A. apply existsb_exists in A as (x & Hx & Ex).
  apply Z.eqb_eq in Ex. rewrite Ex. exact Hx.
Qed.

Lemma cmd_handlers_len : List.length ObjCensus.cmd_handlers = 56%nat.
Proof. vm_compute. reflexivity. Qed.

Lemma shr_ui : forall (ce : composite_env) n m,
  sem_binary_operation ce Oshr (Vint n) tuint (Vint (Int.repr 24)) tint m
  = Some (Vint (Int.shru n (Int.repr 24))).
Proof. reflexivity. Qed.

Lemma shru24 : forall n, Int.unsigned (Int.shru n (Int.repr 24)) = Z.shiftr (Int.unsigned n) 24.
Proof.
  intros n. unfold Int.shru. change (Int.unsigned (Int.repr 24)) with 24.
  pose proof (Int.unsigned_range n) as R. change Int.modulus with 4294967296 in R.
  apply Int.unsigned_repr. rewrite Z.shiftr_div_pow2 by lia. change (2 ^ 24) with 16777216.
  split; [ apply Z.div_pos; lia | ]. change Int.max_unsigned with 4294967295.
  apply Z.div_le_upper_bound; lia.
Qed.

Definition fpt : type := tptr (Tfunction [] tint cc_default).

Lemma add_au : forall (ce : composite_env) b o x m,
  sem_binary_operation ce Oadd (Vptr b o) (tarray fpt 56) (Vint x) tuint m
  = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_intu x)))).
Proof. reflexivity. Qed.

Lemma tab_off : forall x, 0 <= Int.unsigned x < 56 ->
  Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_intu x)))
  = 4 * Int.unsigned x.
Proof.
  intros x Hx. rewrite Ptrofs.add_zero_l. unfold Ptrofs.mul, Ptrofs.of_intu, Ptrofs.of_int.
  rewrite (Ptrofs.unsigned_repr 4), (Ptrofs.unsigned_repr (Int.unsigned x)) by (rewrite maxu; lia).
  apply Ptrofs.unsigned_repr. rewrite maxu. lia.
Qed.

(* a global array, as an rvalue: its address *)
Lemma ev_garr : forall (ge : genv) e m le id ty n v, e ! id = None ->
  eval_expr ge e le m (Evar id (tarray ty n)) v ->
  exists b, Genv.find_symbol ge id = Some b /\ v = Vptr b Ptrofs.zero.
Proof.
  intros ge e m le id ty n v He H. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [ congruence | ].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate. eauto.
Qed.

(* cur_obj_update's dispatch loop:
     do { bhvCmdProc = BehaviorCmdTable[*gCurBhvCommand >> 24];
          bhvProcResult = bhvCmdProc(); } while (bhvProcResult == BHV_PROC_CONTINUE); *)
Definition DISP : statement :=
  Ssequence
    (Ssequence
      (Sset BS._t'50 (Evar BS._gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset BS._t'51 (Ederef (Etempvar BS._t'50 (tptr tuint)) tuint))
        (Sset BS._bhvCmdProc
          (Ederef
            (Ebinop Oadd (Evar BS._BehaviorCmdTable (tarray fpt 56))
              (Ebinop Oshr (Etempvar BS._t'51 tuint) (Econst_int (Int.repr 24) tint) tuint)
              (tptr fpt)) fpt))))
    (Ssequence
      (Scall (Some BS._t'3) (Etempvar BS._bhvCmdProc fpt) [])
      (Sset BS._bhvProcResult (Etempvar BS._t'3 tint))).
Definition DCHK : statement :=
  Sifthenelse (Ebinop Oeq (Etempvar BS._bhvProcResult tint) (Econst_int (Int.repr 0) tint) tint)
    Sskip Sbreak.
Definition DLOOP : statement := Sloop DISP DCHK.

(* DLOOP is the generated code: the first (and only) loop of cur_obj_update's body *)
Fixpoint first_loop (s : statement) : option statement :=
  match s with
  | Sloop _ _ => Some s
  | Ssequence a b | Sifthenelse _ a b =>
      match first_loop a with Some l => Some l | None => first_loop b end
  | Slabel _ a => first_loop a
  | _ => None
  end.
Lemma dloop_is_real : first_loop (fn_body BS.f_cur_obj_update) = Some DLOOP.
Proof. vm_compute. reflexivity. Qed.

(* the copy-in / copy-out around it:
     gCurBhvCommand = gCurrentObject->curBhvCommand;   (before the loop)
     gCurrentObject->curBhvCommand = gCurBhvCommand;   (after it) *)
Notation tobj := (tptr (Tstruct BS._Object noattr)).
Definition COPYIN : statement :=
  Ssequence (Sset BS._t'52 (Evar BS._gCurrentObject tobj))
    (Ssequence
      (Sset BS._t'53 (Efield (Ederef (Etempvar BS._t'52 tobj) (Tstruct BS._Object noattr))
                        BS._curBhvCommand (tptr tuint)))
      (Sassign (Evar BS._gCurBhvCommand (tptr tuint)) (Etempvar BS._t'53 (tptr tuint)))).
Definition COPYOUT : statement :=
  Ssequence (Sset BS._t'48 (Evar BS._gCurrentObject tobj))
    (Ssequence
      (Sset BS._t'49 (Evar BS._gCurBhvCommand (tptr tuint)))
      (Sassign (Efield (Ederef (Etempvar BS._t'48 tobj) (Tstruct BS._Object noattr))
                  BS._curBhvCommand (tptr tuint)) (Etempvar BS._t'49 (tptr tuint)))).

(* the segment Ssequence CI (Ssequence LOOP (Ssequence CO _)) of a body *)
Fixpoint find_seg (s : statement) : option (statement * statement * statement) :=
  match s with
  | Ssequence a b =>
      match b with
      | Ssequence (Sloop x y) (Ssequence co _) => Some (a, Sloop x y, co)
      | _ => match find_seg a with Some r => Some r | None => find_seg b end
      end
  | Sifthenelse _ a b => match find_seg a with Some r => Some r | None => find_seg b end
  | Slabel _ a => find_seg a
  | _ => None
  end.
Lemma seg_is_real : find_seg (fn_body BS.f_cur_obj_update) = Some (COPYIN, DLOOP, COPYOUT).
Proof. vm_compute. reflexivity. Qed.

(* the whole body around the segment: the statements before it (COU_PRE:
   the distance / angle to Mario, the action-timer reset) and the
   statement after it (COU_POST: the timer, the flag-gated move /
   transform / gfx calls, room and render-distance visibility) *)
Fixpoint pre_seg (s : statement) : list statement :=
  match s with
  | Ssequence a b =>
      match b with
      | Ssequence (Sloop _ _) _ => []
      | _ => a :: pre_seg b
      end
  | _ => []
  end.
Fixpoint post_seg (s : statement) : statement :=
  match s with
  | Ssequence a b =>
      match b with
      | Ssequence (Sloop _ _) (Ssequence _ r) => r
      | _ => post_seg b
      end
  | _ => Sskip
  end.
Definition COU_PRE : list statement := pre_seg (fn_body BS.f_cur_obj_update).
Definition COU_POST : statement := post_seg (fn_body BS.f_cur_obj_update).

Lemma cou_split : fn_body BS.f_cur_obj_update
  = ObjLoop.app_seq COU_PRE (Ssequence COPYIN (Ssequence DLOOP (Ssequence COPYOUT COU_POST))).
Proof. vm_compute. reflexivity. Qed.
Lemma cou_plain : ObjLoop.plain (ObjLoop.app_seq COU_PRE Sskip) = true.
Proof. vm_compute. reflexivity. Qed.
(* the segment never names the local filler[4] *)
Lemma cou_nofv : EnvSwap.s_nofv BS._filler COPYIN = true /\ EnvSwap.s_nofv BS._filler DLOOP = true
  /\ EnvSwap.s_nofv BS._filler COPYOUT = true.
Proof. vm_compute. auto. Qed.

Section Link.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  Lemma bs_cenv : forall id co, (prog_comp_env BS.prog) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof.
    intros id co H. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp BS.prog id co (linked12_LO_behavior_script lp H12) H).
  Qed.

  Lemma fo_sidx : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._bhvStackIndex (co_members co) = OK (OW.O_SIDX, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_stk : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._bhvStack (co_members co) = OK (OW.O_STK, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  (* bhvDelayTimer (s16), right after bhvStack[8] *)
  Lemma fo_dt : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._bhvDelayTimer (co_members co) = OK (OW.O_STK + 32, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_cmd : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._curBhvCommand (co_members co) = OK (OW.O_CMD, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_raw : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._rawData (co_members co) = OK (136, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma ufo_s32 : forall co, (genv_cenv G) ! BS.__764 = Some co ->
    union_field_offset G BS._asS32 (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma ufo_f32 : forall co, (genv_cenv G) ! BS.__764 = Some co ->
    union_field_offset G BS._asF32 (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.

  Lemma ufo_u32 : forall co, (genv_cenv G) ! BS.__764 = Some co ->
    union_field_offset G BS._asU32 (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma ufo_vp : forall co, (genv_cenv G) ! BS.__764 = Some co ->
    union_field_offset G BS._asVoidPtr (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_flags : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._activeFlags (co_members co) = OK (OW.O_FLAGS, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_par : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._parentObj (co_members co) = OK (104, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_header : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._header (co_members co) = OK (0, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_gfx : forall co, (genv_cenv G) ! BS._ObjectNode = Some co ->
    field_offset G BS._gfx (co_members co) = OK (0, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_node : forall co, (genv_cenv G) ! BS._GraphNodeObject = Some co ->
    field_offset G BS._node (co_members co) = OK (0, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_gflags : forall co, (genv_cenv G) ! BS._GraphNode = Some co ->
    field_offset G BS._flags (co_members co) = OK (2, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_hbr : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._hitboxRadius (co_members co) = OK (504, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_coll : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._collisionData (co_members co) = OK (536, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_scale : forall co, (genv_cenv G) ! BS._GraphNodeObject = Some co ->
    field_offset G BS._scale (co_members co) = OK (44, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_bhv : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._behavior (co_members co) = OK (524, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_hbh : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._hitboxHeight (co_members co) = OK (508, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_hbd : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._hitboxDownOffset (co_members co) = OK (520, Full).
  Proof. apply (RA.fo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Local Ltac kill_r :=
    try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end);
    try (match goal with Ht : typeof _ = _ |- _ => cbn in Ht; discriminate Ht end);
    try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).

  (* o->rawData.asS32[field], written: the cell oc + 136 + 4 * field *)
  Lemma lv_raw : forall m le p fi i b o bf,
    le ! fi = Some (Vint i) ->
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asS32 (tarray tint 80))
         (Etempvar fi tuchar) (tptr tint)) tint) b o bf ->
    exists o0, le ! p = Some (Vptr b o0) /\ bf = Full /\
      o = Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
            (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)).
  Proof.
    intros m le p fi i b o bf Hfi HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply RA.ev_temp in E2. rewrite Hfi in E2. injection E2 as <-.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_s32 _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: cbn in E3; injection E3 as <- <-.
    all: eexists; split; [ eassumption | split; reflexivity ].
  Qed.

  (* o->rawData.asVoidPtr[field] (LOAD_ANIMATIONS) *)
  Lemma lv_rawvp : forall m le p fi i b o bf,
    le ! fi = Some (Vint i) ->
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asVoidPtr (tarray (tptr tvoid) 80))
         (Etempvar fi tuchar) (tptr (tptr tvoid))) (tptr tvoid)) b o bf ->
    exists o0, le ! p = Some (Vptr b o0) /\ bf = Full /\
      o = Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
            (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)).
  Proof.
    intros m le p fi i b o bf Hfi HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply RA.ev_temp in E2. rewrite Hfi in E2. injection E2 as <-.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_vp _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: cbn in E3; injection E3 as <- <-.
    all: eexists; split; [ eassumption | split; reflexivity ].
  Qed.

  (* o->rawData.asU32[k], k a constant (SET_INTERACT_TYPE) *)
  Lemma lv_rawuc : forall m le p k b o bf,
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asU32 (tarray tuint 80))
         (Econst_int (Int.repr k) tint) (tptr tuint)) tuint) b o bf ->
    exists o0, le ! p = Some (Vptr b o0) /\ bf = Full /\
      o = Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
            (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr k))).
  Proof.
    intros m le p k b o bf HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply RA.ev_const in E2. subst v2.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_u32 _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: cbn in E3; injection E3 as <- <-.
    all: eexists; split; [ eassumption | split; reflexivity ].
  Qed.



  (* o->rawData.asF32[field], written: the cell oc + 136 + 4 * field *)
  Lemma lv_rawf : forall m le p fi i b o bf,
    le ! fi = Some (Vint i) ->
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asF32 (tarray tfloat 80))
         (Etempvar fi tuchar) (tptr tfloat)) tfloat) b o bf ->
    exists o0, le ! p = Some (Vptr b o0) /\ bf = Full /\
      o = Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
            (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)).
  Proof.
    intros m le p fi i b o bf Hfi HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply RA.ev_temp in E2. rewrite Hfi in E2. injection E2 as <-.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_f32 _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: cbn in E3; injection E3 as <- <-.
    all: eexists; split; [ eassumption | split; reflexivity ].
  Qed.

  (* the same with a tuint index (SUM_FLOAT): of_intu *)
  Lemma lv_rawfu : forall m le p fi i b o bf,
    le ! fi = Some (Vint i) ->
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asF32 (tarray tfloat 80))
         (Etempvar fi tuint) (tptr tfloat)) tfloat) b o bf ->
    exists o0, le ! p = Some (Vptr b o0) /\ bf = Full /\
      o = Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
            (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_intu i)).
  Proof.
    intros m le p fi i b o bf Hfi HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply RA.ev_temp in E2. rewrite Hfi in E2. injection E2 as <-.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_f32 _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: cbn in E3; injection E3 as <- <-.
    all: eexists; split; [ eassumption | split; reflexivity ].
  Qed.

  (* o->rawData.asF32[idx], any index expression: the array base and the
     index value *)
  Lemma lv_rawf_any : forall m le p idx b o bf,
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asF32 (tarray tfloat 80))
         idx (tptr tfloat)) tfloat) b o bf ->
    exists b0 o0 vi, le ! p = Some (Vptr b0 o0) /\ bf = Full /\ eval_expr G empty_env le m idx vi /\
      sem_binary_operation G Oadd (Vptr b0 (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0)))
        (tarray tfloat 80) vi (typeof idx) m = Some (Vptr b o).
  Proof.
    intros m le p idx b o bf HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_f32 _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: do 3 eexists; split; [ eassumption | split; [ reflexivity | split; [ exact E2 | exact E3 ] ] ].
  Qed.


  Lemma raw_addr : forall oc j, 0 <= oc <= 145312 -> 0 <= j < 256 ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.add (Ptrofs.repr oc) (Ptrofs.repr 136)) (Ptrofs.repr 0))
                       (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.repr j))) = oc + 136 + 4 * j.
  Proof.
    intros oc j Hoc0 Hj.
    rewrite (Ptrofs.add_unsigned (Ptrofs.repr oc) (Ptrofs.repr 136)).
    rewrite (Ptrofs.unsigned_repr oc), (Ptrofs.unsigned_repr 136) by (rewrite maxu; lia).
    rewrite (Ptrofs.add_unsigned (Ptrofs.repr (oc + 136)) (Ptrofs.repr 0)).
    rewrite (Ptrofs.unsigned_repr (oc + 136)), (Ptrofs.unsigned_repr 0) by (rewrite maxu; lia).
    unfold Ptrofs.mul. rewrite (Ptrofs.unsigned_repr 4), (Ptrofs.unsigned_repr j) by (rewrite maxu; lia).
    rewrite uadd by (try rewrite maxu; lia). lia.
  Qed.

  (* ... at a constant index k: the cell oc + 136 + 4 k *)
  Lemma raw_cidx : forall b0 b oc' k vi m o, 0 <= oc' <= 145312 -> 0 <= k < 80 -> vi = Vint (Int.repr k) ->
    sem_binary_operation G Oadd (Vptr b0 (Ptrofs.add (Ptrofs.add (Ptrofs.repr oc') (Ptrofs.repr 136)) (Ptrofs.repr 0)))
      (tarray tfloat 80) vi tint m = Some (Vptr b o) ->
    b0 = b /\ Ptrofs.unsigned o = oc' + 136 + 4 * k.
  Proof.
    intros b0 b oc' k vi m o Ho Hk -> H. cbn in H. injection H as <- <-. split; [ reflexivity | ].
    unfold Ptrofs.of_ints. rewrite Int.signed_repr by (cbn; lia). apply raw_addr; lia.
  Qed.

  Lemma fun_bs : forall id f, (prog_defmap BS.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_behavior_script lp H12)). Qed.
  Lemma fun_mem : forall id f, (prog_defmap memory.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_memory lp H12)). Qed.
  Lemma fun_oh : forall id f, (prog_defmap OH.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_object_helpers lp H12)). Qed.
  Lemma dm_scale : (prog_defmap OH.prog) ! BS._cur_obj_scale
    = Some (Gfun (Internal OH.f_cur_obj_scale)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_cohb : (prog_defmap OH.prog) ! BS._cur_obj_has_behavior
    = Some (Gfun (Internal OH.f_cur_obj_has_behavior)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma dm_s2v : (prog_defmap memory.prog) ! BS._segmented_to_virtual
    = Some (Gfun (Internal memory.f_segmented_to_virtual)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_push : (prog_defmap BS.prog) ! BS._cur_obj_bhv_stack_push
    = Some (Gfun (Internal BS.f_cur_obj_bhv_stack_push)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_pop : (prog_defmap BS.prog) ! BS._cur_obj_bhv_stack_pop
    = Some (Gfun (Internal BS.f_cur_obj_bhv_stack_pop)).
  Proof. vm_compute. reflexivity. Qed.

  (* tmp = segmented_to_virtual((void * ) x): the identity (TRUST 2.2) *)
  Lemma s2v_call : forall le m t le' m' out tmp x b o,
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some tmp) (Evar BS._segmented_to_virtual (Tfunction [tptr tvoid] (tptr tvoid) cc_default))
         [Ecast (Etempvar x tuint) (tptr tvoid)]) t le' m' out ->
    le ! x = Some (Vptr b o) -> m' = m /\ le' = PTree.set tmp (Vptr b o) le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out tmp x b o H Hx.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [tptr tvoid] (tptr tvoid) cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_mem _ _ dm_s2v bf fd Hs Hff) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
    apply RA.ev_cast in Ev1 as (v0 & Ev0 & C0). apply RA.ev_temp in Ev0. rewrite Hx in Ev0. injection Ev0 as <-.
    cbn in C0. injection C0 as <-. cbn in C1. injection C1 as <-.
    apply fcall_inv in Hc as (le1 & le2 & out1 & Hb & Hx2 & Hor); [ | reflexivity ].
    cbn in Hb. injection Hb as <-. cbn [fn_body memory.f_segmented_to_virtual] in Hx2.
    apply RA.ret_inv in Hx2 as (-> & rv & Erv & ->).
    apply RA.ev_cast in Erv as (r0 & Er0 & Cr). apply RA.ev_temp in Er0. rewrite PTree.gss in Er0.
    injection Er0 as <-. cbn in Cr. injection Cr as <-.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    auto.
  Qed.

  (* the same with a pointer-typed argument (cur_obj_has_behavior) *)
  Lemma s2v_call_p : forall le m t le' m' out tmp x b o,
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some tmp) (Evar BS._segmented_to_virtual (Tfunction [tptr tvoid] (tptr tvoid) cc_default))
         [Etempvar x (tptr tuint)]) t le' m' out ->
    le ! x = Some (Vptr b o) -> m' = m /\ le' = PTree.set tmp (Vptr b o) le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out tmp x b o H Hx.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [tptr tvoid] (tptr tvoid) cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_mem _ _ dm_s2v bf fd Hs Hff) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
    apply RA.ev_temp in Ev1. rewrite Hx in Ev1. injection Ev1 as <-.
    cbn in C1. injection C1 as <-.
    apply fcall_inv in Hc as (le1 & le2 & out1 & Hb & Hx2 & Hor); [ | reflexivity ].
    cbn in Hb. injection Hb as <-. cbn [fn_body memory.f_segmented_to_virtual] in Hx2.
    apply RA.ret_inv in Hx2 as (-> & rv & Erv & ->).
    apply RA.ev_cast in Erv as (r0 & Er0 & Cr). apply RA.ev_temp in Er0. rewrite PTree.gss in Er0.
    injection Er0 as <-. cbn in Cr. injection Cr as <-.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    auto.
  Qed.

  (* a global script array as a value: its address *)
  Lemma ev_gscr : forall le m id bs v, Genv.find_symbol G id = Some bs ->
    eval_expr G empty_env le m (Evar id (tarray tuint 0)) v -> v = Vptr bs Ptrofs.zero.
  Proof.
    intros le m id bs v Hs H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
    - match goal with He : empty_env ! _ = Some _ |- _ => rewrite PTree.gempty in He; discriminate He end.
    - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; kill_r. congruence.
  Qed.

  Variables go pool : block.
  Variable oc : Z.
  Hypothesis Hgo : Genv.find_symbol G BS._gCurrentObject = Some go.
  Hypothesis Hoc : 0 <= oc <= 145312.
  Hypothesis Hpg : pool <> go.

  Definition cur (m : mem) : Prop := Mem.load Mint32 m go 0 = Some (Vptr pool (Ptrofs.repr oc)).

  Lemma ld_cur : forall le m t le' m' out x,
    exec_stmt function_entry2 G empty_env le m
      (Sset x (Evar BS._gCurrentObject (tptr (Tstruct BS._Object noattr)))) t le' m' out ->
    cur m -> le' = PTree.set x (Vptr pool (Ptrofs.repr oc)) le /\ m' = m /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x H Hc.
    apply RA.set_inv in H as (v & Ev & -> & -> & ->).
    destruct (RA.ev_gvar G empty_env m le _ (tptr (Tstruct BS._Object noattr)) v Mint32
                (PTree.gempty _ _) eq_refl Ev) as (b & Hb & Hl).
    rewrite Hgo in Hb. injection Hb as <-. cbn [Mem.loadv] in Hl. rewrite Ptrofs.unsigned_zero, Hc in Hl.
    injection Hl as <-. auto.
  Qed.

  (* o->bhvStackIndex *)
  Lemma ld_sidx : forall le m x d v,
    le ! x = Some (Vptr pool (Ptrofs.repr oc)) ->
    Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr d)) ->
    eval_expr G empty_env le m
      (Efield (Ederef (Etempvar x (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
         BS._bhvStackIndex tuint) v -> v = Vint (Int.repr d).
  Proof.
    intros le m x d v Hx Hl Ev.
    destruct (RA.ev_fld G empty_env m le _ _ _ tuint v Mint32 OW.O_SIDX fo_sidx eq_refl Ev) as (b & o & Hb & Hl').
    rewrite Hx in Hb. injection Hb as <- <-. cbn [Mem.loadv] in Hl'.
    rewrite uadd in Hl' by (unfold OW.O_SIDX; try rewrite maxu; lia). rewrite Hl in Hl'. injection Hl' as <-. reflexivity.
  Qed.

  (* o->parentObj *)
  Lemma ld_par : forall le m x v,
    le ! x = Some (Vptr pool (Ptrofs.repr oc)) ->
    eval_expr G empty_env le m
      (Efield (Ederef (Etempvar x (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
         BS._parentObj (tptr (Tstruct BS._Object noattr))) v ->
    Mem.load Mint32 m pool (oc + 104) = Some v.
  Proof.
    intros le m x v Hx Ev.
    destruct (RA.ev_fld G empty_env m le _ _ _ (tptr (Tstruct BS._Object noattr)) v Mint32 104 fo_par eq_refl Ev) as (b & o & Hb & Hl').
    rewrite Hx in Hb. injection Hb as <- <-. cbn [Mem.loadv] in Hl'.
    rewrite uadd in Hl' by (try rewrite maxu; lia). exact Hl'.
  Qed.

  (* o->header.gfx.node.flags (s16 @ 2) *)
  Definition GFL (p : ident) : expr :=
    Efield (Efield (Efield (Efield
      (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
      BS._header (Tstruct BS._ObjectNode noattr)) BS._gfx (Tstruct BS._GraphNodeObject noattr))
      BS._node (Tstruct BS._GraphNode noattr)) BS._flags tshort.

  Lemma lv_gflags : forall m le p b o bf,
    le ! p = Some (Vptr pool (Ptrofs.repr oc)) ->
    eval_lvalue G empty_env le m (GFL p) b o bf ->
    b = pool /\ Ptrofs.unsigned o = oc + 2 /\ bf = Full.
  Proof.
    intros m le p b o bf Hp H. unfold GFL in H.
    destruct (lv_sfld G empty_env m le _ _ _ _ _ _ _ _ H eq_refl fo_gflags) as (o1 & E1 & -> & ->).
    destruct (ev_sfld G empty_env m le _ _ _ _ E1) as (b1 & o1' & Eq & L1). injection Eq as <- <-.
    destruct (lv_sfld G empty_env m le _ _ _ _ _ _ _ _ L1 eq_refl fo_node) as (o2 & E2 & -> & _).
    destruct (ev_sfld G empty_env m le _ _ _ _ E2) as (b2 & o2' & Eq & L2). injection Eq as <- <-.
    destruct (lv_sfld G empty_env m le _ _ _ _ _ _ _ _ L2 eq_refl fo_gfx) as (o3 & E3 & -> & _).
    destruct (ev_sfld G empty_env m le _ _ _ _ E3) as (b3 & o3' & Eq & L3). injection Eq as <- <-.
    destruct (RA.lv_fld G empty_env m le _ _ _ _ _ _ _ _ fo_header L3) as (o4 & Hp' & -> & _).
    rewrite Hp in Hp'. injection Hp' as <- <-.
    split; [ reflexivity | split; [ | reflexivity ] ].
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero.
    apply uadd; try rewrite maxu; lia.
  Qed.

  Lemma ev_gflags : forall m le p v,
    le ! p = Some (Vptr pool (Ptrofs.repr oc)) ->
    eval_expr G empty_env le m (GFL p) v ->
    Mem.load Mint16signed m pool (oc + 2) = Some v.
  Proof.
    intros m le p v Hp H.
    destruct (ev_lv_fld G empty_env m le _ _ _ _ H) as (b & o & bf & Hl & Hd).
    destruct (lv_gflags m le p b o bf Hp Hl) as (-> & Ho & ->).
    pose proof (deref_full _ tshort _ _ _ Mint16signed eq_refl Hd) as Hl2.
    cbn [Mem.loadv] in Hl2. rewrite Ho in Hl2. exact Hl2.
  Qed.

  (* o->header.gfx.scale[k] (f32 @ 44 + 4k) *)
  Definition SCL (p : ident) : expr :=
    Efield (Efield (Efield
      (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
      BS._header (Tstruct BS._ObjectNode noattr)) BS._gfx (Tstruct BS._GraphNodeObject noattr))
      BS._scale (tarray tfloat 3).

  Lemma deref_scl : forall m b o bf v, deref_loc (tarray tfloat 3) m b o bf v -> v = Vptr b o /\ bf = Full.
  Proof.
    intros m b o bf v H. inv H; kill_r. split; reflexivity.
  Qed.

  Lemma lv_scale : forall m le p k b o bf, 0 <= k < 3 ->
    le ! p = Some (Vptr pool (Ptrofs.repr oc)) ->
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd (SCL p) (Econst_int (Int.repr k) tint) (tptr tfloat)) tfloat) b o bf ->
    b = pool /\ Ptrofs.unsigned o = oc + 44 + 4 * k /\ bf = Full.
  Proof.
    intros m le p k b o bf Hk Hp H. inv H.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply RA.ev_const in E2. subst v2.
    unfold SCL in E1.
    destruct (ev_lv_fld G empty_env m le _ _ _ _ E1) as (b1 & o1 & bf1 & L1 & D1).
    destruct (deref_scl _ _ _ _ _ D1) as (-> & ->).
    destruct (lv_sfld G empty_env m le _ _ _ _ _ _ _ _ L1 eq_refl fo_scale) as (o2 & E2' & -> & _).
    destruct (ev_sfld G empty_env m le _ _ _ _ E2') as (b3 & o3 & Eq & L3). injection Eq as <- <-.
    destruct (lv_sfld G empty_env m le _ _ _ _ _ _ _ _ L3 eq_refl fo_gfx) as (o4 & E4 & -> & _).
    destruct (ev_sfld G empty_env m le _ _ _ _ E4) as (b5 & o5 & Eq & L5). injection Eq as <- <-.
    destruct (RA.lv_fld G empty_env m le _ _ _ _ _ _ _ _ fo_header L5) as (o6 & Hp' & -> & _).
    rewrite Hp in Hp'. injection Hp' as <- <-.
    cbn in E3. injection E3 as <- <-.
    split; [ reflexivity | split; [ | reflexivity ] ].
    change (Ptrofs.repr 0) with Ptrofs.zero. rewrite !Ptrofs.add_zero.
    unfold Ptrofs.of_ints. rewrite Int.signed_repr by (cbn; lia).
    unfold Ptrofs.mul. rewrite (Ptrofs.unsigned_repr 4), (Ptrofs.unsigned_repr k) by (rewrite maxu; lia).
    rewrite Ptrofs.add_unsigned. rewrite (uadd oc 44) by (try rewrite maxu; lia).
    rewrite (Ptrofs.unsigned_repr (4 * k)) by (rewrite maxu; lia).
    apply Ptrofs.unsigned_repr. rewrite maxu. lia.
  Qed.

  Lemma cur_store : forall ch m z v m', Mem.store ch m pool z v = Some m' -> cur m -> cur m'.
  Proof.
    intros ch m z v m' Hs Hc. unfold cur. rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hc | ].
    left. intro E. exact (Hpg (eq_sym E)).
  Qed.

  (* tmp = cur_obj_has_behavior(bhvX), the current slot's behavior a valid
     pointer into another block: 0, no store *)
  Lemma cohb_call : forall le m t le' m' out tmp id bs bb ob,
    cur m -> Genv.find_symbol G id = Some bs ->
    Mem.load Mint32 m pool (oc + 524) = Some (Vptr bb ob) -> bb <> bs ->
    Mem.valid_pointer m bb (Ptrofs.unsigned ob) = true -> Mem.valid_pointer m bs 0 = true ->
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some tmp) (Evar BS._cur_obj_has_behavior (Tfunction [tptr tuint] tint cc_default))
         [Evar id (tarray tuint 0)]) t le' m' out ->
    m' = m /\ le' = PTree.set tmp (Vint Int.zero) le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out tmp id bs bb ob Hc Hs Hbh Hne Hv1 Hv2 H.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcl & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [tptr tuint] tint cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->).
    rewrite (fun_oh _ _ dm_cohb bf fd Hsf Hff) in Hcl.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
    apply (ev_gscr _ _ _ _ _ Hs) in Ev1. subst v1.
    cbn in C1. injection C1 as <-.
    apply fcall_inv in Hcl as (lf1 & lf2 & outf & Hbf & Xf & Horf); [ | reflexivity ].
    cbn [fn_params OH.f_cur_obj_has_behavior bind_parameter_temps] in Hbf. injection Hbf as <-.
    cbn [fn_body OH.f_cur_obj_has_behavior] in Xf.
    apply RA.seq_inv in Xf as [(f1 & fe1 & fm1 & f2 & F1 & F2) | (F1 & Xn)]; [ | kill_sq F1 Xn ].
    destruct (s2v_call_p _ _ _ _ _ _ _ _ bs Ptrofs.zero F1 (PTree.gss _ _ _)) as (-> & -> & _).
    apply RA.seq_inv in F2 as [(f3 & fe3 & fm3 & f4 & F3 & F4) | (F3 & Xn)]; [ | kill_sq F3 Xn ].
    apply ld_cur in F3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in F4 as [(f5 & fe5 & fm5 & f6 & F5 & F6) | (F5 & Xn)]; [ | kill_sq F5 Xn ].
    apply RA.set_inv in F5 as (vb & Evb & -> & -> & _).
    destruct (ev_lv_fld G empty_env _ _ _ _ _ _ Evb) as (b1 & o1 & bf1 & L1 & D1).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_bhv L1) as (o2 & Ho2 & -> & ->).
    rewrite PTree.gss in Ho2. injection Ho2 as <- <-.
    pose proof (deref_full _ (tptr tuint) _ _ _ Mint32 eq_refl D1) as Ld.
    cbn [Mem.loadv] in Ld. rewrite uadd in Ld by (try rewrite maxu; lia). rewrite Hbh in Ld.
    injection Ld as <-.
    apply RA.if_inv in F6 as (vc & bq & Ec & Bq & Xi).
    apply RA.ev_binop in Ec as (c1 & c2 & Ec1 & Ec2 & Ecmp).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_temp in Ec2. do 2 rewrite PTree.gso in Ec2 by (vm_compute; discriminate).
    rewrite PTree.gss in Ec2. injection Ec2 as <-.
    cbn [typeof] in Ecmp. rewrite (cmp_ne _ _ _ _ _ Hne Hv1 Hv2) in Ecmp. injection Ecmp as <-.
    cbn in Bq. injection Bq as <-. cbv iota in Xi.
    apply RA.ret_inv in Xi as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Horf. destruct Horf as (_ & Horf). cbn in Horf. injection Horf as <-.
    split; [ reflexivity | split; reflexivity ].
  Qed.

  Lemma stk_addr : forall d, 0 <= d < 8 ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.repr oc) (Ptrofs.repr OW.O_STK))
                       (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_intu (Int.repr d))))
    = oc + OW.O_STK + 4 * d.
  Proof.
    intros d Hd. unfold Ptrofs.of_intu, Ptrofs.of_int. rewrite Int.unsigned_repr by (cbn; lia).
    unfold Ptrofs.mul. rewrite (Ptrofs.unsigned_repr 4), (Ptrofs.unsigned_repr d) by (rewrite maxu; lia).
    rewrite Ptrofs.add_unsigned.
    rewrite (uadd oc OW.O_STK) by (unfold OW.O_STK; try rewrite maxu; lia).
    rewrite (Ptrofs.unsigned_repr (4 * d)) by (rewrite maxu; lia).
    apply Ptrofs.unsigned_repr. unfold OW.O_STK. rewrite maxu. lia.
  Qed.

  (* the body of cur_obj_bhv_stack_push(w) *)
  Lemma push_body : forall m w d t le' m' out,
    cur m -> Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr d)) -> 0 <= d < 8 ->
    sem_cast w tuint tuint m = Some w ->
    exec_stmt function_entry2 G empty_env
      (PTree.set BS._bhvAddr w (create_undef_temps (fn_temps BS.f_cur_obj_bhv_stack_push))) m
      (fn_body BS.f_cur_obj_bhv_stack_push) t le' m' out ->
    out = Out_normal /\ exists m1, Mem.store Mint32 m pool (oc + OW.O_STK + 4 * d) w = Some m1
      /\ Mem.store Mint32 m1 pool (oc + OW.O_SIDX) (Vint (Int.repr (d + 1))) = Some m'.
  Proof.
    intros m w d t le' m' out Hc Hd Hdr Hw H. cbn [fn_body BS.f_cur_obj_bhv_stack_push] in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* bhvStack[sidx] = bhvAddr *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply ld_cur in X5 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vi & Evi & -> & -> & _).
    apply (ld_sidx _ _ _ d) in Evi; [ subst vi | rewrite PTree.gss; reflexivity | exact Hd ].
    apply RA.assign_inv in X8 as (b & o & bf & v2 & v & Hlv & Ev2 & Hcast & Has & -> & _).
    apply lv_deref in Hlv as (Ea & ->).
    apply RA.ev_binop in Ea as (p1 & p2 & Ep1 & Ep2 & Eadd).
    destruct (ev_fld_arr _ _ _ _ _ _ _ _ _ _ _ fo_stk Ep1) as (b0 & o0 & Hb0 & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Hb0 by (vm_compute; discriminate). injection Hb0 as <- <-.
    apply RA.ev_temp in Ep2. rewrite PTree.gss in Ep2. injection Ep2 as <-.
    cbn in Eadd. injection Eadd as <- <-.
    apply RA.ev_temp in Ev2. do 3 (rewrite PTree.gso in Ev2 by (vm_compute; discriminate)).
    rewrite PTree.gss in Ev2. injection Ev2 as <-.
    cbn [typeof] in Hcast. rewrite Hw in Hcast. injection Hcast as <-.
    pose proof (RA.store_by_value _ tuint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    rewrite stk_addr in Hs1 by exact Hdr.
    (* bhvStackIndex = bhvStackIndex + 1 *)
    pose proof (cur_store _ _ _ _ _ Hs1 Hc) as Hc1.
    assert (Hd1 : Mem.load Mint32 m1 pool (oc + OW.O_SIDX) = Some (Vint (Int.repr d))).
    { rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hd | ]. right. left. change (size_chunk Mint32) with 4. unfold OW.O_SIDX, OW.O_STK. lia. }
    apply RA.seq_inv in X2 as [(u3 & ke3 & n3 & u4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in X4 as [(u5 & ke5 & n5 & u6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply ld_cur in X5 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in X6 as [(u7 & ke7 & n7 & u8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vi & Evi & -> & -> & _).
    apply (ld_sidx _ _ _ d) in Evi; [ subst vi | rewrite PTree.gss; reflexivity | exact Hd1 ].
    apply RA.assign_inv in X8 as (b2 & o2 & bf2 & w2 & w3 & Hlv2 & Ew2 & Hcast2 & Has2 & -> & ->).
    destruct (RA.lv_fld G empty_env m1 _ _ _ _ _ _ _ _ _ fo_sidx Hlv2) as (o1 & Ho1 & -> & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Ho1 by (vm_compute; discriminate). injection Ho1 as <- <-.
    apply RA.ev_binop in Ew2 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn in Eadd. injection Eadd as <-.
    cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tuint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has2) as Hs2.
    rewrite uadd in Hs2 by (unfold OW.O_SIDX; try rewrite maxu; lia).
    rewrite Int.add_unsigned, (Int.unsigned_repr d), (Int.unsigned_repr 1) in Hs2 by (cbn; lia).
    split; [ reflexivity | exists m1; split; [ exact Hs1 | exact Hs2 ] ].
  Qed.

  (* the body of cur_obj_bhv_stack_pop() *)
  Lemma pop_body : forall m d t le' m' out,
    cur m -> Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr (d + 1))) -> 0 <= d < 8 ->
    exec_stmt function_entry2 G empty_env
      (create_undef_temps (fn_temps BS.f_cur_obj_bhv_stack_pop)) m
      (fn_body BS.f_cur_obj_bhv_stack_pop) t le' m' out ->
    Mem.store Mint32 m pool (oc + OW.O_SIDX) (Vint (Int.repr d)) = Some m'
    /\ exists v, Mem.load Mint32 m pool (oc + OW.O_STK + 4 * d) = Some v
      /\ out = Out_return (Some (v, tuint)).
  Proof.
    intros m d t le' m' out Hc Hd Hdr H. cbn [fn_body BS.f_cur_obj_bhv_stack_pop] in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply ld_cur in X5 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vi & Evi & -> & -> & _).
    apply (ld_sidx _ _ _ (d + 1)) in Evi; [ subst vi | rewrite PTree.gss; reflexivity | exact Hd ].
    apply RA.assign_inv in X8 as (b2 & o2 & bf2 & w2 & w3 & Hlv2 & Ew2 & Hcast2 & Has2 & -> & _).
    destruct (RA.lv_fld G empty_env m _ _ _ _ _ _ _ _ _ fo_sidx Hlv2) as (o1 & Ho1 & -> & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Ho1 by (vm_compute; discriminate). injection Ho1 as <- <-.
    apply RA.ev_binop in Ew2 as (q1 & q2 & Eq1 & Eq2 & Esub).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn in Esub. injection Esub as <-.
    cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tuint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has2) as Hs1.
    rewrite uadd in Hs1 by (unfold OW.O_SIDX; try rewrite maxu; lia).
    rewrite Int.sub_signed, Int.signed_repr, (Int.signed_repr 1) in Hs1 by (cbn; lia).
    replace (d + 1 - 1) with d in Hs1 by lia.
    pose proof (cur_store _ _ _ _ _ Hs1 Hc) as Hc1.
    assert (Hd1 : Mem.load Mint32 m1 pool (oc + OW.O_SIDX) = Some (Vint (Int.repr d))).
    { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). reflexivity. }
    assert (Hk : forall z, oc + OW.O_STK <= z -> Mem.load Mint32 m1 pool z = Mem.load Mint32 m pool z).
    { intros z Hz. apply (Mem.load_store_other _ _ _ _ _ _ Hs1). right. right.
      change (size_chunk Mint32) with 4. unfold OW.O_SIDX, OW.O_STK in *. lia. }

    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(u3 & ke3 & n3 & u4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in X4 as [(u5 & ke5 & n5 & u6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply ld_cur in X5 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in X6 as [(u7 & ke7 & n7 & u8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vi & Evi & -> & -> & _).
    apply (ld_sidx _ _ _ d) in Evi; [ subst vi | rewrite PTree.gss; reflexivity | exact Hd1 ].
    apply RA.set_inv in X8 as (va & Eva & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in Eva as (b & o & Ea & Hl).
    apply RA.ev_binop in Ea as (p1 & p2 & Ep1 & Ep2 & Eadd).
    destruct (ev_fld_arr _ _ _ _ _ _ _ _ _ _ _ fo_stk Ep1) as (b0 & o0 & Hb0 & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Hb0 by (vm_compute; discriminate). injection Hb0 as <- <-.
    apply RA.ev_temp in Ep2. rewrite PTree.gss in Ep2. injection Ep2 as <-.
    cbn in Eadd. injection Eadd as <- <-.
    cbn [Mem.loadv] in Hl. rewrite stk_addr in Hl by exact Hdr. rewrite Hk in Hl by lia.
    apply RA.ret_inv in X2 as (-> & rv & Erv & ->).
    apply RA.ev_temp in Erv. rewrite PTree.gss in Erv. injection Erv as <-.
    split; [ exact Hs1 | exists va; split; [ exact Hl | reflexivity ] ].
  Qed.

  (* cur_obj_bhv_stack_push(a) as a call statement *)
  Lemma push_call : forall le m a wv d t le' m' out,
    exec_stmt function_entry2 G empty_env le m
      (Scall None (Evar BS._cur_obj_bhv_stack_push (Tfunction [tuint] tvoid cc_default)) [a]) t le' m' out ->
    cur m -> Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr d)) -> 0 <= d < 8 ->
    (forall v1 w, eval_expr G empty_env le m a v1 -> sem_cast v1 (typeof a) tuint m = Some w -> w = wv) ->
    sem_cast wv tuint tuint m = Some wv ->
    le' = le /\ out = Out_normal /\ exists m1, Mem.store Mint32 m pool (oc + OW.O_STK + 4 * d) wv = Some m1
      /\ Mem.store Mint32 m1 pool (oc + OW.O_SIDX) (Vint (Int.repr (d + 1))) = Some m'.
  Proof.
    intros le m a wv d t le' m' out H Hc Hd Hdr Ha Hw.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hx & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [tuint] tvoid cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_bs _ _ dm_push bf fd Hs Hff) in Hx.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
    rewrite (Ha _ _ Ev1 C1) in *.
    apply fcall_inv in Hx as (le1 & le2 & out1 & Hb & Hx2 & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_cur_obj_bhv_stack_push bind_parameter_temps] in Hb. injection Hb as <-.
    destruct (push_body _ _ _ _ _ _ _ Hc Hd Hdr Hw Hx2) as (-> & Hst).
    auto.
  Qed.

  (* x = cur_obj_bhv_stack_pop() *)
  Lemma pop_call : forall le m x d t le' m' out,
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some x) (Evar BS._cur_obj_bhv_stack_pop (Tfunction [] tuint cc_default)) []) t le' m' out ->
    cur m -> Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr (d + 1))) -> 0 <= d < 8 ->
    out = Out_normal /\ Mem.store Mint32 m pool (oc + OW.O_SIDX) (Vint (Int.repr d)) = Some m'
    /\ exists v vr, Mem.load Mint32 m pool (oc + OW.O_STK + 4 * d) = Some v
      /\ sem_cast v tuint tuint m' = Some vr /\ le' = PTree.set x vr le.
  Proof.
    intros le m x d t le' m' out H Hc Hd Hdr.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hx & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [] tuint cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_bs _ _ dm_pop bf fd Hs Hff) in Hx.
    inversion Eal; subst.
    apply fcall_inv in Hx as (le1 & le2 & out1 & Hb & Hx2 & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_cur_obj_bhv_stack_pop bind_parameter_temps] in Hb. injection Hb as <-.
    destruct (pop_body _ _ _ _ _ _ Hc Hd Hdr Hx2) as (Hs1 & v & Hl & ->).
    cbn in Hor. destruct Hor as (_ & Hor).
    split; [ reflexivity | split; [ exact Hs1 | ] ]. exists v, vres. auto.
  Qed.

  (* cur_obj_bhv_stack_pop(), result dropped *)
  Lemma pop_call_none : forall le m d t le' m' out,
    exec_stmt function_entry2 G empty_env le m
      (Scall None (Evar BS._cur_obj_bhv_stack_pop (Tfunction [] tuint cc_default)) []) t le' m' out ->
    cur m -> Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr (d + 1))) -> 0 <= d < 8 ->
    out = Out_normal /\ Mem.store Mint32 m pool (oc + OW.O_SIDX) (Vint (Int.repr d)) = Some m' /\ le' = le.
  Proof.
    intros le m d t le' m' out H Hc Hd Hdr.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hx & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [] tuint cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_bs _ _ dm_pop bf fd Hs Hff) in Hx.
    inversion Eal; subst.
    apply fcall_inv in Hx as (le1 & le2 & out1 & Hb & Hx2 & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_cur_obj_bhv_stack_pop bind_parameter_temps] in Hb. injection Hb as <-.
    destruct (pop_body _ _ _ _ _ _ Hc Hd Hdr Hx2) as (Hs1 & _).
    auto.
  Qed.

  (* ---- the command pointer gCurBhvCommand ---- *)
  Variable bc : block.
  Hypothesis Hbc : Genv.find_symbol G BS._gCurBhvCommand = Some bc.
  Hypothesis Hbp : bc <> pool.
  Hypothesis Hbg : bc <> go.
  (* the slot pool is not a script block *)
  Hypothesis Hps : forall st b, In st vm_tab -> Genv.find_symbol G (v_s st) = Some b -> b <> pool.

  Notation V := (vmc G bc pool oc).

  (* what the VM may write: the command pointer gCurBhvCommand, and the
     slot's VM cells (curBhvCommand, stack index, stack, delay timer) *)
  Definition Pfr (b : block) (z : Z) : Prop :=
    b <> bc /\ ~ (b = pool /\ oc + OW.O_CMD <= z < oc + OW.O_STK + 34).

  Lemma ld_cmd : forall le m t le' m' out x v,
    exec_stmt function_entry2 G empty_env le m (Sset x (Evar BS._gCurBhvCommand (tptr tuint))) t le' m' out ->
    Mem.load Mint32 m bc 0 = Some v -> le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x v H Hl.
    apply RA.set_inv in H as (v' & Ev & -> & -> & ->).
    destruct (RA.ev_gvar G empty_env m le _ (tptr tuint) v' Mint32 (PTree.gempty _ _) eq_refl Ev) as (b & Hb & Hl').
    rewrite Hbc in Hb. injection Hb as <-. cbn [Mem.loadv] in Hl'. rewrite Ptrofs.unsigned_zero, Hl in Hl'.
    injection Hl' as <-. auto.
  Qed.

  Lemma st_cmd : forall le m t le' m' out a,
    exec_stmt function_entry2 G empty_env le m (Sassign (Evar BS._gCurBhvCommand (tptr tuint)) a) t le' m' out ->
    exists v2 v, eval_expr G empty_env le m a v2 /\ sem_cast v2 (typeof a) (tptr tuint) m = Some v
      /\ Mem.store Mint32 m bc 0 v = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out a H.
    apply RA.assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    apply (RA.lv_gvar G empty_env m) in Hlv as (Hb & -> & ->); [ | apply PTree.gempty ].
    rewrite Hbc in Hb. injection Hb as <-.
    pose proof (RA.store_by_value _ (tptr tuint) _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs.
    rewrite Ptrofs.unsigned_zero in Hs. exists v2, v. auto.
  Qed.

  Lemma bc_store : forall m v m', Mem.store Mint32 m bc 0 v = Some m' ->
    (cur m -> cur m') /\ (forall z, Mem.load Mint32 m' pool z = Mem.load Mint32 m pool z)
    /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m v m' Hs. split; [ | split ].
    - intros Hc. unfold cur. rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hc | left; intro E; exact (Hbg (eq_sym E)) ].
    - intros z. apply (Mem.load_store_other _ _ _ _ _ _ Hs). left. intro E; exact (Hbp (eq_sym E)).
    - apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i _ [Hn _]. exact (Hn eq_refl).
  Qed.

  Lemma V_cmd : forall m m' st s' j b,
    V m st -> (forall z, Mem.load Mint32 m' pool z = Mem.load Mint32 m pool z) ->
    Mem.load Mint32 m' bc 0 = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat j))) ->
    Genv.find_symbol G s' = Some b -> V m' {| v_s := s'; v_i := j; v_k := v_k st |}.
  Proof.
    intros m m' st s' j b (_ & Hsi & Hk) Hp Hl Hs. split; [ | split ].
    - exists b. auto.
    - cbn. rewrite Hp. exact Hsi.
    - cbn. intros n f Hn. rewrite Hp. exact (Hk n f Hn).
  Qed.

  Lemma scr_not_bc : forall st b, In st vm_tab -> Genv.find_symbol G (v_s st) = Some b -> b <> bc.
  Proof.
    intros st b Hst Hb E. subst b. destruct (st_facts st Hst) as (_ & Hn & _).
    apply Hn. eapply Genv.genv_vars_inj; [ exact Hb | exact Hbc ].
  Qed.

  (* the word at &s[i'] of a reachable script, read through a pointer the
     handler computed *)
  Lemma ld_word : forall m st b i' d, scr_ok G m -> In st vm_tab ->
    Genv.find_symbol G (v_s st) = Some b -> (i' < 4096)%nat ->
    nth_error (words (v_s st)) i' = Some d ->
    exists v, Mem.loadv Mint32 m (Vptr b (Ptrofs.repr (4 * Z.of_nat i'))) = Some v /\ init_val G d v.
  Proof.
    intros m st b i' d Hscr Hst Hb Hi Hd. cbn [Mem.loadv].
    rewrite Ptrofs.unsigned_repr by (rewrite maxu; lia).
    apply (Hscr (v_s st) b i' d Hb (in_map _ _ _ Hst) Hd).
  Qed.

  (* ---- the VM state split: command pointer / stack ---- *)
  Definition Vcmd (m : mem) (s : ident) (i : nat) : Prop :=
    exists b, Genv.find_symbol G s = Some b
      /\ Mem.load Mint32 m bc 0 = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat i))).
  Definition Vstk (m : mem) (k : list frame) : Prop :=
    Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr (Z.of_nat (List.length k))))
    /\ forall n f, nth_error k n = Some f ->
         OW.frame_ok G f (Mem.load Mint32 m pool
                            (oc + OW.O_STK + 4 * (Z.of_nat (List.length k) - 1 - Z.of_nat n))).

  Lemma V_iff : forall m st, V m st <-> Vcmd m (v_s st) (v_i st) /\ Vstk m (v_k st).
  Proof. intros m st. unfold vmc, Vcmd, Vstk. tauto. Qed.

  Lemma V_mk : forall m st s i k, Vcmd m s i -> Vstk m k -> V m (at_ st s i k).
  Proof. intros m st s i k H1 H2. apply V_iff. cbn [at_ v_s v_i v_k]. auto. Qed.

  Lemma pool_store : forall m z v m', Mem.store Mint32 m pool z v = Some m' ->
    oc + OW.O_SIDX <= z -> z + 4 <= oc + OW.O_STK + 32 ->
    (cur m -> cur m') /\ Mem.load Mint32 m' bc 0 = Mem.load Mint32 m bc 0 /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m z v m' Hs H1 H2. split; [ | split ].
    - exact (cur_store _ _ _ _ _ Hs).
    - apply (Mem.load_store_other _ _ _ _ _ _ Hs). left. exact Hbp.
    - apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i Hi [_ Hn]. apply Hn.
      split; [ reflexivity | ]. change (size_chunk Mint32) with 4 in Hi.
      unfold OW.O_CMD, OW.O_SIDX, OW.O_STK in *. lia.
  Qed.

  Lemma Vcmd_pool : forall m s i z v m', Vcmd m s i -> Mem.store Mint32 m pool z v = Some m' -> Vcmd m' s i.
  Proof.
    intros m s i z v m' (b & Hb & Hl) Hs. exists b. split; [ exact Hb | ].
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hl | left; exact Hbp ].
  Qed.
  Lemma Vcmd_bc : forall m s j b m', Mem.store Mint32 m bc 0 (Vptr b (Ptrofs.repr (4 * Z.of_nat j))) = Some m' ->
    Genv.find_symbol G s = Some b -> Vcmd m' s j.
  Proof.
    intros m s j b m' Hs Hb. exists b. split; [ exact Hb | ].
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hs). reflexivity.
  Qed.
  Lemma Vstk_bc : forall m k v m', Vstk m k -> Mem.store Mint32 m bc 0 v = Some m' -> Vstk m' k.
  Proof.
    intros m k v m' (Hsi & Hk) Hs. destruct (bc_store _ _ _ Hs) as (_ & Hp & _).
    split; [ rewrite Hp; exact Hsi | intros n f Hn; rewrite Hp; exact (Hk n f Hn) ].
  Qed.

  Lemma frame_ok_lr : forall f wv, OW.frame_ok G f (Some wv) -> OW.frame_ok G f (Some (Val.load_result Mint32 wv)).
  Proof.
    intros [s i|] wv H; cbn in H |- *.
    - destruct H as (b & Hb & E). injection E as ->. exists b. auto.
    - destruct H as (c & E). injection E as ->. exists c. reflexivity.
  Qed.

  Lemma Vstk_push : forall m k f wv m1 m2, Vstk m k -> (List.length k < 8)%nat ->
    Mem.store Mint32 m pool (oc + OW.O_STK + 4 * Z.of_nat (List.length k)) wv = Some m1 ->
    Mem.store Mint32 m1 pool (oc + OW.O_SIDX) (Vint (Int.repr (Z.of_nat (List.length k) + 1))) = Some m2 ->
    OW.frame_ok G f (Some wv) -> Vstk m2 (f :: k).
  Proof.
    intros m k f wv m1 m2 (Hsi & Hk) Hlt Hs1 Hs2 Hf. split.
    - rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2). cbn [List.length].
      rewrite Nat2Z.inj_succ, <- Z.add_1_r. reflexivity.
    - intros n f' Hn. assert (Hnl0 : (n < S (List.length k))%nat) by (apply (nth_error_Some (f :: k)); congruence). cbn [List.length]. rewrite Nat2Z.inj_succ.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2)
        by (right; right; change (size_chunk Mint32) with 4; unfold OW.O_SIDX, OW.O_STK; lia).
      destruct n as [|n].
      + cbn in Hn. injection Hn as <-.
        replace (oc + OW.O_STK + 4 * (Z.succ (Z.of_nat (List.length k)) - 1 - Z.of_nat 0))
          with (oc + OW.O_STK + 4 * Z.of_nat (List.length k)) by lia.
        rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). exact (frame_ok_lr _ _ Hf).
      + cbn in Hn. assert (Hnl : (n < List.length k)%nat) by (apply nth_error_Some; congruence).
        replace (oc + OW.O_STK + 4 * (Z.succ (Z.of_nat (List.length k)) - 1 - Z.of_nat (S n)))
          with (oc + OW.O_STK + 4 * (Z.of_nat (List.length k) - 1 - Z.of_nat n)) by lia.
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1)
          by (right; left; change (size_chunk Mint32) with 4; lia).
        exact (Hk n f' Hn).
  Qed.

  Lemma Vstk_pop : forall m f k m', Vstk m (f :: k) ->
    Mem.store Mint32 m pool (oc + OW.O_SIDX) (Vint (Int.repr (Z.of_nat (List.length k)))) = Some m' ->
    Vstk m' k /\ OW.frame_ok G f (Mem.load Mint32 m pool (oc + OW.O_STK + 4 * Z.of_nat (List.length k))).
  Proof.
    intros m f k m' (Hsi & Hk) Hs. split; [ split | ].
    - rewrite (Mem.load_store_same _ _ _ _ _ _ Hs). reflexivity.
    - intros n f' Hn. assert (Hnl : (n < List.length k)%nat) by (apply nth_error_Some; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs)
        by (right; right; change (size_chunk Mint32) with 4; unfold OW.O_SIDX, OW.O_STK; lia).
      specialize (Hk (S n) f' Hn). cbn [List.length] in Hk. rewrite Nat2Z.inj_succ in Hk.
      replace (Z.succ (Z.of_nat (List.length k)) - 1 - Z.of_nat (S n))
        with (Z.of_nat (List.length k) - 1 - Z.of_nat n) in Hk by lia. exact Hk.
    - specialize (Hk 0%nat f eq_refl). cbn [List.length] in Hk. rewrite Nat2Z.inj_succ in Hk.
      replace (Z.succ (Z.of_nat (List.length k)) - 1 - Z.of_nat 0) with (Z.of_nat (List.length k)) in Hk by lia.
      exact Hk.
  Qed.

  Lemma Vstk_sidx1 : forall m f k, Vstk m (f :: k) ->
    Mem.load Mint32 m pool (oc + OW.O_SIDX) = Some (Vint (Int.repr (Z.of_nat (List.length k) + 1))).
  Proof.
    intros m f k (Hsi & _). rewrite Hsi. cbn [List.length]. rewrite Nat2Z.inj_succ, <- Z.add_1_r. reflexivity.
  Qed.

  (* the pushed (u32) command address p + k *)
  Lemma push_arg : forall le m x b I k J, le ! x = Some (Vptr b (Ptrofs.repr I)) -> -1000 <= k <= 1000 ->
    J = I + 4 * k ->
    forall v1 w, eval_expr G empty_env le m
      (Ecast (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr k) tint) (tptr tuint)) tuint) v1 ->
      sem_cast v1 tuint tuint m = Some w -> w = Vptr b (Ptrofs.repr J).
  Proof.
    intros le m x b I k J Hx Hk -> v1 w Ev Hc.
    apply RA.ev_cast in Ev as (v0 & Ev0 & C0). apply RA.ev_binop in Ev0 as (p1 & p2 & E1 & E2 & Eadd).
    apply RA.ev_temp in E1. rewrite Hx in E1. injection E1 as <-. apply RA.ev_const in E2. subst p2.
    cbn [typeof] in Eadd, C0. rewrite add_pi in Eadd. injection Eadd as <-.
    rewrite cast_pu in C0. injection C0 as <-. rewrite ptr_inc in Hc by lia.
    rewrite cast_uu in Hc by eauto. injection Hc as <-. reflexivity.
  Qed.

  (* a pushed int temp (a repeat count) *)
  Lemma push_arg_int : forall le m x n ty, le ! x = Some (Vint n) -> (ty = tint \/ ty = tuint) ->
    forall v1 w, eval_expr G empty_env le m (Etempvar x ty) v1 ->
      sem_cast v1 ty tuint m = Some w -> w = Vint n.
  Proof.
    intros le m x n ty Hx Ht v1 w Ev Hc. apply RA.ev_temp in Ev. rewrite Hx in Ev. injection Ev as <-.
    destruct Ht as [-> | ->]; [ rewrite cast_iu in Hc | rewrite cast_uu in Hc by eauto ];
      injection Hc as <-; reflexivity.
  Qed.

  (* cmd = (u32 * ) x, x a popped command address *)
  Lemma st_cmd_cast : forall le m t le' m' out x v,
    exec_stmt function_entry2 G empty_env le m
      (Sassign (Evar BS._gCurBhvCommand (tptr tuint)) (Ecast (Etempvar x tuint) (tptr tuint))) t le' m' out ->
    le ! x = Some v -> (exists b o, v = Vptr b o) ->
    Mem.store Mint32 m bc 0 v = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x v H Hx (b & o & ->).
    apply st_cmd in H as (v2 & v3 & Ev & Hcast & Hs & -> & ->).
    apply RA.ev_cast in Ev as (v0 & Ev0 & C0). apply RA.ev_temp in Ev0. rewrite Hx in Ev0. injection Ev0 as <-.
    cbn [typeof] in C0, Hcast. rewrite cast_up in C0. injection C0 as <-.
    rewrite cast_pp in Hcast. injection Hcast as <-. auto.
  Qed.


  (* ---- the object RNG (random_u16 / random_float, behavior_script.c):
     a call changes only gRandomSeed16's block ---- *)
  Variable sb : block.
  Hypothesis HsbR : Genv.find_symbol G BS._gRandomSeed16 = Some sb.
  Hypothesis Hsp : pool <> sb.
  Lemma Hsbc : bc <> sb.
  Proof.
    exact (Genv.global_addresses_distinct G
             (ltac:(vm_compute; discriminate) : BS._gCurBhvCommand <> BS._gRandomSeed16) Hbc HsbR).
  Qed.
  Lemma Hsbg : go <> sb.
  Proof.
    exact (Genv.global_addresses_distinct G
             (ltac:(vm_compute; discriminate) : BS._gCurrentObject <> BS._gRandomSeed16) Hgo HsbR).
  Qed.

  (* the only stores random_u16 makes: to gRandomSeed16 (a u16) *)
  Definition seed_st (lv rhs : expr) : bool :=
    match lv with
    | Evar x ty => Pos.eqb x BS._gRandomSeed16 && (if type_eq ty tushort then true else false)
    | _ => false
    end.
  Definition Psd (b : block) (z : Z) : Prop := b <> sb.

  Lemma seed_store : forall lv rhs le m t le' m' out, seed_st lv rhs = true ->
    exec_stmt function_entry2 G empty_env le m (Sassign lv rhs) t le' m' out ->
    Mem.unchanged_on Psd m m'.
  Proof.
    intros lv rhs le m t le' m' out Hc H.
    destruct lv; try discriminate Hc. cbn [seed_st] in Hc.
    apply andb_prop in Hc as [Hx Ht]. apply Pos.eqb_eq in Hx. subst i.
    destruct (type_eq t0 tushort) as [->|]; [ | discriminate Ht ].
    apply RA.assign_inv in H as (b2 & o2 & bf2 & v2 & v3 & Hlv & _ & _ & Has & _ & _).
    inversion Hlv; subst.
    - match goal with Hl : empty_env ! _ = Some _ |- _ => rewrite PTree.gempty in Hl; discriminate Hl end.
    - match goal with Hf : Genv.find_symbol _ _ = Some _ |- _ => rewrite HsbR in Hf; injection Hf as <- end.
      pose proof (RA.store_by_value _ tushort _ _ _ _ _ _ Mint16unsigned eq_refl eq_refl Has) as Hs.
      apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i _ Hp. apply Hp. reflexivity.
  Qed.

  Lemma no_call : forall optid a al le m t le' m' out,
    (fun (_ : option ident) (_ : expr) (_ : list expr) => false) optid a al = true -> True ->
    exec_stmt function_entry2 G empty_env le m (Scall optid a al) t le' m' out ->
    forall m0, Mem.unchanged_on Psd m0 m -> Mem.unchanged_on Psd m0 m' /\ True.
  Proof. intros optid a al le m t le' m' out Hok. discriminate Hok. Qed.

  Lemma ru16 : forall m t m' vr,
    eval_funcall function_entry2 G m (Internal BS.f_random_u16) [] t m' vr ->
    Mem.unchanged_on Psd m m' /\ exists n, vr = Vint n /\ 0 <= Int.unsigned n < 65536.
  Proof.
    intros m t m' vr H.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    destruct (SpawnBodies.sw_walk G empty_env (Mem.unchanged_on Psd m) (fun _ => True) (fun _ => True)
      (fun _ _ => true) seed_st (fun _ _ _ => false) (fun _ => true)
      (fun _ _ _ _ _ _ _ _ _ => I)
      (fun lv rhs le m0 t0 le' m0' out Hok _ Hx Hf =>
         Mem.unchanged_on_trans _ _ _ _ Hf (seed_store _ _ _ _ _ _ _ _ Hok Hx))
      (fun optid a al le m0 t0 le' m0' out Hok Hp Hx Hf => no_call optid a al le m0 t0 le' m0' out Hok Hp Hx m Hf)
      (fun _ _ _ _ _ _ _ _ => I)
      _ _ _ _ _ _ _ _ X eq_refl ltac:(vm_compute; reflexivity) I (Mem.unchanged_on_refl _ _)) as (U & _ & _).
    split; [ exact U | ].
    cbn [fn_return BS.f_random_u16] in Hor.
    destruct out1 as [| | | [[v ty]|]]; cbn in Hor; try contradiction.
    destruct Hor as [_ Hc]. exact (cast_u16 _ _ _ _ Hc).
  Qed.

  Lemma dm_ru16 : (prog_defmap BS.prog) ! BS._random_u16 = Some (Gfun (Internal BS.f_random_u16)).
  Proof. vm_compute. reflexivity. Qed.

  (* tmp = random_u16() *)
  Lemma ru16_call : forall le m tmp t le' m' out,
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some tmp) (Evar BS._random_u16 (Tfunction [] tushort cc_default)) []) t le' m' out ->
    out = Out_normal /\ Mem.unchanged_on Psd m m'
    /\ exists n, le' = PTree.set tmp (Vint n) le /\ 0 <= Int.unsigned n < 65536.
  Proof.
    intros le m tmp t le' m' out H.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hx & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [] tushort cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_bs _ _ dm_ru16 bf fd Hs Hff) in Hx.
    inversion Eal; subst.
    destruct (ru16 _ _ _ _ Hx) as (U & n & -> & Hn).
    split; [ reflexivity | split; [ exact U | exists n; split; [ reflexivity | exact Hn ] ] ].
  Qed.

  (* random_float's value: (f32)((f64)(f32)u / 65536.0), u a random_u16 *)
  Definition rf_of (n : int) : float32 :=
    Float.to_single (Float.div (Float.of_single (Float32.of_intu n)) (Float.of_int (Int.repr 65536))).

  Lemma rflt : forall m t m' vr,
    eval_funcall function_entry2 G m (Internal BS.f_random_float) [] t m' vr ->
    Mem.unchanged_on Psd m m' /\ exists n, 0 <= Int.unsigned n < 65536 /\ vr = Vsingle (rf_of n).
  Proof.
    intros m t m' vr H.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_random_float bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_random_float] in X.
    apply RA.seq_inv in X as [(t1 & le3 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le4 & m3 & t4 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    destruct (ru16_call _ _ _ _ _ _ _ Y1) as (_ & U & n & -> & Hn).
    apply RA.set_inv in Y2 as (vr1 & Evr & -> & -> & _).
    apply RA.ev_cast in Evr as (x & Ex & Cx). apply RA.ev_temp in Ex. rewrite PTree.gss in Ex. injection Ex as <-.
    cbn in Cx.
    apply RA.ret_inv in X2 as (-> & rv & Erv & ->).
    apply RA.ev_binop in Erv as (a1 & a2 & Ea1 & Ea2 & Ediv).
    apply RA.ev_temp in Ea1. rewrite PTree.gss in Ea1. injection Ea1 as <-.
    apply RA.ev_cast in Ea2 as (c & Ec & Cc). apply RA.ev_const in Ec. subst c.
    cbn [fn_return BS.f_random_float] in Hor. cbn in Hor.
    injection Cx as <-. cbn -[Float.of_int] in Cc. injection Cc as <-.
    cbn -[Float.div Float.of_single Float32.of_intu Float.of_int] in Ediv. injection Ediv as <-.
    destruct Hor as [_ Hor]. injection Hor as <-.
    split; [ exact U | exists n; split; [ exact Hn | reflexivity ] ].
  Qed.

  Lemma dm_rf : (prog_defmap BS.prog) ! BS._random_float = Some (Gfun (Internal BS.f_random_float)).
  Proof. vm_compute. reflexivity. Qed.

  (* tmp = random_float() *)
  Lemma rf_call : forall le m tmp t le' m' out,
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some tmp) (Evar BS._random_float (Tfunction [] tfloat cc_default)) []) t le' m' out ->
    out = Out_normal /\ Mem.unchanged_on Psd m m'
    /\ exists n, le' = PTree.set tmp (Vsingle (rf_of n)) le /\ 0 <= Int.unsigned n < 65536.
  Proof.
    intros le m tmp t le' m' out H.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hx & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m le _ (Tfunction [] tfloat cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (fun_bs _ _ dm_rf bf fd Hs Hff) in Hx.
    inversion Eal; subst.
    destruct (rflt _ _ _ _ Hx) as (U & n & Hn & ->).
    split; [ reflexivity | split; [ exact U | exists n; split; [ reflexivity | exact Hn ] ] ].
  Qed.

  (* what a seed-only change keeps of the stepper's cells *)
  Lemma seed_V : forall m m' st, Mem.unchanged_on Psd m m' -> V m st -> V m' st.
  Proof.
    intros m m' st U HV. apply V_iff in HV as ((b & Hsb' & Hcm) & Hsi & Hk). apply V_iff.
    split; [ exists b; split; [ exact Hsb' | ] | split ].
    - apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros i _; exact Hsbc | exact Hcm ].
    - apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros i _; exact Hsp | exact Hsi ].
    - intros j f Hj. specialize (Hk j f Hj). unfold OW.frame_ok in Hk |- *.
      destruct f as [s0 i0 |].
      + destruct Hk as (b0 & Hb0 & Hl). exists b0. split; [ exact Hb0 | ].
        apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros i _; exact Hsp | exact Hl ].
      + destruct Hk as (c & Hl). exists c.
        apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros i _; exact Hsp | exact Hl ].
  Qed.
  Lemma seed_cur : forall m m', Mem.unchanged_on Psd m m' -> cur m -> cur m'.
  Proof.
    intros m m' U Hc. unfold cur.
    apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros i _; exact Hsbg | exact Hc ].
  Qed.
  (* ---- GOTO (0x04) ---- *)
  Lemma hd_goto : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 4 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_goto) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 0) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & _ & l & Hl & _).
    pose proof (succs_goto st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb (List.length (words (v_s st))) (v_i st + 2)) eqn:Elt; [ discriminate Es | ].
    apply Nat.ltb_ge in Elt.
    destruct (target_at (v_s st) (v_i st + 1)) as [[tt j]|] eqn:Et; [ | discriminate Es ].
    destruct (tgt_ok _ _ _ _ Et) as (o & Ed & ->).
    destruct HV as ((b & Hsb & Hcm) & Hsi & Hk). remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_goto bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_goto] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* gCurBhvCommand = gCurBhvCommand + 1 *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply st_cmd in X4 as (v2 & v & Ev & Hcast & Hs1 & -> & _).
    apply RA.ev_binop in Ev as (p1 & p2 & Ep1 & Ep2 & Eadd).
    apply RA.ev_temp in Ep1. rewrite PTree.gss in Ep1. injection Ep1 as <-.
    apply RA.ev_const in Ep2. subst p2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
    rewrite ptr_inc in Hs1 by lia.
    destruct (bc_store _ _ _ Hs1) as (Hc1 & Hp1 & U1). specialize (Hc1 Hc).
    (* the target word *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply RA.seq_inv in Y3 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    assert (Lc1 : Mem.load Mint32 m1 bc 0
                  = Some (Vptr b (Ptrofs.repr (I4 + 4 * 1)))).
    { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). reflexivity. }
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y5 Lc1) as (-> & -> & _).
    apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & X8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.set_inv in Y7 as (va & Eva & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in Eva as (b1 & o1 & Ea & Hla).
    apply RA.ev_binop in Ea as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <- <-.
    rewrite ptr_inc in Hla by lia.
    norm_off Hla (4 * Z.of_nat (v_i st + 1)).
    assert (Hla2 : Mem.load Mint32 m b (4 * Z.of_nat (v_i st + 1)) = Some va).
    { cbn [Mem.loadv] in Hla. rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) in Hla
        by (left; exact (scr_not_bc st b Hst Hsb)).
      rewrite Ptrofs.unsigned_repr in Hla by (rewrite maxu; lia). exact Hla. }
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Ed) as (va' & Hla' & Hiv).
    rewrite Hla' in Hla2. injection Hla2 as <-.
    destruct Hiv as (bt & Hbt & ->).
    apply (s2v_call _ _ _ _ _ _ _ _ bt (Ptrofs.repr (4 * Z.of_nat j))) in X8 as (-> & -> & _);
      [ | rewrite PTree.gss; reflexivity ].
    (* gCurBhvCommand = jumpAddress *)
    apply st_cmd in Y4 as (v3 & v4 & Ev3 & Hcast3 & Hs2 & -> & _).
    apply RA.ev_temp in Ev3. rewrite PTree.gss in Ev3. injection Ev3 as <-.
    cbn [typeof] in Hcast3. rewrite cast_pp in Hcast3. injection Hcast3 as <-.
    destruct (bc_store _ _ _ Hs2) as (Hc2 & Hp2 & U2). specialize (Hc2 Hc1).
    apply RA.ret_inv in Y2 as (-> & rv & Erv & ->).
    apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    subst I4. injection Es as Es. subst l. exists [at_ st tt j (v_k st)], (at_ st tt j (v_k st)).
    split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply (V_cmd m _ st tt j bt); [ exact (conj (ex_intro _ b (conj Hsb Hcm)) (conj Hsi Hk)) | | | exact Hbt ].
      + intros z. rewrite Hp2, Hp1. reflexivity.
      + exact (Mem.load_store_same _ _ _ _ _ _ Hs2).
    - split; [ exact Hc2 | split; [ reflexivity | ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ U1 U2).
  Qed.

  Ltac stk_bounds := unfold OW.O_SIDX, OW.O_STK; lia.

  (* ---- BEGIN_LOOP (0x08) ---- *)
  Lemma hd_begin_loop : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 8 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_begin_loop) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 0) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & _ & l & Hl & Hcl).
    pose proof (succs_begin_loop st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    destruct (st_facts _ (Hcl _ (or_introl eq_refl))) as (_ & _ & Hd' & _).
    cbn [at_ v_k List.length] in Hd'.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_begin_loop bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_begin_loop] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    (* push(cmd + 1) *)
    destruct (push_call _ _ _ (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st + 1))))
                (Z.of_nat (List.length (v_k st))) _ _ _ _ X4 Hc (proj1 HS) ltac:(lia)
                (push_arg _ _ _ b I4 1 (4 * Z.of_nat (v_i st + 1)) (PTree.gss _ _ _) ltac:(lia) ltac:(lia))
                (cast_uu _ _ (or_introl (ex_intro _ b (ex_intro _ _ eq_refl)))))
      as (-> & _ & m5 & Hs5 & Hs6).
    destruct (pool_store _ _ _ _ Hs5 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc5 & Lb5 & U5).
    destruct (pool_store _ _ _ _ Hs6 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc6 & Lb6 & U6).
    pose proof (Vstk_push _ _ (FAddr (v_s st) (v_i st + 1)) _ _ _ HS ltac:(lia) Hs5 Hs6
                  (ex_intro _ b (conj Hsb eq_refl))) as HS1.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    assert (Lc1 : Mem.load Mint32 m1 bc 0 = Some (Vptr b (Ptrofs.repr I4))) by (rewrite Lb6, Lb5; exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Lc1) as (-> & -> & _).
    apply st_cmd in Y4 as (v2 & v & Ev & Hcast & Hs7 & -> & _).
    apply RA.ev_binop in Ev as (p1 & p2 & Ep1 & Ep2 & Eadd).
    apply RA.ev_temp in Ep1. rewrite PTree.gss in Ep1. injection Ep1 as <-.
    apply RA.ev_const in Ep2. subst p2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
    rewrite ptr_inc in Hs7 by lia. norm_off Hs7 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs7) as (Hc7 & _ & U7).
    apply RA.ret_inv in Y2 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs7 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs7) ].
    - split; [ exact (Hc7 (Hc6 (Hc5 Hc))) | split; [ reflexivity | ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U5 U6) U7).
  Qed.

  (* ---- END_LOOP (0x09) ---- *)
  Lemma hd_end_loop : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 9 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_end_loop) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 1) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_end_loop st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    apply V_iff in HV as (HC & HS).
    destruct (v_k st) as [|f k'] eqn:Ek; [ discriminate Es | ].
    destruct f as [t0 j0|]; [ | discriminate Es ].
    injection Es as Es. subst l. cbn [List.length] in Hd.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_end_loop bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_end_loop] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    (* cmd = pop() *)
    destruct (pop_call _ _ _ (Z.of_nat (List.length k')) _ _ _ _ X3 Hc (Vstk_sidx1 _ _ _ HS) ltac:(lia))
      as (_ & Hs4 & v & vr1 & Hv & Hcv & ->).
    destruct (Vstk_pop _ _ _ _ HS Hs4) as (HS4 & Hf). rewrite Hv in Hf.
    destruct Hf as (bt & Hbt & Ev). injection Ev as ->.
    rewrite cast_uu in Hcv by (left; do 2 eexists; reflexivity). injection Hcv as <-.
    destruct (pool_store _ _ _ _ Hs4 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc4 & Lb4 & U4).
    destruct (st_cmd_cast _ _ _ _ _ _ _ _ X4 (PTree.gss _ _ _) (ex_intro _ _ (ex_intro _ _ eq_refl))) as (Hs5 & -> & _).
    destruct (bc_store _ _ _ Hs5) as (Hc5 & Hp5 & U5).
    pose proof (Vstk_bc _ _ _ _ HS4 Hs5) as HS5.
    (* push(cmd + 0) *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 (Mem.load_store_same _ _ _ _ _ _ Hs5)) as (-> & -> & _).
    destruct (push_call _ _ _ (Vptr bt (Ptrofs.repr (4 * Z.of_nat j0)))
                (Z.of_nat (List.length k')) _ _ _ _ Y4 (Hc5 (Hc4 Hc)) (proj1 HS5) ltac:(lia)
                (push_arg _ _ _ bt (4 * Z.of_nat j0) 0 (4 * Z.of_nat j0) (PTree.gss _ _ _) ltac:(lia) ltac:(lia))
                (cast_uu _ _ (or_introl (ex_intro _ bt (ex_intro _ _ eq_refl)))))
      as (-> & _ & m6 & Hs6 & Hs7).
    destruct (pool_store _ _ _ _ Hs6 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc6 & Lb6 & U6).
    destruct (pool_store _ _ _ _ Hs7 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc7 & Lb7 & U7).
    pose proof (Vstk_push _ _ (FAddr t0 j0) _ _ _ HS5 ltac:(lia) Hs6 Hs7
                  (ex_intro _ bt (conj Hbt eq_refl))) as HS7.
    apply RA.ret_inv in Y2 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ | exact HS7 ].
      exact (Vcmd_pool _ _ _ _ _ _ (Vcmd_pool _ _ _ _ _ _ (Vcmd_bc _ _ _ _ _ Hs5 Hbt) Hs6) Hs7).
    - split; [ exact (Hc7 (Hc6 (Hc5 (Hc4 Hc)))) | split; [ reflexivity | ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _
               (Mem.unchanged_on_trans _ _ _ _ U4 U5) U6) U7).
  Qed.

  (* ---- RETURN (0x03) ---- *)
  Lemma hd_return : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 3 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_return) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 0) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_return st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    apply V_iff in HV as (HC & HS).
    destruct (v_k st) as [|f k'] eqn:Ek; [ discriminate Es | ].
    destruct f as [t0 j0|]; [ | discriminate Es ].
    injection Es as Es. subst l. cbn [List.length] in Hd.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_return bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_return] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (pop_call _ _ _ (Z.of_nat (List.length k')) _ _ _ _ X3 Hc (Vstk_sidx1 _ _ _ HS) ltac:(lia))
      as (_ & Hs4 & v & vr1 & Hv & Hcv & ->).
    destruct (Vstk_pop _ _ _ _ HS Hs4) as (HS4 & Hf). rewrite Hv in Hf.
    destruct Hf as (bt & Hbt & Ev). injection Ev as ->.
    rewrite cast_uu in Hcv by (left; do 2 eexists; reflexivity). injection Hcv as <-.
    destruct (pool_store _ _ _ _ Hs4 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc4 & Lb4 & U4).
    destruct (st_cmd_cast _ _ _ _ _ _ _ _ X4 (PTree.gss _ _ _) (ex_intro _ _ (ex_intro _ _ eq_refl))) as (Hs5 & -> & _).
    destruct (bc_store _ _ _ Hs5) as (Hc5 & Hp5 & U5).
    apply RA.ret_inv in X2 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs5 Hbt) | exact (Vstk_bc _ _ _ _ HS4 Hs5) ].
    - split; [ exact (Hc5 (Hc4 Hc)) | split; [ reflexivity | ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ U4 U5).
  Qed.

  (* ---- CALL (0x02) ---- *)
  Lemma hd_call : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 2 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_call) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 0) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & _ & l & Hl & Hcl).
    pose proof (succs_call st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    destruct (target_at (v_s st) (v_i st + 1)) as [[tt j]|] eqn:Et; [ | discriminate Es ].
    destruct (tgt_ok _ _ _ _ Et) as (o & Ed & ->).
    injection Es as Es. subst l.
    destruct (st_facts _ (Hcl _ (or_introl eq_refl))) as (_ & _ & Hd' & _).
    cbn [at_ v_k List.length] in Hd'.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_call bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_call] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply st_cmd in X4 as (v2 & v & Ev & Hcast & Hs1 & -> & _).
    apply RA.ev_binop in Ev as (p1 & p2 & Ep1 & Ep2 & Eadd).
    apply RA.ev_temp in Ep1. rewrite PTree.gss in Ep1. injection Ep1 as <-.
    apply RA.ev_const in Ep2. subst p2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
    rewrite ptr_inc in Hs1 by lia.
    destruct (bc_store _ _ _ Hs1) as (Hc1 & Hp1 & U1). specialize (Hc1 Hc).
    pose proof (Vstk_bc _ _ _ _ HS Hs1) as HS1.
    (* push(cmd + 1) *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 (Mem.load_store_same _ _ _ _ _ _ Hs1)) as (-> & -> & _).
    destruct (push_call _ _ _ (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st + 2))))
                (Z.of_nat (List.length (v_k st))) _ _ _ _ Y4 Hc1 (proj1 HS1) ltac:(lia)
                (push_arg _ _ _ b (I4 + 4 * 1) 1 (4 * Z.of_nat (v_i st + 2)) (PTree.gss _ _ _) ltac:(lia) ltac:(lia))
                (cast_uu _ _ (or_introl (ex_intro _ b (ex_intro _ _ eq_refl)))))
      as (-> & _ & m5 & Hs5 & Hs6).
    destruct (pool_store _ _ _ _ Hs5 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc5 & Lb5 & U5).
    destruct (pool_store _ _ _ _ Hs6 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc6 & Lb6 & U6).
    pose proof (Vstk_push _ _ (FAddr (v_s st) (v_i st + 2)) _ _ _ HS1 ltac:(lia) Hs5 Hs6
                  (ex_intro _ b (conj Hsb eq_refl))) as HS6.
    (* jumpAddress = segmented_to_virtual( *(cmd + 0)) *)
    apply RA.seq_inv in Y2 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.seq_inv in Y5 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    assert (Lc6 : Mem.load Mint32 n1 bc 0 = Some (Vptr b (Ptrofs.repr (I4 + 4 * 1)))).
    { rewrite Lb6, Lb5. exact (Mem.load_store_same _ _ _ _ _ _ Hs1). }
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y9 Lc6) as (-> & -> & _).
    apply RA.seq_inv in Y10 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.set_inv in Y11 as (va & Eva & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in Eva as (b1 & o1 & Ea & Hla).
    apply RA.ev_binop in Ea as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <- <-.
    rewrite ptr_inc in Hla by lia.
    norm_off Hla (4 * Z.of_nat (v_i st + 1)).
    assert (Hla2 : Mem.load Mint32 m b (4 * Z.of_nat (v_i st + 1)) = Some va).
    { cbn [Mem.loadv] in Hla. rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6), (Mem.load_store_other _ _ _ _ _ _ Hs5) in Hla by (left; exact (Hps st b Hst Hsb)).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) in Hla by (left; exact (scr_not_bc st b Hst Hsb)).
      rewrite Ptrofs.unsigned_repr in Hla by (rewrite maxu; lia). exact Hla. }
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Ed) as (va' & Hla' & Hiv).
    rewrite Hla' in Hla2. injection Hla2 as <-.
    destruct Hiv as (bt & Hbt & ->).
    apply (s2v_call _ _ _ _ _ _ _ _ bt (Ptrofs.repr (4 * Z.of_nat j))) in Y12 as (-> & -> & _);
      [ | rewrite PTree.gss; reflexivity ].
    apply RA.set_inv in Y8 as (vj & Evj & -> & -> & _).
    apply RA.ev_temp in Evj. rewrite PTree.gss in Evj. injection Evj as <-.
    (* cmd = jumpAddress *)
    apply RA.seq_inv in Y6 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    apply st_cmd in Y13 as (v3 & v4 & Ev3 & Hcast3 & Hs7 & -> & _).
    apply RA.ev_temp in Ev3. rewrite PTree.gss in Ev3. injection Ev3 as <-.
    cbn [typeof] in Hcast3. rewrite cast_pp in Hcast3. injection Hcast3 as <-.
    destruct (bc_store _ _ _ Hs7) as (Hc7 & Hp7 & U7).
    apply RA.ret_inv in Y14 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs7 Hbt) | exact (Vstk_bc _ _ _ _ HS6 Hs7) ].
    - split; [ exact (Hc7 (Hc6 (Hc5 Hc1))) | split; [ reflexivity | ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _
               (Mem.unchanged_on_trans _ _ _ _ U1 U5) U6) U7).
  Qed.

  Ltac uchain := repeat (eapply Mem.unchanged_on_trans; [ eassumption | ]); eassumption.

  (* ---- BREAK (0x0A) / BREAK_UNUSED (0x0B) ---- *)
  Lemma hd_break : forall f m st w t m' vr,
    (f = BS.f_bhv_cmd_break \/ f = BS.f_bhv_cmd_break_unused) ->
    (Z.shiftr w 24 = 10 \/ Z.shiftr w 24 = 11) ->
    In st vm_tab -> V m st -> cur m -> word_at (v_s st) (v_i st) = Some w ->
    eval_funcall function_entry2 G m (Internal f) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 1) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros f m st w t m' vr Hf Ho Hst HV Hc Hw H.
    destruct (st_facts st Hst) as (_ & _ & _ & l & Hl & _).
    pose proof (succs_break st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _); [ discriminate Es | ]. injection Es as Es. subst l.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | destruct Hf as [-> | ->]; reflexivity ].
    assert (Eb : fn_body f = Sreturn (Some (Econst_int (Int.repr 1) tint)) /\ fn_return f = tint)
      by (destruct Hf as [-> | ->]; split; reflexivity).
    destruct Eb as (Eb & Er). rewrite Eb in X. rewrite Er in Hor.
    apply RA.ret_inv in X as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    exists [st], st. split; [ exact Hl | split; [ left; reflexivity | ] ].
    split; [ exact HV | split; [ exact Hc | split; [ reflexivity | apply Mem.unchanged_on_refl ] ] ].
  Qed.

  (* ---- BEGIN_REPEAT (0x05) ---- *)
  Lemma hd_begin_repeat : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 5 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_begin_repeat) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 0) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & _ & l & Hl & Hcl).
    pose proof (succs_begin_repeat st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    destruct (st_facts _ (Hcl _ (or_introl eq_refl))) as (_ & _ & Hd' & _).
    cbn [at_ v_k List.length] in Hd'.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_begin_repeat bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_begin_repeat] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* count = ( *cmd) & 0xFFFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (va & _ & -> & -> & _).
    apply RA.set_inv in X6 as (vc & Evc & -> & -> & _).
    apply RA.ev_cast in Evc as (x & _ & Cx). cbn [typeof] in Cx.
    destruct (cast_short _ _ _ Cx) as (cn & ->).
    (* push(cmd + 1) *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    destruct (push_call _ _ _ (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st + 1))))
                (Z.of_nat (List.length (v_k st))) _ _ _ _ Y4 Hc (proj1 HS) ltac:(lia)
                (push_arg _ _ _ b I4 1 (4 * Z.of_nat (v_i st + 1)) (PTree.gss _ _ _) ltac:(lia) ltac:(lia))
                (cast_uu _ _ (or_introl (ex_intro _ b (ex_intro _ _ eq_refl)))))
      as (-> & _ & m6 & Hs6 & Hs7).
    destruct (pool_store _ _ _ _ Hs6 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc6 & Lb6 & U6).
    destruct (pool_store _ _ _ _ Hs7 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc7 & Lb7 & U7).
    pose proof (Vstk_push _ _ (FAddr (v_s st) (v_i st + 1)) _ _ _ HS ltac:(lia) Hs6 Hs7
                  (ex_intro _ b (conj Hsb eq_refl))) as HS7.
    (* push(count) *)
    apply RA.seq_inv in Y2 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    match type of Y5 with exec_stmt _ _ _ ?le _ _ _ _ _ _ =>
      assert (Hcn : le ! BS._count = Some (Vint cn))
        by (rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss) end.
    destruct (push_call _ _ _ (Vint cn)
                (Z.of_nat (List.length (FAddr (v_s st) (v_i st + 1) :: v_k st))) _ _ _ _ Y5
                (Hc7 (Hc6 Hc)) (proj1 HS7) ltac:(cbn [List.length]; lia)
                (push_arg_int _ _ _ _ _ Hcn (or_introl eq_refl))
                (cast_uu _ _ (or_intror (ex_intro _ cn eq_refl))))
      as (-> & _ & m8 & Hs8 & Hs9).
    destruct (pool_store _ _ _ _ Hs8 ltac:(stk_bounds) ltac:(cbn [List.length] in *; stk_bounds)) as (Hc8 & Lb8 & U8).
    destruct (pool_store _ _ _ _ Hs9 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc9 & Lb9 & U9).
    pose proof (Vstk_push _ _ FCount _ _ _ HS7 ltac:(cbn [List.length]; lia) Hs8 Hs9
                  (ex_intro _ cn eq_refl)) as HS9.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    assert (Lc : Mem.load Mint32 n5 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite Lb9, Lb8, Lb7, Lb6; exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y9 Lc) as (-> & -> & _).
    apply st_cmd in Y10 as (v2 & v & Ev & Hcast & Hs10 & -> & _).
    apply RA.ev_binop in Ev as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
    rewrite ptr_inc in Hs10 by lia. norm_off Hs10 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs10) as (Hc10 & _ & U10).
    apply RA.ret_inv in Y8 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs10 Hsb) | exact (Vstk_bc _ _ _ _ HS9 Hs10) ].
    - split; [ exact (Hc10 (Hc9 (Hc8 (Hc7 (Hc6 Hc))))) | split; [ reflexivity | ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U6 U7) U8) U9) U10).
  Qed.

  (* ---- END_REPEAT (0x06) / END_REPEAT_CONTINUE (0x07) ---- *)
  Lemma hd_end_repeat : forall f rc m st w t m' vr,
    (f = BS.f_bhv_cmd_end_repeat /\ rc = 1 /\ Z.shiftr w 24 = 6
     \/ f = BS.f_bhv_cmd_end_repeat_continue /\ rc = 0 /\ Z.shiftr w 24 = 7) ->
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w ->
    eval_funcall function_entry2 G m (Internal f) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr rc) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros f rc m st w t m' vr Hf Hst HV Hc Hw H.
    assert (Eb : fn_body f = er_body rc /\ fn_vars f = [] /\ fn_params f = [] /\ fn_return f = tint
                 /\ (Z.shiftr w 24 = 6 \/ Z.shiftr w 24 = 7))
      by (destruct Hf as [(-> & -> & Ho) | (-> & -> & Ho)]; [ exact (conj er_1 (conj eq_refl (conj eq_refl (conj eq_refl (or_introl Ho))))) | exact (conj er_0 (conj eq_refl (conj eq_refl (conj eq_refl (or_intror Ho))))) ]).
    destruct Eb as (Eb & Ev0 & Ep0 & Er0 & Ho).
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_end_repeat st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    destruct (v_k st) as [|f1 k1] eqn:Ek; [ discriminate Es | ].
    destruct f1 as [s1 i1|]; [ discriminate Es | ].
    destruct k1 as [|f2 k']; [ discriminate Es | ].
    destruct f2 as [t0 j0|]; [ | discriminate Es ].
    injection Es as Es. subst l. cbn [List.length] in Hd.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | exact Ev0 ].
    rewrite Ep0 in Hb. cbn [bind_parameter_temps] in Hb. injection Hb as <-.
    rewrite Eb in X. unfold er_body in X. cbn [fn_body BS.f_bhv_cmd_end_repeat] in X.
    rewrite Er0 in Hor.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    (* count = pop() *)
    destruct (pop_call _ _ _ (Z.of_nat (List.length (FAddr t0 j0 :: k'))) _ _ _ _ X3 Hc
                (Vstk_sidx1 _ _ _ HS) ltac:(cbn [List.length]; lia))
      as (_ & Hs4 & v & vr1 & Hv & Hcv & ->).
    destruct (Vstk_pop _ _ _ _ HS Hs4) as (HS4 & Hf1). rewrite Hv in Hf1.
    destruct Hf1 as (c & Ec). injection Ec as ->.
    rewrite cast_uu in Hcv by (right; eexists; reflexivity). injection Hcv as <-.
    destruct (pool_store _ _ _ _ Hs4 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc4 & Lb4 & U4).
    apply RA.set_inv in X4 as (vcnt & Evc & -> & -> & _).
    apply RA.ev_temp in Evc. rewrite PTree.gss in Evc. injection Evc as <-.
    (* count = count - 1 *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.set_inv in Y1 as (vc1 & Evc1 & -> & -> & _).
    apply RA.ev_binop in Evc1 as (p1 & p2 & Ep1 & Ep2 & Esub).
    apply RA.ev_temp in Ep1. rewrite PTree.gss in Ep1. injection Ep1 as <-.
    apply RA.ev_const in Ep2. subst p2. cbn [typeof] in Esub. rewrite sub_ui in Esub. injection Esub as <-.
    apply RA.seq_inv in Y2 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply RA.ret_inv in Y4 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    apply RA.if_inv in Y3 as (vb & bb & _ & _ & Y3).
    destruct bb.
    - (* count != 0: back to the loop head, the frames pushed again *)
      apply RA.seq_inv in Y3 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
      apply RA.seq_inv in Y5 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
      destruct (pop_call _ _ _ (Z.of_nat (List.length k')) _ _ _ _ Y7 (Hc4 Hc) (Vstk_sidx1 _ _ _ HS4) ltac:(lia))
        as (_ & Hs5 & v5 & vr5 & Hv5 & Hcv5 & ->).
      destruct (Vstk_pop _ _ _ _ HS4 Hs5) as (HS5 & Hf5). rewrite Hv5 in Hf5.
      destruct Hf5 as (bt & Hbt & Ev5). injection Ev5 as ->.
      rewrite cast_uu in Hcv5 by (left; do 2 eexists; reflexivity). injection Hcv5 as <-.
      destruct (pool_store _ _ _ _ Hs5 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc5 & Lb5 & U5).
      destruct (st_cmd_cast _ _ _ _ _ _ _ _ Y8 (PTree.gss _ _ _) (ex_intro _ _ (ex_intro _ _ eq_refl)))
        as (Hs6 & -> & _).
      destruct (bc_store _ _ _ Hs6) as (Hc6 & Hp6 & U6).
      pose proof (Vstk_bc _ _ _ _ HS5 Hs6) as HS6.
      apply RA.seq_inv in Y6 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
      apply RA.seq_inv in Y9 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
      destruct (ld_cmd _ _ _ _ _ _ _ _ Y11 (Mem.load_store_same _ _ _ _ _ _ Hs6)) as (-> & -> & _).
      destruct (push_call _ _ _ (Vptr bt (Ptrofs.repr (4 * Z.of_nat j0)))
                  (Z.of_nat (List.length k')) _ _ _ _ Y12 (Hc6 (Hc5 (Hc4 Hc))) (proj1 HS6) ltac:(lia)
                  (push_arg _ _ _ bt (4 * Z.of_nat j0) 0 (4 * Z.of_nat j0) (PTree.gss _ _ _) ltac:(lia) ltac:(lia))
                  (cast_uu _ _ (or_introl (ex_intro _ bt (ex_intro _ _ eq_refl)))))
        as (-> & _ & m7 & Hs7 & Hs8).
      destruct (pool_store _ _ _ _ Hs7 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc7 & Lb7 & U7).
      destruct (pool_store _ _ _ _ Hs8 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc8 & Lb8 & U8).
      pose proof (Vstk_push _ _ (FAddr t0 j0) _ _ _ HS6 ltac:(lia) Hs7 Hs8
                    (ex_intro _ bt (conj Hbt eq_refl))) as HS8.
      match type of Y10 with exec_stmt _ _ _ ?le _ _ _ _ _ _ =>
        assert (Hcn : le ! BS._count = Some (Vint (Int.sub c (Int.repr 1))))
          by (rewrite PTree.gso by (vm_compute; discriminate);
              rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss) end.
      destruct (push_call _ _ _ (Vint (Int.sub c (Int.repr 1)))
                  (Z.of_nat (List.length (FAddr t0 j0 :: k'))) _ _ _ _ Y10
                  (Hc8 (Hc7 (Hc6 (Hc5 (Hc4 Hc))))) (proj1 HS8) ltac:(cbn [List.length]; lia)
                  (push_arg_int _ _ _ _ _ Hcn (or_intror eq_refl))
                  (cast_uu _ _ (or_intror (ex_intro _ _ eq_refl))))
        as (-> & _ & m9 & Hs9 & Hs10).
      destruct (pool_store _ _ _ _ Hs9 ltac:(stk_bounds) ltac:(cbn [List.length] in *; stk_bounds)) as (Hc9 & Lb9 & U9).
      destruct (pool_store _ _ _ _ Hs10 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc10 & Lb10 & U10).
      pose proof (Vstk_push _ _ FCount _ _ _ HS8 ltac:(cbn [List.length]; lia) Hs9 Hs10
                    (ex_intro _ _ eq_refl)) as HS10.
      eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
      + apply V_mk; [ | exact HS10 ].
        exact (Vcmd_pool _ _ _ _ _ _ (Vcmd_pool _ _ _ _ _ _ (Vcmd_pool _ _ _ _ _ _
                 (Vcmd_pool _ _ _ _ _ _ (Vcmd_bc _ _ _ _ _ Hs6 Hbt) Hs7) Hs8) Hs9) Hs10).
      + split; [ exact (Hc10 (Hc9 (Hc8 (Hc7 (Hc6 (Hc5 (Hc4 Hc))))))) | split; [ reflexivity | ] ].
        exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U4 U5) U6) U7) U8) U9) U10).
    - (* count == 0: drop the loop frame, step past *)
      apply RA.seq_inv in Y3 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
      destruct (pop_call_none _ _ (Z.of_nat (List.length k')) _ _ _ _ Y5 (Hc4 Hc) (Vstk_sidx1 _ _ _ HS4) ltac:(lia))
        as (_ & Hs5 & ->).
      destruct (Vstk_pop _ _ _ _ HS4 Hs5) as (HS5 & _).
      destruct (pool_store _ _ _ _ Hs5 ltac:(stk_bounds) ltac:(stk_bounds)) as (Hc5 & Lb5 & U5).
      apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
      assert (Lc : Mem.load Mint32 n5 bc 0 = Some (Vptr b (Ptrofs.repr I4))) by (rewrite Lb5, Lb4; exact Hcm).
      destruct (ld_cmd _ _ _ _ _ _ _ _ Y7 Lc) as (-> & -> & _).
      apply st_cmd in Y8 as (v2 & v & Ev & Hcast & Hs6 & -> & _).
      apply RA.ev_binop in Ev as (q1 & q2 & Eq1 & Eq2 & Eadd).
      apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
      apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
      cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
      rewrite ptr_inc in Hs6 by lia. norm_off Hs6 (4 * Z.of_nat (v_i st + 1)).
      destruct (bc_store _ _ _ Hs6) as (Hc6 & _ & U6).
      eexists _, _. split; [ exact Hl | split; [ right; left; reflexivity | split ] ].
      + apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs6 Hsb) | exact (Vstk_bc _ _ _ _ HS5 Hs6) ].
      + split; [ exact (Hc6 (Hc5 (Hc4 Hc))) | split; [ reflexivity | ] ].
        exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U4 U5) U6).
  Qed.

  (* the slot's bhvDelayTimer store *)
  Lemma timer_store : forall m v m',
    Mem.store Mint16signed m pool (oc + (OW.O_STK + 32)) v = Some m' ->
    (cur m -> cur m') /\ Mem.load Mint32 m' bc 0 = Mem.load Mint32 m bc 0 /\ Mem.unchanged_on Pfr m m'
    /\ (forall k, Vstk m k -> (List.length k <= 8)%nat -> Vstk m' k).
  Proof.
    intros m v m' Hs. split; [ | split; [ | split ] ].
    - exact (cur_store _ _ _ _ _ Hs).
    - apply (Mem.load_store_other _ _ _ _ _ _ Hs). left. exact Hbp.
    - apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i Hi [_ Hn]. apply Hn.
      split; [ reflexivity | ]. change (size_chunk Mint16signed) with 2 in Hi. unfold OW.O_CMD, OW.O_SIDX, OW.O_STK in *. lia.
    - intros k (Hsi & Hk) Hl. split.
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hsi | ].
        right. left. change (size_chunk Mint32) with 4. unfold OW.O_SIDX, OW.O_STK. lia.
      + intros n f Hn. assert (Hnl : (n < List.length k)%nat) by (apply nth_error_Some; congruence).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact (Hk n f Hn) | ].
        right. left. change (size_chunk Mint32) with 4. unfold OW.O_STK. lia.
  Qed.

  (* o->bhvDelayTimer = e, o = gCurrentObject in temp x *)
  Lemma st_timer : forall le m t le' m' out x a,
    exec_stmt function_entry2 G empty_env le m
      (Sassign (Efield (Ederef (Etempvar x (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
                 BS._bhvDelayTimer tshort) a) t le' m' out ->
    le ! x = Some (Vptr pool (Ptrofs.repr oc)) ->
    (exists v, Mem.store Mint16signed m pool (oc + (OW.O_STK + 32)) v = Some m') /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x a H Hx.
    apply RA.assign_inv in H as (b2 & o2 & bf2 & w2 & w3 & Hlv & _ & _ & Has & -> & ->).
    destruct (RA.lv_fld G empty_env m _ _ _ _ _ _ _ _ _ fo_dt Hlv) as (o1 & Ho1 & -> & ->).
    rewrite Hx in Ho1. injection Ho1 as <- <-.
    pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Has) as Hs.
    rewrite uadd in Hs by (unfold OW.O_STK; try rewrite maxu; lia). eauto.
  Qed.

  (* ---- DELAY (0x01) ---- *)
  Lemma hd_delay : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 1 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_delay) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 1) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_delay st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    pose proof HV as HV0.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_delay bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_delay] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* num = ( *cmd) & 0xFFFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (va & _ & -> & -> & _).
    apply RA.set_inv in X6 as (vn & _ & -> & -> & _).
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.ret_inv in Y2 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply ld_cur in Y3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vt & _ & -> & -> & _).
    apply RA.if_inv in Y6 as (vb & bb & _ & _ & Y6).
    destruct bb.
    - (* timer < num - 1: timer++, the command stays *)
      apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
      apply ld_cur in Y7 as (-> & -> & _); [ | exact Hc ].
      apply RA.seq_inv in Y8 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
      apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
      apply RA.seq_inv in Y10 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
      apply RA.set_inv in Y11 as (vt2 & _ & -> & -> & _).
      destruct (st_timer _ _ _ _ _ _ _ _ Y12) as ((v1 & Hs1) & _ & _);
        [ rewrite PTree.gso, PTree.gso, PTree.gss by (vm_compute; discriminate); reflexivity | ].
      destruct (timer_store _ _ _ Hs1) as (Hc1 & Lb1 & U1 & Vk1).
      exists [st; at_ st (v_s st) (v_i st + 1) (v_k st)], st.
      split; [ exact Hl | split; [ left; reflexivity | split ] ].
      + apply V_iff. split; [ exists b; split; [ exact Hsb | rewrite Lb1; subst I4; exact Hcm ] | ].
        exact (Vk1 _ HS Hd).
      + split; [ exact (Hc1 Hc) | split; [ reflexivity | exact U1 ] ].
    - (* timer = 0; cmd = cmd + 1 *)
      apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
      apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
      apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
      destruct (st_timer _ _ _ _ _ _ _ _ Y10) as ((v1 & Hs1) & -> & _); [ apply PTree.gss | ].
      destruct (timer_store _ _ _ Hs1) as (Hc1 & Lb1 & U1 & Vk1).
      apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
      assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4))) by (rewrite Lb1; exact Hcm).
      destruct (ld_cmd _ _ _ _ _ _ _ _ Y11 Lc) as (-> & -> & _).
      apply st_cmd in Y12 as (v2 & v & Ev & Hcast & Hs2 & -> & _).
      apply RA.ev_binop in Ev as (q1 & q2 & Eq1 & Eq2 & Eadd).
      apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
      apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
      cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
      rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
      destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
      eexists _, _. split; [ exact Hl | split; [ right; left; reflexivity | split ] ].
      + apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ (Vk1 _ HS Hd) Hs2) ].
      + split; [ exact (Hc2 (Hc1 Hc)) | split; [ reflexivity | exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) ] ].
  Qed.

  (* ---- DELAY_VAR (0x25): DELAY, with the count read from the field
     o->rawData.asS32[field] (cur_obj_get_int, inlined); writes the same
     cells ---- *)
  Lemma hd_delay_var : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 37 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_delay_var) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr 1) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_delay_var st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    pose proof HV as HV0.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_delay_var bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_delay_var] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* num = ( *cmd) & 0xFFFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (va & _ & -> & -> & _).
    apply RA.set_inv in X6 as (vn & _ & -> & -> & _).
    (* num = o->rawData.asS32[field] *)
    apply RA.seq_inv in X2 as [(z1 & kz1 & mz1 & z2 & Z1 & Z2) | (Z1 & Xn)]; [ | kill_sq Z1 Xn ].
    apply RA.seq_inv in Z1 as [(z3 & kz3 & mz3 & z4 & Z3 & Z4) | (Z3 & Xn)]; [ | kill_sq Z3 Xn ].
    apply ld_cur in Z3 as (-> & -> & _); [ | exact Hc ].
    apply RA.set_inv in Z4 as (vnum & _ & -> & -> & _).
    apply RA.seq_inv in Z2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.ret_inv in Y2 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply ld_cur in Y3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vt & _ & -> & -> & _).
    apply RA.if_inv in Y6 as (vb & bb & _ & _ & Y6).
    destruct bb.
    - (* timer < num - 1: timer++, the command stays *)
      apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
      apply ld_cur in Y7 as (-> & -> & _); [ | exact Hc ].
      apply RA.seq_inv in Y8 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
      apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
      apply RA.seq_inv in Y10 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
      apply RA.set_inv in Y11 as (vt2 & _ & -> & -> & _).
      destruct (st_timer _ _ _ _ _ _ _ _ Y12) as ((v1 & Hs1) & _ & _);
        [ rewrite PTree.gso, PTree.gso, PTree.gss by (vm_compute; discriminate); reflexivity | ].
      destruct (timer_store _ _ _ Hs1) as (Hc1 & Lb1 & U1 & Vk1).
      exists [st; at_ st (v_s st) (v_i st + 1) (v_k st)], st.
      split; [ exact Hl | split; [ left; reflexivity | split ] ].
      + apply V_iff. split; [ exists b; split; [ exact Hsb | rewrite Lb1; subst I4; exact Hcm ] | ].
        exact (Vk1 _ HS Hd).
      + split; [ exact (Hc1 Hc) | split; [ reflexivity | exact U1 ] ].
    - (* timer = 0; cmd = cmd + 1 *)
      apply RA.seq_inv in Y6 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
      apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
      apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
      destruct (st_timer _ _ _ _ _ _ _ _ Y10) as ((v1 & Hs1) & -> & _); [ apply PTree.gss | ].
      destruct (timer_store _ _ _ Hs1) as (Hc1 & Lb1 & U1 & Vk1).
      apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
      assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4))) by (rewrite Lb1; exact Hcm).
      destruct (ld_cmd _ _ _ _ _ _ _ _ Y11 Lc) as (-> & -> & _).
      apply st_cmd in Y12 as (v2 & v & Ev & Hcast & Hs2 & -> & _).
      apply RA.ev_binop in Ev as (q1 & q2 & Eq1 & Eq2 & Eadd).
      apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
      apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
      cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
      rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
      destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
      eexists _, _. split; [ exact Hl | split; [ right; left; reflexivity | split ] ].
      + apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ (Vk1 _ HS Hd) Hs2) ].
      + split; [ exact (Hc2 (Hc1 Hc)) | split; [ reflexivity | exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) ] ].
  Qed.

  (* *(cmd + 0): the command word *)
  Lemma ev_w0 : forall le m x b I n v, le ! x = Some (Vptr b (Ptrofs.repr I)) -> 0 <= I <= 1000000 ->
    Mem.load Mint32 m b I = Some (Vint n) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint) v ->
    v = Vint n.
  Proof.
    intros le m x b I n v Hx HI Hl H.
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in H as (b1 & o1 & Ea & Hlv).
    apply RA.ev_binop in Ea as (p1 & p2 & E1 & E2 & E3).
    apply RA.ev_temp in E1. rewrite Hx in E1. injection E1 as <-.
    apply RA.ev_const in E2. subst p2. cbn [typeof] in E3. rewrite add_pi in E3. injection E3 as <- <-.
    rewrite ptr_inc in Hlv by lia. replace (I + 4 * 0) with I in Hlv by lia.
    cbn [Mem.loadv] in Hlv. rewrite Ptrofs.unsigned_repr in Hlv by (rewrite maxu; lia).
    rewrite Hl in Hlv. injection Hlv as <-. reflexivity.
  Qed.

  Lemma ev_w1 : forall le m x b I n v, le ! x = Some (Vptr b (Ptrofs.repr I)) -> 0 <= I <= 1000000 ->
    Mem.load Mint32 m b (I + 4) = Some (Vint n) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint) v ->
    v = Vint n.
  Proof.
    intros le m x b I n v Hx HI Hl H.
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in H as (b1 & o1 & Ea & Hlv).
    apply RA.ev_binop in Ea as (p1 & p2 & E1 & E2 & E3).
    apply RA.ev_temp in E1. rewrite Hx in E1. injection E1 as <-.
    apply RA.ev_const in E2. subst p2. cbn [typeof] in E3. rewrite add_pi in E3. injection E3 as <- <-.
    rewrite ptr_inc in Hlv by lia. replace (I + 4 * 1) with (I + 4) in Hlv by lia.
    cbn [Mem.loadv] in Hlv. rewrite Ptrofs.unsigned_repr in Hlv by (rewrite maxu; lia).
    rewrite Hl in Hlv. injection Hlv as <-. reflexivity.
  Qed.

  Lemma ev_w2 : forall le m x b I n v, le ! x = Some (Vptr b (Ptrofs.repr I)) -> 0 <= I <= 1000000 ->
    Mem.load Mint32 m b (I + 8) = Some (Vint n) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint) v ->
    v = Vint n.
  Proof.
    intros le m x b I n v Hx HI Hl H.
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in H as (b1 & o1 & Ea & Hlv).
    apply RA.ev_binop in Ea as (p1 & p2 & E1 & E2 & E3).
    apply RA.ev_temp in E1. rewrite Hx in E1. injection E1 as <-.
    apply RA.ev_const in E2. subst p2. cbn [typeof] in E3. rewrite add_pi in E3. injection E3 as <- <-.
    rewrite ptr_inc in Hlv by lia. replace (I + 4 * 2) with (I + 8) in Hlv by lia.
    cbn [Mem.loadv] in Hlv. rewrite Ptrofs.unsigned_repr in Hlv by (rewrite maxu; lia).
    rewrite Hl in Hlv. injection Hlv as <-. reflexivity.
  Qed.

  Lemma ev_wk : forall le m x b I k n v, 0 <= k <= 8 ->
    le ! x = Some (Vptr b (Ptrofs.repr I)) -> 0 <= I <= 1000000 ->
    Mem.load Mint32 m b (I + 4 * k) = Some (Vint n) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr k) tint) (tptr tuint)) tuint) v ->
    v = Vint n.
  Proof.
    intros le m x b I k n v Hk Hx HI Hl H.
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in H as (b1 & o1 & Ea & Hlv).
    apply RA.ev_binop in Ea as (p1 & p2 & E1 & E2 & E3).
    apply RA.ev_temp in E1. rewrite Hx in E1. injection E1 as <-.
    apply RA.ev_const in E2. subst p2. cbn [typeof] in E3. rewrite add_pi in E3. injection E3 as <- <-.
    rewrite ptr_inc in Hlv by lia.
    cbn [Mem.loadv] in Hlv. rewrite Ptrofs.unsigned_repr in Hlv by (rewrite maxu; lia).
    rewrite Hl in Hlv. injection Hlv as <-. reflexivity.
  Qed.

  Lemma ev_wkv : forall le m x b I k v0 v, 0 <= k <= 8 ->
    le ! x = Some (Vptr b (Ptrofs.repr I)) -> 0 <= I <= 1000000 ->
    Mem.load Mint32 m b (I + 4 * k) = Some v0 ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr k) tint) (tptr tuint)) tuint) v ->
    v = v0.
  Proof.
    intros le m x b I k v0 v Hk Hx HI Hl H.
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in H as (b1 & o1 & Ea & Hlv).
    apply RA.ev_binop in Ea as (p1 & p2 & E1 & E2 & E3).
    apply RA.ev_temp in E1. rewrite Hx in E1. injection E1 as <-.
    apply RA.ev_const in E2. subst p2. cbn [typeof] in E3. rewrite add_pi in E3. injection E3 as <- <-.
    rewrite ptr_inc in Hlv by lia.
    cbn [Mem.loadv] in Hlv. rewrite Ptrofs.unsigned_repr in Hlv by (rewrite maxu; lia).
    rewrite Hl in Hlv. injection Hlv as <-. reflexivity.
  Qed.

  (* ---- SET_INT (0x10): o->rawData.asS32[byte2 w] = (s16)(w & 0xFFFF) ---- *)
  Definition s16_of (w : Z) : int := Int.sign_ext 16 (Int.and (Int.repr w) (Int.repr 65535)).

  (* the generated handler: ONE store, of the script's value, to the
     script's field (byte2 w < 0x50: below the VM cells), then cmd + 1 *)
  Lemma hd_set_int : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 16 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_int) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists m1, Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (s16_of w)) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_set_int st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; right; right; right; left; reflexivity).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_int bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_int] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field = ( *cmd >> 16) & 0xFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* value = (s16)( *cmd & 0xFFFF) *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_cast in Ey1 as (y2 & Ey2 & D2).
    apply RA.ev_binop in Ey2 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D2. injection D2 as <-. cbn in D1. injection D1 as <-.
    (* o->rawData.asS32[field] = value *)
    apply RA.seq_inv in Y2 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in Y10 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 4 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (lv_raw _ _ _ _ _ _ _ _ Hfi Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gss in Ho0. injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1.
    rewrite PTree.gso, PTree.gss in Ez1 by (vm_compute; discriminate). injection Ez1 as <-.
    cbn in Cz. injection Cz as <-. cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    (* the VM cells lie above the field store *)
    assert (HS1 : Vstk n7 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. change (size_chunk Mint32) with 4. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. change (size_chunk Mint32) with 4. unfold OW.O_STK. lia. }
    assert (Ev : s16_of w = Int.sign_ext 16 (Int.and n (Int.repr 65535)))
      by (unfold s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists n7. split; [ | exact U2 ]. rewrite Ev.
      rewrite Int.sign_ext_idem in Hs1 by lia. exact Hs1.
  Qed.

  (* ---- SET_FLOAT (0x0E): o->rawData.asF32[byte2 w] = (f32)(s16)(w & 0xFFFF) ---- *)
  Definition f32_of (w : Z) : float32 := Float32.of_int (s16_of w).

  (* the generated handler: ONE store, of the script's value, to the
     script's field (byte2 w < 0x50: below the VM cells), then cmd + 1 *)
  Lemma hd_set_float : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 14 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_float) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists m1, Mem.store Mfloat32 m pool (oc + 136 + 4 * byte2 w) (Vsingle (f32_of w)) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_set_float st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; right; left; reflexivity).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_float bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_float] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field = ( *cmd >> 16) & 0xFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* value = (s16)( *cmd & 0xFFFF) *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_cast in Ey1 as (y2 & Ey2 & D2).
    apply RA.ev_binop in Ey2 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D2. injection D2 as <-.
    cbn -[Float32.of_int] in D1. injection D1 as <-.
    (* o->rawData.asS32[field] = value *)
    apply RA.seq_inv in Y2 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in Y10 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 4 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (lv_rawf _ _ _ _ _ _ _ _ Hfi Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gss in Ho0. injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1.
    rewrite PTree.gso, PTree.gss in Ez1 by (vm_compute; discriminate). injection Ez1 as <-.
    cbn -[Float32.of_int] in Cz. injection Cz as <-. cbn -[Float32.of_int] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    (* the VM cells lie above the field store *)
    assert (HS1 : Vstk n7 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Ev : f32_of w = Float32.of_int (Int.sign_ext 16 (Int.and n (Int.repr 65535))))
      by (unfold f32_of, s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists n7. split; [ | exact U2 ]. rewrite Ev.
      try (rewrite Int.sign_ext_idem in Hs1 by lia). exact Hs1.
  Qed.

  (* o->rawData.asS32[field], read *)
  Lemma ev_raw_rd : forall m le p fi i v,
    le ! fi = Some (Vint i) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asS32 (tarray tint 80))
         (Etempvar fi tuchar) (tptr tint)) tint) v ->
    exists b o0, le ! p = Some (Vptr b o0) /\
      Mem.loadv Mint32 m (Vptr b (Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
                                    (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)))) = Some v.
  Proof.
    intros m le p fi i v Hfi H.
    apply (ev_deref _ _ _ _ _ tint Mint32 _ eq_refl) in H as (b & o & Ea & Hl).
    destruct (lv_raw m le p fi i b o Full Hfi (eval_Ederef G empty_env le m _ tint b o Ea))
      as (o0 & Hp & _ & ->).
    exists b, o0. auto.
  Qed.

  (* o->rawData.asF32[field], read *)
  Lemma ev_raw_rdf : forall m le p fi i v,
    le ! fi = Some (Vint i) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asF32 (tarray tfloat 80))
         (Etempvar fi tuchar) (tptr tfloat)) tfloat) v ->
    exists b o0, le ! p = Some (Vptr b o0) /\
      Mem.loadv Mfloat32 m (Vptr b (Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
                                    (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)))) = Some v.
  Proof.
    intros m le p fi i v Hfi H.
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in H as (b & o & Ea & Hl).
    destruct (lv_rawf m le p fi i b o Full Hfi (eval_Ederef G empty_env le m _ tfloat b o Ea))
      as (o0 & Hp & _ & ->).
    exists b, o0. auto.
  Qed.

  (* the same with a tuint index *)
  Lemma ev_raw_rdfu : forall m le p fi i v,
    le ! fi = Some (Vint i) ->
    eval_expr G empty_env le m
      (Ederef (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asF32 (tarray tfloat 80))
         (Etempvar fi tuint) (tptr tfloat)) tfloat) v ->
    exists b o0, le ! p = Some (Vptr b o0) /\
      Mem.loadv Mfloat32 m (Vptr b (Ptrofs.add (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0))
                                    (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_intu i)))) = Some v.
  Proof.
    intros m le p fi i v Hfi H.
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in H as (b & o & Ea & Hl).
    destruct (lv_rawfu m le p fi i b o Full Hfi (eval_Ederef G empty_env le m _ tfloat b o Ea))
      as (o0 & Hp & _ & ->).
    exists b, o0. auto.
  Qed.

  (* ---- ADD_INT (0x0F): o->rawData.asS32[byte2 w] += (s16)(w & 0xFFFF) ---- *)
  Lemma hd_add_int : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 15 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_add_int) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists old m1, Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old)
         /\ Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (Int.add old (s16_of w))) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_add_int st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; right; right; left; reflexivity).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_add_int bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_add_int] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* value *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_cast in Ey1 as (y2 & Ey2 & D2).
    apply RA.ev_binop in Ey2 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D2. injection D2 as <-. cbn in D1. injection D1 as <-.
    (* t4 = o->rawData.asS32[field]; o->rawData.asS32[field] = t4 + value *)
    apply RA.seq_inv in Y2 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y10 as [(u15 & ke15 & n15 & u16 & Y15 & Y16) | (Y15 & Xn)]; [ | kill_sq Y15 Xn ].
    apply ld_cur in Y15 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y16 as [(u17 & ke17 & n17 & u18 & Y17 & Y18) | (Y17 & Xn)]; [ | kill_sq Y17 Xn ].
    apply RA.set_inv in Y17 as (vo & Evo & -> & -> & _).
    match type of Evo with eval_expr _ _ ?le _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 5 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (ev_raw_rd _ _ _ _ _ _ Hfi Evo) as (bo & oo & Hpo & Hld).
    rewrite PTree.gss in Hpo. injection Hpo as <- <-.
    cbn [Mem.loadv] in Hld. unfold Ptrofs.of_ints in Hld. rewrite Efi in Hld. rewrite raw_addr in Hld by lia.
    apply RA.assign_inv in Y18 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi2 : le ! BS._field = Some (Vint fi))
        by (rewrite PTree.gso by (vm_compute; discriminate); exact Hfi) end.
    destruct (lv_raw _ _ _ _ _ _ _ _ Hfi2 Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Ho0 by (vm_compute; discriminate). injection Ho0 as <- <-.
    apply RA.ev_binop in Ev2 as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply RA.ev_cast in Ee2 as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1.
    rewrite PTree.gso, PTree.gso, PTree.gso, PTree.gss in Ez1 by (vm_compute; discriminate).
    injection Ez1 as <-.
    cbn in Cz. injection Cz as <-.
    destruct vo as [| old | | | | ]; cbn in Eadd'; try discriminate Eadd'.
    injection Eadd' as <-. cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk n7 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Ev : s16_of w = Int.sign_ext 16 (Int.and n (Int.repr 65535)))
      by (unfold s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists old, n7. split; [ exact Hld | split; [ | exact U2 ] ]. rewrite Ev.
      rewrite Int.sign_ext_idem in Hs1 by lia. exact Hs1.
  Qed.

  (* ---- ADD_FLOAT (0x0D): o->rawData.asF32[byte2 w] += (f32)(s16)(w & 0xFFFF) ---- *)
  Lemma hd_add_float : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 13 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_add_float) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists old m1, Mem.load Mfloat32 m pool (oc + 136 + 4 * byte2 w) = Some (Vsingle old)
         /\ Mem.store Mfloat32 m pool (oc + 136 + 4 * byte2 w) (Vsingle (Float32.add old (f32_of w))) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_add_float st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; left; reflexivity).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_add_float bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_add_float] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* value *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_cast in Ey1 as (y2 & Ey2 & D2).
    apply RA.ev_binop in Ey2 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D2. injection D2 as <-.
    cbn -[Float32.of_int] in D1. injection D1 as <-.
    (* t4 = o->rawData.asS32[field]; o->rawData.asS32[field] = t4 + value *)
    apply RA.seq_inv in Y2 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y10 as [(u15 & ke15 & n15 & u16 & Y15 & Y16) | (Y15 & Xn)]; [ | kill_sq Y15 Xn ].
    apply ld_cur in Y15 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y16 as [(u17 & ke17 & n17 & u18 & Y17 & Y18) | (Y17 & Xn)]; [ | kill_sq Y17 Xn ].
    apply RA.set_inv in Y17 as (vo & Evo & -> & -> & _).
    match type of Evo with eval_expr _ _ ?le _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 5 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (ev_raw_rdf _ _ _ _ _ _ Hfi Evo) as (bo & oo & Hpo & Hld).
    rewrite PTree.gss in Hpo. injection Hpo as <- <-.
    cbn [Mem.loadv] in Hld. unfold Ptrofs.of_ints in Hld. rewrite Efi in Hld. rewrite raw_addr in Hld by lia.
    apply RA.assign_inv in Y18 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi2 : le ! BS._field = Some (Vint fi))
        by (rewrite PTree.gso by (vm_compute; discriminate); exact Hfi) end.
    destruct (lv_rawf _ _ _ _ _ _ _ _ Hfi2 Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Ho0 by (vm_compute; discriminate). injection Ho0 as <- <-.
    apply RA.ev_binop in Ev2 as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply RA.ev_cast in Ee2 as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1.
    rewrite PTree.gso, PTree.gso, PTree.gso, PTree.gss in Ez1 by (vm_compute; discriminate).
    injection Ez1 as <-.
    cbn -[Float32.of_int] in Cz. injection Cz as <-.
    destruct vo as [| | | | old | ]; cbn -[Float32.add Float32.of_int] in Eadd'; try discriminate Eadd'.
    injection Eadd' as <-. cbn -[Float32.add Float32.of_int] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk n7 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Ev : f32_of w = Float32.of_int (Int.sign_ext 16 (Int.and n (Int.repr 65535))))
      by (unfold f32_of, s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists old, n7. split; [ exact Hld | split; [ | exact U2 ] ]. rewrite Ev.
      try (rewrite Int.sign_ext_idem in Hs1 by lia). exact Hs1.
  Qed.

  (* ---- DEACTIVATE (0x1D): o->activeFlags = 0; return BHV_PROC_BREAK
     (the command stays: succs = [st]) ---- *)
  Lemma hd_deactivate : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 29 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_deactivate) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 1)
      /\ Mem.store Mint16signed m pool (oc + OW.O_FLAGS) (Vint Int.zero) = Some m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_deact st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ].
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_deactivate bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_deactivate] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in X4 as (b2 & o2 & bf2 & v2 & v3 & Hlv & Ev & Hcast & Has & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_flags Hlv) as (o1 & Ho1 & -> & ->).
    rewrite PTree.gss in Ho1. injection Ho1 as <- <-.
    apply RA.ev_const in Ev. subst v2.
    assert (Ev3 : v3 = Vint Int.zero) by (cbn in Hcast; injection Hcast as <-; reflexivity). subst v3.
    pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Has) as Hs.
    rewrite uadd in Hs by (unfold OW.O_FLAGS; try rewrite maxu; lia).
    apply RA.ret_inv in X2 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    exists [st], st. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_iff. split.
      + exists b. split; [ exact Hsb | ].
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs) by (left; exact Hbp). exact Hcm.
      + destruct HS as (Hsi & Hk). split.
        * rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hsi | ].
          right. right. cbn [size_chunk]. unfold OW.O_SIDX, OW.O_FLAGS. lia.
        * intros j f Hj.
          assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact (Hk j f Hj) | ].
          right. right. cbn [size_chunk]. unfold OW.O_STK, OW.O_FLAGS. lia.
    - split; [ exact (cur_store _ _ _ _ _ Hs Hc) | split; [ reflexivity | exact Hs ] ].
  Qed.

  (* ---- SET_INTERACT_TYPE (0x2F): o->rawData.asU32[42] = cmd[1]; cmd += 2 ---- *)
  Lemma hd_set_interact_type : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 47 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_interact_type) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists a m1, word_at (v_s st) (v_i st + 1) = Some (Int.unsigned a)
         /\ Mem.store Mint32 m pool (oc + 136 + 4 * 42) (Vint a) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_sit st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (sit_arg st w Hst Hw Ho) as (z & Hz & _).
    destruct (word_int _ _ _ Hz) as (a & Ha & Eza).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Ha) as (va & Hla & Hia).
    cbn in Hia. subst va.
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Ha; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hla by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_interact_type bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_interact_type] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X5 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vw & Evw & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 a _ (PTree.gss _ _ _) ltac:(lia) Hla) in Evw. subst vw.
    apply RA.assign_inv in X8 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    destruct (lv_rawuc _ _ _ _ _ _ _ Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Ho0 by (vm_compute; discriminate). injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1. rewrite PTree.gss in Ez1.
    injection Ez1 as <-. cbn in Cz. injection Cz as <-. cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tuint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    change (Ptrofs.of_ints (Int.repr 42)) with (Ptrofs.repr 42) in Hs1.
    rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in X2 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 m1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk m1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists a, m1. split; [ rewrite <- Eza; exact Hz | split; [ exact Hs1 | exact U2 ] ].
  Qed.

  (* ---- SET_RANDOM_FLOAT (0x14):
     o->rawData.asF32[byte2 w] = (f32)(s16)(w1 >> 16) * random_float() + (f32)(s16)(w & 0xFFFF);
     cmd += 2.  The call changes only gRandomSeed16 ---- *)
  Definition rng_of (z : Z) : float32 := Float32.of_int (Int.sign_ext 16 (Int.shru (Int.repr z) (Int.repr 16))).

  Lemma hd_set_random_float : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 20 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_random_float) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists z u m1 m2, word_at (v_s st) (v_i st + 1) = Some z /\ 0 <= Int.unsigned u < 65536
         /\ Mem.unchanged_on Psd m m1
         /\ Mem.store Mfloat32 m1 pool (oc + 136 + 4 * byte2 w)
              (Vsingle (Float32.add (Float32.mul (rng_of z) (rf_of u)) (f32_of w))) = Some m2
         /\ Mem.unchanged_on Pfr m2 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_rand st w Hw (or_intror (or_introl Ho))) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; do 7 right; left; reflexivity).
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    destruct (rand_w1 st w Hst Hw (or_intror (or_introl Ho))) as (z & Hz).
    destruct (word_int _ _ _ Hz) as (n1 & Hn1 & Ezn).
    destruct (Hscr (v_s st) b (v_i st) _ Hsbs (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn1; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hlv1 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_random_float bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_random_float] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* min *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & k1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & k3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & k5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_cast in Ey1 as (y2 & Ey2 & D2).
    apply RA.ev_binop in Ey2 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D2. injection D2 as <-.
    cbn -[Float32.of_int] in D1. injection D1 as <-.
    (* range *)
    apply RA.seq_inv in Y2 as [(p1 & pe1 & pm1 & p2 & Z1 & Z2) | (Z1 & Xn)]; [ | kill_sq Z1 Xn ].
    apply RA.seq_inv in Z1 as [(p3 & pe3 & pm3 & p4 & Z3 & Z4) | (Z3 & Xn)]; [ | kill_sq Z3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Z3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Z4 as [(p5 & pe5 & pm5 & p6 & Z5 & Z6) | (Z5 & Xn)]; [ | kill_sq Z5 Xn ].
    apply RA.set_inv in Z5 as (vw & Evw & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evw. subst vw.
    apply RA.set_inv in Z6 as (vg & Evg & -> & -> & _).
    apply RA.ev_cast in Evg as (g1 & Eg1 & G1). apply RA.ev_cast in Eg1 as (g2 & Eg2 & G2).
    apply RA.ev_binop in Eg2 as (h1 & h2 & Eh1 & Eh2 & Eshr2).
    apply RA.ev_temp in Eh1. rewrite PTree.gss in Eh1. injection Eh1 as <-.
    apply RA.ev_const in Eh2. subst h2.
    cbn in Eshr2. injection Eshr2 as <-. cbn in G2. injection G2 as <-.
    cbn -[Float32.of_int] in G1. injection G1 as <-.
    (* t1 = random_float(); o->asF32[field] = range * t1 + min *)
    apply RA.seq_inv in Z2 as [(q1 & qe1 & qm1 & q2 & D3 & E1) | (D3 & Xn)]; [ | kill_sq D3 Xn ].
    apply RA.seq_inv in D3 as [(r1 & re1 & rm1 & r2 & W1 & W2) | (W1 & Xn)]; [ | kill_sq W1 Xn ].
    destruct (rf_call _ _ _ _ _ _ _ W1) as (_ & Ur & u & -> & Hu).
    pose proof (seed_cur _ _ Ur Hc) as Hc1.
    assert (HVr : V rm1 st)
      by (apply (seed_V m); [ exact Ur | apply V_iff; split; [ exists b; split; [ exact Hsbs | subst I4; exact Hcm ] | exact HS ] ]).
    apply V_iff in HVr as ((b' & Hsbs' & Hcm1) & HSr).
    rewrite Hsbs in Hsbs'. injection Hsbs' as <-. rewrite <- EI in Hcm1.
    apply RA.seq_inv in W2 as [(s3 & se3 & sm3 & s4 & W3 & W4) | (W3 & Xn)]; [ | kill_sq W3 Xn ].
    apply ld_cur in W3 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in W4 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 8 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (lv_rawf _ _ _ _ _ _ _ _ Hfi Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gss in Ho0. injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (y & Ey & Cy).
    apply RA.ev_binop in Ey as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_binop in Ee1 as (k1' & k2' & Ek1 & Ek2 & Emul).
    apply RA.ev_temp in Ek1. do 2 rewrite PTree.gso in Ek1 by (vm_compute; discriminate). rewrite PTree.gss in Ek1. injection Ek1 as <-.
    apply RA.ev_temp in Ek2. rewrite PTree.gso in Ek2 by (vm_compute; discriminate). rewrite PTree.gss in Ek2. injection Ek2 as <-.
    apply RA.ev_temp in Ee2. do 5 rewrite PTree.gso in Ee2 by (vm_compute; discriminate). rewrite PTree.gss in Ee2. injection Ee2 as <-.
    cbn -[Float32.mul Float32.add Float32.of_int rf_of] in Emul. injection Emul as <-.
    cbn -[Float32.mul Float32.add Float32.of_int rf_of] in Eadd'. injection Eadd' as <-.
    cbn -[Float32.mul Float32.add Float32.of_int rf_of] in Cy. injection Cy as <-.
    cbn -[Float32.mul Float32.add Float32.of_int rf_of] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 qm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm1).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk qm1 (v_k st)).
    { destruct HSr as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Ev : Float32.add (Float32.mul (rng_of z) (rf_of u)) (f32_of w)
                 = Float32.add (Float32.mul (Float32.of_int (Int.sign_ext 16 (Int.shru n1 (Int.repr 16)))) (rf_of u))
                     (Float32.of_int (Int.sign_ext 16 (Int.and n (Int.repr 65535)))))
      by (unfold rng_of, f32_of, s16_of; rewrite Ezn, Ewn, !Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsbs) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc1)) | split; [ reflexivity | ] ].
      exists z, u, rm1, qm1. split; [ exact Hz | split; [ exact Hu | split; [ exact Ur | split; [ | exact U2 ] ] ] ].
      rewrite Ev. repeat (rewrite Int.sign_ext_idem in Hs1 by lia). exact Hs1.
  Qed.

  (* ---- SET_RANDOM_INT (0x15):
     o->rawData.asS32[byte2 w] = (s32)((s16)(w1 >> 16) * random_float()) + (s16)(w & 0xFFFF);
     cmd += 2 ---- *)
  Definition rngi_of (z : Z) : int := Int.sign_ext 16 (Int.shru (Int.repr z) (Int.repr 16)).

  Lemma hd_set_random_int : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 21 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_random_int) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists z u ri m1 m2, word_at (v_s st) (v_i st + 1) = Some z /\ 0 <= Int.unsigned u < 65536
         /\ Float32.to_int (Float32.mul (Float32.of_int (rngi_of z)) (rf_of u)) = Some ri
         /\ Mem.unchanged_on Psd m m1
         /\ Mem.store Mint32 m1 pool (oc + 136 + 4 * byte2 w) (Vint (Int.add ri (s16_of w))) = Some m2
         /\ Mem.unchanged_on Pfr m2 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_rand st w Hw (or_intror (or_intror Ho))) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; do 8 right; left; reflexivity).
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    destruct (rand_w1 st w Hst Hw (or_intror (or_intror Ho))) as (z & Hz).
    destruct (word_int _ _ _ Hz) as (n1 & Hn1 & Ezn).
    destruct (Hscr (v_s st) b (v_i st) _ Hsbs (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn1; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hlv1 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_random_int bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_random_int] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* min *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & k1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & k3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & k5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1).
    apply RA.ev_binop in Ey1 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D1. injection D1 as <-.
    (* range *)
    apply RA.seq_inv in Y2 as [(p1 & pe1 & pm1 & p2 & Z1 & Z2) | (Z1 & Xn)]; [ | kill_sq Z1 Xn ].
    apply RA.seq_inv in Z1 as [(p3 & pe3 & pm3 & p4 & Z3 & Z4) | (Z3 & Xn)]; [ | kill_sq Z3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Z3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Z4 as [(p5 & pe5 & pm5 & p6 & Z5 & Z6) | (Z5 & Xn)]; [ | kill_sq Z5 Xn ].
    apply RA.set_inv in Z5 as (vw & Evw & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evw. subst vw.
    apply RA.set_inv in Z6 as (vg & Evg & -> & -> & _).
    apply RA.ev_cast in Evg as (g1 & Eg1 & G1).
    apply RA.ev_binop in Eg1 as (h1 & h2 & Eh1 & Eh2 & Eshr2).
    apply RA.ev_temp in Eh1. rewrite PTree.gss in Eh1. injection Eh1 as <-.
    apply RA.ev_const in Eh2. subst h2.
    cbn in Eshr2. try change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eshr2; cbn in Eshr2. injection Eshr2 as <-. cbn in G1. injection G1 as <-.
    (* t1 = random_float(); o->asF32[field] = range * t1 + min *)
    apply RA.seq_inv in Z2 as [(q1 & qe1 & qm1 & q2 & D3 & E1) | (D3 & Xn)]; [ | kill_sq D3 Xn ].
    apply RA.seq_inv in D3 as [(r1 & re1 & rm1 & r2 & W1 & W2) | (W1 & Xn)]; [ | kill_sq W1 Xn ].
    destruct (rf_call _ _ _ _ _ _ _ W1) as (_ & Ur & u & -> & Hu).
    pose proof (seed_cur _ _ Ur Hc) as Hc1.
    assert (HVr : V rm1 st)
      by (apply (seed_V m); [ exact Ur | apply V_iff; split; [ exists b; split; [ exact Hsbs | subst I4; exact Hcm ] | exact HS ] ]).
    apply V_iff in HVr as ((b' & Hsbs' & Hcm1) & HSr).
    rewrite Hsbs in Hsbs'. injection Hsbs' as <-. rewrite <- EI in Hcm1.
    apply RA.seq_inv in W2 as [(s3 & se3 & sm3 & s4 & W3 & W4) | (W3 & Xn)]; [ | kill_sq W3 Xn ].
    apply ld_cur in W3 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in W4 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 8 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (lv_raw _ _ _ _ _ _ _ _ Hfi Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gss in Ho0. injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (y & Ey & Cy).
    apply RA.ev_binop in Ey as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_cast in Ee1 as (k0 & Ek0 & Ck0).
    apply RA.ev_binop in Ek0 as (k1' & k2' & Ek1 & Ek2 & Emul).
    apply RA.ev_temp in Ek1. do 2 rewrite PTree.gso in Ek1 by (vm_compute; discriminate). rewrite PTree.gss in Ek1. injection Ek1 as <-.
    apply RA.ev_temp in Ek2. rewrite PTree.gso in Ek2 by (vm_compute; discriminate). rewrite PTree.gss in Ek2. injection Ek2 as <-.
    apply RA.ev_temp in Ee2. do 5 rewrite PTree.gso in Ee2 by (vm_compute; discriminate). rewrite PTree.gss in Ee2. injection Ee2 as <-.
    cbn -[Float32.mul Float32.of_int rf_of] in Emul. injection Emul as <-.
    assert (Ec : forall f mm, sem_cast (Vsingle f) tfloat tint mm = option_map Vint (Float32.to_int f))
      by (intros f mm; unfold sem_cast; cbn; destruct (intsize_eq I32 IBool) as [Eb|_]; [ discriminate Eb | ]; cbn; destruct (Float32.to_int f); reflexivity).
    rewrite Ec in Ck0.
    match type of Ck0 with context [Float32.to_int ?x] =>
      destruct (Float32.to_int x) as [ri|] eqn:Eri end; [ | discriminate Ck0 ].
    cbn in Ck0. injection Ck0 as <-.
    cbn in Eadd'. injection Eadd' as <-. cbn in Cy. injection Cy as <-.
    cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 qm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm1).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk qm1 (v_k st)).
    { destruct HSr as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Er : rngi_of z = Int.sign_ext 16 (Int.shru n1 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn, Int.repr_unsigned; reflexivity).
    assert (Em : s16_of w = Int.sign_ext 16 (Int.and n (Int.repr 65535)))
      by (unfold s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsbs) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc1)) | split; [ reflexivity | ] ].
      exists z, u, ri, rm1, qm1.
      split; [ exact Hz | split; [ exact Hu | split; [ rewrite Er; exact Eri | split; [ exact Ur | split; [ | exact U2 ] ] ] ] ].
      rewrite Em. exact Hs1.
  Qed.

  (* ---- SET_INT_RAND_RSHIFT (0x13):
     o->rawData.asS32[byte2 w] = (random_u16() >> (s16)(w1 >> 16)) + (s16)(w & 0xFFFF);
     cmd += 2 ---- *)
  Lemma hd_set_int_rand_rshift : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 19 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_int_rand_rshift) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists z u ri m1 m2, word_at (v_s st) (v_i st + 1) = Some z /\ 0 <= Int.unsigned u < 65536
         /\ Int.ltu (rngi_of z) Int.iwordsize = true /\ ri = Int.shr u (rngi_of z)
         /\ Mem.unchanged_on Psd m m1
         /\ Mem.store Mint32 m1 pool (oc + 136 + 4 * byte2 w) (Vint (Int.add ri (s16_of w))) = Some m2
         /\ Mem.unchanged_on Pfr m2 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_rand st w Hw (or_introl Ho)) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; do 6 right; left; reflexivity).
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    destruct (rand_w1 st w Hst Hw (or_introl Ho)) as (z & Hz).
    destruct (word_int _ _ _ Hz) as (n1 & Hn1 & Ezn).
    destruct (Hscr (v_s st) b (v_i st) _ Hsbs (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn1; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hlv1 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_int_rand_rshift bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_int_rand_rshift] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* min *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & k1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & k3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & k5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1).
    apply RA.ev_binop in Ey1 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D1. injection D1 as <-.
    (* range *)
    apply RA.seq_inv in Y2 as [(p1 & pe1 & pm1 & p2 & Z1 & Z2) | (Z1 & Xn)]; [ | kill_sq Z1 Xn ].
    apply RA.seq_inv in Z1 as [(p3 & pe3 & pm3 & p4 & Z3 & Z4) | (Z3 & Xn)]; [ | kill_sq Z3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Z3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Z4 as [(p5 & pe5 & pm5 & p6 & Z5 & Z6) | (Z5 & Xn)]; [ | kill_sq Z5 Xn ].
    apply RA.set_inv in Z5 as (vw & Evw & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evw. subst vw.
    apply RA.set_inv in Z6 as (vg & Evg & -> & -> & _).
    apply RA.ev_cast in Evg as (g1 & Eg1 & G1).
    apply RA.ev_binop in Eg1 as (h1 & h2 & Eh1 & Eh2 & Eshr2).
    apply RA.ev_temp in Eh1. rewrite PTree.gss in Eh1. injection Eh1 as <-.
    apply RA.ev_const in Eh2. subst h2.
    cbn in Eshr2. try change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eshr2; cbn in Eshr2. injection Eshr2 as <-. cbn in G1. injection G1 as <-.
    (* t1 = random_float(); o->asF32[field] = range * t1 + min *)
    apply RA.seq_inv in Z2 as [(q1 & qe1 & qm1 & q2 & D3 & E1) | (D3 & Xn)]; [ | kill_sq D3 Xn ].
    apply RA.seq_inv in D3 as [(r1 & re1 & rm1 & r2 & W1 & W2) | (W1 & Xn)]; [ | kill_sq W1 Xn ].
    destruct (ru16_call _ _ _ _ _ _ _ W1) as (_ & Ur & u & -> & Hu).
    pose proof (seed_cur _ _ Ur Hc) as Hc1.
    assert (HVr : V rm1 st)
      by (apply (seed_V m); [ exact Ur | apply V_iff; split; [ exists b; split; [ exact Hsbs | subst I4; exact Hcm ] | exact HS ] ]).
    apply V_iff in HVr as ((b' & Hsbs' & Hcm1) & HSr).
    rewrite Hsbs in Hsbs'. injection Hsbs' as <-. rewrite <- EI in Hcm1.
    apply RA.seq_inv in W2 as [(s3 & se3 & sm3 & s4 & W3 & W4) | (W3 & Xn)]; [ | kill_sq W3 Xn ].
    apply ld_cur in W3 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in W4 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 8 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (lv_raw _ _ _ _ _ _ _ _ Hfi Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gss in Ho0. injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (y & Ey & Cy).
    apply RA.ev_binop in Ey as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_binop in Ee1 as (k1' & k2' & Ek1 & Ek2 & Eshr3).
    apply RA.ev_temp in Ek1. rewrite PTree.gso in Ek1 by (vm_compute; discriminate). rewrite PTree.gss in Ek1. injection Ek1 as <-.
    apply RA.ev_temp in Ek2. do 2 rewrite PTree.gso in Ek2 by (vm_compute; discriminate). rewrite PTree.gss in Ek2. injection Ek2 as <-.
    apply RA.ev_temp in Ee2. do 5 rewrite PTree.gso in Ee2 by (vm_compute; discriminate). rewrite PTree.gss in Ee2. injection Ee2 as <-.
    cbn in Eshr3.
    match type of Eshr3 with context [Int.ltu ?x ?y] =>
      destruct (Int.ltu x y) eqn:Elu end; [ | discriminate Eshr3 ].
    injection Eshr3 as <-.
    cbn in Eadd'. injection Eadd' as <-. cbn in Cy. injection Cy as <-.
    cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 qm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm1).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk qm1 (v_k st)).
    { destruct HSr as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Er : rngi_of z = Int.sign_ext 16 (Int.shru n1 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn, Int.repr_unsigned; reflexivity).
    assert (Em : s16_of w = Int.sign_ext 16 (Int.and n (Int.repr 65535)))
      by (unfold s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsbs) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc1)) | split; [ reflexivity | ] ].
      exists z, u, (Int.shr u (rngi_of z)), rm1, qm1.
      split; [ exact Hz | split; [ exact Hu | split; [ rewrite Er; exact Elu | split; [ reflexivity | split; [ exact Ur | split; [ | exact U2 ] ] ] ] ] ].
      rewrite Em, Er. exact Hs1.
  Qed.

  (* ---- PARENT_BIT_CLEAR (0x33):
     obj_and_int(o->parentObj, byte2 w, w1 ^ 0xFFFFFFFF); cmd += 2.
     A parent POINTER is a pool slot (po) disjoint from o's script stack
     (par51_ok at the row gives it positively) ---- *)
  Lemma hd_parent_bit_clear : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 51 ->
    (forall pb o, Mem.load Mint32 m pool (oc + 104) = Some (Vptr pb o) ->
       pb = pool /\ exists po, o = Ptrofs.repr po /\ 0 <= po <= 145312
                      /\ (po = oc \/ po + 608 <= oc \/ oc + 608 <= po)) ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_parent_bit_clear) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists po a old m1, Mem.load Mint32 m pool (oc + 104) = Some (Vptr pool (Ptrofs.repr po))
         /\ word_at (v_s st) (v_i st + 1) = Some (Int.unsigned a)
         /\ Mem.load Mint32 m pool (po + 136 + 4 * byte2 w) = Some (Vint old)
         /\ Mem.store Mint32 m pool (po + 136 + 4 * byte2 w)
              (Vint (Int.and old (Int.xor a (Int.repr (-1))))) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho Hpar H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_pbc st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; do 13 right; left; reflexivity).
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    destruct (pbc_w1 st w Hst Hw Ho) as (z & Hz).
    destruct (word_int _ _ _ Hz) as (n1 & Hn1 & Ezn).
    destruct (Hscr (v_s st) b (v_i st) _ Hsbs (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn1; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hlv1 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_parent_bit_clear bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_parent_bit_clear] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* value = (u32) cmd[1] *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & k1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & k3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & k5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_temp in Ey1. rewrite PTree.gss in Ey1.
    injection Ey1 as <-. cbn in D1. injection D1 as <-.
    (* value ^= 0xFFFFFFFF *)
    apply RA.seq_inv in Y2 as [(p1 & pe1 & pm1 & p2 & Z1 & Z2) | (Z1 & Xn)]; [ | kill_sq Z1 Xn ].
    apply RA.set_inv in Z1 as (vx & Evx & -> & -> & _).
    apply RA.ev_binop in Evx as (x1' & x2' & Ex1' & Ex2' & Exor).
    apply RA.ev_temp in Ex1'. rewrite PTree.gss in Ex1'. injection Ex1' as <-.
    apply RA.ev_const in Ex2'. subst x2'.
    cbn in Exor. injection Exor as <-.
    (* t6 = parent->asS32[field]; parent->asS32[field] = t6 & value *)
    apply RA.seq_inv in Z2 as [(q1 & qe1 & qm1 & q2 & D3 & E1) | (D3 & Xn)]; [ | kill_sq D3 Xn ].
    apply RA.seq_inv in D3 as [(r1 & re1 & rm1 & r2 & W1 & W2) | (W1 & Xn)]; [ | kill_sq W1 Xn ].
    apply ld_cur in W1 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in W2 as [(s1' & se1 & sm1 & s2' & W3 & W4) | (W3 & Xn)]; [ | kill_sq W3 Xn ].
    apply RA.set_inv in W3 as (v3 & Ev3 & -> & -> & _).
    apply (ld_par _ _ _ _ (PTree.gss _ _ _)) in Ev3.
    apply RA.seq_inv in W4 as [(s3 & se3 & sm3 & s4 & W5 & W6) | (W5 & Xn)]; [ | kill_sq W5 Xn ].
    apply ld_cur in W5 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in W6 as [(s5 & se5 & sm5 & s6 & W7 & W8) | (W7 & Xn)]; [ | kill_sq W7 Xn ].
    apply RA.set_inv in W7 as (v5 & Ev5 & -> & -> & _).
    apply (ld_par _ _ _ _ (PTree.gss _ _ _)) in Ev5. rewrite Ev3 in Ev5. injection Ev5 as <-.
    apply RA.seq_inv in W8 as [(s7 & se7 & sm7 & s8 & W9 & W10) | (W9 & Xn)]; [ | kill_sq W9 Xn ].
    apply RA.set_inv in W9 as (vo & Evo & -> & -> & _).
    match type of Evo with eval_expr _ _ ?le _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 8 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (ev_raw_rd _ _ _ _ _ _ Hfi Evo) as (bo & oo & Hpo' & Hld).
    rewrite PTree.gss in Hpo'. injection Hpo' as ->.
    destruct (Hpar _ _ Ev3) as (-> & po & -> & Hpo & Hdj).
    cbn [Mem.loadv] in Hld. unfold Ptrofs.of_ints in Hld. rewrite Efi in Hld. rewrite raw_addr in Hld by lia.
    apply RA.assign_inv in W10 as (b2 & o2 & bf2 & v2 & v6 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi2 : le ! BS._field = Some (Vint fi))
        by (rewrite PTree.gso by (vm_compute; discriminate); exact Hfi) end.
    destruct (lv_raw _ _ _ _ _ _ _ _ Hfi2 Hlv2) as (o0 & Ho0 & -> & ->).
    do 3 rewrite PTree.gso in Ho0 by (vm_compute; discriminate). rewrite PTree.gss in Ho0.
    injection Ho0 as <- <-.
    apply RA.ev_binop in Ev2 as (e1 & e2 & Ee1 & Ee2 & Eand').
    apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply RA.ev_cast in Ee2 as (c0 & Ec0 & Cc0). apply RA.ev_temp in Ec0.
    do 5 rewrite PTree.gso in Ec0 by (vm_compute; discriminate). rewrite PTree.gss in Ec0.
    injection Ec0 as <-. cbn in Cc0. injection Cc0 as <-.
    destruct vo as [| old | | | | ]; cbn in Eand'; try discriminate Eand'.
    injection Eand' as <-. cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 qm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk qm1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsbs) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists po, n1, old, qm1.
      split; [ exact Ev3 | split; [ rewrite <- Ezn; exact Hz | split; [ exact Hld | split; [ exact Hs1 | exact U2 ] ] ] ].
  Qed.

  (* ---- ANIMATE_TEXTURE (0x34):
     if (gGlobalTimer % (s16)(w & 0xFFFF) == 0) o->rawData.asS32[byte2 w] += 1;
     cmd += 1.  Either branch: the condition is not analysed ---- *)
  Lemma hd_animate_texture : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 52 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_animate_texture) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists m1, (m1 = m \/ exists old, Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old)
                       /\ Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w)
                            (Vint (Int.add old (Int.repr 1))) = Some m1)
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_atex st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; do 14 right; left; reflexivity).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_animate_texture bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_animate_texture] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* rate: not analysed *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & _ & -> & -> & _).
    apply RA.set_inv in Y6 as (vr8 & _ & -> & -> & _).
    (* t2 = gGlobalTimer; if (t2 % rate == 0) o->asS32[field] = o->asS32[field] + 1 *)
    apply RA.seq_inv in Y2 as [(q1 & qe1 & qm1 & q2 & D3 & E1) | (D3 & Xn)]; [ | kill_sq D3 Xn ].
    apply RA.seq_inv in D3 as [(r1 & re1 & rm1 & r2 & W1 & W2) | (W1 & Xn)]; [ | kill_sq W1 Xn ].
    apply RA.set_inv in W1 as (vg & _ & -> & -> & _).
    apply RA.if_inv in W2 as (vc & bb & _ & _ & W2).
    assert (Hq : qm1 = m \/ exists old, Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old)
                   /\ Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w)
                        (Vint (Int.add old (Int.repr 1))) = Some qm1).
    { destruct bb.
      - right.
        apply RA.seq_inv in W2 as [(s1' & se1 & sm1 & s2' & W3 & W4) | (W3 & Xn)]; [ | kill_sq W3 Xn ].
        apply ld_cur in W3 as (-> & -> & _); [ | exact Hc ].
        apply RA.seq_inv in W4 as [(s3 & se3 & sm3 & s4 & W5 & W6) | (W5 & Xn)]; [ | kill_sq W5 Xn ].
        apply ld_cur in W5 as (-> & -> & _); [ | exact Hc ].
        apply RA.seq_inv in W6 as [(s5 & se5 & sm5 & s6 & W7 & W8) | (W7 & Xn)]; [ | kill_sq W7 Xn ].
        apply RA.set_inv in W7 as (vo & Evo & -> & -> & _).
        match type of Evo with eval_expr _ _ ?le _ _ _ =>
          assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
            by (eexists; split;
                [ do 6 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
                | rewrite Ewn; apply fld_eq ]) end.
        destruct Hfi as (fi & Hfi & Efi).
        destruct (ev_raw_rd _ _ _ _ _ _ Hfi Evo) as (bo & oo & Hpo & Hld).
        rewrite PTree.gss in Hpo. injection Hpo as <- <-.
        cbn [Mem.loadv] in Hld. unfold Ptrofs.of_ints in Hld. rewrite Efi in Hld. rewrite raw_addr in Hld by lia.
        apply RA.assign_inv in W8 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
        match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
          assert (Hfi2 : le ! BS._field = Some (Vint fi))
            by (rewrite PTree.gso by (vm_compute; discriminate); exact Hfi) end.
        destruct (lv_raw _ _ _ _ _ _ _ _ Hfi2 Hlv2) as (o0 & Ho0 & -> & ->).
        do 2 rewrite PTree.gso in Ho0 by (vm_compute; discriminate). rewrite PTree.gss in Ho0.
        injection Ho0 as <- <-.
        apply RA.ev_binop in Ev2 as (e1 & e2 & Ee1 & Ee2 & Eadd').
        apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
        apply RA.ev_cast in Ee2 as (c0 & Ec0 & Cc0). apply RA.ev_const in Ec0. subst c0.
        cbn in Cc0. injection Cc0 as <-.
        destruct vo as [| old | | | | ]; cbn in Eadd'; try discriminate Eadd'.
        injection Eadd' as <-. cbn in Hcast2. injection Hcast2 as <-.
        pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
        unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
        exists old. split; [ exact Hld | exact Hs1 ].
      - left. apply RA.skip_inv in W2 as (-> & _ & _). reflexivity. }
    assert (HM : Mem.load Mint32 qm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)) /\ Vstk qm1 (v_k st) /\ cur qm1).
    { destruct Hq as [-> | (old & _ & Hs1)]; [ split; [ exact Hcm | split; [ exact HS | exact Hc ] ] | ].
      split; [ rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm | split ].
      - destruct HS as (Hsi & Hk). split.
        + rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
          right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
        + intros j f Hj.
          assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
          right. right. cbn [size_chunk]. unfold OW.O_STK. lia.
      - exact (cur_store _ _ _ _ _ Hs1 Hc). }
    destruct HM as (Lc & HS1 & Hc1).
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 Hc1) | split; [ reflexivity | ] ].
      exists qm1. split; [ exact Hq | exact U2 ].
  Qed.

  (* ---- BILLBOARD (0x21): o->header.gfx.node.flags |= GRAPH_RENDER_BILLBOARD; cmd += 1 ---- *)
  Lemma hd_billboard : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 33 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_billboard) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists old m1, Mem.load Mint16signed m pool (oc + 2) = Some (Vint old)
         /\ Mem.store Mint16signed m pool (oc + 2) (Vint (Int.sign_ext 16 (Int.or old (Int.shl (Int.repr 1) (Int.repr 2))))) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_gfl st w Hw (or_introl Ho)) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_billboard bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_billboard] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & E1) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply ld_cur in X5 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vo & Evo & -> & -> & _).
    pose proof (ev_gflags _ _ _ _ (PTree.gss _ _ _) Evo) as Hld.
    apply RA.assign_inv in X8 as (b2 & o2 & bf2 & v2 & v3 & Hlv & Ev & Hcast & Has & -> & _).
    match type of Hlv with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hp2 : le ! BS._t'2 = Some (Vptr pool (Ptrofs.repr oc)))
        by (do 2 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss) end.
    destruct (lv_gflags _ _ _ _ _ _ Hp2 Hlv) as (-> & Eo2 & ->).
    apply RA.ev_binop in Ev as (e1 & e2 & Ee1 & Ee2 & Eop).
    apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply RA.ev_binop in Ee2 as (c1 & c2 & Ec1 & Ec2 & Eshl).
    apply RA.ev_const in Ec1. apply RA.ev_const in Ec2. subst c1 c2.
    cbn in Eshl. try (match type of Eshl with context [Int.ltu ?x ?y] =>
      change (Int.ltu x y) with true in Eshl end); cbn in Eshl. injection Eshl as <-.
    destruct vo as [| old | | | | ]; cbn in Eop; try discriminate Eop.
    injection Eop as <-. cbn in Hcast. injection Hcast as <-.
    pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Has) as Hs1.
    rewrite Eo2 in Hs1.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 m1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk m1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists old, m1. split; [ exact Hld | split; [ exact Hs1 | exact U2 ] ].
  Qed.

  (* ---- DISABLE_RENDERING (0x35): o->header.gfx.node.flags &= ~GRAPH_RENDER_ACTIVE; cmd += 1 ---- *)
  Lemma hd_disable_rendering : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 53 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_disable_rendering) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists old m1, Mem.load Mint16signed m pool (oc + 2) = Some (Vint old)
         /\ Mem.store Mint16signed m pool (oc + 2) (Vint (Int.sign_ext 16 (Int.and old (Int.not (Int.shl (Int.repr 1) (Int.repr 0)))))) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_gfl st w Hw (or_intror Ho)) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_disable_rendering bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_disable_rendering] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & E1) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply ld_cur in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply ld_cur in X5 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.set_inv in X7 as (vo & Evo & -> & -> & _).
    pose proof (ev_gflags _ _ _ _ (PTree.gss _ _ _) Evo) as Hld.
    apply RA.assign_inv in X8 as (b2 & o2 & bf2 & v2 & v3 & Hlv & Ev & Hcast & Has & -> & _).
    match type of Hlv with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hp2 : le ! BS._t'2 = Some (Vptr pool (Ptrofs.repr oc)))
        by (do 2 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss) end.
    destruct (lv_gflags _ _ _ _ _ _ Hp2 Hlv) as (-> & Eo2 & ->).
    apply RA.ev_binop in Ev as (e1 & e2 & Ee1 & Ee2 & Eop).
    apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply ev_unop in Ee2 as (c0 & Ec0 & Enot).
    apply RA.ev_binop in Ec0 as (c1 & c2 & Ec1 & Ec2 & Eshl).
    apply RA.ev_const in Ec1. apply RA.ev_const in Ec2. subst c1 c2.
    cbn in Eshl. try (match type of Eshl with context [Int.ltu ?x ?y] =>
      change (Int.ltu x y) with true in Eshl end); cbn in Eshl. injection Eshl as <-.
    cbn in Enot. injection Enot as <-.
    destruct vo as [| old | | | | ]; cbn in Eop; try discriminate Eop.
    injection Eop as <-. cbn in Hcast. injection Hcast as <-.
    pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Has) as Hs1.
    rewrite Eo2 in Hs1.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 m1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk m1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists old, m1. split; [ exact Hld | split; [ exact Hs1 | exact U2 ] ].
  Qed.

  (* ---- SET_HITBOX (0x23): o->hitboxRadius = (s16)(w1 >> 16);
     o->hitboxHeight = (s16)(w1 & 0xFFFF); cmd += 2 ---- *)
  Lemma hd_set_hitbox : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 35 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_hitbox) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists z m1 m2, word_at (v_s st) (v_i st + 1) = Some z
         /\ Mem.store Mfloat32 m pool (oc + 504) (Vsingle (Float32.of_int (rngi_of z))) = Some m1
         /\ Mem.store Mfloat32 m1 pool (oc + 508) (Vsingle (Float32.of_int (s16_of z))) = Some m2
         /\ Mem.unchanged_on Pfr m2 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_hb st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    destruct (hb_w1 st w Hst Hw (or_introl Ho)) as (z & Hz).
    destruct (word_int _ _ _ Hz) as (n1 & Hn1 & Ezn).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn1; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hlv1 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_hitbox bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_hitbox] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(a1r & ae1r & am1r & a2r & A1r & A2r) | (A1r & Xn)]; [ | kill_sq A1r Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A1r Hcm) as (-> & -> & _).
    apply RA.seq_inv in A2r as [(a3r & ae3r & am3r & a4r & A3r & A4r) | (A3r & Xn)]; [ | kill_sq A3r Xn ].
    apply RA.set_inv in A3r as (vwr & Evwr & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evwr. subst vwr.
    apply RA.set_inv in A4r as (vvr & Er & -> & -> & _).
    apply RA.ev_cast in Er as (x1r & Ex1r & C1r). apply RA.ev_cast in Ex1r as (x2r & Ex2r & C2r).
    apply RA.ev_binop in Ex2r as (s1r & s2r & Es1r & Es2r & Eopr).
    apply RA.ev_temp in Es1r. rewrite PTree.gss in Es1r. injection Es1r as <-.
    apply RA.ev_const in Es2r. subst s2r.
    cbn in Eopr. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eopr); cbn in Eopr.
    injection Eopr as <-. cbn in C2r. injection C2r as <-. cbn in C1r. injection C1r as <-.
    apply RA.seq_inv in X2 as [(p1 & pe1 & pm1 & p2 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.seq_inv in X3 as [(a1h & ae1h & am1h & a2h & A1h & A2h) | (A1h & Xn)]; [ | kill_sq A1h Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A1h Hcm) as (-> & -> & _).
    apply RA.seq_inv in A2h as [(a3h & ae3h & am3h & a4h & A3h & A4h) | (A3h & Xn)]; [ | kill_sq A3h Xn ].
    apply RA.set_inv in A3h as (vwh & Evwh & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evwh. subst vwh.
    apply RA.set_inv in A4h as (vvh & Eh & -> & -> & _).
    apply RA.ev_cast in Eh as (x1h & Ex1h & C1h). apply RA.ev_cast in Ex1h as (x2h & Ex2h & C2h).
    apply RA.ev_binop in Ex2h as (s1h & s2h & Es1h & Es2h & Eoph).
    apply RA.ev_temp in Es1h. rewrite PTree.gss in Es1h. injection Es1h as <-.
    apply RA.ev_const in Es2h. subst s2h.
    cbn in Eoph. injection Eoph as <-. cbn in C2h. injection C2h as <-. cbn in C1h. injection C1h as <-.
    apply RA.seq_inv in X4 as [(p3 & pe3 & pm3 & p4 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.seq_inv in X5 as [(r11 & re11 & rm11 & r21 & W11 & W21) | (W11 & Xn)]; [ | kill_sq W11 Xn ].
    apply ld_cur in W11 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in W21 as (b21 & o21 & bf21 & v21 & v31 & Hlx1 & Ev1 & Hcast1 & Has1 & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_hbr Hlx1) as (o11 & Ho11 & -> & ->).
    rewrite PTree.gss in Ho11. injection Ho11 as <- <-.
    apply RA.ev_temp in Ev1. do 4 rewrite PTree.gso in Ev1 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev1. injection Ev1 as <-.
    cbn -[Float32.of_int] in Hcast1. injection Hcast1 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has1) as Hs1.
    rewrite uadd in Hs1 by (try rewrite maxu; lia).
    repeat (rewrite Int.sign_ext_idem in Hs1 by lia).
    pose proof (cur_store _ _ _ _ _ Hs1 Hc) as Hc1.
    apply RA.seq_inv in X6 as [(p5 & pe5 & pm5 & p6 & X7 & E1) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.seq_inv in X7 as [(r12 & re12 & rm12 & r22 & W12 & W22) | (W12 & Xn)]; [ | kill_sq W12 Xn ].
    apply ld_cur in W12 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in W22 as (b22 & o22 & bf22 & v22 & v32 & Hlx2 & Ev2 & Hcast2 & Has2 & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_hbh Hlx2) as (o12 & Ho12 & -> & ->).
    rewrite PTree.gss in Ho12. injection Ho12 as <- <-.
    apply RA.ev_temp in Ev2. do 2 rewrite PTree.gso in Ev2 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev2. injection Ev2 as <-.
    cbn -[Float32.of_int] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has2) as Hs2.
    rewrite uadd in Hs2 by (try rewrite maxu; lia).
    repeat (rewrite Int.sign_ext_idem in Hs2 by lia).
    pose proof (cur_store _ _ _ _ _ Hs2 Hc1) as Hc2.
    assert (Lc : Mem.load Mint32 pm5 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; exact Hbp); rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HSx : Vstk pm5 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; left; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; left; cbn [size_chunk]; unfold OW.O_SIDX; lia). exact Hsi.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; left; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; left; cbn [size_chunk]; unfold OW.O_STK; lia). exact (Hk j f Hj). }
    assert (Er : rngi_of z = Int.sign_ext 16 (Int.shru n1 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn, Int.repr_unsigned; reflexivity).
    assert (Em : s16_of z = Int.sign_ext 16 (Int.and n1 (Int.repr 65535)))
      by (unfold s16_of; rewrite Ezn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsbs) | exact (Vstk_bc _ _ _ _ HSx Hs9) ].
    - split; [ exact (Hc9 Hc2) | split; [ reflexivity | ] ].
      exists z, pm3, pm5. rewrite Er, Em.
      split; [ exact Hz | split; [ exact Hs1 | split; [ exact Hs2 | exact U9 ] ] ].
  Qed.

  (* ---- SET_HITBOX_WITH_OFFSET (0x2B): as SET_HITBOX, and
     o->hitboxDownOffset = (s16)(w2 >> 16); cmd += 3 ---- *)
  Lemma hd_set_hitbox_with_offset : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 43 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_hitbox_with_offset) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists z z2 m1 m2 m3, word_at (v_s st) (v_i st + 1) = Some z
         /\ word_at (v_s st) (v_i st + 2) = Some z2
         /\ Mem.store Mfloat32 m pool (oc + 504) (Vsingle (Float32.of_int (rngi_of z))) = Some m1
         /\ Mem.store Mfloat32 m1 pool (oc + 508) (Vsingle (Float32.of_int (s16_of z))) = Some m2
         /\ Mem.store Mfloat32 m2 pool (oc + 520) (Vsingle (Float32.of_int (rngi_of z2))) = Some m3
         /\ Mem.unchanged_on Pfr m3 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_hbo st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    destruct (hb_w1 st w Hst Hw (or_intror Ho)) as (z & Hz).
    destruct (word_int _ _ _ Hz) as (n1 & Hn1 & Ezn).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    destruct (hbo_w2 st w Hst Hw Ho) as (z2 & Hz2).
    destruct (word_int _ _ _ Hz2) as (n2 & Hn2 & Ezn2).
    destruct (Hscr (v_s st) b (v_i st + 2)%nat _ Hsbs (in_map _ _ _ Hst) Hn2) as (vn2 & Hlv2 & Hiv2).
    cbn in Hiv2. subst vn2.
    assert (Hilt : (v_i st + 2 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn2; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4) in Hlv1 by lia.
    replace (4 * Z.of_nat (v_i st + 2)) with (I4 + 8) in Hlv2 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_hitbox_with_offset bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_hitbox_with_offset] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(a1r & ae1r & am1r & a2r & A1r & A2r) | (A1r & Xn)]; [ | kill_sq A1r Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A1r Hcm) as (-> & -> & _).
    apply RA.seq_inv in A2r as [(a3r & ae3r & am3r & a4r & A3r & A4r) | (A3r & Xn)]; [ | kill_sq A3r Xn ].
    apply RA.set_inv in A3r as (vwr & Evwr & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evwr. subst vwr.
    apply RA.set_inv in A4r as (vvr & Er & -> & -> & _).
    apply RA.ev_cast in Er as (x1r & Ex1r & C1r). apply RA.ev_cast in Ex1r as (x2r & Ex2r & C2r).
    apply RA.ev_binop in Ex2r as (s1r & s2r & Es1r & Es2r & Eopr).
    apply RA.ev_temp in Es1r. rewrite PTree.gss in Es1r. injection Es1r as <-.
    apply RA.ev_const in Es2r. subst s2r.
    cbn in Eopr. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eopr); cbn in Eopr.
    injection Eopr as <-. cbn in C2r. injection C2r as <-. cbn in C1r. injection C1r as <-.
    apply RA.seq_inv in X2 as [(p1 & pe1 & pm1 & p2 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.seq_inv in X3 as [(a1h & ae1h & am1h & a2h & A1h & A2h) | (A1h & Xn)]; [ | kill_sq A1h Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A1h Hcm) as (-> & -> & _).
    apply RA.seq_inv in A2h as [(a3h & ae3h & am3h & a4h & A3h & A4h) | (A3h & Xn)]; [ | kill_sq A3h Xn ].
    apply RA.set_inv in A3h as (vwh & Evwh & -> & -> & _).
    apply (ev_w1 _ _ _ b I4 n1 _ (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evwh. subst vwh.
    apply RA.set_inv in A4h as (vvh & Eh & -> & -> & _).
    apply RA.ev_cast in Eh as (x1h & Ex1h & C1h). apply RA.ev_cast in Ex1h as (x2h & Ex2h & C2h).
    apply RA.ev_binop in Ex2h as (s1h & s2h & Es1h & Es2h & Eoph).
    apply RA.ev_temp in Es1h. rewrite PTree.gss in Es1h. injection Es1h as <-.
    apply RA.ev_const in Es2h. subst s2h.
    cbn in Eoph. injection Eoph as <-. cbn in C2h. injection C2h as <-. cbn in C1h. injection C1h as <-.
    apply RA.seq_inv in X4 as [(p7 & pe7 & pm7 & p8 & X9 & X10) | (X9 & Xn)]; [ | kill_sq X9 Xn ].
    apply RA.seq_inv in X9 as [(a1d & ae1d & am1d & a2d & A1d & A2d) | (A1d & Xn)]; [ | kill_sq A1d Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A1d Hcm) as (-> & -> & _).
    apply RA.seq_inv in A2d as [(a3d & ae3d & am3d & a4d & A3d & A4d) | (A3d & Xn)]; [ | kill_sq A3d Xn ].
    apply RA.set_inv in A3d as (vwd & Evwd & -> & -> & _).
    apply (ev_w2 _ _ _ b I4 n2 _ (PTree.gss _ _ _) ltac:(lia) Hlv2) in Evwd. subst vwd.
    apply RA.set_inv in A4d as (vvd & Ed & -> & -> & _).
    apply RA.ev_cast in Ed as (x1d & Ex1d & C1d). apply RA.ev_cast in Ex1d as (x2d & Ex2d & C2d).
    apply RA.ev_binop in Ex2d as (s1d & s2d & Es1d & Es2d & Eopd).
    apply RA.ev_temp in Es1d. rewrite PTree.gss in Es1d. injection Es1d as <-.
    apply RA.ev_const in Es2d. subst s2d.
    cbn in Eopd. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eopd); cbn in Eopd.
    injection Eopd as <-. cbn in C2d. injection C2d as <-. cbn in C1d. injection C1d as <-.
    apply RA.seq_inv in X10 as [(p3 & pe3 & pm3 & p4 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.seq_inv in X5 as [(r11 & re11 & rm11 & r21 & W11 & W21) | (W11 & Xn)]; [ | kill_sq W11 Xn ].
    apply ld_cur in W11 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in W21 as (b21 & o21 & bf21 & v21 & v31 & Hlx1 & Ev1 & Hcast1 & Has1 & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_hbr Hlx1) as (o11 & Ho11 & -> & ->).
    rewrite PTree.gss in Ho11. injection Ho11 as <- <-.
    apply RA.ev_temp in Ev1. do 7 rewrite PTree.gso in Ev1 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev1. injection Ev1 as <-.
    cbn -[Float32.of_int] in Hcast1. injection Hcast1 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has1) as Hs1.
    rewrite uadd in Hs1 by (try rewrite maxu; lia).
    repeat (rewrite Int.sign_ext_idem in Hs1 by lia).
    pose proof (cur_store _ _ _ _ _ Hs1 Hc) as Hc1.
    apply RA.seq_inv in X6 as [(p5 & pe5 & pm5 & p6 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.seq_inv in X7 as [(r12 & re12 & rm12 & r22 & W12 & W22) | (W12 & Xn)]; [ | kill_sq W12 Xn ].
    apply ld_cur in W12 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in W22 as (b22 & o22 & bf22 & v22 & v32 & Hlx2 & Ev2 & Hcast2 & Has2 & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_hbh Hlx2) as (o12 & Ho12 & -> & ->).
    rewrite PTree.gss in Ho12. injection Ho12 as <- <-.
    apply RA.ev_temp in Ev2. do 5 rewrite PTree.gso in Ev2 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev2. injection Ev2 as <-.
    cbn -[Float32.of_int] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has2) as Hs2.
    rewrite uadd in Hs2 by (try rewrite maxu; lia).
    repeat (rewrite Int.sign_ext_idem in Hs2 by lia).
    pose proof (cur_store _ _ _ _ _ Hs2 Hc1) as Hc2.
    apply RA.seq_inv in X8 as [(p9 & pe9 & pm9 & p10 & X11 & E1) | (X11 & Xn)]; [ | kill_sq X11 Xn ].
    apply RA.seq_inv in X11 as [(r13 & re13 & rm13 & r23 & W13 & W23) | (W13 & Xn)]; [ | kill_sq W13 Xn ].
    apply ld_cur in W13 as (-> & -> & _); [ | exact Hc2 ].
    apply RA.assign_inv in W23 as (b23 & o23 & bf23 & v23 & v33 & Hlx3 & Ev3 & Hcast3 & Has3 & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_hbd Hlx3) as (o13 & Ho13 & -> & ->).
    rewrite PTree.gss in Ho13. injection Ho13 as <- <-.
    apply RA.ev_temp in Ev3. do 3 rewrite PTree.gso in Ev3 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev3. injection Ev3 as <-.
    cbn -[Float32.of_int] in Hcast3. injection Hcast3 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has3) as Hs3.
    rewrite uadd in Hs3 by (try rewrite maxu; lia).
    repeat (rewrite Int.sign_ext_idem in Hs3 by lia).
    pose proof (cur_store _ _ _ _ _ Hs3 Hc2) as Hc3.
    assert (Lc : Mem.load Mint32 pm9 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (left; exact Hbp); rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; exact Hbp); rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    (* cmd = cmd + 3 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 3)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HSx : Vstk pm9 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (right; left; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; left; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; left; cbn [size_chunk]; unfold OW.O_SIDX; lia). exact Hsi.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (right; left; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; left; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; left; cbn [size_chunk]; unfold OW.O_STK; lia). exact (Hk j f Hj). }
    assert (Er : rngi_of z = Int.sign_ext 16 (Int.shru n1 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn, Int.repr_unsigned; reflexivity).
    assert (Er2 : rngi_of z2 = Int.sign_ext 16 (Int.shru n2 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn2, Int.repr_unsigned; reflexivity).
    assert (Em : s16_of z = Int.sign_ext 16 (Int.and n1 (Int.repr 65535)))
      by (unfold s16_of; rewrite Ezn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsbs) | exact (Vstk_bc _ _ _ _ HSx Hs9) ].
    - split; [ exact (Hc9 Hc3) | split; [ reflexivity | ] ].
      exists z, z2, pm3, pm5, pm9. rewrite Er, Er2, Em.
      split; [ exact Hz | split; [ exact Hz2 | split; [ exact Hs1 | split; [ exact Hs2 | split; [ exact Hs3 | exact U9 ] ] ] ] ].
  Qed.

  (* ---- SET_HOME (0x2D): o->oHomeX/Y/Z (fields 55-57) = o->oPosX/Y/Z
     (fields 6-8); cmd += 1 ---- *)
  Lemma hd_set_home : forall m st w t m' vr,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 45 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_home) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists f1 f2 f3 m1 m2 m3,
           Mem.load Mfloat32 m pool (oc + 136 + 4 * 6) = Some (Vsingle f1)
         /\ Mem.store Mfloat32 m pool (oc + 136 + 4 * 55) (Vsingle f1) = Some m1
         /\ Mem.load Mfloat32 m1 pool (oc + 136 + 4 * 7) = Some (Vsingle f2)
         /\ Mem.store Mfloat32 m1 pool (oc + 136 + 4 * 56) (Vsingle f2) = Some m2
         /\ Mem.load Mfloat32 m2 pool (oc + 136 + 4 * 8) = Some (Vsingle f3)
         /\ Mem.store Mfloat32 m2 pool (oc + 136 + 4 * 57) (Vsingle f3) = Some m3
         /\ Mem.unchanged_on Pfr m3 m'.
  Proof.
    intros m st w t m' vr Hst HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_home st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_home bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_home] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(a1x & ae1x & am1x & a2x & A1x & A2x) | (A1x & Xn)]; [ | kill_sq A1x Xn ].
    apply ld_cur in A1x as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in A2x as [(a3x & ae3x & am3x & a4x & A3x & A4x) | (A3x & Xn)]; [ | kill_sq A3x Xn ].
    apply ld_cur in A3x as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in A4x as [(a5x & ae5x & am5x & a6x & A5x & A6x) | (A5x & Xn)]; [ | kill_sq A5x Xn ].
    apply RA.set_inv in A5x as (vvx & Evx & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in Evx as (brx & orx & Eax & Hldx).
    destruct (lv_rawf_any _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tfloat _ _ Eax))
      as (b0rx & o0rx & virx & Hprx & _ & Eirx & Earx).
    rewrite PTree.gss in Hprx. injection Hprx as <- <-.
    apply RA.ev_binop in Eirx as (i1x & i2x & Ei1x & Ei2x & Eiax).
    apply RA.ev_const in Ei1x. apply RA.ev_const in Ei2x. subst i1x i2x.
    cbn in Eiax. injection Eiax as <-.
    apply (raw_cidx _ _ _ 6 _ _ _ Hoc ltac:(lia) eq_refl) in Earx as (Ebrx & Earx). subst brx.
    cbn [Mem.loadv] in Hldx. rewrite Earx in Hldx.
    apply RA.assign_inv in A6x as (b2x & o2x & bf2x & v2x & v3x & Hlxx & Exx & Hcastx & Hasx & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlxx) as (b0wx & o0wx & viwx & Hpwx & -> & Eiwx & Eawx).
    do 2 rewrite PTree.gso in Hpwx by (vm_compute; discriminate). rewrite PTree.gss in Hpwx.
    injection Hpwx as <- <-.
    apply RA.ev_const in Eiwx. subst viwx.
    apply (raw_cidx _ _ _ 55 _ _ _ Hoc ltac:(lia) eq_refl) in Eawx as (Ebwx & Eawx). subst b2x.
    apply RA.ev_temp in Exx. rewrite PTree.gss in Exx. injection Exx as <-.
    destruct vvx as [ | ? | ? | ? | fx | ? ? ]; try (cbn in Hcastx; discriminate Hcastx).
    cbn in Hcastx. injection Hcastx as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Hasx) as Hsx.
    rewrite Eawx in Hsx.
    pose proof (cur_store _ _ _ _ _ Hsx Hc) as Hc1.
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.seq_inv in X3 as [(a1y & ae1y & am1y & a2y & A1y & A2y) | (A1y & Xn)]; [ | kill_sq A1y Xn ].
    apply ld_cur in A1y as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in A2y as [(a3y & ae3y & am3y & a4y & A3y & A4y) | (A3y & Xn)]; [ | kill_sq A3y Xn ].
    apply ld_cur in A3y as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in A4y as [(a5y & ae5y & am5y & a6y & A5y & A6y) | (A5y & Xn)]; [ | kill_sq A5y Xn ].
    apply RA.set_inv in A5y as (vvy & Evy & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in Evy as (bry & ory & Eay & Hldy).
    destruct (lv_rawf_any _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tfloat _ _ Eay))
      as (b0ry & o0ry & viry & Hpry & _ & Eiry & Eary).
    rewrite PTree.gss in Hpry. injection Hpry as <- <-.
    apply RA.ev_binop in Eiry as (i1y & i2y & Ei1y & Ei2y & Eiay).
    apply RA.ev_const in Ei1y. apply RA.ev_const in Ei2y. subst i1y i2y.
    cbn in Eiay. injection Eiay as <-.
    apply (raw_cidx _ _ _ 7 _ _ _ Hoc ltac:(lia) eq_refl) in Eary as (Ebry & Eary). subst bry.
    cbn [Mem.loadv] in Hldy. rewrite Eary in Hldy.
    apply RA.assign_inv in A6y as (b2y & o2y & bf2y & v2y & v3y & Hlxy & Exy & Hcasty & Hasy & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlxy) as (b0wy & o0wy & viwy & Hpwy & -> & Eiwy & Eawy).
    do 2 rewrite PTree.gso in Hpwy by (vm_compute; discriminate). rewrite PTree.gss in Hpwy.
    injection Hpwy as <- <-.
    apply RA.ev_const in Eiwy. subst viwy.
    apply (raw_cidx _ _ _ 56 _ _ _ Hoc ltac:(lia) eq_refl) in Eawy as (Ebwy & Eawy). subst b2y.
    apply RA.ev_temp in Exy. rewrite PTree.gss in Exy. injection Exy as <-.
    destruct vvy as [ | ? | ? | ? | fy | ? ? ]; try (cbn in Hcasty; discriminate Hcasty).
    cbn in Hcasty. injection Hcasty as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Hasy) as Hsy.
    rewrite Eawy in Hsy.
    pose proof (cur_store _ _ _ _ _ Hsy Hc1) as Hc2.
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & E1) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.seq_inv in X5 as [(a1z & ae1z & am1z & a2z & A1z & A2z) | (A1z & Xn)]; [ | kill_sq A1z Xn ].
    apply ld_cur in A1z as (-> & -> & _); [ | exact Hc2 ].
    apply RA.seq_inv in A2z as [(a3z & ae3z & am3z & a4z & A3z & A4z) | (A3z & Xn)]; [ | kill_sq A3z Xn ].
    apply ld_cur in A3z as (-> & -> & _); [ | exact Hc2 ].
    apply RA.seq_inv in A4z as [(a5z & ae5z & am5z & a6z & A5z & A6z) | (A5z & Xn)]; [ | kill_sq A5z Xn ].
    apply RA.set_inv in A5z as (vvz & Evz & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in Evz as (brz & orz & Eaz & Hldz).
    destruct (lv_rawf_any _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tfloat _ _ Eaz))
      as (b0rz & o0rz & virz & Hprz & _ & Eirz & Earz).
    rewrite PTree.gss in Hprz. injection Hprz as <- <-.
    apply RA.ev_binop in Eirz as (i1z & i2z & Ei1z & Ei2z & Eiaz).
    apply RA.ev_const in Ei1z. apply RA.ev_const in Ei2z. subst i1z i2z.
    cbn in Eiaz. injection Eiaz as <-.
    apply (raw_cidx _ _ _ 8 _ _ _ Hoc ltac:(lia) eq_refl) in Earz as (Ebrz & Earz). subst brz.
    cbn [Mem.loadv] in Hldz. rewrite Earz in Hldz.
    apply RA.assign_inv in A6z as (b2z & o2z & bf2z & v2z & v3z & Hlxz & Exz & Hcastz & Hasz & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlxz) as (b0wz & o0wz & viwz & Hpwz & -> & Eiwz & Eawz).
    do 2 rewrite PTree.gso in Hpwz by (vm_compute; discriminate). rewrite PTree.gss in Hpwz.
    injection Hpwz as <- <-.
    apply RA.ev_const in Eiwz. subst viwz.
    apply (raw_cidx _ _ _ 57 _ _ _ Hoc ltac:(lia) eq_refl) in Eawz as (Ebwz & Eawz). subst b2z.
    apply RA.ev_temp in Exz. rewrite PTree.gss in Exz. injection Exz as <-.
    destruct vvz as [ | ? | ? | ? | fz | ? ? ]; try (cbn in Hcastz; discriminate Hcastz).
    cbn in Hcastz. injection Hcastz as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Hasz) as Hsz.
    rewrite Eawz in Hsz.
    pose proof (cur_store _ _ _ _ _ Hsz Hc2) as Hc3.
    assert (Lc : Mem.load Mint32 m5 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hsz) by (left; exact Hbp);
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsy) by (left; exact Hbp);
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsx) by (left; exact Hbp); exact Hcm).
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HSx : Vstk m5 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hsz) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsy) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsx) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia).
        exact Hsi.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsz) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsy) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsx) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia).
        exact (Hk j f Hj). }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsbs) | exact (Vstk_bc _ _ _ _ HSx Hs9) ].
    - split; [ exact (Hc9 Hc3) | split; [ reflexivity | ] ].
      exists fx, fy, fz, m1, m3, m5.
      split; [ exact Hldx | split; [ exact Hsx | split; [ exact Hldy | split; [ exact Hsy |
        split; [ exact Hldz | split; [ exact Hsz | exact U9 ] ] ] ] ] ].
  Qed.

  (* ---- SET_OBJ_PHYSICS (0x30): oWallHitboxRadius (40) = (s16)(w1 >> 16);
     oGravity (23) / oBounciness (52) / oDragStrength (41) / oFriction (58) /
     oBuoyancy (59) = the next s16 halves of w1..w3 / 100.0f; two unused
     reads of w4; cmd += 5 ---- *)
  Definition pdiv (x : int) : float32 := Float32.div (Float32.of_int x) (Float32.of_bits (Int.repr 1120403456)).

  Lemma hd_set_obj_physics : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 48 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_set_obj_physics) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists z1 z2 z3 m1 m2 m3 m4 m5 m6,
           word_at (v_s st) (v_i st + 1) = Some z1 /\ word_at (v_s st) (v_i st + 2) = Some z2
         /\ word_at (v_s st) (v_i st + 3) = Some z3
         /\ Mem.store Mfloat32 m pool (oc + 136 + 4 * 40) (Vsingle (Float32.of_int (rngi_of z1))) = Some m1
         /\ Mem.store Mfloat32 m1 pool (oc + 136 + 4 * 23) (Vsingle (pdiv (s16_of z1))) = Some m2
         /\ Mem.store Mfloat32 m2 pool (oc + 136 + 4 * 52) (Vsingle (pdiv (rngi_of z2))) = Some m3
         /\ Mem.store Mfloat32 m3 pool (oc + 136 + 4 * 41) (Vsingle (pdiv (s16_of z2))) = Some m4
         /\ Mem.store Mfloat32 m4 pool (oc + 136 + 4 * 58) (Vsingle (pdiv (rngi_of z3))) = Some m5
         /\ Mem.store Mfloat32 m5 pool (oc + 136 + 4 * 59) (Vsingle (pdiv (s16_of z3))) = Some m6
         /\ Mem.unchanged_on Pfr m6 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_phys st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    pose proof (Hps st b Hst Hsbs) as Hbpl.
    destruct (phys_w st w Hst Hw Ho) as (z1 & z2 & z3 & Hz1 & Hz2 & Hz3).
    destruct (word_int _ _ _ Hz1) as (n1 & Hn1 & Ezn1).
    destruct (word_int _ _ _ Hz2) as (n2 & Hn2 & Ezn2).
    destruct (word_int _ _ _ Hz3) as (n3 & Hn3 & Ezn3).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsbs (in_map _ _ _ Hst) Hn1) as (vn1 & Hlv1 & Hiv1).
    cbn in Hiv1. subst vn1.
    destruct (Hscr (v_s st) b (v_i st + 2)%nat _ Hsbs (in_map _ _ _ Hst) Hn2) as (vn2 & Hlv2 & Hiv2).
    cbn in Hiv2. subst vn2.
    destruct (Hscr (v_s st) b (v_i st + 3)%nat _ Hsbs (in_map _ _ _ Hst) Hn3) as (vn3 & Hlv3 & Hiv3).
    cbn in Hiv3. subst vn3.
    assert (Hilt : (v_i st + 3 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn3; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4 * 1) in Hlv1 by lia.
    replace (4 * Z.of_nat (v_i st + 2)) with (I4 + 4 * 2) in Hlv2 by lia.
    replace (4 * Z.of_nat (v_i st + 3)) with (I4 + 4 * 3) in Hlv3 by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_set_obj_physics bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_set_obj_physics] in X.
    (* block 1: field 40 *)
    apply RA.seq_inv in X as [(c11 & ce11 & mb1 & c21 & B1 & R1) | (B1 & Xn)]; [ | kill_sq B1 Xn ].
    apply RA.seq_inv in B1 as [(a11 & ae11 & am11 & a21 & A11 & A21) | (A11 & Xn)]; [ | kill_sq A11 Xn ].
    apply ld_cur in A11 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in A21 as [(a31 & ae31 & am31 & a41 & A31 & A41) | (A31 & Xn)]; [ | kill_sq A31 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A31 Hcm) as (-> & -> & _).
    apply RA.seq_inv in A41 as [(a51 & ae51 & am51 & a61 & A51 & A61) | (A51 & Xn)]; [ | kill_sq A51 Xn ].
    apply RA.set_inv in A51 as (vw1 & Evw1 & -> & -> & _).
    apply (ev_wk _ _ _ b I4 1 n1 _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evw1. subst vw1.
    apply RA.assign_inv in A61 as (b21 & o21 & bf21 & v21 & v31 & Hlx1 & Ex1 & Hcast1 & Has1 & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlx1) as (b0w1 & o0w1 & viw1 & Hpw1 & -> & Eiw1 & Eaw1).
    do 2 rewrite PTree.gso in Hpw1 by (vm_compute; discriminate). rewrite PTree.gss in Hpw1.
    injection Hpw1 as <- <-.
    apply RA.ev_const in Eiw1. subst viw1.
    apply (raw_cidx _ _ _ 40 _ _ _ Hoc ltac:(lia) eq_refl) in Eaw1 as (Ebw1 & Eaw1). subst b21.
    apply RA.ev_cast in Ex1 as (y11 & Ey11 & Cy11).
    apply RA.ev_binop in Ey11 as (s11 & s21 & Es11 & Es21 & Eop1).
    apply RA.ev_temp in Es11. rewrite PTree.gss in Es11. injection Es11 as <-.
    apply RA.ev_const in Es21. subst s21.
    cbn in Eop1. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eop1); cbn in Eop1.
    injection Eop1 as <-. cbn in Cy11. injection Cy11 as <-.
    cbn -[Float32.of_int] in Hcast1. injection Hcast1 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has1) as Hs1.
    rewrite Eaw1 in Hs1.
    pose proof (cur_store _ _ _ _ _ Hs1 Hc) as Hc1.
    assert (Lc1 : Mem.load Mint32 mb1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    assert (Hb1 : forall z v, Mem.load Mint32 m b z = Some v -> Mem.load Mint32 mb1 b z = Some v)
      by (intros z v Hz; rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbpl); exact Hz).
    apply Hb1 in Hlv1. apply Hb1 in Hlv2. apply Hb1 in Hlv3.
    (* block 2: field 23 *)
    apply RA.seq_inv in R1 as [(c12 & ce12 & mb2 & c22 & B2 & R2) | (B2 & Xn)]; [ | kill_sq B2 Xn ].
    apply RA.seq_inv in B2 as [(a12 & ae12 & am12 & a22 & A12 & A22) | (A12 & Xn)]; [ | kill_sq A12 Xn ].
    apply ld_cur in A12 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.seq_inv in A22 as [(a32 & ae32 & am32 & a42 & A32 & A42) | (A32 & Xn)]; [ | kill_sq A32 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A32 Lc1) as (-> & -> & _).
    apply RA.seq_inv in A42 as [(a52 & ae52 & am52 & a62 & A52 & A62) | (A52 & Xn)]; [ | kill_sq A52 Xn ].
    apply RA.set_inv in A52 as (vw2 & Evw2 & -> & -> & _).
    apply (ev_wk _ _ _ b I4 1 n1 _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hlv1) in Evw2. subst vw2.
    apply RA.assign_inv in A62 as (b22 & o22 & bf22 & v22 & v32 & Hlx2 & Ex2 & Hcast2 & Has2 & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlx2) as (b0w2 & o0w2 & viw2 & Hpw2 & -> & Eiw2 & Eaw2).
    do 2 rewrite PTree.gso in Hpw2 by (vm_compute; discriminate). rewrite PTree.gss in Hpw2.
    injection Hpw2 as <- <-.
    apply RA.ev_const in Eiw2. subst viw2.
    apply (raw_cidx _ _ _ 23 _ _ _ Hoc ltac:(lia) eq_refl) in Eaw2 as (Ebw2 & Eaw2). subst b22.
    apply RA.ev_binop in Ex2 as (d12 & d22 & Ed12 & Ed22 & Ediv2).
    apply RA.ev_cast in Ed12 as (y12 & Ey12 & Cy12).
    apply RA.ev_binop in Ey12 as (s12 & s22 & Es12 & Es22 & Eop2).
    apply RA.ev_temp in Es12. rewrite PTree.gss in Es12. injection Es12 as <-.
    apply RA.ev_const in Es22. subst s22.
    cbn in Eop2. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eop2); cbn in Eop2.
    injection Eop2 as <-. cbn in Cy12. injection Cy12 as <-.
    apply RA.ev_single in Ed22. subst d22.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Ediv2. injection Ediv2 as <-.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has2) as Hs2.
    rewrite Eaw2 in Hs2.
    pose proof (cur_store _ _ _ _ _ Hs2 Hc1) as Hc2.
    assert (Lc2 : Mem.load Mint32 mb2 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; exact Hbp); exact Lc1).
    assert (Hb2 : forall z v, Mem.load Mint32 mb1 b z = Some v -> Mem.load Mint32 mb2 b z = Some v)
      by (intros z v Hz; rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; exact Hbpl); exact Hz).
    apply Hb2 in Hlv1. apply Hb2 in Hlv2. apply Hb2 in Hlv3.
    (* block 3: field 52 *)
    apply RA.seq_inv in R2 as [(c13 & ce13 & mb3 & c23 & B3 & R3) | (B3 & Xn)]; [ | kill_sq B3 Xn ].
    apply RA.seq_inv in B3 as [(a13 & ae13 & am13 & a23 & A13 & A23) | (A13 & Xn)]; [ | kill_sq A13 Xn ].
    apply ld_cur in A13 as (-> & -> & _); [ | exact Hc2 ].
    apply RA.seq_inv in A23 as [(a33 & ae33 & am33 & a43 & A33 & A43) | (A33 & Xn)]; [ | kill_sq A33 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A33 Lc2) as (-> & -> & _).
    apply RA.seq_inv in A43 as [(a53 & ae53 & am53 & a63 & A53 & A63) | (A53 & Xn)]; [ | kill_sq A53 Xn ].
    apply RA.set_inv in A53 as (vw3 & Evw3 & -> & -> & _).
    apply (ev_wk _ _ _ b I4 2 n2 _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hlv2) in Evw3. subst vw3.
    apply RA.assign_inv in A63 as (b23 & o23 & bf23 & v23 & v33 & Hlx3 & Ex3 & Hcast3 & Has3 & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlx3) as (b0w3 & o0w3 & viw3 & Hpw3 & -> & Eiw3 & Eaw3).
    do 2 rewrite PTree.gso in Hpw3 by (vm_compute; discriminate). rewrite PTree.gss in Hpw3.
    injection Hpw3 as <- <-.
    apply RA.ev_const in Eiw3. subst viw3.
    apply (raw_cidx _ _ _ 52 _ _ _ Hoc ltac:(lia) eq_refl) in Eaw3 as (Ebw3 & Eaw3). subst b23.
    apply RA.ev_binop in Ex3 as (d13 & d23 & Ed13 & Ed23 & Ediv3).
    apply RA.ev_cast in Ed13 as (y13 & Ey13 & Cy13).
    apply RA.ev_binop in Ey13 as (s13 & s23 & Es13 & Es23 & Eop3).
    apply RA.ev_temp in Es13. rewrite PTree.gss in Es13. injection Es13 as <-.
    apply RA.ev_const in Es23. subst s23.
    cbn in Eop3. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eop3); cbn in Eop3.
    injection Eop3 as <-. cbn in Cy13. injection Cy13 as <-.
    apply RA.ev_single in Ed23. subst d23.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Ediv3. injection Ediv3 as <-.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Hcast3. injection Hcast3 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has3) as Hs3.
    rewrite Eaw3 in Hs3.
    pose proof (cur_store _ _ _ _ _ Hs3 Hc2) as Hc3.
    assert (Lc3 : Mem.load Mint32 mb3 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (left; exact Hbp); exact Lc2).
    assert (Hb3 : forall z v, Mem.load Mint32 mb2 b z = Some v -> Mem.load Mint32 mb3 b z = Some v)
      by (intros z v Hz; rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (left; exact Hbpl); exact Hz).
    apply Hb3 in Hlv1. apply Hb3 in Hlv2. apply Hb3 in Hlv3.
    (* block 4: field 41 *)
    apply RA.seq_inv in R3 as [(c14 & ce14 & mb4 & c24 & B4 & R4) | (B4 & Xn)]; [ | kill_sq B4 Xn ].
    apply RA.seq_inv in B4 as [(a14 & ae14 & am14 & a24 & A14 & A24) | (A14 & Xn)]; [ | kill_sq A14 Xn ].
    apply ld_cur in A14 as (-> & -> & _); [ | exact Hc3 ].
    apply RA.seq_inv in A24 as [(a34 & ae34 & am34 & a44 & A34 & A44) | (A34 & Xn)]; [ | kill_sq A34 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A34 Lc3) as (-> & -> & _).
    apply RA.seq_inv in A44 as [(a54 & ae54 & am54 & a64 & A54 & A64) | (A54 & Xn)]; [ | kill_sq A54 Xn ].
    apply RA.set_inv in A54 as (vw4 & Evw4 & -> & -> & _).
    apply (ev_wk _ _ _ b I4 2 n2 _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hlv2) in Evw4. subst vw4.
    apply RA.assign_inv in A64 as (b24 & o24 & bf24 & v24 & v34 & Hlx4 & Ex4 & Hcast4 & Has4 & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlx4) as (b0w4 & o0w4 & viw4 & Hpw4 & -> & Eiw4 & Eaw4).
    do 2 rewrite PTree.gso in Hpw4 by (vm_compute; discriminate). rewrite PTree.gss in Hpw4.
    injection Hpw4 as <- <-.
    apply RA.ev_const in Eiw4. subst viw4.
    apply (raw_cidx _ _ _ 41 _ _ _ Hoc ltac:(lia) eq_refl) in Eaw4 as (Ebw4 & Eaw4). subst b24.
    apply RA.ev_binop in Ex4 as (d14 & d24 & Ed14 & Ed24 & Ediv4).
    apply RA.ev_cast in Ed14 as (y14 & Ey14 & Cy14).
    apply RA.ev_binop in Ey14 as (s14 & s24 & Es14 & Es24 & Eop4).
    apply RA.ev_temp in Es14. rewrite PTree.gss in Es14. injection Es14 as <-.
    apply RA.ev_const in Es24. subst s24.
    cbn in Eop4. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eop4); cbn in Eop4.
    injection Eop4 as <-. cbn in Cy14. injection Cy14 as <-.
    apply RA.ev_single in Ed24. subst d24.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Ediv4. injection Ediv4 as <-.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Hcast4. injection Hcast4 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has4) as Hs4.
    rewrite Eaw4 in Hs4.
    pose proof (cur_store _ _ _ _ _ Hs4 Hc3) as Hc4.
    assert (Lc4 : Mem.load Mint32 mb4 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by (left; exact Hbp); exact Lc3).
    assert (Hb4 : forall z v, Mem.load Mint32 mb3 b z = Some v -> Mem.load Mint32 mb4 b z = Some v)
      by (intros z v Hz; rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by (left; exact Hbpl); exact Hz).
    apply Hb4 in Hlv1. apply Hb4 in Hlv2. apply Hb4 in Hlv3.
    (* block 5: field 58 *)
    apply RA.seq_inv in R4 as [(c15 & ce15 & mb5 & c25 & B5 & R5) | (B5 & Xn)]; [ | kill_sq B5 Xn ].
    apply RA.seq_inv in B5 as [(a15 & ae15 & am15 & a25 & A15 & A25) | (A15 & Xn)]; [ | kill_sq A15 Xn ].
    apply ld_cur in A15 as (-> & -> & _); [ | exact Hc4 ].
    apply RA.seq_inv in A25 as [(a35 & ae35 & am35 & a45 & A35 & A45) | (A35 & Xn)]; [ | kill_sq A35 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A35 Lc4) as (-> & -> & _).
    apply RA.seq_inv in A45 as [(a55 & ae55 & am55 & a65 & A55 & A65) | (A55 & Xn)]; [ | kill_sq A55 Xn ].
    apply RA.set_inv in A55 as (vw5 & Evw5 & -> & -> & _).
    apply (ev_wk _ _ _ b I4 3 n3 _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hlv3) in Evw5. subst vw5.
    apply RA.assign_inv in A65 as (b25 & o25 & bf25 & v25 & v35 & Hlx5 & Ex5 & Hcast5 & Has5 & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlx5) as (b0w5 & o0w5 & viw5 & Hpw5 & -> & Eiw5 & Eaw5).
    do 2 rewrite PTree.gso in Hpw5 by (vm_compute; discriminate). rewrite PTree.gss in Hpw5.
    injection Hpw5 as <- <-.
    apply RA.ev_const in Eiw5. subst viw5.
    apply (raw_cidx _ _ _ 58 _ _ _ Hoc ltac:(lia) eq_refl) in Eaw5 as (Ebw5 & Eaw5). subst b25.
    apply RA.ev_binop in Ex5 as (d15 & d25 & Ed15 & Ed25 & Ediv5).
    apply RA.ev_cast in Ed15 as (y15 & Ey15 & Cy15).
    apply RA.ev_binop in Ey15 as (s15 & s25 & Es15 & Es25 & Eop5).
    apply RA.ev_temp in Es15. rewrite PTree.gss in Es15. injection Es15 as <-.
    apply RA.ev_const in Es25. subst s25.
    cbn in Eop5. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eop5); cbn in Eop5.
    injection Eop5 as <-. cbn in Cy15. injection Cy15 as <-.
    apply RA.ev_single in Ed25. subst d25.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Ediv5. injection Ediv5 as <-.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Hcast5. injection Hcast5 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has5) as Hs5.
    rewrite Eaw5 in Hs5.
    pose proof (cur_store _ _ _ _ _ Hs5 Hc4) as Hc5.
    assert (Lc5 : Mem.load Mint32 mb5 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by (left; exact Hbp); exact Lc4).
    assert (Hb5 : forall z v, Mem.load Mint32 mb4 b z = Some v -> Mem.load Mint32 mb5 b z = Some v)
      by (intros z v Hz; rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by (left; exact Hbpl); exact Hz).
    apply Hb5 in Hlv1. apply Hb5 in Hlv2. apply Hb5 in Hlv3.
    (* block 6: field 59 *)
    apply RA.seq_inv in R5 as [(c16 & ce16 & mb6 & c26 & B6 & R6) | (B6 & Xn)]; [ | kill_sq B6 Xn ].
    apply RA.seq_inv in B6 as [(a16 & ae16 & am16 & a26 & A16 & A26) | (A16 & Xn)]; [ | kill_sq A16 Xn ].
    apply ld_cur in A16 as (-> & -> & _); [ | exact Hc5 ].
    apply RA.seq_inv in A26 as [(a36 & ae36 & am36 & a46 & A36 & A46) | (A36 & Xn)]; [ | kill_sq A36 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A36 Lc5) as (-> & -> & _).
    apply RA.seq_inv in A46 as [(a56 & ae56 & am56 & a66 & A56 & A66) | (A56 & Xn)]; [ | kill_sq A56 Xn ].
    apply RA.set_inv in A56 as (vw6 & Evw6 & -> & -> & _).
    apply (ev_wk _ _ _ b I4 3 n3 _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hlv3) in Evw6. subst vw6.
    apply RA.assign_inv in A66 as (b26 & o26 & bf26 & v26 & v36 & Hlx6 & Ex6 & Hcast6 & Has6 & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlx6) as (b0w6 & o0w6 & viw6 & Hpw6 & -> & Eiw6 & Eaw6).
    do 2 rewrite PTree.gso in Hpw6 by (vm_compute; discriminate). rewrite PTree.gss in Hpw6.
    injection Hpw6 as <- <-.
    apply RA.ev_const in Eiw6. subst viw6.
    apply (raw_cidx _ _ _ 59 _ _ _ Hoc ltac:(lia) eq_refl) in Eaw6 as (Ebw6 & Eaw6). subst b26.
    apply RA.ev_binop in Ex6 as (d16 & d26 & Ed16 & Ed26 & Ediv6).
    apply RA.ev_cast in Ed16 as (y16 & Ey16 & Cy16).
    apply RA.ev_binop in Ey16 as (s16 & s26 & Es16 & Es26 & Eop6).
    apply RA.ev_temp in Es16. rewrite PTree.gss in Es16. injection Es16 as <-.
    apply RA.ev_const in Es26. subst s26.
    cbn in Eop6. try (change (Int.ltu (Int.repr 16) Int.iwordsize) with true in Eop6); cbn in Eop6.
    injection Eop6 as <-. cbn in Cy16. injection Cy16 as <-.
    apply RA.ev_single in Ed26. subst d26.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Ediv6. injection Ediv6 as <-.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Hcast6. injection Hcast6 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has6) as Hs6.
    rewrite Eaw6 in Hs6.
    pose proof (cur_store _ _ _ _ _ Hs6 Hc5) as Hc6.
    assert (Lc6 : Mem.load Mint32 mb6 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by (left; exact Hbp); exact Lc5).
    assert (Hb6 : forall z v, Mem.load Mint32 mb5 b z = Some v -> Mem.load Mint32 mb6 b z = Some v)
      by (intros z v Hz; rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by (left; exact Hbpl); exact Hz).
    apply Hb6 in Hlv1. apply Hb6 in Hlv2. apply Hb6 in Hlv3.
    (* the two unused reads of word 4 *)
    apply RA.seq_inv in R6 as [(c17 & ce17 & mu1 & c27 & U1 & R7) | (U1 & Xn)]; [ | kill_sq U1 Xn ].
    apply RA.seq_inv in U1 as [(a17 & ae17 & am17 & a27 & A17 & A27) | (A17 & Xn)]; [ | kill_sq A17 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A17 Lc6) as (-> & -> & _).
    apply RA.seq_inv in A27 as [(a37 & ae37 & am37 & a47 & A37 & A47) | (A37 & Xn)]; [ | kill_sq A37 Xn ].
    apply RA.set_inv in A37 as (? & _ & -> & -> & _). apply RA.set_inv in A47 as (? & _ & -> & -> & _).
    apply RA.seq_inv in R7 as [(c18 & ce18 & mu2 & c28 & U2 & E1) | (U2 & Xn)]; [ | kill_sq U2 Xn ].
    apply RA.seq_inv in U2 as [(a18 & ae18 & am18 & a28 & A18 & A28) | (A18 & Xn)]; [ | kill_sq A18 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A18 Lc6) as (-> & -> & _).
    apply RA.seq_inv in A28 as [(a38 & ae38 & am38 & a48 & A38 & A48) | (A38 & Xn)]; [ | kill_sq A38 Xn ].
    apply RA.set_inv in A38 as (? & _ & -> & -> & _). apply RA.set_inv in A48 as (? & _ & -> & -> & _).
    (* cmd = cmd + 5 *)
    apply RA.seq_inv in E1 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc6) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 5)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HSx : Vstk mb6 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). exact Hsi.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). exact (Hk j f Hj). }
    assert (Er1 : rngi_of z1 = Int.sign_ext 16 (Int.shru n1 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn1, Int.repr_unsigned; reflexivity).
    assert (Em1 : s16_of z1 = Int.sign_ext 16 (Int.and n1 (Int.repr 65535)))
      by (unfold s16_of; rewrite Ezn1, Int.repr_unsigned; reflexivity).
    assert (Er2 : rngi_of z2 = Int.sign_ext 16 (Int.shru n2 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn2, Int.repr_unsigned; reflexivity).
    assert (Em2 : s16_of z2 = Int.sign_ext 16 (Int.and n2 (Int.repr 65535)))
      by (unfold s16_of; rewrite Ezn2, Int.repr_unsigned; reflexivity).
    assert (Er3 : rngi_of z3 = Int.sign_ext 16 (Int.shru n3 (Int.repr 16)))
      by (unfold rngi_of; rewrite Ezn3, Int.repr_unsigned; reflexivity).
    assert (Em3 : s16_of z3 = Int.sign_ext 16 (Int.and n3 (Int.repr 65535)))
      by (unfold s16_of; rewrite Ezn3, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsbs) | exact (Vstk_bc _ _ _ _ HSx Hs9) ].
    - split; [ exact (Hc9 Hc6) | split; [ reflexivity | ] ].
      exists z1, z2, z3, mb1, mb2, mb3, mb4, mb5, mb6. unfold pdiv.
      rewrite Er1, Em1, Er2, Em2, Er3, Em3.
      split; [ exact Hz1 | split; [ exact Hz2 | split; [ exact Hz3 | split; [ exact Hs1 | split; [ exact Hs2 |
        split; [ exact Hs3 | split; [ exact Hs4 | split; [ exact Hs5 | split; [ exact Hs6 | exact U9 ] ] ] ] ] ] ] ] ].
  Qed.

  (* ---- LOAD_ANIMATIONS (0x27): o->rawData.asVoidPtr[byte2 w] = (void * ) w1
     (field 38, oAnimations, for all five reachable users) ---- *)
  Lemma hd_load_animations : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 39 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_load_animations) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists ta oa bt m1, nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof ta oa)
         /\ Genv.find_symbol G ta = Some bt
         /\ Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vptr bt oa) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_la st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (la_w st w Hst Hw (or_introl Ho)) as (ta & oa & Ha).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Ha) as (va & Hla & Hia).
    cbn in Hia. destruct Hia as (bt & Hbt & ->).
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Ha; discriminate).
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; do 12 right; left; reflexivity).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4 * 1) in Hla by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_load_animations bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_load_animations] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field = ( *cmd >> 16) & 0xFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* o->rawData.asVoidPtr[field] = (void * ) cmd[1] *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & mm1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & mm3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply ld_cur in Y3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y4 as [(u5 & ke5 & mm5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y5 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y6 as [(u7 & ke7 & mm7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.set_inv in Y7 as (vq & Evq & -> & -> & _).
    apply (ev_wkv _ _ _ b I4 1 _ _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hla) in Evq. subst vq.
    apply RA.assign_inv in Y8 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi : exists fi, le ! BS._field = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 3 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (lv_rawvp _ _ _ _ _ _ _ _ Hfi Hlv2) as (o0 & Ho0 & -> & ->).
    do 2 rewrite PTree.gso in Ho0 by (vm_compute; discriminate).
    rewrite PTree.gss in Ho0. injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (z1 & Ez1 & Cz). apply RA.ev_cast in Ez1 as (z2 & Ez2 & Cz2).
    apply RA.ev_temp in Ez2. rewrite PTree.gss in Ez2. injection Ez2 as <-.
    cbn in Cz2. injection Cz2 as <-. cbn in Cz. injection Cz as <-. cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ (tptr tvoid) _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in Y2 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 mm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk mm1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. change (size_chunk Mint32) with 4. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. change (size_chunk Mint32) with 4. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists ta, oa, bt, mm1. split; [ exact Ha | split; [ exact Hbt | split; [ exact Hs1 | exact U2 ] ] ].
  Qed.

  (* ---- LOAD_COLLISION_DATA (0x2A): o->collisionData = segmented_to_virtual(w1)
     (@536; the identity, TRUST 2.2) ---- *)
  Lemma hd_load_collision_data : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 42 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_load_collision_data) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists ta oa bt m1, nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof ta oa)
         /\ Genv.find_symbol G ta = Some bt
         /\ Mem.store Mint32 m pool (oc + 536) (Vptr bt oa) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_lcd st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (la_w st w Hst Hw (or_intror Ho)) as (ta & oa & Ha).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Ha) as (va & Hla & Hia).
    cbn in Hia. destruct Hia as (bt & Hbt & ->).
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Ha; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4 * 1) in Hla by lia.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_load_collision_data bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_load_collision_data] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.seq_inv in X3 as [(a1 & ae1 & am1 & a2 & A1 & A2) | (A1 & Xn)]; [ | kill_sq A1 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ A1 Hcm) as (-> & -> & _).
    apply RA.seq_inv in A2 as [(a3 & ae3 & am3 & a4 & A3 & A4) | (A3 & Xn)]; [ | kill_sq A3 Xn ].
    apply RA.set_inv in A3 as (vq & Evq & -> & -> & _).
    apply (ev_wkv _ _ _ b I4 1 _ _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hla) in Evq. subst vq.
    destruct (s2v_call _ _ _ _ _ _ _ _ bt oa A4 (PTree.gss _ _ _)) as (-> & -> & _).
    apply RA.set_inv in X4 as (vc & Evc & -> & -> & _).
    apply RA.ev_temp in Evc. rewrite PTree.gss in Evc. injection Evc as <-.
    apply RA.seq_inv in X2 as [(u1 & ke1 & mm1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & mm3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply ld_cur in Y3 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in Y4 as (b2 & o2 & bf2 & v2 & v3 & Hlx & Ev & Hcast & Has & -> & _).
    destruct (RA.lv_fld G empty_env _ _ _ _ _ _ _ _ _ _ fo_coll Hlx) as (o1 & Ho1 & -> & ->).
    rewrite PTree.gss in Ho1. injection Ho1 as <- <-.
    apply RA.ev_temp in Ev. rewrite PTree.gso in Ev by (vm_compute; discriminate).
    rewrite PTree.gss in Ev. injection Ev as <-.
    cbn in Hcast. injection Hcast as <-.
    pose proof (RA.store_by_value _ (tptr tvoid) _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    rewrite uadd in Hs1 by (try rewrite maxu; lia).
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in Y2 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 mm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk mm1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. left. change (size_chunk Mint32) with 4. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. left. change (size_chunk Mint32) with 4. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists ta, oa, bt, mm1. split; [ exact Ha | split; [ exact Hbt | split; [ exact Hs1 | exact U2 ] ] ].
  Qed.

  (* ---- SCALE (0x32): cur_obj_scale((s16)(w & 0xFFFF) / 100.0f), i.e. the
     current slot's header.gfx.scale[0..2] (@44/48/52) ---- *)
  Lemma hd_scale : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 50 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_scale) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists m1 m2 m3,
           Mem.store Mfloat32 m pool (oc + 44 + 4 * 0) (Vsingle (pdiv (s16_of w))) = Some m1
         /\ Mem.store Mfloat32 m1 pool (oc + 44 + 4 * 1) (Vsingle (pdiv (s16_of w))) = Some m2
         /\ Mem.store Mfloat32 m2 pool (oc + 44 + 4 * 2) (Vsingle (pdiv (s16_of w))) = Some m3
         /\ Mem.unchanged_on Pfr m3 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_scale st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_scale bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_scale] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* unusedField *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & _ & -> & -> & _).
    (* percent = (s16)( *cmd & 0xFFFF) *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1). apply RA.ev_cast in Ey1 as (y2 & Ey2 & D2).
    apply RA.ev_binop in Ey2 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D2. injection D2 as <-. cbn in D1. injection D1 as <-.
    (* cur_obj_scale(percent / 100.0f) *)
    apply RA.seq_inv in Y2 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.call_inv in Y7 as (tya & tyr & cc & vfn & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcl2 & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun G empty_env m _ _ (Tfunction [tfloat] tvoid cc_default) vfn
                (PTree.gempty _ _) eq_refl Evf) as (bfn & Hsf & ->).
    rewrite (fun_oh _ _ dm_scale bfn fd Hsf Hff) in Hcl2.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
    apply RA.ev_binop in Ev1 as (d1 & d2 & Ed1 & Ed2 & Ediv).
    apply RA.ev_temp in Ed1. rewrite PTree.gss in Ed1. injection Ed1 as <-.
    apply RA.ev_single in Ed2. subst d2.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in Ediv. injection Ediv as <-.
    cbn -[Float32.div Float32.of_int Float32.of_bits] in C1. injection C1 as <-.
    apply fcall_inv in Hcl2 as (lf1 & lf2 & outf & Hbf & Xf & _); [ | reflexivity ].
    cbn [fn_params OH.f_cur_obj_scale bind_parameter_temps] in Hbf. injection Hbf as <-.
    cbn [fn_body OH.f_cur_obj_scale] in Xf.
    apply RA.seq_inv in Xf as [(g1 & ge1 & gm1 & g2 & Xa & Xb) | (Xa & Xn)]; [ | kill_sq Xa Xn ].
    apply RA.seq_inv in Xa as [(c10 & ce10 & cm10 & c20 & W0 & R0) | (W0 & Xn)]; [ | kill_sq W0 Xn ].
    apply ld_cur in W0 as (-> & -> & _); [ | exact Hc ].
    apply RA.assign_inv in R0 as (b20 & o20 & bf20 & v20 & v30 & Hlx0 & Ev0 & Hcast0 & Has0 & -> & _).
    destruct (lv_scale _ _ _ 0 _ _ _ ltac:(lia) (PTree.gss _ _ _) Hlx0) as (-> & Eo0 & ->).
    apply RA.ev_temp in Ev0. rewrite PTree.gso in Ev0 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev0. injection Ev0 as <-.
    cbn in Hcast0. injection Hcast0 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has0) as Hs0.
    rewrite Eo0 in Hs0.
    pose proof (cur_store _ _ _ _ _ Hs0 Hc) as Hc0.
    apply RA.seq_inv in Xb as [(g3 & ge3 & gm3 & g4 & Xc & Xd) | (Xc & Xn)]; [ | kill_sq Xc Xn ].
    apply RA.seq_inv in Xc as [(c11 & ce11 & cm11 & c21 & W1 & R1) | (W1 & Xn)]; [ | kill_sq W1 Xn ].
    apply ld_cur in W1 as (-> & -> & _); [ | exact Hc0 ].
    apply RA.assign_inv in R1 as (b21 & o21 & bf21 & v21 & v31 & Hlx1 & Ev1 & Hcast1 & Has1 & -> & _).
    destruct (lv_scale _ _ _ 1 _ _ _ ltac:(lia) (PTree.gss _ _ _) Hlx1) as (-> & Eo1 & ->).
    apply RA.ev_temp in Ev1. do 1 rewrite PTree.gso in Ev1 by (vm_compute; discriminate). rewrite PTree.gso in Ev1 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev1. injection Ev1 as <-.
    cbn in Hcast1. injection Hcast1 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has1) as Hs1.
    rewrite Eo1 in Hs1.
    pose proof (cur_store _ _ _ _ _ Hs1 Hc0) as Hc1.
    apply RA.seq_inv in Xd as [(c12 & ce12 & cm12 & c22 & W2 & R2) | (W2 & Xn)]; [ | kill_sq W2 Xn ].
    apply ld_cur in W2 as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in R2 as (b22 & o22 & bf22 & v22 & v32 & Hlx2 & Ev2 & Hcast2 & Has2 & -> & _).
    destruct (lv_scale _ _ _ 2 _ _ _ ltac:(lia) (PTree.gss _ _ _) Hlx2) as (-> & Eo2 & ->).
    apply RA.ev_temp in Ev2. do 2 rewrite PTree.gso in Ev2 by (vm_compute; discriminate). rewrite PTree.gso in Ev2 by (vm_compute; discriminate).
    rewrite PTree.gss in Ev2. injection Ev2 as <-.
    cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has2) as Hs2.
    rewrite Eo2 in Hs2.
    pose proof (cur_store _ _ _ _ _ Hs2 Hc1) as Hc2.
    assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; exact Hbp); rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by (left; exact Hbp); exact Hcm).
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    (* the scale cells lie below the VM cells *)
    assert (HS1 : Vstk n7 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia). exact Hsi.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia). exact (Hk j f Hj). }
    assert (Ev : s16_of w = Int.sign_ext 16 (Int.and n (Int.repr 65535)))
      by (unfold s16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs9) ].
    - split; [ exact (Hc9 Hc2) | split; [ reflexivity | ] ].
      exists gm1, gm3, n7. unfold pdiv. rewrite Ev.
      rewrite Int.sign_ext_idem in Hs0, Hs1, Hs2 by lia.
      split; [ exact Hs0 | split; [ exact Hs1 | split; [ exact Hs2 | exact U9 ] ] ].
  Qed.

  (* ---- BEGIN (0x00): three cur_obj_has_behavior tests (bhvHauntedChair,
     bhvMadPiano -> bhv_init_room; bhvMessagePanel -> field 67 := 150.0f);
     cmd += 1.  When the current slot's behavior is none of the three (a
     valid pointer into another block), no store besides the cursor ---- *)
  Lemma hd_begin : forall m st w t m' vr bb ob,
    In st vm_tab -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 0 ->
    Mem.load Mint32 m pool (oc + 524) = Some (Vptr bb ob) ->
    Mem.valid_pointer m bb (Ptrofs.unsigned ob) = true ->
    (forall id, In id [BS._bhvHauntedChair; BS._bhvMadPiano; BS._bhvMessagePanel] ->
       exists bs, Genv.find_symbol G id = Some bs /\ bs <> bb /\ Mem.valid_pointer m bs 0 = true) ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_begin) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros m st w t m' vr bb ob Hst HV Hc Hw Ho Hbh Hvb Hsy H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_begin st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI. try rewrite <- EI in Hcm.
    destruct (Hsy BS._bhvHauntedChair ltac:(left; reflexivity)) as (bs1 & Hs1 & Hn1 & Hv1).
    destruct (Hsy BS._bhvMadPiano ltac:(right; left; reflexivity)) as (bs2 & Hs2 & Hn2 & Hv2).
    destruct (Hsy BS._bhvMessagePanel ltac:(right; right; left; reflexivity)) as (bs3 & Hs3 & Hn3 & Hv3).
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_begin bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_begin] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(a11 & ae11 & am11 & a21 & A1 & A2) | (A1 & Xn)]; [ | kill_sq A1 Xn ].
    destruct (cohb_call _ _ _ _ _ _ _ _ _ _ _ Hc Hs1 Hbh (fun E => Hn1 (eq_sym E)) Hvb Hv1 A1) as (-> & -> & _).
    apply RA.if_inv in A2 as (vc1 & bq1 & Ec1 & Bq1 & Xi1).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    cbn in Bq1. injection Bq1 as <-. cbv iota in Xi1.
    apply RA.skip_inv in Xi1 as (-> & -> & _).
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.seq_inv in X3 as [(a12 & ae12 & am12 & a22 & A3 & A4) | (A3 & Xn)]; [ | kill_sq A3 Xn ].
    destruct (cohb_call _ _ _ _ _ _ _ _ _ _ _ Hc Hs2 Hbh (fun E => Hn2 (eq_sym E)) Hvb Hv2 A3) as (-> & -> & _).
    apply RA.if_inv in A4 as (vc2 & bq2 & Ec2 & Bq2 & Xi2).
    apply RA.ev_temp in Ec2. rewrite PTree.gss in Ec2. injection Ec2 as <-.
    cbn in Bq2. injection Bq2 as <-. cbv iota in Xi2.
    apply RA.skip_inv in Xi2 as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.seq_inv in X5 as [(a13 & ae13 & am13 & a23 & A5 & A6) | (A5 & Xn)]; [ | kill_sq A5 Xn ].
    destruct (cohb_call _ _ _ _ _ _ _ _ _ _ _ Hc Hs3 Hbh (fun E => Hn3 (eq_sym E)) Hvb Hv3 A5) as (-> & -> & _).
    apply RA.if_inv in A6 as (vc3 & bq3 & Ec3 & Bq3 & Xi3).
    apply RA.ev_temp in Ec3. rewrite PTree.gss in Ec3. injection Ec3 as <-.
    cbn in Bq3. injection Bq3 as <-. cbv iota in Xi3.
    apply RA.skip_inv in Xi3 as (-> & -> & _).
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in X6 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Hcm) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsb) | exact (Vstk_bc _ _ _ _ HS Hs9) ].
    - split; [ exact (Hc9 Hc) | split; [ reflexivity | exact U9 ] ].
  Qed.


  (* ---- SUM_FLOAT (0x1F): o->rawData.asF32[byte2 w] =
          o->rawData.asF32[byte3 w] + o->rawData.asF32[byte4 w] ---- *)
  Lemma hd_sum_float : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 31 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_sum_float) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists a1 a2 m1, Mem.load Mfloat32 m pool (oc + 136 + 4 * byte3 w) = Some (Vsingle a1)
         /\ Mem.load Mfloat32 m pool (oc + 136 + 4 * byte4 w) = Some (Vsingle a2)
         /\ Mem.store Mfloat32 m pool (oc + 136 + 4 * byte2 w) (Vsingle (Float32.add a1 a2)) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_sum_float st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    destruct (sum_lt80 st w Hst Hw Ho) as (H2 & H3 & H4).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_sum_float bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_sum_float] in X.
    (* fieldDst = (w >> 16) & 0xFF *)
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1).
    apply RA.ev_binop in Ex1 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C1. injection C1 as <-.
    (* fieldSrc1 = (w >> 8) & 0xFF *)
    apply RA.seq_inv in X2 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.seq_inv in X7 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Xn)]; [ | kill_sq X9 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X9 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X10 as [(t11 & le11 & m11 & t12 & X11 & X12) | (X11 & Xn)]; [ | kill_sq X11 Xn ].
    apply RA.set_inv in X11 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X12 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1).
    apply RA.ev_binop in Ex1 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C1. injection C1 as <-.
    (* fieldSrc2 = w & 0xFF *)
    apply RA.seq_inv in X8 as [(t13 & le13 & m13 & t14 & X13 & X14) | (X13 & Xn)]; [ | kill_sq X13 Xn ].
    apply RA.seq_inv in X13 as [(t15 & le15 & m15 & t16 & X15 & X16) | (X15 & Xn)]; [ | kill_sq X15 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X15 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X16 as [(t17 & le17 & m17 & t18 & X17 & X18) | (X17 & Xn)]; [ | kill_sq X17 Xn ].
    apply RA.set_inv in X17 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X18 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1).
    apply RA.ev_binop in Ex1 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_temp in Ea1. rewrite PTree.gss in Ea1. injection Ea1 as <-.
    apply RA.ev_const in Ea2. subst a2. cbn in Eand. injection Eand as <-.
    cbn in C1. injection C1 as <-.
    (* t4 = o->asF32[src1]; t6 = o->asF32[src2]; o->asF32[dst] = t4 + t6 *)
    apply RA.seq_inv in X14 as [(u1 & ke1 & n1 & u2 & D1 & E1) | (D1 & Xn)]; [ | kill_sq D1 Xn ].
    apply RA.seq_inv in D1 as [(u3 & ke3 & n3 & u4 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply ld_cur in Y1 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y2 as [(u5 & ke5 & n5 & u6 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply ld_cur in Y3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y4 as [(u7 & ke7 & n7 & u8 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (va & Eva & -> & -> & _).
    match type of Eva with eval_expr _ _ ?le _ _ _ =>
      assert (Hf1 : exists fi, le ! BS._fieldSrc1 = Some (Vint fi) /\ Int.unsigned fi = byte3 w)
        by (eexists; split;
            [ do 5 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply b3_eq ]) end.
    destruct Hf1 as (f1 & Hf1 & Ef1).
    destruct (ev_raw_rdfu _ _ _ _ _ _ Hf1 Eva) as (bo & oo & Hpo & Hld1).
    rewrite PTree.gss in Hpo. injection Hpo as <- <-.
    cbn [Mem.loadv] in Hld1. unfold Ptrofs.of_intu, Ptrofs.of_int in Hld1. rewrite Ef1 in Hld1. rewrite raw_addr in Hld1 by lia.
    apply RA.seq_inv in Y6 as [(u9 & ke9 & n9 & u10 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply ld_cur in Y7 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    apply RA.set_inv in Y9 as (vb & Evb & -> & -> & _).
    match type of Evb with eval_expr _ _ ?le _ _ _ =>
      assert (Hf2 : exists fi, le ! BS._fieldSrc2 = Some (Vint fi) /\ Int.unsigned fi = byte4 w)
        by (eexists; split;
            [ do 4 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply b4_eq ]) end.
    destruct Hf2 as (f2 & Hf2 & Ef2).
    destruct (ev_raw_rdfu _ _ _ _ _ _ Hf2 Evb) as (bo & oo & Hpo & Hld2).
    rewrite PTree.gss in Hpo. injection Hpo as <- <-.
    cbn [Mem.loadv] in Hld2. unfold Ptrofs.of_intu, Ptrofs.of_int in Hld2. rewrite Ef2 in Hld2. rewrite raw_addr in Hld2 by lia.
    apply RA.assign_inv in Y10 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hf0 : exists fi, le ! BS._fieldDst = Some (Vint fi) /\ Int.unsigned fi = byte2 w)
        by (eexists; split;
            [ do 11 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply b2_eq ]) end.
    destruct Hf0 as (f0 & Hf0 & Ef0).
    destruct (lv_rawfu _ _ _ _ _ _ _ _ Hf0 Hlv2) as (o0 & Ho0 & -> & ->).
    do 4 rewrite PTree.gso in Ho0 by (vm_compute; discriminate). rewrite PTree.gss in Ho0.
    injection Ho0 as <- <-.
    apply RA.ev_cast in Ev2 as (z & Ez & Cz).
    apply RA.ev_binop in Ez as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_temp in Ee1. do 2 rewrite PTree.gso in Ee1 by (vm_compute; discriminate).
    rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply RA.ev_temp in Ee2. rewrite PTree.gss in Ee2. injection Ee2 as <-.
    destruct va as [| | | | a1 | ]; cbn -[Float32.add] in Eadd'; try discriminate Eadd'.
    destruct vb as [| | | | a2 | ]; cbn -[Float32.add] in Eadd'; try discriminate Eadd'.
    injection Eadd' as <-. cbn -[Float32.add] in Cz. injection Cz as <-.
    cbn -[Float32.add] in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_intu, Ptrofs.of_int in Hs1. rewrite Ef0 in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in E1 as [(u13 & ke13 & n13 & u14 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u15 & ke15 & n15 & u16 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 n1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk n1 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists a1, a2, n1. split; [ exact Hld1 | split; [ exact Hld2 | split; [ exact Hs1 | exact U2 ] ] ].
  Qed.

  (* ---- OR_INT (0x11): o->rawData.asS32[byte2 w] |= ((s16)(w & 0xFFFF)) & 0xFFFF ---- *)
  Definition u16_of (w : Z) : int :=
    Int.and (Int.sign_ext 16 (Int.and (Int.repr w) (Int.repr 65535))) (Int.repr 65535).
  Lemma hd_or_int : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 17 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_or_int) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists old m1, Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old)
         /\ Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (Int.or old (u16_of w))) = Some m1
         /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_or_int st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    assert (Hf80 : 0 <= byte2 w < 80)
      by (apply (fld_lt80 st w Hst Hw); rewrite Ho; right; right; right; right; left; reflexivity).
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_or_int bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_or_int] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* field *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x1 & Ex1 & C1). apply RA.ev_cast in Ex1 as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-.
    cbn in C2. injection C2 as <-. cbn in C1. injection C1 as <-.
    (* value *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.set_inv in Y5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in Y6 as (vv & Evv & -> & -> & _).
    apply RA.ev_cast in Evv as (y1 & Ey1 & D1).
    apply RA.ev_binop in Ey1 as (c1 & c2 & Ec1 & Ec2 & Eand2).
    apply RA.ev_temp in Ec1. rewrite PTree.gss in Ec1. injection Ec1 as <-.
    apply RA.ev_const in Ec2. subst c2.
    cbn in Eand2. injection Eand2 as <-. cbn in D1. injection D1 as <-.
    (* value &= 0xFFFF *)
    apply RA.seq_inv in Y2 as [(w1 & kw1 & nw1 & w2 & Yv & Z2b) | (Yv & Xn)]; [ | kill_sq Yv Xn ].
    apply RA.set_inv in Yv as (vv2 & Evv2 & -> & -> & _).
    apply RA.ev_binop in Evv2 as (g1 & g2 & Eg1 & Eg2 & Eand3).
    apply RA.ev_temp in Eg1. rewrite PTree.gss in Eg1. injection Eg1 as <-.
    apply RA.ev_const in Eg2. subst g2. cbn in Eand3. injection Eand3 as <-.
    rename Z2b into Y2.
    (* t4 = o->rawData.asS32[field]; o->rawData.asS32[field] = t4 + value *)
    apply RA.seq_inv in Y2 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply RA.seq_inv in Y7 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)]; [ | kill_sq Y9 Xn ].
    apply ld_cur in Y9 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y10 as [(u15 & ke15 & n15 & u16 & Y15 & Y16) | (Y15 & Xn)]; [ | kill_sq Y15 Xn ].
    apply ld_cur in Y15 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in Y16 as [(u17 & ke17 & n17 & u18 & Y17 & Y18) | (Y17 & Xn)]; [ | kill_sq Y17 Xn ].
    apply RA.set_inv in Y17 as (vo & Evo & -> & -> & _).
    match type of Evo with eval_expr _ _ ?le _ _ _ =>
      assert (Hfi : exists fi, le ! BS._objectOffset = Some (Vint fi) /\ Int.signed fi = byte2 w)
        by (eexists; split;
            [ do 6 rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss
            | rewrite Ewn; apply fld_eq ]) end.
    destruct Hfi as (fi & Hfi & Efi).
    destruct (ev_raw_rd _ _ _ _ _ _ Hfi Evo) as (bo & oo & Hpo & Hld).
    rewrite PTree.gss in Hpo. injection Hpo as <- <-.
    cbn [Mem.loadv] in Hld. unfold Ptrofs.of_ints in Hld. rewrite Efi in Hld. rewrite raw_addr in Hld by lia.
    apply RA.assign_inv in Y18 as (b2 & o2 & bf2 & v2 & v3 & Hlv2 & Ev2 & Hcast2 & Has & -> & _).
    match type of Hlv2 with eval_lvalue _ _ ?le _ _ _ _ _ =>
      assert (Hfi2 : le ! BS._objectOffset = Some (Vint fi))
        by (rewrite PTree.gso by (vm_compute; discriminate); exact Hfi) end.
    destruct (lv_raw _ _ _ _ _ _ _ _ Hfi2 Hlv2) as (o0 & Ho0 & -> & ->).
    rewrite PTree.gso, PTree.gso, PTree.gss in Ho0 by (vm_compute; discriminate). injection Ho0 as <- <-.
    apply RA.ev_binop in Ev2 as (e1 & e2 & Ee1 & Ee2 & Eadd').
    apply RA.ev_temp in Ee1. rewrite PTree.gss in Ee1. injection Ee1 as <-.
    apply RA.ev_cast in Ee2 as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1.
    rewrite PTree.gso, PTree.gso, PTree.gso, PTree.gss in Ez1 by (vm_compute; discriminate).
    injection Ez1 as <-.
    cbn in Cz. injection Cz as <-.
    destruct vo as [| old | | | | ]; cbn in Eadd'; try discriminate Eadd'.
    injection Eadd' as <-. cbn in Hcast2. injection Hcast2 as <-.
    pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs1.
    unfold Ptrofs.of_ints in Hs1. rewrite Efi in Hs1. rewrite raw_addr in Hs1 by lia.
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in Y8 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Lc : Mem.load Mint32 n7 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; exact Hbp); exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. norm_off Hs2 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk n7 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact Hsi | ].
        right. right. cbn [size_chunk]. unfold OW.O_SIDX. lia.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1); [ exact (Hk j f Hj) | ].
        right. right. cbn [size_chunk]. unfold OW.O_STK. lia. }
    assert (Ev : u16_of w = Int.and (Int.sign_ext 16 (Int.and n (Int.repr 65535))) (Int.repr 65535))
      by (unfold u16_of; rewrite Ewn, Int.repr_unsigned; reflexivity).
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 (cur_store _ _ _ _ _ Hs1 Hc)) | split; [ reflexivity | ] ].
      exists old, n7. split; [ exact Hld | split; [ | exact U2 ] ]. rewrite Ev.
      exact Hs1.
  Qed.

  (* ---- the control commands, together ---- *)
  Definition ctl_handler (op : Z) (f : function) (rc : Z) : Prop :=
       op = 2 /\ f = BS.f_bhv_cmd_call /\ rc = 0
    \/ op = 3 /\ f = BS.f_bhv_cmd_return /\ rc = 0
    \/ op = 4 /\ f = BS.f_bhv_cmd_goto /\ rc = 0
    \/ op = 5 /\ f = BS.f_bhv_cmd_begin_repeat /\ rc = 0
    \/ op = 6 /\ f = BS.f_bhv_cmd_end_repeat /\ rc = 1
    \/ op = 7 /\ f = BS.f_bhv_cmd_end_repeat_continue /\ rc = 0
    \/ op = 8 /\ f = BS.f_bhv_cmd_begin_loop /\ rc = 0
    \/ op = 9 /\ f = BS.f_bhv_cmd_end_loop /\ rc = 1
    \/ op = 10 /\ f = BS.f_bhv_cmd_break /\ rc = 1
    \/ op = 11 /\ f = BS.f_bhv_cmd_break_unused /\ rc = 1
    \/ op = 1 /\ f = BS.f_bhv_cmd_delay /\ rc = 1.

  (* B3 (iii), the control layer: at a reachable VM state whose command
     cells hold it, the generated handler of a control opcode moves the
     cells to one of the VM's successors, returns the handler's code, and
     writes nothing but gCurBhvCommand and the slot's stack cells *)
  Theorem ctl_step : forall op f rc m st w t m' vr, ctl_handler op f rc ->
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = op ->
    eval_funcall function_entry2 G m (Internal f) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m'
      /\ vr = Vint (Int.repr rc) /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros op f rc m st w t m' vr Hh Hst Hscr HV Hc Hw Ho H.
    destruct Hh as [(-> & -> & ->) | [(-> & -> & ->) | [(-> & -> & ->) | [(-> & -> & ->) |
                   [(-> & -> & ->) | [(-> & -> & ->) | [(-> & -> & ->) | [(-> & -> & ->) |
                   [(-> & -> & ->) | [(-> & -> & ->) | (-> & -> & ->)]]]]]]]]]].
    - exact (hd_call _ _ _ _ _ _ Hst Hscr HV Hc Hw Ho H).
    - exact (hd_return _ _ _ _ _ _ Hst HV Hc Hw Ho H).
    - exact (hd_goto _ _ _ _ _ _ Hst Hscr HV Hc Hw Ho H).
    - exact (hd_begin_repeat _ _ _ _ _ _ Hst HV Hc Hw Ho H).
    - exact (hd_end_repeat _ _ _ _ _ _ _ _ (or_introl (conj eq_refl (conj eq_refl Ho))) Hst HV Hc Hw H).
    - exact (hd_end_repeat _ _ _ _ _ _ _ _ (or_intror (conj eq_refl (conj eq_refl Ho))) Hst HV Hc Hw H).
    - exact (hd_begin_loop _ _ _ _ _ _ Hst HV Hc Hw Ho H).
    - exact (hd_end_loop _ _ _ _ _ _ Hst HV Hc Hw Ho H).
    - exact (hd_break _ _ _ _ _ _ _ (or_introl eq_refl) (or_introl Ho) Hst HV Hc Hw H).
    - exact (hd_break _ _ _ _ _ _ _ (or_intror eq_refl) (or_intror Ho) Hst HV Hc Hw H).
    - exact (hd_delay _ _ _ _ _ _ Hst HV Hc Hw Ho H).
  Qed.

  (* ---- the dispatch loop ---- *)
  Variable INV : mem -> Prop.
  (* the slot's script family (2026-11-07): a set of VM states closed under
     succs.  The rows' keeps may assume the executing state is in it -- the
     script tie: a field store is the slot's OWN script's store, not any
     reachable script's (sit_keep without it is false: a pole script's
     INTERACT_POLE stored into a non-pole slot breaks kind_ok) *)
  Variable Qs : vst -> Prop.
  Hypothesis Hqs_cl : forall st l st', In st vm_tab -> Qs st -> succs st = Some l -> In st' l -> Qs st'.

  (* ONE COMMAND: the handler BehaviorCmdTable names for opcode op, called
     at a reachable state whose cells hold it, moves the cells to a VM
     successor, keeps INV, and returns BHV_PROC_CONTINUE (0) or _BREAK (1) *)
  Definition cmd_row_op (op : Z) : Prop :=
    forall m st w id hb fd t m' vr, In st vm_tab -> Qs st -> V m st -> INV m ->
      word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = op ->
      nth_error ObjCensus.cmd_handlers (Z.to_nat op) = Some id ->
      Genv.find_symbol G id = Some hb -> Genv.find_funct G (Vptr hb Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 G m fd [] t m' vr ->
      exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ INV m'
        /\ (vr = Vint (Int.repr 0) \/ vr = Vint (Int.repr 1)).

  Hypothesis Hinv : forall m, INV m -> scr_ok G m /\ OW.cmdtab_ok G m.

  Lemma disp_step : forall le m t le1 m1 out1 st, (forall op, cmd_row_op op) ->
    exec_stmt function_entry2 G empty_env le m DISP t le1 m1 out1 ->
    In st vm_tab -> Qs st -> V m st -> INV m ->
    out1 = Out_normal /\ exists st1 vr, In st1 vm_tab /\ Qs st1 /\ V m1 st1 /\ INV m1
      /\ le1 ! BS._bhvProcResult = Some vr /\ (vr = Vint (Int.repr 0) \/ vr = Vint (Int.repr 1)).
  Proof.
    intros le m t le1 m1 out1 st Hrow H Hst HQs0 HV HI.
    destruct (Hinv m HI) as (Hscr & (btab & Hbt & Htab)).
    destruct (st_facts st Hst) as (Hlen & _ & _ & l & Hl & Hcl).
    pose proof HV as HV0. destruct HV as ((b & Hsb & Hcm) & Hsi & Hk).
    unfold DISP in H.
    apply RA.seq_inv in H as [(t1 & le2 & m2 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    (* the command word *)
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in Evw as (b1 & o1 & Ea & Hlw).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    apply RA.ev_temp in Ea. rewrite PTree.gss in Ea. injection Ea as <- <-.
    destruct (succs_word _ _ Hl) as (w & Hw). destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    cbn [Mem.loadv] in Hlw. rewrite Ptrofs.unsigned_repr in Hlw by (rewrite maxu; lia). rewrite <- EI in Hlv.
    rewrite Hlv in Hlw. injection Hlw as <-.
    (* the handler pointer *)
    apply RA.set_inv in X6 as (vp & Evp & -> & -> & _).
    apply (ev_deref _ _ _ _ _ fpt Mint32 _ eq_refl) in Evp as (b2 & o2 & Ea & Hlp).
    apply RA.ev_binop in Ea as (p1 & p2 & Ep1 & Ep2 & Eadd).
    destruct (ev_garr _ _ _ _ _ _ _ _ (PTree.gempty _ _) Ep1) as (bt & Hbt' & ->).
    rewrite Hbt in Hbt'. injection Hbt' as <-.
    apply RA.ev_binop in Ep2 as (q1 & q2 & Eq1 & Eq2 & Eshr).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eshr, Eadd.
    rewrite shr_ui in Eshr. injection Eshr as <-.
    rewrite add_au in Eadd. injection Eadd as <- <-.
    pose proof (op_range st w Hst Hw) as Hop.
    assert (Eop : Int.unsigned (Int.shru n (Int.repr 24)) = Z.shiftr w 24) by (rewrite shru24, Ewn; reflexivity).
    cbn [Mem.loadv] in Hlp. rewrite tab_off in Hlp by lia. rewrite Eop in Hlp.
    destruct (nth_error ObjCensus.cmd_handlers (Z.to_nat (Z.shiftr w 24))) as [id|] eqn:Eid;
      [ | apply nth_error_None in Eid; rewrite cmd_handlers_len in Eid; lia ].
    destruct (Htab _ _ Eid) as (hb & Hhb & Hlt). rewrite Z2Nat.id in Hlt by lia.
    rewrite Hlt in Hlp. injection Hlp as <-.
    (* the call *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.call_inv in Y1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hx & -> & _).
    apply RA.ev_temp in Evf. rewrite PTree.gss in Evf. injection Evf as <-.
    inversion Eal; subst.
    destruct (Hrow _ _ _ _ _ _ _ _ _ _ Hst HQs0 HV0 HI Hw eq_refl Eid Hhb Hff Hx)
      as (l' & st1 & Hl' & Hin & HV1 & HI1 & Hvr).
    apply RA.set_inv in Y2 as (vr & Evr & -> & -> & ->).
    apply RA.ev_temp in Evr. cbn [set_opttemp] in Evr. rewrite PTree.gss in Evr.
    injection Evr as <-.
    split; [ reflexivity | ].
    exists st1, vres. split; [ exact (vm_succ_in st l' st1 Hst Hl' Hin) | ].
    split; [ exact (Hqs_cl st l' st1 Hst HQs0 Hl' Hin) | ].
    split; [ exact HV1 | split; [ exact HI1 | split; [ apply PTree.gss | exact Hvr ] ] ].
  Qed.

  Lemma dchk : forall le m t le' m' out vr, exec_stmt function_entry2 G empty_env le m DCHK t le' m' out ->
    le ! BS._bhvProcResult = Some vr -> (vr = Vint (Int.repr 0) \/ vr = Vint (Int.repr 1)) ->
    m' = m /\ (vr = Vint (Int.repr 0) /\ out = Out_normal \/ vr = Vint (Int.repr 1) /\ out = Out_break).
  Proof.
    intros le m t le' m' out vr H Hv Hvr. unfold DCHK in H.
    apply RA.if_inv in H as (c & bb & Ec & Hb & H).
    apply RA.ev_binop in Ec as (c1 & c2 & E1 & E2 & E3).
    apply RA.ev_temp in E1. rewrite Hv in E1. injection E1 as <-. apply RA.ev_const in E2. subst c2.
    destruct Hvr as [-> | ->]; cbn in E3; injection E3 as <-; cbn in Hb; injection Hb as <-.
    - apply RA.skip_inv in H as (-> & _ & ->). auto.
    - inv H. auto.
  Qed.

  (* THE DISPATCH LOOP: from a reachable state whose cells hold it, the loop
     ends at a reachable state whose cells hold it, keeping INV *)
  Theorem dloop : (forall op, cmd_row_op op) ->
    forall le m t le' m' out, exec_stmt function_entry2 G empty_env le m DLOOP t le' m' out ->
    forall st, In st vm_tab -> Qs st -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ Qs st' /\ V m' st' /\ INV m'.
  Proof.
    intros Hrow le m t le' m' out H.
    remember empty_env as e0 eqn:Ee. remember DLOOP as S eqn:ES.
    induction H; intros st0 Hst HQ HV HI; try discriminate ES; unfold DLOOP in ES; injection ES as E1 E2; subst.
    - destruct (disp_step _ _ _ _ _ _ _ Hrow H Hst HQ HV HI) as (-> & _). inv H0.
    - destruct (disp_step _ _ _ _ _ _ _ Hrow H Hst HQ HV HI) as (_ & st1 & vr & Hst1 & HQ1 & HV1 & HI1 & Hv & Hvr).
      destruct (dchk _ _ _ _ _ _ _ H1 Hv Hvr) as (-> & [(_ & ->) | (_ & ->)]); inv H2.
      split; [ reflexivity | exact (ex_intro _ st1 (conj Hst1 (conj HQ1 (conj HV1 HI1)))) ].
    - destruct (disp_step _ _ _ _ _ _ _ Hrow H Hst HQ HV HI) as (_ & st1 & vr & Hst1 & HQ1 & HV1 & HI1 & Hv & Hvr).
      destruct (dchk _ _ _ _ _ _ _ H1 Hv Hvr) as (-> & [(_ & _) | (_ & E)]); [ | discriminate E ].
      exact (IHexec_stmt3 eq_refl eq_refl st1 Hst1 HQ1 HV1 HI1).
  Qed.

  (* the control opcodes discharge their rows *)
  Hypothesis Hinv_cur : forall m, INV m -> cur m.
  Hypothesis Hinv_frame : forall m m', INV m -> Mem.unchanged_on Pfr m m' -> INV m'.

  Lemma ctl_id : forall op f rc, ctl_handler op f rc ->
    exists id, nth_error ObjCensus.cmd_handlers (Z.to_nat op) = Some id
      /\ (prog_defmap BS.prog) ! id = Some (Gfun (Internal f)).
  Proof.
    intros op f rc H. unfold ctl_handler in H.
    destruct H as [H|[H|[H|[H|[H|[H|[H|[H|[H|[H|H]]]]]]]]]];
      destruct H as (-> & -> & ->); eexists; split; vm_compute; reflexivity.
  Qed.

  Lemma ctl_rc : forall op f rc, ctl_handler op f rc -> rc = 0 \/ rc = 1.
  Proof.
    intros op f rc H. unfold ctl_handler in H.
    destruct H as [H|[H|[H|[H|[H|[H|[H|[H|[H|[H|H]]]]]]]]]];
      destruct H as (_ & _ & ->); auto.
  Qed.

  Lemma ctl_row1 : forall op f rc, ctl_handler op f rc -> cmd_row_op op.
  Proof.
    intros op f rc Hh m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    destruct (ctl_id _ _ _ Hh) as (id' & Hid' & Hdm). rewrite Hid' in Hid. injection Hid as <-.
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (ctl_step _ _ _ _ _ _ _ _ _ Hh Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & Hc' & -> & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ HI U).
    - destruct (ctl_rc _ _ _ Hh) as [-> | ->]; [ left | right ]; reflexivity.
  Qed.

  Definition ctl_ops : list Z := [1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11].

  Theorem ctl_rows : forall op, In op ctl_ops -> cmd_row_op op.
  Proof.
    intros op Hin. cbn [ctl_ops In] in Hin.
    destruct Hin as [<-|[<-|[<-|[<-|[<-|[<-|[<-|[<-|[<-|[<-|[<-|[]]]]]]]]]]]].
    all: eapply ctl_row1; unfold ctl_handler;
      repeat (first [ left; split; [ reflexivity | split; reflexivity ] | right ]);
      try (split; [ reflexivity | split; reflexivity ]).
  Qed.

  (* so the loop needs the rows of the other opcodes only *)
  Theorem dloop_ctl : (forall op, ~ In op ctl_ops -> cmd_row_op op) ->
    forall le m t le' m' out, exec_stmt function_entry2 G empty_env le m DLOOP t le' m' out ->
    forall st, In st vm_tab -> Qs st -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ Qs st' /\ V m' st' /\ INV m'.
  Proof.
    intros Hrest. apply dloop. intros op.
    destruct (in_dec Z.eq_dec op ctl_ops) as [Hin | Hn]; [ exact (ctl_rows op Hin) | exact (Hrest op Hn) ].
  Qed.

  (* a row for an opcode the reachable VM never executes holds vacuously *)
  Lemma unused_row : forall op, ~ In op used_ops -> cmd_row_op op.
  Proof.
    intros op Hu m st w id hb fd t m' vr Hst _ _ _ Hw Ho. exfalso. apply Hu.
    rewrite <- Ho. exact (op_used st w Hst Hw).
  Qed.

  (* so the loop's open premise is the 28 rows of the used non-control
     opcodes: begin, call_native, the field arithmetic (13-17, 19-21, 31),
     spawn_child, deactivate, drop_to_floor, billboard, set_hitbox,
     delay_var, load_animations, animate, load_collision_data,
     set_hitbox_with_offset, set_home, set_interact_type, set_obj_physics,
     scale, parent_bit_clear, animate_texture, disable_rendering,
     spawn_water_droplet *)
  Theorem dloop_used : (forall op, In op used_ops -> ~ In op ctl_ops -> cmd_row_op op) ->
    forall le m t le' m' out, exec_stmt function_entry2 G empty_env le m DLOOP t le' m' out ->
    forall st, In st vm_tab -> Qs st -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ Qs st' /\ V m' st' /\ INV m'.
  Proof.
    intros Hrest. apply dloop_ctl. intros op Hn.
    destruct (in_dec Z.eq_dec op used_ops) as [Hu | Hu]; [ exact (Hrest op Hu Hn) | exact (unused_row op Hu) ].
  Qed.

  (* ---- the non-control rows, one by one ---- *)
  Lemma row_delay_var : cmd_row_op 37.
  Proof.
    intros m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 37) = Some BS._bhv_cmd_delay_var)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_delay_var
                  = Some (Gfun (Internal BS.f_bhv_cmd_delay_var))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_delay_var _ _ _ _ _ _ Hst HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ HI U).
    - right. reflexivity.
  Qed.

  (* SET_INT's row, given that INV survives the handler's one field store.
     PINNED, not a phantom: only at reachable SET_INT words, only the
     script's field (byte2 w) and the script's value (s16_of w) -- obj_w
     reads some of these fields (the interact type, 42), so a premise over
     any field or any value would be false *)
  Definition set_keep : Prop := forall m st w m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 16 ->
    Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (s16_of w)) = Some m1 -> INV m1.

  Lemma row_set_int : set_keep -> cmd_row_op 16.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 16) = Some BS._bhv_cmd_set_int)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_int
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_int))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_int _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & m1 & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ HI Hst HQs Hw Ho Hs1) U).
    - left. reflexivity.
  Qed.

  (* SET_FLOAT's row, likewise (pinned: the script's field and value) *)
  Definition setf_keep : Prop := forall m st w m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 14 ->
    Mem.store Mfloat32 m pool (oc + 136 + 4 * byte2 w) (Vsingle (f32_of w)) = Some m1 -> INV m1.

  Lemma row_set_float : setf_keep -> cmd_row_op 14.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 14) = Some BS._bhv_cmd_set_float)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_float
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_float))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_float _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & m1 & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ HI Hst HQs Hw Ho Hs1) U).
    - left. reflexivity.
  Qed.

  (* set_keep at field 42, computed over its finite domain: the reachable
     SET_INTs to oInteractType are exactly bhvPoleGrabbing's
     SET_INT(oInteractType, INTERACT_POLE) (64) and bhvCannon's
     SET_INT(oInteractType, INTERACT_CANNON_BASE) (16384).  Both values are
     in wmotr_interact_types, so at field 42 set_keep is exactly kind_ok's
     two pinned cases: the pole (pole_obj_ok / pole_xz_ok) and the cannon
     (cannon_obj_ok / cannon_xz_ok) must hold for that slot *)
  (* PERF TRAP: stated inline (a named bool constant over vm_tab makes the
     kernel evaluate vm_tab lazily at the Qed of every user) *)
  Lemma chk42_ok :
    forallb (fun st => if (opc st =? 16) && (byte2 (w0 st) =? 42)
                       then (Pos.eqb (v_s st) SM64.Generated.behavior_data._bhvPoleGrabbing
                             && (Int.unsigned (s16_of (w0 st)) =? 64))
                         || (Pos.eqb (v_s st) SM64.Generated.behavior_data._bhvCannon
                             && (Int.unsigned (s16_of (w0 st)) =? 16384))
                       else true) vm_tab = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma set42 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
    Z.shiftr w 24 = 16 -> byte2 w = 42 ->
    v_s st = SM64.Generated.behavior_data._bhvPoleGrabbing /\ Int.unsigned (s16_of w) = 64
    \/ v_s st = SM64.Generated.behavior_data._bhvCannon /\ Int.unsigned (s16_of w) = 16384.
  Proof.
    intros st w Hst Hw Ho Hf. pose proof chk42_ok as A.
    rewrite forallb_forall in A. specialize (A st Hst). unfold opc, w0 in A. rewrite Hw in A.
    cbv beta iota in A. rewrite Ho, Hf in A. cbn [Z.eqb andb Pos.eqb] in A.
    apply orb_prop in A as [A | A]; apply andb_prop in A as [A1 A2];
      apply Pos.eqb_eq in A1; apply Z.eqb_eq in A2; [ left | right ]; split; assumption.
  Qed.

  (* ADD_INT's row: the store of old + (s16)w to the script's field, the old
     value read from that cell (pinned; ADD_INT's fields 16, 19, 26 are
     none that obj_w reads) *)
  Definition addi_keep : Prop := forall m st w old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 15 ->
    Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old) ->
    Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (Int.add old (s16_of w))) = Some m1 -> INV m1.

  Lemma row_add_int : addi_keep -> cmd_row_op 15.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 15) = Some BS._bhv_cmd_add_int)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_add_int
                  = Some (Gfun (Internal BS.f_bhv_cmd_add_int))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_add_int _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & old & m1 & Hld & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ HI Hst HQs Hw Ho Hld Hs1) U).
    - left. reflexivity.
  Qed.

  (* OR_INT's row (pinned; OR_INT's fields 1 (oFlags) and 3 are none that
     obj_w reads) *)
  Definition ori_keep : Prop := forall m st w old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 17 ->
    Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old) ->
    Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (Int.or old (u16_of w))) = Some m1 -> INV m1.

  Lemma row_or_int : ori_keep -> cmd_row_op 17.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 17) = Some BS._bhv_cmd_or_int)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_or_int
                  = Some (Gfun (Internal BS.f_bhv_cmd_or_int))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_or_int _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & old & m1 & Hld & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ HI Hst HQs Hw Ho Hld Hs1) U).
    - left. reflexivity.
  Qed.

  (* ADD_FLOAT's row.  Its one reachable field is 7 = oPosY, which obj_w
     DOES read (kind_ok's pole / cannon pins): the premise is pinned to
     the old value read from that cell plus the script's constant *)
  Definition addf_keep : Prop := forall m st w old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 13 ->
    Mem.load Mfloat32 m pool (oc + 136 + 4 * byte2 w) = Some (Vsingle old) ->
    Mem.store Mfloat32 m pool (oc + 136 + 4 * byte2 w) (Vsingle (Float32.add old (f32_of w))) = Some m1 ->
    INV m1.

  Lemma row_add_float : addf_keep -> cmd_row_op 13.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 13) = Some BS._bhv_cmd_add_float)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_add_float
                  = Some (Gfun (Internal BS.f_bhv_cmd_add_float))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_add_float _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & old & m1 & Hld & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ HI Hst HQs Hw Ho Hld Hs1) U).
    - left. reflexivity.
  Qed.

  (* SUM_FLOAT's row.  Its reachable destination fields are 6 / 7 / 8 =
     oPosX / oPosY / oPosZ, which obj_w DOES read: the premise is pinned
     to the one store of the sum of the two source cells read at m *)
  Definition sumf_keep : Prop := forall m st w a1 a2 m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 31 ->
    Mem.load Mfloat32 m pool (oc + 136 + 4 * byte3 w) = Some (Vsingle a1) ->
    Mem.load Mfloat32 m pool (oc + 136 + 4 * byte4 w) = Some (Vsingle a2) ->
    Mem.store Mfloat32 m pool (oc + 136 + 4 * byte2 w) (Vsingle (Float32.add a1 a2)) = Some m1 ->
    INV m1.

  Lemma row_sum_float : sumf_keep -> cmd_row_op 31.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 31) = Some BS._bhv_cmd_sum_float)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_sum_float
                  = Some (Gfun (Internal BS.f_bhv_cmd_sum_float))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_sum_float _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & a1 & a2 & m1 & Hl1 & Hl2 & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ HI Hst HQs Hw Ho Hl1 Hl2 Hs1) U).
    - left. reflexivity.
  Qed.

  (* DEACTIVATE's row.  obj_w reads activeFlags (a FREE slot is inactive;
     the converse is not claimed, so a listed slot going inactive is a
     state the real game produces: unload_deactivated_objects frees it on
     the next pass).  Pinned to the one store of 0 at reachable DEACTIVATE
     words only *)
  Definition deact_keep : Prop := forall m st w m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 29 ->
    Mem.store Mint16signed m pool (oc + OW.O_FLAGS) (Vint Int.zero) = Some m1 -> INV m1.

  Lemma row_deactivate : deact_keep -> cmd_row_op 29.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 29) = Some BS._bhv_cmd_deactivate)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_deactivate
                  = Some (Gfun (Internal BS.f_bhv_cmd_deactivate))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_deactivate _ _ _ _ _ _ Hst HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & Hs1).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hk _ _ _ _ HI Hst HQs Hw Ho Hs1).
    - right. reflexivity.
  Qed.

  (* SET_INTERACT_TYPE's row.  It writes field 42 = oInteractType, which
     obj_w's KIND clause reads.  Computed (sit_arg): the value is the
     script's next word -- bhvBobombBuddyOpensCannon's 0x800000 (in
     wmotr_interact_types) or bhvKoopaShellFlame's INTERACT_FLAME (NOT in
     it: the FOUND at chk47_ok).  The flame is outside WMotR's real spawn
     graph (BoxCensus.flame_unreached; sit_kind), so discharging this
     premise from obj_w needs obj_w's SCRIPT domain narrowed to
     BoxCensus.wmotr_closure_b.  Pinned to that one store *)
  Definition sit_keep : Prop := forall m st w a m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 47 ->
    word_at (v_s st) (v_i st + 1) = Some (Int.unsigned a) ->
    Mem.store Mint32 m pool (oc + 136 + 4 * 42) (Vint a) = Some m1 -> INV m1.

  Lemma row_set_interact_type : sit_keep -> cmd_row_op 47.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 47) = Some BS._bhv_cmd_set_interact_type)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_interact_type
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_interact_type))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_interact_type _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & a & m1 & Ha & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ HI Hst HQs Hw Ho Ha Hs1) U).
    - left. reflexivity.
  Qed.

  (* SET_RANDOM_FLOAT's row (opcode 20 = 0x14).  Its reachable fields are
     10 and 27-29; 27 is the cell obj_w's RED clause reads for a
     bhvHiddenRedCoinStar slot (oHiddenStarTriggerCounter).  Pinned: the RNG call changes only gRandomSeed16
     (Psd), then ONE store of range * r + min, r = rf_of u the real
     random_float value of a 16-bit u, range / min the script's *)
  Definition srf_keep : Prop := forall m st w z u m1 m2, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 20 ->
    word_at (v_s st) (v_i st + 1) = Some z -> 0 <= Int.unsigned u < 65536 ->
    Mem.unchanged_on Psd m m1 ->
    Mem.store Mfloat32 m1 pool (oc + 136 + 4 * byte2 w)
      (Vsingle (Float32.add (Float32.mul (rng_of z) (rf_of u)) (f32_of w))) = Some m2 -> INV m2.

  Lemma row_set_random_float : srf_keep -> cmd_row_op 20.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 20) = Some BS._bhv_cmd_set_random_float)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_random_float
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_random_float))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_random_float _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & z & u & m1 & m2 & Hz & Hu & Ur & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ HI Hst HQs Hw Ho Hz Hu Ur Hs1) U).
    - left. reflexivity.
  Qed.

  (* SET_RANDOM_INT's row (opcode 21).  Its one reachable field is 27, the cell obj_w's RED clause reads
     for a bhvHiddenRedCoinStar slot.  Pinned: the RNG call changes only
     gRandomSeed16 (Psd), then ONE store of the real computed value *)
  Definition sri_keep : Prop := forall m st w z u ri m1 m2, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 21 ->
    word_at (v_s st) (v_i st + 1) = Some z -> 0 <= Int.unsigned u < 65536 ->
    Float32.to_int (Float32.mul (Float32.of_int (rngi_of z)) (rf_of u)) = Some ri ->
    Mem.unchanged_on Psd m m1 ->
    Mem.store Mint32 m1 pool (oc + 136 + 4 * byte2 w) (Vint (Int.add ri (s16_of w))) = Some m2 -> INV m2.

  Lemma row_set_random_int : sri_keep -> cmd_row_op 21.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 21) = Some BS._bhv_cmd_set_random_int)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_random_int
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_random_int))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_random_int _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & z & u & ri & m1 & m2 & Hz & Hu & Hv & Ur & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ _ HI Hst HQs Hw Ho Hz Hu Hv Ur Hs1) U).
    - left. reflexivity.
  Qed.

  (* SET_INT_RAND_RSHIFT's row (opcode 19).  Its one reachable field is 16, which obj_w does not read.  Pinned: the RNG call changes only
     gRandomSeed16 (Psd), then ONE store of the real computed value *)
  Definition sir_keep : Prop := forall m st w z u ri m1 m2, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 19 ->
    word_at (v_s st) (v_i st + 1) = Some z -> 0 <= Int.unsigned u < 65536 ->
    Int.ltu (rngi_of z) Int.iwordsize = true /\ ri = Int.shr u (rngi_of z) ->
    Mem.unchanged_on Psd m m1 ->
    Mem.store Mint32 m1 pool (oc + 136 + 4 * byte2 w) (Vint (Int.add ri (s16_of w))) = Some m2 -> INV m2.

  Lemma row_set_int_rand_rshift : sir_keep -> cmd_row_op 19.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 19) = Some BS._bhv_cmd_set_int_rand_rshift)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_int_rand_rshift
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_int_rand_rshift))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_int_rand_rshift _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & z & u & ri & m1 & m2 & Hz & Hu & Hv1 & Hv2 & Ur & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ _ HI Hst HQs Hw Ho Hz Hu (conj Hv1 Hv2) Ur Hs1) U).
    - left. reflexivity.
  Qed.

  (* PARENT_BIT_CLEAR's row (opcode 51).  It writes the PARENT's field 22
     (oActiveParticleFlags), clearing mask bits.  Two pinned premises:
     par51_ok -- POSITIVE (a stuck NULL deref would silently drop a run):
     at a reachable 0x33 word, o->parentObj IS a pool slot disjoint from
     o's script stack.  Phantom check: the 0x33 states are the twelve
     particle spawners (BhvVM.pbc_states); every real spawn path for them
     is spawn_object_at_origin(parent = gCurrentObject, a live slot it
     dereferences): spawn_particle (Mario's particle table,
     object_list_processor.c), spawn_object in bubba / mips (water splash),
     SPAWN_CHILD (bhvWhitePuff1 from bhvMistParticleSpawner); none of the
     20 C writers of parentObj targets them (they are behavior-specific,
     create_object's obj itself, or obj_set_held_state on a held object).
     Clauses for obj_w: (1) every slot's parentObj is NULL or a slot (red
     coins may store NULL); (2) a slot running a pbc behavior has a slot
     parent.  With oc a slot offset, alignment gives the disjointness.
     pbc_keep -- the one store, old & ~mask, into that slot's field 22,
     which obj_w does not read *)
  Definition par51_ok : Prop := forall m st w, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 51 ->
    exists po, Mem.load Mint32 m pool (oc + 104) = Some (Vptr pool (Ptrofs.repr po))
      /\ 0 <= po <= 145312 /\ (po = oc \/ po + 608 <= oc \/ oc + 608 <= po).

  Definition pbc_keep : Prop := forall m st w po a old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 51 ->
    Mem.load Mint32 m pool (oc + 104) = Some (Vptr pool (Ptrofs.repr po)) ->
    word_at (v_s st) (v_i st + 1) = Some (Int.unsigned a) ->
    Mem.load Mint32 m pool (po + 136 + 4 * byte2 w) = Some (Vint old) ->
    Mem.store Mint32 m pool (po + 136 + 4 * byte2 w)
      (Vint (Int.and old (Int.xor a (Int.repr (-1))))) = Some m1 -> INV m1.

  Lemma row_parent_bit_clear : par51_ok -> pbc_keep -> cmd_row_op 51.
  Proof.
    intros Hp Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 51) = Some BS._bhv_cmd_parent_bit_clear)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_parent_bit_clear
                  = Some (Gfun (Internal BS.f_bhv_cmd_parent_bit_clear))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (Hp _ _ _ HI Hst HQs Hw Ho) as (po0 & Hpl0 & Hpo0 & Hdj0).
    assert (Hpar : forall pb o, Mem.load Mint32 m pool (oc + 104) = Some (Vptr pb o) ->
       pb = pool /\ exists po, o = Ptrofs.repr po /\ 0 <= po <= 145312
                      /\ (po = oc \/ po + 608 <= oc \/ oc + 608 <= po)).
    { intros pb o Hl. rewrite Hpl0 in Hl. injection Hl as <- <-.
      split; [ reflexivity | exists po0; split; [ reflexivity | split; [ exact Hpo0 | exact Hdj0 ] ] ]. }
    destruct (hd_parent_bit_clear _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hpar Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & po & a & old & m1 & Hpl & Ha & Hld & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ HI Hst HQs Hw Ho Hpl Ha Hld Hs1) U).
    - left. reflexivity.
  Qed.

  (* ANIMATE_TEXTURE's row (opcode 52).  Computed (BhvVM.atex_states): the
     only reachable 0x34 word is bhvKoopaShellFlame's
     ANIMATE_TEXTURE(oAnimState, 2) -- field 26, rate 2 (nonzero, so the %
     is defined) -- and the flame is outside WMotR's real spawn graph
     (BoxCensus.flame_unreached): once obj_w's SCRIPT domain is narrowed to
     BoxCensus.wmotr_closure_b this premise holds vacuously.  Pinned to the
     one store, old + 1 (the timer branch not taken leaves m unchanged) *)
  Definition atex_keep : Prop := forall m st w old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 52 ->
    Mem.load Mint32 m pool (oc + 136 + 4 * byte2 w) = Some (Vint old) ->
    Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vint (Int.add old (Int.repr 1))) = Some m1 -> INV m1.

  Lemma row_animate_texture : atex_keep -> cmd_row_op 52.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 52) = Some BS._bhv_cmd_animate_texture)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_animate_texture
                  = Some (Gfun (Internal BS.f_bhv_cmd_animate_texture))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_animate_texture _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & m1 & Hq & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - refine (Hinv_frame _ _ _ U).
      destruct Hq as [-> | (old & Hld & Hs1)]; [ exact HI | exact (Hk _ _ _ _ _ HI Hst HQs Hw Ho Hld Hs1) ].
    - left. reflexivity.
  Qed.

  (* BILLBOARD's row (opcode 33).  Sets GRAPH_RENDER_BILLBOARD.
     Pinned to the one s16 store into the CURRENT slot's
     header.gfx.node.flags (@2), which obj_w does not read (ow_gfx reads the
     node's prev / next / parent links @4 / @8 / @12; mact the activeFlags @116) *)
  Definition bb_keep : Prop := forall m st w old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 33 ->
    Mem.load Mint16signed m pool (oc + 2) = Some (Vint old) ->
    Mem.store Mint16signed m pool (oc + 2) (Vint (Int.sign_ext 16 (Int.or old (Int.shl (Int.repr 1) (Int.repr 2))))) = Some m1 -> INV m1.

  Lemma row_billboard : bb_keep -> cmd_row_op 33.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 33) = Some BS._bhv_cmd_billboard)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_billboard
                  = Some (Gfun (Internal BS.f_bhv_cmd_billboard))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_billboard _ _ _ _ _ _ Hst HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & old & m1 & Hld & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ HI Hst HQs Hw Ho Hld Hs1) U).
    - left. reflexivity.
  Qed.

  (* DISABLE_RENDERING's row (opcode 53).  Clears GRAPH_RENDER_ACTIVE.
     Pinned to the one s16 store into the CURRENT slot's
     header.gfx.node.flags (@2), which obj_w does not read (ow_gfx reads the
     node's prev / next / parent links @4 / @8 / @12; mact the activeFlags @116) *)
  Definition dr_keep : Prop := forall m st w old m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 53 ->
    Mem.load Mint16signed m pool (oc + 2) = Some (Vint old) ->
    Mem.store Mint16signed m pool (oc + 2) (Vint (Int.sign_ext 16 (Int.and old (Int.not (Int.shl (Int.repr 1) (Int.repr 0)))))) = Some m1 -> INV m1.

  Lemma row_disable_rendering : dr_keep -> cmd_row_op 53.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 53) = Some BS._bhv_cmd_disable_rendering)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_disable_rendering
                  = Some (Gfun (Internal BS.f_bhv_cmd_disable_rendering))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_disable_rendering _ _ _ _ _ _ Hst HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & old & m1 & Hld & Hs1 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ HI Hst HQs Hw Ho Hld Hs1) U).
    - left. reflexivity.
  Qed.

  (* SET_HITBOX's row (opcode 35) and SET_HITBOX_WITH_OFFSET's (43).  They
     write the CURRENT slot's hitboxRadius / hitboxHeight (@504 / @508) and
     hitboxDownOffset (@520) -- none read by obj_w (they feed interaction
     tests, which the height frame treats through Mario's own rows).
     Pinned to the stores of the script's real s16 halves *)
  Definition hb_keep : Prop := forall m st w z m1 m2, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 35 ->
    word_at (v_s st) (v_i st + 1) = Some z ->
    Mem.store Mfloat32 m pool (oc + 504) (Vsingle (Float32.of_int (rngi_of z))) = Some m1 ->
    Mem.store Mfloat32 m1 pool (oc + 508) (Vsingle (Float32.of_int (s16_of z))) = Some m2 -> INV m2.

  Lemma row_set_hitbox : hb_keep -> cmd_row_op 35.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 35) = Some BS._bhv_cmd_set_hitbox)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_hitbox
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_hitbox))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_hitbox _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & z & m1 & m2 & Hz & Hs1 & Hs2 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ HI Hst HQs Hw Ho Hz Hs1 Hs2) U).
    - left. reflexivity.
  Qed.

  Definition hbo_keep : Prop := forall m st w z z2 m1 m2 m3, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 43 ->
    word_at (v_s st) (v_i st + 1) = Some z -> word_at (v_s st) (v_i st + 2) = Some z2 ->
    Mem.store Mfloat32 m pool (oc + 504) (Vsingle (Float32.of_int (rngi_of z))) = Some m1 ->
    Mem.store Mfloat32 m1 pool (oc + 508) (Vsingle (Float32.of_int (s16_of z))) = Some m2 ->
    Mem.store Mfloat32 m2 pool (oc + 520) (Vsingle (Float32.of_int (rngi_of z2))) = Some m3 -> INV m3.

  Lemma row_set_hitbox_with_offset : hbo_keep -> cmd_row_op 43.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 43) = Some BS._bhv_cmd_set_hitbox_with_offset)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_hitbox_with_offset
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_hitbox_with_offset))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_hitbox_with_offset _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & z & z2 & m1 & m2 & m3 & Hz & Hz2 & Hs1 & Hs2 & Hs3 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ _ HI Hst HQs Hw Ho Hz Hz2 Hs1 Hs2 Hs3) U).
    - left. reflexivity.
  Qed.

  (* SET_HOME's row (opcode 45).  It copies the CURRENT slot's pos (fields
     6-8) to its home (fields 55-57), which obj_w does not read.  Pinned to
     the three real load / store pairs *)
  Definition home_keep : Prop := forall m st w f1 f2 f3 m1 m2 m3, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 45 ->
    Mem.load Mfloat32 m pool (oc + 136 + 4 * 6) = Some (Vsingle f1) ->
    Mem.store Mfloat32 m pool (oc + 136 + 4 * 55) (Vsingle f1) = Some m1 ->
    Mem.load Mfloat32 m1 pool (oc + 136 + 4 * 7) = Some (Vsingle f2) ->
    Mem.store Mfloat32 m1 pool (oc + 136 + 4 * 56) (Vsingle f2) = Some m2 ->
    Mem.load Mfloat32 m2 pool (oc + 136 + 4 * 8) = Some (Vsingle f3) ->
    Mem.store Mfloat32 m2 pool (oc + 136 + 4 * 57) (Vsingle f3) = Some m3 -> INV m3.

  Lemma row_set_home : home_keep -> cmd_row_op 45.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 45) = Some BS._bhv_cmd_set_home)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_home
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_home))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_home _ _ _ _ _ _ Hst HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & f1 & f2 & f3 & m1 & m2 & m3 & L1 & S1 & L2 & S2 & L3 & S3 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ _ _ HI Hst HQs Hw Ho L1 S1 L2 S2 L3 S3) U).
    - left. reflexivity.
  Qed.

  (* SET_OBJ_PHYSICS's row (opcode 48).  Six f32 stores into the CURRENT
     slot's fields 40, 23, 52, 41, 58, 59 (wall radius, gravity, bounciness,
     drag, friction, buoyancy) -- none read by obj_w.  Computed reachable
     users (vm_tab): bhvJumpingBox, bhvKoopaShell, bhvSingleCoinGetsSpawned.
     Pinned to the real values *)
  Definition phys_keep : Prop := forall m st w z1 z2 z3 m1 m2 m3 m4 m5 m6, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 48 ->
    word_at (v_s st) (v_i st + 1) = Some z1 -> word_at (v_s st) (v_i st + 2) = Some z2 ->
    word_at (v_s st) (v_i st + 3) = Some z3 ->
    Mem.store Mfloat32 m pool (oc + 136 + 4 * 40) (Vsingle (Float32.of_int (rngi_of z1))) = Some m1 ->
    Mem.store Mfloat32 m1 pool (oc + 136 + 4 * 23) (Vsingle (pdiv (s16_of z1))) = Some m2 ->
    Mem.store Mfloat32 m2 pool (oc + 136 + 4 * 52) (Vsingle (pdiv (rngi_of z2))) = Some m3 ->
    Mem.store Mfloat32 m3 pool (oc + 136 + 4 * 41) (Vsingle (pdiv (s16_of z2))) = Some m4 ->
    Mem.store Mfloat32 m4 pool (oc + 136 + 4 * 58) (Vsingle (pdiv (rngi_of z3))) = Some m5 ->
    Mem.store Mfloat32 m5 pool (oc + 136 + 4 * 59) (Vsingle (pdiv (s16_of z3))) = Some m6 -> INV m6.

  Lemma row_set_obj_physics : phys_keep -> cmd_row_op 48.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 48) = Some BS._bhv_cmd_set_obj_physics)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_set_obj_physics
                  = Some (Gfun (Internal BS.f_bhv_cmd_set_obj_physics))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_set_obj_physics _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & z1 & z2 & z3 & m1 & m2 & m3 & m4 & m5 & m6
          & Hz1 & Hz2 & Hz3 & S1 & S2 & S3 & S4 & S5 & S6 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ _ _ _ _ _ HI Hst HQs Hw Ho Hz1 Hz2 Hz3 S1 S2 S3 S4 S5 S6) U).
    - left. reflexivity.
  Qed.

  (* LOAD_ANIMATIONS's row (opcode 39).  ONE pointer store into the CURRENT slot:
     rawData field byte2 w (38, oAnimations, for every user), of the script's own symbol address (the generated word).
     Computed reachable users (vm_tab): bhvBobombBuddyOpensCannon, bhvBowserKeyCourseExit, bhvBowserKeyUnlockDoor, bhvEndToad, bhvEndPeach.  obj_w does not read field 38; PhiW pins Mario's own animation state, and no user is Mario. *)
  Definition la_keep : Prop := forall m st w ta oa bt m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 39 ->
    nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof ta oa) ->
    Genv.find_symbol G ta = Some bt ->
    Mem.store Mint32 m pool (oc + 136 + 4 * byte2 w) (Vptr bt oa) = Some m1 -> INV m1.

  Lemma row_load_animations : la_keep -> cmd_row_op 39.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 39) = Some BS._bhv_cmd_load_animations)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_load_animations
                  = Some (Gfun (Internal BS.f_bhv_cmd_load_animations))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_load_animations _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & ta & oa & bt & m1 & Ha & Hbt & Hs & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ HI Hst HQs Hw Ho Ha Hbt Hs) U).
    - left. reflexivity.
  Qed.

  (* LOAD_COLLISION_DATA's row (opcode 42).  ONE pointer store into the CURRENT slot:
     collisionData (@536, O_COLL), of the script's own symbol address (the generated word).
     Computed reachable users (vm_tab): bhvCannonClosed, bhvExclamationBox.  obj_w DOES read @536 (coll_pin: a LIDS / BOXS slot holds NULL or its mesh), so the discharge is the vm fact that these two scripts' word 1 is &cannon_lid / &exclamation_box_outline collision at offset 0. *)
  Definition lcd_keep : Prop := forall m st w ta oa bt m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 42 ->
    nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof ta oa) ->
    Genv.find_symbol G ta = Some bt ->
    Mem.store Mint32 m pool (oc + 536) (Vptr bt oa) = Some m1 -> INV m1.

  Lemma row_load_collision_data : lcd_keep -> cmd_row_op 42.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 42) = Some BS._bhv_cmd_load_collision_data)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_load_collision_data
                  = Some (Gfun (Internal BS.f_bhv_cmd_load_collision_data))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_load_collision_data _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & ta & oa & bt & m1 & Ha & Hbt & Hs & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ _ HI Hst HQs Hw Ho Ha Hbt Hs) U).
    - left. reflexivity.
  Qed.

  (* SCALE's row (opcode 50).  cur_obj_scale's three f32 stores into the
     CURRENT slot's header.gfx.scale (@44/48/52): obj_w reads only the gfx
     node links @4/8/12.  Computed reachable users (vm_tab):
     bhvRedCoinStarMarker (150%), bhvRotatingExclamationMark (200%) -- not
     Mario, whose scale PhiW's window [12,64) covers.  Pinned to the real
     values *)
  Definition scale_keep : Prop := forall m st w m1 m2 m3, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 50 ->
    Mem.store Mfloat32 m pool (oc + 44 + 4 * 0) (Vsingle (pdiv (s16_of w))) = Some m1 ->
    Mem.store Mfloat32 m1 pool (oc + 44 + 4 * 1) (Vsingle (pdiv (s16_of w))) = Some m2 ->
    Mem.store Mfloat32 m2 pool (oc + 44 + 4 * 2) (Vsingle (pdiv (s16_of w))) = Some m3 -> INV m3.

  Lemma row_scale : scale_keep -> cmd_row_op 50.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 50) = Some BS._bhv_cmd_scale)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_scale
                  = Some (Gfun (Internal BS.f_bhv_cmd_scale))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_scale _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & m1 & m2 & m3 & S1 & S2 & S3 & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ _ _ HI Hst HQs Hw Ho S1 S2 S3) U).
    - left. reflexivity.
  Qed.

  (* BEGIN's row (opcode 0; 95 reachable states, every script's head,
     Mario's included -- frame 1 really runs bhvMario's BEGIN).  POSITIVE
     premise (a stuck compare would silently drop a run): the current
     slot's behavior is a valid pointer, and bhvHauntedChair / bhvMadPiano /
     bhvMessagePanel are linked, valid, and in other blocks -- none of the
     three is a WMotR object.  Then no store besides the cursor (Pfr) *)
  Definition begin_ok : Prop := forall m st w, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 0 ->
    exists bb ob, Mem.load Mint32 m pool (oc + 524) = Some (Vptr bb ob)
      /\ Mem.valid_pointer m bb (Ptrofs.unsigned ob) = true
      /\ forall id, In id [BS._bhvHauntedChair; BS._bhvMadPiano; BS._bhvMessagePanel] ->
           exists bs, Genv.find_symbol G id = Some bs /\ bs <> bb /\ Mem.valid_pointer m bs 0 = true.

  Lemma row_begin : begin_ok -> cmd_row_op 0.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 0) = Some BS._bhv_cmd_begin)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_begin
                  = Some (Gfun (Internal BS.f_bhv_cmd_begin))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (Hk m st w HI Hst HQs Hw Ho) as (bb & ob & Hbh & Hvb & Hsy).
    destruct (hd_begin _ _ _ _ _ _ _ _ Hst HV (Hinv_cur m HI) Hw Ho Hbh Hvb Hsy Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ HI U).
    - left. reflexivity.
  Qed.

  (* ---- CALL_NATIVE: the bulk half, by the precise frame SFR' ---- *)
  Hypothesis Hsq : FpuFloor.sqrtf_spec.
  (* the slots live in gObjectPool (what gCurrentObject points into) *)
  Hypothesis Hpool : Genv.find_symbol G ObjSelf.POOL = Some pool.

  (* SFR' at entry memory m: every block valid in m stays, except the
     running slot's non-XBn bytes, the allow_n globals, and blocks
     allocated during the call *)
  Definition SFPn (m : mem) : block -> Z -> Prop :=
    ObjSelf.SFP (Some ObjFrame.allow_n) ObjFrame.XBn G (Mem.nextblock m) pool go (Ptrofs.repr oc) ObjFrame.OSZ.

  (* THE KEEP (one premise for the whole bulk): INV survives any change
     SFR' allows, at a generic slot (its state outside sp_scripts).  What
     it asks of INV: for a generic slot, obj_w reads only XBn's cells of
     the slot, no allow_n global's contents, and nothing allocated later.
     (Phantom note: kind_ok's pole / cannon pins are keyed on the slot's
     interactType and surf_obj_at's angle-velocity pins on surface
     ownership, not on the script; the keep needs INV to tie both to the
     special scripts -- see the SKILL open surface.) *)
  (* FOUND / REPAIRED (2026-11-07, phantom forall): SFR' says only WHERE a
     bulk native stores, never WHAT, so over every m1 it allows (a pointer
     to a freed local stored into the slot) sfr_keep was FALSE for any INV
     holding MWF_real (R7: the pool is SafeB and SafeB is load-closed) or
     PhiW's closedness.  REPAIRED: the keep takes the VALUE premise nvals --
     a pointer an old cell holds after the call that it did not hold before
     aims at a block PV names at entry (the instance: a SafeB block of the
     entry memory).  The natives' side is native_vals (true in the game:
     bulk natives store ints / floats, pool and surface pointers, data
     symbols; to be discharged by a value-tracking SFR' walk) *)
  Variable PV : mem -> block -> Prop.
  Definition nvals (m m1 : mem) : Prop :=
    forall b z bp op, Plt b (Mem.nextblock m) -> Mem.load Mint32 m1 b z = Some (Vptr bp op) ->
      Mem.load Mint32 m b z <> Some (Vptr bp op) -> PV m bp.

  Definition sfr_keep : Prop := forall m m1 st,
    INV m -> V m st -> In st vm_tab -> Qs st -> existsb (Pos.eqb (v_s st)) sp_scripts = false ->
    Mem.unchanged_on (SFPn m) m m1 -> nvals m m1 -> INV m1.

  (* THE NATIVES' VALUE SIDE: a bulk native called at a generic state
     stores only PV pointers into old blocks *)
  Definition native_vals : Prop := forall m st fid bfn fd t m1 vres,
    INV m -> V m st -> In st vm_tab -> Qs st -> existsb (Pos.eqb (v_s st)) sp_scripts = false ->
    has_null fid ObjFrame.self_tab_n = true ->
    Genv.find_symbol G fid = Some bfn -> Genv.find_funct G (Vptr bfn Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 G m fd [] t m1 vres -> nvals m m1.

  (* THE RESIDUAL: a CALL_NATIVE at a special state (Mario's three
     included), or of a callee with no nullary SFR'-clean entry (at a
     generic state these are nat_res_gen) *)
  Definition native_res : Prop := forall m st w fid bfn fd t m1 vres,
    INV m -> V m st -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 12 ->
    nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof fid Ptrofs.zero) ->
    existsb (Pos.eqb (v_s st)) sp_scripts = true \/ has_null fid ObjFrame.self_tab_n = false ->
    Genv.find_symbol G fid = Some bfn -> Genv.find_funct G (Vptr bfn Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 G m fd [] t m1 vres -> INV m1 /\ V m1 st.

  Lemma valid_of_load : forall ch m b z v, Mem.load ch m b z = Some v -> Plt b (Mem.nextblock m).
  Proof.
    intros ch m b z v H. apply (Mem.valid_access_valid_block m ch b z).
    apply (Mem.valid_access_implies m ch b z Readable Nonempty);
      [ exact (Mem.load_valid_access _ _ _ _ _ H) | constructor ].
  Qed.

  (* the VM cells are XBn cells / gCurBhvCommand: V survives SFR' *)
  Lemma V_sfr : forall m m1 st, In st vm_tab -> V m st -> Mem.unchanged_on (SFPn m) m m1 -> V m1 st.
  Proof.
    intros m m1 st Hst HV U. destruct (st_facts st Hst) as (_ & _ & Hd & _).
    apply V_iff in HV as ((b & Hsb & Hcm) & Hsi & Hk). apply V_iff.
    assert (Hro : Ptrofs.unsigned (Ptrofs.repr oc) = oc) by (apply Ptrofs.unsigned_repr; rewrite maxu; lia).
    assert (Hpool_c : forall z, oc + 460 <= z < oc + 500 -> SFPn m pool z).
    { intros z Hz. left. split; [ reflexivity | right ].
      exists (460, 500). split; [ unfold ObjFrame.XBn; cbn [In]; do 3 right; left; reflexivity
                                | cbn [fst snd]; rewrite Hro; lia ]. }
    split.
    - exists b. split; [ exact Hsb | ].
      rewrite (Mem.load_unchanged_on_1 _ _ _ Mint32 bc 0 U (valid_of_load _ _ _ _ _ Hcm)); [ exact Hcm | ].
      intros i _. right. right. split; [ exact Hbp | split; [ exact (valid_of_load _ _ _ _ _ Hcm) | ] ].
      intros (x & Hx & Hs). assert (Ex : x = BS._gCurBhvCommand) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hbc ]).
      subst x. pose proof bc_not_allow as Hn.
      assert (Ht : existsb (Pos.eqb BS._gCurBhvCommand) ObjFrame.allow_n = true)
        by (apply existsb_exists; exists BS._gCurBhvCommand; split; [ exact Hx | apply Pos.eqb_refl ]).
      rewrite Ht in Hn. discriminate Hn.
    - split.
      + rewrite (Mem.load_unchanged_on_1 _ _ _ Mint32 pool _ U (valid_of_load _ _ _ _ _ Hsi)); [ exact Hsi | ].
        intros i Hi. apply Hpool_c. change (size_chunk Mint32) with 4 in Hi. unfold OW.O_SIDX in Hi. lia.
      + intros n f Hn. pose proof (Hk n f Hn) as Hf.
        assert (Hlt : (n < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hn; discriminate).
        destruct f as [s0 i0|].
        * destruct Hf as (b0 & Hb0 & Hl0). exists b0. split; [ exact Hb0 | ].
          rewrite (Mem.load_unchanged_on_1 _ _ _ Mint32 pool _ U (valid_of_load _ _ _ _ _ Hl0)); [ exact Hl0 | ].
          intros i Hi. apply Hpool_c. change (size_chunk Mint32) with 4 in Hi. unfold OW.O_STK in Hi. lia.
        * destruct Hf as (c & Hl0). exists c.
          rewrite (Mem.load_unchanged_on_1 _ _ _ Mint32 pool _ U (valid_of_load _ _ _ _ _ Hl0)); [ exact Hl0 | ].
          intros i Hi. apply Hpool_c. change (size_chunk Mint32) with 4 in Hi. unfold OW.O_STK in Hi. lia.
  Qed.

  (* THE BULK: a bulk native, called at a generic state, runs under SFR' *)
  Lemma native_bulk : forall m st fid bfn fd t m1 vres,
    INV m -> V m st -> has_null fid ObjFrame.self_tab_n = true ->
    Genv.find_symbol G fid = Some bfn -> Genv.find_funct G (Vptr bfn Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 G m fd [] t m1 vres -> Mem.unchanged_on (SFPn m) m m1.
  Proof.
    intros m st fid bfn fd t m1 vres HI HV Hb Hs Hff Hev.
    destruct (has_null_in fid _ Hb) as (i & Hin).
    pose proof (Hinv_cur m HI) as Hc.
    assert (Hro : Ptrofs.unsigned (Ptrofs.repr oc) + ObjFrame.OSZ <= Ptrofs.max_unsigned)
      by (rewrite Ptrofs.unsigned_repr by (rewrite maxu; lia); rewrite maxu; unfold ObjFrame.OSZ; lia).
    apply V_iff in HV as (_ & Hsi & _).
    refine (ObjFrame.obj_body_frame_x lp H12 Hsq pool go (Ptrofs.repr oc) Hpool Hgo Hro
              (Some ObjFrame.allow_n) ObjFrame.XBn (Mem.nextblock m) ObjFrame.self_tab_n ObjFrame.self_walk_ok_n
              fid i [] bfn fd m [] t m1 vres Hin Hs Hff Hev (Forall2_nil _) Hc _).
    split; [ exact (valid_of_load _ _ _ _ _ Hsi) | ].
    intros b [-> | (_ & Hlt & _)]; [ exact (valid_of_load _ _ _ _ _ Hc) | exact Hlt ].
  Qed.

  (* CALL_NATIVE's row (opcode 12).  The handler reads word 1 (the native's
     address, cn_w), calls it, and moves the cursor by 2.  The premise is
     pinned to the REAL callee's execution: for each reachable 0x0C state
     (computed: ~110 natives, bhv_mario_update included), the linked
     function at that address preserves INV and the VM cells of the
     current state.  This is the per-native open surface (what
     Hobj_step_act stood for), now naming each callee by the script word *)
  Definition native_keep : Prop := forall m st w fid bfn fd t m1 vres,
    INV m -> V m st -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 12 ->
    nth_error (words (v_s st)) (v_i st + 1) = Some (Init_addrof fid Ptrofs.zero) ->
    Genv.find_symbol G fid = Some bfn -> Genv.find_funct G (Vptr bfn Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 G m fd [] t m1 vres -> INV m1 /\ V m1 st.

  (* the split discharges native_keep *)
  Lemma native_keep_of : sfr_keep -> native_vals -> native_res -> native_keep.
  Proof.
    intros Hk Hnv Hr m st w fid bfn fd t m1 vres HI HV Hst HQs Hw Ho Ha Hs Hff Hev.
    destruct (existsb (Pos.eqb (v_s st)) sp_scripts) eqn:E1;
      [ exact (Hr m st w fid bfn fd t m1 vres HI HV Hst HQs Hw Ho Ha (or_introl E1) Hs Hff Hev) | ].
    destruct (has_null fid ObjFrame.self_tab_n) eqn:E2;
      [ | exact (Hr m st w fid bfn fd t m1 vres HI HV Hst HQs Hw Ho Ha (or_intror E2) Hs Hff Hev) ].
    pose proof (native_bulk m st fid bfn fd t m1 vres HI HV E2 Hs Hff Hev) as U.
    split; [ exact (Hk m m1 st HI HV Hst HQs E1 U (Hnv m st fid bfn fd t m1 vres HI HV Hst HQs E1 E2 Hs Hff Hev))
           | exact (V_sfr m m1 st Hst HV U) ].
  Qed.

  Lemma row_call_native : native_keep -> cmd_row_op 12.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 12) = Some BS._bhv_cmd_call_native)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_call_native
                  = Some (Gfun (Internal BS.f_bhv_cmd_call_native))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    pose proof (proj1 (Hinv m HI)) as Hscr.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_cn st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    pose proof HV as HV0.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (cn_w st w Hst Hw Ho) as (fid & Ha).
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Ha) as (va & Hla & Hia).
    cbn in Hia. destruct Hia as (bfn & Hbf & ->).
    assert (Hilt : (v_i st + 1 < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Ha; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hcm.
    replace (4 * Z.of_nat (v_i st + 1)) with (I4 + 4 * 1) in Hla by lia.
    apply fcall_inv in Hev as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_call_native bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_call_native] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vq & Evq & -> & -> & _).
    apply (ev_wkv _ _ _ b I4 1 _ _ ltac:(lia) (PTree.gss _ _ _) ltac:(lia) Hla) in Evq. subst vq.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (z1 & Ez1 & Cz). apply RA.ev_temp in Ez1. rewrite PTree.gss in Ez1.
    injection Ez1 as <-. cbn in Cz. injection Cz as <-.
    apply RA.seq_inv in X2 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.call_inv in Y1 as (tya & tyr & cc & vfn & vargs & fd2 & vres & Hcf & Evf2 & Eal & Hff & _ & Hcl2 & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    apply RA.ev_temp in Evf2. rewrite PTree.gss in Evf2. injection Evf2 as <-.
    assert (Ev0 : vargs = []) by (inversion Eal; reflexivity). subst vargs.
    destruct (Hk m st w fid bfn fd2 _ n1 vres HI HV0 Hst HQs Hw Ho Ha Hbf Hff Hcl2) as (HI1 & HV1).
    apply V_iff in HV1 as ((b' & Hsb' & Hcm1) & HS1).
    rewrite Hsb in Hsb'. injection Hsb' as <-.
    try rewrite <- EI in Hcm1.
    (* cmd = cmd + 2 *)
    apply RA.seq_inv in Y2 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Hcm1) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 2)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs9) ].
    - split; [ exact (Hinv_frame _ _ HI1 U9) | left; reflexivity ].
  Qed.

  (* ---- SPAWN_CHILD (opcode 28): the REAL bhv_cmd_spawn_child ---- *)
  Lemma LO_olp : Linking.linkorder object_list_processor.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))))))))))))) H12).
  Qed.

  (* the list symbols are defined in the link *)
  Lemma sc_syms : exists la fl bpg gol,
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la
    /\ Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl
    /\ Genv.find_symbol G area._gObjParentGraphNode = Some bpg
    /\ Genv.find_symbol G object_list_processor._gObjectLists = Some gol.
  Proof.
    destruct ((prog_defmap object_list_processor.prog) ! object_list_processor._gObjectListArray) as [g1|] eqn:E1;
      [ | vm_compute in E1; discriminate E1 ].
    destruct ((prog_defmap object_list_processor.prog) ! object_list_processor._gFreeObjectList) as [g2|] eqn:E2;
      [ | vm_compute in E2; discriminate E2 ].
    destruct ((prog_defmap object_list_processor.prog) ! object_list_processor._gObjectLists) as [g4|] eqn:E4;
      [ | vm_compute in E4; discriminate E4 ].
    destruct ((prog_defmap area.prog) ! area._gObjParentGraphNode) as [g3|] eqn:E3;
      [ | vm_compute in E3; discriminate E3 ].
    destruct (linkorder_resolves_symbol lp _ _ _ LO_olp E1) as (la & H1).
    destruct (linkorder_resolves_symbol lp _ _ _ LO_olp E2) as (fl & H2).
    destruct (linkorder_resolves_symbol lp _ _ _ LO_olp E4) as (gol & H4).
    destruct (linkorder_resolves_symbol lp _ _ _ (linked12_LO_area lp H12) E3) as (bpg & H3).
    exists la, fl, bpg, gol. auto.
  Qed.

  (* SPAWN_CHILD's row (opcode 28).  The handler is walked whole in
     ObjChild.child_real (spawn_object_at_origin -> create_object ->
     allocate_object, geo_obj_init, obj_copy_pos_and_angle, all on the real
     linked bodies).  Three pinned premises:
     sc_pre -- what obj_w carries at a 0x1C state: the list rings, the
       free list, their disjointness (ow_part), the graph links, the list
       array pointer, and the running slot is a ring member (so the new
       slot, taken from the free list, is another one);
     sc_free -- POOL EXHAUSTION (NAMED): the free list is nonempty at a 0x1C
       state.  With it empty, create_object would hand back NULL and the
       stores through it are stuck; no computed bound on live objects yet;
     sc_keep -- INV survives the spawn as child_real describes it: the new
       slot k (the free list's head) appended to its list's ring, the free
       list's tail left, the graph links kept, memory unchanged outside the
       link cells, slot k's non-link bytes and gCurBhvCommand, slot k's
       known facts (cpa_facts (origin_facts ..): the child's behavior,
       curBhvCommand, parentObj = the running slot, ...), and the command
       pointer at the next command.  Nothing is quantified the game cannot
       produce: the child script, its list and the parent are the computed
       / running ones *)
  Definition sc_pre : Prop := forall m st w la fl gol,
    INV m -> In st vm_tab -> Qs st -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 28 ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    exists rs fs kc, OW.rings m pool la = Some rs /\ OW.free_list m pool fl = Some fs
      /\ NoDup (concat rs ++ fs) /\ OW.gfx_ok G pool m
      /\ Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero)
      /\ oc = kc * OW.OSZ /\ In kc (concat rs).

  Definition sc_free : Prop := forall m st w fl fs,
    INV m -> In st vm_tab -> Qs st -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 28 ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    OW.free_list m pool fl = Some fs -> fs <> [].

  Definition sc_keep : Prop := forall m st w la fl bpg c bsc n rs k fs' m',
    INV m -> In st vm_tab -> Qs st -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 28 ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    nth_error (words (v_s st)) (v_i st + 2) = Some (Init_addrof c Ptrofs.zero) ->
    Genv.find_symbol G c = Some bsc -> nth_error (words c) 0 = Some (Init_int32 n) ->
    OW.rings m pool la = Some rs -> OW.free_list m pool fl = Some (k :: fs') -> 0 <= k < OW.NSLOT ->
    OW.rings m' pool la
      = Some (ObjRing.upd rs (Z.to_nat (ObjMake.bhv_list n)) (nth (Z.to_nat (ObjMake.bhv_list n)) rs [] ++ [k])) ->
    OW.free_list m' pool fl = Some fs' -> OW.gfx_ok G pool m' ->
    Mem.unchanged_on (fun b z => ObjAlloc.AKEEP pool la fl bpg b z /\ ObjCreate.KP pool (k * OW.OSZ) b z /\ b <> bc) m m' ->
    ObjCreate.facts m' pool (k * OW.OSZ) (OW.slot_v pool k)
      (ObjCopy.cpa_facts (ObjOrigin.origin_facts (ObjMake.bhv_list n) (Vptr bsc Ptrofs.zero) (Vptr pool (Ptrofs.repr oc)))) ->
    Vcmd m' (v_s st) (v_i st + 3) -> INV m'.

  Lemma sc_cell : forall la fl bpg k kc i, pool <> la -> pool <> fl -> pool <> bpg ->
    0 <= k < OW.NSLOT -> k <> kc -> oc = kc * OW.OSZ -> oc + 460 <= i < oc + 500 ->
    ObjAlloc.AKEEP pool la fl bpg pool i /\ ObjCreate.KP pool (k * OW.OSZ) pool i /\ pool <> bc.
  Proof.
    intros la fl bpg k kc i Hl Hf Hb Hk Hne Ek Hi. unfold OW.OSZ in *.
    split; [ split | split; [ | exact (not_eq_sym Hbp) ] ].
    - intros [(_ & j & Hj & Hz) | (E & _)]; [ | exact (Hb E) ].
      unfold OW.G_PREV, OW.G_CHILD, OW.OSZ in Hz. lia.
    - intros [(_ & j & Hj & Hz) | [E | E]]; [ | exact (Hl E) | exact (Hf E) ].
      unfold OW.O_NEXT, OW.O_PREV, OW.OSZ in Hz. lia.
    - unfold ObjCreate.KP. right. try unfold OW.OSZ.
      destruct (Z.lt_ge_cases k kc) as [Hc | Hc]; [ right; left; nia | left; nia ].
  Qed.

  Lemma row_spawn_child : sc_pre -> sc_free -> sc_keep -> cmd_row_op 28.
  Proof.
    intros Hpre Hfr Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 28) = Some BS._bhv_cmd_spawn_child)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_spawn_child
                  = Some (Gfun (Internal BS.f_bhv_cmd_spawn_child))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct sc_syms as (la & fl & bpg & gol & Hla & Hfl & Hbpg & Hgol).
    assert (Hpl : pool <> la) by (apply (ObjAlloc.sym_ne lp _ _ _ _ Hpool Hla); RA.neq).
    assert (Hpf : pool <> fl) by (apply (ObjAlloc.sym_ne lp _ _ _ _ Hpool Hfl); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (ObjAlloc.sym_ne lp _ _ _ _ Hpool Hbpg); RA.neq).
    destruct (Hpre m st w la fl gol HI Hst HQs Hw Ho Hla Hfl Hgol)
      as (rs & fs & kc & Hr & Hf & Hnd & Hg & Hgl & Ekc & Hkc).
    destruct (sc_w st w Hst Hw Ho) as (c & n & Hc2 & Hcin & Hn0 & H13 & H4 & H5 & H10).
    pose proof (proj1 (Hinv m HI)) as Hscr.
    destruct (st_facts st Hst) as (Hlen & _ & Hdep & l & Hl & _).
    pose proof (succs_sc st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    pose proof HV as HV0. apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    (* word 2: the child's script pointer; the child's first word *)
    destruct (Hscr (v_s st) b (v_i st + 2)%nat _ Hsb (in_map _ _ _ Hst) Hc2) as (va & Hl2 & Hia).
    cbn in Hia. destruct Hia as (bsc & Hbsc & ->).
    destruct (Hscr c bsc 0%nat _ Hbsc Hcin Hn0) as (vn & Hln & Hin0). cbn in Hin0. subst vn.
    assert (L8 : Mem.loadv Mint32 m (Vptr b (Ptrofs.add (Ptrofs.repr (4 * Z.of_nat (v_i st))) (Ptrofs.repr 8)))
                 = Some (Vptr bsc Ptrofs.zero)).
    { cbn [Mem.loadv]. unfold Ptrofs.add.
      rewrite (Ptrofs.unsigned_repr (4 * _)), (Ptrofs.unsigned_repr 8), Ptrofs.unsigned_repr by (rewrite maxu; lia).
      replace (4 * Z.of_nat (v_i st) + 8) with (4 * Z.of_nat (v_i st + 2)) by lia. exact Hl2. }
    destruct (ObjChild.child_real lp H12 pool la fl bpg gol bc go Hpool Hla Hfl Hbpg Hgol Hbc Hgo
                m rs fs b (Ptrofs.repr (4 * Z.of_nat (v_i st))) bsc Ptrofs.zero n (Vptr pool (Ptrofs.repr oc)) t m' vr
                Hr Hf Hnd Hg Hgl Hcm (Hinv_cur m HI) L8 Hln H13 H4 H5 H10 Hev)
      as [E0 | (k & fs' & -> & Hk' & -> & Lbc & R' & F' & G' & U & HF)].
    { exfalso. exact (Hfr m st w fl fs HI Hst HQs Hw Ho Hfl Hf E0). }
    assert (Hne : k <> kc).
    { intros ->. apply (nd_app_disj _ _ kc Hnd Hkc). left. reflexivity. }
    assert (Vc : Vcmd m' (v_s st) (v_i st + 3)).
    { exists b. split; [ exact Hsb | rewrite Lbc, padd_repr ].
      (* PERF TRAP: f_equal here took 13 min (it tries to compute) *)
      replace (4 * Z.of_nat (v_i st) + 12) with (4 * Z.of_nat (v_i st + 3)) by lia. reflexivity. }
    assert (Hvp : Plt pool (Mem.nextblock m)) by (destruct HS as (Hsi & _); exact (valid_of_load _ _ _ _ _ Hsi)).
    assert (Hcell : forall z, oc + 460 <= z -> z + 4 <= oc + 500 -> Mem.load Mint32 m' pool z = Mem.load Mint32 m pool z).
    { intros z Hz1 Hz2. apply (Mem.load_unchanged_on_1 _ _ _ Mint32 pool z U Hvp).
      intros i Hi. change (size_chunk Mint32) with 4 in Hi.
      exact (sc_cell la fl bpg k kc i Hpl Hpf Hpb Hk' Hne Ekc ltac:(lia)). }
    assert (HS' : Vstk m' (v_k st)).
    { destruct HS as (Hsi & Hkk). split.
      - rewrite Hcell by (unfold OW.O_SIDX; lia). exact Hsi.
      - intros n0 f Hn0'. assert (Hlt : (n0 < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hn0'; discriminate).
        rewrite Hcell by (unfold OW.O_STK; lia). exact (Hkk n0 f Hn0'). }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - exact (V_mk m' st (v_s st) (v_i st + 3) (v_k st) Vc HS').
    - split; [ | left; reflexivity ].
      exact (Hk m st w la fl bpg c bsc n rs k fs' m' HI Hst HQs Hw Ho Hla Hfl Hbpg Hc2 Hbsc Hn0 Hr Hf Hk' R' F' G' U HF Vc).
  Qed.

  (* ---- SPAWN_WATER_DROPLET (opcode 0x37 = 55): the REAL
     bhv_cmd_spawn_water_droplet -> spawn_water_droplet ----
     The handler is walked whole in ObjDroplet.wd_real: spawn_object
     (create_object / allocate_object / geo_obj_init /
     obj_copy_pos_and_angle on the real linked bodies), then the droplet
     tail -- every flag branch of the params (random_u16 / random_float /
     random_f32_around_zero / find_water_level for the seeds; obj_scale /
     obj_translate_xz_random / obj_translate_xyz_random on the slot).
     ALTERNATIVE (route 1, not taken): the only reachable 0x37 states are
     bhvShallowWaterSplash / bhvShallowWaterWave, spawned only through
     sParticleTypes from Mario's particleFlags bits 8 / 12, which only
     play_sound_and_spawn_particles sets, under terrainSoundAddend ==
     SOUND_TERRAIN_WATER << 16; in WMotR env regions are NULL (env_w), so
     find_water_level is -11000 and that needs floorHeight < -11010 (WMotR
     static vertices have y in [-8191, 4542]) or an sTerrainSounds entry 2
     (none).  So the row is believed unreachable in WMotR (docs/TRUST.md);
     proving it from the real code instead makes the row hold either way.
     Four pinned premises:
     wd_pre / wd_free / wd_keep -- as sc_pre / sc_free / sc_keep for 0x1C
       (wd_free is POOL EXHAUSTION, NAMED); wd_keep's facts are the droplet
       tail's (dtail) over cpa_facts (origin_facts ..) of bhvWaterDroplet;
     wd_dp -- the params' behavior field (byte 4) holds &bhvWaterDroplet:
       the initializer says so (dparams_init); nothing in the game writes
       these globals.  Pinned for the StartTerrain recheck, like ow_anim *)
  Definition wd_pre : Prop := forall m st w la fl gol,
    INV m -> In st vm_tab -> Qs st -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 55 ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    exists rs fs kc, OW.rings m pool la = Some rs /\ OW.free_list m pool fl = Some fs
      /\ NoDup (concat rs ++ fs) /\ OW.gfx_ok G pool m
      /\ Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero)
      /\ oc = kc * OW.OSZ /\ In kc (concat rs).

  Definition wd_free : Prop := forall m st w fl fs,
    INV m -> In st vm_tab -> Qs st -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 55 ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    OW.free_list m pool fl = Some fs -> fs <> [].

  Definition wd_dp : Prop := forall m p bp,
    INV m -> In p dparams -> Genv.find_symbol G p = Some bp ->
    exists bwd, Genv.find_symbol G behavior_data._bhvWaterDroplet = Some bwd
      /\ Mem.load Mint32 m bp 4 = Some (Vptr bwd Ptrofs.zero).

  Definition wd_keep : Prop := forall m st w la fl bpg bwd n rs k fs' m',
    INV m -> In st vm_tab -> Qs st -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 55 ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G behavior_data._bhvWaterDroplet = Some bwd ->
    nth_error (words behavior_data._bhvWaterDroplet) 0 = Some (Init_int32 n) ->
    OW.rings m pool la = Some rs -> OW.free_list m pool fl = Some (k :: fs') -> 0 <= k < OW.NSLOT ->
    OW.rings m' pool la
      = Some (ObjRing.upd rs (Z.to_nat (ObjMake.bhv_list n)) (nth (Z.to_nat (ObjMake.bhv_list n)) rs [] ++ [k])) ->
    OW.free_list m' pool fl = Some fs' -> OW.gfx_ok G pool m' ->
    Mem.unchanged_on (fun b z => ObjAlloc.AKEEP pool la fl bpg b z /\ ObjCreate.KP pool (k * OW.OSZ) b z
                                 /\ b <> bc /\ b <> sb) m m' ->
    ObjCreate.facts m' pool (k * OW.OSZ) (OW.slot_v pool k)
      (ObjDroplet.dtail (ObjCopy.cpa_facts (ObjOrigin.origin_facts (ObjMake.bhv_list n) (Vptr bwd Ptrofs.zero)
                                                                   (Vptr pool (Ptrofs.repr oc))))) ->
    Vcmd m' (v_s st) (v_i st + 2) -> INV m'.

  Lemma row_spawn_water_droplet : wd_pre -> wd_free -> wd_dp -> wd_keep -> cmd_row_op 55.
  Proof.
    intros Hpre Hfr Hdp Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 55) = Some BS._bhv_cmd_spawn_water_droplet)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_spawn_water_droplet
                  = Some (Gfun (Internal BS.f_bhv_cmd_spawn_water_droplet))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct sc_syms as (la & fl & bpg & gol & Hla & Hfl & Hbpg & Hgol).
    assert (Hpl : pool <> la) by (apply (ObjAlloc.sym_ne lp _ _ _ _ Hpool Hla); RA.neq).
    assert (Hpf : pool <> fl) by (apply (ObjAlloc.sym_ne lp _ _ _ _ Hpool Hfl); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (ObjAlloc.sym_ne lp _ _ _ _ Hpool Hbpg); RA.neq).
    destruct (Hpre m st w la fl gol HI Hst HQs Hw Ho Hla Hfl Hgol)
      as (rs & fs & kc & Hr & Hf & Hnd & Hg & Hgl & Ekc & Hkc).
    destruct (wd_w st w Hst Hw Ho) as (p & Hp1 & Hpin).
    destruct wd_child as (n & Hcin & Hn0 & H13 & H4 & H5 & H10).
    pose proof (proj1 (Hinv m HI)) as Hscr.
    destruct (st_facts st Hst) as (Hlen & _ & Hdep & l & Hl & _).
    pose proof (succs_wd st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    pose proof HV as HV0. apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    (* word 1: &params; params' byte 4: &bhvWaterDroplet; its first word *)
    destruct (Hscr (v_s st) b (v_i st + 1)%nat _ Hsb (in_map _ _ _ Hst) Hp1) as (va & Hl1 & Hia).
    cbn in Hia. destruct Hia as (bp & Hbq & ->).
    destruct (Hdp m p bp HI Hpin Hbq) as (bwd & Hbwd & Hpb4).
    destruct (Hscr _ bwd 0%nat _ Hbwd Hcin Hn0) as (vn & Hln & Hin0). cbn in Hin0. subst vn.
    assert (L4 : Mem.loadv Mint32 m (Vptr b (Ptrofs.add (Ptrofs.repr (4 * Z.of_nat (v_i st))) (Ptrofs.repr 4)))
                 = Some (Vptr bp Ptrofs.zero)).
    { cbn [Mem.loadv]. unfold Ptrofs.add.
      rewrite (Ptrofs.unsigned_repr (4 * _)), (Ptrofs.unsigned_repr 4), Ptrofs.unsigned_repr by (rewrite maxu; lia).
      replace (4 * Z.of_nat (v_i st) + 4) with (4 * Z.of_nat (v_i st + 1)) by lia. exact Hl1. }
    assert (P4 : Mem.loadv Mint32 m (Vptr bp (Ptrofs.add Ptrofs.zero (Ptrofs.repr 4)))
                 = Some (Vptr bwd Ptrofs.zero)).
    { cbn [Mem.loadv]. rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr by (rewrite maxu; lia). exact Hpb4. }
    destruct (ObjDroplet.wd_real lp H12 sb HsbR pool la fl bpg gol bc go Hpool Hla Hfl Hbpg Hgol Hbc Hgo
                m rs fs b (Ptrofs.repr (4 * Z.of_nat (v_i st))) bp Ptrofs.zero bwd Ptrofs.zero n
                (Vptr pool (Ptrofs.repr oc)) t m' vr
                Hr Hf Hnd Hg Hgl Hcm (Hinv_cur m HI) L4 P4 Hln H13 H4 H5 H10 Hev)
      as [E0 | (k & fs' & -> & Hk' & -> & Lbc & R' & F' & G' & U & HF)].
    { exfalso. exact (Hfr m st w fl fs HI Hst HQs Hw Ho Hfl Hf E0). }
    assert (Hne : k <> kc).
    { intros ->. apply (nd_app_disj _ _ kc Hnd Hkc). left. reflexivity. }
    assert (Vc : Vcmd m' (v_s st) (v_i st + 2)).
    { exists b. split; [ exact Hsb | rewrite Lbc, padd_repr ].
      replace (4 * Z.of_nat (v_i st) + 8) with (4 * Z.of_nat (v_i st + 2)) by lia. reflexivity. }
    assert (Hvp : Plt pool (Mem.nextblock m)) by (destruct HS as (Hsi & _); exact (valid_of_load _ _ _ _ _ Hsi)).
    assert (Hcell : forall z, oc + 460 <= z -> z + 4 <= oc + 500 -> Mem.load Mint32 m' pool z = Mem.load Mint32 m pool z).
    { intros z Hz1 Hz2. apply (Mem.load_unchanged_on_1 _ _ _ Mint32 pool z U Hvp).
      intros i Hi. change (size_chunk Mint32) with 4 in Hi.
      destruct (sc_cell la fl bpg k kc i Hpl Hpf Hpb Hk' Hne Ekc ltac:(lia)) as (C1 & C2 & C3).
      exact (conj C1 (conj C2 (conj C3 Hsp))). }
    assert (HS' : Vstk m' (v_k st)).
    { destruct HS as (Hsi & Hkk). split.
      - rewrite Hcell by (unfold OW.O_SIDX; lia). exact Hsi.
      - intros n0 f Hn0'. assert (Hlt : (n0 < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hn0'; discriminate).
        rewrite Hcell by (unfold OW.O_STK; lia). exact (Hkk n0 f Hn0'). }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - exact (V_mk m' st (v_s st) (v_i st + 2) (v_k st) Vc HS').
    - split; [ | left; reflexivity ].
      exact (Hk m st w la fl bpg bwd n rs k fs' m' HI Hst HQs Hw Ho Hla Hfl Hbpg Hbwd Hn0 Hr Hf Hk' R' F' G' U HF Vc).
  Qed.

  (* ---- ANIMATE (opcode 0x28 = 40): the REAL bhv_cmd_animate ----
     animIndex = byte2 w; animations = o->oAnimations (field 38);
     geo_obj_init_animation(&o->header.gfx, &animations[animIndex]) (walked in
     ObjAnimate.goia_real); gCurBhvCommand++; return 0 *)
  Lemma ufo_anims : forall co, (genv_cenv G) ! BS.__764 = Some co ->
    union_field_offset G BS._asAnims (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env BS.prog)); [ vm_compute; reflexivity | exact bs_cenv ]. Qed.
  Lemma fo_hdr : forall co, (genv_cenv G) ! BS._Object = Some co ->
    field_offset G BS._header (co_members co) = OK (0, Full).
  Proof. exact fo_header. Qed.

  (* o->rawData.asAnims + 38: the cell oc + 136 + 4 * 38 *)
  Lemma ev_anims38 : forall m le p b o,
    eval_expr G empty_env le m
      (Ebinop Oadd
         (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct BS._Object noattr))) (Tstruct BS._Object noattr))
            BS._rawData (Tunion BS.__764 noattr)) BS._asAnims
            (tarray (tptr (tptr (Tstruct BS._Animation noattr))) 80))
         (Econst_int (Int.repr 38) tint) (tptr (tptr (tptr (Tstruct BS._Animation noattr))))) (Vptr b o) ->
    le ! p = Some (Vptr pool (Ptrofs.repr oc)) ->
    b = pool /\ Ptrofs.unsigned o = oc + 136 + 4 * 38.
  Proof.
    intros m le p b o Hb Hp.
    apply RA.ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3).
    apply RA.ev_const in E2. subst v2.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (ufo_anims _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    all: match goal with Ht : ?l ! ?x = Some (Vptr _ _), Hq : ?l ! ?x = Some (Vptr pool _) |- _ =>
           tryif constr_eq Ht Hq then fail else (rewrite Hq in Ht; injection Ht as <- <-) end.
    all: cbn in E3; injection E3 as <- <-.
    all: split; [ reflexivity | ].
    all: unfold Ptrofs.of_ints; rewrite Int.signed_repr by (cbn; lia); apply raw_addr; lia.
  Qed.

  Lemma dm_goia : (prog_defmap graph_node.prog) ! BS._geo_obj_init_animation
    = Some (Gfun (Internal graph_node.f_geo_obj_init_animation)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma fun_gn : forall id f, (prog_defmap graph_node.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_graph_node lp H12)). Qed.
  Lemma gn_cenv : forall id co, (prog_comp_env graph_node.prog) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof. exact (ObjAlloc.cenv_of lp _ (linked12_LO_graph_node lp H12)). Qed.
  Lemma s2v_gn : forall b fd, Genv.find_symbol G graph_node._segmented_to_virtual = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal memory.f_segmented_to_virtual.
  Proof. intros b fd Hs Hf. exact (fun_mem _ _ dm_s2v b fd Hs Hf). Qed.

  (* the four animInfo stores keep the VM cells, gCurBhvCommand and cur *)
  Lemma an_stores : forall m va v1 v2 v3 ma mb mc md,
    Mem.store Mint32 m pool (oc + 56 + 4) va = Some ma ->
    Mem.store Mint16signed ma pool (oc + 56 + 8) v1 = Some mb ->
    Mem.store Mint32 mb pool (oc + 56 + 16) v2 = Some mc ->
    Mem.store Mint16signed mc pool (oc + 56 + 2) v3 = Some md ->
    (cur m -> cur md) /\ Mem.load Mint32 md bc 0 = Mem.load Mint32 m bc 0
    /\ (forall z, oc + 460 <= z -> Mem.load Mint32 md pool z = Mem.load Mint32 m pool z).
  Proof.
    intros m va v1 v2 v3 ma mb mc md S1 S2 S3 S4. split; [ | split ].
    - intros Hc. exact (cur_store _ _ _ _ _ S4 (cur_store _ _ _ _ _ S3 (cur_store _ _ _ _ _ S2 (cur_store _ _ _ _ _ S1 Hc)))).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ S4) by (left; exact Hbp).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S3) by (left; exact Hbp).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S2) by (left; exact Hbp).
      exact (Mem.load_store_other _ _ _ _ _ _ S1 _ _ _ (or_introl Hbp)).
    - intros z Hz.
      rewrite (Mem.load_store_other _ _ _ _ _ _ S4) by (right; right; cbn [size_chunk]; lia).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S3) by (right; right; cbn [size_chunk]; lia).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S2) by (right; right; cbn [size_chunk]; lia).
      apply (Mem.load_store_other _ _ _ _ _ _ S1). right. right. cbn [size_chunk]. lia.
  Qed.

  Definition an_post (m m1 : mem) (w : Z) : Prop :=
    m1 = m
    \/ exists bt ot va v1 v2 v3 ma mb mc,
         Mem.load Mint32 m pool (oc + 136 + 4 * 38) = Some (Vptr bt ot)
         /\ Mem.loadv Mint32 m (Vptr bt (Ptrofs.add ot (Ptrofs.mul (Ptrofs.repr 4)
                                                       (Ptrofs.of_ints (Int.repr (byte2 w)))))) = Some va
         /\ Mem.store Mint32 m pool (oc + 56 + 4) va = Some ma
         /\ Mem.store Mint16signed ma pool (oc + 56 + 8) v1 = Some mb
         /\ Mem.store Mint32 mb pool (oc + 56 + 16) v2 = Some mc
         /\ Mem.store Mint16signed mc pool (oc + 56 + 2) v3 = Some m1.

  Lemma hd_animate : forall m st w t m' vr,
    In st vm_tab -> scr_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 40 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_animate) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists m1, an_post m m1 w /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hscr HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_an st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsb & Hcm) & HS).
    destruct (word_int _ _ _ Hw) as (n & Hn & Ewn).
    destruct (Hscr (v_s st) b (v_i st) _ Hsb (in_map _ _ _ Hst) Hn) as (vn & Hlv & Hiv).
    cbn in Hiv. subst vn.
    assert (Hilt : (v_i st < List.length (words (v_s st)))%nat)
      by (apply nth_error_Some; rewrite Hn; discriminate).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI.
    try rewrite <- EI in Hlv. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_animate bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_animate] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    (* animIndex = ( *cmd >> 16) & 0xFF *)
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hcm) as (-> & -> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.set_inv in X5 as (vw & Evw & -> & -> & _).
    apply (ev_w0 _ _ _ b I4 n _ (PTree.gss _ _ _) ltac:(lia) Hlv) in Evw. subst vw.
    apply RA.set_inv in X6 as (vf & Evf & -> & -> & _).
    apply RA.ev_cast in Evf as (x2 & Ex2 & C2).
    apply RA.ev_binop in Ex2 as (a1 & a2 & Ea1 & Ea2 & Eand).
    apply RA.ev_binop in Ea1 as (s1 & s2 & Es1 & Es2 & Eshr).
    apply RA.ev_temp in Es1. rewrite PTree.gss in Es1. injection Es1 as <-.
    apply RA.ev_const in Es2. subst s2. apply RA.ev_const in Ea2. subst a2.
    cbn in Eshr. injection Eshr as <-. cbn in Eand. injection Eand as <-. cbn in C2. injection C2 as <-.
    match goal with X : exec_stmt _ _ _ (PTree.set BS._animIndex ?v _) _ _ _ _ _ _ |- _ =>
      change v with (Vint (Int.zero_ext 8 (Int.and (Int.shru n (Int.repr 16)) (Int.repr 255)))) in X end.
    (* animations = o->oAnimations *)
    apply RA.seq_inv in X2 as [(u1 & ke1 & mm1 & u2 & Y1 & Y2) | (Y1 & Xn)]; [ | kill_sq Y1 Xn ].
    apply RA.seq_inv in Y1 as [(u3 & ke3 & mm3 & u4 & Y3 & Y4) | (Y3 & Xn)]; [ | kill_sq Y3 Xn ].
    apply ld_cur in Y3 as (-> & -> & _); [ | exact Hc ].
    apply RA.set_inv in Y4 as (va & Eva & -> & -> & _).
    apply (ev_deref _ _ _ _ _ (tptr (tptr (Tstruct BS._Animation noattr))) Mint32 _ eq_refl) in Eva
      as (ba & oa & Eadd & Lva).
    apply ev_anims38 in Eadd as (-> & Eoa); [ | apply PTree.gss ].
    cbn [Mem.loadv] in Lva. rewrite Eoa in Lva.
    (* geo_obj_init_animation(&o->header.gfx, animations + animIndex) *)
    apply RA.seq_inv in Y2 as [(u5 & ke5 & mm5 & u6 & Y5 & Y6) | (Y5 & Xn)]; [ | kill_sq Y5 Xn ].
    apply RA.seq_inv in Y5 as [(u7 & ke7 & mm7 & u8 & Y7 & Y8) | (Y7 & Xn)]; [ | kill_sq Y7 Xn ].
    apply ld_cur in Y7 as (-> & -> & _); [ | exact Hc ].
    apply RA.call_inv in Y8 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env m _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_gn _ _ dm_goia bf fd Hsf Hff) in Hcall.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal) as (ty1 & ty2 & v1 & v2 & w1 & w2 & E1 & -> & Ev1 & C1 & Ev2 & C2').
    injection E1 as <- <-.
    (* arg 1: &o->header.gfx = the slot *)
    inv Ev1; try (match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end).
    match goal with Hlg : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      apply (ObjAnimate.lv_fld2 _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ fo_hdr fo_gfx) in Hlg as (og & Eog & -> & _) end.
    rewrite PTree.gss in Eog. injection Eog as <- <-.
    cbn [typeof] in C1. rewrite cast_pp in C1. injection C1 as <-.
    (* arg 2: animations + animIndex *)
    apply RA.ev_binop in Ev2 as (p1 & p2 & Ep1 & Ep2 & Epadd).
    apply RA.ev_temp in Ep1. repeat first [ rewrite PTree.gss in Ep1 | rewrite PTree.gso in Ep1 by RA.neq ].
    injection Ep1 as <-.
    apply RA.ev_temp in Ep2. repeat first [ rewrite PTree.gss in Ep2 | rewrite PTree.gso in Ep2 by RA.neq ].
    injection Ep2 as <-.
    cbn [typeof] in C2'. apply RA.cast_ptr_id in C2'. subst w2.
    destruct (ObjAnimate.goia_real G gn_cenv s2v_gn _ _ _ _ _ _ _ Hcall) as (ab & ao & -> & Hgi).
    cbn [typeof] in Epadd.
    apply ObjAnimate.padd_inv in Epadd as (ot & -> & ->). rename ab into bt.
    assert (Efi : Int.zero_ext 8 (Int.and (Int.shru n (Int.repr 16)) (Int.repr 255))
                  = Int.repr (byte2 (Int.unsigned n))).
    { rewrite <- (Int.repr_signed (Int.zero_ext 8 _)). apply (f_equal Int.repr). rewrite <- fld_eq, Int.zero_ext_idem by lia.
      reflexivity. }
    match type of Hgi with context [Ptrofs.of_ints ?X] =>
      change X with (Int.zero_ext 8 (Int.and (Int.shru n (Int.repr 16)) (Int.repr 255))) in Hgi end.
    rewrite Efi in Hgi. try rewrite <- Ewn in Hgi.
    rewrite !aio_eq in Hgi by lia.
    (* gCurBhvCommand++ ; return 0 *)
    apply RA.seq_inv in Y6 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    assert (Hpost : an_post m mm5 (Int.unsigned n) /\ (cur mm5) /\ Mem.load Mint32 mm5 bc 0 = Mem.load Mint32 m bc 0
                    /\ forall z, oc + 460 <= z -> Mem.load Mint32 mm5 pool z = Mem.load Mint32 m pool z).
    { destruct Hgi as [-> | (va' & w1 & w2' & w3 & ma & mb & mc & Lva' & S1 & S2 & S3 & S4)].
      - split; [ left; reflexivity | split; [ exact Hc | split; [ reflexivity | intros; reflexivity ] ] ].
      - destruct (an_stores _ _ _ _ _ _ _ _ _ S1 S2 S3 S4) as (Hc1 & Hb1 & Hp1).
        split; [ right; exists bt, ot, va', w1, w2', w3, ma, mb, mc | split; [ exact (Hc1 Hc) | split; [ exact Hb1 | exact Hp1 ] ] ].
        exact (conj Lva (conj Lva' (conj S1 (conj S2 (conj S3 S4))))). }
    destruct Hpost as (Hpost & Hc5 & Hb5 & Hp5).
    assert (Lc : Mem.load Mint32 mm5 bc 0 = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st))))) by (rewrite Hb5; exact Hcm).
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs2 & -> & _).
    apply RA.ev_binop in Ev4 as (q1 & q2 & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs2 by lia. assert (Hs2x : Mem.store Mint32 mm5 bc 0 (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st + 1)))) = Some n11) by (replace (4 * Z.of_nat (v_i st + 1)) with (4 * Z.of_nat (v_i st) + 4 * 1) by lia; exact Hs2). clear Hs2. rename Hs2x into Hs2.
    destruct (bc_store _ _ _ Hs2) as (Hc2 & _ & U2).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    assert (HS1 : Vstk mm5 (v_k st)).
    { destruct HS as (Hsi & Hk). split.
      - rewrite Hp5 by (unfold OW.O_SIDX; lia). exact Hsi.
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite Hp5 by (unfold OW.O_STK; lia). exact (Hk j f Hj). }
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs2 Hsb) | exact (Vstk_bc _ _ _ _ HS1 Hs2) ].
    - split; [ exact (Hc2 Hc5) | split; [ reflexivity | ] ].
      exists mm5. exact (conj Hpost U2).
  Qed.

  (* ANIMATE's row (opcode 40).  Computed reachable users (vm_animate_users):
     bhvBobombBuddyOpensCannon, bhvEndToad, bhvEndPeach, all with index 0.
     The handler and geo_obj_init_animation are walked whole (hd_animate,
     ObjAnimate.goia_real); the run either writes nothing or the four
     animInfo cells of the CURRENT slot (curAnim @60 := animations[index],
     the pointer the slot's oAnimations table holds; animFrame @64,
     animAccel @72, animYTrans @58).  Pinned: an_keep -- INV survives those
     four stores (obj_w reads no animInfo cell; PhiW pins Mario's, and no
     user is Mario) *)
  Definition an_keep : Prop := forall m st w m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 40 -> an_post m m1 w -> INV m1.

  Lemma row_animate : an_keep -> cmd_row_op 40.
  Proof.
    intros Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 40) = Some BS._bhv_cmd_animate)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_animate
                  = Some (Gfun (Internal BS.f_bhv_cmd_animate))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_animate _ _ _ _ _ _ Hst (proj1 (Hinv m HI)) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & m1 & Hp & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ HI Hst HQs Hw Ho Hp) U).
    - left. reflexivity.
  Qed.

  (* ---- DROP_TO_FLOOR (0x1E): x, y, z = o->oPosX/Y/Z (fields 6-8);
     o->oPosY = find_floor_height(x, y + 200.0f, z);
     o->oMoveFlags (field 25) |= OBJ_MOVE_ON_GROUND (1 << 1); cmd += 1 ---- *)
  Lemma fun_sc : forall id f, (prog_defmap surface_collision.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_surf lp H12)). Qed.

  Lemma sc_cenv_has : FloorList.cenv_has G.
  Proof.
    intros id co Hco. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp surface_collision.prog id co (linked12_LO_surf lp H12) Hco).
  Qed.

  Lemma sc_ffl_pin : FloorList.ffl_pinned G.
  Proof.
    intros bf f Hs Hf. apply (fun_sc _ _ dm_ffl0 bf f Hs). rewrite Genv.find_funct_find_funct_ptr. exact Hf.
  Qed.

  (* find_floor's three statics are none of the stepper's blocks *)
  Lemma nst : forall b, FloorList.is_static G b -> b <> pool /\ b <> bc /\ b <> go.
  Proof.
    intros b (id & Hin & Hs).
    assert (Hne : forall id2 b2, Genv.find_symbol G id2 = Some b2 -> id <> id2 -> b <> b2)
      by (intros id2 b2 H2 Hn; exact (Genv.global_addresses_distinct G Hn Hs H2)).
    unfold FloorList.ff_statics in Hin. cbn [In] in Hin.
    split; [ apply (Hne _ _ Hpool) | split; [ apply (Hne _ _ Hbc) | apply (Hne _ _ Hgo) ] ].
    all: destruct Hin as [<- | [<- | [<- | []]]]; RA.neq.
  Qed.

  Lemma ns_load : forall m m1 ch b z v, Mem.unchanged_on (ObjFloorH.ns G m) m m1 ->
    ~ FloorList.is_static G b -> Mem.load ch m b z = Some v -> Mem.load ch m1 b z = Some v.
  Proof.
    intros m m1 ch b z v U Hn Hl.
    assert (Hv : Mem.valid_block m b).
    { pose proof (Mem.load_valid_access _ _ _ _ _ Hl) as Ha. eapply Mem.valid_access_valid_block.
      eapply Mem.valid_access_implies; [ exact Ha | constructor ]. }
    apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros i _; split; [ exact Hv | exact Hn ] | exact Hl ].
  Qed.

  Lemma ns_V : forall m m1 st, Mem.unchanged_on (ObjFloorH.ns G m) m m1 -> V m st -> V m1 st.
  Proof.
    intros m m1 st U HV. apply V_iff in HV as ((b & Hsb' & Hcm) & Hsi & Hk). apply V_iff.
    split; [ exists b; split; [ exact Hsb' | ] | split ].
    - apply (ns_load m m1 _ _ _ _ U); [ intros Hs; exact (proj1 (proj2 (nst _ Hs)) eq_refl) | exact Hcm ].
    - apply (ns_load m m1 _ _ _ _ U); [ intros Hs; exact (proj1 (nst _ Hs) eq_refl) | exact Hsi ].
    - intros j f Hj. specialize (Hk j f Hj). unfold OW.frame_ok in Hk |- *.
      destruct f as [s0 i0 |].
      + destruct Hk as (b0 & Hb0 & Hl). exists b0. split; [ exact Hb0 | ].
        apply (ns_load m m1 _ _ _ _ U); [ intros Hs; exact (proj1 (nst _ Hs) eq_refl) | exact Hl ].
      + destruct Hk as (c & Hl). exists c.
        apply (ns_load m m1 _ _ _ _ U); [ intros Hs; exact (proj1 (nst _ Hs) eq_refl) | exact Hl ].
  Qed.

  Lemma ns_cur : forall m m1, Mem.unchanged_on (ObjFloorH.ns G m) m m1 -> cur m -> cur m1.
  Proof.
    intros m m1 U Hc. unfold cur.
    apply (ns_load m m1 _ _ _ _ U); [ intros Hs; exact (proj2 (proj2 (nst _ Hs)) eq_refl) | exact Hc ].
  Qed.

  (* what DROP_TO_FLOOR does: three reads of the slot, the REAL
     find_floor_height run (with its footprint: only find_floor's three
     statics change, no permission changes), then oPosY := the result and
     oMoveFlags |= 2 *)
  Definition dtf_post (m m1 : mem) : Prop :=
    exists fx fy fz tc mA h mB fl,
      Mem.load Mfloat32 m pool (oc + 136 + 4 * 6) = Some (Vsingle fx)
      /\ Mem.load Mfloat32 m pool (oc + 136 + 4 * 7) = Some (Vsingle fy)
      /\ Mem.load Mfloat32 m pool (oc + 136 + 4 * 8) = Some (Vsingle fz)
      /\ eval_funcall function_entry2 G m (Internal surface_collision.f_find_floor_height)
           [Vsingle fx; Vsingle (Float32.add fy c200); Vsingle fz] tc mA (Vsingle h)
      /\ Mem.unchanged_on (ObjFloorH.ns G m) m mA
      /\ (forall b i k p, Mem.valid_block m b -> (Mem.perm m b i k p <-> Mem.perm mA b i k p))
      /\ Mem.store Mfloat32 mA pool (oc + 136 + 4 * 7) (Vsingle h) = Some mB
      /\ Mem.load Mint32 mB pool (oc + 136 + 4 * 25) = Some (Vint fl)
      /\ Mem.store Mint32 mB pool (oc + 136 + 4 * 25)
           (Vint (Int.or fl (Int.shl (Int.repr 1) (Int.repr 1)))) = Some m1.

  Lemma hd_drop_to_floor : forall m st w t m' vr,
    In st vm_tab -> ObjFloorH.ff_ok G m -> V m st -> cur m ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 30 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_drop_to_floor) [] t m' vr ->
    exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ cur m' /\ vr = Vint (Int.repr 0)
      /\ exists m1, dtf_post m m1 /\ Mem.unchanged_on Pfr m1 m'.
  Proof.
    intros m st w t m' vr Hst Hff HV Hc Hw Ho H.
    destruct (st_facts st Hst) as (Hlen & _ & Hd & l & Hl & Hcl).
    pose proof (succs_dtf st w Hw Ho) as Es. rewrite Hl in Es.
    destruct (Nat.ltb _ _) eqn:Elt; [ discriminate Es | ]. apply Nat.ltb_ge in Elt.
    injection Es as Es. subst l.
    apply V_iff in HV as ((b & Hsbs & Hcm) & HS).
    remember (4 * Z.of_nat (v_i st)) as I4 eqn:EI. try rewrite <- EI in Hcm.
    apply fcall_inv in H as (le1 & le2 & out1 & Hb & X & Hor); [ | reflexivity ].
    cbn [fn_params BS.f_bhv_cmd_drop_to_floor bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body BS.f_bhv_cmd_drop_to_floor] in X.
    (* x = o->oPosX *)
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply RA.seq_inv in X1 as [(a1x & ae1x & am1x & a2x & A1x & A2x) | (A1x & Xn)]; [ | kill_sq A1x Xn ].
    apply ld_cur in A1x as (-> & -> & _); [ | exact Hc ].
    apply RA.set_inv in A2x as (vvx & Evx & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in Evx as (brx & orx & Eax & Hldx).
    destruct (lv_rawf_any _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tfloat _ _ Eax))
      as (b0rx & o0rx & virx & Hprx & _ & Eirx & Earx).
    rewrite PTree.gss in Hprx. injection Hprx as <- <-.
    apply RA.ev_binop in Eirx as (i1x & i2x & Ei1x & Ei2x & Eiax).
    apply RA.ev_const in Ei1x. apply RA.ev_const in Ei2x. subst i1x i2x.
    cbn in Eiax. injection Eiax as <-.
    apply (raw_cidx _ _ _ 6 _ _ _ Hoc ltac:(lia) eq_refl) in Earx as (Ebrx & Earx). subst brx.
    cbn [Mem.loadv] in Hldx. rewrite Earx in Hldx.
    (* y = o->oPosY *)
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.seq_inv in X3 as [(a1y & ae1y & am1y & a2y & A1y & A2y) | (A1y & Xn)]; [ | kill_sq A1y Xn ].
    apply ld_cur in A1y as (-> & -> & _); [ | exact Hc ].
    apply RA.set_inv in A2y as (vvy & Evy & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in Evy as (bry & ory & Eay & Hldy).
    destruct (lv_rawf_any _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tfloat _ _ Eay))
      as (b0ry & o0ry & viry & Hpry & _ & Eiry & Eary).
    rewrite PTree.gss in Hpry. injection Hpry as <- <-.
    apply RA.ev_binop in Eiry as (i1y & i2y & Ei1y & Ei2y & Eiay).
    apply RA.ev_const in Ei1y. apply RA.ev_const in Ei2y. subst i1y i2y.
    cbn in Eiay. injection Eiay as <-.
    apply (raw_cidx _ _ _ 7 _ _ _ Hoc ltac:(lia) eq_refl) in Eary as (Ebry & Eary). subst bry.
    cbn [Mem.loadv] in Hldy. rewrite Eary in Hldy.
    (* z = o->oPosZ *)
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_sq X5 Xn ].
    apply RA.seq_inv in X5 as [(a1z & ae1z & am1z & a2z & A1z & A2z) | (A1z & Xn)]; [ | kill_sq A1z Xn ].
    apply ld_cur in A1z as (-> & -> & _); [ | exact Hc ].
    apply RA.set_inv in A2z as (vvz & Evz & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tfloat Mfloat32 _ eq_refl) in Evz as (brz & orz & Eaz & Hldz).
    destruct (lv_rawf_any _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tfloat _ _ Eaz))
      as (b0rz & o0rz & virz & Hprz & _ & Eirz & Earz).
    rewrite PTree.gss in Hprz. injection Hprz as <- <-.
    apply RA.ev_binop in Eirz as (i1z & i2z & Ei1z & Ei2z & Eiaz).
    apply RA.ev_const in Ei1z. apply RA.ev_const in Ei2z. subst i1z i2z.
    cbn in Eiaz. injection Eiaz as <-.
    apply (raw_cidx _ _ _ 8 _ _ _ Hoc ltac:(lia) eq_refl) in Earz as (Ebrz & Earz). subst brz.
    cbn [Mem.loadv] in Hldz. rewrite Earz in Hldz.
    (* t'1 = find_floor_height(x, y + 200.0f, z); floor = t'1 *)
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)]; [ | kill_sq X7 Xn ].
    apply RA.seq_inv in X7 as [(c1 & ce1 & cm1 & c2 & D1 & D2) | (D1 & Xn)]; [ | kill_sq D1 Xn ].
    apply RA.call_inv in D1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hfd & _ & Hcall & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_sc _ _ dm_ffh bf fd Hsf Hfd) in Hcall.
    destruct (ObjFloorH.exl3 _ _ _ _ _ _ _ _ _ Eal)
      as (ty1 & ty2 & ty3 & v1 & v2 & v3 & w1 & w2 & w3 & E1 & -> & Ev1 & C1 & Ev2 & C2 & Ev3 & C3).
    injection E1 as <- <- <-.
    apply RA.ev_temp in Ev1. RA.getnorm Ev1. injection Ev1 as <-.
    apply RA.ev_temp in Ev3. RA.getnorm Ev3. injection Ev3 as <-.
    apply RA.ev_binop in Ev2 as (p1 & p2 & Ep1 & Ep2 & Eadd2).
    apply RA.ev_temp in Ep1. RA.getnorm Ep1. injection Ep1 as <-.
    apply RA.ev_single in Ep2. subst p2.
    destruct vvx as [ | ? | ? | ? | fx | ? ? ]; try (cbn in C1; discriminate C1).
    cbn in C1. injection C1 as <-.
    destruct vvz as [ | ? | ? | ? | fz | ? ? ]; try (cbn in C3; discriminate C3).
    cbn in C3. injection C3 as <-.
    destruct vvy as [ | ? | ? | ? | fy | ? ? ]; try (cbn in Eadd2; discriminate Eadd2).
    cbn -[Float32.add Float32.of_bits] in Eadd2. injection Eadd2 as <-.
    cbn -[Float32.add Float32.of_bits] in C2. injection C2 as <-.
    destruct (ObjFloorH.ffh_foot G sc_cenv_has sc_ffl_pin (fun_sc _ _ dm_ff0) m _ _ _ _ _ _ Hff Hcall)
      as (U1 & Hperm & h & ->).
    pose proof (ns_cur _ _ U1 Hc) as Hc1.
    assert (Hcm1 : Mem.load Mint32 cm1 bc 0 = Some (Vptr b (Ptrofs.repr I4)))
      by (apply (ns_load m cm1 _ _ _ _ U1); [ intros Hs; exact (proj1 (proj2 (nst _ Hs)) eq_refl) | exact Hcm ]).
    apply RA.set_inv in D2 as (vfl & Evfl & -> & -> & _).
    apply RA.ev_temp in Evfl. cbn [set_opttemp] in Evfl. rewrite PTree.gss in Evfl. injection Evfl as <-.
    (* o->oPosY = floor *)
    apply RA.seq_inv in X8 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Xn)]; [ | kill_sq X9 Xn ].
    apply RA.seq_inv in X9 as [(a1w & ae1w & am1w & a2w & A1w & A2w) | (A1w & Xn)]; [ | kill_sq A1w Xn ].
    apply ld_cur in A1w as (-> & -> & _); [ | exact Hc1 ].
    apply RA.assign_inv in A2w as (b2w & o2w & bf2w & v2w & v3w & Hlxw & Exw & Hcastw & Hasw & -> & _).
    destruct (lv_rawf_any _ _ _ _ _ _ _ Hlxw) as (b0ww & o0ww & viww & Hpww & -> & Eiww & Eaww).
    rewrite PTree.gss in Hpww. injection Hpww as <- <-.
    apply RA.ev_binop in Eiww as (i1w & i2w & Ei1w & Ei2w & Eiaw).
    apply RA.ev_const in Ei1w. apply RA.ev_const in Ei2w. subst i1w i2w.
    cbn in Eiaw. injection Eiaw as <-.
    apply (raw_cidx _ _ _ 7 _ _ _ Hoc ltac:(lia) eq_refl) in Eaww as (Ebww & Eaww). subst b2w.
    apply RA.ev_temp in Exw. RA.getnorm Exw. injection Exw as <-.
    cbn in Hcastw. injection Hcastw as <-.
    pose proof (RA.store_by_value _ tfloat _ _ _ _ _ _ Mfloat32 eq_refl eq_refl Hasw) as Hsy.
    rewrite Eaww in Hsy.
    pose proof (cur_store _ _ _ _ _ Hsy Hc1) as Hc2.
    (* o->oMoveFlags |= OBJ_MOVE_ON_GROUND *)
    apply RA.seq_inv in X10 as [(t11 & le11 & m11 & t12 & X11 & X12) | (X11 & Xn)]; [ | kill_sq X11 Xn ].
    apply RA.seq_inv in X11 as [(g1 & ge1 & gm1 & g2 & G1 & G2) | (G1 & Xn)]; [ | kill_sq G1 Xn ].
    apply ld_cur in G1 as (-> & -> & _); [ | exact Hc2 ].
    apply RA.seq_inv in G2 as [(g3 & ge3 & gm3 & g4 & G3 & G4) | (G3 & Xn)]; [ | kill_sq G3 Xn ].
    apply ld_cur in G3 as (-> & -> & _); [ | exact Hc2 ].
    apply RA.seq_inv in G4 as [(g5 & ge5 & gm5 & g6 & G5 & G6) | (G5 & Xn)]; [ | kill_sq G5 Xn ].
    apply RA.set_inv in G5 as (vmf & Evmf & -> & -> & _).
    apply (ev_deref _ _ _ _ _ tuint Mint32 _ eq_refl) in Evmf as (bmf & omf & Eamf & Hldmf).
    destruct (lv_rawuc _ _ _ _ _ _ _ (eval_Ederef _ _ _ _ _ tuint _ _ Eamf)) as (o0f & Ho0f & _ & ->).
    rewrite PTree.gss in Ho0f. injection Ho0f as <- <-.
    change (Ptrofs.of_ints (Int.repr 25)) with (Ptrofs.repr 25) in Hldmf.
    cbn [Mem.loadv] in Hldmf. rewrite raw_addr in Hldmf by lia.
    apply RA.assign_inv in G6 as (b3 & o3 & bf3 & v6 & v7 & Hlv3 & Ev6 & Hcast3 & Has3 & -> & _).
    destruct (lv_rawuc _ _ _ _ _ _ _ Hlv3) as (o0g & Ho0g & -> & ->).
    RA.getnorm Ho0g. injection Ho0g as <- <-.
    apply RA.ev_binop in Ev6 as (r1 & r2 & Er1 & Er2 & Eor).
    apply RA.ev_temp in Er1. rewrite PTree.gss in Er1. injection Er1 as <-.
    apply RA.ev_binop in Er2 as (s1 & s2 & Es1 & Es2 & Eshl).
    apply RA.ev_const in Es1. apply RA.ev_const in Es2. subst s1 s2.
    cbn -[Int.shl] in Eshl. injection Eshl as <-.
    destruct vmf as [| fl | | | | ]; cbn -[Int.or Int.shl] in Eor; try discriminate Eor.
    injection Eor as <-. cbn -[Int.or Int.shl] in Hcast3. injection Hcast3 as <-.
    pose proof (RA.store_by_value _ tuint _ _ _ _ _ _ Mint32 eq_refl eq_refl Has3) as Hsfl.
    change (Ptrofs.of_ints (Int.repr 25)) with (Ptrofs.repr 25) in Hsfl. rewrite raw_addr in Hsfl by lia.
    pose proof (cur_store _ _ _ _ _ Hsfl Hc2) as Hc3.
    match type of Hsfl with Mem.store _ _ _ _ _ = Some ?MC =>
      assert (Lc : Mem.load Mint32 MC bc 0 = Some (Vptr b (Ptrofs.repr I4)))
        by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hsfl) by (left; exact Hbp);
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsy) by (left; exact Hbp); exact Hcm1);
      assert (HSx : Vstk MC (v_k st)) end.
    { destruct HS as (Hsi & Hk). split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hsfl) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsy) by (right; right; cbn [size_chunk]; unfold OW.O_SIDX; lia).
        apply (ns_load m cm1 _ _ _ _ U1); [ intros Hs; exact (proj1 (nst _ Hs) eq_refl) | exact Hsi ].
      - intros j f Hj.
        assert (Hjl : (j < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsfl) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hsy) by (right; right; cbn [size_chunk]; unfold OW.O_STK; lia).
        pose proof (Hk j f Hj) as Hf.
        destruct f as [s0 i0 |];
          [ destruct Hf as (b0 & Hb0 & Hl0); exists b0; split; [ exact Hb0 | ]
          | destruct Hf as (c & Hl0); exists c ];
          (apply (ns_load m cm1 _ _ _ _ U1); [ intros Hs; exact (proj1 (nst _ Hs) eq_refl) | exact Hl0 ]). }
    (* cmd = cmd + 1 *)
    apply RA.seq_inv in X12 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)]; [ | kill_sq Y11 Xn ].
    apply RA.seq_inv in Y11 as [(u13 & ke13 & n13 & u14 & Y13 & Y14) | (Y13 & Xn)]; [ | kill_sq Y13 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ Y13 Lc) as (-> & -> & _).
    apply st_cmd in Y14 as (v4 & v5 & Ev4 & Hcast4 & Hs9 & -> & _).
    apply RA.ev_binop in Ev4 as (q1' & q2' & Eq1 & Eq2 & Eadd).
    apply RA.ev_temp in Eq1. rewrite PTree.gss in Eq1. injection Eq1 as <-.
    apply RA.ev_const in Eq2. subst q2'. cbn [typeof] in Eadd. rewrite add_pi in Eadd. injection Eadd as <-.
    cbn [typeof] in Hcast4. rewrite cast_pp in Hcast4. injection Hcast4 as <-.
    rewrite ptr_inc in Hs9 by lia. norm_off Hs9 (4 * Z.of_nat (v_i st + 1)).
    destruct (bc_store _ _ _ Hs9) as (Hc9 & _ & U9).
    apply RA.ret_inv in Y12 as (-> & rv & Erv & ->). apply RA.ev_const in Erv. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn in Hor. injection Hor as <-.
    eexists _, _. split; [ exact Hl | split; [ left; reflexivity | split ] ].
    - apply V_mk; [ exact (Vcmd_bc _ _ _ _ _ Hs9 Hsbs) | exact (Vstk_bc _ _ _ _ HSx Hs9) ].
    - split; [ exact (Hc9 Hc3) | split; [ reflexivity | ] ].
      eexists. split; [ | exact U9 ].
      exists fx, fy, fz. eexists. exists cm1, h. eexists. exists fl.
      split; [ exact Hldx | split; [ exact Hldy | split; [ exact Hldz | split; [ exact Hcall |
        split; [ exact U1 | split; [ exact Hperm | split; [ exact Hsy | split; [ exact Hldmf | exact Hsfl ] ] ] ] ] ] ] ].
  Qed.

  (* DROP_TO_FLOOR's row (opcode 30).  The handler and find_floor_height
     are walked whole (hd_drop_to_floor, ObjFloorH.ffh_foot, on top of
     FloorList.ff_value_contract for find_floor).  Pinned: dtf_ff -- INV
     gives find_floor's entry facts (statics and partitions allocated,
     partition lists well formed off the statics; ObjWorld's surface
     clause) -- and dtf_keep -- INV survives dtf_post *)
  Definition dtf_ff : Prop := forall m, INV m -> ObjFloorH.ff_ok G m.
  Definition dtf_keep : Prop := forall m st w m1, INV m -> In st vm_tab -> Qs st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 30 -> dtf_post m m1 -> INV m1.

  Lemma row_drop_to_floor : dtf_ff -> dtf_keep -> cmd_row_op 30.
  Proof.
    intros Hf Hk m st w id hb fd t m' vr Hst HQs HV HI Hw Ho Hid Hhb Hfd Hev.
    assert (E : nth_error ObjCensus.cmd_handlers (Z.to_nat 30) = Some BS._bhv_cmd_drop_to_floor)
      by (vm_compute; reflexivity).
    rewrite E in Hid. injection Hid as <-.
    assert (Hdm : (prog_defmap BS.prog) ! BS._bhv_cmd_drop_to_floor
                  = Some (Gfun (Internal BS.f_bhv_cmd_drop_to_floor))) by (vm_compute; reflexivity).
    rewrite (fun_bs _ _ Hdm _ _ Hhb Hfd) in Hev.
    destruct (hd_drop_to_floor _ _ _ _ _ _ Hst (Hf m HI) HV (Hinv_cur m HI) Hw Ho Hev)
      as (l & st' & Hl & Hin & HV' & _ & -> & m1 & Hp & U).
    exists l, st'. split; [ exact Hl | split; [ exact Hin | split; [ exact HV' | split ] ] ].
    - exact (Hinv_frame _ _ (Hk _ _ _ _ HI Hst HQs Hw Ho Hp) U).
    - left. reflexivity.
  Qed.

  (* the pinned one-store premises of the field commands, together *)
  Definition row_keeps : Prop := set_keep /\ setf_keep /\ addi_keep /\ ori_keep /\ addf_keep /\ sumf_keep /\ deact_keep /\ sit_keep /\ srf_keep /\ sri_keep /\ sir_keep /\ par51_ok /\ pbc_keep /\ atex_keep /\ bb_keep /\ dr_keep /\ hb_keep /\ hbo_keep /\ home_keep /\ phys_keep /\ la_keep /\ lcd_keep /\ scale_keep /\ begin_ok /\ sfr_keep /\ native_vals /\ native_res
    /\ sc_pre /\ sc_free /\ sc_keep /\ wd_pre /\ wd_free /\ wd_dp /\ wd_keep /\ an_keep /\ dtf_ff /\ dtf_keep.

  (* the opcodes whose rows are proved: the control layer, DELAY_VAR, and
     SET_INT / SET_FLOAT / ADD_INT / OR_INT / ADD_FLOAT / SUM_FLOAT / DEACTIVATE / SET_INTERACT_TYPE / SET_RANDOM_FLOAT / SET_RANDOM_INT / SET_INT_RAND_RSHIFT / PARENT_BIT_CLEAR / ANIMATE_TEXTURE / BILLBOARD / DISABLE_RENDERING / SET_HITBOX(_WITH_OFFSET) / SET_HOME / SET_OBJ_PHYSICS / LOAD_ANIMATIONS / LOAD_COLLISION_DATA / SCALE / BEGIN / CALL_NATIVE / SPAWN_CHILD (from row_keeps) *)
  Definition done_ops : list Z := 30 :: 40 :: 55 :: 28 :: 12 :: 0 :: 50 :: 39 :: 42 :: 48 :: 45 :: 35 :: 43 :: 33 :: 53 :: 52 :: 51 :: 21 :: 19 :: 20 :: 47 :: 29 :: 31 :: 13 :: 17 :: 15 :: 14 :: 16 :: 37 :: ctl_ops.

  Lemma done_rows : row_keeps -> forall op, In op done_ops -> cmd_row_op op.
  Proof.
    intros (K16 & K14 & K15 & K17 & K13 & K31 & K29 & K47 & K20 & K21 & K19 & K51p & K51 & K52 & K33 & K53 & K35 & K43 & K45 & K48 & K39 & K42 & K50 & K0 & K12a & K12v & K12b & K28a & K28b & K28c & K55a & K55b & K55c & K55d & K40 & K30a & K30b) op
      [<- | [<- |[<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | H]]]]]]]]]]]]]]]]]]]]]]]]]]]]];
      [ exact (row_drop_to_floor K30a K30b) | exact (row_animate K40) | exact (row_spawn_water_droplet K55a K55b K55c K55d) | exact (row_spawn_child K28a K28b K28c) | exact (row_call_native (native_keep_of K12a K12v K12b)) | exact (row_begin K0) | exact (row_scale K50) | exact (row_load_animations K39) | exact (row_load_collision_data K42) | exact (row_set_obj_physics K48) | exact (row_set_home K45) | exact (row_set_hitbox K35) | exact (row_set_hitbox_with_offset K43) | exact (row_billboard K33) | exact (row_disable_rendering K53) | exact (row_animate_texture K52) | exact (row_parent_bit_clear K51p K51) | exact (row_set_random_int K21) | exact (row_set_int_rand_rshift K19) | exact (row_set_random_float K20) | exact (row_set_interact_type K47) | exact (row_deactivate K29) | exact (row_sum_float K31) | exact (row_add_float K13) | exact (row_or_int K17) | exact (row_add_int K15)
      | exact (row_set_float K14) | exact (row_set_int K16) | exact row_delay_var | exact (ctl_rows op H) ].
  Qed.

  (* every opcode the reachable VM executes has its row proved *)
  Lemma used_done : forall op, In op used_ops -> In op done_ops.
  Proof.
    intros op Hu. assert (A : forallb (fun o => existsb (Z.eqb o) done_ops) used_ops = true)
      by (vm_compute; reflexivity).
    rewrite forallb_forall in A. specialize (A op Hu).
    apply existsb_exists in A as (x & Hx & Ex). apply Z.eqb_eq in Ex. subst x. exact Hx.
  Qed.

  Theorem dloop_done : row_keeps ->
    forall le m t le' m' out, exec_stmt function_entry2 G empty_env le m DLOOP t le' m' out ->
    forall st, In st vm_tab -> Qs st -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ Qs st' /\ V m' st' /\ INV m'.
  Proof.
    intros Hk. apply dloop_used. intros op Hu Hn. exact (done_rows Hk op (used_done op Hu)).
  Qed.

  (* ---- the segment: copy-in, the loop, copy-out ---- *)
  (* the VM state st in the SLOT's own cells (between frames): the same
     shape as obj_w's ow_vm clause (vm_ok_Vo / Vo_vm_ok) *)
  Definition Vo (m : mem) (st : vst) : Prop :=
    (exists b, Genv.find_symbol G (v_s st) = Some b
       /\ Mem.load Mint32 m pool (oc + OW.O_CMD) = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat (v_i st)))))
    /\ Vstk m (v_k st).

  Lemma vm_ok_Vo : forall m k, oc = k * OW.OSZ -> OW.vm_ok G pool m k ->
    exists st, In st vm_tab /\ Vo m st.
  Proof.
    intros m k Ek (st & Hst & Hc & Hsi & Hk). exists st. split; [ exact Hst | ].
    unfold OW.stk_cell in Hk. unfold Vo, Vstk. rewrite Ek.
    split; [ exact Hc | split; [ exact Hsi | exact Hk ] ].
  Qed.

  Lemma Vo_vm_ok : forall m k st, oc = k * OW.OSZ -> In st vm_tab -> Vo m st -> OW.vm_ok G pool m k.
  Proof.
    intros m k st Ek Hst (Hc & Hsi & Hk). rewrite Ek in Hc, Hsi, Hk.
    exists st. split; [ exact Hst | split; [ exact Hc | split; [ exact Hsi | ] ] ].
    unfold OW.stk_cell. exact Hk.
  Qed.

  Lemma copyin : forall le m t le' m' out st,
    exec_stmt function_entry2 G empty_env le m COPYIN t le' m' out -> cur m -> Vo m st ->
    out = Out_normal /\ V m' st /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros le m t le' m' out st H Hc ((b & Hb & Hl) & Hk). unfold COPYIN in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply ld_cur in X1 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    apply RA.set_inv in X3 as (v & Ev & -> & -> & _).
    destruct (RA.ev_fld G empty_env m _ _ _ _ (tptr tuint) v Mint32 OW.O_CMD fo_cmd eq_refl Ev)
      as (b0 & o & Hb0 & Hl').
    rewrite PTree.gss in Hb0. injection Hb0 as <- <-. cbn [Mem.loadv] in Hl'.
    rewrite uadd in Hl' by (unfold OW.O_CMD; try rewrite maxu; lia). rewrite Hl in Hl'. injection Hl' as <-.
    apply st_cmd in X4 as (v2 & v & Ev2 & Hcast & Hs & -> & ->).
    apply RA.ev_temp in Ev2. rewrite PTree.gss in Ev2. injection Ev2 as <-.
    cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
    destruct (bc_store _ _ _ Hs) as (_ & _ & U).
    split; [ reflexivity | split; [ apply V_iff; split | exact U ] ].
    - exact (Vcmd_bc _ _ _ _ _ Hs Hb).
    - exact (Vstk_bc _ _ _ _ Hk Hs).
  Qed.

  Lemma copyout : forall le m t le' m' out st,
    exec_stmt function_entry2 G empty_env le m COPYOUT t le' m' out -> cur m -> V m st ->
    out = Out_normal /\ Vo m' st /\ Mem.unchanged_on Pfr m m'.
  Proof.
    intros le m t le' m' out st H Hc HV. apply V_iff in HV as ((b & Hb & Hl) & (Hsi & Hk)).
    unfold COPYOUT in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq X1 Xn ].
    apply ld_cur in X1 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_sq X3 Xn ].
    destruct (ld_cmd _ _ _ _ _ _ _ _ X3 Hl) as (-> & -> & _).
    apply RA.assign_inv in X4 as (b2 & o2 & bf2 & w2 & w3 & Hlv & Ew & Hcast & Has & -> & ->).
    destruct (RA.lv_fld G empty_env m _ _ _ _ _ _ _ _ _ fo_cmd Hlv) as (o1 & Ho1 & -> & ->).
    rewrite PTree.gso, PTree.gss in Ho1 by (vm_compute; discriminate). injection Ho1 as <- <-.
    apply RA.ev_temp in Ew. rewrite PTree.gss in Ew. injection Ew as <-.
    cbn [typeof] in Hcast. rewrite cast_pp in Hcast. injection Hcast as <-.
    pose proof (RA.store_by_value _ (tptr tuint) _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs.
    rewrite uadd in Hs by (unfold OW.O_CMD; try rewrite maxu; lia).
    split; [ reflexivity | split; [ split; [ | split ] | ] ].
    - exists b. split; [ exact Hb | ]. rewrite (Mem.load_store_same _ _ _ _ _ _ Hs). reflexivity.
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hsi | ].
      right. right. change (size_chunk Mint32) with 4. unfold OW.O_CMD, OW.O_SIDX. lia.
    - intros n f Hn.
      assert (Hnl : (n < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hn; discriminate).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact (Hk n f Hn) | ].
      right. right. change (size_chunk Mint32) with 4. unfold OW.O_CMD, OW.O_STK. lia.
    - apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i Hi [_ Hn]. apply Hn.
      split; [ reflexivity | ]. change (size_chunk Mint32) with 4 in Hi.
      unfold OW.O_CMD, OW.O_STK in *. lia.
  Qed.

  (* THE SEGMENT: from a slot whose own cells hold a reachable state, the
     real copy-in, dispatch loop and copy-out leave the slot's cells
     holding a reachable state, keeping INV -- every used row is proved
     (used_done); what remains is row_keeps, premises about INV *)
  Theorem seg : row_keeps ->
    forall le0 m0 t1 le1 m1 out1 t2 le2 m2 out2 t3 le3 m3 out3 st,
    In st vm_tab -> Qs st -> Vo m0 st -> INV m0 ->
    exec_stmt function_entry2 G empty_env le0 m0 COPYIN t1 le1 m1 out1 ->
    exec_stmt function_entry2 G empty_env le1 m1 DLOOP t2 le2 m2 out2 ->
    exec_stmt function_entry2 G empty_env le2 m2 COPYOUT t3 le3 m3 out3 ->
    out1 = Out_normal /\ out2 = Out_normal /\ out3 = Out_normal
    /\ exists st', In st' vm_tab /\ Qs st' /\ Vo m3 st' /\ INV m3.
  Proof.
    intros Hk le0 m0 t1 le1 m1 out1 t2 le2 m2 out2 t3 le3 m3 out3 st Hst HQ HV HI X1 X2 X3.
    destruct (copyin _ _ _ _ _ _ _ X1 (Hinv_cur _ HI) HV) as (-> & HV1 & U1).
    pose proof (Hinv_frame _ _ HI U1) as HI1.
    destruct (dloop_done Hk _ _ _ _ _ _ X2 st Hst HQ HV1 HI1) as (-> & st2 & Hst2 & HQ2 & HV2 & HI2).
    destruct (copyout _ _ _ _ _ _ _ X3 (Hinv_cur _ HI2) HV2) as (-> & HV3 & U3).
    split; [ reflexivity | split; [ reflexivity | split; [ reflexivity | ] ] ].
    exact (ex_intro _ st2 (conj Hst2 (conj HQ2 (conj HV3 (Hinv_frame _ _ HI2 U3))))).
  Qed.

  (* ---- the whole REAL cur_obj_update (W1, 2026-11-07) ---- *)
  Lemma Vo_unch : forall (P : block -> Z -> Prop) m m1 st, Mem.unchanged_on P m m1 ->
    (forall z, P pool z) -> Vo m st -> Vo m1 st.
  Proof.
    intros P m m1 st U HP HV. unfold Vo, Vstk in *.
    destruct HV as ((b & Hb & Hl) & Hsi & Hk).
    split; [ exists b; split; [ exact Hb | ] | split ].
    - apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros; apply HP | exact Hl ].
    - apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros; apply HP | exact Hsi ].
    - intros j f Hj. pose proof (Hk j f Hj) as Hf.
      destruct f as [s0 i0 |];
        [ destruct Hf as (b0 & Hb0 & Hl0); exists b0; split; [ exact Hb0 | ]
        | destruct Hf as (c & Hl0); exists c ];
        (apply (Mem.load_unchanged_on _ _ _ _ _ _ _ U); [ intros; apply HP | exact Hl0 ]).
  Qed.

  Definition cou_env (b : block) : env := PTree.set BS._filler (b, tarray tuchar 4) empty_env.

  (* the code before the segment keeps INV and the slot's VM state.  Any
     temps: COU_PRE sets every temp it reads (objFlags, distanceFromMario) *)
  Definition pre_keep : Prop := forall b le m t le' m' out st,
    INV m -> Vo m st -> In st vm_tab ->
    exec_stmt function_entry2 G (cou_env b) le m (ObjLoop.app_seq COU_PRE Sskip) t le' m' out ->
    INV m' /\ Vo m' st.
  (* the code after it.  Any temps: COU_POST re-reads objFlags; the one
     temp it inherits, distanceFromMario, only picks a render-flag branch *)
  Definition post_keep : Prop := forall b le m t le' m' out st,
    INV m -> Vo m st -> In st vm_tab ->
    exec_stmt function_entry2 G (cou_env b) le m COU_POST t le' m' out ->
    INV m' /\ Vo m' st.
  (* freeing a block allocated after an INV state (the local filler[4])
     keeps INV *)
  Definition inv_free : Prop := forall m0 m b m', INV m0 -> ~ Mem.valid_block m0 b -> INV m ->
    Mem.free m b 0 4 = Some m' -> INV m'.

  Lemma cou_ag : forall bF y, y <> BS._filler ->
    (PTree.set BS._filler (bF, tarray tuchar 4) empty_env) ! y = empty_env ! y.
  Proof. intros bF y Hy. rewrite PTree.gso by exact Hy. reflexivity. Qed.

  (* THE OBJECT UPDATE: the REAL cur_obj_update, from a slot whose own cells
     hold a reachable VM state, keeps INV and leaves the slot's cells in a
     reachable state -- given row_keeps (the dispatch loop's premises), the
     code around the segment (pre_keep / post_keep) and inv_free *)
  Theorem cou_real : row_keeps -> pre_keep -> post_keep -> inv_free ->
    forall m t m' vr st, In st vm_tab -> Qs st -> Vo m st -> INV m ->
    eval_funcall function_entry2 G m (Internal BS.f_cur_obj_update) [] t m' vr ->
    exists st', In st' vm_tab /\ Qs st' /\ Vo m' st' /\ INV m'.
  Proof.
    intros Hk Hpre Hpost Hfree m t m' vr st Hst HQ HV HI H.
    destruct cou_nofv as (N1 & N2 & N3).
    inv H.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      cbn [BS.f_cur_obj_update fn_vars] in Ha; inv Ha end.
    match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
    match goal with A1 : Mem.alloc m 0 _ = (?M1, ?b1) |- _ =>
      rename b1 into bF, A1 into HA, M1 into mA end.
    assert (HnF : ~ Mem.valid_block m bF) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA).
    pose proof (Mem.alloc_unchanged_on (fun _ _ => True) _ _ _ _ _ HA) as UA.
    assert (HIA : INV mA) by exact (Hinv_frame _ _ HI (Mem.unchanged_on_implies _ _ _ _ UA (fun _ _ _ _ => I))).
    pose proof (Vo_unch _ _ _ _ UA (fun _ => I) HV) as HVA.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into X end.
    rewrite cou_split in X.
    apply ObjLoop.app_seq_inv in X as [(q1 & qe1 & qm1 & q2 & XP & XR) | ((q1 & XP) & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ XP cou_plain)) ].
    destruct (Hpre bF _ _ _ _ _ _ st HIA HVA Hst XP) as (HI1 & HV1).
    (* the segment, in the empty environment *)
    apply RA.seq_inv in XR as [(r1 & re1 & rm1 & r2 & Y1 & Y2) | (Y1 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y1 eq_refl)) ].
    apply (EnvSwap.exec_swap _ _ _ _ _ _ _ _ _ _ _ Y1 (cou_ag bF)) in N1.
    apply RA.seq_inv in Y2 as [(r3 & re3 & rm3 & r4 & Y3 & Y4) | (Y3 & Xn)].
    2: { exfalso. destruct (copyin _ _ _ _ _ _ _ N1 (Hinv_cur _ HI1) HV1) as (_ & HVc & Uc).
         apply (EnvSwap.exec_swap _ _ _ _ _ _ _ _ _ _ _ Y3 (cou_ag bF)) in N2.
         destruct (dloop_done Hk _ _ _ _ _ _ N2 st Hst HQ HVc (Hinv_frame _ _ HI1 Uc)) as (Eo & _).
         exact (Xn Eo). }
    apply (EnvSwap.exec_swap _ _ _ _ _ _ _ _ _ _ _ Y3 (cou_ag bF)) in N2.
    apply RA.seq_inv in Y4 as [(r5 & re5 & rm5 & r6 & Y5 & Y6) | (Y5 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y5 eq_refl)) ].
    apply (EnvSwap.exec_swap _ _ _ _ _ _ _ _ _ _ _ Y5 (cou_ag bF)) in N3.
    destruct (seg Hk _ _ _ _ _ _ _ _ _ _ _ _ _ _ st Hst HQ HV1 HI1 N1 N2 N3)
      as (_ & _ & _ & st' & Hst' & HQ' & HV2 & HI2).
    destruct (Hpost bF _ _ _ _ _ _ st' HI2 HV2 Hst' Y6) as (HI3 & HV3).
    (* the local is freed *)
    match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
      change (Mem.free_list M [(bF, 0, 4)] = Some R) in Hf; cbn [Mem.free_list] in Hf;
      destruct (Mem.free M bF 0 4) as [M5 |] eqn:F1; [ injection Hf as <- | discriminate Hf ] end.
    assert (Hpf : pool <> bF).
    { intros E. subst bF. apply HnF. destruct HV as ((b & _ & Hl) & _).
      pose proof (Mem.load_valid_access _ _ _ _ _ Hl) as Ha. eapply Mem.valid_access_valid_block.
      eapply Mem.valid_access_implies; [ exact Ha | constructor ]. }
    exists st'. split; [ exact Hst' | split; [ exact HQ' | split ] ].
    - refine (Vo_unch (fun b _ => b <> bF) _ _ _ _ (fun _ => Hpf) HV3).
      eapply Mem.free_unchanged_on; [ exact F1 | ]. intros i _ Hn. exact (Hn eq_refl).
    - exact (Hfree m _ bF _ HI HnF HI3 F1).
  Qed.
End Link.
