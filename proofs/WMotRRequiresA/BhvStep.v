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
(*    the obj_w clause the dispatch theorem will need (OPEN);             *)
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
(* loop of cur_obj_update; the scr_ok obj_w clause; then narrowing        *)
(* Hobj_step_rest by it.                                                  *)
(* ======================================================================= *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require behavior_script memory.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjWorld ObjPhase ObjLoop ObjCensus.
Import ListNotations.
Local Open Scope Z_scope.

Module BS := SM64.Generated.behavior_script.
Module OW := ObjWorld.
Module RA := RenderAnim.

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

(* ---- 2. the script content (a premise here: the script blocks hold their
   initializers) and the VM cells ---- *)
Section Cells.
  Variable G : genv.

  Definition init_val (d : init_data) (v : val) : Prop :=
    match d with
    | Init_int32 n => v = Vint n
    | Init_addrof t o => exists bt, Genv.find_symbol G t = Some bt /\ v = Vptr bt o
    | _ => True
    end.

  Definition scr_ok (m : mem) : Prop :=
    forall s bs i d, Genv.find_symbol G s = Some bs -> In s (map v_s vm_tab) ->
      nth_error (words s) i = Some d ->
      exists v, Mem.load Mint32 m bs (4 * Z.of_nat i) = Some v /\ init_val d v.

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

(* ---- 2b. scr_ok as a checkable clause (the planned obj_w clause SCRIPTS;
   held until the next StartTerrain rebuild): the scripts the VM can
   reach, each cell against its initializer ---- *)
Fixpoint sdedup (l : list ident) : list ident :=
  match l with
  | [] => []
  | x :: l' => let t := sdedup l' in if existsb (Pos.eqb x) t then t else x :: t
  end.
Lemma sdedup_in : forall x l, In x l -> In x (sdedup l).
Proof.
  intros x l. induction l as [| y l IH]; intros H; [ destruct H | ].
  cbn [sdedup]. destruct (existsb (Pos.eqb y) (sdedup l)) eqn:E.
  - destruct H as [<- | H]; [ | exact (IH H) ].
    apply existsb_exists in E as (z & Hz & Ez). apply Pos.eqb_eq in Ez. subst z. exact Hz.
  - destruct H as [<- | H]; [ left; reflexivity | right; exact (IH H) ].
Qed.


Section ScrCheck.
  Variable G : genv.

  Definition cell_b (m : mem) (b : block) (i : nat) (d : init_data) : bool :=
    match d with
    | Init_int32 n =>
        match Mem.load Mint32 m b (4 * Z.of_nat i) with Some (Vint n') => Int.eq n n' | _ => false end
    | Init_addrof t o =>
        match Genv.find_symbol G t, Mem.load Mint32 m b (4 * Z.of_nat i) with
        | Some bt, Some (Vptr b' o') => Pos.eqb bt b' && Ptrofs.eq o o'
        | _, _ => false
        end
    | _ => match Mem.load Mint32 m b (4 * Z.of_nat i) with Some _ => true | None => false end
    end.

  Fixpoint cells_b (m : mem) (b : block) (i : nat) (l : list init_data) : bool :=
    match l with [] => true | d :: l' => cell_b m b i d && cells_b m b (S i) l' end.

  (* the check over a symbol list l; used with l := sdedup (map v_s vm_tab),
     written out (PERF TRAP: never name that list as a constant -- the
     kernel's Qed then unfolds vm_tab when converting it) *)
  Definition scr_b_l (l : list ident) (m : mem) : bool :=
    forallb (fun s => match Genv.find_symbol G s with
                      | Some b => cells_b m b 0 (words s) | None => false end) l.

  Lemma cell_b_sound : forall m b i d, cell_b m b i d = true ->
    exists v, Mem.load Mint32 m b (4 * Z.of_nat i) = Some v /\ init_val G d v.
  Proof.
    intros m b i d H. unfold cell_b in H. revert H.
    generalize (4 * Z.of_nat i) as z. intros z H. destruct d;
      try (destruct (Mem.load Mint32 m b z) as [v|]; [ exists v; split; [ reflexivity | exact I ] | discriminate H ]).
    - destruct (Mem.load Mint32 m b z) as [[]|]; try discriminate H.
      apply Int.same_if_eq in H. subst. eexists; split; reflexivity.
    - destruct (Genv.find_symbol G i0) as [bt|] eqn:Eb; [ | discriminate H ].
      destruct (Mem.load Mint32 m b z) as [[]|]; try discriminate H.
      apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. apply Ptrofs.same_if_eq in H2.
      subst. eexists; split; [ reflexivity | exists b0; auto ].
  Qed.

  Lemma cells_b_sound : forall m b l i, cells_b m b i l = true ->
    forall k d, nth_error l k = Some d ->
      exists v, Mem.load Mint32 m b (4 * Z.of_nat (i + k)) = Some v /\ init_val G d v.
  Proof.
    intros m b l. induction l as [| d0 l IH]; intros i H k d Hk; [ destruct k; discriminate Hk | ].
    cbn [cells_b] in H. apply andb_prop in H as [H1 H2].
    destruct k as [|k]; cbn in Hk.
    - injection Hk as <-. rewrite Nat.add_0_r. exact (cell_b_sound _ _ _ _ H1).
    - replace (i + S k)%nat with (S i + k)%nat by lia. exact (IH _ H2 k d Hk).
  Qed.

  Lemma scr_b_l_sound : forall l, (forall s, In s (map v_s vm_tab) -> In s l) ->
    forall m, scr_b_l l m = true -> scr_ok G m.
  Proof.
    intros l Hl m H s bs i d Hs Hin Hd. unfold scr_b_l in H.
    pose proof (proj1 (forallb_forall _ l) H s (Hl s Hin)) as H1. clear H.
    cbv beta in H1. rewrite Hs in H1.
    exact (cells_b_sound _ _ _ _ H1 i d Hd).
  Qed.

  (* SOUND: the deduplicated check over every script the VM can reach *)
  Theorem scr_b_sound : forall m, scr_b_l (sdedup (map v_s vm_tab)) m = true -> scr_ok G m.
  Proof. exact (scr_b_l_sound (sdedup (map v_s vm_tab)) (fun s => sdedup_in s (map v_s vm_tab))). Qed.
End ScrCheck.

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

Lemma succs_delay : forall st w, word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 1 ->
  succs st = if Nat.ltb (List.length (words (v_s st))) (v_i st + 1) then None else
    Some [st; at_ st (v_s st) (v_i st + 1) (v_k st)].
Proof. intros st w Hw Ho. unfold succs. cbv zeta. rewrite Hw, Ho. reflexivity. Qed.

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

  Lemma fun_bs : forall id f, (prog_defmap BS.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_behavior_script lp H12)). Qed.
  Lemma fun_mem : forall id f, (prog_defmap memory.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_memory lp H12)). Qed.

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

  Variables go pool : block.
  Variable oc : Z.
  Hypothesis Hgo : Genv.find_symbol G BS._gCurrentObject = Some go.
  Hypothesis Hoc : 0 <= oc <= 40960.
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

  Lemma cur_store : forall ch m z v m', Mem.store ch m pool z v = Some m' -> cur m -> cur m'.
  Proof.
    intros ch m z v m' Hs Hc. unfold cur. rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Hc | ].
    left. intro E. exact (Hpg (eq_sym E)).
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

  (* ONE COMMAND: the handler BehaviorCmdTable names for opcode op, called
     at a reachable state whose cells hold it, moves the cells to a VM
     successor, keeps INV, and returns BHV_PROC_CONTINUE (0) or _BREAK (1) *)
  Definition cmd_row_op (op : Z) : Prop :=
    forall m st w id hb fd t m' vr, In st vm_tab -> V m st -> INV m ->
      word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = op ->
      nth_error ObjCensus.cmd_handlers (Z.to_nat op) = Some id ->
      Genv.find_symbol G id = Some hb -> Genv.find_funct G (Vptr hb Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 G m fd [] t m' vr ->
      exists l st', succs st = Some l /\ In st' l /\ V m' st' /\ INV m'
        /\ (vr = Vint (Int.repr 0) \/ vr = Vint (Int.repr 1)).

  Hypothesis Hinv : forall m, INV m -> scr_ok G m /\ OW.cmdtab_ok G m.

  Lemma disp_step : forall le m t le1 m1 out1 st, (forall op, cmd_row_op op) ->
    exec_stmt function_entry2 G empty_env le m DISP t le1 m1 out1 ->
    In st vm_tab -> V m st -> INV m ->
    out1 = Out_normal /\ exists st1 vr, In st1 vm_tab /\ V m1 st1 /\ INV m1
      /\ le1 ! BS._bhvProcResult = Some vr /\ (vr = Vint (Int.repr 0) \/ vr = Vint (Int.repr 1)).
  Proof.
    intros le m t le1 m1 out1 st Hrow H Hst HV HI.
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
    destruct (Hrow _ _ _ _ _ _ _ _ _ _ Hst HV0 HI Hw eq_refl Eid Hhb Hff Hx)
      as (l' & st1 & Hl' & Hin & HV1 & HI1 & Hvr).
    apply RA.set_inv in Y2 as (vr & Evr & -> & -> & ->).
    apply RA.ev_temp in Evr. cbn [set_opttemp] in Evr. rewrite PTree.gss in Evr.
    injection Evr as <-.
    split; [ reflexivity | ].
    exists st1, vres. split; [ exact (vm_succ_in st l' st1 Hst Hl' Hin) | ].
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
    forall st, In st vm_tab -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ V m' st' /\ INV m'.
  Proof.
    intros Hrow le m t le' m' out H.
    remember empty_env as e0 eqn:Ee. remember DLOOP as S eqn:ES.
    induction H; intros st0 Hst HV HI; try discriminate ES; unfold DLOOP in ES; injection ES as E1 E2; subst.
    - destruct (disp_step _ _ _ _ _ _ _ Hrow H Hst HV HI) as (-> & _). inv H0.
    - destruct (disp_step _ _ _ _ _ _ _ Hrow H Hst HV HI) as (_ & st1 & vr & Hst1 & HV1 & HI1 & Hv & Hvr).
      destruct (dchk _ _ _ _ _ _ _ H1 Hv Hvr) as (-> & [(_ & ->) | (_ & ->)]); inv H2.
      split; [ reflexivity | exact (ex_intro _ st1 (conj Hst1 (conj HV1 HI1))) ].
    - destruct (disp_step _ _ _ _ _ _ _ Hrow H Hst HV HI) as (_ & st1 & vr & Hst1 & HV1 & HI1 & Hv & Hvr).
      destruct (dchk _ _ _ _ _ _ _ H1 Hv Hvr) as (-> & [(_ & _) | (_ & E)]); [ | discriminate E ].
      exact (IHexec_stmt3 eq_refl eq_refl st1 Hst1 HV1 HI1).
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
    intros op f rc Hh m st w id hb fd t m' vr Hst HV HI Hw Ho Hid Hhb Hfd Hev.
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
    forall st, In st vm_tab -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ V m' st' /\ INV m'.
  Proof.
    intros Hrest. apply dloop. intros op.
    destruct (in_dec Z.eq_dec op ctl_ops) as [Hin | Hn]; [ exact (ctl_rows op Hin) | exact (Hrest op Hn) ].
  Qed.

  (* a row for an opcode the reachable VM never executes holds vacuously *)
  Lemma unused_row : forall op, ~ In op used_ops -> cmd_row_op op.
  Proof.
    intros op Hu m st w id hb fd t m' vr Hst _ _ Hw Ho. exfalso. apply Hu.
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
    forall st, In st vm_tab -> V m st -> INV m ->
    out = Out_normal /\ exists st', In st' vm_tab /\ V m' st' /\ INV m'.
  Proof.
    intros Hrest. apply dloop_ctl. intros op Hn.
    destruct (in_dec Z.eq_dec op used_ops) as [Hu | Hu]; [ exact (Hrest op Hu Hn) | exact (unused_row op Hu) ].
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
     holding a reachable state, keeping INV -- given the used rows *)
  Theorem seg : (forall op, In op used_ops -> ~ In op ctl_ops -> cmd_row_op op) ->
    forall le0 m0 t1 le1 m1 out1 t2 le2 m2 out2 t3 le3 m3 out3 st,
    In st vm_tab -> Vo m0 st -> INV m0 ->
    exec_stmt function_entry2 G empty_env le0 m0 COPYIN t1 le1 m1 out1 ->
    exec_stmt function_entry2 G empty_env le1 m1 DLOOP t2 le2 m2 out2 ->
    exec_stmt function_entry2 G empty_env le2 m2 COPYOUT t3 le3 m3 out3 ->
    out1 = Out_normal /\ out2 = Out_normal /\ out3 = Out_normal
    /\ exists st', In st' vm_tab /\ Vo m3 st' /\ INV m3.
  Proof.
    intros Hrows le0 m0 t1 le1 m1 out1 t2 le2 m2 out2 t3 le3 m3 out3 st Hst HV HI X1 X2 X3.
    destruct (copyin _ _ _ _ _ _ _ X1 (Hinv_cur _ HI) HV) as (-> & HV1 & U1).
    pose proof (Hinv_frame _ _ HI U1) as HI1.
    destruct (dloop_used Hrows _ _ _ _ _ _ X2 st Hst HV1 HI1) as (-> & st2 & Hst2 & HV2 & HI2).
    destruct (copyout _ _ _ _ _ _ _ X3 (Hinv_cur _ HI2) HV2) as (-> & HV3 & U3).
    split; [ reflexivity | split; [ reflexivity | split; [ reflexivity | ] ] ].
    exact (ex_intro _ st2 (conj Hst2 (conj HV3 (Hinv_frame _ _ HI2 U3)))).
  Qed.
End Link.
